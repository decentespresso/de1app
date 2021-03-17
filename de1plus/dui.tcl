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
#	- Global variables that must change to the dui namespace variables:
#		::de1(current_context) -> ::dui::page::current_page
#		::existing_labels array (one item per page)
#		::all_labels (list with all labels, sorted) Can't this be get from the canvas tags???)
#		screensaver integrated in the dui or not? -> An action on the "saver" page can make it work
#		Idle/stress test in page display_change ?? -> Add a way to add before_show/after_show/hide actions
#		::delayed_image_load system
#	- Global utility functions that are used here:
#		ifexists
#		$::fontm, $::globals(entry_length_multiplier)
#		$::android, $::undroid

package provide de1_dui 1.0

package require de1_logging 1.0
package require Tk
catch {
	# tkblt has replaced BLT in current TK distributions, not on Androwish, they still use BLT and it is preloaded
	package require tkblt
	namespace import blt::*
}

set ::settings(enabled_plugins) {dui_demo}

namespace eval ::dui {
	namespace export init canvas theme aspect symbol font page item \
		add_text add_variable add_symbol add_button add_widget add_entry add_checkbox add_listbox \
		hide_android_keyboard
	namespace ensemble create

	# Set to 1 while debugging to see the "clickable" areas. Also may need to redefine aspect 
	#	'<theme>.button.debug_outline' so it's visible against the theme background.
	variable debug_buttons 0
	
	# Set to 1 to default to create a namespace ::dui::page::<page_name> for each new created page
	variable create_page_namespaces 0
	# Set to 1 to trim leading and trailing whitespace when modifying the value in entry boxes 
	variable trim_entries 0
	# Set to 1 to default to use editor pages if available 
	variable use_editor_pages 1
	
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
	# The theme is always specified globally using 'dui theme current <theme_name>', and cannot be modified for 
	#	individual items/widgets.
	# Whenever an item/widget is added to the canvas using the 'dui add_*' commands, its default options are
	#	taken from the theme aspects, unless they are overridden explicitly in the 'add_*' call.
	# Different styles can be added to any item/widget type, by adding aspects with a ".<style>" suffix.
	# If the 'add_*' call includes a -style option, each default aspect option will be taken from the style. If that
	#	option is not available for the style, the non-style option version will be used. 
	# If an aspect is not defined for the current theme, the aspect from the 'default' theme will be used,
	#	or a default can be provided directly by client code using the -default tag of the 'dui aspect get' command.  
	namespace eval aspect {
		namespace export add exists get list
		namespace ensemble create
		
		variable aspects
		# TBD default.button_label.activefill needed? On buttons the invisible rectangle "hides" the text and
		#	it seems they never become active.
		# $::helvetica_font
		array set aspects {
			default.page.bg_img {}
			default.page.bg_color "#edecfa"
			
			default.font.font_family notosansuiregular
			default.font.font_size 16
			
			default.text.font_family notosansuiregular
			default.text.font_size 16
			default.text.fill "#7f879a"
			default.text.activefill orange
			default.text.disabledfill "#ddd"
			default.text.anchor nw
			default.text.justify left
			
			default.text.fill.remark orange
			default.text.anchor.remark nw
			default.text.fill.error red

			default.symbol.font_family "Font Awesome 5 Pro-Regular-400"
			default.symbol.font_size 16
			default.symbol.fill "#7f879a"
			default.symbol.activefill orange
			default.symbol.disabledfill "#ddd"
			default.symbol.anchor nw
			default.symbol.justify left
			
			default.entry.relief sunken
			default.entry.bg "#ffffff"
			
			default.button.debug_outline black
			default.button.fill "#c0c5e3"
			default.button.activefill "#c0c5e3"
			default.button.disabledfill orange
			default.button.outline "white"
			default.button.disabledoutline "pink"
			default.button.activeoutline "orange"
			default.button.width 0
			
			default.button_label.pos {0.5 0.5}
			default.button_label.anchor center
			default.button_label.font_family notosansuiregular
			default.button_label.font_size 16
			default.button_label.justify center
			default.button_label.fill "#ffffff"
			default.button_label.activefill "#ffffff"
			default.button_label.disabledfill black

			default.button_symbol.pos {0.2 0.5}
			default.button_symbol.font_size 24
			default.button_symbol.anchor center
			default.button_symbol.justify center
			default.button_symbol.fill "#ffffff"
			default.button_symbol.activefill "#ffffff"
			default.button_symbol.disabledfill "#ffffff"

			default.button_state.pos {0.5 0.5}
			default.button_state.anchor center
			default.button_state.justify center
			default.button_state.fill "#ffffff"
			default.button_state.activefill "#ffffff"
			default.button_state.disabledfill "#ffffff"
			
			default.entry.relief flat
			default.entry.bg pink
			default.entry.width 5
			default.entry.font_family notosansuiregular
			default.entry.font_size 16
			
			default.entry.relief.special flat
			default.entry.bg.special yellow
			default.entry.width.special 1
			
			default.checkbox.font_family "Font Awesome 5 Pro-Regular-400"
			default.checkbox.font_size 16
			default.checkbox.anchor nw
			default.checkbox.justify left
			
			default.checkbox_label.pos "e 45 0"
			default.checkbox_label.anchor w
			default.checkbox_label.justify left
			
			default.listbox.relief flat
			default.listbox.borderwidth 1
			default.listbox.foreground black
			default.listbox.background pink
			default.listbox.selectforeground white
			default.listbox.selectbackground black
			default.listbox.selectborderwidth 0
			default.listbox.disabledforeground white
			default.listbox.selectbackground black
			default.listbox.highlightthickness 1
			default.listbox.highlightcolor orange
			default.listbox.selectmode browser
			default.listbox.justify left

			default.listbox_label.pos "wn -10 0"
			default.listbox_label.anchor ne
			default.listbox_label.justify right
			
			default.scrollbar.width 75
			default.scrollbar.length 75
			default.scrollbar.sliderlength 75
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
			
		}
		#default.button.disabledfill "#ddd"
		#default.button.radius 40
		#default.button.arc_offset 50
				
