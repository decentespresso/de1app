package provide de1_gui 1.0
package require de1_plugins 1.0

proc load_skin {} {

	# optional callback for skins, which is reset to normal always, before loading the skin
	eval {
		proc skins_page_change_due_to_de1_state_change { textstate } {
			page_change_due_to_de1_state_change $textstate
		}
	}

	if {[catch {
		source "[skin_directory]/skin.tcl"
	} err] != 0} {
		catch {
			# reset the skin back to default, if their skin failed to load correctly
			# but don't do so if ::debugging flag is enabled
			if {[ifexists ::debugging] != 1} {
				reset_skin
			}
		}
		catch {
			message_page [subst {[translate "Your choice of skin had an error and cannot be used."]\n\n$err}] [translate "Ok"]
		}
		msg "Failed to 'load_skin' because: '$err'"
		after 10000 exit
	}

}

proc setup_images_for_other_pages {} {
	borg spinner on
	load_skin
	borg spinner off
    borg systemui $::android_full_screen_flags
	return
}


proc chart_refresh {} {

}


proc Double2Fraction { dbl {eps 0.000001}} {
    for {set den 1} {$den<1024} {incr den} {
        set num [expr {round($dbl*$den)}]
        if {abs(double($num)/$den - $dbl) < $eps} break
    }
    list $num $den
}

proc photoscale {img sx {sy ""} } {

	if {($::android == 1 && $::undroid != 1)} {
		#photoscale_not_android $img $sx $sy
		photoscale_android $img $sx $sy
	} elseif {$::undroid == 1} {
		# no undroid support for this yet
		photoscale_android $img $sx $sy
		#photoscale_not_android $img $sx $sy
	} else {
		photoscale_not_android $img $sx $sy
	}
}

proc photoscale_not_android {img sx {sy ""} } {
	msg "photoscale $img $sx $sy"
    if { $sx == 1 && ($sy eq "" || $sy == 1) } {
        return;   # Nothing to do!
    }
    
    foreach {sx_m sx_f} [Double2Fraction $sx] break
    if { $sy eq "" } {
        foreach {sy sy_x sy_f} [list $sx $sx_m $sx_f] break;  # Multi-set!
    } else {
        foreach {sy_m sy_f} [Double2Fraction $sy] break
    }
    set tmp [image create photo]
    $tmp copy $img -zoom $sx_m $sy_m -compositingrule set
    $img blank
    $img copy $tmp -shrink -subsample $sx_f $sy_f -compositingrule set
    image delete $tmp
}


proc photoscale_android {img sx {sy ""} } {
	msg "photoscale $img $sx $sy"
    if { $sx == 1 && ($sy eq "" || $sy == 1) } {
        return;   # Nothing to do!
    }
    

    # create a new tmp image
    set tmp [image create photo]

    # resize to the tmp image
    $tmp copy $img -scale $sx $sy

    # recreate the original image and copy the tmp over it
	image delete $img
	image create photo $img
    $img copy $tmp

    # clean up
    image delete $tmp
}

proc add_de1_page {names filename {skin ""} } {

	set ::settings(preload_all_page_images) 0

	if {$skin == ""} {
		set skin $::settings(skin)
	}

	set pngfilename "[homedir]/skins/$skin/${::screen_size_width}x${::screen_size_height}/$filename"
	set srcfilename "[homedir]/skins/$skin/2560x1600/$filename"

	set make_new_image 0
	if {$::screen_size_width == 1280 && $::screen_size_height == 800} {
		# no redoing, as these are shipping with the app
	} elseif {$::screen_size_width == 2560 && $::screen_size_height == 1600} {
		# no redoing, as these are shipping with the app
	} elseif {[file exists $pngfilename] != 1} {
		set make_new_image 1
		msg "Making new image because destination image does not exist: $pngfilename"
	} elseif {[file mtime $srcfilename] > [file mtime $pngfilename]} {
		# if the source image is newer than the target image, 
		set make_new_image 1
		msg "Making new image because date of src image is newer: $srcfilename"
	}

	if {$make_new_image == 1} {
        borg toast [subst {[translate "Resizing image"]\n\n[file tail $filename]}]
		borg spinner on
    	catch {
    		file mkdir "[homedir]/skins/$skin/${::screen_size_width}x${::screen_size_height}/"
    	}


        set rescale_images_x_ratio [expr {$::screen_size_height / 1600.0}]
        set rescale_images_y_ratio [expr {$::screen_size_width / 2560.0}]

		#msg "photoscale $names $::rescale_images_x_ratio $::rescale_images_y_ratio"
		image create photo $names -file $srcfilename
		photoscale $names $rescale_images_y_ratio $rescale_images_x_ratio
		borg spinner off
		$names write $pngfilename  -format {jpeg -quality 90}
		image delete $names

	} else {
		if {$::settings(preload_all_page_images) == 1} {
			set iname [image create photo $names -file $pngfilename]
			msg "loading page: '$names' with image '$pngfilename' with tclname: '$iname'"
			#image create photo $names 			$names -file $pngfilename
		}
	}

	#.can create image {0 0} -anchor nw -image $names -tag [list pages $name] -state hidden 
	foreach name $names {
		.can create image {0 0} -anchor nw  -tag [list pages $name] -state hidden 
		if {$::settings(preload_all_page_images) == 1} {
			#.can itemconfigure $names -image $names 
			.can itemconfigure $name -image $names
		} else {
			set ::delayed_image_load($name) $pngfilename
		}
	}

	#set ::image_to_page($pngfilename) $names
}	

proc set_de1_screen_saver_directory {{dirname {}}} {

	msg "set_de1_screen_saver_directory"

	# force use of our default saver directory if the black screen saver is enabled, otherwise use whatever the skin chooses
	if {$::settings(screen_saver_change_interval) == 0} {
		set dirname "[homedir]/saver"
	}


	global saver_directory
	if {$dirname != ""} {
		set saver_directory $dirname
	}

	#set pngfilename [random_saver_file]
	set names "saver"
	#puts $pngfilename
	#image create photo $names -file $pngfilename
	image create photo $names 

	foreach name $names {
		.can create image {0 0} -anchor nw -image $names  -tag [list saver $name] -state hidden
	}

	setup_display_time_in_screen_saver
}	

proc setup_display_time_in_screen_saver {} {

	if {$::settings(display_time_in_screen_saver) != 1} {
		return
	}

	set ::clocktime [clock seconds]
	set ::previous_clocktime 0
	
	if {$::settings(screen_saver_change_interval) == 0} {
		# black screen saver
		set ::saver_clock2 [add_de1_variable "saver" 1278 898 -justify center -anchor "center" -text "" -font Helv_30_bold -fill "#111111" -width 2000 -textvariable {[time_format $::clocktime 1]}]
		set ::saver_clock3 [add_de1_variable "saver" 1282 902 -justify center -anchor "center" -text "" -font Helv_30_bold -fill "#222222" -width 2000 -textvariable {[time_format $::clocktime 1]}]
		set ::saver_clock [add_de1_variable "saver" 1280 900 -justify center -anchor "center" -text "" -font Helv_30_bold -fill "#444444" -width 2000 -textvariable {[time_format $::clocktime 1]}]
	} else {
		set ::saver_clock2 [add_de1_variable "saver" 1278 898 -justify center -anchor "center" -text "" -font Helv_30_bold -fill "#CCCCCC" -width 2000 -textvariable {[time_format $::clocktime 1]}]
		set ::saver_clock3 [add_de1_variable "saver" 1282 902 -justify center -anchor "center" -text "" -font Helv_30_bold -fill "#666666" -width 2000 -textvariable {[time_format $::clocktime 1]}]
		set ::saver_clock [add_de1_variable "saver" 1280 900 -justify center -anchor "center" -text "" -font Helv_30_bold -fill "#F8F8F8" -width 2000 -textvariable {[time_format $::clocktime 1]}]
	}


	after 1000 saver_clock_move
	proc saver_clock_move {} {
		set ::clocktime [clock seconds]
		set force 0
		if {[time_format $::clocktime] != [time_format $::previous_clocktime] || $force == 1} {


			set newx [expr {[rescale_x_skin 600] + (rand() * [rescale_x_skin 1400])}]
			set newy [expr {[rescale_y_skin 200] + (rand() * [rescale_y_skin 1200])}]
			set newx2 [expr {$newx - [rescale_x_skin 2]}]
			set newy2 [expr {$newy - [rescale_y_skin 2]}]

			set newx3 [expr {$newx + [rescale_x_skin 2]}]
			set newy3 [expr {$newy + [rescale_y_skin 2]}]

			.can coords $::saver_clock2 "$newx2 $newy2"
			.can coords $::saver_clock3 "$newx3 $newy3"
			.can coords $::saver_clock "$newx $newy"
			set ::previous_clocktime $::clocktime 
		}
		after 1000 saver_clock_move
		
	}

}

proc vertical_slider {varname minval maxval x y x0 y0 x1 y1} {
	set yrange [expr {$y1 - $y0}]
	set yoffset [expr {$y - $y0}]

	set range [expr {($yoffset * 1.0)/$yrange}]

	set destrange [expr {$maxval - $minval}]
	set gain [expr {$destrange * $range}]
	set finalvalue [expr {$maxval - $gain}]

	if {$finalvalue < $minval} {
		set finalvalue $minval
	} elseif {$finalvalue > $maxval} {
		set finalvalue $maxval
	}

	#set $var $finalvalue
	#msg "vertical slider $x $y $x0 $y0  $x1 $y1 = $range = $finalvalue = $varname"

	eval set $varname $finalvalue

}

# on android we track finger-down, instead of button-press, as it gives us lower latency by avoding having to distinguish a potential gesture from a tap
# finger down gives a http://blog.tcl.tk/39474
proc translate_coordinates_finger_down_x { x } {

	if {$::android == 1} {
	 	return [expr {$x * [winfo screenwidth .] / 10000}]
	 }
	 return $x
}
proc translate_coordinates_finger_down_y { y } {

	if {$::android == 1} {
	 	return [expr {$y * [winfo screenheight .] / 10000}]
	 }
	 return $y
}

proc is_fast_double_tap { key } {
	# if this is a fast double-tap, then treat it like a long tap (button-3) 

	set b 0
	set millinow [clock milliseconds]
	set prevtime [ifexists ::last_click_time($key)]
	if {$prevtime != ""} {
		# check for a fast double-varName
		if {[expr {$millinow - $prevtime}] < 150} {
			msg "Fast button double-tap on $key"
			set b 1
		}
	}
	set ::last_click_time($key) $millinow

	return $b
}

