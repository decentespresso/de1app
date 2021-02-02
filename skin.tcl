# Barney's Metric skin
package provide metric 0.5
package require de1plus 1.0

source "[homedir]/skins/default/standard_includes.tcl"

set ::skindebug 0
set ::debugging 0

source "[skin_directory]/settings.tcl"

iconik_load_settings
iconik_save_settings

source "[skin_directory]/framework.tcl"
source "[skin_directory]/ui.tcl"

create_grid
.can itemconfigure "grid" -state "hidden"
#.can itemconfigure "grid" -state "normal"

#dont change page on state change
proc skins_page_change_due_to_de1_state_change { textstate } {
	if {$textstate == "Idle"} {
		page_display_change $::de1(current_context) "off"
    } elseif {$textstate == "Sleep"} {
		page_display_change $::de1(current_context) "saver"
    } elseif {$textstate == "Refill"} {
		page_display_change $::de1(current_context) "tankempty"
	} elseif {$textstate == "Descale"} {
		page_display_change $::de1(current_context) "descaling"
	} elseif {$textstate == "Clean"} {
		page_display_change $::de1(current_context) "cleaning"
	} elseif {$textstate == "AirPurge"} {
		page_display_change $::de1(current_context) "travel_do"
	}
}

proc iconik_toggle_cleaning {} {
	if {$::iconik_settings(cleanup_use_profile)} {
		select_profile $::iconik_settings(cleanup_profile)
	} else {
		start_cleaning
	}
}

proc is_connected {} {return [expr {[clock seconds] - $::de1(last_ping)} < 5]}
proc is_scale_disconnected {} {return [expr $::de1(scale_device_handle) == 0 && $::settings(scale_bluetooth_address) != ""]}

proc iconik_get_status_text {} {
	if {[is_connected] != 1} {
		return [translate "Disconnected"]
	}

	if {$::de1(scale_device_handle) == 0 && $::settings(scale_bluetooth_address) != ""} {
		return [translate "Scale disconnected.\nTap here"]
	}

	switch $::de1(substate) {
		"-" {
			return [translate "Starting"]
		}
		0 {
			if {$::settings(scale_bluetooth_address) != ""} {
				return [translate "Ready\nScale connected"]
			}
			return [translate "Ready"]
		}
		1 {
			return [translate "Heating"]
		}
		3 {
			return [translate "Stabilising"]
		}
		4 {
			return [translate "Preinfusion"]
		}
		5 {
			return [translate "Pouring"]
		}
		6 {
			return [translate "Ending"]
		}
		17 {
			return [translate "Refilling"]
		}
		default {
			set result [de1_connected_state 0]
			if {$result == ""} { return "Unknown state" }
			return $result
		}
	}

}

proc iconik_status_tap {} {
	if {$::de1(scale_device_handle) == 0 && $::settings(scale_bluetooth_address) != ""} {
		ble_connect_to_scale
	}
}

proc iconic_steam_tap {up} {

	if {$up == "up"} {
		set ::settings(steam_timeout) [expr {$::settings(steam_timeout) + 1}]
	} else {
		set ::settings(steam_timeout) [expr {$::settings(steam_timeout) - 1}]
	}

	dict set ::iconik_settings(steam_profiles) $::iconik_settings(steam_active_slot) timeout $::settings(steam_timeout)

	save_settings
	de1_send_steam_hotwater_settings
}

proc iconik_temperature_adjust {up} {
	if {$::settings(settings_profile_type) == "settings_2c2" || $::settings(settings_profile_type) == "settings_2c"} {
		set new_profile {}
		foreach step $::settings(advanced_shot) {
			array set step_array $step
			if {$up == "up"} {
				set step_array(temperature) [round_to_one_digits [expr {$step_array(temperature) + 0.5}]]
			} else {
				set step_array(temperature) [round_to_one_digits [expr {$step_array(temperature) - 0.5}]]
			}
			lappend new_profile [array get step_array]
		}
		set ::settings(advanced_shot) $new_profile
		array set ::current_adv_step [lindex $::settings(advanced_shot) 0]

	} else {
		if {$up == "up"} {
			set ::settings(espresso_temperature) [expr {$::settings(espresso_temperature) + 0.5}]
		} else {
			set ::settings(espresso_temperature) [expr {$::settings(espresso_temperature) - 0.5}]
		}
	}
	profile_has_changed_set;
	save_profile
	save_settings_to_de1
	save_settings
}

