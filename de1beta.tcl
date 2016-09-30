#!/usr/local/bin/tclsh

#package require Thread
#package require jpeg
package require img::jpeg

# ray's DE1 address 
# de1_address "EE:01:68:94:A5:48"

# john's DE1
#	de1_address "C5:80:EC:A5:F9:72"

array set ::de1 {
	de1_address "C5:80:EC:A5:F9:72"
	last_action_time 0
    found    0
    scanning 1
    device_handle 0
	suuid "0000A000-0000-1000-8000-00805F9B34FB"
	sinstance 0
	cuuid "0000a002-0000-1000-8000-00805f9b34fb"
	cinstance 0
	timer_interval 500
	pressure 0
	group_temperature 88
	steam_heater_temperature 135
	flow 0
	temperature 0
	steam_temperature 0
	timer 0
	volume 0
	wrote 0
	cmdstack {}
	state 0
	substate 0
	current_context "off"
}

array set ::settings {
	screen_saver_delay 600
	screen_saver_change_interval 60
	measurements "metric"
	steam_max_time 60
	steam_temperature 160
	water_max_time 45
	water_temperature 75
	espresso_max_time 42
	espresso_temperature 92
	espresso_pressure 9.2
}

array set ::de1_state {
  Sleep \x01
  Idle \x02
  Busy \x03
  Espresso \x04
  Steam \x05
  HotWater \x06
  ShortCal \x07
  SelfTest \x08
  LongCal \x09
  Descale \x10
  FatalError \x11
  Init \x12
}

array set ::de1_substate_types {
	-   "starting"
	0	"waiting"
	1	"heating the water tank"
	2	"warming the heater"
	3	"perfecting the mix"
	4	"preinfusion"
	5	"pouring"
	6	"flushing"
}


# decent doser UI based on Morphosis graphics
cd "[file dirname [info script]]/"
source "gui.tcl"
source "vars.tcl"
source "binary.tcl"

array set translation [read_binary_file "translation.tcl"]

##############################

array set page_images {
	"off" "nothing_on.png" \
	"espresso" "espresso_on.png" \
	"steam" "steam_on.png" \
	"water" "tea_on.png" \
	"settings" "settings_on.png" \
	"saver" "splash_antique_1.jpg" \
}


#set screen_size_width 1280
#set screen_size_height 800
#set screen_size_width 1280
#set screen_size_height 720
#set screen_size_width 2560
#set screen_size_height 1600
#set screen_size_width 1920
#set screen_size_height 1080

proc de1_substate_text {} {
	set num $::de1(substate)
	set substate_txt $::de1_substate_types($num)
	return $substate_txt
}

proc language {} {
	#return "fr"
	# the UI language for Decent Espresso is set as the UI language that Android is currently operating in
	global current_language
	if {[info exists current_language] == 0} {
		array set loc [borg locale]
		set current_language $loc(language)
	}

	return $current_language
	#return "en"
	#return "fr"
}

proc translate {english} {

	if {[language] == "en"} {
		return $english
	}

	global translation

	if {[info exists translation($english)] == 1} {
		# this word has been translated
		array set available $translation($english)
		if {[info exists available([language])] == 1} {
			# this word has been translated into the desired non-english language
			return $available([language])
		}
	} 

	# if no translation found, return the english text
	return $english
}

