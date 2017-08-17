#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"
source "pkgIndex.tcl"

set de1(has_flowmeter) 0
set ::de1(de1_address) "F2:C3:43:60:AB:F5"
package provide de1plus 1.0
package require de1_main
de1_ui_startup


