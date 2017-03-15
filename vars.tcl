# de1 internal state live variables
package provide de1_vars 1.0

#############################
# raw data from the DE1

proc clear_espresso_chart {} {
	espresso_elapsed append 0
	espresso_elapsed length 0
	espresso_pressure length 0
	espresso_flow length 0
	espresso_temperature_mix length 0
	espresso_temperature_basket length 0
	espresso_state_change length 0
	espresso_pressure_goal length 0
	espresso_flow_goal length 0
	espresso_temperature_goal length 0
	clear_timers

	update
}	

proc espresso_frame_title {num} {
	if {$num == 1} {
		return "1) Ramp up pressure to 8.4 bar over 12 seconds"
	} elseif {$num == 2} {
		return "2) Hold pressure at 8.4 bars for 10 seconds"
	} elseif {$num == 3} {
		return "3) Maintain 1.2 ml/s flow rate for 30 seconds"
	} elseif {$num == 4} {
		return ""
	} elseif {$num == 5} {
		return ""
	} elseif {$num == 6} {
		return ""
	}
}

proc espresso_frame_description {num} {
	if {$num == 1} {
		return "Gently go to 8.4 bar of pressure with a water mix temperature of 92ºC. Go to the next step after 10 seconds. temperature of 92ºC. Gently go to 8.4 bar of pressure with a water mix temperature of 92ºC."
	} elseif {$num == 2} {
		return "Quickly go to 8.4 bar of pressure with a basket temperature of 90ºC. Go to the next step after 10 seconds."
	} elseif {$num == 3} {
		return "Automatically manage pressure to attain a flow rate of 1.2 ml/s at a water temperature of 88ºC.  End this step after 30 seconds."
	} elseif {$num == 4} {
		return ""
	} elseif {$num == 5} {
		return ""
	} elseif {$num == 6} {
		return ""
	}
}

proc format_alarm_time { in } {
	if {$::settings(enable_ampm) == 1} {
		return [clock format [expr {[round_date_to_nearest_day [clock seconds]] + round($in)}] -format {%l:%M %p}] 
	} else {
		return [clock format [expr {[round_date_to_nearest_day [clock seconds]] + round($in)}] -format {%H:%M}] 
	}
}

proc clear_timers {} {
	global start_timer
	global start_millitimer
	set start_timer [clock seconds]
	set start_millitimer [clock milliseconds]
	unset -nocomplain ::timers
	unset -nocomplain ::substate_timers
	puts "clearing timers"
}

# amount of time that we've been on this page
proc timer {} {
	global start_timer
	return [expr {[clock seconds] - $start_timer}]
}

proc millitimer {} {
	global start_millitimer
	return [expr {[clock milliseconds] - $start_millitimer}]
}

proc event_timer_calculate {state destination_state previous_states} {

	set eventtime [get_timer $state $destination_state]
	 set beforetime 0
	foreach s $previous_states {
		set thistime [get_timer $state $s]
		if {$thistime > $beforetime} {
			set beforetime $thistime
		}
	}

	set elapsed [expr {($eventtime - $beforetime)/100}]
	if {$elapsed < 0} {
		# this means that the event has not yet started
		return 0
	}

	return $elapsed
}

proc preinfusion_timer {} {
	return [event_timer_calculate "Espresso" "preinfusion" {"perfecting the mix" "final heating" "heating the water tank"} ]
}


proc pour_timer {} {
	return [event_timer_calculate "Espresso" "pouring" {"preinfusion" "perfecting the mix" "final heating" "heating the water tank"} ]
}


proc steam_timer {} {
	return [event_timer_calculate "Steam" "pouring" {"perfecting the mix" "final heating"} ]
}

proc water_timer {} {
	return [event_timer_calculate "HotWater" "pouring" {"perfecting the mix" "final heating"} ]
}

proc waterflow {} {
	if {$::de1(substate) != $::de1_substate_types_reversed(pouring) && $::de1(substate) != $::de1_substate_types_reversed(preinfusion)} {	
		return 0
	}

	if {$::android == 0} {
		set ::de1(flow) [expr {4 + (rand() * 2)}]
	}

	return $::de1(flow)
	
}

set start_timer [clock seconds]
set start_millitimer [clock milliseconds]
proc watervolume {} {
	if {$::de1(substate) != $::de1_substate_types_reversed(pouring) && $::de1(substate) != $::de1_substate_types_reversed(preinfusion)} {	
		return 0
	}


	if {$::android == 1} {
		return $::de1(volume)
	}
	global start_timer
	return [expr {[clock seconds] - $start_timer}]
}

proc steamtemp {} {
	if {$::android == 0} {
		set ::de1(steam_heater_temperature) [expr {int(160+(rand() * 5))}]
	}
	return $::de1(steam_heater_temperature)
}

