package provide de1_gui 1.3

package require de1_de1 1.1
package require de1_event 1.0
package require de1_logging 1.1
package require de1_plugins 1.0
package require de1_dui 1.0
package require de1_history_viewer 1.1

###
### ::gui namespace defined after globals
###

proc load_skin {} {

	# optional callback for skins, which is reset to normal always, before loading the skin
	eval {
		proc skins_page_change_due_to_de1_state_change { textstate } {
			page_change_due_to_de1_state_change $textstate
		}
	}

	if {[catch {
		source "[skin_directory]/skin.tcl"
	} err opts_dict ] != 0} {
		::logging::log_error_result_opts_dict $err $opts_dict
		catch {
			# reset the skin back to default, if their skin failed to load correctly
			# but don't do so if ::debugging flag is enabled
			if {[ifexists ::debugging] != 1} {
				reset_skin
			}
		}
		catch {
			message_page [subst {[translate "Your choice of skin had an error and cannot be used."]}] [translate "Ok"] [strip_crlf $err]
		}
		msg -ERROR "Failed to 'load_skin' because: '$err'"
		after 10000 exit
	}

	after 10000 check_for_missing_sn
}

proc strip_crlf {in} {
	regsub -all {\r|\n} $in {} out
	return $out
}

proc page_change_due_to_de1_state_change {textstate} {
	if {$textstate == "Idle"} {
		page_display_change $::de1(current_context) "off"
	} elseif {$textstate == "GoingToSleep"} {
		page_display_change $::de1(current_context) "saver" 
		#page_display_change $::de1(current_context) "sleep" 
	} elseif {$textstate == "Sleep"} {
		page_display_change $::de1(current_context) "saver" 
	} elseif {$textstate == "Steam"} {
		page_display_change $::de1(current_context) "steam" 
	} elseif {$textstate == "Espresso"} {
		page_display_change $::de1(current_context) "espresso" 
	} elseif {$textstate == "HotWater"} {
		page_display_change $::de1(current_context) "water" 
	} elseif {$textstate == "Refill"} {
		page_display_change $::de1(current_context) "tankempty" 
	} elseif {$textstate == "SteamRinse"} {
		page_display_change $::de1(current_context) "steamrinse" 
	} elseif {$textstate == "HotWaterRinse"} {
		page_display_change $::de1(current_context) "hotwaterrinse" 
	} elseif {$textstate == "Descale"} {
		page_display_change $::de1(current_context) "descaling" 
	} elseif {$textstate == "Clean"} {
		page_display_change $::de1(current_context) "cleaning" 
	} elseif {$textstate == "AirPurge"} {
		page_display_change $::de1(current_context) "travel_do" 
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
	msg -DEBUG "photoscale $img $sx $sy"
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

	if {[catch {
	    catch {$tmp copy $img -zoom $sx_m $sy_m -compositingrule set} 
	} err] != 0} {
		# note that not all resolution resizes will work. Some take more memory than is available, 
		# especially if the resolution change is a long float, and not an even number (ie, 2560->2559)
		msg -ERROR "photoscale_not_android failed because: '$err'"
	}

    $img blank
    $img copy $tmp -shrink -subsample $sx_f $sy_f -compositingrule set
    image delete $tmp
}


proc photoscale_android {img sx {sy ""} } {
	msg -DEBUG "photoscale $img $sx $sy"
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
	dui page add $names -bg_img $filename
	
}	

proc set_de1_screen_saver_directory {{dirname {}}} {

	# force use of our default saver directory if the black screen saver is enabled, otherwise use whatever the skin chooses
	if {$::settings(screen_saver_change_interval) == 0} {
		set dirname "[homedir]/saver"
	}


	global saver_directory
	if {$dirname != ""} {
		set saver_directory $dirname
	}

	msg -INFO "set_de1_screen_saver_directory: $::saver_directory"

	#set pngfilename [random_saver_file]
	set names "saver"
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

	eval set $varname $finalvalue

}

# on android we track finger-down, instead of button-press, as it gives us lower latency by avoding having to distinguish a potential gesture from a tap
# finger down gives a http://blog.tcl.tk/39474
proc translate_coordinates_finger_down_x { x } {
	return [dui::platform::translate_coordinates_finger_down_x $x]
}
proc translate_coordinates_finger_down_y { y } {
	return [dui platform translate_coordinates_finger_down_y $y ]	
}

proc is_fast_double_tap { key } {
	return [dui platform is_fast_double_tap $key]
}

proc vertical_clicker {bigincrement smallincrement varname minval maxval x y x0 y0 x1 y1 {b 0} } {
	# b = which button was tapped

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
        return $fieldname
    } else {
    	if {$defvalue != ""} {
    		set fieldname $defvalue
    		return $defvalue
    	} else {
    		return ""
    	}
    }
}

proc set_dose_goal_weight {weight} {
	global current_weight_setting
	set current_weight_setting $weight
	.can itemconfig .current_setting_grams_label -text [round_one_digits $weight]
}


proc round_one_digits {amount} {
	set x $amount
	catch {set x [expr round($amount * 10)/10.00]}
	return $x
}

# convert 0 to O symbols. Useful for monospaced fonts.
proc zero_to_o {in} {

	regsub -all 0 $in O out
	return $out
}

proc round_one_digits_or_integer_if_needed {amount} {
	set x $amount
	catch {set x [expr round($amount * 10)/10.00]}

	set y [round_to_integer $amount]
	if {$y == $x} {
		return $y
	}

	return $x
}


proc canvas'textvar {canvas tag _var args} {
	msg -WARNING "Unexpected use of canvas'textvar"
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

	msg -DEBUG "up_down_button_create"

	if {$buttontype != "onetime" && $buttontype != "holdrepeats"} {
		msg -ERROR "unknown buttontype $buttontype"
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
			}
		}

		if {$change == "leave"} {
			if {[ifexists genericstate($btndown)] != "down"} {
				return
			}

			.can itemconfigure $btnup -state normal
			.can itemconfigure $btndown -state hidden
			update
			set genericstate($btndown) "up"
			set genericstate($btnup) ""
		} elseif {$change == "up"} {
			# this is the up button event
			if {$genericstate($btndown) == "up"} {
				return
			}


			.can itemconfigure $btnup -state normal
			.can itemconfigure $btndown -state hidden
			update
			set genericstate($btnup) ""
			if {$genericstate($btndown) != "held"} {
				eval $action
			}
			set genericstate($btndown) "up"
		} else {
			msg -ERROR "unknown action $change"
		}
	}
}

proc generic_button_held {btnup btndown action} {
	global genericstate	

	# button has been pressed down for a while, so activate a down/up press
	if {$genericstate($btndown) == "held" || $genericstate($btndown) == "down"} {
		set genericstate($btndown) "held"		
		eval $action
		update
		after 150 [list generic_button_held $btnup $btndown $action]

	} elseif {$genericstate($btndown) == "up"} {
		#no longer held
	} else {
		msg -ERROR "unknown held state: '$genericstate($btndown)'"
	}
}


proc appdir {} {
	return [file dirname [DirectPathname .]]
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
		set x [borg shortcut add "Update Decent" $appurl $iconbase64_de1]
		msg -NOTICE "shortcut added: '$x'"
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
	msg -DEBUG "appurl: $appurl"
	catch {
		set x [borg shortcut add "DE1" $appurl $iconbase64_de1]
		msg -NOTICE "shortcut added: '$x'"
	}
}


proc install_de1plus_app_icon {} {
	package require base64
	msg -DEBUG "icon file: '[appdir]/de1plus_icon_v2.png'"
	set icondata_de1plus [read_binary_file "[appdir]/de1plus_icon_v2.png"]
	set iconbase64_de1plus [::base64::encode -maxlen 0 $icondata_de1plus]

	set appurl "file://[appdir]/de1plus.tcl"
	#catch {
		set x [borg shortcut add "Decent" $appurl $iconbase64_de1plus]
		msg -NOTICE "shortcut added: '$x'"
	#}
}