		# Named options:
		# 	-theme theme_name: to add to a theme different than the current one
		#	-type type_name: use this type for all added aspects.
		# 	-style style_name: use this style for all added aspects.
		proc add { args } {
			variable aspects
			set theme [dui::args::get_option -theme [dui theme current] 1]
			set type [dui::args::get_option -type "" 1]
			set style [dui::args::get_option -style "" 1]
			set prefix "$theme."
			if { $type ne "" } {
				append prefix "$type."
			}
			set suffix ""
			if { $style ne "" } {
				set suffix ".$style"
			}
			
			if { [llength $args] == 1 } {
				set args [lindex $args 0]
			}
			for { set i 0 } { $i < [llength $args] } { incr i 2 } {
				set var "$prefix[lindex $args $i]$suffix"
#				if { $style ne "" && [string range $var end-[string length $style] end] ne ".$style" } {
#					append var ".$style"
#				}
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
		proc exists { type aspect args } {
			variable aspects
			set theme [dui::args::get_option -theme [dui theme current]]
			set style [dui::args::get_option -style ""]
			set aspect_name "$theme.$type.$aspect"
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
		#	-default_type to search the same aspect in this type, in case it's not defined for the requested type
		proc get { type aspect args } {
			variable aspects
			set theme [dui::args::get_option -theme [dui theme current]]
			set style [dui::args::get_option -style ""]			
			set default [dui::args::get_option -default ""]
			set default_type [dui::args::get_option -default_type ""]
			
			if { $style ne "" && [info exists aspects($theme.$type.$aspect.$style)] } {
				return $aspects($theme.$type.$aspect.$style)
			} elseif { [info exists aspects($theme.$type.$aspect)] } {
				return $aspects($theme.$type.$aspect)
			} elseif { $default ne "" } {
				return $default
			} elseif { $default_type ne "" && $default_type ne $type } {
				return [get $default_type $aspect -theme $theme -style $style]
			} elseif { [string range $aspect 0 4] eq "font_" && [info exists aspects($theme.font.$aspect)] } {
				return $aspects($theme.font.$aspect)
			} elseif { $theme ne "default" } {
				return [get $default_type $aspect -theme default -style $style]
			} else {
				msg -NOTICE [namespace current] "aspect '$theme.$aspect' not found and no alternative available"
				return ""
			}
		}
		
		# Named options:
		# 	-theme theme_name to return for a theme different than the current one. If not specified and -all_themes=0
		#		(the default), returns aspects for the currently active theme only.
		#	-type to return only the aspects for that type (e.g. "entry", "text", etc.)
		# 	-style to return only the aspects for that style 
		# If the returned values are for a single theme, the theme name prefix is not included, but if -all_themes is 1,
		#	returns the full aspect name including the theme prefix.
		proc list { args } {
			variable aspects
			set theme [dui::args::get_option -theme [dui theme current]]
			set pattern "^$theme."
			
			set type [dui::args::get_option -type ""]
			if { $type eq "" } {
				append pattern {[0-9a-zA-Z_]+\.}
			} else {
				append pattern "$type."
			}
			
			set style [dui::args::get_option -style ""]
			if { $style eq "" } {
				append pattern {[0-9a-zA-Z_]+$}
			} else {
				append pattern "\[0-9a-zA-Z_\]+.$style\$"
			}
			
			msg [namespace current] list "pattern='$pattern'"
			
			set result {}
			foreach full_aspect [array names aspects -regexp $pattern] {
				set aspect_parts [split $full_aspect .]
				set aspect [lindex $aspect_parts 2]
				if { $aspect ne "" } {
					lappend result $aspect
				}
			}
			
			return $result
		}
	}	
	
	### SYMBOL SUB-ENSEMBLE ###
	# This set of commands allow defining Fontawesome Regular symbols by name, then use them in the code by their name.
	# To find out the unicode values of the available symbols, see https://fontawesome.com/icons?d=gallery
	namespace eval symbol {
		namespace export add get exists
		namespace ensemble create
				
		variable font_filename "Font Awesome 5 Pro-Regular-400"
		
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
		namespace export add get width set_in_args
		namespace ensemble create

		#variable loaded_fonts {}
		#variable skin_fonts {}
		
		# Barney  https://3.basecamp.com/3671212/buckets/7351439/documents/2208672342#__recording_2349428596
		proc load { name filename pcsize {androidsize {}} } {
			global loaded_fonts
			# calculate font size
			set familyname ""
		
			if {($::android == 1 || $::undroid == 1) && $androidsize != ""} {
				set pcsize $androidsize
			}
			set platform_font_size [expr {int(1.0 * $::fontm * $pcsize)}]
		
#			if {[language] == "zh-hant" || [language] == "zh-hans"} {
#				set filename ""
#				set familyname $::helvetica_font
#			} elseif {[language] == "th"} {
#				set filename "[dir]/sarabun.ttf"
#			}
		
			if {[info exists ::loaded_fonts] != 1} {
				set loaded_fonts list
			}
			set fontindex [lsearch $loaded_fonts $filename]
			if {$fontindex != -1} {
				set familyname [lindex $loaded_fonts [expr $fontindex + 1]]
			} elseif {($::android == 1 || $::undroid == 1) && $filename != ""} {
				catch {
					set familyname [lindex [sdltk addfont $filename] 0]
				}
		
				if {$familyname == ""} {
					msg -WARN [namespace current] "load" "Unable to get familyname from 'sdltk addfont $filename'"
				} else {
					lappend loaded_fonts $filename $familyname
				}
			}
		
			if {[info exists familyname] != 1 || $familyname == ""} {
				msg -NOTICE [namespace current] "Font familyname not available; using name '$name'."
				set familyname $name
			}
		
			catch {
				font create $name -family $familyname -size $platform_font_size
			}
			msg -INFO [namespace current] "added font name: \"$name\" family: \"$familyname\" size: $platform_font_size filename: \"$filename\""			
		}
		
		# Barney writes: https://3.basecamp.com/3671212/buckets/7351439/documents/2208672342#__recording_2349428596
		# I created a wrapper function that you might be interested in adopting. It makes working with fonts even simpler by removing the need to pre-load fonts before using them.
		# Here's the syntax for using the get_font function in a call to add_de1_text:
		# add_de1_text "off" 100 100 -text "Hi!" -font [get_font "Comic Sans" 12] 
		proc get { font_name size } {
			if {[info exists ::skin_fonts] != 1} {
				set ::skin_fonts list
			}
		
			set font_key "\"$font_name\" $size"
			set font_index [lsearch $::skin_fonts $font_key]
			if {$font_index == -1} {
				# load the font if needed. 
		
				# support for both OTF and TTF files
				if {[file exists "[skin_directory]/fonts/$font_name.otf"] == 1} {
					load_font $font_key "[skin_directory]/fonts/$font_name.otf" $size
					lappend ::skin_fonts $font_key
				} elseif {[file exists "[skin_directory]/fonts/$font_name.ttf"] == 1} {
					load_font $font_key "[skin_directory]/fonts/$font_name.ttf" $size
					lappend ::skin_fonts $font_key
				} elseif {[file exists "[homedir]/fonts/$font_name.otf"] == 1} {
					load_font $font_key "[homedir]/fonts/$font_name.otf" $size
					lappend ::skin_fonts $font_key
				} elseif {[file exists "[homedir]/fonts/$font_name.ttf"] == 1} {
					load_font $font_key "[homedir]/fonts/$font_name.ttf" $size
					lappend ::skin_fonts $font_key	
				} else {
					msg -WARN [namespace current] "Unable to load font '$font_key'"
				}
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

		proc list {} {
			return ::loaded_fonts
		}
			
		# Returns the current fonts directory (if path is not specified) or sets it to path. 
#		proc dir { {font_path {}} } {
#			variable dir
#			if { $font_path eq "" } {
#				return $dir
#			} else {
#				set dir $font_path
#				if { ![file isdirectory $font_path] } {
#					msg -ERROR [namespace current] "dir" "'$font_path' is not a valid path"
#				}
#			}
#		}
	}
	
	### ARGS SUB-ENSEMBLE ###
	# A set of tools to manipulate named options in the 'args' argument to dui commands. 
	# These are heavily used in the 'add' commands that create widgets, with the general objectives of:
	#	1) pass-through any aspect parameter explicitly defined by the user to the main widget creation command,
	#		or otherwise use the theme and style default values. 	
	#	2) extract the options that won't be passed through to the main widget creation command, but to other one,
	#		like aspect values passed to the label creation command in add_button (-label_font, -label_fill...)
	# These namespace commands are not exported, should normally only be used inside the dui namespace, where
	#	they're called using qualified names.
	namespace eval args {
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
		proc remove_option { option_name {args_name args} } {
			upvar $args_name largs
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
		### These are used from most 'dui add_*' commands, for homogeneous handling of the same types of named options.
		
		# Complete the tags and -<type>variable arguments in the args list in a standard way.
		# If -tags is in the args, use the first tag as main tag, otherwise assigns an auto-increment counter tag,
		#	using 2 counters, one for text items, another for widgets.
		# Raises an error if a main tag already exists, as no duplicates are allowed.
		# Adds page tags in the form "p:$page" to the tags. This allows showing and hiding pages, or retrieving items
		#	by their tag name plus the page in which they appear.
		# If a varoption argument is specified (e.g. "-textvariable"), and the first page in $pages is a page
		#	namespace, then:
		#		- if the varoption is not found in the arguments, or it's the empty string, uses the namespace 
		#			variable data(<main_tag>)
		#		- if the varoption is found and it is a plain name instead of a fully qualified name, such as 
		#			"-textvariable pressure", uses the namespace variable data(<varoption>), e.g. data(pressure).
		proc process_tags_and_var { pages type {varoption {}} {add_multi 0} {args_name args} {rm_tags 0} } {
			variable item_cnt
			upvar $args_name largs
			set can [dui canvas]
			
			set tags [get_option -tags {} 1 largs]
			set auto_assign_tag 0
			if { [llength $tags] == 0 } {
				set main_tag "${type}_[incr item_cnt]"
				set tags $main_tag
				set auto_assign_tag 1
			} else {
				set main_tag [lindex $tags 0]
			}
			if { [$can find withtag $main_tag] ne "" } {
				set msg "Tag '$main_tag' already exists in the canvas, duplicated canvas items main tags are not allowed"
				msg [namespace current] process_tags_and_var $msg
				error $msg
				return
			}
			
			if { $add_multi == 1 && "$main_tag*" ni $tags } {
				lappend tags "$main_tag*"
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
				set is_ns [dui::page::is_namespace $first_page]
	
				if { $is_ns == 1 } {
					if { [string range $varoption 0 0 ] ne "-" } {
						set varoption -$varoption
					}
					set varname [get_option $varoption "" 1 largs]
					if { $varname eq "" } {
						if { ! $auto_assign_tag } {
							if { $type eq "variable" } {
								set varname "\$::dui::pages::${first_page}::data($main_tag)"
							} else {
								set varname "::dui::pages::${first_page}::data($main_tag)"
							}
						}
					} elseif { [string is wordchar $varname] } {
						if { $type eq "variable" } {
							set varname "\$::dui::pages::${first_page}::data($varname)"
						} else {
							set varname "::dui::pages::${first_page}::data($varname)"
						}
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
		# TBD: Allow 'type' to be a list from higher to lower precedence. 
		proc process_aspects { type {style {}} {aspects {}} {exclude {}} {args_name args} } {
			upvar $args_name largs
			if { $style eq "" } {
				set style [get_option -style "" 0 largs]
			}
			set default_type ""
			if { [dui::args::has_option -aspect_type largs] } {
				set default_type $type
				set type [dui::args::get_option -aspect_type "" 1 largs]
			}
			
			if { $aspects eq "" } {
				set aspects [dui aspect list -type $type -style $style]
			}
			foreach aspect $aspects {
				if { $aspect ni $exclude } {
					add_option_if_not_exists -$aspect [dui aspect get $type $aspect -style $style \
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
				remove_option -font_family largs
				remove_option -font_size largs
			} else {
				set font_family [get_option -font_family [dui aspect get $type font_family -style $style] 1 largs]
				set default_size [dui aspect get $type font_size -style $style]
				set font_size [get_option -font_size $default_size 1 largs]
				if { [string range $font_size 0 0] in "- +" } {
					set font_size [expr $default_size$font_size]
				}
				set font [dui font get $font_family $font_size]
				add_option_if_not_exists -font $font largs
			}
			return $font
		}

		# Processes the -label* named options in 'args' and produces the label according to the provided options.
		# All the -label* options are removed from 'args'.
		# Returns the main tag of the created text. 
		proc process_label { pages x y type {style {}} {args_name args} } {
			upvar $args_name largs
			set label [get_option -label "" 1 largs]
			set labelvar [get_option -labelvariable "" 1 largs]
			if { $label eq "" && $labelvar eq "" } {
				return
			}
			if { $style eq "" } {
				set style [get_option -style "" 0 largs]
			}
			
			set tags [get_option -tags "" 0 largs]
			set main_tag [lindex $tags 0]
			
			set label_tags [list ${main_tag}-lbl {*}[lrange $tags 1 end]]	
			set label_args [extract_prefixed -label_ largs]
			foreach aspect "anchor justify fill activefill disabledfill font_family font_size" {
				add_option_if_not_exists -$aspect [dui aspect get ${type}_label $aspect -style $style \
					-default {} -default_type text] label_args
			}
			set label_pos [get_option -pos [dui aspect get ${type}_label pos -style $style \
				-default "w -20 0"] 1 label_args]
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
					set xlabel_offset [rescale_x_skin [lindex $label_pos 1]] 
				}
				if { [llength $label_pos] > 2 } {
					set ylabel_offset [rescale_y_skin [lindex $label_pos 2]] 
				}				
				set after_show_cmd "::dui::relocate_text_wrt ${main_tag}-lbl $main_tag [lindex $label_pos 0] \
					$xlabel_offset $ylabel_offset [get_option -anchor nw 0 label_args]"
				foreach page $pages {
					dui page add_action $page show $after_show_cmd
				}
			}

			if { $label ne "" } {
				set w [dui add_text $pages $xlabel $ylabel -text $label -tags $label_tags -aspect_type ${type}_label \
					{*}$label_args]
			} elseif { $labelvar ne "" } {
				set w [dui add_variable $pages $xlabel $ylabel -textvariable $labelvar -tags $label_tags \
					-aspect_type ${type}_label {*}$label_args] 
			}
			return $w
		}

		# Processes the -yscrollbar* named options in 'args' and produces the scrollbar slider widget according to 
		#	the provided options.
		# All the -yscrollbar* options are removed from 'args'.
		# Returns 0 if the scrollbar is not created, or the widget name if it is. 
		proc process_yscrollbar { pages x y type {style {}} {args_name args} } {
			upvar $args_name largs			
			set ysb [get_option -yscrollbar "" 1 largs]
			
			if { $ysb eq "" } {
				set sb_args [extract_prefixed -yscrollbar_ largs]
				if { [llength $sb_args] == 0 } {
					return 0
				}
			} elseif { [string is false $ysb] } {
				return 0
			} else {
				set sb_args [extract_prefixed -yscrollbar_ largs]
			}
		
			if { $style eq "" } {
				set style [get_option -style "" 0 largs]
			}
						
			set tags [get_option -tags "" 0 largs]
			set main_tag [lindex $tags 0]			
			set sb_tags [list ${main_tag}-ysb {*}[lrange $tags 1 end]]

			foreach a [dui aspect list -type scrollbar -style $style] {
				set a_value [dui aspect get ${type}_yscrollbar $a -style $style -default {} -default_type scrollbar]
				if { $a eq "height" } {
					if { $a_value eq "" } {
						set a_value 75
					}
					set a_value [rescale_y_skin $a_value]
				} elseif { $a in "length sliderlength" } {
					if { $a_value eq "" } {
						set a_value 75
					}
					set a_value [rescale_x_skin $a_value]
				}
				add_option_if_not_exists -$a $a_value sb_args
			}
			
			set var [get_option -variable "" 1 sb_args]
			if { $var eq "" } {
				set var "::dui::item::sliders($main_tag)"
				set $var 0
			}
			set cmd [get_option -command "" 1 sb_args]
			if { $cmd eq "" } {
				set cmd "::dui::item::listbox_moveto $main_tag \$$var"
			}
			
			foreach page $pages {
				dui page add_action $page show "::dui::item::set_yscrollbar_dim $page $main_tag ${main_tag}-ysb"
			}
			
			return [dui add_widget $pages scale 10000 $y -tags $sb_tags -variable $var -command $cmd {*}$sb_args]
		}		
	}

	### PAGE SUB-ENSEMBLE ###
	# AT THE MOMENT ONLY page_add SHOULD BE USED AS OTHERS MAY BREAK BACKWARDS COMPATIBILITY #
	namespace eval page {
		namespace export add set_next show_when_off show add_action actions
#		namespace export *
		namespace ensemble create

		# Tcl code to run for specific pages when their 'before_show', 'after_show' or 'hide' events take place.
		variable actions
		array set actions {}
		
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
		#  -create_ns will create a page namespace ::dui::page::<page_name>
		proc add { pages args } {
			array set opts $args
			set can [dui canvas]
			
			set style [dui::args::get_option -style "" 1]
			set bg_img [dui::args::get_option -bg_img [dui aspect get page.bg_img -style $style]]
			if { $bg_img ne "" } {
				::add_de1_page $pages $bg_img [dui::args::get_option -skin ""] 
				#add_de1_image $page 0 0 $bg_img
			} else {
				set bg_color [dui::args::get_option -bg_color [dui aspect get page.bg_color -style $style]]
				if { $bg_color ne "" } {
					foreach c $pages {
						#set tag "${c}.background"
						$can create rect 0 0 [rescale_x_skin 2560] [rescale_y_skin 1600] -fill $bg_color -width 0 \
							-tags  [list pages $c] -state "hidden"
						#item add_to_pages $c $tag
					}
				}
			}
			
			if { [string is true [dui::args::get_option -create_ns ::dui::create_page_namespaces 0]] } {
				foreach page $pages {
					if { [is_namespace $page] } {
						namespace eval ::dui::pages::$page {
							namespace export *
							namespace ensemble create
							
							variable page_drawn 0
						}				
					} else {
						namespace eval ::dui::pages::$page {
							namespace export *
							namespace ensemble create
							
							variable items
							array set items {}
							
							variable data
							array set data {}
							
							variable page_drawn 0
						}
					}
					
#					namespace eval ::dui::page {
#						namespace export $page
#					}
				}
			}
		}
		
		proc current {} {
			# Later on dui will keep the current page. At the moment, just use the global variable 
			return $::de1(current_context)
		}
		
		proc is_namespace { page } {
			return [expr [namespace exists "::dui::pages::$page"] && [info exists ::dui::pages::${page}::data]]
			#return [expr {[string range $page 0 1] eq "::" && [info exists ${page}::widgets]}]
		}
			
		proc set_next { machinepage guipage } {
			#variable nextpage
			#msg "set_next_page $machinepage $guipage"
			set key "machine:$machinepage"
			set ::nextpage($key) $guipage
		}

		proc show_when_off { page_to_show args } {
			set_next off $page_to_show
			show $page_to_show {*}$args
		}
				
		proc show { page_to_show args } {
			display_change [current] $page_to_show {*}$args
		}
		
		proc display_change { page_to_hide page_to_show args } {
			set can [dui canvas]
			delay_screen_saver
			
			# EB
			set hide_is_ns [is_namespace $page_to_hide]
			set show_is_ns [is_namespace $page_to_show]
			
			set key "machine:$page_to_show"
			if {[ifexists ::nextpage($key)] != ""} {
				# there are different possible tabs to display for different states (such as preheat-cup vs hot water)
				set page_to_show $::nextpage($key)
			}
		
			if {[current] == $page_to_show} {
				#jbtemp
				#msg "page_display_change returning because ::de1(current_context) == $page_to_show"
				return 
			}
		
			msg [namespace current] "page_display_change $page_to_hide->$page_to_show"
				
			# This should be handled by the main app adding actions to the sleep/off/saver pages
#			if {$page_to_hide == "sleep" && $page_to_show == "off"} {
#				msg [namespace current] "discarding intermediate sleep/off state msg"
#				return 
#			} elseif {$page_to_show == "saver"} {
#				if {[ifexists ::exit_app_on_sleep] == 1} {
#					get_set_tablet_brightness 0
#					close_all_ble_and_exit
#				}
#			}
		
			# signal the page change with a sound
			say "" $::settings(sound_button_out)
			#msg "page_display_change $page_to_show"
			#set start [clock milliseconds]
		
			# This should be added on the main app as a load action on the "saver" page
			# set the brightness in one place
#			if {$page_to_show == "saver" } {
#				if {$::settings(screen_saver_change_interval) == 0} {
#					# black screen saver
#					display_brightness 0
#				} else {
#					display_brightness $::settings(saver_brightness)
#				}
#				borg systemui $::android_full_screen_flags  
#			} else {
#				display_brightness $::settings(app_brightness)
#			}
		
			
			if {$::settings(stress_test) == 1 && $::de1_num_state($::de1(state)) == "Idle" && [info exists ::idle_next_step] == 1} {		
				msg "Doing next stress test step: '$::idle_next_step '"
				set todo $::idle_next_step 
				unset -nocomplain ::idle_next_step 
				eval $todo
			}
			
			# EB
			foreach action [actions $page_to_show load] {
				eval $action
			}
			if { $show_is_ns && [info procs ::dui::pages::${page_to_show}::load] ne ""} {
				set page_loaded [::dui::pages::${page_to_show}::load $page_to_hide {*}$args]
				if { ![string is true $page_loaded] } {
					return
				}
			}

			foreach action [actions $page_to_hide hide] {
				eval $action
			}			
			if { $hide_is_ns && [info procs ::dui::pages::${page_to_hide}::hide] ne "" } {
				::dui::pages::${page_to_hide}::hide $page_to_show
			}
			
			#global current_context
			set ::de1(current_context) $page_to_show
		
			#puts "page_display_change hide:$page_to_hide show:$page_to_show"
			try {
				$can itemconfigure $page_to_hide -state hidden
			} on error err {
				msg -ERROR [namespace current] display_change "error hiding $page_to_hide: $err"
			}
			#$can itemconfigure [list "pages" "splash" "saver"] -state hidden
		
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
		
			try {
				$can itemconfigure $page_to_show -state normal
			} on error err {
				msg -ERROR [namespace current ] display_change "showing page $page_to_show: $err"
			}
		
			set these_labels [ifexists ::existing_labels($page_to_show)]
#			#msg "these_labels: $these_labels"
#		
#			if {[info exists ::all_labels] != 1} {
#				set ::all_labels {}
#				foreach {page labels} [array get ::existing_labels]  {
#					set ::all_labels [concat $::all_labels $labels]
#				}
#				set ::all_labels [lsort -unique $::all_labels]
#			}
		
			#msg "Hiding [llength $::all_labels] labels"
#			foreach label $::all_labels {
#				if {[$can itemcget $label -state] != "hidden"} {
#					$can itemconfigure $label -state hidden
#					#msg "hiding: '$label'"
#				}
#			}

			# EB NO NEED TO USE ::all_labels, can do with canvas tags
			foreach tag [$can find withtag all] {
				if { [$can itemcget $tag -state] ne "hidden" } {
					$can itemconfigure $tag -state hidden
				}
			}
			
			#msg "Showing [llength $these_labels] labels"
			
			# EB NO NEED TO USE ::existing_labels, can do with canvas tags, provided p:<page_name> tags were used.
			set items_to_show [$can find withtag p:$page_to_show]
			if { [llength $items_to_show] > 0 } {
				foreach tag $items_to_show {
					$can itemconfigure $tag -state normal
				}
			} else {
				# Backward-compatible for pages that are not created using the new tags system.
				foreach label $these_labels {
					$can itemconfigure $label -state normal
					#msg "showing: '$label'"
				}
			}
				
			foreach action [actions $page_to_show show] {
				eval $action
			}
			if { $show_is_ns } {
				if { [info procs ::dui::pages::${page_to_show}::show] ne "" } {
					::dui::pages::${page_to_show}::show $page_to_hide
				}
				set ::dui::pages::${page_to_show}::page_drawn 1
			}
			
			#set end [clock milliseconds]
			#puts "elapsed: [expr {$end - $start}]"
		
			# The old actions system, equivalent to the new page "show" event action. 
			# Left temporarilly for compatibility.
			global actions
			if {[info exists actions($page_to_show)] == 1} {
				foreach action $actions($page_to_show) {
					eval $action
					msg "action: '$action"
				}
			}

			update
						
			#msg "Switched to page: $page_to_show [stacktrace]"
			msg "Switched to page: $page_to_show"
		
			update_onscreen_variables
			dui hide_android_keyboard
		}
		
		proc add_action { page event tclcode } {
			variable actions
			if { $event ni "load show hide" } {
				error "'$event' is not a valid event for dui add_action"
			}
			lappend actions($page,$event) $tclcode
		}
		
		proc actions { page event } {
			variable actions
			if { $event ni "load show hide" } {
				error "'$event' is not a valid event for dui add_action"
			}
			return [ifexists actions($page,$event)]
		}
	}

	### PAGES SUB-ENSEMBLE ###
	# Just a container namespace for client code to create UI pages as children namespaces.
	namespace eval pages {
		namespace export *
		namespace ensemble create
	}
	
	### ITEMS SUB-ENSEMBLE ###
	# Items are visual items added to the canvas, either canvas items (text, arcs, lines...) or Tk widgets.
	namespace eval item {
		namespace export *
		namespace ensemble create
	
		variable item_cnt 0
		variable sliders
		array set sliders {}
		
		# Keep track of what labels are displayed in what pages. Warns if a label already exists.
		# THIS IS NO LONGER NEEDED, AS PAGE HIDE/SHOW IS NOW MANAGED USING THE CANVAS TAGS.
		proc add_to_pages { pages tags } {
			global existing_labels
			foreach page $pages {
				set page_tags [ifexists existing_labels($page)]
				foreach tag $tags {					
					if { $tag in $page_tags } {
						#msg -WARN [namespace current] "tag/label '$tag' already exists in page '$page'"
						error "label '$tag' already exists in page '$page'"
					} else {
						msg [namespace current] "adding tag '$tag' to page '$page'"
						lappend page_tags $tag
					}
				}
				set existing_labels($page) $page_tags
			}
		}

		# Canvas items selector using tags. Returns unique item IDs. Use trailing * as in "<tag>*" to return all  
		#	related tags (e.g. a listbox with its label and scrollbar)
		# Use the empty string, "*", or "all" to return all tags in the page. Leave the page empty to not filter
		#	to a specific page.
		proc get { page tags } {
			set can [dui canvas]
			set ids {}
			foreach tag $tags {
				if { $page eq "" } {
					lappend ids {*}[$can find withtag $tag]
				} elseif { $tag eq "*" || $tag eq "" || $tag eq "all"} {
					lappend ids {*}[$can find withtag "p:$page"]
				} else {
					lappend ids {*}[$can find withtag "p:$page&&$tag"]
				}
			}

			return [unique_list $ids]
		}
		
		# If the provided tags match canvas items that are widgets (=windows), return the window commands, otherwise
		#	empty.
		proc get_widget { page tags } {
			set can [dui canvas]
			set widgets {}
			foreach item [get $page $tags] {
				if { [$can type $item] eq "window" } {
					lappend widgets [$can itemcget $item -window]
				}
			}
			return $widgets
		}
		
		# Provides a single interface to configure options for both canvas items (text, arcs...) and canvas widgets 
		#	(window entries, listboxes, etc.)
		proc config { page tags args } {
			set can [dui canvas]
			# Passing '$tags' directly to itemconfigure when it contains multiple tags not always works, iterating
			#	is often needed.
			foreach item [get $page $tags] {
				#msg [namespace current] "config" "tag '$tag' of type '[$can type $tag]'"
				if { [$can type $item] eq "window" } {
					[$can itemcget $item -window] configure {*}$args
				} else {
					$can itemconfigure $item {*}$args
				}
			}
		}
		
		# "Smart" widgets enabler or disabler. 'enabled' can take any value equivalent to boolean (1, true, yes, etc.) 
		# For text, changes its fill color to the default or provided font or disabled color.
		# For other widgets like rectangle "clickable" button areas, enables or disables them.
		# Does nothing if the widget is hidden.
		proc enable_or_disable { enabled page tags { enabled_color {}} { disabled_color {} } } {
			set can [dui canvas]
			if { $page eq "" } {
				set page [dui page current]
			}
	#		if { $enabled_color eq "" } { 
	#			set enabled_color [dui aspect get $::plugins::DGUI::font_color 
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
			
			config $page $tags -state $state
#			foreach item [get $page $tags] {
#				$can itemconfigure $item -state $state	
#			}
		} 
		
		# "Smart" widgets disabler. 
		# For text, changes its fill color to the default or provided disabled color.
		# For other widgets like rectangle "clickable" button areas, disables them.
		# Does nothing if the widget is hidden. 
		proc disable { page tags { disabled_color {}} } {
msg [namespace current] disable "page=$page, tags=$tags"
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
				set page [dui page current]
			} elseif { $check_context && $page ne [dui page current] } {
				return
			}
			
			if { [string is true $show] } {
				set state normal
			} else {
				set state hidden
			}
			
			config $page $tags -state $state
		}
		
		proc show { page tags { check_context 1} } {
			show_or_hide 1 $page $tags $check_context
		}
		
		proc hide { page tags { check_context 1} } {
			show_or_hide 0 $page $tags $check_context
		}
			
		# Configures a page listbox yscrollbar locations and sizes. Run once the page is shown for then to be dynamically 
		# positioned.
		proc set_yscrollbar_dim { page widget_tag {scrollbar_tag {}} } {
			set can [dui canvas]
			if { $scrollbar_tag eq "" } {
				set scrollbar_tag ${main_tag}-ysb
			}
			
			lassign [$can bbox $widget_tag] x0 y0 x1 y1
			[$can itemcget $scrollbar_tag -window] configure -length [expr {$y1-$y0}]
			$can coords $scrollbar_tag "$x1 $y0"
		}
		
		# convenience function to link a "scale" widget with a "listbox" so that the scale becomes a scrollbar to the 
		#	listbox, rather than using the ugly Tk native scrollbar
		proc listbox_moveto { listbox_tag dest1 dest2 } {
			set lb [[dui canvas] itemcget $listbox_tag -window]
			# get number of items visible in list box
			set visible_items [lindex [split [$lb configure -height] " "] 4]
			# get total items in listbox
			set total_items [$lb size]
			# if all the items fit on screen then there is nothing to do
			if {$visible_items >= $total_items} {return}
			# determine which item would be at the top if the last items is at the bottom
			set last_top_item [expr $total_items - $visible_items]
			# determine which item should be at the top for the requested value
			set top_item [expr int(round($last_top_item * $dest2))]
		
			$lb yview $top_item
		}
		
		# convenience function to link a "scale" widget with a "listbox" so that the scale becomes a scrollbar to the 
		#	listbox, rather than using the ugly Tk native scrollbar
		proc scale_scroll { listbox_tag slider_varname dest1 dest2} {
			set lb [[dui canvas] itemcget $listbox_tag -window]
			# get number of items visible in list box
			set visible_items [lindex [split [$lb configure -height] " "] 4]
			# get total items in listbox
			set total_items [$lb size]
			# if all the items fit on screen then there is nothing to do
			if {$visible_items >= $total_items} {return}
			# determine which item would be at the top if the last items is at the bottom
			set last_top_item [expr $total_items - $visible_items]
			# determine what percentage of the way down the current top item is
			set rescaled_value [expr $dest1 * $total_items / $last_top_item]
		
			upvar $slider_varname fieldname
			set fieldname $rescaled_value
		}
				
	}
	
	### INITIALIZE ###
	proc init {} {		
	}
	
	proc canvas {} {
		return ".can"
	}
	
	### COMMANDS TO ADD ITEMS & WIDGETS TO THE CANVAS ###
	
	# Add text items to the canvas. Returns the list of all added tags (one per page).
	#
	# Named options:
	#	-tags a label that allows to access the created canvas items
	#	-style to apply the default aspects of the provided style
	#	-aspect_type to query default aspects for type different than "text"
	#	All others passed through to the 'canvas create text' command
	proc add_text { pages x y args } {
		global text_cnt
		set x [rescale_x_skin $x]
		set y [rescale_y_skin $y]
		
		set tags [args::process_tags_and_var $pages text ""]
		set main_tag [lindex $tags 0]

		set style [dui::args::get_option -style "" 1]		
		dui::args::process_aspects text $style "" "pos"
		dui::args::process_font text $style
				
		try {
			[dui canvas] create text $x $y -state hidden {*}$args
		} on error err {
			set msg "can't add text '$main_tag' in page(s) '$pages' to canvas: $err"
			msg -ERROR [namespace current] $msg
			error $msg
			return
		}

		msg -INFO [namespace current] add_text "to page(s) '$pages' with tag(s) '$tags' and args '$args'" 
		
		item add_to_pages $pages $main_tag
		return $main_tag
	}
	
	# Adds text to a page that is the result of evaluating some code. The text shown is updated automatically whenever
	#	the underlying code evaluates to a different text.
	# Named options:
	#  -textvariable Tcl code. Not the name of a variable, but code to be evaluated. So, to refer to global variable 'x' 
	#		you must use '{$::x}', not '::x'.
	# 		If -textvariable gives a plain name instead of code to be evaluted (no brackets, parenthesis, ::, etc.) 
	#		and the first page in 'pages' is a namespace, uses {$::dui::pages::<page>::data(<textvariable>)}. 
	#		Also in this case, if -tags is not specified, uses the textvariable name as tag.
	# All others passed through to the 'dui add_text' command
	proc add_variable { pages x y args } {
		global variable_labels
		
		set tags [args::process_tags_and_var $pages "variable" -textvariable]
		set varcmd [dui::args::get_option -textvariable "" 1]

		set main_tag [add_text $pages $x $y {*}$args]
		
		if { $varcmd ne "" } {
			foreach page $pages {
				msg [namespace current] add_variable "with tag '$main_tag' to page(s) '$page'"
				lappend variable_labels($page) [list $main_tag $varcmd]
			}
		}
		
		return $main_tag
	}
	
	
	proc add_symbol { pages x y args } {
		set symbol [dui::args::get_option -symbol "" 1]
		if { $symbol eq "" } {
			set symbol [dui::args::get_option -text "" 1]
		}
		if { $symbol eq "" } {
			return
		}
		
		set symbol [dui symbol get $symbol]
		dui::args::add_option_if_not_exists -font_family $dui::symbol::font_filename
		dui::args::add_option_if_not_exists -aspect_type symbol
		
		return [dui add_text $pages $x $y -text $symbol {*}$args]
	}
	
	# Add button items to the canvas. Returns the list of all added tags (one per page).
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
	#	-label label text, in case a label is to be shown inside the button
	#	-labelvariable, to use a variable as label text
	#	-label_pos a list with 2 elements between 0 and 1 that specify the x and y percentages where to position
	#		the label inside the button
	#	-label_* (-label_fill -label_outline etc.) are passed through to 'dui add_text' or 'dui add_variable'
	#	-symbol to add a Fontawesome symbol/icon to the button, on position -symbol_pos, and using option values
	#		given in -symbol_* that are passed through to 'dui add_symbol'
	#	-radius for rounded rectangles, and -arc_offset for rounded outline rectangles
	#	All others passed through to the respective visible button creation command.
	proc add_button { pages x y args } {
		variable debug_buttons
		set can [dui canvas]

		set cmd [dui::args::get_option -command {} 1]
		set style [dui::args::get_option -style "" 1]
		dui::args::process_aspects button $style

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
			set x1 [expr {x+100}]
		}
		if { $y1 <= 0 } {
			set y1 [expr {y+100}]
		}
		
		set rx [rescale_x_skin $x]
		set rx1 [rescale_x_skin $x1]
		set ry [rescale_y_skin $y]
		set ry1 [rescale_y_skin $y1]
				
		set tags [dui::args::process_tags_and_var $pages button {} 1]
		set main_tag [lindex $tags 0]
		set button_tags [list ${main_tag}-btn {*}[lrange $tags 1 end]]
		
		# Note this cannot be processed by 'dui item process_label' as this one processes the positioning of the
		#	label differently (inside), also we need to extract label options from the args before painting the 
		#	background button (as $args is passed to the painting proc) but not create the label until after that
		#	button has been painted.
		set label [dui::args::get_option -label "" 1]
		set labelvar [dui::args::get_option -labelvariable "" 1]
		if { $label ne "" || $labelvar ne "" } {
			set label_tags [list ${main_tag}-lbl {*}[lrange $tags 1 end]]	
			set label_args [dui::args::extract_prefixed -label_]
			set label_pos [dui::args::get_option -pos [dui aspect get button_label pos -style $style -default {0.5 0.5} \
				-default_type text] 1 label_args]
			set xlabel [expr {$x+int($x1-$x)*[lindex $label_pos 0]}]
			set ylabel [expr {$y+int($y1-$y)*[lindex $label_pos 1]}]
		}
		
		# Process symbol
		set symbol [dui::args::get_option -symbol "" 1]
		if { $symbol ne "" } {
			set symbol_tags [list ${main_tag}-sym {*}[lrange $tags 1 end]]	
			set symbol_args [dui::args::extract_prefixed -symbol_]
			set symbol_pos [dui::args::get_option -pos [dui aspect get button_symbol pos -style $style -default {0.5 0.5} \
				-default_type symbol] 1 symbol_args]
			set xsymbol [expr {$x+int($x1-$x)*[lindex $symbol_pos 0]}]
			set ysymbol [expr {$y+int($y1-$y)*[lindex $symbol_pos 1]}]
		}
				
		# As soon as the rect has a non-zero width (or maybe an outline or fill?), its "clickable" area becomes only
		#	the border, so if a visible rectangular button is needed, we have to add an invisible clickable rect on 
		#	top of it.
		if { $style eq "" && ![dui::args::has_option -shape]} {
			if { $debug_buttons == 1 } {
				set width 1
				set outline [dui aspect get button debug_outline -style $style -default "black"]
			} else {
				set width 0
			}

			if { $width > 0 } {
				$can create rect $rx $ry $rx1 $ry1 -outline $outline -width $width -tags $button_tags -state hidden
				item add_to_pages $pages [lindex $button_tags 0]
			}
		} else {		
			dui::args::remove_option -debug_outline
			set shape [dui::args::get_option -shape [dui aspect get button shape -style $style -default rect] 1]
			
			if { $shape eq "round" } {
				set fill [dui::args::get_option -fill [dui aspect get button fill -style $style]]
				set disabledfill [dui::args::get_option -disabledfill [dui aspect get button disabledfill -style $style]]
				set radius [dui::args::get_option -radius [dui aspect get button radius -style $style -default 40]]
				
				rounded_rectangle $x $y $x1 $y1 $radius $fill $disabledfill $button_tags 
				item add_to_pages $pages [lindex $button_tags 0]
			} elseif { $shape eq "outline" } {
				set outline [dui::args::get_option -outline [dui aspect get button outline -style $style]]
				set disabledoutline [dui::args::get_option -disabledoutline [dui aspect get button disabledoutline -style $style]]
				set arc_offset [dui::args::get_option -arc_offset [dui aspect get button arc_offset -style $style -default 50]]
				set width [dui::args::get_option -width [dui aspect get button width -style $style -default 3]]
				
				rounded_rectangle_outline $x $y $x1 $y1 $arc_offset $outline $disabledoutline $width $button_tags
				item add_to_pages $pages [lindex $button_tags 0]
			} else {
#				foreach aspect "fill activefill disabledfill outline disabledoutline activeoutline width" {
#					dui::args::add_option_if_not_exists -$aspect [dui aspect get button $aspect -style $style]
#				}					
				$can create rect $rx $ry $rx1 $ry1 -tags $button_tags -state hidden {*}$args
				item add_to_pages $pages [lindex $button_tags 0]
			}
		}
		
		if { $label ne "" } {
			add_text $pages $xlabel $ylabel -text $label -tags $label_tags -aspect_type button_label {*}$label_args
		} elseif { $labelvar ne "" } {
			add_variable $pages $xlabel $ylabel -textvariable $labelvar -tags $label_tags -aspect_type button_label {*}$label_args 
		}
		
		if { $symbol ne "" } {
			add_symbol $pages $xsymbol $ysymbol -text $symbol -tags $symbol_tags -aspect_type button_symbol {*}$symbol_args
		}
		
		# Clickable rect
		$can create rect $rx $ry $rx1 $ry1 -fill {} -outline black -width 0 -tags $tags -state hidden
		if { $cmd eq "" } {
			msg -WARN [namespace current] add_button "button '$main_tag' does not have a command"
		} else {
			regsub {%x0} $cmd $rx cmd
			regsub {%x1} $cmd $rx1 cmd
			regsub {%y0} $cmd $ry cmd
			regsub {%y1} $cmd $ry1 cmd
		}
		$can bind $main_tag [platform_button_press] $cmd
		
		msg -INFO [namespace current] add_button "to page(s) '$pages' with tag(s) '$tags'"
		item add_to_pages $pages $main_tag
		return $main_tag
	}
	
	# Adapted from Johanna's MimojaCafe skin code, attributed to Barney.
	proc rounded_rectangle { x0 y0 x1 y1 radius colour disabled tags } {
		set can [dui canvas]
		set x0 [rescale_x_skin $x0] 
		set y0 [rescale_y_skin $y0] 
		set x1 [rescale_x_skin $x1] 
		set y1 [rescale_y_skin $y1]
		
		$can create oval $x0 $y0 [expr $x0 + $radius] [expr $y0 + $radius] -fill $colour -disabledfill $disabled \
			-outline $colour -disabledoutline $disabled -width 0 -tags $tags -state "hidden"
		$can create oval [expr $x1-$radius] $y0 $x1 [expr $y0 + $radius] -fill $colour -disabledfill $disabled \
			-outline $colour -disabledoutline $disabled -width 0 -tags $tags -state "hidden"
		$can create oval $x0 [expr $y1-$radius] [expr $x0+$radius] $y1 -fill $colour -disabledfill $disabled \
			-outline $colour -disabledoutline $disabled -width 0 -tags $tags -state "hidden"
		$can create oval [expr $x1-$radius] [expr $y1-$radius] $x1 $y1 -fill $colour -disabledfill $disabled \
			-outline $colour -disabledoutline $disabled -width 0 -tags $tags -state "hidden"
		$can create rectangle [expr $x0 + ($radius/2.0)] $y0 [expr $x1-($radius/2.0)] $y1 -fill $colour \
			-disabledfill $disabled -disabledoutline $disabled -outline $colour -width 0 -tags $tags -state "hidden"
		$can create rectangle $x0 [expr $y0 + ($radius/2.0)] $x1 [expr $y1-($radius/2.0)] -fill $colour \
			-disabledfill $disabled -disabledoutline $disabled -outline $colour -width 0 -tags $tags -state "hidden"
	}
	
	# Inspired on Barney's rounded_rectangle, mimic DSx buttons showing a button outline without a fill.
	proc rounded_rectangle_outline { x0 y0 x1 y1 arc_offset colour disabled width tags } {
		set can [dui canvas]
		set x0 [rescale_x_skin $x0] 
		set y0 [rescale_y_skin $y0] 
		set x1 [rescale_x_skin $x1] 
		set y1 [rescale_y_skin $y1]
	
		$can create arc [expr $x0] [expr $y0+$arc_offset] [expr $x0+$arc_offset] [expr $y0] -style arc -outline $colour \
			-width [expr $width-1] -tags $tags -start 90 -disabledoutline $disabled -state "hidden"
		$can create arc [expr $x0] [expr $y1-$arc_offset] [expr $x0+$arc_offset] [expr $y1] -style arc -outline $colour \
			-width [expr $width-1] -tags $tags -start 180 -disabledoutline $disabled -state "hidden"
		$can create arc [expr $x1-$arc_offset] [expr $y0] [expr $x1] [expr $y0+$arc_offset] -style arc -outline $colour \
			-width [expr $width-1] -tags $tags -start 0 -disabledoutline $disabled -state "hidden"
		$can create arc [expr $x1-$arc_offset] [expr $y1] [expr $x1] [expr $y1-$arc_offset] -style arc -outline $colour \
			-width [expr $width-1] -tags $tags -start -90 -disabledoutline $disabled -state "hidden"
		
		$can create line [expr $x0+$arc_offset/2] [expr $y0] [expr $x1-$arc_offset/2] [expr $y0] -fill $colour \
			-width $width -tags $tags -disabledfill $disabled -state "hidden"
		$can create line [expr $x1] [expr $y0+$arc_offset/2] [expr $x1] [expr $y1-$arc_offset/2] -fill $colour \
			-width $width -tags $tags -disabledfill $disabled -state "hidden"
		$can create line [expr $x0+$arc_offset/2] [expr $y1] [expr $x1-$arc_offset/2] [expr $y1] -fill $colour \
			-width $width -tags $tags -disabledfill $disabled -state "hidden"
		$can create line [expr $x0] [expr $y0+$arc_offset/2] [expr $x0] [expr $y1-$arc_offset/2] -fill $colour \
			-width $width -tags $tags -disabledfill $disabled -state "hidden"		
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
	#	-label_* passed through to add_text 
	proc add_widget { pages type x y args } {
#		global widget_cnt	
		set can [dui canvas]
		set rx [rescale_x_skin $x]
		set ry [rescale_y_skin $y]
		
		set tags [args::process_tags_and_var $pages $type "" 0 args 0]
		set main_tag [lindex $tags 0]
		
		set widget $can.$main_tag
		if { [info exists ::$widget] } {
			set msg "$type widget with name '$widget' already exists"
			msg -ERROR [namespace current] $msg
			error $msg
			return
		}
		
		set style [dui::args::get_option -style "" 1]
		foreach a [dui aspect list -type $type -style $style] {
			#msg [namespace current] add_widget "type=$type, style=$style, a=$a"
			dui::args::add_option_if_not_exists -$a [dui aspect get $type $a -style $style]
		}

		dui::args::process_font $type $style

		# Options that are to be passed to the 'canvas create' command instead of the widget creation command.
		# Using this we can modify the canvas item anchor, or use pixel widths & heights for text widgets like
		#	entries or listboxes.
		set canvas_args [dui::args::extract_prefixed -canvas_]
		dui::args::add_option_if_not_exists -anchor nw canvas_args
		if { [dui::args::has_option -width canvas_args] } {
			dui::args::add_option_if_not_exists -width [rescale_x_skin [dui::args::get_option -width 0 1 canvas_args]] canvas_args 
		}
		if { [dui::args::has_option -height canvas_args] } {
			dui::args::add_option_if_not_exists -height [rescale_y_skin [dui::args::get_option -height 0 1 canvas_args]] canvas_args 
		}				
		if { $type eq "scrollbar" } {
			# From the original add_de1_widget, why this?
			dui::args::add_option_if_not_exists -height 245 canvas_args
		}
		
		dui::args::process_label $pages $x $y $type $style
		
		dui::args::remove_option -tags
		set tclcode [dui::args::get_option -tclcode "" 1]
		try {
			$type $widget {*}$args
		} on error err {
			set msg "can't create $type widget '$widget' on page(s) '$pages': $err"
			msg -ERROR [namespace current] $msg
			error $msg
			return			
		}
			
		# BLT on android has non standard defaults, so we overrride them here, sending them back to documented defaults
		if {$type eq "graph" && ($::android == 1 || $::undroid == 1)} {
			$widget grid configure -dashes "" -color #DDDDDD -hide 0 -minor 1 
			$widget configure -borderwidth 0
			#$widget grid configure -hide 0
		}
	
		# Additional code to run when creating this widget, such as chart configuration instructions
		# EB: TBD This is inherited from the original code, but can't eval have problems here? It may redefine local 
		#	variables like $x, $pages, etc.
		#	Probably safer to do a %W expansion, then eval in a global context or something.	
		if { $tclcode ne "" } {
			try {  
				eval $tclcode
			} on error err {
				set msg "error evaluating tclcode for $type widget '$widget' \{ $tclcode \}: $err"
				msg -ERROR [namespace current] $msg 
				error $msg
				return
			}
		}
		
		try {
			set windowname [$can create window  $rx $ry -window $widget -tags $tags -state hidden {*}$canvas_args]
		} on error err {
			set msg "can't add $type widget '$widget' in page(s) '$pages' to canvas: $err"
			msg -ERROR [namespace current] $msg
			error $msg
			return
		}
			
		# EB: Maintain this? I don't find any use of this array in the app code
		#set ::tclwindows($widget) [list $x $y]
		msg -INFO [namespace current] add_widget "$type to page(s) '$pages' with tag(s) '$tags' and args '$args'"
		
		item add_to_pages $pages $main_tag
		return $widget
	}
	
	# Add a text entry box. Adds validation and full page editor call on top of add_widget.
	#
	# Named options:
	#  -data_type if 'numeric' and -vcmd is undefined, adds validation based on the following parameters:
	#  -n_decimals number of decimals allowed. Defaults to 0 if undefined.
	#  -min_value minimum value accepted
	#  -max_value maximum value accepted
	#  -small_increment small increment used on clicker controls. Not used by default, but is passed to page editors
	#		if the -editor_page option is specified 
	#  -big_increment big increment used on clicker controls. Not used by default, but is passed to page editors
	#		if the -editor_page option is specified
	#  -default_value Default value passed to the page editor if the -editor_page option is specified
	#  -trim if 1, trims leading and trailing whitespace after editing the value. Defaults to the value of 
	#		$dui::trim_entries.
	#  -editor_page A page name that serves as a full page editor for the value, or "1" to use the default page
	#		editor if it defined for the -data_type. The first argument of that page must be the fully qualified name 
	#		of the variable that holds the value.
	proc add_entry { pages x y args } {
		set tags [args::process_tags_and_var $pages entry -textvariable 1]
		set main_tag [lindex $tags 0]
		
#		set style [dui::args::get_option -style "" 0]
		
		# Data type and validation
		set data_type [dui::args::get_option -data_type "text" 1]
		set n_decimals [dui::args::get_option -n_decimals 0 1]
		set trim  [dui::args::get_option -trim $::dui::trim_entries 1]
		set editor_page [dui::args::get_option -editor_page $::dui::use_editor_pages 1]
		foreach fn {min_value max_value small_increment big_increment default_value} {
			set $fn [dui::args::get_option -$fn "" 1]
		}
		
		if { ![dui::args::has_option -vcmd] } {
			set vcmd ""
			if { $data_type eq "numeric" } {
				set vcmd [list ::dui::validate_numeric %P $n_decimals $min_value $max_value]
			}
			
			if { $vcmd ne "" } {
				dui::args::add_option_if_not_exists -vcmd $vcmd
				dui::args::add_option_if_not_exists -validate key
			}
		}
		
		set widget [dui add_widget $pages entry $x $y {*}$args]
	
		# Default actions on leaving a text entry: Trim text, format if needed, and hide_android_keyboard
		bind $widget <Return> { dui hide_android_keyboard ; focus [tk_focusNext %W] }
		
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
			append leave_cmd "dui hide_android_keyboard;"
			bind $widget <Leave> $leave_cmd
		}
		
		# Invoke editor page on double tap (maybe other editors in the future, e.g. a date editor)		
		if { $editor_page ne "" && ![string is false $editor_page] && $textvariable ne ""} {
			set editor_cmd ""
			if { [string is true $editor_page] && $data_type eq "numeric" } {
				set editor_cmd ::dui::pages::numeric_editor::load_page 
			} elseif { ![string is true $editor_page] } {
				set editor_cmd $editor_page
			}

			if { $editor_cmd ne "" } {
				set editor_cmd "if \{ \[$widget cget -state\] eq \"normal\" \} \{ 
					$editor_cmd $textvariable -n_decimals $n_decimals -min_value $min_value -max_value $max_value \
						-default_value $default_value -small_increment $small_increment -big_increment $big_increment
				\}"
				bind $widget <Double-Button-1> $editor_cmd
			}
		}
			
		return $widget
	}
	
	#  Adds a checkbox using Fontawesome symbols (which can be resized to any font size) instead of the tiny Tk 
	#	checkbutton.
	# Named options:
	#	-textvariable the name of the boolean variable to map the checkbox to.
	#	-command optional tcl code to run when the checkbox is clicked. 
	proc add_checkbox { pages x y args } {
		set tags [args::process_tags_and_var $pages checkbox -textvariable 1]
		set main_tag [lindex $tags 0]
		
		set style [dui::args::get_option -style "" 0]
		dui::args::process_font checkbox $style
		set checkvar [dui::args::get_option -textvariable "" 1]
		dui::args::process_label $pages $x $y checkbox $style
		set cmd [dui::args::get_option -command "" 1]
		if { $checkvar ne "" } {
			set cmd "if { \[string is true \$$checkvar\] } { set $checkvar 0 } else { set $checkvar 1 }; $cmd"
		}
		
		dui add_variable $pages $x $y -textvariable \
			"\[lindex \$::dui::symbol::checkbox_symbols_map \[string is true \$$checkvar\]\]" {*}$args

		set button_tags [list ${main_tag}-btn {*}[lrange $tags 1 end]]		
		dui add_button $pages [expr {$x-5}] [expr {$y-5}] [expr {$x+60}] [expr {$y+60}] ] -tags $button_tags -command $cmd
		
		return $main_tag
	}
	
	proc add_listbox { pages x y args } {
		set tags [args::process_tags_and_var $pages listbox -listvariable 1]
		set main_tag [lindex $tags 0]
		
		set style [dui::args::get_option -style "" 0]
		set width [dui::args::get_option -width "" 1]
		if { $width ne "" } {
			dui::args::add_option_if_not_exists -width [expr {int($width * $::globals(entry_length_multiplier))}]
		}

		set ysb [dui::args::process_yscrollbar $pages $x $y listbox $style]
		if { $ysb != 0 && ![dui::args::has_option -yscrollcommand] } {
			dui::args::add_option_if_not_exists -yscrollcommand \
				"::dui::item::scale_scroll $main_tag ::dui::item::sliders($main_tag)"
		}
		
		return [dui add_widget $pages listbox $x $y {*}$args]
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
	
	# Computes the anchor point coordinates with respect to the provided bounding box coordinates, returns a list 
	#	with 2 elements.
	# Anchor valid values are center, n, ne, e, se, s, sw, w, nw.
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

	# Moves a text widget with respect to another, i.e. to a position relative to another one.
	# pos can be any of "n", "nw", "ne", "s", "sw", "se", "w", "wn", "ws", "e", "en", "es".
	# xoffset and yoffset define a fixed offset with respect to the coordinates obtained from processing 'pos'. 
	#	Can be positive or negative.
	# anchor is how to position the text widget relative to the point obtained after processing pos & offsets. Takes the
	#	same values as the standard -anchor option. If not defined, keeps the existing widget -anchor.
	# move_too is a list of other widgets that will be repositioned together with widget, maintaining the same relative
	#	distances to widget as they had originally. Typically used for the rectangle "button" areas around text labels.
	proc relocate_text_wrt { widget wrt { pos w } { xoffset 0 } { yoffset 0 } { anchor {} } { move_too {} } } {
		set can [dui canvas]
		lassign [$can bbox $wrt ] x0 y0 x1 y1 
		lassign [$can bbox $widget ] wx0 wy0 wx1 wy1
		
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
			catch { $can itemconfigure $widget -anchor $anchor }
		}
		# Don't use 'moveto' as then -anchor is not acknowledged
		$can coords $widget "$newx $newy"
		
		if { $move_too ne "" } {
			lassign [$can bbox $widget] newx newy
			
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
			set width [rescale_x_skin [expr {$x1-$x0}]]
			set height [rescale_y_skin [expr {$y1-$y0}]]
			
			set target_width 0
			if { [info exists opts(-width)] } {
				set target_width [rescale_x_skin $opts(-width)]
			} elseif { [info exists opts(-max_width)] && $width > [rescale_x_skin $opts(-max_width)]} {
				set target_width [rescale_x_skin $opts(-max_width)] 
			} elseif { [info exists opts(-min_width)] && $width < [rescale_x_skin $opts(-min_width)]} {
				set target_width [rescale_x_skin $opts(-min_width)]
			}
			if { $target_width > 0 } {
				$can itemconfigure $w -width $target_width
			}
			
			set target_height 0
			if { [info exists opts(-height)] } {
				set target_height [rescale_y_skin $opts(-height)]
			} elseif { [info exists opts(-max_height)] && $height > [rescale_y_skin $opts(-max_height)]} {
				set target_height [rescale_y_skin $opts(-max_width)] 
			} elseif { [info exists opts(-min_height)] && $height < [rescale_y_skin $opts(-min_height)]} {
				set target_height [rescale_y_skin $opts(-min_height)]
			}
			if { $target_height > 0 } {
				$can itemconfigure $w -height $target_height
			}
		}
	}
		
	proc hide_android_keyboard {} {
		# make sure on-screen keyboard doesn't auto-pop up, and if
		# physical keyboard is connected, make sure navbar stays hidden
		sdltk textinput off
		focus .can
	}
		
}


# General utilities
# Returns the list with duplicates removed, keeping the original list sorting of elements, unlike 'lsort -unique'.
# See discussion in https://wiki.tcl-lang.org/page/Unique+Element+List
proc unique_list {list} {
	set new {}
	foreach item $list {
		if { $item ni $new } {
			lappend new $item
		}
	}
	return $new
}

dui init