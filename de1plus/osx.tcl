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

# Two markers trigger the writable-copy redirect:
#   notarized.flag  -- the signed+notarized DISTRIBUTION build (ships a MINIMAL
#                      seed, then fills the rest via self-update on first run).
#   standalone.flag -- the make_standalone_osx.sh dev build (ships the WHOLE tree,
#                      so it must NOT self-update -- that would overwrite the dev
#                      code John is testing).
set _minimal [file exists [file join $_bundle "notarized.flag"]]
if {!([info exists ::ios] && $::ios) \
        && ($_minimal || [file exists [file join $_bundle "standalone.flag"]])} {

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
        if {$_firstrun && $_minimal} {
            # First run of the minimal-seed package: announce the move, then pull
            # the rest of the payload (the pruned skins/resolutions, etc.) into
            # [homedir] via the self-updater. Three borg toasts (always-foreground)
            # narrate it: arrival -> download started -> download finished. All
            # deferred until the updater + GUI exist (poll). Toasts are catch-wrapped
            # so a non-borg wish still does the fill silently. start_app_update
            # blocks (pumping events) until done and does NOT auto-restart, so the
            # "restart to apply" toast fires once the whole fetch completes.
            proc ::_osx_fill_minimal_seed {tries} {
                if {[llength [info commands start_app_update]] > 0 \
                        && [info exists ::de1(current_context)]} {
                    catch { borg toast "This OSX version is now in your ~/Documents/de1app" }
                    # Self-update from the SAME channel this package was built for
                    # (osx_update_channel marker: 0=stable 1=beta 2=nightly).
                    catch {
                        set _chf [file join [homedir] "osx_update_channel"]
                        if {[file exists $_chf]} {
                            set _fh [open $_chf r]
                            set _ch [string trim [read $_fh]]
                            close $_fh
                            if {[string is integer -strict $_ch]} {
                                set ::settings(app_updates_beta_enabled) $_ch
                            }
                        }
                    }
                    # Let the arrival toast linger, then kick off the background fill.
                    after 4000 ::_osx_do_minimal_fill
                } elseif {$tries > 0} {
                    after 2000 [list ::_osx_fill_minimal_seed [expr {$tries - 1}]]
                }
            }
            proc ::_osx_do_minimal_fill {} {
                catch { borg toast "Currently running minimal: full app downloading in the background" }
                set _ok 0
                catch { set _ok [start_app_update] }
                if {$_ok == 1} {
                    catch { borg toast "Full app downloaded, restart to apply" }
                }
            }
            after 3000 [list ::_osx_fill_minimal_seed 60]
        }
    }
}
