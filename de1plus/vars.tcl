# de1 internal state live variables
package provide de1_vars 1.0

#############################
# raw data from the DE1

proc clear_espresso_chart {} {
	#msg "clear_espresso_chart"
	espresso_elapsed length 0
	espresso_pressure length 0
	espresso_weight length 0
	espresso_weight_chartable length 0
	espresso_flow length 0
	espresso_flow_weight length 0
	espresso_flow_weight_raw length 0
	espresso_flow_weight_2x length 0
	espresso_water_dispensed length 0
	espresso_flow_2x length 0
	espresso_resistance length 0
	espresso_resistance_weight length 0
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

	espresso_de1_explanation_chart_elapsed length 0
	espresso_de1_explanation_chart_elapsed_1 length 0
	espresso_de1_explanation_chart_elapsed_2 length 0
	espresso_de1_explanation_chart_elapsed_3 length 0

	espresso_de1_explanation_chart_elapsed_flow length 0
	espresso_de1_explanation_chart_elapsed_flow_1 length 0
	espresso_de1_explanation_chart_elapsed_flow_2 length 0
	espresso_de1_explanation_chart_elapsed_flow_3 length 0	

	espresso_elapsed append 0
	espresso_pressure append 0
	#god_espresso_pressure append 0
	espresso_weight append 0
	espresso_weight_chartable append 0
	espresso_flow append 0
	espresso_flow_weight append 0
	espresso_flow_weight_2x append 0
	espresso_flow_weight_raw append 0
	espresso_water_dispensed append 0
	espresso_flow_2x append 0
	espresso_resistance append 0
	espresso_resistance_weight append 0
	espresso_pressure_delta append 0
	espresso_flow_delta append 0
	espresso_flow_delta_negative append 0
	espresso_flow_delta_negative_2x append 0
	espresso_temperature_mix append [return_temperature_number $::settings(espresso_temperature)]
	espresso_temperature_basket append [return_temperature_number $::settings(espresso_temperature)]
	espresso_state_change append 0
	espresso_pressure_goal append -1
	espresso_flow_goal append -1
	espresso_flow_goal_2x append -1
	espresso_temperature_goal append [return_temperature_number $::settings(espresso_temperature)]

	god_shot_reference_reset
	
	catch {
		# update the Y axis on the temperature chart, each time that we make an espresso, in case the goal temperature changed
		#update_temperature_charts_y_axis
	}

}	

proc espresso_chart_structures {} {
	return [list espresso_elapsed espresso_pressure espresso_weight espresso_weight_chartable espresso_flow espresso_flow_weight espresso_flow_weight_raw espresso_water_dispensed espresso_flow_weight_2x espresso_flow_2x espresso_resistance espresso_resistance_weight espresso_pressure_delta espresso_flow_delta espresso_flow_delta_negative espresso_flow_delta_negative_2x espresso_temperature_mix espresso_temperature_basket espresso_state_change espresso_pressure_goal espresso_flow_goal espresso_flow_goal_2x espresso_temperature_goal espresso_de1_explanation_chart_flow espresso_de1_explanation_chart_elapsed_flow espresso_de1_explanation_chart_flow_2x espresso_de1_explanation_chart_flow_1_2x espresso_de1_explanation_chart_flow_2_2x espresso_de1_explanation_chart_flow_3_2x espresso_de1_explanation_chart_pressure espresso_de1_explanation_chart_temperature espresso_de1_explanation_chart_temperature_10 espresso_de1_explanation_chart_pressure_1 espresso_de1_explanation_chart_pressure_2 espresso_de1_explanation_chart_pressure_3 espresso_de1_explanation_chart_elapsed_flow espresso_de1_explanation_chart_elapsed_flow_1 espresso_de1_explanation_chart_elapsed_flow_2 espresso_de1_explanation_chart_elapsed_flow_3 espresso_de1_explanation_chart_elapsed espresso_de1_explanation_chart_elapsed_1 espresso_de1_explanation_chart_elapsed_2 espresso_de1_explanation_chart_elapsed_3]
}

proc backup_espresso_chart {} {
	#puts "backup_espresso_chart"
	unset -nocomplain ::chartbk
	foreach s [espresso_chart_structures] {
		if {[$s length] > 0} {
			#puts "backing up: $s with: [$s range 0 end]"
			set ::chartbk($s) [$s range 0 end]
		} else {
			set ::chartbk($s) {}
		}
	}

}

proc restore_espresso_chart {} {
	foreach s [espresso_chart_structures] {
		$s length 0
		if {[info exists ::chartbk($s)] == 1} {
			#puts "restoring chart structure: '$s' to '$::chartbk($s)'"
			$s append $::chartbk($s)
		}
	}
}


proc god_shot_reference_reset {} {
	############################################################################################################
	# god shot reference
	god_espresso_pressure length 0
	god_espresso_temperature_basket length 0
	god_espresso_flow length 0
	god_espresso_flow_weight length 0
	god_espresso_flow_2x length 0
	god_espresso_flow_weight_2x length 0

	if {[info exists ::settings(god_espresso_elapsed)] == 1} {
		espresso_elapsed length 0
		espresso_elapsed append $::settings(god_espresso_elapsed)
	}

	god_espresso_pressure append $::settings(god_espresso_pressure)
	god_espresso_temperature_basket append  $::settings(god_espresso_temperature_basket)

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
		return "Gently go to 8.4 bar of pressure with a water mix temperature of 92\u00B0C. Go to the next step after 10 seconds. temperature of 92\u00B0C. Gently go to 8.4 bar of pressure with a water mix temperature of 92\u00B0C."
	} elseif {$num == 2} {
		return "Quickly go to 8.4 bar of pressure with a basket temperature of 90\u00B0C. Go to the next step after 10 seconds."
	} elseif {$num == 3} {
		return "Automatically manage pressure to attain a flow rate of 1.2 mL/s at a water temperature of 88\u00B0C.  End this step after 30 seconds."
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
	msg "Scheduled wake occurred at [clock format [clock seconds]]"
	
	# set "keep awake" flag if user has chosen new scheduler logic
	if {[ifexists ::settings(scheduler_logic)] == 1} {
                set ::scheduler_awake 1
        }
	
	start_idle

	# after alarm has occurred go ahead and set the alarm for tommorrow
	after 2000 set_alarms_for_de1_wake_sleep
}

proc scheduler_sleep {} {
	msg "Scheduled end occurred at [clock format [clock seconds]]"
	
	# if user has chosen new scheduler logic, clear "keep awake" flag (which will allow machine to sleep per idle timer), else immediately sleep
	if {[ifexists ::settings(scheduler_logic)] == 1} {
                unset -nocomplain ::scheduler_awake
        } else {
		start_sleep
	}
	
	# after alarm has occurred go ahead and set the alarm for tommorrow
	after 2000 set_alarms_for_de1_wake_sleep
}


proc next_alarm_time { in } {
	set alarm [expr {[round_date_to_nearest_day [clock seconds]] + round($in)}]
	if {$alarm < [clock seconds] } {
		# if the alarm time has passed, set it for tomorrow
		#set alarm [expr {$alarm + 86400} ]
		set alarm [clock add $alarm 1 day]
	}
	return $alarm
}

proc time_format {seconds {crlf 0}} {
	set crlftxt " "
	if {$crlf == 1} {
		set crlftxt \n
	}

	if {$::settings(enable_ampm) == 1} {
		return [subst {[translate [clock format $seconds -format {%A}]]$crlftxt[string trim [clock format $seconds -format {%l:%M %p}]]}]
	} else {
		return [subst {[translate [clock format $seconds -format {%A}]]$crlftxt[string trim [clock format $seconds -format {%H:%M}]]}]
	}
}

proc stripzeros {value} {
    set retval [string trimleft $value 0]
    if { ![string length $retval] } {
		return 0
    }
    return $retval
}

proc format_alarm_time { in } {
	return [time_format [next_alarm_time $in]]
}

proc start_timer_espresso_preinfusion {} {
	set ::timers(espresso_preinfusion_start) [clock milliseconds]
}

proc stop_timer_espresso_preinfusion {} {
	set ::timers(espresso_preinfusion_stop) [clock milliseconds]

}

proc start_timer_espresso_pour {} {
	set ::timers(espresso_pour_start) [clock milliseconds]
}

proc start_timer_water_pour {} {

	set ::timers(water_pour_stop) 0
	set ::timers(water_pour_start) [clock milliseconds]
}

proc start_timer_steam_pour {} {

	set ::timers(steam_pour_stop) 0
	set ::timers(steam_pour_start) [clock milliseconds]
}
proc start_timer_flush_pour {} {

	set ::timers(flush_pour_stop) 0
	set ::timers(flush_pour_start) [clock milliseconds]
}

proc stop_timer_espresso_pour {} {
	set ::timers(espresso_pour_stop) [clock milliseconds]

}

proc stop_timer_water_pour {} {
	msg "stop_timer_water_pour"
	set ::timers(water_pour_stop) [clock milliseconds]
}

proc stop_timer_steam_pour {} {
	msg "stop_timer_steam_pour"
	set ::timers(steam_pour_stop) [clock milliseconds]
}

proc stop_timer_flush_pour {} {
	msg "stop_timer_flush_pour"
	set ::timers(flush_pour_stop) [clock milliseconds]
}

proc stop_espresso_timers {} {
	#msg "stop_timers"
	set ::timer_running 0
	set ::timers(espresso_stop) [clock milliseconds]
	#stop_timer_preinfusion
	#stop_timer_pour
	#set ::substate_timers(stop) [clock milliseconds]
}

proc start_espresso_timers {} {
	#msg "stop_timers"
	#clear_timers
	#zz5
	set ::timer_running 1
	set ::timers(espresso_start) [clock milliseconds]
	#set ::timers(millistart) [clock milliseconds]
	#set ::substate_timers(millistart) [clock milliseconds]
}

proc clear_espresso_timers {} {
	#msg "clear_timers"
	#global start_timer
	#global start_millitimer
	#set ::start_timer [clock seconds]
	#set ::start_millitimer [clock milliseconds]
	#set now [clock seconds]
#zz1
	unset -nocomplain ::timers
	set ::timers(espresso_start) 0
	#set ::timers(millistart) 0
	set ::timers(espresso_stop) 0

	unset -nocomplain ::substate_timers
	set ::substate_timers(espresso_start) 0
	set ::substate_timers(espresso_stop) 0

	set ::timers(espresso_preinfusion_start) 0
	set ::timers(espresso_preinfusion_stop) 0

	set ::timers(espresso_pour_start) 0
	set ::timers(espresso_pour_stop) 0

	set ::timer_running 0

	#puts "clearing timers"
}

clear_espresso_timers
#stop_timers


# amount of time that we've been on this page
#set ::timer [clock seconds]
proc espresso_timer {} {
	#global start_timer
	#if {$::timer_running == 1} {
	#	set ::timer [clock seconds]
	#}	
	#return $timer
	return [expr {([clock milliseconds] - $::timers(espresso_start) )/1000}]
}

proc espresso_millitimer {} {
	return [expr {([clock milliseconds] - $::timers(espresso_start))}]
	#global start_millitimer
	#return [expr {[clock milliseconds] - $start_millitimer}]
}

proc espresso_elapsed_timer {} {
	if {$::timers(espresso_start) == 0} {
		return 0
	} elseif {$::timers(espresso_stop) == 0} {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(espresso_start))/1000}]
	} else {
		# stop occured, so show that.
		return [expr {($::timers(espresso_stop) - $::timers(espresso_start))/1000}]
	}
}

