package require de1 1.0

if {$::android != 1} {
	set ::settings(ghc_is_installed) 0
}

set ::off_page "off"
set ::espresso_page "espresso"

set ghc_pos_pffset 0
if {$::settings(ghc_is_installed) == 0} { 
	set ghc_pos_pffset 217
}


if {[info exists ::streamline_dark_mode] != 1} {
	set ::streamline_dark_mode 0
}

::de1::event::listener::after_flow_complete_add [lambda {event_dict} { streamline_shot_ended } ]

if {$::streamline_dark_mode == 0} {
	set ::profile_title_color #385a92
	set ::scale_disconnected_color #cd5360
	set ::profile_button_background_selected_color #385992
	set ::left_label_color2 #385992

	set ::progress_bar_red "#DA515E"
	set ::progress_bar_green "#0CA581"
	set ::progress_bar_grey "#c2c2c2"
	
	set ::plus_minus_text_color #121212
	set ::plus_minus_value_text_color #121212
	set ::data_card_title_text_color #707485
	set ::data_card_text_color #121212
	set ::dataline_label_color #707485
	set ::dataline_data_color #121212
	set ::background_color "#FFFFFF"
	set ::profile_button_background_color "#FFFFFF"
	set ::profile_button_button_color "#5f7ba8"
	set ::profile_button_button_selected_color "#e8e8e8"
	set ::profile_button_outline_color "#c5cdda"
	set ::ghc_button_background_color "#FFFFFF"
	set ::button_inverted_text_color "#FFFFFF"
	set ::status_clickable_text "#1967d4"
	set ::box_color "#f6f8fa"
	#set ::box_line_color #c9c9c9
	set ::box_line_color #e8e8e8
	set ::settings_sleep_button_outline_color "#3d5782"
	set ::settings_sleep_button_color "#f6f8fa"
	set ::settings_sleep_button_text_color "#385a92"
	set ::plus_minus_outline_color $::box_color
	set ::plus_minus_flash_on_color  "#b8b8b8"
	set ::plus_minus_flash_on_color2  "#cfcfcf"
	set ::plus_minus_flash_off_color "#ededed"
	set ::plus_minus_flash_refused_color "#e34e4e"
	set ::ghc_button_color "#375a92"
	set ::preset_value_color "#AAAAAA"
	set ::preset_label_selected_color "#777777"
	set ::blink_button_color "#395ab9"

	set ::ghc_button_outline  $::box_color
	set ::ghc_disabled_button_outline  "#c5d0df"
	set ::ghc_disabled_button_text  "#c5d0df"
	set ::ghc_disabled_button_fill "#f8fafb"	
	set ::ghc_enabled_stop_button_outline  "#efd7db"
	set ::ghc_enabled_stop_button_fill  "#efd7db"
	set ::ghc_enabled_button_fill "#f8fafb"
	set ::ghc_enabled_stop_button_text_color "#f9f8fc"
	set ::ghc_disabled_stop_button_text_color "#f9f8fc"
	set ::ghc_enabled_stop_button_fill_color "#da515e"	

	set ::profile_button_not_selected_color "#607aa7"

	# the espresso chart

	set ::pressurelinecolor "#17c29a"
	set ::flow_line_color "#0358cf"
	set ::pressurelinecolor_goal "#a0e0d1"
	set ::flow_line_color_goal "#bed9ff"
	set ::temperature_line_color "#ff97a1"
	set ::temperature_line_color_goal "#ffd1d5"
	set ::weightlinecolor "#e9d3c3"
	set ::state_change_color "#7c7c7c"
	set ::chart_background $::background_color
	set ::pressurelabelcolor "#959595"
	set ::temperature_label_color "#959595"
	set ::flow_label_color "#1767d4"
	set ::grid_color "#E0E0E0"

} else {

	set ::progress_bar_red "#DA515E"
	set ::progress_bar_green "#0CA581"
	set ::progress_bar_grey "#c2c2c2"

	#set ::profile_title_color #415996
	set ::profile_title_color #e8e8e8
	set ::scale_disconnected_color #cd5360
	set ::profile_button_background_selected_color #415996
	set ::left_label_color2 #415996

	set ::plus_minus_text_color #959595
	set ::plus_minus_value_text_color #e8e8e8
	set ::data_card_text_color #e8e8e8
	set ::data_card_title_text_color #707485
	set ::dataline_label_color #707485
	set ::dataline_data_color #e8e8e8
	set ::background_color #0d0e14

	set ::box_color "#17191e"

	set ::profile_button_background_color #292c38
	set ::profile_button_button_color "#e8e8e8"
	set ::profile_button_button_selected_color "#e8e8e8"
	set ::profile_button_outline_color $::box_color
	set ::profile_button_not_selected_color "#e8e8e8"

set ::ghc_button_background_color "#6576a0"
set ::button_inverted_text_color "#FFFFFF"
	set ::status_clickable_text "#415996"
	set ::box_line_color #000000
	set ::settings_sleep_button_outline_color $::box_color
	set ::settings_sleep_button_color "#101117"
	set ::settings_sleep_button_text_color "#e8e8e8"

	#set ::plus_minus_outline_color "#101115"
	set ::plus_minus_outline_color $::box_color
set ::plus_minus_flash_on_color  "#272A34"
set ::plus_minus_flash_on_color2  "#1a1d25"
set ::plus_minus_flash_off_color "#101115"
set ::plus_minus_flash_refused_color "#e34e4e"
set ::ghc_button_color "#e8e8e8"
	set ::preset_value_color #4e5559
	set ::preset_label_selected_color "#999999"
set ::blink_button_color "#395ab9"

	set ::ghc_button_outline  $::box_color
	set ::ghc_disabled_button_outline  $::box_color
	set ::ghc_disabled_button_text  "#202635"
	set ::ghc_disabled_button_fill "#101115"	
	set ::ghc_enabled_stop_button_outline  $::box_color
	set ::ghc_enabled_stop_button_fill  "#3a252b"
	set ::ghc_enabled_button_fill "#f8fafb"
	set ::ghc_enabled_stop_button_text_color "#e8e8e8"
	set ::ghc_disabled_stop_button_text_color "#5d5050"
	set ::ghc_enabled_stop_button_fill_color "#db515d"	


# the espresso chart

	set ::pressurelinecolor "#17c29a"
	set ::flow_line_color "#0358cf"
	set ::pressurelinecolor_goal "#374d47"
	set ::flow_line_color_goal "#23416c"
	set ::temperature_line_color "#653f43"
	set ::temperature_line_color_goal "#3e3233"
	set ::weightlinecolor "#695f57"
	set ::state_change_color "#7f8bbb"
	set ::chart_background $::background_color
	set ::pressurelabelcolor "#606579"
	set ::temperature_label_color "#959595"
	set ::flow_label_color "#1767d4"
	set ::grid_color "#959595"
	set ::grid_color "#212227"


}


##############################################################################################################################################################################################################################################################################
# STREAMLINE SKIN
##############################################################################################################################################################################################################################################################################

# you should replace the JPG graphics in the 2560x1600/ directory with your own graphics. 
source "[homedir]/skins/default/standard_includes.tcl"

#load_font "Inter-Regular10" "[homedir]/Streamline/Inter-Regular.ttf" 11

# Left column labels
load_font "Inter-Bold16" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 14

# GHC buttons
load_font "Inter-Bold12" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 12

# Profile buttons
load_font "Inter-Bold11" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 12

# status

if {$::undroid == 1} {
	load_font "Inter-Bold18" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 12
} else {
	load_font "Inter-Bold18" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 13
}


# status bold
load_font "Inter-SemiBold18" "[homedir]/skins/Streamline/Inter-Bold.ttf" 13

# +/- buttons
load_font "Inter-Bold24" "[homedir]/skins/Streamline/Inter-ExtraLight.ttf" 29

# profile 
load_font "Inter-HeavyBold24" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 17

# X and Y axis font
load_font "Inter-Regular20" "[homedir]/skins/Streamline/Inter-Regular.ttf" 12

# X and Y axis font
load_font "Inter-Regular12" "[homedir]/skins/Streamline/Inter-Regular.ttf" 12

# X and Y axis font
load_font "Inter-Regular10" "[homedir]/skins/Streamline/Inter-Regular.ttf" 10

load_font "Inter-Regular6" "[homedir]/skins/Streamline/Inter-Regular.ttf" 6

# Scale disconnected msg
load_font "Inter-Black18" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 14

# Vertical bar in top right buttons
load_font "Inter-Thin14" "[homedir]/skins/Streamline/Inter-Thin.ttf" 14

# button icon font
load_font "icomoon" "[homedir]/skins/Streamline/icomoon.ttf" 30

# mono data card
load_font "mono8" "[homedir]/skins/Streamline/NotoSansMono-SemiBold.ttf" 10
load_font "mono10" "[homedir]/skins/Streamline/NotoSansMono-SemiBold.ttf" 12

if {$::undroid == 1} {
	load_font "mono12" "[homedir]/skins/Streamline/NotoSansMono-SemiBold.ttf" 12
} else {
	load_font "mono12" "[homedir]/skins/Streamline/NotoSansMono-SemiBold.ttf" 13
}

# mono data card
load_font "mono10bold" "[homedir]/skins/Streamline/NotoSansMono-ExtraBold.ttf" 12

set ::pages [list off espresso water flush steam hotwaterrinse info]
set ::zoomed_pages [list off_zoomed espresso_zoomed]
set ::all_pages [list off off_zoomed espresso_zoomed steam espresso water flush info hotwaterrinse]
#set ::pages_not_off [list steam espresso water flush info hotwaterrinse]

set ::streamline_hotwater_btn_mode "ml"

dui page add $::all_pages -bg_color $::background_color

# load a default profile if none is loaded
if {[ifexists ::settings(profile_filename)] == ""} {
	select_profile "default"

}

if {$::android != 1} {
	proc cause_random_data {} {
		set x [steamtemp]
		set x [pressure]
		set x [watertemp]
		set x [waterflow]
		set x [water_mix_temperature]
		after 1000 cause_random_data
	}
	cause_random_data
}



##################################################################################################
# UI related convenience procs below, moved over from Mimoja Cafe so they can be generally used

proc streamline_rectangle {contexts x1 y1 x2 y2 colour {tags {}}} {

	if {$tags != ""} {
		dui add canvas_item rect $contexts $x1 $y1 $x2 $y2 -fill $colour -width 0 -tags $tags
	} else {
		dui add canvas_item rect $contexts $x1 $y1 $x2 $y2 -fill $colour -width 0
	}
}



proc streamline_rounded_rectangle {contexts x1 y1 x2 y2 colour angle {tags {}}} {

	if {$tags != ""} {
		dui add shape round $contexts $x1 $y1 -bwidth [expr {$x2 - $x1}] -bheight [expr {$y2 - $y1}] -radius "$angle $angle $angle $angle" -fill $colour -tags $tags
	} else {
		dui add shape round $contexts $x1 $y1 -bwidth [expr {$x2 - $x1}] -bheight [expr {$y2 - $y1}] -radius "$angle $angle $angle $angle" -fill $colour 
	}
}





############################################################################################################################################################################################################
# draw the background shapes

# white background
streamline_rectangle $::all_pages 0 0 2560 1600 $::background_color

# top grey box
streamline_rectangle $::all_pages 0 0 2560 220 $::box_color
#streamline_rectangle $::zoomed_pages 0 0 2560 220 $::box_color

# left grey box
streamline_rectangle $::pages 0 220 626 1600 $::box_color

#  grey line on the left
streamline_rectangle $::pages 626 220 626 1600 $::box_line_color

# grey lines on the left bar
streamline_rectangle $::pages 0 687 626 687 $::box_line_color
streamline_rectangle $::pages 0 913 626 913 $::box_line_color
streamline_rectangle $::pages 0 1139 626 1139 $::box_line_color
streamline_rectangle $::pages 0 1365 626 1365 $::box_line_color


# grey horizontal line 
streamline_rectangle $::pages  626 418 2560 418 $::box_line_color
streamline_rectangle $::zoomed_pages  0 418 2560 418 $::box_line_color

#  grey line on the bottom
streamline_rectangle $::pages 626 1274 2560 1274 $::box_line_color

#  vertical grey line in data card
streamline_rectangle $::pages 1151 1274 1151 1600 $::box_line_color



if {$::settings(ghc_is_installed) == 0} { 
	#
	streamline_rectangle $::pages 2319 220 2600 1274 $::box_color
	streamline_rectangle $::pages 2319 220 2319 1274 $::box_line_color
	streamline_rectangle $::zoomed_pages 2319 220 2600 1600 $::box_color
	streamline_rectangle $::zoomed_pages 2319 220 2319 1600 $::box_line_color
}


streamline_rectangle $::all_pages 0 220 2560 220 $::box_line_color


############################################################################################################################################################################################################

proc streamline_adjust_grind { args } {

	if {$args == "-"} {
		if {$::settings(grinder_setting) > 0} {
			set ::settings(grinder_setting) [round_to_one_digits [expr {$::settings(grinder_setting) - .1}]]
			#save_profile_and_update_de1_soon
		}
	} elseif {$args == "+"} {
		if {$::settings(grinder_setting) < 1000} {
			set ::settings(grinder_setting) [round_to_one_digits [expr {$::settings(grinder_setting) + .1}]]
			#save_profile_and_update_de1_soon
		}
	}

	#save_profile 0
	#puts "ERROR streamline_adjust_grind $args"

	#::refresh_$::toprightbtns
}

############################################################################################################################################################################################################
# top right line with profile name and various text labels that are buttons


if {[ifexists ::settings(grinder_setting)] == ""} {
	set ::settings(grinder_setting) 0
}


proc back_from_settings {} {
	refresh_favorite_profile_button_labels
}


set ::streamline_needs_final_datacard_update 0
proc streamline_profile_title {} {

	update_streamline_status_message

	set this_state [::de1::state::current_state]
	set this_substate [::de1::state::current_substate]

	#puts "ERROR set this_state [::de1::state::current_state]  - this_substate [::de1::state::current_substate]"
	if {$this_state == "Espresso"} {
		if {$this_substate == "preinfusion" || $this_substate == "pouring"} {
			update_datacard_from_live_data
			set ::streamline_needs_final_datacard_update 1
		}

		#return "[ifexists ::settings(profile_title)]: [translate $this_substate]"
		#return "[ifexists ::settings(profile_title)]: [translate $this_substate]"

	} elseif {$::streamline_needs_final_datacard_update == 1} {
		set ::streamline_needs_final_datacard_update 0
		 update_datacard_from_live_data				
	}

	return [ifexists ::settings(profile_title)]
}

proc update_datacard_from_live_data {} {
	#puts "ERROR espresso_elapsed [espresso_state_change length]"

	catch {
		set past_shot_array(espresso_elapsed) [espresso_elapsed range 0 end]
		set past_shot_array(espresso_pressure) [espresso_pressure range 0 end]
		set past_shot_array(espresso_weight) [espresso_weight range 0 end]
		set past_shot_array(espresso_flow) [espresso_flow range 0 end]
		set past_shot_array(espresso_flow_weight) [espresso_flow_weight range 0 end]
		set past_shot_array(espresso_temperature_basket) [espresso_temperature_basket range 0 end]
		set past_shot_array(espresso_water_dispensed) [espresso_water_dispensed range 0 end]
		set past_shot_array(espresso_state_change) [espresso_state_change range 0 end]
	}

	catch {
		update_data_card past_shot_array
	}
}

add_de1_variable $::pages 690 256 -justify left -anchor "nw" -font Inter-HeavyBold24 -fill $::profile_title_color -width [rescale_x_skin 1200] -textvariable {[streamline_profile_title]} 
add_de1_variable $::zoomed_pages 50 256 -justify left -anchor "nw" -font Inter-HeavyBold24 -fill $::profile_title_color -width [rescale_x_skin 1200] -textvariable {[streamline_profile_title]} 


set ::streamline_global(status_msg_progress_red) ""
set ::streamline_global(status_msg_progress_green) ""
set ::streamline_global(status_msg_progress_grey) ""

