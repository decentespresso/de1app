# de1 internal state live variables
package provide de1_vars 1.0

#############################
# raw data from the DE1

proc clear_espresso_chart {} {
	msg "clear_espresso_chart"
	espresso_elapsed length 0
	espresso_pressure length 0
	espresso_flow length 0
	espresso_flow_weight length 0
	espresso_flow_weight_2x length 0
	espresso_flow_2x length 0
	espresso_pressure_delta length 0
	espresso_flow_delta length 0
	espresso_flow_delta_negative length 0
	espresso_flow_delta_negative_2x length 0
	espresso_temperature_mix length 0
	espresso_temperature_basket length 0
	espresso_state_change length 0
	espresso_pressure_goal length 0
	espresso_flow_goal length 0
	espresso_flow_goal_2x length 0
	espresso_temperature_goal length 0

	espresso_elapsed append 0
	espresso_pressure append 0
	#god_espresso_pressure append 0
	espresso_flow append 0
	espresso_flow_weight append 0
	espresso_flow_weight_2x append 0
	espresso_flow_2x append 0
	espresso_pressure_delta append 0
	espresso_flow_delta append 0
	espresso_flow_delta_negative append 0
	espresso_flow_delta_negative_2x append 0
	espresso_temperature_mix append $::settings(espresso_temperature)
	espresso_temperature_basket append $::settings(espresso_temperature)
	espresso_state_change append 0
	espresso_pressure_goal append -1
	espresso_flow_goal append -1
	espresso_flow_goal_2x append -1
	espresso_temperature_goal append $::settings(espresso_temperature)

	catch {
		# update the Y axis on the temperature chart, each time that we make an espresso, in case the goal temperature changed
		update_temperature_charts_y_axis
	}

	############################################################################################################
	# god shot reference
	god_espresso_pressure length 0
	god_espresso_temperature_basket length 0
	god_espresso_flow length 0
	god_espresso_flow_weight length 0
	god_espresso_flow_2x length 0
	god_espresso_flow_weight_2x length 0

	god_espresso_pressure append $::settings(god_espresso_pressure)
	god_espresso_temperature_basket append $::settings(god_espresso_temperature_basket)

	if {$::settings(god_espresso_flow) != {} } {
		god_espresso_flow append $::settings(god_espresso_flow)

		# in zoomed flow/pressure mode we chart flow/weight at 2x the normal Y axis, so we need to populate those vectors by hand
		foreach flow $::settings(god_espresso_flow) {
			god_espresso_flow_2x append [expr {2.0 * $flow}]
		}
	}

	if {$::settings(god_espresso_flow_weight) != {} } {
		god_espresso_flow_weight append $::settings(god_espresso_flow_weight)

		foreach flow_weight $::settings(god_espresso_flow_weight) {
			god_espresso_flow_weight_2x append [expr {2.0 * $flow_weight}]
		}
	}
	############################################################################################################
}	



proc espresso_frame_title {num} {
	if {$num == 1} {
		return "1) Ramp up pressure to 8.4 bar over 12 seconds"
	} elseif {$num == 2} {
		return "2) Hold pressure at 8.4 bars for 10 seconds"
	} elseif {$num == 3} {
		return "3) Maintain 1.2 mL/s flow rate for 30 seconds"
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
		return "Automatically manage pressure to attain a flow rate of 1.2 mL/s at a water temperature of 88ºC.  End this step after 30 seconds."
	} elseif {$num == 4} {
		return ""
	} elseif {$num == 5} {
		return ""
	} elseif {$num == 6} {
		return ""
	}

}

proc set_alarms_for_de1_wake_sleep {} {
	# first clear existing timers
	if {[info exists ::alarms_for_de1_wake] == 1} {
		after cancel $::alarms_for_de1_wake
		unset ::alarms_for_de1_wake
	}
	if {[info exists ::alarms_for_de1_sleep] == 1} {
		after cancel $::alarms_for_de1_sleep
		unset ::alarms_for_de1_sleep
	}

	# if the timers are active, then find the next alarm time and set an alarm to wake in that many milliseconds from now
	if {$::settings(scheduler_enable) == 1} {
		set wake_seconds [expr {[next_alarm_time $::settings(scheduler_wake)] - [clock seconds]}]
		set ::alarms_for_de1_wake [after [expr {1000 * $wake_seconds}] scheduler_wake]

		set sleep_seconds [expr {[next_alarm_time $::settings(scheduler_sleep)] - [clock seconds]}]
		set ::alarms_for_de1_sleep [after [expr {1000 * $sleep_seconds}] scheduler_sleep]

		#msg "Wake schedule set for [next_alarm_time $::settings(scheduler_wake)] in $wake_seconds seconds"
		#msg "Sleep schedule set for [next_alarm_time $::settings(scheduler_sleep)] in $sleep_seconds seconds"
	}
}

proc scheduler_wake {} {
	msg "Scheduled wake occured at [clock format [clock seconds]]"
	start_idle

	# after alarm has occured go ahead and set the alarm for tommorrow
	after 2000 set_alarms_for_de1_wake_sleep
}

proc scheduler_sleep {} {
	msg "Scheduled sleep occured at [clock format [clock seconds]]"
	start_sleep

	# after alarm has occured go ahead and set the alarm for tommorrow
	after 2000 set_alarms_for_de1_wake_sleep
}


proc next_alarm_time { in } {
	set alarm [expr {[round_date_to_nearest_day [clock seconds]] + round($in)}]
	if {$alarm < [clock seconds] } {
		# if the alarm time has passed, set it for tomorrow
		set alarm [expr {$alarm + 86400} ]
	}
	return $alarm
}


proc format_alarm_time { in } {
	if {$::settings(enable_ampm) == 1} {
		return [clock format [next_alarm_time $in] -format {%l:%M %p}] 
	} else {
		return [clock format [next_alarm_time $in] -format {%H:%M}] 
	}
}

proc start_timer_preinfusion {} {
	set ::timers(preinfusion_start) [clock milliseconds]
}

proc stop_timer_preinfusion {} {
	set ::timers(preinfusion_stop) [clock milliseconds]

}

proc start_timer_pour {} {
	set ::timers(pour_start) [clock milliseconds]
}

proc stop_timer_pour {} {
	set ::timers(pour_stop) [clock milliseconds]

}

proc stop_timers {} {
	#msg "stop_timers"
	set ::timer_running 0
	set ::timers(stop) [clock milliseconds]
	#stop_timer_preinfusion
	#stop_timer_pour
	#set ::substate_timers(stop) [clock milliseconds]
}

proc start_timers {} {
	#msg "stop_timers"
	clear_timers
	set ::timer_running 1
	set ::timers(start) [clock milliseconds]
	#set ::timers(millistart) [clock milliseconds]
	#set ::substate_timers(millistart) [clock milliseconds]
}

