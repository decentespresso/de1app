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
    return [random_pick [glob "[saver_directory]/${::screen_size_width}x${::screen_size_height}/*.jpg"]]
}

proc random_splash_file {} {
    return [random_pick [glob "[splash_directory]/${::screen_size_width}x${::screen_size_height}/*.jpg"]]
    #return [random_pick [glob "/d/admin/code/dbeta/splash/1280x800/*.jpg"]]
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
        return "en"
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
        borg brightness $::settings(app_brightness)
        borg systemui $::android_full_screen_flags

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

        set fontm [expr {1280.0 / ($screen_size_width)}]
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

        set screen_size_width 1920
        set screen_size_height 1200
        set fontm 1.5

        set screen_size_width 2048
        set screen_size_height 1536
        set fontm 1.7

        set screen_size_width 1920
        set screen_size_height 1200
        set fontm 1.5


        set screen_size_width 2560
        set screen_size_height 1600
        set fontm 2

        set screen_size_width 1280
        set screen_size_height 800
        set fontm 1

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
    . configure -bg black 


    ############################################
    # define the canvas
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
                set path "/system/media/audio/ui/KeypressDelete.ogg"
                #set path "file://mnt/sdcard/de1beta/KeypressStandard_120.ogg"
                set path "file://mnt/sdcard/de1beta/KeypressStandard_120.ogg"
            } elseif {$sndnum == 11} {
                set path "/system/media/audio/ui/KeypressStandard.ogg"
                set path "file://mnt/sdcard/de1beta/KeypressDelete_120.ogg"
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

    blt::vector create espresso_elapsed god_espresso_pressure espresso_pressure espresso_flow god_espresso_flow espresso_flow_weight god_espresso_flow_weight espresso_flow_weight_2x god_espresso_flow_weight_2x espresso_flow_2x god_espresso_flow_2x espresso_flow_delta espresso_pressure_delta espresso_temperature_mix espresso_temperature_basket god_espresso_temperature_basket espresso_state_change espresso_pressure_goal espresso_flow_goal espresso_flow_goal_2x espresso_temperature_goal
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

proc make_de1_dir {} {

    set nofiles {

        skins/1960\'s/skin.tcl
        skins/1960\'s/retrofont.ttf
        skins/1960\'s/1280x800/espresso_on.png
        skins/1960\'s/1280x800/icon.jpg
        skins/1960\'s/1280x800/nothing_on.png
        skins/1960\'s/1280x800/steam_on.png
        skins/1960\'s/1280x800/tea_on.png        


        skins/Grafitti/skin.tcl
        skins/Grafitti/Grand\ Stylus.ttf
        skins/Grafitti/1280x800/espresso_on.png
        skins/Grafitti/1280x800/icon.jpg
        skins/Grafitti/1280x800/nothing_on.png
        skins/Grafitti/1280x800/steam_on.png
        skins/Grafitti/1280x800/tea_on.png        


    }

    set files {
        binary.tcl *
        bluetooth.tcl *
        translation.tcl *
        de1plus.tcl 1
        de1.tcl 0
        gui.tcl *
        machine.tcl *
        utils.tcl *
        main.tcl *
        vars.tcl *
        pkgIndex.tcl *
        de1_icon_v2.png 0
        de1plus_icon_v2.png 1

        fonts/NotoSansCJKjp-Bold.otf *
        fonts/NotoSansCJKjp-Regular.otf *
        fonts/notosansuibold.ttf *
        fonts/notosansuiregular.ttf *
        fonts/sarabun.ttf *
        fonts/sarabunbold.ttf *

        splash/1280x800/1960.jpg *
        splash/1280x800/8bit.jpg *
        splash/1280x800/aliens.jpg *
        splash/1280x800/chalkboard.jpg *
        splash/1280x800/circus.jpg *
        splash/1280x800/dark_choices.jpg *
        splash/1280x800/dark_comic.jpg *
        splash/1280x800/fashion_girls.jpg *
        splash/1280x800/grey_room.jpg *
        splash/1280x800/jackpot.jpg *
        splash/1280x800/jimshaw.jpg *
        splash/1280x800/leonardo.jpg *
        splash/1280x800/manga_girls.jpg *
        splash/1280x800/manga_outfits.jpg *
        splash/1280x800/modern.jpg *
        splash/1280x800/warhol.jpg *
        splash/1280x800/watercolor.jpg *
        splash/1280x800/wired_superheroes.jpg *

        skins/default/de1_skin_settings.tcl *
        skins/default/skin.tcl *
        skins/default/standard_includes.tcl *
        skins/default/standard_stop_buttons.tcl *

        skins/Antibes/skin.tcl *
        skins/Antibes/moonflower.ttf *
        skins/Antibes/1280x800/espresso_on.png *
        skins/Antibes/1280x800/icon.jpg *
        skins/Antibes/1280x800/nothing_on.png *
        skins/Antibes/1280x800/steam_on.png *
        skins/Antibes/1280x800/tea_on.png *    

        skins/Borg/skin.tcl *
        skins/Borg/diablo.ttf *
        skins/Borg/1280x800/espresso_on.png *
        skins/Borg/1280x800/icon.jpg *
        skins/Borg/1280x800/nothing_on.png *
        skins/Borg/1280x800/steam_on.png *
        skins/Borg/1280x800/tea_on.png *    

        skins/Aztec/skin.tcl *
        skins/Aztec/aztec.ttf *
        skins/Aztec/1280x800/espresso_on.png *
        skins/Aztec/1280x800/icon.jpg *
        skins/Aztec/1280x800/nothing_on.png *
        skins/Aztec/1280x800/steam_on.png *
        skins/Aztec/1280x800/tea_on.png *    

        skins/Constructivism/skin.tcl *
        skins/Constructivism/orbitron.ttf *
        skins/Constructivism/1280x800/espresso_on.png *
        skins/Constructivism/1280x800/icon.jpg *
        skins/Constructivism/1280x800/nothing_on.png *
        skins/Constructivism/1280x800/steam_on.png *
        skins/Constructivism/1280x800/tea_on.png *    

        skins/Roman\ Gods/skin.tcl *
        skins/Roman\ Gods/renaissance.ttf *
        skins/Roman\ Gods/1280x800/espresso_on.png *
        skins/Roman\ Gods/1280x800/icon.jpg *
        skins/Roman\ Gods/1280x800/nothing_on.png *
        skins/Roman\ Gods/1280x800/steam_on.png *
        skins/Roman\ Gods/1280x800/tea_on.png *    

        skins/8-BIT/skin.tcl *
        skins/8-BIT/pixel.ttf *
        skins/8-BIT/pixel2.ttf *
        skins/8-BIT/1280x800/espresso_on.png *
        skins/8-BIT/1280x800/icon.jpg *
        skins/8-BIT/1280x800/nothing_on.png *
        skins/8-BIT/1280x800/steam_on.png *
        skins/8-BIT/1280x800/tea_on.png *    

        skins/Teal\ Modern/skin.tcl *
        skins/Teal\ Modern/novocento.ttf *
        skins/Teal\ Modern/1280x800/espresso_on.png *
        skins/Teal\ Modern/1280x800/icon.jpg *
        skins/Teal\ Modern/1280x800/nothing_on.png *
        skins/Teal\ Modern/1280x800/steam_on.png *
        skins/Teal\ Modern/1280x800/tea_on.png *    

        skins/Green\ Cups/skin.tcl *
        skins/Green\ Cups/leaguegoth.ttf *
        skins/Green\ Cups/1280x800/espresso_on.png *
        skins/Green\ Cups/1280x800/icon.jpg *
        skins/Green\ Cups/1280x800/nothing_on.png *
        skins/Green\ Cups/1280x800/steam_on.png *
        skins/Green\ Cups/1280x800/tea_on.png *    

        skins/Croissant/skin.tcl *
        skins/Croissant/1280x800/espresso_on.png *
        skins/Croissant/1280x800/icon.jpg *
        skins/Croissant/1280x800/nothing_on.png *
        skins/Croissant/1280x800/steam_on.png *
        skins/Croissant/1280x800/tea_on.png *    

        skins/Noir/skin.tcl *
        skins/Noir/1280x800/espresso_on.png *
        skins/Noir/1280x800/icon.jpg *
        skins/Noir/1280x800/nothing_on.png *
        skins/Noir/1280x800/steam_on.png *
        skins/Noir/1280x800/tea_on.png *    

        skins/Three\ Women/skin.tcl *
        skins/Three\ Women/painthand.ttf *
        skins/Three\ Women/1280x800/espresso_on.png *
        skins/Three\ Women/1280x800/icon.jpg *
        skins/Three\ Women/1280x800/nothing_on.png *
        skins/Three\ Women/1280x800/steam_on.png *
        skins/Three\ Women/1280x800/tea_on.png *    

        skins/Rodent/skin.tcl *
        skins/Rodent/Heroes\ Legend.ttf *
        skins/Rodent/1280x800/espresso_on.png *
        skins/Rodent/1280x800/icon.jpg *
        skins/Rodent/1280x800/nothing_on.png *
        skins/Rodent/1280x800/steam_on.png *
        skins/Rodent/1280x800/tea_on.png *    

        skins/Diner/skin.tcl *
        skins/Diner/bellerose.ttf *
        skins/Diner/1280x800/espresso_on.png *
        skins/Diner/1280x800/icon.jpg *
        skins/Diner/1280x800/nothing_on.png *
        skins/Diner/1280x800/steam_on.png *
        skins/Diner/1280x800/tea_on.png *    

        skins/Insight/skin.tcl 1
        skins/Insight/scentone.tcl 1
        skins/Insight/1280x800/espresso_1.png 1
        skins/Insight/1280x800/espresso_1_zoomed.png 1
        skins/Insight/1280x800/espresso_2.png 1
        skins/Insight/1280x800/espresso_2_zoomed.png 1
        skins/Insight/1280x800/espresso_3.png 1
        skins/Insight/1280x800/espresso_3_zoomed.png 1
        skins/Insight/1280x800/steam_1.png 1
        skins/Insight/1280x800/steam_2.png 1
        skins/Insight/1280x800/steam_3.png 1
        skins/Insight/1280x800/water_1.png 1
        skins/Insight/1280x800/water_2.png 1
        skins/Insight/1280x800/water_3.png 1
        skins/Insight/1280x800/preheat_1.png 1
        skins/Insight/1280x800/preheat_2.png 1
        skins/Insight/1280x800/preheat_3.png 1
        skins/Insight/1280x800/preheat_4.png 1
        skins/Insight/1280x800/scentone_1.jpg 1
        skins/Insight/1280x800/scentone_tropical.jpg 1
        skins/Insight/1280x800/scentone_berry.jpg 1
        skins/Insight/1280x800/scentone_citrus.jpg 1
        skins/Insight/1280x800/scentone_stone.jpg 1
        skins/Insight/1280x800/scentone_cereal.jpg 1
        skins/Insight/1280x800/scentone_chocolate.jpg 1
        skins/Insight/1280x800/scentone_flower.jpg 1
        skins/Insight/1280x800/scentone_spice.jpg 1
        skins/Insight/1280x800/scentone_vegetable.jpg 1
        skins/Insight/1280x800/scentone_savory.jpg 1
        skins/Insight/1280x800/describe_espresso.jpg 1
        skins/Insight/1280x800/describe_espresso2.jpg 1

        skins/default/1280x800/nothing_on.png *
        skins/default/1280x800/espresso_on.png *
        skins/default/1280x800/steam_on.png *
        skins/default/1280x800/tea_on.png *
        skins/default/1280x800/sleep.jpg *
        skins/default/1280x800/filling_tank.jpg *
        skins/default/1280x800/fill_tank.jpg *
        skins/default/1280x800/cleaning.jpg *
        skins/default/1280x800/settings_message.jpg  *
        skins/default/1280x800/descaling.jpg *
        skins/default/1280x800/settings_1.png *
        skins/default/1280x800/settings_2.png 0
        skins/default/1280x800/settings_2a.png 1
        skins/default/1280x800/settings_2a2.png 1
        skins/default/1280x800/settings_2b.png 1
        skins/default/1280x800/settings_2b2.png 1
        skins/default/1280x800/settings_2c.png 1
        skins/default/1280x800/settings_3.png *
        skins/default/1280x800/settings_4.png *
        skins/default/1280x800/icon.jpg *

        saver/1280x800/Black\ Steel.jpg *
        saver/1280x800/Cozy-Home.jpg *
        saver/1280x800/Floral.jpg *
        saver/1280x800/Lomen.jpg *
        saver/1280x800/alice.jpg *
        saver/1280x800/apartment.jpg *
        saver/1280x800/aztec.jpg *
        saver/1280x800/borg.jpg *
        saver/1280x800/cafe_girls.jpg *
        saver/1280x800/cities.jpg *
        saver/1280x800/cups.jpg *
        saver/1280x800/dark_choices.jpg *
        saver/1280x800/french_breakfast.jpg *
        saver/1280x800/graffiti_1.jpg *
        saver/1280x800/graffiti_2.jpg *
        saver/1280x800/graffiti_wall.jpg *
        saver/1280x800/greek_gods.jpg *
        saver/1280x800/hindu_gods.jpg *
        saver/1280x800/jim_shaw.jpg *
        saver/1280x800/manga_fashion.jpg *
        saver/1280x800/manga_girls.jpg *
        saver/1280x800/minimalism.jpg *
        saver/1280x800/scifi.jpg *
        saver/1280x800/sin_city.jpg *
        saver/1280x800/splash_noir.jpg *
        saver/1280x800/splash_rodent.jpg *
        saver/1280x800/splotch.jpg *
        saver/1280x800/steampunk_espresso.jpg *
        saver/1280x800/steampunk_latte.jpg *
        saver/1280x800/superheroes.jpg *
        saver/1280x800/three_women.jpg *     

        profiles/Flat\ 2.5\ mL\ per\ second\ shot\ for\ light\ roasts.tcl *
        profiles/Gentler\ but\ still\ traditional\ 8.4\ bar\ shot.tcl *
        profiles/Good\ flow\ profile\ for\ milky\ drinks.tcl *
        profiles/Good\ flow\ profile\ for\ straight\ espresso.tcl *
        profiles/Low\ pressure\ lever\ machine\ at\ 6\ bar.tcl *
        profiles/Powerful\ 10\ bar\ shot.tcl *
        profiles/Preinfuse\ then\ run\ for\ 45ml\ of\ water.tcl *
        profiles/Recommended\ traditional\ 9\ bar\ shot.tcl *
        profiles/Scott\ Rao\ recommends\ this\ as\ best\ overall.tcl *
        profiles/Slow\ preinfusion\ shot\ for\ very\ light\ roasts.tcl *
        profiles/Traditional\ lever\ machine\ at\ 9\ bar.tcl *
        profiles/Traditional\ single-spring\ lever\ machine.tcl *
        profiles/Trendy\ 6\ bar\ low\ pressure\ shot.tcl *
        profiles/Two\ spring\ lever\ machine\ going\ to\ 9\ bar.tcl *
        profiles/Ultra\ traditional\ 9\ bar\ shot.tcl *
        profiles/default.tcl *
        profiles/e61\ classic\ at\ 9\ bar.tcl *
        profiles/e61\ with\ preinfusion\ at\ 9\ bar.tcl *

       
    }

    set srcdir "/d/admin/code/de1beta"
    set destdirs [list "/d/admin/code/de1" "/d/admin/code/de1plus"]

    set dircount  0
    foreach destdir $destdirs {
        if {[file exists $destdir] != 1} {
            file mkdir $destdir
        }
        
        foreach {file scope} $files {
            if {$scope != $dircount && $scope != "*"} {
                # puts skip copying files that are not part of this scope
                continue
            }
            set source "$srcdir/$file"
            set dest "$destdir/$file"

            if {[file exists [file dirname $dest]] != 1} {
                file mkdir [file dirname $dest]
            }
        


            if {[file exists $source] != 1} {
                puts "File '$source' does not exist'"
                continue
            } 

            if {[file exists $dest] == 1} {
                if {[file mtime $source] == [file mtime $dest]} {
                    # files are identical, do not copy
                    continue
                }
            }

            puts "$file -> $destdir"
            file copy -force $source $dest
        }
        incr dircount
    }

}

