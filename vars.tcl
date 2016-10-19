# de1 internal state live variables
package provide de1_vars 1.0

#############################
# raw data from the DE1

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
		return "Gently go to 8.4 bar of pressure with a water mix temperature of 92ºC. Go to the next step after 10 seconds. temperature of 92ºC. Gently go to 8.4 bar of pressure with a water mix temperature of 92ºC. Go to the next step after 10 seconds. temperature of 92ºC. "
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


proc clear_timers {} {
	unset -nocomplain ::timers
}

proc timer {} {
	if {$::android == 1} {
		return [expr {round($::de1(timer) / 100.0)}]
	}
	global start_volume
	return [expr {[clock seconds] - $start_volume}]
}

proc event_timer_calculate {state destination_state previous_states} {

	set eventtime [get_timer $state $destination_state]
	foreach s $previous_states {
		set beforetime [get_timer $state $s]
		if {$beforetime != 0} {
			break
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
	return [event_timer_calculate "Espresso" "preinfusion" {"perfecting the mix" "warming the heater"} ]
}


proc pour_timer {} {
	return [event_timer_calculate "Espresso" "pouring" {"preinfusion" "perfecting the mix" "warming the heater"} ]
}


proc steam_timer {} {
	return [event_timer_calculate "Steam" "pouring" {"perfecting the mix" "warming the heater"} ]
}

proc water_timer {} {
	return [event_timer_calculate "HotWater" "pouring" {"perfecting the mix" "warming the heater"} ]
}

proc waterflow {} {

	if {$::de1(substate) != $::de1_substate_types_reversed(pouring) && $::de1(substate) != $::de1_substate_types_reversed(preinfusion)} {	
		return 0
	}

	if {$::android == 1} {
		return $::de1(flow)
	}
	return [expr {rand() * 15}]
}

set start_volume [clock seconds]
proc watervolume {} {
	if {$::de1(substate) != $::de1_substate_types_reversed(pouring) && $::de1(substate) != $::de1_substate_types_reversed(preinfusion)} {	
		return 0
	}


	if {$::android == 1} {
		return $::de1(volume)
	}
	global start_volume
	return [expr {[clock seconds] - $start_volume}]
}

proc steamtemp {} {
	if {$::android == 1} {
		return $::de1(mix_temperature)
	}
	return [expr {int(140+(rand() * 20))}]
}

proc watertemp {} {
	if {$::android == 1} {
		return $::de1(head_temperature)
	}
	return [expr {50+(rand() * 50)}]
}

proc pressure {} {
	if {$::de1(substate) != $::de1_substate_types_reversed(pouring) && $::de1(substate) != $::de1_substate_types_reversed(preinfusion)} {	
		return 0
	}

	if {$::android == 1} {
		return $::de1(pressure)
	}
	return [expr {(rand() * 3.5)}]
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
	if {$::android == 1} {
		return $::de1(head_temperature)
	}

	global fake_group_temperature
	if {[info exists fake_group_temperature] != 1} {
		set fake_group_temperature 20
	}

	set fake_group_temperature [expr {int($fake_group_temperature + (rand() * 5))}]
	if {$fake_group_temperature > $::settings(espresso_temperature)} {
		set fake_group_temperature $::settings(espresso_temperature)
	}
	return $fake_group_temperature
}

proc steam_heater_temperature {} {
	if {$::android == 1} {
		return $::de1(mix_temperature)
	}

	global fake_steam_temperature
	if {[info exists fake_steam_temperature] != 1} {
		set fake_steam_temperature 20
	}

	set fake_steam_temperature [expr {int($fake_steam_temperature + (rand() * 10))}]
	if {$fake_steam_temperature > $::settings(steam_temperature)} {
		set fake_steam_temperature $::settings(steam_temperature)
	}


	return $fake_steam_temperature
}
proc water_mix_temperature {} {
	if {$::android == 1} {
		return $::de1(mix_temperature)
	}

	global fake_steam_temperature
	if {[info exists fake_steam_temperature] != 1} {
		set fake_steam_temperature 20
	}

	set fake_steam_temperature [expr {int($fake_steam_temperature + (rand() * 10))}]
	if {$fake_steam_temperature > $::settings(steam_temperature)} {
		set fake_steam_temperature $::settings(steam_temperature)
	}


	return $fake_steam_temperature
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
		return [translate "Heater:"]
	}
}

proc group_head_heater_action_text {} {
	set delta [expr {int([group_head_heater_temperature] - [setting_espresso_temperature])}]
	if {$delta < -2} {
		return [translate "(Heating):"]
	} elseif {$delta > 2} {
		return [translate "(Cooling):"]
	} else {
		return [translate "Heater:"]
	}
}

proc timer_text {} {
	return [subst {[timer] [translate "seconds"]}]
}

proc waterflow_text {} {
	if {$::settings(measurements) == "metric"} {
		return [subst {[round_to_two_digits [waterflow]] [translate "ml/s"]}]
	} else {
		return [subst {[round_to_two_digits [ml_to_oz [waterflow]]] "oz/s"}]
	}
}

proc watervolume_text {} {
	if {$::settings(measurements) == "metric"} {
		return [subst {[round_to_one_digits [watervolume]] [translate "ml"]}]
	} else {
		return [subst {[round_to_one_digits [ml_to_oz [watervolume]]] oz}]
	}
}



proc mixtemp_text {} {
	if {$::settings(measurements) == "metric"} {
		return [subst {[round_to_one_digits [water_mix_temperature]]ºC}]
	} else {
		return [subst {[round_to_one_digits [celsius_to_fahrenheit [water_mix_temperature]]]ºF]}]
	}
}