set ::streamline_progress_line [add_de1_rich_text $::all_pages [expr {2490 - $ghc_pos_pffset}] 344 right 0 1 45 $::background_color [list \
	[list -text {$::streamline_global(status_msg_progress_green)}  -font "Inter-Regular6" -foreground $::progress_bar_green  ] \
	[list -text {$::streamline_global(status_msg_progress_red)}  -font "Inter-Regular6" -foreground $::progress_bar_red  ] \
	[list -text {$::streamline_global(status_msg_progress_grey)}  -font "Inter-Regular6" -foreground $::progress_bar_grey ] \
]]


############################################################################################################################################################################################################
# The status message on the top right. Might be clickable.

set ::streamline_global(status_msg_text_red) ""
set ::streamline_global(status_msg_text_green) ""
set ::streamline_global(status_msg_clickable) ""


proc streamline_status_msg_click {} {
	puts "ERROR TAPPED $::streamline_global(status_msg_clickable)"	
}

set ::streamline_data_line [add_de1_rich_text $::all_pages [expr {2516 - $ghc_pos_pffset}] 256 right 0 1 30 $::background_color [list \
	[list -text {$::streamline_global(status_msg_text_green)}  -font "Inter-HeavyBold24" -foreground $::progress_bar_green  ] \
	[list -text {$::streamline_global(status_msg_text_red)}  -font "Inter-HeavyBold24" -foreground $::progress_bar_red  ] \
	[list -text "   " -font "Inter-Black18"] \
	[list -text {$::streamline_global(status_msg_clickable)}  -font "Inter-HeavyBold24" -foreground $::status_clickable_text -exec "streamline_status_msg_click" ] \
]]

#trace add variable ::streamline_global(status_msg_text_green) write ::refresh_$::streamline_data_line
#trace add variable ::streamline_global(status_msg_text_red) write ::refresh_$::streamline_data_line



############################################################################################################################################################################################################



############################################################################################################################################################################################################
# The Mix/Group/Steam/Tank status line



set btns ""
lappend btns \
	[list -text "Mix" -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[lindex [return_temperature_measurement [water_mix_temperature] 1 1] 0]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text {[lindex [return_temperature_measurement [water_mix_temperature] 1 1] 1]} -font "mono8" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-SemiBold18"] \
	[list -text "Group" -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-SemiBold18"] \
	[list -text {[lindex [return_temperature_measurement [group_head_heater_temperature] 1 1] 0]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text {[lindex [return_temperature_measurement [group_head_heater_temperature] 1 1] 1]} -font "mono8" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-Bold16"] \
	[list -text "Steam" -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-SemiBold18"] \
	[list -text {[lindex [return_temperature_measurement [steam_heater_temperature] 1 1] 0]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text {[lindex [return_temperature_measurement [steam_heater_temperature] 1 1] 1]} -font "mono8" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-Bold16"] \
	[list -text "Tank" -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold16"] \
	[list -text {[round_to_tens [water_tank_level_to_milliliters $::de1(water_level)]]} -font "mono12" -foreground $::dataline_data_color  ] \
	[list -text {[translate ml]} -font "mono8" -foreground $::dataline_data_color  ] \
	[list -text "    " -font "Inter-Bold16"] \
	[list -text "Time" -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[time_format [clock seconds]]} -font "mono12" -foreground $::dataline_data_color   ] 

if {$::settings(scale_bluetooth_address) != ""} {
	lappend btns [list -text "    " -font "Inter-Bold16"] 
	lappend btns [list -text "Weight" -font "Inter-Bold18" -foreground $::status_clickable_text  -exec "::device::scale::tare; popup [translate Tare]" ] 
	lappend btns [list -text " " -font "Inter-Bold16"  -exec "::device::scale::tare; popup [translate Tare]" ]
	lappend btns [list -text {[lindex [return_weight_measurement_grams $::de1(scale_sensor_weight) 0 1] 0]} -font "mono12" -foreground $::dataline_data_color  -exec "::device::scale::tare; popup [translate Tare]" ]
	lappend btns [list -text {[lindex [return_weight_measurement_grams $::de1(scale_sensor_weight) 0 1] 1]} -font "mono8" -foreground $::dataline_data_color  -exec "::device::scale::tare; popup [translate Tare]" ]
}


set ::streamline_status_msg [add_de1_rich_text $::pages 690 330 left 1 2 65 $::background_color $btns ]
set ::streamline_status_msg_zoomed [add_de1_rich_text $::zoomed_pages 50 330 left 1 2 65 $::background_color $btns ]

proc percent_to_bar { perc } {
	if {$delta_percent < 96} {
		set red_msg [translate "Heating"]
		set green_msg ""
		set times_red [round_to_integer [expr {$delta_percent / 5}]]
		set times_grey [expr {20 - $times_red}]

		set red_progress [string repeat █ $times_red]
		set green_progress ""
		set grey_progress [string repeat █ $times_grey]
		set updated 1
	} else {
		set green_msg [translate "Ready"]
		set red_msg ""

		set red_progress ""
		set grey_progress ""
		set green_progress ""
		set updated 1
	}

}

proc update_streamline_status_message {} {
	#msg -ERROR "update_streamline_status_message [dui page current]"
	set red_progress ""
	set red_msg ""
	set green_msg ""
	set delta_percent 0

	if {[dui page current] == "off" || [dui page current] == "off_zoomed"} {

		set green_progress ""
		set red_progress ""
		set grey_progress ""		

		set num $::de1(substate)
		set substate_txt $::de1_substate_types($num)
		set delta_percent [expr {int(100 * ((1.0*[group_head_heater_temperature]) / [setting_espresso_temperature]))}]
		set bars [round_to_integer [expr {1+ ($delta_percent / 5)}]]

		if {$::de1(device_handle) == 0} {
			set red_msg [translate "Wait"]
		} elseif {$substate_txt == "ready"} {
			set green_msg [translate "Ready"]
			set green_progress [string repeat █ $bars]
		} else {
			set red_msg [translate "Heating"]
			set red_progress [string repeat █ $bars]
		}

		set bars_grey [expr {20 - $bars}]
		set grey_progress [string repeat █ $bars_grey]

		#msg -ERROR "current: [group_head_heater_temperature] / [setting_espresso_temperature]=delta_percent:$delta_percent"

	} else {

		if {[dui page current] == "espresso" || [dui page current] == "espresso_zoomed" } {

			set green_msg [subst {[translate [string totitle [::de1::state::current_substate]]] ($::settings(current_frame_description))}]

			set final_target [determine_final_weight]
			
			if {$::settings(scale_bluetooth_address) != ""} {
				set current_weight $::streamline_extraction_weight
			} else {
				set current_weight $::streamline_extraction_volume
			}

			if {$current_weight == ""} {
				set current_weight 0
			}

			set delta_percent 0
			catch {
				set delta_percent [expr {int(100 * ((1.0*$current_weight) / $final_target))}]
			}

			#msg -ERROR "current: $current_weight final_target:$final_target delta_percent:$delta_percent"
		} elseif {[dui page current] == "hotwaterrinse" } {

			set green_msg [translate "Flushing"]
			set final_target $::settings(flush_seconds)
			
			set current [flush_pour_timer]		

			set green_msg [subst {[translate "Flushing:"] $current[translate s]}]

			if {$current == ""} {
				set current 0
			}

			set delta_percent 0
			catch {
				set delta_percent [expr {int(100 * ((1.0*$current) / $final_target))}]
			}
			#puts "current: $current final_target:$final_target delta_percent:$delta_percent"
			
		} elseif {[dui page current] == "steam" } {
			

			set current [steam_pour_timer]		
			
			set green_msg [subst {[translate "Steaming:"] $current[translate s]}]
			set final_target $::settings(steam_timeout)
			
			if {$current == ""} {
				set current 0
			}

			set delta_percent 0
			catch {
				set delta_percent [expr {int(100 * ((1.0*$current) / $final_target))}]
			}
			#puts "current: $current final_target:$final_target delta_percent:$delta_percent"
			
		} elseif {[dui page current] == "water" } {

			set current [watervolume]		
			set green_msg [subst {[translate "Hot water:"] $current[translate s]}]

			set final_target $::settings(water_volume)
			
			if {$current == ""} {
				set current 0
			}

			set delta_percent 0
			catch {
				set delta_percent [expr {int(100 * ((1.0*$current) / $final_target))}]
			}
			#puts "current: $current final_target:$final_target delta_percent:$delta_percent"
			
		}


		set bars [round_to_integer [expr {$delta_percent / 5}]]
		if {$bars > 20} {
			set bars 20
		}
		set bars_grey [expr {20 - $bars}]

		#if {$bars < 16} {
			#set green_progress ""
			#set red_progress [string repeat █ $bars]

			#msg -ERROR "green: 0   red: $bars"

		#} else {
			#set red_progress ""
			#set green_progress [string repeat █ $bars]

			#msg -ERROR "red: 0   green: $bars"

		#}

		set green_progress [string repeat █ $bars]
		set grey_progress [string repeat █ $bars_grey]

		if {$final_target == 0} {
			# display no bars if there is no target
			set red_progress ""
			set green_progress ""
			set grey_progress ""
		}

	}

	set updated 0
	if {$::streamline_global(status_msg_text_green) != $green_msg} {
		set ::streamline_global(status_msg_text_green) $green_msg
		set updated 1
	}

	if {$::streamline_global(status_msg_text_red) != $red_msg} {
		set ::streamline_global(status_msg_text_red) $red_msg
		set updated 1
	}

	if {$::streamline_global(status_msg_progress_green) != $green_progress} {
		set ::streamline_global(status_msg_progress_green) $green_progress
		set updated 1
	}

	if {$::streamline_global(status_msg_progress_grey) != $grey_progress} {
		set ::streamline_global(status_msg_progress_grey) $grey_progress
		set updated 1
	}

	if {$::streamline_global(status_msg_progress_red) != $red_progress} {
		set ::streamline_global(status_msg_progress_red) $red_progress
		set updated 1
	}

	if {$updated == 1} {
		::refresh_$::streamline_data_line
		::refresh_$::streamline_progress_line
	}



}
############################################################################################################################################################################################################



############################################################################################################################################################################################################
# draw text labels for the buttons on the left margin


# blink the hot water presets 
streamline_rectangle $::pages 0 1521 626 1555  $::box_color hotwater_presets_rectangle

# hot water
streamline_rounded_rectangle $::pages 360 1396 478 1439  $::box_color  20 hotwater_setting_rectangle

# flush 
streamline_rounded_rectangle $::pages 360 1192 478 1235  $::box_color  20 flush_setting_rectangle

# stream 
streamline_rounded_rectangle $::pages 360 966 478 1008  $::box_color  20 steam_setting_rectangle

# temp 
streamline_rounded_rectangle $::pages 360 738 478 781  $::box_color  20 temp_setting_rectangle

# drink out
streamline_rounded_rectangle $::pages 360 492 478 535  $::box_color  20 weight_setting_rectangle

# dose in
streamline_rounded_rectangle $::pages 360 398 478 442  $::box_color  20 dose_setting_rectangle

# grind
streamline_rounded_rectangle $::pages 360 282 478 325  $::box_color  20 grind_setting_rectangle



# labels
add_de1_text $::pages 50 282 -justify left -anchor "nw" -text [translate "Grind"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200] 
add_de1_text $::pages 50 398 -justify left -anchor "nw" -text [translate "Dose"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200]
add_de1_text $::pages 50 516 -justify left -anchor "nw" -text [translate "Drink"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200]
add_de1_text $::pages 50 741 -justify left -anchor "nw" -text [translate "Brew ºC"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200]
add_de1_text $::pages 50 967 -justify left -anchor "nw" -text [translate "Steam"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200]
add_de1_text $::pages 50 1194 -justify left -anchor "nw" -text [translate "Flush"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200]
add_de1_text $::pages 50 1397 -justify left -anchor "nw" -text [translate "Hot Water"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200]


set ::hw_temp_vol_part1 ""
set ::hw_temp_vol_part2 ""
set ::hw_temp_vol_part3 ""
set ::hw_temp_vol_part4 ""
set ::hw_temp_vol_part5 ""
set ::hw_temp_vol_part6 ""

set ::hw_temp_vol [add_de1_rich_text $::pages 50 1444 left 0 1 8 $::box_color [list \
	[list -text {$::hw_temp_vol_part1} -font Inter-Bold11 -foreground $::left_label_color2 -exec hw_temp_vol_flip] \
	[list -text {$::hw_temp_vol_part2} -font Inter-Bold11 -foreground $::preset_value_color -exec hw_temp_vol_flip] \
	[list -text {$::hw_temp_vol_part3} -font Inter-Bold11 -foreground $::preset_value_color -exec hw_temp_vol_flip] \
	[list -text {$::hw_temp_vol_part4} -font Inter-Bold11 -foreground $::preset_value_color -exec hw_temp_vol_flip ] \
	[list -text {$::hw_temp_vol_part5} -font Inter-Bold11 -foreground $::preset_value_color -exec hw_temp_vol_flip ] \
	[list -text {$::hw_temp_vol_part6} -font Inter-Bold11 -foreground $::left_label_color2 -exec hw_temp_vol_flip ] \
]]


proc hw_temp_vol_flip {} {
	if {$::streamline_hotwater_btn_mode == "ml"} {
		set ::streamline_hotwater_btn_mode "temp"

		set ::hw_temp_vol_part1 "Temp"
		set ::hw_temp_vol_part2 " | "
		set ::hw_temp_vol_part3 "Vol"
		set ::hw_temp_vol_part4 ""
		set ::hw_temp_vol_part5 ""
		set ::hw_temp_vol_part6 ""
	} else {
		set ::streamline_hotwater_btn_mode "ml"

		set ::hw_temp_vol_part1 ""
		set ::hw_temp_vol_part2 ""
		set ::hw_temp_vol_part3 ""
		set ::hw_temp_vol_part4 "Temp"
		set ::hw_temp_vol_part5 " | "
		set ::hw_temp_vol_part6 "Vol"
	}

	catch {
		::refresh_$::hw_temp_vol
	}

	catch {
		refresh_favorite_hw_button_labels
		streamline_hot_water_setting_change

	}
}
hw_temp_vol_flip


# tap areas
add_de1_button "off" {hw_temp_vol_flip} 0 1376 222 1498 ""

############################################################################################################################################################################################################


############################################################################################################################################################################################################
# data card on the bottom center

# labels
set ::streamline_current_history_profile_name ""
set ::streamline_current_history_profile_clock ""


proc start_streamline_espresso {} {
	set ::streamline_history_text_label [translate "CURRENT"] 
	set ::streamline_current_history_profile_clock [clock seconds]
	set ::streamline_current_history_profile_name $::settings(profile_title)


	if {$::off_page == "off"} {
		set ::espresso_page "espresso"
	} else {
		set ::espresso_page "espresso_zoomed"
	}
	set_next_page espresso $::espresso_page
	#page_show espresso;

	unset -nocomplain ::de1(espresso_elapsed)
	update_data_card ::de1
}

set ::streamline_history_text_label [translate "HISTORY"] 
set ::streamline_current_history_third_line ""
add_de1_variable $::pages 890 1348 -justify center -anchor "center" -text "" -font Inter-Bold18 -fill $::data_card_title_text_color -width [rescale_x_skin 400] -textvariable {$::streamline_history_text_label}

add_de1_variable $::pages 890 1410 -justify center -anchor "center" -font Inter-Bold18 -fill $::data_card_text_color  -width [rescale_x_skin 500] -textvariable {[streamline_history_date_format $::streamline_current_history_profile_clock]}
add_de1_variable $::pages 890 1474 -justify center -anchor "center" -font Inter-SemiBold18 -fill $::data_card_text_color -width [rescale_x_skin 1000] -textvariable {$::streamline_current_history_profile_name} 
add_de1_variable $::pages 890 1536 -justify center -anchor "center" -font Inter-SemiBold18 -fill $::data_card_text_color -width [rescale_x_skin 1000] -textvariable {$::streamline_current_history_third_line} 

#add_de1_text $::pages 1364 1328 -justify right -anchor "ne" -text [translate "SHOT DATA"] -font Inter-Bold18 -fill $::data_card_title_text_color -width [rescale_x_skin 400]
add_de1_text $::pages 1364 1390 -justify right -anchor "ne" -text [translate "Preinfusion"] -font Inter-Bold18 -fill $::data_card_title_text_color -width [rescale_x_skin 200]
add_de1_text $::pages 1364 1454 -justify right -anchor "ne" -text [translate "Extraction"] -font Inter-Bold18 -fill $::data_card_title_text_color -width [rescale_x_skin 200]
add_de1_text $::pages 1364 1516 -justify right -anchor "ne" -text [translate "Total"] -font Inter-Bold18 -fill $::data_card_title_text_color -width [rescale_x_skin 200]


proc streamline_history_date_format {shot_time} {

	set seconds [expr {([clock seconds] - $shot_time)}]
	set minutes [expr {([clock seconds] - $shot_time)/60}]
	set hours [expr {([clock seconds] - $shot_time)/3600}]
	set days [expr {([clock seconds] - $shot_time)/86400}]
	set months [expr {([clock seconds] - $shot_time)/(30*86400)}]
	set years [expr {([clock seconds] - $shot_time)/(365*86400)}]

	if {$::de1(state) == 4} {
		set t "now"
	} elseif {$seconds < 120} {
		set t "$seconds [translate {seconds ago}]"
	} elseif {$minutes < 60} {
		set t "${minutes} [translate {minutes ago}]"
	} elseif {$hours < 2} {
		set t [translate "1 hour ago @ [time_format $shot_time]"]
	} elseif {$hours < 24} {
		set t "${hours} [translate {hours ago}] @ [time_format $shot_time]"
	} elseif {$days < 2} {
		set t "[translate {yesterday}] @ [time_format $shot_time]"
	} elseif {$days < 31} {
		set t "${days} [translate {days ago}] @ [time_format $shot_time]"
	} elseif {$months < 25} {
		set t "$months [translate {months ago}] @ [time_format $shot_time]"
	} else {
		set t "$years [translate {years ago}] @ [time_format $shot_time]"
	}

	return $t

	set crlftxt " "
	if {$::settings(enable_ampm) == 1} {
		return [subst {[string trimleft [clock format $seconds -format {%a, %d}] 0] [translate [clock format $seconds -format {%b}]],$crlftxt[string trim [clock format $seconds -format {%l:%M %p %Y}]]}]
	} else {
		return [subst {[string trimleft [clock format $seconds -format {%a, %d}] 0] [translate [clock format $seconds -format {%b}]],$crlftxt[string trim [clock format $seconds -format {%H:%M %Y}]]}]
	}
}

dui aspect set -theme default -type dbutton fill $::profile_button_background_color
dui aspect set -theme default -type dbutton outline $::profile_button_background_color
dui aspect set -theme default -type dbutton_symbol fill $::data_card_text_color
dui aspect set -theme default -type dbutton label_fill $::data_card_text_color
dui aspect set -theme default -type dbutton_symbol font_size 18
dui aspect set -theme default -type dbutton_symbol pos ".50 .5"


if {$::android == 1 || $::undroid == 1} {
	set ::streamline_history_cmd -label
	set ::streamline_history_left "🡐"
	set ::streamline_history_right "🡒"
} else {
	set ::streamline_history_cmd -label
	set ::streamline_history_left "<"
	set ::streamline_history_right ">"
}

dui add dbutton "off" 628 1220 755 1465 -tags profile_back $::streamline_history_cmd $::streamline_history_left  -command { streamline_history_profile_back }  -longpress_cmd { streamline_history_profile_fwd 0 } 
dui add dbutton "off" 1055 1220 1121 1465 -tags profile_fwd $::streamline_history_cmd " "  -command { streamline_history_profile_fwd } -longpress_cmd { streamline_history_profile_fwd 1 } 


add_de1_text $::pages 1416 1328 -justify right -anchor "nw" -text [translate "Time"] -font Inter-Bold18 -fill $::data_card_title_text_color -width [rescale_x_skin 300]
add_de1_variable $::pages 1416 1388 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad $::streamline_preinfusion_time 2 0 [translate "s"]]} 
add_de1_variable $::pages 1416 1452 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad $::streamline_final_extraction_time 2 0 [translate "s"]]}
add_de1_variable $::pages 1416 1514 -justify right -anchor "nw" -font mono10bold -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad $::streamline_shot_time 2 0 [translate "s"]]}