proc espresso_preinfusion_timer {} {
	if {$::timers(espresso_preinfusion_start) == 0} {
		return 0
	} elseif {$::timers(espresso_preinfusion_stop) == 0} {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(espresso_preinfusion_start))/1000}]
	} else {
		# stop occured, so show that.
		return [expr {($::timers(espresso_preinfusion_stop) - $::timers(espresso_preinfusion_start))/1000}]
	}
}


proc espresso_pour_timer {} {
	if {[info exists ::timers(espresso_pour_start)] != 1} {
		return 0
	}

	if {$::timers(espresso_pour_start) == 0} {
		return 0
	} elseif {$::timers(espresso_pour_stop) == 0} {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(espresso_pour_start))/1000}]
	} else {
		# stop occured, so show that.
		return [expr {($::timers(espresso_pour_stop) - $::timers(espresso_pour_start))/1000}]
	}
}

proc water_pour_timer {} {
	if {[info exists ::timers(water_pour_start)] != 1} {
		return 0
	}

	if {$::timers(water_pour_start) == 0} {
		return 0
	} elseif {$::timers(water_pour_stop) == 0} {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(water_pour_start))/1000}]
	} else {
		# stop occured, so show that.
		return [expr {($::timers(water_pour_stop) - $::timers(water_pour_start))/1000}]
	}
}
proc steam_pour_timer {} {
	if {[info exists ::timers(steam_pour_start)] != 1} {
		return 0
	}

	if {$::timers(steam_pour_start) == 0} {
		return 0
	} elseif {$::timers(steam_pour_stop) == 0} {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(steam_pour_start))/1000}]
	} else {
		# stop occured, so show that.
		return [expr {($::timers(steam_pour_stop) - $::timers(steam_pour_start))/1000}]
	}
}

proc steam_pour_millitimer {} {
	if {[info exists ::timers(steam_pour_start)] != 1} {
		return 0
	}

	if {$::timers(steam_pour_start) == 0} {
		return 0
	} elseif {$::timers(steam_pour_stop) == 0} {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(steam_pour_start))/1}]
	} else {
		# stop occured, so show that.
		return [expr {($::timers(steam_pour_stop) - $::timers(steam_pour_start))/1}]
	}
}

proc flush_pour_timer {} {
	set t ""
	set c 0
	if {[info exists ::timers(flush_pour_start)] != 1} {
		set t "-0"
		set c 1
	} elseif {$::timers(flush_pour_start) == 0} {
		set t "-1"
		set c 2
	} elseif {$::timers(flush_pour_stop) == 0} {
		# no stop, so show current elapsed time
		set t [expr {([clock milliseconds] - $::timers(flush_pour_start))/1000}]
		set c 3
	} else {
		# stop occured, so show that.
		set t [expr {($::timers(flush_pour_stop) - $::timers(flush_pour_start))/1000}]
		set c 4
	}
	#msg "flush_pour_timer: $t ($c)"
	return $t
}
proc done_timer {} {
	if {$::timers(stop) == 0} {
		return 0
	} else {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(stop))/1000}]
	}
}

proc espresso_done_timer {} {

	if {[info exists ::timers(espresso_stop)] != 1} {
		return 0
	}

	if {$::timers(espresso_stop) == 0} {
		return 0
	} else {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(espresso_stop))/1000}]
	}
}

proc water_done_timer {} {
	if {[info exists ::timers(water_pour_stop)] != 1} {
		return 0
	}

	if {$::timers(water_pour_stop) == 0} {
		return 0
	} else {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(water_pour_stop))/1000}]
	}
}
proc steam_done_timer {} {
	if {[info exists ::timers(steam_pour_stop)] != 1} {
		return 0
	}

	if {$::timers(steam_pour_stop) == 0} {
		return 0
	} else {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(steam_pour_stop))/1000}]
	}
}

