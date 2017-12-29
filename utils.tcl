package provide de1_utils 1.0


proc homedir {} {
    global home
    if {[info exists home] != 1} {
        set home [file normalize [file dirname [info script]]]
    }
    return $home
}

proc reverse_array {arrname} {
	upvar $arrname arr
	foreach {k v} [array get arr] {
		set newarr($v) $k
	}
	return [array get newarr]
}

proc stacktrace {} {
    set stack "Stack trace:\n"
    for {set i 1} {$i < [info level]} {incr i} {
        set lvl [info level -$i]
        set pname [lindex $lvl 0]
        append stack [string repeat " " $i]$pname
        foreach value [lrange $lvl 1 end] arg [info args $pname] {
            if {$value eq ""} {
                info default $pname $arg value
            }
            append stack " $arg='$value'"
        }
        append stack \n
    }
    return $stack
}

proc random_saver_file {} {


    if {[info exists ::saver_files_cache] != 1} {
        puts "building saver_files_cache"
        set ::saver_files_cache {}
 
        set savers {}
        catch {
            set savers [glob "[saver_directory]/${::screen_size_width}x${::screen_size_height}/*.jpg"]
        }
        if {$savers == ""} {
            catch {
                file mkdir "[saver_directory]/${::screen_size_width}x${::screen_size_height}/"
            }

            set rescale_images_x_ratio [expr {$::screen_size_height / 1600.0}]
            set rescale_images_y_ratio [expr {$::screen_size_width / 2560.0}]

            foreach fn [glob "[saver_directory]/2560x1600/*.jpg"] {
                borg spinner on
                image create photo saver -file $fn
                photoscale saver $rescale_images_y_ratio $rescale_images_x_ratio

                set resized_filename "[saver_directory]/${::screen_size_width}x${::screen_size_height}/[file tail $fn]"
                puts "saving resized image to: $resized_filename"
                borg spinner off

                saver write $resized_filename   -format {jpeg -quality 50}
            }
        }

        set ::saver_files_cache [glob "[saver_directory]/${::screen_size_width}x${::screen_size_height}/*.jpg"]
    }
    return [random_pick $::saver_files_cache]

}

proc random_splash_file {} {
    if {[info exists ::splash_files_cache] != 1} {

        puts "building splash_files_cache"
        set ::splash_files_cache {}
 
        set savers {}
        catch {
            set savers [glob "[splash_directory]/${::screen_size_width}x${::screen_size_height}/*.jpg"]
        }
        if {$savers == ""} {
            catch {
                file mkdir "[splash_directory]/${::screen_size_width}x${::screen_size_height}/"
            }

            set rescale_images_x_ratio [expr {$::screen_size_height / 1600.0}]
            set rescale_images_y_ratio [expr {$::screen_size_width / 2560.0}]

            foreach fn [glob "[splash_directory]/2560x1600/*.jpg"] {
                borg spinner on
                image create photo saver -file $fn
                photoscale saver $rescale_images_y_ratio $rescale_images_x_ratio

                set resized_filename "[splash_directory]/${::screen_size_width}x${::screen_size_height}/[file tail $fn]"
                puts "saving resized image to: $resized_filename"
                borg spinner off
                saver write $resized_filename   -format {jpeg -quality 50}
            }
        }

        set ::splash_files_cache [glob "[splash_directory]/${::screen_size_width}x${::screen_size_height}/*.jpg"]
    }
    return [random_pick $::splash_files_cache]

}

proc random_splash_file_obs {} {
    if {[info exists ::splash_files_cache] != 1} {
        puts "building splash_files_cache"
        set ::splash_files_cache {}
        if {[file exists "[splash_directory]/${::screen_size_width}x${::screen_size_height}/"] == 1} {
            set files [glob "[splash_directory]/${::screen_size_width}x${::screen_size_height}/*.jpg"]
        } else {
            set files [glob "[splash_directory]/2560x1600/*.jpg"]
        }

        borg spinner on
        foreach file $files {
            if {[string first $file resized] == -1} {
                lappend ::splash_files_cache $file
            }
        }
        borg spinner off
        puts "savers: $::splash_files_cache"

    }

    return [random_pick $::splash_files_cache]

}

proc pause {time} {
    global pause_end
    after $time set pause_end 1
    vwait pause_end
    unset -nocomplain pause_end
}


proc language {} {
    global current_language
#return "en"
    if {$::android != 1} {
        #return "sk"
        return en
    }

    #catch {
        #puts "current_language: '$current_language'"
    #}
    #set current_language "zh-hant"

    # the UI language for Decent Espresso is set as the UI language that Android is currently operating in
    if {[info exists current_language] == 0} {
        array set loc [borg locale]

        set current_language $loc(language)
        if {$loc(language) == "zh"} {
            # chinese traditional vs simplified is only differentiated by the country associated with it
            if {$loc(country) == "TW"} {
                set current_language "zh-hant"
            } else {
                set current_language "zh-hans"
            }
        } elseif {$loc(language) == "ko"} {
            # not sure why Androir deviates from KR standard for korean
            set current_language "kr"
        }

        #set current_language "fr"
        #puts "current_language: '$current_language' [array get loc]"

    }

    return $current_language
    #return "en"
    #return "fr"
}

proc translation_langs {} {
    return {fr de it es pt zh-hans zh-hant kr jp ar hu tr th da sv hu fi ro hi pl no sk gr}

}


