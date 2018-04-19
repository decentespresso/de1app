package provide de1_utils 1.0

# from https://developer.android.com/reference/android/view/View.html#SYSTEM_UI_FLAG_IMMERSIVE
set SYSTEM_UI_FLAG_IMMERSIVE_STICKY 0x00001000
set SYSTEM_UI_FLAG_FULLSCREEN 0x00000004
set SYSTEM_UI_FLAG_HIDE_NAVIGATION 0x00000002
set SYSTEM_UI_FLAG_IMMERSIVE 0x00000800
set SYSTEM_UI_FLAG_LAYOUT_STABLE 0x00000100
set SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION 0x00000200
set SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN 0x00000400
set ::android_full_screen_flags [expr {$SYSTEM_UI_FLAG_LAYOUT_STABLE | $SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | $SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | $SYSTEM_UI_FLAG_HIDE_NAVIGATION | $SYSTEM_UI_FLAG_FULLSCREEN | $SYSTEM_UI_FLAG_IMMERSIVE}]

proc setup_environment {} {
    #puts "setup_environment"
    global screen_size_width
    global screen_size_height
    global fontm
    global android
    global undroid

    if {$android == 1 || $undroid == 1} {
        #package require BLT
        #namespace import blt::*
        #namespace import -force blt::tile::*

        # this causes the app to exit if the main window is closed
        wm protocol . WM_DELETE_WINDOW exit

        # force the screen into landscape if it isn't yet
        msg "orientation: [borg screenorientation]"
        if {[borg screenorientation] != "landscape" && [borg screenorientation] != "reverselandscape"} {
            borg screenorientation landscape
        }

        sdltk screensaver off
        

        if {$::settings(screen_size_width) != "" && $::settings(screen_size_height) != ""} {
            set screen_size_width $::settings(screen_size_width)
            set screen_size_height $::settings(screen_size_height)

        } else {


            # A better approach than a pause to wait for the lower panel to move away might be to "bind . <<ViewportUpdate>>" or (when your toplevel is in fullscreen mode) to "bind . <Configure>" and to watch out for "winfo screenheight" in the bound code.
            if {$android == 1} {
                pause 500
            }

            set width [winfo screenwidth .]
            set height [winfo screenheight .]

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

            # only calculate the tablet's dimensions once, then save it in settings for a faster app startup
            set ::settings(screen_size_width) $screen_size_width 
            set ::settings(screen_size_height) $screen_size_height
            save_settings
        }

        # Android seems to automatically resize fonts appropriately to the current resolution
        set fontm .5
        set ::fontw 1

        if {$::undroid == 1} {
            # undroid does not resize fonts appropriately for the current resolution, it assumes a 1024 resolution
            set fontm [expr {($screen_size_width / 1024.0)}]
            set ::fontw 2
        }

        if {[file exists "skins/default/${screen_size_width}x${screen_size_height}"] != 1} {
            set ::rescale_images_x_ratio [expr {$screen_size_height / 1600.0}]
            set ::rescale_images_y_ratio [expr {$screen_size_width / 2560.0}]
        }

        global helvetica_bold_font
        global helvetica_font

        #puts "setting up fonts for language [language]"
        if {[language] == "th"} {
            set helvetica_font [sdltk addfont "fonts/sarabun.ttf"]
            set helvetica_bold_font [sdltk addfont "fonts/sarabunbold.ttf"]
            set fontm [expr {($fontm * 1.2)}]
            set global_font_name [lindex [sdltk addfont "fonts/NotoSansCJKjp-Regular.otf"] 0]
        } elseif {[language] == "zh-hant" || [language] == "zh-hans" || [language] == "kr"} {
            set helvetica_font [lindex [sdltk addfont "fonts/NotoSansCJKjp-Regular.otf"] 0]
            set helvetica_bold_font [lindex [sdltk addfont "fonts/NotoSansCJKjp-Bold.otf"] 0]
            set global_font_name $helvetica_font

            set fontm [expr {($fontm * .95)}]
        } else {
            # we use the immense google font so that we can handle virtually all of the world's languages with consistency
            set helvetica_font [sdltk addfont "fonts/notosansuiregular.ttf"]
            set helvetica_bold_font [sdltk addfont "fonts/notosansuibold.ttf"]
            set global_font_name [lindex [sdltk addfont "fonts/NotoSansCJKjp-Regular.otf"] 0]
        }            


        font create global_font -family $global_font_name -size [expr {int($fontm * 18)}] 

        font create Helv_12_bold -family $helvetica_bold_font -size [expr {int($fontm * 22)}] 
        font create Helv_12 -family $helvetica_font -size [expr {int($fontm * 22)}] 
        font create Helv_11_bold -family $helvetica_bold_font -size [expr {int($fontm * 20)}] 
        font create Helv_11 -family $helvetica_font -size [expr {int($fontm * 20)}] 
        font create Helv_10_bold -family $helvetica_bold_font -size [expr {int($fontm * 19)}] 
        font create Helv_10 -family $helvetica_font -size [expr {int($fontm * 19)}] 
        font create Helv_1 -family $helvetica_font -size 1
        font create Helv_4 -family $helvetica_font -size [expr {int($fontm * 8)}]
        font create Helv_5 -family $helvetica_font -size [expr {int($fontm * 10)}]
        font create Helv_6 -family $helvetica_font -size [expr {int($fontm * 12)}]
        font create Helv_6_bold -family $helvetica_bold_font -size [expr {int($fontm * 12)}]
        font create Helv_7 -family $helvetica_font -size [expr {int($fontm * 14)}]
        font create Helv_7_bold -family $helvetica_bold_font -size [expr {int($fontm * 14)}]
        font create Helv_8 -family $helvetica_font -size [expr {int($fontm * 16)}]
        font create Helv_8_bold -family $helvetica_bold_font -size [expr {int($fontm * 16)}]
        
        font create Helv_9 -family $helvetica_font -size [expr {int($fontm * 18)}]
        font create Helv_9_bold -family $helvetica_bold_font -size [expr {int($fontm * 18)}] 
        font create Helv_15 -family $helvetica_font -size [expr {int($fontm * 24)}] 
        font create Helv_15_bold -family $helvetica_bold_font -size [expr {int($fontm * 24)}] 
        font create Helv_16_bold -family $helvetica_bold_font -size [expr {int($fontm * 27)}] 
        font create Helv_17_bold -family $helvetica_bold_font -size [expr {int($fontm * 30)}] 
        font create Helv_18_bold -family $helvetica_bold_font -size [expr {int($fontm * 32)}] 
        font create Helv_19_bold -family $helvetica_bold_font -size [expr {int($fontm * 34)}] 
        font create Helv_20_bold -family $helvetica_bold_font -size [expr {int($fontm * 36)}]

        # enable swipe gesture translating, to scroll through listboxes
        # sdltk touchtranslate 1
        # disable touch translating as it does not feel native on tablets and is thus confusing
        sdltk touchtranslate 0

        wm maxsize . $screen_size_width $screen_size_height
        wm minsize . $screen_size_width $screen_size_height
        wm attributes . -fullscreen 1

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
        # john 2/12/18 re-enable this when TTS feature is enabled
        # borg speak { }

        source "bluetooth.tcl"

    } else {

        expr {srand([clock milliseconds])}

        if {$::settings(screen_size_width) != "" && $::settings(screen_size_height) != ""} {
            set screen_size_width $::settings(screen_size_width)
            set screen_size_height $::settings(screen_size_height)
        } else {
            # if this is the first time running on Tk, then use a default 1280x800 resolution, and allow changing resolution by editing settings file
            set screen_size_width 1280
            set screen_size_height 800

            set ::settings(screen_size_width) $screen_size_width 
            set ::settings(screen_size_height) $screen_size_height
            save_settings

        }

        set fontm [expr {$screen_size_width / 1280.0}]
        set ::fontw 2

        package require Tk
        catch {
            # tkblt has replaced BLT in current TK distributions, not on Androwish, they still use BLT and it is preloaded
            package require tkblt
            namespace import blt::*
        }

        wm maxsize . $screen_size_width $screen_size_height
        wm minsize . $screen_size_width $screen_size_height

        if {[file exists "skins/default/${screen_size_width}x${screen_size_height}"] != 1} {
            set ::rescale_images_x_ratio [expr {$screen_size_height / 1600.0}]
            set ::rescale_images_y_ratio [expr {$screen_size_width / 2560.0}]
        }

        set regularfont "notosansuiregular"
        set boldfont "notosansuibold"

        if {[language] == "th"} {
            set regularfont "sarabun"
            set boldfont "sarabunbold"
            #set fontm [expr {($fontm * 1.20)}]
        } elseif {[language] == "zh-hant" || [language] == "zh-hans"} {
            set regularfont "notosansuiregular"
            set boldfont "notosansuibold"
        }

        set ::helvetica_font $regularfont
        font create Helv_1 -family $regularfont -size 1
        font create Helv_4 -family $regularfont -size 10
        font create Helv_5 -family $regularfont -size 12
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
        font create Helv_10_bold -family $boldfont -size [expr {int($fontm * 23)}]
        font create Helv_11 -family $regularfont -size [expr {int($fontm * 25)}]
        font create Helv_11_bold -family $boldfont -size [expr {int($fontm * 25)}]
        font create Helv_12 -family $regularfont -size [expr {int($fontm * 27)}]
        font create Helv_12_bold -family $boldfont -size [expr {int($fontm * 30)}]
        font create Helv_15 -family $regularfont -size [expr {int($fontm * 30)}]
        font create Helv_15_bold -family $boldfont -size [expr {int($fontm * 30)}]
        font create Helv_16_bold -family $boldfont -size [expr {int($fontm * 33)}]
        font create Helv_17_bold -family $boldfont -size [expr {int($fontm * 37)}]
        font create Helv_18_bold -family $boldfont -size [expr {int($fontm * 40)}]
        font create Helv_19_bold -family $boldfont -size [expr {int($fontm * 43)}]
        font create Helv_20_bold -family $boldfont -size [expr {int($fontm * 46)}]

        font create global_font -family "Noto Sans CJK JP" -size [expr {int($fontm * 23)}] 
        android_specific_stubs
        source "bluetooth.tcl"
    }

    # define the canvas
    . configure -bg black 
    canvas .can -width $screen_size_width -height $screen_size_height -borderwidth 0 -highlightthickness 0

    ############################################
    # future feature: flight mode
    #if {$::settings(flight_mode_enable) == 1} {
        #if {$android == 1} {
        #   .can bind . "<<SensorUpdate>>" [accelerometer_data_read]
        #}
        #after 250 accelerometer_check
    #}

    ############################################
}



