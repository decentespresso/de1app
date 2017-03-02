package provide de1_gui 1.0

package require img::jpeg


proc chart_refresh {} {

}


proc add_de1_page {names apngfilename} {
	set pngfilename "[skin_directory_graphics]/$apngfilename"
	#puts $pngfilename
	image create photo $names -file $pngfilename
	foreach name $names {
		.can create image {0 0} -anchor nw -image $names  -tag $name -state hidden
	}
}	

proc set_de1_screen_saver_directory {{dirname {}}} {
	global saver_directory
	if {$dirname != ""} {
		set saver_directory $dirname
	}

	set pngfilename [random_saver_file]
	set names "saver"
	#puts $pngfilename
	image create photo $names -file $pngfilename
	foreach name $names {
		.can create image {0 0} -anchor nw -image $names  -tag $name -state hidden
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

proc random_pick {lst} {
    set pick [expr {int(rand() * [llength $lst])}] 
    return [lindex $lst $pick]
}


proc ifexists {fieldname2} {
    upvar $fieldname2 fieldname
    
    if {[info exists fieldname] == 1} {
	    return [subst "\$fieldname"]
    }
    return ""
}

proc set_dose_goal_weight {weight} {
	global current_weight_setting
	set current_weight_setting $weight
	.can itemconfig .current_setting_grams_label -text [round_one_digits $weight]
	update
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
	.can create image [list $img_xloc $img_yloc] -anchor nw -image ${up_png}_img  -tag $up_png
	

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

proc install_this_app_icon {} {
	package require base64
	set icondata2 [read_binary_file "/mnt/sdcard/de1beta/de1_icon.png"]
	set iconbase64b [::base64::encode -maxlen 0 $icondata2]


	set appurl "file://mnt/sdcard/de1beta/de1-5.tcl"
	catch {
		set x [borg shortcut add "DE1 #5" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}

	set appurl "file://mnt/sdcard/de1beta/de1plus-5.tcl"
	catch {
		set x [borg shortcut add "DE1+ #5" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}

	set appurl "file://mnt/sdcard/de1beta/de1c-5.tcl"
	catch {
		set x [borg shortcut add "DE1-C #5" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}
#return

	set appurl "file://mnt/sdcard/de1beta/de1c-3.tcl"
	catch {
		set x [borg shortcut add "DE1-C #3" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}




	set appurl "file://mnt/sdcard/de1beta/de1plus.tcl"
	catch {
		set x [borg shortcut add "DE1+ #1" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}

	set appurl "file://mnt/sdcard/de1beta/de1.tcl"
	catch {
		set x [borg shortcut add "DE1 #1" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}

	set appurl "file://mnt/sdcard/de1beta/de1c.tcl"
	catch {
		set x [borg shortcut add "DE1-C #1" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}

	set appurl "file://mnt/sdcard/de1beta/de1c-2.tcl"
	catch {
		set x [borg shortcut add "DE1-C #2" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}


	set appurl "file://mnt/sdcard/de1beta/de1c-2.tcl"
	catch {
		set x [borg shortcut add "DE1-C #2" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}

	set appurl "file://mnt/sdcard/de1beta/de1-2.tcl"
	catch {
		set x [borg shortcut add "DE1 #2" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}

	set appurl "file://mnt/sdcard/de1beta/de1plus-2.tcl"
	catch {
		set x [borg shortcut add "DE1+ #2" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}

	set appurl "file://mnt/sdcard/de1beta/de1-3.tcl"
	catch {
		set x [borg shortcut add "DE1 #3" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}

	set appurl "file://mnt/sdcard/de1beta/de1plus-3.tcl"
	catch {
		set x [borg shortcut add "DE1+ #3" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}

	set appurl "file://mnt/sdcard/de1beta/de1-4.tcl"
	catch {
		set x [borg shortcut add "DE1 #4" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}

	set appurl "file://mnt/sdcard/de1beta/de1plus-4.tcl"
	catch {
		set x [borg shortcut add "DE1+ #4" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}

	set appurl "file://mnt/sdcard/de1beta/de1c-4.tcl"
	catch {
		set x [borg shortcut add "DE1-C #4" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}


}

proc platform_button_press {} {
	global android 
	if {$android == 1} {
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
set debuglog {}					
proc msg {text} {
	return

	if {$text == ""} {
		return
	}

	#set text "$text ([::thread::id])"
	puts $text

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

}


# derivced from sample code at http://wiki.tcl.tk/17067
set widget_cnt 0
proc add_de1_widget {args} {
	global widget_cnt
	set contexts [lindex $args 0]

	incr widget_cnt
	set widgettype [lindex $args 1]
	#set widget ".can.${contexts}_widget_${widgettype}_$widget_cnt"
	set widget ".can.widget_${widgettype}_$widget_cnt"
	#add_visual_item_to_context $context $widget
	set torun [concat [list $widgettype $widget] [lrange $args 5 end] ]
	set errcode [catch { 
		eval $torun
	} err]

	if {$errcode == 1} {
		puts $err
		puts "while running" 
		puts $torun
	}

	# BLT on android has non standard defaults, so we overrride them here, sending them back to documented defaults
	if {$widgettype == "graph" && $::android == 1} {
		$widget grid configure -dashes "" -color #DDDDDD -hide 0 -minor 1 
		$widget configure -borderwidth 0
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
	set windowname [.can create window  $x $y -window $widget  -anchor nw -tag $widget -state hidden]
	#puts "winfo: [winfo children .can]"
	#.can bind $windowname [platform_button_press] "msg click"
	

		
	set ::tclwindows($widget) [lrange $args 2 3]

	foreach context $contexts {
		#puts "add_visual_item_to_context $context '$widget'"
		add_visual_item_to_context $context $widget
	}
}


proc add_de1_variable {args} {
	global text_cnt
	set varcmd [lindex [unshift args] 0]
	set lastcmd [unshift args]
	if {$lastcmd != "-textvariable"} {
		puts "WARNING: last -command needs to be -textvariable on a add_de1_variable line. You entered: '$lastcmd'"
		return
	}
	set contexts [lindex $args 0]
	set label_name [eval add_de1_text $args]
	foreach context $contexts {
		incr text_cnt
		foreach context $contexts {
			set label_name "${context}_$text_cnt"
			# keep track of what labels are displayed in what contexts
			add_visual_item_to_context $context $label_name
			set x [rescale_x_skin [lindex $args 1]]
			set y [rescale_y_skin [lindex $args 2]]
			set torun [concat [list .can create text] $x $y [lrange $args 3 end] -tag $label_name -state hidden]
			#puts $torun
			eval $torun
			add_variable_item_to_context $context $label_name $varcmd
		}
	}
}




proc delay_screen_saver {} {
	set ::de1(last_action_time) [clock seconds]
}

proc show_going_to_sleep_page  {} {

	page_display_change $::de1(current_context) "sleep"
	start_sleep

}

proc change_screen_saver_image {} {
	#msg "change_screen_saver_image"
	if {$::de1(current_context) != "saver"} {
		return
	}
	
	#set files [glob "[saver_directory]/*.jpg"]
	#set splashpng [random_pick $files]
	#msg "changing screen saver image to $splashpng"
	image delete saver
	image create photo saver -file [random_saver_file]
	.can create image {0 0} -anchor nw -image saver  -tag saver -state normal
	.can lower saver
	update
	after [expr {1000 * $::settings(screen_saver_change_interval)}] change_screen_saver_image
}

proc check_if_should_start_screen_saver {} {


	#msg "check_if_should_start_screen_saver $::de1(last_action_time)"
	after 1000 check_if_should_start_screen_saver

	if {$::settings(screen_saver_delay) == 0} {
		# screen saver is disabled
		return
	}

	if {$::de1(current_context) == "saver"} {
		#after 1000 check_if_should_start_screen_saver
		return
	}

	#msg "check_if_should_start_screen_saver [clock seconds] > [expr {$::de1(last_action_time) + $::de1(screen_saver_delay)}]"
	if {$::de1(last_action_time) == 0} {
		#after 1000 check_if_should_start_screen_saver
		delay_screen_saver
		return
	}

	if {$::de1(current_context) == "off" && [clock seconds] > [expr {$::de1(last_action_time) + (60*$::settings(screen_saver_delay))}]} {
		#page_display_change "off" "sleep"
		show_going_to_sleep_page
	#} else {
		#after 1000 check_if_should_start_screen_saver
	}
}


proc update_chart {} {
	espresso_elapsed notify now
}

proc update_onscreen_variables {} {

	update_chart

	#save_settings

	if {$::android == 0} {
		if {[expr {int(rand() * 100)}] > 70} {
			incr ::de1(substate)
	        set timerkey "$::de1(state)-$::de1(substate)"
	        set ::timers($timerkey) [clock milliseconds]
		}
		if {$::de1(substate) > 6} {
			set ::de1(substate) 0
		}

		if {$::de1(state) == 4} {
			append_live_data_to_espresso_chart
		}
	}
	#msg "updating"
	#global current_context
	
	global variable_labels
	if {[info exists variable_labels($::de1(current_context))] == 1} {
		set labels_to_update $variable_labels($::de1(current_context)) 
		foreach label_to_update $labels_to_update {
			set label_name [lindex $label_to_update 0]
			set label_cmd [lindex $label_to_update 1]
			#msg "Updating $current_context : $label_name with: '$label_cmd'"
			.can itemconfig $label_name -text [subst $label_cmd]
		}
	}

	update
	after $::settings(timer_interval) update_onscreen_variables
}

proc set_next_page {machinepage guipage} {
	set key "machine:$machinepage"
	set ::nextpage($key) $guipage
}

proc page_show {page_to_show} {
	set page_to_hide $::de1(current_context)
	return [page_display_change $page_to_hide $page_to_show] 
}

proc page_display_change {page_to_hide page_to_show} {

	if {$page_to_hide == ""} {
	}

	set key "machine:$page_to_show"
	if {[ifexists ::nextpage($key)] != ""} {
		# in Creator mode there are different possible tabs to display for different states (such as preheat-cup vs hot water)
		set page_to_show $::nextpage($key)
	}


	if {$::de1(current_context) == $page_to_show} {
		#
		return 
	}
	if {$page_to_hide == "sleep" && $page_to_show == "off"} {
		#
		msg "discarding intermediate sleep/off state msg"
		return 
	}

	# signal the page change with a sound
	say "" $::settings(sound_button_out)

	delay_screen_saver



	if {$page_to_show == "saver"} {
		after [expr {1000 * $::settings(screen_saver_change_interval)}] change_screen_saver_image
	}

	# track the time entering into a page
	#clear_timers
	#global start_timer
	#set start_timer [clock seconds]
	#global start_millitimer
	#set start_millitimer [clock milliseconds]

	# set the brightness in one place
	if {$page_to_show == "saver" } {
		borg brightness $::settings(saver_brightness)
		borg systemui 0x1E02
	} else {
		borg brightness $::settings(app_brightness)
		borg systemui 0x1E02
	}


	#global current_context
	set ::de1(current_context) $page_to_show

	puts "page_display_change hide:$page_to_hide show:$page_to_show"
	.can itemconfigure $page_to_show -state normal
	.can itemconfigure $page_to_hide -state hidden
	#update 
	#pause 500

	global existing_labels
	foreach label [ifexists existing_labels($page_to_hide)]  {
		if {[lsearch -exact [ifexists existing_labels($page_to_show)] $label] != -1} {
			#puts "item $label is on both $page_to_hide and $page_to_show"
			continue
		}
		set x [.can itemconfigure $label -state hidden]
	}

	foreach label [ifexists existing_labels($page_to_show)]  {
		if {[lsearch -exact [ifexists existing_labels($page_to_hide)] $label] != -1} {
			#puts "item $label is on both $page_to_hide and $page_to_show"
			continue
		}
		if {[info exists ::tclwindows($label)] == 1} {
			after 100 ".can itemconfigure $label -state normal"
		} else {
			.can itemconfigure $label -state normal
		}
	}


	global actions
	if {[info exists actions($page_to_show)] == 1} {
		foreach action $actions($page_to_show) {
			puts "actions: $action"
			eval $action
		}
	}

	after 100 update_chart

}

proc update_de1_explanation_chart { {itemval {}} } {

	#save_settings
	#puts "update_de1_explanation_chart"
	espresso_de1_explanation_chart_pressure length 0
	espresso_de1_explanation_chart_elapsed length 0

	set seconds 0

	# preinfusion
	if {$::settings(preinfusion_enabled) == 1} {
		espresso_de1_explanation_chart_pressure append 0.5
		espresso_de1_explanation_chart_elapsed append $seconds

		incr seconds 10
		espresso_de1_explanation_chart_pressure append 0.5
		espresso_de1_explanation_chart_elapsed append $seconds
	} else {
		espresso_de1_explanation_chart_elapsed append $seconds
		espresso_de1_explanation_chart_pressure append 0

	}

	# ramp up the pressure
	set totalramptime [expr {round($::settings(espresso_pressure) * 0.5)}]
	incr seconds $totalramptime
	espresso_de1_explanation_chart_elapsed append $seconds
	espresso_de1_explanation_chart_pressure append $::settings(espresso_pressure)

	incr seconds $::settings(pressure_hold_time)
	espresso_de1_explanation_chart_pressure append $::settings(espresso_pressure)
	espresso_de1_explanation_chart_elapsed append $seconds

	incr seconds $::settings(espresso_decline_time)
	espresso_de1_explanation_chart_pressure append $::settings(pressure_end)
	espresso_de1_explanation_chart_elapsed append $seconds


	set ::settings(espresso_max_time) $seconds
}


proc setup_images_for_first_page {} {
	#set files [glob "[splash_directory]/*.jpg"]
	#set splashpng [random_pick $files]
	image create photo splash -file [random_splash_file] -format jpeg
	.can create image {0 0} -anchor nw -image splash  -tag splash -state normal
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
	setup_images_for_first_page
	setup_images_for_other_pages

	after $::settings(timer_interval) update_onscreen_variables

	check_if_should_start_screen_saver
	if {$::android == 1} {
		ble_connect_to_de1
		
	} else {
		after 1 run_de1_app
	}
	vwait forever
}



#install_this_app_icon
