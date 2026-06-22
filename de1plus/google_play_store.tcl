# google_play_store.tcl -- Google Play Store Android-build data-root redirect.
#
# Sourced very early by de1app.tcl, right after osx.tcl and before pkgIndex.tcl /
# any package load. Keep this file self-contained and dependency free (core Tcl
# only), since almost nothing else has loaded yet. iOS is handled separately by
# ios.tcl; this file bails out if ios.tcl already claimed the platform (::ios).
#
# A NO-OP on every build except a Google-Play-distributed Android build. That
# build is identified by a `google_play.flag` marker file the Play build script
# drops into the bundle's de1plus tree (exactly like osx.tcl's `notarized.flag`).
# An ordinary SIDELOADED Android APK has no marker, so this file does nothing and
# the app runs from its own (already-writable) extracted tree exactly as before.
#
# WHY: this MIRRORS osx.tcl, NOT ios.tcl. A Play build ships the de1plus tree as
# read-only packaged assets, so writing into it via [homedir] (log.txt, history/,
# settings.tdb, profiles, self-update, ...) fails. So on first launch we copy the
# WHOLE tree out to a writable ~/Documents/de1app and redirect there -- both the
# DATA root (homedir) AND the cwd. The cwd matters because pkgIndex.tcl registers
# every package with a `./`-relative path, so cd'ing before `source pkgIndex.tcl`
# makes all code load from the writable copy too -- which is what keeps
# SELF-UPDATE working (the updater writes new .tcl into homedir).
#
# This is the DELIBERATE difference from iOS: iOS forbids running interpreted
# code from a writable/user-visible location (Apple guideline 2.5.2), so ios.tcl
# keeps code read-only in the bundle and disables self-update. Android/Google
# Play has no such restriction -- an app's writable storage may hold and run its
# own scripts -- so Android behaves like the macOS app: writable copy + working
# in-app self-update.
#
# Only de1app.tcl, ios.tcl, osx.tcl and this file run from the (read-only) bundle;
# every other file loads from the writable copy and self-updates normally.
#
# ---------------------------------------------------------------------------
# NOT enforceable from Tcl -- the Play build/packaging side must ALSO handle:
#   * Target API level: target a recent Android API (Play requires within ~1yr).
#   * Runtime BLE permissions: BLUETOOTH_SCAN + BLUETOOTH_CONNECT (Android 12+),
#     with android:usesPermissionFlags="neverForLocation"; request at runtime.
#   * Foreground service: long-lived BLE while screen-off needs a foreground
#     service + notification (and the matching FOREGROUND_SERVICE* perms).
#   * Data Safety form: declare the opt-in cloud uploads (visualizer.coffee,
#     log_upload, the Decent account) and Bluetooth use in the Play console.
#   * Privacy policy URL in the listing.
# This file covers only the runtime concern: a writable data/code root so the
# app (and its self-updater) can run from the read-only Play package.
# ---------------------------------------------------------------------------

set _bundle [file normalize [file dirname [info script]]]

if {!([info exists ::ios] && $::ios) \
        && [file exists [file join $_bundle "google_play.flag"]]} {

    set ::play_store_build 1

    set _wdir [file join $::env(HOME) "Documents" "de1app"]
    set _done [file join $_wdir ".complete"]
    set _firstrun 0

    if {![file exists $_done]} {
        # First run (or a previously-interrupted one): copy the bundle's seed to
        # a temp dir, drop the .complete sentinel LAST, then atomically rename
        # into place. tmp+rename means an aborted copy never leaves a
        # half-populated dir that later looks ready. (The package ships only
        # enough to boot; the rest is fetched by the self-updater below.)
        catch { file mkdir [file dirname $_wdir] }
        set _tmp "${_wdir}.tmp"
        catch { file delete -force -- $_tmp }
        if {[catch { file copy -- $_bundle $_tmp } _err]} {
            catch { puts stderr "google_play_store.tcl: seed copy failed: $_err" }
        } else {
            catch { close [open [file join $_tmp ".complete"] w] }
            catch { file delete -force -- $_wdir }
            catch { file rename -- $_tmp $_wdir }
            set _firstrun 1
        }
    }

    # Redirect only if the writable copy is actually complete; otherwise fall
    # through and run (read-only) from the package rather than failing to boot.
    if {[file exists $_done]} {
        set ::home $_wdir   ;# homedir (updater.tcl) returns $::home once set
        cd $::home          ;# so pkgIndex.tcl + every package load from here

        # On the FIRST run only, pull the rest of the payload (the skins pruned
        # from the package, etc.) into [homedir] via the self-updater. Same
        # deferred-readiness pattern osx.tcl uses: the updater package and the
        # GUI aren't loaded yet at this early point, so the callback waits until
        # both exist, then runs start_app_update once. Kept here so no other file
        # needs to know about Play seeding.
        if {$_firstrun} {
            proc ::_play_fill_minimal_seed {tries} {
                if {[llength [info commands start_app_update]] > 0 \
                        && [info exists ::de1(current_context)]} {
                    catch { start_app_update }
                } elseif {$tries > 0} {
                    after 2000 [list ::_play_fill_minimal_seed [expr {$tries - 1}]]
                }
            }
            after 3000 [list ::_play_fill_minimal_seed 60]
        }
    }
}
