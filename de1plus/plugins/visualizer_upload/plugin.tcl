package require http
package require tls
package require json
# zint may not be available in some standard Tcl/Tk distributions, for example on MacOS.
try {
    package require zint
} on error err {
    #msg -WARNING "::plugins::visualizer_upload can't generate QR codes: $err"
}

set plugin_name "visualizer_upload"

namespace eval ::plugins::${plugin_name} {
    variable author "Johanna Schander"
    variable contact "coffee-plugins@mimoja.de"
    variable version 2.0
    variable description "Upload and download shots to/from visualizer.coffee"
    variable name "Upload to visualizer"

    # Paint settings screen
    proc create_ui {} {
        set needs_save_settings 0

        # Create settings if non-existant
        if {[array size ::plugins::visualizer_upload::settings] == 0} {
            array set  ::plugins::visualizer_upload::settings {
                auto_upload 1
                visualizer_endpoint api/shots/upload
                visualizer_password {}
                visualizer_url visualizer.coffee
                visualizer_username {}
            }
            set needs_save_settings 1
        }
        if { ![info exists ::plugins::visualizer_upload::settings(last_upload_shot)] } {
            set ::plugins::visualizer_upload::settings(last_upload_shot) {}
            set ::plugins::visualizer_upload::settings(last_upload_result) {}
            set ::plugins::visualizer_upload::settings(last_upload_id) {}
            set ::plugins::visualizer_upload::settings(auto_upload_min_seconds) 6
            set ::plugins::visualizer_upload::settings(visualizer_browse_url) "https://visualizer.coffee/shots/<ID>"
            set needs_save_settings 1
        }
        if { ![info exists ::plugins::visualizer_upload::settings(last_action)] } {
            set ::plugins::visualizer_upload::settings(visualizer_download_url) "https://visualizer.coffee/api/shots/<ID>"
            set ::plugins::visualizer_upload::settings(last_download_result) {}
            set ::plugins::visualizer_upload::settings(last_download_id) {}
            set ::plugins::visualizer_upload::settings(last_download_shot_start) {}
            set ::plugins::visualizer_upload::settings(last_action) {}
        }
        if { ![info exists ::plugins::visualizer_upload::settings(download_by_code_url)] } {
            set ::plugins::visualizer_upload::settings(download_by_code_url) "https://visualizer.coffee/api/shots/shared?code=<ID>"
        }
        if { ![info exists ::plugins::visualizer_upload::settings(download_all_last_shared)] } {
            set ::plugins::visualizer_upload::settings(download_all_last_shared) "https://visualizer.coffee/api/shots/shared"
        }
        if { $needs_save_settings == 1 } {
            plugins save_settings visualizer_upload
        }

        dui page add visualizer_settings -namespace [namespace current]::visualizer_settings \
            -bg_img settings_message.png -type fpdialog

        return "visualizer_settings"
    }

    proc msg { msg } {
        catch {
            # a bad message migth cause an error here, so catching it
            ::msg [namespace current] {*}$msg
        }
    }

    # --- Uploading -------------------------------------------------------------------------------------------
    #
    # Uploads never block the UI (v2.0). Previously `upload` ran on the UI thread with up to 20 attempts of 8 s
    # each plus a blocking 1 s pause between them, freezing the screen for seconds normally and for minutes when
    # the network or visualizer.coffee was down. Now (same approach as the shot_upload plugin):
    #  - one non-blocking attempt right after each shot (decent_http_async in utils.tcl: libcurl multi interface,
    #    falling back to ::http with -command);
    #  - a shot that failed because of the network or a server error is queued, and the queue is retried only
    #    while the machine is asleep, with exponential backoff, giving up on a shot after max_attempts server
    #    errors. Network errors never count against a shot. Old history is never uploaded, only failed shots;
    #  - 401 (bad username/password) shows its toast once and pauses uploads until the credentials are saved
    #    again; any other 4xx means the shot itself was rejected, so it is not retried.