proc watertemp {} {
	if {$::android == 0} {
		set ::de1(head_temperature) [expr {$::settings(espresso_temperature) - 2.0 + (rand() * 4)}]
		set ::de1(goal_temperature) $::settings(espresso_temperature)
	}

	return $::de1(head_temperature)
}

proc pressure {} {
	if {$::de1(substate) != $::de1_substate_types_reversed(pouring) && $::de1(substate) != $::de1_substate_types_reversed(preinfusion)} {	
		return 0
	}

	if {$::android == 0} {
		set ::de1(pressure) [expr {rand() * 11}]
	}

	return $::de1(pressure)
	#if {$::android == 1} {
	#}
	#return [expr {(rand() * 3.5)}]
}

proc accelerometer_angle {} {
	if {$::android == 0} {
		set ::settings(accelerometer_angle) [expr {(rand() + $::settings(accelerometer_angle)) - 0.5}]
	}
	#msg "::settings(accelerometer_angle) : $::settings(accelerometer_angle)"
	return [round_to_one_digits [expr {abs($::settings(accelerometer_angle))}]]

}

set since_last_acc [clock milliseconds]
set last_acc_count 0
proc accelerometer_angle_text {} {
	global accelerometer_read_count

	global since_last_acc
	global last_acc_count

	set rate 0
	set delta 0
	catch {
		set delta [expr {$accelerometer_read_count - $last_acc_count}]
		set rate [expr {1000* ([clock milliseconds] - $since_last_acc}]
	}
	set since_last_acc [clock milliseconds]
	set last_acc_count $accelerometer_read_count
	return "$::settings(accelerometer_angle)º ($accelerometer_read_count) $rate events/second $delta events $rate"
}

proc group_head_heater_temperature {} {
	if {$::android == 0} {
		set ::de1(head_temperature) [expr {80 + (rand() * 15.0)}]
	}

	return $::de1(head_temperature)
}

proc steam_heater_temperature {} {
	if {$::android == 0} {
		set ::de1(mix_temperature) [expr {140 + (rand() * 20.0)}]
	}

	return $::de1(steam_heater_temperature)

}
proc water_mix_temperature {} {
	if {$::android == 0} {
		set ::de1(mix_temperature) [expr {80 + (rand() * 15.0)}]
	}

	return $::de1(mix_temperature)
}





#################
# formatting DE1 numbers into pretty text



proc steam_heater_action_text {} {
	set delta [expr {int([steam_heater_temperature] - [setting_steam_temperature])}]
	if {$delta < -2} {
		return [translate "(Heating):"]
	} elseif {$delta > 2} {
		return [translate "(Cooling):"]
	} else {
		return [translate "Heated:"]
	}
}

proc group_head_heater_action_text {} {
	set delta [expr {int([group_head_heater_temperature] - [setting_espresso_temperature])}]
	if {$delta < -5} {
		return [translate "Heating:"]
	} elseif {$delta > 5} {
		return [translate "Cooling:"]
	} else {
		return [translate "Heated:"]
	}
}

proc group_head_heating_text {} {
	set delta [expr {int([group_head_heater_temperature] - [setting_espresso_temperature])}]
	if {$delta < -5} {
		return [translate "(heating)"]
	}
}

proc timer_text {} {
	return [subst {[timer] [translate "seconds"]}]
}

proc return_liquid_measurement {in} {
	if {$::settings(enable_fluid_ounces) != 1} {
		return [subst {[round_to_two_digits $in] [translate "ml"]}]
	} else {
		return [subst {[round_to_two_digits [ml_to_oz $in]] oz}]
	}
}

proc return_flow_measurement {in} {
	if {$::settings(enable_fluid_ounces) != 1} {
		return [subst {[round_to_two_digits $in] [translate "ml/s"]}]
	} else {
		return [subst {[round_to_two_digits [ml_to_oz $in]] oz/s}]
	}
}

proc waterflow_text {} {
	return [return_flow_measurement [waterflow]] 
}

proc watervolume_text {} {
	return [return_liquid_measurement $::de1(volume)] 
}



proc mixtemp_text {} {
	return [return_temperature_measurement [water_mix_temperature]]
}

proc watertemp_text {} {
	return [return_temperature_measurement [watertemp]]
}

proc steamtemp_text {} {
	return [return_temperature_measurement [steamtemp]]
}

proc pressure_text {} {
	return [subst {[round_to_two_digits [pressure]] [translate "bar"]}]
}

#######################
# settings
proc setting_steam_max_time {} {
	return [expr {round( $::settings(steam_max_time) )}]
}
proc setting_water_max_time {} {
	return [expr {round( $::settings(water_max_time) )}]
}
proc setting_espresso_max_time {} {
	return $::settings(espresso_max_time)
}
proc setting_steam_max_time_text {} {
	return [subst {[setting_steam_max_time] [translate "seconds"]}]
}
proc setting_water_max_time_text {} {
	return [subst {[setting_water_max_time] [translate "seconds"]}]
}
proc setting_espresso_max_time_text {} {
	return [subst {[setting_espresso_max_time] [translate "seconds"]}]
}


proc setting_steam_temperature {} {
	return $::settings(steam_temperature)
}
proc setting_espresso_temperature {} {
	return $::settings(espresso_temperature)
}
proc setting_water_temperature {} {
	return $::settings(water_temperature)
}

proc return_temperature_number {in} {
	if {$::settings(enable_fahrenheit) == 1} {
		return [round_to_one_digits [celsius_to_fahrenheit $in]]
	} else {
		return [round_to_one_digits $in]
	}
}
proc return_temperature_measurement {in} {
	if {$::settings(enable_fahrenheit) == 1} {
		return [subst {[round_to_integer [celsius_to_fahrenheit $in]]ºF}]
	} else {
		return [subst {[round_to_integer $in]ºC}]
	}
}

proc setting_steam_temperature_text {} {
	return [return_temperature_measurement [setting_steam_temperature]]
}
proc setting_water_temperature_text {} {
	return [return_temperature_measurement [setting_water_temperature]]
}



proc steam_heater_temperature_text {} {
	return [return_temperature_measurement [steam_heater_temperature]]
}

proc group_head_heater_temperature_text {} {
	return [return_temperature_measurement [group_head_heater_temperature]]
}

proc setting_espresso_temperature_text {} {
	return [return_temperature_measurement [setting_espresso_temperature]]
}

proc setting_espresso_pressure {} {
	return $::settings(espresso_pressure)
}
proc setting_espresso_pressure_text {} {
	return [subst {[round_to_one_digits [setting_espresso_pressure]] [translate "bar"]}]
}

proc setting_espresso_stop_pressure_text {} {
	if {$::settings(preinfusion_stop_pressure) == 0} {
		return ""
	}
	return [subst {[round_to_one_digits $::settings(preinfusion_stop_pressure)] [translate "bar"]}]
}

proc setting_espresso_stop_flow_text {} {
	if {$::settings(preinfusion_stop_flow_rate) == 0} {
		return ""
	}
	return [subst {[return_flow_measurement $::settings(preinfusion_stop_flow_rate)]}]
}


proc graph_seconds_axis_format {nm val} {
	if {$val == 0} {
		return [translate "start"]
	}
	return "$val [translate {seconds}]"
}




#######################
# conversion functions

proc round_to_two_digits {in} {
	set x 0
    catch {
    	set x [expr {round($in * 100.0)/100.0}]
    }
    return $x
}

proc round_to_one_digits {in} {
	set x 0
	catch {
    	set x [expr {round($in * 10.0)/10.0}]
    }
    return $x
}

proc round_to_integer {in} {
	set x 0
	catch {
    	set x [expr {round($in)}]
    }
    return $x
}

proc celsius_to_fahrenheit {in} {
	set x 0
	catch {
		set x [expr {32 + ($in * 1.8)}]
	}
	return $x
}

proc ml_to_oz {in} {
	set x 0
	catch {
		set x [expr {$in * 0.033814}]
	}
	return $x
}

proc backup_settings {} {
	unset -nocomplain ::settings_backup; 
	array set ::settings_backup [array get ::settings]
}

proc skin_directories {} {
	set dirs [glob -tails -directory "[homedir]/skins/" *]
	set dd {}
	foreach d $dirs {
		if {$d == "CVS" || $d == "example"} {
			continue
		}
		lappend dd $d		
	}
	return $dd
}

proc fill_skin_listbox {widget} {
	set cnt 0
	set current_skin_number 0
	foreach d [lsort -increasing [skin_directories]] {
		if {$d == "CVS" || $d == "example"} {
			continue
		}
		$widget insert $cnt $d
		if {$::settings(skin) == $d} {
			set current_skin_number $cnt
		}
		incr cnt
	}
	$widget itemconfigure $current_skin_number -foreground blue

	$widget selection set $current_skin_number

	bind $widget <<ListboxSelect>> [list ::preview_tablet_skin %W] 	

	set ::globals(tablet_styles_listbox) $widget
}

proc save_new_tablet_skin_setting {} {
	set ::settings(skin) [$::globals(tablet_styles_listbox) get [$::globals(tablet_styles_listbox) curselection]]
	puts "skin changed to '$::settings(skin)'"
}

proc preview_tablet_skin {w args} {
	set ::settings(skin) [$::globals(tablet_styles_listbox) get [$::globals(tablet_styles_listbox) curselection]]
	set skindir [$w get [$w curselection]]
	set fn "[homedir]/skins/$skindir/${::screen_size_width}x${::screen_size_height}/icon.jpg"
	$::table_style_preview_image read $fn
}
