package provide de1_dui 1.0

package require de1_logging 1.0
package require de1_updater 1.1
package require de1_utils 1.1

# These needs to be catched because some libraries are not present in the build server
catch {
	# tkblt has replaced BLT in current TK distributions, not on Androwish, they still use BLT and it is preloaded
	package require tkblt
	package require Tk
	package require snit
	namespace import blt::*
	# tksvg breaks all images loading in the older Androwish distributions of the first DE1 tablets.
	# so, at the moment it's disabled.
	package require tksvg
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
	namespace export init setup_ui config cget canvas say platform theme aspect sound symbol font image page item add
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
		date_input_format "%d/%m/%Y"
		preload_images 0
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
	
	variable _base_screen_width 2560.0
	variable _base_screen_height 1600.0
	
	# Most coming from old proc "setup_environment" in utils.tcl
	proc init { {screen_size_width {}} {screen_size_height {}} {orientation landscape} } {
		global android
		global undroid
		# Because font files can only be loaded ONCE with 'sdltk addfont', we need to keep the mapping of file names
		# to family names in a global variable, to be compatible with how skins are doing it.
		global loaded_fonts
		
		variable settings
		variable fontm
		variable entry_length_multiplier
		variable listbox_length_multiplier
		variable listbox_global_width_multiplier

		set settings(app_title) $::settings(skin)
		
		if { ![info exists ::loaded_fonts] } {
			set loaded_fonts {}
		}
		
		# Try to locate fonts folders automatically, in case they're not declared explicitly by the skin
		set skin_dir [skin_directory]		
		set skin_font_dir [file normalize "$skin_dir/fonts/"]
		if { [file exists $skin_font_dir] } {
			if { $skin_font_dir ni [dui font dirs] } {
				dui font add_dirs $skin_font_dir
			}
		} else {
			set font_files {}
			set font_files [glob -tails -nocomplain -directory $skin_dir *.{otf,ttf}]
			if { [llength $font_files] > 0 && [file normalize $skin_dir] ni [dui font dirs] } {
				dui font add_dirs $skin_dir
			}
		}
		
		if {$android == 0 || $undroid == 1} {
			# no 'borg' or 'ble' commands, so emulate
			android_specific_stubs
		}
		if {$android == 1} {
			# hide the android keyboard that pops up when you power back on
			bind . <<DidEnterForeground>> {::dui::platform::hide_android_keyboard}
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
			set fontm $::settings(default_font_calibration)
			
			if { $screen_size_width eq "" || $screen_size_height eq "" } {
				# A better approach than a pause to wait for the lower panel to move away might be to "bind . <<ViewportUpdate>>" 
				# or (when your toplevel is in fullscreen mode) to "bind . <Configure>" and to watch out for "winfo screenheight" in 
				# the bound code.
				if {$android == 1} {
					pause 500
				}
	
				set width [winfo screenwidth .]
				set height [winfo screenheight .]

				msg -ERROR "width: $width height: $height"
	
				if {$width == 2960 && $height == 1730} {

					# samsung a9 14" tablet custom resolution
					borg toast $height
					set screen_size_width 2960
					set screen_size_height 1848
					set fontm 0.70
					set ::settings(default_font_calibration) $fontm

					set ::settings(orientation) "reverselandscape"
					borg screenorientation $::settings(orientation)

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
					#set fontm 2
				} elseif {$width == 2048 && $height == 1536} {
					set screen_size_width 2048
					set screen_size_height 1536
					#set fontm 2

				} elseif {$width == 1340 && ($height == 736 || $height == 800)} {
					# samsung a7 lite custom resolution
					set screen_size_width 1340
					set screen_size_height 800
					#set fontm 2
				} elseif {$width == 2000 && ($height == 1128 || $height == 1200)} {
					# samsung a7 (not lite) custom resolution
					set screen_size_width 2000
					set screen_size_height 1200
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
			#set fontw 1
	
			if {$::undroid == 1} {
				# undroid does not resize fonts appropriately for the current resolution, it assumes a 1024 resolution
				set fontm [expr {($screen_size_width / 1024.0)}]
				#set fontw 2
			}
	
			# NOT NEEDED ANYMORE
#			if {[file exists "skins/default/${screen_size_width}x${screen_size_height}"] != 1} {
#				set ::rescale_images_x_ratio [expr {$screen_size_height / $::dui::_base_screen_height}]
#				set ::rescale_images_y_ratio [expr {$screen_size_width / $::dui::_base_screen_width}]
#			}
	
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
				set helvetica_bold_font [dui::font::add_or_get_familyname "hebrew-bold.ttf"]
				set global_font_name $helvetica_font
				#[dui::font::add_or_get_familyname "hebrew-regular.otf"]
				set listbox_length_multiplier 1.35
				set entry_length_multiplier 0.86				
			} elseif {$settings(language) == "zh-hant" || $settings(language) == "zh-hans" || $settings(language) == "kr"} {
				set helvetica_font [dui::font::add_or_get_familyname "NotoSansCJKjp-Regular.otf"]
				set helvetica_bold_font [dui::font::add_or_get_familyname "NotoSansCJKjp-Bold.otf"]
				set global_font_name [dui::font::add_or_get_familyname "notosansuiregular.ttf"]
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
#			if {[file exists "skins/default/${screen_size_width}x${screen_size_height}"] != 1} {
#				set ::rescale_images_x_ratio [expr {$screen_size_height / $::dui::_base_screen_height}]
#				set ::rescale_images_y_ratio [expr {$screen_size_width / $::dui::_base_screen_width}]
#			}
	
			# EB: Is this installed by default on PC/Mac/Linux?? No need to sdltk add it?
			set helvetica_font "notosansuiregular"
			set helvetica_bold_font "notosansuibold"
			set global_font_name $helvetica_font
			
			if {$settings(language) == "th"} {
				set helvetica_font "sarabun"
				set helvetica_bold_font "sarabunbold"
				#set fontm [expr {($fontm * 1.20)}]
			} 
		}
		

		#set fontawesome_brands [dui::font::add_or_get_familyname "Font Awesome 5 Brands-Regular-400.otf"]
		set fontawesome_brands [dui::font::add_or_get_familyname "Font Awesome 6 Brands-Regular-400.otf"]
		#set fontawesome_pro [dui::font::add_or_get_familyname "Font Awesome 5 Pro-Regular-400.otf"]
		set fontawesome_pro [dui::font::add_or_get_familyname "Font Awesome 6 Pro-Regular-400.otf"]

		msg -DEBUG [namespace current] "Font multiplier: $fontm"
		dui aspect set -theme default -type dtext font_family $helvetica_font 
		dui aspect set -theme default -type dtext -style bold font_family $helvetica_bold_font
		dui aspect set -theme default -type dtext -style global font_family $global_font_name font_size $global_font_size
		#msg -DEBUG [namespace current] "Adding global font with family=$global_font_name and size=$global_font_size"		
		dui aspect set -theme default -type symbol font_family $fontawesome_pro
		dui aspect set -theme default -type symbol -style brands font_family $fontawesome_brands
		
		
		set settings(screen_size_width) $screen_size_width 
		set settings(screen_size_height) $screen_size_height

		# Try to locate image folders automatically, in case they're not declared explicitly by the skin
		set skin_img_dir [file normalize "${skin_dir}/${screen_size_width}x${screen_size_height}/"]
		if { $skin_dir ni [dui item image_dirs] } {
			if { [file exists $skin_img_dir] } {
				dui image add_dirs $skin_dir
			} elseif { [file exists "${skin_dir}/[expr {int($::dui::_base_screen_width)}]x[expr {int($::dui::_base_screen_height)}]/"] } {
				try {
					file mkdir $skin_img_dir
					dui image add_dirs $skin_dir
				} on error err {
					msg -ERROR [namespace current] init: "can't create or folder '$skin_img_dir': $err"
				}
			} else {
				msg -WARNING [namespace current] init: "skin default image directory '$skin_img_dir' not found, was not added"
			}
		}
		
		# log dui settings for eventual debugging
		msg -INFO "Platform data: tcl_platform=$::tcl_platform(platform), android=$android, undroid=$undroid, some_droid=$::some_droid"
		msg -INFO "Screen data: width=$screen_size_width, height=$screen_size_height"
		msg -INFO "Font data: default font=$helvetica_font, multiplier=$fontm, language=$settings(language)"
		
		# define the canvas
		set can [dui canvas]
		. configure -bg black 
		::canvas $can -width $screen_size_width -height $screen_size_height -borderwidth 0 -highlightthickness 0
		pack $can

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
		set can [dui canvas]
		# Create a special transparent full-page background for pages with type=dialog
		$can create rect 0 0 [dui platform rescale_x $::dui::_base_screen_width] \
			[dui platform rescale_y $::dui::_base_screen_height] -fill {} -width 0 -tags _dlg_bg -state hidden
		$can bind _dlg_bg [dui::platform::button_press] {dui::page::dialog_background_press; break}
		$can bind _dlg_bg <Double-Button-1> {break}
		
		# Launch setup methods of pages created with 'dui add page'
		dui page add dui_number_editor -namespace true -type fpdialog -theme default
		dui page add dui_item_selector -namespace true -type fpdialog -theme default
		dui page add dui_confirm_dialog -namespace true -type dialog -theme default -bbox {680 500 1880 1100}
		
		set applied_ns {}
		foreach page [page list] {
			set ns [page get_namespace $page]
			if { $ns ne "" && $ns ni $applied_ns } {
				dui::page::setup $page
#				if { [info proc ${ns}::setup] eq "" } {
#					msg [namespace current] -NOTICE "page namespace '${ns}' does not have a setup method"
#				} else {
#					#msg [namespace current] setup_ui "running ${ns}::setup"
#					${ns}::setup
#				}
				lappend applied_ns $ns
			}
		}
		
		# Launch setup methods of pages created as sub-namespaces of ::dui::pages (which do not require 'dui add page')
		# TBD: Disabled at the moment, as this would run the setup method of pages in disabled plugins...
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
	
	proc say { message {sound_name {}} } {
		variable settings
	
		if { $settings(enable_spoken_prompts) == 1 && $message ne  "" } {
			borg speak $message {} $settings(speaking_pitch) $settings(speaking_rate)
		} elseif { $sound_name ne "" } {
			sound make $sound_name
		}
	}
	
	### PLATFORM SUB-ENSEMBLE ###
	# System-related stuff
	namespace eval platform {
		namespace export hide_android_keyboard button_press button_long_press button_motion finger_down button_unpress \
			xscale_factor yscale_factor rescale_x rescale_y translate_coordinates_finger_down_x translate_coordinates_finger_down_y \
			is_fast_double_tap
		namespace ensemble create
		
		variable last_click_time
		array set last_click_time {}
		
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

		proc button_motion {} {
			global android 
			if {$android == 1} {
				return {<<FingerMotion>>}
			}
			return {<B1-Motion>}
		}
		
		proc xscale_factor {} {
			#global screen_size_width
			return [expr {$::dui::_base_screen_width / [dui cget screen_size_width]}]
		}
		
		proc yscale_factor {} {
			#global screen_size_height
			return [expr {$::dui::_base_screen_height /[dui cget screen_size_height]}]
		}
		
		proc rescale_x {in} {
			return [expr {int($in / [xscale_factor])}]
		}

		proc rescale_y {in} {
			return [expr {int($in / [yscale_factor])}]
		}
		
		# on android we track finger-down, instead of button-press, as it gives us lower latency by avoding having to distinguish a potential gesture from a tap
		# finger down gives a http://blog.tcl.tk/39474
		proc translate_coordinates_finger_down_x { x } {
	
			if {$::android == 1 && $::settings(use_finger_down_for_tap) == 1} {
					return [expr {$x * [winfo screenwidth .] / 10000}]
				}
				return $x
		}
		
		proc translate_coordinates_finger_down_y { y } {

			if {$::android == 1 && $::settings(use_finger_down_for_tap) == 1} {
					return [expr {$y * [winfo screenheight .] / 10000}]
				}
				return $y
		}
		
		proc is_fast_double_tap { key } {
			variable last_click_time
			# if this is a fast double-tap, then treat it like a long tap (button-3) 
		
			set b 0
			set millinow [clock milliseconds]
			set prevtime [ifexists last_click_time($key)]
			if {$prevtime != ""} {
				# check for a fast double-varName
				if {[expr {$millinow - $prevtime}] < 150} {
					msg -INFO "Fast button double-tap on $key"
					set b 1
				}
			}
			set last_click_time($key) $millinow
		
			return $b
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
				} else {
					msg -WARNING [namespace current] "sound set path '$path' not found"
				}
			}
		}
		
		proc get { sound_name } {
			variable sounds
			if { [info exists sounds($sound_name)] } {
				return $sounds($sound_name)
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

		array set aspects {
			default.page.bg_img {}
			default.page.bg_color "#d7d9e6"
			
			default.dialog_page.bg_shape round_outline
			default.dialog_page.bg_color "#fff"
			default.dialog_page.fill "#fff"
			default.dialog_page.outline "#7f879a"
			default.dialog_page.width 1
			
			default.font.font_family notosansuiregular
			default.font.font_size 16
			
			default.dtext.font_family notosansuiregular
			default.dtext.font_size 16
			default.dtext.fill "#7f879a"
			default.dtext.disabledfill "#eee"
			default.dtext.anchor nw
			default.dtext.justify left
			
			default.dtext.fill.remark "#4e85f4"
			default.dtext.fill.error red
			default.dtext.font_family.section_title notosansuibold
			
			default.dtext.font_family.page_title notosansuibold
			default.dtext.font_size.page_title 26
			default.dtext.fill.page_title "#35363d"
			default.dtext.anchor.page_title center
			default.dtext.justify.page_title center
						
			default.symbol.font_family "Font Awesome 6 Pro-Regular-400"
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
			default.dbutton.disabledoutline "#ddd"
			default.dbutton.width 0
			
			default.dbutton_label.pos {0.5 0.5}
			default.dbutton_label.font_size 18
			default.dbutton_label.anchor center	
			default.dbutton_label.justify center
			default.dbutton_label.fill white
			default.dbutton_label.disabledfill "#ccc"

			default.dbutton_label1.pos {0.5 0.8}
			default.dbutton_label1.font_size 16
			default.dbutton_label1.anchor center
			default.dbutton_label1.justify center
			default.dbutton_label1.fill "#7f879a"
			default.dbutton_label1.activefill "#7f879a"
			default.dbutton_label1.disabledfill "#ccc"
			
			default.dbutton_symbol.pos {0.2 0.5}
			default.dbutton_symbol.font_size 28
			default.dbutton_symbol.anchor center
			default.dbutton_symbol.justify center
			default.dbutton_symbol.fill "#7f879a"
			default.dbutton_symbol.disabledfill "#ccc"
			
			default.dbutton.shape.insight_ok round
			default.dbutton.radius.insight_ok 30
			default.dbutton.bwidth.insight_ok 480
			default.dbutton.bheight.insight_ok 118
			default.dbutton_label.font_family.insight_ok notosansuibold
			default.dbutton_label.font_size.insight_ok 19
			
			default.dclicker.fill {}
			default.dclicker.disabledfill {}
			default.dclicker_label.pos {0.5 0.5}
			default.dclicker_label.font_size 18
			default.dclicker_label.fill black
			default.dclicker_label.anchor center
			default.dclicker_label.justify center
			
			default.entry.relief flat
			default.entry.bg white
			default.entry.disabledbackground "#ccc"
			default.entry.font_size 16
			default.entry.width 2
			default.entry.foreground black
			default.entry.disabledforeground white
			
			default.multiline_entry.relief flat
			default.multiline_entry.foreground black
			default.multiline_entry.bg white
			default.multiline_entry.width 2
			default.multiline_entry.font_family notosansuiregular
			default.multiline_entry.font_size 16
			default.multiline_entry.width 15
			default.multiline_entry.height 5
			default.multiline_entry.wrap word

			default.dcombobox.relief flat
			default.dcombobox.bg white
			default.dcombobox.width 2
			default.dcombobox.font_family notosansuiregular
			default.dcombobox.font_size 16
			
			default.dbutton_dda.shape {}
			default.dbutton_dda.fill {}
			default.dbutton_dda.bwidth 70
			default.dbutton_dda.bheight 65
			default.dbutton_dda.symbol "sort-down"
			
			default.dbutton_dda_symbol.pos {0.5 0.25}
			default.dbutton_dda_symbol.font_size 24
			default.dbutton_dda_symbol.anchor center
			default.dbutton_dda_symbol.justify center
			default.dbutton_dda_symbol.fill "#7f879a"
			default.dbutton_dda_symbol.disabledfill "#ddd"
			
			default.dcheckbox.font_family "Font Awesome 6 Pro"
			default.dcheckbox.font_size 18
			default.dcheckbox.fill black
			default.dcheckbox.anchor nw
			default.dcheckbox.justify left
			
			default.dcheckbox_label.pos "e 30 0"
			default.dcheckbox_label.anchor w
			default.dcheckbox_label.justify left
			
			default.listbox.relief flat
			default.listbox.borderwidth 0
			default.listbox.foreground "#7f879a"
			default.listbox.background white
			default.listbox.selectforeground white
			default.listbox.selectbackground black
			default.listbox.selectborderwidth 0
			default.listbox.disabledforeground "#cccccc"
			default.listbox.selectmode browse
			default.listbox.justify left
			default.listbox.font_size 16
			default.listbox.font_family notosansuiregular
			
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
			default.dscale.activeforeground "#4e85f4"
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

			default.graph_line.symbol none
			default.graph_line.label ""
			default.graph_line.linewidth 6
			default.graph_line.pixels 0 
			default.graph_line.smooth linear
			
			default.text.bg white
			default.text.font_size 16
			default.text.relief flat
			default.text.highlightthickness 1
			default.text.wrap word
			
			default.dbutton.shape.dne_clicker round 
			default.dbutton.bwidth.dne_clicker 120 
			default.dbutton.bheight.dne_clicker 140 
			default.dbutton.radius.dne_clicker 20 
			default.dbutton.anchor.dne_clicker center
			default.dbutton_symbol.pos.dne_clicker {0.5 0.4} 
			default.dbutton_symbol.anchor.dne_clicker center 
			default.dbutton_symbol.font_size.dne_clicker 20
			default.dbutton_label.pos.dne_clicker {0.5 0.8} 
			default.dbutton_label.font_size.dne_clicker 10 
			default.dbutton_label.anchor.dne_clicker center
	
			default.dbutton.shape.dne_pad_button round 
			default.dbutton.bwidth.dne_pad_button 280 
			default.dbutton.bheight.dne_pad_button 220 
			default.dbutton.radius.dne_pad_button 20 
			default.dbutton.anchor.dne_pad_button nw
			default.dbutton_label.pos.dne_pad_button {0.5 0.5} 
			default.dbutton_label.font_family.dne_pad_button notosansuibold 
			default.dbutton_label.font_size.dne_pad_button 24 
			default.dbutton_label.anchor.dne_pad_button center
			
			default.dbutton.shape.dui_confirm_button round
			default.dbutton.bheight.dui_confirm_button 100
			
			default.dtext.font_size.menu_dlg_title +1
			default.dtext.anchor.menu_dlg_title center
			default.dtext.justify.menu_dlg_title center
				
			default.dbutton.shape.menu_dlg_close rect 
			default.dbutton.fill.menu_dlg_close {} 
			default.dbutton.symbol.menu_dlg_close xmark
			default.dbutton_symbol.pos.menu_dlg_close {0.5 0.5}
			default.dbutton_symbol.anchor.menu_dlg_close center
			default.dbutton_symbol.justify.menu_dlg_close center
			default.dbutton_symbol.fill.menu_dlg_close #3a3b3c
				
			default.dbutton.shape.menu_dlg_btn rect
			default.dbutton.fill.menu_dlg_btn {}
			default.dbutton.disabledfill.menu_dlg_btn {}
			default.dbutton_label.pos.menu_dlg_btn {0.25 0.4} 
			default.dbutton_label.anchor.menu_dlg_btn w
			default.dbutton_label.fill.menu_dlg_btn #7f879a
			default.dbutton_label.disabledfill.menu_dlg_btn #ddd
				
			default.dbutton_label1.pos.menu_dlg_btn {0.25 0.78} 
			default.dbutton_label1.anchor.menu_dlg_btn w
			default.dbutton_label1.fill.menu_dlg_btn #ccc
			default.dbutton_label1.disabledfill.menu_dlg_btn #ddd
			default.dbutton_label1.font_size.menu_dlg_btn -3
				
			default.dbutton_symbol.pos.menu_dlg_btn {0.15 0.5} 
			default.dbutton_symbol.anchor.menu_dlg_btn center
			default.dbutton_symbol.justify.menu_dlg_btn center
			default.dbutton_symbol.fill.menu_dlg_btn #3a3b3c
			default.dbutton_symbol.disabledfill.menu_dlg_btn #ddd
				
			default.line.fill.menu_dlg_sepline #ddd
			default.line.width.menu_dlg_sepline 1
			
			default.dtext.fill.menu_dlg "#7f879a"
			default.dtext.disabledfill.menu_dlg "#ccc"
			default.dcheckbox.fill.menu_dlg "#7f879a"
			default.dcheckbox.disabledfill.menu_dlg "#ccc"
			default.dcheckbox_label.fill.menu_dlg "#7f879a"
			default.dcheckbox_label.disabledfill.menu_dlg "#ccc"
			
			default.dbutton.shape.menu_dlg round
			default.dbutton.radius.menu_dlg 25
			default.dbutton.fill.menu_dlg "#c0c5e3"
			
			default.dselector.radius 40
			default.dselector.fill white
			default.dselector.selectedfill "#4e85f4"
			default.dselector.outline "#c0c5e3"
			default.dselector.selectedoutline "#4e85f4"
			default.dselector.label_fill "#c0c5e3"
			default.dselector.label_selectedfill white
			
			default.dtoggle.width 120
			default.dtoggle.height 68
			default.dtoggle.outline_width 0
			default.dtoggle.background "#c0c5e3"
			default.dtoggle.foreground white
			default.dtoggle.outline white
			default.dtoggle.selectedbackground "light blue"
			default.dtoggle.selectedforeground "#4e85f4"
			default.dtoggle.selectedoutline "dark blue"
			default.dtoggle.disabledbackground "#ccc"
			default.dtoggle.disabledforeground white
			default.dtoggle.disabledoutline white
			
		}

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
				
				::set value [lindex $args [expr {$i+1}]]
				if { [info exists aspects($var)] } {
					if { $aspects($var) eq $value } {
						#msg -INFO [namespace current] "aspect '$var' already exists, new value is equal to old"
					} else {
						msg -NOTICE [namespace current] "aspect '$var' already exists, old value='$aspects($var)', new value='$value'"
						#if { [ifexists ::debugging 0]} { msg -DEBUG [stacktrace] }
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
			if { $style ne "" } {
				::set i 0				
				while { $i < [llength $type] } {
					::set t [lindex $type $i]
					if { [info exists aspects($theme.$t.$aspect.$style)] } {
						return $aspects($theme.$t.$aspect.$style)
					}
					incr i
				}
			}
			
			::set i 0				
			while { $i < [llength $type] } {
				::set t [lindex $type $i]
				if { [info exists aspects($theme.$t.$aspect)] } {
					return $aspects($theme.$t.$aspect)
				}
				incr i
			}
			
			if { $default ne "" } {
				return $default
			} elseif { [string range $aspect 0 4] eq "font_" && [info exists aspects($theme.font.$aspect)] } {
				return $aspects($theme.font.$aspect)
			}
			
			if { $theme ne "default" } {
				::set avalue [get $type $aspect -theme default {*}$args]
				if { $avalue eq "" } {
					msg -DEBUG [namespace current] "aspect '$theme.[join $type /].$aspect' not found and no alternative available"
				}
				return $avalue
			}
			
			return ""
		}
		
		# Check that an aspect exists EXACTLY as requested. That is, this doesn't search for non-style nor default theme,
		#	like 'dui aspect get' does.
		# TBD: Add an option to mimic exactly the search that dui::aspect::get does?
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
		#	-full_aspect 0 to return the full aspect name
		#	-as_options 1 to return a list that can be directly used as argument options (e.g. {-fill black}).
		#		Setting this to 1 automatically implies -values 1 and -full_aspect 0
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
			
			::set use_full_aspect [string is true [dui::args::get_option -full_aspect 0]]
			::set inc_values [string is true [dui::args::get_option -values 0]]
			::set as_options [string is true [dui::args::get_option -as_options 0]]
			if { $as_options } {
				::set inc_values 1
				::set use_full_aspect 0
			}
			
			# First iterate to find all unique aspects (which may come from either requested theme or default,
			#	or from requested style or unstyled)
			::set all_aspects {}
			foreach full_aspect [array names aspects -regexp $pattern] {
				::set type_and_aspect [join [lrange [split $full_aspect .] 1 2] .]
				if { $type_and_aspect ni $all_aspects } {
					lappend all_aspects $type_and_aspect
				}
			}
			
			::set full_aspect_names {}
			foreach aspect $all_aspects {
				::set full_aspect ""
				if { $theme ne "default" } {
					if { $style ne "" && [info exists aspects(${theme}.${aspect}.${style})] } {
						::set full_aspect ${theme}.${aspect}.${style}
					} elseif { [info exists aspects(${theme}.${aspect})] } {
						::set full_aspect ${theme}.${aspect}
					}
				}
				if { $full_aspect eq "" } {
					if { $style ne "" && [info exists aspects(default.${aspect}.${style})] } {
							::set full_aspect default.${aspect}.${style}
					} elseif { [info exists aspects(default.${aspect})] } {
						::set full_aspect default.${aspect}
					}
				}				
				if { $full_aspect eq "" } {
					# By construction, this should never happen
					msg -ERROR [namespace current] list: "aspect '$aspect' not found for theme '$theme' and style '$style'"
				} else {
					lappend full_aspect_names $full_aspect
				}
			}

			::set result {}
			foreach full_aspect $full_aspect_names {
				::set aspect_parts [split $full_aspect .]
				::set aspect_theme [lindex $aspect_parts 0]
				
				if { $use_full_aspect } {
					lappend result $full_aspect
				} elseif { $as_options } {
					lappend result -[lindex [split $full_aspect .] 2]
				} else {
					lappend result [lindex [split $full_aspect .] 2]
				}
				if { $inc_values } {
					lappend result $aspects($full_aspect)
				}
			}
			
			if { $inc_values != 1 && ([llength $type] > 1 || $style ne "") } {
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
				
		#variable font_filename "Font Awesome 5 Pro-Regular-400.otf"
		variable font_filename "Font Awesome 6 Pro-Regular-400.otf"
		
		variable symbols
		array set symbols {	
		    "00" "\ue467"
		    "360-degrees" "\ue2dc"
		    "a" "\u41"
		    "abacus" "\uf640"
		    "accent-grave" "\u60"
		    "acorn" "\uf6ae"
		    "address-book" "\uf2b9"
		    "address-card" "\uf2bb"
		    "air-conditioner" "\uf8f4"
		    "airplay" "\ue089"
		    "alarm-clock" "\uf34e"
		    "alarm-exclamation" "\uf843"
		    "alarm-plus" "\uf844"
		    "alarm-snooze" "\uf845"
		    "album" "\uf89f"
		    "album-circle-plus" "\ue48c"
		    "album-circle-user" "\ue48d"
		    "album-collection" "\uf8a0"
		    "album-collection-circle-plus" "\ue48e"
		    "album-collection-circle-user" "\ue48f"
		    "alicorn" "\uf6b0"
		    "alien" "\uf8f5"
		    "alien-8bit" "\uf8f6"
		    "align-center" "\uf037"
		    "align-justify" "\uf039"
		    "align-left" "\uf036"
		    "align-right" "\uf038"
		    "align-slash" "\uf846"
		    "alt" "\ue08a"
		    "amp-guitar" "\uf8a1"
		    "ampersand" "\u26"
		    "anchor" "\uf13d"
		    "anchor-circle-check" "\ue4aa"
		    "anchor-circle-exclamation" "\ue4ab"
		    "anchor-circle-xmark" "\ue4ac"
		    "anchor-lock" "\ue4ad"
		    "angel" "\uf779"
		    "angle" "\ue08c"
		    "angle-90" "\ue08d"
		    "angle-down" "\uf107"
		    "angle-left" "\uf104"
		    "angle-right" "\uf105"
		    "angle-up" "\uf106"
		    "angles-down" "\uf103"
		    "angles-left" "\uf100"
		    "angles-right" "\uf101"
		    "angles-up" "\uf102"
		    "angles-up-down" "\ue60d"
		    "ankh" "\uf644"
		    "apartment" "\ue468"
		    "aperture" "\ue2df"
		    "apostrophe" "\u27"
		    "apple-core" "\ue08f"
		    "apple-whole" "\uf5d1"
		    "archway" "\uf557"
		    "arrow-down" "\uf063"
		    "arrow-down-1-9" "\uf162"
		    "arrow-down-9-1" "\uf886"
		    "arrow-down-a-z" "\uf15d"
		    "arrow-down-arrow-up" "\uf883"
		    "arrow-down-big-small" "\uf88c"
		    "arrow-down-from-arc" "\ue614"
		    "arrow-down-from-dotted-line" "\ue090"
		    "arrow-down-from-line" "\uf345"
		    "arrow-down-left" "\ue091"
		    "arrow-down-left-and-arrow-up-right-to-center" "\ue092"
		    "arrow-down-long" "\uf175"
		    "arrow-down-right" "\ue093"
		    "arrow-down-short-wide" "\uf884"
		    "arrow-down-small-big" "\uf88d"
		    "arrow-down-square-triangle" "\uf889"
		    "arrow-down-to-arc" "\ue4ae"
		    "arrow-down-to-bracket" "\ue094"
		    "arrow-down-to-dotted-line" "\ue095"
		    "arrow-down-to-line" "\uf33d"
		    "arrow-down-to-square" "\ue096"
		    "arrow-down-triangle-square" "\uf888"
		    "arrow-down-up-across-line" "\ue4af"
		    "arrow-down-up-lock" "\ue4b0"
		    "arrow-down-wide-short" "\uf160"
		    "arrow-down-z-a" "\uf881"
		    "arrow-left" "\uf060"
		    "arrow-left-from-arc" "\ue615"
		    "arrow-left-from-line" "\uf344"
		    "arrow-left-long" "\uf177"
		    "arrow-left-long-to-line" "\ue3d4"
		    "arrow-left-to-arc" "\ue616"
		    "arrow-left-to-line" "\uf33e"
		    "arrow-pointer" "\uf245"
		    "arrow-progress" "\ue5df"
		    "arrow-right" "\uf061"
		    "arrow-right-arrow-left" "\uf0ec"
		    "arrow-right-from-arc" "\ue4b1"
		    "arrow-right-from-bracket" "\uf08b"
		    "arrow-right-from-line" "\uf343"
		    "arrow-right-long" "\uf178"
		    "arrow-right-long-to-line" "\ue3d5"
		    "arrow-right-to-arc" "\ue4b2"
		    "arrow-right-to-bracket" "\uf090"
		    "arrow-right-to-city" "\ue4b3"
		    "arrow-right-to-line" "\uf340"
		    "arrow-rotate-left" "\uf0e2"
		    "arrow-rotate-right" "\uf01e"
		    "arrow-trend-down" "\ue097"
		    "arrow-trend-up" "\ue098"
		    "arrow-turn-down" "\uf149"
		    "arrow-turn-down-left" "\ue2e1"
		    "arrow-turn-down-right" "\ue3d6"
		    "arrow-turn-left" "\ue632"
		    "arrow-turn-left-down" "\ue633"
		    "arrow-turn-left-up" "\ue634"
		    "arrow-turn-right" "\ue635"
		    "arrow-turn-up" "\uf148"
		    "arrow-up" "\uf062"
		    "arrow-up-1-9" "\uf163"
		    "arrow-up-9-1" "\uf887"
		    "arrow-up-a-z" "\uf15e"
		    "arrow-up-arrow-down" "\ue099"
		    "arrow-up-big-small" "\uf88e"
		    "arrow-up-from-arc" "\ue4b4"
		    "arrow-up-from-bracket" "\ue09a"
		    "arrow-up-from-dotted-line" "\ue09b"
		    "arrow-up-from-ground-water" "\ue4b5"
		    "arrow-up-from-line" "\uf342"
		    "arrow-up-from-square" "\ue09c"
		    "arrow-up-from-water-pump" "\ue4b6"
		    "arrow-up-left" "\ue09d"
		    "arrow-up-left-from-circle" "\ue09e"
		    "arrow-up-long" "\uf176"
		    "arrow-up-right" "\ue09f"
		    "arrow-up-right-and-arrow-down-left-from-center" "\ue0a0"
		    "arrow-up-right-dots" "\ue4b7"
		    "arrow-up-right-from-square" "\uf08e"
		    "arrow-up-short-wide" "\uf885"
		    "arrow-up-small-big" "\uf88f"
		    "arrow-up-square-triangle" "\uf88b"
		    "arrow-up-to-arc" "\ue617"
		    "arrow-up-to-dotted-line" "\ue0a1"
		    "arrow-up-to-line" "\uf341"
		    "arrow-up-triangle-square" "\uf88a"
		    "arrow-up-wide-short" "\uf161"
		    "arrow-up-z-a" "\uf882"
		    "arrows-cross" "\ue0a2"
		    "arrows-down-to-line" "\ue4b8"
		    "arrows-down-to-people" "\ue4b9"
		    "arrows-from-dotted-line" "\ue0a3"
		    "arrows-from-line" "\ue0a4"
		    "arrows-left-right" "\uf07e"
		    "arrows-left-right-to-line" "\ue4ba"
		    "arrows-maximize" "\uf31d"
		    "arrows-minimize" "\ue0a5"
		    "arrows-repeat" "\uf364"
		    "arrows-repeat-1" "\uf366"
		    "arrows-retweet" "\uf361"
		    "arrows-rotate" "\uf021"
		    "arrows-rotate-reverse" "\ue630"
		    "arrows-spin" "\ue4bb"
		    "arrows-split-up-and-left" "\ue4bc"
		    "arrows-to-circle" "\ue4bd"
		    "arrows-to-dot" "\ue4be"
		    "arrows-to-dotted-line" "\ue0a6"
		    "arrows-to-eye" "\ue4bf"
		    "arrows-to-line" "\ue0a7"
		    "arrows-turn-right" "\ue4c0"
		    "arrows-turn-to-dots" "\ue4c1"
		    "arrows-up-down" "\uf07d"
		    "arrows-up-down-left-right" "\uf047"
		    "arrows-up-to-line" "\ue4c2"
		    "asterisk" "\u2a"
		    "at" "\u40"
		    "atom" "\uf5d2"
		    "atom-simple" "\uf5d3"
		    "audio-description" "\uf29e"
		    "audio-description-slash" "\ue0a8"
		    "austral-sign" "\ue0a9"
		    "avocado" "\ue0aa"
		    "award" "\uf559"
		    "award-simple" "\ue0ab"
		    "axe" "\uf6b2"
		    "axe-battle" "\uf6b3"
		    "b" "\u42"
		    "baby" "\uf77c"
		    "baby-carriage" "\uf77d"
		    "backpack" "\uf5d4"
		    "backward" "\uf04a"
		    "backward-fast" "\uf049"
		    "backward-step" "\uf048"
		    "bacon" "\uf7e5"
		    "bacteria" "\ue059"
		    "bacterium" "\ue05a"
		    "badge" "\uf335"
		    "badge-check" "\uf336"
		    "badge-dollar" "\uf645"
		    "badge-percent" "\uf646"
		    "badge-sheriff" "\uf8a2"
		    "badger-honey" "\uf6b4"
		    "badminton" "\ue33a"
		    "bag-seedling" "\ue5f2"
		    "bag-shopping" "\uf290"
		    "bag-shopping-minus" "\ue650"
		    "bag-shopping-plus" "\ue651"
		    "bagel" "\ue3d7"
		    "bags-shopping" "\uf847"
		    "baguette" "\ue3d8"
		    "bahai" "\uf666"
		    "baht-sign" "\ue0ac"
		    "ball-pile" "\uf77e"
		    "balloon" "\ue2e3"
		    "balloons" "\ue2e4"
		    "ballot" "\uf732"
		    "ballot-check" "\uf733"
		    "ban" "\uf05e"
		    "ban-bug" "\uf7f9"
		    "ban-parking" "\uf616"
		    "ban-smoking" "\uf54d"
		    "banana" "\ue2e5"
		    "bandage" "\uf462"
		    "bangladeshi-taka-sign" "\ue2e6"
		    "banjo" "\uf8a3"
		    "barcode" "\uf02a"
		    "barcode-read" "\uf464"
		    "barcode-scan" "\uf465"
		    "bars" "\uf0c9"
		    "bars-filter" "\ue0ad"
		    "bars-progress" "\uf828"
		    "bars-sort" "\ue0ae"
		    "bars-staggered" "\uf550"
		    "baseball" "\uf433"
		    "baseball-bat-ball" "\uf432"
		    "basket-shopping" "\uf291"
		    "basket-shopping-minus" "\ue652"
		    "basket-shopping-plus" "\ue653"
		    "basket-shopping-simple" "\ue0af"
		    "basketball" "\uf434"
		    "basketball-hoop" "\uf435"
		    "bat" "\uf6b5"
		    "bath" "\uf2cd"
		    "battery-bolt" "\uf376"
		    "battery-empty" "\uf244"
		    "battery-exclamation" "\ue0b0"
		    "battery-full" "\uf240"
		    "battery-half" "\uf242"
		    "battery-low" "\ue0b1"
		    "battery-quarter" "\uf243"
		    "battery-slash" "\uf377"
		    "battery-three-quarters" "\uf241"
		    "bed" "\uf236"
		    "bed-bunk" "\uf8f8"
		    "bed-empty" "\uf8f9"
		    "bed-front" "\uf8f7"
		    "bed-pulse" "\uf487"
		    "bee" "\ue0b2"
		    "beer-mug" "\ue0b3"
		    "beer-mug-empty" "\uf0fc"
		    "bell" "\uf0f3"
		    "bell-concierge" "\uf562"
		    "bell-exclamation" "\uf848"
		    "bell-on" "\uf8fa"
		    "bell-plus" "\uf849"
		    "bell-ring" "\ue62c"
		    "bell-school" "\uf5d5"
		    "bell-school-slash" "\uf5d6"
		    "bell-slash" "\uf1f6"
		    "bells" "\uf77f"
		    "bench-tree" "\ue2e7"
		    "bezier-curve" "\uf55b"
		    "bicycle" "\uf206"
		    "billboard" "\ue5cd"
		    "bin-bottles" "\ue5f5"
		    "bin-bottles-recycle" "\ue5f6"
		    "bin-recycle" "\ue5f7"
		    "binary" "\ue33b"
		    "binary-circle-check" "\ue33c"
		    "binary-lock" "\ue33d"
		    "binary-slash" "\ue33e"
		    "binoculars" "\uf1e5"
		    "biohazard" "\uf780"
		    "bird" "\ue469"
		    "bitcoin-sign" "\ue0b4"
		    "blanket" "\uf498"
		    "blanket-fire" "\ue3da"
		    "blender" "\uf517"
		    "blender-phone" "\uf6b6"
		    "blinds" "\uf8fb"
		    "blinds-open" "\uf8fc"
		    "blinds-raised" "\uf8fd"
		    "block" "\ue46a"
		    "block-brick" "\ue3db"
		    "block-brick-fire" "\ue3dc"
		    "block-question" "\ue3dd"
		    "block-quote" "\ue0b5"
		    "blog" "\uf781"
		    "blueberries" "\ue2e8"
		    "bluetooth" "\uf293"
		    "bold" "\uf032"
		    "bolt" "\uf0e7"
		    "bolt-auto" "\ue0b6"
		    "bolt-lightning" "\ue0b7"
		    "bolt-slash" "\ue0b8"
		    "bomb" "\uf1e2"
		    "bone" "\uf5d7"
		    "bone-break" "\uf5d8"
		    "bong" "\uf55c"
		    "book" "\uf02d"
		    "book-arrow-right" "\ue0b9"
		    "book-arrow-up" "\ue0ba"
		    "book-atlas" "\uf558"
		    "book-bible" "\uf647"
		    "book-blank" "\uf5d9"
		    "book-bookmark" "\ue0bb"
		    "book-circle-arrow-right" "\ue0bc"
		    "book-circle-arrow-up" "\ue0bd"
		    "book-copy" "\ue0be"
		    "book-font" "\ue0bf"
		    "book-heart" "\uf499"
		    "book-journal-whills" "\uf66a"
		    "book-medical" "\uf7e6"
		    "book-open" "\uf518"
		    "book-open-cover" "\ue0c0"
		    "book-open-reader" "\uf5da"
		    "book-quran" "\uf687"
		    "book-section" "\ue0c1"
		    "book-skull" "\uf6b7"
		    "book-sparkles" "\uf6b8"
		    "book-tanakh" "\uf827"
		    "book-user" "\uf7e7"
		    "bookmark" "\uf02e"
		    "bookmark-slash" "\ue0c2"
		    "books" "\uf5db"
		    "books-medical" "\uf7e8"
		    "boombox" "\uf8a5"
		    "boot" "\uf782"
		    "boot-heeled" "\ue33f"
		    "booth-curtain" "\uf734"
		    "border-all" "\uf84c"
		    "border-bottom" "\uf84d"
		    "border-bottom-right" "\uf854"
		    "border-center-h" "\uf89c"
		    "border-center-v" "\uf89d"
		    "border-inner" "\uf84e"
		    "border-left" "\uf84f"
		    "border-none" "\uf850"
		    "border-outer" "\uf851"
		    "border-right" "\uf852"
		    "border-top" "\uf855"
		    "border-top-left" "\uf853"
		    "bore-hole" "\ue4c3"
		    "bottle-droplet" "\ue4c4"
		    "bottle-water" "\ue4c5"
		    "bow-arrow" "\uf6b9"
		    "bowl-chopsticks" "\ue2e9"
		    "bowl-chopsticks-noodles" "\ue2ea"
		    "bowl-food" "\ue4c6"
		    "bowl-hot" "\uf823"
		    "bowl-rice" "\ue2eb"
		    "bowl-scoop" "\ue3de"
		    "bowl-scoops" "\ue3df"
		    "bowl-soft-serve" "\ue46b"
		    "bowl-spoon" "\ue3e0"
		    "bowling-ball" "\uf436"
		    "bowling-ball-pin" "\ue0c3"
		    "bowling-pins" "\uf437"
		    "box" "\uf466"
		    "box-archive" "\uf187"
		    "box-ballot" "\uf735"
		    "box-check" "\uf467"
		    "box-circle-check" "\ue0c4"
		    "box-dollar" "\uf4a0"
		    "box-heart" "\uf49d"
		    "box-open" "\uf49e"
		    "box-open-full" "\uf49c"
		    "box-taped" "\uf49a"
		    "box-tissue" "\ue05b"
		    "boxes-packing" "\ue4c7"
		    "boxes-stacked" "\uf468"
		    "boxing-glove" "\uf438"
		    "bracket-curly" "\u7b"
		    "bracket-curly-right" "\u7d"
		    "bracket-round" "\u28"
		    "bracket-round-right" "\u29"
		    "bracket-square" "\u5b"
		    "bracket-square-right" "\u5d"
		    "brackets-curly" "\uf7ea"
		    "brackets-round" "\ue0c5"
		    "brackets-square" "\uf7e9"
		    "braille" "\uf2a1"
		    "brain" "\uf5dc"
		    "brain-arrow-curved-right" "\uf677"
		    "brain-circuit" "\ue0c6"
		    "brake-warning" "\ue0c7"
		    "brazilian-real-sign" "\ue46c"
		    "bread-loaf" "\uf7eb"
		    "bread-slice" "\uf7ec"
		    "bread-slice-butter" "\ue3e1"
		    "bridge" "\ue4c8"
		    "bridge-circle-check" "\ue4c9"
		    "bridge-circle-exclamation" "\ue4ca"
		    "bridge-circle-xmark" "\ue4cb"
		    "bridge-lock" "\ue4cc"
		    "bridge-suspension" "\ue4cd"
		    "bridge-water" "\ue4ce"
		    "briefcase" "\uf0b1"
		    "briefcase-arrow-right" "\ue2f2"
		    "briefcase-blank" "\ue0c8"
		    "briefcase-medical" "\uf469"
		    "brightness" "\ue0c9"
		    "brightness-low" "\ue0ca"
		    "bring-forward" "\uf856"
		    "bring-front" "\uf857"
		    "broccoli" "\ue3e2"
		    "broom" "\uf51a"
		    "broom-ball" "\uf458"
		    "broom-wide" "\ue5d1"
		    "browser" "\uf37e"
		    "browsers" "\ue0cb"
		    "brush" "\uf55d"
		    "bucket" "\ue4cf"
		    "bug" "\uf188"
		    "bug-slash" "\ue490"
		    "bugs" "\ue4d0"
		    "building" "\uf1ad"
		    "building-circle-arrow-right" "\ue4d1"
		    "building-circle-check" "\ue4d2"
		    "building-circle-exclamation" "\ue4d3"
		    "building-circle-xmark" "\ue4d4"
		    "building-columns" "\uf19c"
		    "building-flag" "\ue4d5"
		    "building-lock" "\ue4d6"
		    "building-magnifying-glass" "\ue61c"
		    "building-memo" "\ue61e"
		    "building-ngo" "\ue4d7"
		    "building-shield" "\ue4d8"
		    "building-un" "\ue4d9"
		    "building-user" "\ue4da"
		    "building-wheat" "\ue4db"
		    "buildings" "\ue0cc"
		    "bulldozer" "\ue655"
		    "bullhorn" "\uf0a1"
		    "bullseye" "\uf140"
		    "bullseye-arrow" "\uf648"
		    "bullseye-pointer" "\uf649"
		    "buoy" "\ue5b5"
		    "buoy-mooring" "\ue5b6"
		    "burger" "\uf805"
		    "burger-cheese" "\uf7f1"
		    "burger-fries" "\ue0cd"
		    "burger-glass" "\ue0ce"
		    "burger-lettuce" "\ue3e3"
		    "burger-soda" "\uf858"
		    "burrito" "\uf7ed"
		    "burst" "\ue4dc"
		    "bus" "\uf207"
		    "bus-school" "\uf5dd"
		    "bus-simple" "\uf55e"
		    "business-time" "\uf64a"
		    "butter" "\ue3e4"
		    "c" "\u43"
		    "cabin" "\ue46d"
		    "cabinet-filing" "\uf64b"
		    "cable-car" "\uf7da"
		    "cactus" "\uf8a7"
		    "cake-candles" "\uf1fd"
		    "cake-slice" "\ue3e5"
		    "calculator" "\uf1ec"
		    "calculator-simple" "\uf64c"
		    "calendar" "\uf133"
		    "calendar-arrow-down" "\ue0d0"
		    "calendar-arrow-up" "\ue0d1"
		    "calendar-check" "\uf274"
		    "calendar-circle-exclamation" "\ue46e"
		    "calendar-circle-minus" "\ue46f"
		    "calendar-circle-plus" "\ue470"
		    "calendar-circle-user" "\ue471"
		    "calendar-clock" "\ue0d2"
		    "calendar-day" "\uf783"
		    "calendar-days" "\uf073"
		    "calendar-exclamation" "\uf334"
		    "calendar-heart" "\ue0d3"
		    "calendar-image" "\ue0d4"
		    "calendar-lines" "\ue0d5"
		    "calendar-lines-pen" "\ue472"
		    "calendar-minus" "\uf272"
		    "calendar-pen" "\uf333"
		    "calendar-plus" "\uf271"
		    "calendar-range" "\ue0d6"
		    "calendar-star" "\uf736"
		    "calendar-users" "\ue5e2"
		    "calendar-week" "\uf784"
		    "calendar-xmark" "\uf273"
		    "calendars" "\ue0d7"
		    "camcorder" "\uf8a8"
		    "camera" "\uf030"
		    "camera-cctv" "\uf8ac"
		    "camera-movie" "\uf8a9"
		    "camera-polaroid" "\uf8aa"
		    "camera-retro" "\uf083"
		    "camera-rotate" "\ue0d8"
		    "camera-security" "\uf8fe"
		    "camera-slash" "\ue0d9"
		    "camera-viewfinder" "\ue0da"
		    "camera-web" "\uf832"
		    "camera-web-slash" "\uf833"
		    "campfire" "\uf6ba"
		    "campground" "\uf6bb"
		    "can-food" "\ue3e6"
		    "candle-holder" "\uf6bc"
		    "candy" "\ue3e7"
		    "candy-bar" "\ue3e8"
		    "candy-cane" "\uf786"
		    "candy-corn" "\uf6bd"
		    "cannabis" "\uf55f"
		    "cannon" "\ue642"
		    "capsules" "\uf46b"
		    "car" "\uf1b9"
		    "car-battery" "\uf5df"
		    "car-bolt" "\ue341"
		    "car-building" "\uf859"
		    "car-bump" "\uf5e0"
		    "car-burst" "\uf5e1"
		    "car-bus" "\uf85a"
		    "car-circle-bolt" "\ue342"
		    "car-garage" "\uf5e2"
		    "car-mirrors" "\ue343"
		    "car-on" "\ue4dd"
		    "car-rear" "\uf5de"
		    "car-side" "\uf5e4"
		    "car-side-bolt" "\ue344"
		    "car-tilt" "\uf5e5"
		    "car-tunnel" "\ue4de"
		    "car-wash" "\uf5e6"
		    "car-wrench" "\uf5e3"
		    "caravan" "\uf8ff"
		    "caravan-simple" "\ue000"
		    "card-club" "\ue3e9"
		    "card-diamond" "\ue3ea"
		    "card-heart" "\ue3eb"
		    "card-spade" "\ue3ec"
		    "cards" "\ue3ed"
		    "cards-blank" "\ue4df"
		    "caret-down" "\uf0d7"
		    "caret-left" "\uf0d9"
		    "caret-right" "\uf0da"
		    "caret-up" "\uf0d8"
		    "carrot" "\uf787"
		    "cars" "\uf85b"
		    "cart-arrow-down" "\uf218"
		    "cart-arrow-up" "\ue3ee"
		    "cart-circle-arrow-down" "\ue3ef"
		    "cart-circle-arrow-up" "\ue3f0"
		    "cart-circle-check" "\ue3f1"
		    "cart-circle-exclamation" "\ue3f2"
		    "cart-circle-plus" "\ue3f3"
		    "cart-circle-xmark" "\ue3f4"
		    "cart-flatbed" "\uf474"
		    "cart-flatbed-boxes" "\uf475"
		    "cart-flatbed-empty" "\uf476"
		    "cart-flatbed-suitcase" "\uf59d"
		    "cart-minus" "\ue0db"
		    "cart-plus" "\uf217"
		    "cart-shopping" "\uf07a"
		    "cart-shopping-fast" "\ue0dc"
		    "cart-xmark" "\ue0dd"
		    "cash-register" "\uf788"
		    "cassette-betamax" "\uf8a4"
		    "cassette-tape" "\uf8ab"
		    "cassette-vhs" "\uf8ec"
		    "castle" "\ue0de"
		    "cat" "\uf6be"
		    "cat-space" "\ue001"
		    "cauldron" "\uf6bf"
		    "cedi-sign" "\ue0df"
		    "cent-sign" "\ue3f5"
		    "certificate" "\uf0a3"
		    "chair" "\uf6c0"
		    "chair-office" "\uf6c1"
		    "chalkboard" "\uf51b"
		    "chalkboard-user" "\uf51c"
		    "champagne-glass" "\uf79e"
		    "champagne-glasses" "\uf79f"
		    "charging-station" "\uf5e7"
		    "chart-area" "\uf1fe"
		    "chart-bar" "\uf080"
		    "chart-bullet" "\ue0e1"
		    "chart-candlestick" "\ue0e2"
		    "chart-column" "\ue0e3"
		    "chart-gantt" "\ue0e4"
		    "chart-kanban" "\ue64f"
		    "chart-line" "\uf201"
		    "chart-line-down" "\uf64d"
		    "chart-line-up" "\ue0e5"
		    "chart-line-up-down" "\ue5d7"
		    "chart-mixed" "\uf643"
		    "chart-mixed-up-circle-currency" "\ue5d8"
		    "chart-mixed-up-circle-dollar" "\ue5d9"
		    "chart-network" "\uf78a"
		    "chart-pie" "\uf200"
		    "chart-pie-simple" "\uf64e"
		    "chart-pie-simple-circle-currency" "\ue604"
		    "chart-pie-simple-circle-dollar" "\ue605"
		    "chart-pyramid" "\ue0e6"
		    "chart-radar" "\ue0e7"
		    "chart-scatter" "\uf7ee"
		    "chart-scatter-3d" "\ue0e8"
		    "chart-scatter-bubble" "\ue0e9"
		    "chart-simple" "\ue473"
		    "chart-simple-horizontal" "\ue474"
		    "chart-tree-map" "\ue0ea"
		    "chart-user" "\uf6a3"
		    "chart-waterfall" "\ue0eb"
		    "check" "\uf00c"
		    "check-double" "\uf560"
		    "check-to-slot" "\uf772"
		    "cheese" "\uf7ef"
		    "cheese-swiss" "\uf7f0"
		    "cherries" "\ue0ec"
		    "chess" "\uf439"
		    "chess-bishop" "\uf43a"
		    "chess-bishop-piece" "\uf43b"
		    "chess-board" "\uf43c"
		    "chess-clock" "\uf43d"
		    "chess-clock-flip" "\uf43e"
		    "chess-king" "\uf43f"
		    "chess-king-piece" "\uf440"
		    "chess-knight" "\uf441"
		    "chess-knight-piece" "\uf442"
		    "chess-pawn" "\uf443"
		    "chess-pawn-piece" "\uf444"
		    "chess-queen" "\uf445"
		    "chess-queen-piece" "\uf446"
		    "chess-rook" "\uf447"
		    "chess-rook-piece" "\uf448"
		    "chestnut" "\ue3f6"
		    "chevron-down" "\uf078"
		    "chevron-left" "\uf053"
		    "chevron-right" "\uf054"
		    "chevron-up" "\uf077"
		    "chevrons-down" "\uf322"
		    "chevrons-left" "\uf323"
		    "chevrons-right" "\uf324"
		    "chevrons-up" "\uf325"
		    "chf-sign" "\ue602"
		    "child" "\uf1ae"
		    "child-combatant" "\ue4e0"
		    "child-dress" "\ue59c"
		    "child-reaching" "\ue59d"
		    "children" "\ue4e1"
		    "chimney" "\uf78b"
		    "chopsticks" "\ue3f7"
		    "church" "\uf51d"
		    "circle" "\uf111"
		    "circle-0" "\ue0ed"
		    "circle-1" "\ue0ee"
		    "circle-2" "\ue0ef"
		    "circle-3" "\ue0f0"
		    "circle-4" "\ue0f1"
		    "circle-5" "\ue0f2"
		    "circle-6" "\ue0f3"
		    "circle-7" "\ue0f4"
		    "circle-8" "\ue0f5"
		    "circle-9" "\ue0f6"
		    "circle-a" "\ue0f7"
		    "circle-ampersand" "\ue0f8"
		    "circle-arrow-down" "\uf0ab"
		    "circle-arrow-down-left" "\ue0f9"
		    "circle-arrow-down-right" "\ue0fa"
		    "circle-arrow-left" "\uf0a8"
		    "circle-arrow-right" "\uf0a9"
		    "circle-arrow-up" "\uf0aa"
		    "circle-arrow-up-left" "\ue0fb"
		    "circle-arrow-up-right" "\ue0fc"
		    "circle-b" "\ue0fd"
		    "circle-bolt" "\ue0fe"
		    "circle-book-open" "\ue0ff"
		    "circle-bookmark" "\ue100"
		    "circle-c" "\ue101"
		    "circle-calendar" "\ue102"
		    "circle-camera" "\ue103"
		    "circle-caret-down" "\uf32d"
		    "circle-caret-left" "\uf32e"
		    "circle-caret-right" "\uf330"
		    "circle-caret-up" "\uf331"
		    "circle-check" "\uf058"
		    "circle-chevron-down" "\uf13a"
		    "circle-chevron-left" "\uf137"
		    "circle-chevron-right" "\uf138"
		    "circle-chevron-up" "\uf139"
		    "circle-d" "\ue104"
		    "circle-dashed" "\ue105"
		    "circle-divide" "\ue106"
		    "circle-dollar" "\uf2e8"
		    "circle-dollar-to-slot" "\uf4b9"
		    "circle-dot" "\uf192"
		    "circle-down" "\uf358"
		    "circle-down-left" "\ue107"
		    "circle-down-right" "\ue108"
		    "circle-e" "\ue109"
		    "circle-ellipsis" "\ue10a"
		    "circle-ellipsis-vertical" "\ue10b"
		    "circle-envelope" "\ue10c"
		    "circle-euro" "\ue5ce"
		    "circle-exclamation" "\uf06a"
		    "circle-exclamation-check" "\ue10d"
		    "circle-f" "\ue10e"
		    "circle-g" "\ue10f"
		    "circle-h" "\uf47e"
		    "circle-half" "\ue110"
		    "circle-half-stroke" "\uf042"
		    "circle-heart" "\uf4c7"
		    "circle-i" "\ue111"
		    "circle-info" "\uf05a"
		    "circle-j" "\ue112"
		    "circle-k" "\ue113"
		    "circle-l" "\ue114"
		    "circle-left" "\uf359"
		    "circle-location-arrow" "\uf602"
		    "circle-m" "\ue115"
		    "circle-microphone" "\ue116"
		    "circle-microphone-lines" "\ue117"
		    "circle-minus" "\uf056"
		    "circle-n" "\ue118"
		    "circle-nodes" "\ue4e2"
		    "circle-notch" "\uf1ce"
		    "circle-o" "\ue119"
		    "circle-p" "\ue11a"
		    "circle-parking" "\uf615"
		    "circle-pause" "\uf28b"
		    "circle-phone" "\ue11b"
		    "circle-phone-flip" "\ue11c"
		    "circle-phone-hangup" "\ue11d"
		    "circle-play" "\uf144"
		    "circle-plus" "\uf055"
		    "circle-q" "\ue11e"
		    "circle-quarter" "\ue11f"
		    "circle-quarter-stroke" "\ue5d3"
		    "circle-quarters" "\ue3f8"
		    "circle-question" "\uf059"
		    "circle-r" "\ue120"
		    "circle-radiation" "\uf7ba"
		    "circle-right" "\uf35a"
		    "circle-s" "\ue121"
		    "circle-small" "\ue122"
		    "circle-sort" "\ue030"
		    "circle-sort-down" "\ue031"
		    "circle-sort-up" "\ue032"
		    "circle-star" "\ue123"
		    "circle-sterling" "\ue5cf"
		    "circle-stop" "\uf28d"
		    "circle-t" "\ue124"
		    "circle-three-quarters" "\ue125"
		    "circle-three-quarters-stroke" "\ue5d4"
		    "circle-trash" "\ue126"
		    "circle-u" "\ue127"
		    "circle-up" "\uf35b"
		    "circle-up-left" "\ue128"
		    "circle-up-right" "\ue129"
		    "circle-user" "\uf2bd"
		    "circle-v" "\ue12a"
		    "circle-video" "\ue12b"
		    "circle-w" "\ue12c"
		    "circle-waveform-lines" "\ue12d"
		    "circle-x" "\ue12e"
		    "circle-xmark" "\uf057"
		    "circle-y" "\ue12f"
		    "circle-yen" "\ue5d0"
		    "circle-z" "\ue130"
		    "circles-overlap" "\ue600"
		    "citrus" "\ue2f4"
		    "citrus-slice" "\ue2f5"
		    "city" "\uf64f"
		    "clapperboard" "\ue131"
		    "clapperboard-play" "\ue132"
		    "clarinet" "\uf8ad"
		    "claw-marks" "\uf6c2"
		    "clipboard" "\uf328"
		    "clipboard-check" "\uf46c"
		    "clipboard-list" "\uf46d"
		    "clipboard-list-check" "\uf737"
		    "clipboard-medical" "\ue133"
		    "clipboard-prescription" "\uf5e8"
		    "clipboard-question" "\ue4e3"
		    "clipboard-user" "\uf7f3"
		    "clock" "\uf017"
		    "clock-desk" "\ue134"
		    "clock-eight" "\ue345"
		    "clock-eight-thirty" "\ue346"
		    "clock-eleven" "\ue347"
		    "clock-eleven-thirty" "\ue348"
		    "clock-five" "\ue349"
		    "clock-five-thirty" "\ue34a"
		    "clock-four-thirty" "\ue34b"
		    "clock-nine" "\ue34c"
		    "clock-nine-thirty" "\ue34d"
		    "clock-one" "\ue34e"
		    "clock-one-thirty" "\ue34f"
		    "clock-rotate-left" "\uf1da"
		    "clock-seven" "\ue350"
		    "clock-seven-thirty" "\ue351"
		    "clock-six" "\ue352"
		    "clock-six-thirty" "\ue353"
		    "clock-ten" "\ue354"
		    "clock-ten-thirty" "\ue355"
		    "clock-three" "\ue356"
		    "clock-three-thirty" "\ue357"
		    "clock-twelve" "\ue358"
		    "clock-twelve-thirty" "\ue359"
		    "clock-two" "\ue35a"
		    "clock-two-thirty" "\ue35b"
		    "clone" "\uf24d"
		    "closed-captioning" "\uf20a"
		    "closed-captioning-slash" "\ue135"
		    "clothes-hanger" "\ue136"
		    "cloud" "\uf0c2"
		    "cloud-arrow-down" "\uf0ed"
		    "cloud-arrow-up" "\uf0ee"
		    "cloud-binary" "\ue601"
		    "cloud-bolt" "\uf76c"
		    "cloud-bolt-moon" "\uf76d"
		    "cloud-bolt-sun" "\uf76e"
		    "cloud-check" "\ue35c"
		    "cloud-drizzle" "\uf738"
		    "cloud-exclamation" "\ue491"
		    "cloud-fog" "\uf74e"
		    "cloud-hail" "\uf739"
		    "cloud-hail-mixed" "\uf73a"
		    "cloud-meatball" "\uf73b"
		    "cloud-minus" "\ue35d"
		    "cloud-moon" "\uf6c3"
		    "cloud-moon-rain" "\uf73c"
		    "cloud-music" "\uf8ae"
		    "cloud-plus" "\ue35e"
		    "cloud-question" "\ue492"
		    "cloud-rain" "\uf73d"
		    "cloud-rainbow" "\uf73e"
		    "cloud-showers" "\uf73f"
		    "cloud-showers-heavy" "\uf740"
		    "cloud-showers-water" "\ue4e4"
		    "cloud-slash" "\ue137"
		    "cloud-sleet" "\uf741"
		    "cloud-snow" "\uf742"
		    "cloud-sun" "\uf6c4"
		    "cloud-sun-rain" "\uf743"
		    "cloud-word" "\ue138"
		    "cloud-xmark" "\ue35f"
		    "clouds" "\uf744"
		    "clouds-moon" "\uf745"
		    "clouds-sun" "\uf746"
		    "clover" "\ue139"
		    "club" "\uf327"
		    "coconut" "\ue2f6"
		    "code" "\uf121"
		    "code-branch" "\uf126"
		    "code-commit" "\uf386"
		    "code-compare" "\ue13a"
		    "code-fork" "\ue13b"
		    "code-merge" "\uf387"
		    "code-pull-request" "\ue13c"
		    "code-pull-request-closed" "\ue3f9"
		    "code-pull-request-draft" "\ue3fa"
		    "code-simple" "\ue13d"
		    "coffee-bean" "\ue13e"
		    "coffee-beans" "\ue13f"
		    "coffee-pot" "\ue002"
		    "coffin" "\uf6c6"
		    "coffin-cross" "\ue051"
		    "coin" "\uf85c"
		    "coin-blank" "\ue3fb"
		    "coin-front" "\ue3fc"
		    "coin-vertical" "\ue3fd"
		    "coins" "\uf51e"
		    "colon" "\u3a"
		    "colon-sign" "\ue140"
		    "columns-3" "\ue361"
		    "comet" "\ue003"
		    "comma" "\u2c"
		    "command" "\ue142"
		    "comment" "\uf075"
		    "comment-arrow-down" "\ue143"
		    "comment-arrow-up" "\ue144"
		    "comment-arrow-up-right" "\ue145"
		    "comment-captions" "\ue146"
		    "comment-check" "\uf4ac"
		    "comment-code" "\ue147"
		    "comment-dollar" "\uf651"
		    "comment-dots" "\uf4ad"
		    "comment-exclamation" "\uf4af"
		    "comment-heart" "\ue5c8"
		    "comment-image" "\ue148"
		    "comment-lines" "\uf4b0"
		    "comment-medical" "\uf7f5"
		    "comment-middle" "\ue149"
		    "comment-middle-top" "\ue14a"
		    "comment-minus" "\uf4b1"
		    "comment-music" "\uf8b0"
		    "comment-pen" "\uf4ae"
		    "comment-plus" "\uf4b2"
		    "comment-question" "\ue14b"
		    "comment-quote" "\ue14c"
		    "comment-slash" "\uf4b3"
		    "comment-smile" "\uf4b4"
		    "comment-sms" "\uf7cd"
		    "comment-text" "\ue14d"
		    "comment-xmark" "\uf4b5"
		    "comments" "\uf086"
		    "comments-dollar" "\uf653"
		    "comments-question" "\ue14e"
		    "comments-question-check" "\ue14f"
		    "compact-disc" "\uf51f"
		    "compass" "\uf14e"
		    "compass-drafting" "\uf568"
		    "compass-slash" "\uf5e9"
		    "compress" "\uf066"
		    "compress-wide" "\uf326"
		    "computer" "\ue4e5"
		    "computer-classic" "\uf8b1"
		    "computer-mouse" "\uf8cc"
		    "computer-mouse-scrollwheel" "\uf8cd"
		    "computer-speaker" "\uf8b2"
		    "container-storage" "\uf4b7"
		    "conveyor-belt" "\uf46e"
		    "conveyor-belt-arm" "\ue5f8"
		    "conveyor-belt-boxes" "\uf46f"
		    "conveyor-belt-empty" "\ue150"
		    "cookie" "\uf563"
		    "cookie-bite" "\uf564"
		    "copy" "\uf0c5"
		    "copyright" "\uf1f9"
		    "corn" "\uf6c7"
		    "corner" "\ue3fe"
		    "couch" "\uf4b8"
		    "court-sport" "\ue643"
		    "cow" "\uf6c8"
		    "cowbell" "\uf8b3"
		    "cowbell-circle-plus" "\uf8b4"
		    "crab" "\ue3ff"
		    "crate-apple" "\uf6b1"
		    "crate-empty" "\ue151"
		    "credit-card" "\uf09d"
		    "credit-card-blank" "\uf389"
		    "credit-card-front" "\uf38a"
		    "cricket-bat-ball" "\uf449"
		    "croissant" "\uf7f6"
		    "crop" "\uf125"
		    "crop-simple" "\uf565"
		    "cross" "\uf654"
		    "crosshairs" "\uf05b"
		    "crosshairs-simple" "\ue59f"
		    "crow" "\uf520"
		    "crown" "\uf521"
		    "crutch" "\uf7f7"
		    "crutches" "\uf7f8"
		    "cruzeiro-sign" "\ue152"
		    "crystal-ball" "\ue362"
		    "cube" "\uf1b2"
		    "cubes" "\uf1b3"
		    "cubes-stacked" "\ue4e6"
		    "cucumber" "\ue401"
		    "cup-straw" "\ue363"
		    "cup-straw-swoosh" "\ue364"
		    "cup-togo" "\uf6c5"
		    "cupcake" "\ue402"
		    "curling-stone" "\uf44a"
		    "custard" "\ue403"
		    "d" "\u44"
		    "dagger" "\uf6cb"
		    "dash" "\ue404"
		    "database" "\uf1c0"
		    "deer" "\uf78e"
		    "deer-rudolph" "\uf78f"
		    "delete-left" "\uf55a"
		    "delete-right" "\ue154"
		    "democrat" "\uf747"
		    "desktop" "\uf390"
		    "desktop-arrow-down" "\ue155"
		    "dharmachakra" "\uf655"
		    "diagram-cells" "\ue475"
		    "diagram-lean-canvas" "\ue156"
		    "diagram-nested" "\ue157"
		    "diagram-next" "\ue476"
		    "diagram-predecessor" "\ue477"
		    "diagram-previous" "\ue478"
		    "diagram-project" "\uf542"
		    "diagram-sankey" "\ue158"
		    "diagram-subtask" "\ue479"
		    "diagram-successor" "\ue47a"
		    "diagram-venn" "\ue15a"
		    "dial" "\ue15b"
		    "dial-high" "\ue15c"
		    "dial-low" "\ue15d"
		    "dial-max" "\ue15e"
		    "dial-med" "\ue15f"
		    "dial-med-low" "\ue160"
		    "dial-min" "\ue161"
		    "dial-off" "\ue162"
		    "diamond" "\uf219"
		    "diamond-exclamation" "\ue405"
		    "diamond-half" "\ue5b7"
		    "diamond-half-stroke" "\ue5b8"
		    "diamond-turn-right" "\uf5eb"
		    "dice" "\uf522"
		    "dice-d10" "\uf6cd"
		    "dice-d12" "\uf6ce"
		    "dice-d20" "\uf6cf"
		    "dice-d4" "\uf6d0"
		    "dice-d6" "\uf6d1"
		    "dice-d8" "\uf6d2"
		    "dice-five" "\uf523"
		    "dice-four" "\uf524"
		    "dice-one" "\uf525"
		    "dice-six" "\uf526"
		    "dice-three" "\uf527"
		    "dice-two" "\uf528"
		    "dinosaur" "\ue5fe"
		    "diploma" "\uf5ea"
		    "disc-drive" "\uf8b5"
		    "disease" "\uf7fa"
		    "display" "\ue163"
		    "display-arrow-down" "\ue164"
		    "display-chart-up" "\ue5e3"
		    "display-chart-up-circle-currency" "\ue5e5"
		    "display-chart-up-circle-dollar" "\ue5e6"
		    "display-code" "\ue165"
		    "display-medical" "\ue166"
		    "display-slash" "\ue2fa"
		    "distribute-spacing-horizontal" "\ue365"
		    "distribute-spacing-vertical" "\ue366"
		    "ditto" "\u22"
		    "divide" "\uf529"
		    "dna" "\uf471"
		    "do-not-enter" "\uf5ec"
		    "dog" "\uf6d3"
		    "dog-leashed" "\uf6d4"
		    "dollar-sign" "\u24"
		    "dolly" "\uf472"
		    "dolly-empty" "\uf473"
		    "dolphin" "\ue168"
		    "dong-sign" "\ue169"
		    "donut" "\ue406"
		    "door-closed" "\uf52a"
		    "door-open" "\uf52b"
		    "dove" "\uf4ba"
		    "down" "\uf354"
		    "down-from-dotted-line" "\ue407"
		    "down-from-line" "\uf349"
		    "down-left" "\ue16a"
		    "down-left-and-up-right-to-center" "\uf422"
		    "down-long" "\uf309"
		    "down-right" "\ue16b"
		    "down-to-bracket" "\ue4e7"
		    "down-to-dotted-line" "\ue408"
		    "down-to-line" "\uf34a"
		    "download" "\uf019"
		    "dragon" "\uf6d5"
		    "draw-circle" "\uf5ed"
		    "draw-polygon" "\uf5ee"
		    "draw-square" "\uf5ef"
		    "dreidel" "\uf792"
		    "drone" "\uf85f"
		    "drone-front" "\uf860"
		    "droplet" "\uf043"
		    "droplet-degree" "\uf748"
		    "droplet-percent" "\uf750"
		    "droplet-slash" "\uf5c7"
		    "drum" "\uf569"
		    "drum-steelpan" "\uf56a"
		    "drumstick" "\uf6d6"
		    "drumstick-bite" "\uf6d7"
		    "dryer" "\uf861"
		    "dryer-heat" "\uf862"
		    "duck" "\uf6d8"
		    "dumbbell" "\uf44b"
		    "dumpster" "\uf793"
		    "dumpster-fire" "\uf794"
		    "dungeon" "\uf6d9"
		    "e" "\u45"
		    "ear" "\uf5f0"
		    "ear-deaf" "\uf2a4"
		    "ear-listen" "\uf2a2"
		    "ear-muffs" "\uf795"
		    "earth-africa" "\uf57c"
		    "earth-americas" "\uf57d"
		    "earth-asia" "\uf57e"
		    "earth-europe" "\uf7a2"
		    "earth-oceania" "\ue47b"
		    "eclipse" "\uf749"
		    "egg" "\uf7fb"
		    "egg-fried" "\uf7fc"
		    "eggplant" "\ue16c"
		    "eject" "\uf052"
		    "elephant" "\uf6da"
		    "elevator" "\ue16d"
		    "ellipsis" "\uf141"
		    "ellipsis-stroke" "\uf39b"
		    "ellipsis-stroke-vertical" "\uf39c"
		    "ellipsis-vertical" "\uf142"
		    "empty-set" "\uf656"
		    "engine" "\ue16e"
		    "engine-warning" "\uf5f2"
		    "envelope" "\uf0e0"
		    "envelope-circle-check" "\ue4e8"
		    "envelope-dot" "\ue16f"
		    "envelope-open" "\uf2b6"
		    "envelope-open-dollar" "\uf657"
		    "envelope-open-text" "\uf658"
		    "envelopes" "\ue170"
		    "envelopes-bulk" "\uf674"
		    "equals" "\u3d"
		    "eraser" "\uf12d"
		    "escalator" "\ue171"
		    "ethernet" "\uf796"
		    "euro-sign" "\uf153"
		    "excavator" "\ue656"
		    "exclamation" "\u21"
		    "expand" "\uf065"
		    "expand-wide" "\uf320"
		    "explosion" "\ue4e9"
		    "eye" "\uf06e"
		    "eye-dropper" "\uf1fb"
		    "eye-dropper-full" "\ue172"
		    "eye-dropper-half" "\ue173"
		    "eye-evil" "\uf6db"
		    "eye-low-vision" "\uf2a8"
		    "eye-slash" "\uf070"
		    "eyes" "\ue367"
		    "f" "\u46"
		    "face-angry" "\uf556"
		    "face-angry-horns" "\ue368"
		    "face-anguished" "\ue369"
		    "face-anxious-sweat" "\ue36a"
		    "face-astonished" "\ue36b"
		    "face-awesome" "\ue409"
		    "face-beam-hand-over-mouth" "\ue47c"
		    "face-clouds" "\ue47d"
		    "face-confounded" "\ue36c"
		    "face-confused" "\ue36d"
		    "face-cowboy-hat" "\ue36e"
		    "face-diagonal-mouth" "\ue47e"
		    "face-disappointed" "\ue36f"
		    "face-disguise" "\ue370"
		    "face-dizzy" "\uf567"
		    "face-dotted" "\ue47f"
		    "face-downcast-sweat" "\ue371"
		    "face-drooling" "\ue372"
		    "face-exhaling" "\ue480"
		    "face-explode" "\ue2fe"
		    "face-expressionless" "\ue373"
		    "face-eyes-xmarks" "\ue374"
		    "face-fearful" "\ue375"
		    "face-flushed" "\uf579"
		    "face-frown" "\uf119"
		    "face-frown-open" "\uf57a"
		    "face-frown-slight" "\ue376"
		    "face-glasses" "\ue377"
		    "face-grimace" "\uf57f"
		    "face-grin" "\uf580"
		    "face-grin-beam" "\uf582"
		    "face-grin-beam-sweat" "\uf583"
		    "face-grin-hearts" "\uf584"
		    "face-grin-squint" "\uf585"
		    "face-grin-squint-tears" "\uf586"
		    "face-grin-stars" "\uf587"
		    "face-grin-tears" "\uf588"
		    "face-grin-tongue" "\uf589"
		    "face-grin-tongue-squint" "\uf58a"
		    "face-grin-tongue-wink" "\uf58b"
		    "face-grin-wide" "\uf581"
		    "face-grin-wink" "\uf58c"
		    "face-hand-over-mouth" "\ue378"
		    "face-hand-peeking" "\ue481"
		    "face-hand-yawn" "\ue379"
		    "face-head-bandage" "\ue37a"
		    "face-holding-back-tears" "\ue482"
		    "face-hushed" "\ue37b"
		    "face-icicles" "\ue37c"
		    "face-kiss" "\uf596"
		    "face-kiss-beam" "\uf597"
		    "face-kiss-closed-eyes" "\ue37d"
		    "face-kiss-wink-heart" "\uf598"
		    "face-laugh" "\uf599"
		    "face-laugh-beam" "\uf59a"
		    "face-laugh-squint" "\uf59b"
		    "face-laugh-wink" "\uf59c"
		    "face-lying" "\ue37e"
		    "face-mask" "\ue37f"
		    "face-meh" "\uf11a"
		    "face-meh-blank" "\uf5a4"
		    "face-melting" "\ue483"
		    "face-monocle" "\ue380"
		    "face-nauseated" "\ue381"
		    "face-nose-steam" "\ue382"
		    "face-party" "\ue383"
		    "face-pensive" "\ue384"
		    "face-persevering" "\ue385"
		    "face-pleading" "\ue386"
		    "face-pouting" "\ue387"
		    "face-raised-eyebrow" "\ue388"
		    "face-relieved" "\ue389"
		    "face-rolling-eyes" "\uf5a5"
		    "face-sad-cry" "\uf5b3"
		    "face-sad-sweat" "\ue38a"
		    "face-sad-tear" "\uf5b4"
		    "face-saluting" "\ue484"
		    "face-scream" "\ue38b"
		    "face-shush" "\ue38c"
		    "face-sleeping" "\ue38d"
		    "face-sleepy" "\ue38e"
		    "face-smile" "\uf118"
		    "face-smile-beam" "\uf5b8"
		    "face-smile-halo" "\ue38f"
		    "face-smile-hearts" "\ue390"
		    "face-smile-horns" "\ue391"
		    "face-smile-plus" "\uf5b9"
		    "face-smile-relaxed" "\ue392"
		    "face-smile-tear" "\ue393"
		    "face-smile-tongue" "\ue394"
		    "face-smile-upside-down" "\ue395"
		    "face-smile-wink" "\uf4da"
		    "face-smiling-hands" "\ue396"
		    "face-smirking" "\ue397"
		    "face-spiral-eyes" "\ue485"
		    "face-sunglasses" "\ue398"
		    "face-surprise" "\uf5c2"
		    "face-swear" "\ue399"
		    "face-thermometer" "\ue39a"
		    "face-thinking" "\ue39b"
		    "face-tired" "\uf5c8"
		    "face-tissue" "\ue39c"
		    "face-tongue-money" "\ue39d"
		    "face-tongue-sweat" "\ue39e"
		    "face-unamused" "\ue39f"
		    "face-viewfinder" "\ue2ff"
		    "face-vomit" "\ue3a0"
		    "face-weary" "\ue3a1"
		    "face-woozy" "\ue3a2"
		    "face-worried" "\ue3a3"
		    "face-zany" "\ue3a4"
		    "face-zipper" "\ue3a5"
		    "falafel" "\ue40a"
		    "family" "\ue300"
		    "family-dress" "\ue301"
		    "family-pants" "\ue302"
		    "fan" "\uf863"
		    "fan-table" "\ue004"
		    "farm" "\uf864"
		    "faucet" "\ue005"
		    "faucet-drip" "\ue006"
		    "fax" "\uf1ac"
		    "feather" "\uf52d"
		    "feather-pointed" "\uf56b"
		    "fence" "\ue303"
		    "ferris-wheel" "\ue174"
		    "ferry" "\ue4ea"
		    "field-hockey-stick-ball" "\uf44c"
		    "file" "\uf15b"
		    "file-arrow-down" "\uf56d"
		    "file-arrow-up" "\uf574"
		    "file-audio" "\uf1c7"
		    "file-binary" "\ue175"
		    "file-certificate" "\uf5f3"
		    "file-chart-column" "\uf659"
		    "file-chart-pie" "\uf65a"
		    "file-check" "\uf316"
		    "file-circle-check" "\ue5a0"
		    "file-circle-exclamation" "\ue4eb"
		    "file-circle-info" "\ue493"
		    "file-circle-minus" "\ue4ed"
		    "file-circle-plus" "\ue494"
		    "file-circle-question" "\ue4ef"
		    "file-circle-xmark" "\ue5a1"
		    "file-code" "\uf1c9"
		    "file-contract" "\uf56c"
		    "file-csv" "\uf6dd"
		    "file-dashed-line" "\uf877"
		    "file-doc" "\ue5ed"
		    "file-eps" "\ue644"
		    "file-excel" "\uf1c3"
		    "file-exclamation" "\uf31a"
		    "file-export" "\uf56e"
		    "file-gif" "\ue645"
		    "file-heart" "\ue176"
		    "file-image" "\uf1c5"
		    "file-import" "\uf56f"
		    "file-invoice" "\uf570"
		    "file-invoice-dollar" "\uf571"
		    "file-jpg" "\ue646"
		    "file-lines" "\uf15c"
		    "file-lock" "\ue3a6"
		    "file-magnifying-glass" "\uf865"
		    "file-medical" "\uf477"
		    "file-minus" "\uf318"
		    "file-mov" "\ue647"
		    "file-mp3" "\ue648"
		    "file-mp4" "\ue649"
		    "file-music" "\uf8b6"
		    "file-pdf" "\uf1c1"
		    "file-pen" "\uf31c"
		    "file-plus" "\uf319"
		    "file-plus-minus" "\ue177"
		    "file-png" "\ue666"
		    "file-powerpoint" "\uf1c4"
		    "file-ppt" "\ue64a"
		    "file-prescription" "\uf572"
		    "file-shield" "\ue4f0"
		    "file-signature" "\uf573"
		    "file-slash" "\ue3a7"
		    "file-spreadsheet" "\uf65b"
		    "file-svg" "\ue64b"
		    "file-user" "\uf65c"
		    "file-vector" "\ue64c"
		    "file-video" "\uf1c8"
		    "file-waveform" "\uf478"
		    "file-word" "\uf1c2"
		    "file-xls" "\ue64d"
		    "file-xmark" "\uf317"
		    "file-xml" "\ue654"
		    "file-zip" "\ue5ee"
		    "file-zipper" "\uf1c6"
		    "files" "\ue178"
		    "files-medical" "\uf7fd"
		    "fill" "\uf575"
		    "fill-drip" "\uf576"
		    "film" "\uf008"
		    "film-canister" "\uf8b7"
		    "film-simple" "\uf3a0"
		    "film-slash" "\ue179"
		    "films" "\ue17a"
		    "filter" "\uf0b0"
		    "filter-circle-dollar" "\uf662"
		    "filter-circle-xmark" "\ue17b"
		    "filter-list" "\ue17c"
		    "filter-slash" "\ue17d"
		    "filters" "\ue17e"
		    "fingerprint" "\uf577"
		    "fire" "\uf06d"
		    "fire-burner" "\ue4f1"
		    "fire-extinguisher" "\uf134"
		    "fire-flame" "\uf6df"
		    "fire-flame-curved" "\uf7e4"
		    "fire-flame-simple" "\uf46a"
		    "fire-hydrant" "\ue17f"
		    "fire-smoke" "\uf74b"
		    "fireplace" "\uf79a"
		    "fish" "\uf578"
		    "fish-bones" "\ue304"
		    "fish-cooked" "\uf7fe"
		    "fish-fins" "\ue4f2"
		    "fishing-rod" "\ue3a8"
		    "flag" "\uf024"
		    "flag-checkered" "\uf11e"
		    "flag-pennant" "\uf456"
		    "flag-swallowtail" "\uf74c"
		    "flag-usa" "\uf74d"
		    "flashlight" "\uf8b8"
		    "flask" "\uf0c3"
		    "flask-gear" "\ue5f1"
		    "flask-round-poison" "\uf6e0"
		    "flask-round-potion" "\uf6e1"
		    "flask-vial" "\ue4f3"
		    "flatbread" "\ue40b"
		    "flatbread-stuffed" "\ue40c"
		    "floppy-disk" "\uf0c7"
		    "floppy-disk-circle-arrow-right" "\ue180"
		    "floppy-disk-circle-xmark" "\ue181"
		    "floppy-disk-pen" "\ue182"
		    "floppy-disks" "\ue183"
		    "florin-sign" "\ue184"
		    "flower" "\uf7ff"
		    "flower-daffodil" "\uf800"
		    "flower-tulip" "\uf801"
		    "flute" "\uf8b9"
		    "flux-capacitor" "\uf8ba"
		    "flying-disc" "\ue3a9"
		    "folder" "\uf07b"
		    "folder-arrow-down" "\ue053"
		    "folder-arrow-up" "\ue054"
		    "folder-bookmark" "\ue186"
		    "folder-check" "\ue64e"
		    "folder-closed" "\ue185"
		    "folder-gear" "\ue187"
		    "folder-grid" "\ue188"
		    "folder-heart" "\ue189"
		    "folder-image" "\ue18a"
		    "folder-magnifying-glass" "\ue18b"
		    "folder-medical" "\ue18c"
		    "folder-minus" "\uf65d"
		    "folder-music" "\ue18d"
		    "folder-open" "\uf07c"
		    "folder-plus" "\uf65e"
		    "folder-tree" "\uf802"
		    "folder-user" "\ue18e"
		    "folder-xmark" "\uf65f"
		    "folders" "\uf660"
		    "fondue-pot" "\ue40d"
		    "font" "\uf031"
		    "font-awesome" "\uf2b4"
		    "font-case" "\uf866"
		    "football" "\uf44e"
		    "football-helmet" "\uf44f"
		    "fork" "\uf2e3"
		    "fork-knife" "\uf2e6"
		    "forklift" "\uf47a"
		    "fort" "\ue486"
		    "forward" "\uf04e"
		    "forward-fast" "\uf050"
		    "forward-step" "\uf051"
		    "frame" "\ue495"
		    "franc-sign" "\ue18f"
		    "french-fries" "\uf803"
		    "frog" "\uf52e"
		    "function" "\uf661"
		    "futbol" "\uf1e3"
		    "g" "\u47"
		    "galaxy" "\ue008"
		    "gallery-thumbnails" "\ue3aa"
		    "game-board" "\uf867"
		    "game-board-simple" "\uf868"
		    "game-console-handheld" "\uf8bb"
		    "game-console-handheld-crank" "\ue5b9"
		    "gamepad" "\uf11b"
		    "gamepad-modern" "\ue5a2"
		    "garage" "\ue009"
		    "garage-car" "\ue00a"
		    "garage-open" "\ue00b"
		    "garlic" "\ue40e"
		    "gas-pump" "\uf52f"
		    "gas-pump-slash" "\uf5f4"
		    "gauge" "\uf624"
		    "gauge-circle-bolt" "\ue496"
		    "gauge-circle-minus" "\ue497"
		    "gauge-circle-plus" "\ue498"
		    "gauge-high" "\uf625"
		    "gauge-low" "\uf627"
		    "gauge-max" "\uf626"
		    "gauge-min" "\uf628"
		    "gauge-simple" "\uf629"
		    "gauge-simple-high" "\uf62a"
		    "gauge-simple-low" "\uf62c"
		    "gauge-simple-max" "\uf62b"
		    "gauge-simple-min" "\uf62d"
		    "gavel" "\uf0e3"
		    "gear" "\uf013"
		    "gear-code" "\ue5e8"
		    "gear-complex" "\ue5e9"
		    "gear-complex-code" "\ue5eb"
		    "gears" "\uf085"
		    "gem" "\uf3a5"
		    "genderless" "\uf22d"
		    "ghost" "\uf6e2"
		    "gif" "\ue190"
		    "gift" "\uf06b"
		    "gift-card" "\uf663"
		    "gifts" "\uf79c"
		    "gingerbread-man" "\uf79d"
		    "glass" "\uf804"
		    "glass-citrus" "\uf869"
		    "glass-empty" "\ue191"
		    "glass-half" "\ue192"
		    "glass-water" "\ue4f4"
		    "glass-water-droplet" "\ue4f5"
		    "glasses" "\uf530"
		    "glasses-round" "\uf5f5"
		    "globe" "\uf0ac"
		    "globe-pointer" "\ue60e"
		    "globe-snow" "\uf7a3"
		    "globe-stand" "\uf5f6"
		    "goal-net" "\ue3ab"
		    "golf-ball-tee" "\uf450"
		    "golf-club" "\uf451"
		    "golf-flag-hole" "\ue3ac"
		    "gopuram" "\uf664"
		    "graduation-cap" "\uf19d"
		    "gramophone" "\uf8bd"
		    "grapes" "\ue306"
		    "grate" "\ue193"
		    "grate-droplet" "\ue194"
		    "greater-than" "\u3e"
		    "greater-than-equal" "\uf532"
		    "grid" "\ue195"
		    "grid-2" "\ue196"
		    "grid-2-plus" "\ue197"
		    "grid-4" "\ue198"
		    "grid-5" "\ue199"
		    "grid-dividers" "\ue3ad"
		    "grid-horizontal" "\ue307"
		    "grid-round" "\ue5da"
		    "grid-round-2" "\ue5db"
		    "grid-round-2-plus" "\ue5dc"
		    "grid-round-4" "\ue5dd"
		    "grid-round-5" "\ue5de"
		    "grill" "\ue5a3"
		    "grill-fire" "\ue5a4"
		    "grill-hot" "\ue5a5"
		    "grip" "\uf58d"
		    "grip-dots" "\ue410"
		    "grip-dots-vertical" "\ue411"
		    "grip-lines" "\uf7a4"
		    "grip-lines-vertical" "\uf7a5"
		    "grip-vertical" "\uf58e"
		    "group-arrows-rotate" "\ue4f6"
		    "guarani-sign" "\ue19a"
		    "guitar" "\uf7a6"
		    "guitar-electric" "\uf8be"
		    "guitars" "\uf8bf"
		    "gun" "\ue19b"
		    "gun-slash" "\ue19c"
		    "gun-squirt" "\ue19d"
		    "h" "\u48"
		    "h1" "\uf313"
		    "h2" "\uf314"
		    "h3" "\uf315"
		    "h4" "\uf86a"
		    "h5" "\ue412"
		    "h6" "\ue413"
		    "hammer" "\uf6e3"
		    "hammer-brush" "\ue620"
		    "hammer-crash" "\ue414"
		    "hammer-war" "\uf6e4"
		    "hamsa" "\uf665"
		    "hand" "\uf256"
		    "hand-back-fist" "\uf255"
		    "hand-back-point-down" "\ue19e"
		    "hand-back-point-left" "\ue19f"
		    "hand-back-point-ribbon" "\ue1a0"
		    "hand-back-point-right" "\ue1a1"
		    "hand-back-point-up" "\ue1a2"
		    "hand-dots" "\uf461"
		    "hand-fingers-crossed" "\ue1a3"
		    "hand-fist" "\uf6de"
		    "hand-heart" "\uf4bc"
		    "hand-holding" "\uf4bd"
		    "hand-holding-box" "\uf47b"
		    "hand-holding-circle-dollar" "\ue621"
		    "hand-holding-dollar" "\uf4c0"
		    "hand-holding-droplet" "\uf4c1"
		    "hand-holding-hand" "\ue4f7"
		    "hand-holding-heart" "\uf4be"
		    "hand-holding-magic" "\uf6e5"
		    "hand-holding-medical" "\ue05c"
		    "hand-holding-seedling" "\uf4bf"
		    "hand-holding-skull" "\ue1a4"
		    "hand-horns" "\ue1a9"
		    "hand-lizard" "\uf258"
		    "hand-love" "\ue1a5"
		    "hand-middle-finger" "\uf806"
		    "hand-peace" "\uf25b"
		    "hand-point-down" "\uf0a7"
		    "hand-point-left" "\uf0a5"
		    "hand-point-ribbon" "\ue1a6"
		    "hand-point-right" "\uf0a4"
		    "hand-point-up" "\uf0a6"
		    "hand-pointer" "\uf25a"
		    "hand-scissors" "\uf257"
		    "hand-sparkles" "\ue05d"
		    "hand-spock" "\uf259"
		    "hand-wave" "\ue1a7"
		    "handcuffs" "\ue4f8"
		    "hands" "\uf2a7"
		    "hands-asl-interpreting" "\uf2a3"
		    "hands-bound" "\ue4f9"
		    "hands-bubbles" "\ue05e"
		    "hands-clapping" "\ue1a8"
		    "hands-holding" "\uf4c2"
		    "hands-holding-child" "\ue4fa"
		    "hands-holding-circle" "\ue4fb"
		    "hands-holding-diamond" "\uf47c"
		    "hands-holding-dollar" "\uf4c5"
		    "hands-holding-heart" "\uf4c3"
		    "hands-praying" "\uf684"
		    "handshake" "\uf2b5"
		    "handshake-angle" "\uf4c4"
		    "handshake-simple" "\uf4c6"
		    "handshake-simple-slash" "\ue05f"
		    "handshake-slash" "\ue060"
		    "hanukiah" "\uf6e6"
		    "hard-drive" "\uf0a0"
		    "hashtag" "\u23"
		    "hashtag-lock" "\ue415"
		    "hat-beach" "\ue606"
		    "hat-chef" "\uf86b"
		    "hat-cowboy" "\uf8c0"
		    "hat-cowboy-side" "\uf8c1"
		    "hat-santa" "\uf7a7"
		    "hat-winter" "\uf7a8"
		    "hat-witch" "\uf6e7"
		    "hat-wizard" "\uf6e8"
		    "head-side" "\uf6e9"
		    "head-side-brain" "\uf808"
		    "head-side-cough" "\ue061"
		    "head-side-cough-slash" "\ue062"
		    "head-side-gear" "\ue611"
		    "head-side-goggles" "\uf6ea"
		    "head-side-headphones" "\uf8c2"
		    "head-side-heart" "\ue1aa"
		    "head-side-mask" "\ue063"
		    "head-side-medical" "\uf809"
		    "head-side-virus" "\ue064"
		    "heading" "\uf1dc"
		    "headphones" "\uf025"
		    "headphones-simple" "\uf58f"
		    "headset" "\uf590"
		    "heart" "\uf004"
		    "heart-circle-bolt" "\ue4fc"
		    "heart-circle-check" "\ue4fd"
		    "heart-circle-exclamation" "\ue4fe"
		    "heart-circle-minus" "\ue4ff"
		    "heart-circle-plus" "\ue500"
		    "heart-circle-xmark" "\ue501"
		    "heart-crack" "\uf7a9"
		    "heart-half" "\ue1ab"
		    "heart-half-stroke" "\ue1ac"
		    "heart-pulse" "\uf21e"
		    "heat" "\ue00c"
		    "helicopter" "\uf533"
		    "helicopter-symbol" "\ue502"
		    "helmet-battle" "\uf6eb"
		    "helmet-safety" "\uf807"
		    "helmet-un" "\ue503"
		    "hexagon" "\uf312"
		    "hexagon-check" "\ue416"
		    "hexagon-divide" "\ue1ad"
		    "hexagon-exclamation" "\ue417"
		    "hexagon-image" "\ue504"
		    "hexagon-minus" "\uf307"
		    "hexagon-plus" "\uf300"
		    "hexagon-vertical-nft" "\ue505"
		    "hexagon-vertical-nft-slanted" "\ue506"
		    "hexagon-xmark" "\uf2ee"
		    "high-definition" "\ue1ae"
		    "highlighter" "\uf591"
		    "highlighter-line" "\ue1af"
		    "hill-avalanche" "\ue507"
		    "hill-rockslide" "\ue508"
		    "hippo" "\uf6ed"
		    "hockey-mask" "\uf6ee"
		    "hockey-puck" "\uf453"
		    "hockey-stick-puck" "\ue3ae"
		    "hockey-sticks" "\uf454"
		    "holly-berry" "\uf7aa"
		    "honey-pot" "\ue418"
		    "hood-cloak" "\uf6ef"
		    "horizontal-rule" "\uf86c"
		    "horse" "\uf6f0"
		    "horse-head" "\uf7ab"
		    "horse-saddle" "\uf8c3"
		    "hose" "\ue419"
		    "hose-reel" "\ue41a"
		    "hospital" "\uf0f8"
		    "hospital-user" "\uf80d"
		    "hospitals" "\uf80e"
		    "hot-tub-person" "\uf593"
		    "hotdog" "\uf80f"
		    "hotel" "\uf594"
		    "hourglass" "\uf254"
		    "hourglass-clock" "\ue41b"
		    "hourglass-end" "\uf253"
		    "hourglass-half" "\uf252"
		    "hourglass-start" "\uf251"
		    "house" "\uf015"
		    "house-blank" "\ue487"
		    "house-building" "\ue1b1"
		    "house-chimney" "\ue3af"
		    "house-chimney-blank" "\ue3b0"
		    "house-chimney-crack" "\uf6f1"
		    "house-chimney-heart" "\ue1b2"
		    "house-chimney-medical" "\uf7f2"
		    "house-chimney-user" "\ue065"
		    "house-chimney-window" "\ue00d"
		    "house-circle-check" "\ue509"
		    "house-circle-exclamation" "\ue50a"
		    "house-circle-xmark" "\ue50b"
		    "house-crack" "\ue3b1"
		    "house-day" "\ue00e"
		    "house-fire" "\ue50c"
		    "house-flag" "\ue50d"
		    "house-flood-water" "\ue50e"
		    "house-flood-water-circle-arrow-right" "\ue50f"
		    "house-heart" "\uf4c9"
		    "house-laptop" "\ue066"
		    "house-lock" "\ue510"
		    "house-medical" "\ue3b2"
		    "house-medical-circle-check" "\ue511"
		    "house-medical-circle-exclamation" "\ue512"
		    "house-medical-circle-xmark" "\ue513"
		    "house-medical-flag" "\ue514"
		    "house-night" "\ue010"
		    "house-person-leave" "\ue00f"
		    "house-person-return" "\ue011"
		    "house-signal" "\ue012"
		    "house-tree" "\ue1b3"
		    "house-tsunami" "\ue515"
		    "house-turret" "\ue1b4"
		    "house-user" "\ue1b0"
		    "house-water" "\uf74f"
		    "house-window" "\ue3b3"
		    "hryvnia-sign" "\uf6f2"
		    "hundred-points" "\ue41c"
		    "hurricane" "\uf751"
		    "hyphen" "\u2d"
		    "i" "\u49"
		    "i-cursor" "\uf246"
		    "ice-cream" "\uf810"
		    "ice-skate" "\uf7ac"
		    "icicles" "\uf7ad"
		    "icons" "\uf86d"
		    "id-badge" "\uf2c1"
		    "id-card" "\uf2c2"
		    "id-card-clip" "\uf47f"
		    "igloo" "\uf7ae"
		    "image" "\uf03e"
		    "image-landscape" "\ue1b5"
		    "image-polaroid" "\uf8c4"
		    "image-polaroid-user" "\ue1b6"
		    "image-portrait" "\uf3e0"
		    "image-slash" "\ue1b7"
		    "image-user" "\ue1b8"
		    "images" "\uf302"
		    "images-user" "\ue1b9"
		    "inbox" "\uf01c"
		    "inbox-full" "\ue1ba"
		    "inbox-in" "\uf310"
		    "inbox-out" "\uf311"
		    "inboxes" "\ue1bb"
		    "indent" "\uf03c"
		    "indian-rupee-sign" "\ue1bc"
		    "industry" "\uf275"
		    "industry-windows" "\uf3b3"
		    "infinity" "\uf534"
		    "info" "\uf129"
		    "inhaler" "\uf5f9"
		    "input-numeric" "\ue1bd"
		    "input-pipe" "\ue1be"
		    "input-text" "\ue1bf"
		    "integral" "\uf667"
		    "interrobang" "\ue5ba"
		    "intersection" "\uf668"
		    "island-tropical" "\uf811"
		    "italic" "\uf033"
		    "j" "\u4a"
		    "jack-o-lantern" "\uf30e"
		    "jar" "\ue516"
		    "jar-wheat" "\ue517"
		    "jedi" "\uf669"
		    "jet-fighter" "\uf0fb"
		    "jet-fighter-up" "\ue518"
		    "joint" "\uf595"
		    "joystick" "\uf8c5"
		    "jug" "\uf8c6"
		    "jug-bottle" "\ue5fb"
		    "jug-detergent" "\ue519"
		    "k" "\u4b"
		    "kaaba" "\uf66b"
		    "kazoo" "\uf8c7"
		    "kerning" "\uf86f"
		    "key" "\uf084"
		    "key-skeleton" "\uf6f3"
		    "key-skeleton-left-right" "\ue3b4"
		    "keyboard" "\uf11c"
		    "keyboard-brightness" "\ue1c0"
		    "keyboard-brightness-low" "\ue1c1"
		    "keyboard-down" "\ue1c2"
		    "keyboard-left" "\ue1c3"
		    "keynote" "\uf66c"
		    "khanda" "\uf66d"
		    "kidneys" "\uf5fb"
		    "kip-sign" "\ue1c4"
		    "kit-medical" "\uf479"
		    "kitchen-set" "\ue51a"
		    "kite" "\uf6f4"
		    "kiwi-bird" "\uf535"
		    "kiwi-fruit" "\ue30c"
		    "knife" "\uf2e4"
		    "knife-kitchen" "\uf6f5"
		    "l" "\u4c"
		    "lacrosse-stick" "\ue3b5"
		    "lacrosse-stick-ball" "\ue3b6"
		    "lambda" "\uf66e"
		    "lamp" "\uf4ca"
		    "lamp-desk" "\ue014"
		    "lamp-floor" "\ue015"
		    "lamp-street" "\ue1c5"
		    "land-mine-on" "\ue51b"
		    "landmark" "\uf66f"
		    "landmark-dome" "\uf752"
		    "landmark-flag" "\ue51c"
		    "landmark-magnifying-glass" "\ue622"
		    "language" "\uf1ab"
		    "laptop" "\uf109"
		    "laptop-arrow-down" "\ue1c6"
		    "laptop-binary" "\ue5e7"
		    "laptop-code" "\uf5fc"
		    "laptop-file" "\ue51d"
		    "laptop-medical" "\uf812"
		    "laptop-mobile" "\uf87a"
		    "laptop-slash" "\ue1c7"
		    "lari-sign" "\ue1c8"
		    "lasso" "\uf8c8"
		    "lasso-sparkles" "\ue1c9"
		    "layer-group" "\uf5fd"
		    "layer-minus" "\uf5fe"
		    "layer-plus" "\uf5ff"
		    "leaf" "\uf06c"
		    "leaf-heart" "\uf4cb"
		    "leaf-maple" "\uf6f6"
		    "leaf-oak" "\uf6f7"
		    "leafy-green" "\ue41d"
		    "left" "\uf355"
		    "left-from-line" "\uf348"
		    "left-long" "\uf30a"
		    "left-long-to-line" "\ue41e"
		    "left-right" "\uf337"
		    "left-to-line" "\uf34b"
		    "lemon" "\uf094"
		    "less-than" "\u3c"
		    "less-than-equal" "\uf537"
		    "life-ring" "\uf1cd"
		    "light-ceiling" "\ue016"
		    "light-emergency" "\ue41f"
		    "light-emergency-on" "\ue420"
		    "light-switch" "\ue017"
		    "light-switch-off" "\ue018"
		    "light-switch-on" "\ue019"
		    "lightbulb" "\uf0eb"
		    "lightbulb-cfl" "\ue5a6"
		    "lightbulb-cfl-on" "\ue5a7"
		    "lightbulb-dollar" "\uf670"
		    "lightbulb-exclamation" "\uf671"
		    "lightbulb-exclamation-on" "\ue1ca"
		    "lightbulb-gear" "\ue5fd"
		    "lightbulb-on" "\uf672"
		    "lightbulb-slash" "\uf673"
		    "lighthouse" "\ue612"
		    "lights-holiday" "\uf7b2"
		    "line-columns" "\uf870"
		    "line-height" "\uf871"
		    "lines-leaning" "\ue51e"
		    "link" "\uf0c1"
		    "link-horizontal" "\ue1cb"
		    "link-horizontal-slash" "\ue1cc"
		    "link-simple" "\ue1cd"
		    "link-simple-slash" "\ue1ce"
		    "link-slash" "\uf127"
		    "lips" "\uf600"
		    "lira-sign" "\uf195"
		    "list" "\uf03a"
		    "list-check" "\uf0ae"
		    "list-dropdown" "\ue1cf"
		    "list-music" "\uf8c9"
		    "list-ol" "\uf0cb"
		    "list-radio" "\ue1d0"
		    "list-timeline" "\ue1d1"
		    "list-tree" "\ue1d2"
		    "list-ul" "\uf0ca"
		    "litecoin-sign" "\ue1d3"
		    "loader" "\ue1d4"
		    "lobster" "\ue421"
		    "location-arrow" "\uf124"
		    "location-arrow-up" "\ue63a"
		    "location-check" "\uf606"
		    "location-crosshairs" "\uf601"
		    "location-crosshairs-slash" "\uf603"
		    "location-dot" "\uf3c5"
		    "location-dot-slash" "\uf605"
		    "location-exclamation" "\uf608"
		    "location-minus" "\uf609"
		    "location-pen" "\uf607"
		    "location-pin" "\uf041"
		    "location-pin-lock" "\ue51f"
		    "location-pin-slash" "\uf60c"
		    "location-plus" "\uf60a"
		    "location-question" "\uf60b"
		    "location-smile" "\uf60d"
		    "location-xmark" "\uf60e"
		    "lock" "\uf023"
		    "lock-a" "\ue422"
		    "lock-hashtag" "\ue423"
		    "lock-keyhole" "\uf30d"
		    "lock-keyhole-open" "\uf3c2"
		    "lock-open" "\uf3c1"
		    "locust" "\ue520"
		    "lollipop" "\ue424"
		    "loveseat" "\uf4cc"
		    "luchador-mask" "\uf455"
		    "lungs" "\uf604"
		    "lungs-virus" "\ue067"
		    "m" "\u4d"
		    "mace" "\uf6f8"
		    "magnet" "\uf076"
		    "magnifying-glass" "\uf002"
		    "magnifying-glass-arrow-right" "\ue521"
		    "magnifying-glass-arrows-rotate" "\ue65e"
		    "magnifying-glass-chart" "\ue522"
		    "magnifying-glass-dollar" "\uf688"
		    "magnifying-glass-location" "\uf689"
		    "magnifying-glass-minus" "\uf010"
		    "magnifying-glass-music" "\ue65f"
		    "magnifying-glass-play" "\ue660"
		    "magnifying-glass-plus" "\uf00e"
		    "magnifying-glass-waveform" "\ue661"
		    "mailbox" "\uf813"
		    "mailbox-flag-up" "\ue5bb"
		    "manat-sign" "\ue1d5"
		    "mandolin" "\uf6f9"
		    "mango" "\ue30f"
		    "manhole" "\ue1d6"
		    "map" "\uf279"
		    "map-location" "\uf59f"
		    "map-location-dot" "\uf5a0"
		    "map-pin" "\uf276"
		    "marker" "\uf5a1"
		    "mars" "\uf222"
		    "mars-and-venus" "\uf224"
		    "mars-and-venus-burst" "\ue523"
		    "mars-double" "\uf227"
		    "mars-stroke" "\uf229"
		    "mars-stroke-right" "\uf22b"
		    "mars-stroke-up" "\uf22a"
		    "martini-glass" "\uf57b"
		    "martini-glass-citrus" "\uf561"
		    "martini-glass-empty" "\uf000"
		    "mask" "\uf6fa"
		    "mask-face" "\ue1d7"
		    "mask-snorkel" "\ue3b7"
		    "mask-ventilator" "\ue524"
		    "masks-theater" "\uf630"
		    "mattress-pillow" "\ue525"
		    "maximize" "\uf31e"
		    "meat" "\uf814"
		    "medal" "\uf5a2"
		    "megaphone" "\uf675"
		    "melon" "\ue310"
		    "melon-slice" "\ue311"
		    "memo" "\ue1d8"
		    "memo-circle-check" "\ue1d9"
		    "memo-circle-info" "\ue49a"
		    "memo-pad" "\ue1da"
		    "memory" "\uf538"
		    "menorah" "\uf676"
		    "mercury" "\uf223"
		    "merge" "\ue526"
		    "message" "\uf27a"
		    "message-arrow-down" "\ue1db"
		    "message-arrow-up" "\ue1dc"
		    "message-arrow-up-right" "\ue1dd"
		    "message-bot" "\ue3b8"
		    "message-captions" "\ue1de"
		    "message-check" "\uf4a2"
		    "message-code" "\ue1df"
		    "message-dollar" "\uf650"
		    "message-dots" "\uf4a3"
		    "message-exclamation" "\uf4a5"
		    "message-heart" "\ue5c9"
		    "message-image" "\ue1e0"
		    "message-lines" "\uf4a6"
		    "message-medical" "\uf7f4"
		    "message-middle" "\ue1e1"
		    "message-middle-top" "\ue1e2"
		    "message-minus" "\uf4a7"
		    "message-music" "\uf8af"
		    "message-pen" "\uf4a4"
		    "message-plus" "\uf4a8"
		    "message-question" "\ue1e3"
		    "message-quote" "\ue1e4"
		    "message-slash" "\uf4a9"
		    "message-smile" "\uf4aa"
		    "message-sms" "\ue1e5"
		    "message-text" "\ue1e6"
		    "message-xmark" "\uf4ab"
		    "messages" "\uf4b6"
		    "messages-dollar" "\uf652"
		    "messages-question" "\ue1e7"
		    "meteor" "\uf753"
		    "meter" "\ue1e8"
		    "meter-bolt" "\ue1e9"
		    "meter-droplet" "\ue1ea"
		    "meter-fire" "\ue1eb"
		    "microchip" "\uf2db"
		    "microchip-ai" "\ue1ec"
		    "microphone" "\uf130"
		    "microphone-lines" "\uf3c9"
		    "microphone-lines-slash" "\uf539"
		    "microphone-slash" "\uf131"
		    "microphone-stand" "\uf8cb"
		    "microscope" "\uf610"
		    "microwave" "\ue01b"
		    "mill-sign" "\ue1ed"
		    "minimize" "\uf78c"
		    "minus" "\uf068"
		    "mistletoe" "\uf7b4"
		    "mitten" "\uf7b5"
		    "mobile" "\uf3ce"
		    "mobile-button" "\uf10b"
		    "mobile-notch" "\ue1ee"
		    "mobile-retro" "\ue527"
		    "mobile-screen" "\uf3cf"
		    "mobile-screen-button" "\uf3cd"
		    "mobile-signal" "\ue1ef"
		    "mobile-signal-out" "\ue1f0"
		    "money-bill" "\uf0d6"
		    "money-bill-1" "\uf3d1"
		    "money-bill-1-wave" "\uf53b"
		    "money-bill-simple" "\ue1f1"
		    "money-bill-simple-wave" "\ue1f2"
		    "money-bill-transfer" "\ue528"
		    "money-bill-trend-up" "\ue529"
		    "money-bill-wave" "\uf53a"
		    "money-bill-wheat" "\ue52a"
		    "money-bills" "\ue1f3"
		    "money-bills-simple" "\ue1f4"
		    "money-check" "\uf53c"
		    "money-check-dollar" "\uf53d"
		    "money-check-dollar-pen" "\uf873"
		    "money-check-pen" "\uf872"
		    "money-from-bracket" "\ue312"
		    "money-simple-from-bracket" "\ue313"
		    "monitor-waveform" "\uf611"
		    "monkey" "\uf6fb"
		    "monument" "\uf5a6"
		    "moon" "\uf186"
		    "moon-cloud" "\uf754"
		    "moon-over-sun" "\uf74a"
		    "moon-stars" "\uf755"
		    "moped" "\ue3b9"
		    "mortar-pestle" "\uf5a7"
		    "mosque" "\uf678"
		    "mosquito" "\ue52b"
		    "mosquito-net" "\ue52c"
		    "motorcycle" "\uf21c"
		    "mound" "\ue52d"
		    "mountain" "\uf6fc"
		    "mountain-city" "\ue52e"
		    "mountain-sun" "\ue52f"
		    "mountains" "\uf6fd"
		    "mouse-field" "\ue5a8"
		    "mp3-player" "\uf8ce"
		    "mug" "\uf874"
		    "mug-hot" "\uf7b6"
		    "mug-marshmallows" "\uf7b7"
		    "mug-saucer" "\uf0f4"
		    "mug-tea" "\uf875"
		    "mug-tea-saucer" "\ue1f5"
		    "mushroom" "\ue425"
		    "music" "\uf001"
		    "music-magnifying-glass" "\ue662"
		    "music-note" "\uf8cf"
		    "music-note-slash" "\uf8d0"
		    "music-slash" "\uf8d1"
		    "mustache" "\ue5bc"
		    "n" "\u4e"
		    "naira-sign" "\ue1f6"
		    "narwhal" "\uf6fe"
		    "nesting-dolls" "\ue3ba"
		    "network-wired" "\uf6ff"
		    "neuter" "\uf22c"
		    "newspaper" "\uf1ea"
		    "nfc" "\ue1f7"
		    "nfc-lock" "\ue1f8"
		    "nfc-magnifying-glass" "\ue1f9"
		    "nfc-pen" "\ue1fa"
		    "nfc-signal" "\ue1fb"
		    "nfc-slash" "\ue1fc"
		    "nfc-symbol" "\ue531"
		    "nfc-trash" "\ue1fd"
		    "nose" "\ue5bd"
		    "not-equal" "\uf53e"
		    "notdef" "\ue1fe"
		    "note" "\ue1ff"
		    "note-medical" "\ue200"
		    "note-sticky" "\uf249"
		    "notebook" "\ue201"
		    "notes" "\ue202"
		    "notes-medical" "\uf481"
		    "o" "\u4f"
		    "object-exclude" "\ue49c"
		    "object-group" "\uf247"
		    "object-intersect" "\ue49d"
		    "object-subtract" "\ue49e"
		    "object-ungroup" "\uf248"
		    "object-union" "\ue49f"
		    "objects-align-bottom" "\ue3bb"
		    "objects-align-center-horizontal" "\ue3bc"
		    "objects-align-center-vertical" "\ue3bd"
		    "objects-align-left" "\ue3be"
		    "objects-align-right" "\ue3bf"
		    "objects-align-top" "\ue3c0"
		    "objects-column" "\ue3c1"
		    "octagon" "\uf306"
		    "octagon-check" "\ue426"
		    "octagon-divide" "\ue203"
		    "octagon-exclamation" "\ue204"
		    "octagon-minus" "\uf308"
		    "octagon-plus" "\uf301"
		    "octagon-xmark" "\uf2f0"
		    "oil-can" "\uf613"
		    "oil-can-drip" "\ue205"
		    "oil-temperature" "\uf614"
		    "oil-well" "\ue532"
		    "olive" "\ue316"
		    "olive-branch" "\ue317"
		    "om" "\uf679"
		    "omega" "\uf67a"
		    "onion" "\ue427"
		    "option" "\ue318"
		    "ornament" "\uf7b8"
		    "otter" "\uf700"
		    "outdent" "\uf03b"
		    "outlet" "\ue01c"
		    "oven" "\ue01d"
		    "overline" "\uf876"
		    "p" "\u50"
		    "page" "\ue428"
		    "page-caret-down" "\ue429"
		    "page-caret-up" "\ue42a"
		    "pager" "\uf815"
		    "paint-roller" "\uf5aa"
		    "paintbrush" "\uf1fc"
		    "paintbrush-fine" "\uf5a9"
		    "paintbrush-pencil" "\ue206"
		    "palette" "\uf53f"
		    "pallet" "\uf482"
		    "pallet-box" "\ue208"
		    "pallet-boxes" "\uf483"
		    "pan-food" "\ue42b"
		    "pan-frying" "\ue42c"
		    "pancakes" "\ue42d"
		    "panel-ews" "\ue42e"
		    "panel-fire" "\ue42f"
		    "panorama" "\ue209"
		    "paper-plane" "\uf1d8"
		    "paper-plane-top" "\ue20a"
		    "paperclip" "\uf0c6"
		    "paperclip-vertical" "\ue3c2"
		    "parachute-box" "\uf4cd"
		    "paragraph" "\uf1dd"
		    "paragraph-left" "\uf878"
		    "party-bell" "\ue31a"
		    "party-horn" "\ue31b"
		    "passport" "\uf5ab"
		    "paste" "\uf0ea"
		    "pause" "\uf04c"
		    "paw" "\uf1b0"
		    "paw-claws" "\uf702"
		    "paw-simple" "\uf701"
		    "peace" "\uf67c"
		    "peach" "\ue20b"
		    "peanut" "\ue430"
		    "peanuts" "\ue431"
		    "peapod" "\ue31c"
		    "pear" "\ue20c"
		    "pedestal" "\ue20d"
		    "pegasus" "\uf703"
		    "pen" "\uf304"
		    "pen-circle" "\ue20e"
		    "pen-clip" "\uf305"
		    "pen-clip-slash" "\ue20f"
		    "pen-fancy" "\uf5ac"
		    "pen-fancy-slash" "\ue210"
		    "pen-field" "\ue211"
		    "pen-line" "\ue212"
		    "pen-nib" "\uf5ad"
		    "pen-nib-slash" "\ue4a1"
		    "pen-paintbrush" "\uf618"
		    "pen-ruler" "\uf5ae"
		    "pen-slash" "\ue213"
		    "pen-swirl" "\ue214"
		    "pen-to-square" "\uf044"
		    "pencil" "\uf303"
		    "pencil-mechanical" "\ue5ca"
		    "pencil-slash" "\ue215"
		    "people" "\ue216"
		    "people-arrows" "\ue068"
		    "people-carry-box" "\uf4ce"
		    "people-dress" "\ue217"
		    "people-dress-simple" "\ue218"
		    "people-group" "\ue533"
		    "people-line" "\ue534"
		    "people-pants" "\ue219"
		    "people-pants-simple" "\ue21a"
		    "people-pulling" "\ue535"
		    "people-robbery" "\ue536"
		    "people-roof" "\ue537"
		    "people-simple" "\ue21b"
		    "pepper" "\ue432"
		    "pepper-hot" "\uf816"
		    "percent" "\u25"
		    "period" "\u2e"
		    "person" "\uf183"
		    "person-arrow-down-to-line" "\ue538"
		    "person-arrow-up-from-line" "\ue539"
		    "person-biking" "\uf84a"
		    "person-biking-mountain" "\uf84b"
		    "person-booth" "\uf756"
		    "person-breastfeeding" "\ue53a"
		    "person-burst" "\ue53b"
		    "person-cane" "\ue53c"
		    "person-carry-box" "\uf4cf"
		    "person-chalkboard" "\ue53d"
		    "person-circle-check" "\ue53e"
		    "person-circle-exclamation" "\ue53f"
		    "person-circle-minus" "\ue540"
		    "person-circle-plus" "\ue541"
		    "person-circle-question" "\ue542"
		    "person-circle-xmark" "\ue543"
		    "person-digging" "\uf85e"
		    "person-dolly" "\uf4d0"
		    "person-dolly-empty" "\uf4d1"
		    "person-dots-from-line" "\uf470"
		    "person-dress" "\uf182"
		    "person-dress-burst" "\ue544"
		    "person-dress-fairy" "\ue607"
		    "person-dress-simple" "\ue21c"
		    "person-drowning" "\ue545"
		    "person-fairy" "\ue608"
		    "person-falling" "\ue546"
		    "person-falling-burst" "\ue547"
		    "person-from-portal" "\ue023"
		    "person-half-dress" "\ue548"
		    "person-harassing" "\ue549"
		    "person-hiking" "\uf6ec"
		    "person-military-pointing" "\ue54a"
		    "person-military-rifle" "\ue54b"
		    "person-military-to-person" "\ue54c"
		    "person-pinball" "\ue21d"
		    "person-praying" "\uf683"
		    "person-pregnant" "\ue31e"
		    "person-rays" "\ue54d"
		    "person-rifle" "\ue54e"
		    "person-running" "\uf70c"
		    "person-running-fast" "\ue5ff"
		    "person-seat" "\ue21e"
		    "person-seat-reclined" "\ue21f"
		    "person-shelter" "\ue54f"
		    "person-sign" "\uf757"
		    "person-simple" "\ue220"
		    "person-skating" "\uf7c5"
		    "person-ski-jumping" "\uf7c7"
		    "person-ski-lift" "\uf7c8"
		    "person-skiing" "\uf7c9"
		    "person-skiing-nordic" "\uf7ca"
		    "person-sledding" "\uf7cb"
		    "person-snowboarding" "\uf7ce"
		    "person-snowmobiling" "\uf7d1"
		    "person-swimming" "\uf5c4"
		    "person-through-window" "\ue5a9"
		    "person-to-door" "\ue433"
		    "person-to-portal" "\ue022"
		    "person-walking" "\uf554"
		    "person-walking-arrow-loop-left" "\ue551"
		    "person-walking-arrow-right" "\ue552"
		    "person-walking-dashed-line-arrow-right" "\ue553"
		    "person-walking-luggage" "\ue554"
		    "person-walking-with-cane" "\uf29d"
		    "peseta-sign" "\ue221"
		    "peso-sign" "\ue222"
		    "phone" "\uf095"
		    "phone-arrow-down-left" "\ue223"
		    "phone-arrow-right" "\ue5be"
		    "phone-arrow-up-right" "\ue224"
		    "phone-flip" "\uf879"
		    "phone-hangup" "\ue225"
		    "phone-intercom" "\ue434"
		    "phone-missed" "\ue226"
		    "phone-office" "\uf67d"
		    "phone-plus" "\uf4d2"
		    "phone-rotary" "\uf8d3"
		    "phone-slash" "\uf3dd"
		    "phone-volume" "\uf2a0"
		    "phone-xmark" "\ue227"
		    "photo-film" "\uf87c"
		    "photo-film-music" "\ue228"
		    "pi" "\uf67e"
		    "piano" "\uf8d4"
		    "piano-keyboard" "\uf8d5"
		    "pickaxe" "\ue5bf"
		    "pickleball" "\ue435"
		    "pie" "\uf705"
		    "pig" "\uf706"
		    "piggy-bank" "\uf4d3"
		    "pills" "\uf484"
		    "pinata" "\ue3c3"
		    "pinball" "\ue229"
		    "pineapple" "\ue31f"
		    "pipe" "\u7c"
		    "pipe-circle-check" "\ue436"
		    "pipe-collar" "\ue437"
		    "pipe-section" "\ue438"
		    "pipe-smoking" "\ue3c4"
		    "pipe-valve" "\ue439"
		    "pizza" "\uf817"
		    "pizza-slice" "\uf818"
		    "place-of-worship" "\uf67f"
		    "plane" "\uf072"
		    "plane-arrival" "\uf5af"
		    "plane-circle-check" "\ue555"
		    "plane-circle-exclamation" "\ue556"
		    "plane-circle-xmark" "\ue557"
		    "plane-departure" "\uf5b0"
		    "plane-engines" "\uf3de"
		    "plane-lock" "\ue558"
		    "plane-prop" "\ue22b"
		    "plane-slash" "\ue069"
		    "plane-tail" "\ue22c"
		    "plane-up" "\ue22d"
		    "plane-up-slash" "\ue22e"
		    "planet-moon" "\ue01f"
		    "planet-ringed" "\ue020"
		    "plant-wilt" "\ue5aa"
		    "plate-utensils" "\ue43b"
		    "plate-wheat" "\ue55a"
		    "play" "\uf04b"
		    "play-pause" "\ue22f"
		    "plug" "\uf1e6"
		    "plug-circle-bolt" "\ue55b"
		    "plug-circle-check" "\ue55c"
		    "plug-circle-exclamation" "\ue55d"
		    "plug-circle-minus" "\ue55e"
		    "plug-circle-plus" "\ue55f"
		    "plug-circle-xmark" "\ue560"
		    "plus" "\u2b"
		    "plus-large" "\ue59e"
		    "plus-minus" "\ue43c"
		    "podcast" "\uf2ce"
		    "podium" "\uf680"
		    "podium-star" "\uf758"
		    "police-box" "\ue021"
		    "poll-people" "\uf759"
		    "pompebled" "\ue43d"
		    "poo" "\uf2fe"
		    "poo-storm" "\uf75a"
		    "pool-8-ball" "\ue3c5"
		    "poop" "\uf619"
		    "popcorn" "\uf819"
		    "popsicle" "\ue43e"
		    "pot-food" "\ue43f"
		    "potato" "\ue440"
		    "power-off" "\uf011"
		    "prescription" "\uf5b1"
		    "prescription-bottle" "\uf485"
		    "prescription-bottle-medical" "\uf486"
		    "prescription-bottle-pill" "\ue5c0"
		    "presentation-screen" "\uf685"
		    "pretzel" "\ue441"
		    "print" "\uf02f"
		    "print-magnifying-glass" "\uf81a"
		    "print-slash" "\uf686"
		    "projector" "\uf8d6"
		    "pump" "\ue442"
		    "pump-medical" "\ue06a"
		    "pump-soap" "\ue06b"
		    "pumpkin" "\uf707"
		    "puzzle" "\ue443"
		    "puzzle-piece" "\uf12e"
		    "puzzle-piece-simple" "\ue231"
		    "q" "\u51"
		    "qrcode" "\uf029"
		    "question" "\u3f"
		    "quote-left" "\uf10d"
		    "quote-right" "\uf10e"
		    "quotes" "\ue234"
		    "r" "\u52"
		    "rabbit" "\uf708"
		    "rabbit-running" "\uf709"
		    "raccoon" "\ue613"
		    "racquet" "\uf45a"
		    "radar" "\ue024"
		    "radiation" "\uf7b9"
		    "radio" "\uf8d7"
		    "radio-tuner" "\uf8d8"
		    "rainbow" "\uf75b"
		    "raindrops" "\uf75c"
		    "ram" "\uf70a"
		    "ramp-loading" "\uf4d4"
		    "ranking-star" "\ue561"
		    "raygun" "\ue025"
		    "receipt" "\uf543"
		    "record-vinyl" "\uf8d9"
		    "rectangle" "\uf2fa"
		    "rectangle-ad" "\uf641"
		    "rectangle-barcode" "\uf463"
		    "rectangle-code" "\ue322"
		    "rectangle-history" "\ue4a2"
		    "rectangle-history-circle-plus" "\ue4a3"
		    "rectangle-history-circle-user" "\ue4a4"
		    "rectangle-list" "\uf022"
		    "rectangle-pro" "\ue235"
		    "rectangle-terminal" "\ue236"
		    "rectangle-vertical" "\uf2fb"
		    "rectangle-vertical-history" "\ue237"
		    "rectangle-wide" "\uf2fc"
		    "rectangle-xmark" "\uf410"
		    "rectangles-mixed" "\ue323"
		    "recycle" "\uf1b8"
		    "reel" "\ue238"
		    "reflect-horizontal" "\ue664"
		    "reflect-vertical" "\ue665"
		    "refrigerator" "\ue026"
		    "registered" "\uf25d"
		    "repeat" "\uf363"
		    "repeat-1" "\uf365"
		    "reply" "\uf3e5"
		    "reply-all" "\uf122"
		    "reply-clock" "\ue239"
		    "republican" "\uf75e"
		    "restroom" "\uf7bd"
		    "restroom-simple" "\ue23a"
		    "retweet" "\uf079"
		    "rhombus" "\ue23b"
		    "ribbon" "\uf4d6"
		    "right" "\uf356"
		    "right-from-bracket" "\uf2f5"
		    "right-from-line" "\uf347"
		    "right-left" "\uf362"
		    "right-left-large" "\ue5e1"
		    "right-long" "\uf30b"
		    "right-long-to-line" "\ue444"
		    "right-to-bracket" "\uf2f6"
		    "right-to-line" "\uf34c"
		    "ring" "\uf70b"
		    "ring-diamond" "\ue5ab"
		    "rings-wedding" "\uf81b"
		    "road" "\uf018"
		    "road-barrier" "\ue562"
		    "road-bridge" "\ue563"
		    "road-circle-check" "\ue564"
		    "road-circle-exclamation" "\ue565"
		    "road-circle-xmark" "\ue566"
		    "road-lock" "\ue567"
		    "road-spikes" "\ue568"
		    "robot" "\uf544"
		    "robot-astromech" "\ue2d2"
		    "rocket" "\uf135"
		    "rocket-launch" "\ue027"
		    "roller-coaster" "\ue324"
		    "rotate" "\uf2f1"
		    "rotate-exclamation" "\ue23c"
		    "rotate-left" "\uf2ea"
		    "rotate-reverse" "\ue631"
		    "rotate-right" "\uf2f9"
		    "route" "\uf4d7"
		    "route-highway" "\uf61a"
		    "route-interstate" "\uf61b"
		    "router" "\uf8da"
		    "rss" "\uf09e"
		    "ruble-sign" "\uf158"
		    "rug" "\ue569"
		    "rugby-ball" "\ue3c6"
		    "ruler" "\uf545"
		    "ruler-combined" "\uf546"
		    "ruler-horizontal" "\uf547"
		    "ruler-triangle" "\uf61c"
		    "ruler-vertical" "\uf548"
		    "rupee-sign" "\uf156"
		    "rupiah-sign" "\ue23d"
		    "rv" "\uf7be"
		    "s" "\u53"
		    "sack" "\uf81c"
		    "sack-dollar" "\uf81d"
		    "sack-xmark" "\ue56a"
		    "sailboat" "\ue445"
		    "salad" "\uf81e"
		    "salt-shaker" "\ue446"
		    "sandwich" "\uf81f"
		    "satellite" "\uf7bf"
		    "satellite-dish" "\uf7c0"
		    "sausage" "\uf820"
		    "saxophone" "\uf8dc"
		    "saxophone-fire" "\uf8db"
		    "scale-balanced" "\uf24e"
		    "scale-unbalanced" "\uf515"
		    "scale-unbalanced-flip" "\uf516"
		    "scalpel" "\uf61d"
		    "scalpel-line-dashed" "\uf61e"
		    "scanner-gun" "\uf488"
		    "scanner-image" "\uf8f3"
		    "scanner-keyboard" "\uf489"
		    "scanner-touchscreen" "\uf48a"
		    "scarecrow" "\uf70d"
		    "scarf" "\uf7c1"
		    "school" "\uf549"
		    "school-circle-check" "\ue56b"
		    "school-circle-exclamation" "\ue56c"
		    "school-circle-xmark" "\ue56d"
		    "school-flag" "\ue56e"
		    "school-lock" "\ue56f"
		    "scissors" "\uf0c4"
		    "screen-users" "\uf63d"
		    "screencast" "\ue23e"
		    "screwdriver" "\uf54a"
		    "screwdriver-wrench" "\uf7d9"
		    "scribble" "\ue23f"
		    "scroll" "\uf70e"
		    "scroll-old" "\uf70f"
		    "scroll-torah" "\uf6a0"
		    "scrubber" "\uf2f8"
		    "scythe" "\uf710"
		    "sd-card" "\uf7c2"
		    "sd-cards" "\ue240"
		    "seal" "\ue241"
		    "seal-exclamation" "\ue242"
		    "seal-question" "\ue243"
		    "seat-airline" "\ue244"
		    "section" "\ue447"
		    "seedling" "\uf4d8"
		    "semicolon" "\u3b"
		    "send-back" "\uf87e"
		    "send-backward" "\uf87f"
		    "sensor" "\ue028"
		    "sensor-cloud" "\ue02c"
		    "sensor-fire" "\ue02a"
		    "sensor-on" "\ue02b"
		    "sensor-triangle-exclamation" "\ue029"
		    "server" "\uf233"
		    "shapes" "\uf61f"
		    "share" "\uf064"
		    "share-all" "\uf367"
		    "share-from-square" "\uf14d"
		    "share-nodes" "\uf1e0"
		    "sheep" "\uf711"
		    "sheet-plastic" "\ue571"
		    "shekel-sign" "\uf20b"
		    "shelves" "\uf480"
		    "shelves-empty" "\ue246"
		    "shield" "\uf132"
		    "shield-cat" "\ue572"
		    "shield-check" "\uf2f7"
		    "shield-cross" "\uf712"
		    "shield-dog" "\ue573"
		    "shield-exclamation" "\ue247"
		    "shield-halved" "\uf3ed"
		    "shield-heart" "\ue574"
		    "shield-keyhole" "\ue248"
		    "shield-minus" "\ue249"
		    "shield-plus" "\ue24a"
		    "shield-quartered" "\ue575"
		    "shield-slash" "\ue24b"
		    "shield-virus" "\ue06c"
		    "shield-xmark" "\ue24c"
		    "ship" "\uf21a"
		    "shirt" "\uf553"
		    "shirt-long-sleeve" "\ue3c7"
		    "shirt-running" "\ue3c8"
		    "shirt-tank-top" "\ue3c9"
		    "shish-kebab" "\uf821"
		    "shoe-prints" "\uf54b"
		    "shop" "\uf54f"
		    "shop-lock" "\ue4a5"
		    "shop-slash" "\ue070"
		    "shovel" "\uf713"
		    "shovel-snow" "\uf7c3"
		    "shower" "\uf2cc"
		    "shower-down" "\ue24d"
		    "shredder" "\uf68a"
		    "shrimp" "\ue448"
		    "shuffle" "\uf074"
		    "shutters" "\ue449"
		    "shuttle-space" "\uf197"
		    "shuttlecock" "\uf45b"
		    "sickle" "\uf822"
		    "sidebar" "\ue24e"
		    "sidebar-flip" "\ue24f"
		    "sigma" "\uf68b"
		    "sign-hanging" "\uf4d9"
		    "sign-post" "\ue624"
		    "sign-posts" "\ue625"
		    "sign-posts-wrench" "\ue626"
		    "signal" "\uf012"
		    "signal-bars" "\uf690"
		    "signal-bars-fair" "\uf692"
		    "signal-bars-good" "\uf693"
		    "signal-bars-slash" "\uf694"
		    "signal-bars-weak" "\uf691"
		    "signal-fair" "\uf68d"
		    "signal-good" "\uf68e"
		    "signal-slash" "\uf695"
		    "signal-stream" "\uf8dd"
		    "signal-stream-slash" "\ue250"
		    "signal-strong" "\uf68f"
		    "signal-weak" "\uf68c"
		    "signature" "\uf5b7"
		    "signature-lock" "\ue3ca"
		    "signature-slash" "\ue3cb"
		    "signs-post" "\uf277"
		    "sim-card" "\uf7c4"
		    "sim-cards" "\ue251"
		    "sink" "\ue06d"
		    "siren" "\ue02d"
		    "siren-on" "\ue02e"
		    "sitemap" "\uf0e8"
		    "skeleton" "\uf620"
		    "skeleton-ribs" "\ue5cb"
		    "ski-boot" "\ue3cc"
		    "ski-boot-ski" "\ue3cd"
		    "skull" "\uf54c"
		    "skull-cow" "\uf8de"
		    "skull-crossbones" "\uf714"
		    "slash" "\uf715"
		    "slash-back" "\u5c"
		    "slash-forward" "\u2f"
		    "sleigh" "\uf7cc"
		    "slider" "\ue252"
		    "sliders" "\uf1de"
		    "sliders-simple" "\ue253"
		    "sliders-up" "\uf3f1"
		    "slot-machine" "\ue3ce"
		    "smog" "\uf75f"
		    "smoke" "\uf760"
		    "smoking" "\uf48d"
		    "snake" "\uf716"
		    "snooze" "\uf880"
		    "snow-blowing" "\uf761"
		    "snowflake" "\uf2dc"
		    "snowflake-droplets" "\ue5c1"
		    "snowflakes" "\uf7cf"
		    "snowman" "\uf7d0"
		    "snowman-head" "\uf79b"
		    "snowplow" "\uf7d2"
		    "soap" "\ue06e"
		    "socks" "\uf696"
		    "soft-serve" "\ue400"
		    "solar-panel" "\uf5ba"
		    "solar-system" "\ue02f"
		    "sort" "\uf0dc"
		    "sort-down" "\uf0dd"
		    "sort-up" "\uf0de"
		    "spa" "\uf5bb"
		    "space-station-moon" "\ue033"
		    "space-station-moon-construction" "\ue034"
		    "spade" "\uf2f4"
		    "spaghetti-monster-flying" "\uf67b"
		    "sparkle" "\ue5d6"
		    "sparkles" "\uf890"
		    "speaker" "\uf8df"
		    "speakers" "\uf8e0"
		    "spell-check" "\uf891"
		    "spider" "\uf717"
		    "spider-black-widow" "\uf718"
		    "spider-web" "\uf719"
		    "spinner" "\uf110"
		    "spinner-scale" "\ue62a"
		    "spinner-third" "\uf3f4"
		    "split" "\ue254"
		    "splotch" "\uf5bc"
		    "spoon" "\uf2e5"
		    "sportsball" "\ue44b"
		    "spray-can" "\uf5bd"
		    "spray-can-sparkles" "\uf5d0"
		    "sprinkler" "\ue035"
		    "sprinkler-ceiling" "\ue44c"
		    "square" "\uf0c8"
		    "square-0" "\ue255"
		    "square-1" "\ue256"
		    "square-2" "\ue257"
		    "square-3" "\ue258"
		    "square-4" "\ue259"
		    "square-5" "\ue25a"
		    "square-6" "\ue25b"
		    "square-7" "\ue25c"
		    "square-8" "\ue25d"
		    "square-9" "\ue25e"
		    "square-a" "\ue25f"
		    "square-a-lock" "\ue44d"
		    "square-ampersand" "\ue260"
		    "square-arrow-down" "\uf339"
		    "square-arrow-down-left" "\ue261"
		    "square-arrow-down-right" "\ue262"
		    "square-arrow-left" "\uf33a"
		    "square-arrow-right" "\uf33b"
		    "square-arrow-up" "\uf33c"
		    "square-arrow-up-left" "\ue263"
		    "square-arrow-up-right" "\uf14c"
		    "square-b" "\ue264"
		    "square-bolt" "\ue265"
		    "square-c" "\ue266"
		    "square-caret-down" "\uf150"
		    "square-caret-left" "\uf191"
		    "square-caret-right" "\uf152"
		    "square-caret-up" "\uf151"
		    "square-check" "\uf14a"
		    "square-chevron-down" "\uf329"
		    "square-chevron-left" "\uf32a"
		    "square-chevron-right" "\uf32b"
		    "square-chevron-up" "\uf32c"
		    "square-code" "\ue267"
		    "square-d" "\ue268"
		    "square-dashed" "\ue269"
		    "square-dashed-circle-plus" "\ue5c2"
		    "square-divide" "\ue26a"
		    "square-dollar" "\uf2e9"
		    "square-down" "\uf350"
		    "square-down-left" "\ue26b"
		    "square-down-right" "\ue26c"
		    "square-e" "\ue26d"
		    "square-ellipsis" "\ue26e"
		    "square-ellipsis-vertical" "\ue26f"
		    "square-envelope" "\uf199"
		    "square-exclamation" "\uf321"
		    "square-f" "\ue270"
		    "square-fragile" "\uf49b"
		    "square-full" "\uf45c"
		    "square-g" "\ue271"
		    "square-h" "\uf0fd"
		    "square-heart" "\uf4c8"
		    "square-i" "\ue272"
		    "square-info" "\uf30f"
		    "square-j" "\ue273"
		    "square-k" "\ue274"
		    "square-kanban" "\ue488"
		    "square-l" "\ue275"
		    "square-left" "\uf351"
		    "square-list" "\ue489"
		    "square-m" "\ue276"
		    "square-minus" "\uf146"
		    "square-n" "\ue277"
		    "square-nfi" "\ue576"
		    "square-o" "\ue278"
		    "square-p" "\ue279"
		    "square-parking" "\uf540"
		    "square-parking-slash" "\uf617"
		    "square-pen" "\uf14b"
		    "square-person-confined" "\ue577"
		    "square-phone" "\uf098"
		    "square-phone-flip" "\uf87b"
		    "square-phone-hangup" "\ue27a"
		    "square-plus" "\uf0fe"
		    "square-poll-horizontal" "\uf682"
		    "square-poll-vertical" "\uf681"
		    "square-q" "\ue27b"
		    "square-quarters" "\ue44e"
		    "square-question" "\uf2fd"
		    "square-quote" "\ue329"
		    "square-r" "\ue27c"
		    "square-right" "\uf352"
		    "square-ring" "\ue44f"
		    "square-root" "\uf697"
		    "square-root-variable" "\uf698"
		    "square-rss" "\uf143"
		    "square-s" "\ue27d"
		    "square-share-nodes" "\uf1e1"
		    "square-sliders" "\uf3f0"
		    "square-sliders-vertical" "\uf3f2"
		    "square-small" "\ue27e"
		    "square-star" "\ue27f"
		    "square-t" "\ue280"
		    "square-terminal" "\ue32a"
		    "square-this-way-up" "\uf49f"
		    "square-u" "\ue281"
		    "square-up" "\uf353"
		    "square-up-left" "\ue282"
		    "square-up-right" "\uf360"
		    "square-user" "\ue283"
		    "square-v" "\ue284"
		    "square-virus" "\ue578"
		    "square-w" "\ue285"
		    "square-x" "\ue286"
		    "square-xmark" "\uf2d3"
		    "square-y" "\ue287"
		    "square-z" "\ue288"
		    "squid" "\ue450"
		    "squirrel" "\uf71a"
		    "staff" "\uf71b"
		    "staff-snake" "\ue579"
		    "stairs" "\ue289"
		    "stamp" "\uf5bf"
		    "standard-definition" "\ue28a"
		    "stapler" "\ue5af"
		    "star" "\uf005"
		    "star-and-crescent" "\uf699"
		    "star-christmas" "\uf7d4"
		    "star-exclamation" "\uf2f3"
		    "star-half" "\uf089"
		    "star-half-stroke" "\uf5c0"
		    "star-of-david" "\uf69a"
		    "star-of-life" "\uf621"
		    "star-sharp" "\ue28b"
		    "star-sharp-half" "\ue28c"
		    "star-sharp-half-stroke" "\ue28d"
		    "star-shooting" "\ue036"
		    "starfighter" "\ue037"
		    "starfighter-twin-ion-engine" "\ue038"
		    "starfighter-twin-ion-engine-advanced" "\ue28e"
		    "stars" "\uf762"
		    "starship" "\ue039"
		    "starship-freighter" "\ue03a"
		    "steak" "\uf824"
		    "steering-wheel" "\uf622"
		    "sterling-sign" "\uf154"
		    "stethoscope" "\uf0f1"
		    "stocking" "\uf7d5"
		    "stomach" "\uf623"
		    "stop" "\uf04d"
		    "stopwatch" "\uf2f2"
		    "stopwatch-20" "\ue06f"
		    "store" "\uf54e"
		    "store-lock" "\ue4a6"
		    "store-slash" "\ue071"
		    "strawberry" "\ue32b"
		    "street-view" "\uf21d"
		    "stretcher" "\uf825"
		    "strikethrough" "\uf0cc"
		    "stroopwafel" "\uf551"
		    "subscript" "\uf12c"
		    "subtitles" "\ue60f"
		    "subtitles-slash" "\ue610"
		    "suitcase" "\uf0f2"
		    "suitcase-medical" "\uf0fa"
		    "suitcase-rolling" "\uf5c1"
		    "sun" "\uf185"
		    "sun-bright" "\ue28f"
		    "sun-cloud" "\uf763"
		    "sun-dust" "\uf764"
		    "sun-haze" "\uf765"
		    "sun-plant-wilt" "\ue57a"
		    "sunglasses" "\uf892"
		    "sunrise" "\uf766"
		    "sunset" "\uf767"
		    "superscript" "\uf12b"
		    "sushi" "\ue48a"
		    "sushi-roll" "\ue48b"
		    "swap" "\ue609"
		    "swap-arrows" "\ue60a"
		    "swatchbook" "\uf5c3"
		    "sword" "\uf71c"
		    "sword-laser" "\ue03b"
		    "sword-laser-alt" "\ue03c"
		    "swords" "\uf71d"
		    "swords-laser" "\ue03d"
		    "symbols" "\uf86e"
		    "synagogue" "\uf69b"
		    "syringe" "\uf48e"
		    "t" "\u54"
		    "t-rex" "\ue629"
		    "table" "\uf0ce"
		    "table-cells" "\uf00a"
		    "table-cells-large" "\uf009"
		    "table-columns" "\uf0db"
		    "table-layout" "\ue290"
		    "table-list" "\uf00b"
		    "table-picnic" "\ue32d"
		    "table-pivot" "\ue291"
		    "table-rows" "\ue292"
		    "table-tennis-paddle-ball" "\uf45d"
		    "table-tree" "\ue293"
		    "tablet" "\uf3fb"
		    "tablet-button" "\uf10a"
		    "tablet-rugged" "\uf48f"
		    "tablet-screen" "\uf3fc"
		    "tablet-screen-button" "\uf3fa"
		    "tablets" "\uf490"
		    "tachograph-digital" "\uf566"
		    "taco" "\uf826"
		    "tag" "\uf02b"
		    "tags" "\uf02c"
		    "tally" "\uf69c"
		    "tally-1" "\ue294"
		    "tally-2" "\ue295"
		    "tally-3" "\ue296"
		    "tally-4" "\ue297"
		    "tamale" "\ue451"
		    "tank-water" "\ue452"
		    "tape" "\uf4db"
		    "tarp" "\ue57b"
		    "tarp-droplet" "\ue57c"
		    "taxi" "\uf1ba"
		    "taxi-bus" "\ue298"
		    "teddy-bear" "\ue3cf"
		    "teeth" "\uf62e"
		    "teeth-open" "\uf62f"
		    "telescope" "\ue03e"
		    "temperature-arrow-down" "\ue03f"
		    "temperature-arrow-up" "\ue040"
		    "temperature-empty" "\uf2cb"
		    "temperature-full" "\uf2c7"
		    "temperature-half" "\uf2c9"
		    "temperature-high" "\uf769"
		    "temperature-list" "\ue299"
		    "temperature-low" "\uf76b"
		    "temperature-quarter" "\uf2ca"
		    "temperature-snow" "\uf768"
		    "temperature-sun" "\uf76a"
		    "temperature-three-quarters" "\uf2c8"
		    "tenge-sign" "\uf7d7"
		    "tennis-ball" "\uf45e"
		    "tent" "\ue57d"
		    "tent-arrow-down-to-line" "\ue57e"
		    "tent-arrow-left-right" "\ue57f"
		    "tent-arrow-turn-left" "\ue580"
		    "tent-arrows-down" "\ue581"
		    "tent-double-peak" "\ue627"
		    "tents" "\ue582"
		    "terminal" "\uf120"
		    "text" "\uf893"
		    "text-height" "\uf034"
		    "text-size" "\uf894"
		    "text-slash" "\uf87d"
		    "text-width" "\uf035"
		    "thermometer" "\uf491"
		    "theta" "\uf69e"
		    "thought-bubble" "\ue32e"
		    "thumbs-down" "\uf165"
		    "thumbs-up" "\uf164"
		    "thumbtack" "\uf08d"
		    "tick" "\ue32f"
		    "ticket" "\uf145"
		    "ticket-airline" "\ue29a"
		    "ticket-perforated" "\ue63e"
		    "ticket-simple" "\uf3ff"
		    "tickets" "\ue658"
		    "tickets-airline" "\ue29b"
		    "tickets-perforated" "\ue63f"
		    "tickets-simple" "\ue659"
		    "tilde" "\u7e"
		    "timeline" "\ue29c"
		    "timeline-arrow" "\ue29d"
		    "timer" "\ue29e"
		    "tire" "\uf631"
		    "tire-flat" "\uf632"
		    "tire-pressure-warning" "\uf633"
		    "tire-rugged" "\uf634"
		    "toggle-large-off" "\ue5b0"
		    "toggle-large-on" "\ue5b1"
		    "toggle-off" "\uf204"
		    "toggle-on" "\uf205"
		    "toilet" "\uf7d8"
		    "toilet-paper" "\uf71e"
		    "toilet-paper-blank" "\uf71f"
		    "toilet-paper-blank-under" "\ue29f"
		    "toilet-paper-check" "\ue5b2"
		    "toilet-paper-slash" "\ue072"
		    "toilet-paper-under" "\ue2a0"
		    "toilet-paper-under-slash" "\ue2a1"
		    "toilet-paper-xmark" "\ue5b3"
		    "toilet-portable" "\ue583"
		    "toilets-portable" "\ue584"
		    "tomato" "\ue330"
		    "tombstone" "\uf720"
		    "tombstone-blank" "\uf721"
		    "toolbox" "\uf552"
		    "tooth" "\uf5c9"
		    "toothbrush" "\uf635"
		    "torii-gate" "\uf6a1"
		    "tornado" "\uf76f"
		    "tower-broadcast" "\uf519"
		    "tower-cell" "\ue585"
		    "tower-control" "\ue2a2"
		    "tower-observation" "\ue586"
		    "tractor" "\uf722"
		    "trademark" "\uf25c"
		    "traffic-cone" "\uf636"
		    "traffic-light" "\uf637"
		    "traffic-light-go" "\uf638"
		    "traffic-light-slow" "\uf639"
		    "traffic-light-stop" "\uf63a"
		    "trailer" "\ue041"
		    "train" "\uf238"
		    "train-subway" "\uf239"
		    "train-subway-tunnel" "\ue2a3"
		    "train-track" "\ue453"
		    "train-tram" "\ue5b4"
		    "train-tunnel" "\ue454"
		    "transformer-bolt" "\ue2a4"
		    "transgender" "\uf225"
		    "transporter" "\ue042"
		    "transporter-1" "\ue043"
		    "transporter-2" "\ue044"
		    "transporter-3" "\ue045"
		    "transporter-4" "\ue2a5"
		    "transporter-5" "\ue2a6"
		    "transporter-6" "\ue2a7"
		    "transporter-7" "\ue2a8"
		    "transporter-empty" "\ue046"
		    "trash" "\uf1f8"
		    "trash-arrow-up" "\uf829"
		    "trash-can" "\uf2ed"
		    "trash-can-arrow-up" "\uf82a"
		    "trash-can-check" "\ue2a9"
		    "trash-can-clock" "\ue2aa"
		    "trash-can-list" "\ue2ab"
		    "trash-can-plus" "\ue2ac"
		    "trash-can-slash" "\ue2ad"
		    "trash-can-undo" "\uf896"
		    "trash-can-xmark" "\ue2ae"
		    "trash-check" "\ue2af"
		    "trash-clock" "\ue2b0"
		    "trash-list" "\ue2b1"
		    "trash-plus" "\ue2b2"
		    "trash-slash" "\ue2b3"
		    "trash-undo" "\uf895"
		    "trash-xmark" "\ue2b4"
		    "treasure-chest" "\uf723"
		    "tree" "\uf1bb"
		    "tree-christmas" "\uf7db"
		    "tree-city" "\ue587"
		    "tree-deciduous" "\uf400"
		    "tree-decorated" "\uf7dc"
		    "tree-large" "\uf7dd"
		    "tree-palm" "\uf82b"
		    "trees" "\uf724"
		    "triangle" "\uf2ec"
		    "triangle-exclamation" "\uf071"
		    "triangle-instrument" "\uf8e2"
		    "triangle-person-digging" "\uf85d"
		    "tricycle" "\ue5c3"
		    "tricycle-adult" "\ue5c4"
		    "trillium" "\ue588"
		    "trophy" "\uf091"
		    "trophy-star" "\uf2eb"
		    "trowel" "\ue589"
		    "trowel-bricks" "\ue58a"
		    "truck" "\uf0d1"
		    "truck-arrow-right" "\ue58b"
		    "truck-bolt" "\ue3d0"
		    "truck-clock" "\uf48c"
		    "truck-container" "\uf4dc"
		    "truck-container-empty" "\ue2b5"
		    "truck-droplet" "\ue58c"
		    "truck-fast" "\uf48b"
		    "truck-field" "\ue58d"
		    "truck-field-un" "\ue58e"
		    "truck-fire" "\ue65a"
		    "truck-flatbed" "\ue2b6"
		    "truck-front" "\ue2b7"
		    "truck-ladder" "\ue657"
		    "truck-medical" "\uf0f9"
		    "truck-monster" "\uf63b"
		    "truck-moving" "\uf4df"
		    "truck-pickup" "\uf63c"
		    "truck-plane" "\ue58f"
		    "truck-plow" "\uf7de"
		    "truck-ramp" "\uf4e0"
		    "truck-ramp-box" "\uf4de"
		    "truck-ramp-couch" "\uf4dd"
		    "truck-tow" "\ue2b8"
		    "truck-utensils" "\ue628"
		    "trumpet" "\uf8e3"
		    "tty" "\uf1e4"
		    "tty-answer" "\ue2b9"
		    "tugrik-sign" "\ue2ba"
		    "turkey" "\uf725"
		    "turkish-lira-sign" "\ue2bb"
		    "turn-down" "\uf3be"
		    "turn-down-left" "\ue331"
		    "turn-down-right" "\ue455"
		    "turn-left" "\ue636"
		    "turn-left-down" "\ue637"
		    "turn-left-up" "\ue638"
		    "turn-right" "\ue639"
		    "turn-up" "\uf3bf"
		    "turntable" "\uf8e4"
		    "turtle" "\uf726"
		    "tv" "\uf26c"
		    "tv-music" "\uf8e6"
		    "tv-retro" "\uf401"
		    "typewriter" "\uf8e7"
		    "u" "\u55"
		    "ufo" "\ue047"
		    "ufo-beam" "\ue048"
		    "umbrella" "\uf0e9"
		    "umbrella-beach" "\uf5ca"
		    "umbrella-simple" "\ue2bc"
		    "underline" "\uf0cd"
		    "unicorn" "\uf727"
		    "uniform-martial-arts" "\ue3d1"
		    "union" "\uf6a2"
		    "universal-access" "\uf29a"
		    "unlock" "\uf09c"
		    "unlock-keyhole" "\uf13e"
		    "up" "\uf357"
		    "up-down" "\uf338"
		    "up-down-left-right" "\uf0b2"
		    "up-from-bracket" "\ue590"
		    "up-from-dotted-line" "\ue456"
		    "up-from-line" "\uf346"
		    "up-left" "\ue2bd"
		    "up-long" "\uf30c"
		    "up-right" "\ue2be"
		    "up-right-and-down-left-from-center" "\uf424"
		    "up-right-from-square" "\uf35d"
		    "up-to-dotted-line" "\ue457"
		    "up-to-line" "\uf34d"
		    "upload" "\uf093"
		    "usb-drive" "\uf8e9"
		    "user" "\uf007"
		    "user-alien" "\ue04a"
		    "user-astronaut" "\uf4fb"
		    "user-bounty-hunter" "\ue2bf"
		    "user-check" "\uf4fc"
		    "user-chef" "\ue3d2"
		    "user-clock" "\uf4fd"
		    "user-cowboy" "\uf8ea"
		    "user-crown" "\uf6a4"
		    "user-doctor" "\uf0f0"
		    "user-doctor-hair" "\ue458"
		    "user-doctor-hair-long" "\ue459"
		    "user-doctor-message" "\uf82e"
		    "user-gear" "\uf4fe"
		    "user-graduate" "\uf501"
		    "user-group" "\uf500"
		    "user-group-crown" "\uf6a5"
		    "user-group-simple" "\ue603"
		    "user-hair" "\ue45a"
		    "user-hair-buns" "\ue3d3"
		    "user-hair-long" "\ue45b"
		    "user-hair-mullet" "\ue45c"
		    "user-headset" "\uf82d"
		    "user-helmet-safety" "\uf82c"
		    "user-injured" "\uf728"
		    "user-large" "\uf406"
		    "user-large-slash" "\uf4fa"
		    "user-lock" "\uf502"
		    "user-magnifying-glass" "\ue5c5"
		    "user-minus" "\uf503"
		    "user-music" "\uf8eb"
		    "user-ninja" "\uf504"
		    "user-nurse" "\uf82f"
		    "user-nurse-hair" "\ue45d"
		    "user-nurse-hair-long" "\ue45e"
		    "user-pen" "\uf4ff"
		    "user-pilot" "\ue2c0"
		    "user-pilot-tie" "\ue2c1"
		    "user-plus" "\uf234"
		    "user-police" "\ue333"
		    "user-police-tie" "\ue334"
		    "user-robot" "\ue04b"
		    "user-robot-xmarks" "\ue4a7"
		    "user-secret" "\uf21b"
		    "user-shakespeare" "\ue2c2"
		    "user-shield" "\uf505"
		    "user-slash" "\uf506"
		    "user-tag" "\uf507"
		    "user-tie" "\uf508"
		    "user-tie-hair" "\ue45f"
		    "user-tie-hair-long" "\ue460"
		    "user-unlock" "\ue058"
		    "user-visor" "\ue04c"
		    "user-vneck" "\ue461"
		    "user-vneck-hair" "\ue462"
		    "user-vneck-hair-long" "\ue463"
		    "user-xmark" "\uf235"
		    "users" "\uf0c0"
		    "users-between-lines" "\ue591"
		    "users-gear" "\uf509"
		    "users-line" "\ue592"
		    "users-medical" "\uf830"
		    "users-rays" "\ue593"
		    "users-rectangle" "\ue594"
		    "users-slash" "\ue073"
		    "users-viewfinder" "\ue595"
		    "utensils" "\uf2e7"
		    "utensils-slash" "\ue464"
		    "utility-pole" "\ue2c3"
		    "utility-pole-double" "\ue2c4"
		    "v" "\u56"
		    "vacuum" "\ue04d"
		    "vacuum-robot" "\ue04e"
		    "value-absolute" "\uf6a6"
		    "van-shuttle" "\uf5b6"
		    "vault" "\ue2c5"
		    "vector-circle" "\ue2c6"
		    "vector-polygon" "\ue2c7"
		    "vector-square" "\uf5cb"
		    "vent-damper" "\ue465"
		    "venus" "\uf221"
		    "venus-double" "\uf226"
		    "venus-mars" "\uf228"
		    "vest" "\ue085"
		    "vest-patches" "\ue086"
		    "vial" "\uf492"
		    "vial-circle-check" "\ue596"
		    "vial-virus" "\ue597"
		    "vials" "\uf493"
		    "video" "\uf03d"
		    "video-arrow-down-left" "\ue2c8"
		    "video-arrow-up-right" "\ue2c9"
		    "video-plus" "\uf4e1"
		    "video-slash" "\uf4e2"
		    "vihara" "\uf6a7"
		    "violin" "\uf8ed"
		    "virus" "\ue074"
		    "virus-covid" "\ue4a8"
		    "virus-covid-slash" "\ue4a9"
		    "virus-slash" "\ue075"
		    "viruses" "\ue076"
		    "voicemail" "\uf897"
		    "volcano" "\uf770"
		    "volleyball" "\uf45f"
		    "volume" "\uf6a8"
		    "volume-high" "\uf028"
		    "volume-low" "\uf027"
		    "volume-off" "\uf026"
		    "volume-slash" "\uf2e2"
		    "volume-xmark" "\uf6a9"
		    "vr-cardboard" "\uf729"
		    "w" "\u57"
		    "waffle" "\ue466"
		    "wagon-covered" "\uf8ee"
		    "walker" "\uf831"
		    "walkie-talkie" "\uf8ef"
		    "wallet" "\uf555"
		    "wand" "\uf72a"
		    "wand-magic" "\uf0d0"
		    "wand-magic-sparkles" "\ue2ca"
		    "wand-sparkles" "\uf72b"
		    "warehouse" "\uf494"
		    "warehouse-full" "\uf495"
		    "washing-machine" "\uf898"
		    "watch" "\uf2e1"
		    "watch-apple" "\ue2cb"
		    "watch-calculator" "\uf8f0"
		    "watch-fitness" "\uf63e"
		    "watch-smart" "\ue2cc"
		    "water" "\uf773"
		    "water-arrow-down" "\uf774"
		    "water-arrow-up" "\uf775"
		    "water-ladder" "\uf5c5"
		    "watermelon-slice" "\ue337"
		    "wave" "\ue65b"
		    "wave-pulse" "\uf5f8"
		    "wave-sine" "\uf899"
		    "wave-square" "\uf83e"
		    "wave-triangle" "\uf89a"
		    "waveform" "\uf8f1"
		    "waveform-lines" "\uf8f2"
		    "waves-sine" "\ue65d"
		    "webhook" "\ue5d5"
		    "weight-hanging" "\uf5cd"
		    "weight-scale" "\uf496"
		    "whale" "\uf72c"
		    "wheat" "\uf72d"
		    "wheat-awn" "\ue2cd"
		    "wheat-awn-circle-exclamation" "\ue598"
		    "wheat-awn-slash" "\ue338"
		    "wheat-slash" "\ue339"
		    "wheelchair" "\uf193"
		    "wheelchair-move" "\ue2ce"
		    "whiskey-glass" "\uf7a0"
		    "whiskey-glass-ice" "\uf7a1"
		    "whistle" "\uf460"
		    "wifi" "\uf1eb"
		    "wifi-exclamation" "\ue2cf"
		    "wifi-fair" "\uf6ab"
		    "wifi-slash" "\uf6ac"
		    "wifi-weak" "\uf6aa"
		    "wind" "\uf72e"
		    "wind-turbine" "\uf89b"
		    "wind-warning" "\uf776"
		    "window" "\uf40e"
		    "window-flip" "\uf40f"
		    "window-frame" "\ue04f"
		    "window-frame-open" "\ue050"
		    "window-maximize" "\uf2d0"
		    "window-minimize" "\uf2d1"
		    "window-restore" "\uf2d2"
		    "windsock" "\uf777"
		    "wine-bottle" "\uf72f"
		    "wine-glass" "\uf4e3"
		    "wine-glass-crack" "\uf4bb"
		    "wine-glass-empty" "\uf5ce"
		    "won-sign" "\uf159"
		    "worm" "\ue599"
		    "wreath" "\uf7e2"
		    "wreath-laurel" "\ue5d2"
		    "wrench" "\uf0ad"
		    "wrench-simple" "\ue2d1"
		    "x" "\u58"
		    "x-ray" "\uf497"
		    "xmark" "\uf00d"
		    "xmark-large" "\ue59b"
		    "xmark-to-slot" "\uf771"
		    "xmarks-lines" "\ue59a"
		    "y" "\u59"
		    "yen-sign" "\uf157"
		    "yin-yang" "\uf6ad"
		    "z" "\u5a"
		}

		# Used to map booleans to their dcheckbox representation (square/square-check) in fontawesome.
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
		
		# A list with loaded family_name-font_filename pairs. Remembers which fonts have been added with 'sdltk addfont',
		#	which is required because trying to 'sdltk addfont' an already added font file raises an error.
		# NOTE: AT THE MOMENT this is kept in a global variable to be compatible with how skins were doing it before
		#	releasing DUI, but in the future using a namespace variable would be preferred.
		#variable loaded_fonts {}
		
		# An array that maps skin/user-defined font names to dui font keys. So skins & plugins can use fonts
		# using their own names.
		variable skin_fonts
		array set skin_fonts {}
		
		proc add_dirs { args } {
			variable font_dirs
			
			foreach dir $args {
				set dir [file normalize $dir]
				if { [file isdirectory $dir] } {
					if { $dir in $font_dirs } {
						msg -NOTICE [namespace current] "font directory '$dir' was already in the list"
					} else {
						lappend font_dirs $dir
						msg -INFO [namespace current] "adding font directory '$dir'"
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
			global loaded_fonts
			variable font_dirs
			set familyname ""
			
			set fontindex [lsearch $loaded_fonts $filename]
			if {$fontindex != -1} {
				if { $fontindex % 2 == 1 } {
					set familyname $filename
				} else {
					set familyname [lindex $loaded_fonts [expr $fontindex + 1]]
				}
			} elseif {($::android == 1 || $::undroid == 1) && $filename ne "" && [string is true $add_if_needed] } {
				set file_found 0
				if { [file dirname $filename] eq "." } {
					set ndirs [llength $font_dirs]
					for { set i 0 } { $i < $ndirs && !$file_found } { incr i } {
						set dir [lindex $font_dirs $i]
						set test_path [file join $dir $filename]
						if { [file extension $filename] ne "" && [file exists $test_path] } {
							set filename $test_path
							set file_found 1
						} elseif { [file exists "$test_path.otf"] } {
							set filename "$test_path.otf"
							set file_found 1
						} elseif { [file exists "$test_path.ttf"] } {
							set filename "$test_path.ttf"
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
					set $filename [file normalize $filename]
					
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
		#	-name to assign a user-defined font name that can later be used to retrieve the font with 'dui font get'
		#	-weight "normal" (default) or "bold"
		#	-slant "roman" (default) or "italic"
		#	-underline false (default) or true
		#	-overstrike false (default) or true
		proc load { filename size args } {
			variable skin_fonts
			
			set key [dui::args::get_option -name "" 1]
			array set opts $args
			
			# calculate font size 
			set platform_size [expr {int([dui cget fontm] * $size)}]
		
			# Load or get the already-loaded font family name.
			set familyname [add_or_get_familyname $filename]
			if { $familyname eq "" } {
				msg -NOTICE [namespace current] load: "font familyname not available; using filename '$filename'"
				set familyname $filename
			}
			
			if { $key eq "" } {	
				set key [key $familyname $size {*}$args]
			}
			
			if { $key ni [::font names] } {
				# Create the named font instance
				try {
					::font create $key -family $familyname -size $platform_size {*}$args
					msg -DEBUG [namespace current] "load font with key: \"$key\", family: \"$familyname\", requested size: $size, platform size: $platform_size, filename: \"$filename\", options: $args"
				} on error err {
					msg -ERROR [namespace current] "unable to create font with key '$key': $err"
				}
			}
			
#			if { $fontname ne "" } {
#				set skin_fonts($fontname) $key
#			}			
			return $key
		}
		
		
		# Based on Barney's get_font wrapper: 
		#	https://3.basecamp.com/3671212/buckets/7351439/documents/2208672342#__recording_2349428596
		# "I created a wrapper function that you might be interested in adopting. It makes working with fonts even simpler 
		#	by removing the need to pre-load fonts before using them."
		# 'name' can be either a user-defined font name (with 'dui load font ... -name <name>')), a font family name,
		#	or a font file name (with or without path and/or extension). If it is a font filename, it will be 
		#	auto-loaded if it had not been loaded yet.
		proc get { name size args } {
			variable skin_fonts
			
			if { [info exists skin_fonts($name)] } {
				set font_key $skin_fonts($name)
			} else {
				set name [add_or_get_familyname $name]
				set font_key [key $name $size {*}$args]
			}
			
			if { $font_key ni [::font names] } {
				set font_key [load $name $size {*}$args]
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
	
	### IMAGES SUB-ENSEMBLE ###
	namespace eval image {
		namespace export add_dirs dirs add 
		# photoscale find load is_loaded get set_delayed exists_delayed get_delayed load_delayed rm_delayed
		namespace ensemble create
		
		# A list of paths where to look for image files
		variable img_dirs {}
		
		# A dictionary of loaded images. Remembers whether an image has already been loaded to avoid doing it more than 
		# once, and allows deferred loading until the page is actually shown.
		# Indexed by the normalized image path, the value is an empty string if it has not been loaded yet, and the
		# image name (<first_page>-<main_tag>) if it has been.
		variable images
		set images [dict create]
		
		# A dictionary of images whose loading is delayed, to make startup faster. Indexed by the canvas ID of the 
		# image, each value is a list with 1) the normalized image path; 2) the image type; 3) any extra named options
		variable delayed_images
		set delayed_images [dict create]
		
		proc add_dirs { args } {
			variable img_dirs
			
			foreach dir $args {
				set dir [file normalize $dir]
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
		
		proc dirs {} {
			variable img_dirs
			return $img_dirs
		}
		
		proc photoscale { img sx {sy ""}  } {
			msg -DEBUG "photoscale $img $sx $sy"
			if { $sx == 1 && ($sy eq "" || $sy == 1) } {
				return;   # Nothing to do!
			}
					
			if { $::android == 1 || $::undroid == 1 } {
				# create a new tmp image
				set tmp [image create photo]
			
				# resize to the tmp image
				$tmp copy $img -scale $sx $sy
			
				# recreate the original image and copy the tmp over it
				image delete $img
				image create photo $img
				$img copy $tmp
			
				# clean up
				image delete $tmp
			} else {
				foreach {sx_m sx_f} [Double2Fraction $sx] break
				if { $sy eq "" } {
					foreach {sy sy_x sy_f} [list $sx $sx_m $sx_f] break;  # Multi-set!
				} else {
					foreach {sy_m sy_f} [Double2Fraction $sy] break
				}
				set tmp [image create photo]
				$tmp copy $img -zoom $sx_m $sy_m -compositingrule set
				$img blank
				$img copy $tmp -shrink -subsample $sx_f $sy_f -compositingrule set
				image delete $tmp
			}
		}
		
		proc add { args } {
			return [dui add image {*}$args]
		}
		
		# Locates an image file. Returns the normalized path if found, or an empty string otherwise.
		# If a full path is not specified, it will search on the list of available image dirs added with 
		#	[dui image add_dirs]. 
		# Images are always searched in a subfolder of each of those dirs with name 
		#	<current_screen_width>x<current_screen_height>.
		# If the file is not found and -rescale is a boolean true value, it will run the same search but using
		#	the default base resolution subfolder 2560x1600. If found, the file will be rescaled automatically and
		#	saved to disk in the <current_screen_width>x<current_screen_height> subfolder. The subfolder is created
		#	if it doesn't exist.		
		proc find { filename {rescale 1} } {
			if { [file pathtype $filename] in {absolute volumerelative} } {
				if { [file exists $filename] } {
					return [file normalize $filename]
				} else {
					msg -WARNING [namespace current] "image file '$filename' not found"
					return ""
				}
			}
			
			if { [file exists $filename] } {
				return [file normalize $filename]
			}
			
			set screen_size_width [dui cget screen_size_width]
			set screen_size_height [dui cget screen_size_height]
			
			foreach dir [dui image dirs] {
				set full_fn [file join $dir "${screen_size_width}x${screen_size_height}" $filename]
				if { [file exists $full_fn] } {
					return [file normalize $full_fn]
				}
			}
			
			if { [string is true $rescale] && [file pathtype $filename] in {relative volumerelative} } {
				set src_filename ""
				foreach dir [dui image dirs] {
					set full_fn [file join $dir "[expr {int($::dui::_base_screen_width)}]x[expr {int($::dui::_base_screen_height)}]" $filename]
					if { [file exists $full_fn] } {
						set src_filename $full_fn
						break
					}
				}
				
				if { $src_filename eq "" } {
					msg -WARNING [namespace current] "image file '$filename' not found"
					return ""
				} else {					
					set filename [file join $dir "${screen_size_width}x${screen_size_height}" $filename]
					catch {
						file mkdir [file dirname $filename]
					}
					
					msg -DEBUG [namespace current] "resizing image $src_filename to $filename"
					dui say [translate "Resizing image"]
					
					# X = width as per https://www.techopedia.com/definition/10108/x-y-z-matrix
					set rescale_images_x_ratio [expr {$screen_size_width / $::dui::_base_screen_width}]
					set rescale_images_y_ratio [expr {$screen_size_height / $::dui::_base_screen_height}]
					set imgname "_resize_[expr {int(rand()*1000)}]"
												
					::image create photo $imgname -file $src_filename
					photoscale $imgname $rescale_images_x_ratio $rescale_images_y_ratio
					
					switch [string tolower [file extension $filename]] {
						.png {
							set format {png -alpha 1.0}
						}
						default {
							set format {jpeg -quality 90}
						}
					}						
					
					$imgname write $filename -format $format
					::image delete $imgname
					
					return [file normalize $filename]
				}
			}
			
			return ""
		}
		
		# Note that filename can be an empty string (adding it empty and later reading the image file is a trick used
		#	in several places, e.g. for DSx backgrounds) 
		proc load { type name filename {preload 1} args } {
			set filename [file normalize "$filename"]
			
			if { [string is true $preload] } {
				try {
					::image create $type $name -file "$filename" {*}$args
					if { $filename ne "" } {
						dict set dui::image::images "$filename" $name
					}
				} on error err {
					msg -ERROR [namespace current] "load: can't preload $type image '$filename' with name '$name': $err"
					return "" 
				}
			} else {
				try {
					::image create $type $name {*}$args
					if { $filename ne "" } {
						dict set dui::image::images "$filename" $name
						dui::image::set_delayed $name $filename $type {*}$args
					}
				} on error err {
					msg -ERROR [namespace current] "load: can't delay-load $type image '$filename' with name '$name': $err"
					return "" 
				}
			}
			return $name
		}
		
		proc is_loaded { filename } {
			set filename [file normalize "$filename"]
			if { [dict exists $::dui::image::images "$filename"] } {
				return [expr {[dict get $::dui::image::images "$filename"] ne ""}]
			} else {
				return 0
			}
		}
		
		proc get { filename } {
			set filename [file normalize "$filename"]
			return [dict get $::dui::image::images "$filename"]
		}
		
		proc set_delayed { img_name filename type args } {
			dict set ::dui::image::delayed_images $img_name [list [file normalize $filename] $type {*}$args]
		}

		proc exists_delayed { img_name } {
			return [dict exists $::dui::image::delayed_images $img_name]
		}
		
		proc get_delayed { img_name } {
			if { [exists_delayed $img_name] } {
				return [dict get $::dui::image::delayed_images $img_name]
			} else {
				return ""
			}
		}

		proc load_delayed { img_name } {
			set dd [get_delayed $img_name]
			if { [llength $dd] > 0 } {
				try {
					$img_name read [lindex $dd 0]
				} on error err {
					msg [namespace current] "load_delayed: can't load file '[lindex $dd 0]', $err"
				}
				
				rm_delayed $img_name
				return $img_name
			}
		}
		
		proc rm_delayed { img_name } {
			set ::dui::image::delayed_images [dict remove $::dui::image::delayed_images $img_name] 
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
			set initial_state [get_option -initial_state normal 1 largs]
			set auto_assign_tag 0
			if { [llength $tags] == 0 } {
				set main_tag "${type}_[incr item_cnt]"
				set tags $main_tag
				set auto_assign_tag 1
			} else {				
				set main_tag [lindex $tags 0]
				if { [string is integer $main_tag] || ![regexp {^([A-Za-z0-9_\-])+$} $main_tag] } {
					set msg "process_tags_and_var: main tag '$main_tag' can only have letters, numbers, underscores and hyphens, and cannot be a number" 
					msg -ERROR [namespace current] $msg
					return 0
				}
			}
			# Main tags must be unique per-page.
			foreach page $pages {
				if { [dui page has_item $page $main_tag] } {
					set msg "process_tags_and_var: main tag '$main_tag' already exists in page '$page', duplicates are not allowed"
					msg -ERROR [namespace current] $msg
					return 0
				}
			}			
			
			if { $add_multi == 1 && "$main_tag*" ni $tags } {
				lappend tags "$main_tag*"
			}
			if { $initial_state in {hidden disabled} } {
				lappend tags st:$initial_state
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
				
			set font [get_option -font "" 1 largs]
			if { $font ne "" } {
				if { [info exists ::dui::font::skin_fonts($font)] } {
					set font $::dui::font::skin_fonts($font)
				}					
				add_option_if_not_exists -font $font largs
				
				foreach f {family size weight slant underline overstrike} {
					remove_options -font_$f largs
				}
			} elseif { $type ni {ProgressBar} } {
				set font_family [get_option -font_family [dui aspect get [list $type dtext font] font_family -style $style] 1 largs]
				
				set default_size [dui aspect get [list $type dtext font] font_size]
				if { $default_size eq "" || [string range $default_size 0 0] in "- +" } {
					set default_size [dui aspect get [list dtext font] font_size]
					if { $default_size eq "" || [string range $default_size 0 0] in "- +" } {
						set default_size [dui aspect get font font_size]
						if { $default_size eq "" || [string range $default_size 0 0] in "- +" } {
							set default_size 16
						}
					}
				}				
				set font_size [get_option -font_size $default_size 1 largs]	
				if { [string range $font_size 0 0] in "- +" } {
					set font_size [expr int($default_size$font_size)]
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
			foreach aspect [dui aspect list -type [list ${type}_label dtext] -style $style] {
				add_option_if_not_exists -$aspect [dui aspect get ${type}_label $aspect -style $style \
					-default {} -default_type dtext] label_args
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
					set after_show_cmd [list dui::item::relocate_text_wrt $page ${main_tag}-lbl $wrt_tag [lindex $label_pos 0] \
						$xlabel_offset $ylabel_offset [get_option -anchor nw 0 label_args]]	
					dui page add_action $page show $after_show_cmd
				}
			}

			if { $label ne "" } {
				set id [dui add dtext $pages $xlabel $ylabel -text $label -tags $label_tags -aspect_type ${type}_label \
					{*}$label_args]
			} elseif { $labelvar ne "" } {
				set id [dui add variable $pages $xlabel $ylabel -textvariable $labelvar -tags $label_tags \
					-aspect_type ${type}_label {*}$label_args] 
			}
			return $id
		}

		# Processes the coordinates & sizing arguments for bounding rectangles, as used by dui::add::dbutton or
		# dui::add::shape. These can be defined using either 4 coordinates, or 2 coordinates plus -width and -height
		# arguments. The coordinates are interpreted as relative to the top-left coordinate of the first page in
		# $pages, which is {0 0} for normal pages, but can be different for dialog pages. Also allows using
		# percentage coordinates (if the values are >0 and <1), which are interpreted as proportions of the page
		# width and height.
		# The -width, -height and -anchor options are removed from 'args'.
		# Returns 4 coordinates {x y x1 y1} for the top-left and right-bottom points of the bounding rectangle.
		proc process_sizes { pages x y {width_option -bwidth} {default_width 300} {height_option -bheight} \
				{default_height 300} {rescale 1} {args_name args} } {
			upvar $args_name largs
			
			set x [dui::page::calc_x $pages $x $rescale]
			set y [dui::page::calc_y $pages $y $rescale]
			set x1 0
			set y1 0
			set width [dui::args::get_option $width_option "" 1 largs]
			if { $width ne "" } {
				set width [dui::page::calc_width $pages $width $rescale]
				set x1 [expr {$x+$width}]
			}
			set height [dui::args::get_option $height_option "" 1 largs]
			if { $height ne "" } {
				set height [dui::page::calc_height $pages $height $rescale]
				set y1 [expr {$y+$height}]
			} 
			
			if { [llength $largs] > 0 && [string is double [lindex $largs 0]] } {
				if { $x1 <= 0 } {
					set x1 [dui::page::calc_x $pages [lindex $largs 0] $rescale]
					set largs [lrange $largs 1 end]
				} else {
					msg -WARNING [namespace current] process_sizes: "conflicting width and x1 arguments specified"
				}
				
				if { [llength $largs] > 0 && [string is double [lindex $largs 0]] } {
					if { $y1 <= 0 } {
						set y1 [dui::page::calc_x $pages [lindex $largs 0] $rescale]
						set largs [lrange $largs 1 end]
					} else {
						msg -WARNING [namespace current] process_sizes: "conflicting height and y1 arguments specified"
					}
				}
			}
			
			if { $x1 <= 0 } {
				set x1 [expr {$x+$default_width}]
			}
			if { $y1 <= 0 } {
				set y1 [expr {$y+$default_height}]
			}
			
			set anchor [dui::args::get_option -anchor nw 1 largs]
			if { $anchor ne "nw" } {
				lassign [dui::item::anchor_coords $anchor $x $y [expr {$x1-$x}] [expr {$y1-$y}]] x y x1 y1
			}

			return [list $x $y $x1 $y1]
		}
		
		# Processes the -yscrollbar* named options in 'args' and produces the scrollbar slider widget according to 
		#	the provided options.
		# All the -yscrollbar* options are removed from 'args'.
		# Returns 0 if the scrollbar is not created, or the widget name if it is.
		# OBSOLETE, now other commands use 'dui add yscrollbar'
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
	namespace eval page {
		namespace export add current previous exists is_setup is_drawn is_visible type bbox width height list theme \
			retheme recreate resize delete get_namespace load show open_dialog close_dialog add_action actions items has_item \
			update_onscreen_variables add_items calc_x calc_y calc_width calc_height split_space
		namespace ensemble create
		
		# Metadata for every added page. Array keys have the form '<page_name>,<type>', where <type> can be:
		#	'args': The list or arguments after 'dui page add <page>'. Serves to recreate the page if needed. 
		#	'ns': Page namespace. Empty string if the page doesn't have a namespace.
		#	'theme': the theme in use when the page is setup		
		#	'load': List of Tcl callbacks to run when the page is going to be shown, but before it is actually shown.
		#	'show': List of Tcl callbacks to run just after the page is shown.
		#	'hide': List of Tcl callbacks to run just after the page is hidden.
		#	'setup': List of Tcl callbacks to run just after the page is setup
		#	'variables': List of canvas_ids-tcl_code variable pairs to update on the page while it's visible.
		#  	'state': a list with 2 booleans that contains {<is_setup> <is_drawn>}
		#	'type': the type of page, can take values 'default' or 'dialog'.
		#	'bbox': the {x0 y0 x1 y1} bounding box coordinates for dialog-type pages, in base screen resolution 2560x1600
		variable pages_data
		array set pages_data {}

		variable current_page {}
		variable previous_page {}
		variable dialog_states
		array set dialog_states {}
		
		# Use a dictionary to store the current pages stack when dialogs are shown, to allow for several dialogs,
		# each with its own return callback.
		# The first element in the stack should always be a non-dialog page. If a non-dialog page is loaded,
		# the stack is cleared and the new non-dialog page is the new first item. As dialogs (either type=dialog or
		# type=fpdialog) are loaded, they are addded on top of the stack.
		# Stack keys are the page names. Stack values store the return callbacks. 
		variable page_stack
		set page_stack [dict create]

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
		#  -bg_shape the shape to use as background, if -bg_img is not defined. Default is rectangle, but can take any
		#		other as accepted by 'dui add shape'.
		#  -skin passed to ::add_de1_page if necessary
		#  -namespace either a value that can be a boolean, or a list of namespaces names.
		#		If the option is not specified, uses ::dui::create_page_namespaces as default. Then:
		#		If 'true' or equivalent, uses namespace ::dui::pages::<page_name> for each page, creating it if necessary.
		#		If 'false' or equivalent, uses no page namespace.
		#		Otherwise, uses the passed namespaces for each page. A namespace can be provided for each page, or
		#			a common namespace can be used for all of them. If the namespace does not exist yet, it is created,
		#			and the data array variable is defined. 
		#  -theme: the theme to use on page setup. If undefined, uses the current theme
		#  -type: the type of the page, either "default" or "dialog". 
		#  -bbox: for pages with type=dialog, the initial bounding box coordinates {x0 y0 x1 y1} of the dialog rectangle.
		#		If not specified for a dialog-type page, it defaults to full page.
		
		proc add { pages args } {
			variable pages_data
			array set opts $args
			set can [dui canvas]
			
			# Validate page names
			foreach page $pages {
				if { ![string is wordchar $page] } {
					error "Page names can only have letters, numbers and underscores. '$page' is not valid."
				} elseif { [string is integer $page] } { 
					error "Page names can not be numeric only, please change '$page'."
				} elseif { $page in {page pages all true false yes no 1 0} } {
					error "The following page names cannot be used: page, pages, all, true, false, yes, no, 1 or 0."
				} elseif { [exists $page] } {
					error "Page names must be unique. '$page' is duplicated."
				}
			}

			# Parse arguments
			set pages_data(${page},args) $args
			set ns [dui::args::get_option -namespace [dui cget create_page_namespaces] 1]
			set theme [dui::args::get_option -theme [dui theme get] 1]
			if { ![dui theme exists $theme] } {
				msg -WARNING [namespace current] add: "theme '$theme' for pages '$pages' unknown, resorting to 'default'"
				set theme default
			}
			set style [dui::args::get_option -style "" 1]
			set page_type [dui::args::get_option -type "default" 1]
			if { $page_type eq "dialog" } {
				set aspect_type "dialog_page"
			} else {
				set aspect_type "page"
				if { $page_type ne "default" && $page_type ne "fpdialog" } {
					msg -WARNING [namespace current] add: "page type '$page_type' not supported, assuming 'default'"
					set page_type "default"
				}
			}
			
			dui::args::process_aspects $aspect_type $style
			set bbox [subst {0 0 [expr {int($::dui::_base_screen_width)}] [expr {int($::dui::_base_screen_height)}]}]
			set bbox [dui::args::get_option -bbox $bbox 1]
			set bg_img [dui::args::get_option -bg_img [dui aspect get $aspect_type bg_img -style $style] 1]
			set bg_color [dui::args::get_option -bg_color [dui aspect get $aspect_type bg_color -theme $theme -style $style] 1]
			set bg_shape [dui::args::get_option -bg_shape [dui aspect get $aspect_type bg_shape -theme $theme -style $style -default "rect"] 1]
			
			# Create "page infrastructure" variables
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
									array set data {}
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
			
			foreach page $pages {
				set pages_data($page,theme) $theme
				set pages_data($page,type) $page_type
				set pages_data($page,state) {0 0}
				if { $page_type eq "dialog" } {
					set pages_data($page,bbox) $bbox
				}
			}

			# Create page background
			set img_name ""
			if { $bg_img ne "" } {
				#::add_de1_page $pages $bg_img [dui::args::get_option -skin ""]
				#add_de1_image $page 0 0 $bg_img
				set preload_images [dui cget preload_images]
				set bg_img [dui::image::find $bg_img 1]
				if { $bg_img ne "" && [dui::image::is_loaded "$bg_img"] } {
					set img_name [dui::image::get "$bg_img"]
				} 
				if { $bg_img ne "" && $img_name eq "" } {
					set img_name [dui::image::load photo [lindex $pages 0] $bg_img $preload_images]
				}
				if { $img_name ne "" } {
					foreach page $pages {
						$can create image {0 0} -anchor nw -image $img_name -tags [::list $page pages] -state "hidden"
					}
				}
			} 
			
			if { $bg_img eq "" } {
				foreach page $pages {
					if { $bg_color ne "" && $bg_shape in {{} rect rectangle round round_outline} } {
						dui::args::add_option_if_not_exists -fill $bg_color
						#dui::args::add_option_if_not_exists -width 0
					}
					dui add shape $bg_shape {} {*}$bbox -tags [::list $page pages] -aspect_type $aspect_type {*}$args
				}
			}
		}
		
		proc current {} {
			variable current_page
			return $current_page
		}

		proc previous {} {
#			variable previous_page
#			return $previous_page
			variable page_stack
			
			if { [dict size $page_stack] > 1 } {
				return [lindex [dict keys $page_stack] end-1]
			} else {
				return {}
			}
		}
		
		proc exists { page } {
			return [expr { [[dui canvas] find withtag pages&&$page] ne "" }]
		}

		# Returns whether the page has been setup. This is equivalent to their namespace 'setup' command being invoked,
		# so always return 0 for pages without a namespace.
		proc is_setup { page } {
			variable pages_data
			# We don't detect nor warn about non-existing pages as pages that are not declared explicitly with  
			# dui::page::add or add_de1_page (such as settings pages, or saver) are not detected to exist						
#			if { ![exists $page] } {
#				msg -WARNING [namespace current] is_setup: "page '$page' does not exist"
#				return 0
#			}
			return [lindex [value_or_default pages_data($page,state) {0 0}] 0]
		}
		
		# Returns whether the page has been drawn at least one
		proc is_drawn { page } {
			variable pages_data
			# We don't detect nor warn about non-existing pages as pages that are not declared explicitly with  
			# dui::page::add or add_de1_page (such as settings pages, or saver) are not detected to exist			
#			if { ![exists $page] } {
#				msg -WARNING [namespace current] is_drawn: "page '$page' does not exist"
#				return 0
#			}			
			return [lindex [value_or_default pages_data($page,state) {0 0}] 1]
		}
		
		proc is_visible { page } {
			variable current_page
			# We don't detect nor warn about non-existing pages as pages that are not declared explicitly with  
			# dui::page::add or add_de1_page (such as settings pages, or saver) are not detected to exist			
#			if { ![exists $page] } {
#				msg -WARNING [namespace current] is_visible: "page '$page' does not exist"
#				return 0
#			}			
			return [expr {$page eq $current_page}]
		}
		
		proc type { page } {
			variable pages_data
			# We don't detect nor warn about non-existing pages as pages that are not declared explicitly with  
			# dui::page::add or add_de1_page (such as settings pages, or saver) are not detected to exist
#			if { ![exists $page] } {
#				msg -WARNING [namespace current] type: "page '$page' does not exist"
#				return "default"
#			}
			
			return [value_or_default pages_data($page,type) "default"]
		}

		# Returns the theme used when the page was created/added/setup.
		proc theme { page {default {}} } {
			variable pages_data
			return [value_or_default pages_data(${page},theme) $default]
		}
		
		# Returns the bounding box coordinates {x0 y0 x1 y1} of the rectangle that contains the current page.
		# If the page is not a dialog, always returns {0 2560 0 1600}
		proc bbox { page {rescale 0} } {
			variable pages_data
			# We don't detect nor warn about non-existing pages as pages that are not declared explicitly with  
			# dui::page::add or add_de1_page (such as settings pages, or saver) are not detected to exist			
#			if { ![exists $page] } {
#				msg -WARNING [namespace current] bbox: "page '$page' does not exist"
#				return {0 0 0 0}
#			}
			
			if { [info exists pages_data($page,bbox)] } {
				set bbox $pages_data($page,bbox)
			} else {
				set bbox "0 0 [expr {int($::dui::_base_screen_width)}] [expr {int($::dui::_base_screen_height)}]"
			}
			
			if { [string is true $rescale] } {
				set bbox "[dui::platform::rescale_x [lindex $bbox 0]] [dui::platform::rescale_y [lindex $bbox 1]] \
					[dui::platform::rescale_x [lindex $bbox 2]] [dui::platform::rescale_y [lindex $bbox 3]]"
			}
			
			return $bbox
		}
		
		proc width { page {rescale 0} } {
			lassign [bbox $page $rescale] px0 py0 px1 py1
			return [expr {$px1-$px0}]
		}

		proc height { page {rescale 0} } {
			lassign [bbox $page $rescale] px0 py0 px1 py1
			return [expr {$py1-$py0}]
		}
		
		proc list {} {
			variable pages_data
			set pages {}
			foreach arrname [array names pages_data "*,args"] {
				lappend pages [string range $arrname 0 end-5]
			}
			return $pages
		}
				
		# Returns a boolean list telling which of the pages have been deleted.
		proc delete { pages {keep_data 0} } {
			variable pages_data
			set can [dui canvas]
			set keep_data [string is true $keep_data]
			set is_deleted [lrepeat [llength $pages] 0]
			
			set i 0
			foreach page $pages {
				if { $page eq [current] } {
					msg -WARNING [namespace current] "cannot delete currently visible page '$page'"
					continue
				}
				if { ![exists $page] } {
					msg -NOTICE [namespace current] delete: "page '$page' not found"
					continue
				}

				set items_to_delete [items $page 1]
				foreach item $items_to_delete {
					if { [$can type $item] eq "window" } {
						destroy [$can itemcget $item -window]
					}
				}
				$can delete {*}$items_to_delete
			
				if { $keep_data } {
					set pages_data(${page},state) {0 0}
					set pages_data(${page},variables) {}
				} else {
					foreach key [array names pages_data "$page,*"] {
						unset pages_data($key)
					}
				}
				
				set msg "page '$page' has been deleted"
				if { $keep_data } {
					append msg " (keeping its data)"
				}
				msg -INFO [namespace current] $msg 
				lset is_deleted $i 1
				incr i
			}
			
			return $is_deleted
		}
		
		# Recreates pages changing some of its creation parameters. Takes the same arguments as dui::page::add.
		# Returns a list of booleans informing which pages have been actually recreated (normally all except
		# those that don't exist)
		proc recreate { pages args } {
			variable pages_data
			set is_recreated [lrepeat [llength $pages] 0]
			array set opts $args
			
			set i 0
			foreach page $pages {
				if { ![exists $page] } {
					msg -WARNING [namespace current] recreate: "page '$page' does not exist"
					continue
				}
				
				set add_page_args $pages_data(${page},args)
				if { [lindex [delete $page 1] 0] == 1 } {
					foreach opt [array names opts] {
						dui::args::remove_options $opt add_page_args
						dui::args::add_option_if_not_exists $opt $opts($opt) add_page_args
					}
					
					dui page add $page {*}$add_page_args
					lset is_recreated $i [setup $page]
				}
				
				incr i
			}
			
			return $is_recreated
		}
		
		# Rethemes pages. Returns a list of booleans telling which of the pages were rethemed.
		# If force=1, all requested pages are recreated even if their current theme equals the new one, whereas
		# if force=0 only recreates those that had a different theme.
		proc retheme { pages new_theme {force 0} } {
			if { ![dui theme exists $new_theme] } {
				msg -ERROR [namespace current] retheme: "new theme '$new_theme' is not a valid theme"
				return 0
			}
			
			if { [string is true $force] } {
				return [recreate $pages -theme $new_theme]
			} else {
				set is_rethemed [lrepeat [llength $pages] 0]
				set i 0
				foreach page $pages {
					if { ![exists $page] } {
						msg -WARNING [namespace current] retheme: "page '$page' does not exist"
						continue
					}
					if { [theme $page "default"] eq $new_theme } {
						continue
					}
					
					lset is_rethemed $i [recreate $page -theme $new_theme]
					
					incr i
				}
			}
			
			return $is_rethemed
		}
		
		# Resizes a dialog page. This requires deleting the page and recreating it. Pages that are intended to be
		# resized should place all its elements using percentage positions or positions computed dynamically from the
		# page dimensions. Returns 1 if the dialog is actually resized, 0 otherwise.
		proc resize { page width height } {
			if { [type $page] ne "dialog" } {
				msg -WARNING [namespace current] moveto: "page '$page' has to be a dialog"
				return 0
			}
			
			lassign [bbox $page] x0 y0 x1 y1
			if { $width > 0 && $width < 1 } {
				set width [expr {int($::dui::_base_screen_width*$width)}]
			}
			if { $height > 0 && $height < 1 } {
				set height [expr {int($::dui::_base_screen_height*$height)}]
			}
			set nx1 [expr {$x0+$width}]
			set ny1 [expr {$y0+$height}]
			
			if { $nx1 != $x1 || $ny1 != $y1 } {
				set bbox [subst {$x0 $y0 $nx1 $ny1}]
				recreate $page -bbox $bbox
				return 1
			} else {
				return 0
			}
		}
		
		# Moves a dialog page to a new location. Not exported as normally should only be called through open_dialog,
		# thus ensuring that the background page items are properly disabled/hidden.
		proc moveto { page x y {anchor nw} } {
			variable pages_data
			set can [dui canvas]
			
			set page [lindex $page 0]
			if { [type $page] ne "dialog" } {
				msg -WARNING [namespace current] moveto: "page '$page' has to be a dialog"
				return 0
			}
			
			lassign $pages_data($page,bbox) x0 y0 x1 y1
			if { $x > 0 && $x < 1 } {
				set x [expr {int($::dui::_base_screen_width*$x)}]
			}
			if { $y > 0 && $y < 1 } {
				set y [expr {int($::dui::_base_screen_height*$y)}]
			}
			
			if { $anchor ne "nw" } {
				lassign [dui::item::anchor_coords $anchor $x $y [expr {$x1-$x0}] [expr {$y1-$y0}]] x y
			}
			
			set dx [expr {int($x-$x0)}]
			set dy [expr {int($y-$y0)}]
			
			if { $dx != 0 || $dy != 0 } {
				set pages_data($page,bbox) [subst {$x $y [expr {$x1+$dx}] [expr {$y1+$dy}]}]
				
				set dx [dui::platform::rescale_x $dx]
				set dy [dui::platform::rescale_y $dy]
				
				foreach item [items $page 1] {
					$can move $item $dx $dy
				}
			}
			
			return 1
		}
		
		# Not exported as should only be called by other DUI commands
		proc setup { page } {
			variable pages_data
			set $page [lindex $page 0]
			
			if { ![exists $page] } {
				msg -WARNING [namespace current] "setup: page '$page' does not exist"
				return 0
			}
			set ns [get_namespace $page]
			if { $ns eq "" } {
				msg -WARNING [namespace current] "setup: page '$page' does not have a namespace, cannot be setup"
				return 0
			}			
			if { [info proc ${ns}::setup] eq "" } {
				msg -NOTICE [namespace current] "setup: page namespace '$ns' does not have a setup method"
				return 0
			} 
			if { [is_setup $page] } {
				msg -WARNING [namespace current] "setup: page '$page' is already setup. Delete it first for re-setup, or retheme it"
				return 0
			}
			
			#msg -DEBUG [namespace current] "running ${ns}::setup for page '$page'"
			set current_theme [dui theme get]
			set page_theme [theme $page]
			if { $current_theme ne $page_theme } {
				dui theme set $page_theme
			}
			
			try {
				${ns}::setup
			} on error err {
				msg -ERROR [namespace current] "setup for page '$page' with theme '$page_theme' failed: $err"
				dui theme set $current_theme
				return 0
			}
			
			# Run generic and page-specific setup actions
			foreach action [actions {} setup] {
				lappend action $page
				uplevel #0 $action
			}
			foreach action [actions $page setup] {
				lappend action $page
				uplevel #0 $action
			}
			
			dui theme set $current_theme
			set pages_data(${page},state) {1 0}
			return 1
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
		#
		# Named options (args parsed by this function, and removed from $args before passing it to the page load method):
		#	-reload <boolean>: Default 0. If the page requested to be loaded is the same as the current one, should it be reloaded?
		#	-_run_load_actions <boolean>. Default 1. Whether to run the 'load' actions, or only the 'show' actions.
		#		Normally only used by other DUI commands.
		#	-return_callback <proc_name>: Tcl function that will process the result of the page. Normally used for dialogs, 
		#		though can also be used with full pages that behave as dialogs.
		#		This callback function must have arguments that match those returned by the dui::page::close_dialog call 
		#		in the dialog code. 
		#		If this is empty, no special processing is done. This can make sense in some scenarios, for example, 
		#		if the dialog is used to modify a global variable which the calling page reads automatically.
		#	-disable_items <boolean>: Default is 1. Only affects if the page to show has type=dialog.
		#		If 1, the canvas items in the current/background page are explicitly disabled (which may change their 
		#		aspect). If 0, they are not disabled (but they are not clickable as there's a transparent full-screen 
		#		size rectable on top. Tk widgets are always disabled, otherwise they can be clicked as they always 
		#		appear on top of canvas items.
		
		proc load { page_to_show args } {
			variable current_page
			variable previous_page
			variable pages_data
			variable dialog_states
			variable page_stack
			set can [dui canvas]

			catch { delay_screen_saver }
			
			if { [dui::args::has_option -theme] } {
				dui page retheme $page_to_show [dui::args::get_option -theme {} 1]
			}
				
			# run general load actions (same for all pages) in the global context. 
			# If 1 or a string is returned, the loading process continues. 
			# If it's a string that matches a page name, the page to show is changed to that one. 
			# If 0 is returned, the loading process is interrupted.
			# Note that this time we don't use [string is true] as "off" is evaluated as boolean...
			set page_to_hide [current]
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
				msg -NOTICE [namespace current] load "returning because current_page == $page_to_show"
				return 
			}
			
			set hide_ns [get_namespace $page_to_hide]
			set show_ns [get_namespace $page_to_show]
			if { $page_to_hide eq "" } {
				set hide_page_type ""
			} else {
				set hide_page_type [type $page_to_hide]
			}
			set show_page_type [type $page_to_show]
			
			if { $show_page_type eq "dialog" && $hide_page_type eq "dialog" } {
				msg -WARNING [namespace current] load: "only one dialog page can be visible, can't move from dialog '$page_to_hide' to dialog '$page_to_show'"
				return
			}			
			msg [namespace current] load "$page_to_hide -> $page_to_show"
			dui sound make page_change
			
			#msg "page_display_change $page_to_show"
			#set start [clock milliseconds]
			set return_callback [dui::args::get_option -return_callback {} 1]
			set disable_items [string is true [dui::args::get_option -disable_items 1 1]]
			
			# run page-specific load actions
			set run_load_actions 1
			if { [::dui::args::has_option -_run_load_actions] } {
				set run_load_actions [string is true [::dui::args::get_option -_run_load_actions 1 1]]
			}
			
			if { $run_load_actions } {
				# TBD: Pass $args to load actions???
				foreach action [actions $page_to_show load] {
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
				if { $show_ns ne "" && [info procs ${show_ns}::load] ne "" } {
					set action_result [${show_ns}::load $page_to_hide $page_to_show {*}$args]
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
			}

			# Handle page stack
			if { $show_page_type eq "default" } {
				set page_stack [dict create $page_to_show {}]
			} elseif { !($current_page eq $page_to_show && [string is true $reload]) }  {
				# If the page to show was already in the stack, remove any page after it.
				set show_stack_idx [lsearch [dict keys $page_stack] $page_to_show]
				if { $show_stack_idx > -1 } {
					if { $show_stack_idx < [dict size $page_stack]-1 } {
						dict unset page_stack {*}[lrange [dict keys $page_stack] [expr {$show_stack_idx+1}] end]
					}
					#set page_stack [dict replace $page_stack $page_to_show $return_callback]
				} else {
					dict set page_stack $page_to_show $return_callback
				}
			}
			
			# update current and previous pages. In case the pages are dialogs, "previous_page" contains the stack of open pages
			set back_from_dialog 0
			if { $hide_page_type eq "dialog" } {
				set previous_page [lappend previous_page $page_to_hide]
				#set dialog_return_cmd [dui::args::get_option -reload 0 1]
				set back_from_dialog [expr {$page_to_show eq $previous_page}]
			} elseif { $page_to_hide ne {} } {
				set previous_page $page_to_hide
			}
			set current_page $page_to_show
			set ::de1(current_context) $page_to_show

			# check if page background is an image with delayed loading that requires first-time-use loading now
			set preload_images [dui cget preload_images]
			set page_bg "" 
			if { !$preload_images } {
				set page_bg [$can find withtag $page_to_show]
				if { $page_bg ne "" } {
					if { [$can type $page_bg] eq "image" } {
						set img_name [$can itemcget $page_to_show -image]
						msg -INFO [namespace current] load: "loading delayed page image background for page '$page_to_show', with img_name=$img_name"
						if { [dui::image::exists_delayed $img_name] } {
							dui::image::load_delayed $img_name
						}
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
			
			if { $hide_page_type eq "dialog" } {
				foreach item [items $page_to_hide] {
					$can itemconfigure $item -state hidden
				}
				$can itemconfigure _dlg_bg -state hidden
			} 
			
			# If there's a set of saved item states, restore them, even if we're not back to the same page, as
			# Tk widgets disabling is not restored by canvas showing them.
			if { [array size dialog_states] > 0 } {
				foreach item [array names dialog_states] {
					if { [$can type $item] eq "window" } {
						try {
							[$can itemcget $item -window] configure -state $dialog_states($item)
						} on error err {}
					} 
					$can itemconfigure $item -state $dialog_states($item)
				}
				array unset dialog_states
			}
			
			# If showing a dialog page, store the state of the previous page items so it can be restored afterwards, 
			# then disable them. If showing a normal page, just hide every single canvas item.
			if { $show_page_type eq "dialog" } {
				# Tk widgets always appear on top of any canvas item. So we need to iterate through widgets in the 
				# background page, disabling those that don't overlap the dialog, and hiding those that do.
				array set dialog_states {}
				set hide_page_items [items $page_to_hide]
				foreach item $hide_page_items {	
					if { [$can type $item] eq "window" } {
						set w [$can itemcget $item -window]
						# "try" as not all widgets support the -state option (e.g. Graph)	
						try {
							set state [$w cget -state]
							set dialog_states($item) $state
							if { $state ne "hidden" } {
								$w configure -state disabled
							}
						} on error err {
							#msg -WARNING [namespace current] add: "widget of type '[winfo class $w]' doesn't support the -state option"
							set state [$can itemcget $item -state]
							set dialog_states($item) $state
							if { $state ne "hidden" } {
								$can itemconfigure $item -state disabled
							}
						}
					} else {
						set state [$can itemcget $item -state]
						set dialog_states($item) $state
						if { $disable_items && $state ne "hidden" } {
							$can itemconfigure $item -state disabled
						}
					}
				}
			
				foreach item [$can find overlapping {*}[bbox $page_to_show 1]] {
					if { [$can type $item] eq "window" && $item in $hide_page_items } {
						$can itemconfigure $item -state hidden
					}
				}
				
				$can raise _dlg_bg
				$can raise $page_to_show
				$can raise $page_to_show*
				$can lower _dlg_bg $page_to_show
				$can itemconfigure _dlg_bg -state normal
			} else {
				# hide all canvas items at once!
				$can itemconfigure all -state hidden
			}
			
			if { !$back_from_dialog } {
				# show page background item first
				try {
					# If we restrict to items that have tag 'pages', the screensaver images are not shown.
					# TODO: Check how the saver is created, maybe that can be taken care off there, as without restricting
					#	to have the 'pages' tag some unexpected items could eventually appear if user extra tags are 
					#	used.
					#$can itemconfigure pages&&$page_to_show -state normal
					$can itemconfigure $page_to_show*||$page_to_show -state normal
				} on error err {
					msg -ERROR [namespace current] load: "showing page '$page_to_show' background: $err"
				}
				
				# show page items using the "p:<page_name>" tags, unless they have a "st:hidden" tag.
				# show Tk widgets initially disabled so then don't take the "phantom tap" from the previous page.
				set items_to_show [items $page_to_show]
				if { [llength $items_to_show] == 0 } {
					# If no items to show, very likely the page has not been setup yet (e.g. a dui page in a plugin enabled late in the session)
					# Try to auto-launch its setup if possible.
					if { $show_ns ne "" && ![is_setup $page_to_show] } {
						setup $page_to_show
						
						set items_to_show [items $page_to_show]
						if { [llength $items_to_show] == 0 } {
							msg -WARNING [namespace current] "page '$page_to_show' has no visual items to show"
						}
					} 
				}
				if { [llength $items_to_show] == 0 } {
					msg -WARNING [namespace current] "page '$page_to_show' has no visual items to show"
				}
			
				set previous_item $page_to_show
				foreach item $items_to_show {
					set item_type [$can type $item]
					if { !$preload_images && $item_type eq "image" } {
						set img_name [$can itemcget $item -image]
						if { [dui::image::exists_delayed $img_name] } {
							set img_name [dui::image::load_delayed $img_name]
						}
					}

					set state [lsearch -glob -inline [$can gettags $item] {st:*}]
					if { $state eq "" } {
						set state normal
					} else {
						set state [string range $state 3 end]
						if { $state ni {hidden disabled} } {
							set state normal
						}
					}
						
					if { $state in {normal disabled} } {
						if { $::android == 1 && [dui cget use_finger_down_for_tap] } {
							if { $item_type eq "window" } {
								$can itemconfigure $item -state disabled
									if { $state eq "normal" } {
									# Do NOT just show the items. We need to check we're still in the same page after the 400 ms
									after 400 dui::item::show $page_to_show $item
								}
							} else {
								$can itemconfigure $item -state $state
							}
						} else {
							$can itemconfigure $item -state $state
						}
						
						if { $show_page_type eq "dialog" && $previous_item ne {} } {
							# Ensure the z-order stack is properly maintained 
							$can raise $item $previous_item
						}
					}
					
					if { $state ne "hidden" && $item ne {} } {
						set previous_item $item
					}
				}
			}
			
			# Flag is_drawn
			if { [info exists pages_data(${page_to_show},state)] } {
				lset pages_data(${page_to_show},state) 1 1
			} else {
				set pages_data(${page_to_show},state) {0 1}
			}
			
			# Originally (before DUI) it was critical to call 'update' here and give it a bit of time, otherwise the 
			# 'show' actions afterwards may not get the right dimensions of widgets that have never been painted during 
			# the session. That's also why the show actions are triggered "after iddle".
			# BUT update is considered harmful (see https://wiki.tcl-lang.org/page/Update+considered+harmful), so NOW 
			#	all hide/show actions in DUI are triggered "after idle" and controls dynamic relocation/redimensioning is 
			#	done on Configure event bindings, so calling "update" should not be necessary any more.
			#update
			
			# run show actions
			foreach action [actions {} show] {
				after idle $action $page_to_hide $page_to_show
			}			
			foreach action [actions $page_to_show show] {
				# TODO: Append args once old-system actions like ::after_show_extensions are migrated 
				after idle $action
			}			
			if { $show_ns ne "" && [info procs ${show_ns}::show] ne "" } {
				after idle ${show_ns}::show $page_to_hide $page_to_show
			}
			
			#set end [clock milliseconds]
			#puts "elapsed: [expr {$end - $start}]"
			
			dui::page::update_onscreen_variables
			dui platform hide_android_keyboard
			#msg [namespace current] "Switched to page: $page_to_show [stacktrace]"
		}
		
		# A one-liner to conditionally load a page only if the specified widget is enabled. Useful for commands run
		# when double-tapping an entry box.
		proc load_if_widget_enabled { widget args } {
			if { [$widget cget -state] eq "normal" } {
				load {*}$args
			}
		}
		
		proc show { page_to_show } {
			load $page_to_show -_run_load_actions no
		}

		# Opens a page of type 'dialog'. 
		# Named options:
		#	-coords {x y}: A list with a pair of coordinates that gives the reference point (see -anchor) where the dialog 
		#		should appear on screen, on the base 2560x1600 space, or in a percentage of that space (if >0 & <1).  
		#		If not defined, the dialog is open on the same position where it was open the last time. 
		#		If it has never been open, that will be the position where it was created.
		#	-anchor <anchor>: Specifies how the reference point given in -coords should be anchored to, default is "nw".
		#	-size {width height}: A list with the target width and height of the dialog page, on the base 2560x1600 space 
		#		or in percentage of that space (if >0 & <1). The dialog page will be resized as needed, by recreating the page.
		#	-return_callback <proc_name>: Fully qualified name of a tcl function that will process the parameters returned by the dialog 
		#		when it is closed. This callback function must have arguments that match those returned by the
		#		dui::page::close_dialog call in the dialog code. 
		#		If this is empty, no special processing is done. This can work, for example, if the dialog is used to
		#		modify a global variable which the calling page reads automatically.
		#	-disable_items <boolean>: Default is 1. If 1, the canvas items in the current/background page are explicitly 
		#		disabled (which may change their aspect). If 0, they are not disabled (but they are not clickable as 
		#		there's a transparent full-screen size rectable on top. Tk widgets are always disabled, otherwise they
		#		can be clicked as they always appear on top of canvas items.
		#
		#	-return_callback and -disable_items are passed to dui::page::load. All additional arguments are also passed 
		#		through to dui::page::load, which then passes them to the dialog page load method.
		proc open_dialog { page args } {
			if { ![exists $page] } {
				msg -WARNING [namespace current] open_dialog: "page '$page' does not exist"
				return 0
			}
			set page_type [type $page] 
			if { $page_type ne "dialog" && $page_type ne "fpdialog" } {
				msg -WARNING [namespace current] open_dialog: "page '$page' is not a dialog"
				return 0
			}
			
			set dims [dui::args::get_option -size {} 1]
			if { $dims ne {} } {
				dui::page::resize $page {*}$dims
			}

			set coords [dui::args::get_option -coords {} 1]
			set anchor [dui::args::get_option -anchor "nw" 1]
			if { $coords ne {} } {
				dui::page::moveto $page {*}$coords $anchor
			}

			if { $page_type eq "dialog" } { 
				dui::args::add_option_if_not_exists -theme [dui theme get]
			}
			dui page load $page {*}$args
		}
		
		# Closes a page of type 'dialog' and returns control to the page that opened the dialog, invoking the return
		# callback (if it was defined) *AFTER* the previous page is totally loaded and shown. 
		# Arguments given to dui::page::close_dialog are passed through to the return callback proc.
		proc close_dialog { args } {
			variable page_stack
			
			set page [current]
			set page_type [type $page]
			if { $page_type ne "dialog" && $page_type ne "fpdialog" } {
				msg -WARNING [namespace current] close_dialog: "page '$page' is not a dialog"
				return 0
			}

			set previous_page [previous]
			if { $previous_page eq {} } {
				msg -WARNING [namespace current] close_dialog: "no previous page to return to"
				dui page load off
				return 0
			} else {
				set return_callback [dict get $page_stack $page]
				dui page show $previous_page

				if { $return_callback ne {} } {
					after idle $return_callback $args
				}
					
				return 1
			}
		}
		
		proc add_action { pages event tclcode } {
			variable pages_data
			if { $event ni {setup load show hide update_vars} } {
				error "'$event' is not a valid event for 'dui page add_action'"
			}
			if { $pages eq "" } {
				# Run for all pages
				lappend pages_data(,$event) $tclcode
			} else {
				foreach page $pages {
					# Add action even if the page does not exist, it may be created later. In fact some DUI add commands
					# rely on this and create actions before the page is actually created, so we don't even warn.
					lappend pages_data($page,$event) $tclcode
					#msg -DEBUG [namespace current] add_action: "added '$event' action to page '$page': $tclcode"
				}
			}
		}
		
		proc actions { page event } {
			variable pages_data
			if { $event ni {setup load show hide update_vars} } {
				error "'$event' is not a valid event for 'dui page add_action'"
			}
			return [ifexists pages_data($page,$event)]
		}
				
		proc items { page {include_bg 0} } {
			set can [dui canvas]
			if { [llength $page] > 1 } {
				set page [lindex $page 0]
			}
			
			set items [$can find withtag p:$page]
			if { [string is true $include_bg] } {
				lappend items {*}[$can find withtag pages&&($page||$page*)]
			}
			return $items
		}
		
		proc has_item { page tag {include_bg 0} } {
			if { [llength $page] > 1 } {
				set page [lindex $page 0]
			}

			if { [string is true $include_bg] } {
				set items [[dui canvas] find withtag ($tag&&p:$page)||$page||$page*)]
			} else {
				set items [[dui canvas] find withtag $tag&&p:$page]
			}
			return [expr {$items ne ""}]
		}
		
		# Keep track of what labels are displayed in what pages. This is done through the "p:<page_name>" canvas tags 
		#	associated to each item. 
		# 'tags' can actually be canvas tags or ids (in code before DUI). 
		# This is provided for backwards-compatibility and as a helper for client code that creates its own GUI 
		#	elements, but is NOT USED BY DUI. The construction of the tags in dui::args::process_tags_and_var does
		#	the job.
		proc add_items { pages tags } {
			set can [dui canvas]

			foreach tag $tags {
				if { [string is integer $tag] } {
					set ids $tag
				} else {
					set ids [$can find withtag $tag]
				}
				
				foreach id $ids {
					set item_tags [$can gettags $id]
					set changed 0
					foreach page $pages {
						if { "p:$page" ni $item_tags } {
							lappend item_tags "p:$page"
							set page_id [$can find withtag $page]
							if { $page_id ne {} } {
								$can raise $id $page
							}
							set changed 1
						}
					}
					if {$changed == 1} {
						$can itemconfigure $id -tags $item_tags	
					}
				}
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
		
		# NOTE: Original implementation (before DUI) had a 'state' argument that was not used in the command, 
		# so it has been removed.
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
				set ns [dui::page::get_namespace $current_page]
				if { $ns ne "" && [info procs ${ns}::update_vars] ne "" } {
					uplevel #0 ${ns}::update_vars
				}				
				foreach action [actions $current_page update_vars] {
					uplevel #0 $action
				}
				
				# Update the variables				
				set ids_to_update $pages_data(${current_page},variables) 
				foreach {id varcode} $ids_to_update {
					set varvalue ""
					try {
						# Originally just [subst $varcode], but if 'list' was used within $varcode, it would use
						# 'dui page list' instead of '::list'						
						set varvalue [uplevel #0 [::list subst $varcode]]
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

			if {[info exists ::dui::page::update_onscreen_variables_alarm_handle] == 1} {
				after cancel $update_onscreen_variables_alarm_handle
				unset -nocomplain update_onscreen_variables_alarm_handle
			}
			set update_onscreen_variables_alarm_handle [after $::settings(timer_interval) ::dui::page::update_onscreen_variables]
			
		}
		
		# Calculates x-axis coordinates for pages items and returns absolute coordinates, either in the base screen
		# resolution 2560x1600 or in the current screen resolution.
		# If the page has type=dialog, coordinates are interpreted relative to the dialog page top-left point, 
		# otherwise they are absolute coordinates with respect to the {0 0} point. 
		# Also accepts percentage coordinates, if their value is between 0 and 1, that are interpreted as percentages
		# inside the page width.
		proc calc_x { page x {rescale 1} } {
			set page [lindex $page 0]
			if { [type $page] eq "dialog" } {
				lassign [bbox $page] x0 y0 x1 y1
				if { $x > 0 && $x < 1 } {
					set x [expr {int($x0+double($x1-$x0)*$x)}]
				} else {
					set x [expr {$x0+$x}]
				}
			} elseif { $x > 0 && $x < 1 } {
				lassign [bbox $page] x0 y0 x1 y1
				set x [expr {int($x0+double($x1-$x0)*$x)}]
			}
			
			if { [string is true $rescale] } {
				set x [dui::platform::rescale_x $x]
			}
			return $x
		}

		# Calculates y-axis coordinates for pages items and returns absolute coordinates, either in the base screen
		# resolution 2560x1600 or in the current screen resolution.
		# If the page has type=dialog, coordinates are interpreted relative to the dialog page top-left point, 
		# otherwise they are absolute coordinates with respect to the {0 0} point. 
		# Also accepts percentage coordinates, if their value is between 0 and 1, that are interpreted as percentages
		# inside the page height.		
		proc calc_y { page y {rescale 1} } {
			set page [lindex $page 0]
			if { [type $page] eq "dialog" } {
				lassign [bbox $page] x0 y0 x1 y1
				if { $y > 0 && $y < 1 } {
					set y [expr {int($y0+double($y1-$y0)*$y)}]
				} else {
					set y [expr {$y0+$y}]
				}
			} elseif { $y > 0 && $y < 1 } {
				lassign [bbox $page] x0 y0 x1 y1
				set y [expr {int($y0+double($y1-$y0)*$y)}]
			}

			if { [string is true $rescale] } {
				set y [dui::platform::rescale_y $y]
			}			
			return $y
		}
		
		# Calculates widths for pages items and returns absolute widths, either in the base screen
		# resolution 2560x1600 or in the current screen resolution.
		# Accepts percentage widths, if their value is between 0 and 1, that are interpreted as percentages
		# of the page total width.		
		proc calc_width { page width {rescale 1} } {
			set page [lindex $page 0]
			if { $width > 0 && $width < 1 } {
				lassign [bbox $page] x0 y0 x1 y1
				set width [expr {($x1-$x0)*$width}]
			}			
			if { [string is true $rescale] } {
				set width [dui::platform::rescale_x $width]
			}
			return $width
		}

		# Calculates heights for pages items and returns absolute widths, either in the base screen
		# resolution 2560x1600 or in the current screen resolution.
		# Accepts percentage heights, if their value is between 0 and 1, that are interpreted as percentages
		# of the page total height.
		proc calc_height { page height {rescale 1} } {
			set page [lindex $page 0]
			if { $height > 0 && $height < 1 } {
				lassign [bbox $page] x0 y0 x1 y1
				set height [expr {($y1-$y0)*$height}]
			}
			if { [string is true $rescale] } {
				set height [dui::platform::rescale_y $height]
			}			
			return $height
		}
		
		# Splits/slices a distance, defined by 'start' and 'end', using the spec given by args. Each argument provides 
		# either an absolute number of pixels (if >=1) or a percentage (if >=0 & <1). Once the absolute
		# portions are removed from the total distance, the remaining distance is splitted according to their relative ratio.
		# Returns a list, with one more element than $args, giving the cut point of each slice.
		# page_or_coords can be either a list with 4 coordinates {x0 y0 x1 y1} defining the available space, or the name
		# of a page. In the second case, the coords used are the bounding box for the page, shifted to {0 0} top-left
		# position so that the resulting values can be used to place items also in dialog pages.
		proc split_space { start end args } {
			set distance [expr {$end-$start}]
			
			# Loop first to compute the height of each item
			set sum_px_spec 0
			set sum_perc_spec 0
			foreach spec $args {
				if { $spec > 0 && $spec < 1 } {
					set sum_perc_spec [expr {$sum_perc_spec+$spec}]
				} elseif { $spec >= 1 } {
					set sum_px_spec [expr {$sum_px_spec+$spec}]
				}
			}
			
			set available_px [expr {$distance-$sum_px_spec}]
			if { $available_px < 0 } {
				set available_px 0
			}
			
			# Compute each item distance in pixels
			set result $start
			set i0 $start
			foreach spec $args {
				if { $spec < 0 } {
					set idist 0
				} elseif { $spec > 0 && $spec < 1 } {
					set idist [expr {round($available_px*($spec/$sum_perc_spec))}]
				} elseif { $spec >= 1 } {
					set idist $spec
				}
				set i1 [expr {$i0+$idist}]
				lappend result $i1
				
				set i0 $i1
			}
	
			return $result
		}
		
		# Run when the background page of a dialog is clicked.
		# If the page has a close_dialog command, invoke it (useful for dialogs that need to always provide 
		# data back to the invoking page), otherwise just call dui::page::close_dialog
		proc dialog_background_press { } {
			set dlg_page [current]
			if { [type $dlg_page] ne "dialog" } {
				return
			}
			
			set ns [get_namespace $dlg_page]
			if { [info procs ${ns}::close_dialog] ne "" } {
				${ns}::close_dialog
			} else {
				dui::page::close_dialog
			}
		}
		
	}
	
	### ITEMS SUB-ENSEMBLE ###
	# Items are visual items added to the canvas, either canvas items (text, arcs, lines...) or Tk widgets.
	namespace eval item {
		namespace export add delete get get_widget config cget enable_or_disable enable disable \
			show_or_hide show hide add_image_dirs image_dirs listbox_get_selection listbox_set_selection \
			relocate_text_wrt moveto pages
		namespace ensemble create
	
		# Stores the initial tap position when dragging dscale sliders. Array keys are <first_page>,<dscale_tag>, and
		# it contains the following value:
		#   * an empty string when not in the middle of a drag/motion movement;
		#   * the offset of the starting tap coordinate (x if horizontal, y if vertical) with respect to the left/top
		#       coordinate of the slider shape, when in the middle of a drag/motion movement.
		variable sliders
		array set sliders {}
		
		# A list of paths where to look for image and sound files. 
		# Within each image directory, it will look in the <screen_width>x<screen_height> subfolder.
		variable img_dirs {}
		variable sound_dirs {}
		
		# Tracks press times for longpress and similar events. Indexed by keys "<widget_id>,<event>".
		variable press_events
		array set press_events {}
		# Milliseconds to distinguish between press and longpress
		variable longpress_default_threshold 1500
		# Current longpress "after" event
		variable longpress_timer {}
	
		# Just a wrapper for the dui::add::<type> commands, for consistency of the API
		proc add { type args } {
			if { [info proc ::dui::add::$type] ne "" } {
				::dui::add::$type {*}$args
			} else {
				msg -ERROR [namespace current] add: "no 'dui add $type' command available"
			}
		}

		# Deletes items from the canvas. Returns the number of deleted items.
		proc delete { page_or_ids_or_widgets {tags {}} } {
			set items [get $page_or_ids_or_widgets $tags]
			
			if { [llength $items] > 0 } {
				set can [dui canvas]
				
				foreach item $items {
					if { [$can type $item] eq "window" } {
						destroy [$can itemcget $item -window]
					}
				}
				
				$can delete {*}$items
			}
			
			return [llength $items]
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
					msg -DEBUG [namespace current] get: "no canvas tag matches '$tag' in page '$page'"
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
				
			set istate [dui::args::get_option -initial_state "" 1]
			
			# Passing '$tags' directly to itemconfigure when it contains multiple tags not always works, iterating
			#	is often needed.
			foreach item $items {
				#msg [namespace current] "config:" "item '$item' of type '[$can type $tag]' with '$args'"
				if { $istate ne "" } {
					_config_initial_state $item $istate
				}
				
				if { [llength $args] > 0 } {
					if { [winfo exists $item] } {
						$item configure {*}$args
					} elseif { [$can type $item] eq "window" } {
						[$can itemcget $item -window] configure {*}$args
					} else {
						$can itemconfigure $item {*}$args
					}
				}
			}
		}
		
		proc _config_initial_state { item state } {
			set can [dui canvas]
			if { $state ni {hidden disabled normal} } {
				msg -WARNING [namespace current] "_config_initial_state: state '$state' not supported, assuming 'normal'"
				set state normal
			}
			set current_istate [_cget_initial_state $item]
			if { $current_istate eq $state } {
				return
			}

			if { $current_istate ne "normal" } {
				$can dtag $item st:$current_istate
			}
			if { $state ne "normal" } {
				$can addtag st:$state withtag $item
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
				if { "-initial_state" in $args } {
					set args [list_remove_element $args -initial_state]
					lappend result [_cget_initial_state $item]
				}
				
				if { [llength $args] > 0 } {
					#msg [namespace current] "config:" "item '$item' of type '[$can type $tag]' with '$args'"
					if { [winfo exists $item] } {
						lappend result [$item cget {*}$args]
					} elseif { [$can type $item] eq "window" } {
						lappend result [[$can itemcget $item -window] cget {*}$args]
					} else {
						lappend result [$can itemcget $item {*}$args]
					}
				}
			}
			return $result
		}
				
		proc _cget_initial_state { item } {
			set can [dui canvas]
			set tags [$can gettags $item]
			if { "st:hidden" in $tags } {
				return "hidden"
			} elseif { "st:disabled" in $tags } {
				return "disabled"
			} else {
				return "normal"
			}
		}
		
		# Returns the list of pages where the specified item appears
		proc pages { page_or_id_or_widget {tag {}} } {
			set can [dui canvas]
			set ids [get $page_or_id_or_widget $tag]
			if { [llength $ids] == 0} {
				msg -WARNING [namespace current] "pages: can't find item with page_or_id_or_widget='$page_or_id_or_widget' and tag '$tag'"
				return ""
			}
			
			set tags [$can gettags [lindex $ids 0]]
			set pages [list]
			foreach page [lsearch -inline -all $tags {p:*}] {
				lappend pages [string range $page 2 end]
			}
			
			return $pages
		}
		
		# "Smart" widgets enabler or disabler. 'enabled' can take any value equivalent to boolean (1, true, yes, etc.) 
		# For text, changes its fill color to the default or provided font or disabled color.
		# For other widgets like rectangle "clickable" button areas, enables or disables them.
		# Does nothing if the widget is hidden.
		proc enable_or_disable { enabled page_or_ids_or_widgets {tags {}} args } {
			set can [dui canvas]
			array set opts $args
			set do_current [string is true [dui::args::get_option -current 1]]
			set do_initial [string is true [dui::args::get_option -initial 0]]
			
			if { [string is true $enabled] || $enabled eq "enable" } {
				set state normal
			} else {
				set state disabled
			}

			foreach id [get $page_or_ids_or_widgets $tags] {
				if { $do_current } {
					if { [$can itemcget $id -state] ne "hidden" } {
						$can itemconfigure $id -state $state
						# Tk widgets need to be enabled/disabled directly, not through the canvas
						if { [$can type $id] eq "window" } {
							[$can itemcget $id -window] configure -state $state
						}
					}
				}
				if { $do_initial } {
					dui item config $id -initial_state $state
				}
			}
		} 
		
		# "Smart" widgets disabler. 
		# For text, changes its fill color to the default or provided disabled color.
		# For other widgets like rectangle "clickable" button areas, disables them.
		# Does nothing if the widget is hidden. 
		proc disable { page_or_ids_or_widgets {tags {}} args } {
			enable_or_disable 0 $page_or_ids_or_widgets $tags {*}$args
		}
		
		proc enable { page_or_ids_or_widgets {tags {}} args } {
			enable_or_disable 1 $page_or_ids_or_widgets $tags {*}$args
		}
		
		# "Smart" widgets shower or hider. 'show' can take any value equivalent to boolean (1, true, yes, etc.)
		# Named options:
		# -check_page (default 1): Only hides or shows if the items page is the currently active page. This is useful,
		#	for example, if you're showing after a delay, as the page/page may have been changed in between.
		# -current (default 1): Shows or hides in the currently active page.
		# -initial (default 0): Sets the initial state when the page is shown the next time, i.e. modifiess the
		#	item -initial_state option.
		proc show_or_hide { show page_or_ids_or_widgets {tags {}} args } {
#			if { $tags eq "" && [llength $page_or_ids_or_widgets] == 1 && [dui page exists $paGranadage_or_ids_or_widgets] && $check_page } {
#				if { $page_or_ids_or_widgets ne [dui page current] } {
#					return
#				}
#			}
			array set opts $args
			set check_page [string is true [dui::args::get_option -check_page 1]]
			set do_current [string is true [dui::args::get_option -current 1]]
			set do_initial [string is true [dui::args::get_option -initial 0]]
			
			if { [string is true $show] || $show eq "show" } {
				set state normal
			} else {
				set state hidden
			}
			
			foreach id [get $page_or_ids_or_widgets $tags] {
				if { $do_current } {
					if { $check_page } {
						if { [dui page current] in [dui item pages $id] } {
							[dui canvas] itemconfigure $id -state $state
						}						
					} else {
						[dui canvas] itemconfigure $id -state $state
					}
				}
				if { $do_initial } {
					dui item config $id -initial_state $state
				}
			}
		}
		
		proc show { page tags args } {
			show_or_hide 1 $page $tags {*}$args
		}
		
		proc hide { page tags args } {
			show_or_hide 0 $page $tags {*}$args
		}

		proc add_image_dirs { args } {
			return [dui image add_dirs {*}$args] 
		}
		
		proc image_dirs {} {
			return [dui image dirs]
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
		
		# Moves canvas items or compounds to a new screen location. Accepts percentage and empty coordinates.
		proc moveto { page_or_id_or_widget tag x y } {
			set can [dui canvas]
			set tag [lindex $tag 0]
			set items [dui item get $page_or_id_or_widget $tag]
			
			if { $tag eq {} } {
				set page [lindex [pages [lindex $items 0]] 0]
			} else {
				set page [lindex $page_or_id_or_widget 0]
			}

			if { $x ne {} } {
				set x [dui::page::calc_x $page $x]
			}
			if { $y ne {} } {
				set y [dui::page::calc_y $page $y]
			}
			
			if { [string range $tag end-1 end] eq "*" } {
				set refitem [dui item get $page_or_id_or_widget [string range $tag 0 end-1]]
			} else {
				set refitem [lindex $items end]
			}
			if { $refitem eq "" } {
				msg -WARNING [namespace current] "moveto: cannot locate reference item ${page_or_id_or_widget}::${tag}"
				return
			}
			
			lassign [$can coords $refitem] rx0 ry0 rx1 ry1
			if { $x eq {} } {
				set x $rx0
			}
			if { $y eq {} } {
				set y $ry0
			}
			foreach id $items {
				lassign [$can coords $id] x0 y0 x1 y1
				set nx0 [expr {$x+$x0-$rx0}]
				set ny0 [expr {$y+$y0-$ry0}]
				if { $x1 eq "" || $y1 eq "" } {
					$can coords $id $nx0 $ny0
				} else {
					set nx1 [expr {$nx0+($x1-$x0)}]
					set ny1 [expr {$ny0+($y1-$y0)}]
					$can coords $id $nx0 $ny0 $nx1 $ny1 
				}
			}
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
			
			if { ![dui::page::is_visible $page] } {
				return
			}
			
			set tag [get $page [lindex $tag 0]]
			set wrt [get $page [lindex $wrt 0]]
			lassign [$can bbox $wrt] x0 y0 x1 y1 
			lassign [$can bbox $tag] wx0 wy0 wx1 wy1
			
			if { $x0 eq {} || $wx0 eq {} } {
				# One of the items is hidden, so we can't get its coordinates
				return {}
			}
			
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
			
			# Don't use command 'moveto' as then -anchor is not acknowledged for text items
			set lcoords [llength [$can coords $tag]]
			
			if { $lcoords == 2 } {
				$can coords $tag [list $newx $newy]
			} elseif { $lcoords == 4 } {
				$can coords $tag [list $newx $newy [expr {$newx+($wx1-$wx0)}] [expr {$newy+($wy1-$wy0)}]]
			}
			
			if { $move_too ne "" } {
				lassign [$can bbox $tag] newx newy
				
				foreach w $move_too {			
					set mtcoords [$can coords $w]
					set mtxoffset [expr {[lindex $mtcoords 0]-$wx0}]
					set mtyoffset [expr {[lindex $mtcoords 1]-$wy0}]
					
					if { [llength $mtcoords] == 2 } {
						$can coords $w [list [expr {$newx+$mtxoffset}] [expr {$newy+$mtyoffset}]]
					} elseif { [llength $mtcoords] == 4 } {
						$can coords $w [list [expr {$newx+$mtxoffset}] [expr {$newy+$mtyoffset}] \
							[expr {$newx+$mtxoffset+[lindex $mtcoords 2]-[lindex $mtcoords 0]}] \
							[expr {$newy+$mtyoffset+[lindex $mtcoords 3]-[lindex $mtcoords 1]}]]
					}
				}
			}
					
			return [list $newx $newy]
		}
		
		proc relocate_dropdown_arrow { page tag } {
			set can [dui canvas]
			set page [lindex $page 0]
			set tag [lindex $tag 0]
			
			if { ![dui::page::is_visible $page] } {
				return
			}
			
			lassign [$can bbox [get $page $tag]] x0 y0 x1 y1 
			
			set dda_box_ids [get $page "${tag}-dda-btn"]
			lassign [$can coords [lindex $dda_box_ids 0]] ax0 ay0
			
			foreach id [concat $dda_box_ids [get $page "${tag}-dda"]] { 
				lassign [$can coords $id] ix0 iy0
				$can moveto $id [expr {$x1+($ix0-$ax0)}] [expr {$y0+($iy0-$ay0)}]
			}
			
			set dda_sym_id [get $page "${tag}-dda-sym"]
			# This only works correctly with bbox, not with coords, so it cannot be included in the loop above
			lassign [$can bbox $dda_sym_id] ix0 iy0
			$can moveto $dda_sym_id [expr {$x1+($ix0-$ax0)}] [expr {$y0+($iy0-$ay0)}]
			
			set debug_outline_id [get $page "${tag}-dda-dout"]
			if { $debug_outline_id ne "" } {
				lassign [$can coords $debug_outline_id] ix0 iy0
				$can moveto $debug_outline_id [expr {$x1+($ix0-$ax0)}] [expr {$y0+($iy0-$ay0)}]
			}
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
			if { ![dui::page::is_visible $page] } {
				return
			}
			
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
				set rescaled_value $dest1
			} elseif { $class eq "Multiline_entry" || $class eq "Text" } {
				if { $dest1 <= 0.0 && $dest2 >= 1.0 } {
					return
				}
				set rescaled_value [expr {$dest1/(1-($dest2-$dest1))}]
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
				$widget yview moveto $dest2
			} elseif { $class in {Multiline_entry Text} } {
				lassign [$widget yview] visible_start visible_end
				if { $visible_start <= 0.0 && $visible_end >= 1.0 } {
					return
				}
				$widget yview moveto [expr {$dest1*(1-($visible_end-$visible_start))}]
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
		# Doesn't rescale the coordinates {x0 y0 x1 y1} as this is normally not intended to be called by client code,
		# but to be invoked from dui::add:shape, dui::add::dbutton, etc.
		# 'radius' can be a list of up to 4 elements, giving the radius of each of the 4 corners separately, starting
		#	top-left and going clockwards {top-left top-right bottom-right bottom-left}. If it has less than 4 elements,
		#	they are replicated until having 4 elements.
		proc rounded_rectangle { x0 y0 x1 y1 radius colour disabled tags } {
			set can [dui canvas]
			set ids {}
			set nradius [llength $radius]
			set radius [lreplicate 4 $radius]
			lassign $radius radius1 radius2 radius3 radius4
			set maxradius [::max {*}$radius]
			
			if { $radius1 > 0 } {
				lappend ids [$can create oval $x0 $y0 [expr $x0 + $radius1] [expr $y0 + $radius1] -fill $colour -disabledfill $disabled \
					-outline $colour -disabledoutline $disabled -width 0 -tags $tags -state "hidden"]
			}
			if { $radius2 > 0 } {
				lappend ids [$can create oval [expr $x1-$radius2] $y0 $x1 [expr $y0 + $radius2] -fill $colour -disabledfill $disabled \
					-outline $colour -disabledoutline $disabled -width 0 -tags $tags -state "hidden"]
			}
			if { $radius3 > 0 } {
				lappend ids [$can create oval [expr $x1-$radius3] [expr $y1-$radius3] $x1 $y1 -fill $colour -disabledfill $disabled \
					-outline $colour -disabledoutline $disabled -width 0 -tags $tags -state "hidden"]
			}			
			if { $radius4 > 0 } {
				lappend ids [$can create oval $x0 [expr $y1-$radius4] [expr $x0+$radius4] $y1 -fill $colour -disabledfill $disabled \
					-outline $colour -disabledoutline $disabled -width 0 -tags $tags -state "hidden"]
			}
			
			if { $nradius == 1 } {
				lappend ids [$can create rectangle [expr $x0 + ($radius1/2.0)] $y0 [expr $x1-($radius1/2.0)] $y1 -fill $colour \
					-disabledfill $disabled -disabledoutline $disabled -outline $colour -width 0 -tags $tags -state "hidden"]
				lappend ids [$can create rectangle $x0 [expr $y0 + ($radius1/2.0)] $x1 [expr $y1-($radius1/2.0)] -fill $colour \
					-disabledfill $disabled -disabledoutline $disabled -outline $colour -width 0 -tags $tags -state "hidden"]
			} else {
				# Draw 5 rectangles to cover all possible combinations
				# Inner rectangle
				lappend ids [$can create rectangle [expr {$x0+($maxradius/2.0)}] [expr {$y0+($maxradius/2.0)}] \
					[expr {$x1-($maxradius/2.0)}] [expr {$y1-($maxradius/2.0)}] -fill $colour \
					-disabledfill $disabled -disabledoutline $disabled -outline $colour -width 0 -tags $tags -state "hidden"]
				# Top rectangle
				lappend ids [$can create rectangle [expr {$x0+($radius1/2.0)}] $y0 \
					[expr {$x1-($radius2/2.0)}] [expr {$y0+($maxradius/2.0)}] -fill $colour \
					-disabledfill $disabled -disabledoutline $disabled -outline $colour -width 0 -tags $tags -state "hidden"]
				# Bottom rectangle
				lappend ids [$can create rectangle [expr {$x0+($radius4/2.0)}] [expr {$y1-($maxradius/2.0)}] \
					[expr {$x1-($radius3/2.0)}] $y1 -fill $colour \
					-disabledfill $disabled -disabledoutline $disabled -outline $colour -width 0 -tags $tags -state "hidden"]
				# Left rectangle
				lappend ids [$can create rectangle $x0 [expr {$y0+($radius1/2.0)}] \
					[expr {$x0+($maxradius/2.0)}] [expr {$y1-($radius4/2.0)}] -fill $colour \
					-disabledfill $disabled -disabledoutline $disabled -outline $colour -width 0 -tags $tags -state "hidden"]
				# Right rectangle
				lappend ids [$can create rectangle [expr {$x1-($maxradius/2.0)}] [expr {$y0+($radius2/2.0)}] \
					$x1 [expr {$y1-($radius3/2.0)}] -fill $colour \
					-disabledfill $disabled -disabledoutline $disabled -outline $colour -width 0 -tags $tags -state "hidden"]
			}
			return $ids
		}
		
		# Inspired on Barney's rounded_rectangle, mimic DSx buttons showing a button outline without a fill.
		# Return the canvas IDs of all created items. 
		# Doesn't rescale the coordinates {x0 y0 x1 y1} as this is normally not intended to be called by client code,
		# but to be invoked from dui::add:shape, dui::add::dbutton, etc.
		# 'radius' can be a list of up to 4 elements, giving the radius of each of the 4 corners separately, starting
		#	top-left and going clockwards {top-left top-right bottom-right bottom-left}. If it has less than 4 elements,
		#	they are replicated until having 4 elements.		
		proc rounded_rectangle_outline { x0 y0 x1 y1 radius colour disabled width tags } {
			set can [dui canvas]
			set ids {}
			set main_tag [lindex $tags 0]
			
			set nradius [llength $radius]
			set radius [lreplicate 4 $radius]
			lassign $radius radius1 radius2 radius3 radius4
			set maxradius [::max {*}$radius]
			
			# in discussion https://github.com/decentespresso/de1app/issues/246 decided to remove -1 width code in the arc drawing, as it looks better at the same width
			#if { $width > 1 } {
				# Adjustment to look better under Android, that uses dithering
			#	set arc_width [expr {$width-1}]
			#} else {
			#	set arc_width $width
			#}
			set arc_width $width

			if { $radius1 > 0 } {
				lappend ids [$can create arc $x0 [expr {$y0+$radius1+1.0}] [expr {$x0+$radius1+1.0}] $y0 -style arc -outline $colour \
					-width $arc_width -tags [list ${main_tag}-nw ${main_tag}-cor {*}$tags] -start 90 -disabledoutline $disabled -state "hidden"]
			}
			if { $radius2 > 0 } {
				lappend ids [$can create arc [expr {$x1-$radius2-1}] $y0 $x1 [expr {$y0+$radius2+1}] -style arc -outline $colour \
					-width $arc_width -tags [list ${main_tag}-ne ${main_tag}-cor {*}$tags] -start 0 -disabledoutline $disabled -state "hidden"]
			}
			if { $radius3 > 0 } {
				lappend ids [$can create arc [expr {$x1-$radius3-1.0}] $y1 $x1 [expr {$y1-$radius3-1.0}] -style arc -outline $colour \
					-width $arc_width -tags [list ${main_tag}-se ${main_tag}-cor {*}$tags] -start -90 -disabledoutline $disabled -state "hidden"]
			}			
			if { $radius4 > 0 } {
				lappend ids [$can create arc $x0 [expr {$y1-$radius4-1.0}] [expr {$x0+$radius4+1.0}] $y1 -style arc -outline $colour \
					-width $arc_width -tags [list ${main_tag}-sw ${main_tag}-cor {*}$tags] -start 180 -disabledoutline $disabled -state "hidden"]
			}

			# Top line
			lappend ids [$can create line [expr {$x0+$radius1/2.0-1.0}] $y0 [expr {$x1-$radius2/2.0+1.0}] $y0 -fill $colour \
				-width $width -tags [list ${main_tag}-n ${main_tag}-lin {*}$tags] -disabledfill $disabled -state "hidden"]
			# Right line
			lappend ids [$can create line $x1 [expr {$y0+$radius2/2.0-1.0}] $x1 [expr {$y1-$radius3/2.0+1.0}] -fill $colour \
				-width $width -tags [list ${main_tag}-e ${main_tag}-lin {*}$tags] -disabledfill $disabled -state "hidden"]
			# Bottom line
			lappend ids [$can create line [expr {$x0+$radius4/2.0-1.0}] $y1 [expr {$x1-$radius3/2.0+1.0}] $y1 -fill $colour \
				-width $width -tags [list ${main_tag}-s ${main_tag}-lin {*}$tags] -disabledfill $disabled -state "hidden"]
			# Left line
			lappend ids [$can create line $x0 [expr {$y0+$radius1/2.0-1.0}] $x0 [expr {$y1-$radius4/2.0+1.0}] -fill $colour \
				-width $width -tags [list ${main_tag}-w ${main_tag}-lin {*}$tags] -disabledfill $disabled -state "hidden"]
			return $ids
		}
		
		# Moves the slider in the dscale to the provided position. This has 2 modes:
		#	1) If slider_coord is specified, changes the value of variable $varname according to the relative
		#		position of the slider within the scale, given by slider_coord.
		#	2) If slider_coord is not specified, uses the value of $varname and moves the slider to match the value.
		# Needs 'args' at the end because this is called from a 'trace add variable'.
		proc dscale_moveto { page dscale_tag varname from to {resolution 1} {n_decimals 0} {slider_coord {}} \
				{slider_change {}} args } {
			variable sliders
			if { ![info exists sliders(${page},${dscale_tag})] } {
				msg -WARNING [namespace current] scale_moveto: "scale on page '$page' with tag '$dscale_tag' not found"
				return
			}
			set offset $sliders(${page},${dscale_tag})
			# If we're in the middle of a slider drag motion and are here due to the trace add variable, do nothing.
			if { $slider_coord eq "" && $offset ne "" } return
			if { $offset eq "" } {
				set offset 0
			}

			set can [dui canvas]
			set slider [dui item get $page "${dscale_tag}-crc"]
			if { $slider eq "" } return
			lassign [$can bbox $slider] sx0 sy0 sx1 sy1
			# Return if the page is not currently visible
			if {$sx0 eq "" } return	
			
			set back [dui item get $page "${dscale_tag}-bck"]
			set front [dui item get $page "${dscale_tag}-frn"]
			if { $back eq "" || $front eq "" } {
				return
			}

			lassign [$can coords $back] bx0 by0 bx1 by1
			lassign [$can coords $front] fx0 fy0 fx1 fy1
				
			set swidth [expr {$sx1-$sx0}]
			set sheight [expr {$sy1-$sy0}]
			if { ($bx1 - $bx0) >= ($by1 -$by0) } {
				set orient h
				if { $slider_coord ne "" } {
					set slider_coord [dui::platform::translate_coordinates_finger_down_x $slider_coord]
				}
			} else {
				set orient v
				if { $slider_coord ne "" } {
					set slider_coord [dui::platform::translate_coordinates_finger_down_y $slider_coord]
				}
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
#					if { $varvalue <= $from } {
#						switch $orient h {set slider_coord $bx0} v {set slider_coord [expr {$by1-$sheight/2}]}
#					} elseif { $varvalue >= $to } {
#						switch $orient h {set slider_coord [expr {$bx1-$swidth/2}]} v {set slider_coord $by0 }
#					} elseif { $orient eq "h" } {
#						set slider_coord [expr {($bx0+$swidth/2)+($bx1-$bx0-$swidth)*$varvalue/($to-$from)}]
#					} else {
#						set slider_coord [expr {($by1-$sheight/2)+($by1-$by0-$sheight)*$varvalue/($from-$to)}]
#					}
					if { $varvalue <= $from } {
						switch $orient h {set slider_coord $bx0} v {set slider_coord [expr {$by1-$sheight}]}
					} elseif { $varvalue >= $to } {
						switch $orient h {set slider_coord [expr {$bx1-$swidth}]} v {set slider_coord $by0 }
					} elseif { $orient eq "h" } {
						set slider_coord [expr {round($bx0+($bx1-$bx0-$swidth)*double($varvalue-$from)/double($to-$from))}]
					} else {
						set slider_coord [expr {round(($by1-$sheight)+($by1-$by0-$sheight)*double($varvalue-$from)/double($from-$to))}]
					}
				} else {
					return
				}
			}
			
			# Move the slider to slider_coord (x-axis for horizontal scale, y-axis for vertical scale) 
			if { $orient eq "h" } {
				# Horizontal
				#if { ($slider_coord-$swidth/2) <= $bx0 } 
				if { ($slider_coord-$offset) <= $bx0 } {
					$can coords $front $bx0 $by0 [expr {$bx0+$swidth/2.0}] $by1
					$can coords $slider $bx0 $sy0 [expr {$bx0+$swidth}] $sy1
					if { $varvalue eq "" } { set $varname $from }
				#elseif { $slider_coord >= ($bx1-$swidth/2) }
				} elseif { $slider_coord >= ($bx1-$swidth+$offset) } {
					$can coords $front $bx0 $by0 [expr {$bx1-$swidth/2.0}] $by1
					$can coords $slider [expr {$bx1-$swidth}] $sy0 $bx1 $sy1
					if { $varvalue eq "" } { set $varname $to }
				} else {
#					$can coords $front $bx0 $by0 $slider_coord $by1
#					#$can move $slider [expr {$slider_coord-($swidth/2)-$sx0}] 0
#					$can move $slider [expr {$slider_coord-$sx0-$offset}] 0
#					if { $varvalue eq "" } {
#						#set newcoord [expr {$from+($to-$from)*(($slider_coord-$swidth/2-$bx0)/($bx1-$swidth-$bx0))}]
#						set newcoord [expr {round($from+($to-$from)*(double($slider_coord-$offset-$bx0)/double($bx1-$swidth-$bx0)))}]
#						set $varname [number_in_range $newcoord {} $from $to $resolution $n_decimals]
#					}
					if { $varvalue eq "" } {
						# Slider movement. Check we actually need to move if resolution is defined
						set varvalue [ifexists $varname $from]
						if { $varvalue eq "" } {
							set varvalue $from
						}
						set newvalue [expr {$from+($to-$from)*(double($slider_coord-$offset-$bx0)/double($bx1-$swidth-$bx0))}]
						set newvalue [number_in_range $newvalue {} $from $to $resolution $n_decimals]

						if { abs($newvalue - $varvalue) > 1e-10 } {
							$can coords $front $bx0 $by0 $slider_coord $by1
							$can move $slider [expr {$slider_coord-$sx0-$offset}] 0
							if { $varname ne "" } {
								set $varname $newvalue
							}
						}
					} else {
						# Direct move to
						$can coords $front $bx0 $by0 $slider_coord $by1
						$can move $slider [expr {$slider_coord-$sx0-$offset}] 0
						#
						# set newvalue [expr {round($from+($to-$from)*(double($slider_coord-$offset-$bx0)/double($bx1-$swidth-$bx0)))}]
						# set $varname [number_in_range $newvalue {} $from $to $resolution $n_decimals]
					}
					}
					} else {
				# Vertical
				#if { ($slider_coord-$sheight/2) <= $by0 }
				if { ($slider_coord-$offset) <= $by0 } {
					$can coords $front $bx0 [expr {$by0+$sheight/2.0}] $bx1 $by1
					$can coords $slider $sx0 $by0 $sx1 [expr {$by0+$sheight}]
					if { $varvalue eq "" } { 
						set $varname $to
					}
				# elseif { ($slider_coord+$sheight/2) >= $by1 }
				} elseif { ($slider_coord+$sheight-$offset) >= $by1 } {
					$can coords $front $bx0 [expr {$by1-$sheight/2.0}] $bx1 $by1
					$can coords $slider $sx0 [expr {$by1-$sheight}] $sx1 $by1
					if { $varvalue eq "" } { 
						set $varname $from
					}
				} else {
#					$can coords $front $bx0 [expr {$slider_coord-$offset+$sheight/2.0}] $bx1 $by1
#					#$can move $slider 0 [expr {$slider_coord-$sheight/2-$sy0}]
#					$can move $slider 0 [expr {$slider_coord-$offset-$sy0}]
#					if { $varvalue eq "" } {
#						#set newcoord [expr {$from+($to-$from)*($by1-$slider_coord-$sheight/2)/($by1-$sheight-$by0)}]
#						set newcoord [expr {round($from+($to-$from)*double($by1-$sheight-$slider_coord+$offset)/double($by1-$sheight-$by0))}]
#						set $varname [number_in_range $newcoord {} $from $to $resolution $n_decimals]
#					}
					if { $varvalue eq "" } {
						# Slider movement. Check we actually need to move if resolution is defined
						set varvalue [ifexists $varname $from]
						if { $varvalue eq "" } {
							set varvalue $from
						}
						set newvalue [expr {$from+($to-$from)*double($by1-$sheight-$slider_coord+$offset)/double($by1-$sheight-$by0)}]
						set newvalue [number_in_range $newvalue {} $from $to $resolution $n_decimals]
						if { abs($newvalue - $varvalue) > 1e-10 } {
							$can coords $front $bx0 [expr {$slider_coord-$offset+$sheight/2.0}] $bx1 $by1
							$can move $slider 0 [expr {$slider_coord-$offset-$sy0}]
							if { $varname ne "" } {
								set $varname $newvalue
							}
						}
					} else {
							# Direct move to
							$can coords $front $bx0 [expr {$slider_coord-$offset+$sheight/2.0}] $bx1 $by1
							$can move $slider 0 [expr {$slider_coord-$offset-$sy0}]
						}
					}
			}
					}
		
		proc dscale_start_motion { page dscale_tag orient coord } {
			variable sliders

			set slider [dui item get $page "${dscale_tag}-crc"]
			if { $slider eq "" } return

			set can [dui canvas]
			lassign [$can bbox $slider] sx0 sy0 sx1 sy1
			# Return if the page is not currently visible
			if {$sx0 eq "" } return

			if { $orient eq "v" } {
				set coord [dui::platform::translate_coordinates_finger_down_y $coord]
				#set sliders(${page},${dscale_tag}) [expr {int($coord-($sy0+($sy1-$sy0)/2))}]
				set sliders(${page},${dscale_tag}) [expr {int($coord-$sy0)}]
			} else {
				set coord [dui::platform::translate_coordinates_finger_down_x $coord]
				#set sliders(${page},${dscale_tag}) [expr {int($coord-($sx0+($sx1-$sx0)/2))}]
				set sliders(${page},${dscale_tag}) [expr {int($coord-$sx0)}]
			}
		}

		proc dscale_end_motion { page dscale_tag orient coord } {
			variable sliders
			set sliders(${page},${dscale_tag}) {}
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
			
			dui::page::update_onscreen_variables
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
			
			dui::page::update_onscreen_variables
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
		
		# Helper private function for dbutton_press
		proc _process_pressfill { tag fill pressfill } {
			set can [dui canvas]
			
			$can itemconfigure $tag -fill [lindex $pressfill 0]
			
			# Parse the -pressfill list, which contains {color time color time ... time}
			# If some time is missing, adds 40 ms to last time. Always finish with the 
			# original button fill color.
			set ms 0
			set max_ms 0
			set col {}
			set n [llength $pressfill]
			set j 1
			while { $j < $n } {
				set ms 0
				set col {}
				if { [string is integer [lindex $pressfill $j]] } {
					set ms [lindex $pressfill $j]
					set max_ms [::max $ms $max_ms]
					if { $j < [expr {$n-1}] } {
						set col [lindex $pressfill [incr j 1]]
					}
				} else {
					set col [lindex $pressfill $j]
				}

				if { $col ne {} } {
					if { $ms == 0 } {
						set ms [incr max_ns 40]
					}
					after $ms $can itemconfigure $tag -fill $col
				}
				
				incr j 1
			}
			
			if { $max_ms == 0 } {
				set max_ms 200
			} elseif { $col ne {} && $ms == $max_ms } {
				incr max_ns 40
			}
			after $max_ms $can itemconfigure $tag -fill $fill
		}
		
		proc dbutton_press { main_tag press_command args } {
			variable longpress_timer

			# Handles a bug in android which doesn't seem to cancel timers properly 
			after cancel $longpress_timer
			set ::dui::item::longpress_timer {}
			
			set can [dui canvas]
			set pressfill [dui::args::get_option -pressfill]
			if { $pressfill ne {} } {
				set fill [dui::args::get_option -fill]
				if { $fill eq {} } {
					set fill [$can itemcget $main_tag-btn -fill]
				}
				
				_process_pressfill $main_tag-btn $fill $pressfill
			}

			set i 0
			set suffix "" 
			set label_fill [dui::args::get_option -label_fill]
			set label_pressfill [dui::args::get_option -label_pressfill]
			while { $label_pressfill ne "" } {
				if { $label_fill eq {} } {
					set label_fill [$can itemcget $main_tag-lbl$suffix -fill]
				}
				
				_process_pressfill $main_tag-lbl$suffix $label_fill $label_pressfill
				
				set suffix [incr i]
				set "label_fill" [dui::args::get_option "-label${suffix}_fill" "" 1]
				set "label_pressfill" [dui::args::get_option "-label${suffix}_pressfill" "" 1]
			}
			
			set i 0
			set suffix "" 
			set symbol_fill [dui::args::get_option -symbol_fill]
			set symbol_pressfill [dui::args::get_option -symbol_pressfill]
			while { $symbol_pressfill ne "" } {
				if { $symbol_fill eq {} } {
					set symbol_fill [$can itemcget $main_tag-sym$suffix -fill]
				}

				_process_pressfill $main_tag-sym$suffix $symbol_fill $symbol_pressfill
				
				set suffix [incr i]
				set "symbol_fill" [dui::args::get_option "-symbol${suffix}_fill" "" 1]
				set "symbol_pressfill" [dui::args::get_option "-symbol${suffix}_pressfill" "" 1]
			}
							
			if { $press_command ne {} } {
				uplevel #0 $press_command
			}
		}
		
		proc longpress_press { main_tag longpress_command {longpress_threshold 0}} {
			variable longpress_timer
			variable longpress_default_threshold
			
			after cancel $longpress_timer
			set ::dui::item::longpress_timer {}
			
			if { $longpress_threshold <= 0 } {
				set longpress_threshold $longpress_default_threshold
			}
			
			set ::dui::item::longpress_timer [after $longpress_threshold [subst {
				set ::dui::item::longpress_timer {}
				uplevel #0 $longpress_command
			}]]
		}

		proc longpress_unpress { main_tag press_command args } {
			variable longpress_timer
			if { $longpress_timer ne {} } {
				dbutton_press $main_tag $press_command $args
			} 
		}
		
		# Run when any of the buttons in a dselector is tapped. This relies on the target variable having a 
		# trace variable write that runs dselector_draw.
		proc dselector_click { i n varname value multiple } {
			set curvalue [subst \$$varname]
			if { $multiple } {
				if { $value in $curvalue } {
					set $varname [list_remove_element $curvalue $value]
				} else {
					lappend $varname $value
				}
			} else {
				if { [llength $curvalue] > 1 } {
					set curvalue [lindex $curvalue 0]
				}
				if { $curvalue ne $value } {
					set $varname $value
				}
			}
		}
		
		# Paints each of the buttons in a dselector control compound, to reflect the value of the underlying variable.
		# Needs 'args' at the end because this is called from a 'trace add variable'.
		proc dselector_draw { page main_tag varname values multiple orient fill selectedfill outline selectedoutline 
				label_fill label_selectedfill symbol_fill symbol_selectedfill args } {
			set can [dui canvas]
			set n [llength $values]
			set curval [subst \$$varname]
			
			if { ![string is true $multiple] && [llength $curval] > 1 } {
				set curval [lindex $curval 0]
			}

			for { set i 1 } { $i <= $n } { incr i } {
				if { [lindex $values [expr {$i-1}]] in $curval } {
					dui item config $page ${main_tag}_${i}-btn -fill $selectedfill
					# Line items are colored with -fill and arc items with -outline, so we catch
					catch {
						dui item config $page ${main_tag}_${i}-out -fill $selectedoutline
						dui item config $page ${main_tag}_${i}-out -outline $selectedoutline
					}
					if { $label_selectedfill ne {} } {
						dui item config $page ${main_tag}_${i}-lbl -fill $label_selectedfill
					}
					
					# Ensure the selected element outline bordering a (possibly) non-selected element is shown on top,
					# otherwise we have unwanted lines on the border.
					if { $orient eq "v" } {
						if { $i == 1 && $n > 1 } {
							if { [lindex $values 1] in $curval } {
								dui item config $page ${main_tag}_${i}-out-s -fill $outline
							} else {
								dui item config $page ${main_tag}_${i}-out-s -fill $selectedoutline
							}
							
							$can raise [dui item get $page ${main_tag}_$i-out-s] [dui item get $page ${main_tag}_[expr {$i+1}]-out-n]
						} elseif { $i == $n && $n > 1 } {
							if { [lindex $values $n-1] in $curval } {
								dui item config $page ${main_tag}_${i}-out-n -fill $outline
							} else {
								dui item config $page ${main_tag}_${i}-out-n -fill $selectedoutline
							}

							$can raise [dui item get $page ${main_tag}_$i-out-n] [dui item get $page ${main_tag}_[expr {$i-1}]-out-s]
						} elseif { $n > 1 } {
							if { [lindex $values $i-1] in $curval } {
								dui item config $page ${main_tag}_${i}-out-n -fill $outline
							} else {
								dui item config $page ${main_tag}_${i}-out-n -fill $selectedoutline
							}
							if { [lindex $values $i+1] in $curval } {
								dui item config $page ${main_tag}_${i}-out-s -fill $outline
							} else {
								dui item config $page ${main_tag}_${i}-out-s -fill $selectedoutline
							}
							
							$can raise [dui item get $page ${main_tag}_$i-out-s] [dui item get $page ${main_tag}_[expr {$i+1}]-out-n]
							$can raise [dui item get $page ${main_tag}_$i-out-n] [dui item get $page ${main_tag}_[expr {$i-1}]-out-s]
						}
					} else {
						if { $i == 1 && $n > 1 } {
							if { [lindex $values 1] in $curval } {
								dui item config $page ${main_tag}_${i}-out-e -fill $outline
							} else {
								dui item config $page ${main_tag}_${i}-out-e -fill $selectedoutline
							}
							
							$can raise [dui item get $page ${main_tag}_$i-out-e] [dui item get $page ${main_tag}_[expr {$i+1}]-out-w]
						} elseif { $i == $n && $n > 1 } {
							if { [lindex $values $n-1] in $curval } {
								dui item config $page ${main_tag}_${i}-out-w -fill $outline
							} else {
								dui item config $page ${main_tag}_${i}-out-w -fill $selectedoutline
							}
							
							$can raise [dui item get $page ${main_tag}_$i-out-w] [dui item get $page ${main_tag}_[expr {$i-1}]-out-e]
						} elseif { $n > 1 } {
							if { [lindex $values $i+1] in $curval } {
								dui item config $page ${main_tag}_${i}-out-e -fill $outline
							} else {
								dui item config $page ${main_tag}_${i}-out-e -fill $selectedoutline
							}
							if { [lindex $values $i-1] in $curval } {
								dui item config $page ${main_tag}_${i}-out-w -fill $outline
							} else {
								dui item config $page ${main_tag}_${i}-out-w -fill $selectedoutline
							}
							
							$can raise [dui item get $page ${main_tag}_$i-out-e] [dui item get $page ${main_tag}_[expr {$i+1}]-out-w]
							$can raise [dui item get $page ${main_tag}_$i-out-w] [dui item get $page ${main_tag}_[expr {$i-1}]-out-e]
						}
					}
					
				} else {
					dui item config $page ${main_tag}_${i}-btn -fill $fill
					# Line items are colored with -fill and arc items with -outline, so we catch
					catch {
						dui item config $page ${main_tag}_${i}-out -fill $outline
						dui item config $page ${main_tag}_${i}-out -outline $outline
					}
					if { $label_fill ne {} } {
						dui item config $page ${main_tag}_${i}-lbl -fill $label_fill
					}
				}
			}
		}
				
		# Run when dtoggle is tapped. This relies on the target variable having a trace variable write that runs 
		# dtoggle_draw.
		proc dtoggle_click { varname } {
			set $varname [expr {![string is true [subst \$$varname]]}]
		}
		
		# Paint each dtoggle control compound item, to refelect the value of its boolean variable.
		# Needs 'args' at the end because this is called from a 'trace add variable'.
		proc dtoggle_draw { page main_tag varname sliderwidth outline_width foreground selectedforeground 
				background selectedbackground outline selectedoutline args } {
			set can [dui::canvas]
			set curval [subst \$$varname]
			
			# Original coordinates passed to the proc don't work if the dtoggle has been moved
			lassign [$can coords [dui item get $page ${main_tag}-bck]] x0 y0 x1 y1
			set x0 [expr {$x0-$sliderwidth/2.0}] 
			set y0 [expr {$y0-$sliderwidth/2.0}]
			set x1 [expr {$x1+$sliderwidth/2.0}] 
			set y1 [expr {$y1+$sliderwidth/2.0}]
					
			if { [string is true $curval] } {
				dui item config $page ${main_tag}-bck -fill $selectedbackground
				dui item config $page ${main_tag}-crc -fill $selectedforeground
				if { $outline_width > 0 } {
					dui item config $page ${main_tag}-crc -outline $selectedoutline
				}
				$can coords [dui item get $page ${main_tag}-crc] [expr {$x1-$sliderwidth+$outline_width+2}] \
					[expr {$y0+$outline_width+2}] [expr {$x1-$outline_width-2}] [expr {$y0+$sliderwidth-$outline_width-2}]
				
			} else {
				dui item config $page ${main_tag}-bck -fill $background
				dui item config $page ${main_tag}-crc -fill $foreground
				if { $outline_width > 0 } {
					dui item config $page ${main_tag}-crc -outline $outline
				}
				$can coords [dui item get $page ${main_tag}-crc] [expr {$x0+$outline_width+2}] [expr {$y0+$outline_width+2}] \
					[expr {$x0+$sliderwidth-$outline_width-2}] [expr {$y0+$sliderwidth-$outline_width-2}]
			}
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
		# This may be needed in the future if we want client code to invoke methods on dscales easily.
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
			while { [llength $args] > 0 && [string is double [lindex $args 0]] } {
				if { $i % 2 == 0 } {
					set coord [dui::page::calc_x $pages [lindex $args 0]]
				} else {
					set coord [dui::page::calc_y $pages [lindex $args 0]]
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
		#	-compatibility_mode: set to 1 to be backwards-compatible with add_de1_text calls (don't apply aspects,
		#		font suboptions and don't rescale width)
		#	-_abs_coords: default 0. If 1, coords are not offset relative to the page top-left coordinate.
		#		Normally only used internally by DUI for when some add commands call other add commands.
		#
		#	All others passed through to the 'canvas create text' command
		proc dtext { pages x y args } {
			global text_cnt
			set can [dui canvas]
			
			set first_page [lindex $pages 0]
			set abs_coords [string is true [dui::args::get_option -_abs_coords 0 1]] 
			if { $abs_coords } {
				set x [dui::platform::rescale_x $x]
				set y [dui::platform::rescale_y $y]
			} else {
				set x [dui::page::calc_x $first_page $x]
				set y [dui::page::calc_y $first_page $y]
			}
			
			set tags [dui::args::process_tags_and_var $pages dtext ""]
			set main_tag [lindex $tags 0]
			set cmd [dui::args::get_option -command {} 1]
			
			set compatibility_mode [string is true [dui::args::get_option -compatibility_mode 0 1]]
			if { ! $compatibility_mode } {				
				set style [dui::args::get_option -style "" 1]
				dui::args::process_aspects dtext $style "" "pos"
				dui::args::process_font dtext $style
				set width [dui::args::get_option -width {} 1]
				if { $width ne "" } {
					if { $abs_coords } {
						set width [dui::platform::rescale_x $width]
					} else {
						set width [dui::page::calc_width $first_page $width]
					}
					dui::args::add_option_if_not_exists -width $width
				}
				
				# Pressfill defined only when inside dbuttons, remove or error is raised
				dui::args::remove_options pressfill
			}
			
			try {
				set id [$can create text $x $y -state hidden {*}$args]
			} on error err {
				set msg "can't add dtext '$main_tag' in page(s) '$pages' to canvas: $err"
				msg -ERROR [namespace current] dtext: $msg
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
			
			#msg -INFO [namespace current] dtext "'$main_tag' to page(s) '$pages' with args '$args'"
			return $id
		}
		
		# Adds text to pages, where the text is the result of evaluating some code. The text shown is updated automatically whenever
		#	the underlying code evaluates to a different text.
		# Named options:
		#  -textvariable Tcl code. Not the name of a variable, but code to be evaluated. So, to refer to global variable 'x' 
		#		you must use '{$::x}', not '::x'.
		# 		If -textvariable gives a plain name instead of code to be evaluted (no brackets, parenthesis, ::, etc.) 
		#		and the first page in 'pages' is a namespace, uses {$::dui::pages::<page>::data(<textvariable>)}. 
		#		Also in this case, if -tags is not specified, uses the textvariable name as tag.
		#  All others passed through to the 'dui add dtext' command
		proc variable { pages x y args } {
			global variable_labels
			
			set tags [dui::args::process_tags_and_var $pages "variable" -textvariable]
			set main_tag [lindex $tags 0]
			set varcode [dui::args::get_option -textvariable "" 1]
	
			set id [dui add dtext $pages $x $y {*}$args]
			dui::page::add_variable $pages $id $varcode
			return $id
		}
		
		# Adds symbols to pages. Symbols are just characters in the special font "Fontawesome".
		# Named options:
		#  -symbol: either the unicode value or the descriptive name of the symbol.
		#  All others passed through to the 'dui add dtext' command
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
			
			return [dui add dtext $pages $x $y -text $symbol {*}$args]
		}
		
		# Adds canvas shapes to pages. Shapes can be variations of rectangles, and ovals. These are normally drawn
		# as containers for other items, such as buttons or dialog pages. Provides a common API for drawing different
		# shapes, some of which are straightforward canvas items (rectangles or ovals) whereas others are built
		# from several canvas items (rounded-corner rectangles, filled or unfilled, with our without an outline).
		#
		proc shape { shape pages x y args } {
			set can [dui canvas]
			set ns [dui page get_namespace $pages]
			
			set tags [dui::args::process_tags_and_var $pages shape {} 1 args 1]
			set main_tag [lindex $tags 0]
			
			lassign [dui::args::process_sizes $pages $x $y -bwidth 300 -bheight 300 1] rx ry rx1 ry1
			
			set style [dui::args::get_option -style "" 1]
			set aspect_type [list [dui::args::get_option -aspect_type $shape 1] $shape shape]
			dui::args::process_aspects $aspect_type $style {} {bg_img bg_color bg_shape}
			
			# As soon as the rect has a non-zero width (or maybe an outline or fill?), its "clickable" area becomes only
			#	the border, so if a visible rectangular button is needed, we have to add an invisible clickable rect on 
			#	top of it.
			set ids {}
			
			if { $shape eq "round" } {
				set fill [dui::args::get_option -fill [dui aspect get $aspect_type fill -style $style]]
				set disabledfill [dui::args::get_option -disabledfill [dui aspect get $aspect_type disabledfill -style $style]]
				set radius [dui::args::get_option -radius [dui aspect get $aspect_type radius -style $style -default 40]]
				
				set ids [dui::item::rounded_rectangle $rx $ry $rx1 $ry1 $radius $fill $disabledfill $tags]
			} elseif { $shape eq "outline" } {
				set outline [dui::args::get_option -outline [dui aspect get $aspect_type outline -style $style]]
				set disabledoutline [dui::args::get_option -disabledoutline [dui aspect get $aspect_type disabledoutline -style $style]]
				set arc_offset [dui::args::get_option -arc_offset [dui aspect get $aspect_type arc_offset -style $style -default 50]]
				set width [dui::args::get_option -width [dui aspect get $aspect_type width -style $style -default 3]]
				
				set outline_tags [list ${main_tag}-out {*}[lrange $tags 1 end]]
				set ids [dui::item::rounded_rectangle_outline $rx $ry $rx1 $ry1 $arc_offset $outline $disabledoutline \
					$width $outline_tags]
			} elseif { $shape eq "round_outline" } {
				set fill [dui::args::get_option -fill [dui aspect get $aspect_type fill -style $style]]
				set disabledfill [dui::args::get_option -disabledfill [dui aspect get $aspect_type disabledfill -style $style]]
				set radius [dui::args::get_option -radius [dui aspect get $aspect_type radius -style $style -default 40]]
				set outline [dui::args::get_option -outline [dui aspect get $aspect_type outline -style $style]]
				set disabledoutline [dui::args::get_option -disabledoutline [dui aspect get $aspect_type disabledoutline -style $style]]
				set width [dui::args::get_option -width [dui aspect get $aspect_type width -style $style -default 3]]
				
				set ids [dui::item::rounded_rectangle $rx $ry $rx1 $ry1 $radius $fill $disabledfill $tags]
				set outline_tags [list ${main_tag}-out {*}[lrange $tags 1 end]]
				
				set ids [dui::item::rounded_rectangle_outline $rx $ry $rx1 $ry1 $radius $outline \
					$disabledoutline $width $outline_tags]
			} elseif { $shape eq "oval" } {
				set ids [$can create oval $rx $ry $rx1 $ry1 -tags $tags -state hidden {*}$args]
			} else {
				if { $shape ne "rect" && $shape ne "rectangle" } {
					msg -WARNING [namespace current] shape: "shape '$shape' not recognized, defaulting to 'rectangle'"
				}
				set ids [$can create rect $rx $ry $rx1 $ry1 -tags $tags -state hidden {*}$args]
			}
			
			if { $ids ne "" && $ns ne "" } {
				set ${ns}::widgets($main_tag) $ids
			}
			
			#msg -INFO [namespace current] shape: "'$main_tag' to page(s) '$pages' with args '$args'"
			return $ids
		}
		
		# Add dbutton items to the canvas. Returns the list of all added tags (one per page).
		#
		# Defaults to an "invisible" button, i.e. a rectangular "clickable" area. Specify the -style or -shape argument
		#	to generate a visible button instead.
		# Invisible buttons can show their clickable area while debugging, by setting namespace variable debug_buttons=1.
		#	In that case, the outline color is given by aspect 'button.debug_outline' (or black if undefined).
		# Generates up to 3 canvas items/tags per page. Default one is named upon the provided -tags and corresponds to 
		#	the invisible "clickable" area. If a visible button is generated, it its assigned tag "<tag>-btn".
		#	If a label is specified, it gets tag "<tag>-lbl". Returns the canvas ID of the invisible clickable rectangle.
		#
		# Named options:  
		#	If the first two arguments are integer numbers, they are interpreted as the absolute bottom-right coordinates
		#		of the button. If not provided, arguments -bwidth and -bheight are used.
		#	-tags a label that allows to access the created canvas items
		#	-bwidth to set the width of the button. If this is provided, x1 is ignored and width is added to x0 instead.
		#	-bheight to set the height of the button. If this is provided, y1 is ignored and height is added to y0 instead.
		#		Normally bwidth and bheight are used when defining a button style in the theme aspects, so that buttons
		#		using a given style always have the same size.
		#	-shape: empty string for an invisible rectangle, or any of 'rect', 'oval', 'rounded' (Barney/MimojaCafe style),
		#		'outline' (rounded rectangle outline without a fill, DSx style), or 'rounded_outline' (rounded rectangle
		#		outline with a fill color).
		#	-style to apply the default aspects of the provided style
		#	-command tcl code to be run when the button is clicked
		#	-longpress_cmd tcl code to be run when the button is long pressed
		#	-longpress_threshold number of milliseconds to distinguish between presses and long presses
		#	-label, -label1, -label2... label text, in case a label is to be shown inside the button
		#	-labelvariable, -label1variable... to use a variable as label text
		#	-label_pos, -label1_pos... a list with 2 elements between 0 and 1 that specify the x and y percentages where to position
		#		the label inside the button
		#	-label_* (-label_fill -label_outline etc.) are passed through to 'dui add dtext' or 'dui add variable'
		#	-symbol to add a Fontawesome symbol/icon to the button, on position -symbol_pos, and using option values
		#		given in -symbol_* that are passed through to 'dui add symbol'
		#	-radius for rounded rectangles, and -arc_offset for rounded outline rectangles
		#	-tap_pad A list with up to 4 elements, specifying an increase in tapping area in each of the 4 directions.
		#	All others passed through to the respective visible button creation command.
		#	-pressfill: Background color when pressing the button 
		#	-pressoutline: Outline color when pressing the button
		proc dbutton { pages x y args } { 			
			set debug_buttons [dui cget debug_buttons]
			set can [dui canvas]
			set ns [dui page get_namespace $pages]
			set first_page [lindex $pages 0]
			
			set cmd [dui::args::get_option -command {} 1]
			set longpress_cmd [dui::args::get_option -longpress_cmd {} 1]
			set longpress_threshold [dui::args::get_option -longpress_threshold 0 1]
			set style [dui::args::get_option -style "" 1]
			set aspect_type [dui::args::get_option -aspect_type dbutton]
			dui::args::process_aspects dbutton $style {} {use_biginc orient}
			
			set x [dui::page::calc_x $first_page $x 0]
			set y [dui::page::calc_y $first_page $y 0]
			set x1 0
			set y1 0
			set bwidth [dui::args::get_option -bwidth "" 1]
			if { $bwidth ne "" } {
				set bwidth [dui::page::calc_width $first_page $bwidth 0]
				set x1 [expr {$x+$bwidth}]
			}
			set bheight [dui::args::get_option -bheight "" 1]
			if { $bheight ne "" } {
				set bheight [dui::page::calc_height $first_page $bheight 0]
				set y1 [expr {$y+$bheight}]
			}		 
			
			if { [llength $args] > 0 && [string is double [lindex $args 0]] } {
				if { $x1 <= 0 } {
					set x1 [dui::page::calc_x $first_page [lindex $args 0] 0]
					set args [lrange $args 1 end]
				}
			}
			if { [llength $args] > 0 && [string is double [lindex $args 0]] } {
				if { $y1 <= 0 } {
					set y1 [dui::page::calc_y $first_page [lindex $args 0] 0]
					set args [lrange $args 1 end]
				}				
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
			
			set tags [dui::args::process_tags_and_var $pages dbutton {} 1 args 1]
			set main_tag [lindex $tags 0]
			set button_tags [list ${main_tag}-btn {*}[lrange $tags 1 end]]
			lassign [lreplicate 4 [dui::args::get_option -tap_pad 0 1]] tp0 tp1 tp2 tp3
			set tp0 [dui::platform::rescale_x $tp0]
			set tp1 [dui::platform::rescale_y $tp1]
			set tp2 [dui::platform::rescale_x $tp2]
			set tp3 [dui::platform::rescale_y $tp3]
									
			set rx [dui::platform::rescale_x $x]
			set rx1 [dui::platform::rescale_x $x1]
			set ry [dui::platform::rescale_y $y]
			set ry1 [dui::platform::rescale_y $y1]
						
			# Note this cannot be processed by 'dui item process_label' as this one processes the positioning of the
			#	label differently (inside), also we need to extract label options from the args before painting the 
			#	background button (as $args is passed to the painting proc) but not create the label until after that
			#	button has been painted.
			set i 0
			set suffix "" 
			set label [dui::args::get_option -label "" 1]
			set labelvar [dui::args::get_option -labelvariable "" 1]
			set press_args [list]
			while { [subst \$label$suffix] ne "" || [subst \$labelvar$suffix] ne "" } {
				set "label${suffix}_tags" [list "${main_tag}-lbl$suffix" {*}[lrange $tags 1 end]]	
				set "label${suffix}_args" [dui::args::extract_prefixed "-label${suffix}_"]
				
				foreach aspect [dui aspect list -type [list "${aspect_type}_label$suffix" dtext] -style $style] {
					dui::args::add_option_if_not_exists -$aspect [dui aspect get "${aspect_type}_label$suffix" $aspect \
						-style $style -default {} -default_type dtext] "label${suffix}_args"
				}
				
				lappend press_args "-label${suffix}_fill" [dui::args::get_option -fill "" 0 "label${suffix}_args"]
				lappend press_args "-label${suffix}_pressfill" [dui::args::get_option -pressfill "" 1 "label${suffix}_args"]
				
				set "label${suffix}_pos" [dui::args::get_option -pos {0.5 0.5} 1 "label${suffix}_args"]
				set lx [lindex [subst \$label${suffix}_pos] 0]
				set ly [lindex [subst \$label${suffix}_pos] 1]
				if { $lx >= 0.0 && $lx <= 1.0} {
					set "xlabel$suffix" [expr {$x+int($x1-$x)*$lx}]
				} else {
					set "xlabel$suffix" [expr {$x+$lx}]
				}
				if { $ly >= 0.0 && $ly <= 1.0 } {
					set "ylabel$suffix" [expr {$y+int($y1-$y)*$ly}]
				} else {
					set "ylabel$suffix" [expr {$y+$ly}]
				}
				
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
					dui::args::add_option_if_not_exists -$aspect \
						[dui aspect get "${aspect_type}_symbol$suffix" $aspect -style $style \
						-default {} -default_type symbol] "symbol${suffix}_args"
				}
				
				lappend press_args "-symbol${suffix}_fill" [dui::args::get_option -fill "" 0 "symbol${suffix}_args"]
				lappend press_args "-symbol${suffix}_pressfill" [dui::args::get_option -pressfill "" 1 "symbol${suffix}_args"]
				
				set "symbol${suffix}_pos" [dui::args::get_option -pos {0.5 0.5} 1 "symbol${suffix}_args"]
				set lx [lindex [subst \$symbol${suffix}_pos] 0]
				set ly [lindex [subst \$symbol${suffix}_pos] 1]
				if { $lx >= 0.0 && $lx <= 1.0 } {
					set "xsymbol$suffix" [expr {$x+int($x1-$x)*$lx}]
				} else {
					set "xsymbol$suffix" [expr {$x+$lx}]
				}
				if { $ly >= 0.0 && $ly <= 1.0 } {
					set "ysymbol$suffix" [expr {$y+int($y1-$y)*$ly}]
				} else {
					set "ysymbol$suffix" [expr {$y+$ly}]
				}
				
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
			
			#if { $style eq "" && ![dui::args::has_option -shape]} {
				if { $debug_buttons } {
					set outline [dui aspect get dbutton debug_outline -style $style -default "black"]
					$can create rect [expr {$rx-$tp0}] [expr {$ry-$tp1}] [expr {$rx1+$tp2}] [expr {$ry1+$tp3}] \
						-outline $outline -width 1 -tags [list ${main_tag}-dout {*}[lrange $tags 1 end]] -state hidden
				}
#				else {
#					set width 0
#				}
#	
#				if { $width > 0 } {
#					set ids [$can create rect [expr {$rx+$tp0}] [expr {$ry+$tp1}] [expr {$rx1+$tp2}] [expr {$ry1+$tp3}] \
#						-outline $outline -width $width -tags $button_tags -state hidden]
#				}
			#} else {}
			
			set ids {}
			if { ![dui::args::has_option -shape] } {
				set ids [$can create rect $rx $ry $rx1 $ry1 -fill {} -outline black -width 0 -tags $button_tags -state hidden]	
			} else {
				dui::args::remove_options -debug_outline
				set shape [dui::args::get_option -shape [dui aspect get dbutton shape -style $style -default rect] 1]
				
				if { $shape eq "round" } {
					set fill [dui::args::get_option -fill [dui aspect get dbutton fill -style $style]]
					lappend press_args -fill $fill
					set disabledfill [dui::args::get_option -disabledfill [dui aspect get dbutton disabledfill -style $style]]
					set radius [dui::args::get_option -radius [dui aspect get dbutton radius -style $style -default 40]]
					
					set ids [dui::item::rounded_rectangle $rx $ry $rx1 $ry1 $radius $fill $disabledfill $button_tags]
				} elseif { $shape eq "outline" } {
					set outline [dui::args::get_option -outline [dui aspect get dbutton outline -style $style]]
					lappend press_args -outline $outline
					set disabledoutline [dui::args::get_option -disabledoutline [dui aspect get dbutton disabledoutline -style $style]]
					set arc_offset [dui::args::get_option -arc_offset [dui aspect get dbutton arc_offset -style $style -default 50]]
					set width [dui::args::get_option -width [dui aspect get dbutton width -style $style -default 3]]
					set outline_tags [list ${main_tag}-out {*}[lrange $tags 1 end]]
					
					set ids [dui::item::rounded_rectangle_outline $rx $ry $rx1 $ry1 $arc_offset $outline $disabledoutline \
						$width $button_tags]
				} elseif { $shape eq "round_outline" } {
					set fill [dui::args::get_option -fill [dui aspect get dbutton fill -style $style]]
					lappend press_args -fill $fill
					set disabledfill [dui::args::get_option -disabledfill [dui aspect get dbutton disabledfill -style $style]]
					set radius [dui::args::get_option -radius [dui aspect get dbutton radius -style $style -default 40]]
					set outline [dui::args::get_option -outline [dui aspect get dbutton outline -style $style]]
					lappend press_args -outline $outline
					set disabledoutline [dui::args::get_option -disabledoutline [dui aspect get dbutton disabledoutline -style $style]]
					set width [dui::args::get_option -width [dui aspect get dbutton width -style $style -default 3]]
					
					set ids [dui::item::rounded_rectangle $rx $ry $rx1 $ry1 $radius $fill $disabledfill $button_tags]
					set outline_tags [list ${main_tag}-out {*}[lrange $tags 1 end]]
					set ids [dui::item::rounded_rectangle_outline $rx $ry $rx1 $ry1 $radius $outline \
						$disabledoutline $width $outline_tags]
				} elseif { $shape eq "oval" } {
					set ids [$can create oval $rx $ry $rx1 $ry1 -tags $button_tags -state hidden {*}$args]
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
				dui add image $pages [subst \$ximage$suffix] [subst \$yimage$suffix] [subst \$image$suffix] \
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
					-style $style -_abs_coords 1 {*}[subst \$symbol${suffix}_args]
				set suffix [incr i]
			}
			
			# Add each of the (possibly several) labels
			set i 0
			set suffix ""
			while { ([info exists label$suffix] && [subst \$label$suffix] ne "") || 
					([info exists labelvar$suffix] && [subst \$labelvar$suffix] ne "") } {
				if { [info exists label$suffix] && [subst \$label$suffix] ne "" } {
					dui add dtext $pages [subst \$xlabel$suffix] [subst \$ylabel$suffix] -text [subst \$label$suffix] \
						-tags [subst \$label${suffix}_tags] -aspect_type "dbutton_label$suffix" \
						-style $style -_abs_coords 1 {*}[subst \$label${suffix}_args]
				} elseif { [info exists labelvar$suffix] && [subst \$labelvar$suffix] ne "" } {
					dui add variable $pages [subst \$xlabel$suffix] [subst \$ylabel$suffix] \
						-textvariable [subst \$labelvar$suffix] -tags [subst \$label${suffix}_tags] \
						-aspect_type "dbutton_label$suffix" -style $style -_abs_coords 1 {*}[subst \$label${suffix}_args] 
				}
				set suffix [incr i]
			}
			
			# Clickable rect. Needs to have -width 0.
			set rx [expr {$rx-$tp0}] 
			set ry [expr {$ry-$tp1}] 
			set rx1 [expr {$rx1+$tp2}] 
			set ry1 [expr {$ry1+$tp3}]

			set id [$can create rect $rx $ry $rx1 $ry1 -fill {} -outline black -width 0 -tags $tags -state hidden]
			if { $longpress_cmd ne "" } {
				if { $ns ne "" } { 
					if { [string is wordchar $longpress_cmd] && [namespace which -command "${ns}::$longpress_cmd"] ne "" } {
						set longpress_cmd ${ns}::$longpress_cmd
					}				
					regsub -all {%NS} $longpress_cmd $ns longpress_cmd
				}
				regsub {%x0} $longpress_cmd $rx longpress_cmd
				regsub {%x1} $longpress_cmd $rx1 longpress_cmd
				regsub {%y0} $longpress_cmd $ry longpress_cmd
				regsub {%y1} $longpress_cmd $ry1 longpress_cmd
			}
			
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
			
			lappend press_args -pressfill [dui::args::get_option -pressfill \
				[dui aspect get dbutton pressfill -style $style -default {}] 1]			
			if { $cmd eq "" } {
				msg -DEBUG [namespace current] dbutton "'$main_tag' in page(s) '$pages' does not have a command"

				if { $longpress_cmd ne "" } {
					$can bind $id [dui::platform::button_press] [list ::dui::item::longpress_press $main_tag \
							$longpress_cmd $longpress_threshold]
					$can bind $id [dui::platform::button_unpress] \
							[list ::dui::item::longpress_unpress $main_tag $cmd {*}$press_args] 
				}
			} elseif { $longpress_cmd eq "" } {
				$can bind $id [dui::platform::button_press] [list ::dui::item::dbutton_press $main_tag \
					$cmd {*}$press_args]
			} else {
				$can bind $id [dui::platform::button_press] [list ::dui::item::longpress_press $main_tag \
						$longpress_cmd $longpress_threshold]
				$can bind $id [dui::platform::button_unpress] \
					[list ::dui::item::longpress_unpress $main_tag $cmd {*}$press_args] 
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
			set theme [dui::args::get_option -theme [dui page theme [lindex $pages 0] "default"] 0]
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
				
				set editor_cmd [list dui page open_dialog $editor_page $var -n_decimals $n_decimals -min $min -max $max \
					-default $default -smallincrement $smallincrement -bigincrement $bigincrement -theme $theme {*}$editor_args]
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

		# A set of dbuttons joined in a row or column that allows selecting one or more elements. 
		# -orient
		# -variable
		# -values
		# -lengths
		# -multiple
		# -command
		# -fill
		# -selectedfill
		# -outline
		# -selectedoutline
		# -labels
		# -label_fill
		# -label_selectedfill
		# -symbols
		# -symbols_selectedfill
		proc dselector { pages x y args } {
			set can [dui::canvas]
			set tags [dui::args::process_tags_and_var $pages dselector -variable 1]
			set main_tag [lindex $tags 0]
			set ns [dui page get_namespace $pages]
				
			set style [dui::args::get_option -style "" 0]
			set theme [dui::args::get_option -theme [dui page theme [lindex $pages 0] "default"] 0]
			set var [dui::args::get_option -variable "" 1]
			if { ![info exists $var] } {
				set $var {}
			}
			set multiple [string is true [dui::args::get_option -multiple 0 1]]
			dui::args::process_aspects dselector $style

			set values [dui::args::get_option -values {} 1]
			set labels [dui::args::get_option -labels {} 1]
			set symbols [dui::args::get_option -symbols {} 1]
			set images [dui::args::get_option -images {} 1]
			set n [::max [llength $values] [llength $labels] [llength $symbols] [llength $images]]
			if { $n == 0 } {
				msg -WARNING [namespace current] dselector: "any of 'values', 'labels', 'symbols' or 'images' must be specified"
				return
			}
			if { $values eq {} } {
				set values [lsequence 1 $n]
			}
			if { $labels eq {} && $symbols eq {} && $images eq {} } {
				set labels $values
			}
			
			set fill [dui::args::get_option -fill white 1]
			set selectedfill [dui::args::get_option -selectedfill grey 1]
			set outline [dui::args::get_option -outline $selectedfill 1]
			set selectedoutline [dui::args::get_option -selectedoutline $selectedfill 1]
			set width [dui::args::get_option -width 2 1]
			
			if { $labels eq {} } {
				set label_fill {}
				set label_selectedfill {}
			} else {
				set label_fill [dui::args::get_option -label_fill $selectedfill 1]
				set label_selectedfill [dui::args::get_option -label_selectedfill $fill 1]
			}
			if { $symbols eq {} } {
				set symbol_fill {}
				set symbol_selectedfill {}
			} else {
				set symbol_fill [dui::args::get_option -symbol_fill $selectedfill 1]
				set symbol_selectedfill [dui::args::get_option -symbol_selectedfill $fill 1]
			}

			# Don't pass the page here because the page top-left offset is already taken into the posterior call to dui::add::dbutton 
			lassign [dui::args::process_sizes {} $x $y -bwidth 600 -bheight 100 0] x y x1 y1
			
			set lengths [dui::args::get_option -lengths {} 1]
			if { $lengths eq {} } {
				set lengths [lreplicate $n 0.1]
			} elseif { [llength $lengths] != $n } {
				set lengths [lreplicate $n $lengths] 
			}

			set radius [lreplicate 4 [dui::args::get_option -radius 40 1]]
			set user_cmd [dui::args::get_option -command {} 1]
			if { $user_cmd ne {} } {
				if { $ns ne "" } { 
					if { [string is wordchar $user_cmd] && [namespace which -command "${ns}::$user_cmd"] ne "" } {
						set user_cmd ${ns}::$user_cmd
					}				
					regsub -all {%NS} $user_cmd $ns user_cmd
				}
				
				regsub {%V} $user_cmd $values user_cmd
				regsub {%m} $user_cmd $multiple user_cmd
			}
			
			set orient [string range [dui::args::get_option -orient h 1] 0 0]
			if { $orient eq "v" } {
				set splits [dui::page::split_space $y $y1 {*}$lengths]
			} else {
				set splits [dui::page::split_space $x $x1 {*}$lengths]
			}

			set ids {}
			for { set i 0 } { $i < $n } { incr i } {
				set i1 [expr {$i+1}]
				set iargs $args
				
				if { $orient eq "v" } {
					if { $i == 0 } {
						lappend iargs -shape round_outline -radius [list [lindex $radius 0] [lindex $radius 1] 0 0] \
							-outline $outline -fill $fill -width $width -label_fill $label_fill
					} elseif { $i == [expr {$n-1}] } {
						lappend iargs -shape round_outline -radius [list 0 0 [lindex $radius 2] [lindex $radius 3]] \
							-outline $outline -fill $fill -width $width -label_fill $label_fill
					} else {
						lappend iargs -shape round_outline -radius {0 0 0 0} -outline $outline -fill $fill -width $width \
							-label_fill $label_fill
					}
					set ix $x
					set iy [lindex $splits $i]
					set ix1 $x1
					set iy1 [lindex $splits $i1]
				} else {
					if { $i == 0 } {
						lappend iargs -shape round_outline -radius [list [lindex $radius 0] 0 0 [lindex $radius 3]] \
							-outline $outline -fill $fill -width $width -label_fill $label_fill
					} elseif { $i == [expr {$n-1}] } {
						lappend iargs -shape round_outline -radius [list 0 [lindex $radius 1] [lindex $radius 2] 0] \
							-outline $outline -fill $fill -width $width -label_fill $label_fill
					} else {
						lappend iargs -shape round_outline -radius {0 0 0 0} -outline $outline -fill $fill -width $width \
							-label_fill $label_fill
					}
					set ix [lindex $splits $i]
					set iy $y
					set ix1 [lindex $splits $i1]
					set iy1 $y1
				}
				
				if { $labels ne {} } {
					lappend iargs -label [lindex $labels $i] -label_fill $label_fill
				}
				if { $symbols ne {} } {
					lappend iargs -symbol [lindex $symbols $i] -symbol_fill $symbol_fill
				}
				
				set cmd [::list ::dui::item::dselector_click $i1 $n $var [lindex $values $i] $multiple]
				set id [dui::add::dbutton $pages $ix $iy $ix1 $iy1 -tags [list ${main_tag}_$i1 ${main_tag}*] -command $cmd {*}$iargs]
				lappend ids $id
				
				if { $user_cmd ne {} } {
					regsub {%x0} $user_cmd $ix user_cmd
					regsub {%x1} $user_cmd $ix1 user_cmd
					regsub {%y0} $user_cmd $iy user_cmd
					regsub {%y1} $user_cmd $iy1 user_cmd
					regsub {%v} $user_cmd [lindex $values $i] user_cmd
						
					$can bind $id [dui::platform::button_press] [list + {*}$user_cmd]
				}
			}

			set draw_cmd [::list ::dui::item::dselector_draw [lindex $pages 0] $main_tag $var $values $multiple $orient $fill \
				$selectedfill $outline $selectedoutline $label_fill $label_selectedfill $symbol_fill $symbol_selectedfill]
			# Initialize the control
			uplevel #0 $draw_cmd
			trace add variable $var write $draw_cmd
			
			return $ids
		}

		# Toggle-switch, a modern-looking checkbox alternative
		# -width
		# -height
		# -sliderwidth: width/height or the slider circle
		# -foreground fill color of the slider circle, when false
		# -selectedforeground inner color of the slider circle, when true
		# -disabledforeground inner color of the slider circle, when disabled
		# -background fill color of the background rounded line, when false
		# -selectedbackground fill color of the background rounded line, when true
		# -disabledbackground fill color of the background rounded line, when disabled
		# -outline_width
		# -outline fill color of the circle outline line, when false
		# -selectedoutline fill color of the circle outline line, when true
		# -disabledoutline fill color of the circle outline line, when disabled
		# -label and -label_* options
		proc dtoggle { pages x y args } {
			set can [dui::canvas]
			set tags [dui::args::process_tags_and_var $pages dtoggle -variable 1]
			set main_tag [lindex $tags 0]
			set ns [dui page get_namespace $pages]
				
			set style [dui::args::get_option -style "" 0]
			set theme [dui::args::get_option -theme [dui page theme [lindex $pages 0] "default"] 0]
			set var [dui::args::get_option -variable "" 1]
			if { ![info exists $var] } {
				set $var 0
			}
			dui::args::process_aspects dtoggle $style
			dui::args::process_label $pages $x $y dtoggle $style
			
			lassign [dui::args::process_sizes $pages $x $y -width 60 -height 35 1] x y x1 y1
			set sliderwidth [dui::args::get_option -sliderwidth {} 1]
			if { $sliderwidth eq {} } {
				set sliderwidth [expr {$y1-$y-2}]
			} else {
				set sliderwidth [dui::platform::rescale_x $sliderwidth]
			}
			
			set background [dui::args::get_option -background grey 1]
			set selectedbackground [dui::args::get_option -selectedbackground aquamarine 1]
			set disabledbackground [dui::args::get_option -disabledbackground "#ccc" 1]
			set foreground [dui::args::get_option -foreground white 1]
			set selectedforeground [dui::args::get_option -selectedforeground blue 1]
			set disabledforeground [dui::args::get_option -disabledforeground "#ccc" 1]
			set outline_width [dui::args::get_option -outline_width 1 1]
			if { $outline_width ne {} && $outline_width > 0 } {
				set outline_width [dui::platform::rescale_x $outline_width]
			}
			set outline [dui::args::get_option -outline $foreground	1]
			set selectedoutline [dui::args::get_option -selectedoutline black 1]
			set user_cmd [dui::args::get_option -command {} 1]
			
			set ids {}
			#$can create rect $x $y $x1 $y1 -width 1 -fill {} -outline pink -tags [list ${main_tag}-border {*}$tags] -state hidden
			
			# Background rounded-extremes line
			set id [$can create line [expr {$x+$sliderwidth/2.0}] [expr {$y+$sliderwidth/2.0}] \
				[expr {$x1-$sliderwidth/2.0}] [expr {$y+$sliderwidth/2.0}] -width [expr {$y1-$y}] \
				-fill $background -disabledfill $disabledbackground -capstyle round \
				-tags [list ${main_tag}-bck {*}$tags] -state hidden]
			lappend ids $id
			if { $ns ne "" } {
				set "${ns}::widgets(${main_tag}-bck)" $id
			}

			# Inner slider circle
			set id [$can create oval [expr {$x+$outline_width+2}] [expr {$y+$outline_width+2}] \
				[expr {$x+$sliderwidth-$outline_width-2}] [expr {$y+$sliderwidth-$outline_width-2}] -fill $foreground \
				-disabledfill $disabledforeground -width $outline_width -outline $outline \
				-tags [list {*}$tags ${main_tag}-crc] -state hidden]
			lappend ids $id	
			if { $ns ne "" } {
				set "${ns}::widgets(${main_tag}-crc)" $id
			}

			# Transparent tappable rectangle
			set id [$can create rect [expr {$x-6}] [expr {$y-12}] [expr {$x1+6}] [expr {$y1+12}] -width 0 -fill {} \
				-tags $tags -state hidden]
			lappend ids $id
			if { $ns ne "" } {
				set "${ns}::widgets($main_tag)" $ids
			}
			
			set cmd [::list ::dui::item::dtoggle_click $var]
			$can bind $id [dui::platform::button_press] $cmd

			set draw_cmd [::list ::dui::item::dtoggle_draw [lindex $pages 0] $main_tag $var $sliderwidth \
				$outline_width $foreground $selectedforeground $background $selectedbackground \
				$outline $selectedoutline]
			# Initialize the control
			uplevel #0 $draw_cmd
			trace add variable $var write $draw_cmd
			
			if { $user_cmd ne {} } {
				if { $ns ne "" } { 
					if { [string is wordchar $user_cmd] && [namespace which -command "${ns}::$user_cmd"] ne "" } {
						set user_cmd ${ns}::$user_cmd
					}				
					regsub -all {%NS} $user_cmd $ns user_cmd
				}
				
				regsub {%x0} $user_cmd $x user_cmd
				regsub {%x1} $user_cmd $x1 user_cmd
				regsub {%y0} $user_cmd $y user_cmd
				regsub {%y1} $user_cmd $y1 user_cmd
					
				$can bind $id [dui::platform::button_press] [list + {*}$user_cmd]
			}
			
			return $id
		}
		
		# Extra named options:
		#	-type The type of image, defaults to 'photo'
		#	-canvas_* Options to be passed through to the canvas create command
		proc image { pages x y filename args } {
			set can [dui canvas]

			if { $filename ne "" } {
				set filename [dui::image::find $filename yes]
				if { $filename eq "" } {
					return
				}
			}
			
			set x [dui::page::calc_x $pages $x]
			set y [dui::page::calc_y $pages $y]
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
			
			set preload_images [dui cget preload_images]
			set img_name ""
			if { $filename ne "" && [dui::image::is_loaded "$filename"] } {
				set img_name [dui::image::get "$filename"]
			} 
			if { $img_name eq "" } {
				set img_name "[lindex $pages 0]-$main_tag"
				set img_name [dui::image::load $type $img_name $filename $preload_images {*}$args]
				if { $img_name eq "" } return
			}
			
			try {
				[dui canvas] create image $x $y -image $img_name -tags $tags -state hidden {*}$canvas_args
			} on error err {
				msg -ERROR [namespace current] "image: can't add image '$filename' with tag '$main_tag' to canvas page(s) '$pages' : $err"
				return
			}
			
			set ns [dui page get_namespace $pages]
			if { $ns ne "" } {
				set ${ns}::widgets($main_tag) $img_name
			}			
			#msg -INFO [namespace current] image "add '$main_tag' to page(s) '$pages' with args '$args' (img_name=$img_name)"
			return $img_name
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
		#	-label_* passed through to 'add dtext'
		#	-tclcode code to be evaluated after the widget is created, to allow configuring the widget. It is evaluated
		#		in a global context, and performs the following substitutions:
		#			%W the widget pathname
		#			%NS the page namespace, if it has one, o/w an empty string
		#	-process_aspects <boolean>, to query and apply all the aspects of the type. Usually set to "no" when
		#		this is invoked from another 'dui add' command that has already processed the aspects.
		proc widget { type pages x y args } {
			set can [dui canvas]
			set rx [dui::page::calc_x $pages $x]
			set ry [dui::page::calc_y $pages $y]
			
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
				dui::args::add_option_if_not_exists -width [dui::page::calc_width $pages \
					[dui::args::get_option -width 0 1 canvas_args]] canvas_args 
			}
			if { [dui::args::has_option -height canvas_args] } {
				dui::args::add_option_if_not_exists -height [dui::page::calc_height $pages \
					[dui::args::get_option -height 0 1 canvas_args]] canvas_args 
			}				
			if { $type eq "scrollbar" } {
				# From the original add_de1_widget, but WHY this? Also, scrollbars are no longer used, scales
				#	are used instead...
				dui::args::add_option_if_not_exists -height 245 canvas_args
			}
			
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
			
			# Allow using widget pathnames to retrieve canvas items (also needed for backwards compatibility with 
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
	
			set style [dui::args::get_option -style "" 0]
			set theme [dui::args::get_option -theme [dui page theme [lindex $pages 0] "default"] 0]
			dui::args::process_aspects entry $style
			
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
			
			if { [dui::args::has_option -vcmd] } {
				dui::args::add_option_if_not_exists -validate key
			} else {
				set vcmd ""
				if { $data_type eq "numeric" } {
					set vcmd [list ::dui::validate_numeric %P $n_decimals $min $max]
					set validate [dui::args::get_option -validate key 1]
				} elseif { $data_type eq "date" } {
					set dateformat [dui cget date_input_format]
					regsub -all "%" $dateformat "%%" dateformat
					set fg [dui::args::get_option -foreground [dui aspect get entry foreground -style $style -default black] 0]
					set error_fg [dui aspect get dtext fill -style error -default red] 
					set vcmd [list ::dui::validate_date %P %W $dateformat $fg $error_fg]
					set validate [dui::args::get_option -validate focus 1]
				} else {
					set validate key
				}
				
				if { $vcmd ne "" } {
					dui::args::add_option_if_not_exists -vcmd $vcmd
					dui::args::add_option_if_not_exists -validate $validate
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
					set editor_cmd [list dui::page::load_if_widget_enabled $widget $editor_page $textvariable \
						-n_decimals $n_decimals -min $min -max $max -default $default -smallincrement $smallincrement \
						-bigincrement $bigincrement -page_title $editor_page_title -theme $theme]
					set editor_cmd "if \{ \[\[dui canvas\] itemcget $widget -state\] eq \"normal\" \} \{ $editor_cmd \}" 

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
			set theme [dui::args::get_option -theme [dui page theme [lindex $pages 0] "default"] 0]
			
			set values [dui::args::get_option -values {} 1]
			#set values_ids [dui::args::get_option -values_ids {} 1]
			#set item_type [dui::args::get_option -item_type {} 1]
			set tap_pad [dui::args::get_option -tap_pad {25 22 22 25} 1]
			
			set textvariable [dui::args::get_option -textvariable {} 0]
			set callback_cmd [dui::args::get_option -callback_cmd {} 1]
			if { $callback_cmd ne "" } {
				if { $ns ne "" && [string is wordchar $callback_cmd] && [namespace which -command "${ns}::$callback_cmd"] ne "" } {
					set callback_cmd "${ns}::$callback_cmd"
				} else {
					regsub -all {%NS} $callback_cmd $ns callback_cmd
				}
			}

			set cmd [dui::args::get_option -command {} 1]
			set expand_cmd 0
			if { $cmd eq "" } {
				set cmd [list dui::page::load_if_widget_enabled %W dui_item_selector]
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
					#lappend cmd -callback_cmd $callback_cmd
					lappend cmd -return_callback $callback_cmd
				}
				foreach fn {values_ids item_type page_title listbox_width} { 
					if { [dui::args::has_option -$fn] } {
						lappend cmd -$fn [dui::args::get_option -$fn {} 1]
					}
				}
				lappend cmd -theme $theme
				#set cmd [list say "select" $::settings(sound_button_in) \; {*}$cmd ]
			}
#			dui::args::process_font dcombobox $style
			
			set w [dui add entry $pages $x $y -aspect_type dcombobox {*}$args]
			regsub -all {%W} $cmd $w cmd
			bind $w <Double-Button-1> $cmd
			
			# Dropdown selection arrow
			set arrow_tags [list ${main_tag}-dda {*}[lrange $tags 1 end]]
			dui add dbutton $pages [expr {$x+650}] $y -tags $arrow_tags -aspect_type dbutton_dda -command $cmd \
				-symbol sort-down -tap_pad $tap_pad
			bind $w <Configure> [list dui::item::relocate_dropdown_arrow [lindex $pages 0] $main_tag]
			
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
	
			return $main_tag
		}
		
		proc listbox { pages x y args } {
			set tags [dui::args::process_tags_and_var $pages listbox -listvariable 1]
			set main_tag [lindex $tags 0]
			set ns [dui page get_namespace $pages]
			
			#set style [dui::args::get_option -style "" 0]
			dui::args::process_aspects listbox
			
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
			if { $ysb != 0 && ![dui::args::has_option -yscrollcommand] } {
				set first_page [lindex $pages 0]
				dui::args::add_option_if_not_exists -yscrollcommand \
					[list ::dui::item::scale_scroll $first_page $main_tag ::dui::item::sliders($first_page,$main_tag)]
			}
			
			set cmd [dui::args::get_option -select_cmd {} 1]
			
			set widget [dui add widget listbox $pages $x $y -theme none {*}$args]

			if { $cmd ne "" } {
				if { $ns ne "" && [string is wordchar $cmd] && [namespace which -command ${ns}::$cmd] ne "" } {
					set cmd "${ns}::$cmd"
				} else {
					regsub -all {%W} $cmd $widget cmd
					regsub -all {%NS} $cmd $ns cmd
				}
				bind $widget <<ListboxSelect>> $cmd
			}
			
			if { [string is true $ysb] || [llength $sb_args] > 0 } {
				dui add yscrollbar $pages $x $y -tags $tags -aspect_type listbox_yscrollbar {*}$sb_args 
			}
			
			return $widget
		}
		
		# Adds a vertical Tk scale widget that works as a scrollbar for another widget (the one identified by the first
		#	tag in -tags) and all the code necessary to link the scrollbar to the scrolled widget.
		# This is not normally invoked directly by client code, but from other 'add' commands like 'dui add listbox'.
		# Tags should be those of the original scrolled widget.
		proc yscrollbar { pages x y args } {
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
			
			bind [dui item get_widget $pages $main_tag] <Configure> [list after idle ::dui::item::set_yscrollbar_dim \
				[lindex $pages 0] $main_tag ${main_tag}-ysb]
			
			return $w
		}		
		
		proc scale { pages x y args } {
			set can [dui canvas]			
			set tags [dui::args::process_tags_and_var $pages scale -variable 1]
			set main_tag [lindex $tags 0]

			set style [dui::args::get_option -style "" 0]
			dui::args::process_aspects scale $style
			
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
					
				set editor_cmd [list dui page open_dialog $editor_page $var -n_decimals $n_decimals -min $from \
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
			set theme [dui::args::get_option -theme [dui page theme [lindex $pages 0] "default"] 0]
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
			set activeforeground [dui::args::get_option -activeforeground blue]
			set disabledforeground [dui::args::get_option -disabledforeground grey]
			set background [dui::args::get_option -background grey]
			set disabledbackground [dui::args::get_option -disabledforeground grey]
			set plus_minus [string is true [dui::args::get_option -plus_minus 1]]
			set pm_length 0
			
			set x [dui::page::calc_x $pages $x]
			set y [dui::page::calc_y $pages $y]
			set moveto_cmd [list dui::item::dscale_moveto [lindex $pages 0] $main_tag $var $from $to $resolution $n_decimals]
			if { $orient eq "v" } {
				# VERTICAL SCALE
				if { $plus_minus } {
					set pm_length [dui platform rescale_y 40]
				}
				set length [dui::page::calc_height $pages $length]
				set sliderlength [dui::page::calc_height $pages $sliderlength]
				set pm_length [dui::page::calc_height $pages $pm_length]
				set width [dui::page::calc_width $pages $width]
				set x1 $x
				set y [expr {$y+$pm_length}]
				set y1 [expr {$y+$length-$pm_length*2}]
				set yf [expr {$y1-$sliderlength/2}]
				lappend moveto_cmd %y %Y

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
					-disabledfill $disabledforeground -activefill $activeforeground -width 0 \
					-tags [list {*}$tags ${main_tag}-crc] -state hidden]
				set ::dui::item::sliders([lindex $pages 0],${main_tag}) {}
				$can bind ${main_tag}-crc [dui platform button_press] [list ::dui::item::dscale_start_motion [lindex $pages 0] $main_tag v %y]
				$can bind ${main_tag}-crc [dui platform button_unpress] [list ::dui::item::dscale_end_motion [lindex $pages 0] $main_tag v %y]                
				#$can bind ${main_tag}-crc <B1-Motion> $moveto_cmd
				$can bind ${main_tag}-crc [dui platform button_motion] $moveto_cmd
				lappend ids $id			
				if { $ns ne "" } {
					set "${ns}::widgets(${main_tag}-crc)" $id
					set "${ns}::widgets($main_tag)" $ids
				}
			} else {
				# HORIZONTAL SCALE
				if { $plus_minus } {
					set pm_length [dui::page::calc_width $pages 60]
				}				
				set length [dui::page::calc_width $pages $length]
				set sliderlength [dui::page::calc_width $pages $sliderlength]
				set width [dui::page::calc_height $pages $width]
				set x [expr {$x+$pm_length}]
				set x1 [expr {$x+$length-$pm_length*2}]
				set x1f [expr {$x+$sliderlength/2}]
				set y1 $y
				set y1f $y
				lappend moveto_cmd %x %X
				
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
					-disabledfill $disabledforeground -activefill $activeforeground -width 0 \
					-tags [list {*}$tags ${main_tag}-crc] -state hidden]
				set ::dui::item::sliders([lindex $pages 0],${main_tag}) {}                
				$can bind ${main_tag}-crc [dui platform button_press] [list ::dui::item::dscale_start_motion [lindex $pages 0] $main_tag h %x]
				$can bind ${main_tag}-crc [dui platform button_unpress] [list ::dui::item::dscale_end_motion [lindex $pages 0] $main_tag h %x]                
				#$can bind ${main_tag}-crc <B1-Motion> $moveto_cmd
				$can bind ${main_tag}-crc [dui platform button_motion] $moveto_cmd
				lappend ids $id			
				if { $ns ne "" } {
					set "${ns}::widgets(${main_tag}-crc)" $id
					set "${ns}::widgets($main_tag)" $ids
				}
			}
			
			set update_cmd [lreplace $moveto_cmd end-1 end {} {}]
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
				set editor_cmd [list dui page open_dialog $editor_page $var -n_decimals $n_decimals -min $from \
					-max $to -default $default -smallincrement $smallinc -bigincrement $biginc \
					-page_title $editor_page_title -theme $theme]
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
		#	-width, total width in pixels
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
					set half_symbol [dui symbol get star-half]
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
			dui::args::process_aspects graph
			
			set width [dui::args::get_option -width "" 1]
			if { $width ne "" } {
				dui::args::add_option_if_not_exists -width [dui::page::calc_width $pages $width]
			}
			set height [dui::args::get_option -height "" 1]
			if { $height ne "" } {
				dui::args::add_option_if_not_exists -height [dui::page::calc_height $pages $height]
			}
#			dui::args::process_font listbox $style
			
			return [dui add widget graph $pages $x $y {*}$args]
			
		}
		
		proc text { pages x y args } {
			set tags [dui::args::process_tags_and_var $pages tk_text {} 1]
			set main_tag [lindex $tags 0]
			
			#set style [dui::args::get_option -style "" 0]
			dui::args::process_aspects text
			
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
#			set ysb [dui::args::process_yscrollbar $pages $x $y listbox $style]
			if { $ysb != 0 && ![dui::args::has_option -yscrollcommand] } {
				set first_page [lindex $pages 0]
				dui::args::add_option_if_not_exists -yscrollcommand \
					[list ::dui::item::scale_scroll $first_page $main_tag ::dui::item::sliders($first_page,$main_tag)]
			}
						
			set widget [dui add widget tk::text $pages $x $y -theme none {*}$args]

			if { [string is true $ysb] || [llength $sb_args] > 0 } {
				dui add yscrollbar $pages $x $y -tags $tags -aspect_type tk_text_yscrollbar {*}$sb_args 
			}
			
			return $widget
		}
		
	}
	
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
	
	proc validate_date { value widget {format {}} {fg black} {fg_error red} } {	
		if { $format eq "" } {
			set format [dui cget date_input_format]
			if { $format eq "" } {
				set format "%d/%m/%Y"
			}
		}

		set result 1
		if { $value ne "" } {
			try { 
				set check [clock scan $value -format $format]
			} on error err {
				set result 0
			}
		}
		if { $result } {
			$widget configure -foreground $fg
		} else {
			$widget configure -foreground $fg_error
		}
		return $result
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

# Forces a list or set of arguments to be a list of length $len, removing elements if necessary, or replicating them
# as many times as necessary.
proc lreplicate { len args } {
	set largs [concat {*}$args]
	set n [llength $largs]
	
	if { $len == $n } {
		return $largs
	} elseif { $len < $n } {
		return [lrange $largs 0 [expr {$len-1}]]
	} else {
		set largs [lrepeat [expr {int($len/$n)+1}] {*}$largs]
		return [lrange $largs 0 [expr {$len-1}]]
	}
}

# Returns a list with a sequence of numbers. 'step' is assumed to be 1 or -1 if not defined, depending on whether
# it's an increasing or decreasing seqence. Properly formats the sequence numbers, using the maximum number of
# decimals used in any of the input arguments.
proc lsequence { from to {step {}} } {
	set seq {}
	if { $step eq {} } {
		if { $to >= $from } {
			set step 1
		} else {
			set step -1
		}
	}
	
	if { $step == 0 } {
		return {}
	} elseif { $to > $from && $step < 0 } {
		return {}
	} elseif { $to < $from && $step > 0 } {
		return {}
	}
	
	set n_dec_from [string length [lindex [split $from .] 1]]
	set n_dec_to [string length [lindex [split $to .] 1]]
	set n_dec_step [string length [lindex [split $step .] 1]]
	set n_decimals [::max $n_dec_from $n_dec_to $n_dec_step]
	
	for {set i 0} true {incr i} {
		set x [expr {$i*$step + $from}]
		if { $step > 0 && $x > $to} {
			break
		} elseif { $step < 0 && $x < $to } {
			break
		}
		lappend seq [format "%.${n_decimals}f" $x]
	}
	
	return $seq
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
		set newvalue [expr {round(double($newvalue)/double($resolution))*double($resolution)}]
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

# tcl::mathfunc::max fails on older Androwish (TheLeydenJar), so we create our version, taken from https://wiki.tcl-lang.org/page/max # 
proc max { args } {
	if { [llength $args] == 0 } {
		msg -WARNING max: "empty arguments"
		return {}
	}
	lindex [lsort -real $args] end
}

proc min { args } {
	if { [llength $args] == 0 } {
		msg -WARNING min: "empty arguments"
		return {}
	}	
	lindex [lsort -real $args] 0
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

		# Decrement value arrows		
		set hoffset 45; set bspace 140
		dui add dbutton $page [expr {$x-$hoffset-$bspace}] $y -tags small_decr -style dne_clicker \
			-symbol chevron-left -labelvariable {-[format [%NS::value_format] $%NS::data(smallincrement)]} \
			-command { %NS::incr_value -$%NS::data(smallincrement) }
		
		dui add dbutton $page [expr {$x-$hoffset-$bspace*2}] $y -tags big_decr -style dne_clicker \
			-symbol chevrons-left -labelvariable {-[format [%NS::value_format] $%NS::data(bigincrement)]} \
			-command { %NS::incr_value -$%NS::data(bigincrement) } 

		dui add dbutton $page [expr {$x-$hoffset-$bspace*3}] $y -tags to_min -style dne_clicker \
			-symbol arrow-left-to-line -labelvariable {[format [%NS::value_format] $%NS::data(min)]} \
			-command { %NS::set_value $%NS::data(min) } 

		# Increment value arrows
		dui add dbutton $page [expr {$x+$hoffset+$bspace}] $y -tags small_incr -style dne_clicker \
			-symbol chevron-right -labelvariable {+[format [%NS::value_format] $%NS::data(smallincrement)]} \
			-command { %NS::incr_value $%NS::data(smallincrement) }
			
		dui add dbutton $page [expr {$x+$hoffset+$bspace*2}] $y -tags big_incr -style dne_clicker \
			-symbol chevrons-right -labelvariable {+[format [%NS::value_format] $%NS::data(bigincrement)]} \
			-command { %NS::incr_value $%NS::data(bigincrement) } 
	
		dui add dbutton $page [expr {$x+$hoffset+$bspace*3}] $y -tags to_max -style dne_clicker \
			-symbol arrow-right-to-line -labelvariable {[format [%NS::value_format] $%NS::data(max)]} \
			-command { %NS::set_value $%NS::data(max) } 
		
		# Erase button
		#		dui add symbol $page $x_left_center [expr {$y+140}] eraser -size medium -has_button 1 \
		#			-button_cmd { set ::dui::pages::dui_number_editor::data(value) "" }
		
#		# Previous values listbox
		dui add listbox $page 450 780 -tags previous_values -canvas_width 350 -canvas_height 550 -yscrollbar 1 \
			-label [translate "Previous values"] -label_style section_font_size -label_pos {450 700} -label_anchor nw -font_size +15
		bind $widgets(previous_values) <<ListboxSelect>> ::dui::pages::dui_number_editor::previous_values_select
		
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
					-label [translate $num] -command [list %NS::enter_character $num] 
				
				incr col
			}
			set col 0
			incr row
		}

		# Ok and Cancel buttons
		dui add dbutton $page 750 1460 -tags page_cancel -style insight_ok -label [translate Cancel] -tap_pad 20
		dui add dbutton $page 1330 1460 -tags page_done -style insight_ok -label [translate Ok] -tap_pad 20
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
		
#		if { [info exists opts(-theme)] } {
#			dui page retheme $page_to_show $opts(-theme)
#		}
		
		if { ![info exists $num_variable] } {
			set $num_variable ""
		}
		
		set fields {page_title previous_values default min max n_decimals smallincrement bigincrement}
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
	

	# convenience function for getting previous values for a dui_number_editor
	proc get_previous_values { context } {
		array set number_editor_previous_values $::settings(dui_number_editor_previous_values)
		set existing [ifexists number_editor_previous_values($context)]
		set existing2 [lsort -unique [lrange $existing end-5 end]]
		catch {
			# if we can sort this numerically, try to.  Might fail if the list is text, not numbers
			set existing2 [lsort -real -unique [lrange $existing end-5 end]]
		}
		return $existing2
	}

	# adds the new value to the saved previous values and then calls the next proc to handle the new value
	proc save_previous_value { nextproc context newvalue } {

		if {$newvalue != ""} {
			array set number_editor_previous_values $::settings(dui_number_editor_previous_values)
			set existing [ifexists number_editor_previous_values($context)]
			lappend existing $newvalue
			
			set number_editor_previous_values($context) $existing
			set ::settings(dui_number_editor_previous_values) [array get number_editor_previous_values]
			save_settings

			catch {
				$nextproc $newvalue
			}
		} else {
			# don't let dui put the invalid value into the variable
			msg -INFO "Invalid data-entry value of '$newvalue' detected ($nextproc/$context)"
		}

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
			if { $new_value != 0 } { 
				set new_value [string trimleft $new_value 0] 
			} 
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
				$widget configure -foreground [dui aspect get dtext fill -style error]
			} elseif { $data(max) ne "" && $data(value) > $data(max) } {
				$widget configure -foreground [dui aspect get dtext fill -style error]
			} else {
				$widget configure -foreground [dui aspect get dtext fill]
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
		dui page close_dialog {}
#		variable data
#		if { $data(callback_cmd) ne "" } {
#			$data(callback_cmd) {}
#		} else {
#			dui page show $data(previous_page)
#		}
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
		} else {
			# blank entry is treated the same as minimum value
			msg -INFO "Empty data entered, so using minimum value of '$data(min)'"
			set data(value) $data(min)
			set $data(num_variable) [format $fmt $data(min)]
			set $data(num_variable) $data(value)			
		}
		
		if { $data(num_variable) ne "" } {
			# john changed so that a invalid entry (such as a blank) no longer causes a Tcl error
			catch {
				set $data(num_variable) $data(value)
			}
		}


		
		dui page close_dialog $data(value)
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
			-justify "center" -initial_state hidden
	
		# Items listbox: Don't use $data(items) as listvariable, as the list changes dynamically with the filter string!
		dui add listbox $page 1280 350 -tags items -listvariable {} -canvas_width $data(listbox_width) -canvas_height 1000 \
			-canvas_anchor n -font_size $font_size -label [translate "Values"] -label_pos {wn -20 3} \
			-label_anchor ne -label_justify right -label_font_size $font_size -yscrollbar 1
		
		bind $widgets(items) <<ListboxSelect>> ::dui::pages::dui_item_selector::items_select
		bind $widgets(items) <Double-Button-1> ::dui::pages::dui_item_selector::page_done
				
		# Ok and Cancel buttons
		dui add dbutton $page 750 1460 -tags page_cancel -style insight_ok -label [translate Cancel] -tap_pad 20
		dui add dbutton $page 1330 1460 -tags page_done -style insight_ok -label [translate Ok] -tap_pad 20
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
	#	-theme: If provided and the current theme for the page is not the requested one, rethemes the page.
	proc load { page_to_hide page_to_show variable values args } {
		variable data
		variable widgets
		array set opts $args

#		if { [info exists opts(-theme)] } {
#			dui page retheme $page_to_show $opts(-theme)
#		}
		
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
		set data(item_values) $values		
		set data(item_type) [ifexists opts(-category_name)]
#		set data(callback_cmd) [ifexists opts(-callback_cmd)]
		set data(selectmode) [ifexists opts(-selectmode) "browse"]
		dui item config $page_to_show items -selectmode $data(selectmode)
		set data(empty_items_msg) [ifexists opts(-empty_items_msg) [translate "There are no available items to show"]]
		set data(listbox_width) [number_in_range [ifexists opts(-listbox_width) 1775] {} 200 2100 {} 0]
		set data(filter_string) {}
		set data(filter_indexes) {}
	
		# We load the widget items directly instead of mapping it to a listvariable, as it may have either the full
		# list or a filtered one.	
		$widgets(items) delete 0 end
		$widgets(items) insert 0 {*}$values
		
		if { $selected ne "" } {
			if { $data(selectmode) in {browse single} } {
				set idx [lsearch -exact $values $selected]
				if { $idx < 0 } {
					$widgets(items) insert end $selected
					lappend $data(item_values) $selected
					lappend $data(item_ids) -1
					set idx [$widgets(items) index end]
				}
				$widgets(items) selection set $idx
				$widgets(items) see $idx
				items_select
			} else {
				foreach sel [split $selected ";"] {
					set idx [lsearch -exact $values $sel]
					if { $idx < 0 } {
						$widgets(items) insert end $sel
						lappend $data(item_values) $sel
						lappend $data(item_ids) -1
						set idx [$widgets(items) index end]
					}
					$widgets(items) selection set $idx
					$widgets(items) see $idx
				}
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
		if { [expr {abs($x1-$x0-$target_width) > 0}] } {
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
		
		if { [string length $filter_string ] < 3 } {
			# Show full list
			if { [llength $item_values] > [$items_widget index end] } {
				$items_widget delete 0 end
				$items_widget insert 0 {*}$item_values
			}
			set data(filter_indexes) {}
		} else {
			set data(filter_indexes) [lsearch -all -nocase $item_values "*$filter_string*"]
	
			$items_widget delete 0 end
			set i 0
			foreach idx $data(filter_indexes) { 
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
		dui page close_dialog {} {} $data(item_type)
	}
		
	proc page_done {} {
		variable data
		variable widgets
		say [translate {done}] $::settings(sound_button_in)

		set items_widget $widgets(items)
		set item_values [list]
		set item_ids [list]
		
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

		if { [$items_widget cget -selectmode] in {single browse} } {
			set item_values [lindex $item_values 0]
			set item_ids [lindex $item_ids 0]
		}

		if { $data(variable) ne "" } {
			set $data(variable) $item_values
		}
				
		dui page close_dialog $item_values $item_ids $data(item_type)
	}

}

namespace eval ::dui::pages::dui_confirm_dialog {
	variable widgets
	array set widgets {}
		
	variable data
	array set data {
		n_buttons 0
		question_y 0.4 
		buttons_y 0.85
	}

	proc setup {} {
		variable data
		set page [namespace tail [namespace current]]
		
		dui add dtext $page 0.5 $data(question_y) -width 0.9 -anchor center -justify center -tags question \
			-style dui_confirm_question -text "Are you sure?" 
		
		set data(n_buttons) 0
		setup_buttons {Yes No} $data(buttons_y)
	}

	proc setup_buttons { labels {y 0.85} } {
		variable data
		variable widgets
		set page [namespace tail [namespace current]]
		
		set n_buttons [llength $labels]
		if { $n_buttons > 5 } {
			set n_buttons 5
		}
		
		if { $n_buttons == $data(n_buttons) && $y == $data(buttons_y) } {
			for { set i 1 } { $i <= $n_buttons } { incr i } {
				dui item config $widgets(button${i}-lbl) -text [translate [lindex $labels [expr {$i-1}]]]
			}
		} else {
			set i 1
			while { $i <= 5 && [dui::page::has_item $page button$i] } {
				dui item delete $page button${i}*
				incr i
			}
		
			set pwidth [expr {(0.8-($n_buttons-1)*0.05)/$n_buttons}]
			
			for { set i 1 } { $i <= $n_buttons } { incr i } {
				dui add dbutton $page [expr {0.1+(($pwidth+0.05)*($i-1))}] $y -bwidth $pwidth -anchor w \
					-tags button$i -style dui_confirm_button -command [list dui::page::close_dialog $i] \
					-label [translate [lindex $labels [expr {$i-1}]]] -label_pos {0.5 0.5} \
			}
			
			set data(n_buttons) $n_buttons
			set data(buttons_y) $y
		}
	}
	
	proc load { page_to_hide page_to_show question {button_labels {Yes No}} args } {
		variable widgets
		variable data
		set page [namespace tail [namespace current]]
		
		set question_y [dui::args::get_option -question_y 0.4 0]
		if { $question_y != $data(question_y) } {
			dui item moveto $page question {} $question_y
			set data(question_y) $question_y
		}
		dui item config $widgets(question) -text [translate $question]

		setup_buttons $button_labels [dui::args::get_option -buttons_y 0.85 0]
		
		return 1
	}

}