proc translate {english} {

    if {$english == ""} { 
        return "" 
    }

    if {[language] == "en"} {
        return $english
    }

    global translation

    if {[info exists translation($english)] == 1} {
        # this word has been translated
        array set available $translation($english)
        if {[info exists available([language])] == 1} {
            # this word has been translated into the desired non-english language
            #puts "$available([language])"
            return $available([language])
        }
    } 

    # if no translation found, return the english text
    if {$::android != 1} {
        if {[info exists ::already_shown_trans($english)] != 1} {
            set t [subst {"$english" \{}]
            foreach l [translation_langs] {
                set translation($l) $english
                append t [subst {$l "$english" }]
            }
            append t "\}"
            puts "Appending new phrase: $english"
            msg [stacktrace]
            append_file "[homedir]/translation.tcl" $t
            set ::already_shown_trans($english) 1
        }
    }

    return $english
}

# from https://developer.android.com/reference/android/view/View.html#SYSTEM_UI_FLAG_IMMERSIVE
set SYSTEM_UI_FLAG_IMMERSIVE_STICKY 0x00001000
set SYSTEM_UI_FLAG_FULLSCREEN 0x00000004
set SYSTEM_UI_FLAG_HIDE_NAVIGATION 0x00000002
set SYSTEM_UI_FLAG_IMMERSIVE 0x00000800
set SYSTEM_UI_FLAG_LAYOUT_STABLE 0x00000100
set SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION 0x00000200
set SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN 0x00000400

set ::android_full_screen_flags [expr {$SYSTEM_UI_FLAG_LAYOUT_STABLE | $SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | $SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | $SYSTEM_UI_FLAG_HIDE_NAVIGATION | $SYSTEM_UI_FLAG_FULLSCREEN | $SYSTEM_UI_FLAG_IMMERSIVE}]


#set ::android_full_screen_flags [expr {$SYSTEM_UI_FLAG_IMMERSIVE_STICKY | $SYSTEM_UI_FLAG_FULLSCREEN | $SYSTEM_UI_FLAG_HIDE_NAVIGATION | $SYSTEM_UI_FLAG_IMMERSIVE}]
#set ::android_full_screen_flags [expr {$SYSTEM_UI_FLAG_IMMERSIVE_STICKY}]

proc setup_environment {} {
    #puts "setup_environment"
    global screen_size_width
    global screen_size_height
    global fontm
    global android
    set android 0
    catch {
        package require ble
        set android 1
    }

    #puts "android: $android"

    if {$android == 1} {
        package require BLT
        namespace import blt::*
        namespace import -force blt::tile::*

        #borg systemui 0x1E02
        #borg brightness 0
        #borg brightness $::settings(app_brightness)
        #borg systemui $::android_full_screen_flags

        # force the screen into landscape if it isn't yet
        msg "orientation: [borg screenorientation]"
        if {[borg screenorientation] != "landscape" && [borg screenorientation] != "reverselandscape"} {
            borg screenorientation landscape
        }

        wm attributes . -fullscreen 1
        sdltk screensaver off
        
        # A better approach than a pause to wait for the lower panel to move away might be to "bind . <<ViewportUpdate>>" or (when your toplevel is in fullscreen mode) to "bind . <Configure>" and to watch out for "winfo screenheight" in the bound code.
        pause 200

        set width [winfo screenwidth .]
        set height [winfo screenheight .]

        # sets immersive mode
        #set fontm 1

        # john: it would make sense to save the previous screen size so that we can start up faster, without waiting for the chrome to disappear

        #array set displaymetrics [borg displaymetrics]
        if {$width > 2300} {
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
            #set fontm 2
        } elseif {$width == 2048 && $height == 1536} {
            set screen_size_width 2048
            set screen_size_height 1536
            #set fontm 2
        } elseif {$width == 1920} {
            set screen_size_width 1920
            set screen_size_height 1080
            if {$width > 1080} {
                set screen_size_height 1200
            }

        } elseif {$width == 1280} {
            set screen_size_width 1280
            if {$width > 720} {
                set screen_size_height 800
            } else {
                set screen_size_height 720
            }
        } else {
            # unknown resolution type, go with smallest
            set screen_size_width 1280
            set screen_size_height 720
        }

        if {[file exists "skins/default/${screen_size_width}x${screen_size_height}"] != 1} {
            set ::rescale_images_x_ratio [expr {$screen_size_height / 1600.0}]
            set ::rescale_images_y_ratio [expr {$screen_size_width / 2560.0}]
        }

        #set fontm [expr {$screen_size_width / 1280.0}]
        #set fontm [expr {1280.0 / ($screen_size_width)}]
        set fontm .5
        set ::fontw 1
        #set fontm [expr {2560.0 / $screen_size_width}]
        #set fontm 1

        #set helvetica_font [sdltk addfont "fonts/HelveticaNeue Light.ttf"]
        #set helvetica_bold_font [sdltk addfont "fonts/helvetica-neue-bold.ttf"]
        #set sourcesans_font [sdltk addfont "fonts/SourceSansPro-Regular.ttf"]

        global helvetica_bold_font
        global helvetica_font

        #puts "setting up fonts for language [language]"
        if {[language] == "th"} {
            #set regularfont "sarabun"
            #set boldfont "sarabunbold"
            set helvetica_font [sdltk addfont "fonts/sarabun.ttf"]
            #puts "helvetica_font: $helvetica_font"
            set helvetica_bold_font [sdltk addfont "fonts/sarabunbold.ttf"]
            set fontm [expr {($fontm * 1.2)}]
        #set fontm [expr {($fontm * 1.20)}]
        } elseif {[language] == "zh-hant" || [language] == "zh-hans" || [language] == "kr"} {
            #set helvetica_font [sdltk addfont "fonts/DroidSansFallbackFull.ttf"]
            #set helvetica_font [sdltk addfont "fonts/cwTeXQHei-Bold.ttf"]
            
            set helvetica_font [lindex [sdltk addfont "fonts/NotoSansCJKjp-Regular.otf"] 0]
            #NotoSansCJKjp-Bold
            #puts "helvetica_font: $helvetica_font"
            #set helvetica_font [sdltk addfont "fonts/wts11.ttf"]
            set helvetica_bold_font [lindex [sdltk addfont "fonts/NotoSansCJKjp-Bold.otf"] 0]

            set fontm [expr {($fontm * .95)}]
            #puts "loading asian otf font"
            #set fontm [expr {($fontm * -)}]
            #set fontm 3
        } else {
            set helvetica_font [sdltk addfont "fonts/notosansuiregular.ttf"]
            #puts "helvetica_font: $helvetica_font"
            set helvetica_bold_font [sdltk addfont "fonts/notosansuibold.ttf"]
        }



        #set helvetica_font $helvetica_bold_font
        #puts "helvetica_font: $helvetica_font : fontm: $fontm"
        #puts "helvetica_bold_font: $helvetica_bold_font"
        #puts "1c"

        #set helvetica_font [sdltk addfont "fonts/HelveticaNeueHv.ttf"]
        #set helvetica_font [sdltk addfont "fonts/HelveticaNeue Light.ttf"]
        
        #set helvetica_bold_font [sdltk addfont "fonts/SourceSansPro-Bold.ttf"]

        #set helvetica_bold_font [sdltk addfont "fonts/HelveticaNeueBd.ttf"]
        #set helvetica_bold_font [sdltk addfont "fonts/HelveticaNeueHv.ttf"]

        #set helvetica_bold_font2 [sdltk addfont "fonts/SourceSansPro-Semibold.ttf"]
        #puts "helvetica_bold_font: $helvetica_bold_font2"
        #set sourcesans_font [sdltk addfont "fonts/SourceSansPro-Regular.ttf"]

        font create Helv_12_bold -family $helvetica_bold_font -size [expr {int($fontm * 22)}] 
        font create Helv_12 -family $helvetica_font -size [expr {int($fontm * 22)}] 
        font create Helv_10_bold -family $helvetica_bold_font -size [expr {int($fontm * 19)}] 
        font create Helv_10 -family $helvetica_font -size [expr {int($fontm * 19)}] 
        font create Helv_1 -family $helvetica_font -size 1
        font create Helv_4 -family $helvetica_font -size [expr {int($fontm * 8)}]
        font create Helv_5 -family $helvetica_font -size [expr {int($fontm * 10)}]
        #font create Helv_7 -family $helvetica_font -size 7
        font create Helv_6 -family $helvetica_font -size [expr {int($fontm * 12)}]
        font create Helv_6_bold -family $helvetica_bold_font -size [expr {int($fontm * 12)}]
        font create Helv_7 -family $helvetica_font -size [expr {int($fontm * 14)}]
        font create Helv_7_bold -family $helvetica_bold_font -size [expr {int($fontm * 14)}]
        font create Helv_8 -family $helvetica_font -size [expr {int($fontm * 16)}]
        font create Helv_8_bold -family $helvetica_bold_font -size [expr {int($fontm * 16)}]
        
        font create Helv_9 -family $helvetica_font -size [expr {int($fontm * 18)}]
        font create Helv_9_bold -family $helvetica_bold_font -size [expr {int($fontm * 18)}] 
        #font create Helv_10_bold -family "Source Sans Pro" -size 10 -weight bold
        font create Helv_15 -family $helvetica_font -size [expr {int($fontm * 24)}] 
        font create Helv_15_bold -family $helvetica_bold_font -size [expr {int($fontm * 24)}] 
        font create Helv_18_bold -family $helvetica_bold_font -size [expr {int($fontm * 32)}] 
        font create Helv_20_bold -family $helvetica_bold_font -size [expr {int($fontm * 36)}]

        #font create Sourcesans_30 -family "Source Sans Pro" -size 10
        #font create Sourcesans_20 -family "Source Sans Pro" -size 6

        sdltk touchtranslate 0
        wm maxsize . $screen_size_width $screen_size_height
        wm minsize . $screen_size_width $screen_size_height

        if {$::settings(flight_mode_enable) == 1 && [de1plus] } {
            if {[package require de1plus] > 1} {
                borg sensor enable 0
                sdltk accelerometer 1
                after 200 accelerometer_check 
            }
        }

        #if {[de1plus]} {
        #    set ::settings(timer_interval) 1000
        #}

        # preload the speaking engine
        borg speak { }

        #puts "1d"
        source "bluetooth.tcl"
        #puts "1e"

    } else {

        expr {srand([clock milliseconds])}

        set screen_size_width 2048
        set screen_size_height 1536

        set screen_size_width 1920
        set screen_size_height 1200

        set screen_size_width 2560
        set screen_size_height 1600

        set screen_size_width 640
        set screen_size_height 480

        set screen_size_width 1920
        set screen_size_height 1080

        set screen_size_width 1280
        set screen_size_height 800

        set screen_size_width 2048
        set screen_size_height 1536

        set screen_size_width 640
        set screen_size_height 480

        set screen_size_width 1920
        set screen_size_height 1200

        set screen_size_width 1280
        set screen_size_height 800


        set fontm [expr {$screen_size_width / 1280.0}]
        #puts "fontm: $fontm"

#set fonntm .5

        set ::fontw 2

        #set ::fontw 1
        

        #set screen_size_width 1920
        #set screen_size_height 1080
        #set fontm 1.5

        #set screen_size_width 1280
        #set screen_size_height 720
        #set fontm 1

        package require Tk
        catch {
            package require tkblt
            namespace import blt::*
        }

        wm maxsize . $screen_size_width $screen_size_height
        wm minsize . $screen_size_width $screen_size_height

        if {[file exists "skins/default/${screen_size_width}x${screen_size_height}"] != 1} {
            set ::rescale_images_x_ratio [expr {$screen_size_height / 1600.0}]
            set ::rescale_images_y_ratio [expr {$screen_size_width / 2560.0}]
        }

        #set regularfont "Helvetica Neue Regular"
        #set boldfont "Helvetica Neue Bold"

        set regularfont "notosansuiregular"
        set boldfont "notosansuibold"

        if {[language] == "th"} {
            set regularfont "sarabun"
            set boldfont "sarabunbold"
            #set fontm [expr {($fontm * 1.20)}]
        } elseif {[language] == "zh-hant" || [language] == "zh-hans"} {
            set regularfont "notosansuiregular"
            set boldfont "notosansuibold"
            #set fontm [expr {($fontm * 1.3)}]
        }


        #   puts "setarting up with langage: [language]"
        set ::helvetica_font $regularfont

        font create Helv_1 -family $regularfont -size 1
        font create Helv_4 -family $regularfont -size 10
        font create Helv_5 -family $regularfont -size 12
        #pngfont create Helv_7 -family $regularfont -size 14
        font create Helv_6 -family $regularfont -size [expr {int($fontm * 14)}]
        font create Helv_6_bold -family $boldfont -size [expr {int($fontm * 14)}]
        font create Helv_7 -family $regularfont -size [expr {int($fontm * 16)}]
        font create Helv_7_bold -family $boldfont -size [expr {int($fontm * 16)}]
        font create Helv_8 -family $regularfont -size [expr {int($fontm * 19)}]
        font create Helv_8_bold_underline -family $boldfont -size [expr {int($fontm * 19)}] -underline 1
        font create Helv_8_bold -family $boldfont -size [expr {int($fontm * 19)}]
        font create Helv_9 -family $regularfont -size [expr {int($fontm * 23)}]
        font create Helv_9_bold -family $boldfont -size [expr {int($fontm * 21)}]
        font create Helv_10 -family $regularfont -size [expr {int($fontm * 23)}]
        font create Helv_10_bold -family $boldfont -size [expr {int($fontm * 25)}]
        font create Helv_12 -family $regularfont -size [expr {int($fontm * 27)}]
        font create Helv_12_bold -family $boldfont -size [expr {int($fontm * 30)}]
        font create Helv_15 -family $regularfont -size [expr {int($fontm * 30)}]
        font create Helv_15_bold -family $boldfont -size [expr {int($fontm * 30)}]
        font create Helv_18_bold -family $boldfont -size [expr {int($fontm * 40)}]
        font create Helv_20_bold -family $boldfont -size [expr {int($fontm * 46)}]
        #font create Helv_9_bold -family $boldfont -size [expr {int($fontm * 18)}]
    
        #font create Sourcesans_30 -family {Source Sans Pro Bold} -size 50
        #font create Sourcesans_20 -family {Source Sans Pro Bold} -size 22

        #proc send_de1_shot_and_steam_settings {} {}
        proc ble {args} { puts "    ble $args"; return 1 }
        proc borg {args} { 
            if {[lindex $args 0] == "locale"} {
                return [list "language" "en"]
            } elseif {[lindex $args 0] == "log"} {
                # do nothing
            } else {
                #puts "borg $args"
            }
        }

        #proc save_settings_to_de1 {} {}
        #proc de1_send_steam_hotwater_settings {} {}
        #proc de1_read_hotwater {} {return 90}
        #proc de1_send_shot_frames {} {}

        #proc de1_send {x} { clear_timers;delay_screen_saver; }
        #proc de1_read {} { puts "de1_read" }
        #proc app_exit {} { exit }       
        #proc ble_find_de1s {} { puts "ble_find_de1s" }
        #set ::de1(connect_time) [clock seconds]

        source "bluetooth.tcl"


    }



    ############################################
    # define the canvas
    . configure -bg black 
    canvas .can -width $screen_size_width -height $screen_size_height -borderwidth 0 -highlightthickness 0

    #if {$::settings(flight_mode_enable) == 1} {
        #if {$android == 1} {
        #   .can bind . "<<SensorUpdate>>" [accelerometer_data_read]
        #}
        #after 250 accelerometer_check
    #}

    ############################################
}

proc skin_directory {} {
    global screen_size_width
    global screen_size_height

    set skindir "skins"
    #if {[de1plus]} {
        #set skindir "skinsplus"
    #}

    #if {[ifexists ::creator] == 1} {
        #set skindir "skinscreator"
    #}

    #puts "skind: $skindir"
    #set dir "[file dirname [info script]]/$skindir/default/${screen_size_width}x${screen_size_height}"
    set dir "[homedir]/$skindir/$::settings(skin)"
    return $dir
}



proc settings_directory_graphics {} {
    
    global screen_size_width
    global screen_size_height

    set settingsdir "[homedir]/skins"
    set dir "$settingsdir/$::settings(skin)/${screen_size_width}x${screen_size_height}"
    
    if {[info exists ::rescale_images_x_ratio] == 1} {
        set dir "$settingsdir/$::settings(skin)/2560x1600"
    }
    return $dir
}

proc skin_directory_graphics {} {
    global screen_size_width
    global screen_size_height

    set skindir "[homedir]/skins"
    #if {[ifexists ::de1(has_flowmeter)] == 1} {
    #    set skindir "[homedir]/skinsplus"
    #}

    #if {[ifexists ::creator] == 1} {
    #    set skindir "[homedir]/skinscreator"
    #}

    #puts "skind: $skindir"
    set dir "$skindir/$::settings(skin)/${screen_size_width}x${screen_size_height}"

    if {[info exists ::rescale_images_x_ratio] == 1} {
        set dir "$skindir/$::settings(skin)/2560x1600"
    }
    #puts "skindir '$skindir'"
    #set dir "[file dirname [info script]]/$skindir/default"
    return $dir
}



proc defaultskin_directory_graphics {} {
    global screen_size_width
    global screen_size_height

    set skindir "[homedir]/skins"
    #if {[ifexists ::de1(has_flowmeter)] == 1} {
    #    set skindir "[homedir]/skinsplus"
    #}

    #if {[ifexists ::creator] == 1} {
    #    set skindir "[homedir]/skinscreator"
    #}

    #puts "skind: $skindir"
    set dir "$skindir/default/${screen_size_width}x${screen_size_height}"
    
    if {[info exists ::rescale_images_x_ratio] == 1} {
        set dir "$skindir/default/2560x1600"
    }
    #puts "skindir '$skindir'"
    #set dir "[file dirname [info script]]/$skindir/default"
    return $dir
}
proc saver_directory {} {
    global saver_directory 
    if {[info exists saver_directory] != 1} {
        global screen_size_width
        global screen_size_height
        set saver_directory "[homedir]/saver/${screen_size_width}x${screen_size_height}"
    }
    return $saver_directory 
}

proc splash_directory {} {
    global screen_size_width
    global screen_size_height
    set dir "[homedir]/splash"
    return $dir
}



proc pop { { stack "" } { n 1 } } {
     set s [ uplevel 1 [ list set $stack ] ]
     incr n -1
     set data [ lrange $s 0 $n ]
     incr n
     set s [ lrange $s $n end ]
     uplevel 1 [ list set $stack $s ]
     set data
}

proc unshift { { stack "" } { n 1 } } {
     set s [ uplevel 1 [ list set $stack ] ]
     set data [ lrange $s end-[ expr { $n - 1 } ] end ]
     uplevel 1 [ list set $stack [ lrange $s 0 end-$n ] ]
     set data
}

set accelerometer_read_count 0
proc accelerometer_data_read {} {
    global accelerometer_read_count
    incr accelerometer_read_count

    #set reads {}
    #for {set x 0} {$x < 20} {incr x} {
    #   set a [borg sensor get 0]
    #   set xvalue [lindex [lindex $a 11] 0]
    #   lappend reads $xvalue
    #}
    #msg "reads: $reads"

    #set a [borg sensor get 0]
    #set a 

    #set xvalue [lindex [lindex $a 11] 0]

    mean_accelbuffer
    set xvalue $::ACCEL(e3)

    #msg "xvalue : $xvalue $::ACCEL(e1) $::ACCEL(e2) $::ACCEL(e3)"

    return $xvalue;

    if {$xvalue != "" && $xvalue < 9.807} {
        set accelerometer $xvalue
        set angle [expr {(180/3.141592654) * acos( $xvalue / 9.807) }]
        return $angle
    } else {
        return -1
    }

}

#proc flight_mode_enable {} {
#   return 1
#}

proc mean_accelbuffer {} {
    #after cancel mean_accelbuffer
    #after 250 mean_accelbuffer
    foreach x {1 2 3} {
        set list [sdltk accelbuffer $x]
        set ::ACCEL(f$x) [::tcl::mathop::/ [::tcl::mathop::+ {*}$list] [llength $list]]
        set ::ACCEL(e$x) [expr {$::ACCEL(f$x) / 364}]
    }

    set ::settings(accelerometer_angle) $::ACCEL(e3)
}

proc accelerometer_check {} {
    #global accelerometer

    #set e [borg sensor enable 0]
    set e2 [borg sensor state 0]
    if {$e2 != 1} {
        borg sensor enable 0
    }
    
    set angle [accelerometer_data_read]

    if {$::settings(flight_mode_enable) == 1} {
        if {$angle > "$::settings(flight_mode_angle)"} {
            if {$::de1_num_state($::de1(state)) == "Idle"} {
                start_espresso
            } else {
                if {$::de1_num_state($::de1(state)) == "Espresso"} {
                    # we're currently flying, so use the angle to change the flow/pressure
                }
            }
            set ::settings(flying) 1
        } elseif {$angle < $::settings(flight_mode_angle) && $::settings(flying) == 1 && $::de1_num_state($::de1(state)) == "Espresso"} {
            set ::settings(flying) 0
            start_idle
        }
        #msg "accelerometer angle: $angle"
    }
    after 200 accelerometer_check
}



proc say {txt sndnum} {

    if {$::android != 1} {
        #return
    }

    if {$::settings(enable_spoken_prompts) == 1 && $txt != ""} {
        borg speak $txt {} $::settings(speaking_pitch) $::settings(speaking_rate)
    } else {
        catch {
            # sounds from https://android.googlesource.com/platform/frameworks/base/+/android-5.0.0_r2/data/sounds/effects/ogg?autodive=0%2F%2F%2F%2F%2F%2F
            set path ""
            if {$sndnum == 8} {
                #set path "/system/media/audio/ui/KeypressDelete.ogg"
                #set path "file://mnt/sdcard/de1beta/KeypressStandard_120.ogg"
                set path "sounds/KeypressStandard_120.ogg"
            } elseif {$sndnum == 11} {
                #set path "/system/media/audio/ui/KeypressStandard.ogg"
                set path "sounds/KeypressDelete_120.ogg"
            }
            borg beep $path
            #borg beep $sounds($sndnum)
        }
    }
}


proc fast_write_open {fn parms} {
    set f [open $fn $parms]
    fconfigure $f -blocking 0
    fconfigure $f -buffersize 1000000
    return $f
}

proc write_file {filename data} {
    set fn [fast_write_open $filename w]
    puts $fn $data 
    close $fn
    return 1
}

proc read_file {filename} {
    set data ""
    catch {
        set fn [open $filename]
        set data [read $fn]
        close $fn
    }
    return $data
}

proc append_file {filename data} {
    set fn [open $filename a]
    puts $fn $data 
    close $fn
    return 1
}


proc save_array_to_file {arrname fn} {
    upvar $arrname item
    set toexport2 {}
    foreach k [lsort -dictionary [array names item]] {
        set v $item($k)
        append toexport2 [subst {[list $k] [list $v]\n}]
    }
    write_file $fn $toexport2
}

proc god_shot_save {} {
    set ::settings(god_espresso_pressure) [espresso_pressure range 0 end]
    set ::settings(god_espresso_temperature_basket) [espresso_temperature_basket range 0 end]
    set ::settings(god_espresso_flow) [espresso_flow range 0 end]
    set ::settings(god_espresso_flow_weight) [espresso_flow_weight range 0 end]

    god_espresso_pressure length 0
    god_espresso_temperature_basket length 0
    god_espresso_flow length 0
    god_espresso_flow_weight length 0

    god_espresso_pressure append $::settings(god_espresso_pressure)
    god_espresso_temperature_basket append $::settings(god_espresso_temperature_basket)
    god_espresso_flow append $::settings(god_espresso_flow)
    god_espresso_flow_weight append $::settings(god_espresso_flow_weight)

    save_settings


    #clear_espresso_chart
}

proc god_shot_clear {} {
    set ::settings(god_espresso_pressure) {}
    set ::settings(god_espresso_temperature_basket) {}
    set ::settings(god_espresso_flow) {}
    set ::settings(god_espresso_flow_weight) {}

    god_espresso_pressure length 0
    god_espresso_temperature_basket length 0
    god_espresso_flow length 0
    god_espresso_flow_weight length 0

    save_settings
}

proc save_settings {} {
    msg "saving settings"
    save_array_to_file ::settings [settings_filename]
    #save_settings_to_de1
    # john not sure what this is for since we're receiving hot water notifications
    #de1_read_hotwater
}

proc load_settings {} {
    #puts "loading settings"
    array set ::settings [read_file [settings_filename]]

    set skintcl [read_file "[skin_directory]/skin.tcl"]
    if {![de1plus] && [string first "package require de1plus" $skintcl] != -1} {
        puts "Error: incompatible DE1PLUS skin loaded on a DE1"
        set ::settings(skin) "default"
    }

    if {![de1plus]} {
        set settings(water_temperature) 80
        set settings(water_volume) 100
    }

    blt::vector create espresso_elapsed god_espresso_pressure espresso_pressure espresso_flow god_espresso_flow espresso_flow_weight god_espresso_flow_weight espresso_flow_weight_2x god_espresso_flow_weight_2x espresso_flow_2x god_espresso_flow_2x espresso_flow_delta espresso_pressure_delta espresso_temperature_mix espresso_temperature_basket god_espresso_temperature_basket espresso_state_change espresso_pressure_goal espresso_flow_goal espresso_flow_goal_2x espresso_temperature_goal espresso_weight
    blt::vector create espresso_de1_explanation_chart_pressure espresso_de1_explanation_chart_flow espresso_de1_explanation_chart_elapsed espresso_de1_explanation_chart_elapsed_flow 
    blt::vector create espresso_de1_explanation_chart_flow_1 espresso_de1_explanation_chart_elapsed_flow_1 espresso_de1_explanation_chart_flow_2 espresso_de1_explanation_chart_elapsed_flow_2 espresso_de1_explanation_chart_flow_3 espresso_de1_explanation_chart_elapsed_flow_3
    blt::vector create espresso_de1_explanation_chart_elapsed_1 espresso_de1_explanation_chart_elapsed_2 espresso_de1_explanation_chart_elapsed_3 espresso_de1_explanation_chart_pressure_1 espresso_de1_explanation_chart_pressure_2 espresso_de1_explanation_chart_pressure_3

    # experimental chargts showing flow from the top, or 2x normal size
    blt::vector espresso_flow_delta_negative espresso_flow_delta_negative_2x

    #espresso_temperature_goal append [expr {$::settings(espresso_temperature) - 5}]
    #espresso_elapsed append 0    
    clear_espresso_chart

}

proc settings_filename {} {
    set fn "[homedir]/settings.tdb"
    #puts "sc: '$fn'"
    return $fn
}

proc skin_xskale_factor {} {
    global screen_size_width
    return [expr {2560.0/$screen_size_width}]
}

proc skin_yskale_factor {} {
    global screen_size_height
    return [expr {1600.0/$screen_size_height}]
}

proc rescale_x_skin {in} {
    #puts "rescale_x_skin $in / [skin_xskale_factor]"
    return [expr {int($in / [skin_xskale_factor])}]
}

proc rescale_y_skin {in} {
    return [expr {int($in / [skin_yskale_factor])}]
}

proc rescale_font {in} {
    return [expr {int($in * $::fontm)}]
}


proc skin_convert_all {} {
    skin_convert "[homedir]/saver/2560x1600"
    skin_convert "[homedir]/splash/2560x1600"

    foreach d [lsort -increasing [skin_directories]] {
        skin_convert "[homedir]/skins/$d/2560x1600"
    }
}

proc skin_convert {indir} {
    #puts "skin_convert: $indir"
    cd $indir
    #set skinfiles {}
    set skinfiles [concat [glob -nocomplain "*.png"] [glob -nocomplain  "*.jpg"]]

    if {$skinfiles == ""} {
        puts "No jpg files found in '$indir'"
        return
    }
    set dirs [list \
        "1280x800" 2 2 \
    ]

    set nondirs [list \
        "2048x1536" 1.25 1.041666666 \
        "2048x1440" 1.25 1.11111 \
        "1920x1200" 1.333333 1.333333 \
        "1920x1080" 1.333333 1.4814814815 \
        "1280x720"  2 2.22222 \
        "2560x1440" 1 1.11111 \
    ]

    #set dirs [list \
    #    "1280x800" 2 2 \
    #]



    # convert all the skin PNG files
    foreach {dir xdivisor ydivisor} $dirs {
        #puts -nonewline "Making $dir skin $xdivisor / $ydivisor"
        set started 0


        foreach skinfile $skinfiles {
            if {[file exists "../$dir/$skinfile"] == 1} {
                if {[file mtime $skinfile] < [file mtime "../$dir/$skinfile"]} {
                    #puts "skipping $skinfile [file exists "../$dir/$skinfile"]"
                    # skip files that have not been modified.
                    continue
                }
            }

            if {$started == 0} {
                set started 1
                puts -nonewline "Making $dir skin $indir"
            }

            file mkdir ../$dir

            puts -nonewline "/$skinfile"
            flush stdout
            if {[file extension $skinfile] == ".png"} {
                catch {
                    #-format png8
                	exec convert $skinfile -strip -resize $dir!   ../$dir/$skinfile 
                    
                    # additional optional PNG compression step 
                    exec zopflipng -q --iterations=1 -y   ../$dir/$skinfile   ../$dir/$skinfile 
                    
                }
            } else {

                catch {
                	exec convert $skinfile -resize $dir!  -quality 90 ../$dir/$skinfile 
                }
                if {$skinfile == "icon.jpg"} {
                    # icon files are reduced to 25% of the screen resolution
                    #catch {
                    	exec convert ../$dir/$skinfile -resize 25%  ../$dir/$skinfile 
                    #}
                }
            }
        }


        if {$started != 0} {
            puts "";
        }

    }
}


proc regsubex {regex in replace} {
    set escaped [string map {\[ \\[ \] \\] \$ \\$ \\ \\\\} $in]
    regsub -all $regex $escaped $replace result
    set result [subst $result]
    return $result
}

proc round_date_to_nearest_day {now} {
    set rounded [clock format $now -format "%m/%d/%Y"]  
    return [clock scan $rounded]
}

proc load_font {name fn pcsize {androidsize {}} } {
    if {$androidsize == ""} {
        set androidsize $pcsize
    }

    puts "loadfont: [language]"
 
    if {[language] == "zh-hant" || [language] == "zh-hans"} {

        if {$::android == 1} {
            font create $name -family $::helvetica_font -size [expr {int(1.0 * $::fontm * $androidsize)}]
        } else {
            font create "$name" -family $::helvetica_font -size [expr {int(1.0 * $pcsize * $::fontm)}]
            #puts "created font $name in $::helvetica_font"
        }
        return
    } elseif {[language] == "th"} {

        if {$::android == 1} {
            if {[info exists ::thai_fontname] != 1} {
                set fn "[homedir]/fonts/sarabun.ttf"
                set ::thai_fontname  [sdltk addfont $fn]
            }
            font create $name -family $::thai_fontname -size [expr {int(1.0 * $::fontm * $androidsize)}]
        } else {
            font create "$name" -family "sarabun" -size [expr {int(1.0 * $pcsize * $::fontm)}]
            #puts "created font $name in sarabun"
        }
        return
    } else {
        #puts "$::android load_font $name '$fn' $size : fontm: $::fontm"
        if {$::android == 1} {
            #puts "sdltk addfont '$fn'"
            set result ""
            catch {
                set result [sdltk addfont $fn]
            }
            puts "addfont of '$fn' finished with fonts added: '$result'"
            if {$name != $result} {
                puts "Warning, font name used does not equal Android font name added: '$name' != '$result'"
            }
            catch {
                font create $name -family $name -size [expr {int(1.0 * $::fontm * $androidsize)}]
            }
            
        } else {
            font create "$name" -family "$name" -size [expr {int(1.0 * $pcsize * $::fontm)}]
            #puts "font create \"$name\" -family \"$name\" -size [expr {int($size * $::fontm)}]"
        }

    }
}


proc list_remove_element {list toremove} {
    set newlist [lsearch -all -inline -not -exact $list $toremove]
    #puts "remove  :'$toremove'"
    #puts "oldlist  :$list"
    #puts "newlist: '$newlist'"
    return $newlist
}

proc web_browser {url} {
    msg "Browser '$url'"
    borg activity android.intent.action.VIEW $url text/html
}

proc font_width {untranslated_txt font} {
    set x [font measure $font -displayof .can [translate $untranslated_txt]]
    #if {$::android != 1} {    
        # not sure why font measurements are half off on osx but not on android
        return [expr {2 * $x}]
    #}
    return $x
}

proc array_item_difference {arr1 arr2 keylist} {
    upvar $arr1 a1
    upvar $arr2 a2
    foreach k $keylist {
        if {[ifexists a1($k)] != [ifexists a2($k)]} {
            return 1
        }
    }
    return 0
}



proc shot_history_export {} {

    set dirs [lsort -dictionary [glob -tails -directory "[homedir]/history/" *.shot]]
    set dd {}
    foreach d $dirs {
        array unset -nocomplain arr
        set rootname [file tail $d]
        array set arr [read_file "history/$d"]
        puts "keys: [array names arr]"
        set x 0
        set lines {}
        set lines [subst {espresso_elapsed, espresso_pressure, espresso_flow, espresso_flow_weight, espresso_temperature_basket, espresso_temperature_mix\n}]

        for {set x 0} {$x < [llength $arr(espresso_elapsed)]} {incr x} {
            set line [subst {[lindex $arr(espresso_elapsed) $x], [lindex $arr(espresso_pressure) $x], [lindex $arr(espresso_flow) $x], [lindex $arr(espresso_flow_weight) $x], [lindex $arr(espresso_temperature_basket) $x], [lindex $arr(espresso_temperature_mix) $x]\n}]
            append lines $line
        }

        set newfile "[file rootname $rootname].csv"
        puts "$rootname, $newfile"
        write_file "history/$newfile" $lines
    }
    return [lsort -dictionary -increasing $dd]

}

proc decent_http_get {url {timeout 30000}} {

    set body {}
    set token {}    
    #puts "url: $url"
    #catch {
        ::http::config -useragent "mer454"
        set token [::http::geturl $url -timeout $timeout]
        set body [::http::data $token]

        set cnt 0
        while {[string length $body] == 0} {
            puts "Amazon RequestThrottled #[incr cnt] reissuing GET query"
            sleep 5000
            ::http::cleanup $token
            set token [::http::geturl $url -timeout $timeout]
            set body [::http::data $token]
        }
        #puts "body: $body"
        
        if {[::http::error $token] != ""} {
            debug_puts "http_get error: [::http::error $token]"
        }
        if {$token != ""} {
            ::http::cleanup $token
        }
    #}
    
    return $body
}



proc percent20encode {in} {
    set out $in
    regsub -all " " $out "%20" out
    #regsub -all "&" $out "%26" out
    regsub -all {"} $out "%22" out
    regsub -all {#} $out "%23" out
    regsub -all {'} $out "%27" out
    regsub -all {!} $out "%21" out
    regsub -all {:} $out "%3A" out
    regsub -all {;} $out "%3B" out
    regsub -all {#} $out "%23" out
    #regsub -all {=} $out "%3D" out
    regsub -all {:} $out "%3A" out
    regsub -all "\\?" $out "%3F" out
    regsub -all {@} $out "%40" out
    regsub -all {>} $out "%3E" out
    regsub -all {/} $out "%2F" out
    regsub -all {<} $out "%3C" out
    regsub -all {\$} $out "%24" out
    regsub -all {`} $out "%60" out
    regsub -all {\[} $out "%5B" out
    regsub -all {\]} $out "%5D" out
    regsub -all {~} $out "%7E" out
    regsub -all {\^} $out "%5E" out
    regsub -all {\|} $out "%7C" out
    regsub -all "," $out "%2C" out
    regsub -all "\\)" $out "%29" out
    regsub -all "\\(" $out "%28" out
    
    #puts "urlenc: '$in' / '$out'"
    return $out
}

proc verify_decent_tls_certificate {} {
    package require tls
    set channel [tls::socket decentespresso.com 443]
    tls::handshake $channel

    set status [tls::status $channel]
    close $channel
    
    array set status_array $status
    set sha1 [ifexists status_array(sha1_hash)]
    if {$sha1 == "CBA22B05D7D874275105AB3284E5F2CBE970603E"} {
        return 1
    }

    # if the sha_1 hash on the certificate doesn't match what we expect, return the entire array of what we received from the https connection, optionally to display it to the user
    return $status
}

proc start_app_update {} {

    set cert_check [verify_decent_tls_certificate]
    if {$cert_check != 1} {
        puts "https certification is not what we expect, update failed"
        foreach {k v} $cert_check {
            puts "$k : '$v'"
        }
        return
    }

    set host "http://10.0.1.200:8000"

    set progname "de1"
    if {[de1plus] == 1} {
        set progname "de1plus"
    }

    set url_timestamp "$host/download/sync/$progname/timestamp.txt"
    set remote_timestamp [string trim [decent_http_get $url_timestamp]]
    #puts "timestamp: '$remote_timestamp'"
    set local_timestamp [string trim [read_file "[homedir]/timestamp.txt"]]
    if {$local_timestamp == $remote_timestamp} {
        puts "Local timestamp is the same as remote timestamp, so no need to update"
        #return
    }


    set url_manifest "$host/download/sync/$progname/manifest.txt"
    set remote_manifest [string trim [decent_http_get $url_manifest]]
    set local_manifest [string trim [read_file "[homedir]/manifest.txt"]]

    # load the local manifest into memory
    foreach {filename filesize filemtime filesha} $local_manifest {
        set lmanifest($filename) [list filesize $filesize filemtime $filemtime filesha $filesha]
        #puts "$filename [list filesize $filesize filemtime $filemtime filesha $filesha]"
    }
    #return

    # compare the local vs remote manifest
    foreach {filename filesize filemtime filesha} $remote_manifest {
        array unset -complain data
        array set data [ifexists lmanifest($filename)]
        if {[ifexists data(filesha)] != $filesha} {
            # if the CRCs don't match, then we'll want to fetch this file
            set tofetch($filename) [list filesize $filesize filemtime $filemtime filesha $filesha]
            #puts "SHA256 mismatch '[ifexists data(filesha)]' != '$filesha' : will fetch: $filename"
        }
    }

    set tmpdir "[homedir]/tmp"
    file delete -force $tmpdir
    file mkdir $tmpdir


    foreach {k v} [array get tofetch] {
        unset -nocomplain arr
        array set arr $v
        set fn "$tmpdir/$arr(filesha)"
        set url "$host/download/sync/$progname/[percent20encode $k]"
        write_file $fn [decent_http_get $url]
        set newsha [calc_sha $fn]
        puts "Fetched $k -> $fn ($url) - $arr(filesha) vs $newsha"

    }
    #puts "Files to fetch: [join [array names tofetch] {, }]"

}



proc calc_sha {source} {
    #return [::crc::crc32 -filename $source]
    return [::sha2::sha256 -hex -filename $source]
}
