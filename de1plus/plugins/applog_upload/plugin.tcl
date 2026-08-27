# applog_upload -- uploads the de1app's own runtime logs to the Decent server so
# support can look at what a given machine has been doing. Companion to the
# shot_upload plugin: it reuses the same linked-Decent-account credentials, the
# same machine serial, and the same TLS-pinned POST path.
#
# Once an hour (independent of machine state) it reads the app's log files from
# disk -- log.txt plus the rotated log.txt.1 .. log.txt.10 -- picks out the lines
# newer than the last successful upload (by each line's own timestamp), and POSTs
# them to /support/api/applog_upload. It does NOT modify logging.tcl; it only
# reads the files logging.tcl already writes. A watermark (last_upload_ts) is
# persisted so each run sends only what is new; the very first run sends the past
# 24h.
#
# Uploads go to the live server (https://decentespresso.com); see _server_base to
# point at a dev server.

set plugin_name "applog_upload"

namespace eval ::plugins::${plugin_name} {
    variable author "Decent"
    variable contact "john@decentespresso.com"
    variable version 0.1
    variable description "Upload this app's logs to your Decent account for support."
    variable name "App Log Upload"

    variable settings
    array set settings {}

    # Hourly.
    variable interval_ms 3600000
    # Reachability-probe scratch (socket -> connect result).
    variable _reach
    array set _reach {}
}

proc ::plugins::applog_upload::_init_settings {} {
    variable settings
    # On by default: enabling this (opt-in) plugin is the affirmative choice, and
    # with no linked Decent account it simply no-ops.
    if {![info exists settings(auto_upload)]}        { set settings(auto_upload) 1 }
    # Epoch of the newest log line successfully uploaded so far. Empty until the
    # first upload; the first run then sends the past 24h.
    if {![info exists settings(last_upload_ts)]}     { set settings(last_upload_ts) {} }
    if {![info exists settings(last_upload_result)]} { set settings(last_upload_result) {} }
}

# Target server. Same caveat as shot_upload: the app can't tell dev from prod, so
# this points at the live server. For local testing, swap in the dev URL.
proc ::plugins::applog_upload::_server_base {} {
    return "https://decentespresso.com"
    # dev: return "http://localhost:8000"
}

proc ::plugins::applog_upload::_account_linked {} {
    return [expr {[ifexists ::settings(decent_login_email)] ne "" &&
                  [ifexists ::settings(decent_login_password_encrypted)] ne ""}]
}

