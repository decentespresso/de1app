package require http
package require tls
package require json

set plugin_name "visualizer_upload"

set ::plugins::${plugin_name}::author "Johanna Schander"
set ::plugins::${plugin_name}::contact "coffee-plugins@mimoja.de"
set ::plugins::${plugin_name}::version 1.0
set ::plugins::${plugin_name}::description "Upload your last shot to visualizer.coffee"

# Paint settings screen
proc ::plugins::${plugin_name}::preload {} {

    # Unique name per page
    set page_name "plugin_visualizer_page_default"

    # Background image and "Done" button
    add_de1_page "$page_name" "settings_message.png" "default"
    add_de1_text $page_name 1280 1310 -text [translate "Done"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"
    add_de1_button $page_name {say [translate {Done}] $::settings(sound_button_in); save_plugin_settings visualizer_upload;  page_to_show_when_off extensions; }  980 1210 1580 1410 ""

    # Headline
    add_de1_text $page_name 1280 300 -text [translate "Visualizer Upload"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"

    # Username
    add_de1_text $page_name 280 480 -text [translate "Username"] -font Helv_8 -width 300 -fill "#444444" -anchor "nw" -justify "center"
    # The actual content. Here a list of all settings for this plugin
    add_de1_widget "$page_name" entry 280 540  {
        set ::globals(widget_profile_name_to_save) $widget
        bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; save_plugin_settings visualizer_upload; hide_android_keyboard}
        bind $widget <Leave> hide_android_keyboard
    } -width [expr {int(38 * $::globals(entry_length_multiplier))}] -font Helv_8  -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -textvariable ::plugins::visualizer_upload::settings(visualizer_username) -relief flat  -highlightthickness 1 -highlightcolor #000000

    # Password
    add_de1_text $page_name 280 660 -text [translate "Password"] -font Helv_8 -width 300 -fill "#444444" -anchor "nw" -justify "center"
    # The actual content. Here a list of all settings for this plugin
    add_de1_widget "$page_name" entry 280 720  {
        set ::globals(widget_profile_name_to_save) $widget
        bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; save_plugin_settings visualizer_upload; hide_android_keyboard}
        bind $widget <Leave> hide_android_keyboard
    } -width [expr {int(38 * $::globals(entry_length_multiplier))}] -font Helv_8  -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -textvariable ::plugins::visualizer_upload::settings(visualizer_password) -relief flat  -highlightthickness 1 -highlightcolor #000000

    # Auto-Upload
    add_de1_widget "$page_name" checkbutton 280 840 {} -text [translate "Auto-Upload"] -indicatoron true  -font Helv_8 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::plugins::visualizer_upload::settings(auto_upload)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF  -bd 0 -activeforeground #4e85f4 -relief flat -bd 0

    return $page_name
}


proc ::plugins::${plugin_name}::upload {content} {
    msg "uploading shot"
    borg toast "Uploading Shot"

    set content [encoding convertto utf-8 $content]

    http::register https 443 [list ::tls::socket -servername $::plugins::visualizer_upload::settings(visualizer_url)]

    set username $::plugins::visualizer_upload::settings(visualizer_username)
    set password $::plugins::visualizer_upload::settings(visualizer_password)

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
        msg "status: $status"
        msg "answer $answer"
        http::cleanup $token
        if {$returncode == 401} {
            msg "Upload failed. Unauthorized"
            borg toast "Upload failed! Authentication failed. Please check username / password"
            return
        }
        if {[string length $answer] == 0 || $returncode != 200} {
            msg "Upload failed"
            borg toast "Upload failed!"
            return
        }
	} err] != 0} {
        msg "Could not upload shot! $err"
        borg toast "Upload failed!"
        return
    }

    borg toast "Upload successfull"

    if {[catch {
        set response [::json::json2dict $answer]
        set uploaded_id [dict get $response id]
    } err] != 0} {
        msg "Upload successfull but unexpected server answer!"
        return
    }
    msg "Upload successfull with id: $uploaded_id"

    return $uploaded_id
}

proc ::plugins::${plugin_name}::uploadShotData {old new} {
    if {[espresso_elapsed length] > 5 && [espresso_pressure length] > 5
         && $::plugins::visualizer_upload::settings(auto_upload)} {
        set espresso_data [format_espresso_for_history]
        upload $espresso_data
    }
}


proc ::plugins::${plugin_name}::main {} {
    register_state_change_handler Espresso Idle ::plugins::visualizer_upload::uploadShotData
}

