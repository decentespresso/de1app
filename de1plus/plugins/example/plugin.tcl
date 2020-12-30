
# Change package name for you extension / plugin
set plugin_name "example"

# These are chown in the plugin selection page
set ::plugins::${plugin_name}::author "JoJo"
set ::plugins::${plugin_name}::contact "email@coffee-mail.de"
set ::plugins::${plugin_name}::version 1.0
set ::plugins::${plugin_name}::description "Minimal plugin to showcase the interface of the plugin / extensions system."

# Just call the plugin translate function with a shortcut
proc i10n {english} {
    msg "i10n $english"
    plugin_translate "example" $english
}

# only set if you want to provide a settings page for your plugin
# returns the name of the page to show next
proc ::plugins::${plugin_name}::settingsfunction {} {
    # Unique name per page
    set page_name "plugin_example_page_default"

    # Background image and "Done" button
    add_de1_page "$page_name" "settings_message.png" "default"
    add_de1_text $page_name 1280 1310 -text [i10n "Done"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"
	add_de1_button $page_name {say [i10n "Done"] $::settings(sound_button_in); page_to_show_when_off settings_4; }  980 1210 1580 1410 ""

    # Headline
    add_de1_text $page_name 1280 300 -text [i10n "Example Plugin"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"

    # The actual content. Here a list of all settings for this plugin
    set content_textfield [add_de1_text $page_name 600 380 -text  "" -font global_font -width 600 -fill "#444444" -anchor "nw" -justify "left" ]
    set description ""
    foreach {key value} [array get ::plugins::example::settings] {
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
# general scope as there are no quarantees about when it will be run.
# For security reasons it is highly unlikely you will find the plugin in the
# official distribution if you are not beeing run from your main
# REQUIRED
proc ::plugins::${plugin_name}::main {} {
    msg "[i10n "Accessing loaded settings"]: $::plugins::example::settings(amazing_feature)"
    msg "[i10n "Changing settings"]"
    set ::plugins::example::settings(amazing_feature) 3
    msg "[i10n "Saving settings"]"
    save_plugin_settings "example"
    msg "[i10n "Dumping settings"]:"
    msg [array get ::plugins::example::settings]

    msg "[i10n "registering espresso ending handler"]"
    register_state_change_handler "Espresso" "Idle" on_espresso_end

    msg "[i10n "Tracing function call"]"
    trace add execution start_sleep leave on_function_called
}

