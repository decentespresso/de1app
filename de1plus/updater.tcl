
# this file contains the minimum amount of library procedures needed
# for the DE1 software updater to run. 
# the idea is to minimize the liklihood of breaking the updater

package provide de1_updater 1.1

package require de1_logging 1.0

# NB: the BLE/USB transport loaders (load_ble_command / load_usb_command) used to
# live here, but were moved to utils.tcl so this failsafe updater never loads BLE
# -- android detection below now uses `borg osbuildinfo`, not the `ble` command.
# See android_specific_stubs (utils.tcl), which loads them at app runtime.
proc determine_if_android {} {

    set ::android 0
    set ::undroid 0
    set ::some_droid 0

    # Detect a real Android device via `borg osbuildinfo` (Android's
    # android.os.Build.*): ONLY a genuine Android reports a positive version.sdk
    # (the API level). Every other AndroWish-family build -- desktop undroidwish,
    # iWish iPad/Catalyst -- reports 0, and a build without borg errors out (the
    # catch leaves android=0). See BORG-OSX.md. This deliberately does NOT load
    # BLE: the failsafe updater must stay lean, so the real BLE/USB drivers load
    # later, in android_specific_stubs (utils.tcl), which the updater never runs.
    catch {
        set _bi [borg osbuildinfo]
        if {[dict exists $_bi version.sdk] && [dict get $_bi version.sdk] > 0} {
            set ::android 1
        }
    }

    # undroidwish family (desktop undroidwish OR iWish iPad/Catalyst): the sdl2tk /
    # BLT Tk GUI stack is present but this is not a real Android device. The
    # namespace import makes blt::graph etc. available to the app (on Android too).
    # (catch: a plain headless tclsh has neither BLT nor the blt:: namespace.)
    catch {
        package require BLT
        namespace import blt::*
        namespace import -force blt::tile::*
        if {!$::android} { set ::undroid 1 }
    }

    # Safety net: iWish is an Apple build, so borg should already have given
    # android=0 -- but force it, so a surprising osbuildinfo can never mis-flag the
    # iPad/Catalyst app as Android.
    if {[info exists ::iwish] && $::iwish} {
        set ::android 0
        set ::undroid 1
    }

    # Whether the underlying OS is iOS. This is a distinct concept from $::iwish,
    # which is merely the *build* we run on Apple platforms (the same iWish build
    # also runs on Mac Catalyst, which is not iOS). A launcher that knows it is on
    # a real iOS device or the iOS Simulator can set ::ios before sourcing de1app;
    # otherwise default it from the iWish build, which today only targets the iOS
    # family. We can't reliably tell iOS from Mac Catalyst at runtime (both report
    # Darwin), so the launcher is the authoritative source.
    if {![info exists ::ios]} {
        set ::ios [expr {[info exists ::iwish] && $::iwish}]
    }

    # Transport capabilities DEFAULT to "none" here. Their REAL values are set
    # later, at app runtime, by android_specific_stubs (utils.tcl) once it loads
    # the BLE / USB drivers -- which the failsafe updater never runs, so the
    # updater never loads BLE. Set to safe defaults (not left unset) so any early
    # reader sees 0. A launcher may still pre-set ::has_usb before startup, like
    # ::ios. Connectivity decisions key on these capabilities, NOT on the OS flags.
    # On Android `ble` is a built-in command, already present now (no loading) --
    # capture it via a cheap [info commands] CHECK (not a load). Android is the one
    # platform where android_specific_stubs is NOT called (it has real borg/ble),
    # so this is where has_bluetooth gets its true value there. On macOS/desktop
    # ble isn't loaded yet, so this is 0 and android_specific_stubs sets the real
    # value after it loads the driver.
    if {![info exists ::has_bluetooth]} {
        set ::has_bluetooth [expr {[llength [info commands ble]] > 0}]
    }
    if {![info exists ::has_usb]}       { set ::has_usb 0 }
    set ::can_connect_de1 [expr {$::has_bluetooth || $::has_usb}]

    if {$::android == 1 || $::undroid == 1} {
        # turn the background window black as soon as possible
        # and then make it full screen on android/undroid, so as to prepare for the loading of the splash screen
        # and also to remove the displaying of the Tcl/Tk app bar, which looks weird being on Android
        # NB: only when a real Tk root exists. The OSX ble driver now loads under
        # headless tclsh too (makede1.tcl build), where there is no "." root --
        # without this guard these Tk calls crash the build.
        if {[llength [info commands winfo]] && [winfo exists .]} {
            . configure -bg black -bd 0
            # `wm attributes -fullscreen` here is RELATIVE TO THE undroidwish SDL
            # window -- it makes the app fill that window (dropping sdl2tk's window
            # chrome), it does NOT take over the macOS/Windows/Linux desktop. So we
            # want it on every GUI host (this whole block is gated on android ||
            # undroid), desktop undroidwish included.
            wm attributes . -fullscreen 1
        }
        set ::some_droid 1
    }

}
determine_if_android

