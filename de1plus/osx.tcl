# osx.tcl -- macOS notarized-bundle data-root redirect.
#
# Sourced very early by de1app.tcl, right after ios.tcl and before pkgIndex.tcl
# / any package load. Keep this file self-contained and dependency free (core
# Tcl only), since almost nothing else has loaded yet.
#
# A NO-OP on every build except the signed+notarized macOS .app. That build is
# identified by a `notarized.flag` marker file the build script drops into the
# bundle's de1plus tree. The ordinary in-place desktop/dev build has no marker,
# so this file does nothing and the app runs from its own (writable) tree
# exactly as before. iOS is handled separately by ios.tcl; this file bails out
# if ios.tcl already claimed the platform (::ios).
#
# WHY: a notarized bundle must stay byte-for-byte immutable or its code
# signature breaks. But de1app writes log.txt, history/, settings.tdb, profiles,
# etc. INTO its own tree via [homedir]. So on first launch we copy the WHOLE
# bundle tree out to a writable ~/Documents/de1app, then redirect there -- both
# the DATA root (homedir) AND the cwd. The cwd matters because pkgIndex.tcl
# registers every package with a `./`-relative path, so cd'ing before
# `source pkgIndex.tcl` makes all code load from the writable copy too -- which
# is what keeps SELF-UPDATE working (the updater writes new .tcl into homedir).
#
# Only de1app.tcl, ios.tcl and this osx.tcl run from the (frozen) bundle; every
# other file loads from the writable copy and updates normally.

set _bundle [file normalize [file dirname [info script]]]

if {!([info exists ::ios] && $::ios) \
        && [file exists [file join $_bundle "notarized.flag"]]} {

    set _wdir [file join $::env(HOME) "Documents" "de1app"]
    set _done [file join $_wdir ".complete"]
    set _firstrun 0

    if {![file exists $_done]} {
        # First run (or a previously-interrupted one): copy the bundle's MINIMAL
        # SEED to a temp dir, drop the .complete sentinel LAST, then atomically
        # rename into place. tmp+rename means an aborted copy never leaves a
        # half-populated dir that later looks ready. Silent -- no confirmation.
        # (The bundle ships only enough to boot; the rest is fetched below.)
        catch { file mkdir [file dirname $_wdir] }
        set _tmp "${_wdir}.tmp"
        catch { file delete -force -- $_tmp }
        if {[catch { file copy -- $_bundle $_tmp } _err]} {
            catch { puts stderr "osx.tcl: seed copy failed: $_err" }
        } else {
            catch { close [open [file join $_tmp ".complete"] w] }
            catch { file delete -force -- $_wdir }
            catch { file rename -- $_tmp $_wdir }
            set _firstrun 1
        }
    }

    # Redirect only if the writable copy is actually complete; otherwise fall
    # through and run (read-only) from the bundle rather than failing to boot.
    if {[file exists $_done]} {
        set ::home $_wdir   ;# homedir (updater.tcl) returns $::home once set
        cd $::home          ;# so pkgIndex.tcl + every package load from here

        # Minimal seed: on the FIRST run only, pull the rest of the payload (the
        # skins pruned from the bundle, etc.) into [homedir]. The self-updater
        # already force-fetches every file missing locally; we just trigger it,
        # because its on-launch auto-run only fires in sleep/saver context.
        # Deferred via `after` + a readiness poll: the updater package and the
        # GUI aren't loaded yet at this very early point, so the callback waits
        # until both exist, then runs start_app_update once. Kept here so no
        # other file needs to know anything about seeding.
        if {$_firstrun} {
            proc ::_osx_fill_minimal_seed {tries} {
                if {[llength [info commands start_app_update]] > 0 \
                        && [info exists ::de1(current_context)]} {
                    catch { start_app_update }
                } elseif {$tries > 0} {
                    after 2000 [list ::_osx_fill_minimal_seed [expr {$tries - 1}]]
                }
            }
            after 3000 [list ::_osx_fill_minimal_seed 60]
        }
    }
}
