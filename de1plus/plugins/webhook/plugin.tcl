package require http
package require sha256

set plugin_name "webhook"

namespace eval ::plugins::${plugin_name} {

    variable author "Kevin Gao"
    variable contact "@sudowork"
    variable version 1.0
    variable description "Sends shot data as a webhook to a specified URL"
    variable name "Webhook"

    proc preload {} {
        return [build_settings_ui]
    }

    proc build_settings_ui {}  {
        # Create settings if non-existant
        if {[array size ::plugins::webhook::settings] == 0} {
            array set ::plugins::webhook::settings {
                webhook_domain "example.com"
                webhook_endpoint "/decent/webhook"
                webhook_secret_key "SecretKeyForSigning"
                webhook_trigger_after 10
            }
            plugins save_settings webhook
        }

        # Unique name per page
        set page_name "plugin_webhook_page_default"

        # Background image and "Done" button
        add_de1_page "$page_name" "settings_message.png" "default"
        add_de1_text $page_name 1280 1310 -text [translate "Done"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"
        add_de1_button $page_name {say [translate {Done}] $::settings(sound_button_in); page_to_show_when_off extensions}  980 1210 1580 1410 ""

        # Headline
        add_de1_text $page_name 1280 300 -text [translate "Webhook"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"

        # Render Settings
        build_setting_text_input $page_name [translate "Webhook Domain"] {::plugins::webhook::settings(webhook_domain)} 480
        build_setting_text_input $page_name [translate "Webhook Endpoint"] {::plugins::webhook::settings(webhook_endpoint)} 660
        build_setting_text_input $page_name [translate "Webhook Secret Key"] {::plugins::webhook::settings(webhook_secret_key)} 840
        build_setting_text_input $page_name [translate "Trigger After (seconds)"] {::plugins::webhook::settings(webhook_trigger_after)} 1020

        return $page_name
    }

    proc build_setting_text_input {page_name label var y} {
        set x 280
        add_de1_text $page_name $x $y -text $label -font Helv_8 -width 300 -fill "#444444" -anchor "nw" -justify "center"
        add_de1_widget $page_name entry $x [expr $y + 60]  {
            bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; save_plugin_settings webhook; hide_android_keyboard}
            bind $widget <Leave> hide_android_keyboard
        } -width [expr {int(38 * $::globals(entry_length_multiplier))}] -font Helv_8  -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -textvariable "$var" -relief flat  -highlightthickness 1 -highlightcolor #000000
    }

    proc post_shot_data {} {
        variable settings

        msg "triggering webhook"
        borg toast [translate "Triggering Webhook"]

        http::register https 443 [list ::tls::socket -servername $settings(webhook_domain)]

        # Craft HTTP Body
        set espresso_data [::shot::create]
        set clock [clock seconds]
        set boundary "--------$clock"
        set type "multipart/form-data, charset=utf-8, boundary=$boundary"
        set content [encoding convertto utf-8 $espresso_data]
        set contentHeader "Content-Disposition: form-data; name=\"file\"; filename=\"file.shot\"\r\nContent-Type: application/octet-stream\r\n"
        set body "--$boundary\r\n$contentHeader\r\n$content\r\n--$boundary--\r\n"

        # Build HMAC signature
        # HMAC Signature = SHA256(secret, endpoint_path + "\n" + clock + "\n" + body)
        set message_for_hmac "$settings(webhook_endpoint)\n$clock\n$body"
        set signature [sha2::hmac $settings(webhook_secret_key) $message_for_hmac]
        set headerl [list \
            Authorization "$clock!$signature" \
            Content-Type "multipart/form-data; boundary=$boundary"]

        if {[catch {
            # HTTPS only for now
            set url "https://$settings(webhook_domain)$settings(webhook_endpoint)"
            set token [http::geturl $url -headers $headerl -method POST -type $type -query $body -timeout 30000]
            set status [http::status $token]
            set answer [http::data $token]
            set returncode [http::ncode $token]
            set returnfullcode [http::code $token]
            msg $token
            msg "status: $status"
            # msg "answer: $answer"
        } err] != 0} {
            msg "Could not upload shot to webhook! $err"
            borg toast [translate "Webhook failed!"]
            catch { http::cleanup $token }
            return
        }

        http::cleanup $token
        if {$returncode != 200} {
            msg "Webhook failed: $returnfullcode"
            borg toast "Webhook failed!"
            return
        }

        msg "Webhook succeeded!"
        borg toast "Webhook succeeded!"
    }

    proc async_dispatch {old new} {
        after [expr 1000 * $::plugins::webhook::settings(webhook_trigger_after)] ::plugins::webhook::post_shot_data
    }

    proc msg { msg } {
        ::msg [namespace current] $msg
    }

    proc main {} {
        ::de1::event::listener::after_flow_complete_add \
            [lambda {event_dict} {
            ::plugins::webhook::async_dispatch \
                [dict get $event_dict previous_state] \
                [dict get $event_dict this_state] \
            } ]
    }
}
