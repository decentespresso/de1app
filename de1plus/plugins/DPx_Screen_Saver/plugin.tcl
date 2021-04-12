# Change package name for you extension / plugin
set plugin_name "DPx_Screen_Saver"

namespace eval ::plugins::${plugin_name} {
    # These are shown in the plugin selection page
    variable author "Damian"
    variable contact "via Diaspora"
    variable version 1.1
    variable description "A plugin that allows users to select an alternate screen saver directory, for skins that don't already do so"

    proc build_ui {} {
        # Unique name per page
        set page_name "DPx_SS_options"

        # Background image and "Done" button
        add_de1_page "$page_name" "settings_message.png" "default"
        add_de1_text $page_name 1280 1310 -text [translate "Done"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"
        add_de1_button $page_name {say [translate {Done}] $::settings(sound_button_in); page_to_show_when_off extensions; }  980 1210 1580 1410 ""

        # Headline
        add_de1_text $page_name 1280 300 -text [translate "DPx Screen Saver"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"

        # The actual content. Here a list of all settings for this plugin
        add_de1_variable $page_name 1280 600 -justify center -anchor "n" -font Helv_10 -fill "#444444" -textvariable {[::plugins::DPx_Screen_Saver::message]}
        add_de1_button "$page_name" {say [translate {awake}] $::settings(sound_button_in); ::plugins::DPx_Screen_Saver::create_mysaver} 1000 450 1560 750

        return $page_name
    }

    proc create_mysaver {} {
        if {[file exists [homedir]/MySaver/${::screen_size_width}x${::screen_size_height}] != 1} {
            set path [homedir]/MySaver/${::screen_size_width}x${::screen_size_height}
            file mkdir $path
            file attributes $path
        }
    }

    proc message {args} {
        if {[file exists [homedir]/MySaver/${::screen_size_width}x${::screen_size_height}] != 1} {
            return "I could not find MySaver/${::screen_size_width}x${::screen_size_height} folder\r If you tap  **HERE** I'll create them for you"
        }
        set dir "[homedir]/MySaver/${::screen_size_width}x${::screen_size_height}"
        set file_list [glob -nocomplain "$dir/*"]
        if {[llength $file_list] == 0} {
            return "I found your MySaver/${::screen_size_width}x${::screen_size_height} folder, but the folder is empty\r\rOnce you have added your image files, restart the app\r to direct the screen saver settings to your new images\r\rEnsure you use image files\r${::screen_size_width} pixels wide & ${::screen_size_height} pixels high\rso they fit your display correctly"
        }
        return "MySaver/${::screen_size_width}x${::screen_size_height} found with [llength $file_list] files\r\rAll looks good!"
    }

    proc check_MySaver_exists {args} {
        set dir "[homedir]/MySaver"
        set file_list [glob -nocomplain "$dir/*"]
        if {[llength $file_list] != 0} {
            set_de1_screen_saver_directory "[homedir]/MySaver"
        }
        add_de1_button "saver sleep descaling cleaning" {say [translate {awake}] $::settings(sound_button_in); set_next_page off off; page_show off; start_idle; de1_send_waterlevel_settings; } 0 0 2560 1600

    }

    # This file will be sourced to display meta-data. Dont put any code into the
    # general scope as there are no guarantees about when it will be run.
    # For security reasons it is highly unlikely you will find the plugin in the
    # official distribution if you are not beeing run from your main
    # REQUIRED

    proc main {} {
        trace add execution load_skin leave ::plugins::DPx_Screen_Saver::check_MySaver_exists
        plugins gui DPx_Screen_Saver [build_ui]
    }

}

