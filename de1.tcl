#!/usr/local/bin/tclsh

source "pkgIndex.tcl"
set de1(has_flowmeter) 0
set ::de1(de1_address) "C1:80:A7:32:CD:A3"
package require de1_main
#cd [homedir]
de1_ui_startup