    # Shots waiting for a retry: dict <espresso clock seconds> -> <server-error attempts>, persisted in
    # [_pending_file] so it survives restarts.
    variable max_attempts 5
    # Never keep more than this many shots waiting (oldest dropped first).
    variable max_pending 50
    variable draining 0
    variable drain_backoff 2000
    # Set by a 401 this session; cleared when the credentials are saved again.
    variable auth_failed 0

    proc _pending_file {} { return "[data_directory]/history/visualizer_upload_pending.tdb" }

    proc _load_pending {} {
        set f [_pending_file]
        if {![file exists $f] || [catch {read_file $f} d] || [catch {dict size $d}]} { return {} }
        return $d
    }

    proc _save_pending {d} {
        catch { write_file [_pending_file] $d }
    }

    proc _queue_shot {clock} {
        variable max_pending
        if {$clock eq ""} return
        set d [_load_pending]
        if {![dict exists $d $clock]} { dict set d $clock 0 }
        while {[dict size $d] > $max_pending} {
            set oldest [lindex [lsort -integer [dict keys $d]] 0]
            msg "dropping oldest queued shot $oldest (queue full)"
            dict unset d $oldest
        }
        _save_pending $d
    }

    proc _unqueue_shot {clock} {
        set d [_load_pending]
        if {[dict exists $d $clock]} { dict unset d $clock; _save_pending $d }
    }

    proc pending_count {} { return [dict size [_load_pending]] }

    # The saved history file for a shot, read back for a retry. Returns {} when it is gone.
    proc _read_saved_shot {clock} {
        set ts [clock format $clock -format "%Y%m%dT%H%M%S"]
        foreach f [list "[data_directory]/history_v2/$ts.json" "[data_directory]/history/$ts.shot"] {
            if {[file exists $f] && ![catch {read_file $f} raw]} {
                # read_file returns raw bytes; the files are UTF-8
                return [encoding convertfrom utf-8 $raw]
            }
        }
        return {}
    }

    # What an HTTP result means for this shot:
    #   uploaded | auth (401) | rejected (other 4xx) | network (no HTTP answer) | server (5xx or other)
    proc classify_result {ncode error} {
        if {$ncode == 0 || ($error ne "" && $ncode < 200)} { return network }
        if {$ncode >= 200 && $ncode < 300} { return uploaded }
        if {$ncode == 401} { return auth }
        if {$ncode >= 400 && $ncode < 500} { return rejected }
        return server
    }

    # The id visualizer.coffee returns for an uploaded shot, or {} when the answer can't be parsed.
    proc parse_upload_id {body} {
        if {[catch { set id [dict get [::json::json2dict $body] id] }]} { return {} }
        return $id
    }

