
# Change package name for you extension / plugin
set plugin_name "example"

namespace eval ::plugins::${plugin_name} {

    # These are shown in the plugin selection page
    variable author "JoJo"
    variable contact "email@coffee-mail.de"
    variable version 1.0
    variable description "Minimal plugin to showcase the interface of the plugin / extensions system."
    variable name "Example Plugin"

    proc build_ui {}  {
        variable settings

        # Unique name per page
        set page_name "plugin_example_page_default"

        # Background image and "Done" button
        add_de1_page "$page_name" "settings_message.png" "default"
        add_de1_text $page_name 1280 1310 -text [translate "Done"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"
        add_de1_button $page_name {say [translate {Done}] $::settings(sound_button_in); page_to_show_when_off extensions}  980 1210 1580 1410 ""

        # Headline
        add_de1_text $page_name 1280 300 -text [translate "Example Plugin"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"

        # The actual content. Here a list of all settings for this plugin
        set content_textfield [add_de1_text $page_name 600 380 -text  "" -font global_font -width 600 -fill "#444444" -anchor "nw" -justify "left" ]
        set description ""
        foreach {key value} [array get settings] {
            set description "$description\n$key: $value"
        }
        .can itemconfigure $content_textfield -text $description

        return $page_name
    }

    proc on_espresso_end {old new} {
        borg toast "espresso ended"
    }

    proc on_function_called {call code result op} {
        borg toast "start_sleep called!"
    }

    # This file will be sourced to display meta-data. Dont put any code into the
    # general scope as there are no guarantees about when it will be run.
    # For security reasons it is highly unlikely you will find the plugin in the
    # official distribution if you are not beeing run from your main
    # REQUIRED
    proc main {} {
        variable settings

        msg [namespace current] "Accessing loaded settings: $settings(amazing_feature)"
        msg [namespace current] "Changing settings"
        set settings(amazing_feature) 3
        msg [namespace current] "Saving settings"
        save_plugin_settings "example"
        msg [namespace current] "Dumping settings:"
        msg [array get settings]

        msg [namespace current] "registering espresso ending handler"
        register_state_change_handler "Espresso" "Idle" ::plugins::example::on_espresso_end

        msg [namespace current] "Tracing function call"
        trace add execution start_sleep leave ::plugins::example::on_function_called

        # register gui
        plugins gui example [build_ui]
    }
}