proc platform_button_press {} {
	return [dui platform button_press]
}

proc platform_button_native_press {} {
	return {<ButtonPress-1>}
}


proc platform_button_long_press {} {
	return [dui platform button_long_press]
}

proc platform_finger_down {} {
	return [dui platform finger_down]
}

proc platform_button_unpress {} {
	return [dui platform button_unpress]
}


proc add_variable_item_to_context {context label_name varcmd} {
	msg -WARNING "add_variable_item_to_context is DEPRECATED, please use 'dui page add_variable' instead"
	# This may or may not work as dui::page::add_variable takes canvas IDs instead of labels.
	dui::page::add_variable $context $label_name $varcmd
}


proc add_visual_item_to_context {context label_name} {
	dui page add_items $context $label_name
}

# add multiple visuals to multiple contexts
proc add_visual_items_to_contexts { contexts tags } {
    set context_list [split $contexts " "]
    set tag_list [split $tags " " ]
    foreach context $context_list {
        foreach tag $tag_list {
            add_visual_item_to_context $context $tag
        }
    }
}


#set button_cnt 0
proc add_de1_action {context tclcmd} {
	dui page add_action $context show $tclcmd
}

proc add_de1_button {displaycontexts tclcode x0 y0 x1 y1 {options {}}} {
	return [dui add dbutton $displaycontexts $x0 $y0 $x1 $y1 -command $tclcode -theme none]
}

# truncates strings that are too long to display and add a ...message on the end.
proc maxstring {in maxlength {optmsg {}} } {
	if {[string length $in] > $maxlength} {
		return "[string range $in 0 $maxlength]...$optmsg"
	}

	return $in
}

# truncates strings that are too long to display and add a ...message on the end.
# this version counts paragraph breaks as having "crlfequiv" equivalent characters
proc maxstring_with_crlf_count {in maxlength crlfequiv {optmsg {}} } {

	set crlfs [regexp -all {\n\n} [string range $in 0 $maxlength]]
	set thislen [expr {[string length $in] + ($crlfs * $crlfequiv)}]
	if {$thislen > $maxlength} {
		return "[string range $in 0 [expr {$maxlength - ($crlfs * $crlfequiv)}]]...$optmsg"
	}

	return $in
}

#set text_cnt 0
proc add_de1_text {args} {
	return [dui add dtext [lindex $args 0] [lindex $args 1] [lindex $args 2] -compatibility_mode 1 {*}[lrange $args 3 end]]
}

# text widget that has variable fonts/properties in it, and any element can be tappable. If refresh=1 then it is updated at 10hz
#
# example:
#
# add_de1_rich_text $pages 1020 160 [list \
# 	[list -text "This is a long text" -font "Inter-Bold11" -foreground black -exec "puts 1" ] \
# 	[list -text " " -font "Inter-Bold11"] \
# 	[list -text "widget with multiple" -font "Inter-Bold16" -foreground blue -exec "puts 2" ] \
# 	[list -text " " -font "Inter-Bold11"] \
# 	[list -text "fonts on one line." -font "Inter-Bold24" -foreground red -exec "puts 3" ] \
# ]

# justification can be left/right/middle and if it is a list, the 2nd parameter is the wrapping, ie char/word/none, ie:
# add_de1_rich_text "off espresso" 690 330 [list left none] 1 2 74 $::background_color $btns

proc add_de1_rich_text {context x y justification autorefresh height width backgroundcolor textparts args} {

	set name "rich_${x}_${y}_"
	set code ""
	#set height 2
	set startpos 0
	set endpos 0
	set cnt 0
	set font ""


	# find the name of the first font mentioned and use that to size this line
	foreach text $textparts {
		incr cnt

		set opts ""
		set txt ""
		set exec ""
		foreach {k v} $text {
			if {$k == "-font"} {
				set font $v
			}
		}
		if {$font != ""} {
			break
		}
	}


	#optional wrapping directive on the justification line
	set wrap word
	if {[lindex $justification 1] != ""} {
		set wrap [lindex $justification 1]
	}
	set justification [lindex $justification 0]

	set widget [add_de1_widget $context "text" $x $y "" -relief flat  -highlightthickness 0 -insertwidth 0 -height $height -background $backgroundcolor  -selectbackground $backgroundcolor -highlightbackground $backgroundcolor  -inactiveselectbackground $backgroundcolor  -insertbackground $backgroundcolor -selectbackground $backgroundcolor -highlightbackground $backgroundcolor -font $font -width $width -wrap $wrap]
	
	foreach text $textparts {
		incr cnt

		set opts ""
		set txt ""
		set exec ""
		foreach {k v} $text {
			# allow options of -text -exec and anything else is passed along to the text widget. We implement -text and -exec ourselves
			if {$k == "-text"} {
				set txt $v
			} elseif {$k == "-exec"} {
				set exec $v
			} else {
				append opts " $k $v "
			}
		}

		#if {$txt != ""} {
			set endpos [expr {$startpos + [string length $txt]}]

			# create and configure the tags that define the look of this chunk of text
			append codetags [subst {\n\t$widget tag configure tag_$name$cnt $opts -justify $justification\n\t$widget tag add tag_$name$cnt 1.$startpos 1.$endpos\n}]

			# need to protect quotes since this is making code that will execute in the future, and the string itself is quoted
			regsub -all {"} $txt {\\"} txt

			# insert the text as a separate step, so that we don't needlessly recreate tags when refreshing this
			append codetext [subst {\t$widget insert end "$txt" tag_$name$cnt\n}]			

			if {$exec != ""} {
				# if there's a tap action on this text, define it once as part of the tags
				append codetags [subst {\t$widget tag bind tag_$name$cnt \[platform_button_press\] {$exec}\n}]
			}
		#}

		set startpos $endpos

	}

	# for some reason, the -anchor option is not available at creation time, but it is available later as a configuration option.
	# and it's essential for the correct positioning of the widget when right aligned
	if {$justification == "right"} {
		.can itemconfigure $widget -anchor ne		
	}

	# this will list all parameters in the widget, useful for debugging
	# msg -ERROR [join [lmap c [$widget configure ] {if {[llength $c] == 2} continue; lindex $c 0}] \n]

	bindtags $widget [list SdlTkNoTextInput {*}[bindtags $widget]]

	# create the tags for this widget
	eval $codetags

	# create a function which updates the text on the widget, and run that once, allowing other functions to now refresh at will
	#
	# example refresh approach:
	# set toprightbtns [add_de1_rich_text $pages 2500 44 "Inter-Bold12" ...
	# trace add variable ::water_level write ::refresh_$toprightbtns

	set proccode [subst {proc ::refresh_$widget \{args\} \{ $widget delete 1.0 end\n$codetext \} }]
	eval $proccode
	::refresh_$widget

	if {$autorefresh == 1} {
		dui page add_action $context update_vars ::refresh_$widget
	}

	return $widget
}



#set image_cnt 0
proc add_de1_image {args} {
	return [dui add image [lindex $args 0] [lindex $args 1] [lindex $args 2] [lindex $args 3] -theme none]
}


# derivced from sample code at http://wiki.tcl.tk/17067
#set widget_cnt 0
proc add_de1_widget {args} {
	return [dui add widget [lindex $args 1] [lindex $args 0] [lindex $args 2] [lindex $args 3] -tclcode [lindex $args 4] \
		-theme none {*}[lrange $args 5 end]]
}


proc add_de1_variable {args} {
	set varcmd [lindex [unshift args] 0]
	set lastcmd [unshift args]
	if {$lastcmd != "-textvariable"} {
		msg -WARN add_de1_variable "last -command needs to be -textvariable on a add_de1_variable line. You entered: '$lastcmd'"
		return
	}
	
	return [dui add variable [lindex $args 0] [lindex $args 1] [lindex $args 2] -compatibility_mode 1 \
		-textvariable $varcmd {*}[lrange $args 3 end]]
	
#	set contexts [lindex $args 0]
#	set label_name [eval add_de1_text $args]
#
#	# john 24-1-20 now unneeded code https://3.basecamp.com/3671212/buckets/7351439/messages/2360038011
#	#set x [rescale_x_skin [lindex $args 1]]
#	#set y [rescale_y_skin [lindex $args 2]]
#	#set torun [concat [list .can create text] $x $y [lrange $args 3 end] -tag $label_name -state hidden]
#	#eval $torun
#	#incr ::text_cnt
#
#	foreach context $contexts {
#		# keep track of what labels are displayed in what contexts
#		add_variable_item_to_context $context $label_name $varcmd
#	}
#	return $label_name
}