proc clear_timers {} {
	#msg "clear_timers"
	#global start_timer
	#global start_millitimer
	#set ::start_timer [clock seconds]
	#set ::start_millitimer [clock milliseconds]
	#set now [clock seconds]

	unset -nocomplain ::timers
	set ::timers(start) 0
	#set ::timers(millistart) 0
	set ::timers(stop) 0

	unset -nocomplain ::substate_timers
	set ::substate_timers(start) 0
	set ::substate_timers(stop) 0

	set ::timers(preinfusion_start) 0
	set ::timers(preinfusion_stop) 0

	set ::timers(pour_start) 0
	set ::timers(pour_stop) 0

	set ::timer_running 0
	#puts "clearing timers"
}

clear_timers
#stop_timers


# amount of time that we've been on this page
#set ::timer [clock seconds]
proc timer {} {
	#global start_timer
	#if {$::timer_running == 1} {
	#	set ::timer [clock seconds]
	#}	
	#return $timer
	return [expr {([clock milliseconds] - $::timers(start) )/1000}]
}

proc millitimer {} {
	return [expr {([clock milliseconds] - $::timers(start))}]
	#global start_millitimer
	#return [expr {[clock milliseconds] - $start_millitimer}]
}

proc elapsed_timer {} {
	if {$::timers(start) == 0} {
		return 0
	} elseif {$::timers(stop) == 0} {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(start))/1000}]
	} else {
		# stop occured, so show that.
		return [expr {($::timers(stop) - $::timers(start))/1000}]
	}
}

proc preinfusion_timer {} {
	if {$::timers(preinfusion_start) == 0} {
		return 0
	} elseif {$::timers(preinfusion_stop) == 0} {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(preinfusion_start))/1000}]
	} else {
		# stop occured, so show that.
		return [expr {($::timers(preinfusion_stop) - $::timers(preinfusion_start))/1000}]
	}
}


proc pour_timer {} {
	if {$::timers(pour_start) == 0} {
		return 0
	} elseif {$::timers(pour_stop) == 0} {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(pour_start))/1000}]
	} else {
		# stop occured, so show that.
		return [expr {($::timers(pour_stop) - $::timers(pour_start))/1000}]
	}
}

proc done_timer {} {
	if {$::timers(stop) == 0} {
		return 0
	} else {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(stop))/1000}]
	}
}