add_de1_text $::pages 1532 1328 -justify right -anchor "nw" -text [translate "Weight"] -font Inter-Bold18 -fill $::data_card_title_text_color -width [rescale_x_skin 300]
add_de1_variable $::pages 1532 1388 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad $::streamline_preinfusion_weight 4 1 [translate "g"]]} 
add_de1_variable $::pages 1532 1452 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad $::streamline_final_extraction_weight 4 1 [translate "g"]]} 
add_de1_variable $::pages 1532 1514 -justify right -anchor "nw" -font mono10bold -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad $::streamline_shot_weight 4 1 [translate "g"]]} 

proc streamline_zero_pad {num dig prec {optional_label {}}} {
	if {$num == ""} {
		return ""
	}
 	return [format "%00${dig}.${prec}f" $num]$optional_label
}



set ::streamline_shot_volume 0
set ::streamline_final_extraction_volume 0
set ::streamline_preinfusion_volume 0
add_de1_text $::pages 1690 1328 -justify right -anchor "nw" -text [translate "Volume"] -font Inter-Bold18 -fill $::data_card_title_text_color -width [rescale_x_skin 150]
add_de1_variable $::pages 1690 1388 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 150] -textvariable {[streamline_zero_pad $::streamline_preinfusion_volume 2 0 [translate "ml"]]} 
add_de1_variable $::pages 1690 1452 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 150] -textvariable {[streamline_zero_pad $::streamline_final_extraction_volume 2 0 [translate "ml"]]} 
add_de1_variable $::pages 1690 1514 -justify right -anchor "nw" -font mono10bold -fill $::data_card_text_color -width [rescale_x_skin 150] -textvariable {[streamline_zero_pad $::streamline_shot_volume 2 0 [translate "ml"]]} 

set ::streamline_preinfusion_temp " "
set ::streamline_extraction_temp " "
add_de1_text $::pages 1850 1328 -justify right -anchor "nw" -text [translate "Temp"] -font Inter-Bold18 -fill $::data_card_title_text_color -width [rescale_x_skin 300]
add_de1_variable $::pages 1850 1388 -justify right -anchor "nw"  -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {$::streamline_preinfusion_temp}
add_de1_variable $::pages 1850 1452 -justify right -anchor "nw"  -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {$::streamline_extraction_temp}

set ::streamline_extraction_low_peak_flow_label "-"
set ::streamline_extraction_low_peak_flow_label "-"
add_de1_text $::pages 2044 1328 -justify right -anchor "nw" -text [translate "Flow"] -font Inter-Bold18 -fill $::data_card_title_text_color -width [rescale_x_skin 300]
add_de1_variable $::pages 2044 1388 -justify right -anchor "nw"  -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {$::streamline_preinfusion_low_peak_flow_label} 
add_de1_variable $::pages 2044 1452 -justify right -anchor "nw"  -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {$::streamline_extraction_low_peak_flow_label} 

set ::streamline_preinfusion_low_peak_pressure_label "-"
set ::streamline_extraction_low_peak_pressure_label "-"
add_de1_text $::pages 2316 1328 -justify right -anchor "nw" -text [translate "Pressure"] -font Inter-Bold18 -fill $::data_card_title_text_color -width [rescale_x_skin 230]
add_de1_variable $::pages 2316 1388 -justify right -anchor "nw"  -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 230] -textvariable {$::streamline_preinfusion_low_peak_pressure_label}
add_de1_variable $::pages 2316 1452 -justify right -anchor "nw"  -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 230] -textvariable {$::streamline_extraction_low_peak_pressure_label}


############################################################################################################################################################################################################




############################################################################################################################################################################################################
# draw current setting numbers on the left margin


if {[ifexists ::settings(grinder_dose_weight)] == "" || [ifexists ::settings(grinder_dose_weight)] == "0"} {
	set ::settings(grinder_dose_weight) 15
}


# labels
#set ::settings(grinder_setting) 1.4
add_de1_variable $::pages 418 304 -justify center -anchor "center" -text [translate "20g"] -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -textvariable {[ifexists ::settings(grinder_setting)]}
add_de1_variable $::pages 418 418 -justify center -anchor "center" -text [translate "20g"] -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -tags dose_label_1st -textvariable {[return_weight_measurement $::settings(grinder_dose_weight) 2]}
add_de1_variable $::pages 418 512 -justify center -anchor "center" -text [translate "45g"] -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -tags weight_label_1st -textvariable {[return_weight_measurement [determine_final_weight] 2]}
add_de1_variable $::pages 418 558 -justify center -anchor "center" -text [translate "1:2.3"] -font Inter-Regular12 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -textvariable {([dose_weight_ratio])}
add_de1_variable $::pages 418 761 -justify center -anchor "center" -text [translate "92ºC"] -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -tags temp_label_1st -textvariable {[setting_espresso_temperature_text 1]}   
add_de1_variable $::pages 418 988 -justify center -anchor "center" -text [translate "31s"] -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -tags steam_label_1st -textvariable {[seconds_text_very_abbreviated $::settings(steam_timeout)]}
add_de1_variable $::pages 418 1215 -justify center -anchor "center" -text [translate "5s"] -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -tags flush_label_1st -textvariable {[seconds_text_very_abbreviated $::settings(flush_seconds)]}
add_de1_variable $::pages 418 1417 -justify center -anchor "center" -text [translate "75ml"] -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -tags hotwater_label_1st -textvariable {$::streamline_hotwater_label_1st}
add_de1_variable $::pages 418 1460 -justify center -anchor "center" -text [translate "75ml"] -font Inter-Regular12 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -textvariable {$::streamline_hotwater_label_2nd}



# highly rounded rectangles

# dose
streamline_rounded_rectangle $::pages 25 606 145 656  $::box_color  20 dose_preset_rectangle_1
streamline_rounded_rectangle $::pages 189 606 309 656  $::box_color  20 dose_preset_rectangle_2
streamline_rounded_rectangle $::pages 343 606 463 656  $::box_color  20 dose_preset_rectangle_3
streamline_rounded_rectangle $::pages 487 606 607 656  $::box_color  20 dose_preset_rectangle_4


# temp
streamline_rounded_rectangle $::pages 25 833 145 883  $::box_color  20 temp_preset_rectangle_1
streamline_rounded_rectangle $::pages 189 833 309 883  $::box_color  20 temp_preset_rectangle_2
streamline_rounded_rectangle $::pages 343 833 463 883  $::box_color  20 temp_preset_rectangle_3
streamline_rounded_rectangle $::pages 487 833 607 883  $::box_color  20 temp_preset_rectangle_4

# steam
streamline_rounded_rectangle $::pages 25 1059 145 1109  $::box_color  20 steam_preset_rectangle_1
streamline_rounded_rectangle $::pages 189 1059 309 1109  $::box_color  20 steam_preset_rectangle_2
streamline_rounded_rectangle $::pages 343 1059 463 1109  $::box_color  20 steam_preset_rectangle_3
streamline_rounded_rectangle $::pages 487 1059 607 1109  $::box_color  20 steam_preset_rectangle_4


# flush
streamline_rounded_rectangle $::pages 25 1289 145 1339  $::box_color  20 flush_preset_rectangle_1
streamline_rounded_rectangle $::pages 189 1289 309 1339  $::box_color  20 flush_preset_rectangle_2
streamline_rounded_rectangle $::pages 343 1289 463 1339  $::box_color  20 flush_preset_rectangle_3
streamline_rounded_rectangle $::pages 487 1289 607 1339  $::box_color  20 flush_preset_rectangle_4


# hotwater
streamline_rounded_rectangle $::pages 25 1512 145 1562  $::box_color  20 hot_water_preset_rectangle_1
streamline_rounded_rectangle $::pages 189 1512 309 1562  $::box_color  20 hot_water_preset_rectangle_2
streamline_rounded_rectangle $::pages 343 1512 463 1562  $::box_color  20 hot_water_preset_rectangle_3
streamline_rounded_rectangle $::pages 487 1512 607 1562  $::box_color  20 hot_water_preset_rectangle_4


############################################################################################################################################################################################################

############################################################################################################################################################################################################
# draw current setting numbers on the left margin


#########
# dose/beverage presets
add_de1_variable $::pages 50 616  -justify left -tags dose_btn_1 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_1)}
add_de1_variable $::pages 222 616  -justify left -tags dose_btn_2 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_2)}
add_de1_variable $::pages 376 616  -justify left  -tags dose_btn_3 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_3)}
add_de1_variable $::pages 580 616  -justify right -tags dose_btn_4 -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_4)}

dui add dbutton $::pages 0 594 148 672 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_dosebev_select 1 } -theme none  -longpress_cmd { streamline_set_dosebev_preset 1 } 
dui add dbutton $::pages 148 594 310 672 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_dosebev_select 2 } -theme none  -longpress_cmd {streamline_set_dosebev_preset 2 } 
dui add dbutton $::pages 310 594 474 672 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_dosebev_select 3 } -theme none  -longpress_cmd {streamline_set_dosebev_preset 3 } 
dui add dbutton $::pages 474 594 624 672 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_dosebev_select 4 } -theme none  -longpress_cmd {streamline_set_dosebev_preset 4 } 



#########
# temp presets
add_de1_variable $::pages 50 842  -justify left -tags temp_btn_1 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_1)}
add_de1_variable $::pages 222 842  -justify left -tags temp_btn_2 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_2)}
add_de1_variable $::pages 376 842  -justify left  -tags temp_btn_3 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_3)}
add_de1_variable $::pages 580 842  -justify right -tags temp_btn_4 -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_4)}

dui add dbutton $::pages 0 822 148 900 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_temperature_select 1 } -theme none  -longpress_cmd { streamline_set_temperature_preset 1 } 
dui add dbutton $::pages 148 822 310 900 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_temperature_select 2 } -theme none  -longpress_cmd {streamline_set_temperature_preset 2 } 
dui add dbutton $::pages 310 822 474 900 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_temperature_select 3 } -theme none  -longpress_cmd {streamline_set_temperature_preset 3 } 
dui add dbutton $::pages 474 822 624 900 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_temperature_select 4 } -theme none  -longpress_cmd {streamline_set_temperature_preset 4 } 




#########
# steam presets

add_de1_variable $::pages 50 1068  -justify left -tags steam_btn_1 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_1)}
add_de1_variable $::pages 222 1068  -justify left -tags steam_btn_2 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_2)}
add_de1_variable $::pages 376 1068  -justify left -tags steam_btn_3 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_3)}
add_de1_variable $::pages 580 1068  -justify right -tags steam_btn_4 -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_4)}


dui add dbutton $::pages 0 1050 148 1128 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_steam_select 1 } -theme none  -longpress_cmd { streamline_set_steam_preset 1 } 
dui add dbutton $::pages 148 1050 310 1128 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_steam_select 2 } -theme none  -longpress_cmd {streamline_set_steam_preset 2 } 
dui add dbutton $::pages 310 1050 474 1128 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_steam_select 3 } -theme none  -longpress_cmd {streamline_set_steam_preset 3 } 
dui add dbutton $::pages 474 1050 624 1128 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_steam_select 4 } -theme none  -longpress_cmd {streamline_set_steam_preset 4 } 


#########
# flush presets

add_de1_variable $::pages 50 1296  -justify left -tags flush_btn_1 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_1)}
add_de1_variable $::pages 222 1296  -justify left -tags flush_btn_2 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_2)}
add_de1_variable $::pages 376 1296  -justify left -tags flush_btn_3 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_3)}
add_de1_variable $::pages 580 1296  -justify right -tags flush_btn_4 -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_4)}