proc stop_screen_saver_timer {} {

	if {[info exists ::screen_saver_alarm_handle] == 1} {
		after cancel $::screen_saver_alarm_handle
		unset -nocomplain ::screen_saver_alarm_handle
	}

	if {[info exists ::steam_eco_alarm_handle] == 1} {
		after cancel $::steam_eco_alarm_handle
		unset -nocomplain ::steam_eco_alarm_handle
	}

}


proc delay_screen_saver {} {

	stop_screen_saver_timer

	if {$::settings(screen_saver_delay) != 0 } {
		set ::screen_saver_alarm_handle [after [expr {60 * 1000 * $::settings(screen_saver_delay)}] "show_going_to_sleep_page"]
	}

	# if the timers are active, then find the next alarm time and set an alarm to wake in that many milliseconds from now
	if {$::settings(eco_steam) == 1} {
		# ten minute eco 
		set ::steam_eco_alarm_handle [after [expr {$::de1(steam_eco_delay_seconds) * 1000}] do_eco_steam]

		if {$::de1(in_eco_steam_mode) == 1} {
			# return steam to normal temperature
			msg -INFO "Disabling steam eco mode"
			set ::de1(in_eco_steam_mode) 0
			de1_send_steam_hotwater_settings
		}
	}
}

proc after_info {} {

	set t {}
	foreach id [after info] {
		append t $id:[after info $id]\n
	}
	return $t
}

proc do_eco_steam {} {
	msg -INFO "Enabling steam eco mode ($::de1(steam_eco_temperature)C)"
	set ::de1(in_eco_steam_mode) 1
	de1_send_steam_hotwater_settings
}

