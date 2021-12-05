package require http
package require tls
package require json
# zint may not be available in some standard Tcl/Tk distributions, for example on MacOS.
try {
    package require zint
} on error err {
    msg -WARNING "::plugins::visualizer_upload can't generate QR codes: $err"
}

set plugin_name "visualizer_upload"

namespace eval ::plugins::${plugin_name} {
    variable author "Johanna Schander"
    variable contact "coffee-plugins@mimoja.de"
    variable version 1.2
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
                visualizer_password passwd
                visualizer_url visualizer.coffee
                visualizer_username demo@demo123
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
        ::msg [namespace current] {*}$msg
    }

    proc upload {content} {
        variable settings

        msg "uploading shot"
        borg toast [translate "Uploading Shot"]
        
        set settings(last_action) "upload"
        set settings(last_upload_shot) $::settings(espresso_clock)
        set settings(last_upload_result) ""
        set settings(last_upload_id) ""
        
        set content [encoding convertto utf-8 $content]

        http::register https 443 [list ::tls::socket -servername $settings(visualizer_url)]

        if {![has_credentials]} {
            borg toast [translate "Please configure your username and password in the settings"]
            set settings(last_upload_result) [translate "Please configure your username and password in the settings"]
            plugins save_settings visualizer_upload
            return
        }

        set auth "Basic [binary encode base64 $settings(visualizer_username):$settings(visualizer_password)]"
        set boundary "--------[clock seconds]"
        set type "multipart/form-data, charset=utf-8, boundary=$boundary"
        set headerl [list Authorization "$auth"]

        set url "https://$settings(visualizer_url)/$settings(visualizer_endpoint)"

        set contentHeader "Content-Disposition: form-data; name=\"file\"; filename=\"file.shot\"\r\nContent-Type: application/octet-stream\r\n"
        set body "--$boundary\r\n$contentHeader\r\n$content\r\n--$boundary--\r\n"

        if {[catch {
            set token [http::geturl $url -headers $headerl -method POST -type $type -query $body -timeout 30000]
            msg $token
            set status [http::status $token]
            set answer [http::data $token]
            set returncode [http::ncode $token]
            set returnfullcode [http::code $token]
            msg "status: $status"
            msg "answer $answer"
        } err] != 0} {
            msg "Could not upload shot! $err"
            borg toast [translate "Upload failed!"]
            set settings(last_upload_result) "[translate {Upload failed!}] ERR $err"
            plugins save_settings visualizer_upload
            catch { http::cleanup $token }
            return
        }

        http::cleanup $token
        if {$returncode == 401} {
            msg "Upload failed. Unauthorized"
            borg toast [translate "Upload failed! Authentication failed. Please check username / password"]
            set settings(last_upload_result) [translate "Authentication failed. Please check username / password"]
            plugins save_settings visualizer_upload
            return
        }
        if {[string length $answer] == 0 || $returncode != 200} {
            msg "Upload failed: $returnfullcode"
            borg toast "Upload failed!"
            set settings(last_upload_result) "[translate {Upload failed!}] $returnfullcode"
            plugins save_settings visualizer_upload
            return
        }

        borg toast "Upload successful"
        if {[catch {
            set response [::json::json2dict $answer]
            set uploaded_id [dict get $response id]
        } err] != 0} {
            msg "Upload successful but unexpected server answer!"
            set settings(last_upload_result) [translate "Upload successful but unexpected server answer!"]
            plugins save_settings visualizer_upload
            return
        }
        
        msg "Upload successful with id: $uploaded_id"
        set settings(last_upload_id) $uploaded_id
        set settings(last_upload_result) "[translate {Upload successful with id}] $uploaded_id"
        
        plugins save_settings visualizer_upload
	

        return $uploaded_id
    }

    proc uploadShotData {} {
        variable settings
        set settings(last_action) "upload"
        set settings(last_upload_shot) $::settings(espresso_clock)
        set settings(last_upload_result) ""
        set settings(last_upload_id) ""
        
        if { ! $settings(auto_upload) } {
            set settings(last_upload_result) [translate "Not uploaded: auto-upload is not enabled"]
            save_plugin_settings visualizer_upload
            return
        }
        if {[espresso_elapsed length] < 6 && [espresso_pressure length] < 6 } {
            set settings(last_upload_result) [translate "Not uploaded: shot was too short"]
            save_plugin_settings visualizer_upload
            return
        }
        set min_seconds [ifexists settings(auto_upload_min_seconds) 6]
        msg "espresso_elapsed range end end = [espresso_elapsed range end end]"	
        if {[espresso_elapsed range end end] < $min_seconds } {
            set settings(last_upload_result) [translate "Not uploaded: shot duration was less than $min_seconds seconds"]
            save_plugin_settings visualizer_upload
            return
        }
        set bev_type [ifexists ::settings(beverage_type) "espresso"]
        if {$bev_type eq "cleaning" || $bev_type eq "calibrate"} {
            set settings(last_upload_result) [translate "Not uploaded: Profile was 'cleaning' or 'calibrate'"]
            save_plugin_settings visualizer_upload
            return
        }
        
        set espresso_data [::shot::create]
        ::plugins::visualizer_upload::upload $espresso_data
    }

    proc async_dispatch {old new} {
        # Prevent uploading of data if last flow was HotWater or HotWaterRinse
        if { $old eq "Espresso" } {
            after 100 ::plugins::visualizer_upload::uploadShotData
        }
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
        return [expr { [string trim $settings(visualizer_username)] ne "" && $settings(visualizer_username) ne "demo@demo123" || \
            [string trim $settings(visualizer_password)] ne "" }]
    }
    
    proc main {} {
        plugins gui visualizer_upload [create_ui]
        ::de1::event::listener::after_flow_complete_add \
            [lambda {event_dict} {
            ::plugins::visualizer_upload::async_dispatch \
                [dict get $event_dict previous_state] \
                [dict get $event_dict this_state] \
            } ]
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
            dui item config $page_to_show last_action_result -text $::plugins::visualizer_upload::settings(last_upload_result)
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
        save_plugin_settings visualizer_upload
    }
    
    proc page_done {} {
        dui say [translate {Done}] sound_button_in
        save_plugin_settings visualizer_upload
        dui page close_dialog
    }
}