proc watertemp_text {} {
	if {$::settings(measurements) == "metric"} {
		return [subst {[round_to_one_digits [watertemp]]ºC}]
	} else {
		return [subst {[round_to_one_digits [celsius_to_fahrenheit [watertemp]]]ºF]}]
	}
}

proc steamtemp_text {} {
	if {$::settings(measurements) == "metric"} {
		return [subst {[round_to_integer [steamtemp]]ºC}]
	} else {
		return [subst {[round_to_integer [celsius_to_fahrenheit [steamtemp]]]ºF]}]
	}
}

proc pressure_text {} {
	return [subst {[round_to_two_digits [pressure]] [translate "bar"]}]
}


#######################
# settings
proc setting_steam_max_time {} {
	return $::settings(steam_max_time)
}
proc setting_water_max_time {} {
	return $::settings(water_max_time)
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

proc setting_steam_temperature_text {} {
	if {$::settings(measurements) == "metric"} {
		return [subst {[round_to_integer [setting_steam_temperature]]ºC}]
	} else {
		return [subst {[round_to_integer [celsius_to_fahrenheit [setting_steam_temperature]]]ºF]}]
	}
}
proc setting_water_temperature_text {} {
	if {$::settings(measurements) == "metric"} {
		return [subst {[round_to_integer [setting_water_temperature]]ºC}]
	} else {
		return [subst {[round_to_integer [celsius_to_fahrenheit [setting_water_temperature]]]ºF]}]
	}
}



proc steam_heater_temperature_text {} {
	if {$::settings(measurements) == "metric"} {
		return [subst {[round_to_integer [steam_heater_temperature]]ºC}]
	} else {
		return [subst {[round_to_integer [celsius_to_fahrenheit [steam_heater_temperature]]]ºF]}]
	}
}

proc group_head_heater_temperature_text {} {
	if {$::settings(measurements) == "metric"} {
		return [subst {[round_to_integer [group_head_heater_temperature]]ºC}]
	} else {
		return [subst {[round_to_integer [celsius_to_fahrenheit [group_head_heater_temperature]]]ºF]}]
	}
}

proc setting_espresso_temperature_text {} {
	if {$::settings(measurements) == "metric"} {
		return [subst {[round_to_integer [setting_espresso_temperature]]ºC}]
	} else {
		return [subst {[round_to_integer [celsius_to_fahrenheit [setting_espresso_temperature]]]ºF]}]
	}
}

proc setting_espresso_pressure {} {
	return $::settings(espresso_pressure)
}
proc setting_espresso_pressure_text {} {
		return [subst {[round_to_one_digits [setting_espresso_pressure]] [translate "bar"]}]
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
