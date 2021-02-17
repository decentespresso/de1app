#!/usr/local/bin/tclsh

encoding system utf-8
cd "[file dirname [info script]]/"
source "pkgIndex.tcl"
source "version.tcl"

package provide de1plus 1.0

package require de1_logging 1.0

try {
	package require de1_main
} on error {result ropts} {
	msg -CRIT "Untrapped error loading de1_main with result: $result"
	msg -CRIT "$ropts"
	msg -CRIT "Exiting"
	exit
}

try {
	de1_ui_startup
} on error {result ropts} {
	msg -CRIT "Untrapped error running de1_ui_startup with result: $result"
	msg -CRIT "$ropts"
	msg -CRIT "Exiting"
	exit
}