proc reverse_array {arrname} {
    upvar $arrname arr
    foreach {k v} [array get arr] {
        set newarr($v) $k
    }
    return [array get newarr]
}

# name the procs in the stack
proc stackprocs {} {

    set stack {}
    for {set i 1} {$i < [info level]} {incr i} {
        set lvl [info level -$i]
        set pname [lindex $lvl 0]
        lappend stack $pname
        #foreach value [lrange $lvl 1 end] arg [info args $pname] {
        #    if {$value eq ""} {
        #        info default $pname $arg value
        #    }
        #    append stack " $arg='$value'"
        #}
        #append stack \n
    }
    return $stack
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
        #puts "building saver_files_cache"
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

        #puts "building splash_files_cache"
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

proc language {} {
    global current_language

    if {[ifexists ::settings(language)] != "--" && [ifexists ::settings(language)] != ""} {
        return [ifexists ::settings(language)]
    } 


    if {$::android != 1} {
        # on non-android OS, we don't know the system language so use english if nothing else is set
        return "en"
    }

    # otherwise use the Android system language, if we can

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
            # not sure why Android deviates from KR standard for korean
            set current_language "kr"
        }

    }

    return $current_language
}

proc translation_langs {} {
    set l {}
    foreach {k v} [translation_langs_array] {
        lappend l $k
    }
    return $l
}

