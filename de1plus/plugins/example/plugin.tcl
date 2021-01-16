
# Change package name for you extension / plugin
set plugin_name "example"

# These are chown in the plugin selection page
set ::plugins::${plugin_name}::author "JoJo"
set ::plugins::${plugin_name}::contact "email@coffee-mail.de"
set ::plugins::${plugin_name}::version 1.0
set ::plugins::${plugin_name}::description "Minimal plugin to showcase the interface of the plugin / extensions system."

# preload is called on app start even if the plugin is disabled. Can be used to show
# dynamic informations on the settings overview. Please dont put logic here
# needs to return the page you want to be shown first
proc ::plugins::${plugin_name}::preload {} {
    # Unique name per page
    set page_name "plugin_example_page_default"

    # Background image and "Done" button
    add_de1_page "$page_name" "settings_message.png" "default"
    add_de1_text $page_name 1280 1310 -text [translate "Done"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"
	add_de1_button $page_name {say [translate {Done}] $::settings(sound_button_in); fill_extensions_listbox; page_to_show_when_off extensions; set_extensions_scrollbar_dimensions}  980 1210 1580 1410 ""

    # Headline
    add_de1_text $page_name 1280 300 -text [translate "Example Plugin"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"

    # The actual content. Here a list of all settings for this plugin
    set content_textfield [add_de1_text $page_name 600 380 -text  "" -font global_font -width 600 -fill "#444444" -anchor "nw" -justify "left" ]
    set description ""
    foreach {key value} [array get ::plugins::example::settings] {
		set description "$description\n$key: $value"
  	}
    .can itemconfigure $content_textfield -text $description

    return $page_name
}


# Preload_tab is used to acces the quick-access tabs. This offers less free space but at the same time allows
# for easier access without moving trough the menues
proc ::plugins::${plugin_name}::preload_tab {page_name} {
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
    msg "Accessing loaded settings: $::plugins::example::settings(amazing_feature)"
    msg "Changing settings"
    set ::plugins::example::settings(amazing_feature) 3
    msg "Saving settings"
    save_plugin_settings "example"
    msg "Dumping settings:"
    msg [array get ::plugins::example::settings]

    msg "registering espresso ending handler"
    register_state_change_handler "Espresso" "Idle" on_espresso_end

    msg "Tracing function call"
    trace add execution start_sleep leave on_function_called
}