dui add dbutton $::pages 0 1272 148 1350 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_flush_select 1 } -theme none  -longpress_cmd { streamline_set_flush_preset 1 } 
dui add dbutton $::pages 148 1272 310 1350 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_flush_select 2 } -theme none  -longpress_cmd {streamline_set_flush_preset 2 } 
dui add dbutton $::pages 310 1272 474 1350 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_flush_select 3 } -theme none  -longpress_cmd {streamline_set_flush_preset 3 } 
dui add dbutton $::pages 474 1272 624 1350 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_flush_select 4 } -theme none  -longpress_cmd {streamline_set_flush_preset 4 } 


#########
# hot water presets

add_de1_variable $::pages 50 1520  -justify left -tags hw_btn_1 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_1)}
add_de1_variable $::pages 222 1520  -justify left -tags hw_btn_2 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_2)}
add_de1_variable $::pages 376 1520  -justify left -tags hw_btn_3 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_3)}
add_de1_variable $::pages 580 1520  -justify right -tags hw_btn_4 -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_4)}

dui add dbutton $::pages 0 1500 148 1600 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_hw_preset_select 1 } -theme none  -longpress_cmd {streamline_set_hw_preset 1 } 
dui add dbutton $::pages 148 1500 310 1600 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_hw_preset_select 2 } -theme none  -longpress_cmd {streamline_set_hw_preset 2 } 
dui add dbutton $::pages 310 1500 474 1600 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_hw_preset_select 3 } -theme none  -longpress_cmd {streamline_set_hw_preset 3 } 
dui add dbutton $::pages 474 1500 624 1600 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_hw_preset_select 4 } -theme none  -longpress_cmd {streamline_set_hw_preset 4 } 

#########




############################################################################################################################################################################################################
# four ESPRESSO PROFILE shotcut buttons at the top left


proc refresh_favorite_profile_button_labels {} {


	set profiles [ifexists ::settings(favorite_profiles)]
	set streamline_selected_favorite_profile ""
	catch {
		set streamline_selected_favorite_profile [dict get $profiles selected number]
	}

	if {$streamline_selected_favorite_profile == ""} {
		after 500 "streamline_profile_select 1"
		set streamline_selected_favorite_profile 1
	}


	set profiles [ifexists ::settings(favorite_profiles)]

	set changed 0
	set default_profile_buttons [list "" "default" "best_practice"	"rao_allonge" "80s_Espresso" "Cleaning_forward_flush_x5"]

	for {set x 1} {$x <= 5}  {incr x} {
		set b($x) ""

		catch {
			set b($x) [dict get $profiles $x title]
		}

		if {$b($x) == ""} {
			set t($x) [lindex $default_profile_buttons $x]
			set b($x) [profile_title [lindex $default_profile_buttons $x]]

			#regsub "/" $b($x) "/ " b($x)

			dict set profiles $x name $t($x)
			dict set profiles $x title $b($x)
			set changed 1
			puts "ERROR set button $x to $b($x)"
		}		

	}

	if {$changed == 1} {
		set ::settings(favorite_profiles) $profiles	
		save_settings	
	}


	for {set x 1} {$x <= 5}  {incr x} {
		set ::streamline_favorite_profile_buttons(label_$x) $b($x)
	}


	for {set x 1} {$x <= 5}  {incr x} {
		set bc($x) $::profile_button_background_color
		set lbc($x) "$::profile_button_not_selected_color"
		set obc($x) "$::profile_button_outline_color"
	}

	if {$streamline_selected_favorite_profile >= 1 && $streamline_selected_favorite_profile <= 5 && $::settings(profile_title) == $b($streamline_selected_favorite_profile)} {
		set bc($streamline_selected_favorite_profile) $::profile_button_background_selected_color
		set lbc($streamline_selected_favorite_profile) $::profile_button_button_selected_color
		set obc($streamline_selected_favorite_profile) $::profile_button_background_selected_color
	} 

	for {set x 1} {$x <= 5}  {incr x} {
		.can itemconfigure profile_${x}_btn-btn -fill $bc($x)
		.can itemconfigure profile_${x}_btn-lbl -fill $lbc($x)
		.can itemconfigure profile_${x}_btn-out -fill $obc($x)
		dui item config "off" profile_${x}_btn-out-ne  -outline $obc($x)
		dui item config "off" profile_${x}_btn-out-nw  -outline $obc($x)
		dui item config "off" profile_${x}_btn-out-se  -outline $obc($x)
		dui item config "off" profile_${x}_btn-out-sw  -outline $obc($x)
	}

}


####
# favorite profile buttons




# font to use
dui aspect set -theme default -type dbutton label_font Inter-Bold11

# rounded retangle radius
dui aspect set -theme default -type dbutton radius [rescale_y_skin 36]

# rounded rectangle line width
dui aspect set -theme default -type dbutton width 2


# width of the text, to enable auto-wrapping
dui aspect set -theme default -type dbutton_label width [rescale_x_skin 480]

# button shape
dui aspect set -theme default -type dbutton shape round_outline 

# label position
dui aspect set -theme default -type dbutton label_pos ".50 .50" 

####
# the selected profile button

# font color
dui aspect set -theme default -type dbutton label_fill $::profile_button_button_color

# width of text of profile selection button
dui aspect set -theme default -type dbutton_label width 220




#  -longpress_cmd { puts "ERRORlongpress" }
dui add dbutton $::all_pages 50 50 360 170 -tags profile_1_btn -labelvariable {$::streamline_favorite_profile_buttons(label_1)}  -command { streamline_profile_select 1 }
dui add dbutton $::all_pages 380 50 710 170 -tags profile_2_btn -labelvariable {$::streamline_favorite_profile_buttons(label_2)}  -command { streamline_profile_select 2 } 
dui add dbutton $::all_pages 730 50 1050 170 -tags profile_3_btn -labelvariable {$::streamline_favorite_profile_buttons(label_3)} -command { streamline_profile_select 3 } 
dui add dbutton $::all_pages 1070 50 1370 170 -tags profile_4_btn -labelvariable {$::streamline_favorite_profile_buttons(label_4)}   -command { streamline_profile_select 4 } 
dui add dbutton $::all_pages 1390 50 1690 170 -tags profile_5_btn -labelvariable {$::streamline_favorite_profile_buttons(label_5)}   -command { streamline_profile_select 5 } 



# button color
dui aspect set -theme default -type dbutton fill $::settings_sleep_button_color

# rounded rectangle color 
dui aspect set -theme default -type dbutton outline $::settings_sleep_button_outline_color

dui aspect set -theme default -type dbutton width 2

# rounded retangle radius
#dui aspect set -theme default -type dbutton radius 36
dui aspect set -theme default -type dbutton radius [rescale_y_skin 56]

# font color
dui aspect set -theme default -type dbutton label_fill $::settings_sleep_button_text_color


dui add dbutton $::all_pages 2100 66 2300 155 -tags settings_btn -label "Settings"  -command { say [translate {settings}] $::settings(sound_button_in); show_settings "" "back_from_settings" }
dui add dbutton $::all_pages 2330 66 2530 155 -tags sleep_btn -label "Sleep"  -command { say [translate {sleep}] $::settings(sound_button_in);start_sleep }



############################################################################################################################################################################################################
# DYE support

# DYE support

set dyebtns ""

if { [plugins enabled DYE] } {
	dui add dbutton $::all_pages 1880 76 2070 145 -tags dye_btn -label "DYE"  -command { show_DYE_page }

}

proc show_DYE_page {} {
	if { [plugins enabled DYE] } {
		plugins::DYE::open -which_shot default -coords {700 250} -anchor nw
	}
}
############################################################################################################################################################################################################


# button color
#dui aspect set -theme default -type dbutton fill "d8d8d8"

# font color
#dui aspect set -theme default -type dbutton label_fill "3c5782"

refresh_favorite_profile_button_labels

############################################################################################################################################################################################################


############################################################################################################################################################################################################
# plus/minus +/- buttons on the left hand side for changing parameters

# rounded rectangle color 
dui aspect set -theme default -type dbutton outline $::plus_minus_outline_color


# inside button color

dui aspect set -theme default -type dbutton fill $::plus_minus_flash_off_color

# font color
dui aspect set -theme default -type dbutton label_fill "$::plus_minus_text_color"

# font to use
dui aspect set -theme default -type dbutton label_font Inter-Bold24 

# rounded retangle radius
dui aspect set -theme default -type dbutton radius [rescale_y_skin 36]

# rounded retangle line width
dui aspect set -theme default -type dbutton width 2 

# button shape
dui aspect set -theme default -type dbutton shape round_outline 

# label position is higher because we're using a _ as a minus symbol
dui aspect set -theme default -type dbutton label_pos ".50 .22" 


# the - buttons
dui add dbutton $::pages 254 257 346 349 -tags streamline_minus_grind_btn -label "_"  -command { streamline_adjust_grind - } 
dui add dbutton $::pages 254 369 346 461 -tags streamline_minus_dose_btn -label "_"  -command { streamline_dose_btn - } 
dui add dbutton $::pages 254 486 346 578 -tags streamline_minus_beverage_btn -label "_"  -command { streamline_beverage_btn - } 
dui add dbutton $::pages 254 713 346 805 -tags streamline_minus_temp_btn -label "_"  -command { streamline_temp_btn - } 
dui add dbutton $::pages 254 940 346 1032 -tags streamline_minus_steam_btn -label "_"  -command { streamline_steam_btn - } 
dui add dbutton $::pages 254 1164 346 1256 -tags streamline_minus_flush_btn -label "_"  -command { streamline_flush_btn - } 
dui add dbutton $::pages 254 1390 346 1482 -tags streamline_minus_hotwater_btn -label "_"  -command { streamline_hotwater_btn - } 

# label position
dui aspect set -theme default -type dbutton label_pos ".49 .44" 

# the + buttons
dui add dbutton $::pages 486 259 578 351 -tags streamline_plus_grind_btn -label "+"  -command { streamline_adjust_grind + } 
dui add dbutton $::pages 486 371 578 463 -tags streamline_plus_dose_btn -label "+"  -command { streamline_dose_btn + } 
dui add dbutton $::pages 486 488 578 580 -tags streamline_plus_beverage_btn -label "+"  -command { streamline_beverage_btn + } 
dui add dbutton $::pages 486 715 578 807 -tags streamline_plus_temp_btn -label "+"  -command { streamline_temp_btn + } 
dui add dbutton $::pages 486 942 578 1034 -tags streamline_plus_steam_btn -label "+"  -command { streamline_steam_btn + } 
dui add dbutton $::pages 486 1166 578 1258 -tags streamline_plus_flush_btn -label "+"  -command { streamline_flush_btn + } 
dui add dbutton $::pages 486 1392 578 1484 -tags streamline_plus_hotwater_btn -label "+"  -command { streamline_hotwater_btn + } 

############################################################################################################################################################################################################

proc save_profile_and_update_de1 {} {

	set current_title [ifexists ::settings(profile_title)]
	set ::settings(original_profile_title) $current_title
	save_profile 0
	
	set new_title [ifexists ::settings(profile_title)]
	if {$current_title != $new_title} {

		####
		# update the profiles buttons if the title has changed
		set profiles [ifexists ::settings(favorite_profiles)]

		set slot [dict get $profiles selected number]	

		dict set profiles $slot name $::settings(profile_filename)
		dict set profiles $slot title $::settings(profile_title)

		set ::settings(favorite_profiles) $profiles
		set var "label_$slot"
		set ::streamline_favorite_profile_buttons($var) $::settings(profile_title)
		####


	}

	#puts "ERROR save_profile_and_update_de1 '$new_title' '$::settings(profile_filename)'"

	save_settings_to_de1
}

proc save_profile_and_update_de1_soon {} {

	if {[info exists ::streamline_save_update_id] == 1} {
		after cancel $::streamline_save_update_id; 
		unset -nocomplain ::streamline_save_update_id
	}

	set ::streamline_save_update_id [after 1000 save_profile_and_update_de1]
}

proc flash_button {buttontag firstcolor finalcolor} {
	.can itemconfigure ${buttontag}-btn -fill $::plus_minus_flash_on_color2 
	after 40 .can itemconfigure ${buttontag}-btn -fill $::plus_minus_flash_on_color
	after 200 .can itemconfigure ${buttontag}-btn -fill $::plus_minus_flash_on_color2 
	after 280 .can itemconfigure ${buttontag}-btn -fill $::plus_minus_flash_off_color
}

proc streamline_dose_btn { args } {
	if {$args == "-"} {
		if {$::settings(grinder_dose_weight) > 1} {
			set ::settings(grinder_dose_weight) [round_to_one_digits [expr {$::settings(grinder_dose_weight) - .1}]]
			flash_button "streamline_minus_dose_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			#save_profile_and_update_de1_soon
		}
	} elseif {$args == "+"} {
		if {$::settings(grinder_dose_weight) < 30} {
			set ::settings(grinder_dose_weight) [round_to_one_digits [expr {$::settings(grinder_dose_weight) + .1}]]
			flash_button "streamline_plus_dose_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			#save_profile_and_update_de1_soon
		}
	}
	refresh_favorite_dosebev_button_labels
}

proc streamline_beverage_btn { args } {
	if {$args == "-"} {
		if {[determine_final_weight] > 0} {
			determine_final_weight -1
			flash_button "streamline_minus_beverage_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			save_profile_and_update_de1_soon
		}
	} elseif {$args == "+"} {
		if {[determine_final_weight] < 1000} {
			determine_final_weight 1
			flash_button "streamline_plus_beverage_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			save_profile_and_update_de1_soon
		}
	}

	refresh_favorite_dosebev_button_labels
}


proc streamline_temp_btn { args } {
	if {$args == "-"} {
		if {$::settings(espresso_temperature) > 1} {
			#set ::settings(espresso_temperature) [expr {$::settings(espresso_temperature) - 1}]
			change_espresso_temperature -1
			flash_button "streamline_minus_temp_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			save_profile_and_update_de1_soon
		}
	} elseif {$args == "+"} {
		if {$::settings(espresso_temperature) < 110} {
			#set ::settings(espresso_temperature) [expr {$::settings(espresso_temperature) + 1}]
			change_espresso_temperature 1
			flash_button "streamline_plus_temp_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			save_profile_and_update_de1_soon
		}
	}
	refresh_favorite_temperature_button_labels
}

proc streamline_steam_btn { args } {
	if {$args == "-"} {
		if {$::settings(steam_timeout) > 1} {
			set ::settings(steam_timeout) [expr {$::settings(steam_timeout) - 1}]
			flash_button "streamline_minus_steam_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			save_profile_and_update_de1_soon
		}
	} elseif {$args == "+"} {
		if {$::settings(steam_timeout) < 254} {
			set ::settings(steam_timeout) [expr {$::settings(steam_timeout) + 1}]
			flash_button "streamline_plus_steam_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			save_profile_and_update_de1_soon
		}
	}
	refresh_favorite_steam_button_labels
}
proc streamline_flush_btn { args } {
	if {$args == "-"} {
		if {$::settings(flush_seconds) > 3} {
			set ::settings(flush_seconds) [expr {$::settings(flush_seconds) - 1}]
			flash_button "streamline_minus_flush_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			save_profile_and_update_de1_soon
		} else {
			#flash_button "streamline_minus_flush_btn" $::plus_minus_flash_refused_color $::plus_minus_flash_off_color
		}
	} elseif {$args == "+"} {
		if {$::settings(flush_seconds) < 254} {
			set ::settings(flush_seconds) [expr {$::settings(flush_seconds) + 1}]
			flash_button "streamline_plus_flush_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			save_profile_and_update_de1_soon
		} else {
			#flash_button "streamline_plus_flush_btn" $::plus_minus_flash_refused_color $::plus_minus_flash_off_color
		}
	}
	refresh_favorite_flush_button_labels
}



proc streamline_hot_water_setting_change { } {

	puts "streamline_hot_water_setting : ::streamline_hot_water_setting"
	if {$::streamline_hotwater_btn_mode == "ml"} {
		set ::streamline_hotwater_label_1st [return_liquid_measurement_ml $::settings(water_volume)]
		set ::streamline_hotwater_label_2nd ([return_temperature_measurement $::settings(water_temperature) 1])
	} else {
		set ::streamline_hotwater_label_1st [return_temperature_measurement $::settings(water_temperature) 1]
		set ::streamline_hotwater_label_2nd ([return_liquid_measurement_ml $::settings(water_volume)])
	}
}