proc vertical_clicker {bigincrement smallincrement varname minval maxval x y x0 y0 x1 y1 {b 0} } {
	# b = which button was tapped
	#msg "Var: $varname : Button $b  $x $y $x0 $y0 $x1 $y1 "

	set x [translate_coordinates_finger_down_x $x]
	set y [translate_coordinates_finger_down_y $y]

	set yrange [expr {$y1 - $y0}]
	set yoffset [expr {$y - $y0}]

	set midpoint [expr {$y0 + ($yrange / 2)}]
	set onequarterpoint [expr {$y0 + ($yrange / 4)}]
	set threequarterpoint [expr {$y1 - ($yrange / 4)}]

	set onethirdpoint [expr {$y0 + ($yrange / 3)}]
	set twothirdpoint [expr {$y1 - ($yrange / 3)}]

	if {[info exists $varname] != 1} {
		# if the variable doesn't yet exist, initialize it with a zero value
		set $varname 0
	}
	set currentval [subst \$$varname]
	set newval $currentval

	# check for a fast double tap
	set b 0
	if {[is_fast_double_tap $varname] == 1} {
		#set the button to 3, which is the same as a long press, or middle button (ie button 3) on a mouse
		set b 3
	}

	if {$y < $onethirdpoint} {
		if {$b == 3} {
			set newval [expr "1.0 * \$$varname + $bigincrement"]
		} else {
			set newval [expr "1.0 * \$$varname + $smallincrement"]
		}
	} elseif {$y > $twothirdpoint} {
		if {$b == 3} {
			set newval [expr "1.0 * \$$varname - $bigincrement"]
		} else {
			set newval [expr "1.0 * \$$varname - $smallincrement"]
		}
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

proc random_pick {lst} {
    set pick [expr {int(rand() * [llength $lst])}] 
    return [lindex $lst $pick]
}


proc ifexists {fieldname2 {defvalue {}} } {
    upvar $fieldname2 fieldname
    
    if {[info exists fieldname] == 1} {
	    return [subst "\$fieldname"]
    } else {
    	if {$defvalue != ""} {
    		set fieldname $defvalue
    		return $defvalue
    	} else {
    		return ""
    	}
    }
    #return $defvalue
}

proc set_dose_goal_weight {weight} {
	global current_weight_setting
	set current_weight_setting $weight
	.can itemconfig .current_setting_grams_label -text [round_one_digits $weight]
	#update
}


proc round_one_digits {amount} {
	set x $amount
	catch {set x [expr round($amount * 10)/10.00]}
	return $x
}


proc canvas'textvar {canvas tag _var args} {
	puts "UNUSED CURRENTLY"
    upvar 1 $_var var
    if { [llength $args] } {
        $canvas itemconfig $tag -text $var
    } else {
        uplevel 1 trace var $_var w \
            [list [list canvas'textvar $canvas $tag]]
    }
}

# optional "alsobind" allows us to put text on top of a pressable button and have the text also bound to the same down/up/leave actions
proc up_down_button_create {actionscript btn_images img_loc key_loc buttontype {alsobind {}} } {

	msg "up_down_button_create"

	if {$buttontype != "onetime" && $buttontype != "holdrepeats"} {
		puts "ERROR unknown buttontype $buttontype"
		return
	}

	set img_xloc [lindex $img_loc 0]
	set img_yloc [lindex $img_loc 1]

	set up_png [lindex $btn_images 0]
	set down_png [lindex $btn_images 1]

	set key_xloc [lindex $key_loc 0]
	set key_yloc [lindex $key_loc 1]
	set key_xdistance [lindex $key_loc 2]
	set key_ydistance [lindex $key_loc 3]

	image create photo ${up_png}_img -file $up_png
	image create photo ${down_png}_img -file $down_png
	.can create image [list $img_xloc $img_yloc] -anchor nw -image ${down_png}_img  -tag $down_png -state hidden
	.can create image [list $img_xloc $img_yloc] -anchor nw -image ${up_png}_img  -tag $up_png -state hidden
	

	set rect "${up_png}_rect"
	.can create rect $key_xloc $key_yloc [expr {$key_xloc + $key_xdistance}] [expr {$key_yloc + $key_ydistance}] -fill {}  -outline white -width 0 -tag $rect

	lappend alsobind $rect
	foreach tobind $alsobind {
		.can bind $tobind [platform_button_press] [list generic_push_button_settings $up_png $down_png $actionscript down $buttontype] 
		.can bind $tobind [platform_button_unpress] [list generic_push_button_settings $up_png $down_png $actionscript up $buttontype]
		.can bind $tobind <Leave> [list generic_push_button_settings $up_png $down_png $actionscript leave $buttontype]
		lappend image_tags_created $up_png $down_png
	}

	return 
} 



proc generic_push_button_settings {btnup btndown action change buttontype} {
	global genericstate
	if {$change == "down"} {
		#borg beep
		.can itemconfigure $btndown -state normal
		.can itemconfigure $btnup -state hidden
		update
		set genericstate($btndown) "down"
		
		if {$buttontype == "holdrepeats"} {
			set afterid [after 700 [list generic_button_held $btnup $btndown $action]]
			set genericstate($btnup) $afterid
		}

	} else {

		if {$buttontype == "holdrepeats"} {
			if {[ifexists genericstate($btnup)] != ""} {
				# cancel the held-button timer when they 
				after cancel $genericstate($btnup)
				#puts "cancelling held timer $genericstate($btnup) for $btnup"
			}
		}

		if {$change == "leave"} {
			if {[ifexists genericstate($btndown)] != "down"} {
				#puts "skipping leave event because they never pressed the button down"
				return
			}

			.can itemconfigure $btnup -state normal
			.can itemconfigure $btndown -state hidden
			update
			set genericstate($btndown) "up"
			set genericstate($btnup) ""
			#puts "leave button $btnup"
		} elseif {$change == "up"} {
			# this is the up button event
			if {$genericstate($btndown) == "up"} {
				#puts "skipping up event because already left the button"
				return
			}

			#puts "- $btnup : $genericstate($btndown) - $genericstate($btnup) "

			.can itemconfigure $btnup -state normal
			.can itemconfigure $btndown -state hidden
			update
			set genericstate($btnup) ""
			#puts "evaling action with previous state $genericstate($btndown)"
			if {$genericstate($btndown) != "held"} {
				eval $action
			}
			set genericstate($btndown) "up"
		} else {
			puts "unknown action $change"
		}
	}
}

proc generic_button_held {btnup btndown action} {
	global genericstate	

	# button has been pressed down for a while, so activate a down/up press
	if {$genericstate($btndown) == "held" || $genericstate($btndown) == "down"} {
		set genericstate($btndown) "held"		
		#puts "button $btnup held evaling function now"
		eval $action
		update
		#generic_push_button_settings $btnup $btndown $action "up"
		#update

		#generic_push_button_settings $btnup $btndown $action "down"
		#update
		after 150 [list generic_button_held $btnup $btndown $action]

	} elseif {$genericstate($btndown) == "up"} {
		#no longer held
	} else {
		puts "unknown held state: '$genericstate($btndown)'"
	}
}


proc appdir {} {
	#return [file dirname [DirectPathname [info script]]]
	return [file dirname [DirectPathname .]]
	
	#return [file dirname [info script]]
	#return [file dirname [file join [pwd] $pathname]]
	# this old version would give us "." if run from current directory, which wasn't helpful always for Android, which wants an absolute path
    
}

# copied from https://wiki.tcl-lang.org/page/Making+a+Path+Absolute
proc DirectPathname {filename} {
     set savewd [pwd]
     set realFile [file join $savewd $filename]
     # Hmm.  This (unusually) looks like a job for do...while!
     cd [file dirname $realFile]
     set dir [pwd] ;# Always gives a canonical directory name
     set filename [file tail $realFile]
     while {![catch {file readlink $filename} realFile]} {
         cd [file dirname $realFile]
         set dir [pwd]
         set filename [file tail $realFile]
     }
     cd $savewd
     return [file join $dir $filename]
 }


proc install_update_app_icon {} {
	package require base64
	set icondata_de1 [read_binary_file "[appdir]/cloud_download_icon.png"]
	set iconbase64_de1 [::base64::encode -maxlen 0 $icondata_de1]

	if {$icondata_de1 == ""} {
		set icondata_de1 [read_binary_file "cloud_download_icon.png"]
	}

	set appurl "file://[appdir]/appupdate.tcl"
	catch {
		set x [borg shortcut add "Decent Update" $appurl $iconbase64_de1]
		puts "shortcut added: '$x'"
	}

}

proc install_de1_app_icon {} {
	package require base64
	set icondata_de1 [read_binary_file "[appdir]/de1_icon_v2.png"]
	
	if {$icondata_de1 == ""} {
		set icondata_de1 [read_binary_file "de1_icon_v2.png"]
	}

	set iconbase64_de1 [::base64::encode -maxlen 0 $icondata_de1]

	set appurl "file://[appdir]/de1.tcl"
	puts "appurl: $appurl"
	catch {
		set x [borg shortcut add "DE1" $appurl $iconbase64_de1]
		puts "shortcut added: '$x'"
	}

	#install_update_app_icon [appdir]

}


proc install_de1plus_app_icon {} {
	package require base64
	puts "icon file: '[appdir]/de1plus_icon_v2.png'"
	set icondata_de1plus [read_binary_file "[appdir]/de1plus_icon_v2.png"]
	set iconbase64_de1plus [::base64::encode -maxlen 0 $icondata_de1plus]

	set appurl "file://[appdir]/de1plus.tcl"
	#puts "appurl: $appurl"
	#catch {
		set x [borg shortcut add "Decent" $appurl $iconbase64_de1plus]
		puts "shortcut added: '$x'"
	#}

	#install_update_app_icon [appdir]
}

proc platform_button_press {} {
	global android 
	global undroid
	#return {<Motion>}
	if {$android == 1} {
		return {<<FingerDown>>}
		#return {<ButtonPress-1>}
	}
	#return {<Motion>}
	return {<ButtonPress-1>}
}

proc platform_button_long_press {} {
	global android 
	if {$android == 1} {
		#return {<<FingerUp>>}
		return {<ButtonPress-3>}
	}
	return {<ButtonPress-3>}
}

proc platform_finger_down {} {
	global android 
	if {$android == 1} {
		return {<<FingerDown>>}
	}
	return {<ButtonPress-1>}
}

proc platform_button_unpress {} {
	global android 
	if {$android == 1} {
		return {<<FingerUp>>}
	}
	return {<ButtonRelease-1>}
}


set cnt 0
set debugcnt 0
set ::debuglog {}	
# display a debug message into the on-screen debug window, if that's enabled
# also saves the info to the log file.				
proc msg {text} {

	if {$text == ""} {
		return
	}

	catch {
		log_to_debug_file $text
	}

	if {[ifexists ::debugging] != 1} {
		# don't keep a rolling window of debug msgs if it's not going to be displayed onscreen
		return
	}

	incr ::debugcnt

	# someone inefficent mechanism, but no better way to prepend a string exists https://stackoverflow.com/questions/10009181/tcl-string-prepend
	set ::debuglog "$::debugcnt) $text\n$::debuglog"

	set loglines [split $::debuglog "\n"]

	while {[llength $loglines] > $::settings(debuglog_window_size)} {
		unshift loglines
		set ::debuglog [join $loglines \n]
	}

}



proc add_variable_item_to_context {context label_name varcmd} {
	#puts "varcmd: '$varcmd'"
	global variable_labels
	#if {[info exists variable_labels($context)] != 1} {
	#	set variable_labels($context) [list $label_name $varcmd]
	#} else {
		lappend variable_labels($context) [list $label_name $varcmd]
	#}
}


proc add_visual_item_to_context {context label_name} {
	global existing_labels
	set existing_text_labels [ifexists existing_labels($context)]
	lappend existing_text_labels $label_name
	set existing_labels($context) $existing_text_labels
}

set button_cnt 0
proc add_de1_action {context tclcmd} {
	global actions
	if {[info exists actions(context)] == 1} {
		lappend actions($context) $tclcmd
	} else {
		set actions($context) $tclcmd
	}
}

proc add_de1_button {displaycontexts tclcode x0 y0 x1 y1 {options {}}} {
	global button_cnt

	incr button_cnt
	set btn_name ".btn_$button_cnt"
	#set btn_name $bname
	global skindebug
	set width 0
	if {[info exists skindebug] == 1} {
		if {$skindebug == 1} {
			set width 1
		}
	}
	set rx0 [rescale_x_skin $x0]
	set rx1 [rescale_x_skin $x1]
	set ry0 [rescale_y_skin $y0]
	set ry1 [rescale_y_skin $y1]
	.can create rect $rx0 $ry0 $rx1 $ry1 -fill {} -outline black -width 0 -tag $btn_name -state hidden
	if {[info exists skindebug] == 1} {
		if {$skindebug == 1} {
			.can create rect $rx0 $ry0 $rx1 $ry1 -fill {} -outline black -width 1 -tag ${btn_name}_lines -state hidden 
			#add_visual_item_to_context $displaycontext ${btn_name}_lines
		}
	}

	#puts "binding $btn_name to switch to new context: '$newcontext'"

	#set tclcode [list page_display_change $displaycontext $newcontext]

	regsub {%x0} $tclcode $rx0 tclcode
	regsub {%x1} $tclcode $rx1 tclcode
	regsub {%y0} $tclcode $ry0 tclcode
	regsub {%y1} $tclcode $ry1 tclcode

	.can bind $btn_name [platform_button_press] $tclcode
	
#	if {$::settings(disable_long_press) != 1 } {
#		.can bind $btn_name [platform_button_long_press] $tclcode
#	}

#	if {[string first mousemove $options] != -1} {
		#puts "mousemove detected"
#		.can bind $btn_name [platform_finger_down] $tclcode
#	}

	foreach displaycontext $displaycontexts {
		add_visual_item_to_context $displaycontext $btn_name
		if {[ifexists skindebug] == 1} {
			add_visual_item_to_context $displaycontext ${btn_name}_lines
		}

	}
	return $btn_name
}

# truncates strings that are too long to display and add a ...message on the end.
proc maxstring {in maxlength {optmsg {}} } {
	if {[string length $in] > $maxlength} {
		return "[string range $in 0 $maxlength]...$optmsg"
	}

	return $in
}

set text_cnt 0
proc add_de1_text {args} {
	global text_cnt
	incr text_cnt
	set contexts [lindex $args 0]
	set label_name "text_$text_cnt"
	# keep track of what labels are displayed in what contexts
	set x [rescale_x_skin [lindex $args 1]]
	set y [rescale_y_skin [lindex $args 2]]
	set torun [concat [list .can create text] $x $y [lrange $args 3 end] -tag $label_name -state hidden]
	eval $torun

	foreach context $contexts {
		add_visual_item_to_context $context $label_name
	}
	return $label_name
}

set image_cnt 0
proc add_de1_image {args} {

	msg "add_de1_image $args"
	global image_cnt
	incr image_cnt
	set contexts [lindex $args 0]
	set label_name "image_$image_cnt"
	# keep track of what labels are displayed in what contexts
	set x [rescale_x_skin [lindex $args 1]]
	set y [rescale_y_skin [lindex $args 2]]
	set fn [lindex $args 3]

	image create photo $label_name -file $fn
	.can create image [list $x $y] -anchor nw -image $label_name -tag $label_name -state hidden 

	foreach context $contexts {
		add_visual_item_to_context $context $label_name
	}

	return $label_name
}


# derivced from sample code at http://wiki.tcl.tk/17067
set widget_cnt 0
proc add_de1_widget {args} {
	global widget_cnt
	set contexts [lindex $args 0]

	incr widget_cnt
	set widgettype [lindex $args 1]

	set widget ".can.w_${widgettype}_$widget_cnt"

	set errcode 0
	set torun [concat [list $widgettype $widget] [lrange $args 5 end] ]
	#msg $torun
	#set errcode [catch { 
		eval $torun
	#} err]

	if {$errcode == 1} {
		puts $err
		puts "while running" 
		puts $torun
	}

	# BLT on android has non standard defaults, so we overrride them here, sending them back to documented defaults
	if {$widgettype == "graph" && ($::android == 1 || $::undroid == 1)} {
		$widget grid configure -dashes "" -color #DDDDDD -hide 0 -minor 1 
		$widget configure -borderwidth 0
		#$widget grid configure -hide 0
	}

	# the 4th parameter gives additional code to run when creating this widget, such as chart configuration instructions
	set errcode [catch { 
		eval [lindex $args 4]
	} err]

	if {$errcode == 1} {
		puts $err
		puts "while running" 
		puts [lindex $args 4]
	}
	#.can create window [lindex $args 2] [lindex $args 3] -window $widget  -anchor nw -tag $widget -state normal
	#set windowname [.can create window  [lindex $args 2] [lindex $args 3] -window $widget  -anchor nw -tag $widget -state hidden]
	set x [rescale_x_skin [lindex $args 2]]
	set y [rescale_y_skin [lindex $args 3]]

	if {$widgettype == "scrollbar"} {
		set windowname [.can create window  $x $y -window $widget  -anchor nw -tag $widget -state hidden -height 245]
	} else {
		set windowname [.can create window  $x $y -window $widget  -anchor nw -tag $widget -state hidden]
	}
	#puts "winfo: [winfo children .can]"
	#.can bind $windowname [platform_button_press] "msg click"
	

		
	set ::tclwindows($widget) [lrange $args 2 3]

	foreach context $contexts {
		#puts "add_visual_item_to_context $context '$widget'"
		add_visual_item_to_context $context $widget
	}
	return $widget 
}


proc add_de1_variable {args} {

	set varcmd [lindex [unshift args] 0]
	set lastcmd [unshift args]
	if {$lastcmd != "-textvariable"} {
		puts "WARNING: last -command needs to be -textvariable on a add_de1_variable line. You entered: '$lastcmd'"
		return
	}
	set contexts [lindex $args 0]
	set label_name [eval add_de1_text $args]

	# john 24-1-20 now unneeded code https://3.basecamp.com/3671212/buckets/7351439/messages/2360038011
	#set x [rescale_x_skin [lindex $args 1]]
	#set y [rescale_y_skin [lindex $args 2]]
	#set torun [concat [list .can create text] $x $y [lrange $args 3 end] -tag $label_name -state hidden]
	#eval $torun
	#incr ::text_cnt

	foreach context $contexts {
		# keep track of what labels are displayed in what contexts
		add_variable_item_to_context $context $label_name $varcmd
	}
	return $label_name
}

proc stop_screen_saver_timer {} {

	if {[info exists ::screen_saver_alarm_handle] == 1} {
		after cancel $::screen_saver_alarm_handle
		unset -nocomplain ::screen_saver_alarm_handle
		#msg "unset old saver alarm"
	}

}


proc delay_screen_saver {} {

	stop_screen_saver_timer

	if {$::settings(screen_saver_delay) != 0 } {
		set ::screen_saver_alarm_handle [after [expr {60 * 1000 * $::settings(screen_saver_delay)}] "show_going_to_sleep_page"]
	}

	#msg "delay_screen_saver: [ifexists ::screen_saver_alarm_handle] [after_info]"
}

proc after_info {} {

	set t {}
	foreach id [after info] {
		append t $id:[after info $id]\n
	}
	return $t
}

proc show_going_to_sleep_page  {} {

	if {$::settings(scheduler_enable) == 1} {
		set wake [current_alarm_time $::settings(scheduler_wake)]
		set sleep [current_alarm_time $::settings(scheduler_sleep)]
		if {[clock seconds] > $wake && [clock seconds] < $sleep} {
			msg "Delaying screen saver because we are during scheduled forced-awake time"
			delay_screen_saver
			return
		}
	}

	if {$::de1_num_state($::de1(state)) != "Idle"} {
		# never go to sleep if the DE1 is not idle
		msg "delaying screen saver because de1 is not idle: '$::de1_num_state($::de1(state))'"
		delay_screen_saver
		return
	}

    if {[ifexists ::app_updating] == 1} {
		msg "delaying screen saver because tablet app is updating"
		delay_screen_saver
		return
	}

	if {$::de1(currently_updating_firmware) == 1 || [ifexists ::de1(in_fw_update_mode)] == 1} {
		msg "delaying screen saver because firmware is updating"
		delay_screen_saver
		return
	}	



	puts "show_going_to_sleep_page"
 	if {$::de1(current_context) == "sleep" || $::de1(current_context) == "saver"} {
 		return
 	}

	page_display_change $::de1(current_context) "sleep"
	start_sleep

}


proc resized_filename {infile} {
	set resized_filename "[file rootname $infile]-resized-${::screen_size_width}x${::screen_size_height}.jpg"
	#set resized_filename "[file rootname $infile]-${::screen_size_width}x${::screen_size_height}.png"
	return $resized_filename
}

proc change_screen_saver_img {} {

	if {[llength [ifexists ::saver_files_cache]] == 1} {
		# no need to change the background screen saver image if it's only 1
		#msg "xxxxno need to change the background screen saver image if it's only 1"
		return
	}

	#msg "change_screen_saver_img $::de1(current_context) '[page_displaying_now]'"
	#if {$::de1(current_context) == "saver"} {
		#catch {
			# image delete is not needed, as Tk silently replaces the existing image if the object has the same name
			#image delete saver
		#}

		set fn [random_saver_file]

		set err ""
		set errcode [catch {
			# this can happen during an upgrade
			#msg "image create photo saver -file $fn"
			image create photo saver -file $fn
			
			# BUG FIX: this was causing a new canvas item to be created each time a screen saver object was created
			# switching to itemconfigure instead
			# .can create image {0 0} -anchor nw -image saver  -tag saver -state hidden

			#.can itemconfigure -anchor nw -image saver  -tag saver -state hidden
			#.can lower saver
		} err]

		if {$errcode != 0} {

			error $err
		}
		#update
	#}

	if {[info exists ::change_screen_saver_image_handle] == 1} {
		after cancel $::change_screen_saver_image_handle
		unset -nocomplain ::change_screen_saver_image_handle
	}


 	if {$::settings(screen_saver_change_interval) != 0} {
		set ::change_screen_saver_image_handle [after [expr {60 * 1000 * $::settings(screen_saver_change_interval)}] change_screen_saver_img]
	}
	#set ::change_screen_saver_image_handle [after 1 change_screen_saver_img]
	#set ::change_screen_saver_image_handle [after 100 change_screen_saver_img]
}

proc update_chart {} {
	espresso_elapsed notify now
}


proc de1_connected_state { {hide_delay 0} } {

	set hide_delay $::settings(display_connected_msg_seconds)

	set since_last_ping [expr {[clock seconds] - $::de1(last_ping)}]
	set elapsed [expr {[clock seconds] - $::de1(connect_time)}]

	if {$::android == 0} {

		if {$elapsed > $hide_delay && $hide_delay != 0} {
			if {$::de1(substate) != 0} {
				return [translate Wait]
			}
			return ""
		} else {
			return [translate Connected]
		}
	}

	if {$since_last_ping < 5} {
		#borg spinner off

		if {$::de1(substate) != 0} {
			if {$::de1(substate) == 4 || $::de1(substate) == 5} {
				# currently making espresso.
				return ""
			}
			return [translate Wait]
		}

		if {$elapsed > $hide_delay && $hide_delay != 0} {
			# only show the "connected" message for 5 seconds
			return ""
		}
		#return "[translate Connected] : $elapsed"
		#borg toast "[translate Connected]"
		#borg toast "[translate Connected]"
		return [translate Connected]
		#return "[translate Connected] $elapsed [translate seconds] - last ping: $::de1(last_ping) $::de1_device_list"
	} else {

#		if {[ifexists ::de1(in_fw_update_mode)] == 1} {
#			return ""
#		}


		if {$::de1(device_handle) == 0} {
			#return "[translate Connecting]"
			if {$elapsed > 600} {
				if {$::scanning == 1} {
					return "[translate Searching]"
				} elseif {$::scanning == -1} {
					return [translate "Disconnected"]
					#return "[translate Starting]"
				}
				return "[translate Connecting]"
			} else {
				if {$::scanning == 1} {
					return "[translate Searching] : $elapsed"
				} else {
					return "[translate Connecting] : $elapsed"
				}
				return "[translate Connecting] : $elapsed"
			}
		} else {
			if {$since_last_ping > 59} {
				#ble_find_de1s
				#ble_connect_to_de1
				return [translate "Disconnected"]
			}
			return [subst {[translate "Disconnected"] : $since_last_ping}]
		}
	}
}

#
# Proc to generate a string of (given) characters
# Range defaults to "ABCDEF...wxyz'
#
proc randomRangeString {length {chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"}} {
    set range [expr {[string length $chars]-1}]

    set txt ""
    for {set i 0} {$i < $length} {incr i} {
       set pos [expr {int(rand()*$range)}]
       append txt [string range $chars $pos $pos]
    }
    return $txt
}

proc cancel_borg_notifications {} {
	borg notification delete
}

proc display_popup_android_message_if_necessary {intxt} {

	if {[string first "*" $intxt] != -1} {
		# beep if a * is found in the description
		borg beep
	}

	set msg ""
	regexp {\[(.*?)\]} $intxt discard msg
	if {$msg != ""} {
		# post the message 1 second after the start, so that there's a slight delay 
		after 1000 [list borg toast $msg 1]
	}
	
}


proc update_onscreen_variables { {state {}} } {

	#update_chart

	#save_settings

	#set since_last_ping [expr {[clock seconds] - $::de1(last_ping)}]
	#if {$since_last_ping > 3} {
		#set ::de1(last_ping) [clock seconds]
		#if {$::android == 1} {
			#set ::de1(found) 0
			#ble_find_de1s
			#ble_connect_to_de1
		#}

	#}

	if {$::android == 0} {

		if {[expr {int(rand() * 100)}] > 96} {
			set ::state_change_chart_value [expr {$::state_change_chart_value * -1}]
			
			if {[expr {rand()}] > 0.5} {
				set ::settings(current_frame_description) [translate "pouring"]
			} else {
				set ::settings(current_frame_description) [translate "preinfusion"]
			}
		}

		if {$::de1(state) == 2} {
			# idle
			if {$::de1(substate) == 0} {
				if {[expr {int(rand() * 100)}] > 92} {
					# occasionally set the de1 to heating mode
					#set ::de1(substate) 1
					#update_de1_state "$::de1_state(Idle)\x1"
				}
			} else {
				if {[expr {int(rand() * 100)}] > 90} {
					# occasionally set the de1 to heating mode
					update_de1_state "$::de1_state(Idle)\x0"
				}
			}
		} elseif {$::de1(state) == 4} {
			# espresso
			if {$::de1(substate) == 0} {
			} elseif {$::de1(substate) < 4} {
				if {[expr {int(rand() * 100)}] > 80} {
					# occasionally set the de1 to heating mode
					#set ::de1(substate) 4
					update_de1_state "$::de1_state(Espresso)\x4"
				}
			} elseif {$::de1(substate) == 4} {
				if {[expr {int(rand() * 100)}] > 80} {
					# occasionally set the de1 to heating mode
					#set ::de1(substate) 5
					update_de1_state "$::de1_state(Espresso)\x5"
				}
			} 
		}

        #set timerkey "$::de1(state)-$::de1(substate)"
        #set ::timers($timerkey) [clock milliseconds]

		#if {$::de1(substate) > 6} {
		#	set ::de1(substate) 0
		#}

		if {$::de1(state) == 4} {
			append_live_data_to_espresso_chart
		} elseif {$::de1(state) == 5} {
			#steaming
			append_live_data_to_espresso_chart
		}
	}

	# update the timers
  	#set state_timerkey "$::de1(state)"
  	#set substate_timerkey "$::de1(state)-$::de1(substate)"
  	#set now [clock seconds]
  	#set ::timers($state_timerkey) $now
  	#set ::substate_timers($timerkey) $now


	#set x [clock milliseconds]
	global variable_labels
	set something_updated 0
	if {[info exists variable_labels($::de1(current_context))] == 1} {
		set labels_to_update $variable_labels($::de1(current_context)) 
		foreach label_to_update $labels_to_update {
			set label_name [lindex $label_to_update 0]
			set label_cmd [lindex $label_to_update 1]
			
			set label_value ""
			set errcode [catch {
				set label_value [subst $label_cmd]
			}]


		    if {$errcode != 0} {
		        catch {
		            msg "update_onscreen_variables error: $::errorInfo"
		        }
		    }

			if {[ifexists ::labelcache($label_name)] != $label_value} {
				.can itemconfig $label_name -text $label_value
				set ::labelcache($label_name) $label_value
				set something_updated 1
			}
		}
	}

	if {$something_updated == 1} {
		# john 3-10-19 not sure we need to do a forced screen update
		#update
	}

	#set y [clock milliseconds]
	#puts "elapsed: [expr {$y - $x}] $something_updated"

	if {[info exists ::update_onscreen_variables_alarm_handle] == 1} {
		after cancel $::update_onscreen_variables_alarm_handle
		unset ::update_onscreen_variables_alarm_handle
	}
	set ::update_onscreen_variables_alarm_handle [after $::settings(timer_interval) update_onscreen_variables]
}

proc set_next_page {machinepage guipage} {
	#msg "set_next_page $machinepage $guipage"
	set key "machine:$machinepage"
	set ::nextpage($key) $guipage
}

proc show_settings { {tab_to_show ""} } {
	backup_settings; 

	puts "show_settings"

	if {$tab_to_show == ""} {
		page_to_show_when_off $::settings(active_settings_tab)
		scheduler_feature_hide_show_refresh
		set_profiles_scrollbar_dimensions
		set_advsteps_scrollbar_dimensions
	} else {
		page_to_show_when_off $tab_to_show
	}

	update_de1_explanation_chart

	#preview_profile 
}

proc page_to_show_when_off {page_to_show} {
	set_next_page off $page_to_show
	page_show $page_to_show
}

proc page_show {page_to_show} {
	set page_to_hide $::de1(current_context)
	return [page_display_change $page_to_hide $page_to_show] 
}

proc display_brightness {percentage} {
	set percentage [check_battery_low $percentage]
	#puts "brightness: $percentage %"
	get_set_tablet_brightness $percentage
}


proc page_display_change {page_to_hide page_to_show} {

	#msg [stacktrace]

	#if {$page_to_hide == ""} {
	#}

	delay_screen_saver

	set key "machine:$page_to_show"
	if {[ifexists ::nextpage($key)] != ""} {
		# there are different possible tabs to display for different states (such as preheat-cup vs hot water)
		set page_to_show $::nextpage($key)
	}

	if {$::de1(current_context) == $page_to_show} {
		#jbtemp
		#msg "page_display_change returning because ::de1(current_context) == $page_to_show"
		return 
	}

	msg "page_display_change $page_to_hide->$page_to_show"


	if {$page_to_hide == "sleep" && $page_to_show == "off"} {
		msg "discarding intermediate sleep/off state msg"
		return 
	} elseif {$page_to_show == "saver"} {
		if {[ifexists ::exit_app_on_sleep] == 1} {
			get_set_tablet_brightness 0
			close_all_ble_and_exit
		}
	}

	# signal the page change with a sound
	say "" $::settings(sound_button_out)
	#msg "page_display_change $page_to_show"
	#set start [clock milliseconds]

	# set the brightness in one place
	if {$page_to_show == "saver" } {
		if {$::settings(screen_saver_change_interval) == 0} {
			# black screen saver
			display_brightness 0
		} else {
			display_brightness $::settings(saver_brightness)
		}
		borg systemui $::android_full_screen_flags  
	} else {
		display_brightness $::settings(app_brightness)
	}


	if {$::settings(stress_test) == 1 && $::de1_num_state($::de1(state)) == "Idle" && [info exists ::idle_next_step] == 1} {

		msg "Doing next stress test step: '$::idle_next_step '"
		set todo $::idle_next_step 
		unset -nocomplain ::idle_next_step 
		eval $todo
	}


	#global current_context
	set ::de1(current_context) $page_to_show

	#puts "page_display_change hide:$page_to_hide show:$page_to_show"
	catch {
		.can itemconfigure $page_to_hide -state hidden
	}
	#.can itemconfigure [list "pages" "splash" "saver"] -state hidden

	if {[info exists ::delayed_image_load($page_to_show)] == 1} {
		set pngfilename	$::delayed_image_load($page_to_show)
		msg "Loading skin image from disk: $pngfilename"
		
		set errcode [catch {
			# this can happen if the image file has been moved/deleted underneath the app
			#fallback is to at least not crash
			msg "page_display_change image create photo $page_to_show -file $pngfilename" 
			image create photo $page_to_show -file $pngfilename
			#msg "image create photo $page_to_show -file $pngfilename"
		}]

	    if {$errcode != 0} {
	        catch {
	            msg "image create photo error: $::errorInfo"
	        }
	    }

	    foreach {page img} [array get ::delayed_image_load] {
	    	if {$img == $pngfilename} {
	    		
	    		# Matching delayed image load to every page that references it
	    		# this avoids loading the same iamge over and over, for each page referencing it

				set errcode [catch {
					# this error can happen if the image file has been moved/deleted underneath the app, fallback is to at least not crash
					.can itemconfigure $page -image $page_to_show -state hidden					
				}]

			    if {$errcode != 0} {
			        catch {
			            msg ".can itemconfigure page_to_show ($page/$page_to_show) error: $::errorInfo"
			        }
			    }

				unset -nocomplain ::delayed_image_load($page)
	    	}
	    }

	}

	set errcode [catch {
		.can itemconfigure $page_to_show -state normal
	}]

	if {$errcode != 0} {
		catch {
			msg ".can itemconfigure page_to_show error: $::errorInfo"
		}

	} 

	set these_labels [ifexists ::existing_labels($page_to_show)]
	#msg "these_labels: $these_labels"

	if {[info exists ::all_labels] != 1} {
		set ::all_labels {}
		foreach {page labels} [array get ::existing_labels]  {
			set ::all_labels [concat $::all_labels $labels]
		}
		set ::all_labels [lsort -unique $::all_labels]
	}

	#msg "Hiding [llength $::all_labels] labels"
	foreach label $::all_labels {
		if {[.can itemcget $label -state] != "hidden"} {
			.can itemconfigure $label -state hidden
			#msg "hiding: '$label'"
		}
	}

	#msg "Showing [llength $these_labels] labels"
	foreach label $these_labels {
		.can itemconfigure $label -state normal
		#msg "showing: '$label'"
	}

	update
	#set end [clock milliseconds]
	#puts "elapsed: [expr {$end - $start}]"

	global actions
	if {[info exists actions($page_to_show)] == 1} {
		foreach action $actions($page_to_show) {
			eval $action
			msg "action: '$action"
		}
	}

	#msg "Switched to page: $page_to_show [stacktrace]"
	msg "Switched to page: $page_to_show"

	update_onscreen_variables

	hide_android_keyboard

}

proc hide_android_keyboard {} {
	# make sure on-screen keyboard doesn't auto-pop up, and if
	# physical keyboard is connected, make sure navbar stays hidden
	sdltk textinput off
	focus .can
}

proc update_de1_explanation_chart_soon  { {context {}} } {
	# we can optionally delay displaying the chart until data from the slider stops coming
	update_de1_explanation_chart
	return
	
	#after 10 {after cancel update_de1_explanation_chart; after idle update_de1_explanation_chart}
	if {[info exists ::chart_update_id] == 1} {
		after cancel $::chart_update_id; 
		unset -nocomplain ::chart_update_id
	}

	set ::chart_update_id [after idle update_de1_explanation_chart]
	#after idle update_de1_explanation_chart
}

proc update_de1_explanation_chart { {context {}} } {
	#puts "update_de1_explanation_chart"
	#puts "update_de1_explanation_chart 1: $::settings(settings_profile_type)"

	espresso_de1_explanation_chart_elapsed length 0
	espresso_de1_explanation_chart_temperature length 0
	espresso_de1_explanation_chart_temperature_10 length 0
	espresso_de1_explanation_chart_selected_step length 0

	espresso_de1_explanation_chart_pressure length 0
	espresso_de1_explanation_chart_pressure_1 length 0
	espresso_de1_explanation_chart_elapsed_1 length 0
	espresso_de1_explanation_chart_pressure_2 length 0
	espresso_de1_explanation_chart_elapsed_2 length 0
	espresso_de1_explanation_chart_pressure_3 length 0
	espresso_de1_explanation_chart_elapsed_3 length 0

	espresso_de1_explanation_chart_flow length 0

	espresso_de1_explanation_chart_elapsed_flow length 0
	espresso_de1_explanation_chart_flow_1 length 0
	espresso_de1_explanation_chart_elapsed_flow_1 length 0
	espresso_de1_explanation_chart_flow_2 length 0
	espresso_de1_explanation_chart_elapsed_flow_2 length 0
	espresso_de1_explanation_chart_flow_3 length 0
	espresso_de1_explanation_chart_elapsed_flow_3 length 0

	espresso_de1_explanation_chart_flow_2x length 0
	espresso_de1_explanation_chart_flow_1_2x length 0
	espresso_de1_explanation_chart_flow_2_2x length 0
	espresso_de1_explanation_chart_flow_3_2x length 0

	if {[ifexists ::settings(espresso_temperature_steps_enabled)] != 1} {
		set ::settings(espresso_temperature_0) $::settings(espresso_temperature)
		set ::settings(espresso_temperature_1) $::settings(espresso_temperature)
		set ::settings(espresso_temperature_2) $::settings(espresso_temperature)
		set ::settings(espresso_temperature_3) $::settings(espresso_temperature)
	}

	clear_espresso_chart

	if {$::settings(settings_profile_type) == "settings_2b"} {
		update_de1_plus_flow_explanation_chart
	    espresso_de1_explanation_chart_elapsed append [espresso_de1_explanation_chart_elapsed_flow range 0 end]
		return
	} elseif {$::settings(settings_profile_type) == "settings_2c" || $::settings(settings_profile_type) == "settings_2c2"} {
		# advanced shots currently get no graphic preview
		update_de1_plus_advanced_explanation_chart
		return
	}

	#puts "update_de1_explanation_chart 2"

	set seconds 0

	#set temperature 90

	# preinfusion
	set preinfusion_pressure 0.5
	if {$::settings(preinfusion_time) > 0} {
		#set preinfusion_pressure [expr {$::settings(preinfusion_flow_rate) / 6.0}]
		set preinfusion_pressure $::settings(preinfusion_stop_pressure)

		espresso_de1_explanation_chart_pressure append 0.1
		espresso_de1_explanation_chart_elapsed append $seconds

		espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_0) 
		espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_0) / 10.0}]


		set seconds [expr {-.01  + $seconds + $::settings(preinfusion_time)}]
		espresso_de1_explanation_chart_pressure append $preinfusion_pressure
		espresso_de1_explanation_chart_elapsed append $seconds

		espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_1) 
		espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_1) / 10.0}]

		# these 0.01 add/remove is to force the chart library to put two dots in to keep the curves all moving the same way
		set seconds [expr {.01  + $seconds}]
		espresso_de1_explanation_chart_pressure append $preinfusion_pressure
		espresso_de1_explanation_chart_elapsed append $seconds

		espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_1) 
		espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_1) / 10.0}]

	} else {
		espresso_de1_explanation_chart_elapsed append $seconds
		espresso_de1_explanation_chart_pressure append 0

		espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_0)
		espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_0) / 10.0}]
	}



	# color coding the preinfusion section
	espresso_de1_explanation_chart_pressure_1 append espresso_de1_explanation_chart_pressure
	espresso_de1_explanation_chart_elapsed_1 append espresso_de1_explanation_chart_elapsed
	espresso_de1_explanation_chart_pressure_2 append espresso_de1_explanation_chart_pressure
	espresso_de1_explanation_chart_elapsed_2 append espresso_de1_explanation_chart_elapsed
	espresso_de1_explanation_chart_pressure_3 append espresso_de1_explanation_chart_pressure
	espresso_de1_explanation_chart_elapsed_3 append espresso_de1_explanation_chart_elapsed


	set espresso_pressure $::settings(espresso_pressure)
	if {$espresso_pressure == 0} {
		# don't chart espresso pressure at zero, because you get visual interference with the baseline
		set espresso_pressure 0.05
	}

	set pressure_end $::settings(pressure_end)
	if {$pressure_end == 0} {
		# don't chart espresso end pressure at zero, because you get visual interference with the baseline
		set pressure_end 0.05
	}

	# the 0.1 added is to avoid having a rampup of zero which causes the chart library to remove one of the plotted dots
	set approximate_ramptime [expr {0.01 + (abs($espresso_pressure - $preinfusion_pressure) * 0.5)}]
	set pressure_hold_time $::settings(espresso_hold_time)

	#puts "approximate_ramptime: $approximate_ramptime / pressure_hold_time: $pressure_hold_time"
	if {$approximate_ramptime > $pressure_hold_time} {
		set espresso_pressure [expr {$pressure_hold_time * 2}]
	}


	#puts "pressure_hold_time: $pressure_hold_time"

	set espresso_decline_time $::settings(espresso_decline_time)
	#if {$pressure_hold_time > $approximate_ramptime} {
		set pressure_hold_time [expr {$pressure_hold_time - $approximate_ramptime}]
	#} elseif {$espresso_decline_time > $approximate_ramptime} {
	#	set espresso_decline_time [expr {$espresso_decline_time - $approximate_ramptime}]
	#} else {
	#	set approximate_ramptime 0

	#}	

	# ramp up the pressure - 
	set seconds [expr {$seconds + $approximate_ramptime}]
	espresso_de1_explanation_chart_elapsed append $seconds
	espresso_de1_explanation_chart_pressure append $espresso_pressure

	espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_2)
	espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_2) / 10.0}]


	espresso_de1_explanation_chart_elapsed_2 append $seconds
	espresso_de1_explanation_chart_pressure_2 append $espresso_pressure
	espresso_de1_explanation_chart_elapsed_3 append $seconds
	espresso_de1_explanation_chart_pressure_3 append $espresso_pressure

	# hold the pressure
	if {$pressure_hold_time > 0} {
		set seconds [expr {$seconds + $pressure_hold_time}]
		espresso_de1_explanation_chart_pressure append $espresso_pressure
		espresso_de1_explanation_chart_elapsed append $seconds

		espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_2)
		espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_2) / 10.0}]

		espresso_de1_explanation_chart_pressure_2 append $espresso_pressure
		espresso_de1_explanation_chart_elapsed_2 append $seconds
		espresso_de1_explanation_chart_pressure_3 append $espresso_pressure
		espresso_de1_explanation_chart_elapsed_3 append $seconds
	}

	# decline pressure stage
	if {$::settings(espresso_decline_time) > 0} {
		set seconds [expr {$seconds + $espresso_decline_time}]
		espresso_de1_explanation_chart_pressure append $pressure_end
		espresso_de1_explanation_chart_elapsed append $seconds

		espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_3)
		espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_3) / 10.0}]

		espresso_de1_explanation_chart_pressure_3 append $pressure_end
		espresso_de1_explanation_chart_elapsed_3 append $seconds
	}

	# save the total time
	set ::settings(espresso_max_time) $seconds

}


