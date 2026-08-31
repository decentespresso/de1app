#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"
source "pkgIndex.tcl"

catch {
	# john 4-11-20 Android 10 is failing on this script, if we don't include these two dependencies
	package require snit
	package require de1_updater
}

package require de1_main
package require de1_gui

## Added by Damian 1st Aug 2025
## Adjust the settings file when copying existing de1plus folders to a new tablet with a different screen size.
##
## IMPORTANT (John/Claude 2026-08-26): this must only ever change screen_size when we
## CONFIDENTLY recognise the new resolution. The original version fell back to
## 1280x800 for any unrecognised resolution and then unconditionally overwrote the
## user's stored screen_size -- which reset font scaling to a wrong value and made
## fonts huge/unreadable (and sometimes crashed on launch) on several Samsung
## tablets after a nightly update. See Basecamp "App update font size issue".
## Fixes: (1) normalise orientation (de1app runs landscape; winfo can report
## portrait), (2) NO destructive fallback -- on an unrecognised resolution we leave
## the user's settings untouched, (3) the whole block is catch-wrapped so it can
## never crash the icon script or corrupt settings.tdb.
if {[file exists "[data_directory]/settings.tdb"] == 1} {
    catch {
        ## find screen size and convert to DUI standards
        set raw_w [winfo screenwidth .]
        set raw_h [winfo screenheight .]
        # Normalise to landscape (width >= height) so a portrait winfo report maps correctly.
        set width  [expr {max($raw_w, $raw_h)}]
        set height [expr {min($raw_w, $raw_h)}]

        set matched 1
        if {$width == 2960 && $height == 1730} {
            # samsung a9 14" tablet custom resolution
            set screen_size_width 2960
            set screen_size_height 1848
        } elseif {$width >= 2300} {
            set screen_size_width 2560
            if {$height > 1450} {
                set screen_size_height 1600
            } else {
                set screen_size_height 1440
            }
        } elseif {$width == 2048 && $height == 1440} {
            set screen_size_width 2048
            set screen_size_height 1440
        } elseif {$width == 2048 && $height == 1536} {
            set screen_size_width 2048
            set screen_size_height 1536
        } elseif {$width == 2000 && ($height == 1128 || $height == 1200)} {
            # samsung a7 (not lite) custom resolution
            set screen_size_width 2000
            set screen_size_height 1200
        } elseif {$width == 1920} {
            set screen_size_width 1920
            set screen_size_height 1200
        } elseif {$width == 1340 && ($height == 736 || $height == 800)} {
            # samsung a7 lite custom resolution
            set screen_size_width 1340
            set screen_size_height 800
        } elseif {$width == 1280} {
            set screen_size_width 1280
            set screen_size_height 800
        } else {
            # Unrecognised resolution: DO NOT guess and DO NOT touch the user's
            # settings -- guessing here is exactly what reset fonts on Samsung tablets.
            set matched 0
        }

        ## Only change settings when we confidently recognised the resolution AND it
        ## actually differs from what is stored (i.e. the folder was moved to a
        ## genuinely different tablet).
        if {$matched} {
            set fn "[data_directory]/settings.tdb"
            array set ::settings [encoding convertfrom utf-8 [read_binary_file $fn]]
            if {$screen_size_width != [ifexists ::settings(screen_size_width)] || $screen_size_height != [ifexists ::settings(screen_size_height)]} {
                unset -nocomplain ::settings(screen_size_height)
                unset -nocomplain ::settings(screen_size_width)

                ## the app doesn't auto size DSx images, switch to Insight skin if the relevant sized images don't exist
                if {[ifexists ::settings(skin)] == "DSx"} {
                    if {[file exists [homedir]/skins/DSx/${screen_size_width}x${screen_size_height}] != 1} {
                        set ::settings(skin) "Insight"
                        catch { popup [translate "DSx ${screen_size_width}x${screen_size_height} folder not found"] }
                    }
                }
                save_array_to_file ::settings $fn
            }
        }
    }
}
## end settings adjustment

install_de1plus_app_icon
exit
