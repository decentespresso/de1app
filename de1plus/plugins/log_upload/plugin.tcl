package require http
package require tls
package require json

set plugin_name "log_upload"

namespace eval ::plugins::${plugin_name} {
    variable author "Johanna Schander"
    variable contact "coffee-plugins@mimoja.de"
    variable version 1.0
    variable description "Upload your logfiles to transfer.sh"
    variable name "Log Uploader"

    proc add_visual_items_to_contexts { contexts tags } {
        set context_list [split $contexts " "]
        set tag_list [split $tags " " ]
        foreach context $context_list {
            foreach tag $tag_list {
                add_visual_item_to_context $context $tag
            }
        }
    }

    proc rounded_rectangle {contexts x1 y1 x2 y2 radius colour } {
        set x1 [rescale_x_skin $x1] 
        set y1 [rescale_y_skin $y1] 
        set x2 [rescale_x_skin $x2] 
        set y2 [rescale_y_skin $y2]
        if { [info exists ::_rect_id] != 1 } { set ::_rect_id 0 }
        set tag "rect_$::_rect_id"
        .can create oval $x1 $y1 [expr $x1 + $radius] [expr $y1 + $radius] -fill $colour -outline $colour -width 0 -tag $tag -state "hidden"
        .can create oval [expr $x2-$radius] $y1 $x2 [expr $y1 + $radius] -fill $colour -outline $colour -width 0 -tag $tag -state "hidden"
        .can create oval $x1 [expr $y2-$radius] [expr $x1+$radius] $y2 -fill $colour -outline $colour -width 0 -tag $tag -state "hidden"
        .can create oval [expr $x2-$radius] [expr $y2-$radius] $x2 $y2 -fill $colour -outline $colour -width 0 -tag $tag -state "hidden"
        .can create rectangle [expr $x1 + ($radius/2.0)] $y1 [expr $x2-($radius/2.0)] $y2 -fill $colour -outline $colour -width 0 -tag $tag -state "hidden"
        .can create rectangle $x1 [expr $y1 + ($radius/2.0)] $x2 [expr $y2-($radius/2.0)] -fill $colour -outline $colour -width 0 -tag $tag -state "hidden"
        add_visual_items_to_contexts $contexts $tag
        incr ::_rect_id
        return $tag
    }


    proc create_button { contexts x1 y1 x2 y2 font backcolor textcolor action variable } {
        rounded_rectangle $contexts  $x1 $y1 $x2 $y2 [rescale_x_skin 80] $backcolor
        add_de1_variable "$contexts"  [expr ($x1 + $x2) / 2.0 ] [expr ($y1 + $y2) / 2.0 ] -width [rescale_x_skin [expr ($x2 - $x1) - 20]]  -text "" -font $font -fill $textcolor -anchor "center" -justify "center" -state "hidden" -textvariable $variable
        add_de1_button $contexts $action $x1 $y1 $x2 $y2
    }

