#!/usr/local/bin/tclsh


# decent doser UI based on Morphosis graphics
source "[file dirname [info script]]/gui.tcl"
cd "[file dirname [info script]]/"

##############################

array set page_images {
	"off" "nothing_on.png" \
	"espresso" "espresso_on.png" \
	"steam" "steam_on.png" \
	"water" "tea_on.png" \
	"settings" "settings_on.png" \
}


set screen_size_width 1280
set screen_size_height 800
#set screen_size_width 1280
#set screen_size_height 720
#set screen_size_width 2560
#set screen_size_height 1600
#set screen_size_width 1920
#set screen_size_height 1080

proc language {} {
	return "fr"
}

proc translate {english} {

	if {[language] == "en"} {
		return $english
	}

	array set translation {
		{espresso} {fr espresso de espresso}
		{hot water} {fr "eau chaude" de "heisses wasser"}
		{steam} {fr "vapeur" de "dampf"}
		{settings} {fr "paramètres" de "Einstellungen"}

	}

	if {[info exists translation($english)} {
		# this word has been translated
		array set available $translation($english)
		if {[info exists available([language])} {
			# this word has been translated into the desired non-english language
			return $available([language]
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

		wm attributes . -fullscreen 1
		sdltk screensaver off

		# sets immersive mode
		borg systemui 0x1E02
		borg screenorientation landscape

		set helvetica_font [sdltk addfont "HelveticaNeue Light.ttf"]
		puts "helvetica_font: $helvetica_font"
		
		set helvetica_bold_font [sdltk addfont "helvetica-neue-bold.ttf"]
		puts "helveticab_font: $helvetica_bold_font"
		
		set sourcesans_font [sdltk addfont "SourceSansPro-Regular.ttf"]
		puts "sourcesans: $sourcesans_font"

	    font create Helv_8 -family "HelveticaNeue" -size 4
	    font create Helv_10 -family "Helvetica Neue" -size 5

		font create Sourcesans_30 -family "Source Sans Pro" -size 10
	    font create Sourcesans_20 -family "Source Sans Pro" -size 6

		sdltk touchtranslate 0
		wm maxsize . $screen_size_width $screen_size_height
		wm minsize . $screen_size_width $screen_size_height

		source "bluetooth.tcl"

	} else {
		package require Tk
		package require tkblt
		namespace import blt::*

		wm maxsize . $screen_size_width $screen_size_height
		wm minsize . $screen_size_width $screen_size_height

		font create Helv_8 -family {Helvetica Neue Regular} -size 14
		font create Helv_10 -family {Helvetica Neue Bold} -size 19
		#font create Helvb_10 -family [list "HelveticaNeue" 5 bold] -size 19
		#font create Helvb_10 -family {Helvetica Neue Regular} -size 19
		#font create Helv_20 -family {Helvetica Neue Regular} -size 20
		
		font create Sourcesans_30 -family {Source Sans Pro Bold} -size 50
		font create Sourcesans_20 -family {Source Sans Pro Bold} -size 22

		proc ble {args} { puts "ble $args" }
		proc de1_send {x} { puts "de1_send '$x'" }
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

proc add_de1_command {bname tclcode x0 y0 x1 y1} {
	set btn_name ".btn_$bname"
	#set btn_name $bname
	.can create rect $x0 $y0 $x1 $y1 -fill {} -outline black -width 0 -tag $btn_name -state normal
	.can bind $btn_name [platform_button_press] $tclcode
}

proc setup_images_for_first_page {} {
	image create photo splash -file "[skin_directory]/splash.png"
	.can create image {0 0} -anchor nw -image splash  -tag splash -state normal
	pack .can
	update
	return
}


proc setup_images_for_other_pages {} {

	global screen_size_width
	global screen_size_height

	global page_images

	# load each of the PNGs that get displayed for each espresso machine achivity
	foreach {name pngfilename} [array get page_images] {
		image create photo $name -file "[skin_directory]/$pngfilename"
		.can create image {0 0} -anchor nw -image $name  -tag $name -state hidden
	}

	# debug log, will be invisible in release mode
	.can create text 10 10 -text "" -anchor nw -tag .t -fill #666666 -font Helv_8 -width 500

	# rectangle to act as a button for the entire screen
	.can create rect 0 0 $screen_size_width $screen_size_height -fill {} -outline black -width 0 -tag .btn_screen -state hidden

	# set up the rectangles that define the finger tap zones and the associated command for each 
	source "[skin_directory]/skin.tcl"

	#add_de1_command "steam" do_steam 124 294 422 693
	#add_de1_command "espresso" do_espresso 492 278 822 708
	#add_de1_command "water" do_water 893 294 1192 693
	#add_de1_command "exit" app_exit 1112 0 1279 160

	#add_de1_command "steam" do_steam 210 612 808 1416
	#add_de1_command "espresso" do_espresso 948 584 1606 1444
	#add_de1_command "water" do_water 1748 616 2346 1414
	#add_de1_command "exit" app_exit 2250 0 2558 284

	#.can create rect 124 294 422 693 -fill {} -outline black -width 0 -tag .btn_steam -state normal
	#.can create rect 492 278 822 708 -fill {} -outline black -width 0 -tag .btn_espresso -state normal
	#.can create rect 893 294 1192 693 -fill {} -outline black -width 0 -tag .btn_water -state normal
	#.can create rect 1112 0 1279 160 -fill {} -outline black -width 0 -tag .btn_settings -state normal

	#.can bind .btn_steam [platform_button_press] [list do_steam]
	#.can bind .btn_espresso [platform_button_press] [list do_espresso]
	#.can bind .btn_water [platform_button_press] [list do_water]
	#.can bind .btn_settings [platform_button_press] [list app_exit]
}


proc run_de1_app {} {
	page_display_change "splash" "off"
}


proc do_steam {} {
	msg "Make steam"
	#after cancel steam_dismiss
	disable_all_four_buttons
	.can bind .btn_screen [platform_button_press] [list steam_dismiss]
	page_display_change "off" "steam"
	de1_send "S"
	#after 2000 steam_dismiss
}

proc steam_dismiss {} {
	msg "End steam"
	after cancel steam_dismiss
	#de1_send " "
	enable_all_four_buttons
	page_display_change "steam" "off"
}

proc do_espresso {} {
	msg "Make espresso"
	after cancel espresso_dismiss
	disable_all_four_buttons
	.can bind .btn_screen [platform_button_press] [list espresso_dismiss]
	page_display_change "off" "espresso"
	de1_send "E"
	#after 2000 espresso_dismiss
}

proc espresso_dismiss {} {
	msg "End espresso"
	after cancel espresso_dismiss
	#de1_send " "
	enable_all_four_buttons
	page_display_change "espresso" "off"
}

proc do_water {} {
	msg "Make water"
	after cancel water_dismiss
	disable_all_four_buttons
	.can bind .btn_screen [platform_button_press] [list water_dismiss]
	page_display_change "off" "water"
	de1_send "H"
	#after 2000 water_dismiss
}

proc water_dismiss {} {
	msg "End water"
	after cancel water_dismiss
	#de1_send " "
	enable_all_four_buttons
	page_display_change "water" "off"
}

proc do_settings {} {
	msg "Make settings"
	after cancel settings_dismiss
	disable_all_four_buttons
	.can bind .btn_screen [platform_button_press] [list settings_dismiss]
	page_display_change "off" "settings"
}

proc settings_dismiss {} {
	msg "End settings"
	after cancel settings_dismiss
	enable_all_four_buttons
	page_display_change "settings" "off"
}

proc disable_all_four_buttons {} {
	.can itemconfigure ".btn_steam" -state hidden
	.can itemconfigure ".btn_espresso" -state hidden
	.can itemconfigure ".btn_water" -state hidden
	.can itemconfigure ".btn_settings" -state hidden
	.can itemconfigure .btn_screen -state normal
}

proc enable_all_four_buttons {} {
	.can itemconfigure ".btn_steam" -state normal
	.can itemconfigure ".btn_espresso" -state normal
	.can itemconfigure ".btn_water" -state normal
	.can itemconfigure ".btn_settings" -state normal
	.can itemconfigure .btn_screen -state hidden
}

proc page_display_change {page_to_hide page_to_show} {
	foreach image $page_to_show	 {
		.can itemconfigure $image -state normal
	}	
	foreach image $page_to_hide	 {
		.can itemconfigure $image -state hidden
	}	
}

proc load_android_wifi_settings {} {
	borg toast "Tap the \u25C0BACK\u25B6 BUTTON to return to\nDecent Espresso." 1
	after 500 { borg activity android.settings.WIFI_SETTINGS {} {} {} {} {} }
}


setup_environment
setup_images_for_first_page
#update
setup_images_for_other_pages
#update
if {$android == 1} {
	after 100 ble_connect_to_de1
	
} else {
	after 1000 run_de1_app
}
#run_de1_app

#pack .can
vwait forever