proc update_de1_plus_flow_explanation_chart { {context {}} } {

	set seconds 0

	# preinfusion
	if {$::settings(preinfusion_time) > 0} {
		espresso_de1_explanation_chart_flow append 0
		espresso_de1_explanation_chart_elapsed_flow append $seconds

		espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_0) 
		espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_0) / 10.0}]

		set seconds [expr {$::settings(preinfusion_flow_rate)/4}]

		espresso_de1_explanation_chart_flow append $::settings(preinfusion_flow_rate);
		espresso_de1_explanation_chart_elapsed_flow append $seconds

		espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_0) 
		espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_0) / 10.0}]


		set likely_pressure_attained_during_preinfusion [expr {(($::settings(preinfusion_flow_rate) * $::settings(preinfusion_time)) - 5) / 10}]
		set pressure_gained_needed [expr {$::settings(preinfusion_stop_pressure) - $likely_pressure_attained_during_preinfusion}]

		set seconds [expr {$seconds + $::settings(preinfusion_time)}]
		espresso_de1_explanation_chart_flow append $::settings(preinfusion_flow_rate);
		espresso_de1_explanation_chart_elapsed_flow append $seconds

		espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_1) 
		espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_1) / 10.0}]


	} else {
		set seconds [expr {$::settings(flow_profile_hold)/4}]
		espresso_de1_explanation_chart_flow append 0
		espresso_de1_explanation_chart_elapsed_flow append $seconds

		espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_0) 
		espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_0) / 10.0}]

	}

	# color coding the preinfusion section
	espresso_de1_explanation_chart_flow_1 append espresso_de1_explanation_chart_flow
	espresso_de1_explanation_chart_elapsed_flow_1 append espresso_de1_explanation_chart_elapsed_flow
	espresso_de1_explanation_chart_flow_2 append espresso_de1_explanation_chart_flow
	espresso_de1_explanation_chart_elapsed_flow_2 append espresso_de1_explanation_chart_elapsed_flow
	espresso_de1_explanation_chart_flow_3 append espresso_de1_explanation_chart_flow
	espresso_de1_explanation_chart_elapsed_flow_3 append espresso_de1_explanation_chart_elapsed_flow

	set approximate_ramptime 3
	set flow_profile_hold_time $::settings(espresso_hold_time)
	set espresso_decline_time $::settings(espresso_decline_time)

	set flow_profile_hold $::settings(flow_profile_hold)
	if {$flow_profile_hold == 0} {
		# don't chart espresso pressure at zero, because you get visual interference with the baseline
		set flow_profile_hold 0.05
	}

	set flow_profile_decline $::settings(flow_profile_decline)
	if {$flow_profile_decline == 0} {
		# don't chart espresso end pressure at zero, because you get visual interference with the baseline
		set flow_profile_decline 0.05
	}



	# ramp up the flow
	if {$flow_profile_hold_time > 0} {
		set seconds [expr {$seconds + $approximate_ramptime}]
		espresso_de1_explanation_chart_elapsed_flow append $seconds
		espresso_de1_explanation_chart_flow append $flow_profile_hold

		espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_2) 
		espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_2) / 10.0}]

		
		espresso_de1_explanation_chart_elapsed_flow_2 append $seconds
		espresso_de1_explanation_chart_flow_2 append $flow_profile_hold
		espresso_de1_explanation_chart_elapsed_flow_3 append $seconds
		espresso_de1_explanation_chart_flow_3 append $flow_profile_hold

		# hold the flow
		set seconds [expr {$seconds + $flow_profile_hold_time}]
		espresso_de1_explanation_chart_flow append $flow_profile_hold
		espresso_de1_explanation_chart_elapsed_flow append $seconds

		espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_2) 
		espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_2) / 10.0}]

		
		espresso_de1_explanation_chart_flow_2 append $flow_profile_hold
		espresso_de1_explanation_chart_elapsed_flow_2 append $seconds
		espresso_de1_explanation_chart_flow_3 append $flow_profile_hold
		espresso_de1_explanation_chart_elapsed_flow_3 append $seconds

	}

	# decline flow stage
	if {$espresso_decline_time > 0} {
		set seconds [expr {$seconds + $espresso_decline_time}]
		espresso_de1_explanation_chart_flow append $flow_profile_decline
		espresso_de1_explanation_chart_elapsed_flow append $seconds

		espresso_de1_explanation_chart_temperature append $::settings(espresso_temperature_3) 
		espresso_de1_explanation_chart_temperature_10 append [expr {$::settings(espresso_temperature_3) / 10.0}]		

		espresso_de1_explanation_chart_flow_3 append $flow_profile_decline
		espresso_de1_explanation_chart_elapsed_flow_3 append $seconds
	}

	######################################
	# 2x zoomed flow explanation
	foreach f [espresso_de1_explanation_chart_flow range 0 end] {
		espresso_de1_explanation_chart_flow_2x append [expr {2.0 * $f}]
	}
	foreach f [espresso_de1_explanation_chart_flow_1 range 0 end] {
		espresso_de1_explanation_chart_flow_1_2x append [expr {2.0 * $f}]
	}
	foreach f [espresso_de1_explanation_chart_flow_2 range 0 end] {
		espresso_de1_explanation_chart_flow_2_2x append [expr {2.0 * $f}]
	}
	foreach f [espresso_de1_explanation_chart_flow_3 range 0 end] {
		espresso_de1_explanation_chart_flow_3_2x append [expr {2.0 * $f}]
	}

	######################################



	# save the total time
	set ::settings(espresso_max_time) $seconds
}