proc show_going_to_sleep_page  {} {

	if {$::settings(scheduler_enable) == 1} {
		set wake [current_alarm_time $::settings(scheduler_wake)]
		set sleep [current_alarm_time $::settings(scheduler_sleep)]
		if {[clock seconds] > $wake && [clock seconds] < $sleep} {
			msg -INFO "Delaying screen saver because we are during scheduled forced-awake time"
			delay_screen_saver
			return
		}
	}

	if {$::de1_num_state($::de1(state)) != "Idle" && $::de1_num_state($::de1(state)) != "Refill"} {
		# never go to sleep if the DE1 is not idle
		msg -INFO "delaying screen saver because de1 is not idle: '$::de1_num_state($::de1(state))'"
		delay_screen_saver
		return
	}

    if {[ifexists ::app_updating] == 1} {
		msg -INFO "delaying screen saver because tablet app is updating"
		delay_screen_saver
		return
	}

	if {$::de1(currently_updating_firmware) == 1 || [ifexists ::de1(in_fw_update_mode)] == 1} {
		msg -INFO "delaying screen saver because firmware is updating"
		delay_screen_saver
		return
	}	



	msg -INFO "show_going_to_sleep_page"
 	if {$::de1(current_context) == "sleep" || $::de1(current_context) == "saver"} {
 		return
 	}

	page_display_change $::de1(current_context) "saver"
	#page_display_change $::de1(current_context) "sleep"
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
		return
	}

	#if {$::de1(current_context) == "saver"} {
		#catch {
			# image delete is not needed, as Tk silently replaces the existing image if the object has the same name
			#image delete saver
		#}

		set fn [random_saver_file]

		set err ""
		set errcode [catch {
			# this can happen during an upgrade
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

	check_front_switch
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
		return [translate Connected]
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

proc display_popup_android_message_if_necessary {msg} {

	if {[string first "*" $msg] != -1} {
		# beep if a * is found in the description
		borg beep
		return
	}

	if {[string first "tare" $msg] != -1} {
		if {$::de1(scale_weight) != ""} {
			# tare command found in step message
			::device::scale::tare
			return
		}
	}

	#set msg ""
	#regexp {\[(.*?)\]} $intxt discard msg

	if {$msg != ""} {

		# replace $weight with the weight

		set weight [drink_weight_text]
		set timer [espresso_timer_text]
		set pressure [pressure_text]

		if {[catch {
			set msg [string trim [subst $msg]]
		} err] != 0} {
			msg -ERROR "display_popup_android_message_if_necessary failed because: '$err'"
		}

		# post the message 1 second after the start, so that there's a slight delay 
		if {$msg != ""} {
			after 1000 [list popup $msg]
			#msg -DEBUG "Popup: $msg"
		}
	}
	
}

# For JB's GUI-driver, get some reasonable "t0" to derive DE1 SampleTime
# It also needs the period, in seconds, which can't be determined from the DE1
# ::settings() hasn't been loaded as this point, nor has ::machine(hertz)

# With no viable information available, hard-wire 50 Hz for now

if {$::android == 0} {
	namespace eval ::gui {
		variable _arbitrary_t0 [expr { [clock milliseconds] / 1000.0 }]
		variable _st_period [expr { 1.0 / ( 2.0 * 50 ) }]
		msg -DEBUG "GUI driver using 50 Hz, hard-wired, for DE1 SampleTime"
	}
}

set _last_st 0

# TODO (EB): Move the first part of this proc to a parametrized action run from 'dui page update_onscreen_variables'
proc update_onscreen_variables { {state {}} } {
	dui page update_onscreen_variables
	return
}

# Define fake / dummy espresso variables on workstations
proc set_dummy_espresso_vars {} {

	set ::settings(do_realtime_espresso_simulation) 0

	if { $::android } { return }

	if {$::de1(state) != 4} {
		return
	}

	if {$::de1(state) == 4} {
		if {$::de1(substate) == 1} {
			# espresso is starting
			::device::scale::init
			set ::de1(scale_device_handle) 1
			set ::simindex  0

			open_random_simulation_file	

			# playing a random history item also means loading it as the current profile, otherwise it's weird and things don't line up
			array set simulation_settings [ifexists ::simulated(settings)]
			
			# only load the actually needed variables from the saved shot simulation, not the entire setting file therein.  
			# previously loaded all settings from the simulation, and this caused bugs to occur in DYE since we'd clobbered some settings it was depending on
			foreach varname [profile_vars] {
				set ::settings($varname) [ifexists simulation_settings($varname)]
			}
			
			# reset the current_frame_number when we load the shot to simulate it, because it's not being correctly reset by a DE1 event
			set ::de1(current_frame_number) -1

			# this is the final drink weight, a few seconds after the shot stopped. We don't currently do anything with this for simulated shots.
			# set ::de1(simulated_drink_weight) [ifexists ::settings(drink_weight)]

			update_de1_state "$::de1_state(Espresso)\x4"
		}

		if {$::settings(do_realtime_espresso_simulation) != 1} {
			incr ::simindex

		} else {

			
			if {[llength [ifexists ::simulated(espresso_pressure)]] > 0} {

				set t [expr {[espresso_millitimer] / 1000.0}]

				set cnt 0
				foreach i $::simulated(espresso_elapsed) {
					incr cnt
					#puts "compare $i > $t"
					if {$i > $t} {
						break
					}
				}


				set ::simindex $cnt
				if {$::simindex == [ifexists ::previous_simindex]} {
					set ::previous_simindex $::simindex
					return
				}

				set ::previous_simindex $::simindex

			}			
		}

		if {$::simindex >= [llength [ifexists ::simulated(espresso_pressure)]]} {
			# end of data
			 update_de1_state "$::de1_state(Idle)\x0"
			 return
		}

	}

	if {[info exists ::simindex] != 1} {
		set ::simindex 0
	}



	# JB's GUI driver needs an event_dict

	# NB: This seems to be getting called at a 10 Hz rate
	#     which is faster than the DE1's 25/(2 * line frequency)
	set _now [expr {[clock milliseconds] / 1000.0}]

	# SampleTime is a 16-bit counter of zero crossings
	set _de1_sample_time [expr { int( ( $_now - $::gui::_arbitrary_t0 ) / $::gui::_st_period ) % 65536 }]


	if {$::de1(substate) == 4} {
		# track the end of preinfusion
		#puts [array names ::simulated]
		#exit
		set x "timers(espresso_preinfusion_stop)"
		set espresso_preinfusion_stop $::simulated($x)
		set x "timers(espresso_preinfusion_start)"
		set espresso_preinfusion_start $::simulated($x)
		#set espresso_preinfusion_start $::simulated(timers(espresso_preinfusion_start))
		#puts "pre $espresso_preinfusion_stop "
		set diff_pre [expr {($espresso_preinfusion_stop - $espresso_preinfusion_start)/10}]
		#puts "pre $espresso_preinfusion_stop / $espresso_preinfusion_start = $diff_pre > $_de1_sample_time"
		#exit
	}

	set espresso_water_dispensed 0

	if {$::de1(substate) == 4 || $::de1(substate) == 5} {
		# espresso preinfusion or pouring, get data from simulation

		catch {
			set ::de1(pressure) [lindex $::simulated(espresso_pressure) $::simindex]
		}
		if {[info exists ::de1(pressure)] != 1} {
			set ::de1(pressure) 8.1
		}

		catch {
			set ::de1(flow) [lindex $::simulated(espresso_flow) $::simindex]
		}
		if {[info exists ::de1(flow)] != 1} {
			set ::de1(flow) 1.1
		}

		catch {
			set ::de1(mix_temperature) [lindex $::simulated(espresso_temperature_mix) $::simindex]
		}
		if {[info exists ::de1(mix_temperature)] != 1} {
			set ::de1(mix_temperature) 90
		}

		catch {
			set ::de1(head_temperature) [lindex $::simulated(espresso_temperature_basket) $::simindex]
		}
		if {[info exists ::de1(head_temperature)] != 1} {
			set ::de1(head_temperature) 90
		}

		catch {
			set ::de1(goal_temperature) [lindex $::simulated(espresso_temperature_goal) $::simindex]
		}
		if {[info exists ::de1(goal_temperature)] != 1} {
			set ::de1(goal_temperature) 90
		}


		catch {
			set ::de1(goal_pressure) [lindex $::simulated(espresso_pressure_goal) $::simindex]
		}
		if {[info exists ::de1(goal_pressure)] != 1} {
			set ::de1(goal_pressure) 8.3
		}

		catch {
			set ::de1(goal_flow) [lindex $::simulated(espresso_flow_goal) $::simindex]
		}
		if {[info exists ::de1(goal_flow)] != 1} {
			set ::de1(goal_flow) 2.3
		}

		catch {
			#set ::de1(scale_weight) [lindex $::simulated(espresso_weight) $::simindex]
			#set ::de1(scale_sensor_weight) $::de1(scale_weight)
			#set ::settings(running_weight) $::de1(scale_weight)
			::device::scale::process_weight_update [lindex $::simulated(espresso_weight) $::simindex]
		}
		if {[info exists ::de1(scale_weight)] != 1} {
			set ::de1(scale_weight) 8.3
		}

		catch {
			set ::de1(scale_weight_rate) [lindex $::simulated(espresso_flow_weight) $::simindex]
		}
		if {[info exists ::de1(scale_weight_rate)] != 1} {
			set ::de1(scale_weight_rate) 1.4
		}


		catch {
			set espresso_water_dispensed [expr {10.0 * [lindex $::simulated(espresso_water_dispensed) $::simindex] }]
		}		

		

		set this_state [::de1::state::current_state]
		set this_substate [::de1::state::current_substate]

		# track water volume
		if {$this_state == "Espresso"} {
			if {$this_substate == "preinfusion"} {
				set ::de1(preinfusion_volume) [round_to_two_digits $espresso_water_dispensed]
			} else {
				set ::de1(pour_volume) [round_to_two_digits [expr {$espresso_water_dispensed - $::de1(preinfusion_volume)}]]
			}
		}

		#puts "ERROR $::de1(state) espresso_water_dispensed: $::simindex : $espresso_water_dispensed ($this_state : $this_substate )  $::de1(preinfusion_volume)ml/$::de1(pour_volume)ml"

		if {$::simindex > 0} {
			if {[lindex $::simulated(espresso_state_change) $::simindex] != [lindex $::simulated(espresso_state_change) $::simindex-1]} {
				incr ::de1(current_frame_number)

				if {$::settings(settings_profile_type) ==  "settings_2c"} {
					array set parts [lindex $::settings(advanced_shot) $::de1(current_frame_number)]
					if {[ifexists parts(popup)] != ""} {
						msg -ERROR "profile has a popup message in frame $::de1(current_frame_number): '[ifexists parts(popup)]'"
						display_popup_android_message_if_necessary $parts(popup)
					}
				}
				

				if {$::simindex > 60 &&  $::de1(substate) == 4} {
					update_de1_state "$::de1_state(Espresso)\x5"
				}

			}
		}
	}

	set event_dict [dict create \
		event_time 	$_now \
		update_received	$_now \
		SampleTime	$_de1_sample_time \
		GroupPressure	$::de1(pressure) \
		scale_weight	$::de1(scale_weight) \
		GroupFlow	$::de1(flow) \
		MixTemp		$::de1(mix_temperature) \
		HeadTemp	$::de1(head_temperature) \
		SetHeadTemp	$::de1(goal_temperature) \
		SetGroupPressure $::de1(goal_pressure) \
		SetGroupFlow	$::de1(goal_flow) \
		FrameNumber	$::de1(current_frame_number) \
		SteamTemp	$::de1(steam_heater_temperature) \
		this_state	[::de1::state::current_state] \
		this_substate	[::de1::state::current_substate] \
	]

	if {$::de1(state) == 4} {
		::de1::event::apply::on_shotvalue_available_callbacks $event_dict

	} elseif {$::de1(state) == 5} {
		#steaming
		::de1::event::apply::on_shotvalue_available_callbacks $event_dict
	}	
}

proc set_next_page {machinepage guipage} {
	set key "machine:$machinepage"
	set ::nextpage($key) $guipage
}

proc show_settings { {tab_to_show ""} {optional_callback ""} } {
	backup_settings; 

	set ::settings_optional_callback $optional_callback

	msg -INFO "show_settings"

    if {$::android == 1} {
		if {[borg networkinfo] == "none"} {
        	set ::de1(app_update_button_label) [translate "No Wifi network"];
    	}	
    }

	if {$tab_to_show == ""} {
		page_to_show_when_off $::settings(active_settings_tab)
		scheduler_feature_hide_show_refresh
	} else {
		page_to_show_when_off $tab_to_show
	}
	after idle {
		set_profiles_scrollbar_dimensions
		set_advsteps_scrollbar_dimensions
	}

	update_de1_explanation_chart
	fill_advanced_profile_steps_listbox
	load_advanced_profile_step 1

}

proc check_if_should_send_user_present_notice {} {

	catch {
		set seconds_since_last_idle_update [expr {[clock seconds] - $::globals(time_last_idle_update)}]
		#msg -INFO "check_if_should_send_user_present_notice '$::de1_num_state($::de1(state))' - $seconds_since_last_idle_update"
		if {$::de1_num_state($::de1(state)) == "Idle"} {
			if {[info exists ::globals(sent_scheduled_idle)] == 1} {
				# we just caused a scheduled idle, no need to indicate user is present
				#msg -INFO "scheduler_idle does not cause user-present notice"
			} elseif {$seconds_since_last_idle_update > 30} {
				set_user_present
				set ::globals(time_last_idle_update) [clock seconds]
				#msg -INFO "updating time_last_idle_update and setting user-not-idle"		
			} else {
				#msg -INFO "NOT updating time_last_idle_update and setting user-not-idle"		
			}
		}
	}
}

proc page_to_show_when_off {page_to_show args} {
	set_next_page off $page_to_show
	dui page load $page_to_show {*}$args
	check_if_should_send_user_present_notice
#	page_show $page_to_show
}

proc page_show {page_to_show args} {

	if {$::settings(show_elapsed_time_to_load_pages) == 1} {
		set start [clock milliseconds]
		dui page load $page_to_show {*}$args
		check_if_should_send_user_present_notice
		set end [clock milliseconds]
		set elapsed [expr {$end - $start}]
		popup "$page_to_show: $elapsed"
	} else {
		dui page load $page_to_show {*}$args
		check_if_should_send_user_present_notice
	}

}

proc display_brightness {percentage} {
	set percentage [check_battery_low $percentage]
	get_set_tablet_brightness $percentage
}


proc page_display_change {page_to_hide page_to_show args} {
	dui page load $page_to_show {*}$args
	check_if_should_send_user_present_notice
}

proc adjust_machine_nextpage { page_to_hide page_to_show } { 
	set key "machine:$page_to_show"
	if {[ifexists ::nextpage($key)] != ""} {
		# there are different possible tabs to display for different states (such as preheat-cup vs hot water)
		return $::nextpage($key)
	}
	return 1
}

proc hide_android_keyboard {} {
	dui platform hide_android_keyboard
}

proc update_de1_explanation_chart_soon  { {context {}} } {
	# we can optionally delay displaying the chart until data from the slider stops coming
	#update_de1_explanation_chart
	#return
	
	#after 10 {after cancel update_de1_explanation_chart; after idle update_de1_explanation_chart}
	if {[info exists ::chart_update_id] == 1} {
		after cancel $::chart_update_id; 
		unset -nocomplain ::chart_update_id
	}

	set ::chart_update_id [after idle update_de1_explanation_chart]
	#after idle update_de1_explanation_chart
}

proc update_de1_explanation_chart { {context {}} } {

	if {[string range $::de1(current_context) 0 7] != "settings" && $::settings(skin) != "Insight" && $::settings(skin) != "Insight Dark" && $::settings(skin) != "MimojaCafe"} {
		# only Insight and MimojaCafe skin needs this feature, or if you are currently looking at a Settings tab
		return {}
	}


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

	if {$::settings(skin) == "Insight" || $::settings(skin) == "Insight Dark" || $::settings(skin) == "MimojaCafe"} {
		clear_espresso_chart
	}

	if {$::settings(settings_profile_type) == "settings_2b"} {
		update_de1_plus_flow_explanation_chart
	    espresso_de1_explanation_chart_elapsed append [espresso_de1_explanation_chart_elapsed_flow range 0 end]
		return
	} elseif {$::settings(settings_profile_type) == "settings_2c" || $::settings(settings_profile_type) == "settings_2c2"} {
		# advanced shots currently get no graphic preview
		update_de1_plus_advanced_explanation_chart
		return
	}


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

	if {$approximate_ramptime > $pressure_hold_time} {
		set espresso_pressure [expr {$pressure_hold_time * 2}]
	}



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

	if {[ifexists props(temperature)] == ""} {
		msg -ERROR "Empty props(temperature) received by update_de1_plus_advanced_explanation_chart"
		return
	}
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


		set theseconds [ifexists props(seconds)]
		set transition [ifexists props(transition)]


		if {[expr {$cnt - 1}] == [ifexists ::current_step_number]} {
			set selected_step_value [expr {-1 * $selected_step_value}]
		}

		if {$pump == "pressure"} {

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
	
	msg -DEBUG "setup_images_for_first_page"
	set fn [dui::image::find "splash.jpg"]

	if {$fn == "" || ![file exists $fn]} {
		msg "skin/splash.jpg does not exist. Using default wallpaper"
		set fn [random_splash_file]
	}
	image create photo splash -file $fn 
	.can create image {0 0} -anchor nw -image splash -tag splash -state normal
	
	update
	return
}

proc run_de1_app {} {
	page_display_change "splash" "off"
}
package require de1_shot 2.0

proc ui_startup {} {
	
	load_settings

	# Metric is now uppercase, so this is translation code
	if { $::settings(skin) eq "metric" } {
		set ::settings(skin) "Metric"
	}

	#::profile::sync_from_legacy	
	setup_environment

	bluetooth_connect_to_devices

	if {[ifexists ::settings(enable_shot_history_export)] == "1"} {
		shot_history_export
	}

	shot_history_upload_to_decent

	if {[ifexists ::settings(mark_most_popular_profiles_used)] == "1"} {
		shot_history_count_profile_use
	}
	#ble_find_de1s

	setup_images_for_first_page
	setup_images_for_other_pages
	history_viewer init

	plugins init

	set app_version [package version de1app]

	if {$::settings(last_version) != $app_version  && [ifexists ::settings(app_updates_beta_enabled)] < 2} {
		if {$::settings(espresso_count) == 0} {
			set message "You are running Version $app_version."
		} else {
			set message "Version updated from $::settings(last_version) to $app_version."
		}
		if {[ifexists ::changelog_link] != ""} {
			set message "$message\n Tap here to open the latest changelog"
		}
		version_page $message [translate "Ok"]
		set ::settings(last_version) $app_version
		save_settings
	}

	# auto-setup of DUI pages. dui init and setting of folders may need to be done before skin & plugins inits?
	#dui init
	dui font add_dirs "[homedir]/fonts"
	dui item add_image_dirs "[homedir]/skins/$::settings(skin)" "[homedir]/skins/default"
	dui setup_ui

	.can itemconfigure splash -state hidden
	
	#after $::settings(timer_interval) 
	update_onscreen_variables
	delay_screen_saver
	change_screen_saver_img

	check_if_battery_low_and_give_message

	# check for app updates, some time after startup, and then every 24h thereafter
	if {$::settings(do_async_update_check) == 1} {
		# no need to delay doing a remove update check, if we're doing it async
		#after 500 scheduled_app_update_check
	} else {
		#after 3000 scheduled_app_update_check
	}

	schedule_app_update_check
	tcl_introspection
	run_de1_app

	if {$::settings(benchmark_gui) == "1"} {
		benchmark_gui
	}

	vwait forever
}

package require snit
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


proc benchmark_gui  {} {

	set ::time_start [clock milliseconds]

	set pages [list "off" "steam_1" "water_1" "preheat_1" "off" "steam_1" "water_1" "preheat_1" "off" "steam_1" "water_1" "preheat_1" "off" "steam_1" "water_1" "preheat_1" "off" "steam_1" "water_1" "preheat_1" "off" "steam_1" "water_1" "preheat_1" "off" "steam_1" "water_1" "preheat_1"]

	foreach page $pages {
		page_show $page
		update
	}

	set ::time_end [clock milliseconds]

	set elapsed [expr {$::time_end - $::time_start}]
	popup "Elapsed: $elapsed"
	puts "Elapsed: $elapsed"

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


	if {[info exists ::water_level_color_check_count] != 1} {
		set ::water_level_color_check_count  0
	}
	incr ::water_level_color_check_count 
	set colors [list  "#7ad2ff"  "#ff6b6b"]

	if {[ifexists ::insight_dark_mode] == 1} {
		set colors [list  "#003e5d"  "#790000"]
	}

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

	catch {
		$widget configure -background $color
	}
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
		msg -NOTICE "Calibration disabled Fahrenheit" \
			"::settings(enable_farenheit) has been set to 0"
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
		#after 3000 get_calibration_flow_multiplier
		#after 3000 de1_read_calibration "flow"

		after 4000 de1_read_calibration "temperature" "factory"
		after 5000 de1_read_calibration "pressure" "factory"
		#after 6000 de1_read_calibration "flow" "factory"


	}
}

proc import_god_shots_from_common_format {} {


	set import_files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/godshots/import/common/" *.csv]]
	foreach import_file $import_files {
		set import_files_array($import_file) 1
	}

	set files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/godshots/" *.shot]]
	set dd {}
	foreach f $files {
		unset -nocomplain import_files_array($f)
	}

	set files_to_import [array names import_files_array]
	if {$files_to_import != ""} {
		foreach file_to_import $files_to_import {
			set fn_import "[homedir]/godshots/import/common/$file_to_import"
			set fn_export "[homedir]/godshots/[file rootname $file_to_import].shot"
			if {[file exist $fn_export] == 1} {
				continue
			}
			msg -INFO "Importing common file format into god shot from '$fn_import' to '$fn_export'"

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
					msg -DEBUG "labels: '[join $labels |]'"
					continue
				}

				set parts [split $line ,]
				if {[lindex $parts 0] == "meta"} {
					set metatype [string trim [lindex $parts 9]]
					set metadata [string trim [lindex $parts 10]]
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
				msg -DEBUG "we have no gravimetric flow data, but we have weight data, so remaking the gravimetric flow rate list using incremental weight data"
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
		}
	}
}

proc god_shot_files {} {
	import_god_shots_from_common_format

	set files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/godshots/" *.shot]]
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
				msg -INFO "Exporting God Shot file from $fn to $fnexport" 
				export_csv godprops $fnexport
			}

	    	set fnexport_common "[homedir]/godshots/export/common/[file rootname $f].csv"
			if {[file exists $fnexport_common] != 1} { 
				msg -INFO "Exporting God Shot file from $fn to $fnexport_common" 
				export_csv_common_format godprops $fnexport_common
			}

			# keep up to date the list of files to import
			unset -nocomplain import_files_array($f)
	    }
		lappend dd $name $f 
	}

	return $dd
}



