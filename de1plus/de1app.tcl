#!/usr/local/bin/tclsh

encoding system utf-8
cd "[file dirname [info script]]/"
source "pkgIndex.tcl"
source "version.tcl"
package provide de1plus 1.0
package require de1_logging 1.0
package require de1_main
de1_ui_startup