proc streamline_hotwater_btn { args } {

	if {$::streamline_hotwater_btn_mode == "ml"} {
		# ui mode is set to change the hot water volume
		if {$args == "-"} {
			if {$::settings(water_volume) > 1} {
				set ::settings(water_volume) [expr {$::settings(water_volume) - 1}]
				flash_button "streamline_minus_hotwater_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
				save_profile_and_update_de1_soon
			}
		} elseif {$args == "+"} {
			if {$::settings(water_volume) < 1000} {
				set ::settings(water_volume) [expr {$::settings(water_volume) + 1}]
				flash_button "streamline_plus_hotwater_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
				save_profile_and_update_de1_soon
			}
		}
	} else {
		# the UI mode is set to change the temperature
		if {$args == "-"} {
			if {$::settings(water_temperature) > 1} {
				set ::settings(water_temperature) [expr {$::settings(water_temperature) - 1}]
				flash_button "streamline_minus_hotwater_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
				save_profile_and_update_de1_soon
			}
		} elseif {$args == "+"} {
			if {$::settings(water_volume) < 110} {
				set ::settings(water_temperature) [expr {$::settings(water_temperature) + 1}]
				flash_button "streamline_plus_hotwater_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
				save_profile_and_update_de1_soon
			}
		}
	}
	streamline_hot_water_setting_change
	refresh_favorite_hw_button_labels
}

proc OBSOLETE_toggle_streamline_hot_water_setting {} {
	puts toggle_streamline_hot_water_setting
	if {$::streamline_hotwater_btn_mode == "ml"} {
		set ::streamline_hotwater_btn_mode "temp"
	} else {
		set ::streamline_hotwater_btn_mode "ml"
	}
	streamline_hot_water_setting_change
}
streamline_hot_water_setting_change

############################################################################################################################################################################################################
# Profile QuickSettings

# font to use
dui aspect set -theme default -type dbutton label_font "Helv_10_bold"

# label position
dui aspect set -theme default -type dbutton label_pos ".50 .5" 

# font color
dui aspect set -theme default -type dbutton label_fill $::profile_button_background_color

# rounded rectangle color 
dui aspect set -theme default -type dbutton outline $::plus_minus_outline_color

# inside button color
dui aspect set -theme default -type dbutton fill $::profile_button_button_color

dui aspect set -theme default -type dbutton radius [rescale_y_skin 52]

dui add dbutton "settings_1" 50 1452 160 1580  -tags profile_btn_1 -label "1"  -command { save_favorite_profile 1 } 
dui add dbutton "settings_1" 180 1452 290 1580   -tags profile_btn_2 -label "2"  -command { save_favorite_profile 2 } 
dui add dbutton "settings_1" 310 1452 420 1580  -tags profile_btn_3 -label "3"  -command { save_favorite_profile 3} 
dui add dbutton "settings_1" 440 1452 550 1580  -tags profile_btn_4 -label "4"  -command { save_favorite_profile 4 } 
dui add dbutton "settings_1" 570 1452 680 1580  -tags profile_btn_5 -label "5"  -command { save_favorite_profile 5 } 


proc streamline_profile_select { slot } {

	if {[dui page current] != "off" && [dui page current] != "off_zoomed"} {
		return ""
	}

	set profiles [ifexists ::settings(favorite_profiles)]
	select_profile [dict get $profiles $slot name]
	dict set profiles selected number $slot
	set ::settings(favorite_profiles) $profiles

	#streamline_adjust_chart_x_axis
	refresh_favorite_profile_button_labels
}

proc save_favorite_profile { slot } {
	puts "ERROR save_favorite_profile $slot"
	set profiles [ifexists ::settings(favorite_profiles)]

	dict set profiles $slot name $::settings(profile_filename)

	set title $::settings(profile_title)
	#regsub "/" $title "/ " title

	dict set profiles $slot title $title

	set ::settings(favorite_profiles) $profiles
	#refresh_favorite_profile_button_labels
	refresh_favorite_profile_button_labels
	save_settings
	popup [translate "Saved"]
}

############################################################################################################################################################################################################



############################################################################################################################################################################################################
# Four GHC buttons on bottom right

if {$::settings(ghc_is_installed) == 0} { 

	# color of the button icons
	dui aspect set -theme default -type dbutton_symbol fill $::ghc_button_color

	# font size of the button icons
	dui aspect set -theme default -type dbutton_symbol font_size 24

	# position of the button icons
	dui aspect set -theme default -type dbutton_symbol pos ".50 .38"

	# rounded rectangle color 
	dui aspect set -theme default -type dbutton outline $::ghc_button_outline

	# inside button color
	dui aspect set -theme default -type dbutton fill $::ghc_button_background_color

	# font color
	dui aspect set -theme default -type dbutton label_fill $::ghc_button_color
	dui aspect set -theme default -type dbutton label1_fill $::ghc_button_color

	# font to use
	dui aspect set -theme default -type dbutton label_font Inter-Bold12 
	
	dui aspect set -theme default -type dbutton label1_font icomoon
	# rounded retangle radius
	dui aspect set -theme default -type dbutton radius [rescale_y_skin 36]

	# rounded retangle line width
	dui aspect set -theme default -type dbutton width 2 

	# button shape
	dui aspect set -theme default -type dbutton shape round_outline 

	# label position
	dui aspect set -theme default -type dbutton label_pos ".50 .75" 
	dui aspect set -theme default -type dbutton label1_pos ".50 .35" 


	# Four GHC buttons on bottom right
	if {$::android == 1 || $::undroid == 1} {

		# custom characters in a font made by Pulak
		set s1 "\uE915"
		set s2 "\uE917"
		set s3 "\uE918"
		set s4 "\uE916"

		# font awesome
		set s5 "hand"

	} else {

		set s1 "C"
		set s2 "S"
		set s3 "W"
		set s4 "F"
		set s5 "S"
	}


	if {$::settings(ghc_is_installed) == 0} { 

		dui add dbutton "off off_zoomed espresso_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 258 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 425 -tags espresso_btn -label1 $s1 -label [translate "Coffee"]   -command {say [translate {Espresso}] $::settings(sound_button_in); start_streamline_espresso; start_espresso} 
		dui add dbutton "off off_zoomed espresso_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 463 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 630 -tags water_btn -label1 $s3 -label [translate "Water"]   -command {say [translate {Water}] $::settings(sound_button_in); start_water} 
		dui add dbutton "off off_zoomed espresso_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 668 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 835 -tags flush_btn -label1 $s4 -label [translate "Flush"]  -command {say [translate {Flush}] $::settings(sound_button_in); start_flush} 
		dui add dbutton "off off_zoomed espresso_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 873 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 1040 -tags steam_btn -label1 $s2 -label [translate "Steam"]   -command {say [translate {Steam}] $::settings(sound_button_in); start_steam} 
		
		dui aspect set -theme default -type dbutton outline $::ghc_disabled_button_outline 
		dui aspect set -theme default -type dbutton fill $::ghc_disabled_button_fill 
		dui aspect set -theme default -type dbutton label_fill $::ghc_disabled_button_text 
		dui aspect set -theme default -type dbutton label1_fill $::ghc_disabled_button_text 
		dui aspect set -theme default -type dbutton_symbol fill $::ghc_disabled_button_text 
		dui add dbutton "espresso water steam hotwaterrinse espresso_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 258 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 425 -tags espresso_btn_disabled -label1 $s1 -label [translate "Coffee"]  
		dui add dbutton "espresso water steam hotwaterrinse espresso_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 463 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 630 -tags water_btn_disabled -label1 $s3 -label [translate "Water"]  
		dui add dbutton "espresso water steam hotwaterrinse espresso_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 668 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 835 -tags flush_btn_disabled -label1 $s4 -label [translate "Flush"]  
		dui add dbutton "espresso water steam hotwaterrinse espresso_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 873 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 1040 -tags steam_btn_disabled -label1 $s2 -label [translate "Steam"] 

		# stop button
		#dui add dbutton "espresso water steam hotwaterrinse" 2159 1216 2494 1566 -tags espresso_btn -symbol $s5  -label [translate "Stop"] -command {say [translate {Stop}] $::settings(sound_button_in); start_idle} 
		dui aspect set -theme default -type dbutton outline $::ghc_enabled_stop_button_outline
		dui aspect set -theme default -type dbutton fill $::ghc_enabled_stop_button_fill
		dui aspect set -theme default -type dbutton label_fill $::ghc_disabled_stop_button_text_color
		dui aspect set -theme default -type dbutton_symbol fill $::ghc_disabled_stop_button_text_color
		dui add dbutton "off off_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 1079 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 1246 -tags off_btn_disabled -symbol $s5  -label [translate "Stop"] -command {say [translate {Stop}] $::settings(sound_button_in); start_idle} 
		dui aspect set -theme default -type dbutton fill $::ghc_enabled_stop_button_fill_color
		dui aspect set -theme default -type dbutton label_fill $::ghc_enabled_stop_button_text_color
		dui aspect set -theme default -type dbutton_symbol fill $::ghc_enabled_stop_button_text_color
		dui add dbutton "espresso water steam hotwaterrinse espresso_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 1079 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 1246 -tags off_btn -symbol $s5  -label [translate "Stop"] -command {say [translate {Stop}] $::settings(sound_button_in); start_idle} 
	}
}

############################################################################################################################################################################################################

proc streamline_set_temperature_preset { slot } {
	set temperatures [ifexists ::settings(favorite_temperatures)]
	dict set temperatures $slot value $::settings(espresso_temperature)
	set ::settings(favorite_temperatures) $temperatures	
	save_settings	
	refresh_favorite_temperature_button_labels

	streamline_blink_rounded_setting "temp_setting_rectangle" "temp_label_1st"
	streamline_blink_rounded_setting "temp_preset_rectangle_$slot" "temp_btn_$slot"
	
}


proc streamline_set_steam_preset { slot } {
	set steams [ifexists ::settings(favorite_steams)]
	dict set steams $slot value $::settings(steam_timeout)
	set ::settings(favorite_steams) $steams	
	save_settings	
	refresh_favorite_steam_button_labels

	streamline_blink_rounded_setting "steam_setting_rectangle" "steam_label_1st"
	streamline_blink_rounded_setting "steam_preset_rectangle_$slot" "steam_btn_$slot"
}


proc streamline_set_flush_preset { slot } {
	set flushs [ifexists ::settings(favorite_flushs)]
	dict set flushs $slot value $::settings(flush_seconds)
	set ::settings(favorite_flushs) $flushs	
	save_settings	
	refresh_favorite_flush_button_labels

	streamline_blink_rounded_setting "flush_setting_rectangle" "flush_label_1st"
	streamline_blink_rounded_setting "flush_preset_rectangle_$slot" "flush_btn_$slot"
	
}


proc streamline_set_hw_preset { slot }  {
	if {$::streamline_hotwater_btn_mode == "ml"} {
		streamline_set_hwvol_preset $slot
	} else {
		streamline_set_hwtemp_preset $slot
	}

	streamline_blink_rounded_setting "hotwater_setting_rectangle" "hotwater_label_1st"
	streamline_blink_rounded_setting "hot_water_preset_rectangle_$slot" "hw_btn_$slot"


}

proc streamline_set_hwvol_preset { slot } {
	set hwvols [ifexists ::settings(favorite_hwvols)]
	dict set hwvols $slot value $::settings(water_volume)
	set ::settings(favorite_hwvols) $hwvols	
	save_settings	
	streamline_hot_water_setting_change

	streamline_blink_rounded_setting "hotwater_setting_rectangle" "hotwater_label_1st"
	streamline_blink_rounded_setting "hot_water_preset_rectangle_$slot" "hw_btn_$slot"
	
	refresh_favorite_hw_button_labels
}


proc streamline_set_hwtemp_preset { slot } {
	set hwtemps [ifexists ::settings(favorite_hwtemps)]
	dict set hwtemps $slot value $::settings(water_temperature)
	set ::settings(favorite_hwtemps) $hwtemps	
	save_settings	
	streamline_hot_water_setting_change

	streamline_blink_rounded_setting "hotwater_setting_rectangle" "hotwater_label_1st"
	streamline_blink_rounded_setting "hot_water_preset_rectangle_$slot" "hw_btn_$slot"

	refresh_favorite_hw_button_labels	
}



proc streamline_set_dosebev_preset { slot } {
	set dosebevs [ifexists ::settings(favorite_dosebevs)]
	dict set dosebevs $slot value [round_to_two_digits $::settings(grinder_dose_weight)]
	dict set dosebevs $slot value2 [round_to_two_digits [determine_final_weight] ]
	set ::settings(favorite_dosebevs) $dosebevs	
	save_settings	
	refresh_favorite_dosebev_button_labels

	streamline_blink_rounded_setting "dose_setting_rectangle" "dose_label_1st"
	streamline_blink_rounded_setting "weight_setting_rectangle" "weight_label_1st"
	streamline_blink_rounded_setting "dose_preset_rectangle_$slot" "dose_btn_$slot"
}



proc refresh_favorite_temperature_button_labels {} {

	puts "refresh_favorite_temperature_button_labels"

	set temperatures [ifexists ::settings(favorite_temperatures)]
	set streamline_selected_favorite_temperature ""
	catch {
		set streamline_selected_favorite_temperature [dict get $temperatures selected number]
	}

	set temperatures [ifexists ::settings(favorite_temperatures)]

	set t1 ""
	set t2 ""
	set t3 ""
	set t4 ""

	catch {
		set t1 [dict get $temperatures 1 value]
	}
	catch {
		set t2 [dict get $temperatures 2 value]
	}
	catch {
		set t3 [dict get $temperatures 3 value]
	}
	catch {
		set t4 [dict get $temperatures 4 value]
	}

	set changed 0
	if {$t1 == ""} {
		set t1 "75"
		dict set temperatures 1 value $t1
		set changed 1
	}

	if {$t2 == ""} {
		set t2 "80"		
		dict set temperatures 2 value $t2
		set changed 1
	}

	if {$t3 == ""} {
		set t3 "85"		
		dict set temperatures 3 value $t3
		set changed 1
	}

	if {$t4 == ""} {
		set t4 "90"		
		dict set temperatures 4 value $t4
		set changed 1
	}


	if {$changed == 1} {
		set ::settings(favorite_temperatures) $temperatures	
		save_settings	
		
	}

	set ::streamline_favorite_temperature_buttons(label_1) [return_temperature_measurement $t1 1]
	set ::streamline_favorite_temperature_buttons(label_2) [return_temperature_measurement $t2 1]
	set ::streamline_favorite_temperature_buttons(label_3) [return_temperature_measurement $t3 1]
	set ::streamline_favorite_temperature_buttons(label_4) [return_temperature_measurement $t4 1]



	set lb1c $::preset_value_color
	set lb2c $::preset_value_color
	set lb3c $::preset_value_color
	set lb4c $::preset_value_color

	if {$::settings(espresso_temperature) == [dict get $temperatures 1 value]} {

		set lb1c $::preset_label_selected_color
	} 
	if {$::settings(espresso_temperature) == [dict get $temperatures 2 value]} {

		set lb2c $::preset_label_selected_color
	} 
	if {$::settings(espresso_temperature) == [dict get $temperatures 3 value]} {
	
		set lb3c $::preset_label_selected_color
	} 
	if {$::settings(espresso_temperature) == [dict get $temperatures 4 value]} {
	
		set lb4c $::preset_label_selected_color
	}

	.can itemconfigure temp_f_btn_1 -fill $lb1c
	.can itemconfigure temp_btn_2 -fill $lb2c
	.can itemconfigure temp_btn_3 -fill $lb3c
	.can itemconfigure temp_btn_4 -fill $lb4c
}



