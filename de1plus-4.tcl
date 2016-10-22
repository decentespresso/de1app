#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"
source "pkgIndex.tcl"
#4
set ::de1(de1_address) "EA:CB:B5:9F:D1:FF"
set de1(has_flowmeter) 1
package require de1_main
de1_ui_startup


