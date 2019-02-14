#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"

# do an app update on the de1plus code base, if this is a de1plus machine
if {[file exists "de1plus.tcl"] == 1} {
	package provide de1plus 1.0
}


source "updater.tcl"

determine_if_android

#source pkgIndex.tcl
#package require de1_utils
#package require snit
package require sha256
package require crc32
package require http 2.5
package require tls 1.6
::http::register https 443 ::tls::socket
cd "[file dirname [info script]]/"
set ::settings(logfile) "updatelog.txt"
set debugcnt 0

proc translate {x} {return $x}

set tk ""
catch {
	set tk [package present Tk]
}
if {$tk != ""} {
	button .hello -text "Updating" -command { exit } -height 10 -width 50
	#-width 200 -height 100
	button .resetapp -text "Reset app" -command { catch { file delete "settings.tdb"} ; exit } -height 5 -width 40
	#-width 200 -height 100 -bd 2
	pack .hello  -pady 10
	pack .resetapp -side bottom -pady 10
	
}

set success 0
set err [catch {
	start_app_update
	set success 1
}]

if {$err != 0} {
	puts $errorInfo
}

if {$tk != ""} {
	if {$success == 1} {
		.hello configure -text "[ifexists ::de1(app_update_button_label)]\n\nTap here to exit."
	} else {
		.hello configure -text "Failed.\n------------\n\nError info:\n------------\n$errorInfo\n\nTap here to exit." 
	}
}

catch {

}

##

#pause 2000
