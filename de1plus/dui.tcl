# ##### TEMPORAL DEV COMMENTS ####
#
# TODOs: SOME CHANGES TO DECOUPLE THIS LAYER AS A TOTALLY INDEPENDENT COMPONENT
#	- Global variables that must change to the dui namespace variables:
#		FONTS! Make Insight font creation compatible with the more generic/general fonts mechanism proposed here.
#		::de1(current_context) -> ::dui::page::current_page
#		screensaver integrated in the dui or not? -> An action on the "saver" page can make it work
#		Idle/stress test in page display_change ?? -> Add a way to add before_show/after_show/hide actions
#		::delayed_image_load system
#
#	- Global utility functions that are used here
#		ifexists
#		$::fontm, $::globals(entry_length_multiplier)
#		$::android, $::undroid
#		$::android_full_screen_flags
#################################
package provide de1_dui 1.0

package require de1_logging 1.0
package require de1_updater 1.1
package require de1_utils 1.1
package require Tk
package require snit
# tksvg breaks all images loading in the older Androwish distributions of the first DE1 tablets.
#catch { package require tksvg }
catch {
	# tkblt has replaced BLT in current TK distributions, not on Androwish, they still use BLT and it is preloaded
	package require tkblt
	namespace import blt::*
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

namespace eval ::dui {
	namespace export init setup_ui config cget canvas say platform theme aspect sound symbol font page item add
	namespace ensemble create

	variable settings
	# debug_buttons: Set to 1 while debugging to see the "clickable" areas. Also may need to redefine aspect 
	#	'<theme>.button.debug_outline' so it's visible against the theme background.
	# create_page_namespaces: Set to 1 to default to create a namespace ::dui::page::<page_name> for each new created 
	#	page, unless a different namespace is provided in the -namespace option of 'dui page add'.
	# trim_entries: Set to 1 to trim leading and trailing whitespace when modifying the values in entry boxes. 
	# use_editor_pages: Set to 1 to default to use editor pages if available (currently only for numbers)
	# timer_interval: Number of milliseconds between updates of on-screen variables (in the active page)
	array set settings {
		debug_buttons 0
		create_page_namespaces 0
		trim_entries 0
		use_editor_pages 1
		
		app_title Decent
		language en
		screen_size_width {}
		screen_size_height {}
		default_font_calibration 0.5
		use_finger_down_for_tap 1
		disable_long_press 0
		timer_interval 100
		enable_spoken_prompts 1
		speaking_pitch 1.0
		speaking_rate 1.5
	}

	# Store in namespace variables and not in settings what are internal parameters that are not to be modified by client code.
	
	# fontm is a multiplier that is computed only once at startup on 'dui init' combining the user-settable 
	# default_font_calibration setting, the used language, and the platform; with the objective of having a 
	# session-specific multiplier that makes the fixed sizes used in client code (dui add ... -font_size X) map to
	# fonts of similar sizes throughout platforms and languages. 
	variable fontm 1
	
	# Font/language-dependent multipliers to adjust the sizing of character-based widgets like entries and listboxes.
	# Take into account that with DUI these sizes can be set in pixels, using -canvas_width and -canvas-height. 
	variable entry_length_multiplier 1
	variable listbox_length_multiplier 1
	variable listbox_global_width_multiplier 1

	# Most coming from old proc "setup_environment" in utils.tcl
	proc init { {screen_size_width {}} {screen_size_height {}} {orientation landscape} } {
		global android
		global undroid
		msg [namespace current] init "android=$android, undroid=$undroid, some_droid=$::some_droid"
		
		variable settings
		variable fontm
		variable entry_length_multiplier
		variable listbox_length_multiplier
		variable listbox_global_width_multiplier

		if {$android == 0 || $undroid == 1} {
			# no 'borg' or 'ble' commands, so emulate
			android_specific_stubs
		}
		if {$android == 1} {
			# hide the android keyboard that pops up when you power back on
			bind . <<DidEnterForeground>> [::dui::platform::hide_android_keyboard]
		}
		
		if {$android == 1 || $undroid == 1} {
			# this causes the app to exit if the main window is closed
			wm protocol . WM_DELETE_WINDOW exit
	
			# set the window title of the app. Only visible when casting the app via jsmpeg, and when running the app in a window using undroidwish
			wm title . $settings(app_title)
	
			# force the screen into landscape if it isn't yet
			msg [namespace current] "orientation: [borg screenorientation]"
			if {[borg screenorientation] != "landscape" && [borg screenorientation] != "reverselandscape"} {
				borg screenorientation $orientation
			}
	
			sdltk screensaver off
			
			if { $screen_size_width eq "" || $screen_size_height eq "" } {
				# A better approach than a pause to wait for the lower panel to move away might be to "bind . <<ViewportUpdate>>" 
				# or (when your toplevel is in fullscreen mode) to "bind . <Configure>" and to watch out for "winfo screenheight" in 
				# the bound code.
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
			}
	
			# Android seems to automatically resize fonts appropriately to the current resolution
			set fontm $settings(default_font_calibration)
			#set fontw 1
	
			if {$::undroid == 1} {
				# undroid does not resize fonts appropriately for the current resolution, it assumes a 1024 resolution
				set fontm [expr {($screen_size_width / 1024.0)}]
				#set fontw 2
			}
	
			# HOW TO HANDLE THIS?
			if {[file exists "skins/default/${screen_size_width}x${screen_size_height}"] != 1} {
				set ::rescale_images_x_ratio [expr {$screen_size_height / 1600.0}]
				set ::rescale_images_y_ratio [expr {$screen_size_width / 2560.0}]
			}
	
			set global_font_size 18
			
			#puts "setting up fonts for language $settings(language)"
			if {$settings(language) == "th"} {
				set helvetica_font [dui::font::add_or_get_familyname "sarabun.ttf"]
				set helvetica_bold_font [dui::font::add_or_get_familyname "sarabunbold.ttf"]
				set global_font_name [dui::font::add_or_get_familyname "NotoSansCJKjp-Regular.otf"]
				set fontm [expr {($fontm * 1.2)}]								
				set global_font_size 16
			} elseif {$settings(language) == "ar" || $settings(language) == "arb"} {
				set helvetica_font [dui::font::add_or_get_familyname "Dubai-Regular.otf"]
				set helvetica_bold_font [dui::font::add_or_get_familyname "Dubai-Bold.otf"]
				set global_font_name [dui::font::add_or_get_familyname "NotoSansCJKjp-Regular.otf"]
			} elseif {$settings(language) == "he" || $settings(language) == "heb"} {
				set helvetica_font [dui::font::add_or_get_familyname "hebrew-regular.ttf"]
				set helvetica_bold_font [dui::font::add_or_get_familyname "hebrew-bold.tt"]
				set global_font_name [dui::font::add_or_get_familyname "NotoSansCJKjp-Regular.otf"]
				set listbox_length_multiplier 1.35
				set entry_length_multiplier 0.86				
			} elseif {$settings(language) == "zh-hant" || $settings(language) == "zh-hans" || $settings(language) == "kr"} {
				set helvetica_font [dui::font::add_or_get_familyname "NotoSansCJKjp-Regular.otf"]
				set helvetica_bold_font [dui::font::add_or_get_familyname "NotoSansCJKjp-Bold.otf"]
				set global_font_name $helvetica_font	
				set fontm [expr {($fontm * .94)}]
			} else {
				# we use the immense google font so that we can handle virtually all of the world's languages with consistency
				set helvetica_font [dui::font::add_or_get_familyname "notosansuiregular.ttf"]
				set helvetica_bold_font [dui::font::add_or_get_familyname "notosansuibold.ttf"]
				set global_font_name [dui::font::add_or_get_familyname "NotoSansCJKjp-Regular.otf"]
			}

			# enable swipe gesture translating, to scroll through listboxes
			# sdltk touchtranslate 1
			# disable touch translating as it does not feel native on tablets and is thus confusing
			if {$settings(disable_long_press) != 1 } {
				sdltk touchtranslate 1
			} else {
				sdltk touchtranslate 0
			}
	
			wm maxsize . $screen_size_width $screen_size_height
			wm minsize . $screen_size_width $screen_size_height
			wm attributes . -fullscreen 1
	
			# flight mode, not yet debugged
			#if {$::settings(flight_mode_enable) == 1 } {
			#    if {[package require de1plus] > 1} {
			#        borg sensor enable 0
			#        sdltk accelerometer 1
			#        after 200 accelerometer_check 
			#    }
			#}
	
			# preload the speaking engine 
			# john 2/12/18 re-enable this when TTS feature is enabled
			# borg speak { }
		} else {	
			# global font is wider on non-android
			set listbox_global_width_multiplier .8
			set listbox_length_multiplier 1
	
			expr {srand([clock milliseconds])}
	
			if { $screen_size_width eq "" || $screen_size_height eq "" } {
				# if this is the first time running on Tk, then use a default 1280x800 resolution, and allow changing resolution by editing settings file
				set screen_size_width 1280
				set screen_size_height 800
			}
	
			set fontm [expr {$screen_size_width / 1280.0}]
			set global_font_size 23
			#set fontw 2
	
			wm title . $settings(app_title)
			wm maxsize . $screen_size_width $screen_size_height
			wm minsize . $screen_size_width $screen_size_height

			# TBD WHAT TO DO WITH THIS 
			if {[file exists "skins/default/${screen_size_width}x${screen_size_height}"] != 1} {
				set ::rescale_images_x_ratio [expr {$screen_size_height / 1600.0}]
				set ::rescale_images_y_ratio [expr {$screen_size_width / 2560.0}]
			}
	
			# EB: Is this installed by default on PC/Mac/Linux?? No need to sdltk add it?
			set helvetica_font "notosansuiregular"
			set helvetica_bold_font "notosansuibold"
	
			if {$settings(language) == "th"} {
				set helvetica_font "sarabun"
				set helvetica_bold_font "sarabunbold"
				#set fontm [expr {($fontm * 1.20)}]
			} 
		}

		set fontawesome_brands [dui::font::add_or_get_familyname "Font Awesome 5 Brands-Regular-400.otf"]
		set fontawesome_pro [dui::font::add_or_get_familyname "Font Awesome 5 Pro-Regular-400.otf"]

		msg -DEBUG [namespace current] "Font multiplier: $fontm"
		dui aspect set -theme default -type text font_family $helvetica_font 
		dui aspect set -theme default -type text -style bold font_family $helvetica_bold_font
		dui aspect set -theme default -type text -style global font_family $global_font_name font_size $global_font_size
		#msg -DEBUG [namespace current] "Adding global font with family=$global_font_name and size=$global_font_size"		
		dui aspect set -theme default -type symbol font_family $fontawesome_pro
		dui aspect set -theme default -type symbol -style brands font_family $fontawesome_brands
		
		set settings(screen_size_width) $screen_size_width 
		set settings(screen_size_height) $screen_size_height
		
		# define the canvas
		set can [dui canvas]
		. configure -bg black 
		::canvas $can -width $screen_size_width -height $screen_size_height -borderwidth 0 -highlightthickness 0
		pack $can

		# Create an invisible full-page rectangle to "absorb" taps when changing pages, to prevent the bug of taps
		# persisting through pages. Suggested by Ray.
		$can create rect 0 0 $screen_size_width $screen_size_height -fill {} -width 0 -tags _tapabsorber_ -state "hidden"
		$can bind _tapabsorber_ [dui platform button_press] {}
		
		############################################
		# future feature: flight mode
		#if {$::settings(flight_mode_enable) == 1} {
			#if {$android == 1} {
			#   .can bind . "<<SensorUpdate>>" [accelerometer_data_read]
			#}
			#after 250 accelerometer_check
		#}

		############################################
		
		return $can 
	}
	
	proc canvas {} {
		return ".can"
	}
	
	proc setup_ui {} {
		# Launch setup methods of pages created with 'dui add page'
		dui page add dui_number_editor -namespace true
		dui page add dui_item_selector -namespace true
		
		set applied_ns {}
		foreach page [page list] {
			set ns [page get_namespace $page]
			if { $ns ne "" && $ns ni $applied_ns } {
				if { [info proc ${ns}::setup] eq "" } {
					msg [namespace current] -NOTICE "page namespace '${ns}' does not have a setup method"
				} else {
					#msg [namespace current] setup_ui "running ${ns}::setup"
					${ns}::setup
				}
				lappend applied_ns $ns
			}
		}
		
		# Launch setup methods of pages created as sub-namespaces of ::dui::pages (which do not require 'dui add page')
		# TBD: Disable at the moment, as this would run the setup method of pages in disabled plugins...
#		foreach ns [namespace children ::dui::pages] {
#			if { $ns ni $applied_ns } {
#				if { [info proc ${ns}::setup] eq "" } {
#					msg [namespace current] -NOTICE "page namespace '${ns}' does not have a setup method"
#				} else {
#					#msg [namespace current] setup_ui "running ${ns}::setup"
#					${ns}::setup
#				}
#				lappend applied_ns $ns
#			}
#		}
	}
	
	# Sets dui configuration variables. Logs a warning if the variable does not exist.
	proc config { args } {
		variable settings
		array set opts $args
		if { [llength $args] == 1 } {
			set args [lindex $args 0]
		}
		
		foreach key [array names opts] {
			if { [info exists settings($key)] } {
				if { $key in {debug_buttons create_page_namespaces trim_entries use_editor_pages use_finger_down_for_tap
						disable_long_press enable_spoken_prompts} } {
					set settings($key) [string is true -strict $opts($key)]
				} elseif { $settings($key) ne $opts($key) }  {
					if { $key eq "app_title" } {
						wm title . $opts(app_title)
					}
					set settings($key) $opts($key)
				}
			} else {
				msg -WARN [namespace current] config: "invalid settings variable '$key'"
			}
		}
	}
	
	# Gets a dui configuration variable value. Returns an empty string if the variable is not recognized, and issues
	#	a log notice.
	proc cget { varname } {
		variable settings
		if { [info exists settings($varname)] } {
			return $settings($varname)
		} elseif { [info exists ::dui::$varname] } {
			return [subst \$::dui::$varname]
		} else {
			msg -NOTICE [namespace current] cget: "invalid variable '$varname'"
			return ""
		}
	}
	
	proc say { message sound_name } {
		variable settings
	
		if { $settings(enable_spoken_prompts) == 1 && $message ne  "" } {
			borg speak $message {} $settings(speaking_pitch) $settings(speaking_rate)
		} else {
			sound make $sound_name
		}
	}
	
	### PLATFORM SUB-ENSEMBLE ###
	# System-related stuff
	namespace eval platform {
		namespace export hide_android_keyboard button_press button_long_press finger_down button_unpress \
			xscale_factor yscale_factor rescale_x rescale_y
		namespace ensemble create
		
		proc hide_android_keyboard {} {
			# make sure on-screen keyboard doesn't auto-pop up, and if
			# physical keyboard is connected, make sure navbar stays hidden
			sdltk textinput off
			#	# this auto-hides the bottom android controls, which can appear if a gesture was made
			borg systemui $::android_full_screen_flags
			catch { focus [dui canvas] }
		}
		
		proc button_press {} {
			global android 
			global undroid
			#return {<Motion>}
			if {$android == 1 && [dui cget use_finger_down_for_tap] == 1} {
				return {<<FingerDown>>}
				#return {<ButtonPress-1>}
			}
			#return {<Motion>}
			return {<ButtonPress-1>}
		}
		
		proc button_long_press {} {
			global android 
			if {$android == 1} {
				#return {<<FingerUp>>}
				return {<ButtonPress-3>}
			}
			return {<ButtonPress-3>}
		}
		
		proc finger_down {} {
			global android 
			if {$android == 1 && [dui cget use_finger_down_for_tap] == 1} {
				return {<<FingerDown>>}
			}
			return {<ButtonPress-1>}
		}
		
		proc button_unpress {} {
			global android 
			if {$android == 1} {
				return {<<FingerUp>>}
			}
			return {<ButtonRelease-1>}
		}
		
		proc xscale_factor {} {
			#global screen_size_width
			return [expr {2560.0/[dui cget screen_size_width]}]
		}
		
		proc yscale_factor {} {
			#global screen_size_height
			return [expr {1600.0/[dui cget screen_size_height]}]
		}
		
		proc rescale_x {in} {
			return [expr {int($in / [xscale_factor])}]
		}

		proc rescale_y {in} {
			return [expr {int($in / [yscale_factor])}]
		}		
	}
	
	### THEME SUB-ENSEMBLE ###
	# Themes are just names that serve as groupings for sets of aspect variables. They define a "visual identity"
	#	by setting default option values for widgets (colors, fonts, backgrounds, etc.), which are called "aspects"
	#	in this framework.
	namespace eval theme {
		namespace export add get set exists list
		namespace ensemble create
		
		variable themes { default }
		variable current default
		
		proc add { args } {
			variable themes
			foreach theme $args {
				if { [lsearch $themes $theme] == -1 } {
					lappend themes $theme
				} else {
					msg -NOTICE [namespace current] "theme '$theme' already in the list of available themes"
				}
			}
			return $themes
		}

		# Returns the current active theme
		proc get {} {
			variable current
			return $current
		}
		
		# Changes the current active theme, adding it to the list if it doesn't exist (with a NOTICE on the log).
		proc set { {theme {}} } {
			variable current
			if { ![exists $theme] } {
				msg -NOTICE [namespace current] "current theme '$theme' not previously added"
				add $theme
			}
			::set current $theme
		}
		
		proc exists { theme } {
			variable themes
			return [expr { [lsearch $themes $theme] > -1 } ]
		}
		
		proc list {} {
			variable themes
			return $themes
		}
	}
	
	### SOUND SUB-ENSEMBLE ###
	# Sound names that are used by DUI (must be defined by client code): button_in, button_out and page_change
	
	namespace eval sound {
		namespace export set get exists make list
		namespace ensemble create
		
		variable sounds
		array set sounds {}
		
		proc set { args } {
			variable sounds
			if { [llength $args] == 1 } {
				::set args [lindex $args 0]
			}
			foreach {name path} $args {
				if { [file exists $path] } {
					::set sounds($name) $path
				}
			}
		}
		
		proc get { sound_name } {
			variable sounds
			if { [info exists sounds(sound_name)] } {
				return sounds($sound_name)
			} else {
				return {}
			}
		}
		
		proc exists { sound_name } {
			variable sounds
			return [info exists sounds(sound_name)]
		}
		
		proc make { sound_name } {
			::set path [get $sound_name]
			if { $path ne "" } {
				catch { borg beep $path } 
			}
		}
		
		proc list { {paths 0} } {
			if { [string is true $paths] } {
				# Using 'variable sounds' fails here
				return [array get ::dui::sound::sounds]
			} else {
				return [array names ::dui::sound::sounds]
			}
		}
	}
	
	### ASPECT SUB-ENSEMBLE ###
	# Aspects are the variables that define the default options for each item/widget in a theme.
	# They are stored with labels that use the syntax "<theme>.<widget/type>.<option>?.<style>?".
	# The theme is always specified globally using 'dui theme current <theme_name>', and cannot be modified for 
	#	individual items/widgets.
	# Whenever an item/widget is added to the canvas using the 'dui add *' commands, its default options are
	#	taken from the theme aspects, unless they are overridden explicitly in the 'add *' call.
	# Different styles can be added to any item/widget type, by adding aspects with a ".<style>" suffix.
	# If the 'add *' call includes a -style option, each default aspect option will be taken from the style. If that
	#	option is not available for the style, the non-style option version will be used. 
	# If an aspect is not defined for the current theme, the aspect from the 'default' theme will be used,
	#	or a default can be provided directly by client code using the -default tag of the 'dui aspect get' command.  
	namespace eval aspect {
		namespace export set get exists list
		namespace ensemble create
		
		variable aspects
		# TBD default.button_label.activefill needed? On buttons the invisible rectangle "hides" the text and
		#	it seems they never become active.
		# $::helvetica_font
		
		#"Font Awesome 5 Pro-Regular-400"
		#default.button_label.font_family notosansuiregular
		#default.page.bg_color "#edecfa"
#		default.listbox.highlightthickness 1
#		default.listbox.highlightcolor orange
#		default.listbox.foreground "#7f879a"
#		default.symbol.font_family "Font Awesome 5 Pro"
#		default.entry.font_family notosansuiregular
#		default.entry.font_size 16
		
		array set aspects {
			default.page.bg_img {}
			default.page.bg_color "#d7d9e6"
			
			default.font.font_family notosansuiregular
			default.font.font_size 16
			
			default.text.font_family notosansuiregular
			default.text.font_size 16
			default.text.fill "#7f879a"
			default.text.disabledfill "#ddd"
			default.text.anchor nw
			default.text.justify left
			
			default.text.fill.remark "#4e85f4"
			default.text.fill.error red
			default.text.font_family.section_title notosansuibold
			
			default.text.font_family.page_title notosansuibold
			default.text.font_size.page_title 26
			default.text.fill.page_title "#35363d"
			default.text.anchor.page_title center
			default.text.justify.page_title center
						
			default.symbol.font_family "Font Awesome 5 Pro-Regular-400"
			default.symbol.font_size 55
			default.symbol.fill "#7f879a"
			default.symbol.disabledfill "#ddd"
			default.symbol.anchor nw
			default.symbol.justify left
			
			default.symbol.font_size.small 24
			default.symbol.font_size.medium 40
			default.symbol.font_size.big 55
			
			default.dbutton.debug_outline black
			default.dbutton.fill "#c0c5e3"
			default.dbutton.disabledfill "#ddd"
			default.dbutton.outline white
			default.dbutton.disabledoutline "pink"
			default.dbutton.activeoutline "orange"
			default.dbutton.width 0
			
			default.dbutton_label.pos {0.5 0.5}
			default.dbutton_label.font_size 18
			default.dbutton_label.anchor center	
			default.dbutton_label.justify center
			default.dbutton_label.fill white
			default.dbutton_label.disabledfill "#ddd"

			default.dbutton_label1.pos {0.5 0.8}
			default.dbutton_label1.font_size 16
			default.dbutton_label1.anchor center
			default.dbutton_label1.justify center
			default.dbutton_label1.fill "#7f879a"
			default.dbutton_label1.activefill "#7f879a"
			default.dbutton_label1.disabledfill black
			
			default.dbutton_symbol.pos {0.2 0.5}
			default.dbutton_symbol.font_size 28
			default.dbutton_symbol.anchor center
			default.dbutton_symbol.justify center
			default.dbutton_symbol.fill white
			default.dbutton_symbol.disabledfill "#ccc"
			
			default.dbutton.shape.insight_ok round
			default.dbutton.radius.insight_ok 30
			default.dbutton.bwidth.insight_ok 480
			default.dbutton.bheight.insight_ok 118
			default.dbutton_label.font_family.insight_ok notosansuibold
			default.dbutton_label.font_size.insight_ok 19
			
			default.dclicker.fill {}
			default.dclicker_label.pos {0.5 0.5}
			default.dclicker_label.font_size 18
			default.dclicker_label.fill black
			default.dclicker_label.anchor center
			default.dclicker_label.justify center
			
			default.entry.relief flat
			default.entry.bg white
			default.entry.width 2
			default.entry.foreground black
			
			default.entry.relief.special flat
			default.entry.bg.special yellow
			default.entry.width.special 1

			default.multiline_entry.relief flat
			default.multiline_entry.bg white
			default.multiline_entry.width 2
			default.multiline_entry.font_family notosansuiregular
			default.multiline_entry.font_size 16
			default.multiline_entry.width 15
			default.multiline_entry.height 5

			default.dcombobox.relief flat
			default.dcombobox.bg white
			default.dcombobox.width 2
			default.dcombobox.font_family notosansuiregular
			default.dcombobox.font_size 16
			
			default.dcombobox_ddarrow.font_size 24
			default.dcombobox_ddarrow.disabledfill "#ccc"
			
			default.dcheckbox.font_family "Font Awesome 5 Pro"
			default.dcheckbox.font_size 18
			default.dcheckbox.fill black
			default.dcheckbox.anchor nw
			default.dcheckbox.justify left
			
			default.dcheckbox_label.pos "en 30 -10"
			default.dcheckbox_label.anchor nw
			default.dcheckbox_label.justify left
			
			default.listbox.relief flat
			default.listbox.borderwidth 0
			default.listbox.foreground "#7f879a"
			default.listbox.background white
			default.listbox.selectforeground white
			default.listbox.selectbackground black
			default.listbox.selectborderwidth 0
			default.listbox.disabledforeground "#cccccc"
			default.listbox.selectbackground "#cccccc"
			default.listbox.selectmode browse
			default.listbox.justify left

			default.listbox_label.pos "wn -10 0"
			default.listbox_label.anchor ne
			default.listbox_label.justify right
			
			default.listbox_label.font_family.section_title notosansuibold
			
			default.scrollbar.orient vertical
			default.scrollbar.width 120
			default.scrollbar.length 300
			default.scrollbar.sliderlength 120
			default.scrollbar.from 0.0
			default.scrollbar.to 1.0
			default.scrollbar.bigincrement 0.2
			default.scrollbar.borderwidth 1
			default.scrollbar.showvalue 0
			default.scrollbar.resolution 0.01
			default.scrollbar.background "#d3dbf3"
			default.scrollbar.foreground "#FFFFFF"
			default.scrollbar.troughcolor "#f7f6fa"
			default.scrollbar.relief flat
			default.scrollbar.borderwidth 0
			default.scrollbar.highlightthickness 0
	
			default.dscale.orient horizontal
			default.dscale.foreground "#4e85f4"
			default.dscale.background "#7f879a"
			default.dscale.sliderlength 75
			
			default.scale.orient horizontal
			default.scale.foreground "#FFFFFF"
			default.scale.background "#e4d1c1"
			default.scale.troughcolor "#EAEAEA"
			default.scale.showvalue 0
			default.scale.relief flat
			default.scale.borderwidth 0
			default.scale.highlightthickness 0
			default.scale.sliderlength 125
			default.scale.width 150
			
			default.drater.fill "#7f879a" 
			default.drater.disabledfill "#ccc"
			default.drater.font_size 24
			
			default.rect.fill.insight_back_box "#ededfa"
			default.rect.width.insight_back_box 0
			default.line.fill.insight_back_box_shadow "#c7c9d5"
			default.line.width.insight_back_box_shadow 2
			default.rect.fill.insight_front_box white
			default.rect.width.insight_front_box 0
			
			default.graph.plotbackground "#F8F8F8"
			default.graph.borderwidth 1
			default.graph.background white
			default.graph.plotrelief raised
			default.graph.plotpady 0 
			default.graph.plotpadx 10
		}
		#default.button.disabledfill "#ddd"
		#default.button.radius 40 -- only include if the button style has shape=round
		#default.button.arc_offset 50 -- only include if the button style has shape=outline
				
		# Named options:
		# 	-theme theme_name: to add to a theme different than the current one.
		#	-type type_name: adds this type for all added aspects.
		# 	-style style_name: adds this style for all added aspects.
		# value-pairs can be passed directly in the args, or as a single-argument list.
		proc set { args } {
			variable aspects
			::set theme [dui::args::get_option -theme [dui theme get] 1]
			::set type [dui::args::get_option -type "" 1]
			::set style [dui::args::get_option -style "" 1]
			::set prefix "$theme."
			if { $type ne "" } {
				append prefix "$type."
			}
			::set suffix ""
			if { $style ne "" } {
				::set suffix ".$style"
			}
			
			if { [llength $args] == 1 } {
				::set args [lindex $args 0]
			}
			for { ::set i 0 } { $i < [llength $args] } { incr i 2 } {
				::set var "$prefix[lindex $args $i]$suffix"
#				if { $style ne "" && [string range $var end-[string length $style] end] ne ".$style" } {
#					append var ".$style"
#				}
				::set value [lindex $args [expr {$i+1}]]
				if { [info exists aspects($var)] } {
					if { $aspects($var) eq $value } {
						#msg -INFO [namespace current] "aspect '$var' already exists, new value is equal to old"
					} else {
						msg -NOTICE [namespace current] "aspect '$var' already exists, old value='$aspects($var)', new value='$value'"
						if { [ifexists ::debugging 0]} { msg -DEBUG [stacktrace] }
					}
				}
				::set aspects($var) $value
			}
		}
		
		# Named options:
		# 	-theme theme_name to get for a theme different than the current one
		#	-style style_name to get only that style. If the aspect is not found in that style, the non-styled
		#		value of the aspect is returned instead, if available
		#	-default value to return in case the aspect is undefined
		#	-default_type to search the same aspect in this type, in case it's not defined for the requested type
		proc get { type aspect args } {
			variable aspects
			::set theme [dui::args::get_option -theme [dui theme get] 1]
			::set style [dui::args::get_option -style "" 0]			
			::set default [dui::args::get_option -default "" 1]
			# Inherited argument from first implementation of DUI. Now just append to the $type list.
			lappend type [dui::args::get_option -default_type {} 0]
			
			::set type [list_remove_element [lunique $type] ""]
			::set avalue ""
			if { $style ne "" } {
				::set i 0				
				while { $avalue eq "" && $i < [llength $type] } {
					::set t [lindex $type $i]
					if { [info exists aspects($theme.$t.$aspect.$style)] } {
						::set avalue $aspects($theme.$t.$aspect.$style)
					}
					incr i
				}
			}
			
			if { $avalue eq "" } {
				::set i 0				
				while { $avalue eq "" && $i < [llength $type] } {
					::set t [lindex $type $i]
					if { [info exists aspects($theme.$t.$aspect)] } {
						::set avalue $aspects($theme.$t.$aspect)
					}
					incr i
				}
			}
			
			if { $avalue eq "" } {
				if { $default ne "" } {
					::set avalue $default
				} elseif { [string range $aspect 0 4] eq "font_" && [info exists aspects($theme.font.$aspect)] } {
					::set avalue $aspects($theme.font.$aspect)
				}
			}
			
			if { $avalue eq "" && $theme ne "default" } {
				::set avalue [get $type $aspect -theme default {*}$args] 
			}
			
			if { $avalue eq "" } {
				msg -NOTICE [namespace current] "aspect '$theme.[join $type /].$aspect' not found and no alternative available"
			}
			
			return $avalue
			
#			if { $style ne "" && [info exists aspects($theme.$type.$aspect.$style)] } {
#				return $aspects($theme.$type.$aspect.$style)
#			} elseif { [info exists aspects($theme.$type.$aspect)] } {
#				return $aspects($theme.$type.$aspect)
#			} elseif { $default ne "" } {
#				return $default
#			} elseif { $default_type ne "" && $default_type ne $type } {
#				return [get $default_type $aspect -theme $theme -style $style]
#			} elseif { [string range $aspect 0 4] eq "font_" && [info exists aspects($theme.font.$aspect)] } {
#				return $aspects($theme.font.$aspect)
#			} elseif { $theme ne "default" } {
#				return [get $default_type $aspect -theme default -style $style]
#			} else {
#				msg -NOTICE [namespace current] "aspect '$theme.$aspect' not found and no alternative available"
#				return ""
#			}
		}
		
		# Named options:
		#	-theme theme_name to check for a theme different than the current one
		#	-style style_name to query only that style
		proc exists { type aspect args } {
			variable aspects
			::set theme [dui::args::get_option -theme [dui theme get]]
			::set style [dui::args::get_option -style ""]
			::set aspect_name "$theme.$type.$aspect"
			if { $style ne "" } {
				append aspect_name .$style
			}
			return [info exists aspects($aspect_name)]
		}
				
		# Returns the defined aspect names according to the request parameters.
		# Named options:
		# 	-theme theme_name to return for a theme different than the current one. If not specified and -all_themes=0
		#		(the default), returns aspects for the currently active theme only.
		#	-type to return only the aspects for that type (e.g. "entry", "text", etc.)
		# 	-style to return only the aspects for that style 
		#	-values if 1, returns {<aspect name> <aspect value>} pairs. Defaults to 0 for returning only the aspect names.
		# If the returned values are for a single theme, the theme name prefix is not included, but if -all_themes is 1,
		#	returns the full aspect name including the theme prefix.
		proc list { args } {
			variable aspects
			::set theme [dui::args::get_option -theme [dui theme get]]
			if { $theme eq "default" } {
				::set pattern "^default\\."
			} else {
				::set pattern "^(?:${theme}|default)\\."
			}
			
			::set type [dui::args::get_option -type ""]
			if { $type eq "" } {
				append pattern "\[0-9a-zA-Z_\]+\\."
			} elseif { [llength $type] == 1 } {
				append pattern "${type}\\."
			} else {
				append pattern "(?:[join $type |])\\."
			}
			
			::set style [dui::args::get_option -style ""]
			if { $style eq "" } {
				append pattern "\[0-9a-zA-Z_\]+\$"
			} else {
				# Return aspects with the requested style AND with no style
				append pattern "\[0-9a-zA-Z_\]+(\\.${style})?\$"
			}
			
			#msg [namespace current] list "pattern='$pattern'"
			::set values [string is true [dui::args::get_option -values 0]]
			
			::set result {}			
			foreach full_aspect [array names aspects -regexp $pattern] {
				::set aspect_parts [split $full_aspect .]
				::set aspect [lindex $aspect_parts 2]
				if { $aspect ne "" } {
					lappend result $aspect
				}
				if { $values == 1 } {
					lappend result $aspects($full_aspect)
				}
			}
			
			if { $values != 1 && ([llength $type] > 1 || $style ne "") } {
				return [lunique $result]
			} else {
				return $result
			}
		}
	}	
	
	### SYMBOL SUB-ENSEMBLE ###
	# This set of commands allow defining Fontawesome Regular symbols by name, then use them in the code by their name.
	# To find out the unicode values of the available symbols, see https://fontawesome.com/icons?d=gallery
	namespace eval symbol {
		namespace export set get exists list
		namespace ensemble create
				
		variable font_filename "Font Awesome 5 Pro-Regular-400.otf"
		
		variable symbols
		array set symbols {
			square "\uf0c8"
			square_check "\uf14a"
			sort_down "\uf0dd"
			star "\uf005"
			half_star "\uf089"
			chevron_left "\uf053"
			chevron_double_left "\uf323"
			arrow_to_left "\uf33e"
			chevron_right "\uf054"
			chevron_double_right "\uf324"
			arrow_to_right "\uf340"
			chevron_up "\uf077"
			chevron_double_up "\uf325"
			chevron_down "\uf078"
			chevron_double_down "\uf322"
			eraser "\uf12d"
			eye "\uf06e"
		}

		# Used to map booleans to their dcheckbox representation (square/square_check) in fontawesome.
		variable dcheckbox_symbols_map {"\uf0c8" "\uf14a"}

		# Define Fontawesome symbols by name. If a symbol name is already defined and the value differs, it is NOT 
		#	redefined, and a warning added to the log.
		# value-pairs can be passed directly in the args, or as a single-argument list.
		proc set { args } {
			variable symbols
			
			::set n [expr {[llength $args]-1}]
			if { $n == 0 } {
				::set args [lindex $args 0]
				::set n [expr {[llength $args]-1}]
			}
			for { ::set i 0 } { $i < $n } { incr i 2 } {
				::set sn [lindex $args $i]
				::set sv [lindex $args [expr {$i+1}]]
				::set idx [lsearch [array names symbols] $sn]
				if { $idx == -1 } {
					#msg -INFO [namespace current] "add symbol $sn='$sv'"
					::set symbols($sn) $sv
				} elseif { $symbols($sn) ne $sv } {
					msg -WARN [namespace current ] "symbol '$sn' already defined with a different value"
				}
			}
		}
		
		# If undefined, warns in the log and returns the provided symbol name.
		proc get { symbol } {
			variable symbols
			if { [info exists ::dui::symbol::symbols($symbol)] } {
				return $symbols($symbol)
			} else {
				# Don't warn on unicode values
				if { [string length $symbol] > 1 } {
					msg -WARN [namespace current] "symbol '$symbol' not recognized"
				}
				return $symbol
			}
		}
			
		proc exists { symbol } {
			variable symbols
			return [info exists symbols($symbol)]
		}
		
		proc list {} {
			variable symbols
			return [array names symbols]
		}
	}

	### FONTS SUB-ENSEMBLE ###
	namespace eval font {
		namespace export add_dirs dirs load get width list
		namespace ensemble create

		# A list of paths where to look for font files
		variable font_dirs {}
		# A list with loaded family_name-font_filename pairs. Remembers which fonts have been added with 'sdltk addfont' 
		variable loaded_fonts {}
		# A list with each loaded & created font (each font identified by family+size+options)
		# TBD Why this needed? Just use 'font names'
		variable skin_fonts {}
		
		proc add_dirs { args } {
			variable font_dirs
			if { [llength $args] == 1 } {
				set args [lindex $args 0]
			}
			
			foreach dir $args {
				if { [file isdirectory $dir] } {
					if { $dir in $font_dirs } {
						msg -NOTICE [namespace current] "font directory '$dir' was already in the list"
					} else {
						lappend font_dirs $dir
					}
				} else {
					msg -ERROR [namespace current] "font directory '$dir' not found"
				}
			}
		}
		
		proc dirs {} {
			variable font_dirs
			return $font_dirs
		}
		
		# Returns the font family name corresponding to the font filename. If it's not yet added and 'add_if_needed=1'
		#	(the default), loads the font family. 
		# filename can take several forms:
		#	- A full path, with or without extension. If no extension is provided, both .otf and .ttf are tried.
		#	- A basename, with or without extension. Searches sequentially in each of the font_dirs folders until a 
		#		match is found, trying both .otf and .ttf extensions if the basename has no extension.
		#	- A font family name. In this case, the same family name is returned if the family name is loaded. 
		proc add_or_get_familyname { filename {add_if_needed 1} } {
			variable loaded_fonts
			variable font_dirs
			set familyname ""
			
			set fontindex [lsearch $loaded_fonts $filename]
			if {$fontindex != -1} {
				if { $fontindex % 2 == 1 } {
					set familyname $filename
				} else {
					set familyname [lindex $loaded_fonts [expr $fontindex + 1]]
				}
			} elseif {($::android == 1 || $::undroid == 1) && $filename != "" && [string is true $add_if_needed] } {
				set file_found 0
				if { [file dirname $filename] eq "." } {
					set ndirs [llength $font_dirs]
					for { set i 0 } { $i < $ndirs && !$file_found } { incr i } {
						set dir [lindex $font_dirs $i]
						set test_path [file join $dir $filename]
						if { [file extension $filename] ne "" && [file exists $test_path] } {
							set filename $test_path
							set file_found 1
						} elseif { [file exists "$testpath.otf"] } {
							set filename "$testpath.otf"
							set file_found 1
						} elseif { [file exists "$testpath.ttf"] } {
							set filename "$testpath.ttf"
							set file_found 1
						}
					}
				} else {
					if { [file extension $filename] ne "" && [file exists $filename] } {
						set file_found 1
					} elseif { [file exists "$filename.otf"] } {
						set filename  "$filename.otf"
						set file_found 1
					} elseif { [file exists "$filename.ttf"] } {
						set filename  "$filename.ttf"
						set file_found 1
					}					
				}
				
				if { $file_found } {
					set fontindex [lsearch $loaded_fonts $filename]
					if { $fontindex != -1 } {
						set familyname [lindex $loaded_fonts [expr $fontindex + 1]]
					} else {
						try {
							foreach familyname [sdltk addfont $filename] {
								msg -DEBUG [namespace current] add_or_get_familyname "added file '$filename', familyname '$familyname'"
								lappend loaded_fonts $filename $familyname
							}
						} on error err {
							msg -ERROR [namespace current] load "unable to get familyname from 'sdltk addfont $filename', or font already added: $err"
						}
					}
				} else {
					msg -WARN [namespace current] "can't find font file '$filename'"
				}
			}
			return $familyname
		}
		
		proc key { family_name size args } {
			array set opts $args
			
			#set font_key "\"$family_name\" $size"
			set font_key "$family_name $size"
			if { [array size opts] > 0 } {
				set suffix ""
				if { [info exists opts(-weight)] && $opts(-weight) eq "bold" } {
					append suffix "b"
				} else {
					append suffix "n"
				}
				
				if { [info exists opts(-slant)] && $opts(-slant) eq "italic" } {
					append suffix "i"
				} else {
					append suffix "r"
				}
				
				if { [info exists opts(-underline)] && [string is true $opts(-underline)] } {
					append suffix "1"
				} else {
					append suffix "0"
				}
				
				if { [info exists opts(-overstrike)] && [string is true $opts(-overstrike)] } {
					append suffix "1"
				} else {
					append suffix "0"
				}
				
				if { $suffix ne "nr00" } {
					append font_key " $suffix"
				}
			}
			
			return $font_key
		}
		
		# Based on Barney's load_font: 
		#	https://3.basecamp.com/3671212/buckets/7351439/documents/2208672342#__recording_2349428596
		# filename can be either a font filename, or an added font family name. 
		# args options are passed-through to 'font create', so they may include:
		#	-weight "normal" (default) or "bold"
		#	-slant "roman" (default) or "italic"
		#	-underline false (default) or true
		#	-overstrike false (default) or true
		proc load { filename size args } {
			#variable skin_fonts
			array set opts $args

			# calculate font size 
			set platform_size [expr {int([dui cget fontm] * $size)}]
		
			# Load or get the already-loaded font family name.
			set familyname [add_or_get_familyname $filename]
			if { $familyname eq "" } {
				msg -NOTICE [namespace current] load: "font familyname not available; using filename '$filename'"
				set familyname $filename
			}
			
			set key [key $familyname $size {*}$args]
			if { $key ni [::font names] } {
				# Create the named font instance
				try {
					::font create $key -family $familyname -size $platform_size {*}$args
					msg -DEBUG [namespace current] "load font with key: \"$key\", family: \"$familyname\", requested size: $size, platform size: $platform_size, filename: \"$filename\", options: $args"
				} on error err {
					msg -ERROR [namespace current] "unable to create font with key '$key': $err"
				}
			}
			return $key
		}
		
		
		# Based on Barney's get_font wrapper: 
		#	https://3.basecamp.com/3671212/buckets/7351439/documents/2208672342#__recording_2349428596
		# "I created a wrapper function that you might be interested in adopting. It makes working with fonts even simpler 
		#	by removing the need to pre-load fonts before using them."
		# family_name can also be a font filename (with or without path and/or extension), then it will be auto-loaded
		#	first.
		proc get { family_name size args } {
			#variable skin_fonts
			#variable font_dirs			
			set family_name [add_or_get_familyname $family_name]
			set font_key [key $family_name $size {*}$args]
			if { $font_key ni [::font names] } {
				set font_key [load $family_name $size {*}$args]
			}
		
			return $font_key
		}
		
		
		proc width {untranslated_txt font} {
			set x [font measure $font -displayof [dui canvas] [translate $untranslated_txt]]
			#if {$::android != 1} {    
				# not sure why font measurements are half off on osx but not on android
				return [expr {2 * $x}]
			#}
			#return $x
		}

		proc list { {loaded 0} } {
			if { [string is true $loaded] } {
				variable loaded_fonts
				return $loaded_fonts
			} else {
#				variable skin_fonts
#				return $skin_fonts
				return [::font names]
			}
		}
	}
	
	### ARGS SUB-ENSEMBLE ###
	# A set of tools to manipulate named options in the 'args' argument to dui commands. 
	# These are heavily used in the 'add' commands that create widgets, with the general objectives of:
	#	1) pass-through any aspect parameter explicitly defined by the user to the main widget creation command,
	#		or otherwise use the theme and style default values. 	
	#	2) extract the options that won't be passed through to the main widget creation command, but to other one,
	#		like aspect values passed to the label creation command in 'add dbutton' (-label_font, -label_fill...)
	# These namespace commands are not exported, should normally only be used inside the dui namespace, where
	#	they're called using qualified names.
	namespace eval args {
		variable item_cnt 0
				
		# Adds a named option "-option_name option_value" to a named argument list if the option doesn't exist in the list.
		# Returns the option value.
		proc add_option_if_not_exists { option_name option_value {args_name args} } {
			upvar $args_name largs	
			if { [string range $option_name 0 0] ne "-" } { set option_name "-$option_name" }
			set opt_idx [lsearch $largs $option_name]
			if {  $opt_idx == -1 } {
				lappend largs $option_name $option_value
			} else {
				set option_value [lindex $largs [expr {$opt_idx+1}]]
			}
			return $option_value
		}
		
		# Removes the named option "-option_name" from the named argument list, if it exists.
		proc remove_options { option_names {args_name args} } {
			upvar $args_name largs
			foreach option_name $option_names {
				if { [string range $option_name 0 0] ne "-" } { set option_name "-$option_name" }	
				set option_idx [lsearch $largs $option_name]
				if { $option_idx > -1 } {
					if { $option_idx == [expr {[llength $largs]-1}] } {
						set value_idx $option_idx 
					} else {
						set value_idx [expr {$option_idx+1}]
					}
					set largs [lreplace $largs $option_idx $value_idx]
				}
			}
		}
		
		# Returns 1 if the named arguments list has a named option "-option_name".
		proc has_option { option_name {args_name args} } {
			upvar $args_name largs
			if { [string range $option_name 0 0] ne "-" } { set option_name "-$option_name" }	
			set n [llength $largs]
			set option_idx [lsearch $largs $option_name]
			return [expr {$option_idx > -1 && $option_idx < [expr {$n-1}]}]
		}
		
		# Returns the value of the named option in the named argument list
		proc get_option { option_name {default_value {}} {rm_option 0} {args_name args} } {
			upvar $args_name largs	
			if { [string range $option_name 0 0] ne "-" } { set option_name "-$option_name" }
			set n [llength $largs]
			set option_idx [lsearch $largs $option_name]
			if { $option_idx > -1 && $option_idx < [expr {$n-1}] } {
				set result [lindex $largs [expr {$option_idx+1}]]
				if { $rm_option == 1 } {
					set largs [lreplace $largs $option_idx [expr {$option_idx+1}]]
				}
			} else {
				set result $default_value
			}	
			return $result
		}
		
		# Extracts from args all pairs whose key start by the prefix. And returns the extracted named options in a new
		# args list that contains the pairs, with the prefix stripped from the keys. 
		# For example, "-label_fill X" will return "-fill X" if prefix="-label_", and args will be emptied.
		proc extract_prefixed { prefix {args_name args} } {
			upvar $args_name largs
			set new_args {}
			set n [expr {[string length $prefix]-1}]
			set i 0 
			while { $i < [llength $largs] } { 
				if { [string range [lindex $largs $i] 0 $n] eq $prefix } {
					lappend new_args "-[string range [lindex $largs $i] [expr {$n+1}] end]"
					lappend new_args [lindex $largs [expr {$i+1}]]
					set largs [lreplace $largs $i [expr {$i+1}]]
				} else {
					incr i 2
				}
			}
			return $new_args
		}
		
		
		### NON-EXPORTED COMMANDS TO PARSE AND PROCESS ITEM CREATION args ###
		### These are used from most 'dui add *' commands, for homogeneous handling of the same types of named options.
		
		# Complete the tags and -<type>variable arguments in the args list in a standard way.
		# If -tags is in the args, use the first tag as main tag, otherwise assigns an auto-increment counter.
		# Raises an error if a main tag already exists in the same page, as no duplicates are allowed.
		# Adds page tags in the form "p:$page" to the tags. This allows showing and hiding pages, or retrieving items
		#	by their tag name plus the page in which they appear.
		# If a varoption argument is specified (e.g. "-textvariable"), and the first page in $pages is a page
		#	namespace, then:
		#		- if the varoption is not found in the arguments, or it's the empty string, uses the namespace 
		#			variable data(<main_tag>)
		#		- if the varoption is found and it is a plain name instead of a fully qualified name, such as 
		#			"-textvariable pressure", uses the namespace variable data(<varoption>), e.g. data(pressure).
		#		- otherwise, substitutes %NS in -textvariable by the page namespace, if one is used, or the empty 
		#			string otherwise.
		# -add_multi 1 instructs to add the "<main_tag>*" compound indicator to the list of tags.
		proc process_tags_and_var { pages type {varoption {}} {add_multi 0} {args_name args} {rm_tags 0} } {
			variable item_cnt
			upvar $args_name largs
			set can [dui canvas]
			
			set tags [get_option -tags {} 1 largs]
			set state [get_option -state normal 1 largs]
			set auto_assign_tag 0
			if { [llength $tags] == 0 } {
				set main_tag "${type}_[incr item_cnt]"
				set tags $main_tag
				set auto_assign_tag 1
			} else {				
				set main_tag [lindex $tags 0]
				if { [string is integer $main_tag] || ![regexp {^([A-Za-z0-9_\-])+$} $main_tag] } {
					set msg "Main tag '$main_tag' can only have letters, numbers, underscores and hyphens, and cannot be a number"
					msg [namespace current] process_tags_and_var: $msg
					error $msg
					return
				}
			}
			# Main tags must be unique per-page.
			foreach page $pages {
				if { [$can find withtag $main_tag&&p:$page] ne "" } {
					set msg "Main tag '$main_tag' already exists in page '$page', duplicates are not allowed"
					msg [namespace current] process_tags_and_var: $msg
					error $msg
					return
				}
			}			
			
			if { $add_multi == 1 && "$main_tag*" ni $tags } {
				lappend tags "$main_tag*"
			}
			if { $state in {hidden disabled} } {
				lappend tags st:$state
			}

			foreach p $pages {
				if { "p:$p" ni $tags } { 
					lappend tags "p:$p"
				}
			}
			if { $rm_tags == 0 } {
				add_option_if_not_exists -tags $tags largs
			}
						
			if { $varoption ne "" } {
				set first_page [lindex $pages 0]
				set ns [dui::page::get_namespace $first_page]
	
				if { $ns ne "" } {
					if { [string range $varoption 0 0 ] ne "-" } {
						set varoption -$varoption
					}
					set varname [get_option $varoption "" 1 largs]
					if { $varname eq "" } {
						if { ! $auto_assign_tag } {
							set varname "${ns}::data($main_tag)"
							if { ![info exists $varname] } {
								set $varname {}
							}							
							if { $type eq "variable" } {
								set varname "\$$varname"
							} 
						}
					} elseif { [string is wordchar $varname] } {
						set varname "${ns}::data($varname)"
						if { ![info exists $varname] } {
							set $varname {}
						}						
						if { $type eq "variable" } {
							set varname "\$$varname"
						}
					} else {
						regsub -all {%NS} $varname $ns varname
					}
					
					if { $varname eq "" } {
						msg -WARN [namespace current] complete_tags_and_var "no $varoption specified for item $main_tag"
					} else {
						add_option_if_not_exists $varoption $varname largs
					}
				}
			}
			
			return $tags
		}

		# For each of the requested aspects, modifies the args adding the default option value for the current 
		#	theme and optional style. If an option is already in the args, does not modify it.
		# A fixed set of aspects can be provided on 'aspects', but most frequently this is left empty so that
		#	all options available for the type in the theme aspects are applied.
		# Note that -aspect_type, if provided in the args, has precedence over 'type'.
		# TBD: Allow 'type' to be a list from higher to lower precedence in the aspect searching. 
		proc process_aspects { type {style {}} {aspects {}} {exclude {}} {args_name args} } {
			upvar $args_name largs
			set theme [dui::args::get_option -theme [dui theme get] 1 largs]
			if { $theme eq "none" } {
				return
			}
			if { $style eq "" } {
				set style [get_option -style "" 0 largs]
			}
			set default_type ""
			if { [dui::args::has_option -aspect_type largs] } {
				set default_type $type
				set type [dui::args::get_option -aspect_type "" 1 largs]
				set types [lunique [concat $type $default_type]]
			} else {
				set types $type
			}
			
			if { $aspects eq "" } {
				set aspects [dui aspect list -theme $theme -type $types -style $style]
			}
			foreach aspect $aspects {
				if { $aspect ni $exclude } {
					add_option_if_not_exists -$aspect [dui aspect get $type $aspect -theme $theme -style $style \
						-default_type $default_type] largs
				}
			}
		}
		
		
		# Handles -font_* options in the args:
		#	1) if -font is provided in the args, does nothing
		#	2) otherwise, uses -font_family and -font_size in the args, or, if not provided, from the theme type & style,
		#		and modifies the args to use a -font specification according to the provided options..
		#		If the type does not provide any font definition, uses the <theme>.font.font_* value.
		#		Relative font sizes +1/-1/+2 etc. can be defined, with respect to whatever font size is defined in the 
		#		theme for that type & style.
		# Returns the font.
		# Because this is on "dui add widget", it may make some widget creators fail, if they don't support the -font
		#	attribute, such as ProgressBar.
		proc process_font { type {style {}} {args_name args} } {
			upvar $args_name largs
			if { $type eq "" } {
				set type font
			}
			if { $style eq "" } {
				set style [get_option -style "" 0 largs]
			}
						
			if { [has_option -font largs] } {
				set font [get_option -font "" 0 largs]
				foreach f {family size weight slant underline overstrike} {
					remove_options -font_$f largs
				}
			} elseif { $type ni {ProgressBar} } {
				set font_family [get_option -font_family [dui aspect get $type font_family -style $style] 1 largs]
				set default_size [dui aspect get $type font_size -style $style]	
				set font_size [get_option -font_size $default_size 1 largs]
				if { [string range $font_size 0 0] in "- +" } {
					set font_size [expr $default_size$font_size]
				}
				set weight [get_option -font_weight normal 1 largs]
				set slant [get_option -font_slant roman 1 largs]
				set underline [get_option -font_underline false 1 largs]
				set overstrike [get_option -font_overstrike false 1 largs]
				set font [dui font get $font_family $font_size -weight $weight -slant $slant -underline $underline \
					-overstrike $overstrike]
				add_option_if_not_exists -font $font largs
			} else {
				# Some widget, like ProgressBar, doesn't has a -font option.
				# In this cases we may also query for accepted configuration options and check if -font is supported.
				set font {}
			}
			return $font
		}

		# Processes the -label* named options in 'args' and produces the label according to the provided options.
		# All the -label* options are removed from 'args'.
		# Returns the main tag of the created text.
		proc process_label { pages x y type {style {}} {wrt_tag {}} {args_name args} } {
			upvar $args_name largs
			set label [get_option -label "" 1 largs]
			set labelvar [get_option -labelvariable "" 1 largs]
			if { $label eq "" && $labelvar eq "" } {
				return ""
			}
			if { $style eq "" } {
				set style [get_option -style "" 0 largs]
			}
			
			set tags [get_option -tags "" 0 largs]
			set main_tag [lindex $tags 0]
			if { $wrt_tag eq "" } {
				set wrt_tag $main_tag
			} elseif { $main_tag eq "" } {
				set main_tag $wrt_tag
			}
			
			set label_tags [list ${main_tag}-lbl {*}[lrange $tags 1 end]]
			set label_args [extract_prefixed -label_ largs]
			foreach aspect [dui aspect list -type [list ${type}_label text] -style $style] {
				add_option_if_not_exists -$aspect [dui aspect get ${type}_label $aspect -style $style \
					-default {} -default_type text] label_args
			}
						
			set label_pos [get_option -pos "w -20 0" 1 label_args]
			#[dui aspect get ${type}_label pos -style $style -default "w -20 0"] 
			if { [llength $label_pos] == 2 && [string is integer [lindex $label_pos 0]] && \
					[string is integer [lindex $label_pos 1]] } {
				set xlabel [lindex $label_pos 0]
				if { [string range $xlabel 0 0] in "- +" } {
					set xlabel [expr {$x+$xlabel}]
				}
				set ylabel [lindex $label_pos 1]
				if { [string range $ylabel 0 0] in "- +" } {
					set ylabel [expr {$y+$ylabel}]
				}				
			} else {
				set xlabel [expr {$x-20}]
				set ylabel [expr {$y-3}]
				set xlabel_offset 0
				set ylabel_offset 0
				if { [llength $label_pos] > 1 } {
					set xlabel_offset [dui platform rescale_x [lindex $label_pos 1]] 
				}
				if { [llength $label_pos] > 2 } {
					set ylabel_offset [dui platform rescale_y [lindex $label_pos 2]] 
				}				
				foreach page $pages {
#					set after_show_cmd "dui item relocate_text_wrt $page ${main_tag}-lbl $wrt_tag [lindex $label_pos 0] \
#						$xlabel_offset $ylabel_offset [get_option -anchor nw 0 label_args]"
					set after_show_cmd [list dui item relocate_text_wrt $page ${main_tag}-lbl $wrt_tag [lindex $label_pos 0] \
						$xlabel_offset $ylabel_offset [get_option -anchor nw 0 label_args]]	
					dui page add_action $page show $after_show_cmd
				}
			}

			if { $label ne "" } {
				set id [dui add text $pages $xlabel $ylabel -text $label -tags $label_tags -aspect_type ${type}_label \
					{*}$label_args]
			} elseif { $labelvar ne "" } {
				set id [dui add variable $pages $xlabel $ylabel -textvariable $labelvar -tags $label_tags \
					-aspect_type ${type}_label {*}$label_args] 
			}
			return $id
		}

		# Processes the -yscrollbar* named options in 'args' and produces the scrollbar slider widget according to 
		#	the provided options.
		# All the -yscrollbar* options are removed from 'args'.
		# Returns 0 if the scrollbar is not created, or the widget name if it is. 
#		proc process_yscrollbar { pages x y type {style {}} {args_name args} } {
#			upvar $args_name largs			
#			set ysb [get_option -yscrollbar "" 1 largs]
#			
#			if { $ysb eq "" } {
#				set sb_args [extract_prefixed -yscrollbar_ largs]
#				if { [llength $sb_args] == 0 } {
#					return 0
#				}
#			} elseif { [string is false $ysb] } {
#				return 0
#			} else {
#				set sb_args [extract_prefixed -yscrollbar_ largs]
#			}
#		
#			if { $style eq "" } {
#				set style [get_option -style "" 0 largs]
#			}
#						
#			set tags [get_option -tags "" 0 largs]
#			set main_tag [lindex $tags 0]			
#			set sb_tags [list ${main_tag}-ysb {*}[lrange $tags 1 end]]
#
#			foreach a [dui aspect list -type scrollbar -style $style] {
#				set a_value [dui aspect get ${type}_yscrollbar $a -style $style -default {} -default_type scrollbar]
#				if { $a eq "height" } {
#					if { $a_value eq "" } {
#						set a_value 75
#					}
#					set a_value [dui platform rescale_x $a_value]
#				} elseif { $a in "length sliderlength" } {
#					if { $a_value eq "" } {
#						set a_value 75
#					}
#					set a_value [dui platform rescale_y $a_value]
#				}
#				add_option_if_not_exists -$a $a_value sb_args
#			}
#			
#			set var [get_option -variable "" 1 sb_args]
#			set first_page [lindex $pages 0]
#			if { $var eq "" } {
#				set var "::dui::item::sliders($first_page,$main_tag)"
#				set $var 0
#			}
#			set cmd [get_option -command "" 1 sb_args]
#			if { $cmd eq "" } {
#				set cmd "::dui::item::scrolled_widget_moveto $first_page $main_tag \$$var"
#			}
#			
#			foreach page $pages {
#				dui page add_action $page show "::dui::item::set_yscrollbar_dim $page $main_tag ${main_tag}-ysb"
#			}
#			
#			set w [dui add widget scale $pages 10000 $y -tags $sb_tags -variable $var -command $cmd {*}$sb_args]
##			set scrollable_widget [dui item get_widget $pages $main_tag]
##msg -DEBUG "BINDING $scrollable_widget to set_yscrollbar_dim"			
##			bind [dui item get_widget $pages $main_tag] <Configure> [list ::dui::item::set_yscrollbar_dim [lindex $pages 0] $main_tag ${main_tag}-ysb]
#			
#			return $w
#		}		
	}

	### PAGE SUB-ENSEMBLE ###
	# AT THE MOMENT ONLY page_add SHOULD BE USED AS OTHERS MAY BREAK BACKWARDS COMPATIBILITY #
	namespace eval page {
		namespace export add current exists list delete get_namespace load show add_action actions \
			add_items add_variable update_onscreen_variables
			#set_next show_when_off 
		namespace ensemble create
		
		# Metadata for every added page. Array keys have the form '<page_name>,<type>', where <type> can be:
		#	'ns': Page namespace. Empty string if the page doesn't have a namespace.
		#	'load': List of Tcl callbacks to run when the page is going to be shown, but before it is actually shown.
		#	'show': List of Tcl callbacks to run just after the page is shown.
		#	'hide': List of Tcl callbacks to run just after the page is hidden.
		#	'variables': List of canvas_ids-tcl_code variable pairs to update on the page while it's visible.  
		variable pages_data 
		array set pages_data {}

		variable current_page {}
		
		# A cache to only update variables whose values have actually changed. 
		variable variables_cache
		array set variables_cache {}

		# Keep track of which variables we have already warned about in update_onscreen_variables, otherwise the log
		#	can fill with thousands of identical entries and destroy performance.
		variable warned_variables {}
		
		#variable nextpage
		#array set nextpage {}
		#variable exit_app_on_sleep 0
		
		# 'page add' accommodates both simple-style skin/plugin pages using the same background image or colored rectangle 
		#	for all pages (which can be defined in the theme), or Insight-style customized with a background image per-page,
		#	by defining -bg_img
		#
		# Named options:
		#  -style to apply the default aspects of the provided style
		#  -bg_img background image file to use
		#  -bg_color background color to use, in case no background image is defined
		#  -skin passed to ::add_de1_page if necessary
		#  -namespace either a value that can be a boolean, or a list of namespaces names.
		#		If the option is not specified, uses ::dui::create_page_namespaces as default. Then:
		#		If 'true' or equivalent, uses namespace ::dui::pages::<page_name> for each page, creating it if necessary.
		#		If 'false' or equivalent, uses no page namespace.
		#		Otherwise, uses the passed namespaces for each page. A namespace can be provided for each page, or
		#			a common namespace can be used for all of them. If the namespace does not exist yet, it is created,
		#			and the data array variable is defined. 
		proc add { pages args } {
			variable pages_data
			array set opts $args
			set can [dui canvas]
			
			foreach page $pages {
				if { ![string is wordchar $page] } {
					error "Page names can only have letters, numbers and underscores. '$page' is not valid."
				} elseif { [string is integer $page] } { 
					error "Page names can not be numeric only."
				} elseif { $page in {page pages all true false yes no 1 0} } {
					error "The following page names cannot be used: page, pages, all, true, false, yes, no, 1 or 0."
				} elseif { [info exists pages_data($page,ns)] } {
					error "Page names must be unique. '$page' is duplicated."
				}
			}
			
			set style [dui::args::get_option -style "" 1]			
			set bg_img [dui::args::get_option -bg_img [dui aspect get page bg_img -style $style]]
			if { $bg_img ne "" } {
				::add_de1_page $pages $bg_img [dui::args::get_option -skin ""] 
				#add_de1_image $page 0 0 $bg_img
			} else {
				set bg_color [dui::args::get_option -bg_color [dui aspect get page bg_color -style $style]]
				if { $bg_color ne "" } {
					foreach page $pages {
						$can create rect 0 0 [dui platform rescale_x 2560] [dui platform rescale_y 1600] -fill $bg_color \
							-width 0 -tags "pages $page" -state "hidden"
					}
				}
			}

			set ns [dui::args::get_option -namespace [dui cget create_page_namespaces] 0]
			if { [string is true -strict $ns] } {
				set ns {}
				foreach page $pages {
					lappend ns ::dui::pages::${page}
				}				
			} elseif { [string is false -strict $ns] } {
				set ns ""
			} 

			if { $ns eq "" } {
				foreach page $pages {
					set pages_data($page,ns) {}
				}
			} else {
				# If the page namespace does not exist, create it. Also ensure it has the needed variables.
				foreach page $pages page_ns $ns {
					if { $page_ns eq "" } {
						set page_ns [lindex $ns 0]
					}
					set pages_data($page,ns) $page_ns
					
					if { $page_ns ne "" } {
						if { [namespace exists $page_ns] } {
							if { ![info exists ${page_ns}::data] } {
								namespace eval $page_ns {
									variable data
									array set $data {}
								}
							}
							if { ![info exists ${page_ns}::widgets] } {
								namespace eval $page_ns {
									variable widgets
									array set widgets {}
								}
							}
						} else {
							namespace eval $page_ns {
								namespace export *
								namespace ensemble create
								
								variable data
								array set data {}
								
								variable widgets
								array set widgets {}
							}
						}
					}
				}
			}
		}
		
		proc current {} {
			# Later on dui will keep the current page. At the moment, just use the global variable
			variable current_page
			return $current_page
		}
		
		proc exists { page } {
			variable pages_data
			return [info exists pages_data($page,ns)]
		}
		
		proc list {} {
			variable pages_data
			set pages {}
			foreach arrname [array names pages_data "*,ns"] {
				lappend pages [string range $arrname 0 end-3]
			}
			return $pages
		}
		
		proc delete { pages } {
			variable pages_data
			set can [dui canvas]
			
			foreach page $pages {
				if { $page eq [current] } {
					msg -WARN [namespace current] "cannot delete currently visible page '$page'"
					continue
				}
				if { ![exists $page] } {
					msg -NOTICE [namespace current] delete: "page '$page' not found"
					continue
				}
				$can delete [$can find withtag p:$page]
				$can delete [$can find withtag pages&&$page]
				
				foreach key [array names pages_data "$page,*"] {
					unset pages_data($key)
				}
				
				msg [namespace current] "page '$page' has been deleted"
			}
		}
				
		# If several pages are passed, only uses the first one. Checks that the namespace actually exists, if it
		#	doesn't returns an empty string.
		proc get_namespace { page } {
			variable pages_data
			set page [lindex $page 0]
			set ns [ifexists pages_data($page,ns)]
			if { $ns ne "" && ![namespace exists $ns] } {
				msg -WARN [namespace current] "page namespace '$ns' not found"
				set ns ""
			} 
			return $ns
		}

		# Loads and shows a page, hiding the currently visible one. If -_run_load_actions=0/no/false, doesn't run
		# 	the page-specific load actions (this is used when a page needs to be "shown" but not "(re)-loaded").
		# The load process can be customized by apps adding page actions, either generic ones that run for all pages,
		#	or page-specific ones.
		proc load { page_to_show args } {
			variable current_page
			set can [dui canvas]
			catch { delay_screen_saver }
			
			set page_to_hide [current]
			
			# run general load actions (same for all pages) in the global context. 
			# If 1 or a string is returned, the loading process continues. 
			# If it's a string that matches a page name, the page to show is changed to that one. 
			# If 0 is returned, the loading process is interrupted.
			# Note that this time we don't use [string is true] as "off" is evaluated as boolean...
			foreach action [actions {} load] {
				lappend action $page_to_hide $page_to_show
				set action_result [uplevel #0 $action]
				if { $action_result ne "" && $action_result != 1 } {
					if { $action_result == 0 } {
						msg -NOTICE [namespace current] "loading of page '$page_to_show' interrupted"
						return
					} else {
						msg -NOTICE [namespace current] "CHANGING page_to_show from '$page_to_show' to '$action_result'"
						set page_to_show $action_result	
					} 
				}
			}

			set reload [dui::args::get_option -reload 0 1]
			if { $current_page eq $page_to_show && ![string is true $reload] } {
				#msg -NOTICE [namespace current] load "returning because current_page == $page_to_show"
				return 
			}
			
			set hide_ns [get_namespace $page_to_hide]
			set show_ns [get_namespace $page_to_show]
					
			msg [namespace current] load "$page_to_hide -> $page_to_show"
			dui sound make page_change
			
			#msg "page_display_change $page_to_show"
			#set start [clock milliseconds]
		
			# run page-specific load actions
			set run_load_actions 1
			if { [::dui::args::has_option -_run_load_actions] } {
				set run_load_actions [string is true [::dui::args::get_option -_run_load_actions 1 1]]
			}
			
			if { $run_load_actions } {
				# TBD: Pass $args to load actions???
				foreach action [actions $page_to_show load] {
					lappend action $page_to_hide $page_to_show
					uplevel #0 $action
					#eval $action
				}
				if { $show_ns ne "" && [info procs ${show_ns}::load] ne "" } {
					set page_loaded [${show_ns}::load $page_to_hide $page_to_show {*}$args]
					if { ![string is true $page_loaded] } {
						# Interrupt the loading: don't show the new page
						return
					}
				}
			}

			# update current page
			set current_page $page_to_show
			if { [info exists ::de1(current_context)] } {
				set ::de1(current_context) $page_to_show
			}
		
#			try {
#				$can itemconfigure $page_to_hide -state hidden
#			} on error err {
#				msg -ERROR [namespace current] display_change "error hiding $page_to_hide: $err"
#			}
		
			if {[info exists ::delayed_image_load($page_to_show)] == 1} {
				set pngfilename	$::delayed_image_load($page_to_show)
				msg "Loading skin image from disk: $pngfilename"
				
				set errcode [catch {
					# this can happen if the image file has been moved/deleted underneath the app
					#fallback is to at least not crash
					msg "page_display_change image create photo $page_to_show -file $pngfilename" 
					image create photo $page_to_show -file $pngfilename
					#msg "image create photo $page_to_show -file $pngfilename"
				}]
		
				if {$errcode != 0} {
					catch {
						msg "image create photo error: $::errorInfo"
					}
				}
		
				foreach {page img} [array get ::delayed_image_load] {
					if {$img == $pngfilename} {
						
						# Matching delayed image load to every page that references it
						# this avoids loading the same iamge over and over, for each page referencing it
		
						set errcode [catch {
							# this error can happen if the image file has been moved/deleted underneath the app, fallback is to at least not crash
							$can itemconfigure $page -image $page_to_show -state hidden	
						}]
		
						if {$errcode != 0} {
							catch {
								msg "$can itemconfigure page_to_show ($page/$page_to_show) error: $::errorInfo"
							}
						}
		
						unset -nocomplain ::delayed_image_load($page)
					}
				}
		
			}

			# run hide actions
			if { $page_to_hide ne "" } {
				foreach action [actions {} hide] {
#					lappend action $page_to_hide $page_to_show
#					uplevel #0 $action
					after idle $action $page_to_hide $page_to_show
				}
				foreach action [actions $page_to_hide hide] {
#					lappend action $page_to_hide $page_to_show
#					uplevel #0 $action
					after idle $action $page_to_hide $page_to_show
				}			
				if { $hide_ns ne "" && [info procs ${hide_ns}::hide] ne "" } {
					after idle ${hide_ns}::hide $page_to_hide $page_to_show
				}
			}
			
			# hide all canvas items at once!
			$can itemconfigure all -state hidden

			# show page background item first
			try {
				# If we restrict to items that have tag 'pages', the screensaver images are not shown.
				# TODO: Check how the saver is created, maybe that can be taken care off there, as without restricting
				#	to have the 'pages' tag some unexpected items could eventually appear if user extra tags are 
				#	used.
				#$can itemconfigure pages&&$page_to_show -state normal
				$can itemconfigure $page_to_show -state normal
				$can itemconfigure _tapabsorber_ -state normal
			} on error err {
				msg -ERROR [namespace current] display_change "showing page $page_to_show: $err"
			}
			after 50 {[dui canvas] itemconfigure _tapabsorber_ -state hidden}
						
			# show page items using the "p:<page_name>" tags, unless the have a "st:hidden" tag. 
			foreach item [$can find withtag p:$page_to_show] {
				set state [lsearch -glob -inline [$can gettags $item] {st:*}]
				if { $state eq "" } {
					set state normal
				} else {
					set state [string range $state 3 end]
					if { $state ni {hidden disabled} } {
						set state normal
					}
				}
				$can itemconfigure $item -state $state
			}
			
			# It's critical to call 'update' here and give it a bit of time, otherwise the 'show' actions afterwards 
			# may not get the right dimensions of widgets that have never been painted during the session.
			# That's also why the show actions are triggered "after iddle".
			# TBD: update is considered harmful (see https://wiki.tcl-lang.org/page/Update+considered+harmful), once 
			#	all hide/show actions are triggered "after idle" and controls dynamic relocation/redimensioning is done
			#	on Configure event bindings, it should not be necessary any more.
			#update
			
			# run show actions
			foreach action [actions {} show] {
				after 0 $action $page_to_hide $page_to_show
			}			
			foreach action [actions $page_to_show show] {
				# TODO: Append args once old-system actions like ::after_show_extensions are migrated 
				after 0 $action
			}			
			if { $show_ns ne "" && [info procs ${show_ns}::show] ne "" } {
				after 0 ${show_ns}::show $page_to_hide $page_to_show
			}
			
			#set end [clock milliseconds]
			#puts "elapsed: [expr {$end - $start}]"
			
			dui page update_onscreen_variables
			dui platform hide_android_keyboard
			#msg [namespace current] "Switched to page: $page_to_show [stacktrace]"
		}
		
		proc show { page_to_show } {
			load $page_to_show -_run_load_actions no
		}
		
#		proc set_next { machinepage guipage } {
#			#variable nextpage
#			#msg "set_next_page $machinepage $guipage"
#			set key "machine:$machinepage"
#			set ::nextpage($key) $guipage
#		}
#
#		proc show_when_off { page_to_show args } {
#			set_next off $page_to_show
#			show $page_to_show {*}$args
#		}
#				
#		proc show { page_to_show args } {
#			display_change [current] $page_to_show {*}$args
#		}
#		
#		proc display_change { page_to_hide page_to_show args } {
#			variable current_page
#			set can [dui canvas]
#			catch { delay_screen_saver }
#			
#			set hide_ns [get_namespace $page_to_hide]
#			set show_ns [get_namespace $page_to_show]
#			
#			set key "machine:$page_to_show"
#			if {[ifexists ::nextpage($key)] != ""} {
#				# there are different possible tabs to display for different states (such as preheat-cup vs hot water)
#				set page_to_show $::nextpage($key)
#			}
#		
#			if {$current_page eq $page_to_show} {
#				#msg "page_display_change returning because ::de1(current_context) == $page_to_show"
#				return 
#			}
#		
#			msg [namespace current] display_change "$page_to_hide->$page_to_show"
#				
##			# TODO: This should be handled by the main app adding actions to the sleep/off/saver pages
##			if {$page_to_hide == "sleep" && $page_to_show == "off"} {
##				msg [namespace current] "discarding intermediate sleep/off state msg"
##				return 
##			} elseif {$page_to_show == "saver"} {
##				if {[ifexists ::exit_app_on_sleep] == 1} {
##					get_set_tablet_brightness 0
##					close_all_ble_and_exit
##				}
##			}
#		
#			# signal the page change with a sound
#			dui sound make page_change
#			
#			#msg "page_display_change $page_to_show"
#			#set start [clock milliseconds]
#		
#			# TODO: This should be added on the main app as a load action on the "saver" page
#			# set the brightness in one place
##			if {$page_to_show == "saver" } {
##				if {$::settings(screen_saver_change_interval) == 0} {
##					# black screen saver
##					display_brightness 0
##				} else {
##					display_brightness $::settings(saver_brightness)
##				}
##				borg systemui $::android_full_screen_flags  
##			} else {
##				display_brightness $::settings(app_brightness)
##			}
#		
#			
##			if {$::settings(stress_test) == 1 && $::de1_num_state($::de1(state)) == "Idle" && [info exists ::idle_next_step] == 1} {		
##				msg "Doing next stress test step: '$::idle_next_step '"
##				set todo $::idle_next_step 
##				unset -nocomplain ::idle_next_step 
##				eval $todo
##			}
#
#			# run load actions
#			foreach action [actions {} load] {
#				lappend action $page_to_hide $page_to_show
#				uplevel #0 $action
#			}			
#			foreach action [actions $page_to_show load] {
#				lappend action $page_to_hide $page_to_show
#				uplevel #0 $action
#				#eval $action
#			}
#			if { $show_ns ne "" && [info procs ${show_ns}::load] ne "" } {
#				set page_loaded [${show_ns}::load $page_to_hide $page_to_show {*}$args]
#				if { ![string is true $page_loaded] } {
#					# Interrupt the loading: don't show the new page
#					return
#				}
#			}
#
#			# run hide actions
#			foreach action [actions {} hide] {
#				lappend action $page_to_hide $page_to_show
#				uplevel #0 $action
#				#eval $action
#			}
#			foreach action [actions $page_to_hide hide] {
#				lappend action $page_to_hide $page_to_show
#				uplevel #0 $action
#				#eval $action
#			}			
#			if { $hide_ns ne "" && [info procs ${hide_ns}::hide] ne "" } {
#				${hide_ns}::hide $page_to_hide $page_to_show
#			}
#
#			# update global page
#			set current_page $page_to_show
#			if { [info exists ::de1(current_context)] } {
#				set ::de1(current_context) $page_to_show
#			}
#		
#			#puts "page_display_change hide:$page_to_hide show:$page_to_show"
#			try {
#				$can itemconfigure $page_to_hide -state hidden
#			} on error err {
#				msg -ERROR [namespace current] display_change "error hiding $page_to_hide: $err"
#			}
#			#$can itemconfigure [list "pages" "splash" "saver"] -state hidden
#		
#			if {[info exists ::delayed_image_load($page_to_show)] == 1} {
#				set pngfilename	$::delayed_image_load($page_to_show)
#				msg "Loading skin image from disk: $pngfilename"
#				
#				set errcode [catch {
#					# this can happen if the image file has been moved/deleted underneath the app
#					#fallback is to at least not crash
#					msg "page_display_change image create photo $page_to_show -file $pngfilename" 
#					image create photo $page_to_show -file $pngfilename
#					#msg "image create photo $page_to_show -file $pngfilename"
#				}]
#		
#				if {$errcode != 0} {
#					catch {
#						msg "image create photo error: $::errorInfo"
#					}
#				}
#		
#				foreach {page img} [array get ::delayed_image_load] {
#					if {$img == $pngfilename} {
#						
#						# Matching delayed image load to every page that references it
#						# this avoids loading the same iamge over and over, for each page referencing it
#		
#						set errcode [catch {
#							# this error can happen if the image file has been moved/deleted underneath the app, fallback is to at least not crash
#							$can itemconfigure $page -image $page_to_show -state hidden					
#						}]
#		
#						if {$errcode != 0} {
#							catch {
#								msg "$can itemconfigure page_to_show ($page/$page_to_show) error: $::errorInfo"
#							}
#						}
#		
#						unset -nocomplain ::delayed_image_load($page)
#					}
#				}
#		
#			}
#		
#			# hide all canvas items at once!
#			$can itemconfigure all -state hidden
#
#			# show background, then all page items
#			try {
#				$can itemconfigure $page_to_show -state normal
#			} on error err {
#				msg -ERROR [namespace current ] display_change "showing page $page_to_show: $err"
#			}
#						
#			# new dui system, show page items using the "p:<page_name>" tags 
#			foreach item [$can find withtag p:$page_to_show] {
#				$can itemconfigure $item -state normal
#			}
#
#			# run show actions
#			foreach action [actions {} show] {
#				uplevel #0 $action
#				#eval $action
#			}			
#			foreach action [actions $page_to_show show] {
#				uplevel #0 $action
#				#eval $action
#			}			
#			if { $show_ns ne "" && [info procs ${show_ns}::show] ne "" } {
#				${show_ns}::show $page_to_hide $page_to_show
#				#set ::dui::pages::${page_to_show}::page_drawn 1
#			}
#			
#			#set end [clock milliseconds]
#			#puts "elapsed: [expr {$end - $start}]"
#			
#			update
#			dui page update_onscreen_variables
#			dui platform hide_android_keyboard
#			#msg "Switched to page: $page_to_show [stacktrace]"
#		}
		
		proc add_action { pages event tclcode } {
			variable pages_data
			if { $event ni {load show hide update_vars} } {
				error "'$event' is not a valid event for 'dui page add_action'"
			}
			if { $pages eq "" } {
				# Run for all pages
				lappend pages_data(,$event) $tclcode
			} else {
				foreach page $pages {
					lappend pages_data($page,$event) $tclcode
				}
			}
		}
		
		proc actions { page event } {
			variable pages_data
			if { $event ni {load show hide update_vars} } {
				error "'$event' is not a valid event for 'dui page add_action'"
			}
			return [ifexists pages_data($page,$event)]
		}
		
		# Keep track of what labels are displayed in what pages. This is done through the "p:<page_name>" canvas tags 
		#	associated to each item.
		# This is provided for backwards-compatibility and as a helper for client code that creates its own GUI 
		#	elements, but is NOT USED by DUI. The construction of the tags in dui::args::process_tags_and_var does
		#	the job.
		proc add_items { pages tags } {
			set can [dui canvas]
			foreach tag $tags {
				set item_tags [$can gettags $tag]
				foreach page $pages {
					if { "p:$page" ni $item_tags } {
						lappend item_tags "p:$page"
					}
				}
				msg [namespace current] add_items "new_tags=$item_tags"
				$can itemconfigure $tags -tags $item_tags
			}
		}
		
		proc add_variable { pages id tcl_code } {
			variable pages_data
			
			if { $tcl_code ne "" } {
				#msg [namespace current] add_variable "with id '$id' to pages '$pages'"
				foreach page $pages {
					lappend pages_data(${page},variables) $id $tcl_code
				}
			}
		}
		
		# NOTE: state argument not used in the command, need to keep it???
		proc update_onscreen_variables { } {
			variable update_onscreen_variables_alarm_handle
			variable pages_data
			variable variables_cache
			variable warned_variables
			
			set can [dui canvas]
			set current_page [current]
						
			set something_updated 0	
			if {[info exists pages_data(${current_page},variables)] == 1} {
				# Run actions
				foreach action [actions {} update_vars] {
					uplevel #0 $action
				}
				foreach action [actions $current_page update_vars] {
					uplevel #0 $action
				}
				
				# Update the variables				
				set ids_to_update $pages_data(${current_page},variables) 
				foreach {id varcode} $ids_to_update {
					set varvalue ""
					try {
						set varvalue [subst $varcode]
					} on error err {
						# The log can fill with thousands of identical entries if this is hit, so we save those already
						#	warned about, to warn just once per ID.
						if { $id ni $warned_variables } {  
							msg -ERROR [namespace current] update_onscreen_variables: "Can't update '$id' with code '$varcode': $err"
							lappend warned_variables $id
						}
					}
		
					if { [ifexists variables_cache($id)] ne $varvalue } {
						$can itemconfig $id -text $varvalue
						set variables_cache($id) $varvalue
						set something_updated 1
					}
				}
			}
		
			# john 3-10-19 not sure we need to do a forced screen update
			# See also https://wiki.tcl-lang.org/page/Update+considered+harmful
#			if {$something_updated == 1} {
#				update
#			}
		
			#set y [clock milliseconds]
			#puts "elapsed: [expr {$y - $x}] $something_updated"
		
			if {[info exists update_onscreen_variables_alarm_handle] == 1} {
				after cancel $update_onscreen_variables_alarm_handle
				unset update_onscreen_variables_alarm_handle
			}
			set update_onscreen_variables_alarm_handle [after [dui cget timer_interval] ::dui::page::update_onscreen_variables]
		}
	}
	
	### ITEMS SUB-ENSEMBLE ###
	# Items are visual items added to the canvas, either canvas items (text, arcs, lines...) or Tk widgets.
	namespace eval item {
		namespace export add get get_widget config cget enable_or_disable enable disable \
			show_or_hide show hide add_image_dirs image_dirs listbox_get_selection listbox_set_selection \
			relocate_text_wrt
		namespace ensemble create
	
		variable sliders
		array set sliders {}
		
		# A list of paths where to look for image and sound files. 
		# Within each image directory, it will look in the <screen_width>x<screen_height> subfolder.
		variable img_dirs {}
		variable sound_dirs {}
	
		# Just a wrapper for the add_* commands, for consistency of the API
		proc add { type args } {
			if { [info proc ::dui::add::$type] ne "" } {
				::dui::add::$type {*}$args
			} else {
				msg -ERROR [namespace current] "no 'dui add $type' command available"
			}
		}
		
		# Canvas items selector using tags. Returns unique item IDs. Use trailing * as in "<tag>*" to return all  
		#	related tags (e.g. a listbox with its label and scrollbar)
		# Use the empty string, "*", or "all" to return all tags in the page. Leave the page empty to not filter
		#	to a specific page.
		# Allows specifiying items/widgets in 3 ways:
		#	1) As a page + a list of canvas tags
		#	2) As a list of canvas item IDs (integer numbers) if only one argument is specified. They are then
		#		returned without changes.
		#	3) As a canvas widget pathname. Then it is returned without changes.
		# The second form is there to allow passing the contents of widgets(tag) directly to this function. 
		proc get { page_or_ids_or_widgets {tags {}} } {
			set can [dui canvas]
			if { $tags eq "" } {
				if { $page_or_ids_or_widgets eq "" } {
					return ""
				}
				
				set result {}
				if { [string is integer [lindex $page_or_ids_or_widgets 0]] } {
					foreach id $page_or_ids_or_widgets {						
						if { [$can find withtag $id] eq $id } {
							lappend result $id
						}
					}
				} else {
					foreach w $page_or_ids_or_widgets {
						if { [winfo exists $w] } {
							lappend result $w
						}
					}
				}
				return [lunique $result]
			}
			
			set ids {}
			set page [lindex $page_or_ids_or_widgets 0] 
			foreach tag $tags {
				if {  $page eq "" } {
					set found [$can find withtag $tag]
				} elseif { $tag eq "*" || $tag eq "" || $tag eq "all"} {
					set found [$can find withtag "p:$page"]
				} else {
					set found [$can find withtag "p:$page&&$tag"]
					
				}
				if { $found eq "" } {
					msg -NOTICE [namespace current] get: "no canvas tag matches '$tag' in page '$page'"
				} else {
					lappend ids {*}$found
				}
			}

			return [lunique $ids]
		}
		
		# If page is empty, 'tag_or_widget' should be a widget pathname, and returns it if it exists, or an empty
		#	string if not.
		# If page is non-empty, searches the widget in the dui canvas by tag and returns its pathanme if it's a 
		#	widget/window, or and empty string if it's not found or not a window.
		# This is used by all 'dui item' subcommands that use Tk widgets, so that client code can refer to them
		#	by any of canvas ID, page/canvas tag, or by widget pathname.
		# proc get_widget { page {tag_or_widget {}} }
		proc get_widget { page_or_ids_or_widget {tag {}} } {			
			set widget [lindex [get $page_or_ids_or_widget $tag] 0]
			if { [winfo exists $widget] } {
				return $widget
			} else {
				set can [dui canvas]
				if { [$can type $widget] eq "window" } {
					return [$can itemcget $widget -window]
				}
			}
			return ""
			
#			if { $page eq "" } {
#				set widget [lindex $tag_or_widget 0]
#				if { winfo exists $widget } {
#					return $widget
#				}
#			} else {
#				set can [dui canvas]
#				set item [get [lindex $page 0] [lindex $tag_or_widget 0]]
#				if { [$can type $item] eq "window" } {
#					return [$can itemcget $item -window]
#				}
#			}
#			return ""
		}
		
		# Provides a single interface to configure options for both canvas items (text, arcs...) and canvas widgets 
		#	(window entries, listboxes, etc.)
		# Allows specifiying items/widgets in 3 ways:
		#	1) As a list of widgets pathnames (.can.my_entry, etc.)
		#	2) As a list of canvas item IDs (integer numbers)
		#	3) As a page name as first argument, and a list of tag names as second argument
		proc config { page_or_ids_or_widgets args } {
			set can [dui canvas]
			if { [string range [lindex $args 0] 0 0] eq "-" || [lindex $args 0] eq "" } {
				set items [get $page_or_ids_or_widgets]
			} else {
				set items [get $page_or_ids_or_widgets [lindex $args 0]]
				set args [lrange $args 1 end]
			}
				
			# Passing '$tags' directly to itemconfigure when it contains multiple tags not always works, iterating
			#	is often needed.
			foreach item $items {
				#msg [namespace current] "config:" "item '$item' of type '[$can type $tag]' with '$args'"
				if { [winfo exists $item] } {
					$item configure {*}$args
				} elseif { [$can type $item] eq "window" } {
					[$can itemcget $item -window] configure {*}$args
				} else {
					$can itemconfigure $item {*}$args
				}
			}
		}
		
		proc cget { page_or_ids_or_widgets args } {
			set can [dui canvas]
			if { [string range [lindex $args 0] 0 0] eq "-" || [lindex $args 0] eq "" } {
				set items [get $page_or_ids_or_widgets]
			} else {
				set items [get $page_or_ids_or_widgets [lindex $args 0]]
				set args [lrange $args 1 end]
			}
				
			# Passing '$tags' directly to itemconfigure when it contains multiple tags not always works, iterating
			#	is often needed.
			set result {}
			foreach item $items {
				#msg [namespace current] "config:" "item '$item' of type '[$can type $tag]' with '$args'"
				if { [winfo exists $item] } {
					lappend result [$item cget {*}$args]
				} elseif { [$can type $item] eq "window" } {
					lappend result [[$can itemcget $item -window] cget {*}$args]
				} else {
					lappend result [$can itemcget $item {*}$args]
				}
			}
			return $result
		}
		
		# "Smart" widgets enabler or disabler. 'enabled' can take any value equivalent to boolean (1, true, yes, etc.) 
		# For text, changes its fill color to the default or provided font or disabled color.
		# For other widgets like rectangle "clickable" button areas, enables or disables them.
		# Does nothing if the widget is hidden.
		proc enable_or_disable { enabled page_or_ids_or_widgets {tags {}} } {
			#set can [dui canvas]
#			if { $page eq "" } {
#				set page [dui page current]
#			}
			
			if { [string is true $enabled] || $enabled eq "enable" } {
				set state normal
			} else {
				set state disabled
			}
			
			config $page_or_ids_or_widgets $tags -state $state
		} 
		
		# "Smart" widgets disabler. 
		# For text, changes its fill color to the default or provided disabled color.
		# For other widgets like rectangle "clickable" button areas, disables them.
		# Does nothing if the widget is hidden. 
		proc disable { page_or_ids_or_widgets {tags {}} } {
			enable_or_disable 0 $page_or_ids_or_widgets $tags
		}
		
		proc enable { page_or_ids_or_widgets {tags {}} } {
			enable_or_disable 1 $page_or_ids_or_widgets $tags
		}
		
		# "Smart" widgets shower or hider. 'show' can take any value equivalent to boolean (1, true, yes, etc.)
		# If check_context=1, only hides or shows if the items page is the currently active page. This is useful,
		#	for example, if you're showing after a delay, as the page/page may have been changed in between.
		proc show_or_hide { show page_or_ids_or_widgets {tags {}} { check_context 1 } } {
			if { $tags eq "" && [llength $page_or_ids_or_widgets] == 1 && [dui page exists $page_or_ids_or_widgets] && $check_context } {
				if { $page_or_ids_or_widgets ne [dui page current] } {
					return
				}
			}
#			if { $page eq "" } {
#				set page [dui page current]
#			} elseif { $check_context && $page ne [dui page current] } {
#				return
#			}
			
			if { [string is true $show] || $show eq "show" } {
				set state normal
			} else {
				set state hidden
			}
			
			#set ids [get $page_or_ids_or_widgets $tags]
			foreach id [get $page_or_ids_or_widgets $tags] {
				[dui canvas] itemconfigure $id -state $state
			}
			#config $page_or_ids_or_widgets $tags -state $state
		}
		
		proc show { page tags { check_context 1} } {
			show_or_hide 1 $page $tags $check_context
		}
		
		proc hide { page tags { check_context 1} } {
			show_or_hide 0 $page $tags $check_context
		}

		proc add_image_dirs { args } {
			variable img_dirs
			if { [llength $args] == 1 } {
				set args [lindex $args 0]
			}
			
			foreach dir $args {
				if { [file isdirectory $dir] } {
					if { $dir in $img_dirs } {
						msg -NOTICE [namespace current] "images directory '$dir' was already in the list"
					} else {
						lappend img_dirs $dir
						msg [namespace current] "adding image directory '$dir'"
					}
				} else {
					msg -ERROR [namespace current] "images directory '$dir' not found"
				}
			}
		}
		
		proc image_dirs {} {
			variable img_dirs
			return $img_dirs
		}

		proc add_sound_dirs { args } {
			variable sound_dirs
			if { [llength $args] == 1 } {
				set args [lindex $args 0]
			}
			
			foreach dir $args {
				if { [file isdirectory $dir] } {
					if { $dir in $img_dirs } {
						msg -NOTICE [namespace current] "sounds directory '$dir' was already in the list"
					} else {
						lappend img_dirs $dir
						msg [namespace current] "adding sounds directory '$dir'"
					}
				} else {
					msg -ERROR [namespace current] "sounds directory '$dir' not found"
				}
			}
		}
		
		proc sound_dirs {} {
			variable sound_dirs
			return $sound_dirs
		}
		
		# Moves a text canvas item with respect to another item or widget, i.e. to a position relative to another one.
		# pos can be any of "n", "nw", "ne", "s", "sw", "se", "w", "wn", "ws", "e", "en", "es".
		# xoffset and yoffset define a fixed offset with respect to the coordinates obtained from processing 'pos'. 
		#	Can be positive or negative.
		# anchor is how to position the text widget relative to the point obtained after processing pos & offsets. 
		#	Takes the same values as the standard -anchor option. If not defined, keeps the existing widget -anchor.
		# move_too is a list of other widgets that will be repositioned together with widget, maintaining the same relative
		#	distances to the 'wrt' widget as they had originally. Typically used for the rectangle "button" areas 
		#	around text labels.
		proc relocate_text_wrt { page tag wrt { pos w } { xoffset 0 } { yoffset 0 } { anchor {} } { move_too {} } } {
			set can [dui canvas]
			set page [lindex $page 0]
			set tag [get $page [lindex $tag 0]]
			set wrt [get $page [lindex $wrt 0]]
			lassign [$can bbox $wrt] x0 y0 x1 y1 
			lassign [$can bbox $tag] wx0 wy0 wx1 wy1
			
			set xoffset [dui platform rescale_x $xoffset]
			set yoffset [dui platform rescale_y $yoffset]
			
			if { $pos eq "center" } {
				set newx [expr {$x0+int(($x1-$x0)/2)+$xoffset}]
				set newy [expr {$y0+int(($y1-$y0)/2)+$yoffset}]
			} else {
				set pos1 [string range $pos 0 0]
				set pos2 [string range $pos 1 1]
				
				if { $pos1 eq "w" || $pos1 eq ""} {
					set newx [expr {$x0+$xoffset}]
					
					if { $pos2 eq "n" } {
						set newy [expr {$y0+$yoffset}]
					} elseif { $pos2 eq "s" } {
						set newy [expr {$y1+$yoffset}]
					} else {
						set newy [expr {$y0+int(($y1-$y0)/2)+$yoffset}]
					}
				} elseif { $pos1 eq "e" } {
					set newx [expr {$x1+$xoffset}]
					
					if { $pos2 eq "n" } {
						set newy [expr {$y0+$yoffset}]
					} elseif { $pos2 eq "s" } {
						set newy [expr {$y1+$yoffset}]
					} else {
						set newy [expr {$y0+int(($y1-$y0)/2)+$yoffset}]
					}			
				} elseif { $pos1 eq "n" } {
					set newy [expr {$y0+$yoffset}]
					
					if { $pos2 eq "w" } {
						set newx [expr {$x0+$xoffset}]
					} elseif { $pos2 eq "e" } {
						set newx [expr {$x1+$xoffset}]
					} else {
						set newx [expr {$x0+int(($x1-$x0)/2)+$xoffset}]
					}
				} elseif { $pos1 eq "s" } {
					set newy [expr {$y1+$yoffset}]
					
					if { $pos2 eq "w" } {
						set newx [expr {$x0+$xoffset}]
					} elseif { $pos2 eq "e" } {
						set newx [expr {$x1+$xoffset}]
					} else {
						set newx [expr {$x0+int(($x1-$x0)/2)+$xoffset}]
					}
				} else return 
			}
			
			if { $anchor ne "" } {
				# Embedded in catch as widgets like rectangles don't support -anchor
				catch { $can itemconfigure $tag -anchor $anchor }
			}
			# Don't use command 'moveto' as then -anchor is not acknowledged
			$can coords $tag "$newx $newy"
			
			if { $move_too ne "" } {
				lassign [$can bbox $tag] newx newy
				
				foreach w $move_too {			
					set mtcoords [$can coords $w]
					set mtxoffset [expr {[lindex $mtcoords 0]-$wx0}]
					set mtyoffset [expr {[lindex $mtcoords 1]-$wy0}]
					
					if { [llength $mtcoords] == 2 } {
						$can coords $w "[expr {$newx+$mtxoffset}] [expr {$newy+$mtyoffset}]"
					} elseif { [llength $mtcoords] == 4 } {
						$can coords $w "[expr {$newx+$mtxoffset}] [expr {$newy+$mtyoffset}] \
							[expr {$newx+$mtxoffset+[lindex $mtcoords 2]-[lindex $mtcoords 0]}] \
							[expr {$newy+$mtyoffset+[lindex $mtcoords 3]-[lindex $mtcoords 1]}]"
					}
				}
			}
					
			return "$newx $newy"
		}
		
		# Ensures a minimum or maximum size of a widget in pixels. This is normally useful for text base entries like 
		#	entry or listbox whose width & height on creation have to be defined in number of characters, so may be too
		#	small or too big depending on the actual font in use.
		# OBSOLETE, use -canvas_width and -canvas_height options to set sizes in pixels of text-based widgets. 
		proc ensure_size { widgets args } {
			array set opts $args
			set can [dui canvas]
			foreach w $widgets {
				lassign [$can bbox $w ] x0 y0 x1 y1
				set width [dui platform rescale_x [expr {$x1-$x0}]]
				set height [dui platform rescale_y [expr {$y1-$y0}]]
				
				set target_width 0
				if { [info exists opts(-width)] } {
					set target_width [dui platform rescale_x $opts(-width)]
				} elseif { [info exists opts(-max_width)] && $width > [dui platform rescale_x $opts(-max_width)]} {
					set target_width [dui platform rescale_x $opts(-max_width)] 
				} elseif { [info exists opts(-min_width)] && $width < [dui platform rescale_x $opts(-min_width)]} {
					set target_width [dui platform rescale_x $opts(-min_width)]
				}
				if { $target_width > 0 } {
					$can itemconfigure $w -width $target_width
				}
				
				set target_height 0
				if { [info exists opts(-height)] } {
					set target_height [dui platform rescale_y $opts(-height)]
				} elseif { [info exists opts(-max_height)] && $height > [dui platform rescale_y $opts(-max_height)]} {
					set target_height [dui platform rescale_y $opts(-max_width)] 
				} elseif { [info exists opts(-min_height)] && $height < [dui platform rescale_y $opts(-min_height)]} {
					set target_height [dui platform rescale_y $opts(-min_height)]
				}
				if { $target_height > 0 } {
					$can itemconfigure $w -height $target_height
				}
			}
		}
		
		# Configures a page listbox yscrollbar scale location and size. Run once the page is shown for then to be  
		# dynamically positioned.
		proc set_yscrollbar_dim { page widget_tag {scrollbar_tag {}} } {
			set can [dui canvas]
			if { $scrollbar_tag eq "" } {
				set scrollbar_tag ${widget_tag}-ysb
			}
			set widget [get $page $widget_tag]
			set yscb [get $page $scrollbar_tag]
			
			lassign [$can bbox $widget] x0 y0 x1 y1
			[$can itemcget $yscb -window] configure -length [expr {$y1-$y0}]
			$can coords $yscb [list $x1 $y0]
		}
		
		# convenience function to link a scale widget with a listbox or a multiline_entry so that the scale becomes a 
		#	scrollbar to the widget, rather than using the ugly Tk native scrollbar
		proc scale_scroll { page widget_tag slider_varname dest1 dest2 } {
			set widget [get_widget $page $widget_tag]
			set class [winfo class $widget]
			
			if { $class eq "Listbox" } {
				# get number of items visible in list box
				set visible_items [lindex [split [$widget configure -height] " "] 4]
				# get total items in listbox
				set total_items [$widget size]

				# if all the items fit on screen then there is nothing to do
				if { $visible_items >= $total_items } {
					return
				}
				# determine which item would be at the top if the last items is at the bottom
				set last_top_item [expr $total_items - $visible_items]
				# determine what percentage of the way down the current top item is
				set rescaled_value [expr $dest1 * $total_items / $last_top_item]
			} elseif { $class eq "Multiline_entry" } {
				set rescaled_value $dest1
			} else {
				msg -WARNING [namespace current] scale_scroll "cannot scroll a widget of class '$class'"
				return
			}
			
			upvar $slider_varname fieldname
			set fieldname $rescaled_value
		}
		
		# convenience function to link a scale widget with a listbox or a multiline_entry so that the scale becomes 
		#	a scrollbar to the widget, rather than using the ugly Tk native scrollbar
		proc scrolled_widget_moveto { page widget_tag dest1 dest2 } {
			set widget [get_widget $page $widget_tag]
			set class [winfo class $widget]

			if { $class eq "Listbox" } {
				# get number of items visible in list box
				set visible_items [lindex [split [$widget configure -height] " "] 4]
				# get total items in listbox
				set total_items [$widget size]
				# if all the items fit on screen then there is nothing to do
				if {$visible_items >= $total_items} {
					return
				}
				# determine which item would be at the top if the last items is at the bottom
				set last_top_item [expr $total_items - $visible_items]
				# determine which item should be at the top for the requested value
				set top_item [expr int(round($last_top_item * $dest2))]
				
				$widget yview $top_item
			} elseif { $class eq "Multiline_entry" } {
				$widget yview moveto $dest2
			} else {
				msg -WARNING [namespace current] scrolled_widget_moveto "cannot 'move to' a widget of class '$class'"
			}
		}
		
		# Returns the values of the selected items in a listbox. If a 'values' list is provided, returns the matching
		# items in that list instead of matching to listbox entries, unless 'values' is shorter than the listbox,
		# in which case indexes not reachable from 'values' are taken from the listbox values.
		proc listbox_get_selection { page_or_id_or_widget {tag {}} {values {}} } {
			set widget [get_widget $page_or_id_or_widget $tag]
			set cursel [$widget curselection]
			if { $cursel eq "" } return {}
		
			set result {}	
			set n [llength $values]
			foreach idx [$widget curselection] {
				if { $values ne "" && $idx < $n } {
					lappend result [lindex $values $idx]
				} else {
					lappend result [$widget get $idx]
				}
			}	
			
		#	if { [llength $result] == 1 } {
		#		return [lindex $result 0]
		#	} else {
		#		return $result
		#	}
			return $result	
		}
		
		# Sets the selected items in a listbox, matching the string values.
		# If a 'values' list is provided, 'selected' is matched against that list instead of the actual values shown in the listbox.
		# If 'reset_current' is 1, clears the previous selection first.
		proc listbox_set_selection { page_or_id_or_widget tag selected { values {} } { reset_current 1 } } {
			set widget [get_widget $page_or_id_or_widget $tag]
			if { $selected eq "" } return
			if { $values eq "" } { 
				set values [$widget get 0 end]
			} else {
				# Ensure values has the same length as the listbox items, otherwises trim it or add the listbox items
				set ln [$widget size]
				set vn [llength $values]
				if { $ln < $vn } {
					set values [lreplace $values $ln end]
				} elseif { $ln > $vn } {
					lappend values [$widget get $vn end]
				}
			}
			
			if { [string is true $reset_current] } { 
				$widget selection clear 0 end 
			}	
			if { [$widget cget -selectmode] eq "single" && [llength $selected] > 1 } {
				set selected [lindex $selected end]
			}
			
			
			foreach sel $selected {
				set sel_idx [lsearch -exact $values $sel]
				if { $sel_idx > -1 } { 
					$widget selection set $sel_idx 
					$widget see $sel_idx
				}
			}
		}
		
		# Adapted from Johanna's MimojaCafe skin code, attributed to Barney.
		# Return the canvas IDs of all created items.
		proc rounded_rectangle { x0 y0 x1 y1 radius colour disabled tags } {
			set can [dui canvas]
			set ids {}
			set x0 [dui platform rescale_x $x0] 
			set y0 [dui platform rescale_y $y0] 
			set x1 [dui platform rescale_x $x1] 
			set y1 [dui platform rescale_y $y1]
			
			lappend ids [$can create oval $x0 $y0 [expr $x0 + $radius] [expr $y0 + $radius] -fill $colour -disabledfill $disabled \
				-outline $colour -disabledoutline $disabled -width 0 -tags $tags -state "hidden"]
			lappend ids [$can create oval [expr $x1-$radius] $y0 $x1 [expr $y0 + $radius] -fill $colour -disabledfill $disabled \
				-outline $colour -disabledoutline $disabled -width 0 -tags $tags -state "hidden"]
			lappend ids [$can create oval $x0 [expr $y1-$radius] [expr $x0+$radius] $y1 -fill $colour -disabledfill $disabled \
				-outline $colour -disabledoutline $disabled -width 0 -tags $tags -state "hidden"]
			lappend ids [$can create oval [expr $x1-$radius] [expr $y1-$radius] $x1 $y1 -fill $colour -disabledfill $disabled \
				-outline $colour -disabledoutline $disabled -width 0 -tags $tags -state "hidden"]
			lappend ids [$can create rectangle [expr $x0 + ($radius/2.0)] $y0 [expr $x1-($radius/2.0)] $y1 -fill $colour \
				-disabledfill $disabled -disabledoutline $disabled -outline $colour -width 0 -tags $tags -state "hidden"]
			lappend ids [$can create rectangle $x0 [expr $y0 + ($radius/2.0)] $x1 [expr $y1-($radius/2.0)] -fill $colour \
				-disabledfill $disabled -disabledoutline $disabled -outline $colour -width 0 -tags $tags -state "hidden"]
			return $ids
		}
		
		# Inspired on Barney's rounded_rectangle, mimic DSx buttons showing a button outline without a fill.
		# Return the canvas IDs of all created items.
		proc rounded_rectangle_outline { x0 y0 x1 y1 arc_offset colour disabled width tags } {
			set can [dui canvas]
			set ids {}
			set x0 [dui platform rescale_x $x0] 
			set y0 [dui platform rescale_y $y0] 
			set x1 [dui platform rescale_x $x1] 
			set y1 [dui platform rescale_y $y1]
		
			lappends ids [$can create arc [expr $x0] [expr $y0+$arc_offset] [expr $x0+$arc_offset] [expr $y0] -style arc -outline $colour \
				-width [expr $width-1] -tags $tags -start 90 -disabledoutline $disabled -state "hidden"]
			lappend ids [$can create arc [expr $x0] [expr $y1-$arc_offset] [expr $x0+$arc_offset] [expr $y1] -style arc -outline $colour \
				-width [expr $width-1] -tags $tags -start 180 -disabledoutline $disabled -state "hidden"]
			lappend ids [$can create arc [expr $x1-$arc_offset] [expr $y0] [expr $x1] [expr $y0+$arc_offset] -style arc -outline $colour \
				-width [expr $width-1] -tags $tags -start 0 -disabledoutline $disabled -state "hidden"]
			lappend ids [$can create arc [expr $x1-$arc_offset] [expr $y1] [expr $x1] [expr $y1-$arc_offset] -style arc -outline $colour \
				-width [expr $width-1] -tags $tags -start -90 -disabledoutline $disabled -state "hidden"]
			
			lappend ids [$can create line [expr $x0+$arc_offset/2] [expr $y0] [expr $x1-$arc_offset/2] [expr $y0] -fill $colour \
				-width $width -tags $tags -disabledfill $disabled -state "hidden"]
			lappend ids[$can create line [expr $x1] [expr $y0+$arc_offset/2] [expr $x1] [expr $y1-$arc_offset/2] -fill $colour \
				-width $width -tags $tags -disabledfill $disabled -state "hidden"]
			lappend ids[$can create line [expr $x0+$arc_offset/2] [expr $y1] [expr $x1-$arc_offset/2] [expr $y1] -fill $colour \
				-width $width -tags $tags -disabledfill $disabled -state "hidden"]
			lappend ids[$can create line [expr $x0] [expr $y0+$arc_offset/2] [expr $x0] [expr $y1-$arc_offset/2] -fill $colour \
				-width $width -tags $tags -disabledfill $disabled -state "hidden"]
			return $ids
		}
		
		# Moves the slider in the dscale to the provided position. This has 2 modes:
		#	1) If slider_coord is specified, changes the value of variable $varname according to the relative
		#		position of the slider within the scale, given by slider_coord.
		#	2) If slider_coord is not specified, uses the value of $varname and moves the slider to match the value.
		# Needs 'args' at the end because this is called from a 'trace add variable'.
		proc dscale_moveto { page dscale_tag varname from to {resolution 1} {n_decimals 0} {slider_coord {}} args } {
			set can [dui canvas]
			set slider [dui item get $page "${dscale_tag}-crc"]
			if { $slider eq "" } return
			lassign [$can bbox $slider] sx0 sy0 sx1 sy1
			# Return if the page is not currently visible
			if {$sx0 eq "" } return		
			
			set back [dui item get $page "${dscale_tag}-bck"]
			set front [dui item get $page "${dscale_tag}-frn"]
			if { $slider eq "" || $back eq "" || $front eq "" } {
				return
			}
			
			lassign [$can coords $back] bx0 by0 bx1 by1
			lassign [$can coords $front] fx0 fy0 fx1 fy1
				
			set swidth [expr {$sx1-$sx0}]
			set sheight [expr {$sy1-$sy0}]
			if { ($bx1 - $bx0) >= ($by1 -$by0) } {
				set orient h
			} else {
				set orient v
			}
			
			set varvalue ""
			# If no slider_coord is given, reads the value from whatever is in variable $varname and transforms it
			#	to a slider_coord value.
			if { $slider_coord eq "" && $varname ne "" } {
				if { [info exists $varname] } {
					set varvalue [number_in_range [subst \$$varname] 0 $from $to $resolution $n_decimals]  
				} else {
					set varvalue [number_in_range $from 0 $from $to $resolution $n_decimals]
					set $varname $varvalue
				}

				if { [string is double -strict $varvalue] } {
					if { $varvalue <= $from } {
						switch $orient h {set slider_coord $bx0} v {set slider_coord [expr {$by1-$sheight/2}]}
					} elseif { $varvalue >= $to } {
						switch $orient h {set slider_coord [expr {$bx1-$swidth/2}]} v {set slider_coord $by0 }
					} elseif { $orient eq "h" } {
						set slider_coord [expr {($bx0+$swidth/2)+($bx1-$bx0-$swidth)*$varvalue/($to-$from)}]
					} else {
						set slider_coord [expr {($by1-$sheight/2)+($by1-$by0-$sheight)*$varvalue/($from-$to)}]
					}
				} else {
					return
				}
			}
			
			# Move the slider to slider_coord (x-axis for horizontal scale, y-axis for vertical scale) 
			if { $orient eq "h" } {
				# Horizontal
				if { ($slider_coord-$swidth/2) <= $bx0 } {
					$can coords $front $bx0 $by0 [expr {$bx0+$swidth/2}] $by1
					$can coords $slider $bx0 $sy0 [expr {$bx0+$swidth}] $sy1
					if { $varvalue eq "" } { set $varname $from }
				} elseif { $slider_coord >= ($bx1-$swidth/2) } {
					$can coords $front $bx0 $by0 [expr {$bx1-$swidth/2}] $by1
					$can coords $slider [expr {$bx1-$swidth}] $sy0 $bx1 $sy1
					if { $varvalue eq "" } { set $varname $to }
				} else {
					$can coords $front $bx0 $by0 $slider_coord $by1
					$can move $slider [expr {$slider_coord-($swidth/2)-$sx0}] 0
					if { $varvalue eq "" } {
						set newcoord [expr {$from+($to-$from)*(($slider_coord-$swidth/2-$bx0)/($bx1-$swidth-$bx0))}]
						set $varname [number_in_range $newcoord {} $from $to $resolution $n_decimals]  
					}
				} 
			} else {
				# Vertical
				if { ($slider_coord-$sheight/2) <= $by0 } {
					$can coords $front $bx0 [expr {$by0+$sheight/2}] $bx1 $by1
					$can coords $slider $sx0 $by0 $sx1 [expr {$by0+$sheight}]
					if { $varvalue eq "" } { set $varname $to }
				} elseif { ($slider_coord+$sheight/2) >= $by1 } {
					$can coords $front $bx0 [expr {$by1-$sheight/2}] $bx1 $by1
					$can coords $slider $sx0 [expr {$by1-$sheight}] $sx1 $by1
					if { $varvalue eq "" } { set $varname $from }
				} else {
					$can coords $front $bx0 [expr {$slider_coord+$sheight/2}] $bx1 $by1
					$can move $slider 0 [expr {$slider_coord-$sheight/2-$sy0}]
					if { $varvalue eq "" } {
						set newcoord [expr {$from+($to-$from)*($by1-$slider_coord-$sheight/2)/($by1-$sheight-$by0)}]
						set $varname [number_in_range $newcoord {} $from $to $resolution $n_decimals]
					}
				} 
			}
		}
		
		# Paints each of the symbols of a drater control compound, according to the value of the underlying variable.
		# Needs 'args' at the end because this is called from a 'trace add variable'.
		proc drater_draw { page tag variable {n_ratings 5} {use_halfs 1} {min 0} {max 10} args } {
			set button_id [dui item get $page ${tag}-btn]
			
			if { $button_id eq "" } { return }
			if { [dui item cget $button_id -state] ne "normal" } { return }
			set can [dui canvas]
			
#			if { ($min eq "" || $min == 0 ) && ($max eq "" || $max == 0) } {
#				set current_val [return_zero_if_blank [subst \$$variable]]
#			} else {
#				set current_val [expr {int(([return_zero_if_blank [subst \$$variable]] - 1) / \
#					(($max-$min) / ($n_ratings*$halfs_mult))) + 1}]
#			}
			if { $use_halfs == 1 } { set halfs_mult 2 } else { set halfs_mult 1 }
			set current_val [number_in_range [subst \$$variable] "" $min $max "" 0]
			set current_val [expr {int(($current_val - 1) / (($max-$min) / ($n_ratings*$halfs_mult))) + 1}]
			
			for { set i 1 } { $i <= $n_ratings } { incr i } {
				set wn [dui item get $page ${tag}-$i]
				if { $use_halfs == 1 } {
					set wnh [dui item get $page ${tag}-h$i]
				}
				if { [expr {$i * $halfs_mult}] <= $current_val } {
					#.can itemconfig $wn -fill $::plugins::DGUI::font_color
					$can itemconfig $wn -state normal
					if { $use_halfs == 1 } { $can itemconfig $wnh -state hidden } 
				} else {
					if { $use_halfs == 1 } {
						if { [expr {$i * $halfs_mult - 1}] == $current_val } {
							$can itemconfig $wn -state disabled
							#.can itemconfig $wn -fill $::plugins::DGUI::disabled_color
							$can itemconfig $wnh -state normal 
							#.can itemconfig $wnh -fill $::plugins::DGUI::font_color
						} else {
							$can itemconfig $wn -state disabled
							$can itemconfig $wnh -state hidden
#							.can itemconfig $wn -fill $::plugins::DGUI::disabled_color
#							.can itemconfig $wnh -state hidden 
						}
					} else {
						$can itemconfig $wn -state disabled
						#.can itemconfig $wn -fill $::plugins::DGUI::disabled_color
					}
				}
			}
		}
		
		# Similar to a horizontal_clicker but for arbitrary discrete values like rating stars. 
		proc drater_clicker { variable inx iny x0 y0 x1 y1 {n_ratings 5} {use_halfs 1} {min 0} {max 10} } {
			set x [translate_coordinates_finger_down_x $inx]
			set y [translate_coordinates_finger_down_y $iny]
			set xrange [expr {$x1 - $x0}]
			set xoffset [expr {$x - $x0}]
			if { $use_halfs == 1 } { set halfs_mult 2 } else { set halfs_mult 1 }
			
			set interval [expr {int($xrange / $n_ratings)}] 
			set clicked_val [expr {(int($xoffset / $interval) + 1) * $halfs_mult}]
			set current_val [number_in_range [subst \$$variable] "" $min $max "" 0]
			set current_val [expr {int(($current_val - 1) / (($max-$min) / ($n_ratings*$halfs_mult))) + 1}]	
			
			if { $current_val == $clicked_val && $current_val > 0 } {
				set clicked_val [expr {$clicked_val-1}]
			} elseif { $use_halfs == 1 && $current_val > 0 && $clicked_val == [expr {$current_val+1}] } {
				set clicked_val [expr {$clicked_val-2}]
			}
			
			set $variable [expr {int($min + (($max - $min) * $clicked_val / ($n_ratings*$halfs_mult))) }]	
			#msg [namespace current] "$variable=[subst \$$variable]\rcurrent_value=$current_val, clicked_val=$$clicked_val\rnew_val=[subst \$$variable]"	
		}
		
		proc horizontal_clicker { variable bigincrement smallincrement min max default n_decimals use_biginc x y x0 y0 x1 y1 \
				{editor_cmd {}} {callback_cmd {}} } {
			if { [dui sound exists button_in] } {
				dui sound make button_in
			}
			set x [translate_coordinates_finger_down_x $x]
			set y [translate_coordinates_finger_down_y $y]
			set xrange [expr {$x1 - $x0}]
			set midpoint [expr {$x0 + ($xrange / 2)}]
					
			if { $use_biginc } {
				set onequarterpoint [expr {$x0 + ($xrange / 5)}]
				set twoquarterpoint [expr {$x0 + 2 * ($xrange / 5)}]
				set threequarterpoint [expr {$x1 - 2 * ($xrange / 5)}]
				set fourquarterpoint [expr {$x1 - ($xrange / 5)}]
			} else {
				set onethirdpoint [expr {$x0 + ($xrange / 3)}]
				set twothirdpoint [expr {$x0 + 2 * ($xrange / 3)}]
				set threethirdpoint [expr {$x1 - ($xrange / 3)}]
			}
					
			if {[info exists $variable] != 1 || [subst \$$variable] eq "" || ![string is double [subst \$$variable]] } {
				if { $default ne "" } {
					set $variable $default
				} elseif { $min ne "" && $max ne "" } {
					set $variable [expr {1.0*($max-$min)/2}]
				} elseif { $min ne "" } {
					set $variable $min
				} elseif { $max ne "" && $max > 0 } {
					set $variable $max
				} else {
					set $variable 0
				}
			}
			set_var_in_range $variable "" 0 $min $max 0 $n_decimals 

			set currentval [subst \$$variable]
			set newval $currentval
			set change 0
			if { $use_biginc } {
				if {$x < $onequarterpoint} {
					set change -$bigincrement 
				} elseif {$x < $twoquarterpoint} {
					set change -$smallincrement
				} elseif {$x < $midpoint} {
					if {$editor_cmd eq "" } {
						set change -$smallincrement
					} else {
						uplevel #0 $editor_cmd
					}
				} elseif {$x < $threequarterpoint} {
					if {$editor_cmd eq "" } {
						set change $smallincrement
					} else {
						uplevel #0 $editor_cmd
					}
				} elseif {$x < $fourquarterpoint} {
					set change $smallincrement
				} else {
					set change $bigincrement
				}
			} else {
				if {$x < $onethirdpoint} {
					set change -$smallincrement 
				} elseif {$x < $midpoint} {
					if {$editor_cmd eq "" } {
						set change -$smallincrement
					} else {
						uplevel #0 $editor_cmd
					}
				} elseif {$x < $twothirdpoint} {
					if {$editor_cmd eq "" } {
						set change $smallincrement
					} else {
						uplevel #0 $editor_cmd
					}
				} else {
					set change $smallincrement
				}
			}
			set_var_in_range $variable "" $change $min $max 0 $n_decimals

			if { $callback_cmd ne "" } {
				uplevel #0 $callback_cmd
			}
			
			dui page update_onscreen_variables
			return
		}

		proc vertical_clicker { variable bigincrement smallincrement min max default n_decimals use_biginc x y x0 y0 x1 y1 \
				{editor_cmd {}} {callback_cmd {}} } {
			if { [dui sound exists button_in] } {
				dui sound make button_in
			}
			set x [translate_coordinates_finger_down_x $x]
			set y [translate_coordinates_finger_down_y $y]
			set yrange [expr {$y1 - $y0}]
			set midpoint [expr {$y0 + ($yrange / 2)}]
					
			if { $use_biginc } {
				set onequarterpoint [expr {$y0 + ($yrange / 5)}]
				set twoquarterpoint [expr {$y0 + 2 * ($yrange / 5)}]
				set threequarterpoint [expr {$y1 - 2 * ($yrange / 5)}]
				set fourquarterpoint [expr {$y1 - ($yrange / 5)}]
			} else {
				set onethirdpoint [expr {$y0 + ($yrange / 3)}]
				set twothirdpoint [expr {$y0 + 2 * ($yrange / 3)}]
				set threethirdpoint [expr {$y1 - ($yrange / 3)}]
			}
					
			if {[info exists $variable] != 1 || [subst \$$variable] eq "" || ![string is double [subst \$$variable]] } {
				if { $default ne "" } {
					set $variable $default
				} elseif { $min ne "" && $max ne "" } {
					set $variable [expr {1.0*($max-$min)/2}]
				} elseif { $min ne "" } {
					set $variable $min
				} elseif { $max ne "" && $max > 0 } {
					set $variable $max
				} else {
					set $variable 0
				}
			}
			set_var_in_range $variable "" 0 $min $max 0 $n_decimals 

			set currentval [subst \$$variable]
			set newval $currentval
			set change 0
			if { $use_biginc } {
				if {$y < $onequarterpoint} {
					set change $bigincrement 
				} elseif {$y < $twoquarterpoint} {
					set change $smallincrement
				} elseif {$y < $midpoint} {
					if {$editor_cmd eq "" } {
						set change $smallincrement
					} else {
						uplevel #0 $editor_cmd
					}
				} elseif {$y < $threequarterpoint} {
					if {$editor_cmd eq "" } {
						set change -$smallincrement
					} else {
						uplevel #0 $editor_cmd
					}
				} elseif {$y < $fourquarterpoint} {
					set change -$smallincrement
				} else {
					set change -$bigincrement
				}
			} else {
				if {$y < $onethirdpoint} {
					set change $smallincrement 
				} elseif {$y < $midpoint} {
					if {$editor_cmd eq "" } {
						set change $smallincrement
					} else {
						uplevel #0 $editor_cmd
					}
				} elseif {$y < $twothirdpoint} {
					if {$editor_cmd eq "" } {
						set change -$smallincrement
					} else {
						uplevel #0 $editor_cmd
					}
				} else {
					set change -$smallincrement
				}
			}
			set_var_in_range $variable "" $change $min $max 0 $n_decimals

			if { $callback_cmd ne "" } {
				uplevel #0 $callback_cmd
			}
			
			dui page update_onscreen_variables
			return
		}
						
		# Computes the anchor point coordinates with respect to the provided bounding box coordinates, returns a list 
		#	with 2 elements. 
		# Has more valid values than usual anchor: n, ne, nw, e, en, ew, s, sw, se, w, wn, ws.
		proc anchor_inside_box { anchor x0 y0 x1 y1 {xoffset 0} {yoffset 0} } {
			if { $anchor eq "center" } {
				set x [expr {$x0+int(($y1-$x0)/2)+$xoffset}]
				set y [expr {$y0+int(($y1-$y0)/2)+$yoffset}]
				return [list $x $y]
			}
			
			set anchor1 [string range $anchor 0 0]
			set anchor2 [string range $anchor 1 1]
			
			if { $anchor1 eq "w" || $anchor1 eq ""} {
				set x [expr {$x0+$xoffset}]
				
				if { $anchor2 eq "n" } {
					set y [expr {$y0+$yoffset}]
				} elseif { $anchor2 eq "s" } {
					set y [expr {$y1+$yoffset}]
				} else {
					set y [expr {$y0+int(($y1-$y0)/2)+$yoffset}]
				}
			} elseif { $anchor1 eq "e" } {
				set x [expr {$x1+$xoffset}]
				
				if { $anchor2 eq "n" } {
					set y [expr {$y0+$yoffset}]
				} elseif { $anchor2 eq "s" } {
					set y [expr {$y1+$yoffset}]
				} else {
					set y [expr {$y0+int(($y1-$y0)/2)+$yoffset}]
				}			
			} elseif { $anchor1 eq "n" } {
				set y [expr {$y0+$yoffset}]
				
				if { $anchor2 eq "w" } {
					set x [expr {$x0+$xoffset}]
				} elseif { $anchor2 eq "e" } {
					set x [expr {$x1+$xoffset}]
				} else {
					set x [expr {$x0+int(($x1-$x0)/2)+$xoffset}]
				}
			} elseif { $anchor1 eq "s" } {
				set y [expr {$y1+$yoffset}]
				
				if { $anchor2 eq "w" } {
					set x [expr {$x0+$xoffset}]
				} elseif { $anchor2 eq "e" } {
					set x [expr {$x1+$xoffset}]
				} else {
					set x [expr {$x0+int(($x1-$x0)/2)+$xoffset}]
				}
			} else {
				return [list "" ""]
			}
			
			return [list $x $y]
		}
	
		# Given a box reference coordinates {x0 y0} and dimensions {width height}, returns a 4-element list with the new 
		#	"nw" and "se" coordinates corresponding to anchoring the box to {x0 y0} with the 'anchor' specification.
		# This works like setting canvas text coordinates and an anchor point, but for boxes like buttons.
		# Optional x and y-offsets can be defined to move the targets once they have been computed.
		# Anchor valid values are center, n, ne, nw, s, se, sw, w, e
		proc anchor_coords { anchor x y width height {xoffset 0} {yoffset 0} } {
			if { $anchor eq "center" } {
				set x0 [expr {$x-$width/2+$xoffset}]
				set y0 [expr {$y-$height/2+$yoffset}]
				set x1 [expr {$x+$width/2+$xoffset}]
				set y1 [expr {$y+$height/2+$yoffset}]
				return [list $x0 $y0 $x1 $y1]
			}
			
			set anchor1 [string range $anchor 0 0]
			set anchor2 [string range $anchor 1 1]
			
			if { $anchor1 eq "w" && $anchor2 eq ""} {
				set x0 [expr {$x+$xoffset}]
				set y0 [expr {$y-$height/2+$yoffset}]
			} elseif { $anchor1 eq "e" && $anchor2 eq "" } {
				set x0 [expr {$x-$width+$xoffset}]
				set y0 [expr {$y-$height/2+$yoffset}]
			} elseif { $anchor1 eq "n" } {
				set y0 [expr {$y+$yoffset}]
				
				if { $anchor2 eq "w" } {
					set x0 [expr {$x+$xoffset}]
				} elseif { $anchor2 eq "e" } {
					set x0 [expr {$x-$width+$xoffset}]
				} elseif { $anchor2 eq "" }  {
					set x0 [expr {$x-$width/2+$xoffset}]
				}
			} elseif { $anchor1 eq "s" } {
				set y0 [expr {$y-$height+$yoffset}]
				
				if { $anchor2 eq "w" } {
					set x0 [expr {$x+$xoffset}]
				} elseif { $anchor2 eq "e" } {
					set x0 [expr {$x-$width+$xoffset}]
				} elseif { $anchor2 eq "" }  {
					set x0 [expr {$x-$width/2+$xoffset}]
				}
			} else {
				return [list "" "" "" ""]
			}

			set x1 [expr {$x0+$width+$xoffset}]
			set y1 [expr {$y0+$height+$yoffset}]
			return [list $x0 $y0 $x1 $y1]
		}
	}

	### ADD SUBENSEMBLE: COMMANDS TO CREATE CANVAS ITEMS AND WIDGETS AND ADD THEM TO THE CANVAS ###
	### These work as "facades" to the widget create and canvas commands, to simplify creation, styling and adding
	###		extra commonly used functionality.
	
	namespace eval add {
		namespace export *
		namespace ensemble create
		
		# Not needed at the moment. For basic operation we don't need to keep the dscale state anywhere. The
		# 	calls in the bind events are enough, as they include all the info in their arguments.
		# This may be needed in the future if we want client code to invoke methods on dscales easilyt.
#		::variable dscales
#		array set dscales {}
		
		proc theme { args } {
			dui theme add {*}$args
		}
		
		proc aspect { args } {
			dui aspect set {*}$args
		}
		
		proc symbol { args } {
			dui symbol set {*}$args
		}
		
		proc page { args } {
			dui page add {*}$args
		}

		proc font { args } {
			dui font load {*}$args
		}
		
		proc font_dirs { args } {
			dui font add_dirs {*}$args
		}
		
		proc image_dirs { args } {
			dui item add_image_dirs {*}$args 
		}

		proc sound_dirs { args } {
			dui item add_sound_dirs {*}$args 
		}
		
		# Adds canvas items (arcs, ovals, lines, etc.) to pages
		proc canvas_item { type pages args } {
			set can [dui canvas]
			
			set coords {}
			set i 0
			while { [llength $args] > 0 && [string is entier [lindex $args 0]] } {
				if { $i % 2 == 0 } {
					set coord [dui platform rescale_x [lindex $args 0]]
				} else {
					set coord [dui platform rescale_y [lindex $args 0]]
				}
				lappend coords $coord 
				set args [lrange $args 1 end]
				incr i
			}
					
			set tags [dui::args::process_tags_and_var $pages $type ""]
			set main_tag [lindex $tags 0]
	
			set style [dui::args::get_option -style "" 1]
			dui::args::process_aspects $type $style "" "pos"
					
			try {
				set w [[dui canvas] create $type {*}$coords -state hidden {*}$args]
			} on error err {
				set msg "can't add $type '$main_tag' in page(s) '$pages' to canvas: $err"
				msg -ERROR [namespace current] $msg
				error $msg
				return
			}

			set ns [dui page get_namespace $pages]
			if { $ns ne "" } {
				set ${ns}::widgets($main_tag) $w
			}
			
			#msg -INFO [namespace current] canvas_item "$type '$main_tag' to page(s) '$pages' with args '$args'"
			return $main_tag
		}
		
		
		# Add text items to the canvas. Returns the list of all added tags (one per page).
		#
		# New named options:
		#	-tags: a label that allows to access the created canvas items
		#	-style: to apply the default aspects of the provided style
		#	-aspect_type: to query default aspects for type different than "text"
		#	-compatibility_mode: set to 0 to be backwards-compatible with add_de1_text calls (don't apply aspects,
		#		font suboptions and don't rescale width)
		#	All others passed through to the 'canvas create text' command
		proc text { pages x y args } {
			global text_cnt
			set can [dui canvas]
			set x [dui platform rescale_x $x]
			set y [dui platform rescale_y $y]
			
			set tags [dui::args::process_tags_and_var $pages text ""]
			set main_tag [lindex $tags 0]
			set cmd [dui::args::get_option -command {} 1]
			
			set compatibility_mode [string is true [dui::args::get_option -compatibility_mode 0 1]]
			if { ! $compatibility_mode } {				
				set style [dui::args::get_option -style "" 1]
				dui::args::process_aspects text $style "" "pos"
#if { $main_tag eq "launch_dye" } { msg "BEFORE PROCESSING FONT args='$args'" }
				dui::args::process_font text $style
#if { $main_tag eq "launch_dye" } { msg "AFTER PROCESSING FONT args='$args'" }
				set width [dui::args::get_option -width {} 1]
				if { $width ne "" } {
					set width [dui platform rescale_x $width]
					dui::args::add_option_if_not_exists -width $width
				}
			}
			
			try {
				set id [$can create text $x $y -state hidden {*}$args]
			} on error err {
				set msg "can't add text '$main_tag' in page(s) '$pages' to canvas: $err"
				msg -ERROR [namespace current] $msg
				error $msg
				return
			}
			
			set ns [dui page get_namespace $pages]
			if { $ns ne "" } {
				set ${ns}::widgets($main_tag) $id
			}
			
			if { $cmd ne "" &&  ![string is false -strict $cmd] } {
				if { [string is true -strict $cmd] && $ns ne "" && [namespace which -command ${ns}::$main_tag] ne "" } {
					set cmd ${ns}::$main_tag
				} elseif { [string is wordchar $cmd] && $ns ne "" && [namespace which -command ${ns}::$cmd] ne "" } {
					set cmd ${ns}::$cmd
				} else {
					regsub -all {%NS} $cmd $ns cmd	
				}
				$can bind $id [dui platform button_press] $cmd
			}
			
			#msg -INFO [namespace current] text "'$main_tag' to page(s) '$pages' with args '$args'"
			return $id
		}
		
		# Adds text to a page that is the result of evaluating some code. The text shown is updated automatically whenever
		#	the underlying code evaluates to a different text.
		# Named options:
		#  -textvariable Tcl code. Not the name of a variable, but code to be evaluated. So, to refer to global variable 'x' 
		#		you must use '{$::x}', not '::x'.
		# 		If -textvariable gives a plain name instead of code to be evaluted (no brackets, parenthesis, ::, etc.) 
		#		and the first page in 'pages' is a namespace, uses {$::dui::pages::<page>::data(<textvariable>)}. 
		#		Also in this case, if -tags is not specified, uses the textvariable name as tag.
		# All others passed through to the 'dui add text' command
		proc variable { pages x y args } {
			global variable_labels
			
			set tags [dui::args::process_tags_and_var $pages "variable" -textvariable]
			set main_tag [lindex $tags 0]
			set varcode [dui::args::get_option -textvariable "" 1]
	
			set id [dui add text $pages $x $y {*}$args]
			dui page add_variable $pages $id $varcode
			return $id
		}
		
		
		proc symbol { pages x y args } {
			set symbol [dui::args::get_option -symbol "" 1]
			if { $symbol eq "" } {
				set symbol [dui::args::get_option -text "" 1]
			}
			if { $symbol eq "" } {
				return
			}
			
			set symbol [dui symbol get $symbol]
			dui::args::add_option_if_not_exists -font_family $::dui::symbol::font_filename
			
			dui::args::add_option_if_not_exists -aspect_type symbol
			
			return [dui add text $pages $x $y -text $symbol {*}$args]
		}
		
		# Add dbutton items to the canvas. Returns the list of all added tags (one per page).
		#
		# Defaults to an "invisible" button, i.e. a rectangular "clickable" area. Specify the -style or -shape argument
		#	to generate a visible button instead.
		# Invisible buttons can show their clickable area while debugging, by setting namespace variable debug_buttons=1.
		#	In that case, the outline color is given by aspect 'button.debug_outline' (or black if undefined).
		# Generates up to 3 canvas items/tags per page. Default one is named upon the provided -tags and corresponds to 
		#	the invisible "clickable" area. If a visible button is generated, it its assigned tag "<tag>.button".
		#	If a label is specified, it gets tag "<tag>.label". Returns the list of all added tags.
		#
		# Named options:  
		#	If the first two arguments are integer numbers, they are interpreted as the absolute bottom-right coordinates
		#		of the button. If not provided, arguments -bwidth and -bheight are used.
		#	-tags a label that allows to access the created canvas items
		#	-bwidth to set the width of the button. If this is provided, x1 is ignored and width is added to x0 instead.
		#	-bheight to set the height of the button. If this is provided, y1 is ignored and height is added to y0 instead.
		#		Normally bwidth and bheight are used when defining a button style in the theme aspects, so that buttons
		#		using a given style always have the same size.
		#	-shape any of 'rect', 'rounded' (Barney/MimojaCafe style) or 'outline' (DSx style)
		#	-style to apply the default aspects of the provided style
		#	-command tcl code to be run when the button is clicked
		#	-label, -label1, -label2... label text, in case a label is to be shown inside the button
		#	-labelvariable, -label1variable... to use a variable as label text
		#	-label_pos, -label1_pos... a list with 2 elements between 0 and 1 that specify the x and y percentages where to position
		#		the label inside the button
		#	-label_* (-label_fill -label_outline etc.) are passed through to 'dui add text' or 'dui add variable'
		#	-symbol to add a Fontawesome symbol/icon to the button, on position -symbol_pos, and using option values
		#		given in -symbol_* that are passed through to 'dui add symbol'
		#	-radius for rounded rectangles, and -arc_offset for rounded outline rectangles
		#	All others passed through to the respective visible button creation command.
		proc dbutton { pages x y args } {
			set debug_buttons [dui cget debug_buttons]
			set can [dui canvas]
			set ns [dui page get_namespace $pages]
			
			set cmd [dui::args::get_option -command {} 1]
			set style [dui::args::get_option -style "" 1]
			set aspect_type [dui::args::get_option -aspect_type dbutton]
			dui::args::process_aspects dbutton $style {} {use_biginc orient}
			
			set x1 0
			set y1 0
			set bwidth [dui::args::get_option -bwidth "" 1]
			if { $bwidth ne "" } {
				set x1 [expr {$x+$bwidth}]
			}
			set bheight [dui::args::get_option -bheight "" 1]
			if { $bheight ne "" } {
				set y1 [expr {$y+$bheight}]
			}		 
			
			if { [llength $args] > 0 && [string is entier [lindex $args 0]] } {
				if { $x1 <= 0 } {
					set x1 [lindex $args 0]
				}
				set args [lrange $args 1 end]
			}
			if { [llength $args] > 0 && [string is entier [lindex $args 0]] } {
				if { $y1 <= 0 } {
					set y1 [lindex $args 0]
				}
				set args [lrange $args 1 end]
			}
			if { $x1 <= 0 } {
				set x1 [expr {$x+100}]
			}
			if { $y1 <= 0 } {
				set y1 [expr {$y+100}]
			}
			
			set anchor [dui::args::get_option -anchor nw 1]
			if { $anchor ne "nw" } {
				lassign [dui::item::anchor_coords $anchor $x $y [expr {$x1-$x}] [expr {$y1-$y}]] x y x1 y1
			}
			
			set rx [dui platform rescale_x $x]
			set rx1 [dui platform rescale_x $x1]
			set ry [dui platform rescale_y $y]
			set ry1 [dui platform rescale_y $y1]
					
			set tags [dui::args::process_tags_and_var $pages dbutton {} 1]
			set main_tag [lindex $tags 0]
			set button_tags [list ${main_tag}-btn {*}[lrange $tags 1 end]]
			
			# Note this cannot be processed by 'dui item process_label' as this one processes the positioning of the
			#	label differently (inside), also we need to extract label options from the args before painting the 
			#	background button (as $args is passed to the painting proc) but not create the label until after that
			#	button has been painted.
			set i 0
			set suffix "" 
			set label [dui::args::get_option -label "" 1]
			set labelvar [dui::args::get_option -labelvariable "" 1]
			while { [subst \$label$suffix] ne "" || [subst \$labelvar$suffix] ne "" } {
				set "label${suffix}_tags" [list "${main_tag}-lbl$suffix" {*}[lrange $tags 1 end]]	
				set "label${suffix}_args" [dui::args::extract_prefixed "-label${suffix}_"]
				
				foreach aspect [dui aspect list -type [list "${aspect_type}_label$suffix" text] -style $style] {
					dui::args::add_option_if_not_exists -$aspect [dui aspect get "${aspect_type}_label$suffix" $aspect \
						-style $style -default {} -default_type text] "label${suffix}_args"
				}
				
				set "label${suffix}_pos" [dui::args::get_option -pos {0.5 0.5} 1 "label${suffix}_args"]
				set "xlabel$suffix" [expr {$x+int($x1-$x)*[lindex [subst \$label${suffix}_pos] 0]}]
				set "ylabel$suffix" [expr {$y+int($y1-$y)*[lindex [subst \$label${suffix}_pos] 1]}]
				
				set suffix [incr i]
				set "label$suffix" [dui::args::get_option "-label$suffix" "" 1]
				set "labelvar$suffix" [dui::args::get_option "-label${suffix}variable" "" 1]
			}

			# Process symbols
			set i 0
			set suffix ""
			set symbol [dui::args::get_option -symbol "" 1]
			while { [subst \$symbol$suffix] ne "" } {
				set "symbol${suffix}_tags" [list "${main_tag}-sym$suffix" {*}[lrange $tags 1 end]]	
				set "symbol${suffix}_args" [dui::args::extract_prefixed "-symbol${suffix}_"]
				
				foreach aspect [dui aspect list -type [list "${aspect_type}_symbol$suffix" symbol] -style $style] {
					dui::args::add_option_if_not_exists -$aspect [dui aspect get "${aspect_type}_symbol$suffix" $aspect -style $style \
						-default {} -default_type symbol] "symbol${suffix}_args"
				}
				
				set "symbol${suffix}_pos" [dui::args::get_option -pos {0.5 0.5} 1 "symbol${suffix}_args"]
				set "xsymbol$suffix" [expr {$x+int($x1-$x)*[lindex [subst \$symbol${suffix}_pos] 0]}]
				set "ysymbol$suffix" [expr {$y+int($y1-$y)*[lindex [subst \$symbol${suffix}_pos] 1]}]
				
				set suffix [incr i]
				set "symbol$suffix" [dui::args::get_option "-symbol$suffix" "" 1]
			}

			# Process images
			set i 0
			set suffix ""
			set image [dui::args::get_option -image "" 1]
			while { [subst \$image$suffix] ne "" } {
				set "image${suffix}_tags" [list "${main_tag}-img$suffix" {*}[lrange $tags 1 end]]	
				set "image${suffix}_args" [dui::args::extract_prefixed "-image${suffix}_"]
				
				foreach aspect [dui aspect list -type [list "${aspect_type}_image$suffix" image] -style $style] {
					dui::args::add_option_if_not_exists -$aspect [dui aspect get "${aspect_type}_image$suffix" $aspect -style $style \
						-default {} -default_type image] "image{suffix}_args"
				}
				
				set "image${suffix}_pos" [dui::args::get_option -pos {0.5 0.5} 1 "image${suffix}_args"]
				set "ximage$suffix" [expr {$x+int($x1-$x)*[lindex [subst \$image${suffix}_pos] 0]}]
				set "yimage$suffix" [expr {$y+int($y1-$y)*[lindex [subst \$image${suffix}_pos] 1]}]
				
				set suffix [incr i]
				set "image$suffix" [dui::args::get_option "-image$suffix" "" 1]
			}
			
			# As soon as the rect has a non-zero width (or maybe an outline or fill?), its "clickable" area becomes only
			#	the border, so if a visible rectangular button is needed, we have to add an invisible clickable rect on 
			#	top of it.
			set ids {}
			if { $style eq "" && ![dui::args::has_option -shape]} {
				if { $debug_buttons == 1 } {
					set width 1
					set outline [dui aspect get dbutton debug_outline -style $style -default "black"]
				} else {
					set width 0
				}
	
				if { $width > 0 } {
					set ids [$can create rect $rx $ry $rx1 $ry1 -outline $outline -width $width -tags $button_tags \
						-state hidden]
				}
			} else {
				dui::args::remove_options -debug_outline
				set shape [dui::args::get_option -shape [dui aspect get dbutton shape -style $style -default rect] 1]
				
				if { $shape eq "round" } {
					set fill [dui::args::get_option -fill [dui aspect get dbutton fill -style $style]]
					set disabledfill [dui::args::get_option -disabledfill [dui aspect get dbutton disabledfill -style $style]]
					set radius [dui::args::get_option -radius [dui aspect get dbutton radius -style $style -default 40]]
					
					set ids [dui::item::rounded_rectangle $x $y $x1 $y1 $radius $fill $disabledfill $button_tags]
				} elseif { $shape eq "outline" } {
					set outline [dui::args::get_option -outline [dui aspect get dbutton outline -style $style]]
					set disabledoutline [dui::args::get_option -disabledoutline [dui aspect get dbutton disabledoutline -style $style]]
					set arc_offset [dui::args::get_option -arc_offset [dui aspect get dbutton arc_offset -style $style -default 50]]
					set width [dui::args::get_option -width [dui aspect get dbutton width -style $style -default 3]]
					
					set ids [dui::item::rounded_rectangle_outline $x $y $x1 $y1 $arc_offset $outline $disabledoutline \
						$width $button_tags]
				} else {
					set ids [$can create rect $rx $ry $rx1 $ry1 -tags $button_tags -state hidden {*}$args]
				}
			}
			if { $ids ne "" && $ns ne "" } {
				set ${ns}::widgets([lindex $button_tags 0]) $ids
			}

			# Add each of the (possibly several) images
			set i 0
			set suffix ""
			while { [info exists image$suffix] && [subst \$image$suffix] ne "" } {
				dui add image $pages [subst \$xsymbol$suffix] [subst \$ysymbol$suffix] -text [subst \$image$suffix] \
					-tags [subst \$image${suffix}_tags] -aspect_type "dbutton_image$suffix" \
					-style $style {*}[subst \$image${suffix}_args]
				set suffix [incr i]
			}

			# Add each of the (possibly several) symbols
			set i 0
			set suffix ""
			while { [info exists symbol$suffix] && [subst \$symbol$suffix] ne "" } {
				dui add symbol $pages [subst \$xsymbol$suffix] [subst \$ysymbol$suffix] -text [subst \$symbol$suffix] \
					-tags [subst \$symbol${suffix}_tags] -aspect_type "dbutton_symbol$suffix" \
					-style $style {*}[subst \$symbol${suffix}_args]
				set suffix [incr i]
			}
			
			
			# Add each of the (possibly several) labels
			set i 0
			set suffix ""
			while { ([info exists label$suffix] && [subst \$label$suffix] ne "") || 
					([info exists labelvar$suffix] && [subst \$labelvar$suffix] ne "") } {
				if { [info exists label$suffix] && [subst \$label$suffix] ne "" } {
					dui add text $pages [subst \$xlabel$suffix] [subst \$ylabel$suffix] -text [subst \$label$suffix] \
						-tags [subst \$label${suffix}_tags] -aspect_type "dbutton_label$suffix" \
						-style $style {*}[subst \$label${suffix}_args]
				} elseif { [info exists labelvar$suffix] && [subst \$labelvar$suffix] ne "" } {
					dui add variable $pages [subst \$xlabel$suffix] [subst \$ylabel$suffix] \
						-textvariable [subst \$labelvar$suffix] -tags [subst \$label${suffix}_tags] \
						-aspect_type "dbutton_label$suffix" -style $style {*}[subst \$label${suffix}_args] 
				}
				set suffix [incr i]
			}
			
			# Clickable rect
			set id [$can create rect $rx $ry $rx1 $ry1 -fill {} -outline black -width 0 -tags $tags -state hidden]
			if { $cmd eq "" } {
				if { $ns ne "" && [namespace which -command "${ns}::${main_tag}"] ne "" } {
					set cmd "${ns}::${main_tag}"
				}
			} else {
				if { $ns ne "" } { 
					if { [string is wordchar $cmd] && [namespace which -command "${ns}::$cmd"] ne "" } {
						set cmd ${ns}::$cmd
					}				
					regsub -all {%NS} $cmd $ns cmd
				}
				regsub {%x0} $cmd $rx cmd
				regsub {%x1} $cmd $rx1 cmd
				regsub {%y0} $cmd $ry cmd
				regsub {%y1} $cmd $ry1 cmd
			}
			if { $cmd eq "" } {
				msg -WARN [namespace current] dbutton "'$main_tag' in page(s) '$pages' does not have a command"
			} else {
				$can bind $id [dui platform button_press] $cmd
			}
			
			if { $ns ne "" } {
				set ${ns}::widgets($main_tag) $id
			}
			#msg -INFO [namespace current] dbutton "'$main_tag' to page(s) '$pages' with args '$args'"			
			return $id
		}

		# A dbutton with clickable "sub-areas" for increasing and decreasing a numeric value.
		# Extra named options:
		#	-variable
		#	-smallincrement
		#	-bigincrement
		#	-use_biginc
		#	-min
		#	-max
		#	-default
		#	-n_decimals
		#	-editor_page
		#	-editor_*, passed through to the number editor page, e.g. -editor_page_title, -editor_callback_cmd, etc.
		
		proc dclicker { pages x y args } {
			set tags [dui::args::process_tags_and_var $pages dclicker -variable 1]
			set main_tag [lindex $tags 0]
			set ns [dui page get_namespace $pages]
				
			set style [dui::args::get_option -style "" 0]
			set var [dui::args::get_option -variable "" 1]
			dui::args::process_aspects dclicker $style
			
			set orient [string range [dui::args::get_option -orient h 1] 0 0]
			set use_biginc [dui::args::get_option -use_biginc 1 1]
			set n_decimals [dui::args::get_option -n_decimals 0 1]
			foreach fn {min max default smallincrement bigincrement} {
				set $fn [dui::args::get_option -$fn "" 1]
			}

			set editor_cmd {}
			set editor_page [dui::args::get_option -editor_page [dui cget use_editor_pages] 1]
			set callback_cmd [dui::args::get_option -callback_cmd "" 1]
			if { $callback_cmd ne "" } {
				regsub -all {%NS} $callback_cmd $ns callback_cmd
			}
			
			if { $editor_page ne "" && ![string is false $editor_page] && $var ne ""} {
				if { [string is true $editor_page] } {
					set editor_page "dui_number_editor" 
				} 
				set editor_args [dui::args::extract_prefixed -editor_ ]
				
				set editor_cmd [list dui page load $editor_page $var -n_decimals $n_decimals -min $min \
					-max $max -default $default -smallincrement $smallincrement -bigincrement $bigincrement \
					{*}$editor_args ]
				#set editor_cmd "if \{ \[dui item cget [lindex $pages 0] $main_tag -state\] eq \"normal\" \} \{ $editor_cmd \};"
#				bind $widget <Double-Button-1> $editor_cmd
			}
			
			if { $orient eq "v" } {
				set cmd [list ::dui::item::vertical_clicker $var $bigincrement $smallincrement $min $max $default \
					$n_decimals $use_biginc %x %y %%x0 %%y0 %%x1 %%y1 $editor_cmd $callback_cmd]
			} else {
				set cmd [list ::dui::item::horizontal_clicker $var $bigincrement $smallincrement $min $max $default \
					$n_decimals $use_biginc %x %y %%x0 %%y0 %%x1 %%y1 $editor_cmd $callback_cmd]
			}

			return [dui add dbutton $pages $x $y -command $cmd -aspect_type dclicker {*}$args]
		}
		
		# Extra named options:
		#	-type The type of image, defaults to 'photo'
		#	-canvas_* Options to be passed through to the canvas create command
		proc image { pages x y filename args } {
			set can [dui canvas]
			# No-file images are used in the default skin to generate "dummy" pages or something like that...
#			if { $filename eq "" } {
#				set msg "An image filename is required"
#				msg -ERROR [namespace current] image $msg
#				error $msg
#				return
#			}
			if { $filename ne "" } {
				if { [file dirname $filename] eq "." } {
					foreach dir [dui item image_dirs] {
						set full_fn "$dir/[dui cget screen_size_width]x[dui cget screen_size_height]/$filename"
						if { [file exists $full_fn] } {
							set filename $full_fn
							break
						}
					}
				}
				if { ![file exists $filename] } {
					# TBD: Do resizing if the 2560x1600 image file exists, as in background images?
					set msg "Image filename '$filename' not found"
					msg -ERROR [namespace current] image $msg
					error $msg
					return	
				}
			}
			
			set x [dui platform rescale_x $x]
			set y [dui platform rescale_y $y]
			set tags [dui::args::process_tags_and_var $pages image ""]
			set main_tag [lindex $tags 0]
			set style [dui::args::get_option -style "" 1]
			dui::args::process_aspects image $style ""
			set type [dui::args::get_option -type photo 1]
			
			# Options that are to be passed to the 'canvas create' command instead of the image creation command.
			# Using this we can modify the canvas image anchor or other options.
			set canvas_args [dui::args::extract_prefixed -canvas_]
			dui::args::add_option_if_not_exists -anchor nw canvas_args
			
			dui::args::remove_options -tags
			try {
				set w [::image create $type $main_tag -file "$filename" {*}$args]
			} on error err {
				set msg "can't create image '$main_tag' in page(s) '$pages': $err"
				msg -ERROR [namespace current] $msg
				error $msg
				return	
			}
			
			try {
				[dui canvas] create image $x $y -image $main_tag -tags $tags -state hidden {*}$canvas_args
			} on error err {
				set msg "can't add image '$main_tag' in page(s) '$pages' to canvas: $err"
				msg -ERROR [namespace current] $msg
				error $msg
				return
			}
	
			 
			set ns [dui page get_namespace $pages]
			if { $ns ne "" } {
				set ${ns}::widgets($main_tag) $w
			}			
			#msg -INFO [namespace current] image "add '$main_tag' to page(s) '$pages' with args '$args'"			
			return $main_tag
		}
				
		# Named options:
		#	-tags
		#	-canvas_anchor, canvas_width, canvas_height are passed to the canvas create command.
		#   -label or -labelvariable
		#	-label_pos can be a pair of absolute coordinates; a pair of relative coordinates with respect to the widget
		#		top-left coordinates {x y}, if they start by "-" or "+"; or a position marker and optional positive or
		#		negative x and y offsets. The marker and offsets are used in a relocate_text_wrt call on the page show 
		#		event, so that it is repositioned dynamically for widgets whose size is defined in characters instead
		#		of pixels.
		#	-label_* passed through to 'add text'
		#	-tclcode code to be evaluated after the widget is created, to allow configuring the widget. It is evaluated
		#		in a global context, and performs the following substitutions:
		#			%W the widget pathname
		#			%NS the page namespace, if it has one, o/w an empty string
		proc widget { type pages x y args } {
			set can [dui canvas]
			set rx [dui platform rescale_x $x]
			set ry [dui platform rescale_y $y]
			
			set ns [dui page get_namespace $pages]
			set tags [dui::args::process_tags_and_var $pages $type "" 0 args 0]
			set main_tag [lindex $tags 0]
			
			# Widget names after ".can" cannot start by an uppercase letter, so we make the page name lowercase.
			set widget $can.[string tolower [lindex $pages 0]]-$main_tag
			if { [info exists ::$widget] } {
				set msg "$type widget with name '$widget' already exists"
				msg -ERROR [namespace current] $msg
				error $msg
				return
			}
			
			set style [dui::args::get_option -style "" 1]
			dui::args::process_aspects $type $style	
			dui::args::process_font $type $style
	
			# Options that are to be passed to the 'canvas create' command instead of the widget creation command.
			# Using this we can modify the canvas item anchor, or use pixel widths & heights for text widgets like
			#	entries or listboxes.
			set canvas_args [dui::args::extract_prefixed -canvas_]
			dui::args::add_option_if_not_exists -anchor nw canvas_args
			if { [dui::args::has_option -width canvas_args] } {
				dui::args::add_option_if_not_exists -width [dui platform rescale_x [dui::args::get_option -width 0 1 canvas_args]] canvas_args 
			}
			if { [dui::args::has_option -height canvas_args] } {
				dui::args::add_option_if_not_exists -height [dui platform rescale_y [dui::args::get_option -height 0 1 canvas_args]] canvas_args 
			}				
#			if { $type eq "scrollbar" } {
#				# From the original add_de1_widget, but WHY this? Also, scrollbars are no longer used, scales
#				#	are used instead...
#				dui::args::add_option_if_not_exists -height 245 canvas_args
#			}
			
			dui::args::process_label $pages $x $y $type $style
			
			dui::args::remove_options -tags
			set tclcode [dui::args::get_option -tclcode "" 1]
			try {
				::$type $widget {*}$args
			} on error err {
				set msg "can't create $type widget '$widget' on page(s) '$pages': $err"
				msg -ERROR [namespace current] $msg
				error $msg
				return			
			}			
			
			# BLT on android has non standard defaults, so we overrride them here, sending them back to documented defaults
			# TBD: Kept temporarily for backwards-compatibility when using 'add_de1_widget graph' or 'dui add widget graph'. 
			# Recommended current use is 'dui add graph'
			if { $type eq "graph" && ($::android == 1 || $::undroid == 1) } {
				$widget grid configure -dashes "" -color "#DDDDDD" -hide 0 -minor 1 
				$widget configure -borderwidth 0
				#$widget grid configure -hide 0
			}
		
			# Additional code to run when creating this widget, such as chart configuration instructions
			if { $tclcode ne "" } {
				regsub -all {%W} $tclcode $widget tclcode
				regsub -all {%NS} $tclcode $ns tclcode
				try {  
					# It should be safer to run 'uplevel #0 $tclcode', but inherited code would break, so at the moment
					# 	we eval in the current context (but it's unsafe, may redefine local variables like $x, $pages, etc.)
					#uplevel #0 $tclcode
					eval $tclcode
				} on error err {
					set msg "error evaluating tclcode for $type widget '$widget' \{ $tclcode \}: $err"
					msg -ERROR [namespace current] $msg 
					error $msg
					return
				}
			}
			
			# Allow using widget pathnames to retrieve canvas items (also needed for backwards compatiblity with 
			#	existing code)
			lappend tags $widget
			
			try {
				set windowname [$can create window  $rx $ry -window $widget -tags $tags -state hidden {*}$canvas_args]
			} on error err {
				set msg "can't add $type widget '$widget' in page(s) '$pages' to canvas: $err"
				msg -ERROR [namespace current] $msg
				error $msg
				return
			}
				
			# TBD: Maintain this? I don't find any use of this array in the app code
			#set ::tclwindows($widget) [list $x $y]
			#msg -INFO [namespace current] widget "$type '$main_tag' to page(s) '$pages' with args '$args'"

			if { $ns ne "" } {
				set "${ns}::widgets($main_tag)" $widget
			}			
			return $widget
		}
		
		# Add a text entry box. Adds validation and full page editor call on top of add_widget.
		#
		# Named options:
		#  -data_type if 'numeric' and -vcmd is undefined, adds validation based on the following parameters:
		#  -n_decimals number of decimals allowed. Defaults to 0 if undefined.
		#  -min minimum value accepted
		#  -max maximum value accepted
		#  -smallincrement small increment used on clicker controls. Not used by default, but is passed to page editors
		#		if the -editor_page option is specified 
		#  -bigincrement big increment used on clicker controls. Not used by default, but is passed to page editors
		#		if the -editor_page option is specified
		#  -default Default value passed to the page editor if the -editor_page option is specified
		#  -trim if 1, trims leading and trailing whitespace after editing the value. Defaults to the value of 
		#		$dui::trim_entries.
		#  -editor_page A page name that serves as a full page editor for the value, or "1" to use the default page
		#		editor if it defined for the -data_type. The first argument of that page must be the fully qualified name 
		#		of the variable that holds the value.
		proc entry { pages x y args } {
			set tags [dui::args::process_tags_and_var $pages entry -textvariable 1]
			set main_tag [lindex $tags 0]
			
			# Data type and validation
			set data_type [dui::args::get_option -data_type "text" 1]
			set n_decimals [dui::args::get_option -n_decimals 0 1]
			set trim  [dui::args::get_option -trim [dui cget trim_entries] 1]
			set editor_page [dui::args::get_option -editor_page [dui cget use_editor_pages] 1]
			set editor_page_title [dui::args::get_option -editor_page_title "" 1]
			foreach fn {min max default smallincrement bigincrement} {
				set $fn [dui::args::get_option -$fn "" 1]
			}
#			dui::args::process_font entry [dui::args::get_option -style {}]
			
			set width [dui::args::get_option -width "" 1]
			if { $width ne "" } {
				dui::args::add_option_if_not_exists -width [expr {int($width * $::globals(entry_length_multiplier))}]
			}
			
			if { ![dui::args::has_option -vcmd] } {
				set vcmd ""
				if { $data_type eq "numeric" } {
					set vcmd [list ::dui::validate_numeric %P $n_decimals $min $max]
				}
				
				if { $vcmd ne "" } {
					dui::args::add_option_if_not_exists -vcmd $vcmd
					dui::args::add_option_if_not_exists -validate key
				}
			}
					
			set widget [dui add widget entry $pages $x $y {*}$args]
		
			# Default actions on leaving a text entry: Trim text, format if needed, and hide_android_keyboard
			bind $widget <Return> { dui platform hide_android_keyboard ; focus [tk_focusNext %W] }
			
			set textvariable [dui::args::get_option -textvariable]
			if { $textvariable ne "" } {
				set leave_cmd ""
				if { $data_type in "text long_text category" } {
					if { [string is true $trim] } {
						append leave_cmd "set $textvariable \[string trim \$$textvariable\];"
					}
				} elseif { $data_type eq "numeric" } {
					append leave_cmd "if \{\$$textvariable ne \{\} \} \{ 
						set $textvariable \[format \"%%.${n_decimals}f\" \$$textvariable\] 
					\};"
				} 
				append leave_cmd "dui platform hide_android_keyboard;"
				bind $widget <Leave> $leave_cmd
			}
			
			# Invoke editor page on double tap (maybe other editors in the future, e.g. a date editor)
			if { $editor_page ne "" && ![string is false $editor_page] && $textvariable ne ""} {
				if { [string is true $editor_page] && $data_type eq "numeric" } {
					set editor_page "dui_number_editor" 
				} 
				
				if { ![string is true $editor_page] } {
					set editor_cmd [list dui page load $editor_page $textvariable -n_decimals $n_decimals -min $min \
						-max $max -default $default -smallincrement $smallincrement -bigincrement $bigincrement \
						-page_title $editor_page_title]
					set editor_cmd "if \{ \[$widget cget -state\] eq \"normal\" \} \{ $editor_cmd \}" 

					bind $widget <Double-Button-1> $editor_cmd
				}
			}
				
			return $widget
		}

		proc multiline_entry { pages x y args } {
			set tags [dui::args::process_tags_and_var $pages multiline_entry -textvariable 1]
			set main_tag [lindex $tags 0]
			
			set style [dui::args::get_option -style "" 0]
			set data_type [dui::args::get_option -data_type "text" 1]
			set trim  [dui::args::get_option -trim [dui cget trim_entries] 1]
			set editor_page [dui::args::get_option -editor_page [dui cget use_editor_pages] 1]
			set editor_page_title [dui::args::get_option -editor_page_title "" 1]
#			dui::args::process_font multiline_entry $style
			
			set width [dui::args::get_option -width "" 1]
			if { $width ne "" } {
				dui::args::add_option_if_not_exists -width [expr {int($width * $::globals(entry_length_multiplier))}]
			}
			set height [dui::args::get_option -height "" 1]
			if { $height ne "" } {
				dui::args::add_option_if_not_exists -height [expr {int($height * $::globals(listbox_length_multiplier))}]
			}

			set ysb [dui::args::get_option -yscrollbar 0 1]
			set sb_args [dui::args::extract_prefixed -yscrollbar_]
			
#			set ysb [dui::args::process_yscrollbar $pages $x $y multiline_entry $style]
#			if { $ysb != 0 && ![dui::args::has_option -yscrollcommand] } {
#				set first_page [lindex $pages 0]
#				dui::args::add_option_if_not_exists -yscrollcommand \
#					[list ::dui::item::scale_scroll $first_page $main_tag ::dui::item::sliders($first_page,$main_tag)]
#			}
							
			set widget [dui add widget multiline_entry $pages $x $y {*}$args]
		
			# Default actions on leaving a text entry: Trim text, format if needed, and hide_android_keyboard
			bind $widget <Return> { dui platform hide_android_keyboard ; focus [tk_focusNext %W] }
			
			set textvariable [dui::args::get_option -textvariable]
			if { $textvariable ne "" } {
				set leave_cmd ""
				if { $data_type in {text long_text category} && [string is true $trim] } {
					append leave_cmd "set $textvariable \[string trim \$$textvariable\];"
				} 
				append leave_cmd "dui platform hide_android_keyboard;"
				bind $widget <Leave> $leave_cmd
			}
			
			if { [string is true $ysb] || [llength $sb_args] > 0 } {
				dui add yscrollbar $pages $x $y -tags $tags -aspect_type multiline_entry_yscrollbar {*}$sb_args 
			}
			
			# Double-tapping doesn't work on multiline entries. Think of an alternative way, e.g. show a "dropdown arrow"
	#		if { $editor_page ne "" && ![string is false $editor_page] && $textvariable ne ""} {
	#			if { [string is true $editor_page] && $data_type eq "numeric" } {
	#				set editor_page "dui_number_editor" 
	#			} 
	#
	#			set editor_cmd [list dui page load $editor_page $textvariable -n_decimals $n_decimals -min $min \
	#				-max $max -default $default -smallincrement $smallincrement -bigincrement $bigincrement \
	#				-page_title $editor_page_title]
	#			set editor_cmd "if \{ \[$widget cget -state\] eq \"normal\" \} \{ $editor_cmd \}" 
	#			
	#			bind $widget <Double-Button-1> $editor_cmd
	#		}
				
			return $widget
		}

		# A text entry box with a "dropdown arrow" symbol on its right that allows to select the value from a list
		#	that opens in a new page. 
		# Extra named options:
		# 	-values  
		#	-values_ids
		#	-item_type
		#	-command: if you want to customize the page that opens when the dropdown box is clicked or the entry
		#		is double clicked. If not defined, page "dui_item_selector" is launched.
		#	-callback_cmd: the code to pass to the page that opens when the dropdown box is clicked, to run when
		#		control is returned to the combobox page.
		
		proc dcombobox { pages x y args } {
			set tags [dui::args::process_tags_and_var $pages dcombobox -textvariable 1]
			set main_tag [lindex $tags 0]
			set ns [dui page get_namespace $pages]
			set style [dui::args::get_option -style "" 0]

			set values [dui::args::get_option -values {} 1]
			#set values_ids [dui::args::get_option -values_ids {} 1]
			#set item_type [dui::args::get_option -item_type {} 1]

			set textvariable [dui::args::get_option -textvariable {} 0]
			set callback_cmd [dui::args::get_option -callback_cmd {} 1]
			if { $callback_cmd ne "" } {
#				if { $ns ne "" && [namespace which -command "${ns}::select_${main_tag}_callback"] ne "" } {
#					set callback_cmd "${ns}::select_${main_tag}_callback"
#				}
				if { $ns ne "" && [string is wordchar $callback_cmd] && [namespace which -command "${ns}::$callback_cmd"] ne "" } {
					set callback_cmd "${ns}::$callback_cmd"
				} else {
					regsub -all {%NS} $callback_cmd $ns callback_cmd
				}
			}

			set cmd [dui::args::get_option -command {} 1]
			set expand_cmd 0
			if { $cmd eq "" } {
				set cmd [list dui page load dui_item_selector]
				set expand_cmd 1
			} elseif { $ns ne "" && [string is wordchar $cmd] && [namespace which -command ${ns}::$cmd] ne "" } {
				set cmd "${ns}::$cmd"
				set expand_cmd 1
			} else {
				regsub -all {%NS} $cmd $ns cmd
				
			}
			if { $expand_cmd } {
				lappend cmd $textvariable $values
				if { $callback_cmd ne "" } {
					lappend cmd -callback_cmd $callback_cmd
				}
				foreach fn {values_ids item_type page_title listbox_width} { 
					if { [dui::args::has_option -$fn] } {
						lappend cmd -$fn [dui::args::get_option -$fn {} 1]
					}
				}
				#set cmd [list say "select" $::settings(sound_button_in) \; {*}$cmd ]
			}
#			dui::args::process_font dcombobox $style
			
			set w [dui add entry $pages $x $y -aspect_type dcombobox {*}$args]
			bind $w <Double-Button-1> $cmd
			
			# Dropdown selection arrow
			set arrow_tags [list ${main_tag}-dda {*}[lrange $tags 1 end]]
			set arrow_id [dui add symbol $pages 10000 $y -symbol sort_down -tags $arrow_tags -anchor w -justify left \
				-aspect_type dcombobox_ddarrow -command $cmd] 
			#[dui canvas] bind $arrow_id [dui platform button_press] $select_cmd
			
			bind $w <Configure> [list dui::item::relocate_text_wrt [lindex $pages 0] ${main_tag}-dda $main_tag e 20 -12 w]
#			foreach page $pages {
#				set after_show_cmd [list dui item relocate_text_wrt $page ${main_tag}-dda $main_tag e 20 -12 w]
#				dui page add_action $page show $after_show_cmd
#			}
			
#			dui add dbutton $pages [expr {$x-5}] [expr {$y+}]  -command $select_cmd  \
#				[expr {$x_widget+360}] [expr {$y_widget+68}] ]
			
			return $w
		}
		
		#  Adds a checkbox using Fontawesome symbols (which can be resized to any font size) instead of the tiny Tk 
		#	checkbutton.
		# Named options:
		#	-textvariable the name of the boolean variable to map the dcheckbox to.
		#	-command optional tcl code to run when the dcheckbox is clicked. 
		proc dcheckbox { pages x y args } {
			set tags [dui::args::process_tags_and_var $pages dcheckbox -textvariable 1]
			set main_tag [lindex $tags 0]
			
			set style [dui::args::get_option -style "" 0]
#			dui::args::process_font dcheckbox $style
			set checkvar [dui::args::get_option -textvariable "" 1]			
			set cmd [dui::args::get_option -command "" 1]
			
			#set first_page [lindex $pages 0]
			set ns [dui::page::get_namespace [lindex $pages 0]]
			if { $ns ne "" } { 
				if { [string is wordchar $cmd] && [info proc ${ns}::$cmd] ne "" } {
					set cmd ${ns}::$cmd
				}		
				regsub -all {%NS} $cmd $ns cmd
			}
			if { $checkvar ne "" } {
				set cmd "if { \[string is true \$$checkvar\] } { set $checkvar 0 } else { set $checkvar 1 }; $cmd"
			}
			dui::args::add_option_if_not_exists -label_command $cmd
			dui::args::process_label $pages $x $y dcheckbox $style
						
			dui add variable $pages $x $y -aspect_type dcheckbox -command $cmd -textvariable \
				"\[lindex \$::dui::symbol::dcheckbox_symbols_map \[string is true \$$checkvar\]\]" {*}$args
	
#			set button_tags [list ${main_tag}-btn {*}[lrange $tags 1 end]]		
#			dui add dbutton $pages [expr {$x-5}] [expr {$y-5}] [expr {$x+60}] [expr {$y+60}] ] -tags $button_tags \
#				-command $cmd
			
			return $main_tag
		}
		
		proc listbox { pages x y args } {
			set tags [dui::args::process_tags_and_var $pages listbox -listvariable 1]
			set main_tag [lindex $tags 0]
			
			set style [dui::args::get_option -style "" 0]
			set width [dui::args::get_option -width "" 1]
			if { $width ne "" } {
				dui::args::add_option_if_not_exists -width [expr {int($width * $::globals(entry_length_multiplier))}]
			}
			set height [dui::args::get_option -height "" 1]
			if { $height ne "" } {
				dui::args::add_option_if_not_exists -height [expr {int($height * $::globals(listbox_length_multiplier))}]
			}
#			dui::args::process_font listbox $style
			
			set ysb [dui::args::get_option -yscrollbar 0 1]
			set sb_args [dui::args::extract_prefixed -yscrollbar_]

#			set ysb [dui::args::process_yscrollbar $pages $x $y listbox $style]
#			if { $ysb != 0 && ![dui::args::has_option -yscrollcommand] } {
#				set first_page [lindex $pages 0]
#				dui::args::add_option_if_not_exists -yscrollcommand \
#					[list ::dui::item::scale_scroll $first_page $main_tag ::dui::item::sliders($first_page,$main_tag)]
#			}
			
			set w [dui add widget listbox $pages $x $y {*}$args]
					
			if { [string is true $ysb] || [llength $sb_args] > 0 } {
				dui add yscrollbar $pages $x $y -tags $tags -aspect_type listbox_yscrollbar {*}$sb_args 
			}
			
			return $w
		}
		
		# Adds a vertical Tk scale widget that works as a scrollbar for another widget (the one identified by the first
		#	tag in -tags) and all the code necessary to link the scrollbar to the scrolled widget.
		# This is not normally invoked directly by client code, but from other 'add' commands like 'dui add listbox'.
		# Tags should be those of the original scrolled widget.
		proc yscrollbar { pages x y args } {
			#set tags [dui::args::process_tags_and_var $pages yscrollbar -variable 0]
			set tags [dui::args::get_option -tags {} 1]
			set main_tag [lindex $tags 0]
			if { $main_tag eq "" } return
			
			set sb_tags [list ${main_tag}-ysb {*}[lrange $tags 1 end]]
			
			set var [dui::args::get_option -variable "" 1]
			set first_page [lindex $pages 0]
			if { $var eq "" } {
				set var "::dui::item::sliders($first_page,$main_tag)"
				set $var 0
			}
			set cmd [dui::args::get_option -command "" 1]
			if { $cmd eq "" } {
				set cmd "::dui::item::scrolled_widget_moveto $first_page $main_tag \$$var"
			}
			
			set aspect_type [dui::args::get_option -aspect_type {} 1]
			if { "scrollbar" ni $aspect_type } {
				lappend aspect_type scrollbar
			}
			
			set w [dui add scale $pages 10000 $y -tags $sb_tags -variable $var -aspect_type $aspect_type \
				-orient vertical -command $cmd {*}$args]
#			
			bind [dui item get_widget $pages $main_tag] <Configure> [list ::dui::item::set_yscrollbar_dim \
				[lindex $pages 0] $main_tag ${main_tag}-ysb]
			
			return $w
		}		
		
		proc scale { pages x y args } {
			set can [dui canvas]			
			set tags [dui::args::process_tags_and_var $pages scale -variable 1]
			set main_tag [lindex $tags 0]
			#set ns [dui page get_namespace $pages]

			set style [dui::args::get_option -style "" 0]
			
			dui::args::process_aspects scale $style
#			foreach a [dui aspect list -type scale -style $style] {
#				dui::args::add_option_if_not_exists -$a [dui aspect get scale $a -style $style]
#			}
#			dui::args::process_font scale $style
			
			set orient [dui::args::get_option -orient h]
			set sliderlength [dui::args::get_option -sliderlength {} 1]
			set width [dui::args::get_option -width {} 1]
			set length [dui::args::get_option -length {} 1]
			if { [string range $orient 0 0] eq "v" } {
				if { $sliderlength ne "" } {
					dui::args::add_option_if_not_exists -sliderlength [dui platform rescale_y $sliderlength]
				}
				if { $length ne "" } {
					dui::args::add_option_if_not_exists -length [dui platform rescale_y $length]
				}
				if { $width ne "" } {
					dui::args::add_option_if_not_exists -width [dui platform rescale_x $width]
				}		
			} else {
				if { $sliderlength ne "" } {
					dui::args::add_option_if_not_exists -sliderlength [dui platform rescale_x $sliderlength]
				}
				if { $length ne "" } {
					dui::args::add_option_if_not_exists -length [dui platform rescale_x $length]
				}
				if { $width ne "" } {
					dui::args::add_option_if_not_exists -width [dui platform rescale_y $width]
				}
			}
			
			set editor_page [dui::args::get_option -editor_page [dui cget use_editor_pages] 1]
			set editor_page_title [dui::args::get_option -editor_page_title "" 1]
			set n_decimals [dui::args::get_option -n_decimals "" 1]
			
			set widget [dui add widget scale $pages $x $y {*}$args]
			
			# Invoke number editor page when the label is clicked
			set label_id [$can find withtag ${main_tag}-lbl]
			set var [dui::args::get_option -variable "" 0]
			if { $editor_page ne "" && ![string is false $editor_page] && $var ne "" && $label_id ne "" } {
				if { [string is true $editor_page] } {
					set editor_page "dui_number_editor" 
				}
				
				# This code copied verbatim from 'dui add dscale'. Maybe encapsulate it somehow?
				set resolution [dui::args::get_option -resolution 1]
				if { $n_decimals eq "" } {
					set n_decimals [string length [lindex [split $resolution .] 1]]
				}
				set from [number_in_range [dui::args::get_option -from 0] 0 {} {} $resolution $n_decimals]
				set to [number_in_range [dui::args::get_option -to [expr {$from+100}]] 0 {} {} $resolution $n_decimals]
				set default [dui::args::get_option -default [expr {($from-$to)/2}]]
				set smallinc [dui::args::get_option -smallincrement $resolution]
				if { $smallinc < $resolution } {
					set smallinc $resolution
				}
				set biginc [dui::args::get_option -bigincrement [expr {($from-$to)/10}]]
				if { $biginc < $smallinc } {
					set biginc $smallinc
				}			
					
				set editor_cmd [list dui page load $editor_page $var -n_decimals $n_decimals -min $from \
					-max $to -default $default -smallincrement $smallinc -bigincrement $biginc \
					-page_title $editor_page_title]
				set editor_cmd "if \{ \[$can itemcget $label_id -state\] eq \"normal\" \} \{ $editor_cmd \}"
				$can bind $label_id [dui platform button_press] $editor_cmd
			}

			return $widget
		}

		# Creates a "new style" scale built from canvas items. Returns a list with the canvas IDs of all pieces.
		# The {x,y} coordinates give the starting position of the back line (NOT the "bounding" rectangle).
		#
		# Names of most options are defined to match those in Tk scale widget, except we use "n_decimals" instead
		#	of "digits", and we add "smallincrement" which defaults to "resolution" but can be different.
		#
		# -orient: "horizontal" (default) or "vertical"
		# -length: line length (vertical or horizontal total distance)
		# -width: width of the back lines 
		# -sliderlength: width/height or the slider circle
		# -from: minimum accepted value
		# -to: maximum accepted value
		# -variable: name of the global variable
		# -foreground: color for left/bottom line portion and circle
		# -disabledforeground
		# -background: color of the back line
		# -disabledbackground
		# -resolution: minimum step size. Defaults to 1 (integers)
		# -n_decimals: number of decimals to use when formatting the number values.
		# -smallincrement: passed to the full page number editor, and used when tapping the plus/minus. 
		#		Defaults to the same value as -resolution, if not specified.
		# -bigincrement: passed to the full page number editor, and used when tapping repeteadly the plus/minus.
		# -plus_minus: 0 or 1 (default) to hide/show the plus and minus on the extremes.
		# -default: default value when the variable is empty (used only by the page editor to assign an initial value
		#	if we start from an empty string)
		# -editor_page: 0, 1 (=use default number editor), or an editor page name.
		# -editor_page_title: the page title to show on the page editor 
		proc dscale { pages x y args } {
			set can [dui canvas]			
			set tags [dui::args::process_tags_and_var $pages dscale -variable 1]
			set main_tag [lindex $tags 0]
			set ns [dui page get_namespace $pages]
												
			set style [dui::args::get_option -style "" 0]
			dui::args::process_aspects dscale $style ""
			set label_id [dui::args::process_label $pages $x $y dscale $style ${main_tag}-bck]
			set var [dui::args::get_option -variable "" 1]
			set orient [string range [dui::args::get_option -orient horizontal] 0 0]
			
			set resolution [dui::args::get_option -resolution 1]
			set n_decimals [dui::args::get_option -n_decimals ""]
			if { $n_decimals eq "" } {
				set n_decimals [string length [lindex [split $resolution .] 1]]
			}
			set from [number_in_range [dui::args::get_option -from 0] 0 {} {} $resolution $n_decimals]
			set to [number_in_range [dui::args::get_option -to [expr {$from+100}]] 0 {} {} $resolution $n_decimals]
			set default [dui::args::get_option -default [expr {($from-$to)/2}]]
			set smallinc [dui::args::get_option -smallincrement $resolution]
			if { $smallinc < $resolution } {
				set smallinc $resolution
			}
			set biginc [dui::args::get_option -bigincrement [expr {($from-$to)/10}]]
			if { $biginc < $smallinc } {
				set biginc $smallinc
			}			
			
			set width [dui::args::get_option -width 8]
			set length [dui::args::get_option -length 300]
			set sliderlength [dui::args::get_option -sliderlength 25]
			set foreground [dui::args::get_option -foreground blue]
			set disabledforeground [dui::args::get_option -disabledforeground grey]
			set background [dui::args::get_option -background grey]
			set disabledbackground [dui::args::get_option -disabledforeground grey]
			set plus_minus [string is true [dui::args::get_option -plus_minus 1]]
			set pm_length 0
			
			set x [dui platform rescale_x $x]
			set y [dui platform rescale_y $y]
			set moveto_cmd [list dui::item::dscale_moveto [lindex $pages 0] $main_tag $var $from $to $resolution $n_decimals]
			if { $orient eq "v" } {
				# VERTICAL SCALE
				if { $plus_minus } {
					set pm_length [dui platform rescale_y 40]
				}
				set length [dui platform rescale_y $length]
				set sliderlength [dui platform rescale_y $sliderlength]
				set pm_length [dui platform rescale_y $pm_length]
				set width [dui platform rescale_x $width]
				set x1 $x
				set y [expr {$y+$pm_length}]
				set y1 [expr {$y+$length-$pm_length*2}]
				set yf [expr {$y1-$sliderlength/2}]
				lappend moveto_cmd %y

				if { $plus_minus } {
					set id [$can create text $x [expr {$y-$pm_length*2/3}] -text "+" -anchor s -justify center \
						-font [dui font get notosansuiregular 16] -fill $foreground -disabledfill $disabledforeground \
						-tags [list ${main_tag}-inc {*}$tags] -state hidden]
					lappend ids $id
					if { $ns ne "" } {
						set "${ns}::widgets(${main_tag}-inc)" $id
					}							
					set id [$can create rect [expr {$x-$sliderlength}] [expr {$y-$pm_length-10}] [expr {$x+$sliderlength/2}] $y \
						-fill {} -width 0 -tags [list ${main_tag}-tinc {*}$tags] -state hidden]					
					$can bind ${main_tag}-tinc [dui platform button_press] [list set_var_in_range $var {} \
						$smallinc $from $to $resolution $n_decimals]
					$can bind ${main_tag}-tinc <Triple-ButtonPress-1> [list set_var_in_range $var {} \
						$biginc $from $to $resolution $n_decimals]
					lappend ids $id
					if { $ns ne "" } {
						set "${ns}::widgets(${main_tag}-tinc)" $id
					}
					
					set id [$can create text $x [expr {$y1+$pm_length*1/3}] -text "-" -anchor n -justify center \
						-font [dui font get notosansuiregular 18] -fill $foreground -disabledfill $disabledforeground \
						-tags [list ${main_tag}-dec {*}$tags] -state hidden]
					lappend ids $id
					if { $ns ne "" } {
						set "${ns}::widgets(${main_tag}-dec)" $id
					}											
					set id [$can create rect [expr {$x-$sliderlength/2}] $y1 [expr {$x+$sliderlength/2}] [expr {$y1+$pm_length+10}] \
						-fill {} -width 0 -tags [list ${main_tag}-tdec {*}$tags] -state hidden]
					$can bind ${main_tag}-tdec [dui platform button_press] [list set_var_in_range $var {} \
						-$smallinc $from $to $resolution $n_decimals ]
					$can bind ${main_tag}-tdec <Triple-ButtonPress-1> [list set_var_in_range $var {} \
						-$biginc $from $to $resolution $n_decimals]
					lappend ids $id
					if { $ns ne "" } {
						set "${ns}::widgets(${main_tag}-tdec)" $id
					}
				}
				
				# Vertical back line
				set id [$can create line $x $y $x $y1 -width $width -fill $background -disabledfill $disabledbackground \
					-capstyle round -tags [list ${main_tag}-bck {*}$tags] -state hidden]
				lappend ids $id
				if { $ns ne "" } {
					set "${ns}::widgets(${main_tag}-bck)" $id
				}
				# Vertical front line (from min on the bottom to variable value)
				set id [$can create line $x $yf $x $y1 -width $width -fill $foreground -disabledfill $disabledforeground \
					-capstyle round -tags [list ${main_tag}-frn {*}$tags] -state hidden]
				lappend ids $id
				if { $ns ne "" } {
					set "${ns}::widgets(${main_tag}-frn)" $id
				}			
				# Vertical "clickable" rectangle. Use the "bounding" box that contains both lines and circle. 
				set id [$can create rect [expr {$x-$sliderlength/2}] $y [expr {$x+$sliderlength/2}] $y1 -fill {} -width 0 \
					-tags [list ${main_tag}-tap {*}$tags] -state hidden]			
				$can bind ${main_tag}-tap [dui platform button_press] $moveto_cmd
				lappend ids $id
				if { $ns ne "" } {
					set "${ns}::widgets(${main_tag}-tap)" $id
				}
				# Vertical circle slider
				set id [$can create oval [expr {$x-$sliderlength/2}] [expr {$yf-$sliderlength/2}] \
					[expr {$x+$sliderlength/2}] [expr {$yf+$sliderlength/2}] -fill $foreground \
					-disabledfill $disabledforeground -width 0 -tags [list {*}$tags ${main_tag}-crc] -state hidden] 
				$can bind ${main_tag}-crc <B1-Motion> $moveto_cmd
				lappend ids $id			
				if { $ns ne "" } {
					set "${ns}::widgets(${main_tag}-crc)" $id
					set "${ns}::widgets($main_tag)" $ids
				}								
			} else {
				# HORIZONTAL SCALE
				if { $plus_minus } {
					set pm_length [dui platform rescale_x 40]
				}				
				set length [dui platform rescale_x $length]
				set sliderlength [dui platform rescale_x $sliderlength]
				set width [dui platform rescale_y $width]
				set x [expr {$x+$pm_length}]
				set x1 [expr {$x+$length-$pm_length*2}]
				set x1f [expr {$x+$sliderlength/2}]
				set y1 $y
				set y1f $y
				lappend moveto_cmd %x
				
				if { $plus_minus } {
					set id [$can create text [expr {$x-$pm_length}] [expr {$y-3}] -text "-" -anchor w -justify left  \
						-font [dui font get notosansuiregular 18] -fill $foreground -disabledfill $disabledforeground \
						-tags [list ${main_tag}-dec {*}$tags] -state hidden]
					lappend ids $id
					if { $ns ne "" } {
						set "${ns}::widgets(${main_tag}-dec)" $id
					}							
					set id [$can create rect [expr {$x-$pm_length-20}] [expr {$y-$sliderlength/2}] $x [expr {$y+$sliderlength/2}] \
						-fill {} -width 0 -tags [list ${main_tag}-tdec {*}$tags] -state hidden]					
					$can bind ${main_tag}-tdec [dui platform button_press] [list set_var_in_range $var {} \
						-$smallinc $from $to $resolution $n_decimals]
					$can bind ${main_tag}-tdec <Triple-ButtonPress-1> [list set_var_in_range $var {} \
						-$biginc $from $to $resolution $n_decimals]
					lappend ids $id
					if { $ns ne "" } {
						set "${ns}::widgets(${main_tag}-tdec)" $id
					}							
					
					set id [$can create text [expr {$x1+$pm_length}] [expr {$y-1}] -text "+" -anchor e -justify right -font [dui font get notosansuiregular 16] \
						-fill $foreground -disabledfill $disabledforeground -tags [list ${main_tag}-inc {*}$tags] \
						-state hidden]
					lappend ids $id
					if { $ns ne "" } {
						set "${ns}::widgets(${main_tag}-inc)" $id
					}											
					set id [$can create rect $x1 [expr {$y-$sliderlength/2}] [expr {$x1+$pm_length+20}] [expr {$y+$sliderlength/2}] \
						-fill {} -width 0 -tags [list ${main_tag}-tinc {*}$tags] -state hidden]
					$can bind ${main_tag}-tinc [dui platform button_press] [list set_var_in_range $var {} \
						$smallinc $from $to $resolution $n_decimals ]
					$can bind ${main_tag}-tinc <Triple-ButtonPress-1> [list set_var_in_range $var {} \
						$biginc $from $to $resolution $n_decimals]
					lappend ids $id
					if { $ns ne "" } {
						set "${ns}::widgets(${main_tag}-tinc)" $id
					}
				}
				
				# Horizontal back line
				set id [$can create line $x $y $x1 $y1 -width $width -fill $background -disabledfill $disabledbackground \
					-capstyle round -tags [list ${main_tag}-bck {*}$tags] -state hidden]
				lappend ids $id
				if { $ns ne "" } {
					set "${ns}::widgets(${main_tag}-bck)" $id
				}
				# Horizontal front line (from min on the left to variable value)
				set id [$can create line $x $y $x1f $y1f -width $width -fill $foreground -disabledfill $disabledforeground \
					-capstyle round -tags [list ${main_tag}-frn {*}$tags] -state hidden]
				lappend ids $id
				if { $ns ne "" } {
					set "${ns}::widgets(${main_tag}-frn)" $id
				}			
				# Horizontal "clickable" rectangle. Use the "bounding" box that contains both lines and circle. 
				set id [$can create rect  $x [expr {$y-$sliderlength/2}] $x1 [expr {$y1+$sliderlength/2}] -fill {} -width 0 \
					-tags [list ${main_tag}-tap {*}$tags] -state hidden]			
				$can bind ${main_tag}-tap [dui platform button_press] $moveto_cmd
				lappend ids $id
				if { $ns ne "" } {
					set "${ns}::widgets(${main_tag}-tap)" $id
				}
				# Horizontal circle slider
				set id [$can create oval [expr {$x1f-($sliderlength/2)}] [expr {$y1f-($sliderlength/2)}] \
					[expr {$x1f+($sliderlength/2)}] [expr {$y1f+($sliderlength/2)}] -fill $foreground \
					-disabledfill $disabledforeground -width 0 -tags [list {*}$tags ${main_tag}-crc] -state hidden] 
				$can bind ${main_tag}-crc <B1-Motion> $moveto_cmd
				lappend ids $id			
				if { $ns ne "" } {
					set "${ns}::widgets(${main_tag}-crc)" $id
					set "${ns}::widgets($main_tag)" $ids
				}
			}
			
			set update_cmd [lreplace $moveto_cmd end end ""]
			trace add variable $var write $update_cmd
			# Force initializing the slider position
			dui page add_action $pages show $update_cmd
			
			# Invoke number editor page when the label is clicked
			set editor_page [dui::args::get_option -editor_page [dui cget use_editor_pages]]
			if { $editor_page ne "" && ![string is false $editor_page] && $var ne "" && $label_id ne "" } {
				if { [string is true $editor_page] } {
					set editor_page "dui_number_editor" 
				}
				set editor_page_title [dui::args::get_option -editor_page_title]
				set editor_cmd [list dui page load $editor_page $var -n_decimals $n_decimals -min $from \
					-max $to -default $default -smallincrement $smallinc -bigincrement $biginc \
					-page_title $editor_page_title]
				set editor_cmd "if \{ \[$can itemcget $label_id -state\] eq \"normal\" \} \{ $editor_cmd \}"
				$can bind $label_id [dui platform button_press] $editor_cmd
			}
			
			return $ids
		}
				
		# Adds a "rater" made of clickable stars (or other symbol). Maps to any existing INTEGER variable.
		# Named options:
		#	-variable, the name of the global variable with the rating. 
		#	-symbol, default "star"
		#	-n_ratings, default 5
		#	-use_halfs, default 1
		#	-min, default 0
		#	-max, default 10
		proc drater { pages x y args } {
			set ids {}
			set tags [dui::args::process_tags_and_var $pages drater -variable 1 args 0]
			set main_tag [lindex $tags 0]
			set ns [dui page get_namespace $pages]
			
			set ratingvar [dui::args::get_option -variable "" 1]
			if { ![info exists $ratingvar] } { set $ratingvar {} }
			
			set style [dui::args::get_option -style "" 0]
			dui::args::process_aspects drater $style ""
			set label_id [dui::args::process_label $pages $x $y drater $style ${main_tag}-btn]
			
			set use_halfs [string is true [dui::args::get_option -use_halfs 1 1]]
			set symbol [dui::args::get_option -symbol "star" 1]
			if { $use_halfs == 1 } {
				if { [dui symbol exists "half_$symbol"] } {
					set half_symbol [dui symbol get "half_$symbol"]
				} else {
					set half_symbol [dui symbol get half_star]
				}
			}		
			if { [dui symbol exists $symbol] } {
				set symbol [dui symbol get $symbol]
			} else {
				set symbol [dui symbol get star]
			}

			set n_ratings [dui::args::get_option -n_ratings 5 1]
			set min [dui::args::get_option -min 0 1]
			set max [dui::args::get_option -max 10 1]
			set width [dui::args::get_option -width 500 1]
			dui::args::remove_options {-anchor -justify -tags}
			
			set space [expr {$width / $n_ratings}]	
			for { set i 1 } { $i <= $n_ratings } { incr i } {
				set star_tags [list ${main_tag}-$i $main_tag {*}[lrange $tags 1 end]]
				set half_star_tags [list ${main_tag}-h$i $main_tag {*}[lrange $tags 1 end]]
				
				set id [dui add symbol $pages [expr {$x+$space/2+$space*($i-1)}] [expr {$y+25}] -symbol $symbol \
						-anchor center -justify center -tags $star_tags -aspect_type drater {*}$args]
				lappend ids $id
				if { $use_halfs == 1 } {
					set id [dui add symbol $pages [expr {$x+$space/2+$space*($i-1)}] [expr {$y+25}] -symbol $half_symbol \
						-anchor center -justify center -tags $half_star_tags -aspect_type drater {*}$args]
					lappend ids $id
				}
			}
		
			set rating_cmd [list ::dui::item::drater_clicker $ratingvar %x %y %%x0 %%y0 %%x1 %%y1 \
				$n_ratings $use_halfs $min $max]				
			set button_tags [list ${main_tag}-btn {*}[lrange $tags 1 end]]
			set id [dui add dbutton $pages $x [expr {$y-15}] [expr {$x+$width}] [expr {$y+70}] -command $rating_cmd \
				-tags $button_tags]
			lappend ids $id
						
			set draw_cmd [list ::dui::item::drater_draw [lindex $pages 0] $main_tag $ratingvar $n_ratings $use_halfs $min $max]
			trace add variable $ratingvar write $draw_cmd
			# Force drawing the stars correctly whenever we show the page (as all stars are shown in normal state 
			#	when the page is shown).
			foreach page $pages {
				dui page add_action $page show $draw_cmd
			}
			if { $ns ne "" } {
				set ${ns}::widgets($main_tag) $ids
			}
			
			return $ids
		}

		proc graph { pages x y args } {
#			set tags [dui::args::process_tags_and_var $pages graph {} 1]
#			set main_tag [lindex $tags 0]
			
			#set style [dui::args::get_option -style "" 0]
			set width [dui::args::get_option -width "" 1]
			if { $width ne "" } {
				dui::args::add_option_if_not_exists -width [dui platform rescale_x $width]
			}
			set height [dui::args::get_option -height "" 1]
			if { $height ne "" } {
				dui::args::add_option_if_not_exists -height [dui platform rescale_y $height]
			}
#			dui::args::process_font listbox $style
			
			return [dui add widget graph $pages $x $y {*}$args]
			
		}
	}
	
	### INITIALIZE ###
		
	### GENERAL TOOLS ###
	
	# Command to invoke from the -vcmd option to validate numeric entries, with -validate key.
	# Returns 1 if empty or a valid numeric value in the requested range, 0 otherwise.
	# Trims leading zeros to avoid octal arithmetic.
	proc validate_numeric { value {n_decimals 0} {min_value {}} {max_value {}} } {
		set value [string trimleft $value 0]
		if { $value eq {} } {
			return 1
		}
		if { $value eq "." && $n_decimals > 0 } {
			return 1
		}
		if { $value eq "-" } {
			return [expr {($min_value eq "" || ([string is double $min_value] && $min_value < 0))}]
		}
		
		if { $n_decimals eq "" || $n_decimals == 0 } {
			if { ![string is entier $value] } {
				return 0
			}			
		} elseif { ![string is double $value] } {
			return 0
		} else {
			set parts [split $value .]
			set dec_part ""
			if { [llength $parts] > 1 } {
				set dec_part [lindex $parts 1]
			} 
			if { $dec_part ne "" && [string length $dec_part] > $n_decimals } {
				return 0
			}
		}
		
		if { $min_value ne "" && [string is double $min_value] && $value < $min_value } {
			return 0
		}
		if { $max_value ne "" && [string is double $max_value] && $value > $max_value } {
			return 0
		}
		return 1
	}
	

}


# General utilities (TO BE MOVED TO de1_utils.tcl or similar)
# Returns the list with duplicates removed, keeping the original list sorting of elements, unlike 'lsort -unique'.
# See discussion in https://wiki.tcl-lang.org/page/Unique+Element+List
proc lunique {list} {
	set new {}
	foreach item $list {
		if { $item ni $new } {
			lappend new $item
		}
	}
	return $new
}

# Sets or changes a numeric value within a valid range, using the given resolution, and formats it 
#	with the given number of decimals.
# This is normally used from scales or clickers.
proc number_in_range { {value 0} {change 0} {min {}} {max {}} {resolution 0} {n_decimals {}} } {
	if { $value eq "" || ![string is double $value] } {
		if { $min ne "" } {
			set newvalue $min
		} elseif { $max ne "" && $max >= 0 } {
			set newvalue 0
		} else {
			set newvalue $max
		}
	} else {
		set newvalue $value
	} 
	if { $change ne "" && $change != 0 } {
		set newvalue [expr {$newvalue+$change}]
	}
	if { $min ne "" && $newvalue < $min } {
		set newvalue $min
	} 
	if { $max ne "" && $newvalue > $max } {
		set newvalue $max
	} 
	if { $resolution ne "" && $resolution != 0 } {
		set newvalue [expr {int($newvalue/$resolution)*$resolution}]
	}
	if { $n_decimals ne "" } {
		set newvalue [format "%.${n_decimals}f" $newvalue]
	}
	return $newvalue
}

# Sets or changes a global variable value using the parameters specified by proc 'change_in_range'.
# Takes the same arguments as 'number_in_range. If 'value' is undefined, uses the current value of the variable.
# This is normally used from scales or clickers.
proc set_var_in_range { variable {value {}} args } {
	if { $value eq "" } {
		set value [ifexists $variable 0]
	}
	set $variable [number_in_range $value {*}$args]
}

# A one-liner to return a default if a variable is undefined.
# Similar to ifexists in updater.tcl but does not set var (only returns the new value), and assigns empty values.
proc value_or_default { var {default {}} } {
	upvar $var thevar
	
	if { [info exists thevar] } {
		return [subst "\$thevar"]
	} else {
		return $default
	}
}

### FULL-PAGE EDITORS ################################################################################################

### PAGES SUB-ENSEMBLE ###
# Just a container namespace for client code to create UI pages as children namespaces.
namespace eval ::dui::pages {
	namespace export *
	namespace ensemble create
}

namespace eval ::dui::pages::dui_number_editor {
	variable widgets
	array set widgets {}
		
	variable data
	array set data {		
		previous_page {}
		callback_cmd {}
		page_title {}
		num_variable {}
		value {}
		min {}
		max {}
		default {}
		n_decimals {}
		smallincrement {}
		bigincrement {}
		previous_values {}
	}

	proc setup {} {
		variable data 
		variable widgets
		set page [namespace tail [namespace current]]
		
		# Page and title
		#dui page add $page -namespace 1
		dui add variable $page 1280 100 -tags page_title -style page_title
		
		# Insight-style background shapes
		dui add canvas_item rect $page 10 190 2550 1430 -style insight_back_box
		dui add canvas_item line $page 14 188 2552 189 -style insight_back_box_shadow
		dui add canvas_item line $page 2551 188 2552 1426 -style insight_back_box_shadow

		dui add canvas_item rect $page 22 210 1270 600 -style insight_front_box
		dui add canvas_item rect $page 22 620 1270 1410 -style insight_front_box
		dui add canvas_item rect $page 1290 210 2536 1410 -style insight_front_box
		
		# Value being edited. Use the center coordinates of the text entry as reference for the whole row.
		set x 625; set y 390
		dui add entry $page $x $y -tags value -width 6 -data_type numeric -font_size +6 -canvas_anchor center \
			-justify center
				
		# Increment/decrement clicker buttons style
		dui aspect set -style dne_clicker {dbutton.shape round dbutton.bwidth 120 dbutton.bheight 140 
			dbutton.radius 20 dbutton.anchor center
			dbutton_symbol.pos {0.5 0.4} dbutton_symbol.anchor center dbutton_symbol.font_size 20
			dbutton_label.pos {0.5 0.8} dbutton_label.font_size 10 dbutton_label.anchor center}
		
		# Decrement value arrows		
		set hoffset 45; set bspace 140
		dui add dbutton $page [expr {$x-$hoffset-$bspace}] $y -tags small_decr -style dne_clicker \
			-symbol chevron_left -labelvariable {-[format [%NS::value_format] $%NS::data(smallincrement)]} \
			-command { %NS::incr_value -$%NS::data(smallincrement) }
		
		dui add dbutton $page [expr {$x-$hoffset-$bspace*2}] $y -tags big_decr -style dne_clicker \
			-symbol chevron_double_left -labelvariable {-[format [%NS::value_format] $%NS::data(bigincrement)]} \
			-command { %NS::incr_value -$%NS::data(bigincrement) } 

		dui add dbutton $page [expr {$x-$hoffset-$bspace*3}] $y -tags to_min -style dne_clicker \
			-symbol arrow_to_left -labelvariable {[format [%NS::value_format] $%NS::data(min)]} \
			-command { %NS::set_value -$%NS::data(min) } 

		# Increment value arrows
		dui add dbutton $page [expr {$x+$hoffset+$bspace}] $y -tags small_incr -style dne_clicker \
			-symbol chevron_right -labelvariable {+[format [%NS::value_format] $%NS::data(smallincrement)]} \
			-command { %NS::incr_value $%NS::data(smallincrement) }
			
		dui add dbutton $page [expr {$x+$hoffset+$bspace*2}] $y -tags big_incr -style dne_clicker \
			-symbol chevron_double_right -labelvariable {+[format [%NS::value_format] $%NS::data(bigincrement)]} \
			-command { %NS::incr_value $%NS::data(bigincrement) } 
	
		dui add dbutton $page [expr {$x+$hoffset+$bspace*3}] $y -tags to_max -style dne_clicker \
			-symbol arrow_to_right -labelvariable {[format [%NS::value_format] $%NS::data(max)]} \
			-command { %NS::set_value $%NS::data(max) } 
		
		# Erase button
		#		dui add symbol $page $x_left_center [expr {$y+140}] eraser -size medium -has_button 1 \
		#			-button_cmd { set ::dui::pages::dui_number_editor::data(value) "" }
		
#		# Previous values listbox
		dui add listbox $page 450 780 -tags previous_values -canvas_width 350 -canvas_height 550 -yscrollbar 1 \
			-label [translate "Previous values"] -label_style section_font_size -label_pos {450 700} -label_anchor nw 
		bind $widgets(previous_values) <<ListboxSelect>> ::dui::pages::dui_number_editor::previous_values_select
		
#		# Numeric type pad
		dui aspect set -style dne_pad_button {dbutton.shape round dbutton.bwidth 280 dbutton.bheight 220 
			dbutton.radius 20 dbutton.anchor nw
			button_label.pos {0.5 0.5} button_label.font_family notosansuibold 
			button_label.font_size 24 button_label.anchor center}
		
		set x_base 1425; set y_base 290
		set width 280; set height 220; set hspace 80; set vspace 60
		set row 0; set col 0
		
		foreach line { {7 8 9} {4 5 6} {1 2 3} {Del 0 .} } {
			foreach num $line {
				set x [expr {$x_base+$col*($width+$hspace)}]
				set y [expr {$y_base+$row*($height+$vspace)}]
				if { $num eq "." } {
					set tag "num_dot"
				} else {
					set tag "num$num"
				}
				
				dui add dbutton $page $x $y [expr {$x+$width}] [expr {$y+$height}] -tags $tag -style dne_pad_button \
					-label "$num" -command [list %NS::enter_character $num] 
				
				incr col
			}
			set col 0
			incr row
		}

		# Ok and Cancel buttons
		dui add dbutton $page 750 1460 -tags page_cancel -style insight_ok -label [translate Cancel]
		dui add dbutton $page 1330 1460 -tags page_done -style insight_ok -label [translate Ok]
	}
	
	# Accepts any of the named options -page_title, -callback_cmd, -min, -max, -n_decimals, -default, -smallincrement  
	#	and -bigincrement. If any from -min on is not defined or an empty string, the page does not load.
	proc load { page_to_hide page_to_show num_variable args } {
		variable data
		array set opts $args
		set page [namespace tail [namespace current]]
			
		set data(num_variable) $num_variable 
		if { $data(num_variable) eq "" } {
			msg -WARN [namespace current] load: "num_variable is required"
			return 0
		}
		if { ![info exists $num_variable] } {
			set $num_variable ""
		}
		
		set data(previous_page) $page_to_hide
		
		set fields {page_title callback_cmd previous_values default min max n_decimals smallincrement bigincrement}
		foreach fn $fields {
			set data($fn) [ifexists opts(-$fn)]
		}
		foreach fn [lrange $fields 4 end] {
			if { $data($fn) eq "" } {
				msg -WARN [namespace current] load: "-$fn is required"
				return 0
			}
		}
		if { $data(max) <= $data(min) } {
			msg -WARN [namespace current] load: "max ($data(max)) must be bigger than min ($data(min))"
			return 0			
		}
		
		if { $data(page_title) eq "" } {
			set data(page_title) [translate "Edit number"]
		}
		if { $data(default) eq "" } {
			set data(default) $data(min)
		}
		
		return 1
	}
	
	proc show { page_to_hide page_to_show } {
		variable data
		set page [namespace tail [namespace current]]
		dui item enable_or_disable [expr {$data(n_decimals)>0}] $page "num_dot*"
		dui item enable_or_disable [expr {[llength $data(previous_values)]>0}] $page "previous_values*"
	
		if { $data(num_variable) ne "" && [subst \$$data(num_variable)] ne "" } {
			# Without the delay, the value is not selected. Tcl misteries...
			after 10 ::dui::pages::dui_number_editor::set_value [subst \$$data(num_variable)]
		}	
	}
	
	proc value_format {} {
		variable data
		return "%.$data(n_decimals)f"
	}
	
	proc set_value { new_value } {
		variable data
		if { $new_value ne "" } {
			if { $new_value != 0 } { set new_value [string trimleft $new_value 0] } 
			set new_value [format [value_format] $new_value]
		}
		set data(value) $new_value
		value_change
		select_value
	}
	
	proc select_value {} {
		variable widgets
		focus $widgets(value)
		$widgets(value) selection range 0 end 
	}
	
	proc value_change {} {
		variable data 
		variable widgets
		set widget $widgets(value)
		
		if { $data(value) ne "" } {
			if { $data(min) ne "" && $data(value) < $data(min) } {
				$widget configure -foreground [dui aspect get text fill -style error]
			} elseif { $data(max) ne "" && $data(value) > $data(max) } {
				$widget configure -foreground [dui aspect get text fill -style error]
			} else {
				$widget configure -foreground [dui aspect get text fill]
			}
		}
	}
	
	proc enter_character { char } {
		variable data
		variable widgets
		set widget $widgets(value)
		
		set max_len [string length [expr round($data(max))]]
		if { $data(n_decimals) > 0 } { 
			incr max_len [expr {$data(n_decimals)+1}] 
		}
	
		set idx -1
		catch { set idx [$widget index sel.first] }
		#[selection own] eq $widget
		if { $idx > -1 } {
			set idx_last [$widget index sel.last]
			if { $char eq "Del" } {
				set data(value) "[string range $data(value) 0 [expr {$idx-1}]][string range $data(value) $idx_last end]"
			} else {
				set data(value) "[string range $data(value) 0 [expr {$idx-1}]]$char[string range $data(value) $idx_last end]"
			}
			selection own $widget
			$widget selection clear
			$widget icursor [expr {$idx+1}]
		} else {	
			set idx [$widget index insert]
			if { $char eq "Del" } {
				set data(value) "[string range $data(value) 0 [expr {$idx-2}]][string range $data(value) $idx end]"
				if { $idx > 0 } { $widget icursor [expr {$idx-1}] }
			} elseif { [string length $data(value)] < $max_len } {
				$widget insert $idx $char
			}
		}
		
		set data(value) [string trimleft $data(value) 0]
		value_change
	}
	
	proc incr_value { incr } {
		variable data	
		
		if { $data(value) eq "" } {
			if { $data(default) ne "" } {
				set value $data(default)
			} elseif { $data(min) ne "" && $data(max) ne "" } {
				set value [expr {($data(max)-$data(min))/2}]
			} else {
				set value 0
			}
		} else {
			set value $data(value)
		}
	
		set new_value [expr {$value + $incr}]
		if { $data(min) ne "" && $new_value < $data(min) } {
			set new_value $data(min)
		} 
		if { $data(max) ne "" && $new_value > $data(max) } {
			set new_value $data(max)
		}
		
		set new_value [format [value_format] $new_value]
		if { $new_value != $data(value) } {
			set_value $new_value
		}
	}
	
	proc previous_values_select {} {
		variable widgets		
		set new_value [dui item listbox_get_selection $widgets(previous_values)]
		if { $new_value ne "" } { 
			set_value $new_value 
		}
	}
	
	proc page_cancel {} {
		variable data
		if { $data(callback_cmd) ne "" } {
			$data(callback_cmd) {}
		} else {
			dui page show $data(previous_page)
		}
	}
	
	proc page_done {} {
		variable data
		set fmt [value_format]
		
		if { $data(value) ne "" } {
			if { $data(value) < $data(min) } {
				set data(value) [format $fmt $data(min)]
			} elseif { $data(value) > $data(max) } {
				set data(value) [format $fmt $data(max)]
			} else {
				if { $data(value) > 0 } { set data(value) [string trimleft $data(value) 0] }
				set data(value) [format $fmt $data(value)]
			}
		}
		
		if { $data(num_variable) ne "" } {
			set $data(num_variable) $data(value)
		}
		
		if { $data(callback_cmd) ne "" } {
			$data(callback_cmd) $data(value)
		} else {
			dui page show $data(previous_page)
		}
	}
}

namespace eval ::dui::pages::dui_item_selector {
	variable widgets
	array set widgets {}
	
	# NOTE that we use "item_values" to hold all available items, not "items" as the listbox widget, as we need
	# to have the full list always stored. So the "items" listbox widget does not have a list_variable but we
	# directly add to it, and it may contain a filtered version of "item_values".	
	variable data
	array set data {
		previous_page {}
		callback_cmd {}
		page_title {}
		variable {} 
		item_type {}
		selectmode browse
		filter_string {}
		filter_indexes {}
		item_ids {}
		item_values {}
		empty_items_msg {}
		listbox_width 1775
	}
		
	proc setup {} {
		variable widgets
		variable data
		set page [namespace tail [namespace current]]
		set font_size +1
		
		# Page and title
		#dui page add $page -namespace 1
		dui add variable $page 1280 100 -tags page_title -style page_title
		
		# Insight-style background shapes
		dui add canvas_item rect $page 10 190 2550 1430 -style insight_back_box
		dui add canvas_item line $page 14 188 2552 189 -style insight_back_box_shadow
		dui add canvas_item line $page 2551 188 2552 1426 -style insight_back_box_shadow
		dui add canvas_item rect $page 22 210 2536 1410 -style insight_front_box
		
		# Items search entry box
		dui add entry $page 1280 250 -tags filter_string -canvas_width $data(listbox_width) -canvas_anchor n \
			-font_size $font_size -label [translate Filter] -label_pos {wn -20 3} -label_anchor ne \
			-label_justify right -label_font_size $font_size 
		bind $widgets(filter_string) <KeyRelease> ::dui::pages::dui_item_selector::filter_string_change 
		
		# Empty category message
		dui add variable $page 1280 750 -tags empty_items_msg -style remark -font_size +2 -anchor center \
			-justify "center" -state hidden
	
		# Items listbox: Don't use $data(items) as listvariable, as the list changes dynamically with the filter string!
		dui add listbox $page 1280 350 -tags items -listvariable {} -canvas_width $data(listbox_width) -canvas_height 1000 \
			-canvas_anchor n -font_size $font_size -label [translate "Values"] -label_pos {wn -20 3} \
			-label_anchor ne -label_justify right -label_font_size $font_size -yscrollbar 1
		
		bind $widgets(items) <<ListboxSelect>> ::dui::pages::dui_item_selector::items_select
		bind $widgets(items) <Double-Button-1> ::dui::pages::dui_item_selector::page_done
				
		# Ok and Cancel buttons
		dui add dbutton $page 750 1460 -tags page_cancel -style insight_ok -label [translate Cancel]
		dui add dbutton $page 1330 1460 -tags page_done -style insight_ok -label [translate Ok]
	}
	
	# Named options:
	#	-page_title
	#	-category_name: an optional string to identify the type of data being edited. This is occasionally useful when
	#		passed to a callback command, so that a single callback can be used for several item types.
	#	-values_ids: use this to assign a lookup value that identifies the selected item, such as a unique ID.
	#	-callback_cmd: an optional command to be executed when control is returned to the calling page (i.e. when "Ok" of "Cancel" are clicked). 
	#		It must be a function with three arguments {item_id item_value item_type} that processes the result and moves 
	#		to the source page (or somewhere else). 
	#	-selected: list of items to be selected when the page is open. If some of them is not in 'items', it is appended
	#		to the list. If not specified, uses the curent value of -variable.
	#	-selectmode: single, browse, multiple or extended.
	#	-empty_items_msg: text to show if there are no items to select.
	#	-listbox_width: the width in pixels of the filter entry and the items listbox.
	
	proc load { page_to_hide page_to_show variable values args } {
		variable data
		variable widgets
		array set opts $args

		if { $page_to_hide eq "" } {
			msg -WARN [namespace current] load "NO PAGE TO HIDE"
		}
		set data(previous_page) $page_to_hide
		set data(page_title) [ifexists opts(-page_title) [translate "Select an item"]]
				
		# If no selected is given, but variable is given and it has a current value, use it as selected.
		set data(variable) $variable
		set selected [ifexists opts(-selected) ""]
		if { $variable ne "" && $selected eq "" && [subst "\$$variable"] ne "" } {
			set selected [subst "\$$data(variable)"]
		}	
		# Add the current/selected value if not included in the list of available items
		set values [subst $values]
		set data(item_ids) [ifexists opts(-values_ids)]
		if { $selected ne "" } {
			if { $selected ni $values } {
				if { [llength $data(item_ids)] > 0 } { 
					lappend data(item_ids) -1 
				}
				lappend values $selected
			}
		}
		set data(item_values) $values		
		set data(item_type) [ifexists opts(-category_name)]
		set data(callback_cmd) [ifexists opts(-callback_cmd)]
		set data(selectmode) [ifexists opts(-selectmode) "browse"]
		set data(empty_items_msg) [ifexists opts(-empty_items_msg) [translate "There are no available items to show"]]
		set data(listbox_width) [number_in_range [ifexists opts(-listbox_width) 1775] {} 200 2100 {} 0]
		set data(filter_string) {}
		set data(filter_indexes) {}
	
		# We load the widget items directly instead of mapping it to a listvariable, as it may have either the full
		# list or a filtered one.	
		$widgets(items) delete 0 end
		$widgets(items) insert 0 {*}$values
		
		if { $selected ne "" } {		
			set idx [lsearch -exact $values $selected]
			if { $idx >= 0 } {
				$widgets(items) selection set $idx
				$widgets(items) see $idx
				items_select
			}
		}
	}
	
	proc show { page_to_hide page_to_show } {
		variable data
		variable widgets
		set can [dui canvas]
		set page [namespace tail [namespace current]]
	
		set lst [dui item get $page items]
		lassign [$can bbox $lst] x0 y0 x1 y1
		set target_width [dui platform rescale_x $data(listbox_width)]
		if { [expr {abs($x1-$x0-$target_width) > 10}] } {
			$can itemconfig $lst -width $target_width
			$can itemconfig [dui item get $page filter_string] -width $target_width
			# Reposition the labels and scrollbars
			foreach action [dui page actions $page show] {
				eval $action
			}			
		}

		set n_items [llength $data(item_values)] 
		if { $n_items == 0 } {
			say [translate "no choices"] $::settings(sound_button_out)
			dui item hide $page {filter_string* items*}
		}
		
		dui item show_or_hide [expr {$n_items == 0}] $page empty_items_msg	
	}

	proc filter_string_change {} {
		variable data
		variable widgets
		
		set items_widget $widgets(items)
		set item_values $data(item_values)
		set filter_string $data(filter_string) 
		set filter_indexes $data(filter_indexes)
		
		if { [string length $filter_string ] < 3 } {
			# Show full list
			if { [llength $item_values] > [$items_widget index end] } {
				$items_widget delete 0 end
				$items_widget insert 0 {*}$item_values
			}
			set filter_indexes {}
		} else {
			set filter_indexes [lsearch -all -nocase $item_values "*$filter_string*"]
	
			$items_widget delete 0 end
			set i 0
			foreach idx $filter_indexes { 
				$items_widget insert $i [lindex $item_values $idx]
				incr i 
			}
		}
	}
	
	proc items_select {} {
#		variable data
#		variable widgets
#		set widget $widgets(items)
#		
#		if { $data(allow_modify) == 1 } {
#			if { [$widget curselection] eq "" } {
#				set data(modified_value) {}
#			} else {
#				set data(modified_value) [$widget get [$widget curselection]]
#			}
#		}	
	}
		
	proc page_cancel {} {
		variable data
		say [translate {cancel}] $::settings(sound_button_in)
		
		if { $data(callback_cmd) ne "" } {
			$data(callback_cmd) {} {} $data(item_type)
		} else {
			dui page show $data(previous_page)
		}
	}
		
	proc page_done {} {
		variable data
		variable widgets
		say [translate {done}] $::settings(sound_button_in)

		set items_widget $widgets(items)
		set item_values {}
		set item_ids {}
		
		if {[$items_widget curselection] ne ""} {
			set sel_idx [$items_widget curselection]
			
			foreach i $sel_idx {
				lappend item_values [$items_widget get $i]
			}
						
			if { [llength $data(item_ids)] == 0 } {
				set item_ids $item_values
			} else {
				if { [llength $data(filter_indexes)] > 0 } {
					set new_sel_idx {}
					foreach i $sel_idx { 
						lappend new_sel_idx [lindex $data(filter_indexes) $i]
					}
					set sel_idx $new_sel_idx
				}
				foreach i $sel_idx {
					lappend item_ids [lindex $data(item_ids) $i]
				}
			}
		}

		set selectmode [$items_widget cget -selectmode]
		if { $selectmode in {single browse} } {
			set item_values [lindex $item_values 0]
			set item_ids [lindex $item_ids 0]
		}
		
		if { $data(callback_cmd) ne "" } {
			$data(callback_cmd) $item_values $item_ids $data(item_type)
		} else {
			if { $data(variable) ne "" } {
				set $data(variable) $item_values
			}
			dui page show $data(previous_page)
		}
	}

}

### JUST FOR TESTING
set ::settings(enabled_plugins) {}
# dui_demo SDB github
