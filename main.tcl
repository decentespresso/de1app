#!/usr/local/bin/tclsh

package provide de1_main 1.0

package require de1_vars 
package require de1_gui 
package require de1_binary
package require de1_utils 
package require de1_machine

##############################


proc setup_images_for_other_pages {} {
	#puts "setup_images_for_other_pages"

	global screen_size_width
	global screen_size_height

	#global page_images


	array set page_images [list \
		"off" "[skin_directory]/nothing_on.png" \
		"espresso" "[skin_directory]/espresso_on.png" \
		"steam" "[skin_directory]/steam_on.png" \
		"water" "[skin_directory]/tea_on.png" \
		"settings" "[skin_directory]/settings_on.png" \
		"sleep" "[skin_directory]/sleep.jpg" \
		"tankfilling" "[skin_directory]/filling_tank.jpg" \
		"tankempty" "[skin_directory]/fill_tank.jpg" \
		"saver" [random_saver_file] \
	]

	# load each of the PNGs that get displayed for each espresso machine achivity
	foreach {name pngfilename} [array get page_images] {
		image create photo $name -file $pngfilename
		.can create image {0 0} -anchor nw -image $name  -tag $name -state hidden
	}

	# debug log, will be invisible in release mode
	.can create text 10 10 -text "" -anchor nw -tag .t -fill #000000 -font Helv_4 -width 1000

	# set up the rectangles that define the finger tap zones and the associated command for each 
	source "[skin_directory]/skin.tcl"

}


proc de1_ui_startup {} {
	return [ui_startup]
}


