#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"
source "pkgIndex.tcl"

#set de1(has_flowmeter) 1
#set ::de1(de1_address) "C1:80:A7:32:CD:A3"
package provide de1plus 1.0
package require de1_main
de1_ui_startup