    # Paint settings screen
    proc create_ui {} {

        # Create settings if non-existant
        if {[array size ::plugins::log_upload::settings] == 0} {
            array set  ::plugins::log_upload::settings {
                last_upload_log {}
                last_upload_result {}
            }
            plugins save_settings log_upload
        }

        # Unique name per page
        set page_name "plugin_log_upload_page_default"

        # Background image and "Done" button
        add_de1_page "$page_name" "settings_message.png" "default"
        add_de1_text $page_name 1280 1310 -text [translate "Done"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"
        add_de1_button $page_name {say [translate {Done}] $::settings(sound_button_in); save_plugin_settings log_upload; fill_extensions_listbox; page_to_show_when_off extensions; set_extensions_scrollbar_dimensions}  980 1210 1580 1410 ""


        # Headline
        add_de1_text $page_name 1280 300 -text [translate "Log Upload"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"


        # Upload Button
        create_button $page_name 400 480 1200 920 Helv_10_bold #822 #FFF {::plugins::log_upload::uploadLogfiles} {Upload!}

        # Last upload Log
        add_de1_text $page_name 1450 480 -text [translate "Last upload:"] -font Helv_8 -width 300 -fill "#444444" -anchor "nw" -justify "center"	
        add_de1_variable $page_name 1450 540 -font Helv_8 -width 400 -fill "#4e85f4" -anchor "nw" -justify "left" -textvariable {$::plugins::log_upload::settings(last_upload_log)} 	

        # Last upload result
        add_de1_text $page_name 1450 660 -text [translate "Result:"] -font Helv_8 -width 300 -fill "#444444" -anchor "nw" -justify "center"
        add_de1_variable $page_name 1450 720 -font Helv_8 -width 400 -fill "#4e85f4" -anchor "nw" -justify "left" -textvariable {$::plugins::log_upload::settings(last_upload_result)}

        # Browse last uploaded shot in 
        add_de1_text $page_name 1450 920 -text "\[ [translate {Open log in Browser}] \]" -font Helv_8 -width 300 -fill "#4e85f4" -anchor "nw" -justify "left"
        add_de1_button $page_name ::plugins::log_upload::browse 1440 910 2200 990

        return $page_name
    }

    proc msg { msg } {
        ::msg [namespace current] $msg
    }

    proc upload {content} {
        variable settings

        msg "uploading shot"
        borg toast [translate "Uploading Shot"]

        set content [encoding convertto utf-8 $content]

        http::register https 443 [list ::tls::socket -servername "transfer.sh"]

        set boundary "--------[clock seconds]"
        set type "text/plain"

        set url "https://transfer.sh/log.txt"

        set body "$content"

        if {[catch {
            set token [http::geturl $url -method PUT -type $type -query $body -timeout 30000]
            msg $token
            set status [http::status $token]
            set answer [http::data $token]
            set returncode [http::ncode $token]
            set returnfullcode [http::code $token]
            msg "status: $status"
            msg "answer $answer"
        } err] != 0} {
            msg "Could not upload log! $err"
            borg toast [translate "Upload failed!"]
            set settings(last_upload_result) "[translate {Upload failed!}] ERR $err"
            plugins save_settings log_upload
            catch { http::cleanup $token }
            return
        }

        http::cleanup $token
        if {[string length $answer] == 0 || $returncode != 200} {
            msg "Upload failed: $returnfullcode"
            borg toast "Upload failed!"
            set settings(last_upload_result) "[translate {Upload failed!}] $returnfullcode"
            plugins save_settings log_upload
            return
        }

        borg toast "Upload successful"
        if {[catch {
            set response $answer
        } err] != 0} {
            msg "Upload successful but unexpected server answer!"
            set settings(last_upload_result) [translate "Upload successful but unexpected server answer!"]
            plugins save_settings log_upload
            return
        }
        msg "Upload successful"
        set settings(last_upload_log) $answer
        set settings(last_upload_result) "[translate {Upload successful}]"
        plugins save_settings log_upload

        return $answer
    }

    proc uploadLogfiles {} {
        variable settings
        set settings(last_upload_result) ""
	set settings(last_upload_log) ""

	set _logfile_name "[homedir]/$::settings(logfile)"

        if {[file readable $_logfile_name]} {
            ::logging::flush_log
            set log_file_contents [read_binary_file $_logfile_name]
        } else {
            set log_file_contents "Unable to read $_logfile_name"
        }

        set shotfiles [lsort -dictionary -decreasing [glob -nocomplain -tails -directory "[homedir]/history/" *.shot]]
        if {[llength $shotfiles] < 1} {
            set shotfile_contents [format_espresso_for_history]
        } else {
            set shot_file [lindex $shotfiles 0]
            set shotfile_contents [read_file "[homedir]/history/$shot_file"]
        }

        set settings_contents [array get ::settings]
        set spacer "--------------"

        ::plugins::log_upload::upload "$shotfile_contents\n$spacer\n$settings_contents\n$spacer\n$log_file_contents"
    }

    proc browse {} {
        variable settings
        
        if { [info exists settings(last_upload_log)] && $settings(last_upload_log) ne ""  } {
            web_browser $settings(last_upload_log)
        }
    }
    
    proc main {} {
        plugins gui log_upload [create_ui]
    }

}
