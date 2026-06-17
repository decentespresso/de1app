#!/usr/local/bin/tclsh

encoding system utf-8
cd "[file dirname [info script]]/"

# iOS ONLY: the app sandbox bundle is read-only, so writing into
# Contents/Resources/de1plus (settings.tdb, log.txt, history/, profiles/, ...)
# fails. Keep reading assets from the bundle (cwd, unchanged) but redirect the
# WRITABLE data root -- homedir -- to ~/Documents/Decent.
# Gated strictly to iOS via ::ios (iOS and macOS both report Darwin, so only the
# launcher knows; the iOS launcher sets ::ios before sourcing de1app -- see
# updater.tcl). NOT on macOS desktop/undroidwish or Mac Catalyst: there the
# bundle is writable, and redirecting would make de1_ui_startup's `cd [homedir]`
# move cwd off the bundle so it can't source bluetooth.tcl/translation.tcl.
set _bundle [file normalize [file dirname [info script]]]
if {[info exists ::ios] && $::ios} {
	set _wdir [file join $::env(HOME) "Documents/Decent"]
	if {![catch {file mkdir $_wdir}]} {
		set ::home $_wdir   ;# homedir (updater.tcl) returns $::home once set
		# Create history/ FIRST so it exists immediately -- it is NOT seeded from
		# the bundle, and we don't want it to appear only after the (possibly slow,
		# multi-hundred-MB) whole-skins copy below. (Only history needs this:
		# pre-creating the seeded dirs would make the copy's [file exists] guard
		# skip them, so their bundled defaults would never be copied.)
		catch { file mkdir [file join $::home history] }
		# Then seed defaults from the bundle on FIRST RUN only; never clobber
		# existing user data on later launches: settings, the default profiles,
		# godshots, and a curated set of skins (each copied whole, with all its
		# subdirs -- the user can edit these under the data root; every other
		# skin stays read-only in the bundle).
		set _seed [list settings.tdb profiles profiles_v2 godshots \
			skins/default skins/Insight {skins/Insight Dark} skins/Streamline \
			skins/DSx skins/DSx2 skins/MimojaCafe skins/metric]
		foreach _item $_seed {
			set _dst [file join $::home $_item]
			if {![file exists $_dst] && [file exists [file join $_bundle $_item]]} {
				catch { file mkdir [file dirname $_dst] }
				catch { file copy -- [file join $_bundle $_item] $_dst }
			}
		}
		# Fallback: ensure these exist even if the bundle had nothing to seed.
		foreach _d {godshots profiles profiles_v2} {
			catch { file mkdir [file join $::home $_d] }
		}
	}
}

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

			if {[catch {incr ::app::build_timestamp 0}]} {
				msg -NOTICE "timestamp.txt is not a valid integer: '$::app::build_timestamp', resetting to zero"
				set ::app::build_timestamp 0
			}

			

		} else {

			set ::app::build_timestamp 0
		}

		# Use modified ISO 8601 (no T, add space before zone)

		msg -INFO "Androwish build timestamp : $::app::build_timestamp "
		if { $::app::build_timestamp } {
			set ::app::build_time_string [clock format $::app::build_timestamp -format "%Y-%m-%d %H:%M:%S %z"]
		} else {
			set ::app::build_time_string [translate "Unknown"]
		}

		# ANDROID ONLY : if this androwish version allows us to scan and request Android permissions, then ask for what perms this app needs to properly function
		if {$::android == 1} {
			if {$::app::build_timestamp > 1710864000} {
				set perms_wanted [list \
					android.permission.READ_EXTERNAL_STORAGE \
					android.permission.WRITE_EXTERNAL_STORAGE \
					android.permission.BLUETOOTH_CONNECT \
					android.permission.BLUETOOTH_SCAN \
					android.permission.ACCESS_FINE_LOCATION \
					android.permission.ACCESS_COARSE_LOCATION \
				]

				catch {
					set some_wanted 0
					foreach perm $perms_wanted {
						set p [borg checkpermission $perm]
						if {$p != 1} {
							msg -INFO "Asking for Android app permission : $perm "
							borg checkpermission $perm 1
							set some_wanted 1
						}
					}

					set perms [borg checkpermission]
					foreach perm [lsort $perms] {
						set has [borg checkpermission $perm]
						msg -INFO "Android app permission : $has : $perm "
					}
				}
			}
		}


	}

}

::app::load_build_info
::app::ensure_build_strings

msg -INFO "version_string: $::app::version_string"
msg -INFO "build time: $::app::build_time_string"

if {[lsearch -exact $::argv "--ble-test"] >= 0} {

	# Headless Bluetooth self-test instead of the normal app. Never returns
	# (ends in `exit`), so the GUI is deliberately not started in this mode.
	ble_headless_test

} elseif {[lsearch -exact $::argv "--ble-search-and-exit"] >= 0} {

	# Like --ble-test, but runs the FULL GUI (so macOS can present the
	# Bluetooth permission prompt), then runs the same scan as the in-app BLE
	# SEARCH button and exits cleanly once the scan completes.
	after 3000 ble_search_and_exit
	try {
		de1_ui_startup
	} on error {result ropts} {
		msg -CRIT "Untrapped error running de1_ui_startup with result: $result"
		msg -CRIT "$ropts"
		msg -CRIT "Exiting"
		exit
	}

} else {

	try {
		de1_ui_startup
	} on error {result ropts} {
		msg -CRIT "Untrapped error running de1_ui_startup with result: $result"
		msg -CRIT "$ropts"
		msg -CRIT "Exiting"
		exit
	}
}
