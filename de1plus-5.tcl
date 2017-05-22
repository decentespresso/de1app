#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"
source "pkgIndex.tcl"

set ::de1(de1_address) "EE:01:68:94:A5:48"
#set de1(has_flowmeter) 1
package provide de1_plus
package require de1_main
de1_ui_startup