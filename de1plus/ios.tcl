# ios.tcl -- iOS / iPadOS / Mac Catalyst (iWish) specific startup.
#
# Sourced very early by de1app.tcl, right after `cd` into the bundle and before
# pkgIndex.tcl / any package loads. Keep this file self-contained and dependency
# free (core Tcl + the iWish `borg` shim only), since almost nothing else has
# loaded yet. A no-op on every non-iWish platform.

# iWish/AndroWish self-detection from borg's STANDARD `osbuildinfo` keys: an
# Apple `manufacturer` plus an iPad/iPhone/iPod `model` means we are the iWish
# build on real iOS hardware. (iWish is iOS-only; the macOS desktop undroidwish
# build reports a "Mac.." model and is neither ::iwish nor ::ios.) `product`
# carries the friendly product name (iPad/iPhone/Mac), so detection uses model.
# Load Borg first (de1_logging uses `borg log` very early). The launcher only
# sets up auto_path so `package require Borg` can find the battery package.
if {![info exists ::iwish]} {
	if {![catch {package require Borg}] && ![catch {borg osbuildinfo} ::_bi]} {
		set ::_mdl [expr {[dict exists $::_bi model] ? [dict get $::_bi model] : {}}]
		if {[dict exists $::_bi manufacturer] && [dict get $::_bi manufacturer] eq "Apple" \
		    && [regexp {^(iPad|iPhone|iPod)} $::_mdl]} {
			set ::iwish 1
			set ::ios 1
		}
	}
}

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
	# iOS splits the single data root into a read-only CODE root and a writable
	# DATA root. Apple guideline 2.5.2 forbids running interpreted code from a
	# writable/user-visible location, so ALL code and read-only assets (skins,
	# plugins, profile_editors, fonts, sounds, translation.tcl, fw, manifests,
	# ...) stay in the read-only bundle and are read from there via
	# [homedir]/source_directory. ONLY writable user data goes to ~/Documents/Decent
	# (via data_directory). See updater.tcl source_directory/data_directory.
	set _wdir [file join $::env(HOME) "Documents/Decent"]
	set ::home $_bundle   ;# source_directory/homedir -> read-only bundle (code+assets)
	if {![catch {file mkdir $_wdir}]} {
		set ::data_home $_wdir   ;# data_directory -> writable user data
		# Create history/ FIRST so it exists immediately (it is NOT seeded).
		catch { file mkdir [file join $::data_home history] }
		# Seed writable DATA defaults from the bundle on FIRST RUN only; never
		# clobber existing user data on later launches. Code/assets are NOT seeded
		# -- they read directly from the bundle. `splash` is the one asset included,
		# because its images are resized in place under the data root
		# (splash_directory now resolves to [data_directory]/splash). Resized SKIN
		# graphics are cached under the data root too (dui find / image_cache_dir_for),
		# so skins themselves stay read-only in the bundle.
		set _seed [list settings.tdb profiles profiles_v2 godshots splash]
		foreach _item $_seed {
			set _dst [file join $::data_home $_item]
			if {![file exists $_dst] && [file exists [file join $_bundle $_item]]} {
				catch { file mkdir [file dirname $_dst] }
				catch { file copy -- [file join $_bundle $_item] $_dst }
			}
		}
		# Fallback: ensure these exist even if the bundle had nothing to seed.
		foreach _d {godshots profiles profiles_v2} {
			catch { file mkdir [file join $::data_home $_d] }
		}
	}
}