    # Request pieces for uploading shot content (a .shot file's text or ::shot::create's JSON) as the
    # multipart "file" field visualizer.coffee expects. Returns {url headers body} with body as UTF-8 bytes.
    proc build_upload_request {content {boundary {}}} {
        variable settings
        if {$boundary eq ""} { set boundary "--------[clock milliseconds]" }
        set auth "Basic [binary encode base64 [encoding convertto utf-8 $settings(visualizer_username):$settings(visualizer_password)]]"
        set url "https://$settings(visualizer_url)/$settings(visualizer_endpoint)"
        # visualizer_url may carry its own scheme, e.g. http://127.0.0.1:18765 for testing against a local server
        if {[regexp {^https?://} $settings(visualizer_url)]} { set url "$settings(visualizer_url)/$settings(visualizer_endpoint)" }
        set part "Content-Disposition: form-data; name=\"file\"; filename=\"file.shot\"\r\nContent-Type: application/octet-stream\r\n"
        set body [encoding convertto utf-8 "--$boundary\r\n$part\r\n$content\r\n--$boundary--\r\n"]
        set headers [list "Authorization: $auth" "Content-Type: multipart/form-data; boundary=$boundary" "Expect:"]
        return [list $url $headers $body]
    }

    # POST shot content without blocking. Calls <callback> with {ncode body error} when done.
    proc _post_shot {content callback} {
        lassign [build_upload_request $content] url headers body
        if {[decent_http_async $url $callback -body $body -headers $headers -timeout 30 -connecttimeout 15 \
                -useragent "de1app-visualizer-upload"]} {
            return
        }
        # No TclCurl: ::http in its asynchronous (-command) mode.
        set hl {}
        set ctype ""
        foreach h $headers {
            if {![regexp {^([^:]+):\s*(.*)$} $h -> k v] || $v eq ""} continue
            if {$k eq "Content-Type"} { set ctype $v } else { lappend hl $k $v }
        }
        regexp {^https?://([^/:]+)} $url -> host
        if {[catch {
            ::http::register https 443 [list ::tls::socket -servername $host]
            ::http::geturl $url -method POST -type $ctype -query $body -headers $hl -timeout 30000 \
                -command [list [namespace current]::_http_done $callback]
        } err]} {
            after 0 [list {*}$callback [dict create ncode 0 body {} error $err]]
        }
    }

    proc _http_done {callback token} {
        set r [dict create ncode 0 body {} error {}]
        catch {
            if {[::http::status $token] eq "ok"} {
                dict set r ncode [::http::ncode $token]
                dict set r body [::http::data $token]
            } else {
                dict set r error "[::http::status $token] [::http::error $token]"
            }
        }
        catch { ::http::cleanup $token }
        uplevel #0 [linsert $callback end $r]
    }

    # Public, kept for other plugins: DYE calls it to (re-)upload an edited shot and expects the Visualizer id
    # back (or {} on failure). The transfer itself is non-blocking; this waits for it with vwait, so the UI keeps
    # running meanwhile. Single attempt; a failure here is reported, not queued.
    proc upload {content} {
        variable settings
        if {![has_credentials]} { return {} }

        msg "uploading shot"
        set settings(last_action) "upload"
        set settings(last_upload_shot) $::settings(espresso_clock)
        set settings(last_upload_result) ""
        set settings(last_upload_id) ""
        popup [translate_toast "Uploading to Visualizer"]

        set wait [namespace current]::_upload_wait[clock clicks]
        set $wait {}
        _post_shot $content [list set $wait]
        vwait $wait
        set r [set $wait]
        unset $wait

        set outcome [classify_result [dict get $r ncode] [dict get $r error]]
        set id [_report $outcome $r]
        plugins save_settings visualizer_upload
        return $id
    }

    # Show and record the outcome of an upload of the just-finished shot. Returns the Visualizer id, or {}.
    proc _report {outcome r} {
        variable settings
        variable auth_failed
        set ncode [dict get $r ncode]
        switch -- $outcome {
            uploaded {
                set id [parse_upload_id [dict get $r body]]
                popup [translate_toast "Upload successful"]
                if {$id eq ""} {
                    msg "Upload successful but unexpected server answer!"
                    set settings(last_upload_result) [translate "Upload successful but unexpected server answer!"]
                    return {}
                }
                msg "Upload successful with id: $id"
                set settings(last_upload_id) $id
                set settings(last_upload_result) "[translate {Upload successful with id}] $id"
                return $id
            }
            auth {
                msg "Upload failed. Unauthorized"
                if {!$auth_failed} {
                    popup [translate_toast "Upload failed! Authentication failed. Please check username / password"]
                }
                set auth_failed 1
                set settings(last_upload_result) [translate "Authentication failed. Please check username / password"]
            }
            rejected {
                msg "Upload rejected: http $ncode [dict get $r body]"
                popup [translate_toast "Upload failed!"]
                set settings(last_upload_result) "[translate {Upload failed!}] HTTP $ncode"
            }
            default {
                set why [expr {$ncode ? "HTTP $ncode" : [dict get $r error]}]
                msg "Upload failed ($outcome): $why"
                popup [translate_toast "Upload failed!"]
                set settings(last_upload_result) "[translate {Upload failed!}] $why"
            }
        }
        return {}
    }

    # After each espresso: check the upload rules, then start the upload. Never blocks.
    proc start_upload {} {
        variable settings
        variable auth_failed
        set settings(last_action) "upload"
        set settings(last_upload_shot) $::settings(espresso_clock)
        set settings(last_upload_result) ""
        set settings(last_upload_id) ""

        set skip ""
        set min_seconds [ifexists settings(auto_upload_min_seconds) 6]
        set bev_type [ifexists ::settings(beverage_type) "espresso"]
        if { ! $settings(auto_upload) } {
            set skip [translate "Not uploaded: auto-upload is not enabled"]
        } elseif {[espresso_elapsed length] < 6 && [espresso_pressure length] < 6 } {
            set skip [translate "Not uploaded: shot was too short"]
        } elseif {[espresso_elapsed range end end] < $min_seconds } {
            set skip [translate "Not uploaded: shot duration was less than $min_seconds seconds"]
        } elseif {$bev_type eq "cleaning" || $bev_type eq "calibrate"} {
            set skip [translate "Not uploaded: Profile was 'cleaning' or 'calibrate'"]
        } elseif {![has_credentials]} {
            # no Visualizer account set up: nothing to do, and nothing to report
            set skip "-"
        } elseif {$auth_failed} {
            # Known-bad credentials this session: keep the shot for later instead of hammering the server.
            set skip [translate "Authentication failed. Please check username / password"]
            _queue_shot $::settings(espresso_clock)
        }
        if {$skip ne ""} {
            if {$skip ne "-"} { set settings(last_upload_result) $skip }
            uploadShotData
            return
        }

        msg "uploading shot"
        popup [translate_toast "Uploading to Visualizer"]
        set clock $::settings(espresso_clock)
        # Core saved this shot to history moments ago (from the same ::shot::create): reuse that file instead of
        # building the JSON again, which takes ~0.4 s of UI time on a Mac and more on a tablet.
        set content [_read_saved_shot $clock]
        if {$content eq ""} { set content [::shot::create] }
        _post_shot $content [list [namespace current]::_live_done $clock]
    }

    proc _live_done {clock r} {
        variable settings
        set outcome [classify_result [dict get $r ncode] [dict get $r error]]
        # A newer shot may have started uploading meanwhile; only report this one if it is still the latest.
        if {$settings(last_upload_shot) eq $clock} {
            _report $outcome $r
        } else {
            msg "upload of earlier shot $clock finished: $outcome"
        }
        if {$outcome in {network server auth}} {
            _queue_shot $clock
            if {$settings(last_upload_shot) eq $clock} {
                append settings(last_upload_result) " ([translate {will retry later}])"
            }
        }
        if {$settings(last_upload_shot) eq $clock} {
            uploadShotData
        } else {
            plugins save_settings visualizer_upload
        }
    }

    # Called when the upload of the just-finished shot has COMPLETED, or was skipped. Returns the Visualizer id.
    # It keeps this name because the SDB and DYE plugins hook it with
    #   trace add execution ::plugins::visualizer_upload::uploadShotData leave ...
    # to pick up last_upload_id once the upload is done. Before v2.0 this proc did the (blocking) upload itself.
    proc uploadShotData {} {
        variable settings
        plugins save_settings visualizer_upload
        return $settings(last_upload_id)
    }

    proc async_dispatch {old new} {
        # Prevent uploading of data if last flow was HotWater or HotWaterRinse
        if { $old eq "Espresso" } {
            after 100 ::plugins::visualizer_upload::start_upload
        }
    }

    # --- Retrying queued shots, only while the machine is asleep -----------------------------------------

    proc _is_asleep {} {
        if {[catch {::de1::state::current_state} s]} { return 0 }
        return [expr {$s eq "Sleep"}]
    }

    proc drain_pending {} {
        variable settings
        variable draining
        variable drain_backoff
        variable auth_failed
        if {$draining || !$settings(auto_upload) || ![has_credentials] || $auth_failed || ![_is_asleep]} return
        if {[pending_count] == 0} return
        set draining 1
        set drain_backoff 2000
        msg "retrying [pending_count] queued shot(s)"
        _drain_next
    }

    proc _drain_next {} {
        variable settings
        variable draining
        variable auth_failed
        set queue [lsort -integer [dict keys [_load_pending]]]
        if {[llength $queue] == 0 || !$settings(auto_upload) || $auth_failed || ![_is_asleep]} {
            if {[llength $queue] && ![_is_asleep]} { msg "retry paused: machine awake" }
            set draining 0
            return
        }
        set clock [lindex $queue 0]
        set content [_read_saved_shot $clock]
        if {$content eq ""} {
            msg "queued shot $clock has no saved history file; dropping it"
            _unqueue_shot $clock
            after 50 [namespace current]::_drain_next
            return
        }
        _post_shot $content [list [namespace current]::_drain_done $clock]
    }

    proc _drain_done {clock r} {
        variable settings
        variable draining
        variable drain_backoff
        variable max_attempts
        variable auth_failed
        set outcome [classify_result [dict get $r ncode] [dict get $r error]]
        switch -- $outcome {
            uploaded {
                set id [parse_upload_id [dict get $r body]]
                msg "queued shot $clock uploaded, id $id"
                _unqueue_shot $clock
                if {$id ne ""} {
                    set settings(last_upload_result) "[translate {Upload successful with id}] $id"
                    if {$settings(last_upload_shot) eq $clock} { set settings(last_upload_id) $id }
                    plugins save_settings visualizer_upload
                }
                set drain_backoff 2000
                after 800 [namespace current]::_drain_next
            }
            rejected {
                msg "queued shot $clock rejected (HTTP [dict get $r ncode]); dropping it"
                _unqueue_shot $clock
                after 800 [namespace current]::_drain_next
            }
            auth {
                msg "retry paused: authentication failed"
                set auth_failed 1
                set draining 0
            }
            network {
                msg "retry paused: network error ([dict get $r error]); resumes next sleep"
                set draining 0
            }
            default {
                set d [_load_pending]
                set n [expr {[dict exists $d $clock] ? [dict get $d $clock] + 1 : 1}]
                if {$n >= $max_attempts} {
                    msg "giving up on queued shot $clock after $n server errors"
                    dict unset d $clock
                    _save_pending $d
                    after 800 [namespace current]::_drain_next
                } else {
                    dict set d $clock $n
                    _save_pending $d
                    set drain_backoff [expr {min($drain_backoff * 2, 300000)}]
                    after $drain_backoff [namespace current]::_drain_next
                }
            }
        }
    }

    # New credentials were saved: let uploads try again.
    proc credentials_changed {} {
        variable auth_failed
        set auth_failed 0
    }

    # type = browse / download_all / download_essentials / donwload_by_code
    proc id_to_url { {visualizer_id {}} {type browse} } {
        variable settings
        if { $visualizer_id eq {} } {
            set visualizer_id $settings(last_upload_id)
        }
        if { $type eq "download_all" } {
            set url "$settings(visualizer_download_url)/download"
        } elseif { $type eq "download_essentials" } {
            set url "$settings(visualizer_download_url)/download?essentials=1"
        } elseif { $type eq "download_by_code" } {
            set url $settings(download_by_code_url)
        } elseif { $type eq "download_all_last_shared" } {
            set url $settings(download_all_last_shared)
            return $url
        }  else {
            set url $settings(visualizer_browse_url)
        }
        
        if { $visualizer_id ne "" && $url ne "" } {
            regsub "<ID>" $url $visualizer_id url
        }
        return $url
    }
    
    proc id_from_url { visualizer_url } {
        return [file tail $visualizer_url]
    }

    proc browse { {visualizer_id {}} } {
        variable settings
        
        if { $visualizer_id eq {} } {
            set visualizer_id $settings(last_upload_id)
        }
        set link [id_to_url $visualizer_id browse]
        if { $link ne "" } {
            web_browser $link
        }
    }
    
	# if 'visualizer_id' has 4 characters, it is a download code instead (we make it anything with less than 10 chars). 
    # what = all / essentials, only used when 'visualizer_id' is a shot ID and not a download code.
    proc download { visualizer_id {what essentials} } {
        variable settings

        if { $what eq "essentials" } {
            set url_type "download_essentials"
        } else {
            set url_type "download_all"
        }
        if { $visualizer_id eq {} } {
            set visualizer_id $settings(last_upload_id)
            if { $what eq "download_all_last_shared" } {
                set url_type "download_all_last_shared"
                msg "Downloading all shared shots"
            } 
        } elseif { [string length $visualizer_id] < 10 } {
            set url_type "download_by_code"
        }

        set settings(last_action) "download"
        set settings(last_download_id) $visualizer_id
        set settings(last_download_result) ""
        set settings(last_download_shot_start) ""
        
        set download_link [id_to_url $visualizer_id $url_type]
        msg "downloading url '$download_link'"

        ::http::register https 443 ::tls::socket
        tls::init -tls1 0 -ssl2 0 -ssl3 0 -tls1.1 0 -tls1.2 1 -servername $settings(visualizer_url) $settings(visualizer_url) 443
        
        set headerl {}
        if {[has_credentials] && $url_type == "download_all_last_shared"} {
            set auth "Basic [binary encode base64 $settings(visualizer_username):$settings(visualizer_password)]"
            set headerl [list Authorization "$auth"]
             msg "Downloading with authorization"
        }

        if {[catch {
            set token [::http::geturl $download_link -headers $headerl  -method GET -timeout 10000]
            set status [::http::status $token]
            set answer [::http::data $token]
            set ncode [::http::ncode $token]
            set code [::http::code $token]
            ::http::cleanup $token
        } err] != 0} {
            msg "could not download visualizer shot '$download_link' : $err"
            dui say [translate "Download failed"]
            set settings(last_download_result) "[translate {Download failed!}] [ifexists code] [ifexists ncode]"
            catch { ::http::cleanup $token }
            return
        }
        
        catch {
            http::unregister https
        }

        if { $status eq "ok" && $ncode == 200 } {
            if {[catch {
                if { $url_type eq "download_all_last_shared" } {
                    set listResponse [encoding convertfrom utf-8 $answer]
                    set response [::json::json2dict "{\"list\": $listResponse}"]
                } else {
                    set response [::json::json2dict [encoding convertfrom utf-8 $answer]]
                }
            } err] != 0} {
                set my_err ""
                msg "unexpected Visualizer answer: $answer"
                dui say [translate "Download failed"] 
                set settings(last_download_result) "[translate {Download failed!}] [translate {Could not parse JSON answer}]"
                return
            }
        } else {
            msg "could not get Visualizer url $download_link: $code"
            dui say [translate "Download failed"]
            set settings(last_download_result) "[translate {Download failed!}] $code"
            return
        }
        
        if { $url_type eq "download_by_code" && [dict exists $response profile_url] } {
            dict set response profile [download_profile [dict get $response profile_url]]
        }
        
        set settings(last_download_result) [translate {Download successful!}]
        if { [dict exists $response start_time] } {
            set settings(last_download_shot_start) [dict get $response start_time] 
        }
        return $response
    }

    proc download_profile { profile_url } {
        variable settings

        if { $profile_url eq "" } {
            return {}
        }
        
        set profile {}
        msg "downloading profile url '$profile_url'"

        ::http::register https 443 ::tls::socket
        tls::init -tls1 0 -ssl2 0 -ssl3 0 -tls1.1 0 -tls1.2 1 -servername $settings(visualizer_url) $settings(visualizer_url) 443
        
        set headerl {}
        if { [has_credentials] } {
            set auth "Basic [binary encode base64 $settings(visualizer_username):$settings(visualizer_password)]"
            set headerl [list Authorization "$auth"]
            msg "Downloading with authorization"
        }
        
        if {[catch {
            set token [::http::geturl $profile_url -timeout 10000]
            set status [::http::status $token]
            set answer [::http::data $token]
            set ncode [::http::ncode $token]
            set code [::http::code $token]
            ::http::cleanup $token
        } err] != 0} {
            msg "could not download profile url '$profile_url' : $err"
            dui say [translate "Profile download failed"]
            set settings(last_download_result) "[translate {Profile download failed!}] [ifexists code]"
            catch { ::http::cleanup $token }
            return {}
        }

        if { $status eq "ok" && $ncode == 200 } {
            if {[catch {
                set profile [list {*}[encoding convertfrom utf-8 $answer]]
            } err] != 0} {
                set my_err ""
                msg "unexpected Visualizer profile url answer: $answer"
                dui say [translate "Profile download failed"] 
                set settings(last_download_result) "[translate {Profile download failed!}] [translate {Could not parse profile answer}]"
                return {}
            }
        } else {
            msg "could not get profile url $profile_url: $code"
            dui say [translate "Profile download failed"]
            set settings(last_download_result) "[translate {Download failed!}] $code"
            return {}
        }
        
        return $profile
    }
    
    proc has_credentials {} {
        variable settings
        return [expr { [string trim $settings(visualizer_username)] ne "" && $settings(visualizer_username) ne "demo@demo123" && [string trim $settings(visualizer_password)] ne "" }]
    }
    
    proc main {} {
        plugins gui visualizer_upload [create_ui]
        ::de1::event::listener::after_flow_complete_add \
            [lambda {event_dict} {
            ::plugins::visualizer_upload::async_dispatch \
                [dict get $event_dict previous_state] \
                [dict get $event_dict this_state] \
            } ]
        # Load libcurl while the app is starting: the first `package require TclCurl` takes about a second, which
        # would otherwise freeze the UI right after the first shot.
        after 3000 { catch { package require TclCurl } }
        # Retry shots whose upload failed once the machine goes to sleep (it is idle then).
        ::de1::event::listener::on_major_state_change_add [lambda {event_dict} {
            if {[dict get $event_dict this_state] eq "Sleep" && [dict get $event_dict previous_state] ne "Sleep"} {
                after 2000 ::plugins::visualizer_upload::drain_pending
            }
        }]
    }

}

namespace eval ::plugins::${plugin_name}::visualizer_settings {
    variable widgets
    array set widgets {}
    
    variable data
    array set data {}

    variable qr_img 
    
    proc setup { } {
        variable widgets
        set page_name [namespace tail [namespace current]]
        
        # "Done" button
        dui add dbutton $page_name 980 1210 1580 1410 -tags page_done -label [translate "Done"] -label_pos {0.5 0.5} -label_font Helv_10_bold -label_fill "#fAfBff"
        
        # Headline
        dui add dtext $page_name 1280 300 -text [translate "Visualizer Upload"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"
        
        # Username
        dui add entry $page_name 280 540 -tags username -width 38 -font Helv_8  -borderwidth 1 -bg #fbfaff -foreground #4e85f4 -textvariable ::plugins::visualizer_upload::settings(visualizer_username) -relief flat  -highlightthickness 1 -highlightcolor #000000 \
            -label [translate "Username"] -label_pos {280 480} -label_font Helv_8 -label_width 1000 -label_fill "#444444" 
        bind $widgets(username) <Return> [namespace current]::save_settings 
        
        # Password         
        dui add entry $page_name 280 720 -tags password -width 38 -font Helv_8  -borderwidth 1 -bg #fbfaff -foreground #4e85f4 -textvariable ::plugins::visualizer_upload::settings(visualizer_password) -relief flat  -highlightthickness 1 -highlightcolor #000000 \
            -label [translate "Password"] -label_pos {280 660} -label_font Helv_8 -label_width 1000 -label_fill "#444444" 
        bind $widgets(password) <Return> [namespace current]::save_settings
        
        # Auto-Upload
        dui add dcheckbox $page_name 280 840 -tags auto_upload -textvariable ::plugins::visualizer_upload::settings(auto_upload) -fill "#444444" \
            -label [translate "Auto-Upload"] -label_font Helv_8 -label_fill #4e85f4 -command save_settings 
        
        # Mininum seconds to Auto-Upload
        dui add entry $page_name 280 980 -tags auto_upload_min_seconds -textvariable ::plugins::visualizer_upload::settings(auto_upload_min_seconds) -width 3 -font Helv_8  -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -relief flat -highlightthickness 1 -highlightcolor #000000 \
            -label [translate "Minimum shot seconds to auto-upload"] -label_pos {280 920} -label_font Helv_8 -label_width 1100 -label_fill "#444444"
        bind $widgets(auto_upload_min_seconds) <Return> [namespace current]::save_settings
                
        # Last upload shot
        dui add dtext $page_name 1350 480 -tags last_action_label -text [translate "Last upload:"] -font Helv_8 -width 900 -fill "#444444"
        dui add dtext $page_name 1350 540 -tags last_action -font Helv_8 -width 900 -fill "#4e85f4" -anchor "nw" -justify "left" 
        
        # Last upload result
        dui add dtext $page_name 1350 600 -tags last_action_result -font Helv_8 -width 900 -fill "#4e85f4" -anchor "nw" -justify "left"
        
        # Browse last uploaded shot in system browser 920
        try {
            package present zint
            set browse_msg [translate "Scan QR or tap here to open the shot in the system browser"]  
        } on error err {
			set browse_msg [translate "Tap here to open the shot in the system browser"]
        }
        dui add dbutton $page_name 1350 800 -tags browse -bwidth 450 -bheight 350 -label $browse_msg \
            -label_font Helv_8 -label_fill white -label_width 380 -label_justify center \
            -command ::plugins::visualizer_upload::browse -style insight_ok

        image create photo [namespace current]::qr_img -width [dui::platform::rescale_x 1500] -height [dui::platform::rescale_y 1500]
        dui add image $page_name 1900 800 {} -tags qr
        dui item config $page_name qr -image [namespace current]::qr_img
    }

    # This is run immediately after the settings page is shown, wherever it is invoked from.
    proc show { page_to_hide page_to_show } {
        if { $plugins::visualizer_upload::settings(last_action) eq "download" } {
            set last_id $::plugins::visualizer_upload::settings(last_download_id)
            dui item config $page_to_show last_action_label -text [translate "Last download:"]
            dui item config $page_to_show last_action -text "[translate {Shot started on }] $plugins::visualizer_upload::settings(last_download_shot_start)"
            dui item config $page_to_show last_action_result -text $::plugins::visualizer_upload::settings(last_download_result)
        } else {
            set last_id $::plugins::visualizer_upload::settings(last_upload_id)
            set data(last_action_result) $::plugins::visualizer_upload::settings(last_upload_result)
            dui item config $page_to_show last_action_label -text [translate "Last upload:"]
            dui item config $page_to_show last_action -text [::plugins::visualizer_upload::visualizer_settings::format_shot_start]
            set result $::plugins::visualizer_upload::settings(last_upload_result)
            set waiting [::plugins::visualizer_upload::pending_count]
            if {$waiting > 0} {
                append result "\n[translate {Shots waiting to be uploaded:}] $waiting"
            }
            dui item config $page_to_show last_action_result -text $result
        }
        
        # QR: See http://www.androwish.org/index.html/file?name=jni/zint/backend_tcl/demo/demo.tcl&ci=b68e63bacab3647f
        if { $last_id eq {} } {
            dui item hide $page_to_show browse*
            [namespace current]::qr_img blank
        } else {
            dui item show $page_to_show browse*
            catch {
                zint encode [::plugins::visualizer_upload::id_to_url $last_id browse] [namespace current]::qr_img -barcode QR -scale 2.6
            }
        }
    }

    proc format_shot_start {} {
        set dt $::plugins::visualizer_upload::settings(last_upload_shot)
        if { $dt eq {} } {
            return [translate "Last shot not found"]
        }
        if { [clock format [clock seconds] -format "%Y%m%d"] eq [clock format $dt -format "%Y%m%d"] } {
            return "[translate {Shot started today at}] [time_format $dt]"
        } else {
            return "[translate {Shot started on}] [clock format $dt -format {%B %d %Y, %H:%M}]"
        }
    }
    
    proc save_settings {} {
        dui say [translate {Saved}] sound_button_in
        ::plugins::visualizer_upload::credentials_changed
        save_plugin_settings visualizer_upload
    }
    
    proc page_done {} {
        dui say [translate {Done}] sound_button_in
        ::plugins::visualizer_upload::credentials_changed
        save_plugin_settings visualizer_upload
        dui page close_dialog
    }
}
