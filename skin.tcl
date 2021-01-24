# Barney's Metric skin
package provide metric 0.5
package require de1plus 1.0

source "[homedir]/skins/default/standard_includes.tcl"

set ::skindebug 0
set ::debugging 0

source "[skin_directory]/settings.tcl"

iconik_load_settings

source "[skin_directory]/framework.tcl"
source "[skin_directory]/ui.tcl"

create_grid
.can itemconfigure "grid" -state "hidden" 
#.can itemconfigure "grid" -state "normal" 

#dont change page on state change
proc skins_page_change_due_to_de1_state_change { textstate } {
    if {$textstate == "Sleep"} {
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
		select_profile "weber_spring_clean"
}

proc is_connected {} {return [expr {[clock seconds] - $::de1(last_ping)} < 5]}
proc is_scale_disconnected {} {return [expr $::de1(scale_device_handle) == 0 && $::settings(scale_bluetooth_address) != ""]}

proc iconik_get_status_text {} {
	if {[is_connected] != 1} {
		return [translate "Disconnected"]
	}

	if {$::de1(scale_device_handle) == 0 && $::settings(scale_bluetooth_address) != ""} {
		return [translate "Scale disconnected"]
	} 

	switch $::de1(substate) {
		"-" { 
			return [translate "Starting"]
		}
		0 {
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

proc iconik_toggle_steam_settings {slot} {
	# TODO: use dict
	if {$slot == 1} {
		set new_steam_timeout $::iconik_settings(steam_timeout1)
		set ::iconik_settings(steam_timeout1) $::settings(steam_timeout)
	} else {
		set new_steam_timeout $::iconik_settings(steam_timeout2)
		set ::iconik_settings(steam_timeout2) $::settings(steam_timeout)
	}
	iconik_save_settings
	set ::settings(steam_timeout) $new_steam_timeout
	save_settings
	de1_send_steam_hotwater_settings
}

proc timout_flush {old new}  {
	after [round_to_integer [expr $::iconik_settings(flush_timeout) * 1000]] start_idle
}

proc iconik_save_profile {slot} {
	#TODO use DICT
	if {$slot == 1} {
		set ::iconik_settings(profile1) $::settings(profile_filename);
		set ::iconik_settings(profile1_title) $::settings(profile_title); 
	}
	if {$slot == 2} {
		set ::iconik_settings(profile2) $::settings(profile_filename);
		set ::iconik_settings(profile2_title) $::settings(profile_title); 
	}
	if {$slot == 3} {
		set ::iconik_settings(profile3) $::settings(profile_filename);
		set ::iconik_settings(profile3_title) $::settings(profile_title); 
	}
	iconik_save_settings
	borg toast [translate "Saved in slot $slot"]
}

register_state_change_handler "Idle" "HotWaterRinse" timout_flush