proc obsolete_event_timer_calculate {state destination_state previous_states} {



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

#proc preinfusion_timer {} {
#	return [event_timer_calculate "Espresso" "preinfusion" {"stabilising" "final heating" "heating"} ]
#}


#proc pour_timer {} {
#	return [event_timer_calculate "Espresso" "pouring" {"preinfusion" "stabilising" "final heating" "heating"} ]
#}

#proc done_timer {} {
#	return [event_timer_calculate "Idle" "ready" {"pouring" "preinfusion" "stabilising" "final heating" "heating"} ]
#}


proc steam_timer {} {
	return [pour_timer]
	#return [event_timer_calculate "Steam" "pouring" {"stabilising" "final heating"} ]
}

proc water_timer {} {
	return [pour_timer]
	#return [event_timer_calculate "HotWater" "pouring" {"stabilising" "final heating"} ]
}

proc waterflow {} {
	if {$::de1(substate) != $::de1_substate_types_reversed(pouring) && $::de1(substate) != $::de1_substate_types_reversed(preinfusion)} {	
		return 0
	}

	if {$::android == 0} {
		if {[ifexists ::de1(flow)] == ""} {
			set ::de1(flow) 3
		}
		if {$::de1(flow) > 5} {
			set ::de1(flow) 4.5
		}
		if {$::de1(flow) < 1} {
			set ::de1(flow) 1.5
		}


		set ::de1(flow) [expr {(.1 * (rand() - 0.5)) + $::de1(flow)}]		
		#set ::de1(flow) [expr {rand() + $::de1(flow) - 0.5}]
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

		set ::de1(steam_heater_temperature) [expr {(160+(rand() * 5))}]
	}
	return $::de1(steam_heater_temperature)
}

proc watertemp {} {
	if {$::android == 0} {
		#set ::de1(head_temperature) [expr {$::settings(espresso_temperature) - 2.0 + (rand() * 4)}]
		set ::de1(goal_temperature) $::settings(espresso_temperature)

		if {[ifexists ::de1(head_temperature)] == ""} {
			set ::de1(head_temperature) $::de1(goal_temperature)
		}
		if {$::de1(head_temperature) < 80} {
			set ::de1(head_temperature) $::de1(goal_temperature)
		}
		if {$::de1(head_temperature) > 95} {
			set ::de1(head_temperature) $::de1(goal_temperature)
		}

		#set ::de1(head_temperature) [expr {rand() + $::de1(head_temperature) - 0.5}]
		set ::de1(head_temperature) [expr {(.2 * (rand() - 0.6)) + $::de1(head_temperature)}]		
		#set ::de1(head_temperature) 90

	}

	#puts "::de1(head_temperature) $::de1(head_temperature)"
	return $::de1(head_temperature)
}

proc pressure {} {
	if {$::de1(substate) != $::de1_substate_types_reversed(pouring) && $::de1(substate) != $::de1_substate_types_reversed(preinfusion)} {	
		return 0
	}

	if {$::android == 0} {
		if {[ifexists ::de1(pressure)] == ""} {
			set ::de1(pressure) 5
		}

		if {$::de1(pressure) > 10} {
			set ::de1(pressure) 9
		}
		if {$::de1(pressure) < 1} {
			set ::de1(pressure) 5
		}


		set ::de1(pressure) [expr {(.5 * (rand() - 0.5)) + $::de1(pressure)}]
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
		# slowly have the water level drift
		set ::de1(water_level) [expr {$::de1(water_level) + (.1*(rand() - 0.5))}]
		#puts -nonewline .
		#flush stdout
		#update
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
		if {$::de1(substate) == $::de1_substate_types_reversed(pouring) || $::de1(substate) == $::de1_substate_types_reversed(preinfusion)} {	
			if {$::de1(mix_temperature) == "" || $::de1(mix_temperature) < 85 || $::de1(mix_temperature) > 99} {
				set ::de1(mix_temperature) 94
			}
			set ::de1(mix_temperature) [expr {$::de1(mix_temperature) + ((rand() - 0.5) * .3) }]
		}
			#return [return_flow_weight_measurement [expr {(rand() * 6)}]]
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
		return [translate "Ready:"]
	}
}

proc group_head_heater_action_text {} {
	set delta [expr {int([group_head_heater_temperature] - [setting_espresso_temperature])}]
	if {$delta < -5} {
		return [translate "Heating:"]
	} elseif {$delta > 5} {
		return [translate "Cooling:"]
	} else {
		return [translate "Ready:"]
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
		return [subst {[round_to_integer $in] [translate "mL"]}]
	} else {
		return [subst {[round_to_integer [ml_to_oz $in]] oz}]
	}
}

proc return_flow_measurement {in} {
	if {$::settings(enable_fluid_ounces) != 1} {
		return [subst {[round_to_one_digits $in] [translate "mL/s"]}]
	} else {
		return [subst {[round_to_one_digits [ml_to_oz $in]] oz/s}]
	}
}

proc return_pressure_measurement {in} {
	return [subst {[commify [round_to_one_digits $in]] [translate "bar"]}]
}

proc return_flow_weight_measurement {in} {
	if {$::settings(enable_fluid_ounces) != 1} {
		return [subst {[round_to_one_digits $in] [translate "g/s"]}]
	} else {
		return [subst {[round_to_one_digits [ml_to_oz $in]] oz/s}]
	}
}

proc return_weight_measurement {in} {
	if {$::settings(enable_fluid_ounces) != 1} {
		return [subst {[round_to_one_digits $in][translate "g"]}]
	} else {
		return [subst {[round_to_one_digits [ml_to_oz $in]] oz}]
	}
}

proc return_percent {in} {
	return [subst {[round_to_one_digits $in]%}]
}

proc return_percent_off_if_zero {in} {
	if {$in == 0} {
		return [translate "off"]
	}
	return [subst {[round_to_one_digits $in]%}]
}

proc return_off_if_zero {in} {
	if {$in == 0} {
		return [translate "off"]
	}
	return $in

}

proc return_stop_at_weight_measurement {in} {
	if {$in == 0} {
		return [translate "off"]
	} else {
		if {$::settings(enable_fluid_ounces) != 1} {
			return [subst {[round_to_integer $in][translate "g"]}]
		} else {
			return [subst {[round_to_integer [ml_to_oz $in]] oz}]
		}
	}
}


proc preinfusion_volume {} {
	return_liquid_measurement [round_to_integer $::de1(preinfusion_volume)]
}

proc pour_volume {} {
	return_liquid_measurement [round_to_integer $::de1(pour_volume)]
}

proc waterflow_text {} {
	return [return_flow_measurement [waterflow]] 
}

proc watervolume_text {} {
	if {$::android == 0} {
		if {$::de1(substate) == $::de1_substate_types_reversed(pouring) || $::de1(substate) == $::de1_substate_types_reversed(preinfusion)} {	
			if {$::de1(volume) == ""} {
				set ::de1(volume) 0
			}
			set ::de1(volume) [expr {$::de1(volume) + (rand() * .27) }]
		}
	}

	# we sum these two numbers so that we don't have a rounding error that a user might find offensive (ie, "preinfusion + pour = total" ALWAYS) 
	return [return_liquid_measurement [expr {[round_to_integer $::de1(preinfusion_volume)] + [round_to_integer $::de1(pour_volume)]}]] 
}

proc waterweightflow_text {} {
	if {$::android == 0} {
		if {$::de1(substate) == $::de1_substate_types_reversed(pouring) || $::de1(substate) == $::de1_substate_types_reversed(preinfusion)} {	
			if {$::de1(scale_weight_rate) == ""} {
				set ::de1(scale_weight_rate) 3
			}
			set ::de1(scale_weight_rate) [expr {$::de1(scale_weight_rate) + ((rand() - 0.5) * .3) }]
			if {$::de1(scale_weight_rate) < 0} {
				set ::de1(scale_weight_rate) 1
			}
		}
			#return [return_flow_weight_measurement [expr {(rand() * 6)}]]
	}

	if {$::de1(scale_weight_rate) == ""} {
		return ""
	}
	return [return_flow_weight_measurement $::de1(scale_weight_rate)]
}

proc finalwaterweight_text {} {
	if {$::de1(scale_weight) == ""} {
		return ""
	}
	return [return_weight_measurement $::de1(final_water_weight)]
}

proc dump_stack {a b c} {
	msg ---
	msg [stacktrace]
}

#trace add variable de1(final_water_weight) write dump_stack

proc waterweight_text {} {
	if {$::android == 0} {

		if {$::de1(substate) == $::de1_substate_types_reversed(pouring) || $::de1(substate) == $::de1_substate_types_reversed(preinfusion)} {	
			if {$::de1(scale_weight) == ""} {
				set ::de1(scale_weight) 3
			}
			set ::de1(scale_weight) [expr {$::de1(scale_weight) + (rand() * .1) }]
			set ::de1(final_water_weight) $::de1(scale_weight)
		} else {
			set ::de1(scale_weight) 0
		}

		#return [return_weight_measurement [expr {round((rand() * 20))}]]
	}
	if {$::de1(scale_weight) == ""} {
		return ""
	}
	return [return_weight_measurement $::de1(scale_weight)]
}

proc waterweight_label_text {} {
	if {$::de1(scale_weight) == ""} {
		# setting this to negative will cause the progress bar to disappear 
		return ""
	}

	if {$::android == 0} {
		return [translate "Weight"]
	}


	return [translate "Weight"]
}


proc espresso_goal_temp_text {} {
	return [return_temperature_measurement $::de1(goal_temperature)]
}

set ::diff_brew_temp_from_goal 0
set ::positive_diff_brew_temp_from_goal 0
proc diff_brew_temp_from_goal {} {
	set ::diff_brew_temp_from_goal [expr {[water_mix_temperature] - $::de1(goal_temperature)}]
	set ::positive_diff_brew_temp_from_goal [expr {abs($::diff_brew_temp_from_goal)}]
	return $::diff_brew_temp_from_goal
}

proc diff_brew_temp_from_goal_text {} {
	set diff [expr {[water_mix_temperature] - $::de1(goal_temperature)}]
	return [return_delta_temperature_measurement $diff]
}

proc diff_espresso_temp_from_goal {} {
	set diff [expr {[watertemp] - $::de1(goal_temperature)}]
	return $diff
}
proc diff_espresso_temp_from_goal_text {} {
	set diff [expr {[watertemp] - $::de1(goal_temperature)}]
	return [return_delta_temperature_measurement $diff]
}

proc diff_group_temp_from_goal {} {
	set diff [expr {[group_head_heater_temperature] - $::de1(goal_temperature)}]
	return $diff
}

proc diff_group_temp_from_goal_text {} {
	set diff [expr {[group_head_heater_temperature] - $::de1(goal_temperature)}]
	return [return_delta_temperature_measurement $diff]
}

proc diff_pressure {} {
	if {$::android == 0} {
		return [expr {3 - (rand() * 6)}]
	}

	return $::de1(pressure_delta)
}

proc diff_flow_rate {} {
	if {$::android == 0} {
		return [expr {3 - (rand() * 6)}]
	}

	return $::de1(flow_delta)
}

proc diff_flow_rate_text {} {
	return [return_flow_measurement [round_to_one_digits [diff_flow_rate]]]
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
	return [subst {[commify [round_to_one_digits [pressure]]] [translate "bar"]}]
}


proc commify {number}  {
	set sep ,
	 while {[regsub {^([-+]?\d+)(\d\d\d)} $number "\\1$sep\\2" number]} {}
	if {[ifexists ::settings(enable_commanumbers)] == 1} {
		set number [string map {. , , .} $number]
	}
	return $number
}


#######################
# settings
proc setting_steam_max_time {} {
	return [expr {round( $::settings(steam_max_time) )}]
}
proc setting_water_max_time {} {
	return [expr {round( $::settings(water_time_max) )}]
}
proc setting_espresso_max_time {} {
	return [expr {round( $::settings(espresso_max_time) )}]
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

proc return_html_temperature_units {} {
	if {$::settings(enable_fahrenheit) == 1} {
		return "°F"
	} else {
		return "°C"
	}
}
proc return_temperature_number {in} {
	if {$::settings(enable_fahrenheit) == 1} {
		return [celsius_to_fahrenheit $in]
	} else {
		return $in
	}
}

proc return_temperature_measurement {in} {
	if {[de1plus]} {
		if {$::settings(enable_fahrenheit) == 1} {
			return [subst {[round_to_integer [celsius_to_fahrenheit $in]]ºF}]
		} else {
			return [subst {[round_to_one_digits $in]ºC}]
		}
	} else {
		if {$::settings(enable_fahrenheit) == 1} {
			return [subst {[round_to_integer [celsius_to_fahrenheit $in]]ºF}]
		} else {
			return [subst {[round_to_integer $in]ºC}]
		}

	}
}

proc return_temperature_setting {in} {
	if {[de1plus]} {
		if {$::settings(enable_fahrenheit) == 1} {
			return [subst {[round_to_integer [celsius_to_fahrenheit $in]]ºF}]
		} else {
			if {[round_to_half_integer $in] == [round_to_integer $in]} {
				# don't display a .0 on the number if it's not needed
				return [subst {[round_to_integer $in]ºC}]
			} else {
				return [subst {[round_to_half_integer $in]ºC}]
			}
		}
	} else {
		if {$::settings(enable_fahrenheit) == 1} {
			return [subst {[round_to_integer [celsius_to_fahrenheit $in]]ºF}]
		} else {
			return [subst {[round_to_integer $in]ºC}]
		}

	}
}


proc return_delta_temperature_measurement {in} {

	if {$::settings(enable_fahrenheit) == 1} {
		set label "ºF"
		set num [celsius_to_fahrenheit $in]
	} else {
		set label {ºC}
		set num $in
	}

	if {[de1plus]} {
		set num [round_to_one_digits $num]
	} else {
		set num [round_to_integer $num]
	}

	set t {}
	if {$num > 0.0} {
		set t "+$t"
	}

	set s "$t$num$label"
	return $s
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
	return [subst {[commify [round_to_one_digits [setting_espresso_pressure]]] [translate "bar"]}]
}

proc setting_espresso_stop_pressure_text {} {
	if {$::settings(preinfusion_stop_pressure) == 0} {
		return ""
	}
	return [subst {[commify [round_to_one_digits $::settings(preinfusion_stop_pressure)]] [translate "bar"]}]
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
	set dirs [lsort -dictionary [glob -tails -directory "[homedir]/skins/" *]]
	#puts "skin_directories: $dirs"
	set dd {}
	set de1plus [de1plus]
	foreach d $dirs {
		if {$d == "CVS" || $d == "example"} {
			continue
		}
	    
	    if {[string first "package require de1plus" [read_file "[homedir]/skins/$d/skin.tcl"]] != -1} {
	    	if {!$de1plus} {
		    	# don't display DE1PLUS skins to users on a DE1, because those skins will not function right
		    	#puts "Skipping $d"
		    	continue
		    }

		    # keep track of which skins are DE1PLUS so we can display them differently in the listbox
		    set ::de1plus_skins($d) 1
		}

		lappend dd $d		
	}
	return $dd
}


proc fill_history_listbox {} {
	#puts "fill_skin_listbox $widget" 
	set widget $::globals(history_listbox)

	$widget delete 0 99999

	set cnt 0
	set current_skin_number 0
	foreach d [history_directories] {
		$widget insert $cnt [clock format $d]
		incr cnt
	}

	#$widget selection set $current_skin_number

	bind $widget <<ListboxSelect>> [list ::preview_history %W] 	

	preview_history
}

proc fill_skin_listbox {} {
	#puts "fill_skin_listbox $widget" 
	set widget $::globals(tablet_styles_listbox)
	$widget delete 0 99999

	set cnt 0
	set current_skin_number 0
	foreach d [lsort -dictionary -increasing [skin_directories]] {
		if {$d == "CVS" || $d == "example"} {
			continue
		}
		$widget insert $cnt $d
		if {$::settings(skin) == $d} {
			set current_skin_number $cnt
		}

		#puts "d: $d"
		if {[ifexists ::de1plus_skins($d)] == 1} {
			# mark skins that require the DE1PLUS model with a different color to highlight them
			#puts "de1plus skin: $d"
			$widget itemconfigure $cnt -background #F0F0FF
		}
		incr cnt
	}
	
	#$widget itemconfigure $current_skin_number -foreground blue

	$widget selection set $current_skin_number
	make_current_listbox_item_blue $widget

	preview_tablet_skin

}


proc make_current_listbox_item_blue { widget} {

	for {set x 0} {$x < [$widget index end]} {incr x} {
		if {$x == [$widget curselection]} {
			#puts "x: $x"
			$widget itemconfigure $x -foreground #000000 -selectforeground #000000  -background #c0c4e1

		} else {
			$widget itemconfigure $x -foreground #b2bad0 -background #fbfaff
		}
	}

}



proc history_directories {} {
	set dirs [lsort -dictionary [glob -tails -directory "[homedir]/history/" *.shot]]
	set dd {}
	foreach d $dirs {
		lappend dd [file rootname $d]
	}
	return [lsort -dictionary -increasing $dd]
}


proc profile_directories {} {
	set dirs [lsort -dictionary [glob -tails -directory "[homedir]/profiles/" *.tcl]]
	set dd {}
	set de1plus [de1plus]
	foreach d $dirs {
		#if {$d == "CVS" || $d == "example"} {
		#	continue
		#}

		set filecontents [read_file "[homedir]/profiles/$d"]
	    if {[string first "settings_profile_type settings_2b" $filecontents] != -1 || [string first "settings_profile_type settings_2c" $filecontents] != -1 || [string first "settings_profile_type settings_profile_flow" $filecontents] != -1 || [string first "settings_profile_type settings_profile_advanced" $filecontents] != -1} {
	    	if {!$de1plus} {
		    	# don't display DE1PLUS skins to users on a DE1, because those skins will not function right
		    	#puts "Skipping $d"
		    	continue
		    }
		    #puts "de1+ profile: $d"
		    # keep track of which skins are DE1PLUS so we can display them differently in the listbox
		    set ::de1plus_profile([file rootname $d]) 1
		}

		lappend dd [file rootname $d]
	}
	return $dd
}

proc delete_selected_profile {} {

	set todel $::settings(profile)
	#puts "delete profile: $todel"
	if {$todel == "default"} {
		return
	}

	file delete "[homedir]/profiles/${todel}.tcl"
	set ::settings(profile) "default"
	fill_profiles_listbox 
	#preview_profile 

}


#set de1_bluetooth_list {}
proc fill_ble_listbox {} {

	#puts "fill_profiles_listbox $widget"
	#set ::settings(profile_to_save) $::settings(profile)

	set widget $::ble_listbox_widget
	$widget delete 0 99999
	set cnt 0
	set current_ble_number 0

	#set ble_ids [list "C1:80:A7:32:CD:A3" "C5:80:EC:A5:F9:72" "F2:C3:43:60:AB:F5"]
	#lappend ::de1_bluetooth_list $address

	if {$::android == 0} {	
		#set ::de1_bluetooth_list [list "C1:80:A7:32:CD:A3" "C5:80:EC:A5:F9:72" "F2:C3:43:60:AB:F5"]
		#set ::de1_bluetooth_list ""
	}

	foreach d [lsort -dictionary -increasing $::de1_bluetooth_list] {
		$widget insert $cnt $d
		if {[ifexists ::settings(bluetooth_address)] == $d} {
			set current_ble_number $cnt
			#puts "current profile of '$d' is #$cnt"
		}
		incr cnt
	}
	
	#$widget itemconfigure $current_profile_number -foreground blue
	$widget selection set $current_ble_number;

	#$widget selection set 3
	#puts "$widget selection set $current_profile_number"

	#set ::globals(ble_listbox) $widget

	# john - probably makes sense for "pair" to occur on item tap
	make_current_listbox_item_blue $widget
}

proc fill_ble_skale_listbox {} {

	set widget $::ble_skale_listbox_widget
	$widget delete 0 99999
	set cnt 0
	set current_ble_number 0

	foreach d [lsort -dictionary -increasing $::skale_bluetooth_list] {
		$widget insert $cnt $d
		if {[ifexists ::settings(skale_bluetooth_address)] == $d} {
			set current_ble_number $cnt
		}
		incr cnt
	}
	
	$widget selection set $current_ble_number;
	
	make_current_listbox_item_blue $widget
}


proc fill_profiles_listbox {} {
	set widget  $::globals(profiles_listbox)
	set ::settings(profile_to_save) $::settings(profile)

	$widget delete 0 99999
	set cnt 0
	set ::current_profile_number 0

	foreach d [lsort -dictionary -increasing [profile_directories]] {
		if {$d == "CVS" || $d == "example"} {
			continue
		}
		$widget insert $cnt $d 
		#puts "$widget insert $cnt $d"
		if {$::settings(profile) == $d} {
			set ::current_profile_number $cnt
			#puts "current profile of '$d' is #$cnt"
		}

		incr cnt
	}
	
	$widget selection set $::current_profile_number;
	set ::globals(profiles_listbox) $widget
	make_current_listbox_item_blue $widget 
	preview_profile 
}

proc copy_pressure_profile_to_advanced_profile {} {
	set preinfusion [list \
		name [translate "preinfusion"] \
		temperature $::settings(espresso_temperature) \
		sensor "coffee" \
		pump "flow" \
		transition "fast" \
		pressure 1 \
		flow $::settings(preinfusion_flow_rate) \
		seconds $::settings(preinfusion_time) \
		volume $::settings(preinfusion_stop_volumetric) \
		exit_if "1" \
		exit_type "pressure_over" \
		exit_pressure_over $::settings(preinfusion_stop_pressure) \
		exit_pressure_under 0 \
		exit_flow_over 6 \
		exit_flow_under 0 \
	]

	set hold [list \
		name [translate "rise and hold"] \
		temperature $::settings(espresso_temperature) \
		sensor "coffee" \
		pump "pressure" \
		transition "fast" \
		pressure $::settings(espresso_pressure) \
		seconds $::settings(espresso_hold_time) \
		volume $::settings(pressure_hold_stop_volumetric) \
		exit_if 0 \
		exit_pressure_over 11 \
		exit_pressure_under 0 \
		exit_flow_over 6 \
		exit_flow_under 0 \
	]

	set decline [list \
		name [translate "decline"] \
		temperature $::settings(espresso_temperature) \
		sensor "coffee" \
		pump "pressure" \
		transition "smooth" \
		pressure $::settings(pressure_end) \
		seconds $::settings(espresso_decline_time) \
		volume $::settings(pressure_decline_stop_volumetric) \
		exit_if 0 \
		exit_pressure_over 11 \
		exit_pressure_under 0 \
		exit_flow_over 6 \
		exit_flow_under 0 \
	]

	set ::settings(advanced_shot) [list $preinfusion $hold $decline]
	set ::current_step_number 0
}


proc copy_flow_profile_to_advanced_profile {} {
	#puts "copy_flow_profile_to_advanced_profile"
	set preinfusion [list \
		name [translate "preinfusion"] \
		temperature $::settings(espresso_temperature) \
		sensor "coffee" \
		pump "flow" \
		transition "fast" \
		pressure 1 \
		flow $::settings(preinfusion_flow_rate) \
		seconds $::settings(preinfusion_time) \
		volume $::settings(preinfusion_stop_volumetric) \
		exit_if "1" \
		exit_type "pressure_over" \
		exit_pressure_over $::settings(preinfusion_stop_pressure) \
		exit_pressure_under 0 \
		exit_flow_over 6 \
		exit_flow_under 0 \
	]

	set hold [list \
		name [translate "hold"] \
		temperature $::settings(espresso_temperature) \
		sensor "coffee" \
		pump "flow" \
		transition "fast" \
		flow $::settings(flow_profile_hold) \
		seconds $::settings(espresso_hold_time) \
		volume $::settings(flow_hold_stop_volumetric) \
		exit_if 0 \
		exit_pressure_over 11 \
		exit_pressure_under 0 \
		exit_flow_over 6 \
		exit_flow_under 0 \
	]

	set decline [list \
		name [translate "decline"] \
		temperature $::settings(espresso_temperature) \
		sensor "coffee" \
		pump "flow" \
		transition "smooth" \
		flow $::settings(flow_profile_decline) \
		seconds $::settings(espresso_decline_time) \
		volume $::settings(flow_decline_stop_volumetric) \
		exit_if 0 \
		exit_pressure_over 11 \
		exit_pressure_under 0 \
		exit_flow_over 6 \
		exit_flow_under 0 \
	]

	if {$::settings(preinfusion_guarantee) == 1} {
		set rise [list \
			name [translate "rise"] \
			temperature $::settings(espresso_temperature) \
			sensor "coffee" \
			pump "pressure" \
			transition "fast" \
			pressure $::settings(preinfusion_stop_pressure) \
			seconds $::settings(flow_rise_timeout) \
			volume $::settings(pressure_hold_stop_volumetric) \
			exit_if 0 \
			exit_pressure_over 11 \
			exit_pressure_under 0 \
			exit_flow_over 6 \
			exit_flow_under 0 \
		]

		set ::settings(advanced_shot) [list $preinfusion $rise $hold $decline]

	} else {
		set ::settings(advanced_shot) [list $preinfusion $hold $decline]
	}
	#puts "adv: $::settings(advanced_shot)"
	set ::current_step_number 0

}

proc fill_advanced_profile_steps_listbox {} {

	set widget $::advanced_shot_steps_widget
	set cs [ifexists ::current_step_number]

	$widget delete 0 99999
	set cnt 0
	set current_profile_number 0

	foreach step $::settings(advanced_shot) {
		unset -nocomplain props
		array set props $step

		set name $props(name)
		$widget insert $cnt "[expr {1 + $cnt}]. $name"
		incr cnt
	}
	
	if {$cs == ""} {
		$::advanced_shot_steps_widget selection set 0;
		set ::current_step_number 0
	} else {
		$::advanced_shot_steps_widget selection set $cs;
	}

	load_advanced_profile_step
	update
}

# on androwish some listbox selctions are causing multiple cascading events, and we don't know why
# this is a work around that assumes that each cascading event will happen within 100ms of each others
set time_of_last_listbox_event [clock milliseconds]
proc check_for_multiple_listbox_events_bug {} {
	msg "::de1(current_context) $::de1(current_context)"
	return 0

	set now [clock milliseconds]
	set diff [expr {$now - $::time_of_last_listbox_event}]
	set ::time_of_last_listbox_event $now

	if {$diff < 100} {
		#msg "duplicate listbox event detected"
		return 1
	}

	return 0
}

proc load_advanced_profile_step {} {
	#msg "load_advanced_profile_step [clock milliseconds]"

	if {$::de1(current_context) != "settings_2c"} {
		return 
	}

	#if {[check_for_multiple_listbox_events_bug] == 1} {
	#	return
	#}

	set stepnum [$::advanced_shot_steps_widget curselection]
	if {$stepnum == ""} {
		#set stepnum
		return
	}

	set ::current_step_number $stepnum
	#set stepnum [current_adv_step]

	unset -nocomplain ::current_adv_step
	array set ::current_adv_step [lindex $::settings(advanced_shot) $stepnum]

	make_current_listbox_item_blue $::advanced_shot_steps_widget

	set ::profile_step_name_to_add $::current_adv_step(name)
	set ::current_step_number $stepnum
}

proc current_adv_step {} {
	return $::current_step_number

	set stepnum [$::advanced_shot_steps_widget curselection]
	if {$stepnum == ""} {
		puts "blank seleted"
		set stepnum 0
	}
	puts "stepnum: $stepnum"
	return $stepnum
}

proc change_current_adv_shot_step_name {} {
	#puts "change_current_adv_shot_step_name"
	set ::current_adv_step(name) "$::profile_step_name_to_add"
	save_current_adv_shot_step
	fill_advanced_profile_steps_listbox
}

proc save_current_adv_shot_step {} {
	set ::settings(advanced_shot) [lreplace $::settings(advanced_shot) [current_adv_step] [current_adv_step]  [array get ::current_adv_step]]
}

proc delete_current_adv_step {} {
	set ::settings(advanced_shot) [lreplace $::settings(advanced_shot)  [current_adv_step] [current_adv_step]]
	fill_advanced_profile_steps_listbox
}

# inserts a new step immediately after the currently seleted one, with all the same settings except for a different name
proc add_to_current_adv_step {} {
	set newlist {} 
	set cnt 0
	set stepnum [current_adv_step]
	set name $::profile_step_name_to_add
	if {$name == ""} {
		set name [translate "step"]
	}
	foreach s $::settings(advanced_shot) {
		lappend newlist $s
		if {$cnt == $stepnum} {
			array set x $s
			set x(name) $name
			lappend newlist [array get x]
		}
		incr cnt
	}

	if {$newlist == {}} {
		set newlist [list [list name $name]]
	}

	set ::settings(advanced_shot) $newlist
	fill_advanced_profile_steps_listbox

	#$::advanced_shot_steps_widget selection set $stepnum;
	$::advanced_shot_steps_widget selection clear $::current_step_number;;
	incr ::current_step_number
	$::advanced_shot_steps_widget selection set $::current_step_number;
	$::advanced_shot_steps_widget activate $::current_step_number;
#	$::advanced_shot_steps_widget activate $stepnum;
	make_current_listbox_item_blue $::advanced_shot_steps_widget

}


proc save_new_tablet_skin_setting {} {
	set ::settings(skin) [$::globals(tablet_styles_listbox) get [$::globals(tablet_styles_listbox) curselection]]
}


proc preview_tablet_skin {} {
	if {$::de1(current_context) != "settings_3"} {
		return 
	}

	#if {[check_for_multiple_listbox_events_bug] == 1} {
	#	return
	#}
	catch {
	#error "prev"
		msg "preview_tablet_skin"
		set w $::globals(tablet_styles_listbox)
		if {[$w curselection] == ""} {
			msg "no current skin selection"
			return
		}
		set skindir [$w get [$w curselection]]
		set ::settings(skin) $skindir
		#set ::settings(skin)
		set fn "[homedir]/skins/$skindir/${::screen_size_width}x${::screen_size_height}/icon.jpg"
		$::table_style_preview_image read $fn
		make_current_listbox_item_blue $::globals(tablet_styles_listbox)
	}
}

proc preview_history {w args} {
	catch {
		set profile [lindex [history_directories] [$w curselection] [$w curselection]]
		puts "history item: $profile [$w curselection]"

		set fn "[homedir]/history/${profile}.tcl"

		# need to code this
		#load_settings_vars $fn
		array set props [read_file $fn]

		array set ::settings $props(settings)

		espresso_elapsed length 0; espresso_elapsed append $props(espresso_elapsed)
		espresso_pressure length 0; espresso_pressure append $props(espresso_pressure)
		espresso_flow length 0; espresso_flow append $props(espresso_flow)
		espresso_flow_weight length 0; espresso_flow_weight append $props(espresso_flow_weight)
		espresso_temperature_basket length 0; espresso_temperature_basket append $props(espresso_temperature_basket)
		espresso_temperature_mix length 0; espresso_temperature_mix append $props(espresso_temperature_mix)

		make_current_listbox_item_blue $::globals(history_listbox)
		
	}
}


proc change_bluetooth_device {} {

	set w $::ble_listbox_widget
	#set ::settings(profile) [$::globals(profiles_listbox) get [$::globals(profiles_listbox) curselection]]
	if {[$w curselection] == ""} {
		# no current selection
		return ""
	}
	set profile [$w get [$w curselection]]
	if {$profile == $::settings(bluetooth_address)} {
		# if no change in setting, do nothing.
		return
	}
	set ::settings(bluetooth_address) $profile
	#save_settings; 

	#.can itemconfigure $::message_label -text [translate "Please quit and restart this app to apply your changes."]
	#set_next_page off message; page_show message
}


proc change_skale_bluetooth_device {} {
	set w $::ble_skale_listbox_widget

	if {$w == ""} {
		return
	}
	if {[$w curselection] == ""} {
		# no current selection
		return ""
	}
	set profile [$w get [$w curselection]]
	if {$profile == $::settings(skale_bluetooth_address)} {
		# if no change in setting, do nothing.
		return
	}
	set ::settings(skale_bluetooth_address) $profile
	#save_settings; 

	#.can itemconfigure $::message_label -text [translate "Please quit and restart this app to apply your changes."]
	#set_next_page off message; page_show message
}


set preview_profile_counter 0
proc preview_profile {} {
	if {$::de1(current_context) != "settings_1"} {
		return 
	}

	#if {[check_for_multiple_listbox_events_bug] == 1} {
	#	return
	#}
	#catch {
		#msg "preview_profile: [clock milliseconds]"

		incr ::preview_profile_counter
		set w $::globals(profiles_listbox)
	    #msg "$::preview_profile_counter : $w vs $win"

	    #$w selection set active

		#set ::settings(profile) [$::globals(profiles_listbox) get [$::globals(profiles_listbox) curselection]]
		#puts "w: $w '[$w curselection]'"
		if {[$w curselection] == ""} {
			$w selection set $::current_profile_number
			puts "setting profile to $::current_profile_number"
			#set profile $::current_profile_number
		}

		#set profile [$w get [$w curselection]]
		set profile [$w get [$w curselection]]
		#set profile [$w get active]
		set ::settings(profile) $profile
		set ::settings(profile_notes) ""
		set fn "[homedir]/profiles/${profile}.tcl"

		# for importing De1 profiles that don't have this feature.
		set ::settings(preinfusion_flow_rate) 4

		load_settings_vars $fn
		set ::settings(profile_to_save) $::settings(profile)

		make_current_listbox_item_blue $::globals(profiles_listbox)

		if {[de1plus]} {
			
			if {$::settings(settings_profile_type) == "settings_2" || $::settings(settings_profile_type) == "settings_profile_pressure"} {
				set ::settings(settings_profile_type) "settings_2a"
			} elseif {$::settings(settings_profile_type) == "settings_profile_flow"} {
				set ::settings(settings_profile_type) "settings_2b"
			}

		} else {
			set ::settings(settings_profile_type) "settings_2"

			if {$::settings(settings_profile_type) == "settings_2a"} {
				set ::settings(settings_profile_type) "settings_2"
			}
		}
		update_onscreen_variables

		catch {
			break
		}
	#}
}

proc load_settings_vars {fn} {
	#error "load_settings_vars"
	# set the default profile type to use, this can be over-ridden by the saved profile
	if {[de1plus]} {
		set ::settings(settings_profile_type) "settings_2a"
	} else {
		set ::settings(settings_profile_type) "settings_2"
	}

	foreach {k v} [read_file $fn] {
		#puts "$k $v"
		set ::settings($k) $v
	}
	update_de1_explanation_chart

}

proc save_settings_vars {fn varlist} {

	set txt ""
	foreach k $varlist {
		set v $::settings($k)
		append txt "[list $k] [list $v]\n"
	}

	set success 0
	catch {
	    write_file $fn $txt
	    set success 1
	}
	return $success
}

proc save_profile {} {
	if {$::settings(profile_to_save) == [translate "Saved"]} {
		return
	}

	set profile_vars { espresso_hold_time preinfusion_time espresso_pressure espresso_decline_time pressure_end espresso_temperature settings_profile_type flow_profile_preinfusion flow_profile_preinfusion_time flow_profile_hold flow_profile_hold_time flow_profile_decline flow_profile_decline_time flow_profile_minimum_pressure preinfusion_flow_rate profile_notes water_temperature final_desired_shot_weight}
	set profile_name_to_save $::settings(profile_to_save) 
	set fn "[homedir]/profiles/${profile_name_to_save}.tcl"
	if {[save_settings_vars $fn $profile_vars] == 1} {
		set ::settings(profile) $profile_name_to_save
		fill_profiles_listbox 
		update_de1_explanation_chart
		set ::settings(profile_to_save) [translate "Saved"]

		after 1000 {
			set ::settings(profile_to_save) $::settings(profile)

			# moves the cursor to the end of the seletion after showing the "saved" message.
			$::globals(widget_profile_name_to_save) icursor 999
		}
	} else {
		set ::settings(profile_to_save) [translate "Invalid name"]
		after 2000 {
			set ::settings(profile_to_save) $::settings(profile)

			# moves the cursor to the end of the seletion after showing the "saved" message.
			$::globals(widget_profile_name_to_save) icursor 999
		}
	}
}


proc de1plus {} {
	#puts "x: [package present de1plus 1.0]"
	set x 0
	catch {
		catch {
			if {[package present de1plus 1.0] >= 1} {
			set x 1
			}
		}
	}
	return $x

}

proc save_espresso_rating_to_history {} {
	unset -nocomplain ::settings(history_saved)
	save_this_espresso_to_history
}

proc save_this_espresso_to_history {} {

	if {[ifexists ::settings(history_saved)] != 1} {

		set name [clock format [clock seconds]]
		set clock [clock seconds]
		set espresso_data {}
		set espresso_data "name [list $name]\n"
		set espresso_data "clock $clock\n"
		#set espresso_data "final_espresso_weight $::de1(final_espresso_weight)\n"

		#set espresso_data "settings [array get ::settings]\n"

		append espresso_data "espresso_elapsed {[espresso_elapsed range 0 end]}\n"
		append espresso_data "espresso_pressure {[espresso_pressure range 0 end]}\n"
		append espresso_data "espresso_flow {[espresso_flow range 0 end]}\n"
		append espresso_data "espresso_flow_weight {[espresso_flow_weight range 0 end]}\n"
		append espresso_data "espresso_temperature_basket {[espresso_temperature_basket range 0 end]}\n"
		append espresso_data "espresso_temperature_mix {[espresso_temperature_mix range 0 end]}\n"

		# format settings nicely so that it is easier to read and parse
		append espresso_data "settings {\n"
	    foreach k [lsort -dictionary [array names ::settings]] {
	        set v $::settings($k)
	        append espresso_data [subst {\t[list $k] [list $v]\n}]
	    }
	    append espresso_data "}\n"

	    # things associated with the machine itself
		append espresso_data "machine {\n"
	    foreach k [lsort -dictionary [array names ::de1]] {
	        set v $::de1($k)
	        append espresso_data [subst {\t[list $k] [list $v]\n}]
	    }
	    append espresso_data "}\n"



		set fn "[homedir]/history/$clock.shot"

		if {[espresso_elapsed length] > 5} {
			# only save shots that have at least 5 data points
	    	write_file $fn $espresso_data
			puts "save_this_espresso_to_history"
	    }

	    set ::settings(history_saved) 1
	}
}


proc start_text_if_espresso_ready {} {
	set num $::de1(substate)
	set substate_txt $::de1_substate_types($num)
	if {$substate_txt == "ready" && $::de1(device_handle) != 0} {
		return [translate "START"]
	}
	return [translate "WAIT"]

}

proc restart_text_if_espresso_ready {} {
	set num $::de1(substate)
	set substate_txt $::de1_substate_types($num)
	if {$substate_txt == "ready" && $::de1(device_handle) != 0} {
		return [translate "RESTART"]
	}
	return [translate "WAIT"]

}

proc stop_text_if_espresso_stoppable {} {
	set num $::de1(substate)
	set substate_txt $::de1_substate_types($num)
	if {$substate_txt != "ending"} {
		return [translate "STOP"]
	}
	return [translate "WAIT"]

}



proc espresso_history_save_from_gui {} {
	set num $::de1(substate)
	set substate_txt $::de1_substate_types($num)
	if {$substate_txt != "ready"} {
		set state [translate "WAIT"]
	} else {
		if {$::settings(history_saved) != 1} { 
			set state [translate "SAVING"] 
		} else {
			set state [translate "RESTART"]
		}; 
	}
	save_this_espresso_to_history; 
	return $state
}

proc bar_or_off_text {num} {
	if {$num == 0} {
		return [translate "off"]
	} else {
		return [subst {$num [translate "bar"]}]
	}
}



proc preinfusion_seconds_text {num} {
	if {$num == 0} {
		return [translate "off"]
	} elseif {$num == 1} {
		return [subst {< $num [translate "second"]}]
	} else {
		return [subst {> $num [translate "seconds"]}]
	}
}

proc seconds_text {num} {
	if {$num == 0} {
		return [translate "off"]
	} elseif {$num == 1} {
		return [subst {$num [translate "second"]}]
	} elseif {$num == 60} {
		return [translate "1 minute"]
	} else {
		return [subst {$num [translate "seconds"]}]
	}
}


proc seconds_text {num} {
	if {$num == 0} {
		return [translate "off"]
	} elseif {$num == 1} {
		return [subst {$num [translate "second"]}]
	} elseif {$num == 60} {
		return [translate "1 minute"]
	} else {
		return [subst {$num [translate "seconds"]}]
	}
}

proc minutes_text {num} {
	if {$num == 0} {
		return [translate "off"]
	} elseif {$num == 60} {
		return [translate "1 hour"]
	} elseif {$num == 120} {
		return [translate "2 hours"]
	} elseif {$num == 1} {
		return [subst {$num [translate "minute"]}]
	} else {
		return [subst {$num [translate "minutes"]}]
	}
}

proc scentone_choice {english_aroma} {
	if {[lsearch -exact $::settings(scentone) $english_aroma] == -1} {
		return [translate $english_aroma]
	} else {
		return [subst {\[ \[ \[ [translate $english_aroma] \] \] \]}]
	}
}

proc scentone_toggle {english_aroma} {
	if {[lsearch -exact $::settings(scentone) $english_aroma] == -1} {
		lappend ::settings(scentone) $english_aroma
		set ::settings(scentone) [lsort $::settings(scentone)]
	} else {
		set ::settings(scentone) [lsort -unique [list_remove_element $::settings(scentone) $english_aroma]]
	}
	update_onscreen_variables
}

proc scentone_category {english_category} {

	set english_aroma_list $::scentone($english_category)

	foreach english_aroma $english_aroma_list {
		if {[lsearch -exact $::settings(scentone) $english_aroma] != -1} {
			return [subst {\[ \[ \[ [translate $english_category] \] \] \]}]
		}
	}
	return [translate $english_category]
}

proc scentone_selected { {category {}} } {
	#puts "scent one: '$::settings(scentone)'"

	set returnlist {}
	foreach selected $::settings(scentone) {
		if {$category == ""} {
			# if this is a complete list of all selected aromas
			lappend returnlist [translate $selected]
		} else {
			# if this is only the selected aromas for a subcategory
			if {[lsearch -exact $::scentone($category) $selected] != -1} {
				lappend returnlist [translate $selected]
			}
		}

	}

	if {$returnlist == "" } {
		if {$category == ""} {
			return [translate "Categories"]
		} else {
			return [subst {[translate $category]}]
		}
	}
	if {$category != ""} {
		return [subst {[translate $category] : [join [lsort $returnlist] ", "].}]
	} else {
		return [subst {[translate "Selected:"] [join [lsort $returnlist] ", "].}]
	}

}


proc scentone_translated_selection { } {
	#puts "scent one: '$::settings(scentone)'"

	set returnlist {}
	foreach selected $::settings(scentone) {
		lappend returnlist [translate $selected]
	}

	if {$returnlist == ""} {
		return ""
	}

	return [join [lsort $returnlist] ", "].
}

proc round_to_half_integer {in} {
	set r 0
	catch {
		set r [expr {int($in * 2) / 2.0}]
	}
	return $r
}

proc firmware_uploaded_label {} {

	if {$::de1(firmware_bytes_uploaded) == 0 || $::de1(firmware_update_size) == 0} {
		return ""
	} else {
		set percentage [expr {(100.0 * $::de1(firmware_bytes_uploaded)) / $::de1(firmware_update_size)}]
		#puts "percentage $percentage"
		if {$percentage > 100} {
			set percentage 100
		}
		return "[round_to_one_digits $percentage]%"
	}

}