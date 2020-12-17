package provide de1_plugins 1.0

namespace eval ::plugins {}

proc plugin_directory {} {
    return "plugins"
}

proc plugin_settings_file {plugin} {
    return "[homedir]/[plugin_directory]/${plugin}/settings.tdb"
}

proc plugin_settings {plugin} {
    return "::plugins::${plugin}::settings"
}

proc create_plugin_namespace {plugin} {
    namespace eval ::plugins::$plugin {}

    # Set metadata in case the plugin does not
    set ::plugins::${plugin}::author {}
    set ::plugins::${plugin}::contact {}
    set ::plugins::${plugin}::version {}
    set ::plugins::${plugin}::description {}
    set ::plugins::${plugin}::plugin_loaded 0

    array set ::plugins::${plugin}::settings {}
}

proc load_plugin_settings {plugin} {
    create_plugin_namespace $plugin

    set settings_file_contents [encoding convertfrom utf-8 [read_binary_file [plugin_settings_file $plugin]]]
    msg "Settings file: $settings_file_contents"
    if {[string length $settings_file_contents] != 0} {
        array set [plugin_settings $plugin] $settings_file_contents
    }
}

proc save_plugin_settings {plugin} {
    save_array_to_file [plugin_settings $plugin] [plugin_settings_file $plugin]
}

proc source_plugin {plugin} {
        load_plugin_settings $plugin
		source "[homedir]/[plugin_directory]/$plugin/plugin.tcl"
        set ::plugins::${plugin}::plugin_loaded 1
}

proc plugin_preload {plugin} {
    if {[catch {
            source_plugin $plugin
            if {[info proc ::plugins::${plugin}::preload] != ""} {
                set ::plugins::${plugin}::ui_entry [::plugins::${plugin}::preload]
            }
	} err] != 0} {
		catch {
			message_page [subst {[translate "The plugin $plugin could not be sourced for metadata"]\n\n$err}] [translate "Ok"]
		}
	}
}

proc load_plugin {plugin} {
	if {[catch {
        ::plugins::${plugin}::main
	} err] != 0} {
		catch {
			# remove from enabled plugins
            set idx [lsearch $::settings(enabled_plugins) $plugin]
            set $::settings(enabled_plugins) [lreplace $::settings(enabled_plugins) $idx $idx]
            save_settings
		}
		catch {
			message_page [subst {[translate "The plugin $plugin could not be loaded. Disabled"]\n\n$err}] [translate "Ok"]
		}
	}
}

proc plugin_enabled {plugin} {
    if {[lsearch $::settings(enabled_plugins) $plugin] >= 0} {
        return true
    }
    return false
}

proc toggle_plugin {plugin} {
    if {[plugin_enabled $plugin]} {
        set new [lsearch -inline -all -not -exact $::settings(enabled_plugins) $plugin]
        set ::settings(enabled_plugins) $new
        save_settings
    } else {
        lappend ::settings(enabled_plugins) $plugin
        save_settings
    }
}

proc available_plugins {} {
    set plugin_sources [lsort -dictionary [glob -nocomplain -tails -directory [plugin_directory] * ]]
    set plugins {}

    foreach p $plugin_sources {
        set fbasename [file rootname [file tail $p]]
        lappend plugins $fbasename
    }

    return $plugins
}

proc load_plugins {} {
    # Preload all plugins
    foreach plugin [available_plugins] {
        plugin_preload $plugin
    }

    # start enabled plugins
    foreach plugin $::settings(enabled_plugins) {
        load_plugin $plugin
    }
}