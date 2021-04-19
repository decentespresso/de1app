package provide swdark2_functions 1.0

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

proc swdark2_filename {} {
    set fn "[skin_directory]/userdata/swdark2_usersettings.tdb"
    return $fn
}

proc append_file_obsolete {swdark2_filename data} {
    set success 0
    set errcode [catch {
        set fn [open $swdark2_filename a]
        puts $fn $data
        close $fn
        set success 1
    }]
    if {$errcode != 0} {
        msg "append_file $::errorInfo"
    }
    return $success
}

proc save_swdark2_array_to_file {arrname fn} {
    upvar $arrname item
    set swdark2_data {}
    foreach k [lsort -dictionary [array names item]] {
        set v $item($k)
        append swdark2_data [subst {[list $k] [list $v]\n}]
    }
    write_file $fn $swdark2_data
}

proc save_swdark2_settings {} {
    msg "saving settings"
    save_swdark2_array_to_file ::swdark2_settings [swdark2_filename]
}

proc load_swdark2_settings {} {
    array set ::swdark2_settings [encoding convertfrom utf-8 [read_binary_file [swdark2_filename]]]
}


proc skale_display_toggle {} {
    set ::swdark2_settings(skale_display_state_b) $::swdark2_settings(skale_display_state)
    if {$::swdark2_settings(skale_display_state_b) == "."} {
        set ::swdark2_settings(skale_display_state) " "
        save_swdark2_settings
        skale_disable_lcd
        } else {
        set ::swdark2_settings(skale_display_state) "."
        skale_enable_lcd
        save_swdark2_settings
        }
}

proc scale_display_toggle {} {
    set ::swdark2_settings(scale_display_state_b) $::swdark2_settings(scale_display_state)
    if {$::swdark2_settings(scale_display_state_b) == "."} {
        set ::swdark2_settings(scale_display_state) " "
        save_swdark2_settings
        scale_disable_lcd
        } else {
        set ::swdark2_settings(scale_display_state) "."
        scale_enable_lcd
        save_swdark2_settings
        }
}


proc stopatweight {} {
    if {$::settings(settings_profile_type) == "settings_2c"} {
    set ::stopatweight $::settings(final_desired_shot_weight_advanced)g
    } else {
    set ::stopatweight $::settings(final_desired_shot_weight)g
    }
}


proc swdark_setyaxis {} {
	set var ::swdark2_settings(sw_y_axisscale)
    if {[info exists $var]} {
	} else {
		set myList {0 1 3 5 7 9 11 13 15 17 19}
		if {[lsearch -exact $myList $::settings(zoomed_y_axis_scale)] >= 0} {
		set ::swdark2_settings(sw_y_axisscale) 12
		save_swdark2_settings
		} else {
		set ::swdark2_settings(sw_y_axisscale) $::settings(zoomed_y_axis_scale)
		save_swdark2_settings
		}
	}
}