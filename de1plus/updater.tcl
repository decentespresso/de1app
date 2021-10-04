
# this file contains the minimum amount of library procedures needed
# for the DE1 software updater to run. 
# the idea is to minimize the liklihood of breaking the updater

package provide de1_updater 1.1

package require de1_logging 1.0

proc determine_if_android {} {

    set ::android 0
    set ::undroid 0
    set ::some_droid 0

    catch {
        package require BLT
        namespace import blt::*
        namespace import -force blt::tile::*

        #sdltk android
        set ::undroid 1

        package require ble
        set ::undroid 0
        set ::android 1

    }

    if {$::android == 1 || $::undroid == 1} {
        # turn the background window black as soon as possible
        # and then make it full screen on android/undroid, so as to prepare for the loading of the splash screen
        # and also to remove the displaying of the Tcl/Tk app bar, which looks weird being on Android
        . configure -bg black -bd 0
        wm attributes . -fullscreen 1
        set ::some_droid 1
    }

}
determine_if_android

proc calc_sha {source} {
    set sha 0
    set tries 0

    set use_unix_sha 0
    set shasum "/usr/bin/shasum"
    if {$::android != 1} {
        if {[file exists $shasum] == 1} {
            set use_unix_sha 1
        } 
    }

    while {$sha == 0 && $tries < 10} {

        if {$use_unix_sha == 1} {
            #puts "Using fast Unix SHA256"
            set sha [lindex [exec $shasum -a 256 $source] 0]
        } else {
            catch {
                #puts "Using slow Tcl SHA256"
                set sha [::sha2::sha256 -hex -filename $source]
            }
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

proc decent_http_get_to_file {url fn {timeout 30000}} {

    set body {}
    set token {}    

    set out [open $fn w]
    fconfigure $out -blocking 1 -translation binary


    ::http::config -useragent "mer454"
    #set token [::http::geturl $url -binary 1 -timeout $timeout]
    set token [::http::geturl $url -channel $out  -blocksize 4096 -binary 1 -keepalive 0]
    close $out

    #set body [::http::data $token]

    if {[::http::error $token] != ""} {
        msg -ERROR "http_get error: [::http::error $token]"
    }
    if {$token != ""} {
        ::http::cleanup $token
    }
    
    return $body
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

proc homedir {} {
    global home
    if {[info exists home] != 1} {
        set home [file normalize [file dirname [info script]]]
    }
    return $home
}

proc pause {time} {
    global pause_end
    after $time set pause_end 1
    vwait pause_end
    unset -nocomplain pause_end
}



proc verify_decent_tls_certificate {} {

    catch {    
        package require tls
        msg -INFO "Using TLS version [tls::version]"

        set channel [tls::socket decentespresso.com 443]
        tls::handshake $channel

        set status [tls::status $channel]
        close $channel
        
        array set status_array $status
        msg -INFO "TLS status: [array get status_array]"

        set sha1 [ifexists status_array(sha1_hash)]
        if {$sha1 == "BF735474BA9AA423EC03AB9F980BE68BCAA35E57"} {
            msg -INFO "https cert matches what we expect, good"
        } else {
            msg -ERROR "https does not match what we expect. Decent might have changed to a new SSL cert, or something bad is happening. SHA1 received='$sha1'"
        }
    }

    # disabled for now, but does currently work, so we always return true, and put the failure in the the log
    # However: if we pinned updates to this SHA1 then people who did not update in a while, 
    # and Decentespresso.com now had a new SSL cert, would get an error during updates.

    return 1


    # if the sha_1 hash on the certificate doesn't match what we expect, return the entire array of what we received from the https connection, optionally to display it to the user
    return $status
}

proc schedule_app_update_check {} {
    # 3am is when we check for an app update
    set aftertime [next_alarm_time [expr {24 * 60 * 60}]]
    msg -INFO "Scheduling next app update check for [clock format $aftertime]"
    after $aftertime scheduled_app_update_check
}

# every day, check to see if an app update is available
proc scheduled_app_update_check {} {

    # async update check is enabled by default now, for testing in nightly build
    set ::settings(do_async_update_check) 1
	if {$::settings(do_async_update_check) == 1} {
		check_timestamp_for_app_update_available_async
	} else {
    	check_timestamp_for_app_update_available
	}
    
    schedule_app_update_check
}


proc check_timestamp_for_app_update_available_async { {check_only 0} } {

    set host "http://decentespresso.com"
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

proc check_timestamp_for_app_update_available_async_part2 { remote_timestamp_in {check_only 0} } {

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

    set ::app_update_available 1

    if {$check_only != 1} {
        set ::de1(app_update_button_label) [translate "Update available"];     
    }
    # time stamps don't match, so update is useful
    return $remote_timestamp


}


proc check_timestamp_for_app_update_available { {check_only 0} } {

    set host "http://decentespresso.com"
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

    set cert_check [verify_decent_tls_certificate]
    if {$cert_check != 1} {
        msg -ERROR "https certification is not what we expect, update failed"
        foreach {k v} $cert_check {
            msg -DEBUG "$k : '$v'"
        }
        set ::de1(app_update_button_label) [translate "Internet encryption problem"]; 
        set ::app_updating 0
        return $::de1(app_update_button_label)
    }

    set host "https://decentespresso.com"
    set host2 "https://decentespresso.com"
    #set host "http://10.0.1.200:8000"

    set has_tls 0
    catch {
        package package present tls
        set has_tls 1
    }    


    if {$has_tls == 1} {
        # undroid doesn't yet support https
        set host "http://decentespresso.com"
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

    set tmpdir "[homedir]/tmp"
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
                set saver_directory "[homedir]/saver/${::screen_size_width}x${::screen_size_height}"
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
    set fn "[homedir]/settings.tdb"
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

    save_array_to_file ::settings $s
}
