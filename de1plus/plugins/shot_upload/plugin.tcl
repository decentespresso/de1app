# shot_upload -- uploads espresso shots to the Decent server in decaid JSON
# format, so they appear in the owner's Decent account (shot history + charts)
# and interoperate with decaid's own uploads.
#
# Phase 1: fire-after-shot auto-upload (convert the just-finished shot -> decaid
#   ShotRecord JSON via converter.tcl -> POST /support/api/shot_upload, HTTP Basic
#   with the linked Decent account -- same endpoint/auth the decaid plugin uses).
# Phase 2: an uploaded-ledger + a throttled backlog drain that runs ONLY while the
#   machine is asleep (idle), backfilling offline / pre-enable shots, with
#   exponential backoff and a per-shot attempt cap so a bad/unroutable shot is
#   given up on instead of retried forever.
# Phase 3: a settings page (auto-upload toggle, length threshold, tap-to-link the
#   Decent account, tap-to-open the shot history in a browser).
#
# Enabling this (opt-in) plugin turns auto-upload on by default; it no-ops when
# no Decent account is linked. Uploads go to the live server
# (https://decentespresso.com); see _server_base to point at a dev server.

set plugin_name "shot_upload"

namespace eval ::plugins::${plugin_name} {
    variable author "Decent"
    variable contact "john@decentespresso.com"
    variable version 0.4
    variable description "Upload espresso shots to your Decent account."
    variable name "Shot Upload"

    variable settings
    array set settings {}

    # Backlog-drain state.
    variable draining 0
    variable drain_queue {}
    variable drain_backoff 2000
    # Give up on a shot after this many failed upload attempts (across sleeps).
    variable max_attempts 5
    # Reachability-probe scratch (socket -> connect result).
    variable _reach
    array set _reach {}
}

# Load the converter procs (::plugins::shot_upload::convert / convert_data / ...).
source [file join [file dirname [info script]] converter.tcl]

proc ::plugins::shot_upload::_init_settings {} {
    variable settings
    # On by default: enabling this (already opt-in) plugin is the affirmative
    # choice, and with no linked Decent account it simply no-ops -- so it's safe.
    if {![info exists settings(auto_upload)]}        { set settings(auto_upload) 1 }
    # Skip flushes / accidental short pulls.
    if {![info exists settings(min_seconds)]}        { set settings(min_seconds) 5 }
    # espresso_clock of the last successfully-uploaded shot (fast in-session guard).
    if {![info exists settings(last_upload_clock)]}  { set settings(last_upload_clock) {} }
    if {![info exists settings(last_upload_result)]} { set settings(last_upload_result) {} }
}

# Target server. The de1app has no reliable way to tell a dev machine from a
# production one, so this always points at the live server. For local testing,
# temporarily swap in the dev URL below.
proc ::plugins::shot_upload::_server_base {} {
    return "https://decentespresso.com"
    # dev: return "http://localhost:8000"
}

proc ::plugins::shot_upload::_is_asleep {} {
    if {[catch {::de1::state::current_state} s]} { return 0 }
    return [expr {$s eq "Sleep"}]
}

