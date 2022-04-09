package provide de1_plugins 1.0

package require de1_logging 1.1

proc plugin_directory {} {
    return "plugins"
}

proc plugin_settings_file {plugin} {
    return "[homedir]/[plugin_directory]/${plugin}/settings.tdb"
}

proc plugin_settings {plugin} {
    return "::plugins::${plugin}::settings"
}

proc load_plugin_settings {plugin} {
    plugins load_settings $plugin
}

proc save_plugin_settings {plugin} {
    plugins save_settings $plugin
}

proc plugin_preload {plugin} {
    plugins preload $plugin
}

proc load_plugin {plugin} {
    plugins load $plugin
}

proc plugin_enabled {plugin} {
    plugins enabled $plugin
}

proc plugin_available {plugin} {
	plugins available $plugin
}

proc plugin_preloaded {plugin} {
	plugins loaded $plugin
}

proc plugin_loaded {plugin} {
	plugins loaded $plugin
}

proc toggle_plugin {plugin} {
    plugins toggle $plugin
}

proc available_plugins {} {
    plugins list
}

proc load_plugins {} {
    plugins init
}

proc enable_plugin {plugin} {
    plugins enable $plugin
}

proc disable_plugin {plugin} {
    plugins disable $plugin
}

namespace eval ::plugins {
    namespace export load_settings save_settings peek load list toggle disable enable init available enabled loaded peeked read gui preload
    namespace ensemble create

    proc read {plugin} {
        if {[file exists "[homedir]/[plugin_directory]/$plugin/plugin.tcl"] != 1} {
            msg -ERROR [namespace current] "Plugin $plugin does not exist"
            return 0
        }

        ::source "[homedir]/[plugin_directory]/${plugin}/plugin.tcl"

        return 1
    }

    # Keeping compatibilty to early 1.34 beta version
    proc preload {plugin} {
        load $plugin
    }

    proc peek {plugin} {
        msg -INFO [namespace current] "peeking $plugin"
        if { [peeked $plugin] } {
            return
        }

        # Set metadata in case the plugin does not
        namespace eval ::plugins::$plugin {
            variable author {}
            variable contact {}
            variable version {}
            variable name {}
            variable description {}
            variable plugin_peeked 0
            variable plugin_loaded 0
        }

        array set ::plugins::${plugin}::settings {}

        plugins load_settings $plugin

        if {[catch {

                if {$plugin == "D_Flow_Espresso_Profile"} {
                    if {[plugin_enabled $plugin] != true} {
                        # don't peek into the D-Flow plugin code at all if not enabled, because it overwrites other code in the de1app.  Can undo this patch once D-Flow behaves like other extensions
                        return 0
                    }
                }

                # these plugins don't work without Androwish/Undroidwish
                if {$::android != 1 && $::undroid != 1} {
                    if {$plugin == "SDB" || $plugin == "DYE"} {
                        # the DYE and SDB plugins require Androwish/Undroidwish, or it crashes the app on peeking
                        return 0
                    }
                }

                msg -INFO [namespace current] "sourcing $plugin"
                if {[::plugins::read $plugin] != 1} {
                    error "sourcing failed"
                }
                set ${plugin}::plugin_peeked 1
        } err opts_dict] != 0} {
            ::logging::log_error_result_opts_dict $err $opts_dict
            catch {
                info_page [subst {${plugin}:[translate "The plugin did not load correctly"]\n\n$err}] [translate "Ok"]
            }
        }
    }

    proc gui {plugin context} {
        set ${plugin}::ui_entry $context
    }

    proc load {plugin} {
        if { [loaded $plugin] } {
            return
        }
        
        if {[catch {
            if {[info proc ${plugin}::preload] != ""} {
                set ${plugin}::ui_entry [${plugin}::preload]
            }
            if {[info proc ${plugin}::main] != ""} {
                ${plugin}::main
            } else {
                borg toast "loaded empty plugin $plugin"
            }
            set ${plugin}::plugin_loaded 1
            msg -NOTICE "loaded plugin" $plugin 
        } err opts_dict] != 0} {
            ::logging::log_error_result_opts_dict $err $opts_dict
            catch {
                if {!::debugging} {
                    # remove from enabled plugins
                    disable_plugin $plugin
                }
            }
            catch {
                info_page [subst {${plugin}:[translate "The plugin could not be loaded. Disabled"]\n\n$err}] [translate "Ok"]
            }
        }
    }

    proc list {} {
        set plugin_sources [lsort -dictionary [glob -nocomplain -tails -type d -directory "[homedir]/[plugin_directory]" * ]]
        set plugins {}

        foreach p $plugin_sources {
            set fbasename [file rootname [file tail $p]]
            if {[file exists "[homedir]/[plugin_directory]/$fbasename/plugin.tcl"] == 1} {
                lappend plugins $fbasename
            }
        }

        return $plugins
    }

    proc toggle {plugin} {
        if {[plugin_enabled $plugin]} {
            disable_plugin $plugin
        } else {
            enable_plugin $plugin
        }
        return [plugin_enabled $plugin]
    }

    proc disable {plugin} {
        if {[plugin_enabled $plugin] == 0} {
            return 0;
        }
        set new [lsearch -inline -all -not -exact $::settings(enabled_plugins) $plugin]
        set ::settings(enabled_plugins) $new
        ::save_settings
        return 1;
    }

    proc enable {plugin} {
        if {[plugin_enabled $plugin]} {
            return 0;
        }
        lappend ::settings(enabled_plugins) $plugin
        ::save_settings
        plugins peek $plugin
        plugins load $plugin
        return 1;
    }

    proc save_settings {plugin} {
        save_array_to_file [plugin_settings $plugin] [plugin_settings_file $plugin]
    }


    proc load_settings {plugin} {
        msg -NOTICE [namespace current] "loading settings for $plugin"
        set fn [plugin_settings_file $plugin]
        if { [file exists $fn] } {
            set settings_file_contents [encoding convertfrom utf-8 [read_binary_file $fn]]
            if {[string length $settings_file_contents] != 0} {
                array set [plugin_settings $plugin] $settings_file_contents
                return 1
            }
        }
        msg -INFO [namespace current] "Settings file $fn not found"
        return 0
    }

    proc init {} {
        # Source all plugins
        foreach plugin [plugins list] {
            plugins peek $plugin
        }

        # start enabled plugins
        foreach plugin $::settings(enabled_plugins) {
            plugins load $plugin
        }
    }

    #
    # Status requests
    #
    proc available {plugin} {
        return [expr {[lsearch [plugins list] $plugin] >= 0}]
    }

    proc peeked {plugin} {
        return [expr {[info exists ::plugins::${plugin}::plugin_peeked] && [subst \$::plugins::${plugin}::plugin_peeked] == 1}]
    }

    proc loaded {plugin} {
        return [expr {[info exists ::plugins::${plugin}::plugin_loaded] && [subst \$::plugins::${plugin}::plugin_loaded] == 1}]
    }

    proc enabled {plugin} {
        if {[lsearch $::settings(enabled_plugins) $plugin] >= 0} {
            return true
        }
        return false
    }
}
