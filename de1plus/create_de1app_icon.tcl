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
## Adjust the settings file when copying existing de1plus folders to new a tablet with a different screen sizes
if {[file exists "[homedir]/settings.tdb"] == 1} {
    ## find screen size and convert to DUI standards
    set width [winfo screenwidth .]
	set height [winfo screenheight .]
	if {$width == 2960 && $height == 1730} {
        # samsung a9 14" tablet custom resolution
            set screen_size_width 2960
            set screen_size_height 1848
        } elseif {$width > 2300} {
            set screen_size_width 2560
            if {$height > 1450} {
                set screen_size_height 1600
            } else {
                set screen_size_height 1440
            }
        } elseif {$height > 2300} {
            set screen_size_width 2560
            if {$width > 1440} {
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
        } elseif {$width == 1340 && ($height == 736 || $height == 800)} {
            # samsung a7 lite custom resolution
            set screen_size_width 1340
            set screen_size_height 800
        } elseif {$width == 2000 && ($height == 1128 || $height == 1200)} {
            # samsung a7 (not lite) custom resolution
            set screen_size_width 2000
            set screen_size_height 1200
        } elseif {$width == 1920} {
            set screen_size_width 1920
            set screen_size_height 1080
            if {$width > 1080} {
                set screen_size_height 1200
            }
        } elseif {$width == 1280} {
            set screen_size_width 1280
            set screen_size_height 800
            if {$width >= 720} {
                set screen_size_height 800
            } else {
                set screen_size_height 720
            }
        } else {
            # unknown resolution type, go with smallest
            set screen_size_width 1280
            set screen_size_height 800
        }

    ## check if settings need changing
    set fn "[homedir]/settings.tdb"
    array set ::settings [encoding convertfrom utf-8 [read_binary_file $fn]]
    if {$screen_size_width != "$::settings(screen_size_width)" || $screen_size_height != $::settings(screen_size_height)} {
        unset -nocomplain ::settings(screen_size_height)
        unset -nocomplain ::settings(screen_size_width)
        
        ## the app doesn't auto size DSx images, switch to Insight skin if the relevant sized images don't exist 
        if {$::settings(skin) == "DSx"} {
            if {[file exists [homedir]/skins/DSx/${screen_size_width}x${screen_size_height}] != 1} {
                set ::settings(skin) "Insight"
                popup [translate "DSx ${screen_size_width}x${screen_size_height} folder not found"]
            }
        }
        save_array_to_file ::settings $fn
    }
}
## end settings adjustment

install_de1plus_app_icon
exit
