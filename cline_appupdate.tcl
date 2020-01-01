#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"

proc translate {x} {return $x}

# do an app update on the de1plus code base, if this is a de1plus machine
if {[file exists "de1plus.tcl"] == 1} {
	package provide de1plus 1.0
}

source "updater.tcl"
determine_if_android
package require sha256
package require crc32
package require http 2.5
package require tls 1.6
::http::register https 443 ::tls::socket
cd "[file dirname [info script]]/"
set ::settings(logfile) "updatelog.txt"
set debugcnt 0

start_app_update; 