proc iconik_toggle_steam_settings {slot} {

	set new_steam_timeout [dict get $::iconik_settings(steam_profiles) $slot timeout]

	iconik_save_settings
	set ::settings(steam_timeout) $new_steam_timeout
	set ::iconik_settings(steam_active_slot) $slot
	save_settings
	de1_send_steam_hotwater_settings
}

proc iconik_save_water_temperature {} {
	set ::settings(water_temperature) $::iconik_settings(water_temperature_overwride)
	de1_send_steam_hotwater_settings
	save_settings
}

proc iconik_toggle_profile {slot} {

	set profile [dict get $::iconik_settings(profiles) $slot name]

	select_profile $profile

	if {$::settings(settings_profile_type) == "settings_2c2" || $::settings(settings_profile_type) == "settings_2c"} {
		array set ::current_adv_step [lindex $::settings(advanced_shot) 0]
	}

	iconik_save_water_temperature
	save_settings_to_de1
	save_settings
}

proc timout_flush {old new}  {
	after [round_to_integer [expr $::iconik_settings(flush_timeout) * 1000]] start_idle
}

proc iconik_save_profile {slot} {
	set profiles $::iconik_settings(profiles)

	dict set profiles $slot name $::settings(profile_filename)
	dict set profiles $slot title $::settings(profile_title)

	set ::iconik_settings(profiles) $profiles
	iconik_save_settings
	borg toast [translate "Saved in slot $slot"]
}

register_state_change_handler "Idle" "HotWaterRinse" timout_flush


proc iconik_show_settings {} {
	if {$::settings(settings_profile_type) == "settings_2c2" || $::settings(settings_profile_type) == "settings_2c"} {
		fill_advanced_profile_steps_listbox
	}
	show_settings $::settings(settings_profile_type)
}

set ::iconik_max_pressure 0
set ::iconik_min_flow 20

proc iconik_get_max_pressure {} {
	if {$::de1_num_state($::de1(state)) == "Espresso"} {
		if {$::de1(substate) >= $::de1_substate_types_reversed(pouring)} {
			if {$::de1(pressure) >= $::iconik_max_pressure} {
				set ::iconik_max_pressure $::de1(pressure)
			}
		} else {
			set ::iconik_max_pressure 0
		}
	}
	return [round_to_one_digits $::iconik_max_pressure]
}

proc iconik_get_min_flow {} {
	if {$::de1_num_state($::de1(state)) == "Espresso"} {
		if {$::de1_substate_types($::de1(substate)) == "pouring"} {
			if {$::de1(flow) <= $::iconik_min_flow} {
				set ::iconik_min_flow $::de1(flow)
			}
		} else {
			set ::iconik_min_flow 20
		}
	}
	if {$::iconik_min_flow == 20} {
		return 0;
	}
	return [round_to_one_digits $::iconik_min_flow]
}

proc iconik_get_steam_time {} {
	set target_steam_time [round_to_integer $::settings(steam_timeout)]
	if {[info exists ::timers(steam_pour_start)] == 1 && $::de1_num_state($::de1(state)) == "Steam"} {
		set current_steam_time [expr {([clock milliseconds] - $::timers(steam_pour_start))/1000}]
		return "$current_steam_time / ${target_steam_time}s"
	}

	return "${target_steam_time}s"
}

proc iconik_get_final_weight {} {
	if {$::settings(settings_profile_type) == "settings_2c"} {
		set target $::settings(final_desired_shot_weight_advanced)
	} else {
		set target $::settings(final_desired_shot_weight)
	}

	set current ""
	if {$::de1(scale_device_handle) != 0 && $::settings(scale_bluetooth_address) != ""} {
		set current "$::de1(scale_weight) / "
	}

	return "$current$target"
}