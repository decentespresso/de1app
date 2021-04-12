set plugin_name "DPx_Steam_Stop"

namespace eval ::plugins::${plugin_name} {
    # These are shown in the plugin selection page
    variable author "Damian"
    variable contact "via Diaspora"
    variable version 1.1
    variable description "This plugin will change stopping steam via the tablet\r- First tap will start gentle puffs\r- Second tap will end and purge"

    proc DPx_start_idle {} {
        proc ::start_idle {} {
            msg "Tell DE1 to start to go IDLE (and stop whatever it is doing)"

            if  {[sdltk screensaver] == 1} {
                sdltk screensaver off
            }

            if {$::de1(device_handle) == 0} {
                update_de1_state "$::de1_state(Idle)\x0"
                ble_connect_to_de1
                return
            }

            if {$::settings(stress_test) == 1} {
                # pressing stop on any step will stop the stress test
                unset -nocomplain ::idle_next_step
            }
            set ::settings(flying) 0
            if {$::de1_num_state($::de1(state)) == "Steam"} {

                if {$::settings(steam_timeout) > 1} {
                    set ::DPx_steam_timer_backup $::settings(steam_timeout)
                    set ::settings(steam_timeout) 1
                    de1_send_steam_hotwater_settings
                    set ::DPx_puffs_on 1
                    return
                }
                if {$::DPx_puffs_on == 1} {
                    set ::settings(steam_timeout) $::DPx_steam_timer_backup
                    de1_send_steam_hotwater_settings
                    set ::DPx_puffs_on 0
                }

            }
            de1_send_state "go idle" $::de1_state(Idle)

            if {[firmware_has_fan_sleep_bug] == 1} {
                set_fan_temperature_threshold $::settings(fan_threshold)
            }

            if {$::android == 0} {
                after 200 [list update_de1_state "$::de1_state(Idle)\x0"]
            }
        }
    }

    proc main {} {
        DPx_start_idle
    }

}