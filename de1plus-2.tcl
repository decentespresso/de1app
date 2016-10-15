#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"
source "pkgIndex.tcl"

set ::de1(de1_address) "C5:80:EC:A5:F9:72"
set de1(has_flowmeter) 1
package require de1_main
de1_ui_startup