proc setup_environment {} {
	global screen_size_width
	global screen_size_height

	global android
	set android 0
	catch {
		package require ble
		set android 1
	}


	if {$android == 1} {
		package require BLT
		namespace import blt::*
		namespace import -force blt::tile::*

		borg systemui 0x1E02
		borg screenorientation landscape

		wm attributes . -fullscreen 1
		sdltk screensaver off

		set width [winfo screenwidth .]
		set height [winfo screenheight .]

		# sets immersive mode

		#array set displaymetrics [borg displaymetrics]
		if {$width > 2300} {
			set screen_size_width 2560
			if {$height > 1450} {
				set screen_size_height 1600
			} else {
				set screen_size_height 1440
			}
		} elseif {$height > 2300} {
			set screen_size_width 2560
			if {$width > 1440} {
				set screen_size_height 1600
			} else {
				set screen_size_height 1440
			}
		} elseif {$width == 1920} {
			set screen_size_width 1920
			set screen_size_height 1080
			if {$width > 1080} {
				set screen_size_height 1200
			}

		} elseif {$width == 1280} {
			set screen_size_width 1280
			if {$width > 720} {
				set screen_size_height 800
			} else {
				set screen_size_height 720
			}
		} else {
			# unknown resolution type, go with smallest
			set screen_size_width 1280
			set screen_size_height 720
		}


		#set helvetica_font [sdltk addfont "fonts/HelveticaNeue Light.ttf"]
		#set helvetica_bold_font [sdltk addfont "fonts/helvetica-neue-bold.ttf"]
		#set sourcesans_font [sdltk addfont "fonts/SourceSansPro-Regular.ttf"]
		global helvetica_bold_font2
		set helvetica_font [sdltk addfont "fonts/HelveticaNeue Light.ttf"]
		set helvetica_bold_font [sdltk addfont "fonts/SourceSansPro-Bold.ttf"]
		set helvetica_bold_font2 [sdltk addfont "fonts/SourceSansPro-Semibold.ttf"]
		#puts "helvetica_bold_font: $helvetica_bold_font2"
		#set sourcesans_font [sdltk addfont "fonts/SourceSansPro-Regular.ttf"]

	    font create Helv_4 -family "HelveticaNeue" -size 4
	    font create Helv_7 -family "HelveticaNeue" -size 7
	    font create Helv_8 -family "HelveticaNeue" -size 8
	    
	    font create Helv_9_bold -family "Source Sans Pro" -size 8 
	    font create Helv_10_bold -family "Source Sans Pro" -size 10 -weight bold

		#font create Sourcesans_30 -family "Source Sans Pro" -size 10
	    #font create Sourcesans_20 -family "Source Sans Pro" -size 6

		sdltk touchtranslate 0
		wm maxsize . $screen_size_width $screen_size_height
		wm minsize . $screen_size_width $screen_size_height

		source "bluetooth.tcl"

	} else {
		set screen_size_width 1280
		set screen_size_height 800
		#set screen_size_width 1280
		#set screen_size_height 720
		#set screen_size_width 1920
		#set screen_size_height 1080
		#set screen_size_width 2560
		#set screen_size_height 1440
		#set screen_size_width 2560
		#set screen_size_height 1600
		#set screen_size_width 1920
		#set screen_size_height 1200

		package require Tk
		catch {
			package require tkblt
			namespace import blt::*
		}

		wm maxsize . $screen_size_width $screen_size_height
		wm minsize . $screen_size_width $screen_size_height

		font create Helv_4 -family {Helvetica Neue Regular} -size 10
		#pngfont create Helv_7 -family {Helvetica Neue Regular} -size 14
		font create Helv_8 -family {Helvetica Neue Regular} -size 20
		font create Helv_10_bold -family {Helvetica Neue Bold} -size 23
		font create Helv_9_bold -family {Helvetica Neue Bold} -size 18
		#font create Helvb_10 -family [list "HelveticaNeue" 5 bold] -size 19
		#font create Helvb_10 -family {Helvetica Neue Regular} -size 19
		#font create Helv_20 -family {Helvetica Neue Regular} -size 20
		
		font create Sourcesans_30 -family {Source Sans Pro Bold} -size 50
		font create Sourcesans_20 -family {Source Sans Pro Bold} -size 22

		proc ble {args} { puts "ble $args" }
		proc borg {args} { 
			if {[lindex $args 0] == "locale"} {
				return [list "language" "en"]
			} elseif {[lindex $args 0] == "log"} {
				# do nothing
			} else {
				puts "borg $args"
			}
		}
		proc de1_send {x} { delay_screen_saver;puts "de1_send '$x'" }
		proc de1_read {} { puts "de1_read" }
		proc app_exit {} { exit	}		

	}
	. configure -bg black 


	############################################
	# define the canvas
	canvas .can -width $screen_size_width -height $screen_size_height -borderwidth 0 -highlightthickness 0
	############################################
}

