package provide de1_gui 1.0


proc setup_images_for_other_pages {} {
	borg spinner on
	source "[skin_directory]/skin.tcl"
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

proc add_de1_page {names filename {skin ""} } {

	if {$skin == ""} {
		set skin $::settings(skin)
	}

	set pngfilename "[homedir]/skins/$skin/${::screen_size_width}x${::screen_size_height}/$filename"
	set srcfilename "[homedir]/skins/$skin/2560x1600/$filename"

	if {[file exists $pngfilename] != 1} {
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

	} else {
		image create photo $names -file $pngfilename
	}

	foreach name $names {
		.can create image {0 0} -anchor nw -image $names -tag [list pages $name] -state hidden 
	}
}	

proc set_de1_screen_saver_directory {{dirname {}}} {
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


proc vertical_clicker {bigincrement smallincrement varname minval maxval x y x0 y0 x1 y1} {
	set yrange [expr {$y1 - $y0}]
	set yoffset [expr {$y - $y0}]

	set midpoint [expr {$y0 + ($yrange / 2)}]
	set onequarterpoint [expr {$y0 + ($yrange / 4)}]
	set threequarterpoint [expr {$y1 - ($yrange / 4)}]

	if {[info exists $varname] != 1} {
		# if the variable doesn't yet exist, initiialize it with a zero value
		set $varname 0
	}
	set currentval [subst \$$varname]
	set newval $currentval

	if {$y < $onequarterpoint} {
		set newval [expr "1.0 * \$$varname + $bigincrement"]
	} elseif {$y < $midpoint} {
		set newval [expr "1.0 * \$$varname + $smallincrement"]
	} elseif {$y < $threequarterpoint} {
		set newval [expr "1.0 * \$$varname - $smallincrement"]
	} else {
		set newval [expr "1.0 * \$$varname - $bigincrement"]
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



proc read_binary_file {filename} {
    set fn ""
    set err {}
    set error [catch {set fn [open $filename]} err]
    if {$fn == ""} {
        #puts "error opening binary file: $filename / '$err' / '$error' / $fn"
        return ""
    }
    if {$fn == ""} {
        return ""
    }
    
    fconfigure $fn -translation binary
    set data [read $fn]
    close $fn
    return $data
}

proc appdir {} {
    return [file tail [homedir]]
}


proc install_update_app_icon {dir} {
	package require base64
	set icondata_de1 [read_binary_file "/mnt/sdcard/$dir/cloud_download_icon.png"]
	set iconbase64_de1 [::base64::encode -maxlen 0 $icondata_de1]

	set appurl "file://mnt/sdcard/$dir/appupdate.tcl"
	catch {
		set x [borg shortcut add "Decent Update" $appurl $iconbase64_de1]
		puts "shortcut added: '$x'"
	}

}

proc install_de1_app_icon {} {
	package require base64
	set icondata_de1 [read_binary_file "/mnt/sdcard/[appdir]/de1_icon_v2.png"]
	set iconbase64_de1 [::base64::encode -maxlen 0 $icondata_de1]

	set appurl "file://mnt/sdcard/[appdir]/de1.tcl"
	puts "appurl: $appurl"
	catch {
		set x [borg shortcut add "DE1" $appurl $iconbase64_de1]
		puts "shortcut added: '$x'"
	}

	install_update_app_icon [appdir]

}


proc install_de1plus_app_icon {} {
	package require base64
	set icondata_de1plus [read_binary_file "/mnt/sdcard/[appdir]/de1plus_icon_v2.png"]
	set iconbase64_de1plus [::base64::encode -maxlen 0 $icondata_de1plus]

	set appurl "file://mnt/sdcard/[appdir]/de1plus.tcl"
	#puts "appurl: $appurl"
	catch {
		set x [borg shortcut add "DE1+" $appurl $iconbase64_de1plus]
		puts "shortcut added: '$x'"
	}

	install_update_app_icon [appdir]
}


proc install_this_app_icon_beta {} {
	package require base64
	set icondata_de1 [read_binary_file "/mnt/sdcard/de1beta/de1_icon_v2.png"]
	set icondata_de1plus [read_binary_file "/mnt/sdcard/de1beta/de1plus_icon_v2.png"]
	set iconbase64_de1 [::base64::encode -maxlen 0 $icondata_de1]
	set iconbase64_de1plus [::base64::encode -maxlen 0 $icondata_de1plus]

	set appurl "file://mnt/sdcard/de1beta/de1plus.tcl"
	catch {
		set x [borg shortcut add "DE1+" $appurl $iconbase64_de1plus]
		puts "shortcut added: '$x'"
	}

	set appurl "file://mnt/sdcard/de1beta/de1.tcl"
	catch {
		set x [borg shortcut add "DE1" $appurl $iconbase64_de1]
		puts "shortcut added: '$x'"
	}
}


proc platform_button_press {} {
	global android 
	if {$android == 1} {
		#return {<<FingerUp>>}
		return {<ButtonPress-1>}
	}
	return {<ButtonPress-1>}
}

proc platform_finger_down {} {
	global android 
	if {$android == 1} {
		return {<Motion>}
	}
	return {<Motion>}
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
proc msg {text} {
#z

	incr ::debugcnt
	#catch {
	if {[info exists ::debugging] == 1} {
		if {$::debugging == 1} {

			set ::debuglog "$::debugcnt) $text\n$::debuglog"
			#return
			set loglines [split $::debuglog "\n"]
			if {[llength $loglines] > 35} {
				unshift loglines
				set ::debuglog [join $loglines \n]
				#set ::debuglog [join [lrange $loglines 0 [expr {[llength loglines] - 1}] \n]]
				#pop 
				#set loglines [split $::debuglog "\n"]
			}

	        puts $text

			return

	        $::debugwidget insert end "$text\n"
	        set txt [$::debugwidget get 1.0 end]
	        tk::TextSetCursor $::debugwidget {insert display lineend}

	        #append ::debuglog $text\n
	        return

		}
	}
	#}
	#return

	if {$text == ""} {
		return
	}

	#set text "$text ([::thread::id])"
	puts $text
return

	borg log 1 "decent" $text

	global debuglog 
   	global cnt
    incr cnt
	lappend debuglog "$cnt: $text"
 	.can itemconfigure .t -text [join $debuglog \n]

 	if {[llength $debuglog] > 22} {
		set debuglog [lrange $debuglog 1 end]
	}

    catch  {

        #.t insert end "$text\n"
        #set txt [.t get 1.0 end]
        #tk::TextSetCursor .t {insert display lineend}
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

	if {[string first mousemove $options] != -1} {
		#puts "mousemove detected"
		.can bind $btn_name [platform_finger_down] $tclcode
	}

	foreach displaycontext $displaycontexts {
		add_visual_item_to_context $displaycontext $btn_name
		if {[ifexists skindebug] == 1} {
			add_visual_item_to_context $displaycontext ${btn_name}_lines
		}

	}
	return $btn_name
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
	#global text_cnt
	set varcmd [lindex [unshift args] 0]
	set lastcmd [unshift args]
	if {$lastcmd != "-textvariable"} {
		puts "WARNING: last -command needs to be -textvariable on a add_de1_variable line. You entered: '$lastcmd'"
		return
	}
	set contexts [lindex $args 0]
	set label_name [eval add_de1_text $args]

	set x [rescale_x_skin [lindex $args 1]]
	set y [rescale_y_skin [lindex $args 2]]
	set torun [concat [list .can create text] $x $y [lrange $args 3 end] -tag $label_name -state hidden]
	#puts $torun
	eval $torun
	incr ::text_cnt

	foreach context $contexts {
		#set label_name "${context}_$text_cnt"

		# keep track of what labels are displayed in what contexts
		#add_visual_item_to_context $context $label_name
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

	#puts "cont: $::de1(current_context)"

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
	if {$::de1_num_state($::de1(state)) != "Idle"} {
		# never go to sleep if the DE1 is not idle
		msg "delaying screen saver because de1 is not idle"
		delay_screen_saver
		return
	}

    if {[ifexists ::app_updating] == 1} {
		msg "delaying screen saver because tablet app is updating"
		delay_screen_saver
		return
	}

    if {$::de1(currently_updating_firmware) == 1} {
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
	#msg "change_screen_saver_img $::de1(current_context)"
	#if {$::de1(current_context) == "saver"} {
		image delete saver

		set fn [random_saver_file]

		image create photo saver -file $fn
		.can create image {0 0} -anchor nw -image saver  -tag saver -state hidden
		.can lower saver
		#update
	#}#

	if {[info exists ::change_screen_saver_image_handle] == 1} {
		after cancel $::change_screen_saver_image_handle
		unset -nocomplain ::change_screen_saver_image_handle
	}

	#set ::change_screen_saver_image_handle [after 1000 change_screen_saver_image]
	set ::change_screen_saver_image_handle [after [expr {60 * 1000 * $::settings(screen_saver_change_interval)}] change_screen_saver_img]
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
			#return "[translate Connected]: $elapsed"
		}
		#return [translate "Disconnected"]
	}

	if {$since_last_ping < 5} {
		#borg spinner off

		if {$::de1(substate) != 0} {
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
		#return "[translate Connected] $elapsed [translate seconds] - last ping: $::de1(last_ping) $::de1_bluetooth_list"
	} else {
		#borg toast "[translate Disconnected]"
		#borg spinner on
		if {$::de1(device_handle) == 0} {
			#return "[translate Connecting]"
			if {$elapsed > 600} {
				if {$::scanning == 1} {
					return "[translate Searching]"
				} elseif {$::scanning == -1} {
					return "[translate Starting]"
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
				return [subst {[translate "Disconnected"]}]
			}
			return [subst {[translate "Disconnected"] : $since_last_ping}]
		}
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

		if {[expr {int(rand() * 100)}] > 95} {
			set ::state_change_chart_value [expr {$::state_change_chart_value * -1}]
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
			set label_value [subst $label_cmd]
			if {[ifexists ::labelcache($label_name)] != $label_value} {
				.can itemconfig $label_name -text $label_value
				set ::labelcache($label_name) $label_value
				set something_updated 1
			}
		}
	}

	if {$something_updated == 1} {
		update
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
	msg "set_next_page $machinepage $guipage"
	set key "machine:$machinepage"
	set ::nextpage($key) $guipage
}

proc show_settings { {tab_to_show ""} } {
	backup_settings; 
	if {$tab_to_show == ""} {
		page_to_show_when_off $::active_settings_tab
		scheduler_feature_hide_show_refresh
		set_profiles_scrollbar_dimensions
	} else {
		page_to_show_when_off $tab_to_show
	}
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

proc page_display_change {page_to_hide page_to_show} {

	#if {$page_to_hide == ""} {
	#}

	delay_screen_saver

	set key "machine:$page_to_show"
	if {[ifexists ::nextpage($key)] != ""} {
		# there are different possible tabs to display for different states (such as preheat-cup vs hot water)
		set page_to_show $::nextpage($key)
	}


	if {$::de1(current_context) == $page_to_show} {
		return 
	}
	if {$page_to_hide == "sleep" && $page_to_show == "off"} {
		msg "discarding intermediate sleep/off state msg"
		return 
	}

	# signal the page change with a sound
	say "" $::settings(sound_button_out)
	msg "page_display_change $page_to_show"
	#set start [clock milliseconds]

	# set the brightness in one place
	if {$page_to_show == "saver" } {
		borg brightness $::settings(saver_brightness)
		borg systemui $::android_full_screen_flags  
	} else {
		borg brightness $::settings(app_brightness)

		# let the Android controls show for 5 seconds, and if the user doesn't use them in that time, then hide them
		after 5000 borg systemui $::android_full_screen_flags
	}


	if {$::settings(stress_test) == 1 && $::de1_num_state($::de1(state)) == "Idle" && [info exists ::idle_next_step] == 1} {
		set todo $::idle_next_step 
		unset -nocomplain ::idle_next_step 
		eval $todo
	}


	#global current_context
	set ::de1(current_context) $page_to_show

	#puts "page_display_change hide:$page_to_hide show:$page_to_show"
	.can itemconfigure $page_to_hide -state hidden
	#.can itemconfigure [list "pages" "splash" "saver"] -state hidden
	.can itemconfigure $page_to_show -state normal

	set these_labels [ifexists ::existing_labels($page_to_show)]

	if {[info exists ::all_labels] != 1} {
		set ::all_labels {}
		foreach {page labels} [array get ::existing_labels]  {
			set ::all_labels [concat $::all_labels $labels]
		}
		set ::all_labels [lsort -unique $::all_labels]
	}

	foreach label $::all_labels {
		if {[.can itemcget $label -state] != "hidden"} {
			.can itemconfigure $label -state hidden
		}
	}

	foreach label $these_labels {
		.can itemconfigure $label -state normal
	}

	update
	#set end [clock milliseconds]
	#puts "elapsed: [expr {$end - $start}]"

	global actions
	if {[info exists actions($page_to_show)] == 1} {
		foreach action $actions($page_to_show) {
			eval $action
		}
	}

	#update_onscreen_variables
	#after 100 update_chart

}

proc update_de1_explanation_chart_soon  { {context {}} } {
	# we can optionally delay displaying the chart until data from the slider stops coming
	update_de1_explanation_chart
	#return
	#after cancel update_de1_explanation_chart
	#after 5 update_de1_explanation_chart
}

proc update_de1_explanation_chart { {context {}} } {

	if {![de1plus]} {
		if {[expr {$::settings(pressure_end) + 1}] > $::settings(espresso_pressure)} {
			# the end pressure is not allowed to be higher than the hold pressure
			set ::settings(pressure_end) [expr {$::settings(espresso_pressure) - 1}]
		}
	}

	#save_settings
	#puts "update_de1_explanation_chart"
	espresso_de1_explanation_chart_pressure length 0
	#espresso_de1_explanation_chart_flow length 0
	espresso_de1_explanation_chart_elapsed length 0

	espresso_de1_explanation_chart_pressure_1 length 0
	espresso_de1_explanation_chart_elapsed_1 length 0
	espresso_de1_explanation_chart_pressure_2 length 0
	espresso_de1_explanation_chart_elapsed_2 length 0
	espresso_de1_explanation_chart_pressure_3 length 0
	espresso_de1_explanation_chart_elapsed_3 length 0



	set seconds 0

	# preinfusion
	set preinfusion_pressure 0.5
	if {$::settings(preinfusion_time) > 0} {
		if {[de1plus]} {
			#set preinfusion_pressure [expr {$::settings(preinfusion_flow_rate) / 6.0}]
			set preinfusion_pressure $::settings(preinfusion_stop_pressure)
		}

		espresso_de1_explanation_chart_pressure append 0.1
		espresso_de1_explanation_chart_elapsed append $seconds

		set seconds [expr {-.01  + $seconds + $::settings(preinfusion_time)}]
		espresso_de1_explanation_chart_pressure append $preinfusion_pressure
		espresso_de1_explanation_chart_elapsed append $seconds

		# these 0.01 add/remove is to force the chart library to put two dots in to keep the curves all moving the same way
		set seconds [expr {.01  + $seconds}]
		espresso_de1_explanation_chart_pressure append $preinfusion_pressure
		espresso_de1_explanation_chart_elapsed append $seconds
	} else {
		espresso_de1_explanation_chart_elapsed append $seconds
		espresso_de1_explanation_chart_pressure append 0
		#set ::settings(preinfusion_stop_pressure) 4

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

	espresso_de1_explanation_chart_elapsed_2 append $seconds
	espresso_de1_explanation_chart_pressure_2 append $espresso_pressure
	espresso_de1_explanation_chart_elapsed_3 append $seconds
	espresso_de1_explanation_chart_pressure_3 append $espresso_pressure

	# hold the pressure
	if {$pressure_hold_time > 0} {
		set seconds [expr {$seconds + $pressure_hold_time}]
		espresso_de1_explanation_chart_pressure append $espresso_pressure
		espresso_de1_explanation_chart_elapsed append $seconds

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

		espresso_de1_explanation_chart_pressure_3 append $pressure_end
		espresso_de1_explanation_chart_elapsed_3 append $seconds
	}

	# save the total time
	set ::settings(espresso_max_time) $seconds

	if {[de1plus]} {
		update_de1_plus_flow_explanation_chart
	}
}


proc update_de1_plus_flow_explanation_chart { {context {}} } {

	#if {$::settings(pressure_end) > $::settings(espresso_pressure)} {
		# the end pressure is not allowed to be higher than the hold pressure
		#set ::settings(pressure_end) $::settings(espresso_pressure)
	#}

	#save_settings
	#puts "update_de1_explanation_chart"
	#espresso_de1_explanation_chart_pressure length 0
	espresso_de1_explanation_chart_flow length 0
	espresso_de1_explanation_chart_elapsed_flow length 0

	espresso_de1_explanation_chart_flow_1 length 0
	espresso_de1_explanation_chart_elapsed_flow_1 length 0
	espresso_de1_explanation_chart_flow_2 length 0
	espresso_de1_explanation_chart_elapsed_flow_2 length 0
	espresso_de1_explanation_chart_flow_3 length 0
	espresso_de1_explanation_chart_elapsed_flow_3 length 0

	set seconds 0

	# preinfusion
	if {$::settings(preinfusion_time) > 0} {
		espresso_de1_explanation_chart_flow append 0
		espresso_de1_explanation_chart_elapsed_flow append $seconds

		#espresso_de1_explanation_chart_elapsed_flow_1 append $seconds



		set seconds [expr {$::settings(preinfusion_flow_rate)/4}]

		espresso_de1_explanation_chart_flow append $::settings(preinfusion_flow_rate);
		espresso_de1_explanation_chart_elapsed_flow append $seconds

		set likely_pressure_attained_during_preinfusion [expr {(($::settings(preinfusion_flow_rate) * $::settings(preinfusion_time)) - 5) / 10}]
		set pressure_gained_needed [expr {$::settings(preinfusion_stop_pressure) - $likely_pressure_attained_during_preinfusion}]

		set seconds [expr {$seconds + $::settings(preinfusion_time)}]
		espresso_de1_explanation_chart_flow append $::settings(preinfusion_flow_rate);
		espresso_de1_explanation_chart_elapsed_flow append $seconds

#puts "g: $::settings(preinfusion_guarantee)"
		#puts "likely_pressure_attained_during_preinfusion: $likely_pressure_attained_during_preinfusion / $::settings(preinfusion_guarantee) / pressure_gained_needed $pressure_gained_needed"
		if {$::settings(preinfusion_guarantee) != 0} {
			# assume 2 bar per second rise time, and a flow rate of 6 ml/s when rising
			set time_to_rise_pressure [expr {$pressure_gained_needed / 2}]
			if {$time_to_rise_pressure < 1} {
				set time_to_rise_pressure 1
			}

			#puts "time_to_rise_pressure: $time_to_rise_pressure"
			#set rise_hold_time [expr {($::settings(espresso_pressure) - $likely_pressure_attained_during_preinfusion) }]
			set seconds [expr {$seconds + $time_to_rise_pressure}]
			espresso_de1_explanation_chart_flow append 6
			espresso_de1_explanation_chart_elapsed_flow append $seconds

			if {$::settings(flow_profile_hold) > 0} {
				set pressure_drop_needed [expr {6 - $::settings(flow_profile_hold)}]
			} else {
				set pressure_drop_needed 3
			}
			set seconds [expr {$seconds + (($pressure_drop_needed + $time_to_rise_pressure) / 2)}]
			espresso_de1_explanation_chart_flow append 6
			espresso_de1_explanation_chart_elapsed_flow append $seconds
		}
	} else {
		set seconds [expr {$::settings(flow_profile_hold)/4}]
		espresso_de1_explanation_chart_flow append 0
		espresso_de1_explanation_chart_elapsed_flow append $seconds

	#espresso_de1_explanation_chart_elapsed_flow append $seconds
		#espresso_de1_explanation_chart_flow append 0
	}

	# color coding the preinfusion section
	espresso_de1_explanation_chart_flow_1 append espresso_de1_explanation_chart_flow
	espresso_de1_explanation_chart_elapsed_flow_1 append espresso_de1_explanation_chart_elapsed_flow
	espresso_de1_explanation_chart_flow_2 append espresso_de1_explanation_chart_flow
	espresso_de1_explanation_chart_elapsed_flow_2 append espresso_de1_explanation_chart_elapsed_flow
	espresso_de1_explanation_chart_flow_3 append espresso_de1_explanation_chart_flow
	espresso_de1_explanation_chart_elapsed_flow_3 append espresso_de1_explanation_chart_elapsed_flow

		#espresso_de1_explanation_chart_flow append 0
		#espresso_de1_explanation_chart_elapsed_flow append $seconds



	set approximate_ramptime 3
	set flow_profile_hold_time $::settings(espresso_hold_time)
	set espresso_decline_time $::settings(espresso_decline_time)
		#set flow_profile_hold_time [expr {$flow_profile_hold_time - $approximate_ramptime}]
		#puts "flow_profile_hold_time: $flow_profile_hold_time"
	#if {$flow_profile_hold_time > $approximate_ramptime} {
	#	puts "113"
	#} else {
	#	puts "114"
#		set approximate_ramptime 5
	#}	

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
		
		espresso_de1_explanation_chart_elapsed_flow_2 append $seconds
		espresso_de1_explanation_chart_flow_2 append $flow_profile_hold
		espresso_de1_explanation_chart_elapsed_flow_3 append $seconds
		espresso_de1_explanation_chart_flow_3 append $flow_profile_hold

		# hold the flow
		set seconds [expr {$seconds + $flow_profile_hold_time}]
		espresso_de1_explanation_chart_flow append $flow_profile_hold
		espresso_de1_explanation_chart_elapsed_flow append $seconds
		
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
		

		espresso_de1_explanation_chart_flow_3 append $flow_profile_decline
		espresso_de1_explanation_chart_elapsed_flow_3 append $seconds
	}

	# save the total time
	set ::settings(espresso_max_time) $seconds
}


proc setup_images_for_first_page {} {
	
	set fn [random_splash_file]
	image create photo splash -file $fn 
	.can create image {0 0} -anchor nw -image splash  -tag splash -state normal
	pack .can
    #borg brightness 100

	update
	return
}

proc run_de1_app {} {
	page_display_change "splash" "off"
}

proc ui_startup {} {
	puts "setup_environment"
	load_settings
	setup_environment
	#ble_find_de1s
	
	bluetooth_connect_to_devices
	#if {$::android == 1} {
		#ble_connect_to_de1
	#}
	setup_images_for_first_page
	setup_images_for_other_pages
	.can itemconfigure splash -state hidden

	#after $::settings(timer_interval) 
	update_onscreen_variables
	delay_screen_saver
	change_screen_saver_img

	#check_if_should_start_screen_saver
	if {$::android == 1} {
		#ble_find_de1s
		#ble_connect_to_de1
		#puts "ran ble_connect_to_de1"
		#after 1 run_de1_app
		
	} else {
		#after 1 run_de1_app
	}
	#after 1 run_de1_app
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
	if {[info exists ::water_level_color_check_count] != 1} {
		set ::water_level_color_check_count  0
	}
	incr ::water_level_color_check_count 
	set colors [list  "#7ad2ff"  "#ff6b6b"]
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
			set color "#7ad2ff"
			set blinkrate 2000
		} elseif {$::de1(water_level) > 7} {
			set blinkrate 1000
		} elseif {$::de1(water_level) >= 5} {
			set blinkrate 500
		} else {
			set blinkrate 150
		}
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
	$lb yview moveto $dest1
}

# convenience function to link a "scale" widget with a "listbox" so that the scale becomes a scrollbar to the listbox, rather than using the ugly Tk native scrollbar
proc scale_scroll {lb dest1 dest2} {
	upvar $lb fieldname
	set fieldname $dest1
}

proc calibration_gui_init {} {

	# calibration should always take place in Celsius
	set ::settings(enable_fahrenheit) 0; 

	# set the entry fields back to normal
	$::globals(widget_calibrate_temperature) configure -state normal; 
	$::globals(widget_calibrate_pressure) configure -state normal; 
	$::globals(widget_calibrate_flow) configure -state normal; 

	# set the goals to be the HOLD step of FLOW and PRESSURE shots, and the temperature to be the overall espresso temperature
	set ::globals(calibration_espresso_pressure) $::settings(espresso_pressure); 
	set ::globals(calibration_espresso_temperature) $::settings(espresso_temperature); 
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
		calibration_ble_received "\x00\x00\x00\x00\x01\x02\x00\x01\x00\x00\x00\x03\x64\x86"
		after 1000 calibration_ble_received "\x00\x00\x00\x00\x01\x01\x00\x01\x00\x00\x00\x02\x34\x86"
		after 2000 calibration_ble_received "\x00\x00\x00\x00\x01\x00\x00\x01\x00\x00\x00\x01\x14\x86"

		after 3000 calibration_ble_received "\x00\x00\x00\x00\x03\x02\x00\x01\x03\x00\x00\x06\x12\x86"
		after 4000 calibration_ble_received "\x00\x00\x00\x00\x03\x01\x00\x01\x03\x00\x00\x05\x61\x86"
		after 5000 calibration_ble_received "\x00\x00\x00\x00\x03\x00\x00\x01\x03\x00\x00\x04\x32\x86"
	} else {

		de1_read_calibration "temperature"
		after 1000 de1_read_calibration "pressure"
		after 2000 de1_read_calibration "flow"

		after 3000 de1_read_calibration "temperature" "factory"
		after 4000 de1_read_calibration "pressure" "factory"
		after 5000 de1_read_calibration "flow" "factory"
	}
}


#install_de1_app_icon
#install_de1plus_app_icon
#install_this_app_icon