proc flush_done_timer {} {
	if {[info exists ::timers(flush_pour_stop)] != 1} {
		return 0
	}

	if {$::timers(flush_pour_stop) == 0} {
		return 0
	} else {
		# no stop, so show current elapsed time
		return [expr {([clock milliseconds] - $::timers(flush_pour_stop))/1000}]
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
zz1
	return [pour_timer]
	#return [event_timer_calculate "Steam" "pouring" {"stabilising" "final heating"} ]
}

proc water_timer {} {
zz2
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

		if {$::de1_num_state($::de1(state)) == "Espresso"} {
			if {[espresso_millitimer] < 5000} {	
				set ::de1(preinfusion_volume) [expr {$::de1(preinfusion_volume) + ($::de1(flow) * .1) }]
			} else {
				set ::de1(pour_volume) [expr {$::de1(pour_volume) + ($::de1(flow) * .1) }]
			}
		}
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
		if {$::de1(state) == 4} {
			#espresso
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
		} elseif {$::de1(state) == 5} { 
			#steam
			if {[ifexists ::de1(pressure)] == ""} {
				set ::de1(pressure) 2
			}

			if {$::de1(pressure) > 3} {
				set ::de1(pressure) 2
			}
			if {$::de1(pressure) < .2} {
				set ::de1(pressure) 2
			}

			set ::de1(pressure) [expr {(.2 * (rand() - 0.5)) + $::de1(pressure)}]
		}
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
	return "$::settings(accelerometer_angle)\u00B0 ($accelerometer_read_count) $rate events/second $delta events $rate"
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
			set ::de1(mix_temperature) [expr {$::de1(head_temperature) + ((rand() - 0.5) * 2) }]
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

proc return_seconds_divided_by_ten {in} {
	if {$in == ""} {return ""}

	set t [expr {$in / 10.0}]
	return "[round_to_one_digits $t] [translate "seconds"]"

}
proc timer_text {} {
	return [subst {[timer] [translate "seconds"]}]
}

proc return_liquid_measurement {in} {
    if {$::de1(language_rtl) == 1} {
		return [subst {[translate "mL"] [round_to_integer $in] }]
    }

	if {$::settings(enable_fluid_ounces) != 1} {
		return [subst {[round_to_integer $in] [translate "mL"]}]
	} else {
		return [subst {[round_to_integer [ml_to_oz $in]] oz}]
	}
}

proc return_flow_calibration_measurement {in} {
    if {$::de1(language_rtl) == 1} {
		return [subst {[translate "mL/s"] [round_to_one_digits [expr {0.1 * $in}]]}]
    }
	return [subst {[round_to_one_digits [expr {0.1 * $in}]] [translate "mL/s"]}]

}

proc return_flow_measurement {in} {
    if {$::de1(language_rtl) == 1} {
		return [subst {[translate "mL/s"] [round_to_one_digits $in]}]
    }

	if {$::settings(enable_fluid_ounces) != 1} {
		return [subst {[round_to_one_digits $in] [translate "mL/s"]}]
	} else {
		return [subst {[round_to_one_digits [ml_to_oz $in]] oz/s}]
	}
}

proc return_pressure_measurement {in} {
    if {$::de1(language_rtl) == 1} {
		return [subst {[translate "bar"] [commify [round_to_one_digits $in]]}]
    }
	return [subst {[commify [round_to_one_digits $in]] [translate "bar"]}]
}

proc return_flow_weight_measurement {in} {
    if {$::de1(language_rtl) == 1} {
		return [subst {[translate "g/s"] [round_to_one_digits $in]}]
    }

	if {$::settings(enable_fluid_ounces) != 1} {
		return [subst {[round_to_one_digits $in] [translate "g/s"]}]
	} else {
		return [subst {[round_to_one_digits [ml_to_oz $in]] oz/s}]
	}
}

proc return_weight_measurement {in} {
    if {$::de1(language_rtl) == 1} {
		return [subst {[translate "g"][round_to_one_digits $in]}]
    }

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

proc return_zero_if_blank {in} {
	if {$in == ""} {
		return 0
	}
	return $in
}

proc return_stop_at_volume_measurement {in} {
	if {$in == 0} {
		return [translate "off"]
	} else {
		return [return_liquid_measurement [round_to_integer $in]]
	}
}

proc return_off_or_temperature {in} {
	if {$in == 0} {
		return [translate "off"]
	} else {
		return [return_temperature_measurement [round_to_integer $in]]
	}
}

proc return_stop_at_weight_measurement {in} {
	if {$in == 0} {
		return [translate "off"]
	} else {

	    if {$::de1(language_rtl) == 1} {
			return [subst {[translate "g"][round_to_integer $in]}]
		}

		if {$::settings(enable_fluid_ounces) != 1} {
			return [subst {[round_to_integer $in][translate "g"]}]
		} else {
			return [subst {[round_to_integer [ml_to_oz $in]] oz}]
		}
	}
}

proc return_stop_at_weight_measurement_precise {in} {
	if {$in == 0} {
		return [translate "off"]
	} else {
	    if {$::de1(language_rtl) == 1} {
			return [subst {[translate "g"][round_to_one_digits $in]}]
		}
		if {$::settings(enable_fluid_ounces) != 1} {
			return [subst {[round_to_one_digits $in][translate "g"]}]
		} else {
			return [subst {[round_to_half_integer [ml_to_oz $in]] oz}]
		}
	}
}

proc return_shot_weight_measurement {in} {
	if {$in == 0} {
		return [translate "off"]
	} else {
	    if {$::de1(language_rtl) == 1} {
			return [subst {[translate "g"][round_to_one_digits $in]}]
		}

		if {$::settings(enable_fluid_ounces) != 1} {
			return [subst {[round_to_one_digits $in][translate "g"]}]
		} else {
			return [subst {[round_to_one_digits [ml_to_oz $in]] oz}]
		}
	}
}

proc preinfusion_pour_timer_text {} {
    if {$::de1(language_rtl) == 1} {
		return [subst {[translate "s"][espresso_preinfusion_timer] [translate "preinfusion"] }]
	}

	return [subst {[espresso_preinfusion_timer][translate "s"] [translate "preinfusion"]}]
}

proc total_pour_timer_text {} {
    if {$::de1(language_rtl) == 1} {
		if {$::settings(final_desired_shot_volume_advanced) > 0 && $::settings(settings_profile_type) == "settings_2c"} {
			return "[return_liquid_measurement [round_to_integer $::settings(final_desired_shot_volume_advanced)]] < [translate {total}] [translate {s}][espresso_elapsed_timer]"
		} else {
			return "[translate {s}][espresso_elapsed_timer] [translate {total}] "
		}
	}

	if {$::settings(final_desired_shot_volume_advanced) > 0 && $::settings(settings_profile_type) == "settings_2c"} {
		return "[espresso_elapsed_timer][translate {s}] [translate {total}] < [return_liquid_measurement [round_to_integer $::settings(final_desired_shot_volume_advanced)]]"
	} else {
		return "[espresso_elapsed_timer][translate {s}] [translate {total}]"
	}
}

proc espresso_done_timer_text {} {
	if {[espresso_done_timer] < $::settings(seconds_to_display_done_espresso)} {
	    if {$::de1(language_rtl) == 1} {
			return "[translate s][espresso_done_timer] [translate done]"
	    }

		return "[espresso_done_timer][translate s] [translate done]"
	} else { 
		return ""
	}

}

proc pouring_timer_text {} {
    if {$::de1(language_rtl) == 1} {
		if {$::settings(scale_bluetooth_address) == "" && $::settings(final_desired_shot_volume) > 0 && ($::settings(settings_profile_type) == "settings_2a" || $::settings(settings_profile_type) == "settings_2b")} {
			return "[translate {s}][espresso_pour_timer] [translate {pouring}] < [return_liquid_measurement [round_to_integer $::settings(final_desired_shot_volume)]]"

		} else {
			return "[translate {s}][espresso_pour_timer] [translate {pouring}]"
		}
	}

	if {$::settings(scale_bluetooth_address) == "" && $::settings(final_desired_shot_volume) > 0 && ($::settings(settings_profile_type) == "settings_2a" || $::settings(settings_profile_type) == "settings_2b")} {
		return "[espresso_pour_timer][translate {s}] [translate {pouring}] < [return_liquid_measurement [round_to_integer $::settings(final_desired_shot_volume)]]"
	} else {
		return "[espresso_pour_timer][translate {s}] [translate {pouring}]"
	}

}

proc pouring_timer_text_2 {} {
	OBSOLETE
	if {$::de1(language_rtl) == 1} {
		if {$::settings(scale_bluetooth_address) == "" && $::settings(final_desired_shot_volume) > 0 && ($::settings(settings_profile_type) == "settings_2a" || $::settings(settings_profile_type) == "settings_2b")} {

			return "[translate {s}][espresso_pour_timer] [translate {pouring}] < [return_liquid_measurement [round_to_integer $::settings(final_desired_shot_volume)]]"

		} else {
			return "[translate {pouring}] [translate {s}][espresso_pour_timer]"
		}
	}

	if {$::settings(scale_bluetooth_address) == "" && $::settings(final_desired_shot_volume) > 0 && ($::settings(settings_profile_type) == "settings_2a" || $::settings(settings_profile_type) == "settings_2b")} {
		return "[espresso_pour_timer][translate {s}] [translate {pouring}] < [return_liquid_measurement [round_to_integer $::settings(final_desired_shot_volume)]]"
	} else {
		return "[espresso_pour_timer][translate {s}] [translate {pouring}]"
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
			if {[espresso_millitimer] > 5000} {	
				# no weight increase for 5s due to preinfusion
				if {$::de1(scale_weight_rate) == ""} {
					set ::de1(scale_weight_rate) 3
				}

				set ::de1(scale_weight_rate) [expr {$::de1(scale_weight_rate) + ((rand() - 0.5) * .3) }]
				if {$::de1(scale_weight_rate) < 0} {
					set ::de1(scale_weight_rate) 1
				}
				set ::de1(scale_weight_rate_raw) [expr {$::de1(scale_weight_rate) + ((rand() - 0.5) * 1) }]
			}

		}
			#return [return_flow_weight_measurement [expr {(rand() * 6)}]]
	}

	if {$::de1(scale_weight) == "" || [ifexists ::settings(scale_bluetooth_address)] == ""} {
		return ""
	}
	return [return_flow_weight_measurement $::de1(scale_weight_rate)]
}

proc finalwaterweight_text {} {
	if {$::de1(scale_weight) == "" || [ifexists ::settings(scale_bluetooth_address)] == ""} {
		return ""
	}

	if {[ifexists ::blink_water_weight] == 1} {
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
	if {$::de1(scale_weight) == "" || [ifexists ::settings(scale_bluetooth_address)] == ""} {
		return ""
	}

	if {$::android == 0} {
		if {[espresso_millitimer] < 5000} {	
			# no weight increase for 5s due to preinfusion
			set ::de1(scale_weight) 0
		} else {

			if {$::de1(substate) == $::de1_substate_types_reversed(pouring) || $::de1(substate) == $::de1_substate_types_reversed(preinfusion)} {	
				if {$::de1(scale_weight) == ""} {
					set ::de1(scale_weight) 3
				}
				set ::de1(scale_weight) [expr {$::de1(scale_weight) + (rand() * .3) }]
				set ::de1(final_water_weight) $::de1(scale_weight)
			} else {
				set ::de1(scale_weight) 0
			}
		}

		#return [return_weight_measurement [expr {round((rand() * 20))}]]
	}

	if {$::de1(scale_device_handle) == "0"} {
		return [translate "Disconnected"]
	}


	return [return_weight_measurement $::de1(scale_weight)]
}

proc waterweight_label_text {} {
	if {[ifexists ::settings(scale_bluetooth_address)] == ""} {
		return ""
	}

	if {$::de1(scale_device_handle) == "0"} {
		if {[ifexists ::blink_water_weight] != 1} {
			if {$::currently_connecting_scale_handle == 0} {
				set ::blink_water_weight 1
				return {}
			} else {
				return [translate "Wait"]
			}
		} else {
			set ::blink_water_weight 0
			return [translate "Weight"]
		}
	}

	return [translate "Weight"]
}


proc espresso_goal_temp_text {} {
	return [return_temperature_measurement $::de1(goal_temperature)]
}

proc espresso_goal_temp_text_rtl_aware {} {
	return [subst {[return_temperature_measurement $::de1(goal_temperature)] [translate "goal"]}]
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
	if {$::de1(language_rtl) == 1} {
		return [subst {[translate "bar"] [commify [round_to_one_digits [pressure]]]}]
	}
	return [subst {[commify [round_to_one_digits [pressure]]] [translate "bar"]}]
}


proc commify {number}  {
	while {[regsub {^([-+]?\d+)(\d\d\d)} $number {\1,\2} number]} {}
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
		return "[encoding convertfrom utf-8 °]F"
	} else {
		return "[encoding convertfrom utf-8 °]C"
	}
}

proc return_temp_offset {in} {
	if {$::settings(enable_fahrenheit) == 1} {
		return [expr {$in * 1.8}]
	} else {
		return $in
	}
}


proc return_temperature_number {in} {
	if {$::settings(enable_fahrenheit) == 1} {
		return [round_to_two_digits [celsius_to_fahrenheit $in]]
	} else {
		return [round_to_two_digits $in]
	}	
}

# john 25-1-2020 fix
# we were using the wrong unicode symbol for the degrees sign (should be \u00B0 not \u00BA).
# http://www.fileformat.info/info/unicode/char/b0/index.htm
# http://www.fileformat.info/info/unicode/char/ba/index.htm
proc return_temperature_measurement {in} {
	if {$::settings(enable_fahrenheit) == 1} {
		return [subst {[round_to_integer [celsius_to_fahrenheit $in]]\u00B0F}]
	} else {
		return [subst {[round_to_one_digits $in]\u00B0C}]
	}
}

proc round_and_return_temperature_setting {varname} {
	upvar $varname in
	set out [round_temperature_number $in]
	if {$in != $out} {
	#puts "$in != $out"
		set $varname $out
	}	
	return_temperature_setting $in
}

proc round_temperature_number {in} {
	return [round_to_half_integer $in]
}

proc return_temperature_setting_or_off {in} {
	if {$in == 0} {
		return [translate "off"]
	} else {
		return [return_temperature_setting $in]
	}
}

proc return_temperature_setting {in} {
	#msg "return_temperature_setting: $in"
	if {$::settings(enable_fahrenheit) == 1} {
		return [subst {[round_to_integer [celsius_to_fahrenheit $in]]\u00B0F}]
	} else {
		if {[round_to_half_integer $in] == [round_to_integer $in]} {
			# don't display a .0 on the number if it's not needed
			return [subst {[round_to_integer $in]\u00B0C}]
		} else {
			return [subst {[round_to_half_integer $in]\u00B0C}]
		}
	}
}

proc return_plus_or_minus_number {in} {
	if {$in > 0.0} {
		return "+$in"
	}
	return $in
}

proc return_delta_temperature_measurement {in} {

	if {$::settings(enable_fahrenheit) == 1} {
		set label "\u00B0F"
		#set num [celsius_to_fahrenheit $in]
#		set num $in
	} else {
		set label "\u00B0C"
#		set num $in
	}

	# handle ºC vs ºF deltas
	set in [return_temp_offset $in]
	set num [round_to_one_digits $in]
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

proc group_head_heater_temperature_text_rtl_aware {} {

	return [subst {[return_temperature_measurement [group_head_heater_temperature]] [translate "metal"]}]
}

proc coffee_temp_text_rtl_aware {} {
	return "[watertemp_text] [translate {coffee}]"

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

proc round_to_tens {in} {
	set x 0
    catch {
    	set x [expr {round($in / 10.0)*10}]
    }
    return $x
}

proc round_to_two_digits {in} {
	set x 0
	catch {
		set x [format "%.2f" $in]
	}
	return $x

	# obsolete below
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
	backup_espresso_chart
	#update_de1_explanation_chart
}

proc skin_directories {} {
	if {[info exists ::skin_directories_cache] == 1} {
		return $::skin_directories_cache
	}

	set dirs [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/skins/" *]]
	#puts "skin_directories: $dirs"
	set dd {}
	foreach d $dirs {
		if {$d == "CVS" || $d == "example"} {
			continue
		}
	    
	    set fn "[homedir]/skins/$d/skin.tcl"
	    set skintcl [read_file $fn]
	    #set skintcl ""
	    if {[string first "package require de1plus" $skintcl] != -1} {

		    # keep track of which skins are DE1PLUS so we can display them differently in the listbox
		    set ::de1plus_skins($d) 1
		}

		lappend dd $d		
	}
	set ::skin_directories_cache [lsort -dictionary -increasing $dd]
	return $::skin_directories_cache
}


proc fill_history_listbox {} {
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
	set ::current_skin_number 0
	foreach d [skin_directories] {
		if {$d == "CVS" || $d == "example"} {
			continue
		}
		$widget insert $cnt [translate $d]
		if {$::settings(skin) == $d} {
			set ::current_skin_number $cnt
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

	$widget selection set $::current_skin_number

	make_current_listbox_item_blue $widget
	#puts "current_skin_number: $::current_skin_number"

	preview_tablet_skin
	$widget yview $::current_skin_number

}


proc make_current_listbox_item_blue { widget} {
	if {[$widget index end] == 0} {
		# empty listbox
		return
	}

	set found_one 0
	for {set x 0} {$x < [$widget index end]} {incr x} {
		if {$x == [$widget curselection]} {
			#puts "x: $x vs [$widget index end]"
			#if {$x < [$widget index end]} {
				$widget itemconfigure $x -foreground #000000 -selectforeground #000000  -background #c0c4e1
				set found_one 1
			#}

		} else {
			$widget itemconfigure $x -foreground #b2bad0 -background #fbfaff
		}
	}

	if {$found_one != 1} {
		# handle the case where nothing has been selected
		$widget selection set 0
		$widget itemconfigure 0 -foreground #000000 -selectforeground #000000  -background #c0c4e1
	}

}



proc history_directories {} {
	set dirs [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/history/" *.shot]]
	set dd {}
	foreach d $dirs {
		lappend dd [file rootname $d]
	}
	return [lsort -dictionary -increasing $dd]
}


proc profile_directories {} {

	set show_hidden 0
	if {[ifexists ::profiles_hide_mode] == 1} {
		set show_hidden 1
	}

	set dirs [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/profiles/" *.tcl]]
	set dd {}
	foreach d $dirs {
		#if {$d == "CVS" || $d == "example"} {
		#	continue
		#}

		set filecontents [encoding convertfrom utf-8 [read_binary_file "[homedir]/profiles/$d"]]
	    if {[string first "settings_profile_type settings_2b" $filecontents] != -1 || [string first "settings_profile_type settings_2c" $filecontents] != -1 || [string first "settings_profile_type settings_profile_flow" $filecontents] != -1 || [string first "settings_profile_type settings_profile_advanced" $filecontents] != -1} {

		    #puts "de1+ profile: $d"
		    # keep track of which skins are DE1PLUS so we can display them differently in the listbox
		    set ::de1plus_profile([file rootname $d]) 1
		}

		unset -nocomplain profile
		catch {
			array set profile $filecontents
		}
		if {[info exists profile(profile_title)] != 1} {
			msg "Corrupt profile file in profile_directories: '$d'"
			#continue
		}

		if {[ifexists profile(profile_hide)] == 1} {
			#msg "Hide profile: '$d'"
			if {$show_hidden != 1} {
				continue
			}
		}

		set rootname [file rootname $d]

		if {$rootname == "CVS" || $rootname == "example"} {
			continue
		}		

		lappend dd $rootname
	}

	return [lsort -dictionary -increasing $dd]
}

proc delete_selected_profile {} {
	set w $::globals(profiles_listbox)
	#$w selection set $::current_profile_number
	#puts "cc: '[$w curselection]'"
	#set profile [lindex [profile_directories] [lindex [$w curselection] 0]]
	set profile $::profile_number_to_directory([$w curselection]) 

	set fn "[homedir]/profiles/${profile}.tcl"
	puts "todelete: '$fn'"

	set todel $::settings(profile)
	puts "delete profile: $todel"
	if {$profile == "default"} {
		msg "cannot delete default profile"
		return
	}
	#return

	#puts [subst {file delete "[homedir]/profiles/${todel}.tcl"}]
	file delete $fn
	set ::settings(profile) "default"
	fill_profiles_listbox 
	#preview_profile 

}


# the checkbox character is not available in all fonts, so we use an X instead then
proc checkboxchar {} {
	if {[language] == "ar" || [language] == "he"} {
		return "X"
	}

	return \u2713
}

proc bluetooth_character {} {
	if {[language] == "ar" || [language] == "he"} {
		return "BLE:"
	}

	return \uF294
}

proc usb_character {} {
	if {[language] == "ar" || [language] == "he"} {
		return "USB:"
	}

	return \uF287
}

#set de1_device_list {}
proc fill_ble_listbox {} {

	set widget $::ble_listbox_widget
	$widget delete 0 99999
	set cnt 0
	set current_ble_number 0

	set one_selected 0
	foreach d [lsort -dictionary -increasing $::de1_device_list] {
		set addr_raw [dict get $d address]
		set name [dict get $d name]
		set type [dict get $d type]

		set display_addr $addr_raw
		if { $type == "ble" } { 
			set icon [bluetooth_character]
			set display_addr [string range $addr_raw 9 13]
		} elseif { $type == "usb" } {
			set icon [usb_character]
		} else {
			set icon "?"
		}

		if {$addr_raw == [ifexists ::settings(bluetooth_address)]} {
			$widget insert $cnt " \[[checkboxchar]\] $icon $name ($display_addr)"
			set one_selected 1
		} else {
			$widget insert $cnt " \[   \] $icon $name ($display_addr)"
		}

		if {[ifexists ::settings(bluetooth_address)] == $addr_raw} {
			set current_ble_number $cnt
		}
		incr cnt
	}

	set ::de1_needs_to_be_selected 0
	if {[llength $::de1_device_list] > 0 && $one_selected == 0} {
		set ::de1_needs_to_be_selected 1
	}

	# john - probably makes sense for "pair" to occur on item tap
	make_current_listbox_item_blue $widget
}

proc fill_ble_scale_listbox {} {
	

	set widget $::ble_scale_listbox_widget
	$widget delete 0 99999
	set cnt 0
	set current_ble_number 0

	set one_selected 0
	foreach d [lsort -dictionary -increasing $::scale_bluetooth_list] {
		set addr [dict get $d address]
		set name [dict get $d name]
		set type [dict get $d type]
		set icon [bluetooth_character]

		if { $name eq "" } { set name $type }
		if {$addr == [ifexists ::settings(scale_bluetooth_address)]} {
			$widget insert $cnt " \[[checkboxchar]\] $icon $name"
			set one_selected 1
		} else {
			$widget insert $cnt " \[   \] $icon $name"
		}
			#$widget insert $cnt $addr
		if {[ifexists ::settings(scale_bluetooth_address)] == $addr} {
			set current_ble_number $cnt
		}
		incr cnt
	}
	
	$widget selection set $current_ble_number;

	set ::scale_needs_to_be_selected 0
	if {[llength $::de1_device_list] > 0 && $one_selected == 0} {
		set ::scale_needs_to_be_selected 1
	}
	
	make_current_listbox_item_blue $widget
}

proc profile_type_text {} {
	set in $::settings(settings_profile_type)
	if {$in == "settings_2a"} {
		return [translate "Pressure profile"]
	} elseif {$in == "settings_2b"} {
		return [translate "Flow profile"]
	} elseif {$in == "settings_2c"} {
		return [translate "Advanced profile"]
	} else {
		return [translate "Profile"]
	}
}

proc array_keys_sorted_by_val {arrname {sort_order -increasing}} {
	upvar $arrname arr
	foreach k [array names arr] {
		set k2 "$arr($k) $k"
		#set k2 "[format {"%0.12i"} $arr($k)] $k"
		#puts "k2: $k2"
		set t($k2) $k
	}
	
	set toreturn {}

	set keys [lsort $sort_order -dictionary [array names t]]
	foreach k $keys {
		set v $t($k)
		lappend toreturn $v
	}
	return $toreturn
}

proc fill_specific_profiles_listbox { widget selected_profile_name hide_mode} {
	$widget delete 0 99999

	set selected_profile_number 0
	set cnt 0
	set grouping ""

	unset -nocomplain ::profile_number_to_directory

	foreach d [profile_directories] {

		unset -nocomplain profile
		catch {
			set fn "[homedir]/profiles/$d.tcl"

			array set profile [encoding convertfrom utf-8 [read_binary_file $fn]]
		}

		set profile_to_title($d) [translate [ifexists profile(profile_title)]]
	}

	set profiles [array_keys_sorted_by_val profile_to_title]

	foreach d $profiles {

		set fn "[homedir]/profiles/${d}.tcl"
		#puts "fn: $fn"
		unset -nocomplain profile
		catch {
			array set profile [encoding convertfrom utf-8 [read_binary_file $fn]]
		}

		if {[info exists profile(profile_title)] != 1} {
			msg "Corrupt profile file in choices: '$d'"
			#continue
			set profile(profile_title) "$d \u2639 \u2639 \u2639"
		}


		# experimental feature to also load god shots with profiles
		# if {$profile(profile_title) == "Default" || $profile(profile_title) == "Gentle and sweet"} {
		# 	set profile(profile_title) "$d \u2665"
		# }


		set ptitle $profile(profile_title)

		set pcnt [ifexists ::profile_shot_count($d)]
		#puts "ptitle: '$ptitle '$pcnt'"

		if {[language] != "en" && [ifexists profile(profile_language)] == "en" && [ifexists profile(author)] == "Decent"} {
			set p [translate $ptitle]
		} else {
			set p $ptitle
		}

		if {$hide_mode != 1} {
			if {[ifexists profile(profile_hide)] == 1} {
				# hide this profile if it's marked to be hidden, unless we're un the profile_hide edit mode, in which case we show all profiles
				continue
			}
			if {$pcnt != ""} {
				# mark the most frequently used profiles with a special symbol, to attract the eye to them
				set p "$p \u25C0"
			}

			set parts [split $p /]
			if {[llength $parts] > 1} {
				set this_group [lindex $parts 0]
				if {$this_group != $grouping} {
					set grouping $this_group
					$widget insert $cnt $this_group
					set ::profile_number_to_directory($cnt) $d
					incr cnt
				}
				set p " - [lindex $parts 1]"
	
			} else {
			}
	
		} else {
			# if editing what profiles to show, then use a check or empty box, to indicate which profiles will be shown

			if {[ifexists profile(profile_hide)] == 1} {
				if {[language] == "he"} {
					set p "\[   \] $p"
				} else {
					set p "\u2610 $p"
				}
			} else {
				if {[language] == "he"} {
					set p "\[X\] $p"
				} else {
					set p "\u2612 $p"
				}
			}

		}

		$widget insert $cnt $p
		set ::profile_number_to_directory($cnt) $d
	

		#msg "'$selected_profile_name' == '[ifexists profile(profile_title)]'"
		if {[string tolower $selected_profile_name] == [string tolower [ifexists profile(profile_title)]]} {
			set selected_profile_number $cnt
			#puts "current profile of '$d' is #$cnt"
		} elseif {[language] != "en"} {
			if {[string tolower $selected_profile_name] == [string tolower [translate [ifexists profile(profile_title)]]]} {
				set selected_profile_number $cnt
			#	msg "translated current profile of '$d' is #$cnt"
			}
		}

		incr cnt
	}

	return $selected_profile_number
}


proc fill_profiles_listbox {} {

	# use this variable to prevent triggering preview_profile for each profile as it gets added to the listbox.  Tk would otherwise do this for each profile as its added to the listbox
	set ::filling_profiles 1

	set widget $::globals(profiles_listbox)
	set ::settings(profile_to_save) $::settings(profile)

	set ::current_profile_number [fill_specific_profiles_listbox $widget $::settings(profile) [ifexists ::profiles_hide_mode]]

	$widget selection set $::current_profile_number;
	#set ::globals(profiles_listbox) $widget
	make_current_listbox_item_blue $widget 
	preview_profile 
	$widget yview $::current_profile_number
	unset -nocomplain ::filling_profiles 
}

proc copy_pressure_profile_to_advanced_profile {} {

	if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} {
		set temp_bump_time_seconds $::settings(temp_bump_time_seconds)
		set first_frame_len $temp_bump_time_seconds

		set second_frame_len [expr {$::settings(preinfusion_time) - $temp_bump_time_seconds}]		
		if {$second_frame_len < 0} { 
			set second_frame_len 0
		}
	} else {
		set first_frame_len 0
		set second_frame_len $::settings(preinfusion_time)
		set ::settings(espresso_temperature_0) $::settings(espresso_temperature)
		set ::settings(espresso_temperature_1) $::settings(espresso_temperature)
		set ::settings(espresso_temperature_2) $::settings(espresso_temperature)
		set ::settings(espresso_temperature_3) $::settings(espresso_temperature)
	}

	msg "copy_pressure_profile_to_advanced_profile"
	set preinfusion [list \
		name [translate "preinfusion"] \
		temperature $::settings(espresso_temperature) \
		sensor "coffee" \
		pump "flow" \
		transition "fast" \
		pressure 1 \
		flow $::settings(preinfusion_flow_rate) \
		seconds $first_frame_len \
		volume $::settings(preinfusion_stop_volumetric) \
		exit_if "1" \
		exit_type "pressure_over" \
		exit_pressure_over $::settings(preinfusion_stop_pressure) \
		exit_pressure_under 0 \
		exit_flow_over 6 \
		exit_flow_under 0 \
	]

	set preinfusion2 [list \
		name [translate "preinfusion"] \
		temperature $::settings(espresso_temperature_1) \
		sensor "coffee" \
		pump "flow" \
		transition "fast" \
		pressure 1 \
		flow $::settings(preinfusion_flow_rate) \
		seconds $second_frame_len \
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
		temperature $::settings(espresso_temperature_2) \
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
		temperature $::settings(espresso_temperature_3) \
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


	if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} {
		set ::settings(advanced_shot) [list $preinfusion $preinfusion2 $hold $decline]
	} else {
		set ::settings(advanced_shot) [list $preinfusion2 $hold $decline]
	}
	set ::current_step_number 0
}


proc copy_flow_profile_to_advanced_profile {} {


	if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} {
		set temp_bump_time_seconds $::settings(temp_bump_time_seconds)
		set first_frame_len $temp_bump_time_seconds

		set second_frame_len [expr {$::settings(preinfusion_time) - $temp_bump_time_seconds}]		
		if {$second_frame_len < 0} { 
			set second_frame_len 0
		}
	} else {
		set first_frame_len 0
		set second_frame_len $::settings(preinfusion_time)
		set ::settings(espresso_temperature_0) $::settings(espresso_temperature)
		set ::settings(espresso_temperature_1) $::settings(espresso_temperature)
		set ::settings(espresso_temperature_2) $::settings(espresso_temperature)
		set ::settings(espresso_temperature_3) $::settings(espresso_temperature)
	}


	puts "copy_flow_profile_to_advanced_profile"
	set preinfusion [list \
		name [translate "preinfusion"] \
		temperature $::settings(espresso_temperature) \
		sensor "coffee" \
		pump "flow" \
		transition "fast" \
		pressure 1 \
		flow $::settings(preinfusion_flow_rate) \
		seconds $first_frame_len \
		volume $::settings(preinfusion_stop_volumetric) \
		exit_if "1" \
		exit_type "pressure_over" \
		exit_pressure_over $::settings(preinfusion_stop_pressure) \
		exit_pressure_under 0 \
		exit_flow_over 6 \
		exit_flow_under 0 \
	]

	set preinfusion2 [list \
		name [translate "preinfusion"] \
		temperature $::settings(espresso_temperature_1) \
		sensor "coffee" \
		pump "flow" \
		transition "fast" \
		pressure 1 \
		flow $::settings(preinfusion_flow_rate) \
		seconds $second_frame_len \
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
		temperature $::settings(espresso_temperature_2) \
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
		temperature $::settings(espresso_temperature_3) \
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


		if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} {
			set ::settings(advanced_shot) [list $preinfusion $preinfusion2 $rise $hold $decline]
		} else {
			set ::settings(advanced_shot) [list $preinfusion $rise $hold $decline]
		}

	} else {

		if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} {
			set ::settings(advanced_shot) [list $preinfusion $preinfusion2 $hold $decline]
		} else {
			set ::settings(advanced_shot) [list $preinfusion $hold $decline]
		}
	}
	#puts "adv: $::settings(advanced_shot)"
	set ::current_step_number 0
}

proc fill_languages_listbox {} {

	set widget $::languages_widget

	$widget delete 0 99999
	set cnt 0
	set current_profile_number 0

	# on android we can automatically detect the language from the OS setting, and this is the preferred way to go
	$widget insert $cnt [translate Automatic]
	incr cnt

	set current 0

	foreach {code desc} [translation_langs_array] {
        #puts "$code $desc"

		if {$::settings(language) == $code} {
			set current $cnt
		}
		$widget insert $cnt "$desc"
		incr cnt
	}

	$widget selection set $current;
	make_current_listbox_item_blue $::languages_widget

	$::languages_widget yview $current
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
		#puts "[expr {1 + $cnt}]. $name"
		$widget insert $cnt "[expr {1 + $cnt}]. $name"
		incr cnt
	}
	
	if {$cs == "" || $cs > [$::advanced_shot_steps_widget index end]} {
		$::advanced_shot_steps_widget selection set 0;
		set ::current_step_number 0
	} else {
		$::advanced_shot_steps_widget selection set $cs;
	}

	load_advanced_profile_step 1
	make_current_listbox_item_blue $::advanced_shot_steps_widget
	update idletasks
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

proc load_language {} {
	set stepnum [$::languages_widget curselection]
	if {$stepnum == ""} {
		return
	}

	if {$stepnum == 0} {
		set ::settings(language) ""
	} else {
		set ::settings(language) [lindex [translation_langs_array] [expr {($stepnum * 2) - 2}] ]
	}

	make_current_listbox_item_blue $::languages_widget

	#puts "lang '$::settings(language)' '$stepnum'"
}

proc load_advanced_profile_step {{force 0}} {
	#msg "load_advanced_profile_step [clock milliseconds]"

	if {$::de1(current_context) != "settings_2c" && $force == 0} {
		puts "returning load_advanced_profile_step"
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

	profile_has_changed_set
	# for display purposes, make the espresso temperature be equal to the temperature of the first step in the advanced shot
	array set first_step [lindex $::settings(advanced_shot) 0]
	set ::settings(espresso_temperature) [ifexists first_step(temperature)]
}

proc delete_current_adv_step {} {

	if {[$::advanced_shot_steps_widget index end] == 1} {
		# we don't allow deleting the only step, because that leads to weird UI issues.
		puts "not deleting step because there is only one advanced step at the moment"
		return
	}

	set ::settings(advanced_shot) [lreplace $::settings(advanced_shot)  [current_adv_step] [current_adv_step]]

	puts "deleting"
	set ::current_step_number 0
	$::advanced_shot_steps_widget selection set $::current_step_number;
	$::advanced_shot_steps_widget activate $::current_step_number;
	fill_advanced_profile_steps_listbox
	#make_current_listbox_item_blue $::advanced_shot_steps_widget
}

# inserts a new step immediately after the currently seleted one, with all the same settings except for a different name
proc add_to_current_adv_step {} {

	# don't add more than the maximum number of steps that the espresso machine can handle
	if {[llength $::settings(advanced_shot)] >= 20} {
		return
	}

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
	$::advanced_shot_steps_widget selection clear $::current_step_number;
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
	
	if {$::de1(current_context) != "tabletstyles"} {
		return 
	}


	msg "preview_tablet_skin"
	set w $::globals(tablet_styles_listbox)
	if {[$w curselection] == ""} {
		msg "no current skin selection"
		#set w 
		#set skindir [$w get $::current_skin_number]
		#return
		puts "::current_skin_number: $::current_skin_number"
		$w selection set $::current_skin_number
	}


	set skindir [lindex [skin_directories] [$w curselection]]
	set ::settings(skin) $skindir
	#puts "skindir: '$skindir'"

	set fn "[homedir]/skins/$skindir/${::screen_size_width}x${::screen_size_height}/icon.jpg"
	if {[file exists $fn] != 1} {
    	catch {
    		file mkdir "[homedir]/skins/$skindir/${::screen_size_width}x${::screen_size_height}/"
    	}

		puts "creating $fn"
        set rescale_images_x_ratio [expr {$::screen_size_height / 1600.0}]
        set rescale_images_y_ratio [expr {$::screen_size_width / 2560.0}]

		set src "[homedir]/skins/$skindir/2560x1600/icon.jpg"
		catch {
			$::table_style_preview_image read $src
			photoscale $::table_style_preview_image $rescale_images_y_ratio $rescale_images_x_ratio
			$::table_style_preview_image write $fn  -format {jpeg -quality 90}
		}

	} else {
		set fn "[homedir]/skins/$skindir/${::screen_size_width}x${::screen_size_height}/icon.jpg"
		$::table_style_preview_image read $fn
	}

	make_current_listbox_item_blue $::globals(tablet_styles_listbox)
}

proc preview_history {w args} {
	catch {
		set profile [lindex [history_directories] [$w curselection] [$w curselection]]
		puts "history item: $profile [$w curselection]"

		set fn "[homedir]/history/${profile}.tcl"

		# need to code this
		array set props [encoding convertfrom utf-8 [read_binary_file $fn]]

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

proc save_settings_and_ask_to_restart_app {} {
	save_settings; 
	message_page [translate "Please quit and restart this app to apply your changes."] [translate "Quit"];
}

proc message_page {msg buttonmsg} {
	if {[catch {
		.can itemconfigure $::message_label -text $msg
		.can itemconfigure $::message_button_label -text $buttonmsg
		set_next_page off message; 
		page_show message
	} err] != 0} {
		msg "message_page failed because: '$err'"
	}

}


#set ::infopage_label [add_de1_text "infopage" 1280 750 -text "" -font Helv_15_bold -fill "#2d3046" -justify "center" -anchor "center" -width 900]
#set ::infopage_button_label [add_de1_text "infopage" 1280 1090 -text [translate "Ok"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"]
#set ::infopage_button [add_de1_button "infopage" {say [translate {Ok}] $::settings(sound_button_in); set_next_page off off} 980 990 1580 1190 ""]


proc info_page {msg buttonmsg} {
	if {[catch {
		.can itemconfigure $::infopage_label -text $msg
		.can itemconfigure $::infopage_button_label -text $buttonmsg
		set_next_page off infopage; 
		page_show off
	} err] != 0} {
		msg "info_page failed because: '$err'"
	}
}

proc change_bluetooth_device {} {


	################################################################################################################

	set w $::ble_listbox_widget
	#set ::settings(profile) [$::globals(profiles_listbox) get [$::globals(profiles_listbox) curselection]]
	if {[$w curselection] == ""} {
		# no current selection
		puts "no BLE selection"
		return ""
	}

	set selection_index [$w curselection]
	set dic [lindex $::de1_device_list $selection_index]
	set addr [dict get $dic address]

	if {$addr == $::settings(bluetooth_address)} {
		# if no change in setting, then disconnect/reconnect.
		#return

		################################################################################################################
		# prevent rapid changing of DE1 bluetooth setting, because that can cause multiple connections to be made to the same DE1
		if {[ifexists ::globals(changing_bluetooth_device)] == 1} {
			puts "already changing_bluetooth_device"
			return
		}

		msg "reconnecting to DE1"

	}

	set ::globals(changing_bluetooth_device) 1
	after 5000 {set ::globals(changing_bluetooth_device) 0}

	if {$addr != $::settings(bluetooth_address)} {
		# if no change in setting, then disconnect/reconnect.
		set ::settings(bluetooth_address) $addr
		save_settings
	}

	# disconnect (if necessary) and reconnect to the DE1 now
	ble_connect_to_de1

	fill_ble_listbox
}


proc change_scale_bluetooth_device {} {
	set w $::ble_scale_listbox_widget


	if {$w == ""} {
		return
	}
	if {[$w curselection] == ""} {
		# no current selection
		#return ""
		msg "re-connecting to scale"
		ble_connect_to_scale
		return
	}
	set selection_index [$w curselection]
	set dic [lindex $::scale_bluetooth_list $selection_index]
	set addr [dict get $dic address]
	set name [dict get $dic name]

	if { $name == "" } {
		set name [dict get $dic type]
	}

	set ::settings(scale_bluetooth_address) $addr
	set ::settings(scale_bluetooth_name) $name

	set ::settings(scale_type) [ifexists ::scale_types($addr)]
	msg "set scale type to: '$::settings(scale_type)' $addr"

	if {$addr == $::settings(scale_bluetooth_address)} {
		ble_connect_to_scale
		return
	}
	#msg "scale types: [array get ::scale_types]"

	save_settings
	ble_connect_to_scale

	fill_ble_scale_listbox
}


proc select_profile { profile } {
	set fn "[homedir]/profiles/${profile}.tcl"
	set ::settings(profile) $profile
	set ::settings(profile_notes) ""
	
	# for importing De1 profiles that don't have this feature.
	set ::settings(preinfusion_flow_rate) 4

	load_settings_vars $fn

	set ::settings(profile_filename) $profile
	#msg "profile: $profile - $::settings(profile_notes)"

	#puts "Author: '[ifexists ::settings(author)]'"
	if {[language] != "en" && $::settings(profile_language) == "en" && [ifexists ::settings(author)] == "Decent"} {
		# the first time this profile is loaded into another language, we should try to translate the
		# title and notes to the local language
		set ::settings(profile_notes) [translate $::settings(profile_notes)]
		set ::settings(profile_title) [translate $::settings(profile_title)]
		set ::settings(profile_language) [language]
	}
	set ::settings(original_profile_title) $::settings(profile_title)

	if {$::settings(settings_profile_type) == "settings_2" || $::settings(settings_profile_type) == "settings_profile_pressure"} {
		set ::settings(settings_profile_type) "settings_2a"
	} elseif {$::settings(settings_profile_type) == "settings_profile_flow"} {
		set ::settings(settings_profile_type) "settings_2b"
	} elseif {$::settings(settings_profile_type) == "settings_profile_advanced" || $::settings(settings_profile_type) == "settings_2c2"} {
		# old profile names that shouldn't exist any more, so upgrade them to the latest name
		set ::settings(settings_profile_type) "settings_2c"
	}

	#puts "::settings(settings_profile_type)  $::settings(settings_profile_type)"
	set ::settings(profile) $::settings(profile_title)

	if {$::settings(enable_rise) != 1} {
		 # "rise" feature was removed and is disabled by default
		set ::settings(preinfusion_guarantee) 0
	}

	update_onscreen_variables
	profile_has_not_changed_set

	# as of v1.3 people can start an espresso from the group head, which means their currently selected 
	# profile needs to sent right away to the DE1, in case the person taps the GH button to start espresso w/o leaving settings
	send_de1_settings_soon
}

set preview_profile_counter 0
proc preview_profile {} {
	if {$::de1(current_context) != "settings_1"} {
		return 
	}

	if {[ifexists ::filling_profiles] == 1} {
		# use this variable to prevent triggering preview_profile for each profile as it gets added to the listbox.  Tk would otherwise do this for each profile as its added to the listbox
		return
	}


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

	#set profile [lindex [profile_directories] [$w curselection]]
	set profile $::profile_number_to_directory([$w curselection]) 

	
	set fn "[homedir]/profiles/${profile}.tcl"

	if {[ifexists ::profiles_hide_mode] == 1} {

		catch {
			array set thisprofile [encoding convertfrom utf-8 [read_binary_file $fn]]
		}

		if {[info exists thisprofile(profile_title)] != 1} {
			msg "Corrupt profile file to preview: '$d'"
			return
		}


		if {[ifexists thisprofile(profile_hide)] == 1} {
			#msg "unhiding profile: '$profile'"
			set thisprofile(profile_hide) 0
		} else {
			#msg "hiding profile: '$profile'"
			set thisprofile(profile_hide) 1
		}
		save_array_to_file thisprofile $fn 
		set ::filling_profiles 1

		# need to save and restore the scrollbar value, because we're refilling the listbox to show hide/show state change
		set oldscrollbarbalue [$::profiles_scrollbar get]
		#puts "oldscrollbarbalue: $oldscrollbarbalue"
		fill_profiles_listbox
		unset -nocomplain ::filling_profiles 

		$::profiles_scrollbar set $oldscrollbarbalue
		listbox_moveto $::globals(profiles_listbox) $::profiles_slider $oldscrollbarbalue
		return

	}

	select_profile $profile

	make_current_listbox_item_blue $::globals(profiles_listbox)
	
	#set ::settings(profile_notes) [clock seconds]
}


proc send_de1_settings_soon  {} {

	# if they have a GHC then they can press it while in the settings page, and expect the profile they just select to be in place.  Thus we bluetooth send 
	# profiles as they tap on them, but only if they have a GHC. No point in sending bluetooth commands that are not needed on non-GHC machines.
	if {[ghc_required] == 1} {

		if {[info exists ::save_settings_to_de1_id] == 1} {
			after cancel $::save_settings_to_de1_id; 
			unset -nocomplain ::save_settings_to_de1_id
			msg "cancelled extra de1_send"
		}

		set ::save_settings_to_de1_id [after 500 save_settings_to_de1]
	}
}



proc profile_has_changed_set_colors {} {
	#msg "profile_has_changed_set_colors : $::settings(profile_has_changed) [stacktrace]"

	if {$::settings(profile_has_changed) == 1} {
		update_de1_explanation_chart
		if {[info exists ::globals(widget_profile_name_to_save)] == 1} {		
			catch {
				$::globals(widget_profile_name_to_save) configure -bg #ffe3e3
			}
		}

		catch {
			.can itemconfigure $::globals(widget_current_profile_name) -fill $::de1(widget_current_profile_name_color_normal)
		}
		catch {
			.can itemconfigure $::globals(widget_current_profile_name1) -fill $::de1(widget_current_profile_name_color_normal)
		}
		catch {
			.can itemconfigure $::globals(widget_current_profile_name2) -fill $::de1(widget_current_profile_name_color_normal)
		}
		catch {
			.can itemconfigure $::globals(widget_current_profile_name_espresso) -fill $::de1(widget_current_profile_name_color_normal)
		}
		catch {
			.can itemconfigure $::globals(widget_current_profile_name_espresso1) -fill $::de1(widget_current_profile_name_color_normal)
		}
		catch {
			.can itemconfigure $::globals(widget_current_profile_name_espresso2) -fill $::de1(widget_current_profile_name_color_normal)
		}
	} else {
		if {[info exists ::globals(widget_profile_name_to_save)] == 1} {		
			# this indicates to the user that the profile has changed or not
			catch {
				$::globals(widget_profile_name_to_save) configure -bg #fbfaff
			}
		}

		# this is displayed on the main Insight skin page
		catch {
			.can itemconfigure $::globals(widget_current_profile_name) -fill $::de1(widget_current_profile_name_color_changed)
		}
		catch {
			.can itemconfigure $::globals(widget_current_profile_name1) -fill $::de1(widget_current_profile_name_color_changed)
		}
		catch {
			.can itemconfigure $::globals(widget_current_profile_name2) -fill $::de1(widget_current_profile_name_color_changed)
		}
		catch {
			.can itemconfigure $::globals(widget_current_profile_name_espresso) -fill $::de1(widget_current_profile_name_color_changed)
		}
		catch {
			.can itemconfigure $::globals(widget_current_profile_name_espresso1) -fill $::de1(widget_current_profile_name_color_changed)
		}
		catch {
			.can itemconfigure $::globals(widget_current_profile_name_espresso2) -fill $::de1(widget_current_profile_name_color_changed)
		}
	}
}

proc profile_has_changed_set args {

	# if one the scroll bars has been touched by a human (not by the page display code) then mark the profile as having been changed
	if {[lsearch -exact [stackprocs] "page_show"] == -1 && [lsearch -exact [stackprocs] "update_onscreen_variables"] == -1} {
		set ::settings(profile_has_changed) 1
		#puts "profile_has_changed_set:\n[stacktrace]"
	} else {
		#puts "profile_has_changed_set:\n[stacktrace]"
	}

	#profile_has_changed_set_colors
	#puts "profile_has_changed_set:\n[stacktrace]"
}


proc profile_has_not_changed_set args {
	set ::settings(profile_has_changed) 0
}

proc load_settings_vars {fn} {

	msg "load_settings_vars $fn"

	# default to no temp steps, so as to migrate older profiles that did not have this setting, and not accidentally enble this feature on them
	unset -nocomplain ::settings(espresso_temperature_steps_enabled) 

	# default value 
	set ::settings(final_desired_shot_volume_advanced_count_start) 0

	#error "load_settings_vars"
	# set the default profile type to use, this can be over-ridden by the saved profile
	set ::settings(settings_profile_type) "settings_2a"


	catch {
		foreach {k v} [encoding convertfrom utf-8 [read_binary_file $fn]] {
			#puts "$k $v"
			#set ::settings($k) $v
			set temp_settings($k) $v
		}
	}

	if {[ifexists temp_settings(settings_profile_type)] == "settings_2c" && [ifexists temp_settings(final_desired_shot_weight)] != "" && [ifexists temp_settings(final_desired_shot_weight_advanced)] == "" } {
		msg "Using a default for final_desired_shot_weight_advanced from final_desired_shot_weight of [ifexists temp_settings(final_desired_shot_weight)]"
		set temp_settings(final_desired_shot_weight_advanced) [ifexists temp_settings(final_desired_shot_weight)]
	}

	# pre-set the shot volume, to the shot weight, if importing an old shot definition that doesn't have a an end volume 
	if {[ifexists temp_settings(final_desired_shot_volume)] == ""} {
		msg "pre-set the shot volume, to the shot weight, if importing an old shot definition that doesn't have a an end volume "
		set temp_settings(final_desired_shot_volume) [ifexists temp_settings(final_desired_shot_weight)]
	}

	if {[ifexists ::temp_settings(black_screen_saver)] == 1} {
		# we've moved the "black screen saver" feature from its own dedicated variable to now be a setting of "0 minutes" on the screen saver change timer
		# this line is simply for backward compatiblity, moving the old setting to a new one
		set temp_settings(final_desired_shot_volume) 0
		set temp_settings(saver_brightness) 0		
	}

	catch {
		array set ::settings [array get temp_settings]
	}

	# john disabling LONG PRESS support as it appears to be buggy on tablets https://3.basecamp.com/3671212/buckets/7351439/messages/2566269076#__recording_2595312790
	set ::setting(disable_long_press) 1

	update_de1_explanation_chart

}

proc save_settings_vars {fn varlist} {

	set txt ""
	foreach k $varlist {
		if {[info exists ::settings($k)] == 1} {
			set v $::settings($k)
			append txt "[list $k] [list $v]\n"
		}
	}

	set success 0
	catch {
	    write_file $fn $txt
	    set success 1
	}
	return $success
}

proc profile_vars {} {
 	return { advanced_shot espresso_temperature_steps_enabled author espresso_hold_time preinfusion_time espresso_pressure espresso_decline_time pressure_end espresso_temperature espresso_temperature_0 espresso_temperature_1 espresso_temperature_2 espresso_temperature_3 settings_profile_type flow_profile_preinfusion flow_profile_preinfusion_time flow_profile_hold flow_profile_hold_time flow_profile_decline flow_profile_decline_time flow_profile_minimum_pressure preinfusion_flow_rate profile_notes water_temperature final_desired_shot_volume final_desired_shot_weight final_desired_shot_weight_advanced tank_desired_water_temperature final_desired_shot_volume_advanced preinfusion_guarantee profile_title profile_language preinfusion_stop_pressure profile_hide final_desired_shot_volume_advanced_count_start bean_brand bean_type grinder_setting grinder_dose_weight grinder_model}
}


proc set_profile_title_untitled {} {
	# if no name then give it a name which is just a number
	if {$::settings(profile_title) == ""} {
		incr ::settings(preset_counter)  
		save_settings

		set ::settings(profile_title) [subst {[translate "Untitled"] $::settings(preset_counter)}]
	}
}

proc save_profile {} {
	if {$::settings(profile_title) == [translate "Saved"]} {
		return
	}

	# if no name then give it a name which is just a number
	set_profile_title_untitled

	#set profile_vars { advanced_shot author espresso_hold_time preinfusion_time espresso_pressure espresso_decline_time pressure_end espresso_temperature settings_profile_type flow_profile_preinfusion flow_profile_preinfusion_time flow_profile_hold flow_profile_hold_time flow_profile_decline flow_profile_decline_time flow_profile_minimum_pressure preinfusion_flow_rate profile_notes water_temperature final_desired_shot_volume final_desired_shot_weight final_desired_shot_weight_advanced tank_desired_water_temperature final_desired_shot_volume_advanced preinfusion_guarantee profile_title profile_language preinfusion_stop_pressure}
	#set profile_name_to_save $::settings(profile_to_save) 

	if {$::settings(settings_profile_type) == "settings_2c2"} {
		# if on the LIMITS tab, indicate that this is settings_2c (aka "advanced") shot as part of the OK button process
		set ::settings(settings_profile_type) "settings_2c"
		
	}


	if {[ifexists ::settings(original_profile_title)] == $::settings(profile_title)} {
		set profile_filename $::settings(profile_filename) 
	} else {
		# if they change the description of the profile, then save it to a new name
		set profile_filename [clock seconds]
	}
	
	set fn "[homedir]/profiles/${profile_filename}.tcl"

	# set the title back to its title, after we display SAVED for a second
	# moves the cursor to the end of the seletion after showing the "saved" message.
	after 1000 "set ::settings(profile_title) \{$::settings(profile_title)\}; $::globals(widget_profile_name_to_save) icursor 999"

	if {[save_settings_vars $fn [profile_vars]] == 1} {
		#set ::settings(profile) $profile_name_to_save
		set ::settings(profile) $::settings(profile_title)

		fill_profiles_listbox 
		update_de1_explanation_chart
		set ::settings(profile_title) [translate "Saved"]
		profile_has_not_changed_set

	} else {
		set ::settings(profile_title) [translate "Invalid name"]
	}

	profile_has_changed_set_colors
}

proc save_espresso_rating_to_history {} {
	#unset -nocomplain ::settings(history_saved)
	set ::settings(history_saved) 0
	save_this_espresso_to_history {} {}
}


# Lazy way of decoupling from "package require" ordering.
after idle {after 0 {register_state_change_handler Espresso Idle save_this_espresso_to_history}}

proc save_this_espresso_to_history {unused_old_state unused_new_state} {
	puts "save_this_espresso_to_history "
	# only save shots that have at least 5 data points
	if {!$::settings(history_saved) && [espresso_elapsed length] > 5 && [espresso_pressure length] > 5 && $::settings(should_save_history) == 1} {

		#set clock [clock seconds]
		if {[info exists ::settings(espresso_clock)] != 1} {
			# in theory, this should never occur.
			msg "This espresso's start time was not recorded. Possibly we didn't get the bluetooth message of state change to espresso."
			set ::settings(espresso_clock) [clock seconds]
		}
		
		set clock $::settings(espresso_clock)
		set name [clock format $clock]

		set espresso_data {}
		set espresso_data "name [list $name]\n"
		set espresso_data "clock $clock\n"
		#set espresso_data "final_espresso_weight $::de1(final_espresso_weight)\n"

		#set espresso_data "settings [array get ::settings]\n"

		append espresso_data "espresso_elapsed {[espresso_elapsed range 0 end]}\n"
		append espresso_data "espresso_pressure {[espresso_pressure range 0 end]}\n"
		append espresso_data "espresso_weight {[espresso_weight range 0 end]}\n"
		append espresso_data "espresso_flow {[espresso_flow range 0 end]}\n"
		append espresso_data "espresso_flow_weight {[espresso_flow_weight range 0 end]}\n"
		append espresso_data "espresso_flow_weight_raw {[espresso_flow_weight_raw range 0 end]}\n"
		append espresso_data "espresso_temperature_basket {[espresso_temperature_basket range 0 end]}\n"
		append espresso_data "espresso_temperature_mix {[espresso_temperature_mix range 0 end]}\n"
		append espresso_data "espresso_water_dispensed {[espresso_water_dispensed range 0 end]}\n"

		append espresso_data "espresso_pressure_goal {[espresso_pressure_goal range 0 end]}\n"
		append espresso_data "espresso_flow_goal {[espresso_flow_goal range 0 end]}\n"
		append espresso_data "espresso_temperature_goal {[espresso_temperature_goal range 0 end]}\n"		

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

		set fn "[homedir]/history/[clock format $clock -format "%Y%m%dT%H%M%S"].shot"
		write_file $fn $espresso_data
		msg "Save this espresso to history"

		set ::settings(history_saved) 1
	} else {
		msg "Not saved to history $::settings(history_saved) - [espresso_elapsed length] - [espresso_pressure length] - $::settings(should_save_history) "
	}
}

proc ghc_required {} {
	if {$::settings(ghc_is_installed) != 0 && $::settings(ghc_is_installed) != 1 && $::settings(ghc_is_installed) != 2 && $::settings(ghc_is_installed) != 4} {
		return 1
	}
	return 0

}

proc start_text_if_espresso_ready {} {
	set num $::de1(substate)
	set substate_txt $::de1_substate_types($num)
	if {$substate_txt == "ready" && $::de1(device_handle) != 0} {
		
		if {[ghc_required]} {
			# display READY instead of START, because they have to tap the group head to start, they cannot tap the tablet, due to UL compliance limits
			return [translate "READY"]
		}
		return [translate "START"]
	}
	return [translate "WAIT"]
}

proc restart_text_if_espresso_ready {} {
	set num $::de1(substate)
	set substate_txt $::de1_substate_types($num)
	if {$substate_txt == "ready" && $::de1(device_handle) != 0} {
		if {[ghc_required]} {
			# display READY instead of START, because they have to tap the group head to start, they cannot tap the tablet, due to UL compliance limits
			return [translate "READY"]
		}
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


# TODO: this should probably be renamed.
proc espresso_history_save_from_gui {} {
	set num $::de1(substate)
	set substate_txt $::de1_substate_types($num)
	if {$substate_txt != "ready"} {
		set state [translate "WAIT"]
	} else {
#		if {$::settings(history_saved) != 1} { 
	#		set state [translate "SAVING"] 
		#} else {
		#}; 
		if {[ghc_required]} {
			# display READY instead of START, because they have to tap the group head to start, they cannot tap the tablet, due to UL compliance limits
			set state [translate "READY"]
		} else {
			set state [translate "RESTART"]
		}

	}
	#set state [translate "WAIT"]
	#save_this_espresso_to_history; 
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
		return [subst {< $num [translate "seconds"]}]
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

proc screen_saver_change_minutes {num} {
	if {$num == 0} {
		set ::settings(saver_brightness) 0
		return [translate "Always black"]
	} else {
		return "[translate {Change image every:}] [minutes_text $num]"
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

proc days_text {num} {
	if {$num == 0} {
		return [translate "immediately"]
	} elseif {$num == 30} {
		return [translate "One month"]
	} else {
		return [subst {$num [translate "days"]}]
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



proc check_firmware_update_is_available {} {
	#msg "check_firmware_update_is_available"

	#if {$::settings(ghc_is_installed) != 0} {
		# ok to do v1.3 fw update
		#msg "v1.3 can do fw updates at the moment"
		#if {$::settings(force_fw_update) != 1} {
			#set ::de1(firmware_update_button_label) "Up to date"
			#return ""
		#}
	#} else {
		#msg "No firmware updates at the moment for machines earlier than v1.3 unless forced to do so"
		#if {$::settings(force_fw_update) != 1} {
		#	set ::de1(firmware_update_button_label) "Up to date"
		#	return ""
		#}
	#}

	if {[ifexists ::de1(firmware_crc)] == ""} {
		set ::de1(firmware_crc) [crc::crc32 -filename [fwfile]]
		msg "Firmware [fwfile] CRC is $::de1(firmware_crc)"
	}

	# obsolete method, comparing settings-saved CRC of last fw upload, to what DE1 reports as CRC
	if {($::de1(firmware_crc) != [ifexists ::settings(firmware_crc)]) && $::de1(currently_updating_firmware) == ""} {
		#msg "firmware CRCs are not the same"
		##obsolete - set ::de1(firmware_update_button_label) "Firmware update available"
	} else {
		#msg "firmware CRCs are the same $::de1(firmware_crc) == [ifexists ::settings(firmware_crc)]"
	}

	set ::de1(firmware_update_button_label) "Up to date"

	# new method, directly comparing the incremented version number
	if {[ifexists ::de1(Firmware_file_Version)] != "" && [ifexists ::settings(firmware_version_number)] != ""} {
		if {[ifexists ::de1(Firmware_file_Version)] != [ifexists ::settings(firmware_version_number)]} {
			set ::de1(firmware_update_button_label) "Firmware update available"
		}

	}



	return ""
}

proc firmware_update_eta_label {} {

	if {[info exists ::de1(firmware_update_start_time)] != 1} {
		#msg "firmware_update_eta_label - no ::de1(firmware_update_start_time)"
		return
	}

	set elapsed [expr {[clock milliseconds] - $::de1(firmware_update_start_time)}]
	set ::de1(firmware_update_eta) 0

	set percentage [expr {1.0 * ($::de1(firmware_bytes_uploaded)) / $::de1(firmware_update_size)}]

	if {$percentage >= 1 && $::de1(currently_updating_firmware) == 0} {
		#return "[translate {Turn your machine off and on again}]"
		return ""
	} elseif {$percentage < 0.003 } {
		# not enough data to give a good estimate yet
		return ""
	} else {
		set etamin [expr {round((($elapsed / $percentage) - $elapsed) / 60000)}]
		set etasec [expr {1 + round((($elapsed / $percentage) - $elapsed) / 1000)}]
		if {$etasec >=120} {
			return "$etamin [translate minutes]"
		} else {
			return "$etasec [translate seconds]"
		}
	}	
}


proc firmware_uploaded_label {} {
	#puts "firmware_uploaded_label firmware_uploaded_label"

	#msg "currently_updating_firmware:  $::de1(currently_updating_firmware)/ $::de1(currently_erasing_firmware)"

	if {($::de1(firmware_bytes_uploaded) == 0 || $::de1(firmware_update_size) == 0) && $::de1(currently_updating_firmware) != "1" && $::de1(currently_erasing_firmware) != "1"} {
		if {$::de1(firmware_crc) == [ifexists ::settings(firmware_crc)]} {
			return [translate "No update necessary"]
		}

		return ""
	} 

	if {$::de1(firmware_update_size) == 0 || $::de1(firmware_bytes_uploaded) == 0} {
		return "0.0%"
	}

	set percentage [expr {(100.0 * $::de1(firmware_bytes_uploaded)) / $::de1(firmware_update_size)}]
	#puts "percentage $percentage"
	if {$percentage >= 100 && $::de1(currently_updating_firmware) == 0} {
		#return "[translate {Turn your machine off and on again}]"
		return [translate "Done"]
	} else {
		return "[round_to_one_digits $percentage]%"
	}
}

proc de1_version_bleapi {} {
	array set ver $::de1(version)
	set c [ifexists ver(BLE_APIVersion)]
	if {$c == ""} {
		set c 0
	}
	return $c
}


proc de1_version_string {} {
	array set v $::de1(version)

	#set v(BLE_Sha) [clock seconds]

	#, APP=[package version de1app]	
	set version "BLE v[ifexists v(BLE_Release)].[ifexists v(BLE_Changes)].[ifexists v(BLE_Commits)], API v[ifexists v(BLE_APIVersion)], SHA=[ifexists v(BLE_Sha)]"
	if {[ifexists v(FW_Sha)] != [ifexists v(BLE_Sha)] && [ifexists v(FW_Sha)] != 0} {
		append version "\nFW v[ifexists v(FW_Release)].[ifexists v(FW_Changes)].[ifexists v(FW_Commits)], API v[ifexists v(FW_APIVersion)], SHA=[ifexists v(FW_Sha)]"
	}


	if {$::settings(firmware_sha) != "" && [ifexists v(BLE_Sha)] != "" && $::settings(firmware_sha) != [ifexists v(BLE_Sha)] } {
		after 5000 [list info_page "[translate {Your DE1 firmware has been upgraded}]\n\n$version" [translate "Ok"]]
	}
	
	array set modelarr [list 0 [translate "unknown"] 1 DE1 2 DE1+ 3 DE1PRO 4 DE1XL 5 DE1CAFE]

	set brev ""
	if {[ifexists ::settings(cpu_board_model)] != ""} {
		set brev [expr {$::settings(cpu_board_model) / 1000.0}]
	}
	
	if {$brev != ""} {
		append version ", [translate pcb]=$brev"
	}
	if {[ifexists ::settings(machine_model)] != "" && [ifexists ::settings(machine_model)] != "0"} {
		append version ", [translate model]=[ifexists modelarr([ifexists ::settings(machine_model)])]"
	}

	if {[ifexists ::settings(firmware_version_number)] != ""} {
		append version ", [translate current]=[ifexists ::settings(firmware_version_number)]"
	}
	
	if {[ifexists ::de1(Firmware_file_Version)] != "" && [ifexists ::settings(firmware_version_number)] != "" && [ifexists ::de1(Firmware_file_Version)] != [ifexists ::settings(firmware_version_number)] } {
		append version ", [translate available]=[ifexists ::de1(Firmware_file_Version)]"
	}

	if {[ifexists v(BLE_Sha)] != "" && $::settings(firmware_sha) != [ifexists v(BLE_Sha)] } {
		set ::settings(firmware_sha) $v(BLE_Sha)
		save_settings
	}

	return $version

	#return "HW=[ifexists v(BLEFWMajor)].[ifexists v(BLEFWMinor)].[ifexists v(P0BLECommits)].[ifexists v(Dirty)] API=[ifexists v(APIVersion)] SHA=[ifexists v(BLESha)]"
}

# spreadsheet to calculate this calculated from CAD, from Mark Kelly, and is in /d/admin/src/
proc water_tank_level_to_milliliters {mm} {

	set mm_to_ml [list \
		0 \
		16	\
		43	\
		70	\
		97	\
		124	\
		151	\
		179	\
		206	\
		233	\
		261	\
		288	\
		316	\
		343	\
		371	\
		398	\
		426	\
		453	\
		481	\
		509	\
		537	\
		564	\
		592	\
		620	\
		648	\
		676	\
		704	\
		732	\
		760	\
		788	\
		816	\
		844	\
		872	\
		900	\
		929	\
		957	\
		985	\
		1013	\
		1042	\
		1070	\
		1104	\
		1138	\
		1172	\
		1207	\
		1242	\
		1277	\
		1312	\
		1347	\
		1382	\
		1417	\
		1453	\
		1488	\
		1523	\
		1559	\
		1594	\
		1630	\
		1665	\
		1701	\
		1736	\
		1772	\
		1808	\
		1843	\
		1879	\
		1915	\
		1951	\
		1986	\
		2022	\
		2058	\
	]

	set index [expr {int($mm)}]
	set mm 2058
	catch {
		set mm [lindex $mm_to_ml $index ]
	}
	if {$mm == ""} {
		set mm 2058
	}
	return $mm

}

proc refill_kit_retry_button {} {

	if {$::de1(substate) != 0} {
		return [translate "Touch screen to retry"]
	} else {
		return ""
	}
}

proc return_fan_threshold_calibration {temperature} {

	if {$temperature == 0} {
		return [translate "always on"]		
	}
	return [return_temperature_setting $temperature]
}


proc return_steam_flow_calibration {steam_flow} {
	set in [expr {$steam_flow / 100.0}]

	if {$::settings(enable_fluid_ounces) != 1} {
		return [subst {[round_to_two_digits $in] [translate "mL/s"]}]
	} else {
		return [subst {[round_to_two_digits [ml_to_oz $in]] oz/s}]
	}

}


proc return_steam_heater_calibration {steam_temperature} {

	if {$steam_temperature < 130} {
		return [translate "off"]		
	}
	return [return_temperature_setting $steam_temperature]
}


# obsolete - does not work reliably
proc Restart_app {} {
   #foreach w [winfo children .] {
    ##   destroy $w
   #}
   #source [info script]

	setup_images_for_first_page
	setup_images_for_other_pages
	.can itemconfigure splash -state hidden

	#after $::settings(timer_interval) 
	update_onscreen_variables
	delay_screen_saver
	change_screen_saver_img


#de1_ui_startup

}

foreach p [info procs] { set kpv(p,$p) 1 }
 foreach p [info vars]  { set kpv(v,$p) 1 }
 set kpv(p,bgerror) 1

 #######################################################################
 #
 # Restart
 #
 # Deletes all non-root widgets and all bindings This allows us to
 # reload the source file without getting any errors.
 #
 proc Restart_app {{f ""}} {



#    global kpv tk_version
 
    ;#catch {auto_reset}                        ;# Undo all autoload stuff
    if [info exists tk_version] {               ;# In wish not tclsh
        . config -cursor {}
        eval destroy [winfo children .]         ;# Kill all children windows
  
        foreach v [bind .] {                    ;# Remove all bindings also
            bind . $v {}
        }
        if {$tk_version >= 4.0} {               ;# Kill after events
            catch {foreach v [after info] {after cancel $v}}
        }
        if {$tk_version >= 8} {                 ;# Font stuff
            catch { eval font delete [font names] }
            eval image delete [image names]     ;# Image stuff
        }
        wm geom . {}                            ;# Reset main window geometry
        . config -width 200 -height 200
        raise .
    }
    foreach v [info procs] {                    ;# Remove unwanted procs
        if {[info exists kpv(p,$v)] == 0} {
            catch {rename $v {}}
        }
    }
 #     foreach v [namespace children] {
 #       if {[info exists kpv(n,$v)] == 0} {
 #           catch {namespace delete $v}
 #       }
 #     }
    
    uplevel {                                   ;# Get at global variables 
        foreach _v [info vars] {                ;# Remove unwanted variables
            if {[info exists kpv(v,$_v)] == 0} {;# Part of the core?
                catch {unset $_v}
            }
        }
        catch { unset _v }
    }
    if [file exists $f] {
       # uplevel source $f
    }

    source "de1plus.tcl"
 }



 proc toggle_espresso_steps_option {} {

 	if {[ifexists ::settings(espresso_temperature_steps_enabled)] != 1} {
 		set ::settings(espresso_temperature_steps_enabled) 1 
 	} else {
 		set ::settings(espresso_temperature_steps_enabled) 0 

 	} 		

	msg "Clearing default step temps"
	set ::settings(espresso_temperature_0) $::settings(espresso_temperature)
	set ::settings(espresso_temperature_1) $::settings(espresso_temperature)
	set ::settings(espresso_temperature_2) $::settings(espresso_temperature)
	set ::settings(espresso_temperature_3) $::settings(espresso_temperature)
 	

 	msg "toggle_espresso_steps_option $::settings(espresso_temperature_steps_enabled)"

}

proc round_and_return_step_temperature_setting {varname} {

	if {[ifexists ::settings(espresso_temperature_steps_enabled)] != 1} {
		return ""
	}

	set v [ifexists $varname]
	if {$v == ""} {
		msg "can't find variable $varname in round_and_return_step_temperature_setting"
		return ""
	}

	return [round_and_return_temperature_setting $varname]
}

proc range_check_variable {varname low high} {
	
	#msg "range_check_variable $varname"
	upvar $varname var
	if {$var < $low} {
		msg "variable $varname was under $low"
		set var $low
	}
	if {$var > $high} {
		msg "variable $varname was over $high"
		set var $high
	}
}

proc range_check_shot_variables {} {

	range_check_variable ::settings(espresso_temperature) 0 105
	range_check_variable ::settings(espresso_temperature_0) 0 105
	range_check_variable ::settings(espresso_temperature_1) 0 105
	range_check_variable ::settings(espresso_temperature_2) 0 105
	range_check_variable ::settings(espresso_temperature_3) 0 105
	
	range_check_variable ::settings(preinfusion_time) 0 60
	range_check_variable ::settings(espresso_hold_time) 0 60
	range_check_variable ::settings(preinfusion_flow_rate) 0 $::de1(max_flowrate_v11)
	range_check_variable ::settings(flow_profile_hold) 0 $::de1(max_flowrate_v11)
	range_check_variable ::settings(flow_profile_decline) 0 $::de1(max_flowrate_v11)

	range_check_variable ::settings(preinfusion_stop_pressure) 0 $::de1(maxpressure)

	range_check_variable ::settings(espresso_pressure) 0 $::de1(maxpressure)

	range_check_variable ::settings(espresso_decline_time) 0 60
	range_check_variable ::settings(pressure_end) 0 $::de1(maxpressure)
	range_check_variable ::settings(final_desired_shot_volume) 0 100

	range_check_variable ::settings(final_desired_shot_weight) 0 100
	range_check_variable ::settings(final_desired_shot_weight_advanced) 0 2000
	range_check_variable ::settings(final_desired_shot_volume) 0 2000
	range_check_variable ::settings(final_desired_shot_volume_advanced) 0 2000
	range_check_variable ::settings(final_desired_shot_volume_advanced_count_start) 0 20
	range_check_variable ::settings(tank_desired_water_temperature) 0 60






}

proc change_espresso_temperature {amount} {

	if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} {

		# if step temps are enabled then set the preinfusion start temp to the global temp 
		# and then apply the relative change desired to each subsequent step
		set ::settings(espresso_temperature) [expr {$::settings(espresso_temperature) + $amount}]
		set ::settings(espresso_temperature_0) $::settings(espresso_temperature)			
		set ::settings(espresso_temperature_1) [expr {$::settings(espresso_temperature_1) + $amount}]
		set ::settings(espresso_temperature_2) [expr {$::settings(espresso_temperature_2) + $amount}]
		set ::settings(espresso_temperature_3) [expr {$::settings(espresso_temperature_3) + $amount}]

	} else {
		set ::settings(espresso_temperature) [expr {$::settings(espresso_temperature) + $amount}]
	}

	range_check_shot_variables
}

proc when_to_start_pour_tracking_advanced {} {
	if {$::settings(final_desired_shot_volume_advanced_count_start) > 0} {
		set stepdesc ""
		catch {
			# this should all work, but in case there's something wrong with this logic or the advanced shot, wrap it all in a catch{} so as to not cause an error for such a minor feature
			if {$::settings(final_desired_shot_volume_advanced_count_start) > [llength [ifexists ::settings(advanced_shot)]] } {
				set ::settings(final_desired_shot_volume_advanced_count_start) [llength [ifexists ::settings(advanced_shot)]]
			}

			array set steparr [lindex [ifexists ::settings(advanced_shot)] [expr {-1 + $::settings(final_desired_shot_volume_advanced_count_start)}]]
			set stepdesc [ifexists steparr(name)]
		}
		return [subst {[translate "After step"] $::settings(final_desired_shot_volume_advanced_count_start) - $stepdesc}]
	} else {
		return [translate "Immediately"]
	}
}
