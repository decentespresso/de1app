package provide swdark_functions 4.0

proc horizontal_clicker {bigincrement smallincrement varname minval maxval x y x0 y0 x1 y1} {
	set xrange [expr {$x1 - $x0}]
	set xoffset [expr {$x - $x0}]
	set midpoint [expr {$x0 + ($xrange / 2)}]
	set onequarterpoint [expr {$x0 + ($xrange / 5)}]
	set threequarterpoint [expr {$x1 - ($xrange / 5)}]
	if {[info exists $varname] != 1} {
		# if the variable doesn't yet exist, initiialize it with a zero value
		set $varname 0
	}
	set currentval [subst \$$varname]
	set newval $currentval
	if {$x < $onequarterpoint} {
		set newval [expr "1.0 * \$$varname - $bigincrement"]
	} elseif {$x < $midpoint} {
		set newval [expr "1.0 * \$$varname - $smallincrement"]
	} elseif {$x < $threequarterpoint} {
		set newval [expr "1.0 * \$$varname + $smallincrement"]
	} else {
		set newval [expr "1.0 * \$$varname + $bigincrement"]
	}
	set newval [round_to_two_digits $newval]
	if {$newval > $maxval} {
		set $varname $maxval
	} elseif {$newval < $minval} {
		set $varname $minval
	} else {
		set $varname [round_to_two_digits $newval]
	}
	update_onscreen_variables
	return
}

proc swdark_filename {} {
    set fn "[skin_directory]/userdata/swdark_usersettings.tdb"
    return $fn
}

proc append_file {swdark_filename data} {
    set success 0
    set errcode [catch {
        set fn [open $swdark_filename a]
        puts $fn $data
        close $fn
        set success 1
    }]
    if {$errcode != 0} {
        msg "append_file $::errorInfo"
    }
    return $success
}

proc save_swdark_array_to_file {arrname fn} {
    upvar $arrname item
    set swdark_data {}
    foreach k [lsort -dictionary [array names item]] {
        set v $item($k)
        append swdark_data [subst {[list $k] [list $v]\n}]
    }
    write_file $fn $swdark_data
}

proc save_swdark_settings {} {
    save_swdark_array_to_file ::swdark_settings [swdark_filename]
}

proc load_swdark_settings {} {
    array set ::swdark_settings [encoding convertfrom utf-8 [read_binary_file [swdark_filename]]]
}


proc skale_display_toggle {} {
    set ::swdark_settings(skale_display_state_b) $::swdark_settings(skale_display_state)
    if {$::swdark_settings(skale_display_state_b) == "."} {
        set ::swdark_settings(skale_display_state) " "
        save_swdark_settings
        skale_disable_lcd
        } else {
        set ::swdark_settings(skale_display_state) "."
        skale_enable_lcd
        save_swdark_settings
        }
}

proc scale_display_toggle {} {
    set ::swdark_settings(scale_display_state_b) $::swdark_settings(scale_display_state)
    if {$::swdark_settings(scale_display_state_b) == "."} {
        set ::swdark_settings(scale_display_state) " "
        save_swdark_settings
        scale_disable_lcd
        } else {
        set ::swdark_settings(scale_display_state) "."
        scale_enable_lcd
        save_swdark_settings
        }
}


proc stopatweight {} {
    if {$::settings(settings_profile_type) == "settings_2c"} {
    set ::stopatweight $::settings(final_desired_shot_weight_advanced)g
    } else {
    set ::stopatweight $::settings(final_desired_shot_weight)g
    }
}

# sets a variable to enable swsettings page to update the correct stop at weight value
proc swweighttype2 {} {
if {[ifexists ::settings(settings_profile_type)] == "settings_2c"} {
	set ::swdark_settings(swweighttype) "::settings(final_desired_shot_weight_advanced)"
} else {
	set ::swdark_settings(swweighttype) "::settings(final_desired_shot_weight)"
}
}

#Returns correct weight value for SWSettings page
proc swreturnweight {} {
if {[ifexists ::settings(settings_profile_type)] == "settings_2c"} {
	return [round_to_integer $::settings(final_desired_shot_weight_advanced)]
} else {
	return [round_to_integer $::settings(final_desired_shot_weight)]
}
}