proc refresh_favorite_steam_button_labels {} {

	puts "refresh_favorite_steam_button_labels"

	set steams [ifexists ::settings(favorite_steams)]
	set streamline_selected_favorite_steam ""
	catch {
		set streamline_selected_favorite_steam [dict get $steams selected number]
	}

	set steams [ifexists ::settings(favorite_steams)]

	set t1 ""
	set t2 ""
	set t3 ""
	set t4 ""

	catch {
		set t1 [dict get $steams 1 value]
	}
	catch {
		set t2 [dict get $steams 2 value]
	}
	catch {
		set t3 [dict get $steams 3 value]
	}
	catch {
		set t4 [dict get $steams 4 value]
	}

	set changed 0
	if {$t1 == ""} {
		set t1 "20"
		dict set steams 1 value $t1
		set changed 1
	}

	if {$t2 == ""} {
		set t2 "25"		
		dict set steams 2 value $t2
		set changed 1
	}

	if {$t3 == ""} {
		set t3 "30"		
		dict set steams 3 value $t3
		set changed 1
	}

	if {$t4 == ""} {
		set t4 "40"		
		dict set steams 4 value $t4
		set changed 1
	}


	if {$changed == 1} {
		set ::settings(favorite_steams) $steams	
		save_settings	
		
	}

	set ::streamline_favorite_steam_buttons(label_1) [seconds_text_very_abbreviated $t1]
	set ::streamline_favorite_steam_buttons(label_2) [seconds_text_very_abbreviated $t2]
	set ::streamline_favorite_steam_buttons(label_3) [seconds_text_very_abbreviated $t3]
	set ::streamline_favorite_steam_buttons(label_4) [seconds_text_very_abbreviated $t4]


	set lb1c $::preset_value_color
	set lb2c $::preset_value_color
	set lb3c $::preset_value_color
	set lb4c $::preset_value_color


	if {$::settings(steam_timeout) == [dict get $steams 1 value]} {
		set lb1c $::preset_label_selected_color
	} 
	if {$::settings(steam_timeout) == [dict get $steams 2 value]} {
		set lb2c $::preset_label_selected_color
	} 
	if {$::settings(steam_timeout) == [dict get $steams 3 value]} {
		set lb3c $::preset_label_selected_color
	} 
	if {$::settings(steam_timeout) == [dict get $steams 4 value]} {
		set lb4c $::preset_label_selected_color
	}

	.can itemconfigure steam_btn_1 -fill $lb1c
	.can itemconfigure steam_btn_2 -fill $lb2c
	.can itemconfigure steam_btn_3 -fill $lb3c
	.can itemconfigure steam_btn_4 -fill $lb4c
}


proc refresh_favorite_hw_button_labels {} {

	puts "refresh_favorite_hw_button_labels"

	set hwvols [ifexists ::settings(favorite_hwvols)]
	set streamline_selected_favorite_hwvol ""
	catch {
		set streamline_selected_favorite_hwvol [dict get $hwvols selected number]
	}

	set hwtemps [ifexists ::settings(favorite_hwtemps)]
	catch {
		set streamline_selected_favorite_hwtemp [dict get $hwtemps selected number]
	}

	set changed 0

	####
	# vol fist
	set t1 ""
	set t2 ""
	set t3 ""
	set t4 ""

	catch {
		set t1 [dict get $hwvols 1 value]
	}
	catch {
		set t2 [dict get $hwvols 2 value]
	}
	catch {
		set t3 [dict get $hwvols 3 value]
	}
	catch {
		set t4 [dict get $hwvols 4 value]
	}

	if {$t1 == ""} {
		set t1 "10"
		dict set hwvols 1 value $t1
		set changed 1
	}

	if {$t2 == ""} {
		set t2 "20"		
		dict set hwvols 2 value $t2
		set changed 1
	}

	if {$t3 == ""} {
		set t3 "50"		
		dict set hwvols 3 value $t3
		set changed 1
	}

	if {$t4 == ""} {
		set t4 "100"		
		dict set hwvols 4 value $t4
		set changed 1
	}

	# temp second
	set bt1 ""
	set bt2 ""
	set bt3 ""
	set bt4 ""

	catch {
		set bt1 [dict get $hwtemps 1 value]
	}
	catch {
		set bt2 [dict get $hwtemps 2 value]
	}
	catch {
		set bt3 [dict get $hwtemps 3 value]
	}
	catch {
		set bt4 [dict get $hwtemps 4 value]
	}

	if {$bt1 == ""} {
		set bt1 "30"
		dict set hwtemps 1 value $bt1
		set changed 1
	}

	if {$bt2 == ""} {
		set bt2 "40"		
		dict set hwtemps 2 value $bt2
		set changed 1
	}

	if {$bt3 == ""} {
		set bt3 "50"		
		dict set hwtemps 3 value $bt3
		set changed 1
	}

	if {$bt4 == ""} {
		set bt4 "60"		
		dict set hwtemps 4 value $bt4
		set changed 1
	}

	######

	if {$changed == 1} {
		set ::settings(favorite_hwvols) $hwvols	
		set ::settings(favorite_hwtemps) $hwtemps	
		save_settings	
		
	}


	if {$::streamline_hotwater_btn_mode == "ml"} {
		set ::streamline_favorite_hw_buttons(label_1) "[return_liquid_measurement_ml $t1]"
		set ::streamline_favorite_hw_buttons(label_2) "[return_liquid_measurement_ml $t2]"
		set ::streamline_favorite_hw_buttons(label_3) "[return_liquid_measurement_ml $t3]"
		set ::streamline_favorite_hw_buttons(label_4) "[return_liquid_measurement_ml $t4]"
	} else {
		set ::streamline_favorite_hw_buttons(label_1) "[return_temperature_measurement $bt1 1]"
		set ::streamline_favorite_hw_buttons(label_2) "[return_temperature_measurement $bt2 1]"
		set ::streamline_favorite_hw_buttons(label_3) "[return_temperature_measurement $bt3 1]"
		set ::streamline_favorite_hw_buttons(label_4) "[return_temperature_measurement $bt4 1]"
	}

	set lb1c $::preset_value_color
	set lb2c $::preset_value_color
	set lb3c $::preset_value_color
	set lb4c $::preset_value_color

	set lb1c2 $::preset_value_color
	set lb2c2 $::preset_value_color
	set lb3c2 $::preset_value_color
	set lb4c2 $::preset_value_color


	if {$::streamline_hotwater_btn_mode == "ml"} {
		if {[round_to_two_digits $::settings(water_volume)] == [dict get $hwvols 1 value]} {
			set lb1c $::preset_label_selected_color
		} 
		if {[round_to_two_digits $::settings(water_volume)] == [dict get $hwvols 2 value]} {
			set lb2c $::preset_label_selected_color
		} 
		if {[round_to_two_digits $::settings(water_volume)] == [dict get $hwvols 3 value]} {
			set lb3c $::preset_label_selected_color
		} 
		if {[round_to_two_digits $::settings(water_volume)] == [dict get $hwvols 4 value]} {
			set lb4c $::preset_label_selected_color
		}
	} else {

		
		if {[round_to_two_digits $::settings(water_temperature)] == [dict get $hwtemps 1 value]} {
			set lb1c $::preset_label_selected_color
		} 
		if {[round_to_two_digits $::settings(water_temperature)] == [dict get $hwtemps 2 value]} {
			set lb2c $::preset_label_selected_color
		} 
		if {[round_to_two_digits $::settings(water_temperature)] == [dict get $hwtemps 3 value]} {
			set lb3c $::preset_label_selected_color
		} 
		if {[round_to_two_digits $::settings(water_temperature)] == [dict get $hwtemps 4 value]} {
			set lb4c $::preset_label_selected_color
		}
	}

#set lb1c #ff0000
	.can itemconfigure hw_btn_1 -fill $lb1c
	.can itemconfigure hw_btn_2 -fill $lb2c
	.can itemconfigure hw_btn_3 -fill $lb3c
	.can itemconfigure hw_btn_4 -fill $lb4c

}



proc refresh_favorite_dosebev_button_labels {} {

	puts "refresh_favorite_dosebev_button_labels"

	set dosebevs [ifexists ::settings(favorite_dosebevs)]
	set streamline_selected_favorite_dosebev ""
	catch {
		set streamline_selected_favorite_dosebev [dict get $dosebevs selected number]
	}

	set dosebevs [ifexists ::settings(favorite_dosebevs)]
	set changed 0

	####
	# dose fist
	set t1 ""
	set t2 ""
	set t3 ""
	set t4 ""

	catch {
		set t1 [dict get $dosebevs 1 value]
	}
	catch {
		set t2 [dict get $dosebevs 2 value]
	}
	catch {
		set t3 [dict get $dosebevs 3 value]
	}
	catch {
		set t4 [dict get $dosebevs 4 value]
	}

	if {$t1 == ""} {
		set t1 "15"
		dict set dosebevs 1 value $t1
		set changed 1
	}

	if {$t2 == ""} {
		set t2 "16"		
		dict set dosebevs 2 value $t2
		set changed 1
	}

	if {$t3 == ""} {
		set t3 "18"		
		dict set dosebevs 3 value $t3
		set changed 1
	}

	if {$t4 == ""} {
		set t4 "20"		
		dict set dosebevs 4 value $t4
		set changed 1
	}

	# beverage second
	set bt1 ""
	set bt2 ""
	set bt3 ""
	set bt4 ""

	catch {
		set bt1 [dict get $dosebevs 1 value2]
	}
	catch {
		set bt2 [dict get $dosebevs 2 value2]
	}
	catch {
		set bt3 [dict get $dosebevs 3 value2]
	}
	catch {
		set bt4 [dict get $dosebevs 4 value2]
	}

	if {$bt1 == ""} {
		set bt1 "30"
		dict set dosebevs 1 value2 $bt1
		set changed 1
	}

	if {$bt2 == ""} {
		set bt2 "32"		
		dict set dosebevs 2 value2 $bt2
		set changed 1
	}

	if {$bt3 == ""} {
		set bt3 "36"		
		dict set dosebevs 3 value2 $bt3
		set changed 1
	}

	if {$bt4 == ""} {
		set bt4 "40"		
		dict set dosebevs 4 value2 $bt4
		set changed 1
	}

	######

	if {$changed == 1} {
		set ::settings(favorite_dosebevs) $dosebevs	
		save_settings			
	}

	set ::streamline_favorite_dosebev_buttons(label_1) "[round_to_one_digits_if_needed $t1]:[round_to_one_digits_if_needed $bt1]"
	set ::streamline_favorite_dosebev_buttons(label_2) "[round_to_one_digits_if_needed $t2]:[round_to_one_digits_if_needed $bt2]"
	set ::streamline_favorite_dosebev_buttons(label_3) "[round_to_one_digits_if_needed $t3]:[round_to_one_digits_if_needed $bt3]"
	set ::streamline_favorite_dosebev_buttons(label_4) "[round_to_one_digits_if_needed $t4]:[round_to_one_digits_if_needed $bt4]"


	set lb1c $::preset_value_color
	set lb2c $::preset_value_color
	set lb3c $::preset_value_color
	set lb4c $::preset_value_color


	
	if {[round_to_two_digits $::settings(grinder_dose_weight)] == [dict get $dosebevs 1 value] && [round_to_two_digits [determine_final_weight] ] == [dict get $dosebevs 1 value2]} {
		set lb1c $::preset_label_selected_color
	} 
	if {[round_to_two_digits $::settings(grinder_dose_weight)] == [dict get $dosebevs 2 value] && [round_to_two_digits [determine_final_weight] ] == [dict get $dosebevs 2 value2]} {
		set lb2c $::preset_label_selected_color
	} 
	if {[round_to_two_digits $::settings(grinder_dose_weight)] == [dict get $dosebevs 3 value] && [round_to_two_digits [determine_final_weight] ] == [dict get $dosebevs 3 value2]} {
		set lb3c $::preset_label_selected_color
	} 
	if {[round_to_two_digits $::settings(grinder_dose_weight)] == [dict get $dosebevs 4 value] && [round_to_two_digits [determine_final_weight] ] == [dict get $dosebevs 4 value2]} {
		set lb4c $::preset_label_selected_color
	}

	.can itemconfigure dose_btn_1 -fill $lb1c
	.can itemconfigure dose_btn_2 -fill $lb2c
	.can itemconfigure dose_btn_3 -fill $lb3c
	.can itemconfigure dose_btn_4 -fill $lb4c
}

proc refresh_favorite_flush_button_labels {} {

	puts "refresh_favorite_flush_button_labels"

	set flushs [ifexists ::settings(favorite_flushs)]
	set streamline_selected_favorite_flush ""
	catch {
		set streamline_selected_favorite_flush [dict get $flushs selected number]
	}

	set flushs [ifexists ::settings(favorite_flushs)]

	set t1 ""
	set t2 ""
	set t3 ""
	set t4 ""

	catch {
		set t1 [dict get $flushs 1 value]
	}
	catch {
		set t2 [dict get $flushs 2 value]
	}
	catch {
		set t3 [dict get $flushs 3 value]
	}
	catch {
		set t4 [dict get $flushs 4 value]
	}

	set changed 0
	if {$t1 == ""} {
		set t1 "3"
		dict set flushs 1 value $t1
		set changed 1
	}

	if {$t2 == ""} {
		set t2 "5"		
		dict set flushs 2 value $t2
		set changed 1
	}

	if {$t3 == ""} {
		set t3 "10"		
		dict set flushs 3 value $t3
		set changed 1
	}

	if {$t4 == ""} {
		set t4 "15"		
		dict set flushs 4 value $t4
		set changed 1
	}


	if {$changed == 1} {
		set ::settings(favorite_flushs) $flushs	
		save_settings	
		
	}

	set ::streamline_favorite_flush_buttons(label_1) [seconds_text_very_abbreviated $t1]
	set ::streamline_favorite_flush_buttons(label_2) [seconds_text_very_abbreviated $t2]
	set ::streamline_favorite_flush_buttons(label_3) [seconds_text_very_abbreviated $t3]
	set ::streamline_favorite_flush_buttons(label_4) [seconds_text_very_abbreviated $t4]


	set lb1c $::preset_value_color
	set lb2c $::preset_value_color
	set lb3c $::preset_value_color
	set lb4c $::preset_value_color


	if {$::settings(flush_seconds) == [dict get $flushs 1 value]} {
		set lb1c $::preset_label_selected_color
	} 
	if {$::settings(flush_seconds) == [dict get $flushs 2 value]} {
		set lb2c $::preset_label_selected_color
	} 
	if {$::settings(flush_seconds) == [dict get $flushs 3 value]} {
		set lb3c $::preset_label_selected_color
	} 
	if {$::settings(flush_seconds) == [dict get $flushs 4 value]} {
		set lb4c $::preset_label_selected_color
	}

	.can itemconfigure flush_btn_1 -fill $lb1c
	.can itemconfigure flush_btn_2 -fill $lb2c
	.can itemconfigure flush_btn_3 -fill $lb3c
	.can itemconfigure flush_btn_4 -fill $lb4c
}


proc streamline_temperature_select { slot } {
	puts "streamline_temperature_select { $slot } "

	if {[dui page current] != "off"} {
		return ""
	}

	catch {
		# get the favoritae button values
		set temperatures [ifexists ::settings(favorite_temperatures)]

		# set the setting
		#set ::settings(espresso_temperature) [dict get $temperatures $slot value]
		set dest_temp [dict get $temperatures $slot value]
		set diff_temp [expr {$dest_temp - $::settings(espresso_temperature)}]
		change_espresso_temperature $diff_temp

		# save the new selected button 
		dict set temperatures selected number $slot
		set ::settings(favorite_temperatures) $temperatures	
		save_profile_and_update_de1_soon	


	}

	refresh_favorite_temperature_button_labels
	streamline_blink_rounded_setting "temp_setting_rectangle" "temp_label_1st"
	#streamline_blink_rounded_setting "temp_preset_rectangle_$slot" "temp_btn_$slot"
	#streamline_blink_rounded_setting "" "temp_btn_$slot"

}

refresh_favorite_temperature_button_labels


