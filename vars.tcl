# de1 internal state live variables
package provide de1_vars 1.0

#############################
# raw data from the DE1

proc clear_espresso_chart {} {
	espresso_elapsed append 0
	espresso_elapsed length 0
	espresso_pressure length 0
	espresso_flow length 0
	espresso_flow_2x length 0
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
	#puts "clearing timers"
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
	return [event_timer_calculate "Espresso" "preinfusion" {"stabilising" "final heating" "heating"} ]
}


proc pour_timer {} {
	return [event_timer_calculate "Espresso" "pouring" {"preinfusion" "stabilising" "final heating" "heating"} ]
}


proc steam_timer {} {
	return [event_timer_calculate "Steam" "pouring" {"stabilising" "final heating"} ]
}

proc water_timer {} {
	return [event_timer_calculate "HotWater" "pouring" {"stabilising" "final heating"} ]
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


		set ::de1(flow) [expr {rand() + $::de1(flow) - 0.5}]
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

		set ::de1(head_temperature) [expr {rand() + $::de1(head_temperature) - 0.5}]
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


		set ::de1(pressure) [expr {rand() + $::de1(pressure) - 0.5}]
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
	#if {$::android == 0} {
		#set ::de1(head_temperature) [expr {80 + (rand() * 15.0)}]
	#}

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
		return [subst {[round_to_integer $in] [translate "ml"]}]
	} else {
		return [subst {[round_to_integer [ml_to_oz $in]] oz}]
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


proc espresso_goal_temp_text {} {
	return [return_temperature_measurement $::de1(goal_temperature)]
}

proc diff_brew_temp_from_goal {} {
	set diff [expr {[water_mix_temperature] - $::de1(goal_temperature)}]
	return $diff
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

proc diff_flow_rate {} {
	if {$::android == 0} {
		return [expr {3 - (rand() * 6)}]
	}

	return $::de1(flow_delta)
	#return [round_to_one_digits $::de1(flow_delta)]
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
	return [subst {[commify [round_to_two_digits [pressure]]] [translate "bar"]}]
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
	return [expr {round( $::settings(water_max_time) )}]
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
			return [subst {[round_to_one_digits [celsius_to_fahrenheit $in]]ºF}]
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


proc return_delta_temperature_measurement {in} {
	if {$::settings(enable_fahrenheit) == 1} {
		set t [subst {[round_to_one_digits [celsius_to_fahrenheit $in]]ºF}]
	} else {
		set t [subst {[round_to_one_digits $in]ºC}]
	}

	if {$in > 0} {
		set t "+$t"
	}
	return $t
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

proc fill_skin_listbox {widget} {
	#puts "fill_skin_listbox $widget" 
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

	bind $widget <<ListboxSelect>> [list ::preview_tablet_skin %W] 	

	set ::globals(tablet_styles_listbox) $widget
	preview_tablet_skin $widget

	#make_current_listbox_item_blue $widget
}


proc make_current_listbox_item_blue { widget } {

	for {set x 0} {$x < [$widget index end]} {incr x} {
		if {$x == [$widget curselection]} {
			#puts "x: $x"
			$widget itemconfigure $x -foreground #000000 -selectforeground #000000

		} else {
			$widget itemconfigure $x -foreground #b2bad0
		}
	}

}


proc profile_directories {} {
	set dirs [lsort -dictionary [glob -tails -directory "[homedir]/profiles/" *.tcl]]
	set dd {}
	set de1plus [de1plus]
	foreach d $dirs {
		#if {$d == "CVS" || $d == "example"} {
		#	continue
		#}

	    if {[string first "settings_profile_type settings_profile_flow" [read_file "[homedir]/profiles/$d"]] != -1} {
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
	fill_profiles_listbox $::globals(profiles_listbox)
	preview_profile $::globals(profiles_listbox)

}



proc fill_ble_listbox {widget} {

	#puts "fill_profiles_listbox $widget"
	#set ::settings(profile_to_save) $::settings(profile)

	$widget delete 0 99999
	set cnt 0
	set current_ble_number 0
	set ble_ids [list "C1:80:A7:32:CD:A3" "C5:80:EC:A5:F9:72" "F2:C3:43:60:AB:F5"]
	foreach d [lsort -dictionary -increasing $ble_ids] {
		$widget insert $cnt $d
		if {[ifexists ::settings(de1_address)] == $d} {
			set current_ble_number $cnt
			#puts "current profile of '$d' is #$cnt"
		}
		incr cnt
	}
	
	#$widget itemconfigure $current_profile_number -foreground blue
	$widget selection set $current_ble_number;

	#$widget selection set 3
	#puts "$widget selection set $current_profile_number"

	set ::globals(ble_listbox) $widget
	
	# john - probably makes sense for "pair" to occur on item tap
	#bind $widget <<ListboxSelect>> [list ::preview_profile %W] 	
	make_current_listbox_item_blue $widget
}


proc fill_profiles_listbox {widget} {

	#puts "fill_profiles_listbox $widget"
	set ::settings(profile_to_save) $::settings(profile)

	$widget delete 0 99999
	set cnt 0
	set current_profile_number 0
	foreach d [lsort -dictionary -increasing [profile_directories]] {
		if {$d == "CVS" || $d == "example"} {
			continue
		}
		$widget insert $cnt $d
		if {$::settings(profile) == $d} {
			set current_profile_number $cnt
			#puts "current profile of '$d' is #$cnt"
		}

		if {[ifexists ::de1plus_profile($d)] == 1} {
			# mark profiles that require the DE1PLUS model with a different color to highlight them
			#puts "de1plus skin: $d"
			$widget itemconfigure $cnt -background #F0F0FF
		}

		incr cnt
	}
	
	#$widget itemconfigure $current_profile_number -foreground blue
	$widget selection set $current_profile_number;

	#$widget selection set 3
	#puts "$widget selection set $current_profile_number"

	set ::globals(profiles_listbox) $widget
	bind $widget <<ListboxSelect>> [list ::preview_profile %W] 	
	make_current_listbox_item_blue $widget
	#::preview_profile $widget

		#if {[de1plus]} {
			#set_next_page off "$::settings(settings_profile_type)_preview"; #page_show off
			#set_next_page settings_2 "$::settings(settings_profile_type)_preview"; #page_show off
			#page_show off
		#}

#		if {$::settings(settings_profile_type) == "settings_profile_pressure"} {
	#		set_next_page settings_2 "settings_2"; #page_show off
		#} elseif {$::settings(settings_profile_type) == "settings_profile_flow"} {
		#	set_next_page settings_2 "settings_2a"; #page_show off
		#}

}



proc fill_profile_steps_listbox {widget} {

	#puts "fill_profiles_listbox $widget"
	#set ::settings(profile_to_save) $::settings(profile)

	$widget delete 0 99999
	set cnt 0
	set current_profile_number 0


	set steps [list  "Preinfusion" "Hold" "Decline"]

	foreach d $steps {
		#if {$d == "CVS" || $d == "example"} {
		#	continue
		#}
		$widget insert $cnt $d
		if {$::settings(profile) == $d} {
			set current_profile_number $cnt
			#puts "current profile of '$d' is #$cnt"
		}

		if {[ifexists ::de1plus_profile($d)] == 1} {
			# mark profiles that require the DE1PLUS model with a different color to highlight them
			#puts "de1plus skin: $d"
			$widget itemconfigure $cnt -background #F0F0FF
		}

		incr cnt
	}
	
	#$widget itemconfigure $current_profile_number -foreground blue
	$widget selection set $current_profile_number;

	#$widget selection set 3
	#puts "$widget selection set $current_profile_number"

	set ::globals(widget_profile_step_name) $widget
	bind $widget <<ListboxSelect>> [list ::preview_profile_step %W] 	
	make_current_listbox_item_blue $widget
	#::preview_profile $widget

		#if {[de1plus]} {
			#set_next_page off "$::settings(settings_profile_type)_preview"; #page_show off
			#set_next_page settings_2 "$::settings(settings_profile_type)_preview"; #page_show off
			#page_show off
		#}

#		if {$::settings(settings_profile_type) == "settings_profile_pressure"} {
	#		set_next_page settings_2 "settings_2"; #page_show off
		#} elseif {$::settings(settings_profile_type) == "settings_profile_flow"} {
		#	set_next_page settings_2 "settings_2a"; #page_show off
		#}

}
proc save_new_tablet_skin_setting {} {
	set ::settings(skin) [$::globals(tablet_styles_listbox) get [$::globals(tablet_styles_listbox) curselection]]
	#puts "skin changed to '$::settings(skin)'"
}

proc preview_tablet_skin {w args} {
	catch {
		set skindir [$w get [$w curselection]]
		set ::settings(skin) $skindir
		#set ::settings(skin)
		set fn "[homedir]/skins/$skindir/${::screen_size_width}x${::screen_size_height}/icon.jpg"
		$::table_style_preview_image read $fn
		make_current_listbox_item_blue $::globals(tablet_styles_listbox)
	}
}


proc preview_profile_step {w args} {
	catch {

		#set ::settings(profile) [$::globals(profiles_listbox) get [$::globals(profiles_listbox) curselection]]
		set profile_step [$w get [$w curselection]]
		set ::settings(profile_step) $profile_step
		#set fn "[homedir]/profiles/${profile}.tcl"
		#puts "preview_profile $profile"

			# for importing De1 profiles that don't have this feature.
		#set ::settings(preinfusion_flow_rate) 4

		#load_settings_vars $fn
		#fill_profiles_listbox $::globals(profiles_listbox)
		#set ::settings(profile_to_save) $::settings(profile)

		make_current_listbox_item_blue $::globals(widget_profile_step_name)

		#if {[de1plus]} {
			#puts "current context: $::de1(current_context) "

			#set_next_page settings_2 $::settings(settings_profile_type)_preview;
			#page_show settings_2

			#set_next_page off "$::settings(settings_profile_type)_preview"; #page_show off
			#page_show off
			#puts "set_next_page off $::settings(settings_profile_type)_preview;"
		#} else {
		#	set ::settings(settings_profile_type) "settings_1"
		#}
		update_onscreen_variables

		#if {$::settings(settings_profile_type) == "settings_profile_pressure"} {
		#	set_next_page off "settings_2"; #page_show off
		#} elseif {$::settings(settings_profile_type) == "settings_profile_flow"} {
	#		set_next_page off "settings_2a"; #page_show off
	#	}

	}
}

proc preview_profile {w args} {
	catch {
		#set ::settings(profile) [$::globals(profiles_listbox) get [$::globals(profiles_listbox) curselection]]
		set profile [$w get [$w curselection]]
		set ::settings(profile) $profile
		set fn "[homedir]/profiles/${profile}.tcl"
		#puts "preview_profile $profile"

			# for importing De1 profiles that don't have this feature.
		set ::settings(preinfusion_flow_rate) 4

		load_settings_vars $fn
		#fill_profiles_listbox $::globals(profiles_listbox)
		set ::settings(profile_to_save) $::settings(profile)

		make_current_listbox_item_blue $::globals(profiles_listbox)

		if {[de1plus]} {
			#puts "current context: $::de1(current_context) "

			set_next_page settings_2 $::settings(settings_profile_type)_preview;
			page_show settings_2

			#set_next_page off "$::settings(settings_profile_type)_preview"; #page_show off
			#page_show off
			#puts "set_next_page off $::settings(settings_profile_type)_preview;"
		} else {
			set ::settings(settings_profile_type) "settings_1"
		}
		update_onscreen_variables

		#if {$::settings(settings_profile_type) == "settings_profile_pressure"} {
		#	set_next_page off "settings_2"; #page_show off
		#} elseif {$::settings(settings_profile_type) == "settings_profile_flow"} {
	#		set_next_page off "settings_2a"; #page_show off
	#	}

	}
}

proc load_settings_vars {fn} {
	
	# set the default profile type to use, this can be over-ridden by the saved profile
	if {[de1plus]} {
		set ::settings(settings_profile_type) "settings_profile_pressure"
	} else {
		set ::settings(settings_profile_type) "settings_1"
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

    write_file $fn $txt
}

proc save_profile {} {
	if {$::settings(profile_to_save) == [translate "Saved"]} {
		return
	}

	set profile_vars { espresso_hold_time preinfusion_time espresso_pressure pressure_hold_time espresso_decline_time pressure_end espresso_temperature settings_profile_type flow_profile_preinfusion flow_profile_preinfusion_time flow_profile_hold flow_profile_hold_time flow_profile_decline flow_profile_decline_time flow_profile_minimum_pressure preinfusion_flow_rate}
	set profile_name_to_save $::settings(profile_to_save) 
	#puts "save profile: $profile_name_to_save"
	set fn "[homedir]/profiles/${profile_name_to_save}.tcl"
	save_settings_vars $fn $profile_vars
	set ::settings(profile) $profile_name_to_save
	fill_profiles_listbox $::globals(profiles_listbox)
	update_de1_explanation_chart
	set ::settings(profile_to_save) [translate "Saved"]
	after 1000 {
		set ::settings(profile_to_save) $::settings(profile)
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