proc update_de1_plus_advanced_explanation_chart { {context {}} } {

	set seconds 0
	espresso_de1_explanation_chart_pressure append 0
	espresso_de1_explanation_chart_flow append 0
	espresso_de1_explanation_chart_elapsed append 0
	espresso_de1_explanation_chart_elapsed_flow append 0
	espresso_de1_explanation_chart_selected_step append -1
	
	# first step temp
	array set props [lindex $::settings(advanced_shot) 0]
	espresso_de1_explanation_chart_temperature append [ifexists props(temperature)]
	espresso_de1_explanation_chart_temperature_10 append [expr {[ifexists props(temperature)] / 10.0}]

	set cnt 0
	set previous_pump ""
	set previous_flow 0
	set previous_pressure 0
	set selected_step_value -100

	foreach step $::settings(advanced_shot) {
		incr cnt
		unset -nocomplain props
		array set props $step

		unset -nocomplain nextprops
		array set nextprops [lindex $::settings(advanced_shot) $cnt]

		set pump [ifexists props(pump)]

		#puts "$cnt [array get props]\n"

		set theseconds [ifexists props(seconds)]
		set transition [ifexists props(transition)]


		if {[expr {$cnt - 1}] == [ifexists ::current_step_number]} {
			set selected_step_value [expr {-1 * $selected_step_value}]
		}

		if {$pump == "pressure"} {
			#puts "pressure [ifexists props(pressure)] $seconds"

			if {$previous_pump == "flow"} {
				espresso_de1_explanation_chart_pressure append [ifexists props(pressure)]
				espresso_de1_explanation_chart_flow append -1
				espresso_de1_explanation_chart_elapsed append $seconds		
				espresso_de1_explanation_chart_elapsed_flow append $seconds		

				espresso_de1_explanation_chart_temperature append [ifexists props(temperature)]
				espresso_de1_explanation_chart_temperature_10 append [expr {[ifexists props(temperature)] / 10.0}]
				espresso_de1_explanation_chart_selected_step append $selected_step_value

			}

			if {$transition == "fast"} {
				espresso_de1_explanation_chart_pressure append [ifexists props(pressure)]
				espresso_de1_explanation_chart_flow append -1
				espresso_de1_explanation_chart_elapsed append $seconds		
				espresso_de1_explanation_chart_elapsed_flow append $seconds		

				espresso_de1_explanation_chart_temperature append [ifexists props(temperature)]
				espresso_de1_explanation_chart_temperature_10 append [expr {[ifexists props(temperature)] / 10.0}]
				espresso_de1_explanation_chart_selected_step append $selected_step_value
			} else {
				espresso_de1_explanation_chart_pressure append $previous_pressure
				espresso_de1_explanation_chart_flow append -1
				espresso_de1_explanation_chart_elapsed append $seconds		
				espresso_de1_explanation_chart_elapsed_flow append $seconds		

				espresso_de1_explanation_chart_temperature append [ifexists props(temperature)]
				espresso_de1_explanation_chart_temperature_10 append [expr {[ifexists props(temperature)] / 10.0}]
				espresso_de1_explanation_chart_selected_step append $selected_step_value
			}


			set seconds [expr {$seconds + $theseconds}]

			espresso_de1_explanation_chart_pressure append [ifexists props(pressure)]
			espresso_de1_explanation_chart_flow append -1
			espresso_de1_explanation_chart_elapsed append $seconds		
			espresso_de1_explanation_chart_elapsed_flow append $seconds		

			espresso_de1_explanation_chart_temperature append [ifexists props(temperature)]
			espresso_de1_explanation_chart_temperature_10 append [expr {[ifexists props(temperature)] / 10.0}]
			espresso_de1_explanation_chart_selected_step append $selected_step_value



		} elseif {$pump == "flow"} {
			#puts "flow [ifexists props(flow)] $seconds"

			if {$previous_pump == "pressure"} {
				espresso_de1_explanation_chart_flow append [ifexists props(flow)]
				espresso_de1_explanation_chart_pressure append -1
				espresso_de1_explanation_chart_elapsed append $seconds		
				espresso_de1_explanation_chart_elapsed_flow append $seconds		

				espresso_de1_explanation_chart_temperature append [ifexists props(temperature)]
				espresso_de1_explanation_chart_temperature_10 append [expr {[ifexists props(temperature)] / 10.0}]
				espresso_de1_explanation_chart_selected_step append $selected_step_value

			}

			if {$transition == "fast"} {
				espresso_de1_explanation_chart_flow append [ifexists props(flow)]
				espresso_de1_explanation_chart_pressure append -1
				espresso_de1_explanation_chart_elapsed append $seconds		
				espresso_de1_explanation_chart_elapsed_flow append $seconds		

				espresso_de1_explanation_chart_temperature append [ifexists props(temperature)]
				espresso_de1_explanation_chart_temperature_10 append [expr {[ifexists props(temperature)] / 10.0}]
				espresso_de1_explanation_chart_selected_step append $selected_step_value

			}  else {
				espresso_de1_explanation_chart_flow append $previous_flow
				espresso_de1_explanation_chart_pressure append -1
				espresso_de1_explanation_chart_elapsed append $seconds		
				espresso_de1_explanation_chart_elapsed_flow append $seconds		

				espresso_de1_explanation_chart_temperature append [ifexists props(temperature)]
				espresso_de1_explanation_chart_temperature_10 append [expr {[ifexists props(temperature)] / 10.0}]
				espresso_de1_explanation_chart_selected_step append $selected_step_value
			}

			set seconds [expr {$seconds + $theseconds}]

			espresso_de1_explanation_chart_flow append [ifexists props(flow)]
			espresso_de1_explanation_chart_pressure append -1
			espresso_de1_explanation_chart_elapsed append $seconds		
			espresso_de1_explanation_chart_elapsed_flow append $seconds		

			espresso_de1_explanation_chart_temperature append [ifexists props(temperature)]
			espresso_de1_explanation_chart_temperature_10 append [expr {[ifexists props(temperature)] / 10.0}]
			espresso_de1_explanation_chart_selected_step append $selected_step_value

		}

		set previous_pump $pump
		set previous_flow [ifexists props(flow)]
		set previous_pressure [ifexists props(pressure)]
	}

	# save the total time
	set ::settings(espresso_max_time) $seconds
}


