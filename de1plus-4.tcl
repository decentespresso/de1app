#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"
source "pkgIndex.tcl"

set ::de1(de1_address) "F2:C3:43:60:AB:F5"
set ::de1(de1_address) "4F:D5:41:66:4D:39"

#4
set ::de1(de1_address) "EA:CB:B5:9F:D1:FF"
set de1(has_flowmeter) 1
package require de1_main
de1_ui_startup


