#!/usr/local/bin/tclsh

encoding system utf-8
# No trailing slash: Tcl's zipfs (de1app bundled inside an AndroWish APK as
# read-only assets) rejects `cd` to a trailing-slash path; real filesystems
# accept both, so this is safe on desktop/tablet/iOS too.
cd "[file dirname [info script]]"

# Shared read-only-package -> writable-copy redirect, used by ALL THREE packaged
# builds: ios.tcl (iOS/iWish via SideStep), osx.tcl (macOS .app) and
# google_play_store.tcl (Android Play/sideload). A packaged build ships its de1plus
# tree as read-only assets, but de1app writes log.txt/history/settings/profiles +
# self-updates INTO its own tree via [homedir]; so on first launch we copy the
# WHOLE bundle out to $wdir (~/Documents/Decent), then redirect there -- both the
# DATA root ($::home / homedir) AND the cwd (pkgIndex.tcl registers every package
# with a `./`-relative path, so cd'ing before it loads makes all code load from the
# writable copy too, keeping SELF-UPDATE working). iOS used to be an exception
# (code stayed read-only in the bundle for Apple guideline 2.5.2); since it ships
# via SideStep now, it uses this same path -- see ios.tcl.
#
# Returns 1 on the first run (fresh copy just made), 0 on a later run, or "" if the
# copy is incomplete (caller then stays on the read-only bundle rather than failing
# to boot). On a NEWER build (build_id.txt differs) it refreshes the CODE trees
# (skins/lib/plugins + top-level *.tcl) in the copy, overwrite-ONLY so user data
# (settings.tdb, history/, profiles/, ...) is never touched. All catch-wrapped so
# it can never wedge boot. $tag is only used to label stderr diagnostics.
proc ::de1_redirect_data_root {bundle wdir tag} {
    set _done [file join $wdir ".complete"]
    set _firstrun 0
    if {![file exists $_done]} {
        # First run (or a previously-interrupted one): copy to a temp dir, drop the
        # .complete sentinel LAST, then atomically rename into place. tmp+rename
        # means an aborted copy never leaves a half-populated dir that looks ready.
        catch { file mkdir [file dirname $wdir] }
        set _tmp "${wdir}.tmp"
        catch { file delete -force -- $_tmp }
        if {[catch { file copy -- $bundle $_tmp } _err]} {
            catch { puts stderr "$tag: seed copy failed: $_err" }
        } else {
            catch { close [open [file join $_tmp ".complete"] w] }
            catch { file delete -force -- $wdir }
            catch { file rename -- $_tmp $wdir }
            set _firstrun 1
        }
    }
    # Refresh the CODE in an existing copy when this bundle is a newer build, so a
    # rebuilt package actually takes effect instead of the copy staying frozen.
    if {!$_firstrun && [file exists $_done]} {
        # Build identity for the "refresh code on a newer build" check. Prefer an
        # explicit build_id.txt, but fall back to build-info.txt's version_string:
        # build-info.txt is in the misc.tcl manifest so EVERY read-only build (ipa,
        # apk, appimage, osx) ships it, giving them all a refresh trigger even
        # without a separate build_id.txt file.
        proc ::_de1_build_id {_dir} {
            set _p [file join $_dir "build_id.txt"]
            if {[file exists $_p] \
                    && ![catch { set _h [open $_p r]; set _v [string trim [read $_h]]; close $_h }] \
                    && $_v ne ""} {
                return $_v
            }
            set _bi [file join $_dir "build-info.txt"]
            if {[file exists $_bi] \
                    && ![catch { set _h [open $_bi r]; set _t [read $_h]; close $_h }]} {
                foreach _ln [split $_t "\n"] {
                    if {[regexp {^\s*version_string\s+(.+?)\s*$} $_ln -> _vs]} { return [string trim $_vs] }
                }
            }
            return ""
        }
        set _vb [::_de1_build_id $bundle]
        set _vc [::_de1_build_id $wdir]
        if {$_vb ne "" && $_vb ne $_vc} {
            proc ::_de1_refresh_tree {src dst} {
                foreach _f [glob -nocomplain -directory $src -- *] {
                    set _t [file join $dst [file tail $_f]]
                    if {[file isdirectory $_f]} {
                        if {![file exists $_t]} { catch { file mkdir $_t } }
                        ::_de1_refresh_tree $_f $_t
                    } else {
                        catch { file copy -force -- $_f $_t }
                    }
                }
            }
            foreach _sub {skins lib plugins} {
                set _s [file join $bundle $_sub]
                if {[file isdirectory $_s]} {
                    if {![file exists [file join $wdir $_sub]]} { catch { file mkdir [file join $wdir $_sub] } }
                    catch { ::_de1_refresh_tree $_s [file join $wdir $_sub] }
                }
            }
            foreach _f [glob -nocomplain -directory $bundle -- *.tcl] {
                catch { file copy -force -- $_f [file join $wdir [file tail $_f]] }
            }
            foreach _idf {build-info.txt build_id.txt} {
                set _s2 [file join $bundle $_idf]
                if {[file exists $_s2]} { catch { file copy -force -- $_s2 [file join $wdir $_idf] } }
            }
            catch { puts stderr "$tag: refreshed code in copy to build $_vb" }
        }
    }
    # Redirect only if the writable copy is actually complete.
    if {![file exists $_done]} { return "" }
    # Record the frozen read-only bundle path (before we cd away) so the optional
    # readonly_guard.tcl can flag/redirect any write that targets it.
    set ::_readonly_bundle [file normalize $bundle]
    set ::home $wdir   ;# homedir (updater.tcl) returns $::home once set
    cd $::home         ;# so pkgIndex.tcl + every package load from here
    return $_firstrun
}

