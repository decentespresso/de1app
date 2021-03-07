# ##### TEMPORAL DEV COMMENTS ####
# THINGS THIS DOES:
#	- Remove duplication & hardcoded values
#	- Set default aspect values by theme. User only has to defined options that differ from the default.
#		Also allow to define item styles within a theme, so all style options are applied to those items that 
#		have that -style.
#	- Allow users to define the name/tag of canvas items and widgets, so they can be easily retrieved.
#	- Fontawesome symbols by name
#	- Add "widget combos" as a unit with a single command (e.g. button+label+clickable_button, or 
#		listbox+label+scrollbar) and operate with them as a unit too for showing/hiding, enabling/disabling, etc.
#	- Allow to pass arguments to pages, so they can be loaded/started/shown with a set of parameters. This allows 
#		more easily apply the same page to different data/object, as the data reference to be used can be passed
#		as a parameter (instead of always using global variables).

# TODOs: CHANGES TO DECOUPLE THIS LAYER AS A TOTALLY INDEPENDENT COMPONENT
#	- Global variables that must change to the gui namespace variables:
#		::de1(current_context) -> ::gui::page::current_page
#		::existing_labels array (one item per page)
#		::all_labels (list with all labels, sorted) Can't this be get from the canvas tags???)
#		screensaver integrated in the gui or not? -> An action on the "saver" page can make it work
#		Idle/stress test in page display_change ?? -> Add a way to add before_show/after_show/hide actions
#		::delayed_image_load system
#	- Global utility functions that are used here:
#		ifexists

package provide de1_dgui 1.0

package require de1_logging 1.0

namespace eval ::gui {
	namespace export theme aspect symbol page item add_text add_variable add_button add_entry add_listbox add_widget \
		hide_android_keyboard
	namespace ensemble create

	# Set to 1 while debugging to see the "clickable" areas. Also may need to redefine aspect 
	#	'<theme>.button.debug_outline' so it's visible against the theme background.
	variable debug_buttons 0
	
	# Set to 1 to default to create a namespace ::gui::page::<page_name> for each new created page
	variable create_page_namespaces 0
	
	### THEME SUB-ENSEMBLE ###
	# Themes are just names that serve as groupings for sets of aspect variables. They define a "visual identity"
	#	by setting default option values for widgets (colors, fonts, backgrounds, etc.), which are called "aspects"
	#	in this framework.
	namespace eval theme {
		namespace export add exists list current
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

		proc exists { theme } {
			variable themes
			return [expr { [lsearch $themes $theme] > -1 } ]
		}
		
		proc list {} {
			variable themes
			return $themes
		}
		
		# Without arguments, return the current theme. With an argument, changes the current theme, adding it to 
		#	the list if it doesn't exist (with a NOTICE on the log).
		proc current { {current_theme {}} } {
			variable current
			if { $current_theme eq "" } {
				return $current
			} else {
				if { ![exists $current_theme] } {
					msg -NOTICE [namespace current] "current theme '$current_theme' not previously added"
					add $current_theme
				}
				::set current $current_theme
			}
		}
	}
	
	### ASPECT SUB-ENSEMBLE ###
	# Aspects are the variables that define the default options for each item/widget in a theme.
	# They are stored with labels that use the syntax "<theme>.<widget/type>.<option>?.<style>?".
	# The theme is always specified globally using 'gui theme current <theme_name>', and cannot be modified for 
	#	individual items/widgets.
	# Whenever an item/widget is added to the canvas using the 'gui add_*' commands, its default options are
	#	taken from the theme aspects, unless they are overridden explicitly in the 'add_*' call.
	# Different styles can be added to any item/widget type, by adding aspects with a ".<style>" suffix.
	# If the 'add_*' call includes a -style option, each default aspect option will be taken from the style. If that
	#	option is not available for the style, the non-style option version will be used. 
	# If an aspect is not defined for the current theme, the aspect from the 'default' theme will be used,
	#	or a default can be provided directly by client code using the -default tag of the 'gui aspect get' command.  
	namespace eval aspect {
		namespace export add exists get list
		namespace ensemble create
		
		variable aspects
		# TBD default.button_label.activefill needed? On buttons the invisible rectangle "hides" the text and
		#	it seems they never become active.
		array set aspects {
			default.page.bg_img {}
			default.page.bg_color "#edecfa"
			
			default.font.family Helv
			default.font.size 12
			
			default.text.font Helv
			default.text.font_size 12
			default.text.fill "#7f879a"
			default.text.activefill orange
			default.text.disabledfill "#ddd"
			default.text.anchor nw
			default.text.justify left
			
			default.text.fill.remark orange
			default.text.fill.error red
		
			default.entry.relief sunken
			default.entry.bg "#ffffff"
			
			default.button.font Helv
			default.button.font_size 12
			default.button.debug_outline black
			default.button.fill "#c0c5e3"
			default.button.activefill "#c0c5e3"
			default.button.disabledfill "#ddd"
			default.button.outline "white"
			default.button.disabledoutline "pink"
			default.button.activeoutline "orange"
			default.button.width 0
			default.button.radius 40
			default.button.arc_offset 50
			
			default.button_label.pos {0.9 0.1}
			default.button_label.anchor ne
			default.button_label.justify right
			default.button_label.fill "#ffffff"
			default.button_label.activefill "#ffffff"
			default.button_label.disabledfill "#ffffff"

			default.entry.relief sunken
			default.entry.bg pink
			default.entry.width 5
			
			default.entry.relief.special flat
			default.entry.bg.special yellow
			default.entry.width.special 1
			
		}
		
