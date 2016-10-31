#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"
source "pkgIndex.tcl"

set ::de1(has_flowmeter) 1
set ::creator 1
set ::de1(de1_address) "C5:80:EC:A5:F9:72"
package require de1_creatormain
de1_creator_ui_startup