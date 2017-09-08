#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"
source "pkgIndex.tcl"

#set de1(has_flowmeter) 1
#set ::de1(de1_address) "EE:01:68:94:A5:48"
set ::de1(de1_address) "ed:85:72:b4:b3:a6"

package provide de1plus 1.0
package require de1_main
de1_ui_startup