		# Named options:
		# 	-theme theme_name to add to a theme different than the current one
		# 	-style style_name to add all aspects to that style.
		proc add { args } {
			variable aspects
			set theme [gui::args::get_option -theme [gui theme current] 1]
			set style [gui::args::get_option -style "" 1]
			
			for { set i 0 } { $i < [llength $args] } { incr i 2 } {
				set var "${theme}.[lindex $args $i]"
				if { $style ne "" && [string range $var end-[string length $style] end] ne ".$style" } {
					append var ".$style"
				}
				set value [lindex $args [expr {$i+1}]]
				if { [info exists aspects($var)] } {
					if { $aspects($var) eq $value } {
						msg -NOTICE [namespace current] "aspect '$var' already exists, new value is equal to old"
					} else {
						msg -NOTICE [namespace current] "aspect '$var' already exists, old value='$aspects($var)', new value='$value'"
					}
				}
				set aspects($var) $value
			}
		}
		
		# Named options:
		#	-theme theme_name to check for a theme different than the current one
		#	-style style_name to query only that style
		proc exists { aspect args } {
			variable aspects
			set theme [gui::args::get_option -theme [gui theme current]]
			set style [gui::args::get_option -style ""]
			set aspect_name "${theme}.$aspect"
			if { $style ne "" } {
				append aspect_name .$style
			}
			return [info exists aspects($aspect_name)]
		}
		
		# Named options:
		# 	-theme theme_name to get for a theme different than the current one
		#	-style style_name to get only that style. If the aspect is not found in that style, the non-styled
		#		value of the aspect is returned instead, if available
		#	-default value to return in case the aspect is undefined
		proc get { aspect args } {
			variable aspects
			set theme [gui::args::get_option -theme [gui theme current]]
			set style [gui::args::get_option -style ""]
			set default [gui::args::get_option -default ""]

			if { $style ne "" && [info exists aspects($theme.$aspect.$style)] } {
				return $aspects($theme.$aspect.$style)
			} elseif { [info exists aspects($theme.$aspect)] } {
				return $aspects($theme.$aspect)
			} elseif { $default ne "" } {
				return $default
			} elseif { $style ne "" && [info exists aspects(default.$aspect.$style)] } {
				return $aspects(default.$aspect.$style)
			} elseif { [info exists aspects(default.$aspect)] } {
				return $aspects(default.$aspect)
			} else {
				msg -NOTICE [namespace current] "aspect '$theme.$aspect' not found and no alternative available"
				return ""
			}
		}
		
		# Named options:
		# 	-all_themes 1 to return aspects for all themes
		# 	-theme theme_name to return for a theme different than the current one. If not specified and -all_themes=0
		#		(the default), returns aspects for the currently active theme only.
		#	-type to return only the aspects for that type (e.g. "entry", "text", etc.)
		# 	-style to return only the aspects for that style 
		# If the returned values are for a single theme, the theme name prefix is not included, but if -all_themes is 1,
		#	returns the full aspect name including the theme prefix.
		proc list { args } {
			variable aspects
			if { [string is true [gui::args::get_option -all_themes 0]] } {
				set theme_len 0
				set pattern {^[0-9a-zA-Z]+\.}
			} else {
				set theme [gui::args::get_option -theme [gui theme current]]
				set theme_len [expr {[string length $theme]+1}]
				set pattern "^$theme."
			}
			
			set type [gui::args::get_option -type ""]
			if { $type eq "" } {
				append pattern {[0-9a-zA-Z]+\.}
			} else {
				append pattern "$type."
			}
			
			set style [gui::args::get_option -style ""]
			if { $style eq "" } {
				append pattern {[0-9a-zA-Z]+$}
			} else {
				append pattern "\[0-9a-zA-Z\]+.$style\$"
			}
			
			#msg [namespace current] "list, pattern='$pattern'"
			set aspect_names [array names aspects -regexp $pattern]
			#msg [namespace current] "list, aspect_names='$aspect_names'"
			if { $theme_len == 0 } {
				set result $aspect_names
			} else { 
				foreach a $aspect_names {
					lappend result [string range $a $theme_len end]
				}
			}
			
			if { $style ne "" } {
				set style_len [expr {[string length $style]+1}]
				foreach a $result {
					lappend new_result [string range $a 0 end-$style_len]
				}
				set result $new_result
			}
			#msg [namespace current] "list, result='$result'"
			return $result
		}
	}	
	
	### SYMBOL SUB-ENSEMBLE ###
	# This set of commands allow defining Fontawesome Regular symbols by name, then use them in the code by their name.
	# To find out the unicode values of the available symbols, see https://fontawesome.com/icons?d=gallery
	namespace eval symbol {
		namespace export add get exists
		namespace ensemble create
				
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
			eraser "\uf12d"
			eye "\uf06e"
		}

		# Used to map booleans to their checkbox representation (square/square_check) in fontawesome.
		variable checkbox_symbols_map {"\uf0c8" "\uf14a"}

		# Define Fontawesome symbols by name. If a symbol name is already defined and the value differs, it is NOT 
		#	redefined, and a warning added to the log.		
		proc add { args } {
			variable symbols
			
			set n [expr {[llength $args]-1}]
			for { set i 0 } { $i < $n } { incr i 2 } {
				set sn [lindex $args $i]
				set sv [lindex $args [expr {$i+1}]]
				set idx [lsearch [array names symbols] $sn]
				if { $idx == -1 } {
					msg -INFO [namespace current] "add symbol $sn='$sv'"
					set symbols($sn) $sv
				} elseif { $symbols($sn) ne $sv } {
					msg -WARN [namespace current ] "symbol '$sn' already defined with a different value"
				}
			}
		}
		