proc streamline_steam_select { slot } {
	puts "streamline_steam_select { $slot } "

	if {[dui page current] != "off"} {
		return ""
	}

	catch {
		# get the favoritae button values
		set steams [ifexists ::settings(favorite_steams)]

		# set the setting
		set ::settings(steam_timeout) [dict get $steams $slot value]

		# save the new selected button 
		dict set steams selected number $slot
		set ::settings(favorite_steams) $steams	
		save_profile_and_update_de1_soon	


	}

	refresh_favorite_steam_button_labels

	
	streamline_blink_rounded_setting "steam_setting_rectangle" "steam_label_1st"
	#streamline_blink_rounded_setting "steam_preset_rectangle_$slot" "steam_btn_$slot"
	#streamline_blink_rounded_setting "" "steam_btn_$slot"
}

refresh_favorite_steam_button_labels


proc streamline_dosebev_select { slot } {
	puts "streamline_dosebev_select { $slot } "

	if {[dui page current] != "off"} {
		return ""
	}

	#catch {
		# get the favoritae button values
		set dosebevs [ifexists ::settings(favorite_dosebevs)]

		# set the setting
		set ::settings(grinder_dose_weight) [dict get $dosebevs $slot value]

		# setting the final weight is more complicated, as it is stored in a few different places depending on the profile
		set desired_weight [dict get $dosebevs $slot value2]

		set ::settings(final_desired_shot_weight) $desired_weight
		set ::settings(final_desired_shot_weight_advanced) $desired_weight
		set ::settings(final_desired_shot_volume) $desired_weight
		set ::settings(final_desired_shot_volume_advanced) $desired_weight

		if {[::device::scale::expecting_present]} {
			# if they have a scale, then make the volumetric 10g more, so that it is there only as a safety in case the scale turns off
			set ::settings(final_desired_shot_volume) [expr {$desired_weight + 10}]
			set ::settings(final_desired_shot_volume_advanced)  [expr {$desired_weight + 10}]
		}

		puts "ERROR expecting_present [::device::scale::expecting_present]"


		# save the new selected button 
		dict set dosebevs selected number $slot
		set ::settings(favorite_dosebevs) $dosebevs	
		save_profile_and_update_de1_soon	


	#}
	streamline_blink_rounded_setting "dose_setting_rectangle" "dose_label_1st"
	streamline_blink_rounded_setting "weight_setting_rectangle" "weight_label_1st"
	#streamline_blink_rounded_setting "dose_preset_rectangle_$slot" "dose_btn_$slot"\
	streamline_blink_rounded_setting "" "dose_btn_$slot"

	refresh_favorite_dosebev_button_labels
}
refresh_favorite_dosebev_button_labels

proc streamline_flush_select { slot } {
	puts "streamline_flush_select { $slot } "

	if {[dui page current] != "off"} {
		return ""
	}

	catch {
		# get the favoritae button values
		set flushs [ifexists ::settings(favorite_flushs)]

		# set the setting
		set ::settings(flush_seconds) [dict get $flushs $slot value]

		# save the new selected button 
		dict set flushs selected number $slot
		set ::settings(favorite_flushs) $flushs	
		save_profile_and_update_de1_soon	


	}

	streamline_blink_rounded_setting "flush_setting_rectangle" "flush_label_1st"
	#streamline_blink_rounded_setting "flush_preset_rectangle_$slot" "flush_btn_$slot"
	#streamline_blink_rounded_setting "" "flush_btn_$slot"

	refresh_favorite_flush_button_labels
}
refresh_favorite_flush_button_labels


proc streamline_hw_preset_select { slot } {

	if {$::streamline_hotwater_btn_mode == "ml"} {
		streamline_hwvol_select $slot
	} else {
		streamline_hwtemp_select $slot
	}

	streamline_blink_rounded_setting "hotwater_setting_rectangle" "hotwater_label_1st"
	#streamline_blink_rounded_setting "hot_water_preset_rectangle_$slot" "hw_btn_$slot"
	#streamline_blink_rounded_setting "" "hw_btn_$slot"

}

proc streamline_blink_rounded_setting { rect txt } {
	.can itemconfigure $rect -fill $::blink_button_color
	.can itemconfigure $txt -fill $::button_inverted_text_color
	after 400 .can itemconfigure $rect -fill $::box_color
	after 400 .can itemconfigure $txt -fill $::plus_minus_value_text_color
}



proc streamline_hwvol_select { slot } {
	puts "streamline_hwvol_select { $slot } "

	if {[dui page current] != "off"} {
		return ""
	}

#	catch {
		# get the favoritae button values
		set hwvols [ifexists ::settings(favorite_hwvols)]

		# set the setting
		set ::settings(water_volume) [dict get $hwvols $slot value]

		# save the new selected button 
		dict set hwvols selected number $slot
		set ::settings(favorite_hwvols) $hwvols	
		save_profile_and_update_de1_soon	


#	}
	streamline_hot_water_setting_change
	refresh_favorite_hw_button_labels
}
refresh_favorite_hw_button_labels


proc streamline_hwtemp_select { slot } {
	puts "streamline_hwtemp_select { $slot } "

	if {[dui page current] != "off"} {
		return ""
	}

	#catch {
		# get the favoritae button values
		set hwtemps [ifexists ::settings(favorite_hwtemps)]

		# set the setting
		set ::settings(water_temperature) [dict get $hwtemps $slot value]

		# save the new selected button 
		dict set hwtemps selected number $slot
		set ::settings(favorite_hwtemps) $hwtemps	
		save_profile_and_update_de1_soon	


	#}

	streamline_hot_water_setting_change
	refresh_favorite_hw_button_labels
}
refresh_favorite_hw_button_labels

############################################################################################################################################################################################################
# the espresso chart

set ::state_change_dashes "[rescale_x_skin 16] [rescale_x_skin 16]"
set ::temp_goal_dashes "[rescale_x_skin 16] [rescale_x_skin 16]"
set ::pressure_goal_dashes "[rescale_x_skin 8] [rescale_x_skin 8]"
set ::flow_goal_dashes "[rescale_x_skin 8] [rescale_x_skin 8]"


set charts_width 1818
set charts_width_zoomed 2500
set charts_height 784
set charts_height_zoomed 1090

proc streamline_graph_smarts {widget {which ""} } {

	set ::streamline_chart $widget


	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color $::pressurelinecolor_goal  -smooth $::settings(live_graph_smoothing_technique)  -pixels 0 -dashes $::pressure_goal_dashes; 
	$widget element create line_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::pressurelinecolor  -smooth $::settings(live_graph_smoothing_technique) -pixels 0
	

	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color $::flow_line_color_goal -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes $::flow_goal_dashes; 
	$widget element create line_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::flow_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0

	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal10th -symbol none -label ""  -linewidth [rescale_x_skin 2] -color $::temperature_line_color_goal -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::temp_goal_dashes; 
	$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket10th -symbol none -label ""  -linewidth [rescale_x_skin 4] -color $::temperature_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0 


	$widget element create line_espresso_flow_weight  -xdata espresso_elapsed -ydata espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::weightlinecolor -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 

	gridconfigure $widget 

	$widget axis configure x -color $::pressurelabelcolor -tickfont Inter-Regular10 -linewidth [rescale_x_skin 1] -subdivisions 5 -majorticks {0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250} 
	
	if {[lsearch -exact $::zoomed_pages $which] != -1} {
		set mticks {1 2 3 4 5 6 7 8 9 10 11 12} 
		set max 12
	} else {
		set mticks {1 2 3 4 5 6 7 8 9 10} 
		set max 10
	}
	$widget axis configure y -color $::pressurelabelcolor -tickfont Inter-Regular10 -min 0 -max $max -subdivisions 5 -majorticks $mticks

	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 2] -color $::state_change_color  -pixels 0  -dashes $::state_change_dashes

	bind $widget [platform_button_press] { 

		if {$::de1(current_context) == "off"} {
			set ::off_page "off_zoomed"
			set ::espresso_page "espresso_zoomed"
			set_next_page off $::off_page
			set_next_page espresso $::espresso_page
			page_show off;
		} elseif {$::de1(current_context) == "off_zoomed"} {
			set ::off_page "off"
			set ::espresso_page "espresso"
			set_next_page off $::off_page
			set_next_page espresso $::espresso_page
			page_show off;
		} elseif {$::de1(current_context) == "espresso"} {
			set ::off_page "off_zoomed"
			set ::espresso_page "espresso_zoomed"
			set_next_page off $::off_page
			set_next_page espresso $::espresso_page
			page_show espresso;
		} elseif {$::de1(current_context) == "espresso_zoomed"} {
			set ::off_page "off"
			set ::espresso_page "espresso"
			set_next_page off $::off_page
			set_next_page espresso $::espresso_page
			page_show espresso;
		}
	}	

}


add_de1_widget $::pages graph 692 458 { streamline_graph_smarts $widget } -plotbackground $::chart_background -width [rescale_x_skin [expr {$charts_width - $ghc_pos_pffset}]] -height [rescale_y_skin $charts_height] -borderwidth 1 -background $::chart_background -plotrelief flat -plotpady 10 -plotpadx 10  
add_de1_widget $::zoomed_pages graph 22 458 { streamline_graph_smarts $widget "off_zoomed" } -plotbackground $::chart_background -width [rescale_x_skin [expr {$charts_width_zoomed - $ghc_pos_pffset}]] -height [rescale_y_skin $charts_height_zoomed] -borderwidth 1 -background $::chart_background -plotrelief flat -plotpady 10 -plotpadx 10  

############################################################################################################################################################################################################


proc streamline_adjust_chart_x_axis {} {

	set widget $::streamline_chart

	set sz 600

	catch {
		set sz $::de1(espresso_elapsed)
	}

	#puts "ERROR streamline_adjust_chart_x_axis $sz"
	if {$sz < 2} {
		$widget axis configure x -majorticks {0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64} 
	} elseif {$sz < 60} {
		$widget axis configure x -majorticks {0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 125 130 135 140 145 150 155 160 165 170 175 180 185 190 195 200 205 210 215 220 225 230 235 240 245 250 255} 
	} elseif {$sz < 100} {
		$widget axis configure x -majorticks {0 20 40 60 80 100 120} 
	} else {
		$widget axis configure x -majorticks {0 30 60 90 120 150 180 210 240 270} 
	}
}

proc streamline_adjust_chart_x_axis_scheduled {} {
	if {$::de1_num_state($::de1(state)) == "Espresso"} {
		# only automatically adjust the X axis if making espresso, otherwise it's done when the chart changes
		streamline_adjust_chart_x_axis
	}

	after 1000 streamline_adjust_chart_x_axis
}

streamline_adjust_chart_x_axis_scheduled

add_de1_button "saver descaling cleaning" {say [translate {awake}] $::settings(sound_button_in); set_next_page off $::off_page; page_show off; start_idle; de1_send_waterlevel_settings;} 0 0 2560 1600 "buttonnativepress"


proc streamline_load_history_shot {current_shot_filename} {

	set ::streamline_history_text_label [translate "HISTORY"] 

	if {$::streamline_history_file_selected_number == [expr {[llength $::streamline_history_files] -1}]} {
		set ::streamline_history_text_label [translate "NEWEST"] 
	} elseif {$::streamline_history_file_selected_number == 0} {
		set ::streamline_history_text_label [translate "OLDEST"] 
	}

	#puts "ERROR streamline_load_history_shot"


	array set past_shot_array [encoding convertfrom utf-8 [read_file "[homedir]/history/$current_shot_filename"]]
	espresso_elapsed clear

	espresso_elapsed set [ifexists past_shot_array(espresso_elapsed)]

	set ::de1(espresso_elapsed) [lindex [ifexists past_shot_array(espresso_elapsed)] end]

	espresso_pressure set [ifexists past_shot_array(espresso_pressure)]

	espresso_flow_weight length 0
	set ::de1(scale_raw_weight) [lindex [ifexists past_shot_array(scale_raw_weight)] end]
	if {$::de1(scale_raw_weight) != "" && $::de1(scale_raw_weight) != 0} {
		# don't load a weight line if there's no scale
		espresso_flow_weight set [ifexists past_shot_array(espresso_flow_weight)]
	}


	espresso_flow set [ifexists past_shot_array(espresso_flow)]
	espresso_temperature_basket set [ifexists past_shot_array(espresso_temperature_basket)]
	espresso_state_change set [ifexists past_shot_array(espresso_state_change)]
	espresso_pressure_goal set [ifexists past_shot_array(espresso_pressure_goal)]
	espresso_flow_goal set [ifexists past_shot_array(espresso_flow_goal)]
	espresso_temperature_goal set [ifexists past_shot_array(espresso_temperature_goal)]

	espresso_temperature_basket10th length 0
	foreach t [ifexists past_shot_array(espresso_temperature_basket)] {
		espresso_temperature_basket10th append [expr {$t / 10.0}]
	}

	espresso_temperature_goal10th length 0
	foreach t [ifexists past_shot_array(espresso_temperature_goal)] {
		espresso_temperature_goal10th append [expr {$t / 10.0}]
	}

	set ::streamline_current_history_profile_clock [ifexists past_shot_array(clock)]

	update_data_card past_shot_array
}