proc setup_images_for_first_page {} {
	
	msg "setup_images_for_first_page"
	set fn [random_splash_file]
	image create photo splash -file $fn 
	.can create image {0 0} -anchor nw -image splash -tag splash -state normal
	pack .can
	update
	return
}

proc run_de1_app {} {
	page_display_change "splash" "off"
}

proc ui_startup {} {

	load_settings
	setup_environment
	bluetooth_connect_to_devices
	
	if {[ifexists ::settings(enable_shot_history_export)] == "1"} {
		shot_history_export
	}

	if {[ifexists ::settings(mark_most_popular_profiles_used)] == "1"} {
		shot_history_count_profile_use
	}
	#ble_find_de1s
	
	setup_images_for_first_page
	setup_images_for_other_pages
	plugins init
	.can itemconfigure splash -state hidden


	#after $::settings(timer_interval) 
	update_onscreen_variables
	delay_screen_saver
	change_screen_saver_img

	check_if_battery_low_and_give_message

	# check for app updates, some time after startup, and then every 24h thereafter
	after 3000 scheduled_app_update_check
	tcl_introspection

	run_de1_app
	vwait forever
}

# from https://wiki.tcl-lang.org/25189
snit::widget multiline_entry {
    delegate option * to text
    delegate method * to text

    # On/Off options
    option -yscroll -default no
    option -xscroll -default no
    option -allowtab -default no
    option -readonly -default no

    # Miscellaneous options
    option -textvariable -default 0

    constructor { args } {
        install text using text $win.txt
        grid $win.txt -row 0 -column 0 -sticky nswe

        $self configurelist $args

        if { [$win cget -yscroll] } {
            $win.txt configure -yscrollcommand [list $win.vsb set]
            ttk::scrollbar $win.vsb -command [list $win.txt yview]
            grid $win.vsb -row 0 -column 1 -sticky nsw
        }

        if { [$win cget -xscroll] } {
            $win.txt configure -xscrollcommand [list $win.hsb set]
            ttk::scrollbar $win.hsb -orient horizontal -command [list $win.txt xview]
            grid $win.hsb -row 1 -column 0 -sticky we
        }

        grid rowconfigure $win 0 -weight 1
        grid columnconfigure $win 0 -weight 1

        if {[$win cget -textvariable] != 0} {
            set varName [$win cget -textvariable]
            upvar 3 $varName v
            $win.txt insert 1.0 $v
            $win.txt mark set insert 1.0
            trace add variable v write [list $self setContent]
            trace add variable v read [list $self getContent]
        }

        bind $win <FocusIn> [list focus $win.txt]

        if { !$options(-allowtab) } {
            bind $win.txt <Shift-Tab> [list $self focusPrev]
            bind $win.txt <Tab> [list $self focusNext]
        }

        if { $options(-readonly) } {
            bind $win.txt <KeyPress>        break
            bind $win.txt <ButtonRelease-2> break

            bind $win.txt <Down>  continue
            bind $win.txt <Up>    continue
            bind $win.txt <Prior> continue
            bind $win.txt <Next>  continue
            bind $win.txt <Left>  continue
            bind $win.txt <Right> continue
        }
    }

    method getTextWidget {} {
        return $win.txt
    }

    method focusPrev {} {
        focus [tk_focusPrev $win]

        return -code break
    }

    method focusNext {} {
        focus [tk_focusNext $win.txt]

        return -code break
    }

    method setContent { name element op} {
        upvar 1 $name x

        $win.txt delete 1.0 end

        if { [array exists x] } {
            $win.txt insert 1.0 $x($element)
        } else {
            $win.txt insert 1.0 $x
        }
    }

    method getContent { name element op } {
        upvar 1 $name x

        if { [array exists x] } {
            set x($element) [$win.txt get 1.0 "end-1 char"]
        } else {
            set x [$win.txt get 1.0 "end-1 char"]
        }
    }
 }