proc fill_god_shots_listbox {} {
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


	set clock [clock seconds]
	set filename [subst {[clock format $clock -format "%Y%m%dT%H%M%S"].shot}]

	set files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/godshots/" *.shot]]
	set dd {}
	set msg [translate "Saved"]
	set updated 0
	foreach f $files {
	    set fn "[homedir]/godshots/$f"
	    array unset -nocomplete godprops
	    array set godprops [encoding convertfrom utf-8[read_binary_file $fn]]
	    if {[ifexists godprops(name)] == $::settings(god_espresso_name)} {
	    	msg -NOTICE "found pre-existing god shot $f with the same description"
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
	msg -INFO "save_to_god_shots ran"

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
		return 
	}

	set stepnum [$::globals(god_shots_widget) curselection]
	if {$stepnum == ""} {
		return 
	}
	set f [ifexists ::god_shot_filenames($stepnum)]
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

proc profile_title { {filename {}} } {

	if {$filename == ""} {
		# no filename given, so it's the current profile title
		if {$::settings(profile_has_changed) == 1} {
			return "$::settings(profile_title)*"
		} else {
			return $::settings(profile_title)

		}
	}

	# or give it a filename to fetch the title 
	catch {
		set fn "[homedir]/profiles/${filename}.tcl"
		foreach {k v} [encoding convertfrom utf-8 [read_binary_file $fn]] {
			set temp_settings($k) $v
		}
	}

	#puts "ERROR profile_title [ifexists temp_settings(profile_title)]"
	return [ifexists temp_settings(profile_title)]

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
	msg -DEBUG "Keypress detected: $keycode / $::some_droid"

	if {($::some_droid != 1 && $keycode == 101) || ($::some_droid == 1 && $keycode == 8)} {
		# e = espresso (emulate GUI button press)
		start_espresso

	} elseif {($::some_droid != 1 && $keycode == 105) || ($::some_droid != 1 && $keycode == 32) || ($::some_droid == 1 && $keycode == 12) || ($::some_droid == 1 && $keycode == 44)} {
		# i (or space bar) = idle (emulate GUI button press) 
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
		start_espresso

	} elseif {($::some_droid != 1 && $keycode == 48) || ($::some_droid == 1 && $keycode == 39)} {
		# 0 = idle (emulate GHC button press)
		start_sleep

	} elseif {($::some_droid != 1 && $keycode == 49) || ($::some_droid == 1 && $keycode == 30)} {
		start_flush

	} elseif {($::some_droid != 1 && $keycode == 51) || ($::some_droid == 1 && $keycode	== 32)} {
		# 3 = steam (emulate GHC button press)
		start_steam

	} elseif {($::some_droid != 1 && $keycode == 52) || ($::some_droid == 1 && $keycode == 33)} {
		# 4 = water (emulate GHC button press)
		start_water
	}
}

#install_de1_app_icon
#install_de1plus_app_icon
#install_this_app_icon


namespace eval ::gui::state {


	# ::state_change_chart_value -- also used by append_live_data_to_espresso_chart

	variable _state_change_chart_value 10000000

	# As GUI updates can be asynchronous to DE1 state changes
	# keep track of the GUI's state separately

	# -1 is retained from the previous logic as an indicator
	# to not draw a frame separator at the start of the shot
	# as well as to set the current_frame_description
	# See further that previous logic now in
	# ::gui::update::shot_frame_info

	variable _previous_framenumber -1
	variable _current_framenumber -1

	proc init {} {

		::gui::state::reset_framenumbers
		::gui::state::reset_shotsample_deltas
		msg -DEBUG "::gui::state::init done"
	}

	proc reset_framenumbers {} {

		set ::gui::state::_current_framenumber -1
		set ::gui::state::_previous_framenumber -1
	}

	proc current_framenumber {} {
		return $::gui::state::_current_framenumber
	}

	proc previous_framenumber {} {
		return $::gui::state::_previous_framenumber
	}

	proc reset_shotsample_deltas {} {

		set ::gui::state::_delta_flow 0
		set ::gui::state::_delta_pressure 0
		set ::gui::state::_previous_flow 0
		set ::gui::state::_previous_pressure 0
	}

} ;# ::gui::state

::de1::event::listener::on_connect_add [lambda {args} {
	::gui::state::reset_framenumbers
	::gui::state::reset_shotsample_deltas
}]


# JB's off-line GUI driver needs some variables initialized
# that are normally done on DE1 connect

if {$::android == 0} {
	::gui::state::reset_framenumbers
	::gui::state::reset_shotsample_deltas
}




namespace eval ::gui::callbacks {

	proc on_major_state_change {event_dict} {

		switch [dict get $event_dict this_state] {

			Espresso {
				reset_gui_starting_espresso
			}

			Steam {
				reset_gui_starting_steam
			}

			HotWater {
				reset_gui_starting_hotwater
			}

			HotWaterRinse {
				reset_gui_starting_hot_water_rinse
			}

		}
	}

	::de1::event::listener::on_major_state_change_add -noidle  ::gui::callbacks::on_major_state_change


	proc on_shotvalue_available {event_dict} {

		# Preserve order from code prior to 2021-02

		::gui::update::shot_frame_info $event_dict
		::gui::update::append_live_data_to_espresso_chart $event_dict
	}

	::de1::event::listener::on_shotvalue_available_add ::gui::callbacks::on_shotvalue_available



	# only_when_substate_present is not being loaded at this time as seems to freeze the GUI
	# See binary.tcl: proc update_de1_state {statechar} as of early 2021

	proc only_when_substate_present {event_dict} {

		set this_state [dict get $event_dict this_state]
		set this_substate [dict get $event_dict this_substate]

		if { [dict get $event_dict this_substate] != "" } {

			msg -DEBUG "::skins_page_change_due_to_de1_state_change for ${this_state},${this_substate}"

			#
			# This looks wonky, but GUI will freeze if sent on every change
			# logic and catch use after earlier code in binary.tcl: proc update_de1_state {statechar}
			#
			try {
				skins_page_change_due_to_de1_state_change  [dict get $event_dict this_state]
			} on error {result opts_dict} {
				msg -ERROR "::skins_page_change_due_to_de1_state_change ${this_state} $result $opts_dict"
			}
		}
	}

} ;# ::gui::callbacks



namespace eval ::gui::notify {

    	# Show "normal" messages around waiting for updates in the GUI?

	variable show_scale_update_watchdog_notifications False

	proc scale_event {event_id args} {

		switch -exact -- $event_id {

			abandoning_updates {
				if { $::settings(show_scale_notifications) } {
					popup [translate_toast {ABANDONING scale updates}]
				}
			}

			retrying_updates {

			    if { $::gui::notify::show_scale_update_watchdog_notifications } {
					popup "[translate_toast {Retrying scale updates}] [join $args]"
			    }
			}

			timeout_updates {
				if { $::settings(show_scale_notifications) } {
					popup "[translate_toast {Check scale}]"
				}
			}

			scale_reporting {
				if { $::settings(show_scale_notifications) } {
					popup "[translate_toast {Scale reporting}]"
				}
			}

			not_connected {

			    # With the ble reconnect logic
			    # `ble` will report a connection event when attempting to connect.
			    # When the connection fails, the disconnect logic fires.
			    # This has been reported to cause "ticking" sounds every 30 seconds.

			    if { [::de1::state::current_state] == "Sleep" } { return }

				if { $::settings(show_scale_notifications) && $::de1(bluetooth_scale_connection_attempts_tried) < 1} {
					set what [translate_toast {WARNING: Scale not connected}]
					popup $what
					say $what $::settings(sound_button_in)
				}
			}

			no_updates {
				if { $::settings(show_scale_notifications) } {
					set what [translate_toast {WARNING: Scale not updating}]
					popup $what
					say $what $::settings(sound_button_in)
				}
			}

			record_complete {
				set what [translate_toast {Shot complete}]
				popup $what
				say $what $::settings(sound_button_in)
			}

			saw_stop {
				popup [translate_toast {Stopping for weight}]
			}

			saw_skip {
				popup [translate_toast {Advancing to next step}]
			}

			default {

				msg -ERROR "::gui::notify::scale_event called without matching event_id: $event_id $args"
			}

		}
	}

	proc de1_event {event_id args} {

		switch -exact -- $event_id {

			sav_stop {

				popup [translate_toast {Stopping for volume}]
			}

			not_connected {

			    # With the ble reconnect logic
			    # `ble` will report a connection event when attempting to connect.
			    # When the connection fails, the disconnect logic fires.
			    # This has been reported to cause "ticking" sounds every 30 seconds.

			   # if { [::de1::state::current_state] == "Sleep" } { 
			   # 	msg -ERROR "Reconnecting to espresso machine"
			   # 	popup [translate_toast {Reconnecting to espresso machine}]
			   # 	ble_connect_to_de1 
			    #}

				if { $::settings(show_scale_notifications) && $::de1(bluetooth_scale_connection_attempts_tried) < 1} {
					set what [translate_toast {WARNING: Scale not connected}]
					popup $what
					say $what $::settings(sound_button_in)
				}
			}

			default {

				msg -ERROR "::gui::notify::de1_event called without matching event_id: $event_id $args"
			}
		}
	}

} ;# ::gui::notify

namespace eval ::gui::update {

	proc shot_frame_info {event_dict} {

		# Logic extracted from update_de1_shotvalue in binary.tcl - 2021-02

		set ::gui::state::_previous_framenumber [::gui::state::current_framenumber]
		set ::gui::state::_current_framenumber [dict get $event_dict FrameNumber]

		set this_substate [dict get $event_dict this_substate]


		if {[::gui::state::current_framenumber] != [::gui::state::previous_framenumber]} {

			# draw a vertical line at each frame change

			# The following logic, retained from prior versions, is likely a noop
			# as the updates from the DE1 will set the framenumber to 0 or higher

			set ::de1(app_stepskip_triggered) False

			if {[::gui::state::previous_framenumber] >= 0} {
				# don't draw a line a the first frame change
				set ::gui::state::_state_change_chart_value \
					[expr {$::gui::state::_state_change_chart_value * -1}]
			}

			set framepopup ""
			set framedesc ""

			set hold -1
			set decline -1
						
			######
			# the "slow start" and "temperature steps" features, both prefix the FLOW and PRESSURE profiles an an additional preinfusion step, and this has to be accounted for when we label the steps for human reading.
			if { $::settings(settings_profile_type) eq "settings_2a"} {
				# pressure profile shots have separate steps for RISE and HOLD even though the GUI only shows 1 step.
				set rise 1
				set hold 2
				set decline 3

				if {[ifexists ::settings(insert_preinfusion_pause)] == 1} {
					incr hold
					incr rise
					incr decline
				}

				if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} {
					incr hold
					incr rise
					incr decline
				}

			} elseif {$::settings(settings_profile_type) eq "settings_2b" } {
				set hold 1
				set decline 2

				if {[ifexists ::settings(insert_preinfusion_pause)] == 1} {
					incr hold
					incr decline
				}

				if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} {
					incr hold
					incr decline
				}
			}
			######
			

			switch $::settings(settings_profile_type) {

				settings_2a {

					if {[::gui::state::current_framenumber] == $rise} {
						set framedesc [translate "2: rise"] 
					} elseif {[::gui::state::current_framenumber] == $hold} {
						set framedesc [translate "2: hold"] 
					} elseif {[::gui::state::current_framenumber] == $decline} {
						set framedesc [translate "3: decline"]						
					} else {
						set framedesc [translate "1: preinfuse"]
					}
				}

				settings_2b {

					if {[::gui::state::current_framenumber] == $hold} {
						set framedesc [translate "2: hold"] 
					} elseif {[::gui::state::current_framenumber] == $decline} {
						set framedesc [translate "3: decline"] 
					} else {
						set framedesc [translate "1: preinfuse"] 
					}
				}

				settings_2c {

					unset -nocomplain thisadvstep
					array set thisadvstep \
						[lindex $::settings(advanced_shot) \
							 [::gui::state::current_framenumber]]

					set framedesc [format "%s: %s" \
							       [expr {1 + [::gui::state::current_framenumber]}] \
							       [ifexists thisadvstep(name)] \
							      ]

					set framepopup [ifexists thisadvstep(popup)]
				}

				default { set framedesc "-" }
			}

			#msg -ERROR "FRAMEDESC framedesc={$framedesc} / ::settings(settings_profile_type)=$::settings(settings_profile_type) / ::gui::state::current_framenumber = [::gui::state::current_framenumber] / hold=$hold decline=$decline / espresso_temperature_steps_enabled=[ifexists ::settings(espresso_temperature_steps_enabled)] / insert_preinfusion_pause]=[ifexists ::settings(insert_preinfusion_pause)] "


			switch -- $this_substate {

				preinfusion -
				pouring {
					set ::settings(current_frame_description) $framedesc

					# only display a popup message for a frame if we're currently making espresso.
					if {[::de1::state::current_state] == "Espresso"} {
						display_popup_android_message_if_necessary $framepopup
					}
				}

				default { set ::settings(current_frame_description) "" }
			}
		}

		# These are checked on every update as the frame number doesn't change.
		# The previous logic, duplicated here, to suppress drawing the first "line"
		# as well as that to set the first frame's lable is dependent on
		# continually overriding the previous value to -1,
		# as the DE1 updates set it on every report.

		switch -- $this_substate {

			ending {
				set ::settings(current_frame_description) [translate "ending"]
				::gui::state::reset_framenumbers
			}

			heating -
			stabilising -
			"final heating" {
				set ::settings(current_frame_description) [translate "heating"]
				::gui::state::reset_framenumbers
			}

			default {}
		}

	} ;# shot_frame_info


	proc append_live_data_to_espresso_chart {event_dict} {

		set this_state [dict get $event_dict this_state]
		set this_substate [dict get $event_dict this_substate]
		set this_flow [dict get $event_dict GroupFlow]
		set this_pressure [dict get $event_dict GroupPressure]
		set update_received [dict get $event_dict update_received]

		# As this gets called every 4-5 times a second, and usually does nothing
		# bail out early and simplify the logic that follows

		if { ! [::de1::state::is_flow_state \
				[dict get $event_dict this_state] \
				[dict get $event_dict this_substate]] } { return }

		# Intentionally not returning on non-flow substates to allow for recording during "ending"

		dict with event_dict {

			# TODO: If only tracking during flow states, the first sample will be "bad"
			#       Either need to run on every sample, or reset on entering a flow state

			# TODO: Decide how to make these dimensionally meaningful
			#       Probably should be "per second", which would divide by 4 or about 5 (50/60 Hz)

			set ::gui::state::_delta_flow \
				[expr { $this_flow - $::gui::state::_previous_flow }]
			set ::gui::state::_delta_pressure \
				[expr { $this_pressure - $::gui::state::_previous_pressure }]

			set ::gui::state::_previous_flow $this_flow
			set ::gui::state::_previous_pressure $this_pressure

			switch -- $this_state {

				Espresso {
					if { [::de1::state::is_flow_during_state $this_state $this_substate] } {

						# Change to estimated DE1 time, when implemented

						set millitime [espresso_millitimer $update_received]
						set mtime [expr {$millitime/1000.0}]

						# Everything from here on is logically and computationally
						# from previous code. References to $::de1() replaced with
						# references to $event_dict contents

						set last_elapsed_time_index [expr {[espresso_elapsed length] - 1}]
						set last_elapsed_time 0
						if {$last_elapsed_time_index >= 0} {
							set last_elapsed_time \
								[espresso_elapsed range \
									 $last_elapsed_time_index \
									 $last_elapsed_time_index]
						}

						if {$mtime > $last_elapsed_time} {

							# this is for handling cases where a god shot
							# has already loaded a time axis

							espresso_elapsed append $mtime
						}

						if {$::de1(scale_weight) == ""} {
							set ::de1(scale_weight) 0
						}
						espresso_weight append [round_to_two_digits $::de1(scale_weight)]
						espresso_weight_chartable append [round_to_two_digits [expr {0.10 * $::de1(scale_weight)}]]

						espresso_pressure append [round_to_two_digits $GroupPressure]
						espresso_flow append [round_to_two_digits $GroupFlow]
						espresso_flow_2x append [round_to_two_digits [expr {2.0 * $GroupFlow}]]

						set resistance 0
						catch {
							# main calculation, based on laminar flow. # linear adjustment
							set resistance [round_to_two_digits \
										[expr {$GroupPressure \
										       / pow($GroupFlow, 2) }]]
						}
						espresso_resistance append $resistance


						if {$::de1(scale_weight_rate) != ""} {

							# if a bluetooth scale is recording shot weight,
							# graph it along with the flow meter

							espresso_flow_weight append \
								[round_to_two_digits \
									 $::de1(scale_weight_rate)]

							espresso_flow_weight_raw append \
								[round_to_two_digits \
									 $::de1(scale_weight_rate_raw)]

							espresso_flow_weight_2x append \
								[expr {2.0 * [round_to_two_digits \
										      $::de1(scale_weight_rate)] }]

							if { [espresso_resistance_weight length] > 0 } {
								set resistance_weight espresso_resistance_weight(end)
							} else {
	                          set resistance_weight 0
							}
							catch {
								if {    $GroupPressure != 0 \
										&& $::de1(scale_weight_rate) != "" \
										&& $::de1(scale_weight_rate) != 0} {

									# if the scale is available,
									# use that instead of the flowmeter calculation,
									# to determine resistance

									set resistance_weight [round_to_two_digits \
										[expr {$GroupPressure \
										       / pow($::de1(scale_weight_rate), 2) }]]
								}
							}

							espresso_resistance_weight append $resistance_weight
						}

						# diff_flow_rate is defined in vars.tcl, as of 2021-02
						# On Android, it now returns $::gui::state::_delta_flow

						set flow_delta [diff_flow_rate]
						set negative_flow_delta_for_chart 0


						if {$this_substate == "preinfusion"} {

							# don't track flow rate delta during preinfusion
							# because the puck is absorbing water,
							# and so the numbers aren't useful
							# (likely just pump variability)

							set flow_delta 0
						}

						if {$flow_delta > 0} {

							if {$::settings(enable_negative_flow_charts) == 1} {

								# experimental chart from the top

								set negative_flow_delta_for_chart \
									[expr {6.0 - (10.0 * $flow_delta)}]

								set negative_flow_delta_for_chart_2x \
									[expr {12.0 - (10.0 * $flow_delta)}]

								espresso_flow_delta_negative append \
									$negative_flow_delta_for_chart

								espresso_flow_delta_negative_2x append \
									$negative_flow_delta_for_chart_2x
							}

							espresso_flow_delta append 0

						} else {

							espresso_flow_delta append [expr {abs(10*$flow_delta)}]

							if {$::settings(enable_negative_flow_charts) == 1} {

								espresso_flow_delta_negative append 6
								espresso_flow_delta_negative_2x append 12
							}
						}

						# diff_pressure is defined in vars.tcl, as of 2021-02
						# On Android, it now returns $::gui::state::_delta_pressure

						set pressure_delta [diff_pressure]
						espresso_pressure_delta append [expr {abs ($pressure_delta) / $millitime}]

						espresso_temperature_mix append \
							[return_temperature_number $MixTemp]

						espresso_temperature_basket append \
							[return_temperature_number $HeadTemp]

						espresso_temperature_basket10th append \
							[round_to_two_digits [expr {[return_temperature_number $HeadTemp] / 10.0}]]

						espresso_state_change append $::gui::state::_state_change_chart_value

						# don't chart goals at zero, instead take them off the chart

						if {$SetGroupFlow == 0} {
							espresso_flow_goal append "-1"
							espresso_flow_goal_2x append "-1"
						} else {
							espresso_flow_goal append $SetGroupFlow
							espresso_flow_goal_2x append [expr {2.0 * $SetGroupFlow}]
						}

						# don't chart goals at zero, instead take them off the chart

						if {$::de1(goal_pressure) == 0} {
							espresso_pressure_goal append "-1"
						} else {
							espresso_pressure_goal append $SetGroupPressure
						}

						espresso_temperature_goal append \
							[return_temperature_number $SetHeadTemp]

						espresso_temperature_goal10th append \
							[round_to_two_digits [expr {[return_temperature_number $SetHeadTemp] / 10.0}]]

						set total_water_volume \
							[expr {$::de1(preinfusion_volume) + $::de1(pour_volume)}]

						set total_water_volume_divided \
							[expr {0.1 * ($::de1(preinfusion_volume) + $::de1(pour_volume))}]

						espresso_water_dispensed append $total_water_volume_divided

					}
				}

				Steam {
					if { [::de1::state::is_flow_during_state $this_state $this_substate] } {

						steam_pressure append [round_to_two_digits $GroupPressure]

						if {$GroupPressure > $::settings(steam_over_pressure_threshold)} {
							popup [translate_toast "Warning: steam pressure is too high"]
						}
						if {$SteamTemp > $::settings(steam_over_temp_threshold)} {
							popup [translate_toast "Warning: steam temperature is too high"]
						}

						steam_flow append [round_to_two_digits $GroupFlow]

						steam_flow_goal append [round_to_two_digits [expr {$::settings(steam_flow) / 100.0}]]

						if {$::settings(enable_fahrenheit) == 1} {
							steam_temperature append [round_to_integer [celsius_to_fahrenheit $SteamTemp]]
							steam_temperature100th append [round_to_two_digits [expr {[celsius_to_fahrenheit $SteamTemp] / 100.00}]]
						} else {
							steam_temperature append [round_to_integer $SteamTemp]
							steam_temperature100th append [round_to_two_digits [expr {$SteamTemp / 100.00}]]
						}

						steam_elapsed append [expr {[steam_pour_millitimer $update_received]/1000.0}]
					}
				}

				default {}
			}

		}
	} ;# append_live_data_to_espresso_chart

} ;# ::gui::update


proc gridconfigure {widget} {
	# tkblt has not implemented this command, despite what the docs say
	if {[package versions BLT] != ""} {
		$widget grid configure -color $::grid_color 
	}
}