# from wikipedia https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes
# converted UTF8 chars to unicode with http://ratfactor.com/utf-8-to-unicode to avoid problems with this source being loaded on Windows (where UTF8 is not the default).
# note that "Arabic" is the descriptor for that language because can make the correct arabic text render with this same font.
proc translation_langs_array {} {
    return [list \
        en English \
        kr "\uD55C\uAD6D\uC5B4" \
        fr "\u0066\u0072\u0061\u006E\u00E7\u0061\u0069\u0073" \
        de Deutsch \
        it italiano \
        da "dansk" \
        sv "svenska" \
        no "Nynorsk" \
        es "\u0065\u0073\u0070\u0061\u00F1\u006F\u006C" \
        pt "\u0070\u006F\u0072\u0074\u0075\u0067\u0075\u00EA\u0073" \
        pl "\u004A\u119\u007A\u0079\u006B\u0020\u0070\u006F\u006C\u0073\u006B\u0069" \
        fi "suomen kieli" \
        zh-hans "\u7C21\u9AD4" \
        zh-hant "\u7E41\u9AD4" \
        th "\uE20\uE32\uE29\uE32\uE44\uE17\uE22" \
        jp "\u65E5\u672C\u8A9E" \
        el "\u39D\u3AD\u3B1\u0020\u395\u3BB\u3BB\u3B7\u3BD\u3B9\u3BA\u3AC" \
        sk "\u0073\u006C\u006F\u0076\u0065\u006E\u10D\u0069\u006E\u0061" \
        cs "\u10D\u0065\u161\u0074\u0069\u006E\u0061" \
        hu "magyar nyelv" \
        tr "\u0054\u00FC\u0072\u006B\u00E7\u0065" \
        ro "\u006C\u0069\u006D\u0062\u0061\u0020\u0072\u006F\u006D\u00E2\u006E\u103" \
        hi "\u939\u93F\u928\u94D\u926\u940" \
        ar "Arabic" \
        nl "Nederlands" \
    ]
}