#Updates the brew ratio in SWSettings when weight is updated
proc updateswbrewratio2 {} {
	if {[ifexists ::settings(settings_profile_type)] == "settings_2c"} {
		set ::swdark_settings(swbrewratio) [round_to_one_digits [expr $::settings(final_desired_shot_weight_advanced) / $::swdark_settings(swcoffeedose)]]
	} else {
		set ::swdark_settings(swbrewratio) [round_to_one_digits [expr $::settings(final_desired_shot_weight) / $::swdark_settings(swcoffeedose)]]
	}
}

#Updates the brew ratio in SWSettings when dose/ratio are updated
proc updateswbrewratio {} {
	save_swdark_settings
	if {[ifexists ::settings(settings_profile_type)] == "settings_2c"} {
		set ::settings(final_desired_shot_weight_advanced) [expr $::swdark_settings(swcoffeedose) * $::swdark_settings(swbrewratio)]
	} else {
		set ::settings(final_desired_shot_weight) [expr $::swdark_settings(swcoffeedose) * $::swdark_settings(swbrewratio)]
	}
}


#Set the target weight depending on Profile Type std/adv - used as a variable in the data tab to ensure value is uptodate

		proc update_swcoffeeweight {} {
			if {[ifexists ::settings(settings_profile_type)] == "settings_2c"} {
				return $::settings(final_desired_shot_weight_advanced)
			} else {
				return $::settings(final_desired_shot_weight)
			}
		}
		
#Used to ensure espresso target temp is uptodate on data tab, really needs updating to check C vs F temp setting
proc update_swcoffeetemp {} {
	return [round_to_integer $::settings(espresso_temperature)][translate "\u00BAC"]
	}
	
#used to recalculate the brew ration when weight is altered in main settings
proc swautoupdateratio {} {
if {[ifexists ::settings(settings_profile_type)] == "settings_2c"} {
	if {$::swdark_settings(swbrewratio) != [round_to_one_digits [expr $::settings(final_desired_shot_weight_advanced) / $::swdark_settings(swcoffeedose)]]} {
		add_de1_variable "off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" 3000 3000 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[updateswbrewratio2]}	
	} else {}
} else {
	if {$::swdark_settings(swbrewratio) != [round_to_one_digits [expr $::settings(final_desired_shot_weight) / $::swdark_settings(swcoffeedose)]]} {
		add_de1_variable "off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" 3000 3000 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[updateswbrewratio2]}
	} else {}
}
}