proc calc_sha {source} {
    set sha 0
    set tries 0

    # No file to hash (e.g. a download that failed/has not happened): return 0 at
    # once so the caller re-fetches, instead of retrying the hash 10x (and, with
    # the old exec path, throwing an uncaught "No such file" error dialog).
    if {![file exists $source]} { return 0 }

    # Use the tcllib SHA-256, which loads the C accelerator (tcllibc / critcl) when
    # present -- as fast as `shasum` (~45ms for 8MB) but with NO subprocess. The old
    # `exec /usr/bin/shasum` path needed a working `exec` (unavailable on iOS) and
    # was what broke app-update on the macOS undroidwish build.
    catch { package require sha256 }

    while {$sha == 0 && $tries < 10} {

        catch {
            set sha [::sha2::sha256 -hex -filename $source]
        }

        # use this to test SHA failure once
        #if {$tries == 0} { set sha 0 }

        if {$sha == 0} {
            # we are trying to solve an occasional "file busy", maybe the OS is doing something in the background
            catch {
                msg -DEBUG "Pausing and then retrying to calculate SHA for $source"
            }
            after 1000
        }
        incr tries
    }

    if {$sha == 0} {
        catch {
            msg -ERROR "Unable to calculate SHA for $source"
        }
    }

    return $sha
}


proc ifexists {fieldname2 {defvalue {}} } {
    upvar $fieldname2 fieldname
    
    if {[info exists fieldname] == 1} {
        return [subst "\$fieldname"]
    } else {
        if {$defvalue != ""} {
            set fieldname $defvalue
            return $defvalue
        } else {
            return ""
        }
    }
    #return $defvalue
}


proc fast_write_open {fn parms} {
    set success 0
    set f 0
    set errcode [catch {
        set f [open $fn $parms]

        # Michael argues that there's no need to go nonblocking if you have a write buffer defined.
        # https://3.basecamp.com/3671212/buckets/7351439/messages/3033510129#__recording_3037579684
        # so disabling for now, to see if he's right.
        # fconfigure $f -blocking 0

        # explicitly declare LF as the line feed character, as that's what it is on unix/android/macos - only windows doesn't and it causes issues
        fconfigure $f -buffersize 1000000 -translation {lf lf}
        set success 1
    }]

    if {$errcode != 0} {
        catch {
            msg -ERROR "fast_write_open $::errorInfo"
        }
    }

    return $f
    #return ""
}

proc write_file {filename data} {
    set success 0
    set errcode [catch {
        set fn [fast_write_open $filename w]
        puts $fn $data 
        close $fn
        set success 1
    }]

    if {$errcode != 0} {
        catch {
            msg -ERROR "write_file '$filename' $::errorInfo"
        }
    }

    return $success
}

