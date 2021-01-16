#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"
source "pkgIndex.tcl"

catch {
	# john 4-11-20 Android 10 is failing on this script, if we don't include these two dependencies
	package require snit
	package require de1_updater
}

package require de1_main
package require de1_gui

install_de1plus_app_icon
exit