proc canvas_hide { widgetlist } {
	foreach widget $widgetlist {
		.can itemconfigure $widget -state hidden
	}
}

proc canvas_show { widgetlist } {
	foreach widget $widgetlist {
		.can itemconfigure $widget -state normal
	}
}

proc canvas_hide_if_zero { testvar widgetlist } {
	if {$testvar == 0} {
		canvas_hide $widgetlist
	} else {
		canvas_show $widgetlist
	}
}

proc binary_to_canvas_state {binval} {
	if {$binval == 1} {
		set state normal
	} else {
		set state hidden 
	}
	return $state
}

proc show_hide_from_variable {widgetids n1 n2 op} {
	if {$n2 != ""} {
		set val [expr "$$n1\($n2)"]
	}

	set state [binary_to_canvas_state $val]
	foreach widget $widgetids {
		.can itemconfigure $widget -state $state 
	}
}


# causes the water level widget to change between colors (blinking) at an inreasing rate as the water level goes lower
proc water_level_color_check {widget} {
	if {$::settings(waterlevel_indicator_blink) != 1} {
		return
	}

	#puts water_level_color_check

	if {[info exists ::water_level_color_check_count] != 1} {
		set ::water_level_color_check_count  0
	}
	incr ::water_level_color_check_count 
	set colors [list  "#7ad2ff"  "#ff6b6b"]
	if {$::water_level_color_check_count > [expr {-1 + [llength $colors]}] } {
		set ::water_level_color_check_count 0
	}

	# john 28-3-20 not adjusting the blinking to be higher, when refilling earlier, as they will not actually run out of water during drink making, so no need to warn
	#set refill_point_corrected [expr {$::settings(water_refill_point) + $::de1(water_level_mm_correction)}]
	set refill_point_corrected $::de1(water_level_mm_correction)

	set start_blinking_level [expr {$::settings(waterlevel_blink_start_offset) + $refill_point_corrected}]
	set remaining_water [expr {$::de1(water_level)  - $refill_point_corrected}]
	# if using refill kit don't blink
	#set start_blinking_level $::settings(waterlevel_blink_start_offset)
	set blinkrate $::settings(waterlevel_indicator_blink_rate)

	#puts "$::de1(water_level) | $start_blinking_level | $remaining_water"
	set color [lindex $colors $::water_level_color_check_count]
	if {$remaining_water > 7} {
		# check the water rate infrequently if there is enough water and don't blink it
		set color [lindex $colors 0]
		set blinkrate 5000
	} elseif {$remaining_water > 6} {
		#set color "#7ad2ff"
		set blinkrate 2000
	} elseif {$remaining_water > 5} {
		set blinkrate 1000
	} else {
		set blinkrate 500
	}

	$widget configure -background $color
	after $blinkrate water_level_color_check $widget
}

