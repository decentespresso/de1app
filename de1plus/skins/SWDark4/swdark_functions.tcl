package provide swdark_functions 4.0

proc horizontal_clicker {bigincrement smallincrement varname minval maxval inx iny x0 y0 x1 y1} {

	set x [translate_coordinates_finger_down_x $inx]
	set y [translate_coordinates_finger_down_y $iny]

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

proc append_file_obs {swdark_filename data} {
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

proc swdark4varscheck {} {
	set var ::swdark_settings(swstopatvol)
    if {[info exists $var]} {
    } else {
        set $var [round_to_integer $::settings(final_desired_shot_volume)]
		save_swdark_settings
    }
	set var ::swdark_settings(swstopatvoladv)
    if {[info exists $var]} {
    } else {
        set $var [round_to_integer $::settings(final_desired_shot_volume_advanced)]
		save_swdark_settings
    }
	set var ::swdark_settings(swvoltype)
    if {[info exists $var]} {
    } else {
		if {[ifexists ::settings(settings_profile_type)] == "settings_2c"} {
			set ::swdark_settings(swvoltype) "::settings(final_desired_shot_volume_advanced)"
		} else {
			set ::swdark_settings(swvoltype) "::settings(final_desired_shot_volume)"
		}
		save_swdark_settings
    }
	set var ::swdark_settings(swbrewsettings)
    if {[info exists $var]} {
    } else {
		set ::swdark_settings(swbrewsettings) "0"
		save_swdark_settings
    }
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


proc swvoltype2 {} {
if {[ifexists ::settings(settings_profile_type)] == "settings_2c"} {
	set ::swdark_settings(swvoltype) "::settings(final_desired_shot_volume_advanced)"
} else {
	set ::swdark_settings(swvoltype) "::settings(final_desired_shot_volume)"
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


proc updateswbrewvol {} {
	if {[ifexists ::settings(settings_profile_type)] == "settings_2c"} {
		set ::swdark_settings(swstopatvoladv) [round_to_integer $::settings(final_desired_shot_volume_advanced)]
	} else {
		set ::swdark_settings(swstopatvol) [round_to_integer $::settings(final_desired_shot_volume)]
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

#Set the target volume depending on Profile Type std/adv - used as a variable in the data tab to ensure value is uptodate
		proc update_swcoffeevolume {} {
			if {[ifexists ::settings(settings_profile_type)] == "settings_2c"} {
				return $::settings(final_desired_shot_volume_advanced)
			} else {
				return $::settings(final_desired_shot_volume)
			}
		}

		
#Used to ensure espresso target temp is uptodate on data tab, really needs updating to check C vs F temp setting
proc update_swcoffeetemp {} {
	return [return_temperature_measurement [round_to_integer $::settings(espresso_temperature)]]
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


proc swdark_setyaxis {} {
	set var ::swdark_settings(sw_y_axisscale)
    if {[info exists $var]} {
	} else {
		set myList {0 1 3 5 7 9 11 13 15 17 19}
		if {[lsearch -exact $myList $::settings(zoomed_y_axis_scale)] >= 0} {
		set ::swdark_settings(sw_y_axisscale) 12
		save_swdark_settings
		} else {
		set ::swdark_settings(sw_y_axisscale) $::settings(zoomed_y_axis_scale)
		save_swdark_settings
		}
	}
}

#Code by Damian - Thanks
proc DSx_next_step {} {
    de1_send_state "skip to next" $::de1_state(SkipToNext)
}
