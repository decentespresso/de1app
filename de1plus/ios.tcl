# ios.tcl -- iOS / iPadOS (iWish, sideloaded via SideStep) startup.
#
# Sourced early by de1app.tcl. Two responsibilities, split by WHEN they can run:
#
#   1. PLATFORM DETECTION (::iwish / ::ios) -- must be usable before osx.tcl and
#      google_play_store.tcl decide whether to bail. Done at the top of this file.
#   2. READ-ONLY-BUNDLE REDIRECT -- copy the bundle to ~/Documents/Decent and run
#      from there. Uses the shared ::de1_redirect_data_root (defined in de1app.tcl),
#      so this file MUST be sourced AFTER that proc exists -- which is why de1app.tcl
#      sources ios.tcl right before osx.tcl, not at the very top.
#
# Keep this file self-contained and dependency free (core Tcl + the iWish `borg`
# shim only), since almost nothing else has loaded yet. A no-op on every non-iOS
# platform.
#
# HISTORY: earlier iOS builds used a SPLIT model -- code stayed read-only in the
# bundle, only user DATA went to ~/Documents/Decent -- purely to satisfy Apple App
# Store guideline 2.5.2 (no interpreted code from a writable location), which also
# meant iOS could not self-update. de1app now ships on iOS via SideStep (no App
# Store review), so 2.5.2 no longer applies: iOS uses the SAME copy-the-whole-tree
# -to-Documents model as the macOS .app and the Android APK, which unifies the code
# path AND makes in-app self-update work. See updater.tcl start_app_update.

# --- 1. PLATFORM DETECTION -------------------------------------------------
# iWish/AndroWish self-detection from borg's STANDARD `osbuildinfo` keys: an Apple
# `manufacturer` plus an iPad/iPhone/iPod `model` means we are the iWish build on
# real iOS hardware. (iWish is iOS-only here; the macOS desktop undroidwish build
# reports a "Mac.." model and is neither ::iwish nor ::ios.) Load Borg first
# (de1_logging uses `borg log` very early). The launcher only sets up auto_path so
# `package require Borg` can find the battery package.
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

# --- 2. READ-ONLY-BUNDLE REDIRECT ------------------------------------------
# The iOS app bundle is ALWAYS read-only (every distribution channel), so writing
# into Contents/Resources/de1plus (settings.tdb, log.txt, history/, profiles/, the
# self-update, ...) fails. Copy the WHOLE tree to a writable ~/Documents/Decent on
# first run and redirect there -- both the DATA root ($::home / homedir) AND the
# cwd (pkgIndex.tcl uses `./`-relative paths, so cd'ing before it loads makes all
# code load from the writable copy too). This is exactly what osx.tcl and
# google_play_store.tcl do; iOS no longer needs a marker flag because the bundle is
# unconditionally read-only. Gated strictly to real iOS via ::ios (iOS and macOS
# both report Darwin; only the iWish launcher / detection above knows).
set _bundle [file normalize [file dirname [info script]]]
if {[info exists ::ios] && $::ios} {
	set ::ios_sideload_build 1

	# Remember the read-only bundle path BEFORE the redirect cd's away, so the
	# optional read-only write-guard (readonly_guard.tcl) can flag any code that
	# still tries to write back into the frozen bundle.
	set ::_readonly_bundle $_bundle

	set _firstrun [::de1_redirect_data_root \
		$_bundle [file join $::env(HOME) "Documents" "Decent"] "ios.tcl"]

	# First-run: default the update channel to NIGHTLY so sideloaded users track
	# the latest build, and (once the updater + GUI exist) narrate the copy with a
	# borg toast. Deferred + polled so this very-early set is not clobbered when
	# settings.tdb loads; then persisted. Mirrors google_play_store.tcl. No forced
	# on-launch update -- the full tree is already seeded; the user pulls updates
	# from Settings, or the scheduled check runs.
	if {$_firstrun eq "1"} {
		proc ::_ios_first_run_set_nightly {tries} {
			if {[info exists ::de1(current_context)] \
					&& [llength [info commands start_app_update]] > 0 \
					&& [llength [info commands save_settings]] > 0} {
				catch {
					set ::settings(app_updates_beta_enabled) 2
					save_settings
				}
				catch { borg toast "This iOS version is now in your ~/Documents/Decent" }
			} elseif {$tries > 0} {
				after 2000 [list ::_ios_first_run_set_nightly [expr {$tries - 1}]]
			}
		}
		after 3000 [list ::_ios_first_run_set_nightly 60]
	}
}
