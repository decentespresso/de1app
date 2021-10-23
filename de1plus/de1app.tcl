#!/usr/local/bin/tclsh

encoding system utf-8
cd "[file dirname [info script]]/"
source "pkgIndex.tcl"
source "version.tcl"

package provide de1plus 1.0

package require de1_logging 1.0

set ::enable_profiling 0

if {$::enable_profiling == 1} {
	package require de1_profiler 1.0
}

try {
	package require de1_main
} on error {result ropts} {
	msg -CRIT "Untrapped error loading de1_main with result: $result"
	msg -CRIT "$ropts"
	msg -CRIT "Exiting"
	exit
}

#
# Inline for now, then move out
#

namespace eval ::app {

	variable build_info_filename "build-info.txt"
	variable build_info
	set build_info [dict create]

	variable build_string ""
	variable build_timestamp 0

	proc load_build_info {} {

		variable build_info_filename
		variable build_info

		if { [file readable $build_info_filename] } {

			set _fh [open $build_info_filename "r"]

			foreach _line [split [read $_fh] "\n"] {

				msg -NOTICE "build-info: $_line"

				if { [string length $_line] == 0 } { continue }
				if { [regexp {^[:space:]*#} $_line] } { continue }

				set _kv [split $_line "\t"]
				set _k [lindex $_kv 0]
				if { [llength $_kv] == 1 } {
					set _v ""
				} else {
					set _v [join [lrange $_kv 1 end] "\t"]
				}

				dict append build_info $_k $_v
			}
		} else {

			msg -WARNING "build-info: No such file:" \
				$build_info_filename
		}
	}

	proc ensure_build_strings {} {

		if { [dict exists $::app::build_info version_string] } {
			set ::app::version_string [dict get $::app::build_info version_string]
		} else {
			set ::app::version_string [package version de1app]
		}

		if { [dict exists $::app::build_info build_timestamp] } {

			set ::app::build_timestamp [dict get $::app::build_info build_timestamp]

		} elseif { [file readable "[homedir]/timestamp.txt"] } {

			set _fh [open "[homedir]/timestamp.txt" "r"]

			set ::app::build_timestamp [string trim [read $_fh]]

		} else {

			set ::app::build_timestamp 0
		}

		# Use modified ISO 8601 (no T, add space before zone)

		if { $::app::build_timestamp } {
			set ::app::build_time_string [clock format $::app::build_timestamp \
							      -format "%Y-%m-%d %H:%M:%S %z"]
		} else {
			set ::app::build_time_string [translate "Unknown"]
		}
	}

}

::app::load_build_info
::app::ensure_build_strings

msg -INFO "version_string: $::app::version_string"
msg -INFO "build time: $::app::build_time_string"

try {
	de1_ui_startup
} on error {result ropts} {
	msg -CRIT "Untrapped error running de1_ui_startup with result: $result"
	msg -CRIT "$ropts"
	msg -CRIT "Exiting"
	exit
}
