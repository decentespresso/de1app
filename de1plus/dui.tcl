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
				set helvetica_bold_font [dui::font::add_or_get_familyname "hebrew-bold.tt"]
				set global_font_name [dui::font::add_or_get_familyname "NotoSansCJKjp-Regular.otf"]
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
		

		set fontawesome_brands [dui::font::add_or_get_familyname "Font Awesome 5 Brands-Regular-400.otf"]
		set fontawesome_pro [dui::font::add_or_get_familyname "Font Awesome 5 Pro-Regular-400.otf"]

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
			
			default.dcheckbox.font_family "Font Awesome 5 Pro"
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
			default.dbutton.symbol.menu_dlg_close times
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
					msg -NOTICE [namespace current] "aspect '$theme.[join $type /].$aspect' not found and no alternative available"
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
				
		variable font_filename "Font Awesome 5 Pro-Regular-400.otf"
		
		variable symbols
		array set symbols {	
			abacus "\uf640"
			acorn "\uf6ae"
			ad "\uf641"
			address-book "\uf2b9"
			address-card "\uf2bb"
			adjust "\uf042"
			air-conditioner "\uf8f4"
			air-freshener "\uf5d0"
			alarm-clock "\uf34e"
			alarm-exclamation "\uf843"
			alarm-plus "\uf844"
			alarm-snooze "\uf845"
			album "\uf89f"
			album-collection "\uf8a0"
			alicorn "\uf6b0"
			alien "\uf8f5"
			alien-monster "\uf8f6"
			align-center "\uf037"
			align-justify "\uf039"
			align-left "\uf036"
			align-right "\uf038"
			align-slash "\uf846"
			allergies "\uf461"
			ambulance "\uf0f9"
			american-sign-language-interpreting "\uf2a3"
			amp-guitar "\uf8a1"
			analytics "\uf643"
			anchor "\uf13d"
			angel "\uf779"
			angle-double-down "\uf103"
			angle-double-left "\uf100"
			angle-double-right "\uf101"
			angle-double-up "\uf102"
			angle-down "\uf107"
			angle-left "\uf104"
			angle-right "\uf105"
			angle-up "\uf106"
			angry "\uf556"
			ankh "\uf644"
			apple-alt "\uf5d1"
			apple-crate "\uf6b1"
			archive "\uf187"
			archway "\uf557"
			arrow-alt-circle-down "\uf358"
			arrow-alt-circle-left "\uf359"
			arrow-alt-circle-right "\uf35a"
			arrow-alt-circle-up "\uf35b"
			arrow-alt-down "\uf354"
			arrow-alt-from-bottom "\uf346"
			arrow-alt-from-left "\uf347"
			arrow-alt-from-right "\uf348"
			arrow-alt-from-top "\uf349"
			arrow-alt-left "\uf355"
			arrow-alt-right "\uf356"
			arrow-alt-square-down "\uf350"
			arrow-alt-square-left "\uf351"
			arrow-alt-square-right "\uf352"
			arrow-alt-square-up "\uf353"
			arrow-alt-to-bottom "\uf34a"
			arrow-alt-to-left "\uf34b"
			arrow-alt-to-right "\uf34c"
			arrow-alt-to-top "\uf34d"
			arrow-alt-up "\uf357"
			arrow-circle-down "\uf0ab"
			arrow-circle-left "\uf0a8"
			arrow-circle-right "\uf0a9"
			arrow-circle-up "\uf0aa"
			arrow-down "\uf063"
			arrow-from-bottom "\uf342"
			arrow-from-left "\uf343"
			arrow-from-right "\uf344"
			arrow-from-top "\uf345"
			arrow-left "\uf060"
			arrow-right "\uf061"
			arrow-square-down "\uf339"
			arrow-square-left "\uf33a"
			arrow-square-right "\uf33b"
			arrow-square-up "\uf33c"
			arrow-to-bottom "\uf33d"
			arrow-to-left "\uf33e"
			arrow-to-right "\uf340"
			arrow-to-top "\uf341"
			arrow-up "\uf062"
			arrows "\uf047"
			arrows-alt "\uf0b2"
			arrows-alt-h "\uf337"
			arrows-alt-v "\uf338"
			arrows-h "\uf07e"
			arrows-v "\uf07d"
			assistive-listening-systems "\uf2a2"
			asterisk "\uf069"
			at "\uf1fa"
			atlas "\uf558"
			atom "\uf5d2"
			atom-alt "\uf5d3"
			audio-description "\uf29e"
			award "\uf559"
			axe "\uf6b2"
			axe-battle "\uf6b3"
			baby "\uf77c"
			baby-carriage "\uf77d"
			backpack "\uf5d4"
			backspace "\uf55a"
			backward "\uf04a"
			bacon "\uf7e5"
			bacteria "\ue059"
			bacterium "\ue05a"
			badge "\uf335"
			badge-check "\uf336"
			badge-dollar "\uf645"
			badge-percent "\uf646"
			badge-sheriff "\uf8a2"
			badger-honey "\uf6b4"
			bags-shopping "\uf847"
			bahai "\uf666"
			balance-scale "\uf24e"
			balance-scale-left "\uf515"
			balance-scale-right "\uf516"
			ball-pile "\uf77e"
			ballot "\uf732"
			ballot-check "\uf733"
			ban "\uf05e"
			band-aid "\uf462"
			banjo "\uf8a3"
			barcode "\uf02a"
			barcode-alt "\uf463"
			barcode-read "\uf464"
			barcode-scan "\uf465"
			bars "\uf0c9"
			baseball "\uf432"
			baseball-ball "\uf433"
			basketball-ball "\uf434"
			basketball-hoop "\uf435"
			bat "\uf6b5"
			bath "\uf2cd"
			battery-bolt "\uf376"
			battery-empty "\uf244"
			battery-full "\uf240"
			battery-half "\uf242"
			battery-quarter "\uf243"
			battery-slash "\uf377"
			battery-three-quarters "\uf241"
			bed "\uf236"
			bed-alt "\uf8f7"
			bed-bunk "\uf8f8"
			bed-empty "\uf8f9"
			beer "\uf0fc"
			bell "\uf0f3"
			bell-exclamation "\uf848"
			bell-on "\uf8fa"
			bell-plus "\uf849"
			bell-school "\uf5d5"
			bell-school-slash "\uf5d6"
			bell-slash "\uf1f6"
			bells "\uf77f"
			betamax "\uf8a4"
			bezier-curve "\uf55b"
			bible "\uf647"
			bicycle "\uf206"
			biking "\uf84a"
			biking-mountain "\uf84b"
			binoculars "\uf1e5"
			biohazard "\uf780"
			birthday-cake "\uf1fd"
			blanket "\uf498"
			blender "\uf517"
			blender-phone "\uf6b6"
			blind "\uf29d"
			blinds "\uf8fb"
			blinds-open "\uf8fc"
			blinds-raised "\uf8fd"
			blog "\uf781"
			bold "\uf032"
			bolt "\uf0e7"
			bomb "\uf1e2"
			bone "\uf5d7"
			bone-break "\uf5d8"
			bong "\uf55c"
			book "\uf02d"
			book-alt "\uf5d9"
			book-dead "\uf6b7"
			book-heart "\uf499"
			book-medical "\uf7e6"
			book-open "\uf518"
			book-reader "\uf5da"
			book-spells "\uf6b8"
			book-user "\uf7e7"
			bookmark "\uf02e"
			books "\uf5db"
			books-medical "\uf7e8"
			boombox "\uf8a5"
			boot "\uf782"
			booth-curtain "\uf734"
			border-all "\uf84c"
			border-bottom "\uf84d"
			border-center-h "\uf89c"
			border-center-v "\uf89d"
			border-inner "\uf84e"
			border-left "\uf84f"
			border-none "\uf850"
			border-outer "\uf851"
			border-right "\uf852"
			border-style "\uf853"
			border-style-alt "\uf854"
			border-top "\uf855"
			bow-arrow "\uf6b9"
			bowling-ball "\uf436"
			bowling-pins "\uf437"
			box "\uf466"
			box-alt "\uf49a"
			box-ballot "\uf735"
			box-check "\uf467"
			box-fragile "\uf49b"
			box-full "\uf49c"
			box-heart "\uf49d"
			box-open "\uf49e"
			box-tissue "\ue05b"
			box-up "\uf49f"
			box-usd "\uf4a0"
			boxes "\uf468"
			boxes-alt "\uf4a1"
			boxing-glove "\uf438"
			brackets "\uf7e9"
			brackets-curly "\uf7ea"
			braille "\uf2a1"
			brain "\uf5dc"
			bread-loaf "\uf7eb"
			bread-slice "\uf7ec"
			briefcase "\uf0b1"
			briefcase-medical "\uf469"
			bring-forward "\uf856"
			bring-front "\uf857"
			broadcast-tower "\uf519"
			broom "\uf51a"
			browser "\uf37e"
			brush "\uf55d"
			bug "\uf188"
			building "\uf1ad"
			bullhorn "\uf0a1"
			bullseye "\uf140"
			bullseye-arrow "\uf648"
			bullseye-pointer "\uf649"
			burger-soda "\uf858"
			burn "\uf46a"
			burrito "\uf7ed"
			bus "\uf207"
			bus-alt "\uf55e"
			bus-school "\uf5dd"
			business-time "\uf64a"
			cabinet-filing "\uf64b"
			cactus "\uf8a7"
			calculator "\uf1ec"
			calculator-alt "\uf64c"
			calendar "\uf133"
			calendar-alt "\uf073"
			calendar-check "\uf274"
			calendar-day "\uf783"
			calendar-edit "\uf333"
			calendar-exclamation "\uf334"
			calendar-minus "\uf272"
			calendar-plus "\uf271"
			calendar-star "\uf736"
			calendar-times "\uf273"
			calendar-week "\uf784"
			camcorder "\uf8a8"
			camera "\uf030"
			camera-alt "\uf332"
			camera-home "\uf8fe"
			camera-movie "\uf8a9"
			camera-polaroid "\uf8aa"
			camera-retro "\uf083"
			campfire "\uf6ba"
			campground "\uf6bb"
			candle-holder "\uf6bc"
			candy-cane "\uf786"
			candy-corn "\uf6bd"
			cannabis "\uf55f"
			capsules "\uf46b"
			car "\uf1b9"
			car-alt "\uf5de"
			car-battery "\uf5df"
			car-building "\uf859"
			car-bump "\uf5e0"
			car-bus "\uf85a"
			car-crash "\uf5e1"
			car-garage "\uf5e2"
			car-mechanic "\uf5e3"
			car-side "\uf5e4"
			car-tilt "\uf5e5"
			car-wash "\uf5e6"
			caravan "\uf8ff"
			caravan-alt "\ue000"
			caret-circle-down "\uf32d"
			caret-circle-left "\uf32e"
			caret-circle-right "\uf330"
			caret-circle-up "\uf331"
			caret-down "\uf0d7"
			caret-left "\uf0d9"
			caret-right "\uf0da"
			caret-square-down "\uf150"
			caret-square-left "\uf191"
			caret-square-right "\uf152"
			caret-square-up "\uf151"
			caret-up "\uf0d8"
			carrot "\uf787"
			cars "\uf85b"
			cart-arrow-down "\uf218"
			cart-plus "\uf217"
			cash-register "\uf788"
			cassette-tape "\uf8ab"
			cat "\uf6be"
			cat-space "\ue001"
			cauldron "\uf6bf"
			cctv "\uf8ac"
			certificate "\uf0a3"
			chair "\uf6c0"
			chair-office "\uf6c1"
			chalkboard "\uf51b"
			chalkboard-teacher "\uf51c"
			charging-station "\uf5e7"
			chart-area "\uf1fe"
			chart-bar "\uf080"
			chart-line "\uf201"
			chart-line-down "\uf64d"
			chart-network "\uf78a"
			chart-pie "\uf200"
			chart-pie-alt "\uf64e"
			chart-scatter "\uf7ee"
			check "\uf00c"
			check-circle "\uf058"
			check-double "\uf560"
			check-square "\uf14a"
			cheese "\uf7ef"
			cheese-swiss "\uf7f0"
			cheeseburger "\uf7f1"
			chess "\uf439"
			chess-bishop "\uf43a"
			chess-bishop-alt "\uf43b"
			chess-board "\uf43c"
			chess-clock "\uf43d"
			chess-clock-alt "\uf43e"
			chess-king "\uf43f"
			chess-king-alt "\uf440"
			chess-knight "\uf441"
			chess-knight-alt "\uf442"
			chess-pawn "\uf443"
			chess-pawn-alt "\uf444"
			chess-queen "\uf445"
			chess-queen-alt "\uf446"
			chess-rook "\uf447"
			chess-rook-alt "\uf448"
			chevron-circle-down "\uf13a"
			chevron-circle-left "\uf137"
			chevron-circle-right "\uf138"
			chevron-circle-up "\uf139"
			chevron-double-down "\uf322"
			chevron-double-left "\uf323"
			chevron-double-right "\uf324"
			chevron-double-up "\uf325"
			chevron-down "\uf078"
			chevron-left "\uf053"
			chevron-right "\uf054"
			chevron-square-down "\uf329"
			chevron-square-left "\uf32a"
			chevron-square-right "\uf32b"
			chevron-square-up "\uf32c"
			chevron-up "\uf077"
			child "\uf1ae"
			chimney "\uf78b"
			church "\uf51d"
			circle "\uf111"
			circle-notch "\uf1ce"
			city "\uf64f"
			clarinet "\uf8ad"
			claw-marks "\uf6c2"
			clinic-medical "\uf7f2"
			clipboard "\uf328"
			clipboard-check "\uf46c"
			clipboard-list "\uf46d"
			clipboard-list-check "\uf737"
			clipboard-prescription "\uf5e8"
			clipboard-user "\uf7f3"
			clock "\uf017"
			clone "\uf24d"
			closed-captioning "\uf20a"
			cloud "\uf0c2"
			cloud-download "\uf0ed"
			cloud-download-alt "\uf381"
			cloud-drizzle "\uf738"
			cloud-hail "\uf739"
			cloud-hail-mixed "\uf73a"
			cloud-meatball "\uf73b"
			cloud-moon "\uf6c3"
			cloud-moon-rain "\uf73c"
			cloud-music "\uf8ae"
			cloud-rain "\uf73d"
			cloud-rainbow "\uf73e"
			cloud-showers "\uf73f"
			cloud-showers-heavy "\uf740"
			cloud-sleet "\uf741"
			cloud-snow "\uf742"
			cloud-sun "\uf6c4"
			cloud-sun-rain "\uf743"
			cloud-upload "\uf0ee"
			cloud-upload-alt "\uf382"
			clouds "\uf744"
			clouds-moon "\uf745"
			clouds-sun "\uf746"
			club "\uf327"
			cocktail "\uf561"
			code "\uf121"
			code-branch "\uf126"
			code-commit "\uf386"
			code-merge "\uf387"
			coffee "\uf0f4"
			coffee-pot "\ue002"
			coffee-togo "\uf6c5"
			coffin "\uf6c6"
			coffin-cross "\ue051"
			cog "\uf013"
			cogs "\uf085"
			coin "\uf85c"
			coins "\uf51e"
			columns "\uf0db"
			comet "\ue003"
			comment "\uf075"
			comment-alt "\uf27a"
			comment-alt-check "\uf4a2"
			comment-alt-dollar "\uf650"
			comment-alt-dots "\uf4a3"
			comment-alt-edit "\uf4a4"
			comment-alt-exclamation "\uf4a5"
			comment-alt-lines "\uf4a6"
			comment-alt-medical "\uf7f4"
			comment-alt-minus "\uf4a7"
			comment-alt-music "\uf8af"
			comment-alt-plus "\uf4a8"
			comment-alt-slash "\uf4a9"
			comment-alt-smile "\uf4aa"
			comment-alt-times "\uf4ab"
			comment-check "\uf4ac"
			comment-dollar "\uf651"
			comment-dots "\uf4ad"
			comment-edit "\uf4ae"
			comment-exclamation "\uf4af"
			comment-lines "\uf4b0"
			comment-medical "\uf7f5"
			comment-minus "\uf4b1"
			comment-music "\uf8b0"
			comment-plus "\uf4b2"
			comment-slash "\uf4b3"
			comment-smile "\uf4b4"
			comment-times "\uf4b5"
			comments "\uf086"
			comments-alt "\uf4b6"
			comments-alt-dollar "\uf652"
			comments-dollar "\uf653"
			compact-disc "\uf51f"
			compass "\uf14e"
			compass-slash "\uf5e9"
			compress "\uf066"
			compress-alt "\uf422"
			compress-arrows-alt "\uf78c"
			compress-wide "\uf326"
			computer-classic "\uf8b1"
			computer-speaker "\uf8b2"
			concierge-bell "\uf562"
			construction "\uf85d"
			container-storage "\uf4b7"
			conveyor-belt "\uf46e"
			conveyor-belt-alt "\uf46f"
			cookie "\uf563"
			cookie-bite "\uf564"
			copy "\uf0c5"
			copyright "\uf1f9"
			corn "\uf6c7"
			couch "\uf4b8"
			cow "\uf6c8"
			cowbell "\uf8b3"
			cowbell-more "\uf8b4"
			credit-card "\uf09d"
			credit-card-blank "\uf389"
			credit-card-front "\uf38a"
			cricket "\uf449"
			croissant "\uf7f6"
			crop "\uf125"
			crop-alt "\uf565"
			cross "\uf654"
			crosshairs "\uf05b"
			crow "\uf520"
			crown "\uf521"
			crutch "\uf7f7"
			crutches "\uf7f8"
			cube "\uf1b2"
			cubes "\uf1b3"
			curling "\uf44a"
			cut "\uf0c4"
			dagger "\uf6cb"
			database "\uf1c0"
			deaf "\uf2a4"
			debug "\uf7f9"
			deer "\uf78e"
			deer-rudolph "\uf78f"
			democrat "\uf747"
			desktop "\uf108"
			desktop-alt "\uf390"
			dewpoint "\uf748"
			dharmachakra "\uf655"
			diagnoses "\uf470"
			diamond "\uf219"
			dice "\uf522"
			dice-d10 "\uf6cd"
			dice-d12 "\uf6ce"
			dice-d20 "\uf6cf"
			dice-d4 "\uf6d0"
			dice-d6 "\uf6d1"
			dice-d8 "\uf6d2"
			dice-five "\uf523"
			dice-four "\uf524"
			dice-one "\uf525"
			dice-six "\uf526"
			dice-three "\uf527"
			dice-two "\uf528"
			digging "\uf85e"
			digital-tachograph "\uf566"
			diploma "\uf5ea"
			directions "\uf5eb"
			disc-drive "\uf8b5"
			disease "\uf7fa"
			divide "\uf529"
			dizzy "\uf567"
			dna "\uf471"
			do-not-enter "\uf5ec"
			dog "\uf6d3"
			dog-leashed "\uf6d4"
			dollar-sign "\uf155"
			dolly "\uf472"
			dolly-empty "\uf473"
			dolly-flatbed "\uf474"
			dolly-flatbed-alt "\uf475"
			dolly-flatbed-empty "\uf476"
			donate "\uf4b9"
			door-closed "\uf52a"
			door-open "\uf52b"
			dot-circle "\uf192"
			dove "\uf4ba"
			download "\uf019"
			drafting-compass "\uf568"
			dragon "\uf6d5"
			draw-circle "\uf5ed"
			draw-polygon "\uf5ee"
			draw-square "\uf5ef"
			dreidel "\uf792"
			drone "\uf85f"
			drone-alt "\uf860"
			drum "\uf569"
			drum-steelpan "\uf56a"
			drumstick "\uf6d6"
			drumstick-bite "\uf6d7"
			dryer "\uf861"
			dryer-alt "\uf862"
			duck "\uf6d8"
			dumbbell "\uf44b"
			dumpster "\uf793"
			dumpster-fire "\uf794"
			dungeon "\uf6d9"
			ear "\uf5f0"
			ear-muffs "\uf795"
			eclipse "\uf749"
			eclipse-alt "\uf74a"
			edit "\uf044"
			egg "\uf7fb"
			egg-fried "\uf7fc"
			eject "\uf052"
			elephant "\uf6da"
			ellipsis-h "\uf141"
			ellipsis-h-alt "\uf39b"
			ellipsis-v "\uf142"
			ellipsis-v-alt "\uf39c"
			empty-set "\uf656"
			engine-warning "\uf5f2"
			envelope "\uf0e0"
			envelope-open "\uf2b6"
			envelope-open-dollar "\uf657"
			envelope-open-text "\uf658"
			envelope-square "\uf199"
			equals "\uf52c"
			eraser "\uf12d"
			ethernet "\uf796"
			euro-sign "\uf153"
			exchange "\uf0ec"
			exchange-alt "\uf362"
			exclamation "\uf12a"
			exclamation-circle "\uf06a"
			exclamation-square "\uf321"
			exclamation-triangle "\uf071"
			expand "\uf065"
			expand-alt "\uf424"
			expand-arrows "\uf31d"
			expand-arrows-alt "\uf31e"
			expand-wide "\uf320"
			external-link "\uf08e"
			external-link-alt "\uf35d"
			external-link-square "\uf14c"
			external-link-square-alt "\uf360"
			eye "\uf06e"
			eye-dropper "\uf1fb"
			eye-evil "\uf6db"
			eye-slash "\uf070"
			fan "\uf863"
			fan-table "\ue004"
			farm "\uf864"
			fast-backward "\uf049"
			fast-forward "\uf050"
			faucet "\ue005"
			faucet-drip "\ue006"
			fax "\uf1ac"
			feather "\uf52d"
			feather-alt "\uf56b"
			female "\uf182"
			field-hockey "\uf44c"
			fighter-jet "\uf0fb"
			file "\uf15b"
			file-alt "\uf15c"
			file-archive "\uf1c6"
			file-audio "\uf1c7"
			file-certificate "\uf5f3"
			file-chart-line "\uf659"
			file-chart-pie "\uf65a"
			file-check "\uf316"
			file-code "\uf1c9"
			file-contract "\uf56c"
			file-csv "\uf6dd"
			file-download "\uf56d"
			file-edit "\uf31c"
			file-excel "\uf1c3"
			file-exclamation "\uf31a"
			file-export "\uf56e"
			file-image "\uf1c5"
			file-import "\uf56f"
			file-invoice "\uf570"
			file-invoice-dollar "\uf571"
			file-medical "\uf477"
			file-medical-alt "\uf478"
			file-minus "\uf318"
			file-music "\uf8b6"
			file-pdf "\uf1c1"
			file-plus "\uf319"
			file-powerpoint "\uf1c4"
			file-prescription "\uf572"
			file-search "\uf865"
			file-signature "\uf573"
			file-spreadsheet "\uf65b"
			file-times "\uf317"
			file-upload "\uf574"
			file-user "\uf65c"
			file-video "\uf1c8"
			file-word "\uf1c2"
			files-medical "\uf7fd"
			fill "\uf575"
			fill-drip "\uf576"
			film "\uf008"
			film-alt "\uf3a0"
			film-canister "\uf8b7"
			filter "\uf0b0"
			fingerprint "\uf577"
			fire "\uf06d"
			fire-alt "\uf7e4"
			fire-extinguisher "\uf134"
			fire-smoke "\uf74b"
			fireplace "\uf79a"
			first-aid "\uf479"
			fish "\uf578"
			fish-cooked "\uf7fe"
			fist-raised "\uf6de"
			flag "\uf024"
			flag-alt "\uf74c"
			flag-checkered "\uf11e"
			flag-usa "\uf74d"
			flame "\uf6df"
			flashlight "\uf8b8"
			flask "\uf0c3"
			flask-poison "\uf6e0"
			flask-potion "\uf6e1"
			flower "\uf7ff"
			flower-daffodil "\uf800"
			flower-tulip "\uf801"
			flushed "\uf579"
			flute "\uf8b9"
			flux-capacitor "\uf8ba"
			fog "\uf74e"
			folder "\uf07b"
			folder-download "\ue053"
			folder-minus "\uf65d"
			folder-open "\uf07c"
			folder-plus "\uf65e"
			folder-times "\uf65f"
			folder-tree "\uf802"
			folder-upload "\ue054"
			folders "\uf660"
			font "\uf031"
			font-case "\uf866"
			football-ball "\uf44e"
			football-helmet "\uf44f"
			forklift "\uf47a"
			forward "\uf04e"
			fragile "\uf4bb"
			french-fries "\uf803"
			frog "\uf52e"
			frosty-head "\uf79b"
			frown "\uf119"
			frown-open "\uf57a"
			function "\uf661"
			funnel-dollar "\uf662"
			futbol "\uf1e3"
			galaxy "\ue008"
			game-board "\uf867"
			game-board-alt "\uf868"
			game-console-handheld "\uf8bb"
			gamepad "\uf11b"
			gamepad-alt "\uf8bc"
			garage "\ue009"
			garage-car "\ue00a"
			garage-open "\ue00b"
			gas-pump "\uf52f"
			gas-pump-slash "\uf5f4"
			gavel "\uf0e3"
			gem "\uf3a5"
			genderless "\uf22d"
			ghost "\uf6e2"
			gift "\uf06b"
			gift-card "\uf663"
			gifts "\uf79c"
			gingerbread-man "\uf79d"
			glass "\uf804"
			glass-champagne "\uf79e"
			glass-cheers "\uf79f"
			glass-citrus "\uf869"
			glass-martini "\uf000"
			glass-martini-alt "\uf57b"
			glass-whiskey "\uf7a0"
			glass-whiskey-rocks "\uf7a1"
			glasses "\uf530"
			glasses-alt "\uf5f5"
			globe "\uf0ac"
			globe-africa "\uf57c"
			globe-americas "\uf57d"
			globe-asia "\uf57e"
			globe-europe "\uf7a2"
			globe-snow "\uf7a3"
			globe-stand "\uf5f6"
			golf-ball "\uf450"
			golf-club "\uf451"
			gopuram "\uf664"
			graduation-cap "\uf19d"
			gramophone "\uf8bd"
			greater-than "\uf531"
			greater-than-equal "\uf532"
			grimace "\uf57f"
			grin "\uf580"
			grin-alt "\uf581"
			grin-beam "\uf582"
			grin-beam-sweat "\uf583"
			grin-hearts "\uf584"
			grin-squint "\uf585"
			grin-squint-tears "\uf586"
			grin-stars "\uf587"
			grin-tears "\uf588"
			grin-tongue "\uf589"
			grin-tongue-squint "\uf58a"
			grin-tongue-wink "\uf58b"
			grin-wink "\uf58c"
			grip-horizontal "\uf58d"
			grip-lines "\uf7a4"
			grip-lines-vertical "\uf7a5"
			grip-vertical "\uf58e"
			guitar "\uf7a6"
			guitar-electric "\uf8be"
			guitars "\uf8bf"
			h-square "\uf0fd"
			h1 "\uf313"
			h2 "\uf314"
			h3 "\uf315"
			h4 "\uf86a"
			hamburger "\uf805"
			hammer "\uf6e3"
			hammer-war "\uf6e4"
			hamsa "\uf665"
			hand-heart "\uf4bc"
			hand-holding "\uf4bd"
			hand-holding-box "\uf47b"
			hand-holding-heart "\uf4be"
			hand-holding-magic "\uf6e5"
			hand-holding-medical "\ue05c"
			hand-holding-seedling "\uf4bf"
			hand-holding-usd "\uf4c0"
			hand-holding-water "\uf4c1"
			hand-lizard "\uf258"
			hand-middle-finger "\uf806"
			hand-paper "\uf256"
			hand-peace "\uf25b"
			hand-point-down "\uf0a7"
			hand-point-left "\uf0a5"
			hand-point-right "\uf0a4"
			hand-point-up "\uf0a6"
			hand-pointer "\uf25a"
			hand-receiving "\uf47c"
			hand-rock "\uf255"
			hand-scissors "\uf257"
			hand-sparkles "\ue05d"
			hand-spock "\uf259"
			hands "\uf4c2"
			hands-heart "\uf4c3"
			hands-helping "\uf4c4"
			hands-usd "\uf4c5"
			hands-wash "\ue05e"
			handshake "\uf2b5"
			handshake-alt "\uf4c6"
			handshake-alt-slash "\ue05f"
			handshake-slash "\ue060"
			hanukiah "\uf6e6"
			hard-hat "\uf807"
			hashtag "\uf292"
			hat-chef "\uf86b"
			hat-cowboy "\uf8c0"
			hat-cowboy-side "\uf8c1"
			hat-santa "\uf7a7"
			hat-winter "\uf7a8"
			hat-witch "\uf6e7"
			hat-wizard "\uf6e8"
			hdd "\uf0a0"
			head-side "\uf6e9"
			head-side-brain "\uf808"
			head-side-cough "\ue061"
			head-side-cough-slash "\ue062"
			head-side-headphones "\uf8c2"
			head-side-mask "\ue063"
			head-side-medical "\uf809"
			head-side-virus "\ue064"
			head-vr "\uf6ea"
			heading "\uf1dc"
			headphones "\uf025"
			headphones-alt "\uf58f"
			headset "\uf590"
			heart "\uf004"
			heart-broken "\uf7a9"
			heart-circle "\uf4c7"
			heart-rate "\uf5f8"
			heart-square "\uf4c8"
			heartbeat "\uf21e"
			heat "\ue00c"
			helicopter "\uf533"
			helmet-battle "\uf6eb"
			hexagon "\uf312"
			highlighter "\uf591"
			hiking "\uf6ec"
			hippo "\uf6ed"
			history "\uf1da"
			hockey-mask "\uf6ee"
			hockey-puck "\uf453"
			hockey-sticks "\uf454"
			holly-berry "\uf7aa"
			home "\uf015"
			home-alt "\uf80a"
			home-heart "\uf4c9"
			home-lg "\uf80b"
			home-lg-alt "\uf80c"
			hood-cloak "\uf6ef"
			horizontal-rule "\uf86c"
			horse "\uf6f0"
			horse-head "\uf7ab"
			horse-saddle "\uf8c3"
			hospital "\uf0f8"
			hospital-alt "\uf47d"
			hospital-symbol "\uf47e"
			hospital-user "\uf80d"
			hospitals "\uf80e"
			hot-tub "\uf593"
			hotdog "\uf80f"
			hotel "\uf594"
			hourglass "\uf254"
			hourglass-end "\uf253"
			hourglass-half "\uf252"
			hourglass-start "\uf251"
			house "\ue00d"
			house-damage "\uf6f1"
			house-day "\ue00e"
			house-flood "\uf74f"
			house-leave "\ue00f"
			house-night "\ue010"
			house-return "\ue011"
			house-signal "\ue012"
			house-user "\ue065"
			hryvnia "\uf6f2"
			humidity "\uf750"
			hurricane "\uf751"
			i-cursor "\uf246"
			ice-cream "\uf810"
			ice-skate "\uf7ac"
			icicles "\uf7ad"
			icons "\uf86d"
			icons-alt "\uf86e"
			id-badge "\uf2c1"
			id-card "\uf2c2"
			id-card-alt "\uf47f"
			igloo "\uf7ae"
			image "\uf03e"
			image-polaroid "\uf8c4"
			images "\uf302"
			inbox "\uf01c"
			inbox-in "\uf310"
			inbox-out "\uf311"
			indent "\uf03c"
			industry "\uf275"
			industry-alt "\uf3b3"
			infinity "\uf534"
			info "\uf129"
			info-circle "\uf05a"
			info-square "\uf30f"
			inhaler "\uf5f9"
			integral "\uf667"
			intersection "\uf668"
			inventory "\uf480"
			island-tropical "\uf811"
			italic "\uf033"
			jack-o-lantern "\uf30e"
			jedi "\uf669"
			joint "\uf595"
			journal-whills "\uf66a"
			joystick "\uf8c5"
			jug "\uf8c6"
			kaaba "\uf66b"
			kazoo "\uf8c7"
			kerning "\uf86f"
			key "\uf084"
			key-skeleton "\uf6f3"
			keyboard "\uf11c"
			keynote "\uf66c"
			khanda "\uf66d"
			kidneys "\uf5fb"
			kiss "\uf596"
			kiss-beam "\uf597"
			kiss-wink-heart "\uf598"
			kite "\uf6f4"
			kiwi-bird "\uf535"
			knife-kitchen "\uf6f5"
			lambda "\uf66e"
			lamp "\uf4ca"
			lamp-desk "\ue014"
			lamp-floor "\ue015"
			landmark "\uf66f"
			landmark-alt "\uf752"
			language "\uf1ab"
			laptop "\uf109"
			laptop-code "\uf5fc"
			laptop-house "\ue066"
			laptop-medical "\uf812"
			lasso "\uf8c8"
			laugh "\uf599"
			laugh-beam "\uf59a"
			laugh-squint "\uf59b"
			laugh-wink "\uf59c"
			layer-group "\uf5fd"
			layer-minus "\uf5fe"
			layer-plus "\uf5ff"
			leaf "\uf06c"
			leaf-heart "\uf4cb"
			leaf-maple "\uf6f6"
			leaf-oak "\uf6f7"
			lemon "\uf094"
			less-than "\uf536"
			less-than-equal "\uf537"
			level-down "\uf149"
			level-down-alt "\uf3be"
			level-up "\uf148"
			level-up-alt "\uf3bf"
			life-ring "\uf1cd"
			light-ceiling "\ue016"
			light-switch "\ue017"
			light-switch-off "\ue018"
			light-switch-on "\ue019"
			lightbulb "\uf0eb"
			lightbulb-dollar "\uf670"
			lightbulb-exclamation "\uf671"
			lightbulb-on "\uf672"
			lightbulb-slash "\uf673"
			lights-holiday "\uf7b2"
			line-columns "\uf870"
			line-height "\uf871"
			link "\uf0c1"
			lips "\uf600"
			lira-sign "\uf195"
			list "\uf03a"
			list-alt "\uf022"
			list-music "\uf8c9"
			list-ol "\uf0cb"
			list-ul "\uf0ca"
			location "\uf601"
			location-arrow "\uf124"
			location-circle "\uf602"
			location-slash "\uf603"
			lock "\uf023"
			lock-alt "\uf30d"
			lock-open "\uf3c1"
			lock-open-alt "\uf3c2"
			long-arrow-alt-down "\uf309"
			long-arrow-alt-left "\uf30a"
			long-arrow-alt-right "\uf30b"
			long-arrow-alt-up "\uf30c"
			long-arrow-down "\uf175"
			long-arrow-left "\uf177"
			long-arrow-right "\uf178"
			long-arrow-up "\uf176"
			loveseat "\uf4cc"
			low-vision "\uf2a8"
			luchador "\uf455"
			luggage-cart "\uf59d"
			lungs "\uf604"
			lungs-virus "\ue067"
			mace "\uf6f8"
			magic "\uf0d0"
			magnet "\uf076"
			mail-bulk "\uf674"
			mailbox "\uf813"
			male "\uf183"
			mandolin "\uf6f9"
			map "\uf279"
			map-marked "\uf59f"
			map-marked-alt "\uf5a0"
			map-marker "\uf041"
			map-marker-alt "\uf3c5"
			map-marker-alt-slash "\uf605"
			map-marker-check "\uf606"
			map-marker-edit "\uf607"
			map-marker-exclamation "\uf608"
			map-marker-minus "\uf609"
			map-marker-plus "\uf60a"
			map-marker-question "\uf60b"
			map-marker-slash "\uf60c"
			map-marker-smile "\uf60d"
			map-marker-times "\uf60e"
			map-pin "\uf276"
			map-signs "\uf277"
			marker "\uf5a1"
			mars "\uf222"
			mars-double "\uf227"
			mars-stroke "\uf229"
			mars-stroke-h "\uf22b"
			mars-stroke-v "\uf22a"
			mask "\uf6fa"
			meat "\uf814"
			medal "\uf5a2"
			medkit "\uf0fa"
			megaphone "\uf675"
			meh "\uf11a"
			meh-blank "\uf5a4"
			meh-rolling-eyes "\uf5a5"
			memory "\uf538"
			menorah "\uf676"
			mercury "\uf223"
			meteor "\uf753"
			microchip "\uf2db"
			microphone "\uf130"
			microphone-alt "\uf3c9"
			microphone-alt-slash "\uf539"
			microphone-slash "\uf131"
			microphone-stand "\uf8cb"
			microscope "\uf610"
			microwave "\ue01b"
			mind-share "\uf677"
			minus "\uf068"
			minus-circle "\uf056"
			minus-hexagon "\uf307"
			minus-octagon "\uf308"
			minus-square "\uf146"
			mistletoe "\uf7b4"
			mitten "\uf7b5"
			mobile "\uf10b"
			mobile-alt "\uf3cd"
			mobile-android "\uf3ce"
			mobile-android-alt "\uf3cf"
			money-bill "\uf0d6"
			money-bill-alt "\uf3d1"
			money-bill-wave "\uf53a"
			money-bill-wave-alt "\uf53b"
			money-check "\uf53c"
			money-check-alt "\uf53d"
			money-check-edit "\uf872"
			money-check-edit-alt "\uf873"
			monitor-heart-rate "\uf611"
			monkey "\uf6fb"
			monument "\uf5a6"
			moon "\uf186"
			moon-cloud "\uf754"
			moon-stars "\uf755"
			mortar-pestle "\uf5a7"
			mosque "\uf678"
			motorcycle "\uf21c"
			mountain "\uf6fc"
			mountains "\uf6fd"
			mouse "\uf8cc"
			mouse-alt "\uf8cd"
			mouse-pointer "\uf245"
			mp3-player "\uf8ce"
			mug "\uf874"
			mug-hot "\uf7b6"
			mug-marshmallows "\uf7b7"
			mug-tea "\uf875"
			music "\uf001"
			music-alt "\uf8cf"
			music-alt-slash "\uf8d0"
			music-slash "\uf8d1"
			narwhal "\uf6fe"
			network-wired "\uf6ff"
			neuter "\uf22c"
			newspaper "\uf1ea"
			not-equal "\uf53e"
			notes-medical "\uf481"
			object-group "\uf247"
			object-ungroup "\uf248"
			octagon "\uf306"
			oil-can "\uf613"
			oil-temp "\uf614"
			om "\uf679"
			omega "\uf67a"
			ornament "\uf7b8"
			otter "\uf700"
			outdent "\uf03b"
			outlet "\ue01c"
			oven "\ue01d"
			overline "\uf876"
			page-break "\uf877"
			pager "\uf815"
			paint-brush "\uf1fc"
			paint-brush-alt "\uf5a9"
			paint-roller "\uf5aa"
			palette "\uf53f"
			pallet "\uf482"
			pallet-alt "\uf483"
			paper-plane "\uf1d8"
			paperclip "\uf0c6"
			parachute-box "\uf4cd"
			paragraph "\uf1dd"
			paragraph-rtl "\uf878"
			parking "\uf540"
			parking-circle "\uf615"
			parking-circle-slash "\uf616"
			parking-slash "\uf617"
			passport "\uf5ab"
			pastafarianism "\uf67b"
			paste "\uf0ea"
			pause "\uf04c"
			pause-circle "\uf28b"
			paw "\uf1b0"
			paw-alt "\uf701"
			paw-claws "\uf702"
			peace "\uf67c"
			pegasus "\uf703"
			pen "\uf304"
			pen-alt "\uf305"
			pen-fancy "\uf5ac"
			pen-nib "\uf5ad"
			pen-square "\uf14b"
			pencil "\uf040"
			pencil-alt "\uf303"
			pencil-paintbrush "\uf618"
			pencil-ruler "\uf5ae"
			pennant "\uf456"
			people-arrows "\ue068"
			people-carry "\uf4ce"
			pepper-hot "\uf816"
			percent "\uf295"
			percentage "\uf541"
			person-booth "\uf756"
			person-carry "\uf4cf"
			person-dolly "\uf4d0"
			person-dolly-empty "\uf4d1"
			person-sign "\uf757"
			phone "\uf095"
			phone-alt "\uf879"
			phone-laptop "\uf87a"
			phone-office "\uf67d"
			phone-plus "\uf4d2"
			phone-rotary "\uf8d3"
			phone-slash "\uf3dd"
			phone-square "\uf098"
			phone-square-alt "\uf87b"
			phone-volume "\uf2a0"
			photo-video "\uf87c"
			pi "\uf67e"
			piano "\uf8d4"
			piano-keyboard "\uf8d5"
			pie "\uf705"
			pig "\uf706"
			piggy-bank "\uf4d3"
			pills "\uf484"
			pizza "\uf817"
			pizza-slice "\uf818"
			place-of-worship "\uf67f"
			plane "\uf072"
			plane-alt "\uf3de"
			plane-arrival "\uf5af"
			plane-departure "\uf5b0"
			plane-slash "\ue069"
			planet-moon "\ue01f"
			planet-ringed "\ue020"
			play "\uf04b"
			play-circle "\uf144"
			plug "\uf1e6"
			plus "\uf067"
			plus-circle "\uf055"
			plus-hexagon "\uf300"
			plus-octagon "\uf301"
			plus-square "\uf0fe"
			podcast "\uf2ce"
			podium "\uf680"
			podium-star "\uf758"
			police-box "\ue021"
			poll "\uf681"
			poll-h "\uf682"
			poll-people "\uf759"
			poo "\uf2fe"
			poo-storm "\uf75a"
			poop "\uf619"
			popcorn "\uf819"
			portal-enter "\ue022"
			portal-exit "\ue023"
			portrait "\uf3e0"
			pound-sign "\uf154"
			power-off "\uf011"
			pray "\uf683"
			praying-hands "\uf684"
			prescription "\uf5b1"
			prescription-bottle "\uf485"
			prescription-bottle-alt "\uf486"
			presentation "\uf685"
			print "\uf02f"
			print-search "\uf81a"
			print-slash "\uf686"
			procedures "\uf487"
			project-diagram "\uf542"
			projector "\uf8d6"
			pump-medical "\ue06a"
			pump-soap "\ue06b"
			pumpkin "\uf707"
			puzzle-piece "\uf12e"
			qrcode "\uf029"
			question "\uf128"
			question-circle "\uf059"
			question-square "\uf2fd"
			quidditch "\uf458"
			quote-left "\uf10d"
			quote-right "\uf10e"
			quran "\uf687"
			rabbit "\uf708"
			rabbit-fast "\uf709"
			racquet "\uf45a"
			radar "\ue024"
			radiation "\uf7b9"
			radiation-alt "\uf7ba"
			radio "\uf8d7"
			radio-alt "\uf8d8"
			rainbow "\uf75b"
			raindrops "\uf75c"
			ram "\uf70a"
			ramp-loading "\uf4d4"
			random "\uf074"
			raygun "\ue025"
			receipt "\uf543"
			record-vinyl "\uf8d9"
			rectangle-landscape "\uf2fa"
			rectangle-portrait "\uf2fb"
			rectangle-wide "\uf2fc"
			recycle "\uf1b8"
			redo "\uf01e"
			redo-alt "\uf2f9"
			refrigerator "\ue026"
			registered "\uf25d"
			remove-format "\uf87d"
			repeat "\uf363"
			repeat-1 "\uf365"
			repeat-1-alt "\uf366"
			repeat-alt "\uf364"
			reply "\uf3e5"
			reply-all "\uf122"
			republican "\uf75e"
			restroom "\uf7bd"
			retweet "\uf079"
			retweet-alt "\uf361"
			ribbon "\uf4d6"
			ring "\uf70b"
			rings-wedding "\uf81b"
			road "\uf018"
			robot "\uf544"
			rocket "\uf135"
			rocket-launch "\ue027"
			route "\uf4d7"
			route-highway "\uf61a"
			route-interstate "\uf61b"
			router "\uf8da"
			rss "\uf09e"
			rss-square "\uf143"
			ruble-sign "\uf158"
			ruler "\uf545"
			ruler-combined "\uf546"
			ruler-horizontal "\uf547"
			ruler-triangle "\uf61c"
			ruler-vertical "\uf548"
			running "\uf70c"
			rupee-sign "\uf156"
			rv "\uf7be"
			sack "\uf81c"
			sack-dollar "\uf81d"
			sad-cry "\uf5b3"
			sad-tear "\uf5b4"
			salad "\uf81e"
			sandwich "\uf81f"
			satellite "\uf7bf"
			satellite-dish "\uf7c0"
			sausage "\uf820"
			save "\uf0c7"
			sax-hot "\uf8db"
			saxophone "\uf8dc"
			scalpel "\uf61d"
			scalpel-path "\uf61e"
			scanner "\uf488"
			scanner-image "\uf8f3"
			scanner-keyboard "\uf489"
			scanner-touchscreen "\uf48a"
			scarecrow "\uf70d"
			scarf "\uf7c1"
			school "\uf549"
			screwdriver "\uf54a"
			scroll "\uf70e"
			scroll-old "\uf70f"
			scrubber "\uf2f8"
			scythe "\uf710"
			sd-card "\uf7c2"
			search "\uf002"
			search-dollar "\uf688"
			search-location "\uf689"
			search-minus "\uf010"
			search-plus "\uf00e"
			seedling "\uf4d8"
			send-back "\uf87e"
			send-backward "\uf87f"
			sensor "\ue028"
			sensor-alert "\ue029"
			sensor-fire "\ue02a"
			sensor-on "\ue02b"
			sensor-smoke "\ue02c"
			server "\uf233"
			shapes "\uf61f"
			share "\uf064"
			share-all "\uf367"
			share-alt "\uf1e0"
			share-alt-square "\uf1e1"
			share-square "\uf14d"
			sheep "\uf711"
			shekel-sign "\uf20b"
			shield "\uf132"
			shield-alt "\uf3ed"
			shield-check "\uf2f7"
			shield-cross "\uf712"
			shield-virus "\ue06c"
			ship "\uf21a"
			shipping-fast "\uf48b"
			shipping-timed "\uf48c"
			shish-kebab "\uf821"
			shoe-prints "\uf54b"
			shopping-bag "\uf290"
			shopping-basket "\uf291"
			shopping-cart "\uf07a"
			shovel "\uf713"
			shovel-snow "\uf7c3"
			shower "\uf2cc"
			shredder "\uf68a"
			shuttle-van "\uf5b6"
			shuttlecock "\uf45b"
			sickle "\uf822"
			sigma "\uf68b"
			sign "\uf4d9"
			sign-in "\uf090"
			sign-in-alt "\uf2f6"
			sign-language "\uf2a7"
			sign-out "\uf08b"
			sign-out-alt "\uf2f5"
			signal "\uf012"
			signal-1 "\uf68c"
			signal-2 "\uf68d"
			signal-3 "\uf68e"
			signal-4 "\uf68f"
			signal-alt "\uf690"
			signal-alt-1 "\uf691"
			signal-alt-2 "\uf692"
			signal-alt-3 "\uf693"
			signal-alt-slash "\uf694"
			signal-slash "\uf695"
			signal-stream "\uf8dd"
			signature "\uf5b7"
			sim-card "\uf7c4"
			sink "\ue06d"
			siren "\ue02d"
			siren-on "\ue02e"
			sitemap "\uf0e8"
			skating "\uf7c5"
			skeleton "\uf620"
			ski-jump "\uf7c7"
			ski-lift "\uf7c8"
			skiing "\uf7c9"
			skiing-nordic "\uf7ca"
			skull "\uf54c"
			skull-cow "\uf8de"
			skull-crossbones "\uf714"
			slash "\uf715"
			sledding "\uf7cb"
			sleigh "\uf7cc"
			sliders-h "\uf1de"
			sliders-h-square "\uf3f0"
			sliders-v "\uf3f1"
			sliders-v-square "\uf3f2"
			smile "\uf118"
			smile-beam "\uf5b8"
			smile-plus "\uf5b9"
			smile-wink "\uf4da"
			smog "\uf75f"
			smoke "\uf760"
			smoking "\uf48d"
			smoking-ban "\uf54d"
			sms "\uf7cd"
			snake "\uf716"
			snooze "\uf880"
			snow-blowing "\uf761"
			snowboarding "\uf7ce"
			snowflake "\uf2dc"
			snowflakes "\uf7cf"
			snowman "\uf7d0"
			snowmobile "\uf7d1"
			snowplow "\uf7d2"
			soap "\ue06e"
			socks "\uf696"
			solar-panel "\uf5ba"
			solar-system "\ue02f"
			sort "\uf0dc"
			sort-alpha-down "\uf15d"
			sort-alpha-down-alt "\uf881"
			sort-alpha-up "\uf15e"
			sort-alpha-up-alt "\uf882"
			sort-alt "\uf883"
			sort-amount-down "\uf160"
			sort-amount-down-alt "\uf884"
			sort-amount-up "\uf161"
			sort-amount-up-alt "\uf885"
			sort-circle "\ue030"
			sort-circle-down "\ue031"
			sort-circle-up "\ue032"
			sort-down "\uf0dd"
			sort-numeric-down "\uf162"
			sort-numeric-down-alt "\uf886"
			sort-numeric-up "\uf163"
			sort-numeric-up-alt "\uf887"
			sort-shapes-down "\uf888"
			sort-shapes-down-alt "\uf889"
			sort-shapes-up "\uf88a"
			sort-shapes-up-alt "\uf88b"
			sort-size-down "\uf88c"
			sort-size-down-alt "\uf88d"
			sort-size-up "\uf88e"
			sort-size-up-alt "\uf88f"
			sort-up "\uf0de"
			soup "\uf823"
			spa "\uf5bb"
			space-shuttle "\uf197"
			space-station-moon "\ue033"
			space-station-moon-alt "\ue034"
			spade "\uf2f4"
			sparkles "\uf890"
			speaker "\uf8df"
			speakers "\uf8e0"
			spell-check "\uf891"
			spider "\uf717"
			spider-black-widow "\uf718"
			spider-web "\uf719"
			spinner "\uf110"
			spinner-third "\uf3f4"
			splotch "\uf5bc"
			spray-can "\uf5bd"
			sprinkler "\ue035"
			square "\uf0c8"
			square-full "\uf45c"
			square-root "\uf697"
			square-root-alt "\uf698"
			squirrel "\uf71a"
			staff "\uf71b"
			stamp "\uf5bf"
			star "\uf005"
			star-and-crescent "\uf699"
			star-christmas "\uf7d4"
			star-exclamation "\uf2f3"
			star-half "\uf089"
			star-half-alt "\uf5c0"
			star-of-david "\uf69a"
			star-of-life "\uf621"
			star-shooting "\ue036"
			starfighter "\ue037"
			starfighter-alt "\ue038"
			stars "\uf762"
			starship "\ue039"
			starship-freighter "\ue03a"
			steak "\uf824"
			steering-wheel "\uf622"
			step-backward "\uf048"
			step-forward "\uf051"
			stethoscope "\uf0f1"
			sticky-note "\uf249"
			stocking "\uf7d5"
			stomach "\uf623"
			stop "\uf04d"
			stop-circle "\uf28d"
			stopwatch "\uf2f2"
			stopwatch-20 "\ue06f"
			store "\uf54e"
			store-alt "\uf54f"
			store-alt-slash "\ue070"
			store-slash "\ue071"
			stream "\uf550"
			street-view "\uf21d"
			stretcher "\uf825"
			strikethrough "\uf0cc"
			stroopwafel "\uf551"
			subscript "\uf12c"
			subway "\uf239"
			suitcase "\uf0f2"
			suitcase-rolling "\uf5c1"
			sun "\uf185"
			sun-cloud "\uf763"
			sun-dust "\uf764"
			sun-haze "\uf765"
			sunglasses "\uf892"
			sunrise "\uf766"
			sunset "\uf767"
			superscript "\uf12b"
			surprise "\uf5c2"
			swatchbook "\uf5c3"
			swimmer "\uf5c4"
			swimming-pool "\uf5c5"
			sword "\uf71c"
			sword-laser "\ue03b"
			sword-laser-alt "\ue03c"
			swords "\uf71d"
			swords-laser "\ue03d"
			synagogue "\uf69b"
			sync "\uf021"
			sync-alt "\uf2f1"
			syringe "\uf48e"
			table "\uf0ce"
			table-tennis "\uf45d"
			tablet "\uf10a"
			tablet-alt "\uf3fa"
			tablet-android "\uf3fb"
			tablet-android-alt "\uf3fc"
			tablet-rugged "\uf48f"
			tablets "\uf490"
			tachometer "\uf0e4"
			tachometer-alt "\uf3fd"
			tachometer-alt-average "\uf624"
			tachometer-alt-fast "\uf625"
			tachometer-alt-fastest "\uf626"
			tachometer-alt-slow "\uf627"
			tachometer-alt-slowest "\uf628"
			tachometer-average "\uf629"
			tachometer-fast "\uf62a"
			tachometer-fastest "\uf62b"
			tachometer-slow "\uf62c"
			tachometer-slowest "\uf62d"
			taco "\uf826"
			tag "\uf02b"
			tags "\uf02c"
			tally "\uf69c"
			tanakh "\uf827"
			tape "\uf4db"
			tasks "\uf0ae"
			tasks-alt "\uf828"
			taxi "\uf1ba"
			teeth "\uf62e"
			teeth-open "\uf62f"
			telescope "\ue03e"
			temperature-down "\ue03f"
			temperature-frigid "\uf768"
			temperature-high "\uf769"
			temperature-hot "\uf76a"
			temperature-low "\uf76b"
			temperature-up "\ue040"
			tenge "\uf7d7"
			tennis-ball "\uf45e"
			terminal "\uf120"
			text "\uf893"
			text-height "\uf034"
			text-size "\uf894"
			text-width "\uf035"
			th "\uf00a"
			th-large "\uf009"
			th-list "\uf00b"
			theater-masks "\uf630"
			thermometer "\uf491"
			thermometer-empty "\uf2cb"
			thermometer-full "\uf2c7"
			thermometer-half "\uf2c9"
			thermometer-quarter "\uf2ca"
			thermometer-three-quarters "\uf2c8"
			theta "\uf69e"
			thumbs-down "\uf165"
			thumbs-up "\uf164"
			thumbtack "\uf08d"
			thunderstorm "\uf76c"
			thunderstorm-moon "\uf76d"
			thunderstorm-sun "\uf76e"
			ticket "\uf145"
			ticket-alt "\uf3ff"
			tilde "\uf69f"
			times "\uf00d"
			times-circle "\uf057"
			times-hexagon "\uf2ee"
			times-octagon "\uf2f0"
			times-square "\uf2d3"
			tint "\uf043"
			tint-slash "\uf5c7"
			tire "\uf631"
			tire-flat "\uf632"
			tire-pressure-warning "\uf633"
			tire-rugged "\uf634"
			tired "\uf5c8"
			toggle-off "\uf204"
			toggle-on "\uf205"
			toilet "\uf7d8"
			toilet-paper "\uf71e"
			toilet-paper-alt "\uf71f"
			toilet-paper-slash "\ue072"
			tombstone "\uf720"
			tombstone-alt "\uf721"
			toolbox "\uf552"
			tools "\uf7d9"
			tooth "\uf5c9"
			toothbrush "\uf635"
			torah "\uf6a0"
			torii-gate "\uf6a1"
			tornado "\uf76f"
			tractor "\uf722"
			trademark "\uf25c"
			traffic-cone "\uf636"
			traffic-light "\uf637"
			traffic-light-go "\uf638"
			traffic-light-slow "\uf639"
			traffic-light-stop "\uf63a"
			trailer "\ue041"
			train "\uf238"
			tram "\uf7da"
			transgender "\uf224"
			transgender-alt "\uf225"
			transporter "\ue042"
			transporter-1 "\ue043"
			transporter-2 "\ue044"
			transporter-3 "\ue045"
			transporter-empty "\ue046"
			trash "\uf1f8"
			trash-alt "\uf2ed"
			trash-restore "\uf829"
			trash-restore-alt "\uf82a"
			trash-undo "\uf895"
			trash-undo-alt "\uf896"
			treasure-chest "\uf723"
			tree "\uf1bb"
			tree-alt "\uf400"
			tree-christmas "\uf7db"
			tree-decorated "\uf7dc"
			tree-large "\uf7dd"
			tree-palm "\uf82b"
			trees "\uf724"
			triangle "\uf2ec"
			triangle-music "\uf8e2"
			trophy "\uf091"
			trophy-alt "\uf2eb"
			truck "\uf0d1"
			truck-container "\uf4dc"
			truck-couch "\uf4dd"
			truck-loading "\uf4de"
			truck-monster "\uf63b"
			truck-moving "\uf4df"
			truck-pickup "\uf63c"
			truck-plow "\uf7de"
			truck-ramp "\uf4e0"
			trumpet "\uf8e3"
			tshirt "\uf553"
			tty "\uf1e4"
			turkey "\uf725"
			turntable "\uf8e4"
			turtle "\uf726"
			tv "\uf26c"
			tv-alt "\uf8e5"
			tv-music "\uf8e6"
			tv-retro "\uf401"
			typewriter "\uf8e7"
			ufo "\ue047"
			ufo-beam "\ue048"
			umbrella "\uf0e9"
			umbrella-beach "\uf5ca"
			underline "\uf0cd"
			undo "\uf0e2"
			undo-alt "\uf2ea"
			unicorn "\uf727"
			union "\uf6a2"
			universal-access "\uf29a"
			university "\uf19c"
			unlink "\uf127"
			unlock "\uf09c"
			unlock-alt "\uf13e"
			upload "\uf093"
			usb-drive "\uf8e9"
			usd-circle "\uf2e8"
			usd-square "\uf2e9"
			user "\uf007"
			user-alien "\ue04a"
			user-alt "\uf406"
			user-alt-slash "\uf4fa"
			user-astronaut "\uf4fb"
			user-chart "\uf6a3"
			user-check "\uf4fc"
			user-circle "\uf2bd"
			user-clock "\uf4fd"
			user-cog "\uf4fe"
			user-cowboy "\uf8ea"
			user-crown "\uf6a4"
			user-edit "\uf4ff"
			user-friends "\uf500"
			user-graduate "\uf501"
			user-hard-hat "\uf82c"
			user-headset "\uf82d"
			user-injured "\uf728"
			user-lock "\uf502"
			user-md "\uf0f0"
			user-md-chat "\uf82e"
			user-minus "\uf503"
			user-music "\uf8eb"
			user-ninja "\uf504"
			user-nurse "\uf82f"
			user-plus "\uf234"
			user-robot "\ue04b"
			user-secret "\uf21b"
			user-shield "\uf505"
			user-slash "\uf506"
			user-tag "\uf507"
			user-tie "\uf508"
			user-times "\uf235"
			user-unlock "\ue058"
			user-visor "\ue04c"
			users "\uf0c0"
			users-class "\uf63d"
			users-cog "\uf509"
			users-crown "\uf6a5"
			users-medical "\uf830"
			users-slash "\ue073"
			utensil-fork "\uf2e3"
			utensil-knife "\uf2e4"
			utensil-spoon "\uf2e5"
			utensils "\uf2e7"
			utensils-alt "\uf2e6"
			vacuum "\ue04d"
			vacuum-robot "\ue04e"
			value-absolute "\uf6a6"
			vector-square "\uf5cb"
			venus "\uf221"
			venus-double "\uf226"
			venus-mars "\uf228"
			vest "\ue085"
			vest-patches "\ue086"
			vhs "\uf8ec"
			vial "\uf492"
			vials "\uf493"
			video "\uf03d"
			video-plus "\uf4e1"
			video-slash "\uf4e2"
			vihara "\uf6a7"
			violin "\uf8ed"
			virus "\ue074"
			virus-slash "\ue075"
			viruses "\ue076"
			voicemail "\uf897"
			volcano "\uf770"
			volleyball-ball "\uf45f"
			volume "\uf6a8"
			volume-down "\uf027"
			volume-mute "\uf6a9"
			volume-off "\uf026"
			volume-slash "\uf2e2"
			volume-up "\uf028"
			vote-nay "\uf771"
			vote-yea "\uf772"
			vr-cardboard "\uf729"
			wagon-covered "\uf8ee"
			walker "\uf831"
			walkie-talkie "\uf8ef"
			walking "\uf554"
			wallet "\uf555"
			wand "\uf72a"
			wand-magic "\uf72b"
			warehouse "\uf494"
			warehouse-alt "\uf495"
			washer "\uf898"
			watch "\uf2e1"
			watch-calculator "\uf8f0"
			watch-fitness "\uf63e"
			water "\uf773"
			water-lower "\uf774"
			water-rise "\uf775"
			wave-sine "\uf899"
			wave-square "\uf83e"
			wave-triangle "\uf89a"
			waveform "\uf8f1"
			waveform-path "\uf8f2"
			webcam "\uf832"
			webcam-slash "\uf833"
			weight "\uf496"
			weight-hanging "\uf5cd"
			whale "\uf72c"
			wheat "\uf72d"
			wheelchair "\uf193"
			whistle "\uf460"
			wifi "\uf1eb"
			wifi-1 "\uf6aa"
			wifi-2 "\uf6ab"
			wifi-slash "\uf6ac"
			wind "\uf72e"
			wind-turbine "\uf89b"
			wind-warning "\uf776"
			window "\uf40e"
			window-alt "\uf40f"
			window-close "\uf410"
			window-frame "\ue04f"
			window-frame-open "\ue050"
			window-maximize "\uf2d0"
			window-minimize "\uf2d1"
			window-restore "\uf2d2"
			windsock "\uf777"
			wine-bottle "\uf72f"
			wine-glass "\uf4e3"
			wine-glass-alt "\uf5ce"
			won-sign "\uf159"
			wreath "\uf7e2"
			wrench "\uf0ad"
			x-ray "\uf497"
			yen-sign "\uf157"
			yin-yang "\uf6ad"
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
					
					set rescale_images_x_ratio [expr {$screen_size_height / $::dui::_base_screen_height}]
					set rescale_images_y_ratio [expr {$screen_size_width / $::dui::_base_screen_width}]
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
				return $is_rethemed
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
					foreach page $pages {
						if { "p:$page" ni $item_tags } {
							lappend item_tags "p:$page"
						}
					}
					
					msg -DEBUG [namespace current] add_items "with tag(s) '$item_tags' to page(s) '$pages'"
					$can itemconfigure $tag -tags $item_tags
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
		variable longpress_threshold 200
	
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
					-width $arc_width -tags [list ${main_tag}-nw {*}$tags] -start 90 -disabledoutline $disabled -state "hidden"]
			}
			if { $radius2 > 0 } {
				lappend ids [$can create arc [expr {$x1-$radius2-1}] $y0 $x1 [expr {$y0+$radius2+1}] -style arc -outline $colour \
					-width $arc_width -tags [list ${main_tag}-ne {*}$tags] -start 0 -disabledoutline $disabled -state "hidden"]
			}
			if { $radius3 > 0 } {
				lappend ids [$can create arc [expr {$x1-$radius3-1.0}] $y1 $x1 [expr {$y1-$radius3-1.0}] -style arc -outline $colour \
					-width $arc_width -tags [list ${main_tag}-se {*}$tags] -start -90 -disabledoutline $disabled -state "hidden"]
			}			
			if { $radius4 > 0 } {
				lappend ids [$can create arc $x0 [expr {$y1-$radius4-1.0}] [expr {$x0+$radius4+1.0}] $y1 -style arc -outline $colour \
					-width $arc_width -tags [list ${main_tag}-sw {*}$tags] -start 180 -disabledoutline $disabled -state "hidden"]
			}

			# Top line
			lappend ids [$can create line [expr {$x0+$radius1/2.0-1.0}] $y0 [expr {$x1-$radius2/2.0+1.0}] $y0 -fill $colour \
				-width $width -tags [list ${main_tag}-n {*}$tags] -disabledfill $disabled -state "hidden"]
			# Right line
			lappend ids [$can create line $x1 [expr {$y0+$radius2/2.0-1.0}] $x1 [expr {$y1-$radius3/2.0+1.0}] -fill $colour \
				-width $width -tags [list ${main_tag}-e {*}$tags] -disabledfill $disabled -state "hidden"]
			# Bottom line
			lappend ids [$can create line [expr {$x0+$radius4/2.0-1.0}] $y1 [expr {$x1-$radius3/2.0+1.0}] $y1 -fill $colour \
				-width $width -tags [list ${main_tag}-s {*}$tags] -disabledfill $disabled -state "hidden"]
			# Left line
			lappend ids [$can create line $x0 [expr {$y0+$radius1/2.0-1.0}] $x0 [expr {$y1-$radius4/2.0+1.0}] -fill $colour \
				-width $width -tags [list ${main_tag}-w {*}$tags] -disabledfill $disabled -state "hidden"]
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
		
		proc longpress_press { widget_name longpress_command } {
			variable longpress_threshold
			set ::dui::item::press_events($widget_name,press) [clock milliseconds]
			after $longpress_threshold [subst {
				if { \[info exists ::dui::item::press_events($widget_name,press)\] } {
					unset -nocomplain ::dui::item::press_events($widget_name,press)
					uplevel #0 $longpress_command
				}
			}]
		}
		
		proc longpress_unpress { widget_name {press_command {}} } {
			variable press_events
			variable longpress_threshold
			if { [info exists press_events($widget_name,press)] } {
				if { ([clock milliseconds]-$press_events($widget_name,press)) <= $longpress_threshold } {
					unset -nocomplain ::dui::item::press_events($widget_name,press)
					if { $press_command ne {} } {
						uplevel #0 $press_command
					}
				} else {
					unset -nocomplain ::dui::item::press_events($widget_name,press)
				}
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
		proc dtoggle_draw { page main_tag varname x0 y0 x1 y1 sliderwidth outline_width foreground selectedforeground 
				background selectedbackground outline selectedoutline args } {
			set can [dui::canvas]
			set curval [subst \$$varname]
			
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
		proc dbutton { pages x y args } { 			
			set debug_buttons [dui cget debug_buttons]
			set can [dui canvas]
			set ns [dui page get_namespace $pages]
			set first_page [lindex $pages 0]
			
			set cmd [dui::args::get_option -command {} 1]
			set longpress_cmd [dui::args::get_option -longpress_cmd {} 1]
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
			while { [subst \$label$suffix] ne "" || [subst \$labelvar$suffix] ne "" } {
				set "label${suffix}_tags" [list "${main_tag}-lbl$suffix" {*}[lrange $tags 1 end]]	
				set "label${suffix}_args" [dui::args::extract_prefixed "-label${suffix}_"]
				
				foreach aspect [dui aspect list -type [list "${aspect_type}_label$suffix" dtext] -style $style] {
					dui::args::add_option_if_not_exists -$aspect [dui aspect get "${aspect_type}_label$suffix" $aspect \
						-style $style -default {} -default_type dtext] "label${suffix}_args"
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
					set disabledfill [dui::args::get_option -disabledfill [dui aspect get dbutton disabledfill -style $style]]
					set radius [dui::args::get_option -radius [dui aspect get dbutton radius -style $style -default 40]]
					
					set ids [dui::item::rounded_rectangle $rx $ry $rx1 $ry1 $radius $fill $disabledfill $button_tags]
				} elseif { $shape eq "outline" } {
					set outline [dui::args::get_option -outline [dui aspect get dbutton outline -style $style]]
					set disabledoutline [dui::args::get_option -disabledoutline [dui aspect get dbutton disabledoutline -style $style]]
					set arc_offset [dui::args::get_option -arc_offset [dui aspect get dbutton arc_offset -style $style -default 50]]
					set width [dui::args::get_option -width [dui aspect get dbutton width -style $style -default 3]]
					set outline_tags [list ${main_tag}-out {*}[lrange $tags 1 end]]
					
					set ids [dui::item::rounded_rectangle_outline $rx $ry $rx1 $ry1 $arc_offset $outline $disabledoutline \
						$width $button_tags]
				} elseif { $shape eq "round_outline" } {
					set fill [dui::args::get_option -fill [dui aspect get dbutton fill -style $style]]
					set disabledfill [dui::args::get_option -disabledfill [dui aspect get dbutton disabledfill -style $style]]
					set radius [dui::args::get_option -radius [dui aspect get dbutton radius -style $style -default 40]]
					set outline [dui::args::get_option -outline [dui aspect get dbutton outline -style $style]]
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
			if { $cmd eq "" } {
				msg -WARN [namespace current] dbutton "'$main_tag' in page(s) '$pages' does not have a command"
				dump_stack

				if { $longpress_cmd ne "" } {
					$can bind $id [dui::platform::button_press] [list ::dui::item::longpress_press $id $longpress_cmd]
					$can bind $id [dui::platform::button_unpress] [list ::dui::item::longpress_unpress $id]
				}
			} elseif { $longpress_cmd eq "" } {
				$can bind $id [dui::platform::button_press] $cmd
			} else {
				$can bind $id [dui::platform::button_press] [list ::dui::item::longpress_press $id $longpress_cmd]
				$can bind $id [dui::platform::button_unpress] [list ::dui::item::longpress_unpress $id $cmd]
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

			set draw_cmd [::list ::dui::item::dtoggle_draw [lindex $pages 0] $main_tag $var $x $y $x1 $y1 \
				$sliderwidth $outline_width $foreground $selectedforeground $background $selectedbackground \
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
			-symbol chevron-double-left -labelvariable {-[format [%NS::value_format] $%NS::data(bigincrement)]} \
			-command { %NS::incr_value -$%NS::data(bigincrement) } 

		dui add dbutton $page [expr {$x-$hoffset-$bspace*3}] $y -tags to_min -style dne_clicker \
			-symbol arrow-to-left -labelvariable {[format [%NS::value_format] $%NS::data(min)]} \
			-command { %NS::set_value -$%NS::data(min) } 

		# Increment value arrows
		dui add dbutton $page [expr {$x+$hoffset+$bspace}] $y -tags small_incr -style dne_clicker \
			-symbol chevron-right -labelvariable {+[format [%NS::value_format] $%NS::data(smallincrement)]} \
			-command { %NS::incr_value $%NS::data(smallincrement) }
			
		dui add dbutton $page [expr {$x+$hoffset+$bspace*2}] $y -tags big_incr -style dne_clicker \
			-symbol chevron-double-right -labelvariable {+[format [%NS::value_format] $%NS::data(bigincrement)]} \
			-command { %NS::incr_value $%NS::data(bigincrement) } 
	
		dui add dbutton $page [expr {$x+$hoffset+$bspace*3}] $y -tags to_max -style dne_clicker \
			-symbol arrow-to-right -labelvariable {[format [%NS::value_format] $%NS::data(max)]} \
			-command { %NS::set_value $%NS::data(max) } 
		
		# Erase button
		#		dui add symbol $page $x_left_center [expr {$y+140}] eraser -size medium -has_button 1 \
		#			-button_cmd { set ::dui::pages::dui_number_editor::data(value) "" }
		
#		# Previous values listbox
		dui add listbox $page 450 780 -tags previous_values -canvas_width 350 -canvas_height 550 -yscrollbar 1 \
			-label [translate "Previous values"] -label_style section_font_size -label_pos {450 700} -label_anchor nw 
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
					-label "$num" -command [list %NS::enter_character $num] 
				
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
		}
		
		if { $data(num_variable) ne "" } {
			set $data(num_variable) $data(value)
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
