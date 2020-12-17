set plugin_name "example"

set ::plugins::${plugin_name}::author "JoJo"
set ::plugins::${plugin_name}::contact "email@coffee-mail.de"
set ::plugins::${plugin_name}::version 1.0
set ::plugins::${plugin_name}::description "Minimal plugin to showcase the interface"

proc on_espresso_end {old new} {
    borg toast "espresso ended"
}

proc on_function_called {call code result op} {
    borh toast "start_sleep called!"
}

# optional
# the file will be sourced and the main will be called.
# The main is therefore optional
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