proc translate {english} {

    if {$english == ""} { 
        return "" 
    }

    if {[language] == "en"} {
        return $english
    }

    #puts "lang: '[language]'"

    global translation

    if {[info exists translation($english)] == 1} {
        # this word has been translated
        array set available $translation($english)
        if {[info exists available([language])] == 1} {
            # this word has been translated into the desired non-english language
            #puts "$available([language])"

            #puts "translate: '[encoding convertfrom $available([language])]'"
            if {$available([language]) != ""} {
                # if the translated version of the English is NOT blank, return it
                return $available([language])
            } else {
                # if the translation is blank, show the English instead
                return $english
            }
        }
    } 

    # if no translation found, return the english text
    if {$::android != 1} {
        if {[info exists ::already_shown_trans($english)] != 1} {
            set t [subst {"$english" \{}]
            foreach {l d} [translation_langs_array] {
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

proc android_specific_stubs {} {

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


proc append_file {filename data} {
    set success 0
    set errcode [catch {
        set fn [open $filename a]
        puts $fn $data 
        close $fn
        set success 1
    }]
    if {$errcode != 0} {
        msg "append_file $::errorInfo"
    }
    return $success
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

    set ::settings(god_espresso_flow) [espresso_flow range 0 end]
    set ::settings(god_espresso_flow_weight) [espresso_flow_weight range 0 end]

    save_settings
    god_shot_reference_reset
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
    god_espresso_flow_2x length 0
    god_espresso_flow_weight_2x length 0

    save_settings
}

proc save_settings {} {
    msg "saving settings"
    save_array_to_file ::settings [settings_filename]

    catch {
        update_temperature_charts_y_axis
    }
    #save_settings_to_de1
    # john not sure what this is for since we're receiving hot water notifications
    #de1_read_hotwater
}

proc load_settings {} {
    puts "loading settings"
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
#        "320x200" 4 4 
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

        if {$::android == 1 || $::undroid == 1} {
            font create $name -family $::helvetica_font -size [expr {int(1.0 * $::fontm * $androidsize)}]
        } else {
            font create "$name" -family $::helvetica_font -size [expr {int(1.0 * $pcsize * $::fontm)}]
            #puts "created font $name in $::helvetica_font"
        }
        return
    } elseif {[language] == "th"} {

        if {$::android == 1 || $::undroid == 1} {
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
        if {$::android == 1 || $::undroid == 1} {
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
    puts -nonewline "Exporting"
    foreach d $dirs {
        array unset -nocomplain arr
        set rootname [file tail $d]
        array set arr [read_file "history/$d"]
        #puts "keys: [array names arr]"
        set x 0
        set lines {}
        set lines [subst {espresso_elapsed, espresso_pressure, espresso_flow, espresso_flow_weight, espresso_temperature_basket, espresso_temperature_mix\n}]

        for {set x 0} {$x < [llength $arr(espresso_elapsed)]} {incr x} {
            set line [subst {[lindex $arr(espresso_elapsed) $x], [lindex $arr(espresso_pressure) $x], [lindex $arr(espresso_flow) $x], [lindex $arr(espresso_flow_weight) $x], [lindex $arr(espresso_temperature_basket) $x], [lindex $arr(espresso_temperature_mix) $x]\n}]
            append lines $line
        }

        set newfile "[file rootname $rootname].csv"
        #puts "$rootname, $newfile"
        puts -nonewline "."
        write_file "history/$newfile" $lines
    }
    puts "done"
    return [lsort -dictionary -increasing $dd]

}









