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
	cd [homedir]
	return [ui_startup]
}