proc update_data_card { arrname } {

	upvar $arrname past_shot_array

	#puts "ERROR el: [ifexists past_shot_array(espresso_elapsed)]"

	#puts "profile_data: [array get profile_data]"
	#array set profile_data [ifexists past_shot_array(settings)]
	array set profile_data [array get ::settings]

	set ::streamline_current_history_profile_name [ifexists profile_data(profile_title)]

	#####################################
	set third_line_parts ""

	if {[ifexists profile_data(grinder_dose_weight)] != ""} {
		lappend third_line_parts "[translate "In"] $profile_data(grinder_dose_weight)[translate "g"]"
	}
	
	if {[ifexists profile_data(grinder_setting)] != ""} {
		lappend third_line_parts "[translate "Grind"] $profile_data(grinder_setting)"
	}

	set ::streamline_current_history_third_line [join $third_line_parts "  |  "]
	#####################################
	

	set profile_type [::profile::fix_profile_type [ifexists profile_data(settings_profile_type)]]
	#puts "profile_type: $profile_type"

	streamline_adjust_chart_x_axis


	if { $profile_type eq "settings_2a" || $profile_type eq "settings_2b" } {
		set preinfusion_end_step 2
	} else {
		set preinfusion_end_step [ifexists profile_data(final_desired_shot_volume_advanced_count_start)]
	}
	#puts "preinfusion_end_step: $preinfusion_end_step"
	
	set i 0

	set ::streamline_preinfusion_time 0
	set ::streamline_preinfusion_weight 0
	set ::streamline_preinfusion_volume 0
	set ::streamline_preinfusion_temp_high 0
	set ::streamline_preinfusion_temp_low 100
	set ::streamline_preinfusion_low_flow 15
	set ::streamline_preinfusion_peak_flow 0
	set ::streamline_preinfusion_low_pressure 15
	set ::streamline_preinfusion_peak_pressure 0

	set ::streamline_preinfusion_temp_start 100
	set ::streamline_preinfusion_temp_end 0
	set ::streamline_preinfusion_flow_start 15
	set ::streamline_preinfusion_flow_end 0
	set ::streamline_preinfusion_pressure_start 15
	set ::streamline_preinfusion_pressure_end 0


	set ::streamline_extraction_time 0
	set ::streamline_extraction_weight 0
	set ::streamline_extraction_volume 0
	set ::streamline_extraction_temp_high 0
	set ::streamline_extraction_temp_low 100
	set ::streamline_extraction_peak_flow 0
	set ::streamline_extraction_peak_pressure 0
	set ::streamline_extraction_low_flow 15
	set ::streamline_extraction_low_pressure 15

	set ::streamline_extraction_temp_start 100
	set ::streamline_extraction_temp_end 0
	set ::streamline_extraction_flow_start 15
	set ::streamline_extraction_flow_end 0
	set ::streamline_extraction_pressure_start 15
	set ::streamline_extraction_pressure_end 0



	set state "preinfusion"
	set state_change 0
	set stepnum 0

	foreach t [ifexists past_shot_array(espresso_elapsed)] {

		#puts "t is: $t of '$past_shot_array(espresso_elapsed)'"
		#puts "espresso_pressure is '$past_shot_array(espresso_pressure)'"

		set espresso_pressure [return_zero_if_blank [lindex $past_shot_array(espresso_pressure) $i]]
		set espresso_weight [return_zero_if_blank [lindex [ifexists past_shot_array(espresso_weight)] $i]]
		set espresso_flow [return_zero_if_blank [lindex $past_shot_array(espresso_flow) $i]]
		set espresso_flow_weight [return_zero_if_blank [lindex [ifexists past_shot_array(espresso_flow_weight)] $i]]
		set espresso_temperature_basket [return_zero_if_blank [lindex $past_shot_array(espresso_temperature_basket) $i]]
		set espresso_water_dispensed [return_zero_if_blank [lindex $past_shot_array(espresso_water_dispensed) $i]]

		set espresso_state_change 0
		catch {
			set espresso_state_change [return_zero_if_blank [lindex $past_shot_array(espresso_state_change) $i]]
		}

		if {$espresso_water_dispensed == 0 || $espresso_water_dispensed == ""} {
			# ship shots 
			#continue
		}

		if {$state == "preinfusion"} {
			set ::streamline_preinfusion_temp_end $espresso_temperature_basket
			set ::streamline_preinfusion_flow_end $espresso_flow
			set ::streamline_preinfusion_pressure_end $espresso_pressure


		} else {
			# keep track of final numbers 
			set ::streamline_extraction_temp_end $espresso_temperature_basket
			set ::streamline_extraction_flow_end $espresso_flow
			set ::streamline_extraction_pressure_end $espresso_pressure
		}

		if {$state_change != $espresso_state_change} {

			if {$stepnum == 0} {
				set ::streamline_preinfusion_temp_start $espresso_temperature_basket
				set ::streamline_preinfusion_flow_start $espresso_flow
				set ::streamline_preinfusion_pressure_start $espresso_pressure
			}

			incr stepnum
			set state_change $espresso_state_change

			if {$stepnum >= $preinfusion_end_step} {

				if {$state != "extraction"} {
					set ::streamline_extraction_temp_start $espresso_temperature_basket
					set ::streamline_extraction_flow_start $espresso_flow
					set ::streamline_extraction_pressure_start $espresso_pressure
				}

				set state "extraction"
			}


		}



		#puts "ERROR preinfusion_end_step: $stepnum > $preinfusion_end_step"
		#puts "stat ${state} : $stepnum > $preinfusion_end_step"
		set ::streamline_${state}_time $t
		if {$espresso_weight > 0} {
			set ::streamline_${state}_weight $espresso_weight
		}
		set ::streamline_${state}_volume [expr {$espresso_water_dispensed * 10}]
		

		# peak pressure
		if {$espresso_pressure > [subst "\$::streamline_${state}_peak_pressure"]} {
			set ::streamline_${state}_peak_pressure $espresso_pressure
		}

		# low pressure
		if {$espresso_pressure < [subst "\$::streamline_${state}_low_pressure"]} {
			set ::streamline_${state}_low_pressure $espresso_pressure
		}

		# peak flow
		if {$espresso_flow > [subst "\$::streamline_${state}_peak_flow"]} {
			set ::streamline_${state}_peak_flow $espresso_flow
		}
		# low flow
		if {$espresso_flow < [subst "\$::streamline_${state}_low_flow"]} {
			set ::streamline_${state}_low_flow $espresso_flow
		}


		# high temp
		if {$espresso_temperature_basket > [subst "\$::streamline_${state}_temp_high"]} {
			set ::streamline_${state}_temp_high $espresso_temperature_basket
		}

		# low temp
		if {$espresso_temperature_basket < [subst "\$::streamline_${state}_temp_low"]} {
			set ::streamline_${state}_temp_low $espresso_temperature_basket
		}

		incr i
	}



	if {[info exists past_shot_array(espresso_elapsed)] != 1} {
		set t 0
		set espresso_weight 0
		set espresso_water_dispensed 0
	}


	set ::streamline_shot_time $t
	set ::streamline_shot_weight $espresso_weight
	set ::streamline_shot_volume [expr {10.0 * $espresso_water_dispensed}]
	set ::streamline_final_extraction_time [expr {$t - $::streamline_preinfusion_time}]


	set ::streamline_final_extraction_volume [expr {$::streamline_shot_volume - $::streamline_preinfusion_volume}]
	set ::streamline_final_extraction_weight [expr {$::streamline_shot_weight - $::streamline_preinfusion_weight}]

	set ::streamline_preinfusion_peak_flow [round_to_one_digits $::streamline_preinfusion_peak_flow]
	set ::streamline_preinfusion_peak_pressure [round_to_one_digits $::streamline_preinfusion_peak_pressure]
	set ::streamline_extraction_peak_flow [round_to_one_digits $::streamline_extraction_peak_flow]
	set ::streamline_extraction_peak_pressure [round_to_one_digits $::streamline_extraction_peak_pressure]



	if {$::android == 1 || $::undroid == 1} {
		set arrow "🡒"
	} else {
		set arrow "->"
	}

	set ::streamline_preinfusion_temp ""
	set ::streamline_extraction_temp ""

	set show_high_low 0

	if {$show_high_low == 1} {
		if {$::streamline_preinfusion_temp_high == 0} {
			# no label
		} elseif {[round_to_integer $::streamline_preinfusion_temp_low] == [round_to_integer $::streamline_preinfusion_temp_high]} {
			set ::streamline_preinfusion_temp [string tolower [return_temperature_measurement $::streamline_preinfusion_temp_high 1]]
		} else {
			set ::streamline_preinfusion_temp "[string tolower [round_to_integer $::streamline_preinfusion_temp_low]]$arrow[string tolower [return_temperature_measurement $::streamline_preinfusion_temp_high 1]]"
		}

		if {$::streamline_extraction_temp_high == 0} {
			# no label
			set ::streamline_extraction_temp ""
		} elseif {[round_to_integer $::streamline_extraction_temp_low] == [round_to_integer $::streamline_extraction_temp_high]} {
			set ::streamline_extraction_temp [string tolower [return_temperature_measurement $::streamline_extraction_temp_high 1]]
		} else {
			set ::streamline_extraction_temp "[string tolower [round_to_integer $::streamline_extraction_temp_low]]$arrow[string tolower [return_temperature_measurement $::streamline_extraction_temp_high 1]]"
		}



		set ::streamline_preinfusion_low_peak_pressure_label "[round_one_digits_or_integer_if_needed $::streamline_preinfusion_low_pressure]$arrow[round_one_digits_or_integer_if_needed $::streamline_preinfusion_peak_pressure] [translate "bar"]"
		set ::streamline_extraction_low_peak_pressure_label "[round_one_digits_or_integer_if_needed $::streamline_extraction_low_pressure]$arrow[round_one_digits_or_integer_if_needed $::streamline_extraction_peak_pressure] [translate "bar"]"

		set ::streamline_preinfusion_low_peak_flow_label "[round_one_digits_or_integer_if_needed $::streamline_preinfusion_low_flow]$arrow[round_one_digits_or_integer_if_needed $::streamline_preinfusion_peak_flow] [translate "ml/s"]"
		set ::streamline_extraction_low_peak_flow_label "[round_one_digits_or_integer_if_needed $::streamline_extraction_low_flow]$arrow[round_one_digits_or_integer_if_needed $::streamline_extraction_peak_flow] [translate "ml/s"]"

	} else {

		# show start/end numbers

		if {$::streamline_preinfusion_temp_end == 0} {
			# no label
		} elseif {[round_to_integer $::streamline_preinfusion_temp_start] == [round_to_integer $::streamline_preinfusion_temp_end]} {
			set ::streamline_preinfusion_temp [string tolower [return_temperature_measurement $::streamline_preinfusion_temp_end 1]]
		} else {
			set ::streamline_preinfusion_temp "[string tolower [round_to_integer $::streamline_preinfusion_temp_start]]$arrow[string tolower [return_temperature_measurement $::streamline_preinfusion_temp_end 1]]"
		}

		if {$::streamline_extraction_temp_end == 0} {
			# no label
			set ::streamline_extraction_temp ""
		} elseif {[round_to_integer $::streamline_extraction_temp_end] == [round_to_integer $::streamline_extraction_temp_end]} {
			set ::streamline_extraction_temp [string tolower [return_temperature_measurement $::streamline_extraction_temp_end 1]]
		} else {
			set ::streamline_extraction_temp "[string tolower [round_to_integer $::streamline_extraction_temp_end]]$arrow[string tolower [return_temperature_measurement $::streamline_extraction_temp_end 1]]"
		}



		set ::streamline_preinfusion_low_peak_pressure_label "[round_one_digits_or_integer_if_needed $::streamline_preinfusion_pressure_start]$arrow[round_one_digits_or_integer_if_needed $::streamline_preinfusion_pressure_end] [translate "bar"]"
		set ::streamline_extraction_low_peak_pressure_label "[round_one_digits_or_integer_if_needed $::streamline_extraction_pressure_start]$arrow[round_one_digits_or_integer_if_needed $::streamline_extraction_pressure_end] [translate "bar"]"

		set ::streamline_preinfusion_low_peak_flow_label "[round_one_digits_or_integer_if_needed $::streamline_preinfusion_flow_start]$arrow[round_one_digits_or_integer_if_needed $::streamline_preinfusion_flow_end] [translate "ml/s"]"
		set ::streamline_extraction_low_peak_flow_label "[round_one_digits_or_integer_if_needed $::streamline_extraction_flow_start]$arrow[round_one_digits_or_integer_if_needed $::streamline_extraction_flow_end] [translate "ml/s"]"

	}

	#set ::streamline_preinfusion_low_peak_pressure_label ""
	#set ::streamline_preinfusion_low_peak_flow_label ""

	#set ::streamline_extraction_low_peak_pressure_label ""
	#set ::streamline_extraction_low_peak_flow_label ""


	if {$::de1(state) == 4} {
		if {$state == "preinfusion"} {
			# if there was no extraction, use blanks
			set ::streamline_extraction_weight ""
			set ::streamline_extraction_volume ""
			set ::streamline_extraction_temp_high ""
			set ::streamline_extraction_temp_low ""
			set ::streamline_extraction_peak_flow ""
			set ::streamline_extraction_peak_pressure ""

			set ::streamline_final_extraction_volume ""
			set ::streamline_final_extraction_weight ""
			set ::streamline_final_extraction_time ""

			set ::streamline_shot_time ""
			set ::streamline_shot_weight ""
			set ::streamline_shot_volume ""

			set ::streamline_extraction_low_peak_pressure_label ""
			set ::streamline_extraction_low_peak_flow_label ""

			set ::streamline_preinfusion_low_peak_pressure_label "[round_one_digits $::de1(pressure)] [translate "bar"]"
			set ::streamline_preinfusion_low_peak_flow_label "[round_to_one_digits $::de1(flow)] [translate "ml/s"]"
			set ::streamline_preinfusion_temp [return_temperature_measurement $::de1(head_temperature)]

		} else {
			set ::streamline_shot_time ""
			set ::streamline_shot_weight ""
			set ::streamline_shot_volume ""

			set ::streamline_extraction_low_peak_pressure_label "[round_one_digits $::de1(pressure)] [translate "bar"]"
			set ::streamline_extraction_low_peak_flow_label "[round_to_one_digits $::de1(flow)] [translate "ml/s"]"
			set ::streamline_extraction_temp [return_temperature_measurement $::de1(head_temperature)]

		}
	}

	#puts "ERROR $::de1(state) '$state'"

	if {$::streamline_preinfusion_time == 0} {
		set ::streamline_preinfusion_low_peak_pressure_label ""
		set ::streamline_preinfusion_low_peak_flow_label ""
		set ::streamline_preinfusion_temp ""
	}
	if {$::streamline_final_extraction_time == 0} {
		set ::streamline_extraction_low_peak_pressure_label ""
		set ::streamline_extraction_low_peak_flow_label ""
		set ::streamline_extraction_temp ""
	}


	return

	puts "preinfusion_peak_pressure : $::streamline_preinfusion_peak_pressure"
	puts "preinfusion_peak_flow : $::streamline_preinfusion_peak_flow"

	puts "preinfusion_time : $::streamline_preinfusion_time"
	puts "extraction_time : $::streamline_extraction_time"

	puts "preinfusion_temp_low : $::streamline_preinfusion_temp_low"
	puts "preinfusion_temp_high : $::streamline_preinfusion_temp_high"

	puts "extraction_temp_low : $::streamline_extraction_temp_low"
	puts "extraction_temp_high : $::streamline_extraction_temp_high"

	puts "preinfusion_weight : $::streamline_preinfusion_weight"
	puts "extraction_weight : $::streamline_extraction_weight"

	puts "preinfusion_volume : $::streamline_preinfusion_volume"
	puts "extraction_volume : $::streamline_extraction_volume"

	puts "extraction_peak_pressure : $::streamline_extraction_peak_pressure"
	puts "extraction_peak_flow : $::streamline_extraction_peak_flow"



}
proc streamline_load_currently_selected_history_shot {} {
	set current_shot_filename [lindex $::streamline_history_files $::streamline_history_file_selected_number]
	streamline_load_history_shot $current_shot_filename
}

proc streamline_init_history_files {} {
	set ::streamline_history_files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/history/" *.shot]]
	set ::streamline_history_file_selected_number [expr {[llength $::streamline_history_files] -1}]
}

proc streamline_history_profile_btns_refresh {} {

	if {$::streamline_history_file_selected_number == 0} {
		dui item config $::all_pages "profile_back" $::streamline_history_cmd ""
	} else {
		dui item config $::all_pages "profile_back" $::streamline_history_cmd $::streamline_history_left
	}


	if {$::streamline_history_file_selected_number == [llength $::streamline_history_files]-1} {
		dui item config $::all_pages "profile_fwd" $::streamline_history_cmd ""
	} else {
		dui item config $::all_pages "profile_fwd" $::streamline_history_cmd $::streamline_history_right
	}
}

proc streamline_history_profile_back {} {
	set ::streamline_history_file_selected_number [expr {$::streamline_history_file_selected_number	 - 1}]
	if {$::streamline_history_file_selected_number < 0} {
		set ::streamline_history_file_selected_number [expr {[llength $::streamline_history_files] -1}]
	}
	streamline_load_currently_selected_history_shot
	streamline_history_profile_btns_refresh
}

proc streamline_history_profile_fwd { {destination {}} } {

	if {$destination == 0} {
		set ::streamline_history_file_selected_number 0
	} elseif {$destination == 1} {
		set ::streamline_history_file_selected_number [expr {[llength $::streamline_history_files] -1}]
	} else {

		set ::streamline_history_file_selected_number [expr {$::streamline_history_file_selected_number	 + 1}]
		if {$::streamline_history_file_selected_number > [llength $::streamline_history_files]-1} {
			set ::streamline_history_file_selected_number 0
		}
	}

	streamline_history_profile_btns_refresh
	streamline_load_currently_selected_history_shot
}

proc streamline_shot_ended  {} {
	if {[ifexists ::settings(history_saved_shot_filename)] != ""} {		

		# when saving the shot, update the onscreen weight with what the final weight on the scale was.

		lappend ::streamline_history_files [file tail $::settings(history_saved_shot_filename)]
		set ::streamline_history_file_selected_number [expr {[llength $::streamline_history_files] - 1}]

		#streamline_history_profile_fwd 1

		set ::streamline_shot_weight [expr {$::de1(scale_weight_rate_raw)}]
		#set ::streamline_final_extraction_weight [expr {$::streamline_shot_weight - $::streamline_preinfusion_weight}]

	}
	#set current_shot_filename [lindex $::streamline_history_files $::streamline_history_file_selected_number]
}

# not needed in this skin
proc update_temperature_charts_y_axis {} {}


streamline_init_history_files
streamline_load_currently_selected_history_shot


#after 1000 set_next_page off $::zoomed_pages; page_show off_zoomed
#set_next_page off "off_zoomed"
#after 1000 page_show off_zoomed
#after 100 page_show off_zoomed

