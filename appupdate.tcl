#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"
source "updater.tcl"

#determine_if_android

#source pkgIndex.tcl
#package require de1_utils
#package require snit
package require sha256
package require crc32
package require http 2.5
package require tls 1.6
::http::register https 443 ::tls::socket

# this minimal version doesn't do translations so as to not have any dependencies
proc translate {x} {return $x}

set tk ""
catch {
	set tk [package present Tk]
}
if {$tk != ""} {
	button .hello -text "Updating" -command { exit } -width 200 -height 100
	pack .hello
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
		.hello configure -text [ifexists ::de1(app_update_button_label)] 
	} else {
		.hello configure -text "Failed.\n------------\n\nError info:\n------------\n$errorInfo" 
	}
}

##

pause 2000