# Quick TCP-connect probe of the target server so we don't burn a whole backlog's
# worth of failed attempts when Wi-Fi is simply off. Non-blocking with a short
# timeout; returns 0 fast when there's no network.
proc ::plugins::shot_upload::_server_reachable {} {
    set base [_server_base]
    if {![regexp {^(https?)://([^/:]+)(?::([0-9]+))?} $base -> scheme host port]} { return 0 }
    if {$port eq ""} { set port [expr {$scheme eq "https" ? 443 : 80}] }
    set ok 0
    if {![catch {socket -async $host $port} sock]} {
        variable _reach
        set _reach($sock) ""
        fileevent $sock writable [list set ::plugins::shot_upload::_reach($sock) writable]
        set aid [after 4000 [list set ::plugins::shot_upload::_reach($sock) timeout]]
        vwait ::plugins::shot_upload::_reach($sock)
        after cancel $aid
        if {$_reach($sock) eq "writable" && [fconfigure $sock -error] eq ""} { set ok 1 }
        catch { close $sock }
        unset -nocomplain _reach($sock)
    }
    return $ok
}

proc ::plugins::shot_upload::main {} {
    _init_settings
    variable settings

    # Settings page (Phase 3).
    catch { plugins gui shot_upload [create_ui] }

    # Fire the uploader after each flow completes (Phase 1).
    ::de1::event::listener::after_flow_complete_add [lambda {event_dict} {
        ::plugins::shot_upload::async_dispatch \
            [dict get $event_dict previous_state] \
            [dict get $event_dict this_state]
    }]

    # Drain the backlog when the machine goes to Sleep -- it's idle then (Phase 2).
    ::de1::event::listener::on_major_state_change_add [lambda {event_dict} {
        set ps [dict get $event_dict previous_state]
        set ts [dict get $event_dict this_state]
        if {$ts eq "Sleep" && $ps ne "Sleep"} {
            after 2000 ::plugins::shot_upload::drain_backlog
        }
    }]

    msg -INFO "shot_upload plugin loaded (auto_upload=$settings(auto_upload) server=[_server_base])"
}

proc ::plugins::shot_upload::async_dispatch {old new} {
    # Only after an espresso (not steam/hot-water/flush transitions).
    if {$old eq "Espresso"} {
        after 100 ::plugins::shot_upload::upload_current_shot
    }
}

# Machine identity for provenance. The serial recorded at shot time is the source
# of truth; convert_data also falls back to the shot's own settings(sn).
proc ::plugins::shot_upload::machine_identity {} {
    set d [dict create]
    if {[info exists ::settings(sn)] && $::settings(sn) ne "" && $::settings(sn) != 0} {
        dict set d serialNumber $::settings(sn)
    } elseif {[info exists ::de1(sn)] && $::de1(sn) ne ""} {
        dict set d serialNumber $::de1(sn)
    }
    if {[info exists ::de1(version)] && $::de1(version) ne ""} {
        dict set d firmwareVersion $::de1(version)
    }
    return $d
}

# POST a JSON body to the Decent support API with the linked account's HTTP Basic
# credentials. Returns {ncode <int> body <str>}; throws on transport failure.
#
# Uses libcurl (TclCurl) -- much lower CPU than ::http::geturl and it doesn't
# block the Tk event loop -- mirroring decent_http_get_to_file in updater.tcl.
# Falls back to ::http::geturl only if TclCurl is unavailable.
proc ::plugins::shot_upload::post_json {url json} {
    set email   [ifexists ::settings(decent_login_email)]
    set pw      [ifexists ::settings(decent_login_password_encrypted)]
    set auth    "Basic [binary encode base64 $email:$pw]"
    # Pass the Tcl string through as-is. Both transports below already encode it
    # as UTF-8 on the wire (TclCurl from the string rep, ::http from the charset
    # in -type), so pre-encoding it with [encoding convertto utf-8] gets it
    # encoded a SECOND time and every accented character ships as mojibake.
    set body    $json
    set headers [list "Content-Type: application/json; charset=utf-8" "Authorization: $auth"]

    if {![catch {package require TclCurl}]} {
        set resp ""
        set hdl [curl::init]
        set code 0
        if {[catch {
            $hdl configure -url $url -post 1 -postfields $body \
                -httpheader $headers -bodyvar resp \
                -useragent "de1app-shot-upload" \
                -connecttimeout 15 -timeout 30 -failonerror 0 -followlocation 1
            if {[string match -nocase "https:*" $url]} {
                set _ca "[homedir]/allcerts.pem"
                if {[file exists $_ca]} { $hdl configure -sslverifypeer 1 -cainfo $_ca }
            }
            $hdl perform
            set code [$hdl getinfo responsecode]
        } err]} {
            catch { $hdl cleanup }
            error $err
        }
        catch { $hdl cleanup }
        return [dict create ncode $code body $resp]
    }

    # Fallback: blocking ::http::geturl if libcurl is somehow unavailable.
    package require http
    if {[string match -nocase "https:*" $url]} {
        package require tls
        catch { ::http::register https 443 ::tls::socket }
    }
    set tok [::http::geturl $url \
        -method POST \
        -type "application/json; charset=utf-8" \
        -query $body \
        -headers [list Authorization $auth] \
        -timeout 15000]
    set ncode [::http::ncode $tok]
    set rbody [::http::data $tok]
    ::http::cleanup $tok
    return [dict create ncode $ncode body $rbody]
}

# Convert legacy .shot data + POST it. Returns {ncode body}; throws on transport
# error. Shared by the live path and the backlog drain.
proc ::plugins::shot_upload::_do_upload {legacy} {
    set json [::plugins::shot_upload::convert_data $legacy [machine_identity]]
    return [post_json "[_server_base]/support/api/shot_upload" $json]
}

proc ::plugins::shot_upload::_account_linked {} {
    return [expr {[ifexists ::settings(decent_login_email)] ne "" &&
                  [ifexists ::settings(decent_login_password_encrypted)] ne ""}]
}

proc ::plugins::shot_upload::_shot_filename_for_clock {clock} {
    return "[clock format $clock -format "%Y%m%dT%H%M%S"].shot"
}

# --- uploaded marker + ledger + attempt tracking (Phase 2) ---------------------
# The authoritative "uploaded" mark lives IN the .shot file: an
#   uploaded_to_decent <clock seconds>
# key appended on success, so the record itself records that it was uploaded and
# we don't depend on a sidecar file. The .tdb ledger is now just a fast cache of
# that fact (avoids re-reading every file each drain); it's rebuilt from the
# in-file markers if lost.
# attempts: dict filename -> failed-attempt count, so a shot that keeps failing
#           is retried a bounded number of times and then given up on (recorded
#           in the failed list) instead of retried on every Sleep forever.

proc ::plugins::shot_upload::_ledger_file   {} { return "[data_directory]/history/shots_uploaded_to_decent.tdb" }
proc ::plugins::shot_upload::_attempts_file {} { return "[data_directory]/history/shots_upload_attempts.tdb" }
proc ::plugins::shot_upload::_failed_file   {} { return "[data_directory]/history/shots_upload_failed.tdb" }

proc ::plugins::shot_upload::_read_list {f} {
    if {![file exists $f]} { return {} }
    if {[catch {read_file $f} d]} { return {} }
    return $d
}
proc ::plugins::shot_upload::_load_ledger {} { return [_read_list [_ledger_file]] }

proc ::plugins::shot_upload::_add_to_ledger {filename} {
    set l [_load_ledger]
    if {$filename ni $l} { lappend l $filename; catch { write_file [_ledger_file] $l } }
    _clear_attempts $filename
}

proc ::plugins::shot_upload::_load_attempts {} {
    set d [_read_list [_attempts_file]]
    if {[catch {dict size $d}]} { return {} }
    return $d
}
proc ::plugins::shot_upload::_bump_attempts {filename} {
    set d [_load_attempts]
    set n [expr {([dict exists $d $filename] ? [dict get $d $filename] : 0) + 1}]
    dict set d $filename $n
    catch { write_file [_attempts_file] $d }
    return $n
}
proc ::plugins::shot_upload::_clear_attempts {filename} {
    set d [_load_attempts]
    if {[dict exists $d $filename]} { dict unset d $filename; catch { write_file [_attempts_file] $d } }
}
proc ::plugins::shot_upload::_mark_failed {filename} {
    set l [_read_list [_failed_file]]
    if {$filename ni $l} { lappend l $filename; catch { write_file [_failed_file] $l } }
    # Also ledger it so the drain stops offering it.
    set led [_load_ledger]
    if {$filename ni $led} { lappend led $filename; catch { write_file [_ledger_file] $led } }
    _clear_attempts $filename
}

# Does this .shot content already carry the uploaded_to_decent marker?
proc ::plugins::shot_upload::_txt_uploaded {txt} {
    return [regexp {(^|\n)[ \t]*uploaded_to_decent[ \t]} $txt]
}

# Append `uploaded_to_decent <clock seconds>` to a history .shot file. Retries a
# few times if the file hasn't been written yet (the live path can beat the
# save-to-history writer). No-op if already marked.
proc ::plugins::shot_upload::_mark_shot_uploaded {filename {tries 5}} {
    set path "[data_directory]/history/$filename"
    if {![file exists $path]} {
        if {$tries > 0} {
            after 3000 [list ::plugins::shot_upload::_mark_shot_uploaded $filename [expr {$tries - 1}]]
        }
        return
    }
    if {[catch {read_file $path} txt]} { return }
    if {[_txt_uploaded $txt]} { return }
    catch { write_file $path "[string trimright $txt \n]\nuploaded_to_decent [clock seconds]\n" }
}

# --- live path (Phase 1) -------------------------------------------------------

proc ::plugins::shot_upload::upload_current_shot {} {
    variable settings
    _init_settings

    if {![info exists ::settings(espresso_clock)]} { return }
    set clock $::settings(espresso_clock)

    if {$settings(auto_upload) != 1} { return }
    if {$settings(last_upload_clock) eq $clock} { return }
    if {![_account_linked]} {
        msg -INFO "shot_upload: no Decent account linked; skipping upload"
        return
    }

    set fn [_shot_filename_for_clock $clock]
    if {$fn in [_load_ledger]} { set settings(last_upload_clock) $clock; return }

    set legacy [::shot::create_legacy]
    array set _a $legacy
    set dur 0
    catch { set dur [lindex $_a(espresso_elapsed) end] }
    if {![string is double -strict $dur]} { set dur 0 }
    if {$dur < $settings(min_seconds)} {
        msg -INFO "shot_upload: shot too short ($dur s < $settings(min_seconds) s); skipping"
        return
    }

    if {[catch { set r [_do_upload $legacy] } err]} {
        set settings(last_upload_result) "error: $err (will retry on Sleep)"
        msg -WARNING "shot_upload: POST failed: $err"
        return
    }

    set code [dict get $r ncode]
    set body [dict get $r body]
    if {$code >= 200 && $code < 300} {
        set settings(last_upload_clock) $clock
        set settings(last_upload_result) "uploaded [clock format $clock -format {%Y-%m-%d %H:%M}]"
        _add_to_ledger $fn
        _mark_shot_uploaded $fn
        catch { plugins save_settings shot_upload }
        msg -INFO "shot_upload: uploaded shot $clock -> $body"
    } elseif {$code >= 400 && $code < 500} {
        set settings(last_upload_result) "rejected (http $code)"
        msg -ERROR "shot_upload: upload rejected (http $code): $body"
    } else {
        set settings(last_upload_result) "http $code (will retry on Sleep)"
        msg -WARNING "shot_upload: upload failed (http $code); will retry on Sleep"
    }
}

# --- backlog drain (Phase 2) : upload history not yet in the ledger, ASLEEP ----

proc ::plugins::shot_upload::drain_backlog {} {
    variable draining
    variable drain_queue
    variable drain_backoff
    variable settings
    _init_settings

    if {$draining} { return }
    if {$settings(auto_upload) != 1} { return }
    if {![_account_linked]} { return }
    if {![_is_asleep]} { return }        ;# only drain while the machine is idle/asleep
    if {![_server_reachable]} {          ;# Wi-Fi off / no route: don't burn attempts
        msg -INFO "shot_upload: Decent server not reachable; skipping backlog drain"
        return
    }

    set histdir "[data_directory]/history"
    if {![file isdirectory $histdir]} { return }
    set all [glob -nocomplain -tails -directory $histdir *.shot]
    set ledger [_load_ledger]

    set drain_queue {}
    foreach f $all {
        if {$f in $ledger} continue
        # Not in the ledger cache -- consult the .shot file's own marker, which
        # is authoritative and survives ledger loss. If present, heal the cache.
        if {![catch {read_file "$histdir/$f"} t] && [_txt_uploaded $t]} {
            _add_to_ledger $f
            continue
        }
        lappend drain_queue $f
    }
    if {[llength $drain_queue] == 0} { return }

    set draining 1
    set drain_backoff 2000
    msg -INFO "shot_upload: backlog drain starting ([llength $drain_queue] shot(s))"
    _drain_next
}

proc ::plugins::shot_upload::_drain_next {} {
    variable draining
    variable drain_queue
    variable drain_backoff
    variable settings
    variable max_attempts

    # Stop cleanly if the machine woke up, the user disabled uploads, or we're done.
    if {$settings(auto_upload) != 1 || [llength $drain_queue] == 0 || ![_is_asleep]} {
        if {$draining && ![_is_asleep]} { msg -INFO "shot_upload: backlog paused (machine awake)" }
        set draining 0
        return
    }

    set f    [lindex $drain_queue 0]
    set path "[data_directory]/history/$f"

    # outcome: uploaded | done | skip-auth | network | count
    #   uploaded  -> 2xx: mark the .shot file + ledger + advance
    #   done      -> 4xx bad shot, or unreadable: ledger + advance (no upload mark)
    #   skip-auth -> 401/403: pause (login/ownership), not the shot's fault
    #   network   -> transport failure (Wi-Fi off, DNS, timeout): pause, NO count
    #   count     -> server 5xx: count toward the per-shot give-up budget
    set outcome "count"
    set txt ""
    # read_file (updater.tcl) opens with -translation binary, which in Tcl also
    # forces -encoding binary -- so it returns the file's raw BYTES, not characters.
    # A .shot file is UTF-8, so an accented title came back as its UTF-8 bytes read
    # as Latin-1 (e -> U+00C3 U+00A9), and post_json's [encoding convertto utf-8]
    # then encoded those AGAIN: "Rao Allonge" arrived at the server double-encoded.
    # The live path is unaffected because it uses ::shot::create_legacy, which is
    # already a proper Tcl string -- which is why only re-uploaded/backlog shots
    # were mangled. Decode here so both paths hand identical characters to
    # convert_data. (Mirrors converter.tcl's own reader, which uses -encoding utf-8.)
    if {[catch { set txt [encoding convertfrom utf-8 [read_file $path]] }]} {
        set outcome "done"                       ;# unreadable file: skip it
    } elseif {[string trim $txt] eq ""} {
        set outcome "done"
    } elseif {[catch { set r [_do_upload $txt] } err]} {
        set outcome "network"                    ;# transport error -> no attempt burned
        msg -WARNING "shot_upload: network error on $f: $err"
    } else {
        set code [dict get $r ncode]
        if {$code >= 200 && $code < 300} {
            set outcome "uploaded"
        } elseif {$code == 401 || $code == 403} {
            set outcome "skip-auth"
        } elseif {$code >= 400 && $code < 500} {
            set outcome "done"                   ;# permanently bad shot: don't retry
            msg -WARNING "shot_upload: backlog skipping $f (http $code)"
        } else {
            set outcome "count"                  ;# 5xx server error: retryable
        }
    }

    switch -- $outcome {
        uploaded {
            _mark_shot_uploaded $f               ;# write uploaded_to_decent into the .shot
            _add_to_ledger $f
            set drain_queue [lrange $drain_queue 1 end]
            set drain_backoff 2000
            after 800 ::plugins::shot_upload::_drain_next
        }
        done {
            _add_to_ledger $f
            set drain_queue [lrange $drain_queue 1 end]
            set drain_backoff 2000
            after 800 ::plugins::shot_upload::_drain_next
        }
        skip-auth {
            msg -WARNING "shot_upload: backlog paused (login/ownership); will resume later"
            set draining 0
        }
        network {
            # No connectivity: stop now and let the next Sleep retry -- crucially,
            # nothing is counted against the shot, so a Wi-Fi outage never uses up
            # a shot's attempt budget.
            msg -WARNING "shot_upload: backlog paused (network); resumes next Sleep"
            set draining 0
        }
        default {
            # Server responded with a retryable error. Count it; give up on this
            # shot after max_attempts (across sleeps) so one bad shot can't wedge
            # the queue.
            set n [_bump_attempts $f]
            if {$n >= $max_attempts} {
                msg -ERROR "shot_upload: giving up on $f after $n attempts"
                _mark_failed $f
                set drain_queue [lrange $drain_queue 1 end]
                set drain_backoff 2000
                after 800 ::plugins::shot_upload::_drain_next
            } else {
                set drain_backoff [expr {min($drain_backoff * 2, 300000)}]
                after $drain_backoff ::plugins::shot_upload::_drain_next
            }
        }
    }
}

# --- settings page (Phase 3) ---------------------------------------------------

proc ::plugins::shot_upload::create_ui {} {
    _init_settings
    dui page add shot_upload_settings \
        -namespace ::plugins::shot_upload::shot_upload_settings \
        -bg_img settings_message.png -type fpdialog
    return "shot_upload_settings"
}

namespace eval ::plugins::shot_upload::shot_upload_settings {
    variable widgets
    array set widgets {}

    proc setup {} {
        variable widgets
        set page_name [namespace tail [namespace current]]

        # Done
        dui add dbutton $page_name 980 1210 1580 1410 -tags page_done \
            -label [translate "Done"] -label_pos {0.5 0.5} -label_font Helv_10_bold -label_fill "#fAfBff"

        # Title
        dui add dtext $page_name 1280 300 -text [translate "Upload Shots to Decent"] \
            -font Helv_20_bold -width 1800 -fill "#444444" -anchor "center" -justify "center"

        # Decent account status -- tap to open the account-link page.
        dui add dtext $page_name 280 470 -tags account_status -font Helv_8 -width 1000 -fill "#4e85f4" -anchor "nw" -justify "left"
        dui add dbutton $page_name 260 445 1300 560 -tags account_link_btn -command [namespace current]::link_account

        # Where to view -- vertically aligned with the account link; tap opens a browser.
        dui add dtext $page_name 1350 470 -tags view_url -font Helv_8 -width 1000 -fill "#4e85f4" -anchor "nw" -justify "left" \
            -text [translate "See your shots at decentespresso.com/support/espressomachine"]
        dui add dbutton $page_name 1340 445 2400 620 -tags view_url_btn -command [namespace current]::view_shots

        # Auto-upload toggle
        dui add dcheckbox $page_name 280 640 -tags auto_upload \
            -textvariable ::plugins::shot_upload::settings(auto_upload) -fill "#444444" \
            -label [translate "Automatically upload each shot to my Decent account"] \
            -label_font Helv_8 -label_fill #4e85f4 -command [namespace current]::save_settings

        # Minimum shot seconds
        dui add entry $page_name 280 820 -tags min_seconds \
            -textvariable ::plugins::shot_upload::settings(min_seconds) -width 3 -font Helv_8 \
            -borderwidth 1 -bg #fbfaff -foreground #4e85f4 -relief flat -highlightthickness 1 -highlightcolor #000000 \
            -label [translate "Minimum shot seconds to upload (skips flushes)"] \
            -label_pos {280 760} -label_font Helv_8 -label_width 1200 -label_fill "#444444"
        bind $widgets(min_seconds) <Return> [namespace current]::save_settings

        # Last-upload status
        dui add dtext $page_name 280 980 -tags last_result_label -text [translate "Last upload:"] -font Helv_8 -width 400 -fill "#444444"
        dui add dtext $page_name 620 980 -tags last_result -font Helv_8 -width 1400 -fill "#4e85f4" -anchor "nw" -justify "left"
    }

    # Refreshed each time the page is shown.
    proc show {page_to_hide page_to_show} {
        catch { dui item config $page_to_show account_status -text [decent_login_status_show] }
        dui item config $page_to_show last_result -text [ifexists ::plugins::shot_upload::settings(last_upload_result)]
    }

    # Tap on the account status -> the existing "Link your Decent Espresso
    # Account" page (decent_login_show sets it up + navigates).
    proc link_account {} {
        dui say [translate {Ok}] sound_button_in
        catch { dui page close_dialog }
        catch { decent_login_show }
    }

    # Tap on "See your shots at ..." -> open it in the system browser.
    proc view_shots {} {
        dui say [translate {Ok}] sound_button_in
        catch { web_browser "https://decentespresso.com/support/espressomachine" }
    }

    proc save_settings {} {
        save_plugin_settings shot_upload
    }

    proc page_done {} {
        dui say [translate {Done}] sound_button_in
        save_plugin_settings shot_upload
        dui page close_dialog
    }
}
