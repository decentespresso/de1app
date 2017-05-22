#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"
source "pkgIndex.tcl"

set ::de1(de1_address) "F2:C3:43:60:AB:F5"
#set de1(has_flowmeter) 1
package provide de1_plus
package require de1_main
de1_ui_startup