		# If undefined, warns in the log and returns the provided symbol name.
		proc get { symbol } {
			variable symbols
			if { [info exists symbols($symbol)] } {
				return $symbols($symbol)
			} else {
				msg -WARN [namespace current] "symbol '$symbol' not recognized"
				return $symbol
			}
		}
			
		proc exists { symbol } {
			variable symbols
			return [info exists symbols($symbol)]
		}
	}

	### FONTS SUB-ENSEMBLE ###
	namespace eval font {
		namespace export add get exists
		namespace ensemble create

		proc load {} {
			
		}
		
		proc get { } {
			
		}
		
		proc width {untranslated_txt font} {
			set x [font measure $font -displayof .can [translate $untranslated_txt]]
			#if {$::android != 1} {    
				# not sure why font measurements are half off on osx but not on android
				return [expr {2 * $x}]
			#}
			return $x
		}
		
	}
	
	### ARGS SUB-ENSEMBLE ###
	# A set of tools to manipulate named options in the 'args' argument to gui commands. 
	# These are heavily used in the 'add' commands that create widgets, with the general objectives of:
	#	1) pass-through any aspect parameter explicitly defined by the user to the main widget creation command,
	#		or otherwise use the theme and style default values. 	
	#	2) extract the options that won't be passed through to the main widget creation command, but to other one,
	#		like aspect values passed to the label creation command in add_button (-label_font, -label_fill...)
	# These namespace commands are not exported, should normally only be used inside the gui namespace, where
	#	they're called using qualified names.
	namespace eval args {
		# Adds a named option "-option_name option_value" to a named argument list if the option doesn't exist in the list.
		# Returns the option value.
		proc add_option_if_not_exists { option_name option_value {proc_args args} } {
			upvar $proc_args largs	
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
		proc remove_option { option_name {proc_args args} } {
			upvar $proc_args largs
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
		
		# Returns 1 if the named arguments list has a named option "-option_name".
		proc has_option { option_name {proc_args args} } {
			upvar $proc_args largs
			if { [string range $option_name 0 0] ne "-" } { set option_name "-$option_name" }	
			set n [llength $largs]
			set option_idx [lsearch $largs $option_name]
			return [expr {$option_idx > -1 && $option_idx < [expr {$n-1}]}]
		}
		
		# Returns the value of the named option in the named argument list
		proc get_option { option_name {default_value {}} {rm_option 0} {proc_args args} } {
			upvar $proc_args largs	
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
		proc extract_prefixed { prefix {proc_args args} } {
			upvar $proc_args largs
			set new_args {}
			set n [expr {[string length $prefix]-1}]
			set i 0 
			while { $i < [llength $largs] } { 
				if { [string range [lindex $largs $i] 0 $n] eq $prefix } {
					lappend new_args "-[string range [lindex $largs $i] 7 end]"
					lappend new_args [lindex $largs [expr {$i+1}]]
					set largs [lreplace $largs $i [expr {$i+1}]]
				} else {
					incr i 2
				}
			}
			return $new_args
		}
		
		
		# For each of the requested aspects, modifies the args with the default option value for the current 
		#	theme and optional style to the, unless it is already available in the args.
		# Also removes the -style tag.
		# DOES NOT WORK, DOESN'T RECOGNIZE $largs in the second line
		proc complete_with_theme_aspects { type aspects {proc_args args } } {
			upvar $proc_args largs
			set style [get_option -style "" 1 $largs]
			foreach aspect $aspects {
				args::add_option_if_not_exists -$aspect [gui aspect get "$type.$aspect" -style $style] $largs 
			}
		}
	}

	### PAGES SUB-ENSEMBLE ###
	# AT THE MOMENT ONLY page_add SHOULD BE USED AS OTHERS BREAK BACKWARDS COMPATIBILITY #
	namespace eval page {
#		namespace export add set_next show_when_off show back_to_previous
		namespace export *
		namespace ensemble create

		# Tcl code to run for specific pages when their 'before_show', 'after_show' or 'hide' events take place.
		variable actions
		array set actions {}
		
		variable nextpage
		array set nextpage {}
		variable exit_app_on_sleep 0
		
		# 'page add' accommodates both simple-style skin/plugin pages using the same background image or colored rectangle 
		#	for all pages (which can be defined in the theme), or Insight-style customized with a background image per-page,
		#	by defining -bg_img
		#
		# Named options:
		#  -style to apply the default aspects of the provided style
		#  -bg_img background image file to use
		#  -bg_color background color to use, in case no background image is defined
		#  -skin passed to ::add_de1_page if necessary
		#  -create_ns will create a page namespace ::gui::page::<page_name>
		proc add { pages args } {
			array set opts $args
				
			set style [gui::args::get_option -style "" 1]
			set bg_img [gui::args::get_option -bg_img [gui aspect get page.bg_img -style $style]]
			if { $bg_img ne "" } {
				::add_de1_page $pages $bg_img [gui::args::get_option -skin ""] 
				#add_de1_image $page 0 0 $bg_img
			} else {
				set bg_color [gui::args::get_option -bg_color [gui aspect get page.bg_color -style $style]]
				if { $bg_color ne "" } {
					foreach c $pages {
						#set tag "${c}.background"
						.can create rect 0 0 [rescale_x_skin 2560] [rescale_y_skin 1600] -fill $bg_color -width 0 \
							-tag [list pages $c] -state "hidden"
						#item add_to_pages $c $tag
					}
				}
			}
			
			if { [string is true [gui::args::get_option -create_ns ::gui::create_page_namespaces 0]] } {
				foreach page $pages {
					if { [is_namespace $page] } {
						namespace eval ::gui::page::$page {
							namespace export *
							namespace ensemble create
						}				
					} else {
						namespace eval ::gui::page::$page {
							namespace export *
							namespace ensemble create
							
							variable items
							array set items {}
							
							variable data
							array set data {}
						}
					}
					
#					namespace eval ::gui::page {
#						namespace export $page
#					}
				}
			}
		}
		
		proc is_namespace { page } {
			return [namespace exists "::gui::page::$page" ]
			#return [expr {[string range $page 0 1] eq "::" && [info exists ${page}::widgets]}]
		}
			
		proc set_next { machinepage guipage } {
			variable nextpage
			#msg "set_next_page $machinepage $guipage"
			set key "machine:$machinepage"
			set nextpage($key) $guipage
		}

		proc show_when_off { page_to_show } {
			set_next off $page_to_show
			show $page_to_show
		}
				
		proc show { page_to_show } {
			page_display_change $::de1(current_context) $page_to_show
		}
		
		proc display_change { page_to_hide page_to_show } {
			variable nextpage
			variable exit_app_on_sleep
			delay_screen_saver
		
			set key "machine:$page_to_show"
			if {[ifexists nextpage($key)] != ""} {
				# there are different possible tabs to display for different states (such as preheat-cup vs hot water)
				set page_to_show $::nextpage($key)
			}
		
			if {$::de1(current_context) == $page_to_show} {
				#jbtemp
				#msg "page_display_change returning because ::de1(current_context) == $page_to_show"
				return 
			}
		
			msg [namespace current] "page_display_change $page_to_hide->$page_to_show"
				
			if {$page_to_hide == "sleep" && $page_to_show == "off"} {
				msg [namespace current] "discarding intermediate sleep/off state msg"
				return 
			} elseif {$page_to_show == "saver"} {
				if {[ifexists exit_app_on_sleep] == 1} {
					get_set_tablet_brightness 0
					close_all_ble_and_exit
				}
			}
		
			# signal the page change with a sound
			say "" $::settings(sound_button_out)
			#msg "page_display_change $page_to_show"
			#set start [clock milliseconds]
		
			# set the brightness in one place
			if {$page_to_show == "saver" } {
				if {$::settings(screen_saver_change_interval) == 0} {
					# black screen saver
					display_brightness 0
				} else {
					display_brightness $::settings(saver_brightness)
				}
				borg systemui $::android_full_screen_flags  
			} else {
				display_brightness $::settings(app_brightness)
			}
		
		
			if {$::settings(stress_test) == 1 && $::de1_num_state($::de1(state)) == "Idle" && [info exists ::idle_next_step] == 1} {
		
				msg "Doing next stress test step: '$::idle_next_step '"
				set todo $::idle_next_step 
				unset -nocomplain ::idle_next_step 
				eval $todo
			}
		
		
			#global current_context
			set ::de1(current_context) $page_to_show
		
			#puts "page_display_change hide:$page_to_hide show:$page_to_show"
			catch {
				.can itemconfigure $page_to_hide -state hidden
			}
			#.can itemconfigure [list "pages" "splash" "saver"] -state hidden
		
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
							.can itemconfigure $page -image $page_to_show -state hidden					
						}]
		
						if {$errcode != 0} {
							catch {
								msg ".can itemconfigure page_to_show ($page/$page_to_show) error: $::errorInfo"
							}
						}
		
						unset -nocomplain ::delayed_image_load($page)
					}
				}
		
			}
		
			set errcode [catch {
				.can itemconfigure $page_to_show -state normal
			}]
		
			if {$errcode != 0} {
				catch {
					msg ".can itemconfigure page_to_show error: $::errorInfo"
				}
		
			} 
		
			set these_labels [ifexists ::existing_labels($page_to_show)]
			#msg "these_labels: $these_labels"
		
			if {[info exists ::all_labels] != 1} {
				set ::all_labels {}
				foreach {page labels} [array get ::existing_labels]  {
					set ::all_labels [concat $::all_labels $labels]
				}
				set ::all_labels [lsort -unique $::all_labels]
			}
		
			#msg "Hiding [llength $::all_labels] labels"
			foreach label $::all_labels {
				if {[.can itemcget $label -state] != "hidden"} {
					.can itemconfigure $label -state hidden
					#msg "hiding: '$label'"
				}
			}
		
			#msg "Showing [llength $these_labels] labels"
			foreach label $these_labels {
				.can itemconfigure $label -state normal
				#msg "showing: '$label'"
			}
		
			update
			#set end [clock milliseconds]
			#puts "elapsed: [expr {$end - $start}]"
		
			global actions
			if {[info exists actions($page_to_show)] == 1} {
				foreach action $actions($page_to_show) {
					eval $action
					msg "action: '$action"
				}
			}
		
			#msg "Switched to page: $page_to_show [stacktrace]"
			msg "Switched to page: $page_to_show"
		
			update_onscreen_variables
		
			hide_android_keyboard
		
		}
		
		proc back_to_previous {} {
		}
		
		proc add_action { page event cmd } {
			variable actions
			if { [lsearch "before_show after_show hide" $event] == -1 } {
				error "'$event' is not a valid event for gui add_action"
			}
			if { ![info exists actions($page)] } {
				array set actions($page) {}
			}
			array set page_actions $actions($page)
			if { ![info exists page_actions($event)] } {
				set page_actions($event) {}
			}
			lappend page_actions($event) $cmd
			set actions($page) $page_actions
		}
		
		proc actions { page {event {}} } {
			variable actions
			if { $event eq "" } {
				return [array get [ifexists actions($page)]]
			} else {
				array set page_actions [ifexists actions($page)]
				return [array get [ifexists page_actions(event)]]
			}
		}
	}
	
	### ITEMS SUB-ENSEMBLE ###
	# Items are visual items added to the canvas, either canvas items (text, arcs, lines...) or Tk widgets.
	namespace eval item {
		namespace export *
		namespace ensemble create
	
		# Keep track of what labels are displayed in what pages. Warns if a label already exists.
		proc add_to_pages { pages tags } {
			global existing_labels
			foreach page $pages {
				foreach tag $tags {
					set full_tag "$page.$tag"
					set page_tags [ifexists existing_labels($page)]
					if { [lsearch $page_tags $full_tag] > -1 } {
						msg -WARN [namespace current] "tag/label '$full_tag' already exists in page '$page'"
					} else {
						lappend page_tags $full_tag
					}
					set existing_labels($page) $page_tags
				}
			}
		}

		# Items/tags/labels selector. Use trailing * as in "<tag>.*" or "<tag>*" to return all tags matching "$tags.*".
		# Use the empty string or "*" to return all tags in the page.
		proc get { page tags } {
			global existing_labels
			set page_tags [ifexists existing_labels($page)]
	
			set labels {}
			foreach tn $tags {
				if { $tn eq "*" || $tn eq "" } {
					lappend labels {*}$page_tags
				} elseif { [string range $tn end end] eq "*" } {
					set tn "$page.$tn"
					set some_found 0
					if { [string range $tn end-1 end] eq ".*" } {
						set tn [string range $tn 0 end-2]
					} else { 
						set tn [string range $tn 0 end-1]
					}
					if { [lsearch $page_tags $tn] > -1 } {
						set some_found 1
						lappend labels $tn
					}
					set match_tags [lsearch -all -inline -glob $page_tags "$tn.*"]
					if { [llength $match_tags] > 0 } {
						set some_found 1
						lappend labels {*}$match_tags
					}
				
					if { $some_found == 0 } {
						msg -ERROR [namespace current] "cannot find any canvas tags $tn.*"
					}
				} else {
					set tn "$page.$tn"
					if { [lsearch $page_tags $tn] > -1 } {
						lappend labels $tn
					} else {
						msg -ERROR [namespace current] "cannot find canvas tag $tn"
					}
				}
			}
			return $labels
		}
		
		# Provides a single interface to configure options for both canvas items (text, arcs...) and canvas widgets 
		#	(window entries, listboxes, etc.)
		proc config { page tags args } {
			# Passing '$tags' directly to itemconfigure when it contains multiple tags not always works
			foreach tn [get $page $tags] {
				#msg [namespace current] "config" "tag '$tn' type: [.can type $tn]"
				if { [.can type $tn] eq "window" } {
					set tn_parts [split $tn .]
					.can.[lindex $tn_parts end] configure {*}$args
				} else {
					.can itemconfigure $tn {*}$args
				}
			}
		}
		
		# "Smart" widgets enabler or disabler. 'enabled' can take any value equivalent to boolean (1, true, yes, etc.) 
		# For text, changes its fill color to the default or provided font or disabled color.
		# For other widgets like rectangle "clickable" button areas, enables or disables them.
		# Does nothing if the widget is hidden.
		proc enable_or_disable { enabled page tags { enabled_color {}} { disabled_color {} } } {
			if { $page eq "" } {
				set page $::de1(current_context)
			}
	#		if { $enabled_color eq "" } { 
	#			set enabled_color [gui aspect get $::plugins::DGUI::font_color 
	#		}
	#		if { $disabled_color eq "" } { 
	#			set disabled_color $::plugins::DGUI::disabled_color
	#		}
			
			if { [string is true $enabled] } {
				set color $enabled_color
				set state normal
			} else {
				set color $disabled_color
				set state disabled
			}
			
			foreach tn [get $page $tags] {
		#		set wc ""; catch { append wc [winfo class widget] }
		#		msg "DYE disabling widget $wn - class $wc"
				# DE1 prefixes: text / image / .btn			
				if { [string range $wn 0 3] eq "text" } {
					if { [.can itemconfig $wn -state] ne "hidden" } { .can itemconfig $wn -fill $color }
				} elseif { [string range $wn 0 3] eq ".btn" } {
					if { [.can itemconfig $wn -state] ne "hidden" } { .can itemconfig $wn -state $state }
				} elseif { [string range $wn 0 5] eq ".can.w"} {
					if { [$wn cget -state] ne "hidden" } { $wn configure -state $state }
				}
			}
		} 
		
		# "Smart" widgets disabler. 
		# For text, changes its fill color to the default or provided disabled color.
		# For other widgets like rectangle "clickable" button areas, disables them.
		# Does nothing if the widget is hidden. 
		proc disable { page tags { disabled_color {}} } {
			enable_or_disable 0 $page $tags {} $disabled_color
		}
		
		proc enable { page tags { enabled_color {} } } {
			enable_or_disable 1 $page $tags $enabled_color {}
		}
		
		# "Smart" widgets shower or hider. 'show' can take any value equivalent to boolean (1, true, yes, etc.)
		# If check_context=1, only hides or shows if the items page is the currently active page. This is useful,
		#	for example, if you're showing after a delay, as the page/page may have been changed in between.
		proc show_or_hide { show page tags { check_context 1 } } {
			if { $page eq "" } {
				set page $::de1(current_context)
			} elseif { $check_context && $page ne $::de1(current_context) } {
				return
			}
			
			if { [string is true $show] } {
				set state normal
			} else {
				set state hidden
			}
			
			config $page $tags -state $state
#			foreach tn [get $page $tags] {
#				.can itemconfigure $tn -state $state
#			}
		}
		
		proc show { page tags { check_context 1} } {
			show_or_hide 1 $page $tags $check_context
		}
		
		proc hide { page tags { check_context 1} } {
			show_or_hide 0 $page $tags $check_context
		}
	
	}
	
	### COMMANDS TO ADD ITEMS & WIDGETS TO THE CANVAS ###
	
	# Add text items to the canvas. Returns the list of all added tags (one per page).
	#
	# Named options:
	#	-tag a label that allows to access the created canvas items
	#	-style to apply the default aspects of the provided style
	#	All others passed through to the 'canvas create text' command
	proc add_text { pages x y args } {
		global text_cnt
		set x [rescale_x_skin $x]
		set y [rescale_y_skin $y]
		incr text_cnt
		set base_tag [gui::args::get_option -tag "text_$text_cnt" 1]
		foreach c $pages {
			lappend tag "$c.$base_tag"
		}
		
#		args::complete_with_theme_aspects text "fill activefill disabledfill anchor justify"
		set style [gui::args::get_option -style "" 1]
		foreach aspect "fill activefill disabledfill anchor justify" {
			gui::args::add_option_if_not_exists -$aspect [gui aspect get "text.$aspect" -style $style]
		}
				
		.can create text $x $y -tag $tag -state hidden {*}$args

		item add_to_pages $pages $base_tag
		return $tag
	}
	
	# Adds text to a page that is the result of evaluating some code. The text shown is updated automatically whenever
	#	the underlying code evaluates to a different text.
	# Named options:
	#  -textvariable Tcl code. Not the name of a variable, but code to be evaluated. So, to refer to global variable 'x' 
	#		you must use '{$::x}', not '::x'.
	# 		If -textvariable gives a plain name instead of code to be evaluted (no brackets, parenthesis, ::, etc.) 
	#		and the first page in 'pages' is a namespace, uses {$::gui::pages::<page>::data(<textvariable>)}. 
	#		Also in this case, if -tag is not specified, uses the textvariable name as tag.
	# All others passed through to the 'gui add_text' command
	proc add_variable { pages x y args } {
		global variable_labels
		
		set first_page [lindex $pages 0]
		set is_ns [gui::page::is_namespace $first_page]
		set varcmd [gui::args::get_option -textvariable "" 1]
		if { $varcmd eq "" } {
			msg -WARN [namespace current] "no -textvariable passed to add_variable"
			return
		} elseif { $is_ns && [string is wordchar $varcmd] } {
			if { ![gui::args::has_option -tag] } {
				gui::args::add_option_if_not_exists -tag $varcmd 
			}
			set varcmd "\$::gui::page::${first_page}::data($varcmd)"
		}

		set tags [add_text $pages $x $y {*}$args]
		foreach page $pages {
			foreach tag $tags {
#				if { ![info exists variable_labels($page)] } {
#					set variable_labels($page) [list $tag $varcmd]
#				} else {
				lappend variable_labels($page) [list $tag $varcmd]
#				}
			}
		}
		
		return $tags
	}
		
	# Add button items to the canvas. Returns the list of all added tags (one per page).
	#
	# Defaults to an "invisible" button, i.e. a rectangular "clickable" area. Specify the -style or -shape argument
	#	to generate a visible button instead.
	# Invisible buttons can show their clickable area while debugging, by setting namespace variable debug_buttons=1.
	#	In that case, the outline color is given by aspect 'button.debug_outline' (or black if undefined).
	# Generates up to 3 canvas items/tags per page. Default one is named upon the provided -tag and corresponds to 
	#	the invisible "clickable" area. If a visible button is generated, it its assigned tag "<tag>.button".
	#	If a label is specified, it gets tag "<tag>.label". Returns the list of all added tags.
	#
	# Named options:  
	#	-tag a label that allows to access the created canvas items
	#	-shape any of 'rect', 'rounded' (Barney/MimojaCafe style) or 'outline' (DSx style)
	#	-style to apply the default aspects of the provided style
	#	-label label text, in case a label is to be shown inside the button
	#	-labelvariable, to use a variable as label text
	#	-label_pos a list with 2 elements between 0 and 1 that specify the x and y percentages where to position
	#		the label inside the button
	#	-label_* (-label_fill -label_outline etc.) are passed through to 'gui add_text' or 'gui add_variable'
	#	-radius for rounded rectangles, and -arc_offset for rounded outline rectangles
	#	All others passed through to the respective visible button creation command.
	proc add_button { pages cmd x0 y0 x1 y1 args } {
		global button_cnt
		variable debug_buttons
		
		set rx0 [rescale_x_skin $x0]
		set rx1 [rescale_x_skin $x1]
		set ry0 [rescale_y_skin $y0]
		set ry1 [rescale_y_skin $y1]

		set base_tag [gui::args::get_option -tag "btn_$button_cnt" 1]
		foreach c $pages {
			lappend tag "$c.$base_tag"
			lappend button_tag "$c.$base_tag.button"
			lappend label_tag "$c.$base_tag.label"
		}

		set style [gui::args::get_option -style "" 1]

		set label [gui::args::get_option -label "" 1]
		set labelvar [gui::args::get_option -labelvariable "" 1]
		if { $label ne "" || $labelvar ne "" } {
			set label_args [gui::args::extract_prefixed -label_]
			foreach aspect "anchor justify fill activefill disabledfill" {
				gui::args::add_option_if_not_exists -$aspect [gui aspect get button_label.$aspect -style $style -default {}] label_args
			}
			
			set label_pos [gui::args::get_option -pos [gui aspect get button_label.pos -style $style -default {0.5 0.5}] 1 label_args]
			set xlabel [expr {$x0+int($x1-$x0)*[lindex $label_pos 0]}]
			set ylabel [expr {$y0+int($y1-$y0)*[lindex $label_pos 1]}]
		}
		
		# As soon as the rect has a non-zero width (or maybe an outline or fill?), its "clickable" area becomes only
		#	the border, so if a visible rectangular button is needed, we have to add an invisible clickable rect on 
		#	top of it.
		if { $style eq "" && ![gui::args::has_option -shape]} {
			if { $debug_buttons == 1 } {
				set width 1
				set outline [gui aspect get button.debug_outline -style $style -default "black"]
			} else {
				set width 0
			}

			if { $width > 0 } {
				.can create rect $rx0 $ry0 $rx1 $ry1 -outline $outline -width $width -tag $button_tag -state hidden
				item add_to_pages $pages "$base_tag.button"
			}
		} else {
			set shape [gui::args::get_option -shape [gui aspect get button.shape -style $style -default rect] 1]
			
			if { $shape eq "round" } {
				set fill [gui::args::get_option -fill [gui aspect get button.fill -style $style]]
				set disabledfill [gui::args::get_option -disabledfill [gui aspect get button.disabledfill -style $style]]
				set radius [gui::args::get_option -radius [gui aspect get button.radius -style $style -default 40]]
				
				rounded_rectangle $x0 $y0 $x1 $y1 $radius $fill $disabledfill $button_tag 
				item add_to_pages $pages "$base_tag.button"
			} elseif { $shape eq "outline" } {
				set outline [gui::args::get_option -outline [gui aspect get button.outline -style $style]]
				set disabledoutline [gui::args::get_option -disabledoutline [gui aspect get button.disabledoutline -style $style]]
				set arc_offset [gui::args::get_option -arc_offset [gui aspect get button.arc_offset -style $style -default 50]]
				set width [gui::args::get_option -width [gui aspect get button.width -style $style -default 3]]
				
				rounded_rectangle_outline $x0 $y0 $x1 $y1 $arc_offset $outline $disabledoutline $width $button_tag
				item add_to_pages $pages "$base_tag.button"
			} else {
				foreach aspect "fill activefill disabledfill outline disabledoutline activeoutline width" {
					gui::args::add_option_if_not_exists -$aspect [gui aspect get button.$aspect -style $style]
				}					
				.can create rect $rx0 $ry0 $rx1 $ry1 -tag $button_tag -state hidden {*}$args
				item add_to_pages $pages "$base_tag.button"
			}
		}
		
		if { $label ne "" } {
			add_text $pages $xlabel $ylabel -text $label -tag "$base_tag.label" {*}$label_args
		} elseif { $labelvar ne "" } {
			add_variable $pages $xlabel $ylabel -textvariable $labelvar -tag "$base_tag.label" {*}$label_args 
		}
		
		# Clickable rect
		.can create rect $rx0 $ry0 $rx1 $ry1 -fill {} -outline black -width 0 -tag $tag -state hidden
		regsub {%x0} $cmd $rx0 cmd
		regsub {%x1} $cmd $rx1 cmd
		regsub {%y0} $cmd $ry0 cmd
		regsub {%y1} $cmd $ry1 cmd
		foreach t $tag {
			.can bind $t [platform_button_press] $cmd
		}
		item add_to_pages $pages $base_tag
		return $tag
	}
	
	# Discovered through Johanna's MimojaCafe skin code, attributed to Barney.
	proc rounded_rectangle { x0 y0 x1 y1 radius colour disabled tag } {
		set x0 [rescale_x_skin $x0] 
		set y0 [rescale_y_skin $y0] 
		set x1 [rescale_x_skin $x1] 
		set y1 [rescale_y_skin $y1]
		
		.can create oval $x0 $y0 [expr $x0 + $radius] [expr $y0 + $radius] -fill $colour -disabledfill $disabled \
			-outline $colour -disabledoutline $disabled -width 0 -tag $tag -state "hidden"
		.can create oval [expr $x1-$radius] $y0 $x1 [expr $y0 + $radius] -fill $colour -disabledfill $disabled \
			-outline $colour -disabledoutline $disabled -width 0 -tag $tag -state "hidden"
		.can create oval $x0 [expr $y1-$radius] [expr $x0+$radius] $y1 -fill $colour -disabledfill $disabled \
			-outline $colour -disabledoutline $disabled -width 0 -tag $tag -state "hidden"
		.can create oval [expr $x1-$radius] [expr $y1-$radius] $x1 $y1 -fill $colour -disabledfill $disabled \
			-outline $colour -disabledoutline $disabled -width 0 -tag $tag -state "hidden"
		.can create rectangle [expr $x0 + ($radius/2.0)] $y0 [expr $x1-($radius/2.0)] $y1 -fill $colour \
			-disabledfill $disabled -disabledoutline $disabled -outline $colour -width 0 -tag $tag -state "hidden"
		.can create rectangle $x0 [expr $y0 + ($radius/2.0)] $x1 [expr $y1-($radius/2.0)] -fill $colour \
			-disabledfill $disabled -disabledoutline $disabled -outline $colour -width 0 -tag $tag -state "hidden"
	}
	
	# Inspired by Barney's rounded_rectangle, mimic DSx buttons showing a button outline without a fill.
	proc rounded_rectangle_outline { x0 y0 x1 y1 arc_offset colour disabled width tag } {
		set x0 [rescale_x_skin $x0] 
		set y0 [rescale_y_skin $y0] 
		set x1 [rescale_x_skin $x1] 
		set y1 [rescale_y_skin $y1]
	
		.can create arc [expr $x0] [expr $y0+$arc_offset] [expr $x0+$arc_offset] [expr $y0] -style arc -outline $colour \
			-width [expr $width-1] -tag $tag -start 90 -disabledoutline $disabled -state "hidden"
		.can create arc [expr $x0] [expr $y1-$arc_offset] [expr $x0+$arc_offset] [expr $y1] -style arc -outline $colour \
			-width [expr $width-1] -tag $tag -start 180 -disabledoutline $disabled -state "hidden"
		.can create arc [expr $x1-$arc_offset] [expr $y0] [expr $x1] [expr $y0+$arc_offset] -style arc -outline $colour \
			-width [expr $width-1] -tag $tag -start 0 -disabledoutline $disabled -state "hidden"
		.can create arc [expr $x1-$arc_offset] [expr $y1] [expr $x1] [expr $y1-$arc_offset] -style arc -outline $colour \
			-width [expr $width-1] -tag $tag -start -90 -disabledoutline $disabled -state "hidden"
		
		.can create line [expr $x0+$arc_offset/2] [expr $y0] [expr $x1-$arc_offset/2] [expr $y0] -fill $colour \
			-width $width -tag $tag -disabledfill $disabled -state "hidden"
		.can create line [expr $x1] [expr $y0+$arc_offset/2] [expr $x1] [expr $y1-$arc_offset/2] -fill $colour \
			-width $width -tag $tag -disabledfill $disabled -state "hidden"
		.can create line [expr $x0+$arc_offset/2] [expr $y1] [expr $x1-$arc_offset/2] [expr $y1] -fill $colour \
			-width $width -tag $tag -disabledfill $disabled -state "hidden"
		.can create line [expr $x0] [expr $y0+$arc_offset/2] [expr $x0] [expr $y1-$arc_offset/2] -fill $colour \
			-width $width -tag $tag -disabledfill $disabled -state "hidden"		
	}

	# Named options:
	#	-tag
	#	-anchor anchor wrt the {x y} coordinates on the '.can create window' command
	proc add_widget { pages type x y {cmd {}} args } {
		global widget_cnt	
		
		incr widget_cnt	
		set base_tag [gui::args::get_option -tag "w_${type}_$widget_cnt" 1]
		set widget ".can.$base_tag"
		if { [info exists ::$widget] } {
			error "Widget with name '$widget' already exists"
			return
		}
		
		set style [gui::args::get_option -style "" 1]
		foreach a [gui aspect list -type $type -style $style] {
			set opt [lindex [split $a .] end]
			gui::args::add_option_if_not_exists -$opt [gui aspect get $a -style $style]
		}		
		# Anchor is no longer hardcoded but can be defined on the call or on the theme aspect
		set anchor [gui::args::get_option -anchor nw 1]
		
		try {
			$type $widget {*}$args
		} on error err {
			msg -ERROR [namespace current] "can't create $type widget '$widget' on pages '$pages': $err"
		}
			
		# BLT on android has non standard defaults, so we overrride them here, sending them back to documented defaults
		if {$type == "graph" && ($::android == 1 || $::undroid == 1)} {
			$widget grid configure -dashes "" -color #DDDDDD -hide 0 -minor 1 
			$widget configure -borderwidth 0
			#$widget grid configure -hide 0
		}
	
		# Additional code to run when creating this widget, such as chart configuration instructions
		# EB: TBD This is inherited from the original code, but can't eval have problems here? It maay redefine local 
		#	variables like $x, $pages, etc.
		#	Probably safer to do a %W expansion, then run in a global context. 
		try {  
			eval $cmd
		} on error err {
			msg -ERROR [namespace current] "evaluating $type widget '$widget' command \{ $cmd \}: $err" 
		}
	
		set x [rescale_x_skin $x]
		set y [rescale_y_skin $y]
		foreach c $pages {
			lappend tag "$c.$base_tag"
		}
		
		if {$type == "scrollbar"} {
			set windowname [.can create window  $x $y -window $widget -anchor $anchor -tag $tag -state hidden -height 245]
		} else {
			set windowname [.can create window $x $y -window $widget -anchor $anchor -tag $tag -state hidden]
		}
		#puts "winfo: [winfo children .can]"
		#.can bind $windowname [platform_button_press] "msg click"
			
		# EB: Maintain this? I don't find any use of this array in the app code
		#set ::tclwindows($widget) [list $x $y]
	
		item add_to_pages $pages $base_tag
		return $widget 
	}
	
	proc add_entry {} {
		
	}
	
	proc add_listbox {} {
		
	}
		

	### GENERAL TOOLS ###	
	# Computes the anchor point coordinates with respect to the provided bounding box coordinates, returns a list 
	#	with 2 elements.
	# Anchor valid values are center, n, ne, e, se, s, sw, w, nw.
	# Not exported.
	proc anchor_point { anchor x0 y0 x1 y1 {xoffset 0} {yoffset 0} } {
		if { $anchor eq "center" } {
			set x [expr {$x0+int(($x1-$x0)/2)+$xoffset}]
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
	
	proc hide_android_keyboard {} {
		# make sure on-screen keyboard doesn't auto-pop up, and if
		# physical keyboard is connected, make sure navbar stays hidden
		sdltk textinput off
		focus .can
	}
		
}