proc percent20encode {in} {
    set out $in
    regsub -all " " $out "%20" out
    #regsub -all "&" $out "%26" out
    regsub -all "\"" $out "%22" out
    regsub -all {#} $out "%23" out
    regsub -all {'} $out "%27" out
    regsub -all {!} $out "%21" out
    regsub -all {:} $out "%3A" out
    regsub -all {;} $out "%3B" out
    regsub -all {#} $out "%23" out
    #regsub -all {=} $out "%3D" out
    regsub -all {:} $out "%3A" out
    regsub -all "\\?" $out "%3F" out
    regsub -all {@} $out "%40" out
    regsub -all {>} $out "%3E" out
    regsub -all {/} $out "%2F" out
    regsub -all {<} $out "%3C" out
    regsub -all {\$} $out "%24" out
    regsub -all {`} $out "%60" out
    regsub -all {\[} $out "%5B" out
    regsub -all {\]} $out "%5D" out
    regsub -all {~} $out "%7E" out
    regsub -all {\^} $out "%5E" out
    regsub -all {\|} $out "%7C" out
    regsub -all "," $out "%2C" out
    regsub -all "\\)" $out "%29" out
    regsub -all "\\(" $out "%28" out
    
    regsub -all " " $in "%20" out
    regsub -all "\n" $out "%0D" out
    #regsub -all "&" $out "%26" out
    regsub -all {"} $out "%22" out
    regsub -all "\\?" $out "%3F" out
    regsub -all "," $out "%2C" out    
    #puts "urlenc: '$in' / '$out'"
    return $out
}

proc sleep {time} {
    after $time set end 1
    vwait end
}

proc httpHandlerCallback {token} {

    upvar #0 $token state

	set cmd [ifexists ::asyc_handlers($token)]
	unset -nocomplain ::asyc_handlers($token)

    set body [::http::data $token]

    if {[::http::error $token] != ""} {
		msg -ERROR "http_get error: [::http::error $token]"
    }
    if {$token != ""} {
        ::http::cleanup $token
    }

    # run the handler that was defined for this async http request
    $cmd $body
}

proc decent_async_http_get {url cmd {timeout 30000}} {
    set body {}
    set token {}    
    ::http::config -useragent "mer454"
    set errcode [catch {
        set token [::http::geturl $url -binary 1 -timeout $timeout -command httpHandlerCallback]
    }]

    if {$errcode != 0} {
        catch {
            msg -ERROR "decent_async_http_get $::errorInfo"
        }
    } else {

        if {$token != ""} {
            set ::asyc_handlers($token) $cmd
        }
    }
    return $token
}


proc decent_http_get {url {timeout 30000}} {

    # Prefer TclCurl (libcurl) for the fetch. On iWish/iOS the ::http::geturl path
    # over the TclTLS channel errors while READING a larger HTTPS response ("error
    # reading sockNNN: Unknown error ..."): the tiny timestamp.txt squeaks through
    # but the ~57 KB manifest.gz fails, which aborts the whole app update with
    # "Corrupt manifest". libcurl reads it correctly (and is already the transport
    # for decent_http_get_to_file). This stays HTTPS -- it is NOT a downgrade; the
    # cert is still verified against allcerts.pem when present. Falls back to
    # ::http::geturl when TclCurl is unavailable (plain desktop tclsh).
    if {![catch {package require TclCurl}]} {
        set body ""
        set ok 0
        set hdl [::curl::init]
        if {[catch {
            $hdl configure -url $url -bodyvar body -useragent "mer454" \
                -connecttimeout 20 -lowspeedlimit 1 -lowspeedtime 60 \
                -followlocation 1 -failonerror 1
            set _ca "[homedir]/allcerts.pem"
            if {[file exists $_ca]} { $hdl configure -sslverifypeer 1 -cainfo $_ca }
            $hdl perform
            set ok 1
        } curlerr]} {
            catch { msg -DEBUG "decent_http_get: TclCurl failed for $url: $curlerr -- trying ::http" }
        }
        catch { $hdl cleanup }
        if {$ok && [string length $body] > 0} {
            return $body
        }
        # else fall through to the ::http::geturl path below
    }

    set body {}
    set token {}
    #catch {
        ::http::config -useragent "mer454"
        set token [::http::geturl $url -binary 1 -timeout $timeout]
        set body [::http::data $token]

        set cnt 0
        if {[string length $body] == 0} {
            # try once more
            sleep 1000
            ::http::cleanup $token
            set token [::http::geturl $url -binary 1 -timeout $timeout]
            set body [::http::data $token]
        }

        if {[::http::error $token] != ""} {
		msg -ERROR "http_get error: [::http::error $token]"
        }
        if {$token != ""} {
            ::http::cleanup $token
        }
    #}z

    return $body
}

# libcurl (TclCurl) progress callback fired during a download. Pump the Tk event
# loop -- throttled to ~10x/sec -- so the GUI stays responsive (the clock/spinner
# keep running, the window keeps redrawing) while a file streams in. Returning a
# non-zero value would abort the transfer, so always return 0.
proc decent_http_progress {dltotal dlnow ultotal ulnow} {
    catch {
        set now [clock milliseconds]
        if {($now - $::_app_dl_last_update) >= 100} {
            set ::_app_dl_last_update $now
            update
        }
    }
    return 0
}

# Download a URL straight to a file using libcurl (TclCurl) instead of
# ::http::geturl. libcurl is faster, and the progress callback above keeps the
# GUI responsive throughout -- the old `::http::geturl -channel` call blocked the
# Tk event loop for the entire (potentially multi-MB) transfer, freezing the UI.
# TLS is verified against the bundled allcerts.pem (same as the http transport).
# `timeout` is accepted for call-site compatibility; libcurl uses connect + low-
# speed timeouts so large files on a slow link are not cut off mid-transfer.
proc decent_http_get_to_file {url fn {timeout 30000}} {

    if {[catch {package require TclCurl}]} {
        # Fallback to the old blocking http if libcurl is somehow unavailable.
        set out [open $fn w]
        fconfigure $out -blocking 1 -translation binary
        ::http::config -useragent "mer454"
        set token [::http::geturl $url -channel $out -blocksize 4096 -binary 1 -keepalive 0]
        close $out
        if {[::http::error $token] != ""} { msg -ERROR "http_get error: [::http::error $token]" }
        if {$token != ""} { ::http::cleanup $token }
        return ""
    }

    set ::_app_dl_last_update 0
    set hdl [curl::init]
    if {[catch {
        $hdl configure -url $url -file $fn -useragent "mer454" \
            -connecttimeout 20 -lowspeedlimit 1 -lowspeedtime 60 \
            -followlocation 1 -failonerror 1 \
            -noprogress 0 -progressproc decent_http_progress
        set _ca "[homedir]/allcerts.pem"
        if {[file exists $_ca]} {
            $hdl configure -sslverifypeer 1 -cainfo $_ca
        }
        $hdl perform
    } err]} {
        catch { msg -ERROR "decent_http_get_to_file: curl error for '$url': $err" }
    }
    catch { $hdl cleanup }

    return ""
}


proc read_file {filename} {
    set data ""

    set errcode [catch {
        set fn [open $filename]
            fconfigure $fn -translation binary

        set data [read $fn]
        close $fn
    }]

    if {$errcode != 0} {
        catch {
            msg -ERROR "read_file $::errorInfo"
        }
    }

    if {$data == ""} {
        catch {
            msg -DEBUG "read_file: '$filename' exists [file exists $filename] - length [file size $filename]"
        }

    }
    return $data
}

# source_directory -- the CODE / read-only-asset root (skins, plugins, fonts, the
# .tcl tree, ...). On macOS/Android this is the app tree (writable, so self-update
# works); on iOS it is the read-only app bundle. Set explicitly by ios.tcl/osx.tcl/
# google_play_store.tcl (via ::home); falls back to the de1plus dir.
proc source_directory {} {
    global home
    if {[info exists home] != 1} {
        set home [file normalize [file dirname [info script]]]
    }
    return $home
}

# homedir -- historical name for the CODE root. Kept as an exact alias of
# source_directory so the ~230 code call sites need no change.
proc homedir {} { return [source_directory] }

# data_directory -- the WRITABLE user-data root (settings, history, profiles,
# godshots, logs, resized-image caches). On macOS/Android it equals
# source_directory (one writable tree); on iOS ios.tcl points it at
# ~/Documents/Decent while source_directory stays the read-only bundle. Every
# data/write path resolves here instead of homedir.
proc data_directory {} {
    if {[info exists ::data_home]} { return $::data_home }
    return [source_directory]
}

proc pause {time} {
    global pause_end
    after $time set pause_end 1
    vwait pause_end
    unset -nocomplain pause_end
}



proc verify_decent_tls_certificate {} {

    # disabled for now, but does currently work, so we always return true, and put the failure in the the log
    # However: if we pinned updates to this SHA1 then people who did not update in a while, 
    # and Decentespresso.com now had a new SSL cert, would get an error during updates.

    return 1


    catch {    
        package require tls
        msg -INFO "Using TLS version [tls::version]"

        set channel [tls::socket decentespresso.com 443]
        tls::handshake $channel

        set status [tls::status $channel]
        close $channel
        
        array set status_array $status
        msg -INFO "TLS status: [array get status_array]"
        #puts "subj: '[ifexists status_array(subject)]'"

        #set sha1 [ifexists status_array(sha1_hash)]
        #if {$sha1 == "CB23B4F32C08FAE212A39544837A8AD40D09F7FD"} {
        #    msg -INFO "https cert matches what we expect, good"
        #} else {
        #    msg -ERROR "https does not match what we expect. Decent might have changed to a new SSL cert, or something bad is happening. SHA1 received='$sha1'"
        #}
    }

    # the cert should be for the decentespress.com domain
    if {[ifexists status_array(subject)] == {CN=*.decentespresso.com}} {
        msg -INFO "Valid SSL cert found: '[ifexists status_array(subject)]'"
        return 1
    }


    # disabled for now, but does currently work, so we always return true, and put the failure in the the log
    # However: if we pinned updates to this SHA1 then people who did not update in a while, 
    # and Decentespresso.com now had a new SSL cert, would get an error during updates.

    return 0


    # if the sha_1 hash on the certificate doesn't match what we expect, return the entire array of what we received from the https connection, optionally to display it to the user
    return $status
}

proc schedule_app_update_check {} {
    # 3am is when we check for an app update
    set update_time [expr {3 * 60 * 60}]

    set aftertime [next_alarm_time $update_time]
    set delay_to_update [expr {($aftertime - [clock seconds]) * 1000}]

    msg -INFO "Scheduling next app update check for [clock format $aftertime] (delay: $delay_to_update)"
    after $delay_to_update scheduled_app_update_check
}

# every day, check to see if an app update is available
proc scheduled_app_update_check {} {
msg -NOTICE "scheduled_app_update_check"

    # async update check is enabled by default now, for testing in nightly build
    set ::settings(do_async_update_check) 1
	if {$::settings(do_async_update_check) == 1} {
		check_timestamp_for_app_update_available_async
	} else {
    	check_timestamp_for_app_update_available
	}
    
    schedule_app_update_check
}


proc check_timestamp_for_app_update_available_async {} {

    set check_only [expr {![zero_if_empty [ifexists ::settings(app_auto_update)]]}]

    set host "http://fast.decentespresso.com"
    set progname "de1plus"
    if {[ifexists ::settings(app_updates_beta_enabled)] == 1} {
        set progname "de1beta"
    } elseif {[ifexists ::settings(app_updates_beta_enabled)] == 2} {
        set progname "de1nightly"
    }
    msg -NOTICE "checking for updates"
    msg -INFO "update timestanp endpoint: '$progname'"

    set url_timestamp "$host/download/sync/$progname/timestamp.txt"    

    set remote_timestamp {}

    set ::app_update_available 0
    

    catch {
        msg -DEBUG "Fetching remote update timestamp: '$url_timestamp'"
    }

	decent_async_http_get $url_timestamp "check_timestamp_for_app_update_available_async_part2"

}

proc check_timestamp_for_app_update_available_async_part2 { remote_timestamp_in } {

    set check_only [expr {![zero_if_empty [ifexists ::settings(app_auto_update)]]}]

	set remote_timestamp [string trim $remote_timestamp_in]
    msg -INFO "Remote timestamp: '$remote_timestamp'"

    set local_timestamp [string trim [read_file "[homedir]/timestamp.txt"]]
    msg -INFO "Local timestamp: '$local_timestamp'"

    if {$remote_timestamp == ""} {
        msg -WARNING "unable to fetch remote timestamp"

        if {$check_only != 1} {
            set ::de1(app_update_button_label) [translate "Update"];             
        }

        return -1
    } elseif {$local_timestamp == $remote_timestamp} {

        if {$check_only != 1} {
            set ::de1(app_update_button_label) [translate "Up to date"];             
        }

        msg -DEBUG "Local timestamp is the same as remote timestamp, so no need to update"
        return $local_timestamp
    }

    catch {
        msg -NOTICE "app update available"
    }

    #set ::app_update_available 1

    if {$check_only != 1} {
        set ::de1(app_update_button_label) [translate "Update available"];     

        # only start the app updater if currently sleeping or screen savering
        if {$::de1(current_context) == "sleep" || $::de1(current_context) == "saver"} {
            start_app_update
        }
    }
    # time stamps don't match, so update is useful
    return $remote_timestamp
}


proc check_timestamp_for_app_update_available { {check_only 0} } {

    set host "http://fast.decentespresso.com"
    set progname "de1plus"
    if {[ifexists ::settings(app_updates_beta_enabled)] == 1} {
        set progname "de1beta"
    } elseif {[ifexists ::settings(app_updates_beta_enabled)] == 2} {
        set progname "de1nightly"
    }
    msg -NOTICE "checking for updates"
    msg -INFO "update timestanp endpoint: '$progname'"

    set url_timestamp "$host/download/sync/$progname/timestamp.txt"    

    set remote_timestamp {}

    set ::app_update_available 0
    

    catch {
        msg -DEBUG "Fetching remote update timestamp: '$url_timestamp'"
    }

    catch {
        set remote_timestamp [string trim [decent_http_get $url_timestamp]]
    }
    msg -INFO "Remote timestamp: '$remote_timestamp'"

    set local_timestamp [string trim [read_file "[homedir]/timestamp.txt"]]
    msg -INFO "Local timestamp: '$local_timestamp'"

    if {$remote_timestamp == ""} {
        msg -WARNING "unable to fetch remote timestamp"

        if {$check_only != 1} {
            set ::de1(app_update_button_label) [translate "Update"];             
        }

        return -1
    } elseif {$local_timestamp == $remote_timestamp} {

        if {$check_only != 1} {
            set ::de1(app_update_button_label) [translate "Up to date"];             
        }

        msg -DEBUG "Local timestamp is the same as remote timestamp, so no need to update"
        return $local_timestamp
    }

    catch {
        msg -NOTICE "app update available"
    }

    set ::app_update_available 1

    if {$check_only != 1} {
        set ::de1(app_update_button_label) [translate "Update available"];     
    }
    # time stamps don't match, so update is useful
    return $remote_timestamp


}

proc start_app_update {} {

    # Some builds cannot rewrite themselves in place and must not self-update --
    # they hand the user off to a store instead. This is a build property, NOT an
    # OS: key it on the generic ::self_update_prohibited flag so any locked-down
    # store build can just pre-set it (like ::ios / ::has_usb). If unset, derive it
    # from the only case that exists today -- a hypothetical iOS App Store build,
    # marked by `appstore.flag` in the read-only bundle. (The mainstream SideStep-
    # sideloaded build runs from a writable copy in ~/Documents/Decent, so the
    # marker is absent and it self-updates in place like the macOS .app / Android APK.)
    if {![info exists ::self_update_prohibited]} {
        set ::self_update_prohibited [expr {[ifexists ::ios] == 1 \
                && [info exists ::_readonly_bundle] \
                && [file exists [file join $::_readonly_bundle "appstore.flag"]]}]
    }
    if {$::self_update_prohibited} {
        set ::de1(app_update_button_label) [translate "Update"]
        catch { update_onscreen_variables }
        catch {
            info_page [translate "This version must be updated through your app store"] [translate "Ok"]
        }
        return
    }

    if {[ifexists ::app_updating] == 1} {
        catch {
            msg -INFO "App is already updating, not going to run two processes"
        }
    }

    set ::app_updating 1

    if {$::android == 1} {
        if {[borg networkinfo] == "none"} {

            set ::de1(app_update_button_label) [translate "No Wifi network"]; 

            catch {
                .hello configure -text $::de1(app_update_button_label)
            }

            # "no wifi network" label is already displayed, so on tap, Android launch wifi settings
            launch_os_wifi_setting
            
            set ::app_updating 0
            return $::de1(app_update_button_label)
        }
    }

    # disabled by John 5-9-23 while testing out a new of verifying the SSL cert is valid
    #set cert_check [verify_decent_tls_certificate]
    #if {$cert_check != 1} {
    #    msg -ERROR "https certification is not what we expect, update failed"
    #    foreach {k v} $cert_check {
    #        msg -DEBUG "$k : '$v'"
    #    }
    #    set ::de1(app_update_button_label) [translate "Internet encryption problem"]; 
    #    set ::app_updating 0
    #    return $::de1(app_update_button_label)
    #}

    set host "https://fast.decentespresso.com"
    set host2 "https://fast.decentespresso.com"
    #set host "http://10.0.1.200:8000"

    set has_tls 0
    catch {
        package present tls
        set has_tls 1
    }    


    if {$has_tls != 1} {
        # undroid doesn't yet support https, so fallback to plain http in that case
        set host "http://fast.decentespresso.com"
    }

    set progname "de1plus"
    if {[ifexists ::settings(app_updates_beta_enabled)] == 1} {
        set progname "de1beta"
    } elseif {[ifexists ::settings(app_updates_beta_enabled)] == 2} {
        set progname "de1nightly"
    }

    msg -DEBUG "update download endpoint: '$progname'"
    
    set remote_timestamp [check_timestamp_for_app_update_available 1]
    if {$remote_timestamp < 0} {
        set ::de1(app_update_button_label) [translate "Update failed"]; 
        catch {
            .hello configure -text $::de1(app_update_button_label)
        }

        msg -ERROR "Could not fetch remote timestamp. Aborting update"
        set ::app_updating 0
        return -1
    }

    ##############################################################################################################
    # get manifest both as raw TXT and as gzip compressed, to detect tampering 
    #set url_manifest "$host/download/sync/$progname/manifest.txt"
    set url_manifest_gz "$host2/download/sync/$progname/manifest.gz"
    set remote_manifest_gz {}
    set remote_manifest {}
    catch {
        set remote_manifest_gz [decent_http_get $url_manifest_gz]
        set remote_manifest [zlib gunzip $remote_manifest_gz]
    }
    set remote_manifest_gunzip_length 0
    set remote_manifest_gunzip_parts_length -1
    catch {
        set remote_manifest_gunzip_length [llength $remote_manifest]
        set remote_manifest_gunzip_parts_length [expr {$remote_manifest_gunzip_length % 4}]
    }

    catch {
        msg -DEBUG "Length of gunzip remote manifest: $remote_manifest_gunzip_length % $remote_manifest_gunzip_parts_length"
    }

    # test the remote manifest file to see that it is unmodiied and uncorrupted
    set errcode [catch {
        foreach {filename filesize filemtime filesha} $remote_manifest {}
    }]
    if {$errcode != 0 || $remote_manifest == "" || $remote_manifest_gunzip_parts_length != 0} {
        catch {
            msg -ERROR "Corrupt manifest: '[string range $remote_manifest 0 500]'"
        }
        set ::de1(app_update_button_label) [translate "Update failed"]; 

        catch {
            .hello configure -text $::de1(app_update_button_label)
        }

        set ::app_updating 0
        return $::de1(app_update_button_label)
    }
    ##############################################################################################################


    set local_manifest [string trim [read_binary_file "[homedir]/manifest.txt"]]

    catch {
        msg -DEBUG "Local [homedir]/manifest.txt has [string length $local_manifest] bytes - [file exists "[homedir]/manifest.txt"]"
    }

    if {[string length $local_manifest] == 0} {
        set local_manifest [string trim [read_binary_file "[homedir]/manifest.tdb"]]

        catch {
            msg -DEBUG "Now using manifest.tdb file.  Local [homedir]/manifest.tdb has [string length $local_manifest] bytes"
        }

    }

    # load the local manifest into memory
    foreach {filename filesize filemtime filesha} $local_manifest {
        set filesize 0
        catch {
            set filesize [file size "[homedir]/$filename"]
        }

        if {[file exists "[homedir]/$filename"] != 1} {
            # force retrieval of any locally missing file by setting its SHA to zero
            catch {
                msg -ERROR "Missing: $filename"
            }
            set filesha 0
        }
        set lmanifest($filename) [list filesize $filesize filemtime $filemtime filesha $filesha]
    }

    # compare the local vs remote manifest
    foreach {filename filesize filemtime filesha} $remote_manifest {
        unset -nocomplain data
        array set data [ifexists lmanifest($filename)]
        #if {[ifexists data(filesha)] != $filesha || [ifexists data(filesize)] != $filesize} 
        if {[info exists data(filesha)] != 1} {
            set tofetch($filename) [list filesize $filesize filemtime $filemtime filesha $filesha]
            catch {
                msg -NOTICE "Local file is missing in local manifest: $filename"
            }
        } elseif {$data(filesha) != $filesha} {
            # if the SHA doesn't match then we'll want to fetch this file
            # john 4/18/18 note that we no longer use FILESIZE to compare files, because it can vary between file systems, even if the contents are identical
            set tofetch($filename) [list filesize $filesize filemtime $filemtime filesha $filesha]
            msg -DEBUG "SHA256 mismatch local:'[ifexists data(filesha)]' != remote:'$filesha' : will fetch: $filename or filesize [ifexists data(filesize)] != $filesize"
        } else {
        }
    }

    set tmpdir "[data_directory]/tmp"
    catch {
        # john experimenting with not deleting the tmp dir so we can recover from a failed or aborted app update
        # file delete -force $tmpdir
    }
    catch {
        file mkdir $tmpdir
    }


    set cnt 0
    foreach {k v} [array get tofetch] {

        set perc [expr {100.0 * ($cnt / [array size tofetch])}]
        incr cnt


        if {[ifexists ::settings(app_updates_beta_enabled)] == 2} {
            set ::de1(app_update_button_label) "$cnt/[array size tofetch] ([file tail $k])"; 
            catch {
                .hello configure -text "$cnt/[array size tofetch] ([file tail $k])"
                update
            }
        } else {
            set ::de1(app_update_button_label) "$cnt/[array size tofetch]"; 
            catch {
                .hello configure -text "$cnt/[array size tofetch]"
                update
            }
        }

        catch { update_onscreen_variables }
        update

        unset -nocomplain arr
        array set arr $v
        set fn "$tmpdir/$arr(filesha)"
        set url "$host/download/sync/$progname/[percent20encode $k]"

        # check to see if this file already exists from an aborted or partially failed app update
        set skip_this_file 0        
        if {[file exists $fn] == 1} {
            set newsha [calc_sha $fn]
            if {$arr(filesha) == $newsha} {
                msg -INFO "existing file $fn matches expected sha, so no need to redownload"
                set skip_this_file 1
            } else {
                # existing file does not match expected sha, so delete and refetch
                msg -INFO "existing file $fn does not match expected sha, so delete and refetch"
                file delete $fn
            }
        }

        if {$skip_this_file != 1} {
            set newsha ""
            set max_attempts 4
            set success 0
            for {set attempt 1} {$attempt <= $max_attempts} {incr attempt} {
                catch {
                    file delete $fn
                    msg -INFO "HTTP GET $url saving to $fn"
                    decent_http_get_to_file $url $fn
                }

                # call 'update' to keep the gui responsive
                update

                set newsha [calc_sha $fn]
                if {$arr(filesha) != $newsha} {
                    msg -ERROR "Failed to accurately download $k, retrying"
                    file delete $fn

                    set ::de1(app_update_button_label) "$cnt/[array size tofetch] ([file tail $k] - retry #$attempt)"; 
                    catch {
                        .hello configure -text "$cnt/[array size tofetch] ([file tail $k] - retry #$attempt)"
                        update
                    }

                } else {
                    # successful fetch 
                    set success 1
                    break
                }
            }

            if {$success != 1} {
                set ::de1(app_update_button_label) "Unable to download $cnt/[array size tofetch] ([file tail $k])"; 
                catch {
                    .hello configure -text "Unable to download $cnt/[array size tofetch] ([file tail $k])"
                    update
                }
                msg -ERROR "Failed to accurately download $k"
                set ::app_updating 0

                catch {
                    # retry the update automatically
                    after 1000 start_app_update
                }

                return -1
            }

            # call 'update' to keep the gui responsive
            update

            if {$newsha == ""} {
                set newsha [calc_sha $fn]
            }

            if {$arr(filesha) != $newsha} {
                msg -ERROR "Failed to accurately download $k"
                set ::app_updating 0

                catch {
                    # retry the update automatically
                    after 1000 start_app_update
                }

                return -1
            }

            update

            msg -INFO "Successfully fetched $k -> $fn ($url)"
        }
    }

    #set ::de1(app_update_button_label) [translate WAIT]
    catch { update_onscreen_variables }
    update

    # after successfully fetching all files via https, copy them into place
    set success 1
    set files_moved 0
    set graphics_were_updated 0
    set files_to_delete {}
    
    foreach {k v} [array get tofetch] {
        unset -nocomplain arr
        array set arr $v
        set fn "$tmpdir/$arr(filesha)"
        set dest "[homedir]/$k"

        if {[file exists $fn] == 1} {
            set dirname [file dirname $dest]
            if {[file exists $dirname] != 1} {
                msg -DEBUG "Making non-existing directory: '$dirname'"
                file mkdir -force $dirname
            }
            msg -DEBUG "Moving $fn -> $dest"
            #file rename -force $fn $dest

            # john 2-16-19 we copy instead of rename in case two files have an identical SHA (ie, identical content)
            file copy -force $fn $dest

            # the macOS CoreBluetooth helper (ble/bin/ble_helper.bin) must stay executable;
            # downloads land mode 0644, after which ble.tcl rejects it as "unsupported".
            if {[file tail $dest] eq "ble_helper.bin"} {
                catch { file attributes $dest -permission 0755 }
            }

            lappend files_to_delete $fn
            incr files_moved

            # keep track of whether any graphics were updated
            set extension [file extension $dest]
            if {$extension == ".png" || $extension == ".jpg"} {
                set graphics_were_updated 1
            }

        } else {
            msg -WARNING "unable to find file $fn to copy to destination: '$dest' - a partial app update has occured."
            set success 0
        }
    }

    foreach file_to_delete $files_to_delete {
        catch {
            file delete $file_to_delete
        }
    }

    if {$success == 1} {

        catch {
            # once a successful update has occured, delete all files that have been sitting in the temp directory
            msg -INFO "app update successful, so deleting temp directory"
            file delete -force $tmpdir
        }        

        # if everything went well, go ahead and update the local timestamp and manifest to be the same as the remote one
        if {$graphics_were_updated == 1} {

            if {[ifexists ::screen_size_width] != 1} {
                # if we're not running this proc inside the gui, then we don't have resolution info
                set ::screen_size_width 1280
                set ::screen_size_height 800
            }

            set this_resolution "${::screen_size_width}x${::screen_size_height}"
            # if any graphics were updated, and this app is running at a nonstand resolution, then delete all cached local-resolution files, to force a remake of them all. 
            # this is inefficient, as it would be better to only delete the related files, and that would be a good improvement in a future version
            if {$this_resolution != "2560x1600" && $this_resolution != "1280x800"} {
                set saver_directory "[data_directory]/saver/${::screen_size_width}x${::screen_size_height}"
                set splash_directory [glob -nocomplain "[splash_directory]/${::screen_size_width}x${::screen_size_height}"]
                msg -DEBUG "deleting $saver_directory"
                msg -DEBUG "deleting $splash_directory"

                catch {
                    file delete -force $saver_directory
                }
                catch {
                    file delete -force $splash_directory
                }

                set skindirs [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/skins/" *]]
                foreach d $skindirs {
                    set thisskindir "[homedir]/skins/$d/$this_resolution/"
                    msg -DEBUG "testing '$d' - '$thisskindir'"
                    if {[file exists $thisskindir] == 1} {
                        # skins are converted to this apps resolution only as needed, so only delete the existing dirs
                        catch {
                            file delete -force $thisskindir
                        }
                        msg -DEBUG "deleting $thisskindir"
                    }
                }
            }

        }


        # ok, all done.
        write_file "[homedir]/timestamp.txt" $remote_timestamp
        write_file "[homedir]/manifest.txt" $remote_manifest
        msg -NOTICE "successful update"
        unset -nocomplain ::de1(firmware_crc) 

        if {$files_moved > 0} {
            set ::de1(app_update_button_label) "[translate "Updated"] $files_moved"; 
            set ::app_has_updated 1
        } else {
            set ::de1(app_update_button_label) [translate "Up to date"]; 
        }


        catch {
            .hello configure -text $::de1(app_update_button_label)
        }

        catch {
            .hello configure -command { exit }
        }

        set ::app_updating 0
        return 1
    } else {
        set ::de1(app_update_button_label) [translate "Update failed"]; 
        msg -ERROR "failed update"
        set ::app_updating 0


        catch {
            .hello configure -text $::de1(app_update_button_label)
            .hello configure -command { exit }
        }


        return 0
    }
}


proc read_binary_file {filename} {
    set fn ""
    set err {}
    set error [catch {set fn [open $filename]} err]
    if {$fn == ""} {
        msg -ERROR "error opening binary file: $filename / '$err' / '$error' / $fn"
        return ""
    }
    if {$fn == ""} {
        return ""
    }
    
    fconfigure $fn -translation binary
    set data [read $fn]
    close $fn
    return $data
}



proc save_array_to_file {arrname fn} {
    upvar $arrname item
    set toexport2 {}
    foreach k [lsort -dictionary [array names item]] {
        set v $item($k)
        append toexport2 [subst {[list $k] [list $v]\n}]
    }
    write_file $fn $toexport2
}

proc settings_filename {} {
    set fn "[data_directory]/settings.tdb"
    return $fn
}



proc reset_skin {} {
    catch {
        set s "settings.tdb"
        set s [settings_filename]
    }

    array set ::settings [encoding convertfrom utf-8 [read_binary_file $s]]
    set ::settings(skin) "Insight"
    set ::settings(enabled_plugins) ""
    unset -nocomplain ::settings(ghc_is_installed) 

    # also reset the screen resolution to default
    unset -nocomplain ::settings(screen_size_height)
    unset -nocomplain ::settings(screen_size_width) 

    save_array_to_file ::settings $s
}
