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

proc setup_environment {} {

	set screen_size_width 1280
	set screen_size_height 800

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

		proc ble {args} {
			puts "ble $args"
		}


	}
	. configure -bg black 


	############################################
	# define the canvas
	canvas .can -width $screen_size_width -height $screen_size_height -borderwidth 0 -highlightthickness 0
	############################################
}

proc setup_images_for_first_page {} {
	image create photo splash -file "splash_screen_dark_brown.png"
	.can create image {0 0} -anchor nw -image splash  -tag splash -state normal
	pack .can
	update
	return
}


proc setup_images_for_other_pages {} {

	global page_images

	foreach {name pngfilename} [array get page_images] {
		image create photo $name -file $pngfilename
		.can create image {0 0} -anchor nw -image $name  -tag $name -state hidden
	}

	.can create rect 0 0 1279 799 -fill {} -outline black -width 0 -tag .btn_screen -state hidden
	.can create rect 124 294 422 693 -fill {} -outline black -width 0 -tag .btn_steam -state normal
	.can create rect 492 278 822 708 -fill {} -outline black -width 0 -tag .btn_espresso -state normal
	.can create rect 893 294 1192 693 -fill {} -outline black -width 0 -tag .btn_water -state normal
	.can create rect 1112 0 1279 160 -fill {} -outline black -width 0 -tag .btn_settings -state normal

	.can bind .btn_steam [platform_button_press] [list do_steam]
	.can bind .btn_espresso [platform_button_press] [list do_espresso]
	.can bind .btn_water [platform_button_press] [list do_water]
	.can bind .btn_settings [platform_button_press] [list do_settings]

}

proc run_de1_app {} {
	page_display_change "splash" "off"
}


proc do_steam {} {
	after cancel steam_dismiss
	disable_all_four_buttons
	.can bind .btn_screen [platform_button_press] [list steam_dismiss]
	page_display_change "off" "steam"
	after 2000 steam_dismiss
}

proc steam_dismiss {} {
	after cancel steam_dismiss
	enable_all_four_buttons
	page_display_change "steam" "off"
}

proc do_espresso {} {
	after cancel espresso_dismiss
	disable_all_four_buttons
	.can bind .btn_screen [platform_button_press] [list espresso_dismiss]
	page_display_change "off" "espresso"
	after 2000 espresso_dismiss
}

proc espresso_dismiss {} {
	after cancel espresso_dismiss
	enable_all_four_buttons
	page_display_change "espresso" "off"
}

proc do_water {} {
	after cancel water_dismiss
	disable_all_four_buttons
	.can bind .btn_screen [platform_button_press] [list water_dismiss]
	page_display_change "off" "water"
	after 2000 water_dismiss
}

proc water_dismiss {} {
	after cancel water_dismiss
	enable_all_four_buttons
	page_display_change "water" "off"
}

proc do_settings {} {
	after cancel settings_dismiss
	disable_all_four_buttons
	.can bind .btn_screen [platform_button_press] [list settings_dismiss]
	page_display_change "off" "settings"
}

proc settings_dismiss {} {
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


setup_environment
setup_images_for_first_page
setup_images_for_other_pages
run_de1_app
#pack .can
vwait forever