# causes the water level widget to change between colors (blinking) at an inreasing rate as the water level goes lower
proc water_level_color_check_obs {widget} {
	if {$::settings(waterlevel_indicator_blink) != 1} {
		return
	}
	if {[info exists ::water_level_color_check_count] != 1} {
		set ::water_level_color_check_count  0
	}
	incr ::water_level_color_check_count 
	set colors [list  "#7ad2ff"  "#98eeff"]
	if {$::water_level_color_check_count > [expr {-1 + [llength $colors]}] } {
		set ::water_level_color_check_count 0
	}

	if {$::de1(water_level) > $::settings(waterlevel_blink_start_level)} {
		# check the water rate infrequently if there is enough water and don't blink it
		set color "#7ad2ff"
		set blinkrate 5000
	} else {
		set color [lindex $colors $::water_level_color_check_count]
		if {$::de1(water_level) > 10} {
			set blinkrate 2000
		} elseif {$::de1(water_level) > 7} {
			set blinkrate 1000
		} elseif {$::de1(water_level) > 5} {
			set blinkrate 500
		} else {
			set blinkrate 250
		}
	}

	$widget configure -background $color
	after $blinkrate water_level_color_check $widget
}


# convenience function to link a "scale" widget with a "listbox" so that the scale becomes a scrollbar to the listbox, rather than using the ugly Tk native scrollbar
proc listbox_moveto {lb dest1 dest2} {
	listbox_moveto_new $lb $dest1 $dest2
}

# convenience function to link a "scale" widget with a "listbox" so that the scale becomes a scrollbar to the listbox, rather than using the ugly Tk native scrollbar
proc listbox_moveto_new {lb dest1 dest2} {
    # get number of items visible in list box
    set visible_items [lindex [split [$lb configure -height] " "] 4]
    # get total items in listbox
    set total_items [$lb size]
    # if all the items fit on screen then there is nothing to do
    if {$visible_items >= $total_items} {return}
    # determine which item would be at the top if the last items is at the bottom
    set last_top_item [expr $total_items - $visible_items]
    # determine which item should be at the top for the requested value
    set top_item [expr int(round($last_top_item * $dest2))]

    $lb yview $top_item
}

proc scale_prevent_horiz_scroll {lb dest1 dest2} {
	upvar $lb fieldname
	$lb xview 0
}

# convenience function to link a "scale" widget with a "listbox" so that the scale becomes a scrollbar to the listbox, rather than using the ugly Tk native scrollbar
proc scale_scroll {lb dest1 dest2} {
	upvar $lb fieldname
	set fieldname $dest1
}

# convenience function to link a "scale" widget with a "listbox" so that the scale becomes a scrollbar to the listbox, rather than using the ugly Tk native scrollbar
proc scale_scroll_new {lb scrollbar dest1 dest2} {
    # get number of items visible in list box
    set visible_items [lindex [split [$lb configure -height] " "] 4]
    # get total items in listbox
    set total_items [$lb size]
    # if all the items fit on screen then there is nothing to do
    if {$visible_items >= $total_items} {return}
    # determine which item would be at the top if the last items is at the bottom
    set last_top_item [expr $total_items - $visible_items]
    # determine what percentage of the way down the current top item is
    set rescaled_value [expr $dest1 * $total_items / $last_top_item]

    upvar $scrollbar fieldname
    set fieldname $rescaled_value
}

proc calibration_gui_init {} {

	# calibration should always take place in Celsius
	if {[ifexists ::settings(enable_fahrenheit)] == 1} {
		set ::settings(enable_fahrenheit) 0
		set ::calibration_disabled_fahrenheit 1
		msg "Calibration disabled Fahrenheit"
	}

	# set the entry fields back to normal
	$::globals(widget_calibrate_temperature) configure -state normal; 
	$::globals(widget_calibrate_pressure) configure -state normal; 

	if {[info exists ::globals(widget_calibrate_flow)] == 1} {	
		$::globals(widget_calibrate_flow) configure -state normal; 
	}

	# set the goals to be the HOLD step of FLOW and PRESSURE shots, and the temperature to be the overall espresso temperature
	set ::globals(calibration_espresso_pressure) $::settings(espresso_pressure); 
	set ::globals(calibration_espresso_temperature) $::settings(espresso_temperature); 
	set ::globals(calibration_espresso_flow) $::settings(flow_profile_hold); 

	set ::globals(calibration_espresso_flow) $::settings(flow_profile_hold); 


	# read factory and current calibration values for pressure, flow, temperature
	#de1_disable_temp_notifications
	if {[ifexists ::globals(calibration_notifications_enabled)] != 1} {
		set ::globals(calibration_notifications_enabled) 1
		de1_enable_calibration_notifications
	}

	# the read-calibration code can't handle another request coming in while it's still processing the previous one.
	# the *right* way to work around this is to build a spool and unspool each calibration read command as the previous
	# one concludes. However, that's a lot of work, for this rarely used calibration feature, so we're being lazy
	# for now and just issuing each command after a suitable delay, so they don't clobber each other
	if {$::android != 1} {

		# do fake calibration reads
		calibration_ble_received "\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\xFF\xFD\xB3\x34"
		#calibration_ble_received "\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x04\xB3\x34"
		#calibration_ble_received "\x00\x00\x00\x00\x01\x02\x00\x01\x00\x00\x00\x03\x64\x86"
		after 500 calibration_ble_received "\x00\x00\x00\x00\x01\x01\x00\x01\x00\x00\x00\x02\x34\x86"
		after 1000 calibration_ble_received "\x00\x00\x00\x00\x01\x00\x00\x01\x00\x00\x00\x01\x14\x86"

		after 1500 calibration_ble_received "\x00\x00\x00\x00\x03\x02\x00\x01\x03\x00\x00\x06\x12\x86"
		after 2000 calibration_ble_received "\x00\x00\x00\x00\x03\x01\x00\x01\x03\x00\x00\x05\x61\x86"
		after 2500 calibration_ble_received "\x00\x00\x00\x00\x03\x00\x00\x01\x03\x00\x00\x04\x32\x86"
	} else {

		after 1000 de1_read_calibration "temperature"
		after 2000 de1_read_calibration "pressure"
		after 3000 de1_read_calibration "flow"

		after 4000 de1_read_calibration "temperature" "factory"
		after 5000 de1_read_calibration "pressure" "factory"
		after 6000 de1_read_calibration "flow" "factory"

	}
}

proc import_god_shots_from_common_format {} {


	set import_files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/godshots/import/common/" *.csv]]
	#puts "import_files: $import_files"
	foreach import_file $import_files {
		set import_files_array($import_file) 1
	}

	set files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/godshots/" *.shot]]
	set dd {}
	foreach f $files {
		unset -nocomplain import_files_array($f)
	}

	set files_to_import [array names import_files_array]
	#puts "files_to_import: $files_to_import"
	if {$files_to_import != ""} {
		foreach file_to_import $files_to_import {
			set fn_import "[homedir]/godshots/import/common/$file_to_import"
			set fn_export "[homedir]/godshots/[file rootname $file_to_import].shot"
			if {[file exist $fn_export] == 1} {
				continue
			}
			puts "Importing common file format into god shot from '$fn_import' to '$fn_export'"

			set import_espresso_elapsed {}
			set import_espresso_pressure {}
			set import_espresso_weight {}
			set import_espresso_flow {}
			set import_espresso_flow_weight {}
			set import_espresso_temperature_basket {}
			set import_espresso_temperature_mix {}

			set import_filename "[file rootname $file_to_import].shot"
			set import_name [clock seconds]
			set meta(clock) [clock seconds]
			set notes_list {}
			set this_weight 0

			set linecnt 0
			set labels {}
			foreach line [split [read_file $fn_import] \n\r] {
				incr linecnt
				if {$linecnt == 1} {
					set labels [split $line ,]
					puts "labels: '[join $labels |]'"
					continue
				}

				set parts [split $line ,]
				if {[lindex $parts 0] == "meta"} {
					set metatype [string trim [lindex $parts 9]]
					set metadata [string trim [lindex $parts 10]]
					#puts "metadata: '$metadata' / metatype: '$metatype'"
					if {[string tolower $metatype] == "date"} {
					 	set meta(clock) [iso8601stringparse $metadata]
					} else {
					 	set meta([string tolower $metatype]) $metadata
					 	if {$metadata != ""} {
					 		lappend notes_list "$metatype: $metadata"
					 	}
					}
				} elseif {[lindex $parts 0] == "moment"} {
					set partcnt 0
					unset -nocomplain momentarray
					foreach part $parts {
						set labelname [lindex $labels $partcnt]
						incr partcnt

						set momentarray($labelname) $part
					}

					#puts [array get momentarray]

					if {[ifexists momentarray(elapsed)] != ""} {
						lappend import_espresso_elapsed [ifexists momentarray(elapsed)]
						lappend import_espresso_pressure [return_zero_if_blank [ifexists momentarray(pressure)]]
						lappend import_espresso_weight [return_zero_if_blank [ifexists momentarray(current_total_shot_weight)]]
						lappend import_espresso_flow [return_zero_if_blank [ifexists momentarray(flow_in)]]
						lappend import_espresso_flow_weight [return_zero_if_blank [ifexists momentarray(flow_out)]]
						lappend import_espresso_temperature_basket [return_zero_if_blank [ifexists momentarray(water_temperature_basket)]]
						lappend import_espresso_temperature_mix [return_zero_if_blank [ifexists momentarray(water_temperature_in)]]
					}
				}
			}

			# we have no gravimetric flow data, but we have weight data, then remake the gravimetric flow rate list
			if {[lsort -unique [ifexists import_espresso_flow]] == 0} {
				puts "we have no gravimetric flow data, but we have weight data, so remaking the gravimetric flow rate list using incremental weight data"
				set import_espresso_flow {}
				set previous_weight 0
				set previous_time 0
				set smoothed_flow_rate 0
				set cnt 0

				# smoothing of weight flow data
				set multiplier1 0


				foreach w $import_espresso_weight {
					set this_weight [lindex $import_espresso_weight $cnt]
					set this_time [lindex $import_espresso_elapsed $cnt]

					set diff_weight [expr {$this_weight - $previous_weight}]
					set diff_time [expr {$this_time - $previous_time}]
					if {$diff_time > 0} {
						set diff_weight_per_second [expr {$diff_weight / $diff_time}]					
					} else {
						set diff_weight_per_second 0
					}
					if {$diff_weight_per_second < 0} {
						set diff_weight_per_second 0
					}

					#puts "cnt $cnt: $this_time $this_weight = $diff_weight_per_second"
					set multiplier2 [expr {1 - $multiplier1}];
					set smoothed_flow_rate [expr {($smoothed_flow_rate * $multiplier1) + ($diff_weight_per_second * $multiplier2)}]

					lappend import_espresso_flow $smoothed_flow_rate

					incr cnt
					set previous_weight $this_weight
					set previous_time $this_time
				}
			}

set exportdata [subst {filename [file rootname $file_to_import].shot
name [list [ifexists meta(name)]]
clock $meta(clock)
espresso_elapsed [list $import_espresso_elapsed]
espresso_pressure [list $import_espresso_pressure]
espresso_weight [list $import_espresso_weight]
espresso_flow [list $import_espresso_flow]
espresso_flow_weight [list $import_espresso_flow_weight]
espresso_temperature_basket [list $import_espresso_temperature_basket]
espresso_temperature_mix [list $import_espresso_temperature_mix]
espresso_notes [list [join $notes_list { - }]]
}]

			write_file $fn_export $exportdata

			#puts [array get meta]
			#puts ---
		
		}
	}

}