proc skin_directory {} {

	global screen_size_width
	global screen_size_height

	set dir "skins/default/${screen_size_width}x${screen_size_height}"
	return $dir

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
proc add_btn_screen {displaycontext newcontext} {
	global screen_size_width
	global screen_size_height
	global button_cnt
	incr button_cnt
	set btn_name ".btn_$displaycontext$button_cnt"
	#set btn_name $bname
	#.can create rect $x0 $y0 $x1 $y1 -fill {} -outline black -width 0 -tag $btn_name -state hidden
	.can create rect 0 0 $screen_size_width $screen_size_height -fill {} -outline black -width 0 -tag $btn_name  -state hidden
	#puts "binding $btn_name to switch to new context: '$newcontext'"

	set tclcode [list page_display_change $displaycontext $newcontext]
	.can bind $btn_name [platform_button_press] $tclcode
	add_visual_item_to_context $displaycontext $btn_name
}

proc add_de1_action {context tclcmd} {
	global actions
	if {[info exists actions(context)] == 1} {
		lappend actions($context) $tclcmd
	} else {
		set actions($context) $tclcmd
	}
}

proc add_de1_button {displaycontext newcontext x0 y0 x1 y1} {
	global button_cnt
	incr button_cnt
	set btn_name ".btn_$displaycontext$button_cnt"
	#set btn_name $bname
	global skindebug
	set width 0
	if {[info exists skindebug] == 1} {
		if {$skindebug == 1} {
			set width 1
		}
	}
	.can create rect $x0 $y0 $x1 $y1 -fill {} -outline black -width 0 -tag $btn_name -state hidden
	if {[info exists skindebug] == 1} {
		if {$skindebug == 1} {
			.can create rect $x0 $y0 $x1 $y1 -fill {} -outline black -width 1 -tag ${btn_name}_lines -state hidden
			add_visual_item_to_context $displaycontext ${btn_name}_lines
		}
	}

	#puts "binding $btn_name to switch to new context: '$newcontext'"

	set tclcode [list page_display_change $displaycontext $newcontext]
	.can bind $btn_name [platform_button_press] $tclcode
	add_visual_item_to_context $displaycontext $btn_name
}

set text_cnt 0
proc add_de1_text {args} {
	#puts "args: '$args'"
	global text_cnt
	incr text_cnt
	set context [lindex $args 0]
	set label_name "${context}_$text_cnt"

	# keep track of what labels are displayed in what contexts
	add_visual_item_to_context $context $label_name
	set torun [concat [list .can create text] [lrange $args 1 end] -tag $label_name -state hidden]
	#puts "torun : '$torun'"
	eval $torun
	return $label_name
}

proc add_de1_variable {args} {
	set varcmd [lindex [unshift args] 0]
	set lastcmd [unshift args]
	if {$lastcmd != "-textvariable"} {
		puts "WARNING: last -command needs to be -textvariable on a add_de1_variable line. You entered: '$lastcmd'"
		return
	}
	set context [lindex $args 0]
	set label_name [eval add_de1_text $args]
	add_variable_item_to_context $context $label_name $varcmd
}


proc pop { { stack "" } { n 1 } } {
     set s [ uplevel 1 [ list set $stack ] ]
     incr n -1
     set data [ lrange $s 0 $n ]
     incr n
     set s [ lrange $s $n end ]
     uplevel 1 [ list set $stack $s ]
     set data
}

proc unshift { { stack "" } { n 1 } } {
     set s [ uplevel 1 [ list set $stack ] ]
     set data [ lrange $s end-[ expr { $n - 1 } ] end ]
     uplevel 1 [ list set $stack [ lrange $s 0 end-$n ] ]
     set data
}


proc setup_images_for_first_page {} {
	set files [glob "[skin_directory]/splash_*.jpg"]
	set splashpng [random_pick $files]
	image create photo splash -file $splashpng -format jpeg
	.can create image {0 0} -anchor nw -image splash  -tag splash -state normal
	pack .can
	update
	return
}




proc setup_images_for_other_pages {} {
	puts "setup_images_for_other_pages"

	global screen_size_width
	global screen_size_height

	global page_images

	# load each of the PNGs that get displayed for each espresso machine achivity
	foreach {name pngfilename} [array get page_images] {
		image create photo $name -file "[skin_directory]/$pngfilename"
		.can create image {0 0} -anchor nw -image $name  -tag $name -state hidden
	}

	# debug log, will be invisible in release mode
	.can create text 10 10 -text "" -anchor nw -tag .t -fill #666666 -font Helv_4 -width 1000

	# set up the rectangles that define the finger tap zones and the associated command for each 
	source "[skin_directory]/skin.tcl"

	# rectangle to act as a button for the entire screen
	#.can create rect 0 0 $screen_size_width $screen_size_height -fill {} -outline black -width 0 -tag .btn_screen -state hidden
}



proc run_de1_app {} {
	page_display_change "splash" "off"
}


proc do_steam {} {
	msg "Make steam"
	set ::de1(timer) 0
	set ::de1(volume) 0
	de1_send $::de1_state(Steam)
}

#proc steam_dismiss {} {
#	msg "End steam"
#	de1_send $::de1_state(Idle)
#}

proc do_espresso {} {
	msg "Make espresso"
	set ::de1(timer) 0
	set ::de1(volume) 0

	de1_send $::de1_state(Espresso)
	#run_next_userdata_cmd
}

#proc espresso_dismiss {} {
#	msg "End espresso"
#	de1_send $::de1_state(Idle)
#}

proc do_water {} {
	msg "Make water"
	set ::de1(timer) 0
	set ::de1(volume) 0
	de1_send $::de1_state(HotWater)
}

#proc water_dismiss {} {
#	msg "End water"
#	de1_send $::de1_state(Idle)
#}

proc de1_stop_all {} {
	msg "DE1 goes idle"
	de1_send $::de1_state(Idle)
}


#proc do_settings {} {
#	msg "Make settings"
#	.can bind .btn_screen [platform_button_press] [list settings_dismiss]
#}

#proc settings_dismiss {} {#
#	msg "End settings"
#}

#proc disable_all_four_buttons {} {
#	.can itemconfigure ".btn_steam" -state hidden
#	.can itemconfigure ".btn_espresso" -state hidden
#	.can itemconfigure ".btn_water" -state hidden
#	.can itemconfigure ".btn_settings" -state hidden
#	.can itemconfigure .btn_screen -state normal
#}

#proc enable_all_four_buttons {} {
#	.can itemconfigure ".btn_steam" -state normal
#	.can itemconfigure ".btn_espresso" -state normal
#	.can itemconfigure ".btn_water" -state normal
#	.can itemconfigure ".btn_settings" -state normal
#	.can itemconfigure .btn_screen -state hidden
#}

proc page_display_change {page_to_hide page_to_show} {

	if {$page_to_hide == "saver"} {
		after 1000 check_if_should_start_screen_saver
		delay_screen_saver
	}

	#global current_context
	set ::de1(current_context) $page_to_show

	puts "page_display_change hide:$page_to_hide show:$page_to_show"
	foreach image $page_to_show	 {
		.can itemconfigure $image -state normal
	}	
	foreach image $page_to_hide	 {
		.can itemconfigure $image -state hidden
	}	


	global existing_labels
	foreach {context labels} [array get existing_labels] {

		foreach label $labels  {
			if {$context == $page_to_show} {
				# leave these displayed
				#puts "showing $label"
				.can itemconfigure $label -state normal
			} else {
				# hide these labels 
				#puts "hiding $label"
				.can itemconfigure $label -state hidden
			}
		}
	}

	global actions
	if {[info exists actions($page_to_show)] == 1} {
		foreach action $actions($page_to_show) {
			eval $action
		}
	}
}

proc load_android_wifi_settings {} {
	borg toast "Tap the \u25C0BACK\u25B6 BUTTON to return to\nDecent Espresso." 1
	after 500 { borg activity android.settings.WIFI_SETTINGS {} {} {} {} {} }
}

proc timer_test {} {
	global last_timer_test
	if {[info exists last_timer_test] != 1} {
		set last_timer_test [clock milliseconds]
		after 1000 timer_test
		return
	}

	set newtimer [clock milliseconds]
	set time_diff [expr {$newtimer - $last_timer_test - 1000}]

	if {$time_diff > 100} {
		msg "XXXX Delay on background timer test: ${time_diff}ms"
	}

	after $::de1(timer_interval) timer_test
	set last_timer_test $newtimer
}


proc delay_screen_saver {} {
	set ::de1(last_action_time) [clock seconds]
}

proc change_screen_saver_image {} {
	if {$::de1(current_context) != "saver"} {
		return
	}
	#msg "changing screen saver image"
	set files [glob "[skin_directory]/splash_*.jpg"]
	set splashpng [random_pick $files]
	image delete saver
	image create photo saver -file $splashpng
	.can create image {0 0} -anchor nw -image saver  -tag saver -state normal
	.can lower saver
	after [expr {1000 * $::settings(screen_saver_change_interval)}] change_screen_saver_image
}

proc check_if_should_start_screen_saver {} {
	#msg "check_if_should_start_screen_saver [clock seconds] > [expr {$::de1(last_action_time) + $::de1(screen_saver_delay)}]"
	if {$::de1(last_action_time) == 0} {
		after 1000 check_if_should_start_screen_saver
		delay_screen_saver
		return
	}

	if {$::de1(current_context) == "off" && [clock seconds] > [expr {$::de1(last_action_time) + $::settings(screen_saver_delay)}]} {
		page_display_change "off" "saver"
		de1_send $::de1_state(Sleep)
		#msg "start screen saver"
		after [expr {1000 * $::settings(screen_saver_change_interval)}] change_screen_saver_image
	} else {
		after 1000 check_if_should_start_screen_saver
	}
}

proc update_onscreen_variables {} {

	if {$::android == 0} {
		set ::de1(substate) [expr {int(rand() * 6)}]
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
	after $::de1(timer_interval) update_onscreen_variables
}

setup_environment
setup_images_for_first_page
setup_images_for_other_pages
#timer_test

after $::de1(timer_interval) update_onscreen_variables

check_if_should_start_screen_saver

	
#update
if {$android == 1} {
	ble_connect_to_de1
	
} else {
	after 1 run_de1_app
}


#run_de1_app


#pack .can
vwait forever
