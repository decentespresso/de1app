#!/usr/local/bin/tclsh

package provide de1_main 1.0
package require de1_vars 
package require de1_gui 
package require de1_binary
package require de1_utils 
package require de1_machine

##############################



proc setup_images_for_other_pages {} {
	source "[skin_directory]/skin.tcl"
	return
}

proc de1_ui_startup {} {
	foreach d [lsort -increasing [skin_directories]] {
		skin_convert "[homedir]/skins/$d/2560x1600"
	}

	#skin_convert "[homedir]/skins/default/2560x1600"
	#skin_convert "[homedir]/skins/instrumented/2560x1600"
	cd [homedir]
	return [ui_startup]
}