proc god_shot_files {} {
	import_god_shots_from_common_format

	set files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/godshots/" *.shot]]
	#puts "skin_directories: $dirs"
	set dd {}
	foreach f $files {
	    
	    set fn "[homedir]/godshots/$f"
	    array unset -nocomplete godprops
	    array set godprops [encoding convertfrom utf-8 [read_binary_file $fn]]

	    set name [ifexists godprops(name)]
	    if {$name == "None"} {
	    	set name [translate "None"]
	    } else {
	    	set fnexport "[homedir]/godshots/export/columnar/[file rootname $f].csv"
			if {[file exists $fnexport] != 1} { 
				puts "Exporting God Shot file from $fn to $fnexport" 
				export_csv godprops $fnexport
			}

	    	set fnexport_common "[homedir]/godshots/export/common/[file rootname $f].csv"
			if {[file exists $fnexport_common] != 1} { 
				puts "Exporting God Shot file from $fn to $fnexport_common" 
				export_csv_common_format godprops $fnexport_common
			}

			# keep up to date the list of files to import
			unset -nocomplain import_files_array($f)
	    }
		lappend dd $name $f 
	}

	#puts "god shots: '$dd'"
	return $dd
}



proc fill_god_shots_listbox {} {
	#puts "fill_skin_listbox $widget" 
	unset -nocomplain ::god_shot_filenames
	set widget $::globals(god_shots_widget)
	$widget delete 0 99999

	set cnt 0
	#set ::current_skin_number 0
	array set god_shot_files_array [god_shot_files]
	foreach desc [lsort [array names god_shot_files_array]] {
		set fn $god_shot_files_array($desc)
		$widget insert $cnt $desc
		set ::god_shot_filenames($cnt) $fn

		if {$desc == $::settings(god_espresso_name)} {
			$widget selection set $cnt
			load_god_shot 1
		}
		incr cnt
	}

	#$widget selection set $::current_skin_number
	make_current_listbox_item_blue $widget
	#$widget yview $::current_skin_number
}


proc save_to_god_shots {} {
	if {$::settings(god_espresso_name) == [translate "Saved"] || $::settings(god_espresso_name) == [translate "Updated"] || $::settings(god_espresso_name) == [translate "Ok"]} {
		return
	}


	set ::settings(god_espresso_name) [string trim $::settings(god_espresso_name)]
	if {$::settings(god_espresso_name) == "" || [llength [espresso_pressure range 0 end]] <= 50} {
		# refuse to save if no name or too short
		return 
	}

	#puts "ll2: '[llength [espresso_pressure range 0 end]]'"

	set clock [clock seconds]
	set filename [subst {[clock format $clock -format "%Y%m%dT%H%M%S"].shot}]

	set files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/godshots/" *.shot]]
	#puts "skin_directories: $dirs"
	set dd {}
	set msg [translate "Saved"]
	set updated 0
	foreach f $files {
	    set fn "[homedir]/godshots/$f"
	    array unset -nocomplete godprops
	    array set godprops [encoding convertfrom utf-8[read_binary_file $fn]]
	    if {[ifexists godprops(name)] == $::settings(god_espresso_name)} {
	    	puts "found pre-existing god shot $f with the same description"
	    	set filename $f
	    	set msg [translate "Updated"]
	    	set updated 1

			if {$f == "none.shot"} {
				return
			}

	    	break
	    }
	}

	set espresso_data {}
	append espresso_data "filename [list $filename]\n"
	append espresso_data "name [list $::settings(god_espresso_name)]\n"
	append espresso_data "clock $clock\n"

	append espresso_data "espresso_elapsed {[espresso_elapsed range 0 end]}\n"
	append espresso_data "espresso_pressure {[espresso_pressure range 0 end]}\n"
	append espresso_data "espresso_weight {[espresso_weight range 0 end]}\n"
	append espresso_data "espresso_flow {[espresso_flow range 0 end]}\n"
	append espresso_data "espresso_flow_weight {[espresso_flow_weight range 0 end]}\n"
	append espresso_data "espresso_temperature_basket {[espresso_temperature_basket range 0 end]}\n"
	append espresso_data "espresso_temperature_mix {[espresso_temperature_mix range 0 end]}\n"
	#append espresso_data "espresso_weight {[espresso_weight range 0 end]}\n"

	set fn "[homedir]/godshots/$filename"
	write_file $fn $espresso_data
	
	if {$updated != 1} {
		fill_god_shots_listbox
	}
	puts "save_to_god_shots ran"

	god_shot_save

	after 1000 "set ::settings(god_espresso_name) \{$::settings(god_espresso_name)\}; $::globals(widget_god_shot_save) icursor 999"
	set ::settings(god_espresso_name) $msg

}

proc delete_current_god_shot {} {
	set stepnum [$::globals(god_shots_widget) curselection]
	if {$stepnum == ""} {
		return 
	}
	set f [ifexists ::god_shot_filenames($stepnum)]
	if {$f == "none.shot"} {
		return
	}

	set fn "[homedir]/godshots/$f"
	file delete $fn
	fill_god_shots_listbox

}

proc load_god_shot { {force 0} } {

	if {$::de1(current_context) != "describe_espresso0" && $force == 0} {
		# spurious tk call from Android
		#puts "retruning"
		return 
	}

	set stepnum [$::globals(god_shots_widget) curselection]
	if {$stepnum == ""} {
		return 
	}
	set f [ifexists ::god_shot_filenames($stepnum)]
	#puts "god shot: $stepnum $f"
	if {$stepnum == ""} {
		return
	}

	set fn "[homedir]/godshots/$f"
	array unset -nocomplete godprops
	#array set godprops [read_file $fn]
	array set godprops [encoding convertfrom utf-8 [read_binary_file $fn]]

    set ::settings(god_espresso_pressure) $godprops(espresso_pressure)
    set ::settings(god_espresso_temperature_basket) $godprops(espresso_temperature_basket)
    set ::settings(god_espresso_flow) $godprops(espresso_flow)
    set ::settings(god_espresso_flow_weight) $godprops(espresso_flow_weight)
    #set ::settings(god_espresso_flow) $godprops(espresso_flow)
    #set ::settings(god_espresso_flow_weight) $godprops(espresso_flow_weight)
    set ::settings(god_espresso_weight) $godprops(espresso_weight)
    
    if {[ifexists godprops(espresso_notes)] != ""} {
    	set ::settings(espresso_notes) [ifexists godprops(espresso_notes)]
    }

    if {[llength [ifexists godprops(espresso_elapsed)]] > 0} {
    	set ::settings(god_espresso_elapsed) $godprops(espresso_elapsed)
    }

    # also load the godshot as if it were the most recent espresso
    #array set ::settings [read_file $fn]

    save_settings
    god_shot_reference_reset

	make_current_listbox_item_blue $::globals(god_shots_widget)

	#after 1000 "set ::settings(god_espresso_name) \{$godprops(name)\}; $::globals(widget_god_shot_save) icursor 999"
    #set ::settings(god_espresso_name) [translate "Ok"]
    set ::settings(god_espresso_name) $godprops(name)

}

proc profile_title {} {
	if {$::settings(profile_has_changed) == 1} {
		return "$::settings(profile_title)*"
	} else {
		return $::settings(profile_title)

	}
}

# i = idle (0)
# f = flush (1)
# e = espresso (2)
# s = steam (3)
# w = water (4)
# the number version causes the state to arrive as if the DE1 has caused it, such as from the GHC.  
# This is useful for testing that the GUI responds correctly to GHC caused events.  

# NOTE:
# proc hide_android_keyboard {}, in addition to hiding the on-screen keyboard, keeps the navbar hidden when
# a physical keyboard is connected. This may, however, also redirect keypresses from the physical keyboard.
# Using the CTRL modifier key with the desired key can bypass this issue.

proc handle_keypress {keycode} {
	msg "Keypress detected: $keycode / $::some_droid"

	if {($::some_droid != 1 && $keycode == 101) || ($::some_droid == 1 && $keycode == 8)} {
		# e = espresso (emulate GUI button press)
		start_espresso

	} elseif {($::some_droid != 1 && $keycode == 105) || ($::some_droid == 1 && $keycode == 12)} {
		# i = idle (emulate GUI button press)
		start_idle

	} elseif {($::some_droid != 1 && $keycode == 102) || ($::some_droid == 1 && $keycode == 9)} {
		# f = flush (emulate GUI button press)
		start_flush

	} elseif {($::some_droid != 1 && $keycode == 115) || ($::some_droid == 1 && $keycode == 22)} {
		# s = steam (emulate GUI button press)
		start_steam

	} elseif {($::some_droid != 1 && $keycode == 119) || ($::some_droid == 1 && $keycode == 26)} {
		# w = water (emulate GUI button press)
		start_water

	} elseif {($::some_droid != 1 && $keycode == 112) || ($::some_droid == 1 && $keycode == 19)} {
		# p = sleep (emulate GUI button press)
		start_sleep

	} elseif {($::some_droid != 1 && $keycode == 50) || ($::some_droid == 1 && $keycode == 31)} {
		# 2 = espresso (emulate GHC button press)
		update_de1_state "$::de1_state(Espresso)\x0"
		de1_send_state "make espresso" $::de1_state(Espresso)

	} elseif {($::some_droid != 1 && $keycode == 48) || ($::some_droid == 1 && $keycode == 39)} {
		# 0 = idle (emulate GHC button press)
		update_de1_state "$::de1_state(Idle)\x0"
		de1_send_state "go idle" $::de1_state(Idle)

	} elseif {($::some_droid != 1 && $keycode == 49) || ($::some_droid == 1 && $keycode == 30)} {
		# 1 = flush (emulate GHC button press)
		update_de1_state "$::de1_state(HotWaterRinse)\x0"
		de1_send_state "hot water rinse" $::de1_state(HotWaterRinse)

	} elseif {($::some_droid != 1 && $keycode == 51) || ($::some_droid == 1 && $keycode	== 32)} {
		# 3 = steam (emulate GHC button press)
		update_de1_state "$::de1_state(Steam)\x0"
		de1_send_state "make steam" $::de1_state(Steam)

	} elseif {($::some_droid != 1 && $keycode == 52) || ($::some_droid == 1 && $keycode == 33)} {
		# 4 = water (emulate GHC button press)
		update_de1_state "$::de1_state(HotWater)\x0"
		de1_send_state "make hot water" $::de1_state(HotWater)
	}
}

#install_de1_app_icon
#install_de1plus_app_icon
#install_this_app_icon
