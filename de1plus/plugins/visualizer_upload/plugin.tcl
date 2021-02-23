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
    proc preload {} {

        # Create settings if non-existant
        if {[array size ::plugins::visualizer_upload::settings] == 0} {
            array set  ::plugins::visualizer_upload::settings {
                auto_upload 1
                visualizer_endpoint api/shots/upload
                visualizer_password passwd
                visualizer_url visualizer.coffee
                visualizer_username demo@demo123
            }
            save_plugin_settings visualizer_upload
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

        return $page_name
    }


    proc upload {content} {
        msg [namespace current] "uploading shot"
        borg toast "Uploading Shot"

        set content [encoding convertto utf-8 $content]

        http::register https 443 [list ::tls::socket -servername $::plugins::visualizer_upload::settings(visualizer_url)]

        set username $::plugins::visualizer_upload::settings(visualizer_username)
        set password $::plugins::visualizer_upload::settings(visualizer_password)

        if {$username eq "demo@demo123"} {
            borg toast "Please configure your username in the settings"
            return
        }

        set auth "Basic [binary encode base64 $username:$password]"
        set boundary "--------[clock seconds]"
        set type "multipart/form-data, charset=utf-8, boundary=$boundary"
        set headerl [list Authorization "$auth"]

        set url "https://$::plugins::visualizer_upload::settings(visualizer_url)/$::plugins::visualizer_upload::settings(visualizer_endpoint)"

        set contentHeader "Content-Disposition: form-data; name=\"file\"; filename=\"file.shot\"\r\nContent-Type: application/octet-stream\r\n"
        set body "--$boundary\r\n$contentHeader\r\n$content\r\n--$boundary--\r\n"

        if {[catch {
            set token [http::geturl $url -headers $headerl -method POST -type $type -query $body -timeout 30000]
            msg $token
            set status [http::status $token]
            set answer [http::data $token]
            set returncode [http::ncode $token]
            msg [namespace current] "status: $status"
            msg [namespace current] "answer $answer"
            http::cleanup $token
            if {$returncode == 401} {
                msg [namespace current] "Upload failed. Unauthorized"
                borg toast "Upload failed! Authentication failed. Please check username / password"
                return
            }
            if {[string length $answer] == 0 || $returncode != 200} {
                msg [namespace current] "Upload failed"
                borg toast "Upload failed!"
                return
            }
        } err] != 0} {
            msg [namespace current] "Could not upload shot! $err"
            borg toast "Upload failed!"
            return
        }

        borg toast "Upload successfull"

        if {[catch {
            set response [::json::json2dict $answer]
            set uploaded_id [dict get $response id]
        } err] != 0} {
            msg [namespace current] "Upload successfull but unexpected server answer!"
            return
        }
        msg [namespace current] "Upload successfull with id: $uploaded_id"

        return $uploaded_id
    }

    proc uploadShotData {} {
        if {[espresso_elapsed length] > 5 && [espresso_pressure length] > 5
            && $::plugins::visualizer_upload::settings(auto_upload)} {
            set espresso_data [format_espresso_for_history]
            ::plugins::visualizer_upload::upload $espresso_data
        }
    }

    proc async_dispatch {old new} {
        after 100 ::plugins::visualizer_upload::uploadShotData
    }

    proc main {} {
        register_state_change_handler Espresso Idle ::plugins::visualizer_upload::async_dispatch
    }

}