# Quick non-blocking TCP probe of the target server, so an hourly tick with Wi-Fi
# off returns fast instead of stalling on connect. (Copied from shot_upload.)
proc ::plugins::applog_upload::_server_reachable {} {
    set base [_server_base]
    if {![regexp {^(https?)://([^/:]+)(?::([0-9]+))?} $base -> scheme host port]} { return 0 }
    if {$port eq ""} { set port [expr {$scheme eq "https" ? 443 : 80}] }
    set ok 0
    if {![catch {socket -async $host $port} sock]} {
        variable _reach
        set _reach($sock) ""
        fileevent $sock writable [list set ::plugins::applog_upload::_reach($sock) writable]
        set aid [after 4000 [list set ::plugins::applog_upload::_reach($sock) timeout]]
        vwait ::plugins::applog_upload::_reach($sock)
        after cancel $aid
        if {$_reach($sock) eq "writable" && [fconfigure $sock -error] eq ""} { set ok 1 }
        catch { close $sock }
        unset -nocomplain _reach($sock)
    }
    return $ok
}

# Machine identity for provenance -- same source of truth as shot_upload.
proc ::plugins::applog_upload::machine_identity {} {
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

# --- log file reading (from disk; logging.tcl is not touched) -------------------

proc ::plugins::applog_upload::_log_dir {} {
    if {[llength [info commands data_directory]]} { return [data_directory] }
    if {[info exists ::home]} { return $::home }
    return "."
}

# Rotated logs, OLDEST first: log.txt.10 .. log.txt.1, then the current log.txt.
# (logging.tcl rotates log.txt -> log.txt.1 and bumps the numbers up; higher
# number = older. Reading oldest->newest keeps the assembled output chronological.)
proc ::plugins::applog_upload::_ordered_log_files {} {
    set dir  [_log_dir]
    set base [ifexists ::settings(logfile) "log.txt"]
    set files {}
    for {set n 10} {$n >= 1} {incr n -1} {
        set p [file join $dir "$base.$n"]
        if {[file exists $p]} { lappend files $p }
    }
    set cur [file join $dir $base]
    if {[file exists $cur]} { lappend files $cur }
    return $files
}

# Epoch (LOCAL time) of a log line's "YYYY-MM-DD HH:MM:SS.mmm" prefix, or "" if
# the line has no such prefix (a wrapped continuation line).
proc ::plugins::applog_upload::_line_ts {line} {
    if {[regexp {^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\.[0-9]{3} } $line -> stamp]} {
        set ts ""
        catch { set ts [clock scan $stamp] }
        return $ts
    }
    return ""
}

# The server rejects bodies over ~1 MB (413). Cap each upload's payload so a
# first run or a backlog (which can include a multi-MB rotated log) is drained
# across successive ticks instead of failing forever. soft_cap stops adding once
# the body is big enough -- but finishes the current whole second, so a second's
# worth of lines is never split (the watermark advances a clean second at a time);
# hard_cap is a safety stop for a pathological single-second burst.
namespace eval ::plugins::applog_upload {
    variable soft_cap 700000
    variable hard_cap 950000
}

# Collect log lines whose (effective) timestamp is newer than $since, oldest
# first, up to the size cap. A line without its own timestamp inherits the
# previous line's, so a multi-line message is kept or dropped as a unit. Returns
# {text <str> maxts <epoch> count <int> capped <0|1>}; `capped` means the cap was
# hit and more lines remain for the next tick.
proc ::plugins::applog_upload::gather_since {since} {
    variable soft_cap
    variable hard_cap
    set out ""
    set maxts $since
    set count 0
    set capped_at ""     ;# the second at which we crossed soft_cap
    set capped 0
    set stop 0
    foreach f [_ordered_log_files] {
        if {[catch {open $f r} fh]} continue
        catch { fconfigure $fh -encoding utf-8 }
        set cur_ts 0
        while {[gets $fh line] >= 0} {
            set t [_line_ts $line]
            if {$t ne ""} { set cur_ts $t }
            if {$cur_ts > $since} {
                # Once soft-capped, keep taking lines of the same second (so the
                # second isn't split), then stop when the timestamp advances.
                if {$capped_at ne "" && $cur_ts > $capped_at} { set stop 1; break }
                append out $line "\n"
                if {$cur_ts > $maxts} { set maxts $cur_ts }
                incr count
                set len [string length $out]
                if {$capped_at eq "" && $len >= $soft_cap} { set capped_at $cur_ts; set capped 1 }
                if {$len >= $hard_cap} { set stop 1; set capped 1; break }
            }
        }
        catch { close $fh }
        if {$stop} break
    }
    return [list text $out maxts $maxts count $count capped $capped]
}

# --- JSON + POST ---------------------------------------------------------------

# Escape a Tcl string as a JSON string literal (with surrounding quotes). Strips
# the rare control chars json2dict would reject; keeps \t \n \r (escaped).
proc ::plugins::applog_upload::_json_str {s} {
    set s [regsub -all {[\x00-\x08\x0b\x0e-\x1f]} $s ""]
    return "\"[string map [list \\ \\\\ \" \\\" \n \\n \r \\r \t \\t \f \\f] $s]\""
}

proc ::plugins::applog_upload::_build_json {id text since maxts} {
    set sn [expr {[dict exists $id serialNumber] ? [dict get $id serialNumber] : ""}]
    set fw [expr {[dict exists $id firmwareVersion] ? [dict get $id firmwareVersion] : ""}]
    set ver ""; catch { set ver [package version de1app] }
    set now [clock seconds]
    return "{\"app\":\"de1app\",\"appVersion\":[_json_str $ver],\"sn\":[_json_str $sn],\"firmwareVersion\":[_json_str $fw],\"uploadedAt\":$now,\"fromTs\":$since,\"toTs\":$maxts,\"log\":[_json_str $text]}"
}

# POST a JSON body with the linked account's HTTP Basic credentials. Returns
# {ncode <int> body <str>}; throws on transport failure. (Copied from shot_upload:
# libcurl preferred, ::http::geturl fallback, TLS pinned to allcerts.pem.)
proc ::plugins::applog_upload::post_json {url json} {
    set email   [ifexists ::settings(decent_login_email)]
    set pw      [ifexists ::settings(decent_login_password_encrypted)]
    set auth    "Basic [binary encode base64 $email:$pw]"
    set headers [list "Content-Type: application/json; charset=utf-8" "Authorization: $auth"]

    if {![catch {package require TclCurl}]} {
        set resp ""
        set hdl [curl::init]
        set code 0
        if {[catch {
            $hdl configure -url $url -post 1 -postfields $json \
                -httpheader $headers -bodyvar resp \
                -useragent "de1app-applog-upload" \
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

    package require http
    if {[string match -nocase "https:*" $url]} {
        package require tls
        catch { ::http::register https 443 ::tls::socket }
    }
    set tok [::http::geturl $url \
        -method POST \
        -type "application/json; charset=utf-8" \
        -query $json \
        -headers [list Authorization $auth] \
        -timeout 30000]
    set ncode [::http::ncode $tok]
    set rbody [::http::data $tok]
    ::http::cleanup $tok
    return [dict create ncode $ncode body $rbody]
}

# --- the hourly job ------------------------------------------------------------

# Returns 1 if a size-capped chunk was uploaded and more log remains to send
# (so the caller should tick again soon), else 0.
proc ::plugins::applog_upload::upload_logs {} {
    variable settings
    _init_settings

    if {$settings(auto_upload) != 1} { return 0 }
    if {![_account_linked]} {
        msg -INFO "applog_upload: no Decent account linked; skipping"
        return 0
    }
    set id [machine_identity]
    if {![dict exists $id serialNumber]} {
        msg -INFO "applog_upload: machine serial not known yet; skipping"
        return 0
    }
    if {![_server_reachable]} {
        msg -INFO "applog_upload: Decent server not reachable; skipping this hour"
        return 0
    }

    set since $settings(last_upload_ts)
    if {![string is integer -strict $since] || $since <= 0} {
        set since [expr {[clock seconds] - 86400}]   ;# first run: past 24h
    }

    set g      [gather_since $since]
    set text   [dict get $g text]
    set count  [dict get $g count]
    set maxts  [dict get $g maxts]
    set capped [dict get $g capped]
    if {$count == 0} {
        msg -INFO "applog_upload: no new log lines since $since"
        return 0
    }

    set body [_build_json $id $text $since $maxts]
    if {[catch { set r [post_json "[_server_base]/support/api/applog_upload" $body] } err]} {
        set settings(last_upload_result) "error: $err (retry next hour)"
        msg -WARNING "applog_upload: POST failed: $err"
        return 0
    }

    set code [dict get $r ncode]
    set rbody [dict get $r body]
    if {$code >= 200 && $code < 300} {
        set settings(last_upload_ts) $maxts
        set more [expr {$capped ? " (more pending)" : ""}]
        set settings(last_upload_result) "uploaded $count line(s)$more [clock format [clock seconds] -format {%Y-%m-%d %H:%M}]"
        catch { plugins save_settings applog_upload }
        msg -INFO "applog_upload: uploaded $count line(s)$more -> $rbody"
        return $capped
    } elseif {$code == 401 || $code == 403} {
        set settings(last_upload_result) "rejected (http $code)"
        msg -ERROR "applog_upload: upload rejected (http $code): $rbody"
        return 0
    } else {
        set settings(last_upload_result) "http $code (retry next hour)"
        msg -WARNING "applog_upload: upload failed (http $code); will retry next hour"
        return 0
    }
}

proc ::plugins::applog_upload::tick {} {
    variable interval_ms
    set more 0
    catch { set more [upload_logs] }
    # If a capped chunk went up with a backlog behind it, drain the rest soon
    # instead of waiting the full hour.
    after [expr {$more ? 60000 : $interval_ms}] ::plugins::applog_upload::tick
}

proc ::plugins::applog_upload::main {} {
    _init_settings
    variable settings

    catch { plugins gui applog_upload [create_ui] }

    # Kick off the hourly cycle, letting the app settle after boot first.
    after 60000 ::plugins::applog_upload::tick

    msg -INFO "applog_upload plugin loaded (auto_upload=$settings(auto_upload) server=[_server_base])"
}

# --- settings page -------------------------------------------------------------

proc ::plugins::applog_upload::create_ui {} {
    _init_settings
    dui page add applog_upload_settings \
        -namespace ::plugins::applog_upload::applog_upload_settings \
        -bg_img settings_message.png -type fpdialog
    return "applog_upload_settings"
}

namespace eval ::plugins::applog_upload::applog_upload_settings {
    variable widgets
    array set widgets {}

    proc setup {} {
        variable widgets
        set page_name [namespace tail [namespace current]]

        # Done
        dui add dbutton $page_name 980 1210 1580 1410 -tags page_done \
            -label [translate "Done"] -label_pos {0.5 0.5} -label_font Helv_10_bold -label_fill "#fAfBff"

        # Title
        dui add dtext $page_name 1280 300 -text [translate "Upload App Logs to Decent"] \
            -font Helv_20_bold -width 1800 -fill "#444444" -anchor "center" -justify "center"

        # Decent account status -- tap to open the account-link page.
        dui add dtext $page_name 280 470 -tags account_status -font Helv_8 -width 1000 -fill "#4e85f4" -anchor "nw" -justify "left"
        dui add dbutton $page_name 260 445 1300 560 -tags account_link_btn -command [namespace current]::link_account

        # Auto-upload toggle
        dui add dcheckbox $page_name 280 640 -tags auto_upload \
            -textvariable ::plugins::applog_upload::settings(auto_upload) -fill "#444444" \
            -label [translate "Automatically upload my app logs each hour to help Decent support"] \
            -label_font Helv_8 -label_fill #4e85f4 -command [namespace current]::save_settings

        # Explanatory line
        dui add dtext $page_name 280 780 -width 2000 -font Helv_7 -fill "#7f7f7f" -anchor "nw" -justify "left" \
            -text [translate "Sends this app's log files (no personal data beyond your machine serial) so support can diagnose problems remotely."]

        # Upload-now (handy for support / testing)
        # Enabled/disabled look is set in `show`, based on whether an account is
        # linked (the button only works when logged in).
        dui add dbutton $page_name 280 900 880 1030 -tags upload_now \
            -label [translate "Upload now"] -label_font Helv_9 -label_fill "#000000" -shape rect -fill "#e6ecfb" -outline "#4e85f4" -width 2 -radius 20 \
            -command [namespace current]::upload_now

        # Last-upload status
        dui add dtext $page_name 280 1120 -tags last_result_label -text [translate "Last upload:"] -font Helv_8 -width 400 -fill "#444444"
        dui add dtext $page_name 620 1120 -tags last_result -font Helv_8 -width 1600 -fill "#4e85f4" -anchor "nw" -justify "left"
    }

    proc show {page_to_hide page_to_show} {
        catch { dui item config $page_to_show account_status -text [decent_login_status_show] }
        dui item config $page_to_show last_result -text [ifexists ::plugins::applog_upload::settings(last_upload_result)]

        # The Upload-now button only works when a Decent account is linked, so it
        # reads "Upload now" in black when logged in, and greys out to
        # "Upload now (disabled)" otherwise.
        if {[::plugins::applog_upload::_account_linked]} {
            catch { dui item config $page_to_show upload_now -label [translate "Upload now"] \
                -label_fill "#000000" -fill "#e6ecfb" -outline "#4e85f4" }
        } else {
            catch { dui item config $page_to_show upload_now -label [translate "Upload now (disabled)"] \
                -label_fill "#7f7f7f" -fill "#f0f0f0" -outline "#b0b0b0" }
        }
    }

    proc link_account {} {
        dui say [translate {Ok}] sound_button_in
        catch { dui page close_dialog }
        catch { decent_login_show }
    }

    proc upload_now {} {
        # Only works when logged in (no linked account -> the button is greyed out
        # and labelled "(disabled)"; guard here too so a stray tap does nothing).
        if {![::plugins::applog_upload::_account_linked]} { return }
        dui say [translate {Ok}] sound_button_in
        after 100 ::plugins::applog_upload::upload_logs
        after 1500 [list catch [list dui item config applog_upload_settings last_result \
            -text [ifexists ::plugins::applog_upload::settings(last_upload_result)]]]
    }

    proc save_settings {} {
        save_plugin_settings applog_upload
    }

    proc page_done {} {
        dui say [translate {Done}] sound_button_in
        save_plugin_settings applog_upload
        dui page close_dialog
    }
}