proc append_live_data_to_espresso_chart {} {
    if {$::de1_num_state($::de1(state)) == "Steam"} {
		if {$::de1(substate) == $::de1_substate_types_reversed(pouring) || $::de1(substate) == $::de1_substate_types_reversed(preinfusion)} {
		#puts "append_live_data_to_espresso_chart $::de1(pressure)"
			steam_pressure append [round_to_two_digits $::de1(pressure)]
			steam_flow append [round_to_two_digits $::de1(flow)]
			steam_temperature append [round_to_two_digits [expr {$::de1(steam_heater_temperature)/100.0}]]
			#set millitime [steam_pour_timer]
			steam_elapsed append  [expr {[steam_pour_millitimer]/1000.0}]
		}
    	return
    } elseif {$::de1_num_state($::de1(state)) != "Espresso"} {
    	# we only store chart data during espresso
    	# we could theoretically store this data during steam as well, if we want to have charts of steaming temperature and pressure
    	return 
    }

#@	global previous_de1_substate
	#global state_change_chart_value

  	if {$::de1(substate) == $::de1_substate_types_reversed(pouring) || $::de1(substate) == $::de1_substate_types_reversed(preinfusion)} {
		# to keep the espresso charts going
		#if {[millitimer] < 500} { 
		  # need to make sure we don't append data from an earlier time, as that destroys the chart
		 # return
		#}

		#if {[espresso_elapsed length] > 0} {
		  #if {[espresso_elapsed range end end] > [expr {[millitimer]/1000.0}]} {
			#puts "discarding chart data after timer reset"
			#clear_espresso_chart
			#return
		  #}
		#}

		set millitime [espresso_millitimer]

		if {$::de1(substate) == 4 || $::de1(substate) == 5} {

			set mtime [expr {$millitime/1000.0}]
			set last_elapsed_time_index [expr {[espresso_elapsed length] - 1}]
			set last_elapsed_time 0
			if {$last_elapsed_time_index >= 0} {
				set last_elapsed_time [espresso_elapsed range $last_elapsed_time_index $last_elapsed_time_index]
			}
			#puts "last_elapsed_time: $mtime / $last_elapsed_time"

			if {$mtime > $last_elapsed_time} {
				# this is for handling cases where a god shot has already loaded a time axis
				espresso_elapsed append $mtime
			}

			if {$::de1(scale_weight) == ""} {
				set ::de1(scale_weight) 0
			}
			espresso_weight append [round_to_two_digits $::de1(scale_weight)]
			espresso_weight_chartable append [round_to_two_digits [expr {0.10 * $::de1(scale_weight)}]]

			espresso_pressure append [round_to_two_digits $::de1(pressure)]
			espresso_flow append [round_to_two_digits $::de1(flow)]
			espresso_flow_2x append [round_to_two_digits [expr {2.0 * $::de1(flow)}]]

			if {$::de1(scale_weight_rate) != ""} {
				# if a bluetooth scale is recording shot weight, graph it along with the flow meter
				espresso_flow_weight append [round_to_two_digits $::de1(scale_weight_rate)]
				espresso_flow_weight_2x append [expr {2.0 * [round_to_two_digits $::de1(scale_weight_rate)] }]
			}

			#set elapsed_since_last [expr {$millitime - $::previous_espresso_flow_time}]
			#puts "elapsed_since_last: $elapsed_since_last"
			#set flow_delta [expr { 10 * ($::de1(flow)  - $::previous_espresso_flow) }]
			set flow_delta [diff_flow_rate]
			set negative_flow_delta_for_chart 0


			if {$::de1(substate) == $::de1_substate_types_reversed(preinfusion)} {				
				# don't track flow rate delta during preinfusion because the puck is absorbing water, and so the numbers aren't useful (likely just pump variability)
				set flow_delta 0
			}

			if {$flow_delta > 0} {

			    if {$::settings(enable_negative_flow_charts) == 1} {
					# experimental chart from the top
					set negative_flow_delta_for_chart [expr {6.0 - (10.0 * $flow_delta)}]
					set negative_flow_delta_for_chart_2x [expr {12.0 - (10.0 * $flow_delta)}]
					espresso_flow_delta_negative append $negative_flow_delta_for_chart
					espresso_flow_delta_negative_2x append $negative_flow_delta_for_chart_2x
				}

				espresso_flow_delta append 0
				#puts "negative flow_delta: $flow_delta ($negative_flow_delta_for_chart)"
			} else {
				espresso_flow_delta append [expr {abs(10*$flow_delta)}]

			    if {$::settings(enable_negative_flow_charts) == 1} {
					espresso_flow_delta_negative append 6
					espresso_flow_delta_negative_2x append 12
					#puts "flow_delta: $flow_delta ($negative_flow_delta_for_chart)"
				}
			}

			set pressure_delta [diff_pressure]
			espresso_pressure_delta append [expr {abs ($pressure_delta) / $millitime}]

			set ::previous_espresso_flow $::de1(flow)
			set ::previous_espresso_pressure $::de1(pressure)

			espresso_temperature_mix append [return_temperature_number $::de1(mix_temperature)]
			espresso_temperature_basket append [return_temperature_number $::de1(head_temperature)]
			espresso_state_change append $::state_change_chart_value

			set ::previous_espresso_flow_time $millitime

			# don't chart goals at zero, instead take them off the chart
			if {$::de1(goal_flow) == 0} {
				espresso_flow_goal append "-1"
				espresso_flow_goal_2x append "-1"
			} else {
				espresso_flow_goal append $::de1(goal_flow)
				espresso_flow_goal_2x append [expr {2.0 * $::de1(goal_flow)}]
			}

			# don't chart goals at zero, instead take them off the chart
			if {$::de1(goal_pressure) == 0} {
				espresso_pressure_goal append "-1"
			} else {
				espresso_pressure_goal append $::de1(goal_pressure)
			}

			espresso_temperature_goal append [return_temperature_number $::de1(goal_temperature)]


		}
  	}
}