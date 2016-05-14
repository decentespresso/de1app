
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
	set appurl "file://mnt/sdcard/de1beta/de1beta.tcl"
	catch {
		set x [borg shortcut add "DE1 beta" $appurl $iconbase64b]
		puts "shortcut added: '$x'"
	}
}

proc platform_button_press {} {
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
set debuglog {}					
proc msg {text} {

	if {$text == ""} {
		return
	}
	puts $text

	global debuglog 
   	global cnt
    incr cnt
	lappend debuglog "$cnt: $text"
 	.can itemconfigure .t -text [join $debuglog \n]

 	if {[llength $debuglog] > 11} {
		set debuglog [lrange $debuglog 1 end]
	}

    catch  {

        #.t insert end "$text\n"
        #set txt [.t get 1.0 end]
        #tk::TextSetCursor .t {insert display lineend}
   }
}

install_this_app_icon

