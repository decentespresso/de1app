package require http
package require tls
package require json

set plugin_name "visualizer_upload"

namespace eval ::plugins::${plugin_name} {
    variable author "Johanna Schander"
    variable contact "coffee-plugins@mimoja.de"
    variable version 1.0
    variable description "Upload your last shot to visualizer.coffee"
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
        if { $needs_save_settings == 1 } {
		plugins save_settings visualizer_upload
        }

        # Unique name per page
        set page_name "plugin_visualizer_page_default"

        # Background image and "Done" button
        add_de1_page "$page_name" "settings_message.png" "default"
        add_de1_text $page_name 1280 1310 -text [translate "Done"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"
        add_de1_button $page_name {say [translate {Done}] $::settings(sound_button_in); save_plugin_settings visualizer_upload; fill_extensions_listbox; page_to_show_when_off extensions; set_extensions_scrollbar_dimensions}  980 1210 1580 1410 ""

        # Headline
        add_de1_text $page_name 1280 300 -text [translate "Visualizer Upload"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"

        # Username
        add_de1_text $page_name 280 480 -text [translate "Username"] -font Helv_8 -width 300 -fill "#444444" -anchor "nw" -justify "center"
        # The actual content. Here a list of all settings for this plugin
        add_de1_widget "$page_name" entry 280 540  {
            bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; save_plugin_settings visualizer_upload; hide_android_keyboard}
            bind $widget <Leave> hide_android_keyboard
        } -width [expr {int(38 * $::globals(entry_length_multiplier))}] -font Helv_8  -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -textvariable ::plugins::visualizer_upload::settings(visualizer_username) -relief flat  -highlightthickness 1 -highlightcolor #000000

        # Password
        add_de1_text $page_name 280 660 -text [translate "Password"] -font Helv_8 -width 300 -fill "#444444" -anchor "nw" -justify "center"
        # The actual content. Here a list of all settings for this plugin
        add_de1_widget "$page_name" entry 280 720  {
            bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; save_plugin_settings visualizer_upload; hide_android_keyboard}
            bind $widget <Leave> hide_android_keyboard
        } -width [expr {int(38 * $::globals(entry_length_multiplier))}] -font Helv_8  -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -textvariable ::plugins::visualizer_upload::settings(visualizer_password) -relief flat  -highlightthickness 1 -highlightcolor #000000

        # Auto-Upload
        add_de1_widget "$page_name" checkbutton 280 840 {} -text [translate "Auto-Upload"] -indicatoron true  -font Helv_8 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::plugins::visualizer_upload::settings(auto_upload)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF  -bd 0 -activeforeground #4e85f4 -relief flat -bd 0

        # Mininum seconds to Auto-Upload
        add_de1_text $page_name 280 920 -text [translate "Minimum shot seconds to auto-upload"] -font Helv_8 -width 600 -fill "#444444" -anchor "nw" -justify "center"
        add_de1_widget "$page_name" entry 280 980  {
            bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; save_plugin_settings visualizer_upload; hide_android_keyboard}

            bind $widget <Leave> hide_android_keyboard
        } -width [expr {int(3* $::globals(entry_length_multiplier))}] -font Helv_8  -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -textvariable ::plugins::visualizer_upload::settings(auto_upload_min_seconds) -relief flat  -highlightthickness 1 -highlightcolor #000000

        # Last upload shot
        add_de1_text $page_name 1450 480 -text [translate "Last upload:"] -font Helv_8 -width 300 -fill "#444444" -anchor "nw" -justify "center"	
        add_de1_variable $page_name 1450 540 -font Helv_8 -width 400 -fill "#4e85f4" -anchor "nw" -justify "left" -textvariable {[translate "Shot started on"] [time_format $::plugins::visualizer_upload::settings(last_upload_shot)]} 	

        # Last upload result
        add_de1_text $page_name 1450 660 -text [translate "Result:"] -font Helv_8 -width 300 -fill "#444444" -anchor "nw" -justify "center"
        add_de1_variable $page_name 1450 720 -font Helv_8 -width 400 -fill "#4e85f4" -anchor "nw" -justify "left" -textvariable {$::plugins::visualizer_upload::settings(last_upload_result)}

        # Browse last uploaded shot in 
        set ::plugins::visualizer_upload::browse_widget [add_de1_text $page_name 1450 920 -text "\[ [translate {Open shot in visualizer.coffee}] \]" -font Helv_8 -width 300 -fill "#4e85f4" -anchor "nw" -justify "left"]
        add_de1_button $page_name ::plugins::visualizer_upload::browse 1440 910 2200 990

        # Ensure stuff is done whenever the page is shown.
        add_de1_action $page_name ::plugins::visualizer_upload::show_settings_page

        return $page_name
    }

    proc msg { msg } {
        ::msg [namespace current] $msg
    }

    # This is run immediately after the settings page is shown, wherever it is invoked from.
    proc show_settings_page { } {
        variable settings		 
        canvas_hide_if_zero [expr { [info exists settings(last_upload_id)] && $settings(last_upload_id) ne "" }] $::plugins::visualizer_upload::browse_widget 
    }

    proc upload {content} {
        variable settings

        msg "uploading shot"
        borg toast [translate "Uploading Shot"]

        set content [encoding convertto utf-8 $content]

        http::register https 443 [list ::tls::socket -servername $settings(visualizer_url)]

        set username $settings(visualizer_username)
        set password $settings(visualizer_password)

        if {$username eq "demo@demo123"} {
            borg toast [translate "Please configure your username in the settings"]
            set settings(last_upload_result) [translate "Please configure your username in the settings"]
            plugins save_settings visualizer_upload
            return
        }

        set auth "Basic [binary encode base64 $username:$password]"
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
        
        set espresso_data [format_espresso_for_history]
        ::plugins::visualizer_upload::upload $espresso_data
    }

    proc async_dispatch {old new} {
        after 100 ::plugins::visualizer_upload::uploadShotData
    }

    proc browse {} {
        variable settings
        
        if { [info exists settings(last_upload_id)] && $settings(last_upload_id) ne "" && 
                [info exists settings(visualizer_browse_url)] && $settings(visualizer_browse_url) ne "" } {
            regsub "<ID>" $settings(visualizer_browse_url) $settings(last_upload_id) link
            web_browser $link
        }
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