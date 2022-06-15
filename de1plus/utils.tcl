package provide de1_utils 1.1

package require de1_logging 1.0
package require de1_metadata 1.0

proc setup_environment {} {
	global android
	global undroid
	global settings
	global fontm

	# Set DUI settings from the app stored settings
	foreach s {default_font_calibration use_finger_down_for_tap disable_long_press timer_interval enable_spoken_prompts 
			speaking_pitch speaking_rate } {
		if { [info exists settings($s)] } {
			dui config $s $settings($s)
		}
	}
	dui config language [language]
	dui font add_dirs "[homedir]/fonts/"	
	dui config preload_images $::settings(preload_all_page_images)
	dui sound set button_in "[homedir]/sounds/KeypressStandard_120.ogg" \
		button_out "[homedir]/sounds/KeypressDelete_120.ogg" \
		page_change "[homedir]/sounds/KeypressDelete_120.ogg"
	
	dui init $settings(screen_size_width) $settings(screen_size_height) $settings(orientation)
	
	# Do this after dui init, so if the same image is on the current skin and in default, the one in the skin directory takes precedence
	dui image add_dirs "[homedir]/skins/default/"

	source "bluetooth.tcl"
	
	# Configure actions on specific pages (this was previously hardcoded on page_display_change, and should be moved 
	# later to the part of the GUI that builds those pages).
	dui page add_action off load ::off_page_onload
	dui page add_action saver load ::saver_page_onload
	dui page add_action {} load ::adjust_machine_nextpage
	dui page add_action {} load ::page_onload
	if { $::android == 0 } {
		dui page add_action {} update_vars ::set_dummy_espresso_vars
	}
	
	# only calculate the tablet's dimensions once, then save it in settings for a faster app startup
	set ::screen_size_width [dui cget screen_size_width]
	set ::screen_size_height [dui cget screen_size_height]
	if { $settings(screen_size_width) != $::screen_size_width || $settings(screen_size_height) != $::screen_size_height } {
		set settings(screen_size_width) $::screen_size_width
		set settings(screen_size_height) $::screen_size_height
		save_settings
#	}
	# Enrique: This shouldn't be necessary anymore but still the $::rescale_*_ratio vars are used in a couple of procs
	if { ![file exists "skins/default/${::screen_size_width}x${::screen_size_height}"] } {
		set ::rescale_images_x_ratio [expr {$::screen_size_height / $::dui::_base_screen_height}]
		set ::rescale_images_y_ratio [expr {$::screen_size_width / $::dui::_base_screen_width}]
	}


	# Re-store what are now DUI namespace variables into the original global variables to ensure backwards-compatibility
	# with existing code, until all code is migrated.
	set ::globals(listbox_global_width_multiplier) [dui cget listbox_global_width_multiplier]
	set ::globals(listbox_length_multiplier) [dui cget listbox_length_multiplier] 
	set ::globals(entry_length_multiplier) [dui cget entry_length_multiplier]
	set fontm [dui cget fontm]
	#set ::fontw [dui cget fontw]
	
	# Create hardcoded fonts used in default and Insight skins. These should be replaced by DUI aspects in the future,
	# but are left at the moment to guarantee backwards-compatibility.
	set helvetica_font [dui aspect get dtext font_family -theme default]
	set helvetica_bold_font [dui aspect get dtext font_family -theme default -style bold]
	set global_font_name [dui aspect get dtext font_family -theme default -style global]
	set global_font_size [dui aspect get dtext font_size -theme default -style global]
	set fontawesome_brands [dui aspect get symbol font_family -theme default -style brands]
		
	if {$android == 1 || $undroid == 1} {
        font create Fontawesome_brands_11 -family $fontawesome_brands -size [expr {int($fontm * 20)}]

        font create global_font -family $global_font_name -size [expr {int($fontm * $global_font_size)}] 

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
        font create Helv_19_bold -family $helvetica_bold_font -size [expr {int($fontm * 35)}] 
        font create Helv_20_bold -family $helvetica_bold_font -size [expr {int($fontm * 37)}]
        font create Helv_30_bold -family $helvetica_bold_font -size [expr {int($fontm * 54)}]
        font create Helv_30 -family $helvetica_font -size [expr {int($fontm * 56)}]				
	} else {
		set regularfont $helvetica_font
		set boldfont $helvetica_bold_font
		font create Fontawesome_brands_11 -family $fontawesome_brands -size [expr {int($fontm * 25)}]
		
		font create global_font -family $global_font_name  -size [expr {int($fontm * 23)}] 
				
		set regularfont $helvetica_font
		set boldfont $helvetica_bold_font
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
        font create Helv_19_bold -family $boldfont -size [expr {int($fontm * 45)}]
        font create Helv_20_bold -family $boldfont -size [expr {int($fontm * 48)}]
        font create Helv_30_bold -family $boldfont -size [expr {int($fontm * 69)}]
        font create Helv_30 -family $regularfont -size [expr {int($fontm * 72)}]
	}
	
	metadata init
	source "app_metadata.tcl"
	init_app_metadata
			
	after 60000 schedule_minute_task

	return
	
#    #puts "setup_environment"
#    global screen_size_width
#    global screen_size_height
#    global fontm
#    global android
#    global undroid
#
#    set ::globals(listbox_length_multiplier) 1
#    set ::globals(listbox_global_width_multiplier) 1
#
#    set ::globals(entry_length_multiplier) 1
#
#    if {$android == 1 || $undroid == 1} {
#
#        # hide the android keyboard that pops up when you power back on
#        bind . <<DidEnterForeground>> hide_android_keyboard
#
#        # this causes the app to exit if the main window is closed
#        wm protocol . WM_DELETE_WINDOW exit
#
#        # set the window title of the app. Only visible when casting the app via jsmpeg, and when running the app in a window using undroidwish
#        wm title . "Decent"
#
#        # force the screen into landscape if it isn't yet
#        msg "orientation: [borg screenorientation]"
#        if {[borg screenorientation] != "landscape" && [borg screenorientation] != "reverselandscape"} {
#            borg screenorientation $::settings(orientation)
#        }
#
#        sdltk screensaver off
#        
#
#        if {$::settings(screen_size_width) != "" && $::settings(screen_size_height) != ""} {
#            set screen_size_width $::settings(screen_size_width)
#            set screen_size_height $::settings(screen_size_height)
#
#        } else {
#
#
#            # A better approach than a pause to wait for the lower panel to move away might be to "bind . <<ViewportUpdate>>" or (when your toplevel is in fullscreen mode) to "bind . <Configure>" and to watch out for "winfo screenheight" in the bound code.
#            if {$android == 1} {
#                pause 500
#            }
#
#            set width [winfo screenwidth .]
#            set height [winfo screenheight .]
#
#            if {$width > 2300} {
#                set screen_size_width 2560
#                if {$height > 1450} {
#                    set screen_size_height 1600
#                } else {
#                    set screen_size_height 1440
#                }
#            } elseif {$height > 2300} {
#                set screen_size_width 2560
#                if {$width > 1440} {
#                    set screen_size_height 1600
#                } else {
#                    set screen_size_height 1440
#                }
#            } elseif {$width == 2048 && $height == 1440} {
#                set screen_size_width 2048
#                set screen_size_height 1440
#                #set fontm 2
#            } elseif {$width == 2048 && $height == 1536} {
#                set screen_size_width 2048
#                set screen_size_height 1536
#                #set fontm 2
#            } elseif {$width == 1920} {
#                set screen_size_width 1920
#                set screen_size_height 1080
#                if {$width > 1080} {
#                    set screen_size_height 1200
#                }
#
#            } elseif {$width == 1280} {
#                set screen_size_width 1280
#                set screen_size_height 800
#                if {$width >= 720} {
#                    set screen_size_height 800
#                } else {
#                    set screen_size_height 720
#                }
#            } else {
#                # unknown resolution type, go with smallest
#                set screen_size_width 1280
#                set screen_size_height 800
#            }
#
#            # only calculate the tablet's dimensions once, then save it in settings for a faster app startup
#            set ::settings(screen_size_width) $screen_size_width 
#            set ::settings(screen_size_height) $screen_size_height
#            save_settings
#        }
#
#        # Android seems to automatically resize fonts appropriately to the current resolution
#        set fontm $::settings(default_font_calibration)
#        set ::fontw 1
#
#        if {$::undroid == 1} {
#            # undroid does not resize fonts appropriately for the current resolution, it assumes a 1024 resolution
#            set fontm [expr {($screen_size_width / 1024.0)}]
#            set ::fontw 2
#        }
#
#        if {[file exists "skins/default/${screen_size_width}x${screen_size_height}"] != 1} {
#            set ::rescale_images_x_ratio [expr {$screen_size_height / 1600.0}]
#            set ::rescale_images_y_ratio [expr {$screen_size_width / 2560.0}]
#        }
#
#        global helvetica_bold_font
#        global helvetica_font
#        set global_font_size 18
#        #puts "setting up fonts for language [language]"
#        if {[language] == "th"} {
#            set helvetica_font [sdltk addfont "fonts/sarabun.ttf"]
#            set helvetica_bold_font [sdltk addfont "fonts/sarabunbold.ttf"]
#            set fontm [expr {($fontm * 1.2)}]
#            set global_font_name [lindex [sdltk addfont "fonts/NotoSansCJKjp-Regular.otf"] 0]
#            set global_font_size 16
#        } elseif {[language] == "ar" || [language] == "arb"} {
#            set helvetica_font [sdltk addfont "fonts/Dubai-Regular.otf"]
#            set helvetica_bold_font [sdltk addfont "fonts/Dubai-Bold.otf"]
#            set global_font_name [lindex [sdltk addfont "fonts/NotoSansCJKjp-Regular.otf"] 0]
#        } elseif {[language] == "he" || [language] == "heb"} {
#            set ::globals(listbox_length_multiplier) 1.35
#            set ::globals(entry_length_multiplier) 0.86
#            set helvetica_font [sdltk addfont "fonts/hebrew-regular.ttf"]
#            set helvetica_bold_font [sdltk addfont "fonts/hebrew-bold.ttf"]
#            set global_font_name [lindex [sdltk addfont "fonts/NotoSansCJKjp-Regular.otf"] 0]
#        } elseif {[language] == "zh-hant" || [language] == "zh-hans" || [language] == "kr"} {
#            set helvetica_font [lindex [sdltk addfont "fonts/NotoSansCJKjp-Regular.otf"] 0]
#            set helvetica_bold_font [lindex [sdltk addfont "fonts/NotoSansCJKjp-Bold.otf"] 0]
#            set global_font_name $helvetica_font
#
#            set fontm [expr {($fontm * .94)}]
#        } else {
#            # we use the immense google font so that we can handle virtually all of the world's languages with consistency
#            set helvetica_font [sdltk addfont "fonts/notosansuiregular.ttf"]
#            set helvetica_bold_font [sdltk addfont "fonts/notosansuibold.ttf"]
#            set global_font_name [lindex [sdltk addfont "fonts/NotoSansCJKjp-Regular.otf"] 0]
#
#        }            
#
#        set fontawesome_brands [lindex [sdltk addfont "fonts/Font Awesome 5 Brands-Regular-400.otf"] 0]
#        font create Fontawesome_brands_11 -family $fontawesome_brands -size [expr {int($fontm * 20)}]
#
#        font create global_font -family $global_font_name -size [expr {int($fontm * $global_font_size)}] 
#
#        font create Helv_12_bold -family $helvetica_bold_font -size [expr {int($fontm * 22)}] 
#        font create Helv_12 -family $helvetica_font -size [expr {int($fontm * 22)}] 
#        font create Helv_11_bold -family $helvetica_bold_font -size [expr {int($fontm * 20)}] 
#        font create Helv_11 -family $helvetica_font -size [expr {int($fontm * 20)}] 
#        font create Helv_10_bold -family $helvetica_bold_font -size [expr {int($fontm * 19)}] 
#        font create Helv_10 -family $helvetica_font -size [expr {int($fontm * 19)}] 
#        font create Helv_1 -family $helvetica_font -size 1
#        font create Helv_4 -family $helvetica_font -size [expr {int($fontm * 8)}]
#        font create Helv_5 -family $helvetica_font -size [expr {int($fontm * 10)}]
#        font create Helv_6 -family $helvetica_font -size [expr {int($fontm * 12)}]
#        font create Helv_6_bold -family $helvetica_bold_font -size [expr {int($fontm * 12)}]
#        font create Helv_7 -family $helvetica_font -size [expr {int($fontm * 14)}]
#        font create Helv_7_bold -family $helvetica_bold_font -size [expr {int($fontm * 14)}]
#        font create Helv_8 -family $helvetica_font -size [expr {int($fontm * 16)}]
#        font create Helv_8_bold -family $helvetica_bold_font -size [expr {int($fontm * 16)}]
#        
#        font create Helv_9 -family $helvetica_font -size [expr {int($fontm * 18)}]
#        font create Helv_9_bold -family $helvetica_bold_font -size [expr {int($fontm * 18)}] 
#        font create Helv_15 -family $helvetica_font -size [expr {int($fontm * 24)}] 
#        font create Helv_15_bold -family $helvetica_bold_font -size [expr {int($fontm * 24)}] 
#        font create Helv_16_bold -family $helvetica_bold_font -size [expr {int($fontm * 27)}] 
#        font create Helv_17_bold -family $helvetica_bold_font -size [expr {int($fontm * 30)}] 
#        font create Helv_18_bold -family $helvetica_bold_font -size [expr {int($fontm * 32)}] 
#        font create Helv_19_bold -family $helvetica_bold_font -size [expr {int($fontm * 35)}] 
#        font create Helv_20_bold -family $helvetica_bold_font -size [expr {int($fontm * 37)}]
#        font create Helv_30_bold -family $helvetica_bold_font -size [expr {int($fontm * 54)}]
#        font create Helv_30 -family $helvetica_font -size [expr {int($fontm * 56)}]
#
#        # enable swipe gesture translating, to scroll through listboxes
#        # sdltk touchtranslate 1
#        # disable touch translating as it does not feel native on tablets and is thus confusing
#        if {$::settings(disable_long_press) != 1 } {        
#            sdltk touchtranslate 1
#        } else {
#            sdltk touchtranslate 0
#        }
#
#        wm maxsize . $screen_size_width $screen_size_height
#        wm minsize . $screen_size_width $screen_size_height
#        wm attributes . -fullscreen 1
#
#        # flight mode, not yet debugged
#        #if {$::settings(flight_mode_enable) == 1 } {
#        #    if {[package require de1plus] > 1} {
#        #        borg sensor enable 0
#        #        sdltk accelerometer 1
#        #        after 200 accelerometer_check 
#        #    }
#        #}
#
#        # preload the speaking engine 
#        # john 2/12/18 re-enable this when TTS feature is enabled
#        # borg speak { }
#
#        source "bluetooth.tcl"
#
#    } else {
#
#        # global font is wider on non-android
#        set ::globals(listbox_global_width_multiplier) .8
#        set ::globals(listbox_length_multiplier) 1
#
#
#        expr {srand([clock milliseconds])}
#
#        if {$::settings(screen_size_width) != "" && $::settings(screen_size_height) != ""} {
#            set screen_size_width $::settings(screen_size_width)
#            set screen_size_height $::settings(screen_size_height)
#        } else {
#            # if this is the first time running on Tk, then use a default 1280x800 resolution, and allow changing resolution by editing settings file
#            set screen_size_width 1280
#            set screen_size_height 800
#
#            set ::settings(screen_size_width) $screen_size_width 
#            set ::settings(screen_size_height) $screen_size_height
#            save_settings
#
#        }
#
#        set fontm [expr {$screen_size_width / 1280.0}]
#        set ::fontw 2
#
#        package require Tk
#        catch {
#            # tkblt has replaced BLT in current TK distributions, not on Androwish, they still use BLT and it is preloaded
#            package require tkblt
#            namespace import blt::*
#        }
#
#        wm maxsize . $screen_size_width $screen_size_height
#        wm minsize . $screen_size_width $screen_size_height
#
#        if {[file exists "skins/default/${screen_size_width}x${screen_size_height}"] != 1} {
#            set ::rescale_images_x_ratio [expr {$screen_size_height / 1600.0}]
#            set ::rescale_images_y_ratio [expr {$screen_size_width / 2560.0}]
#        }
#
#        set regularfont "notosansuiregular"
#        set boldfont "notosansuibold"
#
#        if {[language] == "th"} {
#            set regularfont "sarabun"
#            set boldfont "sarabunbold"
#            #set fontm [expr {($fontm * 1.20)}]
#        } elseif {[language] == "zh-hant" || [language] == "zh-hans"} {
#            set regularfont "notosansuiregular"
#            set boldfont "notosansuibold"
#        }
#
#        set ::helvetica_font $regularfont
#        font create Helv_1 -family $regularfont -size 1
#        font create Helv_4 -family $regularfont -size 10
#        font create Helv_5 -family $regularfont -size 12
#        font create Helv_6 -family $regularfont -size [expr {int($fontm * 14)}]
#        font create Helv_6_bold -family $boldfont -size [expr {int($fontm * 14)}]
#        font create Helv_7 -family $regularfont -size [expr {int($fontm * 16)}]
#        font create Helv_7_bold -family $boldfont -size [expr {int($fontm * 16)}]
#        font create Helv_8 -family $regularfont -size [expr {int($fontm * 19)}]
#        font create Helv_8_bold_underline -family $boldfont -size [expr {int($fontm * 19)}] -underline 1
#        font create Helv_8_bold -family $boldfont -size [expr {int($fontm * 19)}]
#        font create Helv_9 -family $regularfont -size [expr {int($fontm * 23)}]
#        font create Helv_9_bold -family $boldfont -size [expr {int($fontm * 21)}]
#        font create Helv_10 -family $regularfont -size [expr {int($fontm * 23)}]
#        font create Helv_10_bold -family $boldfont -size [expr {int($fontm * 23)}]
#        font create Helv_11 -family $regularfont -size [expr {int($fontm * 25)}]
#        font create Helv_11_bold -family $boldfont -size [expr {int($fontm * 25)}]
#        font create Helv_12 -family $regularfont -size [expr {int($fontm * 27)}]
#        font create Helv_12_bold -family $boldfont -size [expr {int($fontm * 30)}]
#        font create Helv_15 -family $regularfont -size [expr {int($fontm * 30)}]
#        font create Helv_15_bold -family $boldfont -size [expr {int($fontm * 30)}]
#        font create Helv_16_bold -family $boldfont -size [expr {int($fontm * 33)}]
#        font create Helv_17_bold -family $boldfont -size [expr {int($fontm * 37)}]
#        font create Helv_18_bold -family $boldfont -size [expr {int($fontm * 40)}]
#        font create Helv_19_bold -family $boldfont -size [expr {int($fontm * 45)}]
#        font create Helv_20_bold -family $boldfont -size [expr {int($fontm * 48)}]
#        font create Helv_30_bold -family $boldfont -size [expr {int($fontm * 69)}]
#        font create Helv_30 -family $regularfont -size [expr {int($fontm * 72)}]
#
#        
#        font create Fontawesome_brands_11 -family "Font Awesome 5 Brands Regular" -size [expr {int($fontm * 25)}]
#
#
#        font create global_font -family "Noto Sans CJK JP" -size [expr {int($fontm * 23)}] 
#        android_specific_stubs
#        source "bluetooth.tcl"
#    }
#
#    # define the canvas
#    . configure -bg black 
#    canvas .can -width $screen_size_width -height $screen_size_height -borderwidth 0 -highlightthickness 0
#
#    after 60000 schedule_minute_task
#    #after 1000 schedule_minute_task
#
#    ############################################
#    # future feature: flight mode
#    #if {$::settings(flight_mode_enable) == 1} {
#        #if {$android == 1} {
#        #   .can bind . "<<SensorUpdate>>" [accelerometer_data_read]
#        #}
#        #after 250 accelerometer_check
#    #}
#
#    ############################################
}


proc off_page_onload { page_to_hide page_to_show } {
	if {$page_to_hide == "sleep" && $page_to_show == "off"} {
		msg [namespace current] "discarding intermediate sleep/off state msg"
		return 0 
	}	
}

proc saver_page_onload { page_to_hide page_to_show } {
	if {[ifexists ::exit_app_on_sleep] == 1} {
		get_set_tablet_brightness 0
		close_all_ble_and_exit
	} else {
		if {$::settings(screen_saver_change_interval) == 0} {
			# black screen saver
			display_brightness 0
		} else {
			display_brightness $::settings(saver_brightness)
		}
		borg systemui $::android_full_screen_flags 
	}
}


proc page_onload { page_to_hide page_to_show } {
	if {$page_to_show ne "saver" } {
		display_brightness $::settings(app_brightness)
	}
	
	if {$::settings(stress_test) == 1 && $::de1_num_state($::de1(state)) == "Idle" && [info exists ::idle_next_step] == 1} {		
		msg "Doing next stress test step: '$::idle_next_step '"
		set todo $::idle_next_step 
		unset -nocomplain ::idle_next_step 
		eval $todo
	}
}


proc check_if_battery_low_and_give_message {} {
    if {[battery_percent] < 10 && $::android == 1} {
        info_page [subst {[translate "We noticed that your battery power is very low."]\n\n[translate "Maybe you are turning your DE1 off using the power switch on the back?"]\n\n[translate "If so, that prevents the tablet from charging."]\n\n[translate "Instead, put the DE1 to sleep by tapping the power icon in the App."]}] [translate "Ok"]
    }
}

proc battery_percent {} {

    array set powerinfo [sdltk powerinfo]
    set percent [ifexists powerinfo(percent)]
    if {$percent == ""} {
        set percent 100
    }

    return $percent
}

proc battery_state {} {

    array set powerinfo [sdltk powerinfo]
    set state [ifexists powerinfo(state)]
    if {$state == ""} {
        set state "~"
    }

    return $state
}

proc check_battery_charger {} {

    set percent [battery_percent]

    #####################
    # keep battery charged between 40% and 60%
	if {$::settings(smart_battery_charging) == 1} {
	    if {$percent <= 55} {
			# turn USB charger on
			set_usb_charger_on 1
	    } elseif {$percent >= 65} {
			# turn USB charger off
			set_usb_charger_on 0
	    }
    } else {
		set_usb_charger_on 1
    }

}

# dim the screen automaticaly if the battery is low
proc check_battery_low {brightness_to_use} {

	puts check_battery_low

    set current_brightness [get_set_tablet_brightness]
    if {$current_brightness == ""} {
        set current_brightness 100
    } else {
        set current_brightness [expr {abs($current_brightness)}]
    }

    
    set percent [battery_percent]

    #####################

    if {$percent < $::settings(battery_very_low_trigger_v2)} {
        if {$current_brightness > $::settings(battery_very_low_brightness)} {
            get_set_tablet_brightness $::settings(battery_very_low_brightness)
            msg -WARNING "Battery is very low ($percent < $::settings(battery_very_low_trigger)) so lowering screen to $::settings(battery_very_low_brightness)"
        }
        if {$brightness_to_use > $::settings(battery_very_low_brightness)} {
            return $::settings(battery_very_low_brightness)
        }
    } elseif {$percent < $::settings(battery_low_trigger_v2)} {
        if {$current_brightness > $::settings(battery_low_brightness)} {
            get_set_tablet_brightness $::settings(battery_low_brightness)
            msg -WARNING "Battery is low ($percent < $::settings(battery_low_trigger)) so lowering screen to $::settings(battery_low_brightness)"
        }
        if {$brightness_to_use > $::settings(battery_low_brightness)} {
            return $::settings(battery_low_brightness)
        }
        #return $brightness_to_use
    } elseif {$percent < $::settings(battery_medium_trigger_v2)} {
        if {$current_brightness > $::settings(battery_medium_brightness)} {
            get_set_tablet_brightness $::settings(battery_medium_brightness)
            msg -NOTICE "Battery is medium ($percent < $::settings(battery_medium_trigger)) so lowering screen to $::settings(battery_medium_brightness)"
        }
        if {$brightness_to_use > $::settings(battery_medium_brightness)} {
            return $::settings(battery_medium_brightness)
        }
        #return $brightness_to_use
    }

    return $brightness_to_use
}

proc schedule_minute_task {} {
    check_battery_charger
    check_battery_low $::settings(app_brightness)
    after 60000 schedule_minute_task

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

proc stacktrace {args} {

	set label_args [expr { "-label_args" in $args }]

	# Original code apparently from https://wiki.tcl-lang.org/page/List+the+call+stack
	# Notes there suggest that there are also problems with namespaces with the implementation
	# (This concern is not resolved at this time)

	set stack "Stack trace:\n"

	for {set i 1} {$i < [info level]} {incr i} {

		set level [info level -$i]
		set frame [info frame -$i]

		append stack [string repeat " " $i]

		if { ! $label_args } {

			append stack $level

		} else {
			set pname [lindex $lvl 0]
			if { [info proc $pname] } {
				append stack $pname
				foreach value [lrange $lvl 1 end] arg [info args $pname] {
					catch {
						if {$value eq ""} {
							info default $pname $arg value
						}
						append stack " $arg='$value'"
					}
				}

			} else {

				append stack $lvl
			}
		}
		append stack \n
	}
	return $stack
}

proc random_saver_file {} {


    if {[info exists ::saver_files_cache] != 1} {
        set ::saver_files_cache {}
 
        set savers {}
        catch {
            set savers [glob -nocomplain "[saver_directory]/${::screen_size_width}x${::screen_size_height}/*.jpg"]
        }


        if {$savers == ""} {
            catch {
                file mkdir "[saver_directory]/${::screen_size_width}x${::screen_size_height}/"
            }

            set rescale_images_x_ratio [expr {$::screen_size_height / 1600.0}]
            set rescale_images_y_ratio [expr {$::screen_size_width / 2560.0}]

            foreach fn [glob -nocomplain "[saver_directory]/2560x1600/*.jpg"] {
                borg toast [subst {[translate "Resizing image"]\n\n[file tail $fn]}]
                borg spinner on
                msg -DEBUG "random_saver_file image create photo saver -file $fn"
                image create photo saver -file $fn
                photoscale saver $rescale_images_y_ratio $rescale_images_x_ratio

                set resized_filename "[saver_directory]/${::screen_size_width}x${::screen_size_height}/[file tail $fn]"
                msg -DEBUG  "saving resized image to: $resized_filename"
                borg spinner off

                saver write $resized_filename   -format {jpeg -quality 50}
            }
        }

	set saver_path "[saver_directory]/${::screen_size_width}x${::screen_size_height}/"
        set ::saver_files_cache [glob -nocomplain -path $saver_path {*.[Jj][Pp][Gg]}]

         if {$::settings(screen_saver_change_interval) == 0} {
            # remove all other savers if we are only showing the black one
            set ::saver_files_cache [glob -nocomplain "[saver_directory]/${::screen_size_width}x${::screen_size_height}/black_saver.jpg"]

        } else {
            # remove the black saver if we are not needing it
            set ::saver_files_cache [lsearch -inline -all -not -exact $::saver_files_cache "[saver_directory]/${::screen_size_width}x${::screen_size_height}/black_saver.jpg"]
        }
    }
    return [random_pick $::saver_files_cache]

}

proc tcl_introspection {} {

    catch {
        set txt ""

        append txt "Commands available: [llength [info commands]]\nInstructions run: [info cmdcount]\nGlobals: [llength [info globals]]\nProcs: [llength [info procs]]\nAfter commands: [llength [after info]]\n"

        set show_after_command_detail 0
        if {$show_after_command_detail == 1} {
            set acnt 0
            foreach a [after info] {
                incr acnt
                append txt "$acnt -  [after info $a]\n"
            }
        }

        append txt "Canvas objects: [llength [.can find all]]\n"
        append txt "Images loaded: [llength [image names]]\n"
        append txt "BLE queue: [llength $::de1(cmdstack)]\n"

        set show_image_detail 0
        if {$show_image_detail == 1} {
            set cnt 0
            foreach i [image names] {
                append txt "[incr cnt]. $i [image height $i]x[image width $i] in use:[image inuse $i]\n"
            }
            append txt \n
        }


        set vs [vector names]
        append txt "Vectors: [llength $vs]"
        set total 0
        foreach v $vs {
            set sz [$v length]
            set total [expr {$total + $sz}]
        }
        append txt "\nTOTAL vector length: $total bytes\n"



        set globs [info globals] 
        append txt "Globals [llength $globs]:\n"
        set txt2 ""
        set total 0
        set cnt 0
        foreach g $globs {
            if {[array exists $g] == 1} {   
                set sz [string length [array get $g]]
                if {$sz > 100} {
                    append txt "[incr cnt]. array $g : $sz\n"
                }
                set total [expr {$total + $sz}]
            } else {
                set sz [string length $g]
                if {$sz > 100} {
                    append txt "[incr cnt]. string $g : $sz\n"
                }
                set total [expr {$total + $sz}]
            }

        }
        append txt "TOTAL global variable memory used: $total bytes\n\n"

		if {$::enable_profiling == 1} {

			# this loads the overall app info
			append txt [profilerdata]

			# this gives you profiled run information about individual functions
			# feel free to change these to those you are investigating
			append txt [profilerdata ::load_skin]
			append txt [profilerdata ::add_de1_text]
			append txt [profilerdata ::add_de1_variable]
			append txt [profilerdata ::de1_ble_handler]
			append txt [profilerdata ::device::scale::process_weight_update]
		}

        msg -INFO $txt
    }

    after [expr {60 * 60 * 1000}] tcl_introspection
    #after [expr {1000}] tcl_introspection
}

proc add_commas_to_number { number } {
	regsub -all \\d(?=(\\d{3})+([regexp -inline {\.\d*$} $number]$)) $number {\0,}
}

proc array_keys_decr_sorted_by_number_val {arrname {sort_order -decreasing}} {
	upvar $arrname arr
	foreach k [array names arr] {
		#puts " $arr($k) "
		set k2 "[format {"%0.12i"} $arr($k)] $k"
		#puts "k2: $k2"
		set t($k2) $k
	}
	
	set toreturn {}
	foreach k [lsort -dictionary $sort_order [array names t]] {
		set v $t($k)
		lappend toreturn $v
	}
	return $toreturn
}



proc random_splash_file {} {
    if {[info exists ::splash_files_cache] != 1} {

        set ::splash_files_cache {}
 
        set savers {}
        catch {
            set savers [glob -nocomplain "[splash_directory]/${::screen_size_width}x${::screen_size_height}/*.jpg"]
        }
        if {$savers == ""} {
            catch {
                file mkdir "[splash_directory]/${::screen_size_width}x${::screen_size_height}/"
            }

            set rescale_images_x_ratio [expr {$::screen_size_height / 1600.0}]
            set rescale_images_y_ratio [expr {$::screen_size_width / 2560.0}]

            foreach fn [glob -nocomplain "[splash_directory]/2560x1600/*.jpg"] {
                borg toast [subst {[translate "Resizing image"]\n\n[file tail $fn]}]
                borg spinner on
                msg -DEBUG "random_splash_file image create photo saver -file $fn"
                image create photo saver -file $fn
                photoscale saver $rescale_images_y_ratio $rescale_images_x_ratio

                set resized_filename "[splash_directory]/${::screen_size_width}x${::screen_size_height}/[file tail $fn]"
                msg -DEBUG "saving resized image to: $resized_filename"
                borg spinner off
                saver write $resized_filename   -format {jpeg -quality 50}
            }
            
        }

        set ::splash_files_cache [glob -nocomplain "[splash_directory]/${::screen_size_width}x${::screen_size_height}/*.jpg"]
    }
    return [random_pick $::splash_files_cache]

}

proc random_splash_file_obs {} {
    if {[info exists ::splash_files_cache] != 1} {
	msg -DEBUG "building splash_files_cache"
        set ::splash_files_cache {}
        if {[file exists "[splash_directory]/${::screen_size_width}x${::screen_size_height}/"] == 1} {
            set files [glob -nocomplain "[splash_directory]/${::screen_size_width}x${::screen_size_height}/*.jpg"]
        } else {
            set files [glob -nocomplain "[splash_directory]/2560x1600/*.jpg"]
        }

        borg spinner on
        foreach file $files {
            if {[string first $file resized] == -1} {
                lappend ::splash_files_cache $file
            }
        }
        borg spinner off
        msg -INFO "savers: $::splash_files_cache"

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
# new url: https://mothereff.in/js-escapes
# note that "Arabic" is the descriptor for that language because can make the correct arabic text render with this same font.
proc translation_langs_array {} {
    return [list \
        en English \
        kr "\uD55C\uAD6D\uC5B4" \
        fr "\u0066\u0072\u0061\u006E\u00E7\u0061\u0069\u0073" \
        de Deutsch \
        de-ch Schwiizerd\u00FCtsch \
        it italiano \
        ar "Arabic (with Dubai font)" \
        da "dansk" \
        sv "svenska" \
        no "Nynorsk" \
        he "\u05E2\u05D1\u05E8\u05D9\u05EA" \
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
        nl "Nederlands" \
        ru "русский" 
    ]
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

            if {[ifexists available([language])] != ""} {
                # if the translated version of the English is NOT blank, return it
                if {[language] == "ar" && ($::android == 1 || $::undroid == 1)} {
                    # use the "arb" column on Android/Undroid because they do not correctly right-to-left text like OSX does
                    if {[ifexists available(arb)] != ""} {
                        return $available(arb)
                    }
                }

                if {[language] == "he" && ($::android == 1 || $::undroid == 1)} {
                    # use the "heb" column on Android/Undroid because they do not correctly right-to-left text like OSX does
                    if {[ifexists available(heb)] != ""} {
                        return $available(heb)
                    }
                }

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
            msg -NOTICE "Appending new phrase: '$english' to [homedir]/translation.tcl"
            append_file "[homedir]/translation.tcl" [encoding convertto utf-8 $t]

            set ::already_shown_trans($english) 1
        }
    }

    return $english
}


proc skin_directory {} {
    global screen_size_width
    global screen_size_height

    set skindir "skins"

    #if {[ifexists ::creator] == 1} {
        #set skindir "skinscreator"
    #}

    #set dir "[file dirname [info script]]/$skindir/default/${screen_size_width}x${screen_size_height}"
    set dir "[homedir]/$skindir/$::settings(skin)"
    return $dir
}

proc android_specific_stubs {} {

    proc ble {args} { msg -DEBUG "ble $args"; return 1 }
    
    if {$::android != 1 && $::undroid != 1} {
        proc sdltk {args} {
            if {[lindex $args 0] == "powerinfo"} {
                return [list "percent" 75]
            } elseif {[lindex $args 0] == "textinput"} {
                return 0
            } else {
                msg -ERROR "unknown sdktk comment: '$args'"
            }
        }
    }
    proc borg {args} { 
        if {[lindex $args 0] == "locale"} {
            return [list "language" "en"]
        } elseif {[lindex $args 0] == "log"} {
            # do nothing
        } elseif {[lindex $args 0] == "beep"} {
            # do nothing
        } elseif {[lindex $args 0] == "systemui"} {
            # do nothing
        } elseif {[lindex $args 0] == "osbuildinfo"} {
            # do nothing
            return ""
        } elseif {[lindex $args 0] == "spinner"} {
            # do nothing
        } elseif {[lindex $args 0] == "toast"} {
            msg -NOTICE "screen popup message: '$args'"
        } elseif {[lindex $args 0] == "brightness"} {
            if {[lindex $args 1] == ""} {
                return 70
            } else {
                msg -DEBUG "borg $args"
            }

        } else {
            msg -ERROR "unknown 'borg $args'"
        }
    }
}

proc get_set_tablet_brightness { {setting ""} } {
    set actual [borg brightness]
    if {$setting == ""} {
        # no parameter means: return current value
        return $actual
    }

    # only call the Android setting if the setting needs to be changed.
    if {$actual != $setting} {
        borg brightness $setting

        # hide the bar that is made visible by changing brightness
        borg systemui $::android_full_screen_flags

    }
}


# Enrique: Not used anywhere in the code as of 25/06/2021, image directories now managed by DUI, so commenting 
#proc settings_directory_graphics {} {
#    
#    global screen_size_width
#    global screen_size_height
#
#    set settingsdir "[homedir]/skins"
#    set dir "$settingsdir/$::settings(skin)/${screen_size_width}x${screen_size_height}"
#    
#    if {[info exists ::rescale_images_x_ratio] == 1} {
#        set dir "$settingsdir/$::settings(skin)/2560x1600"
#    }
#    return $dir
#}

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

    set dir "$skindir/$::settings(skin)/${screen_size_width}x${screen_size_height}"

    if {[info exists ::rescale_images_x_ratio] == 1} {
        set dir "$skindir/$::settings(skin)/2560x1600"
    }
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

    set dir "$skindir/default/${screen_size_width}x${screen_size_height}"
    
    if {[info exists ::rescale_images_x_ratio] == 1} {
        set dir "$skindir/default/2560x1600"
    }
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

    #set a [borg sensor get 0]
    #set a 

    #set xvalue [lindex [lindex $a 11] 0]

    mean_accelbuffer
    set xvalue $::ACCEL(e3)


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
    return

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
    }
    after 200 accelerometer_check
}



proc say {txt sndnum} {
	# Handle the old hardcoded numbers associated  to sound files
	if {$sndnum == 8} {
		set sound_name button_in
	} elseif {$sndnum == 11} {
		set sound_name button_out
	} else {
		set sound_name $sndnum
	}

	dui say $txt $sound_name
	
#    if {$::android != 1} {
#        #return
#    }
#
#    if {$::settings(enable_spoken_prompts) == 1 && $txt != ""} {
#        borg speak $txt {} $::settings(speaking_pitch) $::settings(speaking_rate)
#    } else {
#        catch {
#            # sounds from https://android.googlesource.com/platform/frameworks/base/+/android-5.0.0_r2/data/sounds/effects/ogg?autodive=0%2F%2F%2F%2F%2F%2F
#            set path ""
#            if {$sndnum == 8} {
#                #set path "/system/media/audio/ui/KeypressDelete.ogg"
#                #set path "file://mnt/sdcard/de1beta/KeypressStandard_120.ogg"
#                set path "sounds/KeypressStandard_120.ogg"
#            } elseif {$sndnum == 11} {
#                #set path "/system/media/audio/ui/KeypressStandard.ogg"
#                set path "sounds/KeypressDelete_120.ogg"
#            }
#            borg beep $path
#            #borg beep $sounds($sndnum)
#        }
#    }
}


proc append_file {filename data} {
    set success 0
    set errcode [catch {
        set fn [open $filename a]
        fconfigure $fn -translation binary
        puts $fn $data
        close $fn
        set success 1
    }]
    if {$errcode != 0} {
        msg -ERROR "append_file $::errorInfo"
    }
    return $success
}

proc god_shot_save {} {
    set ::settings(god_espresso_pressure) [espresso_pressure range 0 end]
    set ::settings(god_espresso_temperature_basket) [espresso_temperature_basket range 0 end]
    set ::settings(god_espresso_flow) [espresso_flow range 0 end]
    set ::settings(god_espresso_flow_weight) [espresso_flow_weight range 0 end]
    set ::settings(god_espresso_elapsed) [espresso_elapsed range 0 end]

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
    set ::settings(god_espresso_elapsed) {}
    set ::settings(god_espresso_flow_weight) {}

    god_espresso_pressure length 0
    god_espresso_elapsed length 0
    god_espresso_temperature_basket length 0
    god_espresso_flow length 0
    god_espresso_flow_weight length 0
    god_espresso_flow_2x length 0
    god_espresso_flow_weight_2x length 0

    save_settings
}

proc save_settings {} {

    set compare_settings 1

    if {$compare_settings == 1} {
        array set ::settings_saved [encoding convertfrom utf-8 [read_binary_file [settings_filename]]]

        foreach k [lsort [array names ::settings]] {
            set v $::settings($k)

            set sv [ifexists ::settings_saved($k)]
            if {$sv != $v} {
                msg -DEBUG "New setting: '$k' = '$v' (was '$sv')"
            }
        }
    }

    msg -INFO "saving settings"
    save_array_to_file ::settings [settings_filename]

    catch {
        update_temperature_charts_y_axis
    }
    #save_settings_to_de1
    # john not sure what this is for since we're receiving hot water notifications
    #de1_read_hotwater
}

proc load_settings {} {


    set osbuildinfo_string [borg osbuildinfo]

    set settings_file_contents [encoding convertfrom utf-8 [read_binary_file [settings_filename]]]    
    if {[string length $settings_file_contents] == 0} {
       
        # if there are no settings, then set some based on what we know about this machine's settings
        # nb : we could 
        catch {
            array set osbuildinfo $osbuildinfo_string
        }
        if {[ifexists osbuildinfo(product)] == "P80X_EEA"} {
            # this "Teclast" tablet firmware version has an Android metadata configuration bug, and needs 20% larger fonts
            # other Teclast tablets do not have this error.
            # set ::settings(default_font_calibration) 0.6
            # not clear if this is still needed
        }
    } else {
        array set ::settings $settings_file_contents

        msg -NOTICE "OS build info: $osbuildinfo_string"

    }

    if {[ifexists ::settings(language)] == "ar" || [ifexists ::settings(language)] == "arb" || [ifexists ::settings(language)] == "he" || [ifexists ::settings(language)] == "heb"} {
        set ::de1(language_rtl) 1
    }

    #set ::de1(language_rtl) 1
    
    set ::settings(stress_test) 0


    # rao request to increase these defaults to 300 (from 120) to aid in pour-overs. Will remove this settings.tdb override in the future, once 
    # everyone's settings.tdb has had time to save this new default
    set ::settings(seconds_to_display_done_espresso) 300
    set ::settings(seconds_to_display_done_steam) 300
    set ::settings(seconds_to_display_done_flush) 300
    set ::settings(seconds_to_display_done_hotwater) 300

    set skintcl [read_file "[skin_directory]/skin.tcl"]

    # copy the BLE address from Skale to the new generic "scale" BLE address (20-9-19 added support for two kinds of scales)
    if {$::settings(skale_bluetooth_address) != ""} {
        set ::settings(scale_bluetooth_address) $::settings(skale_bluetooth_address)
        set ::settings(scale_type) "atomaxskale"
        set ::settings(skale_bluetooth_address) ""
    }

    # if we don't know what kind of scale it is, assume it's a historical Atomax Skale
    if {$::settings(scale_type) == "" && $::settings(scale_bluetooth_address) != ""} {
        set ::settings(scale_type) "atomaxskale"
    }

    # Transitional for v1.35 where this adjustment became relative to expected delay
    # There is no physical reason for this limit, only to assist users upgrading

    if {[ifexists ::settings(stop_weight_before_seconds)] > 1.5 } {
        set ::settings(stop_weight_before_seconds) 0.15
    }

    # Starting with v1.35, logging is always enabled
    # Variable may be accessed by skins, retain at this time
    # Variable is a placebo, there is no check in ::logging

    set ::settings(log_enabled) True


    blt::vector create espresso_elapsed god_espresso_elapsed god_espresso_pressure steam_pressure steam_temperature steam_temperature100th steam_flow steam_flow_goal steam_elapsed espresso_pressure espresso_flow god_espresso_flow espresso_flow_weight god_espresso_flow_weight espresso_flow_weight_2x god_espresso_flow_weight_2x espresso_flow_2x god_espresso_flow_2x espresso_flow_delta espresso_pressure_delta espresso_temperature_mix espresso_temperature_basket god_espresso_temperature_basket espresso_state_change espresso_pressure_goal espresso_flow_goal espresso_flow_goal_2x espresso_temperature_goal espresso_weight espresso_weight_chartable espresso_resistance_weight espresso_resistance
    blt::vector create espresso_de1_explanation_chart_pressure espresso_de1_explanation_chart_flow espresso_de1_explanation_chart_elapsed espresso_de1_explanation_chart_elapsed_flow espresso_water_dispensed espresso_flow_weight_raw espresso_de1_explanation_chart_temperature  espresso_de1_explanation_chart_temperature_10 espresso_de1_explanation_chart_selected_step
    blt::vector create espresso_de1_explanation_chart_flow_1 espresso_de1_explanation_chart_elapsed_flow_1 espresso_de1_explanation_chart_flow_2 espresso_de1_explanation_chart_elapsed_flow_2 espresso_de1_explanation_chart_flow_3 espresso_de1_explanation_chart_elapsed_flow_3
    blt::vector create espresso_de1_explanation_chart_elapsed_1 espresso_de1_explanation_chart_elapsed_2 espresso_de1_explanation_chart_elapsed_3 espresso_de1_explanation_chart_pressure_1 espresso_de1_explanation_chart_pressure_2 espresso_de1_explanation_chart_pressure_3

    # zoomed flow goal 2x
    blt::vector create espresso_de1_explanation_chart_flow_2x espresso_de1_explanation_chart_flow_1_2x espresso_de1_explanation_chart_flow_2_2x espresso_de1_explanation_chart_flow_3_2x

    # experimental chargts showing flow from the top, or 2x normal size
    blt::vector espresso_flow_delta_negative espresso_flow_delta_negative_2x

    #espresso_temperature_goal append [expr {$::settings(espresso_temperature) - 5}]
    #espresso_elapsed append 0    
    clear_espresso_chart
}

proc skin_xscale_factor {} {
	return [dui platform xscale_factor]	
#    global screen_size_width
#    return [expr {2560.0/$screen_size_width}]
}

proc skin_yscale_factor {} {
	return [dui platform yscale_factor]
#    global screen_size_height
#    return [expr {1600.0/$screen_size_height}]
}

proc rescale_x_skin {in} {
	return [dui platform rescale_x $in]
    #puts "rescale_x_skin $in / [skin_xscale_factor]"
    #return [expr {int($in / [skin_xscale_factor])}]
}

proc rescale_y_skin {in} {
	return [dui platform rescale_y $in]
#    return [expr {int($in / [skin_yscale_factor])}]
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
    set pwd [pwd]
    cd $indir
    set skinfiles [concat [glob -nocomplain "*.png"] [glob -nocomplain  "*.jpg"]]

    if {$skinfiles == ""} {
        msg -DEBUG "No jpg files found in '$indir'"
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


    # convert all the skin PNG files
    foreach {dir xdivisor ydivisor} $dirs {
        set started 0


        foreach skinfile $skinfiles {
            if {[file exists "../$dir/$skinfile"] == 1} {
                if {[file mtime $skinfile] < [file mtime "../$dir/$skinfile"]} {
                    # skip files that have not been modified.
                    continue
                }
            }

            if {$started == 0} {
                set started 1
                msg -DEBUG "skin_convert: Making $dir skin $indir"
            }

            file mkdir ../$dir

            msg -DEBUG "skin_convert: /$skinfile"
            flush stdout
            if {[file extension $skinfile] == ".png"} {
                catch {
                    #-format png8
                    exec convert $skinfile -strip -resize $dir!   ../$dir/$skinfile 
                    
                    # additional optional PNG compression step 
		    msg -DEBUG "skin_convert:" "zopflipng: $skinfile"
                    #exec zopflipng -q --iterations=1 -y   ../$dir/$skinfile   ../$dir/$skinfile 
                    exec zopflipng -m --iterations=1 -y   ../$dir/$skinfile   ../$dir/$skinfile 

                    exec convert $skinfile -strip -resize $dir!   ../$dir/$skinfile 
                    
                }
            } else {

                catch {
                    exec convert $skinfile -resize $dir!  -quality 90 ../$dir/$skinfile 
                    msg -DEBUG "skin_convert:" "convert $skinfile -resize $dir!  -quality 90 ../$dir/$skinfile "
                }
                if {$skinfile == "icon.jpg"} {
                    # icon files are reduced to 25% of the screen resolution
                    #catch {
                        exec convert ../$dir/$skinfile -resize 25%  ../$dir/$skinfile 
                    #}
                }
            }
        }
    }

    cd $pwd
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

# from Barney  https://3.basecamp.com/3671212/buckets/7351439/documents/2208672342#__recording_2349428596
proc load_font {name fn pcsize {androidsize {}} } {
#	if { $androidsize ne "" } {
#		msg -WARNING "BEWARE load_font with non-empty androidsize"
#	}
	return [dui font load $fn $pcsize -name $name]
	
#    # calculate font size
#    set familyname ""
#
#    if {($::android == 1 || $::undroid == 1) && $androidsize != ""} {
#        set pcsize $androidsize
#    }
#    set platform_font_size [expr {int(1.0 * $::fontm * $pcsize)}]
#
#    if {[language] == "zh-hant" || [language] == "zh-hans"} {
#        set fn ""
#        set familyname $::helvetica_font
#    } elseif {[language] == "th"} {
#        set fn "[homedir]/fonts/sarabun.ttf"
#    }
#
#    if {[info exists ::loaded_fonts] != 1} {
#        set ::loaded_fonts list
#    }
#    set fontindex [lsearch $::loaded_fonts $fn]
#    if {$fontindex != -1} {
#        set familyname [lindex $::loaded_fonts [expr $fontindex + 1]]
#    } elseif {($::android == 1 || $::undroid == 1) && $fn != ""} {
#        catch {
#            set familyname [lindex [sdltk addfont $fn] 0]
#        }
#
#        if {$familyname == ""} {
#            msg "Unable to get familyname from 'sdltk addfont $fn'"
#        } else {
#            lappend ::loaded_fonts $fn $familyname
#        }
#    }
#
#    if {[info exists familyname] != 1 || $familyname == ""} {
#        msg "Font familyname not available; using name '$name'."
#        set familyname $name
#    }
#
#    catch {
#        font create $name -family $familyname -size $platform_font_size
#    }
#    msg "added font name: \"$name\" family: \"$familyname\" size: $platform_font_size filename: \"$fn\""
}

# Barney writes: https://3.basecamp.com/3671212/buckets/7351439/documents/2208672342#__recording_2349428596
# I created a wrapper function that you might be interested in adopting. It makes working with fonts even simpler by removing the need to pre-load fonts before using them.
# Here's the syntax for using the get_font function in a call to add_de1_text:
# add_de1_text "off" 100 100 -text "Hi!" -font [get_font "Comic Sans" 12] 
proc get_font { font_name size } {
	return [dui font get $font_name $size]
    
#	if {[info exists ::skin_fonts] != 1} {
#        set ::skin_fonts list
#    }
#
#    set font_key "$font_name $size"
#    set font_index [lsearch $::skin_fonts $font_key]
#    if {$font_index == -1} {
#        # load the font if needed. 
#
#        # support for both OTF and TTF files
#        if {[file exists "[skin_directory]/fonts/$font_name.otf"] == 1} {
#            load_font $font_key "[skin_directory]/fonts/$font_name.otf" $size
#            lappend ::skin_fonts $font_key
#        } elseif {[file exists "[skin_directory]/fonts/$font_name.ttf"] == 1} {
#            load_font $font_key "[skin_directory]/fonts/$font_name.ttf" $size
#            lappend ::skin_fonts $font_key
#        } else {
#            msg "Unable to load font '$font_key'"
#        }
#    }
#
#    return $font_key
}

proc load_font_obsolete {name fn pcsize {androidsize {}} } {

	msg -WARNING "Unexpected use of load_font_obsolete [stacktrace]"

    if {$androidsize == ""} {
        set androidsize $pcsize
    }

    msg -DEBUG "loadfont: [language]"
 
    if {[language] == "zh-hant" || [language] == "zh-hans"} {

        if {$::android == 1 || $::undroid == 1} {
            font create $name -family $::helvetica_font -size [expr {int(1.0 * $::fontm * $androidsize)}]
        } else {
            font create "$name" -family $::helvetica_font -size [expr {int(1.0 * $pcsize * $::fontm)}]
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
        }
        return
    } else {
        if {$::android == 1 || $::undroid == 1} {
            set result ""
            catch {
                set result [sdltk addfont $fn]
            }
            msg -DEBUG "addfont of '$fn' finished with fonts added: '$result'"
            if {$name != $result} {
                msg -WARNING "font name used does not equal Android font name added: '$name' != '$result'"
            }
            catch {
                font create $name -family $name -size [expr {int(1.0 * $::fontm * $androidsize)}]
            }
            
        } else {
            font create "$name" -family "$name" -size [expr {int(1.0 * $pcsize * $::fontm)}]
            msg -DEBUG "font create \"$name\" -family \"$name\" -size [expr {int(1.0 * $pcsize * $::fontm)}]"
        }

    }
}


proc list_remove_element {list toremove} {
    set newlist [lsearch -all -inline -not -exact $list $toremove]
    return $newlist
}

proc any_in_list { x list } {
	if { $x eq "" } {
		return 0
	}	
	set match 0
	set i 0
	while { !$match && $i < [llength $x] } {
		set match [expr {[lindex $x $i] in $list}]
		incr i
	}
	return $match
}

proc all_in_list { x list } {
	if { $x eq "" } {
		return 0
	}
	set match 1
	set i 0
	while { $match && $i < [llength $x] } {
		set match [expr {[lindex $x $i] in $list}]
		incr i
	}
	return $match
}

proc launch_os_wifi_setting {} {
	if { $::android == 1 } {
		borg activity android.settings.WIFI_SETTINGS {} {} {} {} {}
	}
}

proc launch_os_time_setting {} {
	if { $::android == 1 } {
		borg activity android.settings.DATE_SETTINGS {} {} {} {} {}
	}

}

proc web_browser {url} {
    msg -INFO "Browser '$url'"
	if { $::android == 1 } {
		borg activity android.intent.action.VIEW $url text/html
	} elseif { $::tcl_platform(platform) eq "windows" } {
		eval exec [auto_execok start] $url
	}	
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


proc array_keyvalue_sorted_by_val_limited {arrname {sort_order -increasing} {limit -1} } {
    upvar $arrname arr
    foreach k [array names arr] {
        set k2 "$arr($k) $k"
        #set k2 "[format {"%0.12i"} $arr($k)] $k"
        set t($k2) $k
    }
    
    set toreturn {}

    set keys [lsort $sort_order -dictionary [array names t]]
    foreach k $keys {
        set v $t($k)
        lappend toreturn $v [lindex $k 0]
        if {$limit != -1 && [llength $toreturn] >= $limit} {
            break
        }
    }
    return $toreturn
}


proc shot_history_count_profile_use {} {

    set dirs [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/history/" *.shot]]
    set dd {}
    foreach d $dirs {
        unset -nocomplain arr
        unset -nocomplain sett
        catch {
            array set arr [read_file "history/$d"]
            array set sett [ifexists arr(settings)]
        }
            if {[array size arr] == 0} {
                msg -ERROR "Corrupted shot history item during count: 'history/$d'"
                continue
            }

        #return
        set profile [ifexists sett(profile)]
        if {$profile != ""} {

            incr profile_all_shot_count($profile)
        }
    }

    # only keep the top 5 profiles in this global array, which will be marked with a heart symbol to indicate that they are the user's favrite profiles
    array set ::profile_shot_count [array_keyvalue_sorted_by_val_limited profile_all_shot_count -decreasing 6]
    if {[array size ::profile_shot_count] < 3} {
        # indicate that the DEFAULT profile is a favorite, if there are less than 3 faves, as it's a good basic choice
        array set ::profile_shot_count [list "default" 1]
        
    } 

    if {[array size ::profile_shot_count] < 3} {
        # indicate that the 'Blooming espresso' profile is a favorite, if there are less than 3 faves, as it's a good choice
        array set ::profile_shot_count [list "Blooming espresso" 1]
        
    } 

    if {[array size ::profile_shot_count] < 3} {
        # indicate that the 'Gentle and sweet' profile is a favorite, if there are less than 3 faves, as it's a good choice
        array set ::profile_shot_count [list "Gentle and sweet" 1]
    }
}


proc shot_history_export {} {

    # optionally disable this feature
    if {$::settings(enable_shot_history_export) != "1"} {    
        return
    }

    set dirs [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/history/" *.shot]]
    set dd {}

    foreach d $dirs {
        set tailname [file tail $d]
        set newfile [file rootname $tailname]
        set fname "history/$newfile.csv" 
        if {[file exists $fname] != 1} {
            array unset -nocomplain arr
            catch {
                array set arr [read_file "history/$d"]
            }
            if {[array size arr] == 0} {
                msg -ERROR "Corrupted shot history item: 'history/$d'"
                continue
            }
            msg -INFO "Exporting history item: $fname"
            export_csv arr $fname
        }

        set enable_json_export_history 0
        if {$enable_json_export_history == 1} {
            set jsonfname "history/$newfile.json" 
            if {[file exists $jsonfname] != 1} {
                array unset -nocomplain arr
                set ftxt ""
                catch {
                    set ftxt [read_file "history/$d"]
                    array set arr $ftxt

                }
                if {[array size arr] == 0} {
                    msg -ERROR "Corrupted shot history item: 'history/$d'"
                    continue
                }
                msg -INFO "Exporting history item to JSON: $jsonfname"
                export_json $ftxt $jsonfname
            }
        }
    }

    return [lsort -dictionary -increasing $dd]

}

# Export one shot from memory, to a file
proc export_csv {arrname fn} {
    upvar $arrname arr
    set x 0
    set lines {}
    set lines [subst {espresso_elapsed,espresso_pressure,espresso_flow,espresso_flow_weight,espresso_temperature_basket,espresso_temperature_mix,espresso_weight\n}]

    set elapsed [llength $arr(espresso_elapsed)]
    for {set x 0} {$x < $elapsed} {incr x} {
        catch {
            set failed 1
            set line [subst {[lindex $arr(espresso_elapsed) $x],[lindex $arr(espresso_pressure) $x],[lindex $arr(espresso_flow) $x],[lindex $arr(espresso_flow_weight) $x],[lindex $arr(espresso_temperature_basket) $x],[lindex $arr(espresso_temperature_mix) $x],[lindex $arr(espresso_weight) $x]\n}]
            append lines $line
            set failed 0
        } err

        if {$failed == 1} {
            msg -ERROR "export_csv:" "$err: '$fn'"
        }

    }

    #set newfile "[file rootname $rootname].csv"
    msg -DEBUG "export_csv about to write"
    #write_file "history/$newfile" $lines
    write_file $fn $lines

}


proc dict2json {dictToEncode} {
    ::json::write object {*}[dict map {k v} $dictToEncode {
        set v [::json::write string $v]
    }]
}

# Export one shot from memory, to a file
proc export_json {ftxt fn} {
    package require json::write

    set d [dict create]
    foreach {k v} $ftxt {
        dict set d $k $v
    }
    set v [dict2json $d]

    msg -DEBUG "export_json about to write"
    write_file "$fn" $v
}
# Export one shot from memory, to an EEX format file
proc export_csv_common_format {arrname fn} {
    upvar $arrname arr
    set x 0
    set roast_date_seconds [clock seconds]
    catch {
        set roast_date_seconds [clock scan $::settings(roast_date)]
    }

    set lines [subst {information_type,elapsed,pressure,current_total_shot_weight,flow_in,flow_out,water_temperature_boiler,water_temperature_in,water_temperature_basket,metatype,metadata,comment
meta,,,,,,,,,Name,$::settings(god_espresso_name),text
meta,,,,,,,,,Description,$::settings(espresso_notes),text
meta,,,,,,,,,Date,[iso8601clock [clock seconds]],ISO8601 formatted date
meta,,,,,,,,,Operator,$::settings(my_name),text
meta,,,,,,,,,Espresso machine brand,Decent,text
meta,,,,,,,,,Espresso machine model,DE1+,text
meta,,,,,,,,,Basket diameter,58,number
meta,,,,,,,,,Basket make,,text
meta,,,,,,,,,Boiler temperature,$::settings(espresso_temperature),celsius
meta,,,,,,,,,Boiler Pressure,9,bar
meta,,,,,,,,,Brewing temperature,$::settings(espresso_temperature),celsius
meta,,,,,,,,,Roastery,$::settings(bean_brand),text
meta,,,,,,,,,Beans,$::settings(bean_type),text
meta,,,,,,,,,Roasting date,[iso8601clock $roast_date_seconds],ISO8601 formatted date
meta,,,,,,,,,Roast color,$::settings(roast_level),number in range 1 .. 10
meta,,,,,,,,,Grinder brand,$::settings(grinder_model),text
meta,,,,,,,,,Grinder model,$::settings(grinder_model),text
meta,,,,,,,,,Grinder setting,$::settings(grinder_setting),number
meta,,,,,,,,,Dose,$::settings(grinder_dose_weight),grounds weight in g
meta,,,,,,,,,Espresso weight,$::settings(drink_weight),drink weight in g
meta,,,,,,,,,Extraction time,[lindex $arr(espresso_elapsed) end],,sec
meta,,,,,,,,,TDS,,$::settings(drink_tds)
meta,,,,,,,,,EY,,$::settings(drink_ey)
meta,,,,,,,,,Unit system,metric,metric or imperial
meta,,,,,,,,,Attribution,Decent Espresso,
meta,,,,,,,,,Software,DE1+ App,
meta,,,,,,,,,Url,https://decentespresso.com/de1plus,
meta,,,,,,,,,Export version,1.1.0,
}]

#meta,,,,,,,,,Avarage flow rate,[round_to_two_digits [::math::statistics::mean $arr(espresso_flow)]],g/sec

    for {set x 0} {$x < [llength $arr(espresso_elapsed)]} {incr x} {
        set line [subst {[lindex $arr(espresso_elapsed) $x],[lindex $arr(espresso_pressure) $x],[lindex $arr(espresso_flow) $x],[lindex $arr(espresso_flow_weight) $x],[lindex $arr(espresso_temperature_basket) $x],[lindex $arr(espresso_temperature_mix) $x]\n}]

        append lines [subst {moment,[lindex $arr(espresso_elapsed) $x],[lindex $arr(espresso_pressure) $x],[lindex $arr(espresso_weight) $x],[lindex $arr(espresso_flow) $x],[lindex $arr(espresso_flow_weight) $x],[lindex $arr(espresso_temperature_mix) $x],[lindex $arr(espresso_temperature_mix) $x],[lindex $arr(espresso_temperature_basket) $x],,,,,\n}]

        #append lines $line
    }

    #set newfile "[file rootname $rootname].csv"
    msg -DEBUG "export_csv_common_format about to write"
    #write_file "history/$newfile" $lines
    write_file $fn $lines

}

#The following procedure is used to extract all ASCII string parts from the Unicode string. in tk_messageBox after rendering to Arabic they come reversed
#So this fix has been added
# It will give the pairs :  (ASCII string part | ASCII string starting index in the Unicode string) .
proc list_of_all_ascii_parts_a_unicode_string { arabic_string} {

set ascii_parts_list [list]
set length [string length $arabic_string]
    for {set i 0} {$i< $length} {incr i} {
        set start_of_ascii $i
        
        set end_of_ascii  $start_of_ascii 
        while {[string is ascii [
            string range $arabic_string $start_of_ascii $end_of_ascii]] ==  1
            && $i<$length}  {
          
                msg -DEBUG "list_of_all_ascii_parts_a_unicode_string:" [
                    string range $arabic_string $start_of_ascii $end_of_ascii]
                incr i
                incr end_of_ascii 
        }
        
        incr end_of_ascii -1
        
        set ascii_part [
            string range $arabic_string $start_of_ascii $end_of_ascii]
        
        if {[string trim $ascii_part] ne {}} {
          set ascii_parts_list [
              linsert $ascii_parts_list end [list $ascii_part $start_of_ascii]]
        }
    }
    return $ascii_parts_list
}

#a procedure to make Arabic readable when displayed in a Tk widget.
    
proc render_arabic args {

    set  arabic_string [lindex $args 0]
    set  is_messageBox [lindex $args 1]

    #The given of the problem is an Arabic sentence
    
    #Break the sentence into words
    set  words [split [string trim $arabic_string]]
    
    #Display the sentence the way TCL receives it
    #The problem is:
    #Tcl receives the Arabic letters: (i) in the reverse order (ii)
    #disconnected.  We want to re-render the Arabic to be displayed correctly
    #tk_messageBox -message $words
    
    #$count is the word index in the arabic sentence   
    set count 0
    
    #the following is just an example of how to get an arabic character index
    #number in the unicode character charts
    #set z {} ; foreach el [split ل {}] {puts [scan $el %c]}
     
    #foreach word in the arabic sentence 
    foreach word $words {
        if {[string is ascii $word]} {
            incr count
            continue
        } 
         
        #else {
        #    set splits [split $word "!@#$%^&*()_+-=~`123456790/\\"]
        #    if {[llength $splits] > 1} {
        #        set split_counter 0
        #        foreach splitting $splits {
        #            set splitting [render_arabic $splitting]
        #            lset splits $split_counter $splitting
        #            incr split_counter
        #        }
        #        set word [join splits]
        #        incr count
        #        continue
        #    }
        #}
         
        #1-get the  substring in the word without the last letter
        #we will deal with the connection of the last letter later
        set original_word $word
        set sub_word [string range $word 0 end-1]
        
        #All the letters from baa2 to yaa2 when they are NOT the last letter;
        #TCL initially has and reads them in their isolated form as in ل م س;
        #they must be converted into their initial form e.g ل م س
        #so replace and convert every occurrence of each of such letters

        #Also other Arabic-like characters like Urdu, Persian, Kurdish... etc, 
        #You may add them similarly over here
        
        set sub_word [ string map {\u0628 \ufe91} $sub_word] ;#ba2
        set sub_word [ string map {\u062A \ufe97} $sub_word] ;#Ta2
        set sub_word [ string map {\u062B \ufe9b} $sub_word] ;#thaa2
        set sub_word [ string map {\u062C \ufe9f} $sub_word] ;#Jeem
        set sub_word [ string map {\u062d \ufea3} $sub_word] ;#7aa2
        set sub_word [ string map {\u062e \ufeA7} $sub_word] ;#5aa2
        set sub_word [ string map {\u0633 \ufeb3} $sub_word] ;#seen
        set sub_word [ string map {\u0634 \ufeb7} $sub_word] ;#sheen
        set sub_word [ string map {\u0635 \ufebb} $sub_word] ;#SSaad
        set sub_word [ string map {\u0636 \ufebf} $sub_word] ;#DDhahd
        set sub_word [ string map {\u0637 \ufec3} $sub_word] ;#TTaa2
        set sub_word [ string map {\u0638 \ufec7} $sub_word] ;#tthaa2 Zah
        set sub_word [ string map {\u0639 \ufeCb} $sub_word] ;#3eyn
        set sub_word [ string map {\u063A \ufeCF} $sub_word] ;#ghyn
        set sub_word [ string map {\u0641 \ufeD3} $sub_word] ;#faa2
        set sub_word [ string map {\u0642 \ufeD7} $sub_word] ;#quaaf
        set sub_word [ string map {\u0643 \ufeDb} $sub_word] ;#kaaf
        set sub_word [ string map {\u0644 \ufedf} $sub_word] ;#lam
        set sub_word [ string map {\u0645 \ufee3} $sub_word] ;#meem
        set sub_word [ string map {\u0646 \ufee7} $sub_word] ;#noon
        set sub_word [ string map {\u0647 \ufeeb} $sub_word] ;#haa2
        set sub_word [ string map {\u064A \ufef3} $sub_word] ;#yaa2
        set sub_word [ string map {\u0626 \ufe8b} $sub_word] ;#hamza 3ala nabera (initial form of yaa2)
        
        #now replace the whole part of the word that excludes the last letter
        #with the conversion done above
        
        set word [string replace $word 0 end-1 $sub_word]
        
        #The following list of characters are the characters initial form
        #mentioned above + the tatweel chacracter
        set initials [list \u0640 \ufe90 \ufe97 \ufe9b \ufe9f \ufea3 \ufeA7 \
            \ufb3 \ufeb7 \ufebb \ufebf \ufec3 \ufec7 \ufeCb \ufeCF \ufeD3 \
            \ufeD7 \ufeDb \ufedf \ufee3 \ufee7 \ufeeb \ufef3]
        
     
        #find the character before the last.
        
        set before_last_char [string index $word end-1]

        #for debugging purposes just print the character before the last.
        
        #and try to see if  the character before the last is a word in the list
        #$initials defined in the previous line.
        #and if its true, then convert the last character to it's final linked
        #form
        #this way they will be joined
        if {[lsearch -ascii -inline $initials $before_last_char]
            eq $before_last_char} {
            
            #now get also last chacracter
            set last_character [string index $word end]
            
            #print it for debugging purposes
            
            #just to make sure that we we are matching correctly print the unicode
            #index number of the character
            if {[string is ascii $last_character]} {
                set before_last_char [render_arabic $before_last_char]
            }
            
            #\u0627 {
            #    #aleph
            #    set word [ string replace $word end end \ufe8e ]
            #}
            #now convert the last character into its final linked form
            switch -- $last_character {
                \u0628 {
                    #baa2
                    set word [string replace $word end end \ufe90]
                }
                \u0629 {
                    #taa2 marbootta
                    set word [string replace $word end end \ufe94]
                }
                \u062A {
                    #ta2 maftoo7a
                    set word [string replace $word end end \ufe96]
                }
                \u062B {
                    #thaa2
                    set word [string replace $word end end \ufe9A]
                }
                \u062c {
                    #jeem
                    set word [string replace $word end end \ufe9e]
                    msg -DEBUG "render_arabic \\u062B:" $word
                }
                \u062d {
                    #7aa2
                    set word [string replace $word end end \ufeA2]
                }

                \u062e {
                    #5aa2
                    set word [string replace $word end end \ufea6]
                }

                \u062f {
                    #dal
                    set word [string replace $word end end \ufeaa]
                }

                \u0630 {
                    #tthal
                    set word [string replace $word end end \ufeac]
                }
                \u0631 {
                    #raa2
                    set word [string replace $word end end \ufeae]
                }
                \u0632 {
                    #zyn
                    set word [string replace $word end end \ufeaf]
                }

                \u0633 {
                    #seen
                    set word [string replace $word end end \ufeb2]
                }
                \u0634 {
                    #sheen
                    set word [string replace $word end end \ufeb6]
                }
                \u0635 {
                    #ssaad
                    set word [string replace $word end end \ufeba]
                }
                \u0636 {
                    #ddaad
                    set word [string replace $word end end \ufebe]
                }
                \u0637 {
                    #ttaa2
                    set word [string replace $word end end \ufec2]
                }
                \u0638 {
                    #tthaa2
                    set word [string replace $word end end \ufec8]
                }
                \u0639 {
                    #3ayn
                    set word [string replace $word end end \ufeca]
                }
                \u063a {
                    #ghyn
                    set word [string replace $word end end \ufece]
                }
                \u0641 {
                    #faa2
                    set word [string replace $word end end \ufed2]
                }
                \u0642 {
                    #quaaf
                    set word [string replace $word end end \ufed6]
                }
                \u0643 {
                    #kaaf
                    set word [string replace $word end end \ufeda]
                }
                  \u0644 {
                    #laam
                    set word [ string replace $word end end \ufede]
                }
                \u0645 {
                    #meem
                    set word [string replace $word end end \ufee2]
                }
                \u0646 {
                    #noon
                    set word [string replace $word end end \ufee6]
                }
                \u0647 {
                    #haa2
                    set word [string replace $word end end \ufeea]
                }
                \u0648 {
                    #waaw
                    set word [string replace $word end end \ufeee]
                }
                \u0624 {
                    #waaw with hamza above
                    set word [ string replace $word end end \ufe86]
                }
                \u0649 {
                    #alef maqsura
                    set word [string replace $word end end \ufef0]
                }
                \u064a {
                    #yaa2
                    set word [string replace $word end end \ufef1]
                }
                default {
                    #default is nothing to do
                }
            }
     
        }
        # end of if the character before the last is a member of the list
        # $initials
         
        #now reverse every occurrence of the word for correct displaying on the
        #screen

        set failed 1
        catch {
            set arabic_string [regsub -all "\\m$original_word\\M" $arabic_string $word]
            set failed 0
        } err

        if {$failed == 1} {
	    #
	    # Here have to hope that the string is "printable"
	    #
            msg -ERROR "render_arabic failed: $err: '$arabic_string'"
        }

        #add and replace the corrected/conversion-of word with malformed one. in
        #the arabic sentence
        #the whole words in the sentence yet are still in the reverse order
        #lset words $count $word
        
        #move to the  next word
        incr count
    }
    
    #The following 2 line is left for you to see the final result. just remove
    #the comment sign (#)
    #tk_messageBox -message $words
    
    #reverse the whole string
    set arabic_string [string reverse $arabic_string]
     
    #If you see that the ASCII string parts of the whole Arabic/Unicode are
    #reversed, then add another one and only one additional parameter to the
    #Arabic/Unicode string and set it only to
    #"1" (the number ONE).

    if { $is_messageBox ==1 } {
    foreach part [list_of_all_ascii_parts_a_unicode_string $arabic_string] {
        set part_string [string reverse [ lindex $part 0 ]]
        set start_of_ascii [ lindex $part 1 ]
        set length_part_string [string length $part_string]
        
        set arabic_string [string replace $arabic_string $start_of_ascii [expr $start_of_ascii + $length_part_string -1] $part_string]
      
    }
  }
  return $arabic_string 
}

proc iso8601clock {{now {}}} {
    if {$now == ""} {
        set now [clock seconds]
    }

    return [clock format $now -format "%Y-%m-%dT%H:%M:%SZ" -gmt 1 ]
}

proc iso8601stringparse {in} {
    set date ""
    set time ""
    regexp {([0-9-]+)T([0-9:]+)\.?[0-9]+?Z} $in discard date time
    if {$date == ""} {
        msg -ERROR "No date found in: '$in'"
        return 0
    }
    if {$time == ""} {
        msg -ERROR "No time found in: '$in'"
        return 0
    }
    set timestring "$date $time UTC"
    return [clock scan $timestring]
}

proc zero_pad {number len} {
    set out $number
    while {[string length $out] < $len} {
        set out "0$out"
    }
    return $out
}


# similar to wrapped_string_part{} but looks for a / in the title, and uses that as the delimeter if it is there, otherwise wrapping as per normal
# useful for espresso profiles, which contain a category/ in their title
proc wrapped_profile_string_part {input threshold partnumber} {

    set slashpos [string first / $input]
    if {$slashpos != -1} {
        if {$partnumber == 0} {
            return [subst {[string range [string range $input 0 $slashpos] 0 $threshold]}]
        } else {
            return [subst {[string range [string range $input $slashpos+1 end] 0 $threshold]}]
        }
    } 
    set w [wrapped_string_part $input $threshold $partnumber]
    return $w
}

proc wrapped_string_part {input threshold partnumber} {
    if {[string length $input] == [expr {1 + $threshold}] } {
        # wrap algorithm seems to chop off last character if there is just 1 character too many, so 
        # work around that by adding a space when needed.
        append input " "
    }
    set l [wrap_string $input $threshold 1]
    return [lindex $l $partnumber]
}

##
# wrap_string --- line wraps a given paragraph of text
#
# DESCRIPTION
#
# This function will line wrap the given text paragraph.
#
# PROTOTYPE
#
# [proc text::wrap_string {input {threshold 75}}]
#
# EXAMPLE
#
# [
#    set para "asdfas dasdf klasljdf aslkdfj alk jsdlfkja sld kfaslkdfj laksdj flas dfla jsdlfj alskdj flaksj dflkaj sdlfkj asdf\naa sdfhakj sdfkjah sdkfh asf\n\nasjdf ajksdh fkjash dfkha sdfh aksjdh fkjash df\nasdf akjsdhf kjha sdkfja hsdkfhas\nasdfasdf"
#    puts $para
#    puts "================================="
#    set newpara [wrap_string $para]
#    puts $newpara
# ]
#
##
# wraps a string to be no wider than 80 columns by inserting line breaks
proc wrap_string {input {threshold 75} {returnlist 0}} {
    set result_rows [list]
    set start_of_line_index 0

    # john there's a bug in this proc, which I borrowed from the tcl wiki and did not write.  
    # A string of length theshold+1 gets truncated by 1 character
    # this "if" statement is a work around, where we simply accept a +1 overage on the threshold, instead of wrapping it
    if {([string length $input] - 1) <= $threshold} {
        #return $input
    }

    while 1 {
        
        set this_line [string range $input $start_of_line_index [expr $start_of_line_index + $threshold - 1]]
        if { $this_line == "" } {
            if {$returnlist == 0} {
                return [join $result_rows "\n"]
            } else {
                return $result_rows
            }
        }
        
        set first_new_line_pos [string first "\n" $this_line]
        if { $first_new_line_pos != -1 } {
            # there is a newline
            lappend result_rows [string range $input $start_of_line_index [expr $start_of_line_index + $first_new_line_pos - 1]]
            set start_of_line_index [expr $start_of_line_index + $first_new_line_pos + 1]
            continue
        }
        if { [expr $start_of_line_index + $threshold + 1] >= [string length $input] } {
            # we're on the last line and it is < threshold so just return it
            lappend result_rows $this_line
            #return [join $result_rows "\n"]
            if {$returnlist == 0} {
                return [join $result_rows "\n"]
            } else {
                return $result_rows
            }
        }
        
        set last_space_pos [string last " " $this_line]
        if { $last_space_pos == -1 } {
            # no space found!  Try the first space in the whole rest of the string
            set next_space_pos [string first " " [string range $input $start_of_line_index end]]
            set next_newline_pos [string first "\n" [string range $input $start_of_line_index end]]
            if {$next_space_pos == -1} {
                set last_space_pos $next_newline_pos
                
            } elseif {$next_space_pos < $next_newline_pos} {
                set last_space_pos $next_space_pos
                
            } else {
                set last_space_pos $next_newline_pos
            }
            
            if { $last_space_pos == -1 } {
                # didn't find any more whitespace, append the whole thing as a line
                lappend result_rows [string range $input $start_of_line_index end]
                if {$returnlist == 0} {
                    return [join $result_rows "\n"]
                } else {
                    return $result_rows
                }
                #return [join $result_rows "\n"]
            } 
        }
        
        # OK, we have a last space pos of some sort
        set real_index_of_space [expr $start_of_line_index + $last_space_pos]
        lappend result_rows [string range $input $start_of_line_index [expr $real_index_of_space - 1]]
        set start_of_line_index [expr $start_of_line_index + $last_space_pos + 1]
    }
    
}

proc zero_if_empty {in} {
	puts "in: $in"
	if {$in == ""} {
		puts "returning 0"
		return 0
	}
	return $in
}

proc toggle_0_1 {in} {
	if {$in == 1} {
		return 0
	}
	return 1

}