# iOS / iPadOS (iWish, sideloaded via SideStep) startup: platform self-detection
# (::iwish/::ios) AND the read-only-bundle redirect via the shared proc above. Must
# run AFTER ::de1_redirect_data_root is defined, and BEFORE osx.tcl/
# google_play_store.tcl (they bail out when ios.tcl has claimed ::ios) and before
# pkgIndex.tcl (it cd's so packages load from the writable copy). No-op off iOS.
source "ios.tcl"

# macOS notarized-bundle data-root redirect: on a notarized.flag / standalone.flag
# build, copy the read-only bundle to ~/Documents/Decent on first run and cd there
# (via ::de1_redirect_data_root) so [homedir] writes and self-update work without
# breaking the code signature. No-op otherwise. Must run after ios.tcl (it skips
# iOS) and before pkgIndex.tcl (it cd's so packages load from the writable copy).
source "osx.tcl"

# Google Play Store / sideload Android build: same read-only-package redirect via
# the shared ::de1_redirect_data_root -- on a google_play.flag / sideload.flag
# build the de1plus tree ships as read-only assets, so copy it to a writable
# ~/Documents/Decent on first run and cd there, keeping [homedir] writes and
# in-app self-update working. (Unlike iOS, Android may run its own scripts from
# writable storage.) No-op on macOS and iOS. Must run after ios.tcl/osx.tcl.
source "google_play_store.tcl"

# The optional read-only write-guard: wraps `open`(write)/`file copy|rename|delete|
# mkdir` so any write that resolves INSIDE the frozen read-only bundle is logged
# (with a stack trace) and transparently redirected into the writable copy, instead
# of silently failing or corrupting the signed/sealed package. A no-op unless a
# `writeguard.flag` marker is present (dropped into the bundle by the packaging
# scripts for the test builds). Must run AFTER all three platform redirects above
# (whichever fired sets ::_readonly_bundle + cd's to the writable copy) and BEFORE
# pkgIndex.tcl / any package load, so it wraps writes from the very first package.
source "readonly_guard.tcl"

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

} elseif {[lsearch -exact $::argv "--sim-screenshot"] >= 0} {

	# Full GUI, then auto-start a simulated espresso and snapshot the chart.
	# Used to diagnose the empty-live-graph regression headlessly.
	after 4000 sim_screenshot_start
	try {
		de1_ui_startup
	} on error {result ropts} {
		msg -CRIT "Untrapped error running de1_ui_startup with result: $result"
		msg -CRIT "$ropts"
		msg -CRIT "Exiting"
		exit
	}

} elseif {[lsearch -exact $::argv "--proc-profile"] >= 0} {

	# Full GUI, simulated espresso, enter-count traces on every proc; dumps
	# call counts after ~20s. Identifies hot procs for performance work.
	after 4000 proc_profile_start
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
		catch { exit_trace "de1_ui_startup ERROR: $result" }
		catch { exit_trace "errorInfo: [dict get $ropts -errorinfo]" }
		msg -CRIT "Untrapped error running de1_ui_startup with result: $result"
		msg -CRIT "$ropts"
		msg -CRIT "Exiting"
		exit
	}
}
