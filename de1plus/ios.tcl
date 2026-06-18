# ios.tcl -- iOS / iPadOS / Mac Catalyst (iWish) specific startup.
#
# Sourced very early by de1app.tcl, right after `cd` into the bundle and before
# pkgIndex.tcl / any package loads. Keep this file self-contained and dependency
# free (core Tcl + the iWish `borg` shim only), since almost nothing else has
# loaded yet. A no-op on every non-iWish platform.

# iWish self-detection. The iWish borg shim ships a `platform` subcommand that no
# other build has, so we can identify the platform here in the de1app source
# instead of relying on the launcher to set flags. Load Borg first (de1_logging
# uses `borg log` very early), then set ::iwish, and ::ios for a real iOS device
# or the iOS simulator (NOT Mac Catalyst). The launcher only sets up auto_path so
# `package require Borg` can find the battery package.
if {![info exists ::iwish]} {
	if {![catch {package require Borg}] && ![catch {borg platform} ::_iwish_platform]} {
		set ::iwish 1
		if {$::_iwish_platform in {ios iossimulator}} { set ::ios 1 }
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
		# de1app sources/reads both code AND assets through [homedir] (not just
		# writable data), so the seed must include everything it references there:
		# profile_editors/ (sourced by skin standard_includes), fonts/, sounds/,
		# translation.tcl, splash/, etc. Anything missing => white screen on boot.
		set _seed [list settings.tdb profiles profiles_v2 godshots plugins \
			fonts sounds profile_editors translation.tcl allcerts.pem \
			splash simulations fw manifest.tcl timestamp.tcl binary_db.tdb \
			skins/default skins/Insight {skins/Insight Dark} \
			skins/Streamline {skins/Streamline Dark} \
			skins/DSx skins/DSx2 skins/MimojaCafe skins/Metric skins/MiniMetric]
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
