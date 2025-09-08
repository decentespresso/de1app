package require de1 1.0

# possible bug fix for long press misfiring bug
sdltk touchtranslate 0

dui theme add streamline
dui theme set streamline

set ::streamline_longpress_threshold 1000

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


if {$::streamline_dark_mode == 0} {
	set ::profile_title_color #385a92
	set ::data_card_confirm_button #385a92
	set ::data_card_confirm_button_text #FFFFFF
	set ::scale_disconnected_color #cd5360
	set ::profile_button_background_selected_color #385992
	set ::profile_button_background_unused_color #f3f4f6
	set ::left_label_color2 #385992
	set ::left_label_color2_disabled #d0d8e5

	set ::progress_bar_red "#DA515E"
	set ::progress_bar_green "#0CA581"
	set ::progress_bar_grey "#c2c2c2"
	
	set ::datacard_number_text_color #121212
	set ::plus_minus_text_color #121212
	set ::plus_minus_value_text_color #121212
	set ::plus_minus_value_text_color_disabled #c8cacc
	set ::data_card_title_text_color #707485
	set ::data_card_text_color #121212
	set ::dataline_label_color #707485
	set ::dataline_data_color #121212
	set ::background_color "#FFFFFF"
	set ::data_card_background_color "#FFFFFF"
	set ::profile_button_background_color "#FFFFFF"
	set ::profile_button_button_color "#5f7ba8"
	set ::profile_button_button_selected_color "#e8e8e8"
	set ::dataentry_button_color "#C9C9C9"
	set ::dataentry_button_color_flash1 "#888888"
	set ::dataentry_button_color_flash2 "#666666"
	set ::datacard_entry_box_color "#1867D6"

	set ::dataentry_favorites_border_color "#888888"
	set ::profile_button_outline_color "#c5cdda"
	set ::ghc_button_background_color "#FFFFFF"
	set ::button_inverted_text_color "#FFFFFF"
	set ::status_clickable_text "#1967d4"
	set ::box_color "#f6f8fa"

	set ::data_card_previous_color "#ffffff"
	set ::data_card_previous_outline_color "#121212"

	set ::box_line_color #e8e8e8
	set ::datacard_box_line_color "#A5A5A5"
	set ::settings_sleep_button_outline_color "#3d5782"
	set ::settings_sleep_button_color "#f6f8fa"
	set ::settings_sleep_button_text_color "#385a92"
	set ::plus_minus_outline_color $::box_color
	set ::plus_minus_flash_on_color  "#b8b8b8"
	set ::plus_minus_flash_on_color2  "#cfcfcf"
	set ::plus_minus_flash_off_color "#ededed"
	set ::plus_minus_flash_off_color_disabled "#f4f6f7"
	set ::plus_minus_flash_refused_color "#e34e4e"
	set ::ghc_button_color "#375a92"
	set ::preset_value_color "#AAAAAA"
	set ::preset_value_color_disabled "#e3e4e6"
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
	set ::data_card_confirm_button #385A92
	set ::data_card_confirm_button_text #FFFFFF

	set ::profile_title_color #e8e8e8
	set ::scale_disconnected_color #cd5360
	set ::profile_button_background_selected_color #415996
	set ::profile_button_background_unused_color #1d1f2b
	set ::left_label_color2 #415996
	set ::left_label_color2_disabled #202c4c

	set ::data_card_previous_color #101117
	set ::data_card_previous_outline_color "#121212"

	set ::data_card_background_color "#17191E"
	set ::datacard_number_text_color #E8E8E8
	set ::plus_minus_text_color #959595
	set ::plus_minus_value_text_color #e8e8e8
	set ::plus_minus_value_text_color_disabled #4a4a4a
	set ::data_card_text_color #e8e8e8
	set ::data_card_title_text_color #707485
	set ::dataline_label_color #707485
	set ::dataline_data_color #e8e8e8
	set ::background_color #0d0e14
	set ::datacard_box_line_color #3D4255



	set ::box_color "#17191e"

	set ::profile_button_background_color #292c38
	set ::profile_button_button_color "#e8e8e8"
	set ::profile_button_button_selected_color "#e8e8e8"
	set ::profile_button_outline_color $::box_color
	set ::dataentry_button_color "#292C38"
	set ::dataentry_button_color_flash1 "#333333"
	set ::dataentry_button_color_flash2 "#444444"
	set ::datacard_entry_box_color #415996
	set ::dataentry_favorites_border_color "#666666"
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
set ::plus_minus_flash_off_color_disabled "#14151b"
set ::plus_minus_flash_refused_color "#e34e4e"
set ::ghc_button_color "#e8e8e8"
	set ::preset_value_color #4e5559
	set ::preset_value_color_disabled "#262a2c"
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
	set ::temperature_line_color "#AE6D73"
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

# disable the scale popup msgs
set ::settings(show_scale_notifications) 0

#load_font "Inter-Regular10" "[homedir]/Streamline/Inter-Regular.ttf" 11

# Left column labels
load_font "Inter-Bold16" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 14
#load_font "Inter-Bold15" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 13

# GHC buttons
load_font "Inter-Bold12" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 12

load_font "Inter-Bold11" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 12

# Profile buttons
load_font "Inter-Bold13" "[homedir]/skins/Streamline/Inter-Bold.ttf" 13 13 bold

# status

load_font "Inter-Bold17" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 12
load_font "Inter-Bold18" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 13
#if {$::undroid == 1} {
#} else {
#	load_font "Inter-Bold18" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 13
#}


# status bold
load_font "Inter-SemiBold18" "[homedir]/skins/Streamline/Inter-Bold.ttf" 13

# +/- buttons
load_font "Inter-Bold24" "[homedir]/skins/Streamline/Inter-ExtraLight.ttf" 29


# data entry buttons
load_font "Inter-Bold40" "[homedir]/skins/Streamline/Inter-Regular.ttf" 39

# data entry backspace button
load_font "Inter-Bold30" "[homedir]/skins/Streamline/Inter-Regular.ttf" 24

# profile 
load_font "Inter-HeavyBold24" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 17

# data entry title 
load_font "Inter-HeavyBold40" "[homedir]/skins/Streamline/Inter-Bold.ttf" 32 32 bold

# data entry data
load_font "Inter-HeavyBold50" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 40

# data entry confirm and cancel
load_font "Inter-HeavyBold30" "[homedir]/skins/Streamline/Inter-SemiBold.ttf" 16

# data entry previous
load_font "Inter-HeavyBold35" "[homedir]/skins/Streamline/Inter-Regular.ttf" 16

# X and Y axis font
load_font "Inter-Regular20" "[homedir]/skins/Streamline/Inter-Regular.ttf" 16

# X and Y axis font
load_font "Inter-Regular16" "[homedir]/skins/Streamline/Inter-Regular.ttf" 16

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

load_font "mono18" "[homedir]/skins/Streamline/NotoSansMono-SemiBold.ttf" 17

# mono data card
load_font "mono10bold" "[homedir]/skins/Streamline/NotoSansMono-ExtraBold.ttf" 12

set ::pages [list off espresso water flush steam hotwaterrinse info]
set ::zoomed_pages [list off_zoomed espresso_zoomed flush_zoomed hotwaterrinse_zoomed steam_zoomed water_zoomed]
set ::all_pages [list off off_zoomed espresso_zoomed steam steam_zoomed espresso water water_zoomed flush flush_zoomed info hotwaterrinse hotwaterrinse_zoomed]
#set ::pages_not_off [list steam espresso water flush info hotwaterrinse]

set ::streamline_hotwater_btn_mode "ml"
set ::streamline_steam_btn_mode "flow"

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

proc streamline_rectangle {contexts x1 y1 x2 y2 colour disabledcolour {tags {}}} {

	if {$tags != ""} {
		dui add canvas_item rect $contexts $x1 $y1 $x2 $y2 -fill $colour -width 0 -tags $tags -disabledfill $disabledcolour
	} else {
		dui add canvas_item rect $contexts $x1 $y1 $x2 $y2 -fill $colour -width 0  -disabledfill $disabledcolour
	}
}



proc streamline_rounded_rectangle {contexts x1 y1 x2 y2 colour disabledcolour angle {tags {}}} {



	if {$tags != ""} {
		dui add shape round $contexts $x1 $y1 -bwidth [expr {$x2 - $x1}] -bheight [expr {$y2 - $y1}] -radius "$angle $angle $angle $angle" -fill $colour -tags $tags  -disabledfill $disabledcolour
	} else {
		dui add shape round $contexts $x1 $y1 -bwidth [expr {$x2 - $x1}] -bheight [expr {$y2 - $y1}] -radius "$angle $angle $angle $angle" -fill $colour  -disabledfill $disabledcolour
	}
}





############################################################################################################################################################################################################
# draw the background shapes

# white background
streamline_rectangle $::all_pages 0 0 2560 1600 $::background_color $::plus_minus_flash_off_color_disabled

# top grey box
streamline_rectangle $::all_pages 0 0 2560 220 $::box_color $::plus_minus_flash_off_color_disabled
#streamline_rectangle $::zoomed_pages 0 0 2560 220 $::box_color

# left grey box
streamline_rectangle $::pages 0 220 626 1600 $::box_color $::plus_minus_flash_off_color_disabled

#  grey line on the left
streamline_rectangle $::pages 626 220 626 1600 $::box_line_color $::plus_minus_flash_off_color_disabled

# grey lines on the left bar
streamline_rectangle $::pages 0 687 626 687 $::box_line_color $::plus_minus_flash_off_color_disabled
streamline_rectangle $::pages 0 913 626 913 $::box_line_color $::plus_minus_flash_off_color_disabled
streamline_rectangle $::pages 0 1139 626 1139 $::box_line_color $::plus_minus_flash_off_color_disabled
streamline_rectangle $::pages 0 1365 626 1365 $::box_line_color $::plus_minus_flash_off_color_disabled


# grey horizontal line 
streamline_rectangle $::pages  626 418 2560 418 $::box_line_color $::plus_minus_flash_off_color_disabled
streamline_rectangle $::zoomed_pages  0 490 2560 490 $::box_line_color $::plus_minus_flash_off_color_disabled

#  grey line on the bottom
streamline_rectangle $::pages 626 1274 2560 1274 $::box_line_color $::plus_minus_flash_off_color_disabled

#  vertical grey line in data card
streamline_rectangle $::pages 1151 1274 1151 1600 $::box_line_color $::plus_minus_flash_off_color_disabled



if {$::settings(ghc_is_installed) == 0} { 
	#
	streamline_rectangle $::pages 2319 220 2600 1274 $::box_color $::plus_minus_flash_off_color_disabled
	streamline_rectangle $::pages 2319 220 2319 1274 $::box_line_color $::plus_minus_flash_off_color_disabled
	streamline_rectangle $::zoomed_pages 2319 220 2600 1600 $::box_color $::plus_minus_flash_off_color_disabled
	streamline_rectangle $::zoomed_pages 2319 220 2319 1600 $::box_line_color $::plus_minus_flash_off_color_disabled
}


streamline_rectangle $::all_pages 0 220 2560 220 $::box_line_color $::plus_minus_flash_off_color_disabled


############################################################################################################################################################################################################


proc copy_streamline_settings_to_DYE {} {

	if { [plugins enabled DYE] } {
		set ::plugins::DYE::settings(next_drink_weight) $::settings(final_desired_shot_weight) 
		set ::plugins::DYE::settings(next_grinder_dose_weight) $::settings(grinder_dose_weight) 
		set ::plugins::DYE::settings(next_grinder_setting) $::settings(grinder_setting)
	}
}


proc streamline_adjust_grind { args } {

	if {$args == "-"} {
		set ::settings(grinder_setting) [round_to_one_digits [expr {$::settings(grinder_setting) - .1}]]
		flash_button "streamline_minus_grind_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
	} elseif {$args == "+"} {
		set ::settings(grinder_setting) [round_to_one_digits [expr {$::settings(grinder_setting) + .1}]]
		flash_button "streamline_plus_grind_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
	} elseif {$args == "--"} {
		set ::settings(grinder_setting) [round_to_one_digits [expr {$::settings(grinder_setting) - 1}]]
		flash_button "streamline_minus_grind_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
	} elseif {$args == "++"} {
		set ::settings(grinder_setting) [round_to_one_digits [expr {$::settings(grinder_setting) + 1}]]
		flash_button "streamline_plus_grind_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
	}

	if {$::settings(grinder_setting) > 1000} {
		set ::settings(grinder_setting) 1000
	} elseif {$::settings(grinder_setting) < 0} {
		set ::settings(grinder_setting) 0
	}

	#copy_settings_from_streamline_to_profile
	copy_streamline_settings_to_DYE
	save_profile_and_update_de1 0
}

############################################################################################################################################################################################################
# top right line with profile name and various text labels that are buttons


if {[ifexists ::settings(grinder_setting)] == ""} {
	set ::settings(grinder_setting) 0
}

proc streamline_init_history_files {} {
	set ::streamline_history_files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/history/" *.shot]]
	set ::streamline_history_file_selected_number [expr {[llength $::streamline_history_files] -1}]
}



proc array_incr {arrayname key {val 1}} {
    upvar $arrayname arraydata
	set x 1
	#if {[catch {set x [incr arraydata($key) $val}]} then {set arraydata($key) $val}
	if {[catch {set x [incr arraydata($key) $val]}]} then {set arraydata($key) $val}
	return $x
}

proc array_keys_sorted_by_val {arrname {sort_order -increasing}} {
	upvar $arrname arr
	foreach k [array names arr] {
		set k2 "$arr($k) $k"
		set t($k2) $k
	}
	
	set toreturn {}

	set keys [lsort $sort_order -dictionary [array names t]]
	foreach k $keys {
		set v $t($k)
		lappend toreturn $v
	}
	return $toreturn
}

proc streamline_history_most_common_profiles { {max 500} } {

	set c 0
	foreach current_shot_filename [lsort -dictionary -decreasing $::streamline_history_files] {
		if {[incr c] > $max} {
			break
		}

		unset -nocomplain past_shot_array
		catch {
			array set past_shot_array [encoding convertfrom utf-8 [read_file "[homedir]/history/$current_shot_filename"]]
		}

		if {[ifexists past_shot_array(settings)] == ""} {
			continue
		}
		array set profile_settings [ifexists past_shot_array(settings)]
		if {[ifexists profile_settings(profile_filename)] != ""} {
			# only include the most common profiles that still actually exist on disk
			if {[file exists "[homedir]/profiles/[ifexists profile_settings(profile_filename)].tcl"] == 1} {
				array_incr count [ifexists profile_settings(profile_filename)]
			}
		}
	}

	return [array_keys_sorted_by_val count]
}

streamline_init_history_files

	#puts "ERROR [streamline_history_most_common_profiles]"


proc back_from_settings {} {
	refresh_favorite_profile_button_labels
}


set ::streamline_needs_final_datacard_update 0
proc streamline_profile_title {} {

	update_streamline_status_message

	set this_state [::de1::state::current_state]
	set this_substate [::de1::state::current_substate]

	if {$this_state == "Espresso"} {
		if {$this_substate == "preinfusion" || $this_substate == "pouring"} {
			update_datacard_from_live_data
			set ::streamline_needs_final_datacard_update 1
		}

	} elseif {$this_state == "HotWaterRinse"} {
		return [translate "Flush"]
	} elseif {$this_state == "Steam"} {
		return [translate "Steam"]
	} elseif {$this_state == "HotWater"} {
		return [translate "Hot Water"]
	} elseif {$::streamline_needs_final_datacard_update == 1} {
		set ::streamline_needs_final_datacard_update 0
		 update_datacard_from_live_data				
	}

	return [translate [ifexists ::settings(profile_title)]]
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
		update_data_card past_shot_array ::settings
	}
}

add_de1_variable $::pages 690 256 -justify left -anchor "nw" -font Inter-HeavyBold24 -fill $::profile_title_color -width [rescale_x_skin 1200] -textvariable {[streamline_profile_title]} 

proc show_off_page_after_settings {} {
	set_next_page off "off_zoomed"
	page_show off
}
add_de1_variable $::zoomed_pages 52 256 -justify left -anchor "nw" -font Inter-HeavyBold24 -fill $::profile_title_color -width [rescale_x_skin 1200] -textvariable {[streamline_profile_title]} 

add_de1_variable "water_zoomed" 52 256 -justify left -anchor "nw" -font Inter-HeavyBold24 -fill $::profile_title_color -width [rescale_x_skin 1200] -textvariable {[streamline_profile_title]} 
add_de1_button $::pages { after 1000 set_next_page off "off_zoomed" ; show_settings settings_1 back_from_settings} 670 240 1300 320  "off"   
add_de1_button $::zoomed_pages { show_settings settings_1 "back_from_settings; show_off_page_after_settings" ; set_next_page off "off_zoomed" } 0 240 1300 320 ""



############################################################################################################################################################################################################
# The status message on the top right. Might be clickable.

set ::streamline_global(status_msg_text_red) ""
set ::streamline_global(status_msg_text_green) ""
set ::streamline_global(status_msg_text_clickable) ""

proc streamline_green_msg_click {} {
	#msg -ERROR "streamline_green_msg_click"
	set ::streamline_global(status_msg_text_green) ""
	::refresh_$::streamline_data_line
}


#set ::reconnect_text_string [subst {\[[translate "Reconnect"]\]}]
proc streamline_status_msg_click {} {
	#msg -ERROR "streamline_status_msg_click"
	if {[dui page current] == "espresso" || [dui page current] == "espresso_zoomed" } {
		say [translate {skip}] $::settings(sound_button_in)
		popup [translate_toast "Moved to next step"]
		start_next_step;
	}
	#puts "ERROR TAPPED $::streamline_global(status_msg_text_clickable)"	
	#if {$::streamline_global(status_msg_text_clickable) == $::reconnect_text_string} {
	#	ble_connect_to_scale
	#}
}

set ::streamline_data_line [add_de1_rich_text $::all_pages [expr {2490 - $ghc_pos_pffset}] 256 right 0 1 30 $::background_color [list \
	[list -text {$::streamline_global(status_msg_text_green)}  -font "Inter-HeavyBold24" -foreground $::progress_bar_green   -exec "streamline_green_msg_click" ] \
	[list -text {$::streamline_global(status_msg_text_red)}  -font "Inter-HeavyBold24" -foreground $::progress_bar_red  ] \
	[list -text {$::streamline_global(status_msg_text_clickable)}  -font "mono18" -foreground $::status_clickable_text -exec "streamline_status_msg_click" ] \
]]

#trace add variable ::streamline_global(status_msg_text_green) write ::refresh_$::streamline_data_line
#trace add variable ::streamline_global(status_msg_text_red) write ::refresh_$::streamline_data_line



############################################################################################################################################################################################################



############################################################################################################################################################################################################
# The Mix/Group/Steam/Tank status line

set ::streamline_dataline_weight_label_blue ""
set ::streamline_dataline_weight_label_red ""
set ::streamline_dataline_weight_value ""
set ::streamline_dataline_weight_unit ""
proc streamline_ui_weight_refresh {} {
	if {$::de1(scale_device_handle) != 0} {
		set ::streamline_dataline_weight_label_blue [translate "Weight"]
		set ::streamline_dataline_weight_label_red ""
		set ::streamline_dataline_weight_value [lindex [return_weight_measurement_grams $::de1(scale_sensor_weight) 0 1] 0]
		set ::streamline_dataline_weight_unit [lindex [return_weight_measurement_grams $::de1(scale_sensor_weight) 0 1] 1]

		if {$::de1(language_rtl) == 1} {	
			# insert a space between the mL and number, in RTL languages
			set ::streamline_dataline_weight_unit " $::streamline_dataline_weight_unit"
		}
	} else {
		#set ::streamline_dataline_weight_label_blue [translate "Weight: !!"]
		#set ::streamline_dataline_weight_label_blue [translate "Weight: ..."]
		set ::streamline_dataline_weight_label_red "[translate Weight:] !! "
		if {$::currently_connecting_scale_handle == 0} {
			set ::streamline_dataline_weight_label_blue " [translate \[Reconnect\]]"
		} else {
			set ::streamline_dataline_weight_label_blue " [translate Wait]"
		}
		set ::streamline_dataline_weight_value ""
		set ::streamline_dataline_weight_unit ""
	}
	return " "
}

proc scale_tare_or_reconnect {} {
	say [translate {Tare}] $::settings(sound_button_out); 

	if {$::de1(scale_device_handle) != 0} {
		::device::scale::tare; 
		popup [translate Tare]
	} else {
		if {$::currently_connecting_scale_handle == 0} {
			set ::de1(bluetooth_scale_connection_attempts_tried) 0
			ble_connect_to_scale
		}
	}
}
set btns ""
lappend btns \
	[list -text [translate "Mix"] -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[lindex [return_temperature_measurement_no_unit [water_mix_temperature] 1 1] 0]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text {[lindex [return_temperature_measurement_no_unit [water_mix_temperature] 1 1] 1]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-SemiBold18"] \
	[list -text [translate "Group"] -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-SemiBold18"] \
	[list -text {[lindex [return_temperature_measurement_no_unit [group_head_heater_temperature] 1 1] 0]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text {[lindex [return_temperature_measurement_no_unit [group_head_heater_temperature] 1 1] 1]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-Bold16"] \
	[list -text [translate "Steam"] -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-SemiBold18"] \
	[list -text {[lindex [return_temperature_measurement_no_unit [steam_heater_temperature] 1 1] 0]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text {[lindex [return_temperature_measurement_no_unit [steam_heater_temperature] 1 1] 1]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-Bold16"] \
	[list -text [translate "Tank"] -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold16"] \
	[list -text {[return_liquid_measurement_ml [water_tank_level_to_milliliters $::de1(water_level)]]} -font "mono12" -foreground $::dataline_data_color  ] \
	[list -text "    " -font "Inter-Bold16"] \
	[list -text [translate "Clock"] -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[time_format [clock seconds]]} -font "mono12" -foreground $::dataline_data_color   ] 

if { [plugins enabled Graphical_Flow_Calibrator] } {
	# damian's graphics flow calibrator plugin
	lappend btns [list -text "    " -font "Inter-Bold16"] 
	lappend btns [list -text [translate "Calib"] -font "Inter-Bold18" -foreground $::dataline_label_color -exec "page_show GFC"  ] 
	lappend btns [list -text " " -font "Inter-Bold18" -exec "page_show GFC"  ] 
	lappend btns [list -text {[ifexists ::settings(calibration_flow_multiplier)]} -font "mono12" -foreground $::dataline_data_color  -exec "page_show GFC"] 
}


if {$::settings(scale_bluetooth_address) != ""} {
	lappend btns [list -text "    " -font "Inter-Bold16"] 
	lappend btns [list -text {$::streamline_dataline_weight_label_red} -font "Inter-Bold18" -foreground $::progress_bar_red  -exec "scale_tare_or_reconnect" ]
	lappend btns [list -text {$::streamline_dataline_weight_label_blue} -font "Inter-Bold18" -foreground $::profile_title_color  -exec "scale_tare_or_reconnect" ]
	lappend btns [list -text {[streamline_ui_weight_refresh]} -font "Inter-Bold16"  -exec "scale_tare_or_reconnect" ]
	lappend btns [list -text {$::streamline_dataline_weight_value} -font "mono12" -foreground $::profile_title_color  -exec "scale_tare_or_reconnect" ]
	lappend btns [list -text {$::streamline_dataline_weight_unit} -font "mono8" -foreground $::profile_title_color  -exec "scale_tare_or_reconnect" ]
}


add_de1_rich_text "off espresso" 690 330 [list left none] 1 2 74 $::background_color $btns


set flush_btns ""
lappend flush_btns \
	[list -text "Temp" -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[lindex [return_temperature_measurement_no_unit [watertemp] 1 1] 0]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text {[lindex [return_temperature_measurement_no_unit [watertemp] 1 1] 1]} -font "mono8" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-SemiBold18"] \
	[list -text "Flow" -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[round_to_integer $::settings(flush_flow)]} -font "mono12" -foreground $::dataline_data_color  ] \
	[list -text {[translate ml/s]} -font "mono8" -foreground $::dataline_data_color  ] 

add_de1_rich_text "hotwaterrinse" 690 330 left 1 2 65 $::background_color $flush_btns
add_de1_rich_text "hotwaterrinse_zoomed" 50 330 left 1 2 65 $::background_color $flush_btns

set water_btns ""
lappend water_btns \
	[list -text "Temp" -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[lindex [return_temperature_measurement_no_unit [setting_water_temperature] 1 1] 0]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text {[lindex [return_temperature_measurement_no_unit [setting_water_temperature] 1 1] 1]} -font "mono8" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-SemiBold18"] \
	[list -text "Flow" -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[round_to_integer $::settings(hotwater_flow)]} -font "mono12" -foreground $::dataline_data_color  ] \
	[list -text {[translate ml/s]} -font "mono8" -foreground $::dataline_data_color  ] \
	[list -text "    " -font "Inter-SemiBold18"] \
	[list -text "Volume" -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[round_to_integer $::settings(water_volume)]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text [translate "ml"] -font "mono8"  -foreground $::dataline_data_color ] 

if {$::settings(scale_bluetooth_address) != ""} {
	lappend water_btns [list -text "    " -font "Inter-Bold16"] 
	lappend water_btns [list -text {$::streamline_dataline_weight_label_red} -font "Inter-Bold18" -foreground $::progress_bar_red  -exec "scale_tare_or_reconnect" ]
	lappend water_btns [list -text {$::streamline_dataline_weight_label_blue} -font "Inter-Bold18" -foreground $::profile_title_color  -exec "scale_tare_or_reconnect" ]
	lappend water_btns [list -text {[streamline_ui_weight_refresh]} -font "Inter-Bold16"  -exec "scale_tare_or_reconnect" ]
	lappend water_btns [list -text {$::streamline_dataline_weight_value} -font "mono12" -foreground $::profile_title_color  -exec "scale_tare_or_reconnect" ]
	lappend water_btns [list -text {$::streamline_dataline_weight_unit} -font "mono8" -foreground $::profile_title_color  -exec "scale_tare_or_reconnect" ]
}
	

add_de1_rich_text "water" 690 330 left 1 2 65 $::background_color $water_btns
add_de1_rich_text "water_zoomed" 50 330 left 1 2 65 $::background_color $water_btns


set steam_btns ""
lappend steam_btns \
	[list -text "Temp" -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[lindex [return_temperature_measurement_no_unit [steamtemp] 1 1] 0]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text {[lindex [return_temperature_measurement_no_unit [steamtemp] 1 1] 1]} -font "mono8" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-SemiBold18"] \
	[list -text "Pressure" -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[round_one_digits [pressure]]} -font "mono12" -foreground $::dataline_data_color  ] \
	[list -text {[translate bar]} -font "mono8" -foreground $::dataline_data_color  ] \
	[list -text "    " -font "Inter-SemiBold18"] \
	[list -text "Flow" -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[round_to_one_digits $::de1(flow)]} -font "mono12" -foreground $::dataline_data_color  ] \
	[list -text {[translate ml/s]} -font "mono8" -foreground $::dataline_data_color  ] 

#set ::streamline_status_msg [add_de1_rich_text "steam" 690 330 left 1 2 65 $::background_color $steam_btns ]
add_de1_rich_text "steam" 690 330 left 1 2 65 $::background_color $steam_btns 
add_de1_rich_text "steam_zoomed" 50 330 left 1 2 65 $::background_color $steam_btns 


proc steam_timeout_seconds {} {

	set ::settings(steam_timeout) [round_to_integer $::settings(steam_timeout)]
	if {$::settings(steam_timeout) == 0} {
		return [translate "off"]
	}

	if {$::settings(steam_timeout) > 255} {
		set ::settings(steam_timeout) 255
	}

	return $::settings(steam_timeout)
}


set ::streamline_hotwater_label_1st ""
set ::streamline_hotwater_label_2nd ""

set ::streamline_steam_label_1st ""
set ::streamline_steam_label_2nd ""

set zoomed_btns ""
lappend zoomed_btns \
	[list -text [translate "Grind"] -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {$::settings(grinder_setting)} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-SemiBold18"] \
	[list -text [translate "Dose"] -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-SemiBold18"] \
	[list -text {[return_weight_measurement_grams $::settings(grinder_dose_weight)]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-Bold16"] \
	[list -text [translate "Drink"] -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-SemiBold18"] \
	[list -text {[return_weight_measurement_grams [determine_final_weight]]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-Bold16"] \
	[list -text [translate "Brew"] -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold16"] \
	[list -text {[lindex [return_temperature_measurement_no_unit [setting_espresso_temperature] 1 1] 0]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text {[lindex [return_temperature_measurement_no_unit [setting_espresso_temperature] 1 1] 1]} -font "mono8" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-Bold16"] \
	[list -text [translate "Steam"] -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[seconds_text_very_abbreviated [steam_timeout_seconds]]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-Bold16"] \
	[list -text [translate "Flush"] -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[seconds_text_very_abbreviated [round_to_integer $::settings(flush_seconds)]]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text "    " -font "Inter-Bold16"] \
	[list -text [translate "Hot Water"] -font "Inter-Bold18" -foreground $::dataline_label_color  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[return_liquid_measurement_ml $::settings(water_volume)]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text " (" -font "mono12"  -foreground $::dataline_data_color ] \
	[list -text {[lindex [return_temperature_measurement_no_unit $::settings(water_temperature) 1 1] 0]} -font "mono12" -foreground $::dataline_data_color   ] \
	[list -text {[lindex [return_temperature_measurement_no_unit $::settings(water_temperature) 1 1] 1]} -font "mono8" -foreground $::dataline_data_color   ] \
	[list -text ")" -font "mono12"  -foreground $::dataline_data_color ] 
	

add_de1_rich_text "off_zoomed espresso_zoomed" 50 330 left 1 2 85 $::background_color $zoomed_btns 
add_de1_rich_text "off_zoomed espresso_zoomed" 50 400 left 1 2 65 $::background_color $btns 

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


set ::streamline_start_heating_time [clock seconds]
set ::streamline_start_heating_temp [group_head_heater_temperature]
set ::streamline_start_heating_eta_previous 999
proc update_streamline_status_message {} {
	#msg -ERROR "update_streamline_status_message [dui page current]"
	set red_progress ""
	set red_msg ""
	set clickable_msg ""
	set green_msg ""
	set delta_percent 0

	if {[dui page current] == "off" || [dui page current] == "off_zoomed"} {

	}


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
			set ::streamline_start_heating_time [clock seconds]
			set ::streamline_start_heating_temp [group_head_heater_temperature]
		} else {
			set red_msg [translate "Heating"]
			set red_progress [string repeat █ $bars]

			set elapsed [expr {[clock seconds] - $::streamline_start_heating_time}]

			if {$elapsed == 0} {
				set elapsed 1
			}

			if {[catch {
				set warmed [expr {[group_head_heater_temperature] - $::streamline_start_heating_temp}]
				if {$warmed < 1} {
					set warmed 1
				}
				set togo [expr {([setting_espresso_temperature]-10) - [group_head_heater_temperature]}]
				if {$togo > 100} {
					set togo 100
				}
				if {$togo < 1} {
					set togo 1
				}
				set progress [expr {1.0*$warmed/$togo}]
				
				set ETA 0
				catch {
					set ETA [round_to_tens [expr {int(1.0*$elapsed/$progress)}]]
				}

				if {$ETA < 5} {
					set ETA 5
				}
				if {$ETA > 300} {
					set ETA 300
				}

				set force_update 1				
				if {$ETA < $::streamline_start_heating_eta_previous || $force_update == 1} {
					set msg [subst { [seconds_text_very_abbreviated $ETA][translate remaining]}]
					set ::streamline_start_heating_eta_previous $ETA
				} else {
					set msg [subst { [seconds_text_very_abbreviated $::streamline_start_heating_eta_previous][translate remaining]}]
				}
				if {$warmed > 2 } {
					set red_msg [translate "Heating:"]
					set clickable_msg $msg
				}
				#msg -ERROR $msg

			} err] != 0} {
				msg -ERROR "heating eta failed because: '$err' [group_head_heater_temperature] - $::streamline_start_heating_temp - ([setting_espresso_temperature]-10) - [group_head_heater_temperature])"
			}


		}

		set bars_grey [expr {20 - $bars}]
		set grey_progress [string repeat █ $bars_grey]


		#msg -ERROR "current: [group_head_heater_temperature] / [setting_espresso_temperature]=delta_percent:$delta_percent"

	} else {

		if {[dui page current] == "espresso" || [dui page current] == "espresso_zoomed" } {

			#set green_msg [subst {[translate [string totitle [::de1::state::current_substate]]] ($::settings(current_frame_description))}]
			set red_msg ""

			set clickable_msg ""
			set green_msg "[translate [string totitle $::settings(current_frame_description)]]"
			if {$::de1(substate) == $::de1_substate_types_reversed(pouring) || $::de1(substate) == $::de1_substate_types_reversed(preinfusion)} {	
				set clickable_msg "[seconds_text_very_abbreviated [espresso_timer]] ⏩ " 
				set green_msg "[translate [string totitle $::settings(current_frame_description)]] | "
			} 

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
		} elseif {[dui page current] == "hotwaterrinse" || [dui page current] == "hotwaterrinse_zoomed" } {

			set green_msg [subst {[translate "Flushing:"] }]
			set clickable_msg [subst {[seconds_text_very_abbreviated [flush_pour_timer]]}]
			set final_target $::settings(flush_seconds)
			
			set current [flush_pour_timer]		

			if {$current == ""} {
				set current 0
			}

			set delta_percent 0
			catch {
				set delta_percent [expr {int(100 * ((1.0*$current) / $final_target))}]
			}
			#puts "current: $current final_target:$final_target delta_percent:$delta_percent"
			
		} elseif {[dui page current] == "steam" || [dui page current] == "steam_zoomed" } {
			

			set current [steam_pour_timer]		
			
			set green_msg [subst {[translate "Steaming:"] }]
			set clickable_msg [subst {[seconds_text_very_abbreviated [steam_pour_timer]]}]
		
			set final_target $::settings(steam_timeout)
			
			if {$current == ""} {
				set current 0
			}

			set delta_percent 0
			catch {
				set delta_percent [expr {int(100 * ((1.0*$current) / $final_target))}]
			}
			#puts "current: $current final_target:$final_target delta_percent:$delta_percent"
			
		} elseif {[dui page current] == "water" || [dui page current] == "water_zoomed" } {

			set green_msg [subst {[translate "Pouring:"] }]
			if {$::de1(scale_device_handle) != 0} {
				set current $::de1(scale_sensor_weight)
				set clickable_msg [subst {[streamline_zero_pad [round_to_integer $::de1(scale_sensor_weight)] 2 0][translate "ml"]}]
			} else {
				set current [watervolume]
				set clickable_msg [subst {[streamline_zero_pad [round_to_integer [watervolume]] 2 0][translate "ml"]}]
			}

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


		set width 20
		set bars [round_to_integer [expr {$delta_percent / $width}]]
		if {$bars > $width} {
			set bars $width
		}
		set bars_grey [expr {$width - $bars}]

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

	if {$::streamline_global(status_msg_text_clickable) != $clickable_msg} {
		set ::streamline_global(status_msg_text_clickable) $clickable_msg
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
		#::refresh_$::streamline_progress_line
	}




}
############################################################################################################################################################################################################



############################################################################################################################################################################################################
# draw text labels for the buttons on the left margin


# blink the hot water presets 
streamline_rectangle $::pages 0 1521 626 1555  $::box_color $::plus_minus_flash_off_color_disabled hotwater_presets_rectangle

# hot water
streamline_rounded_rectangle $::pages 360 1396 478 1439  $::box_color $::plus_minus_flash_off_color_disabled 20 hotwater_setting_rectangle

# flush 
streamline_rounded_rectangle $::pages 360 1192 478 1235  $::box_color $::plus_minus_flash_off_color_disabled 20 flush_setting_rectangle

# stream 
streamline_rounded_rectangle $::pages 360 946 478 988  $::box_color $::plus_minus_flash_off_color_disabled 20 steam_setting_rectangle

# temp 
streamline_rounded_rectangle $::pages 360 738 478 781  $::box_color $::plus_minus_flash_off_color_disabled 20 temp_setting_rectangle

# drink out
streamline_rounded_rectangle $::pages 360 492 478 535  $::box_color $::plus_minus_flash_off_color_disabled 20 weight_setting_rectangle

# dose in
streamline_rounded_rectangle $::pages 360 398 478 442  $::box_color $::plus_minus_flash_off_color_disabled 20 dose_setting_rectangle

# grind
streamline_rounded_rectangle $::pages 360 282 478 325  $::box_color $::plus_minus_flash_off_color_disabled 20 grind_setting_rectangle



# labels
add_de1_text "off" 50 282 -justify left -anchor "nw" -text [translate "Grind"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200] 
add_de1_text "off" 50 398 -justify left -anchor "nw" -text [translate "Dose"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200]
add_de1_text "off" 50 516 -justify left -anchor "nw" -text [translate "Drink"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200]
add_de1_text "off" 50 741 -justify left -anchor "nw" -text [translate "Brew"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200]
add_de1_text "off steam" 50 947 -justify left -anchor "nw" -text [translate "Steam"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200]
add_de1_text "off flush hotwaterrinse" 50 1194 -justify left -anchor "nw" -text [translate "Flush"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200]
add_de1_text "off water" 50 1397 -justify left -anchor "nw" -text [translate "Hot Water"] -font Inter-Bold16 -fill $::left_label_color2 -width [rescale_x_skin 200]

add_de1_text "espresso steam water flush hotwaterrinse" 50 282 -justify left -anchor "nw" -text [translate "Grind"] -font Inter-Bold16 -fill $::left_label_color2_disabled -width [rescale_x_skin 200] 
add_de1_text "espresso steam water flush hotwaterrinse" 50 398 -justify left -anchor "nw" -text [translate "Dose"] -font Inter-Bold16 -fill $::left_label_color2_disabled -width [rescale_x_skin 200]
add_de1_text "espresso steam water flush hotwaterrinse" 50 516 -justify left -anchor "nw" -text [translate "Drink"] -font Inter-Bold16 -fill $::left_label_color2_disabled -width [rescale_x_skin 200]
add_de1_text "espresso steam water flush hotwaterrinse" 50 741 -justify left -anchor "nw" -text [translate "Brew"] -font Inter-Bold16 -fill $::left_label_color2_disabled -width [rescale_x_skin 200]
add_de1_text "espresso water flush hotwaterrinse" 50 967 -justify left -anchor "nw" -text [translate "Steam"] -font Inter-Bold16 -fill $::left_label_color2_disabled -width [rescale_x_skin 200]
add_de1_text "espresso steam water" 50 1194 -justify left -anchor "nw" -text [translate "Flush"] -font Inter-Bold16 -fill $::left_label_color2_disabled -width [rescale_x_skin 200]
add_de1_text "espresso steam flush hotwaterrinse" 50 1397 -justify left -anchor "nw" -text [translate "Hot Water"] -font Inter-Bold16 -fill $::left_label_color2_disabled -width [rescale_x_skin 200]

################################################################################################
# two line hot water control over temp and vold
set ::hw_temp_vol_part1 ""
set ::hw_temp_vol_part2 ""
set ::hw_temp_vol_part3 ""
set ::hw_temp_vol_part4 ""
set ::hw_temp_vol_part5 ""
set ::hw_temp_vol_part6 ""

set ::hw_temp_vol [add_de1_rich_text "off water" 50 1444 left 0 1 8 $::box_color [list \
	[list -text {$::hw_temp_vol_part1} -font Inter-Bold11 -foreground $::left_label_color2 -exec hw_temp_vol_flip] \
	[list -text {$::hw_temp_vol_part2} -font Inter-Regular10 -foreground $::preset_value_color -exec hw_temp_vol_flip] \
	[list -text {$::hw_temp_vol_part3} -font Inter-Bold11 -foreground $::preset_value_color -exec hw_temp_vol_flip] \
	[list -text {$::hw_temp_vol_part4} -font Inter-Bold11 -foreground $::preset_value_color -exec hw_temp_vol_flip ] \
	[list -text {$::hw_temp_vol_part5} -font Inter-Regular10 -foreground $::preset_value_color -exec hw_temp_vol_flip ] \
	[list -text {$::hw_temp_vol_part6} -font Inter-Bold11 -foreground $::left_label_color2 -exec hw_temp_vol_flip ] \
]]

proc refresh_hw_temp_labels {} {

	if {$::streamline_hotwater_btn_mode == "temp"} {

		set ::hw_temp_vol_part1 [translate "Temp"]
		set ::hw_temp_vol_part2 " | "
		set ::hw_temp_vol_part3 [translate "Vol"]
		set ::hw_temp_vol_part4 ""
		set ::hw_temp_vol_part5 ""
		set ::hw_temp_vol_part6 ""
	} else {

		set ::hw_temp_vol_part1 ""
		set ::hw_temp_vol_part2 ""
		set ::hw_temp_vol_part3 ""
		set ::hw_temp_vol_part4 [translate "Temp"]
		set ::hw_temp_vol_part5 " | "
		set ::hw_temp_vol_part6 [translate "Vol"]
	}

	catch {
		::refresh_$::hw_temp_vol
	}

}

proc hw_temp_vol_flip {} {
	if {$::streamline_hotwater_btn_mode == "ml"} {
		set ::streamline_hotwater_btn_mode "temp"

	} else {
		set ::streamline_hotwater_btn_mode "ml"
	}

	refresh_hw_temp_labels

	catch {
		::refresh_$::hw_temp_vol
	}

	catch {
		refresh_favorite_hw_button_labels
		streamline_hot_water_setting_change

	}
}
hw_temp_vol_flip

# tap area around hot water label to flip the setting between temp/vol
add_de1_button "off water" {hw_temp_vol_flip} 0 1376 222 1498 ""

############################################################################################################################################################################################################


################################################################################################
# two line steam control over time and flow
set ::steam_time_flow_part1 ""
set ::steam_time_flow_part2 ""
set ::steam_time_flow_part3 ""
set ::steam_time_flow_part4 ""
set ::steam_time_flow_part5 ""
set ::steam_time_flow_part6 ""

set ::steam_time_flow [add_de1_rich_text "off steam" 50 994 [list left none] 0 1 9 $::box_color [list \
	[list -text {$::steam_time_flow_part1} -font Inter-Bold11 -foreground $::left_label_color2 -exec steam_time_flow_flip] \
	[list -text {$::steam_time_flow_part2} -font Inter-Regular10 -foreground $::preset_value_color -exec steam_time_flow_flip] \
	[list -text {$::steam_time_flow_part3} -font Inter-Bold11 -foreground $::preset_value_color -exec steam_time_flow_flip] \
	[list -text {$::steam_time_flow_part4} -font Inter-Bold11 -foreground $::preset_value_color -exec steam_time_flow_flip ] \
	[list -text {$::steam_time_flow_part5} -font Inter-Regular10 -foreground $::preset_value_color -exec steam_time_flow_flip ] \
	[list -text {$::steam_time_flow_part6} -font Inter-Bold11 -foreground $::left_label_color2 -exec steam_time_flow_flip ] \
]]

proc refresh_steam_time_flow_labels {} {
	
	if {$::streamline_steam_btn_mode == "time"} {

		set ::steam_time_flow_part1 [translate "Time"]
		set ::steam_time_flow_part2 " | "
		set ::steam_time_flow_part3 [translate "Flow"]
		set ::steam_time_flow_part4 ""
		set ::steam_time_flow_part5 ""
		set ::steam_time_flow_part6 ""
	} else {

		set ::steam_time_flow_part1 ""
		set ::steam_time_flow_part2 ""
		set ::steam_time_flow_part3 ""
		set ::steam_time_flow_part4 [translate "Time"]
		set ::steam_time_flow_part5 " | "
		set ::steam_time_flow_part6 [translate "Flow"]
	}

	catch {
		::refresh_$::steam_time_flow
	}


	#puts "ERROR refresh_steam_time_flow_labelsrefresh_steam_time_flow_labelsrefresh_steam_time_flow_labelsrefresh_steam_time_flow_labels"

}



proc refresh_favorite_steam_button_labels {} {

	puts "refresh_favorite_steam_button_labels"

	########## STEAM TIMEOUT
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
		set t1 "0"
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
	##########


	########## STEAM FLOW RATE
	set steamflow [ifexists ::settings(favorite_steamflow)]
	set streamline_selected_favorite_steamflow ""
	catch {
		set streamline_selected_favorite_steamflow [dict get $steamflow selected number]
	}

	set steamflow [ifexists ::settings(favorite_steamflow)]

	set ft1 ""
	set ft2 ""
	set ft3 ""
	set ft4 ""

	catch {
		set ft1 [dict get $steamflow 1 value]
	}
	catch {
		set ft2 [dict get $steamflow 2 value]
	}
	catch {
		set ft3 [dict get $steamflow 3 value]
	}
	catch {
		set ft4 [dict get $steamflow 4 value]
	}

	
	if {$ft1 == ""} {
		set ft1 "40"
		dict set steamflow 1 value $ft1
		set changed 1
	}

	if {$ft2 == ""} {
		set ft2 "50"		
		dict set steamflow 2 value $ft2
		set changed 1
	}

	if {$ft3 == ""} {
		set ft3 "60"		
		dict set steamflow 3 value $ft3
		set changed 1
	}

	if {$ft4 == ""} {
		set ft4 "80"		
		dict set steamflow 4 value $ft4
		set changed 1
	}
	##########


	if {$changed == 1} {
		set ::settings(favorite_steams) $steams	
		set ::settings(favorite_steamflow) $steamflow
		save_settings	
		
	}

	if {$::streamline_steam_btn_mode == "time"} {
		set ::streamline_favorite_steam_buttons(label_1) [seconds_text_very_abbreviated $t1]
		set ::streamline_favorite_steam_buttons(label_2) [seconds_text_very_abbreviated $t2]
		set ::streamline_favorite_steam_buttons(label_3) [seconds_text_very_abbreviated $t3]
		set ::streamline_favorite_steam_buttons(label_4) [seconds_text_very_abbreviated $t4]

		if {$t1 == "0"} {
			set ::streamline_favorite_steam_buttons(label_1) [translate "off"]
		}
		if {$t2 == "0"} {
			set ::streamline_favorite_steam_buttons(label_2) [translate "off"]
		}
		if {$t3 == "0"} {
			set ::streamline_favorite_steam_buttons(label_3) [translate "off"]
		}
		if {$t4 == "0"} {
			set ::streamline_favorite_steam_buttons(label_4) [translate "off"]
		}


	} else {
		set ::streamline_favorite_steam_buttons(label_1) "[round_to_one_digits [expr {$ft1 / 100.0}]]"
		set ::streamline_favorite_steam_buttons(label_2) "[round_to_one_digits [expr {$ft2 / 100.0}]]"
		set ::streamline_favorite_steam_buttons(label_3) "[round_to_one_digits [expr {$ft3 / 100.0}]]"
		set ::streamline_favorite_steam_buttons(label_4) "[round_to_one_digits [expr {$ft4 / 100.0}]]"
		#set ::streamline_favorite_steam_buttons(label_1) "[round_to_one_digits [expr {$ft1 / 100.0}]][translate mL/s]"
		#set ::streamline_favorite_steam_buttons(label_2) "[round_to_one_digits [expr {$ft2 / 100.0}]][translate mL/s]"
		#set ::streamline_favorite_steam_buttons(label_3) "[round_to_one_digits [expr {$ft3 / 100.0}]][translate mL/s]"
		#set ::streamline_favorite_steam_buttons(label_4) "[round_to_one_digits [expr {$ft4 / 100.0}]][translate mL/s]"
	}


	set lb1c $::preset_value_color
	set lb2c $::preset_value_color
	set lb3c $::preset_value_color
	set lb4c $::preset_value_color

	if {$::streamline_steam_btn_mode == "time"} {
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
	} else {
		if {$::settings(steam_flow) == [dict get $steamflow 1 value]} {
			set lb1c $::preset_label_selected_color
		} 
		if {$::settings(steam_flow) == [dict get $steamflow 2 value]} {
			set lb2c $::preset_label_selected_color
		} 
		if {$::settings(steam_flow) == [dict get $steamflow 3 value]} {
			set lb3c $::preset_label_selected_color
		} 
		if {$::settings(steam_flow) == [dict get $steamflow 4 value]} {
			set lb4c $::preset_label_selected_color
		}
	}

	.can itemconfigure steam_btn_1 -fill $lb1c
	.can itemconfigure steam_btn_2 -fill $lb2c
	.can itemconfigure steam_btn_3 -fill $lb3c
	.can itemconfigure steam_btn_4 -fill $lb4c
}
#refresh_favorite_steam_button_labels


proc streamline_steam_setting_change { } {

	if {$::settings(steam_timeout) == 0} {
		set stimeout [translate off]
	} else {
		set stimeout [seconds_text_very_abbreviated $::settings(steam_timeout)]
	}

	#[translate mL/s]
	puts "streamline_steam_setting : $::streamline_steam_btn_mode"
	if {$::streamline_steam_btn_mode == "time"} {
		set ::streamline_steam_label_1st $stimeout
		set ::streamline_steam_label_2nd "([round_to_one_digits [expr {$::settings(steam_flow) / 100.0}]])"
	} else {
		set ::streamline_steam_label_1st "[round_to_one_digits [expr {$::settings(steam_flow) / 100.0}]]"
		set ::streamline_steam_label_2nd "($stimeout)"
	}
}
streamline_steam_setting_change

proc steam_time_flow_flip {} {

	if {$::streamline_steam_btn_mode == "time"} {
		set ::streamline_steam_btn_mode "flow"

	} else {
		set ::streamline_steam_btn_mode "time"
	}

	#puts "ERROR steam_time_flow_flip $::streamline_steam_btn_mode "
	refresh_steam_time_flow_labels

	#catch {
	#	::refresh_$::steam_time_flow
	#}

	#catch {
		refresh_favorite_steam_button_labels
		streamline_steam_setting_change

	#}
}
steam_time_flow_flip

# tap areas
add_de1_button "off steam" {steam_time_flow_flip} 0 947 222 1056 ""


############################################################################################################################################################################################################

############################################################################################################################################################################################################
# data card on the bottom center

# labels
set ::streamline_current_history_profile_name ""
set ::streamline_current_history_profile_clock ""


proc start_streamline_espresso {} {

	set ::de1(streamline_shot_in_progress) 1

	set ::streamline_history_text_label [translate "CURRENT"] 
	set ::streamline_current_history_profile_clock [clock seconds]
	set ::streamline_current_history_profile_name [translate $::settings(profile_title)]


	if {$::off_page == "off"} {
		set ::espresso_page "espresso"
	} else {
		set ::espresso_page "espresso_zoomed"
	}
	set_next_page espresso $::espresso_page
	#page_show espresso;

	unset -nocomplain ::de1(espresso_elapsed)
	update_data_card ::de1 ::settings
}

set ::streamline_history_text_label [translate "HISTORY"] 
set ::streamline_current_history_third_line ""
add_de1_variable $::pages 890 1348 -justify center -anchor "center" -text "" -font Inter-Bold18 -fill $::data_card_title_text_color -width [rescale_x_skin 400] -textvariable {$::streamline_history_text_label}

add_de1_variable $::pages 890 1410 -justify center -anchor "center" -font Inter-Bold18 -fill $::data_card_text_color  -width [rescale_x_skin 500] -textvariable {[streamline_history_date_format $::streamline_current_history_profile_clock]}
add_de1_variable $::pages 890 1474 -justify center -anchor "center" -font Inter-SemiBold18 -fill $::data_card_text_color -width [rescale_x_skin 1000] -textvariable {[translate $::streamline_current_history_profile_name]} 
add_de1_variable $::pages 890 1536 -justify center -anchor "center" -font Inter-SemiBold18 -fill $::data_card_text_color -width [rescale_x_skin 1000] -textvariable {$::streamline_current_history_third_line} 

#add_de1_text $::pages 1364 1328 -justify right -anchor "ne" -text [translate "SHOT DATA"] -font Inter-Bold18 -fill $::data_card_title_text_color -width [rescale_x_skin 400]
add_de1_text $::pages 1364 1390 -justify right -anchor "ne" -text [translate "Preinfusion"] -font Inter-Bold17 -fill $::data_card_title_text_color -width [rescale_x_skin 200]
add_de1_text $::pages 1364 1454 -justify right -anchor "ne" -text [translate "Extraction"] -font Inter-Bold17 -fill $::data_card_title_text_color -width [rescale_x_skin 200]
add_de1_text $::pages 1364 1516 -justify right -anchor "ne" -text [translate "Total"] -font Inter-Bold17 -fill $::data_card_title_text_color -width [rescale_x_skin 200]


proc streamline_history_date_format {shot_time} {

	if {$shot_time == ""} {
		return ""
	}

	if {$::settings(enable_ampm) == 1} {
		return [clock format $shot_time -format "%Y/%m/%d %l:%M %p"]
	}

	return [clock format $shot_time -format "%Y/%m/%d %H:%M"]

	# all below is obsolete, the previous implementation , which suffered from many bugs due to overcomplexity

	set seconds [expr {([clock seconds] - $shot_time)}]
	set minutes [expr {([clock seconds] - $shot_time)/60}]
	set hours [expr {([clock seconds] - $shot_time)/3600}]
	set days [expr {([clock seconds] - $shot_time)/86400}]
	set months [expr {([clock seconds] - $shot_time)/(30*86400)}]
	set years [expr {([clock seconds] - $shot_time)/(365*86400)}]

	set yesterday 0
	set now_number [clock format [clock seconds] -format %w]
	set then_number [clock format $shot_time -format %w]

	if {($now_number == 0 && $then_number == 6) || ([expr {$now_number - $then_number}] == 1)} {
		# sunday = 0, saturday is 6, so this is an exception case, 
		# otherwise simply test for 1 day of difference
		set yesterday 1
	} 

	if {$::de1(state) == 4} {
		set t "now"
	} elseif {$seconds < 120} {
		set t "$seconds [translate {seconds ago}]"
	} elseif {$minutes < 60} {
		set t "${minutes} [translate {minutes ago}]"
	} elseif {$hours < 2} {
		set t [translate "1 hour ago @ [time_format $shot_time]"]
	} elseif {$yesterday == 1} {
		set t "[translate {yesterday}] @ [time_format $shot_time]"
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

dui aspect set -theme streamline -type dbutton fill $::profile_button_background_color
dui aspect set -theme streamline -type dbutton disabledfill $::plus_minus_flash_off_color_disabled
dui aspect set -theme streamline -type dbutton outline $::profile_button_background_color
dui aspect set -theme streamline -type dbutton disabledoutline $::profile_button_background_color

dui aspect set -theme streamline -type dbutton_symbol fill $::data_card_text_color
dui aspect set -theme streamline -type dbutton label_fill $::data_card_text_color
dui aspect set -theme streamline -type dbutton_symbol font_size 18
dui aspect set -theme streamline -type dbutton_symbol pos ".50 .5"


if {$::android == 1 || $::undroid == 1} {
	set ::streamline_history_cmd -label
	set ::streamline_history_left "🡐"
	set ::streamline_history_right "🡒"
} else {
	set ::streamline_history_cmd -label
	set ::streamline_history_left "<"
	set ::streamline_history_right ">"
}

dui add dbutton "off" 628 1280 728 1600 -tags profile_back $::streamline_history_cmd $::streamline_history_left  -command { say [translate {Previous}] $::settings(sound_button_out); streamline_history_profile_back } -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd { say [translate {First}] $::settings(sound_button_out); streamline_history_profile_fwd 0 } 
dui add dbutton "off" 1050 1280 1150 1600 -tags profile_fwd $::streamline_history_cmd " "  -command { say [translate {Next}] $::settings(sound_button_out); streamline_history_profile_fwd } -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Newest}] $::settings(sound_button_out); streamline_history_profile_fwd 1 } 

proc streamline_zero_pad {num dig prec {optional_label {}}} {
	if {$num == ""} {
		return ""
	}
 	return [format "%00${dig}.${prec}f" $num]$optional_label
}


set ::streamline_shot_volume 0
set ::streamline_final_extraction_volume 0
set ::streamline_preinfusion_volume 0


set ::streamline_datacard_col1 1416
set ::streamline_datacard_col2 1532
set ::streamline_datacard_col3 1680
set ::streamline_datacard_col4 1800
set ::streamline_datacard_col5 1970
set ::streamline_datacard_col6 2230


add_de1_text $::pages $::streamline_datacard_col1 1328 -justify right -anchor "nw" -text [translate "Time"] -font Inter-Bold17 -fill $::data_card_title_text_color -width [rescale_x_skin 300]
add_de1_variable $::pages $::streamline_datacard_col1 1388 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad [ifexists ::streamline_preinfusion_time] 2 0]} 
add_de1_variable $::pages $::streamline_datacard_col1 1452 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad [ifexists ::streamline_final_extraction_time] 2 0]}
add_de1_variable $::pages $::streamline_datacard_col1 1514 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad [ifexists ::streamline_shot_time] 2 0]}
#add_de1_variable $::pages $::streamline_datacard_col1 1388 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad $::streamline_preinfusion_time 2 0]} 
#add_de1_variable $::pages $::streamline_datacard_col1 1452 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad $::streamline_final_extraction_time 2 0]}
#add_de1_variable $::pages $::streamline_datacard_col1 1514 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad $::streamline_shot_time 2 0]}

add_de1_text $::pages $::streamline_datacard_col2 1328 -justify right -anchor "nw" -text [translate "Grams"] -font Inter-Bold17 -fill $::data_card_title_text_color -width [rescale_x_skin 300]
add_de1_variable $::pages $::streamline_datacard_col2 1388 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad [ifexists ::streamline_preinfusion_weight] 4 1]} 
add_de1_variable $::pages $::streamline_datacard_col2 1452 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad [ifexists ::streamline_final_extraction_weight] 4 1]} 
add_de1_variable $::pages $::streamline_datacard_col2 1514 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[streamline_zero_pad [ifexists ::streamline_shot_weight] 4 1]} 


add_de1_text $::pages $::streamline_datacard_col3 1328 -justify right -anchor "nw" -text [translate "mL"] -font Inter-Bold17 -fill $::data_card_title_text_color -width [rescale_x_skin 150]
add_de1_variable $::pages $::streamline_datacard_col3 1388 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 150] -textvariable {[streamline_zero_pad [ifexists ::streamline_preinfusion_volume] 2 0]} 
add_de1_variable $::pages $::streamline_datacard_col3 1452 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 150] -textvariable {[streamline_zero_pad [ifexists ::streamline_final_extraction_volume] 2 0]} 
add_de1_variable $::pages $::streamline_datacard_col3 1514 -justify right -anchor "nw" -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 150] -textvariable {[streamline_zero_pad [ifexists ::streamline_shot_volume] 2 0]} 

set ::streamline_preinfusion_temp " "
set ::streamline_extraction_temp " "
add_de1_text $::pages $::streamline_datacard_col4 1328 -justify right -anchor "nw" -text [translate [return_html_temperature_units]] -font Inter-Bold17 -fill $::data_card_title_text_color -width [rescale_x_skin 300]
add_de1_variable $::pages $::streamline_datacard_col4 1388 -justify right -anchor "nw"  -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {$::streamline_preinfusion_temp}
add_de1_variable $::pages $::streamline_datacard_col4 1452 -justify right -anchor "nw"  -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {$::streamline_extraction_temp}

set ::streamline_extraction_low_peak_flow_label "-"
set ::streamline_extraction_low_peak_flow_label "-"

add_de1_text $::pages $::streamline_datacard_col5 1328 -justify right -anchor "nw" -text [translate "mL/s"] -font Inter-Bold17 -fill $::data_card_title_text_color -width [rescale_x_skin 300]
add_de1_variable $::pages $::streamline_datacard_col5 1388 -justify right -anchor "nw"  -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 260] -textvariable {[ifexists ::streamline_preinfusion_low_peak_flow_label]} 
add_de1_variable $::pages $::streamline_datacard_col5 1452 -justify right -anchor "nw"  -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 260] -textvariable {[ifexists ::streamline_extraction_low_peak_flow_label]} 

set ::streamline_preinfusion_low_peak_pressure_label "-"
set ::streamline_extraction_low_peak_pressure_label "-"
add_de1_text $::pages $::streamline_datacard_col6 1328 -justify right -anchor "nw" -text [translate "Pressure"] -font Inter-Bold17 -fill $::data_card_title_text_color -width [rescale_x_skin 230]
add_de1_variable $::pages $::streamline_datacard_col6 1388 -justify right -anchor "nw"  -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[ifexists ::streamline_preinfusion_low_peak_pressure_label]}
add_de1_variable $::pages $::streamline_datacard_col6 1452 -justify right -anchor "nw"  -font mono10 -fill $::data_card_text_color -width [rescale_x_skin 300] -textvariable {[ifexists ::streamline_extraction_low_peak_pressure_label]}


############################################################################################################################################################################################################




############################################################################################################################################################################################################
# draw current setting numbers on the left margin


if {[ifexists ::settings(grinder_dose_weight)] == "" || [ifexists ::settings(grinder_dose_weight)] == "0"} {
	set ::settings(grinder_dose_weight) 15
	copy_streamline_settings_to_DYE 
	#copy_settings_from_streamline_to_profile
}

# labels
add_de1_variable "off " 418 304 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -textvariable {[ifexists ::settings(grinder_setting)]}
add_de1_variable "off " 418 418 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -tags dose_label_1st -textvariable {[return_weight_measurement $::settings(grinder_dose_weight) 2]}
add_de1_variable "off" 418 512 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -tags weight_label_1st -textvariable {[return_weight_measurement [determine_final_weight] 2]}
add_de1_variable "off" 418 558 -justify center -anchor "center" -text "" -font Inter-Regular12 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -textvariable {([dose_weight_ratio])}
add_de1_variable "off " 418 761 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -tags temp_label_1st -textvariable {[return_temperature_measurement_no_unit $::settings(espresso_temperature) 0]}   
#add_de1_variable "off  steam" 418 988 -justify center -anchor "center" -text [translate "31s"] -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -tags steam_label_1st -textvariable {[steam_timeout_seconds]}
add_de1_variable "off steam" 418 968 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -tags steam_label_1st -textvariable {$::streamline_steam_label_1st}
add_de1_variable "off steam" 418 1011 -justify center -anchor "center" -text "" -font Inter-Regular12 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -textvariable {$::streamline_steam_label_2nd}

add_de1_variable "off  flush hotwaterrinse" 418 1215 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -tags flush_label_1st -textvariable {[seconds_text_very_abbreviated $::settings(flush_seconds)]}
add_de1_variable "off  water" 418 1417 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -tags hotwater_label_1st -textvariable {$::streamline_hotwater_label_1st}
add_de1_variable "off  water" 418 1460 -justify center -anchor "center" -text "" -font Inter-Regular12 -fill $::plus_minus_value_text_color -width [rescale_x_skin 200] -textvariable {$::streamline_hotwater_label_2nd}

#disabled labels
add_de1_variable "espresso water flush hotwaterrinse steam" 418 304 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color_disabled -width [rescale_x_skin 200] -textvariable {[ifexists ::settings(grinder_setting)]}
add_de1_variable "espresso water flush hotwaterrinse steam" 418 418 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color_disabled -width [rescale_x_skin 200] -tags dose_label_1std -textvariable {[return_weight_measurement $::settings(grinder_dose_weight) 2]}
add_de1_variable "espresso water flush hotwaterrinse steam" 418 512 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color_disabled -width [rescale_x_skin 200] -tags weight_label_1std -textvariable {[return_weight_measurement [determine_final_weight] 2]}
add_de1_variable "espresso water flush hotwaterrinse steam" 418 558 -justify center -anchor "center" -text "" -font Inter-Regular12 -fill $::plus_minus_value_text_color_disabled -width [rescale_x_skin 200] -textvariable {([dose_weight_ratio])}
add_de1_variable "espresso water flush hotwaterrinse " 418 761 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color_disabled -width [rescale_x_skin 200] -tags temp_label_1std -textvariable {[return_temperature_measurement_no_unit $::settings(espresso_temperature) 0]}   
#add_de1_variable "espresso water flush hotwaterrinse" 418 988 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color_disabled -width [rescale_x_skin 200] -tags steam_label_1std -textvariable {[steam_timeout_seconds]}
add_de1_variable "espresso water flush hotwaterrinse" 418 968 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color_disabled -width [rescale_x_skin 200] -tags steam_label_1std -textvariable {$::streamline_steam_label_1st}
add_de1_variable "espresso water flush hotwaterrinse" 418 1011 -justify center -anchor "center" -text "" -font Inter-Regular12 -fill $::plus_minus_value_text_color_disabled -width [rescale_x_skin 200] -tags steam_label_2nd -textvariable {$::streamline_steam_label_2nd}

add_de1_variable "espresso water steam" 418 1215 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color_disabled -width [rescale_x_skin 200] -tags flush_label_1std -textvariable {[seconds_text_very_abbreviated $::settings(flush_seconds)]}
add_de1_variable "espresso  flush hotwaterrinse steam" 418 1417 -justify center -anchor "center" -text "" -font Inter-Bold16 -fill $::plus_minus_value_text_color_disabled -width [rescale_x_skin 200] -tags hotwater_label_1std -textvariable {$::streamline_hotwater_label_1st}
add_de1_variable "espresso  flush hotwaterrinse steam" 418 1460 -justify center -anchor "center" -text "" -font Inter-Regular12 -fill $::plus_minus_value_text_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_hotwater_label_2nd}

add_de1_button "off " { ask_for_data_entry_number [translate "GRIND"] [ifexists ::settings(grinder_setting)] ::settings(grinder_setting) "" 0 0 1000 [list copy_streamline_settings_to_DYE {save_profile_and_update_de1 0} "streamline_blink_rounded_setting grind_setting_rectangle"]} 370 260 470 340  ""   
add_de1_button "off " { ask_for_data_entry_number [translate "DOSE"] [ifexists ::settings(grinder_dose_weight)] ::settings(grinder_dose_weight) [translate g] 0 0 30 [list copy_streamline_settings_to_DYE {save_profile_and_update_de1 0} "streamline_blink_rounded_setting dose_setting_rectangle dose_label_1st"]} 370 374 470 454  ""   
add_de1_button "off " { ask_for_data_entry_number [translate "DRINK"] [ifexists ::settings(final_desired_shot_weight)] ::settings(final_desired_shot_weight) [translate g] 0 0 2000 [list copy_streamline_settings_to_DYE {streamline_set_drink_weight $::settings(final_desired_shot_weight)} refresh_favorite_dosebev_button_labels {save_profile_and_update_de1 0} "streamline_blink_rounded_setting weight_setting_rectangle weight_label_1st"]} 370 488 470 578  ""   

add_de1_button "off " { choose_appropriate_data_entry_for_brew_temp} 370 716 470 796  ""   
add_de1_button "off " { choose_appropriate_data_entry_for_steam } 370 944 470 1024  ""   
add_de1_button "off " { ask_for_data_entry_number [translate "FLUSH"] [ifexists ::settings(flush_seconds)] ::settings(flush_seconds) [translate "s"] 1 3 255 [list save_profile_and_update_de1_soon "streamline_blink_rounded_setting flush_setting_rectangle flush_label_1st"]} 370 1172 470 1252  ""   
add_de1_button "off " { choose_appropriate_data_entry_for_hot_water } 370 1400 470 1480  ""   

# TODO add_de1_button "off " { choose_appropriate_data_entry_for_steam } 370 1400 470 1480  ""   


proc save_fahrenheit_hot_water {} {
	set ::settings(water_temperature) [fahrenheit_to_celsius $::data_entry_water_temperature]
}

proc save_brew_temp {} {
	if {$::settings(enable_fahrenheit) == 1} {
		set ::data_entry_brew_temperature [round_to_integer $::data_entry_brew_temperature]
		set dest_espresso_temperature [fahrenheit_to_celsius [round_to_integer $::data_entry_brew_temperature]]
	} else {
		set ::data_entry_brew_temperature [round_one_digits_point_five $::data_entry_brew_temperature]
		set dest_espresso_temperature $::data_entry_brew_temperature		
	}

	set dest_temp $dest_espresso_temperature
	set diff_temp [expr {$dest_temp - $::settings(espresso_temperature)}]
	change_espresso_temperature $diff_temp

}


proc choose_appropriate_data_entry_for_brew_temp {} {
	if {$::settings(enable_fahrenheit) == 1} {
		set ::data_entry_brew_temperature [celsius_to_fahrenheit $::settings(espresso_temperature)]
		ask_for_data_entry_number [translate "TEMP"] $::data_entry_brew_temperature ::data_entry_brew_temperature "º" 1 1 221 [list save_brew_temp save_profile_and_update_de1_soon "streamline_blink_rounded_setting temp_setting_rectangle"]
	} else {
		# celsius
		set ::data_entry_brew_temperature $::settings(espresso_temperature)
		ask_for_data_entry_number [translate "TEMP"] $::data_entry_brew_temperature ::data_entry_brew_temperature "º" 0 1 105 [list save_brew_temp save_profile_and_update_de1_soon "streamline_blink_rounded_setting temp_setting_rectangle"]
	}
}

proc choose_appropriate_data_entry_for_hot_water {} {
	if {$::streamline_hotwater_btn_mode == "ml"} {
		ask_for_data_entry_number [translate "VOLUME"] [ifexists ::settings(water_volume)] ::settings(water_volume) "ml" 1 3 255 [list streamline_hot_water_setting_change refresh_favorite_hw_button_labels save_profile_and_update_de1_soon "streamline_blink_rounded_setting hotwater_setting_rectangle hotwater_label_1st" refresh_hw_temp_labels]
	} else {

		if {$::settings(enable_fahrenheit) == 1} {
			set ::data_entry_water_temperature [celsius_to_fahrenheit $::settings(water_temperature)]
			ask_for_data_entry_number [translate "TEMP"] $::data_entry_water_temperature ::data_entry_water_temperature "º" 1 0 212 [list save_fahrenheit_hot_water streamline_hot_water_setting_change refresh_favorite_hw_button_labels refresh_steam_time_flow_labels save_profile_and_update_de1_soon "streamline_blink_rounded_setting hotwater_setting_rectangle hotwater_label_1st" refresh_hw_temp_labels]
		} else {
			# celsius
			
			ask_for_data_entry_number [translate "TEMP"] [ifexists ::settings(water_temperature)] ::settings(water_temperature) "º" 1 0 100 [list streamline_hot_water_setting_change refresh_favorite_hw_button_labels refresh_steam_time_flow_labels save_profile_and_update_de1_soon "streamline_blink_rounded_setting hotwater_setting_rectangle hotwater_label_1st" refresh_hw_temp_labels]
		}

	}
	refresh_favorite_temperature_button_labels
}

proc save_steam_flow_rate {} {
	set ::settings(steam_flow) [expr {int(100 * $::data_entry_steam_flow)}]

}
proc choose_appropriate_data_entry_for_steam {} {
	if {$::streamline_steam_btn_mode == "time"} {
		#ask_for_data_entry_number [translate "STEAM TIMEOUT"] [ifexists ::settings(steam_timeout)] ::settings(steam_timeout) [translate "s"] 1 3 255 [list save_profile_and_update_de1_soon "streamline_blink_rounded_setting steam_setting_rectangle steam_label_1st"]
		ask_for_data_entry_number [translate "STEAM TIMEOUT"] [ifexists ::settings(steam_timeout)] ::settings(steam_timeout) [translate "s"] 1 0 255 [list streamline_steam_setting_change refresh_favorite_steam_button_labels refresh_hw_temp_labels save_profile_and_update_de1_soon "streamline_blink_rounded_setting steam_setting_rectangle steam_label_1st" refresh_steam_time_flow_labels]
	} else {

		set ::data_entry_steam_flow [round_to_two_digits [expr {.01 * $::settings(steam_flow)}]]
		ask_for_data_entry_number [translate "STEAM FLOW"] [ifexists ::data_entry_steam_flow] ::data_entry_steam_flow "ml/s" 0 0.4 2.5 [list save_steam_flow_rate streamline_steam_setting_change refresh_favorite_steam_button_labels refresh_hw_temp_labels save_profile_and_update_de1_soon "streamline_blink_rounded_setting steam_setting_rectangle steam_label_1st" refresh_steam_time_flow_labels]

	}
	refresh_favorite_steam_button_labels
}


# highly rounded rectangles

# dose
streamline_rounded_rectangle $::pages 25 606 145 656  $::box_color $::plus_minus_flash_off_color_disabled 20 dose_preset_rectangle_1
streamline_rounded_rectangle $::pages 189 606 309 656  $::box_color $::plus_minus_flash_off_color_disabled 20 dose_preset_rectangle_2
streamline_rounded_rectangle $::pages 343 606 463 656  $::box_color $::plus_minus_flash_off_color_disabled 20 dose_preset_rectangle_3
streamline_rounded_rectangle $::pages 487 606 607 656  $::box_color $::plus_minus_flash_off_color_disabled 20 dose_preset_rectangle_4


# temp
streamline_rounded_rectangle $::pages 25 833 145 883  $::box_color $::plus_minus_flash_off_color_disabled 20 temp_preset_rectangle_1
streamline_rounded_rectangle $::pages 189 833 309 883  $::box_color $::plus_minus_flash_off_color_disabled 20 temp_preset_rectangle_2
streamline_rounded_rectangle $::pages 343 833 463 883  $::box_color $::plus_minus_flash_off_color_disabled 20 temp_preset_rectangle_3
streamline_rounded_rectangle $::pages 487 833 607 883  $::box_color $::plus_minus_flash_off_color_disabled 20 temp_preset_rectangle_4

# steam
streamline_rounded_rectangle $::pages 25 1059 145 1109  $::box_color $::plus_minus_flash_off_color_disabled 20 steam_preset_rectangle_1
streamline_rounded_rectangle $::pages 189 1059 309 1109  $::box_color $::plus_minus_flash_off_color_disabled 20 steam_preset_rectangle_2
streamline_rounded_rectangle $::pages 343 1059 463 1109  $::box_color $::plus_minus_flash_off_color_disabled 20 steam_preset_rectangle_3
streamline_rounded_rectangle $::pages 487 1059 607 1109  $::box_color $::plus_minus_flash_off_color_disabled 20 steam_preset_rectangle_4


# flush
streamline_rounded_rectangle $::pages 25 1289 145 1339  $::box_color $::plus_minus_flash_off_color_disabled 20 flush_preset_rectangle_1
streamline_rounded_rectangle $::pages 189 1289 309 1339  $::box_color $::plus_minus_flash_off_color_disabled 20 flush_preset_rectangle_2
streamline_rounded_rectangle $::pages 343 1289 463 1339  $::box_color $::plus_minus_flash_off_color_disabled 20 flush_preset_rectangle_3
streamline_rounded_rectangle $::pages 487 1289 607 1339  $::box_color $::plus_minus_flash_off_color_disabled 20 flush_preset_rectangle_4


# hotwater
streamline_rounded_rectangle $::pages 25 1512 145 1562  $::box_color $::plus_minus_flash_off_color_disabled 20 hot_water_preset_rectangle_1
streamline_rounded_rectangle $::pages 189 1512 309 1562  $::box_color $::plus_minus_flash_off_color_disabled 20 hot_water_preset_rectangle_2
streamline_rounded_rectangle $::pages 343 1512 463 1562  $::box_color $::plus_minus_flash_off_color_disabled 20 hot_water_preset_rectangle_3
streamline_rounded_rectangle $::pages 487 1512 607 1562  $::box_color $::plus_minus_flash_off_color_disabled 20 hot_water_preset_rectangle_4


############################################################################################################################################################################################################

############################################################################################################################################################################################################
# draw current setting numbers on the left margin

set streamline_preset_pos_col1 50
set streamline_preset_pos_col2 204
set streamline_preset_pos_col3 356
set streamline_preset_pos_col4 578 


#########
# dose/beverage presets
add_de1_variable "off " $streamline_preset_pos_col1 616  -justify left -tags dose_btn_1 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_1)}
add_de1_variable "off " [expr {$streamline_preset_pos_col2-12}] 616  -justify left -tags dose_btn_2 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_2)}
add_de1_variable "off " [expr {$streamline_preset_pos_col3-12}] 616  -justify left  -tags dose_btn_3 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_3)}
add_de1_variable "off " $streamline_preset_pos_col4 616  -justify right -tags dose_btn_4 -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_4)}

# disabled versions of same
add_de1_variable "steam water flush hotwaterrinse espresso " $streamline_preset_pos_col1 616  -justify left -tags dose_btn_1d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_1)}
add_de1_variable "steam water flush hotwaterrinse espresso " [expr {$streamline_preset_pos_col2-12}] 616  -justify left -tags dose_btn_2d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_2)}
add_de1_variable "steam water flush hotwaterrinse espresso " [expr {$streamline_preset_pos_col3-12}] 616  -justify left  -tags dose_btn_3d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_3)}
add_de1_variable "steam water flush hotwaterrinse espresso " $streamline_preset_pos_col4 616  -justify right -tags dose_btn_4d -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_4)}

dui add dbutton "off" 0 610 148 672 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_dosebev_select 1 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd { say [translate {Preset}] $::settings(sound_button_out); streamline_set_dosebev_preset 1 } 
dui add dbutton "off" 148 610 310 672 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_dosebev_select 2 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_dosebev_preset 2 } 
dui add dbutton "off" 310 610 474 672 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_dosebev_select 3 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_dosebev_preset 3 } 
dui add dbutton "off" 474 610 624 672 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_dosebev_select 4 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_dosebev_preset 4 } 



#########
# temp presets
add_de1_variable "off" $streamline_preset_pos_col1 842  -justify left -tags temp_btn_1 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_1)}
add_de1_variable "off" $streamline_preset_pos_col2 842  -justify left -tags temp_btn_2 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_2)}
add_de1_variable "off" $streamline_preset_pos_col3 842  -justify left  -tags temp_btn_3 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_3)}
add_de1_variable "off" $streamline_preset_pos_col4 842  -justify right -tags temp_btn_4 -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_4)}

add_de1_variable "espresso steam water flush hotwaterrinse" $streamline_preset_pos_col1 842  -justify left -tags temp_btn_1d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_1)}
add_de1_variable "espresso steam water flush hotwaterrinse" $streamline_preset_pos_col2 842  -justify left -tags temp_btn_2d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_2)}
add_de1_variable "espresso steam water flush hotwaterrinse" $streamline_preset_pos_col3 842  -justify left  -tags temp_btn_3d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_3)}
add_de1_variable "espresso steam water flush hotwaterrinse" $streamline_preset_pos_col4 842  -justify right -tags temp_btn_4d -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_4)}

dui add dbutton $::pages 0 838 148 900 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_temperature_select 1 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd { say [translate {Preset}] $::settings(sound_button_out); streamline_set_temperature_preset 1 } 
dui add dbutton $::pages 148 838 310 900 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_temperature_select 2 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_temperature_preset 2 } 
dui add dbutton $::pages 310 838 474 900 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_temperature_select 3 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_temperature_preset 3 } 
dui add dbutton $::pages 474 838 624 900 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_temperature_select 4 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_temperature_preset 4 } 




#########
# steam presets

add_de1_variable "off steam" $streamline_preset_pos_col1 1068  -justify left -tags steam_btn_1 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_1)}
add_de1_variable "off steam" $streamline_preset_pos_col2 1068  -justify left -tags steam_btn_2 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_2)}
add_de1_variable "off steam" $streamline_preset_pos_col3 1068  -justify left -tags steam_btn_3 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_3)}
add_de1_variable "off steam" $streamline_preset_pos_col4 1068  -justify right -tags steam_btn_4 -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_4)}

# disabled versions 
add_de1_variable "espresso water flush hotwaterrinse" $streamline_preset_pos_col1 1068  -justify left -tags steam_btn_1d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_1)}
add_de1_variable "espresso water flush hotwaterrinse" $streamline_preset_pos_col2 1068  -justify left -tags steam_btn_2d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_2)}
add_de1_variable "espresso water flush hotwaterrinse" $streamline_preset_pos_col3 1068  -justify left -tags steam_btn_3d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_3)}
add_de1_variable "espresso water flush hotwaterrinse" $streamline_preset_pos_col4 1068  -justify right -tags steam_btn_4d -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_4)}


dui add dbutton $::pages  0 1066 148 1128 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_steam_select 1 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd { say [translate {Preset}] $::settings(sound_button_out); streamline_set_steam_preset 1 } 
dui add dbutton $::pages 148 1066 310 1128 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_steam_select 2 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_steam_preset 2 } 
dui add dbutton $::pages 310 1066 474 1128 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_steam_select 3 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_steam_preset 3 } 
dui add dbutton $::pages 474 1066 624 1128 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_steam_select 4 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_steam_preset 4 } 


#########
# flush presets

add_de1_variable "off flush hotwaterrinse" $streamline_preset_pos_col1 1296  -justify left -tags flush_btn_1 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_1)}
add_de1_variable "off flush hotwaterrinse" $streamline_preset_pos_col2 1296  -justify left -tags flush_btn_2 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_2)}
add_de1_variable "off flush hotwaterrinse" $streamline_preset_pos_col3 1296  -justify left -tags flush_btn_3 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_3)}
add_de1_variable "off flush hotwaterrinse" $streamline_preset_pos_col4 1296  -justify right -tags flush_btn_4 -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_4)}

# disabled versions 
add_de1_variable "espresso steam water" $streamline_preset_pos_col1 1296  -justify left -tags flush_btn_1d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_1)}
add_de1_variable "espresso steam water" $streamline_preset_pos_col2 1296  -justify left -tags flush_btn_2d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_2)}
add_de1_variable "espresso steam water" $streamline_preset_pos_col3 1296  -justify left -tags flush_btn_3d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_3)}
add_de1_variable "espresso steam water" $streamline_preset_pos_col4 1296  -justify right -tags flush_btn_4d -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_4)}


dui add dbutton "off flush hotwaterrinse" 0 1288 148 1350 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_flush_select 1 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd { say [translate {Preset}] $::settings(sound_button_out); streamline_set_flush_preset 1 } 
dui add dbutton "off flush hotwaterrinse" 148 1288 310 1350 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_flush_select 2 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_flush_preset 2 } 
dui add dbutton "off flush hotwaterrinse" 310 1288 474 1350 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_flush_select 3 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_flush_preset 3 } 
dui add dbutton "off flush hotwaterrinse" 474 1288 624 1350 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_flush_select 4 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_flush_preset 4 } 


#########
# hot water presets
# font color
dui aspect set -theme streamline -type dbutton label_fill "#ff0000"
dui aspect set -theme streamline -type dbutton fill "#ff0000"

add_de1_variable "off water" $streamline_preset_pos_col1 1520  -justify left -tags hw_btn_1 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_1)}
add_de1_variable "off water" $streamline_preset_pos_col2 1520  -justify left -tags hw_btn_2 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_2)}
add_de1_variable "off water" $streamline_preset_pos_col3 1520  -justify left -tags hw_btn_3 -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_3)}
add_de1_variable "off water" $streamline_preset_pos_col4 1520  -justify right -tags hw_btn_4 -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color  -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_4)}

# disabled versions 
add_de1_variable "espresso steam flush hotwaterrinse" $streamline_preset_pos_col1 1520  -justify left -tags hw_btn_1d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_1)}
add_de1_variable "espresso steam flush hotwaterrinse" $streamline_preset_pos_col2 1520  -justify left -tags hw_btn_2d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_2)}
add_de1_variable "espresso steam flush hotwaterrinse" $streamline_preset_pos_col3 1520  -justify left -tags hw_btn_3d -anchor "nw" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_3)}
add_de1_variable "espresso steam flush hotwaterrinse" $streamline_preset_pos_col4 1520  -justify right -tags hw_btn_4d -anchor "ne" -font Inter-Bold11 -fill $::preset_value_color_disabled -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_4)}

dui add dbutton "off water" 0 1516 148 1600 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_hw_preset_select 1 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_hw_preset 1 } 
dui add dbutton "off water" 148 1516 310 1600 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_hw_preset_select 2 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_hw_preset 2 } 
dui add dbutton "off water" 310 1516 474 1600 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_hw_preset_select 3 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_hw_preset 3 } 
dui add dbutton "off water" 474 1516 624 1600 -command {say [translate {Preset}] $::settings(sound_button_out); streamline_hw_preset_select 4 } -theme none -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd {say [translate {Preset}] $::settings(sound_button_out); streamline_set_hw_preset 4 } 

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
	set default_profile_buttons [list "" "default" "best_practice" "80s_Espresso" "rao_allonge" "Gentle and sweet"]

	if {$profiles == ""} {
		# replace the default profile types with the ones most recently used
		set streamline_history_most_common_profiles [streamline_history_most_common_profiles]
		for {set c 0} {$c < 5} {incr c} {
			if {$c >= [llength $streamline_history_most_common_profiles]} {
				# there are not enough commonly used to replace the defaults
				break
			}
			set default_profile_buttons [lreplace $default_profile_buttons $c+1 $c+1 [lindex $streamline_history_most_common_profiles $c]]
		}
	}

	# look for two buttons with the same profile.  If found, clear the 2nd incidence of that same button.
	for {set x 1} {$x <= 5}  {incr x} {
		set tt {}
		catch {
			set tt [dict get $profiles $x title]
		}
		if {$tt == ""} {
			continue
		}

		if {[info exists profile_button_name_used($tt)] == 1} {

			set t($x) ""
			set b($x) " "

			dict set profiles $x name $t($x)
			dict set profiles $x title $b($x)
			set changed 1

		} else {
			set profile_button_name_used($tt) 1
		}
	}

	for {set x 1} {$x <= 5}  {incr x} {
		set b($x) ""

		catch {
			set b($x) [dict get $profiles $x title]

			set b($x) [file tail $b($x)]

			if {$::settings(profile_title) == $b($x) && $streamline_selected_favorite_profile != $x} {
				msg -ERROR "STREAMLINE: selected a profile manually that matches the same name"
				after 500 streamline_profile_select $x
				return
			}

		}

		if {$b($x) == ""} {
			set t($x) [lindex $default_profile_buttons $x]
			set b($x) [profile_title [lindex $default_profile_buttons $x]]

			dict set profiles $x name $t($x)
			dict set profiles $x title $b($x)
			set changed 1
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

	if {$streamline_selected_favorite_profile >= 1 && $streamline_selected_favorite_profile <= 5 && [file tail $::settings(profile_title)] == $b($streamline_selected_favorite_profile)} {
		set bc($streamline_selected_favorite_profile) $::profile_button_background_selected_color
		set lbc($streamline_selected_favorite_profile) $::profile_button_button_selected_color
		set obc($streamline_selected_favorite_profile) $::profile_button_background_selected_color
	} 

	for {set x 1} {$x <= 5}  {incr x} {
		set dtt ""
		catch {
			set dtt [dict get $profiles $x title]
		}
		if {$dtt == ""} {
			continue
		}
		if {$dtt == " "} {
			# darken favorite-profile buttons that have no setting
			.can itemconfigure profile_${x}_btn-btn -fill $::profile_button_background_unused_color
		} else {
			.can itemconfigure profile_${x}_btn-btn -fill $bc($x)
		}

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
dui aspect set -theme streamline -type dbutton label_font Inter-Bold13

# rounded retangle radius
dui aspect set -theme streamline -type dbutton radius 45

# rounded rectangle line width
dui aspect set -theme streamline -type dbutton width 2


# width of the text, to enable auto-wrapping
dui aspect set -theme streamline -type dbutton_label width 300

# button shape
dui aspect set -theme streamline -type dbutton shape round_outline 

# label position
dui aspect set -theme streamline -type dbutton label_pos ".50 .50" 

####
# the selected profile button

# font color
dui aspect set -theme streamline -type dbutton label_fill $::profile_button_button_color

# width of text of profile selection button
#dui aspect set -theme streamline -type dbutton_label width 220
#dui aspect set -theme streamline -type dbutton label_width [rescale_x_skin 480]



set first_button_start 40
set profile_button_width 320
set profile_button_gap 20
set profile_button_top 45
set profile_button_bottom 175

set preset_tamp_pad {6 40 6 40}
dui add dbutton $::all_pages [expr {$first_button_start}] $profile_button_top [expr {$first_button_start + $profile_button_width}] $profile_button_bottom -tags profile_1_btn -labelvariable {$::streamline_favorite_profile_buttons(label_1)}  -command { say [translate {Edit}] $::settings(sound_button_out); streamline_profile_select 1 } -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Edit}] $::settings(sound_button_out); clear_favorite_profile 1 } -tap_pad $preset_tamp_pad
dui add dbutton $::all_pages [expr {$first_button_start + $profile_button_width + $profile_button_gap}] $profile_button_top [expr {$first_button_start + (2*$profile_button_width) + $profile_button_gap}] $profile_button_bottom -tags profile_2_btn -labelvariable {$::streamline_favorite_profile_buttons(label_2)}  -command { say [translate {Edit}] $::settings(sound_button_out); streamline_profile_select 2 } -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd { say [translate {Edit}] $::settings(sound_button_out); clear_favorite_profile 2 } -tap_pad $preset_tamp_pad
dui add dbutton $::all_pages [expr {$first_button_start + (2*$profile_button_width) + (2*$profile_button_gap)}] $profile_button_top [expr {$first_button_start + (3*$profile_button_width) + (2*$profile_button_gap)}] $profile_button_bottom -tags profile_3_btn -labelvariable {$::streamline_favorite_profile_buttons(label_3)} -command { say [translate {Edit}] $::settings(sound_button_out); streamline_profile_select 3 } -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd { say [translate {Edit}] $::settings(sound_button_out); clear_favorite_profile 3 } -tap_pad $preset_tamp_pad
dui add dbutton $::all_pages [expr {$first_button_start + (3*$profile_button_width) + (3*$profile_button_gap)}] $profile_button_top [expr {$first_button_start + (4*$profile_button_width) + (3*$profile_button_gap)}] $profile_button_bottom -tags profile_4_btn -labelvariable {$::streamline_favorite_profile_buttons(label_4)}   -command { say [translate {Edit}] $::settings(sound_button_out); streamline_profile_select 4 } -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd { say [translate {Edit}] $::settings(sound_button_out); clear_favorite_profile 4 } -tap_pad $preset_tamp_pad
dui add dbutton $::all_pages [expr {$first_button_start + (4*$profile_button_width) + (4*$profile_button_gap)}] $profile_button_top [expr {$first_button_start + (5*$profile_button_width) + (4*$profile_button_gap)}] $profile_button_bottom -tags profile_5_btn -labelvariable {$::streamline_favorite_profile_buttons(label_5)}   -command { say [translate {Edit}] $::settings(sound_button_out); streamline_profile_select 5 } -longpress_threshold $::streamline_longpress_threshold  -longpress_cmd { say [translate {Edit}] $::settings(sound_button_out); clear_favorite_profile 5 } -tap_pad $preset_tamp_pad



# button color
dui aspect set -theme streamline -type dbutton fill $::settings_sleep_button_color

# rounded rectangle color 
dui aspect set -theme streamline -type dbutton outline $::settings_sleep_button_outline_color

dui aspect set -theme streamline -type dbutton width 2

# rounded retangle radius
#dui aspect set -theme streamline -type dbutton radius 36
dui aspect set -theme streamline -type dbutton radius 60

# font color
dui aspect set -theme streamline -type dbutton label_fill $::settings_sleep_button_text_color


set right_buttons_start 2530
set right_buttons_width 200
set right_buttons_separation 20

dui add dbutton $::all_pages [expr {$right_buttons_start - (2*$right_buttons_width) - (2*$right_buttons_separation)}] 66 [expr {$right_buttons_start - $right_buttons_width - $right_buttons_separation}] 155 -tags settings_btn -label [translate "Settings"]  -command { say [translate {settings}] $::settings(sound_button_out); show_settings [::profile::fix_profile_type [ifexists ::settings(settings_profile_type)]] "back_from_settings" } -tap_pad {6 50 6 50}
dui add dbutton $::all_pages [expr {$right_buttons_start - $right_buttons_width}] 66 $right_buttons_start 155 -tags sleep_btn -label [translate "Sleep"]  -command { say [translate {sleep}] $::settings(sound_button_out); start_sleep } -longpress_cmd { say [translate {Exit}] $::settings(sound_button_out); streamline_app_exit_button }  -tap_pad {6 50 24 50}
#-longpress_threshold $::streamline_longpress_threshold 
#

proc streamline_app_exit_button {} {

	# disabled for now as causes unwanted app exits accidentally on some tablets
	#return

	# only exit if we are not in the sleep page : this is trying to work around a bug in DUI with long-press sometimes falsely firing
	if {[dui page current] == "off" || [dui page current] == "off_zoomed"} {
		app_exit
	}
}

############################################################################################################################################################################################################
# DYE support

# DYE support

set dyebtns ""

if { [plugins enabled DYE] } {
	# not yet available
	# plugins disable DYE
	dui add dbutton $::all_pages [expr {$right_buttons_start - (3*$right_buttons_width) - (3*$right_buttons_separation)}] 66 [expr {$right_buttons_start - (2*$right_buttons_width) - (3*$right_buttons_separation)}] 155 -tags dye_btn -label [translate "DYE"]  -command { show_DYE_page } -longpress_cmd { DYE_longpress } -tap_pad {6 50 6 50} -tap_pad {6 50 6 50}
}

proc show_DYE_page {} {

	if { [plugins enabled DYE] } {
		if {[info exists ::streamline_current_history_profile_clock] && $::streamline_history_file_selected_number != [expr {[llength $::streamline_history_files] -1}]} {
			plugins::DYE::open -which_shot $::streamline_current_history_profile_clock
		} else {
			plugins::DYE::open -which_shot default -coords {975 190} -anchor nw
		}
	}
}

proc DYE_longpress {} {
	if { [plugins enabled DYE] } {
		plugins::DYE::open -which_shot dialog -coords {975 190} -anchor nw
	}
}
############################################################################################################################################################################################################


# button color
#dui aspect set -theme streamline -type dbutton fill "d8d8d8"

# font color
#dui aspect set -theme streamline -type dbutton label_fill "3c5782"

refresh_favorite_profile_button_labels

############################################################################################################################################################################################################


############################################################################################################################################################################################################
# plus/minus +/- buttons on the left hand side for changing parameters

# rounded rectangle color 
dui aspect set -theme streamline -type dbutton outline $::plus_minus_outline_color
dui aspect set -theme streamline -type dbutton disabledoutline $::plus_minus_outline_color


# inside button color

dui aspect set -theme streamline -type dbutton fill $::plus_minus_flash_off_color

# font color
dui aspect set -theme streamline -type dbutton label_fill "$::plus_minus_text_color"

# font to use
dui aspect set -theme streamline -type dbutton label_font Inter-Bold24 

# rounded retangle radius
dui aspect set -theme streamline -type dbutton radius 18

# rounded retangle line width
dui aspect set -theme streamline -type dbutton width 2 

# button shape
dui aspect set -theme streamline -type dbutton shape round_outline 



# the - buttons
# label position is higher because we're using a _ as a minus symbol
dui aspect set -theme streamline -type dbutton label_pos ".50 .22" 
dui add dbutton "off" 254 257 346 349 -tags streamline_minus_grind_btn -label "_"  -command { say [translate {Minus}] $::settings(sound_button_out); streamline_adjust_grind -- } -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Minus}] $::settings(sound_button_out); streamline_adjust_grind - } -tap_pad {40 4 2 4}
dui add dbutton "off" 254 369 346 461 -tags streamline_minus_dose_btn -label "_"  -command { say [translate {Minus}] $::settings(sound_button_out); streamline_dose_btn -- } -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Minus}] $::settings(sound_button_out); streamline_dose_btn - } -tap_pad {40 4 2 4}
dui add dbutton "off " 254 486 346 578 -tags streamline_minus_beverage_btn -label "_"  -command { say [translate {Minus}] $::settings(sound_button_out); streamline_beverage_btn - } -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Minus}] $::settings(sound_button_out); streamline_beverage_btn - } -tap_pad {40 4 2 4}
dui add dbutton "off" 254 713 346 805 -tags streamline_minus_temp_btn -label "_"  -command { say [translate {Minus}] $::settings(sound_button_out); streamline_temp_btn - } -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Minus}] $::settings(sound_button_out); streamline_temp_btn -- } -tap_pad {40 4 2 4}
dui add dbutton "off steam" 254 940 346 1032 -tags streamline_minus_steam_btn -label "_"  -command { say [translate {Minus}] $::settings(sound_button_out); streamline_steam_btn - } -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Minus}] $::settings(sound_button_out); streamline_steam_btn - } -tap_pad {14 4 2 4}
dui add dbutton "off flush hotwaterrinse" 254 1164 346 1256 -tags streamline_minus_flush_btn -label "_"  -command { say [translate {Minus}] $::settings(sound_button_out); streamline_flush_btn - } -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Minus}] $::settings(sound_button_out); streamline_flush_btn - } -tap_pad {40 4 2 4}
dui add dbutton "off water" 254 1390 346 1482 -tags streamline_minus_hotwater_btn -label "_"  -command { say [translate {Minus}] $::settings(sound_button_out); streamline_hotwater_btn - } -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Minus}] $::settings(sound_button_out); streamline_hotwater_btn - } -tap_pad {20 4 2 4}

# the + buttons
# label position for +
dui aspect set -theme streamline -type dbutton label_pos ".49 .44" 
dui add dbutton "off" 486 259 578 351 -tags streamline_plus_grind_btn -label "+"  -command { say [translate {Plus}] $::settings(sound_button_out); streamline_adjust_grind ++ } -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Plus}] $::settings(sound_button_out); streamline_adjust_grind + } -tap_pad {2 4 40 4}
dui add dbutton "off" 486 371 578 463 -tags streamline_plus_dose_btn -label "+"  -command { say [translate {Plus}] $::settings(sound_button_out); streamline_dose_btn ++ }  -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Plus}] $::settings(sound_button_out); streamline_dose_btn + } -tap_pad {2 4 40 4}
dui add dbutton "off " 486 488 578 580 -tags streamline_plus_beverage_btn -label "+"  -command { say [translate {Plus}] $::settings(sound_button_out); streamline_beverage_btn + }  -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Plus}] $::settings(sound_button_out); streamline_beverage_btn + } -tap_pad {2 4 40 4}
dui add dbutton "off" 486 715 578 807 -tags streamline_plus_temp_btn -label "+"  -command { say [translate {Plus}] $::settings(sound_button_out); streamline_temp_btn + }  -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Plus}] $::settings(sound_button_out); streamline_temp_btn ++ } -tap_pad {2 4 40 4}
dui add dbutton "off steam" 486 942 578 1034 -tags streamline_plus_steam_btn -label "+"  -command { say [translate {Plus}] $::settings(sound_button_out); streamline_steam_btn + }  -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Plus}] $::settings(sound_button_out); streamline_steam_btn + } -tap_pad {2 4 40 4}
dui add dbutton "off flush hotwaterrinse" 486 1166 578 1258 -tags streamline_plus_flush_btn -label "+"  -command { say [translate {Plus}] $::settings(sound_button_out); streamline_flush_btn + }  -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Plus}] $::settings(sound_button_out); streamline_flush_btn + } -tap_pad {2 4 40 4}
dui add dbutton "off water" 486 1392 578 1484 -tags streamline_plus_hotwater_btn -label "+"  -command { say [translate {Plus}] $::settings(sound_button_out); streamline_hotwater_btn + }  -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { say [translate {Plus}] $::settings(sound_button_out); streamline_hotwater_btn + } -tap_pad {2 4 40 4}

##### disabled versions of same
dui aspect set -theme streamline -type dbutton fill $::plus_minus_flash_off_color_disabled
dui aspect set -theme streamline -type dbutton label_fill $::plus_minus_value_text_color_disabled

# the - buttons
# label position is higher because we're using a _ as a minus symbol
dui aspect set -theme streamline -type dbutton label_pos ".50 .22" 
dui add dbutton "espresso steam water flush hotwaterrinse" 254 257 346 349 -tags streamline_minus_grind_btn -label "_" 
dui add dbutton "espresso steam water flush hotwaterrinse" 254 369 346 461 -tags streamline_minus_dose_btn -label "_"  
dui add dbutton "steam water flush hotwaterrinse espresso" 254 486 346 578 -tags streamline_minus_beverage_btn -label "_"  
dui add dbutton "espresso steam water flush hotwaterrinse" 254 713 346 805 -tags streamline_minus_temp_btn -label "_"
dui add dbutton "espresso water flush hotwaterrinse" 254 940 346 1032 -tags streamline_minus_steam_btn -label "_"  
dui add dbutton "espresso steam water" 254 1164 346 1256 -tags streamline_minus_flush_btn -label "_"  
dui add dbutton "espresso steam flush hotwaterrinse" 254 1390 346 1482 -tags streamline_minus_hotwater_btn -label "_" 

# the + buttons
# label position for +
dui aspect set -theme streamline -type dbutton label_pos ".49 .44" 
dui add dbutton "espresso steam water flush hotwaterrinse" 486 259 578 351 -tags streamline_plus_grind_btn -label "+" 
dui add dbutton "espresso steam water flush hotwaterrinse" 486 371 578 463 -tags streamline_plus_dose_btn -label "+" 
dui add dbutton "steam water flush hotwaterrinse espresso" 486 488 578 580 -tags streamline_plus_beverage_btn -label "+"  
dui add dbutton "espresso steam water flush hotwaterrinse" 486 715 578 807 -tags streamline_plus_temp_btn -label "+"
dui add dbutton "espresso water flush hotwaterrinse" 486 942 578 1034 -tags streamline_plus_steam_btn -label "+" 
dui add dbutton "espresso steam water" 486 1166 578 1258 -tags streamline_plus_flush_btn -label "+"  
dui add dbutton "espresso steam flush hotwaterrinse" 486 1392 578 1484 -tags streamline_plus_hotwater_btn -label "+" 



############################################################################################################################################################################################################

proc save_profile_and_update_de1 { {do_de1_update 1} } {

	copy_settings_from_streamline_to_profile

	# if the currently loaded profile is not the currently selected button, don't save it automatically
	set profiles [ifexists ::settings(favorite_profiles)]
	set slot [dict get $profiles selected number]	
	set selected_filename [dict get $profiles $slot name]
	set selected_title [dict get $profiles $slot title]
	if {$::settings(profile_filename) != $selected_filename} {
		msg -ERROR "STREAMLINE: current profile is not from a streamline button, so not saving changes to disk, $selected_filename vs $::settings(profile_filename) / $selected_title vs $::settings(profile_title) "
		save_settings_to_de1
		return
	}

	msg "STREAMLINE: saving profile changes to disk"

	if {$::settings(steam_timeout) == 0} {
		set ::settings(steam_disabled) 1
	} else {
		set ::settings(steam_disabled) 0
	}

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

	if {$do_de1_update == 1} {
		save_settings_to_de1
	}
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
		}
	} elseif {$args == "+"} {
		if {$::settings(grinder_dose_weight) < 30} {
			set ::settings(grinder_dose_weight) [round_to_one_digits [expr {$::settings(grinder_dose_weight) + .1}]]
			flash_button "streamline_plus_dose_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
		}
	} elseif {$args == "--"} {
		if {$::settings(grinder_dose_weight) > 2} {
			set ::settings(grinder_dose_weight) [round_to_one_digits [expr {$::settings(grinder_dose_weight) - 1}]]
			flash_button "streamline_minus_dose_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
		}
	} elseif {$args == "++"} {
		if {$::settings(grinder_dose_weight) < 29} {
			set ::settings(grinder_dose_weight) [round_to_one_digits [expr {$::settings(grinder_dose_weight) + 1}]]
			flash_button "streamline_plus_dose_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
		}
	}

	#copy_settings_from_streamline_to_profile
	copy_streamline_settings_to_DYE
	save_profile_and_update_de1 0
	refresh_favorite_dosebev_button_labels
}

proc copy_settings_from_profile_to_streamline {} {
	set ::settings(grinder_dose_weight) [ifexists ::settings(profile_grinder_dose_weight)]
	set ::settings(grinder_setting) [ifexists ::settings(profile_grinder_setting)]
}

proc copy_settings_from_streamline_to_profile {} {
	set ::settings(profile_grinder_dose_weight) $::settings(grinder_dose_weight) 
	set ::settings(profile_grinder_setting) $::settings(grinder_setting)
}

proc streamline_beverage_btn { args } {
	if {$args == "-"} {
		if {[determine_final_weight] > 0} {
			determine_final_weight -1
			flash_button "streamline_minus_beverage_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
		}
	} elseif {$args == "+"} {
		if {[determine_final_weight] < 2000} {
			determine_final_weight 1
			flash_button "streamline_plus_beverage_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
		}
	}

	save_profile_and_update_de1_soon
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
	} elseif {$args == "--"} {
		if {$::settings(espresso_temperature) > 1} {
			#set ::settings(espresso_temperature) [expr {$::settings(espresso_temperature) - 1}]
			change_espresso_temperature -0.5
			flash_button "streamline_minus_temp_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			save_profile_and_update_de1_soon
		}
	} elseif {$args == "++"} {
		if {$::settings(espresso_temperature) < 110} {
			#set ::settings(espresso_temperature) [expr {$::settings(espresso_temperature) + 1}]
			change_espresso_temperature 0.5
			flash_button "streamline_plus_temp_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			save_profile_and_update_de1_soon
		}
	}
	refresh_favorite_temperature_button_labels
}

proc streamline_steam_btn_obs { args } {
	if {$args == "-"} {
		if {$::settings(steam_timeout) > 0} {
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

	#puts "streamline_hot_water_setting : $::streamline_hot_water_setting"
	if {$::streamline_hotwater_btn_mode == "ml"} {
		set ::streamline_hotwater_label_1st [return_liquid_measurement_ml $::settings(water_volume)]
		set ::streamline_hotwater_label_2nd ([return_temperature_measurement_no_unit $::settings(water_temperature) 1])
	} else {
		set ::streamline_hotwater_label_1st [return_temperature_measurement_no_unit $::settings(water_temperature) 1]
		set ::streamline_hotwater_label_2nd ([return_liquid_measurement_ml $::settings(water_volume)])
	}
}
streamline_hot_water_setting_change

proc streamline_hotwater_btn { args } {

	if {$::streamline_hotwater_btn_mode == "ml"} {
		# ui mode is set to change the hot water volume
		if {$args == "-"} {
			if {$::settings(water_volume) > 1} {
				set ::settings(water_volume) [expr {$::settings(water_volume) - 1}]
				flash_button "streamline_minus_hotwater_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
				#save_profile_and_update_de1_soon
			}
		} elseif {$args == "+"} {
			if {$::settings(water_volume) < 255} {
				set ::settings(water_volume) [expr {$::settings(water_volume) + 1}]
				flash_button "streamline_plus_hotwater_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
				#save_profile_and_update_de1_soon
			}
		}
	} else {
		# the UI mode is set to change the temperature
		if {$args == "-"} {
			if {$::settings(water_temperature) > 1} {
				set ::settings(water_temperature) [expr {$::settings(water_temperature) - 1}]
				flash_button "streamline_minus_hotwater_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
				#save_profile_and_update_de1_soon
			}
		} elseif {$args == "+"} {
			if {$::settings(water_temperature) < 100} {
				set ::settings(water_temperature) [expr {$::settings(water_temperature) + 1}]
				flash_button "streamline_plus_hotwater_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
				#save_profile_and_update_de1_soon
			}
		}
	}
	#streamline_hot_water_setting_change
	save_profile_and_update_de1_soon
	refresh_favorite_hw_button_labels
	streamline_hot_water_setting_change
	
}









proc streamline_steam_btn { args } {

	if {$::streamline_steam_btn_mode == "time"} {
		if {$args == "-"} {
			if {$::settings(steam_timeout) > 0} {
				set ::settings(steam_timeout) [expr {$::settings(steam_timeout) - 1}]
				flash_button "streamline_minus_steam_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
				#save_profile_and_update_de1_soon
			}
		} elseif {$args == "+"} {
			if {$::settings(steam_timeout) < 255} {
				set ::settings(steam_timeout) [expr {$::settings(steam_timeout) + 1}]
				flash_button "streamline_plus_steam_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
				#save_profile_and_update_de1_soon
			}
		}
		#refresh_favorite_steam_button_labels

	} else {
		# the UI mode is set to change the temperature
		if {$args == "-"} {
			if {$::settings(steam_flow) > 0} {
				set ::settings(steam_flow) [expr {$::settings(steam_flow) - 10}]
				flash_button "streamline_minus_steam_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
				#save_profile_and_update_de1_soon
			}
		} elseif {$args == "+"} {
			if {$::settings(steam_flow) < 250} {
				set ::settings(steam_flow) [expr {$::settings(steam_flow) + 10}]
				flash_button "streamline_plus_steam_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
				#save_profile_and_update_de1_soon
			}
		}
		#refresh_favorite_steam_button_labels

	}
	#streamline_steam_setting_change
	#refresh_favorite_steam_button_labels

	#refresh_steam_time_flow_labels 
	save_profile_and_update_de1_soon
	refresh_favorite_steam_button_labels
	streamline_steam_setting_change

}

############################################################################################################################################################################################################
# Profile QuickSettings

# font to use
dui aspect set -theme streamline -type dbutton label_font "Helv_10_bold"

# label position
dui aspect set -theme streamline -type dbutton label_pos ".50 .5" 

# font color
dui aspect set -theme streamline -type dbutton label_fill "#fffeff"

# rounded rectangle color 
dui aspect set -theme streamline -type dbutton width 0
dui aspect set -theme streamline -type dbutton outline "#3e5682"

# inside button color
dui aspect set -theme streamline -type dbutton fill "#3e5682"

dui aspect set -theme streamline -type dbutton radius 40

dui add dbutton "settings_1" 50 1452 160 1580  -tags profile_btn_1 -label "1"  -command { say [translate {Preset}] $::settings(sound_button_out); save_favorite_profile 1 } 
dui add dbutton "settings_1" 180 1452 290 1580   -tags profile_btn_2 -label "2"  -command { say [translate {Preset}] $::settings(sound_button_out); save_favorite_profile 2 } 
dui add dbutton "settings_1" 310 1452 420 1580  -tags profile_btn_3 -label "3"  -command { say [translate {Preset}] $::settings(sound_button_out); save_favorite_profile 3} 
dui add dbutton "settings_1" 440 1452 550 1580  -tags profile_btn_4 -label "4"  -command { say [translate {Preset}] $::settings(sound_button_out); save_favorite_profile 4 } 
dui add dbutton "settings_1" 570 1452 680 1580  -tags profile_btn_5 -label "5"  -command { say [translate {Preset}] $::settings(sound_button_out); save_favorite_profile 5 } 

proc streamline_profile_edit { slot } {

	if {[dui page current] != "off" && [dui page current] != "off_zoomed"} {
		return ""
	}

	set profiles [ifexists ::settings(favorite_profiles)]
	set name [dict get $profiles $slot name]
	if {$name == ""} {
		msg -ERROR "streamline_profile_edit: attempted to profile edit an empty button"
		return
	}

	#dict set profiles $slot name $::settings(profile_filename)
	#streamline_profile_select $slot

	set profile_type [::profile::fix_profile_type [ifexists ::settings(settings_profile_type)]]

	show_settings $profile_type
	fill_advanced_profile_steps_listbox

}

proc is_this_a_double_tap {context} {

	set is_double_tap 0
	if {[info exists ::double_tap_time_track($context)] == 1} {
		set elapsed_since_last_tap [expr {[clock milliseconds] - $::double_tap_time_track($context)}]
		if {$elapsed_since_last_tap < 500} {
			set is_double_tap 1
		}
	}
	set ::double_tap_time_track($context) [clock milliseconds]
	return $is_double_tap
}

proc store_profile_choice_to_profile_preset_button {} {
	#if {$::streamline_double_tap_empty_preset_button_previous_profile_filename != $::settings(profile_filename)} {
	#}
	save_favorite_profile $::streamline_double_tap_empty_preset_button_slot
}

proc streamline_profile_select { slot } {

	if {[dui page current] != "off" && [dui page current] != "off_zoomed"} {
		return ""
	}

	if {[is_this_a_double_tap "streamline_profile_select $slot"] == 1} {
		puts "ERROR DOUBLE TAP"
		say [translate {Edit}] $::settings(sound_button_out)
		#clear_favorite_profile $slot
		streamline_profile_edit $slot
		return ""
	}

	set profiles [ifexists ::settings(favorite_profiles)]


	set selected_profile [dict get $profiles $slot name]
	if {$selected_profile == ""} {
		# if the profile is empty then do nothing when someone taps on it
		return
	}

	#puts "ERROR select profile '[dict get $profiles $slot name]'"

	set result [select_profile $selected_profile]
	if {$result == "-1"} {
		# button points to a now deleted profile
		return
	}

	copy_settings_from_profile_to_streamline

	dict set profiles selected number $slot
	set ::settings(favorite_profiles) $profiles

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


proc clear_favorite_profile { slot } {
	puts "ERROR clear_favorite_profile $slot"
	set profiles [ifexists ::settings(favorite_profiles)]

	set selected_profile [dict get $profiles $slot name]
	if {$selected_profile == ""} {
		# empty button
		# john source of a potential bug where a button is cleared, need to investigate further 8/11/2024
		set ::streamline_double_tap_empty_preset_button_previous_profile_filename $::settings(profile_filename)
		set ::streamline_double_tap_empty_preset_button_slot $slot
		popup "Assign"
		show_settings "settings_1" "store_profile_choice_to_profile_preset_button"
		return
	}


	dict set profiles $slot name ""
	dict set profiles $slot title " "

	set ::settings(favorite_profiles) $profiles
	#refresh_favorite_profile_button_labels
	refresh_favorite_profile_button_labels
	save_settings
	popup [translate "Cleared"]
}


############################################################################################################################################################################################################



############################################################################################################################################################################################################
# Four GHC buttons on bottom right

if {$::settings(ghc_is_installed) == 0} { 

	# color of the button icons
	dui aspect set -theme streamline -type dbutton_symbol fill $::ghc_button_color

	# font size of the button icons
	dui aspect set -theme streamline -type dbutton_symbol font_size 24

	# position of the button icons
	dui aspect set -theme streamline -type dbutton_symbol pos ".50 .38"

	# rounded rectangle color 
	dui aspect set -theme streamline -type dbutton outline $::ghc_button_outline

	# inside button color
	dui aspect set -theme streamline -type dbutton fill $::ghc_button_background_color

	# font color
	dui aspect set -theme streamline -type dbutton label_fill $::ghc_button_color
	dui aspect set -theme streamline -type dbutton label1_fill $::ghc_button_color

	# font to use
	dui aspect set -theme streamline -type dbutton label_font Inter-Bold12 
	
	dui aspect set -theme streamline -type dbutton label1_font icomoon
	# rounded retangle radius
	dui aspect set -theme streamline -type dbutton radius 36

	# rounded retangle line width
	dui aspect set -theme streamline -type dbutton width 2 

	# button shape
	dui aspect set -theme streamline -type dbutton shape round_outline 

	# label position
	dui aspect set -theme streamline -type dbutton label_pos ".50 .75" 
	dui aspect set -theme streamline -type dbutton label1_pos ".50 .35" 


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

		dui add dbutton "off off_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 258 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 425 -tags espresso_btn -label1 $s1 -label [translate "Coffee"]   -command {say [translate {Espresso}] $::settings(sound_button_out); start_streamline_espresso; start_espresso} -tap_pad {40 16 30 16}
		dui add dbutton "off off_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 463 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 630 -tags water_btn -label1 $s3 -label [translate "Water"]   -command {say [translate {Water}] $::settings(sound_button_out); start_water}  -tap_pad {40 16 30 16}
		dui add dbutton "off off_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 668 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 835 -tags flush_btn -label1 $s4 -label [translate "Flush"]  -command {say [translate {Flush}] $::settings(sound_button_out); start_flush}  -tap_pad {40 16 30 16} 
		dui add dbutton "off off_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 873 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 1040 -tags steam_btn -label1 $s2 -label [translate "Steam"]   -command {say [translate {Steam}] $::settings(sound_button_out); start_steam}  -tap_pad {40 16 30 16}
		
		dui aspect set -theme streamline -type dbutton outline $::ghc_disabled_button_outline 
		dui aspect set -theme streamline -type dbutton fill $::ghc_disabled_button_fill 
		dui aspect set -theme streamline -type dbutton label_fill $::ghc_disabled_button_text 
		dui aspect set -theme streamline -type dbutton label1_fill $::ghc_disabled_button_text 
		dui aspect set -theme streamline -type dbutton_symbol fill $::ghc_disabled_button_text 
		dui add dbutton "espresso water steam hotwaterrinse espresso_zoomed steam_zoomed water_zoomed flush_zoomed hotwaterrinse_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 258 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 425 -tags espresso_btn_disabled -label1 $s1 -label [translate "Coffee"]   -tap_pad {40 16 30 16}
		dui add dbutton "espresso water steam hotwaterrinse espresso_zoomed steam_zoomed water_zoomed flush_zoomed hotwaterrinse_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 463 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 630 -tags water_btn_disabled -label1 $s3 -label [translate "Water"]   -tap_pad {40 16 30 16}
		dui add dbutton "espresso water steam hotwaterrinse espresso_zoomed steam_zoomed water_zoomed flush_zoomed hotwaterrinse_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 668 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 835 -tags flush_btn_disabled -label1 $s4 -label [translate "Flush"]   -tap_pad {40 16 30 16}
		dui add dbutton "espresso water steam hotwaterrinse espresso_zoomed steam_zoomed water_zoomed flush_zoomed hotwaterrinse_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 873 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 1040 -tags steam_btn_disabled -label1 $s2 -label [translate "Steam"]  -tap_pad {40 16 30 16}

		# stop button
		#dui add dbutton "espresso water steam hotwaterrinse" 2159 1216 2494 1566 -tags espresso_btn -symbol $s5  -label [translate "Stop"] -command {say [translate {Stop}] $::settings(sound_button_out); start_idle} 
		dui aspect set -theme streamline -type dbutton outline $::ghc_enabled_stop_button_outline
		dui aspect set -theme streamline -type dbutton fill $::ghc_enabled_stop_button_fill
		dui aspect set -theme streamline -type dbutton label_fill $::ghc_disabled_stop_button_text_color
		dui aspect set -theme streamline -type dbutton_symbol fill $::ghc_disabled_stop_button_text_color
		dui add dbutton "off off_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 1079 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 1246 -tags off_btn_disabled -symbol $s5  -label [translate "Stop"] -command {say [translate {Stop}] $::settings(sound_button_out); start_idle} -tap_pad {40 16 30 16}
		dui aspect set -theme streamline -type dbutton fill $::ghc_enabled_stop_button_fill_color
		dui aspect set -theme streamline -type dbutton label_fill $::ghc_enabled_stop_button_text_color
		dui aspect set -theme streamline -type dbutton_symbol fill $::ghc_enabled_stop_button_text_color
		dui add dbutton "espresso water steam hotwaterrinse espresso_zoomed steam_zoomed water_zoomed flush_zoomed hotwaterrinse_zoomed" [expr {2560 - $ghc_pos_pffset + 20}] 1079 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 1246 -tags off_btn -symbol $s5  -label [translate "Stop"] -command {say [translate {Stop}] $::settings(sound_button_out); start_idle} -tap_pad {40 16 30 16}
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
	if {$::streamline_steam_btn_mode == "time"} {

		set steams [ifexists ::settings(favorite_steams)]
		dict set steams $slot value $::settings(steam_timeout)
		set ::settings(favorite_steams) $steams	

	} else {

		set steams [ifexists ::settings(favorite_steamflow)]
		dict set steams $slot value $::settings(steam_flow)
		set ::settings(favorite_steamflow) $steams	

	}
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

	set ::streamline_favorite_temperature_buttons(label_1) [return_temperature_measurement_no_unit $t1 1]
	set ::streamline_favorite_temperature_buttons(label_2) [return_temperature_measurement_no_unit $t2 1]
	set ::streamline_favorite_temperature_buttons(label_3) [return_temperature_measurement_no_unit $t3 1]
	set ::streamline_favorite_temperature_buttons(label_4) [return_temperature_measurement_no_unit $t4 1]



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

	.can itemconfigure temp_btn_1 -fill $lb1c
	.can itemconfigure temp_btn_2 -fill $lb2c
	.can itemconfigure temp_btn_3 -fill $lb3c
	.can itemconfigure temp_btn_4 -fill $lb4c
}


set ::streamline_favorite_hw_buttons(label_1) ""
set ::streamline_favorite_hw_buttons(label_2) ""
set ::streamline_favorite_hw_buttons(label_3) ""
set ::streamline_favorite_hw_buttons(label_4) ""

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
		set ::streamline_favorite_hw_buttons(label_1) "[return_temperature_measurement_no_unit $bt1 1]"
		set ::streamline_favorite_hw_buttons(label_2) "[return_temperature_measurement_no_unit $bt2 1]"
		set ::streamline_favorite_hw_buttons(label_3) "[return_temperature_measurement_no_unit $bt3 1]"
		set ::streamline_favorite_hw_buttons(label_4) "[return_temperature_measurement_no_unit $bt4 1]"
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
refresh_favorite_hw_button_labels


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

	if {[dui page current] != "off" && [dui page current] != "steam"} {
		return ""
	}

	puts "streamline_steam_select { $slot } "

#	catch {

		if {$::streamline_steam_btn_mode == "time"} {
			# get the favoritae button values
			set steams [ifexists ::settings(favorite_steams)]

			# set the setting
			set ::settings(steam_timeout) [dict get $steams $slot value]

			# save the new selected button 
			dict set steams selected number $slot
			set ::settings(favorite_steams) $steams	
		} else {

			# get the favoritae button values
			set steamflow [ifexists ::settings(favorite_steamflow)]

			# set the setting
			set ::settings(steam_flow) [dict get $steamflow $slot value]

			# save the new selected button 
			dict set steamflow selected number $slot
			set ::settings(favorite_steamflow) $steamflow

		}

		


	#}

	save_profile_and_update_de1_soon	
	refresh_favorite_steam_button_labels
	streamline_steam_setting_change
	
	streamline_blink_rounded_setting "steam_setting_rectangle" "steam_label_1st"
	#streamline_blink_rounded_setting "steam_preset_rectangle_$slot" "steam_btn_$slot"
	#streamline_blink_rounded_setting "" "steam_btn_$slot"

}

	

proc streamline_set_drink_weight {desired_weight} {

	set ::settings(final_desired_shot_weight) $desired_weight
	set ::settings(final_desired_shot_weight_advanced) $desired_weight
	set ::settings(final_desired_shot_volume) $desired_weight
	set ::settings(final_desired_shot_volume_advanced) $desired_weight

	if {[::device::scale::expecting_present]} {
		# if they have a scale, then make the volumetric 10g more, so that it is there only as a safety in case the scale turns off
		#set ::settings(final_desired_shot_volume) [expr {$desired_weight + 10}]
		#set ::settings(final_desired_shot_volume_advanced)  [expr {$desired_weight + 10}]

		# john 6/3/2024 user feedback is that volumetric should be OFF if the scale is being used
		set ::settings(final_desired_shot_volume) 0
		set ::settings(final_desired_shot_volume_advanced) 0

	}

	#puts "ERROR expecting_present [::device::scale::expecting_present]"
}

proc streamline_dosebev_select { slot } {
	#puts "streamline_dosebev_select { $slot } "

	#catch {
		# get the favoritae button values
		set dosebevs [ifexists ::settings(favorite_dosebevs)]

		# set the setting
		set ::settings(grinder_dose_weight) [dict get $dosebevs $slot value]

		# setting the final weight is more complicated, as it is stored in a few different places depending on the profile
		set desired_weight [dict get $dosebevs $slot value2]
		streamline_set_drink_weight $desired_weight

		# save the new selected button 
		dict set dosebevs selected number $slot
		set ::settings(favorite_dosebevs) $dosebevs	
		save_profile_and_update_de1_soon	


	#}
	streamline_blink_rounded_setting "dose_setting_rectangle" "dose_label_1st"
	streamline_blink_rounded_setting "weight_setting_rectangle" "weight_label_1st"
	#streamline_blink_rounded_setting "dose_preset_rectangle_$slot" "dose_btn_$slot"\
	streamline_blink_rounded_setting "" "dose_btn_$slot"
	
	copy_streamline_settings_to_DYE
	refresh_favorite_dosebev_button_labels
}
refresh_favorite_dosebev_button_labels

proc streamline_flush_select { slot } {

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

proc streamline_blink_rounded_setting { rect {txt {}} } {
	.can itemconfigure $rect -fill $::blink_button_color
	after 400 .can itemconfigure $rect -fill $::box_color
	if {$txt != ""} {
		.can itemconfigure $txt -fill $::button_inverted_text_color
	
		after 400 .can itemconfigure $txt -fill $::plus_minus_value_text_color
	}
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
#refresh_favorite_hw_button_labels


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
#refresh_favorite_hw_button_labels

############################################################################################################################################################################################################
# the espresso chart

set ::state_change_dashes "[rescale_x_skin 16] [rescale_x_skin 16]"
set ::temp_goal_dashes "[rescale_x_skin 16] [rescale_x_skin 16]"
set ::pressure_goal_dashes "[rescale_x_skin 8] [rescale_x_skin 8]"
set ::flow_goal_dashes "[rescale_x_skin 8] [rescale_x_skin 8]"


set charts_width 1818
set charts_width_zoomed 2480
set charts_height 784
set charts_height_zoomed 1040

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

	# let BLT set the axis on its own, as BLT was refusing to dynamically change the axis numbers
	# -majorticks {0 30 60 90 120 150 180 210 240 270 300 330 360 390 420 450 480 510 540 570 600} 
	
	$widget axis configure x -color $::pressurelabelcolor -tickfont Inter-Regular10 -linewidth [rescale_x_skin 1] -subdivisions 5 


	if {[lsearch -exact $::zoomed_pages $which] != -1} {
		set mticks {1 2 3 4 5 6 7 8 9 10 11 12 13 14} 
		set max 14
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

			set_next_page water "water_zoomed"
			set_next_page flush "flush_zoomed"
			set_next_page hotwaterrinse "hotwaterrinse_zoomed"
			set_next_page steam "steam_zoomed"

			set_next_page off $::off_page
			set_next_page espresso $::espresso_page

			page_show off;

		} elseif {$::de1(current_context) == "off_zoomed"} {
			set ::off_page "off"
			set ::espresso_page "espresso"

			set_next_page water "water"
			set_next_page flush "flush"
			set_next_page hotwaterrinse "hotwaterrinse"
			set_next_page steam "steam"

			set_next_page off $::off_page
			set_next_page espresso $::espresso_page
			page_show off;

		} elseif {$::de1(current_context) == "espresso"} {
			set ::off_page "off_zoomed"
			set ::espresso_page "espresso_zoomed"

			set_next_page water "water_zoomed"
			set_next_page flush "flush_zoomed"
			set_next_page hotwaterrinse "hotwaterrinse_zoomed"
			set_next_page steam "steam_zoomed"

			set_next_page off $::off_page
			set_next_page espresso $::espresso_page
			page_show espresso;

		} elseif {$::de1(current_context) == "hotwaterrinse"} {
			set ::off_page "off_zoomed"
			set ::espresso_page "espresso_zoomed"

			set_next_page water "water_zoomed"
			set_next_page flush "flush_zoomed"
			set_next_page hotwaterrinse "hotwaterrinse_zoomed"
			set_next_page steam "steam_zoomed"

			set_next_page off $::off_page
			set_next_page espresso $::espresso_page
			page_show hotwaterrinse;

		} elseif {$::de1(current_context) == "water"} {
			set ::off_page "off_zoomed"
			set ::espresso_page "espresso_zoomed"

			set_next_page water "water_zoomed"
			set_next_page flush "flush_zoomed"
			set_next_page hotwaterrinse "hotwaterrinse_zoomed"
			set_next_page steam "steam_zoomed"

			set_next_page off $::off_page
			set_next_page espresso $::espresso_page
			page_show water;

		} elseif {$::de1(current_context) == "steam"} {
			set ::off_page "off_zoomed"
			set ::espresso_page "espresso_zoomed"

			set_next_page water "water_zoomed"
			set_next_page flush "flush_zoomed"
			set_next_page hotwaterrinse "hotwaterrinse_zoomed"
			set_next_page steam "steam_zoomed"

			set_next_page off $::off_page
			set_next_page espresso $::espresso_page
			page_show steam;

		} elseif {$::de1(current_context) == "espresso_zoomed"} {
			set ::off_page "off"
			set ::espresso_page "espresso"
			set_next_page off $::off_page
			set_next_page espresso $::espresso_page

			set_next_page water "water"
			set_next_page flush "flush"
			set_next_page hotwaterrinse "hotwaterrinse"
			set_next_page steam "steam"

			page_show espresso;
		
		} elseif {$::de1(current_context) == "water_zoomed"} {
			set ::off_page "off"
			set ::espresso_page "espresso"
			set_next_page off $::off_page
			set_next_page espresso $::espresso_page

			set_next_page water "water"
			set_next_page flush "flush"
			set_next_page hotwaterrinse "hotwaterrinse"
			set_next_page steam "steam"

			page_show water;

		} elseif {$::de1(current_context) == "steam_zoomed"} {
			set ::off_page "off"
			set ::espresso_page "espresso"
			set_next_page off $::off_page
			set_next_page espresso $::espresso_page

			set_next_page water "water"
			set_next_page flush "flush"
			set_next_page hotwaterrinse "hotwaterrinse"
			set_next_page steam "steam"

			page_show steam;

		} elseif {$::de1(current_context) == "hotwaterrinse_zoomed"} {
			set ::off_page "off"
			set ::espresso_page "espresso"
			set_next_page off $::off_page
			set_next_page espresso $::espresso_page

			set_next_page water "water"
			set_next_page flush "flush"
			set_next_page hotwaterrinse "hotwaterrinse"
			set_next_page steam "steam"

			page_show hotwaterrinse;
		}
	}	
}


add_de1_widget $::pages graph 692 458 { streamline_graph_smarts $widget } -plotbackground $::chart_background -width [rescale_x_skin [expr {$charts_width - $ghc_pos_pffset}]] -height [rescale_y_skin $charts_height] -borderwidth 1 -background $::chart_background -plotrelief flat -plotpady 10 -plotpadx 10  
add_de1_widget $::zoomed_pages graph 22 520 { streamline_graph_smarts $widget "off_zoomed" } -plotbackground $::chart_background -width [rescale_x_skin [expr {$charts_width_zoomed - $ghc_pos_pffset}]] -height [rescale_y_skin $charts_height_zoomed] -borderwidth 1 -background $::chart_background -plotrelief flat -plotpady 10 -plotpadx 10  

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


proc streamline_load_history_shot {current_shot_filename} {

	set ::streamline_history_text_label [translate "HISTORY"] 

	if {$::streamline_history_file_selected_number == [expr {[llength $::streamline_history_files] -1}]} {
		set ::streamline_history_text_label [translate "NEWEST"] 
	} elseif {$::streamline_history_file_selected_number == 0} {
		set ::streamline_history_text_label [translate "OLDEST"] 
	}

	#puts "ERROR streamline_load_history_shot"

	catch {
		array set past_shot_array [encoding convertfrom utf-8 [read_file "[homedir]/history/$current_shot_filename"]]
	}

	if {[ifexists past_shot_array(settings)] == ""} {
		# corrupt hstorical shot
		msg -ERROR "streamline_load_history_shot: '$current_shot_filename' is corrupted"
		return
	}

	array set profile_settings [ifexists past_shot_array(settings)]

	
	catch {
		# replace the final weight in the list, with the final drink weight that was calculated a few seconds later
		lset past_shot_array(espresso_weight) end $profile_settings(drink_weight)
	}

	espresso_elapsed clear

	# this trims off timed part of the shot that had no pressure data, so we don't want to chart that.  Shouldn't normally happen, unless the shot end was not properly recorded.
	espresso_elapsed set [lrange [ifexists past_shot_array(espresso_elapsed)] 0 [llength [ifexists past_shot_array(espresso_pressure)]]]
	# espresso_elapsed set [ifexists past_shot_array(espresso_elapsed)]

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

	update_data_card past_shot_array profile_settings
}

proc track_peak_low { state espresso_pressure espresso_flow espresso_temperature_basket } {


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

}


proc update_data_card { arrname settingsarr } {

	upvar $arrname past_shot_array
	upvar $settingsarr profile_settings

	#puts "ERROR el: [ifexists past_shot_array(espresso_elapsed)]"

	#puts "profile_data: [array get past_shot_array]"
	#array set profile_data [ifexists past_shot_array(settings)]

	set ::streamline_current_history_profile_name [ifexists profile_settings(profile_title)]

	#####################################
	set third_line_parts ""

	if {[ifexists profile_settings(grinder_dose_weight)] != "" && [ifexists profile_settings(grinder_dose_weight)] != "0"} {
		lappend third_line_parts "[translate "In"] [return_weight_measurement_grams [round_one_digits_or_integer_if_needed $profile_settings(grinder_dose_weight)]]"
	}
	
	if {[ifexists profile_settings(grinder_setting)] != "" && [ifexists profile_settings(grinder_setting)] != "0"} {
		lappend third_line_parts "[translate "Grind"] [round_one_digits_or_integer_if_needed $profile_settings(grinder_setting)]"
	}

	set ::streamline_current_history_third_line [join $third_line_parts "  |  "]
	#####################################
	

	set profile_type [::profile::fix_profile_type [ifexists profile_settings(settings_profile_type)]]
	#puts "profile_type: $profile_type"

	streamline_adjust_chart_x_axis


	if { $profile_type eq "settings_2a" || $profile_type eq "settings_2b" } {
		set preinfusion_end_step 1

		if {[ifexists profile_settings(insert_preinfusion_pause)] == 1} {
			set preinfusion_end_step 2
		}

		if {[ifexists profile_settings(espresso_temperature_steps_enabled)] == 1} {
			incr preinfusion_end_step
		}
		

	} else {
		set preinfusion_end_step [ifexists profile_settings(final_desired_shot_volume_advanced_count_start)]

        if {[ifexists profile_settings(espresso_temperature_steps_enabled)] == 1} {
        	incr preinfusion_end_step
        }

	}

	#puts "preinfusion_end_step: $preinfusion_end_step"
	
	set i 1

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

	set espresso_weight 0
	set espresso_water_dispensed 0
	

	set c 0
	foreach t [ifexists past_shot_array(espresso_elapsed)] {

		incr c

		if {[lindex $past_shot_array(espresso_pressure) $i] == ""} {
			# ignore end of shot data where no pressure is being sent
			break
		}

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
			# skip shots, but this is disabled for now as should no longer be needed thanks to check for data above
			# continue
		}

		set ::streamline_${state}_temp_end $espresso_temperature_basket
		set ::streamline_${state}_flow_end $espresso_flow
		set ::streamline_${state}_pressure_end $espresso_pressure

		track_peak_low $state $espresso_pressure $espresso_flow $espresso_temperature_basket

		set ::streamline_${state}_time $t
		if {$espresso_weight > 0} {
			set ::streamline_${state}_weight $espresso_weight
		}
		set ::streamline_${state}_volume [expr {$espresso_water_dispensed * 10}]
		


		if {$state_change != $espresso_state_change} {

			if {$stepnum == 0} {
				set ::streamline_preinfusion_temp_start $espresso_temperature_basket
				set ::streamline_preinfusion_flow_start $espresso_flow
				set ::streamline_preinfusion_pressure_start $espresso_pressure
			}

			incr stepnum
			set state_change $espresso_state_change

			if {$stepnum > $preinfusion_end_step} {

				if {$state != "extraction"} {
					set ::streamline_extraction_temp_start $espresso_temperature_basket
					set ::streamline_extraction_flow_start $espresso_flow
					set ::streamline_extraction_pressure_start $espresso_pressure
				}

				set state "extraction"

				track_peak_low $state $espresso_pressure $espresso_flow $espresso_temperature_basket
			}


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
			set ::streamline_preinfusion_temp [round_to_integer $::streamline_preinfusion_temp_high]
		} else {
			set ::streamline_preinfusion_temp "[round_to_integer $::streamline_preinfusion_temp_low]$arrow[round_to_integer $::streamline_preinfusion_temp_high]"
		}

		if {$::streamline_extraction_temp_high == 0} {
			# no label
			set ::streamline_extraction_temp ""
		} elseif {[round_to_integer $::streamline_extraction_temp_low] == [round_to_integer $::streamline_extraction_temp_high]} {
			set ::streamline_extraction_temp [string tolower [round_to_integer $::streamline_extraction_temp_high]
		} else {
			set ::streamline_extraction_temp "[string tolower [round_to_integer $::streamline_extraction_temp_low]]$arrow[round_to_integer $::streamline_extraction_temp_high]"
		}



		# [translate "bar"]
		set ::streamline_preinfusion_low_peak_pressure_label "[round_one_digits_or_integer_if_needed $::streamline_preinfusion_low_pressure]$arrow[round_one_digits_or_integer_if_needed $::streamline_preinfusion_peak_pressure]"
		set ::streamline_extraction_low_peak_pressure_label "[round_one_digits_or_integer_if_needed $::streamline_extraction_low_pressure]$arrow[round_one_digits_or_integer_if_needed $::streamline_extraction_peak_pressure]"

		#[translate "ml/s"]
		set ::streamline_preinfusion_low_peak_flow_label "[round_one_digits_or_integer_if_needed $::streamline_preinfusion_low_flow]$arrow[round_one_digits_or_integer_if_needed $::streamline_preinfusion_peak_flow]"
		set ::streamline_extraction_low_peak_flow_label "[round_one_digits_or_integer_if_needed $::streamline_extraction_low_flow]$arrow[round_one_digits_or_integer_if_needed $::streamline_extraction_peak_flow]"

	} else {

		# show start/end numbers

		if {$::streamline_preinfusion_temp_end == 0} {
			# no label
		} elseif {[round_to_integer $::streamline_preinfusion_temp_start] == [round_to_integer $::streamline_preinfusion_temp_end]} {
			set ::streamline_preinfusion_temp [round_to_integer $::streamline_preinfusion_temp_end]
		} else {
			set ::streamline_preinfusion_temp "[string tolower [round_to_integer $::streamline_preinfusion_temp_start]]$arrow[round_to_integer $::streamline_preinfusion_temp_end]"
		}

		if {$::streamline_extraction_temp_end == 0} {
			# no label
			set ::streamline_extraction_temp ""
		} elseif {[round_to_integer $::streamline_extraction_temp_end] == [round_to_integer $::streamline_extraction_temp_end]} {
			set ::streamline_extraction_temp [round_to_integer $::streamline_extraction_temp_end]
		} else {
			set ::streamline_extraction_temp "[string tolower [round_to_integer $::streamline_extraction_temp_end]]$arrow[round_to_integer $::streamline_extraction_temp_end]"
		}



		# [translate "bar"]
		set ::streamline_preinfusion_low_peak_pressure_label "[round_one_digits_or_integer_if_needed $::streamline_preinfusion_pressure_start]$arrow[round_one_digits_or_integer_if_needed $::streamline_preinfusion_pressure_end]"
		set ::streamline_extraction_low_peak_pressure_label "[round_one_digits_or_integer_if_needed $::streamline_extraction_pressure_start]$arrow[round_one_digits_or_integer_if_needed $::streamline_extraction_pressure_end]"

		# start/peak/end, if different from start or end
		if {[round_one_digits_or_integer_if_needed $::streamline_preinfusion_peak_pressure] != [round_one_digits_or_integer_if_needed $::streamline_preinfusion_pressure_start] && [round_one_digits_or_integer_if_needed $::streamline_preinfusion_peak_pressure] != [round_one_digits_or_integer_if_needed $::streamline_preinfusion_pressure_end]} {
			set ::streamline_preinfusion_low_peak_pressure_label "[round_one_digits_or_integer_if_needed $::streamline_preinfusion_pressure_start]$arrow[round_one_digits_or_integer_if_needed $::streamline_preinfusion_peak_pressure]$arrow[round_one_digits_or_integer_if_needed $::streamline_preinfusion_pressure_end]"
		}
		if {[round_one_digits_or_integer_if_needed $::streamline_extraction_peak_pressure] != [round_one_digits_or_integer_if_needed $::streamline_extraction_pressure_start] && [round_one_digits_or_integer_if_needed $::streamline_extraction_peak_pressure] != [round_one_digits_or_integer_if_needed $::streamline_extraction_pressure_end]} {
			set ::streamline_extraction_low_peak_pressure_label "[round_one_digits_or_integer_if_needed $::streamline_extraction_pressure_start]$arrow[round_one_digits_or_integer_if_needed $::streamline_extraction_peak_pressure]$arrow[round_one_digits_or_integer_if_needed $::streamline_extraction_pressure_end]"
		}

		# [translate "ml/s"]
		set ::streamline_preinfusion_low_peak_flow_label "[round_one_digits_or_integer_if_needed $::streamline_preinfusion_flow_start]$arrow[round_one_digits_or_integer_if_needed $::streamline_preinfusion_flow_end]"
		set ::streamline_extraction_low_peak_flow_label "[round_one_digits_or_integer_if_needed $::streamline_extraction_flow_start]$arrow[round_one_digits_or_integer_if_needed $::streamline_extraction_flow_end]"
		if {[round_one_digits_or_integer_if_needed $::streamline_preinfusion_peak_flow] != [round_one_digits_or_integer_if_needed $::streamline_preinfusion_flow_start] && [round_one_digits_or_integer_if_needed $::streamline_preinfusion_peak_flow] != [round_one_digits_or_integer_if_needed $::streamline_preinfusion_flow_end]} {
			set ::streamline_preinfusion_low_peak_flow_label "[round_one_digits_or_integer_if_needed $::streamline_preinfusion_flow_start]$arrow[round_one_digits_or_integer_if_needed $::streamline_preinfusion_peak_flow]$arrow[round_one_digits_or_integer_if_needed $::streamline_preinfusion_flow_end]"
		}
		if {[round_one_digits_or_integer_if_needed $::streamline_extraction_peak_flow] != [round_one_digits_or_integer_if_needed $::streamline_extraction_flow_start] && [round_one_digits_or_integer_if_needed $::streamline_extraction_peak_flow] != [round_one_digits_or_integer_if_needed $::streamline_extraction_flow_end]} {
			set ::streamline_extraction_low_peak_flow_label "[round_one_digits_or_integer_if_needed $::streamline_extraction_flow_start]$arrow[round_one_digits_or_integer_if_needed $::streamline_extraction_peak_flow]$arrow[round_one_digits_or_integer_if_needed $::streamline_extraction_flow_end]"
		}

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

			#set ::streamline_shot_time ""
			#set ::streamline_shot_weight ""
			#set ::streamline_shot_volume ""

			set ::streamline_extraction_low_peak_pressure_label ""
			set ::streamline_extraction_low_peak_flow_label ""

			set ::streamline_preinfusion_low_peak_pressure_label "[round_one_digits $::de1(pressure)]"
			set ::streamline_preinfusion_low_peak_flow_label "[round_to_one_digits $::de1(flow)]"
			#set ::streamline_preinfusion_low_peak_pressure_label "[round_one_digits $::de1(pressure)] [translate "bar"]"
			#set ::streamline_preinfusion_low_peak_flow_label "[round_to_one_digits $::de1(flow)] [translate "ml/s"]"
			set ::streamline_preinfusion_temp [return_temperature_measurement_no_unit $::de1(head_temperature)]

		} else {
			#set ::streamline_shot_time ""
			#set ::streamline_shot_weight ""
			#set ::streamline_shot_volume ""

			#set ::streamline_extraction_low_peak_pressure_label "[round_one_digits $::de1(pressure)] [translate "bar"]"
			#set ::streamline_extraction_low_peak_flow_label "[round_to_one_digits $::de1(flow)] [translate "ml/s"]"
			set ::streamline_extraction_low_peak_pressure_label "[round_one_digits $::de1(pressure)]"
			set ::streamline_extraction_low_peak_flow_label "[round_to_one_digits $::de1(flow)]"
			set ::streamline_extraction_temp [return_temperature_measurement_no_unit $::de1(head_temperature)]

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

	if {[info exists ::de1(streamline_shot_in_progress)] == 1} {
		popup [translate "Wait until this shot is saved"]
		return
	}

	set ::streamline_history_file_selected_number [expr {$::streamline_history_file_selected_number	 - 1}]
	if {$::streamline_history_file_selected_number < 0} {
		set ::streamline_history_file_selected_number [expr {[llength $::streamline_history_files] -1}]
	}
	streamline_load_currently_selected_history_shot
	streamline_history_profile_btns_refresh
}

proc streamline_history_profile_fwd { {destination {}} } {

	if {[info exists ::de1(streamline_shot_in_progress)] == 1} {
		popup [translate "Wait until this shot is saved"]
		return
	}

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

# after the shot has ended (finished)
::de1::event::listener::after_flow_complete_add [lambda {event_dict} { streamline_shot_ended } ]
proc streamline_shot_ended  {} {
	if {[ifexists ::settings(history_saved_shot_filename)] != ""} {		

		# when saving the shot, update the onscreen weight with what the final weight on the scale was.

		lappend ::streamline_history_files [file tail $::settings(history_saved_shot_filename)]
		set ::streamline_history_file_selected_number [expr {[llength $::streamline_history_files] - 1}]

		streamline_history_profile_fwd 1

	}

	# reset the shot frame description to blank so that gui doesn't temporarily show it when the next shot starts
	set ::settings(current_frame_description) ""

	unset -nocomplain ::de1(streamline_shot_in_progress)
}

############################################################################################################################################################################################################
# green/red/grey progress bar
set ::streamline_global(status_msg_progress_red) ""
set ::streamline_global(status_msg_progress_green) ""
set ::streamline_global(status_msg_progress_grey) ""

#set ::streamline_progress_line [add_de1_rich_text "off off_zoomed" [expr {2490 - $ghc_pos_pffset}] 236 right 0 1 45 $::background_color [list \
#	[list -text {$::streamline_global(status_msg_progress_green)}  -font "Inter-Regular6" -foreground $::progress_bar_green  ] \
#	[list -text {$::streamline_global(status_msg_progress_red)}  -font "Inter-Regular6" -foreground $::progress_bar_red  ] \
#	[list -text {$::streamline_global(status_msg_progress_grey)}  -font "Inter-Regular6" -foreground $::progress_bar_grey ] \
#]]
############################################################################################################################################################################################################

proc flash_dataentry_button {buttontag} {
	.can itemconfigure ${buttontag}-btn -fill $::dataentry_button_color_flash1
	after 40 .can itemconfigure ${buttontag}-btn -fill $::dataentry_button_color_flash2
	after 200 .can itemconfigure ${buttontag}-btn -fill $::dataentry_button_color_flash1
	after 280 .can itemconfigure ${buttontag}-btn -fill $::dataentry_button_color
}


proc streamline_entry_page_button {btn} {

	say [translate {Tap}] $::settings(sound_button_out); 

	set current $::streamline_data_entry_page_value 
	if {$btn == "0" || $btn == "1" || $btn == "2" || $btn == "3" || $btn == "4" || $btn == "5" || $btn == "6" || $btn == "7" || $btn == "8" || $btn == "9"} {

		if {$::streamline_data_entry_page_typing_started == 0} {
			# on first typing, replace the current value if they type 0-9
			set ::streamline_data_entry_page_typing_started 1
			set current ""
		}
		append current $btn
		flash_dataentry_button "streamline_plus_grind_btn${btn}"

	} elseif {$::streamline_entry_integer_only != 1 && $btn == "." && [string first "." $::streamline_data_entry_page_value] == -1} {
		set ::streamline_data_entry_page_typing_started 1
		append current $btn
		flash_dataentry_button "streamline_plus_grind_btn_period"
	} elseif {$btn == "c"} {
		set ::streamline_data_entry_page_typing_started 1
		set current ""
		flash_dataentry_button "streamline_plus_grind_btn_back"
	} elseif {$btn == "<" && $::streamline_data_entry_page_value != ""} {
		set ::streamline_data_entry_page_typing_started 1
		set current [string range $::streamline_data_entry_page_value 0 end-1]
		flash_dataentry_button "streamline_plus_grind_btn_back"
	}

	if {$::streamline_entry_max != "" && $current != ""} {
		if {$current > $::streamline_entry_max && $::streamline_entry_max != ""} {

			.can itemconfigure streamline_entry_page_box -outline $::ghc_enabled_stop_button_fill_color
			.can itemconfigure streamline_entry_hint -fill $::ghc_enabled_stop_button_fill_color
			after 1000 .can itemconfigure streamline_entry_page_box -outline $::datacard_entry_box_color
			after 1000 .can itemconfigure streamline_entry_hint -fill $::data_card_text_color
			return
		}
	}

	#if {$::streamline_entry_min != "" && $current != ""} {
	#	if {$current < $::streamline_entry_min && $::streamline_entry_min != ""} {
	#		set ::streamline_entry_hint ""
	#		after 300 [list set ::streamline_entry_hint [streamline_entry_hint]]
	#		return
	#	}
	#}

	set parts [split $current {.}]
	if {[llength $parts] > 1} {
		if {[string length [lindex $parts 1]] > 1} {
			# don't allow more than 1 decimal point of precision in data entry
			return
		}
	}

	if {[string length $current] > 7} {
		return
	}

	set ::streamline_data_entry_page_value $current
}

proc streamline_entry_hint {} {
	if {$::streamline_entry_min == "" || $::streamline_entry_max == ""} {
		return ""
	}
	return "[translate {Input a value between}] $::streamline_entry_min-$::streamline_entry_max$::streamline_entry_value_suffix"
}

# callback_success callback_failure
proc ask_for_data_entry_number {title current_value varname_to_store_in value_suffix {integer_only 0} {min {}} {max {}} {callbacks {}} } {

	set ::streamline_data_entry_page_title $title
	set ::streamline_data_entry_page_value $current_value
	if {$integer_only == 1} {
		set ::streamline_data_entry_page_value [round_to_integer $current_value]
	}
	set ::streamline_data_entry_page_typing_started 0
	#set ::streamline_data_entry_page_value ""

	set ::streamline_entry_return_to_page [dui page current]
	set ::streamline_entry_save_to_varname $varname_to_store_in
	set ::streamline_entry_integer_only $integer_only

	set ::streamline_entry_value_suffix $value_suffix

	set ::streamline_entry_previous [::dui::pages::dui_number_editor::get_previous_values $varname_to_store_in]

	set ::streamline_entry_callbacks $callbacks

	set ::streamline_entry_max $max
	set ::streamline_entry_min $min	

	if {$integer_only == 1} {
		page_show streamline_entry_integer
	} else {
		page_show streamline_entry
	}

	#####
	# hide unset previous-value buttons
	set hidden_count 0
	for {set x 0} {$x < 4} { incr x} {
		if {[lindex $::streamline_entry_previous $x] != ""} {
			#.can itemconfigure streamline_data_entry_prev_[expr {1+$x}]-btn -state normal
			#.can itemconfigure streamline_data_entry_prev_[expr {1+$x}]-out -state normal
			dui item show [list streamline_entry_integer streamline_entry] streamline_data_entry_prev_[expr {1+$x}]*
			#dui item show [list streamline_entry_integer streamline_entry] streamline_data_entry_prev_[expr {1+$x}]

		} else {
			#.can itemconfigure streamline_data_entry_prev_[expr {1+$x}]-btn -state hidden
			#.can itemconfigure streamline_data_entry_prev_[expr {1+$x}]-out -state hidden
			dui item hide [list streamline_entry_integer streamline_entry] streamline_data_entry_prev_[expr {1+$x}]*
			#dui item hide [list streamline_entry_integer streamline_entry] streamline_data_entry_prev_[expr {1+$x}]-out
			incr hidden_count
		}		
	}
	if {$hidden_count == 4} {
		#.can itemconfigure data_card_prev_values_label -state hidden
		dui item hide [list streamline_entry_integer streamline_entry] data_card_prev_values_label
	} else {
		dui item show [list streamline_entry_integer streamline_entry] data_card_prev_values_label
	}
}

# save this value if it's valid
proc streamline_entry_save_value {} {

	say [translate {Save}] $::settings(sound_button_out); 

	if {$::streamline_data_entry_page_value == ""} {
		return
	}

	if {$::streamline_entry_min != ""} {
		if {$::streamline_data_entry_page_value < $::streamline_entry_min} {
			return
		}
	}

	if {$::streamline_entry_max != ""} {
		if {$::streamline_data_entry_page_value > $::streamline_entry_max} {
			return
		}
	}

 	set $::streamline_entry_save_to_varname $::streamline_data_entry_page_value

	::dui::pages::dui_number_editor::save_previous_value "" $::streamline_entry_save_to_varname $::streamline_data_entry_page_value

 	foreach callback $::streamline_entry_callbacks {
 		eval $callback
 	}
}

# adds the new value to the saved previous values and then calls the next proc to handle the new value
proc stream_data_entry_save_previous_value { context newvalue } {

	if {$newvalue != ""} {
		array set number_editor_previous_values $::settings(dui_number_editor_previous_values)
		set existing [ifexists number_editor_previous_values($context)]
		lappend existing $newvalue
		
		set number_editor_previous_values($context) $existing
		set ::settings(dui_number_editor_previous_values) [array get number_editor_previous_values]
		save_settings

	} else {
		# don't let dui put the invalid value into the variable
		msg -INFO "Invalid data-entry value of '$newvalue' detected ($context)"
	}

}

proc streamline_data_entry_page_value_formatted {} {
	if {$::streamline_data_entry_page_value == ""} {
		return ""
	}
	return "$::streamline_data_entry_page_value$::streamline_entry_value_suffix"
}

proc streamline_previous {num} {
	say [translate {Preset}] $::settings(sound_button_out); 

	set ::streamline_data_entry_page_value [lindex $::streamline_entry_previous $num]
	streamline_entry_save_value 
	page_show $::streamline_entry_return_to_page
}

proc streamline_entry_page_setup {} {

	set ::streamline_entry_return_to_page "off"
	set ::streamline_entry_save_to_varname "::none"
	set ::streamline_entry_integer_only 0
	set ::streamline_entry_value_suffix ""
	set ::streamline_entry_previous ""

	set ::streamline_entry_max 15
	set ::streamline_entry_min 1

	dui page add "streamline_entry" -bg_color $::data_card_background_color
	dui page add "streamline_entry_integer" -bg_color $::data_card_background_color

	##add_de1_page "streamline_entry streamline_entry_integer" "datadark.png"
	#add_de1_page "streamline_entry streamline_entry_integer" "datalight.png"

	set ::streamline_data_entry_page_title [subst "DOSE"]
	add_de1_variable "streamline_entry streamline_entry_integer" 100 96 -justify left -anchor "nw" -font "Inter-HeavyBold40" -fill $::data_card_text_color -width [rescale_x_skin 1200] -textvariable {$::streamline_data_entry_page_title} 

	add_de1_variable "streamline_entry streamline_entry_integer" 646 430 -justify center -anchor "center" -font "Inter-Regular20" -fill $::data_card_text_color -tags streamline_entry_hint -width [rescale_x_skin 1200] -textvariable { [streamline_entry_hint] } 

	add_de1_text "streamline_entry streamline_entry_integer" 636 990 -justify center -anchor "center" -font "Inter-Regular20" -fill $::data_card_text_color -tags data_card_prev_values_label -width [rescale_x_skin 1200] -text [translate "Previous Values"]

	# box where number appears
	dui add canvas_item rect "streamline_entry streamline_entry_integer" 345 494 949 738  -fill $::box_color -width 4 -outline $::datacard_entry_box_color -fill $::background_color -tags streamline_entry_page_box

	set ::streamline_data_entry_page_value ""
	add_de1_variable "streamline_entry streamline_entry_integer" 648 616 -justify center -anchor "center" -font "Inter-HeavyBold50" -fill $::data_card_text_color -width [rescale_x_skin 1200] -textvariable {[streamline_data_entry_page_value_formatted]} 

	# line below entry box
	streamline_rectangle "streamline_entry streamline_entry_integer" 150 854 1150 858 $::datacard_box_line_color $::plus_minus_flash_off_color_disabled

	# box line below entry title
	streamline_rectangle "streamline_entry streamline_entry_integer" 104 298 2464 302 $::datacard_box_line_color $::plus_minus_flash_off_color_disabled
	streamline_rectangle "streamline_entry streamline_entry_integer" 1278 302 1282 1600 $::datacard_box_line_color $::plus_minus_flash_off_color_disabled

	# rounded rectangle color 
	dui aspect set -theme streamline -type dbutton outline $::dataentry_button_color

	# inside button color
	dui aspect set -theme streamline -type dbutton fill $::dataentry_button_color

	# font color
	dui aspect set -theme streamline -type dbutton label_fill $::datacard_number_text_color

	# font to use
	dui aspect set -theme streamline -type dbutton label_font Inter-Bold40

	# rounded retangle radius
	dui aspect set -theme streamline -type dbutton radius 200

	# rounded retangle line width
	dui aspect set -theme streamline -type dbutton width 2 

	# button shape
	dui aspect set -theme streamline -type dbutton shape round_outline 

	# label position is higher because we're using a _ as a minus symbol
	dui aspect set -theme streamline -type dbutton label_pos ".50 .5" 


	set entryheight 200
	set entrywidth 300
	
	set row1 448
	set row2 718
	set row3 987
	set row4 1259
	set col1 1423
	set col2 1770
	set col3 2121

	dui add dbutton "streamline_entry streamline_entry_integer" $col1 $row1 [expr {$col1+$entrywidth}] [expr {$row1+$entryheight}] -tags streamline_plus_grind_btn1 -label "1"  -command { streamline_entry_page_button 1 }
	dui add dbutton "streamline_entry streamline_entry_integer" $col2 $row1 [expr {$col2+$entrywidth}] [expr {$row1+$entryheight}] -tags streamline_plus_grind_btn2 -label "2"  -command { streamline_entry_page_button 2 }
	dui add dbutton "streamline_entry streamline_entry_integer" $col3 $row1 [expr {$col3+$entrywidth}] [expr {$row1+$entryheight}] -tags streamline_plus_grind_btn3 -label "3"  -command { streamline_entry_page_button 3 }

	dui add dbutton "streamline_entry streamline_entry_integer" $col1 $row2 [expr {$col1+$entrywidth}] [expr {$row2+$entryheight}] -tags streamline_plus_grind_btn4 -label "4"  -command { streamline_entry_page_button 4 }
	dui add dbutton "streamline_entry streamline_entry_integer" $col2 $row2 [expr {$col2+$entrywidth}] [expr {$row2+$entryheight}] -tags streamline_plus_grind_btn5 -label "5"  -command { streamline_entry_page_button 5 }
	dui add dbutton "streamline_entry streamline_entry_integer" $col3 $row2 [expr {$col3+$entrywidth}] [expr {$row2+$entryheight}] -tags streamline_plus_grind_btn6 -label "6"  -command { streamline_entry_page_button 6 } 

	dui add dbutton "streamline_entry streamline_entry_integer" $col1 $row3 [expr {$col1+$entrywidth}] [expr {$row3+$entryheight}] -tags streamline_plus_grind_btn7 -label "7"  -command { streamline_entry_page_button 7 } 
	dui add dbutton "streamline_entry streamline_entry_integer" $col2 $row3 [expr {$col2+$entrywidth}] [expr {$row3+$entryheight}] -tags streamline_plus_grind_btn8 -label "8"  -command { streamline_entry_page_button 8 } 
	dui add dbutton "streamline_entry streamline_entry_integer" $col3 $row3 [expr {$col3+$entrywidth}] [expr {$row3+$entryheight}] -tags streamline_plus_grind_btn9 -label "9"  -command { streamline_entry_page_button 9 } 


	dui add dbutton "streamline_entry" $col2 $row4 [expr {$col2+$entrywidth}] [expr {$row4+$entryheight}] -tags streamline_plus_grind_btn0 -label "0"  -command { streamline_entry_page_button 0 } 
	dui add dbutton "streamline_entry" $col1 $row4 [expr {$col1+$entrywidth}] [expr {$row4+$entryheight}] -tags streamline_plus_grind_btn_period -label "."  -command { streamline_entry_page_button . } 

	dui add dbutton "streamline_entry_integer" $col1 $row4 [expr {$col2+$entrywidth}] [expr {$row4+$entryheight}] -tags streamline_plus_grind_btn0 -label "0"  -command { streamline_entry_page_button 0 } 

	# font to use
	dui aspect set -theme streamline -type dbutton label_font Inter-Bold30
	dui add dbutton "streamline_entry streamline_entry_integer" $col3 $row4 [expr {$col3+$entrywidth}] [expr {$row4+$entryheight}] -tags streamline_plus_grind_btn_back -label "⌫"  -command { streamline_entry_page_button < }  -longpress_threshold $::streamline_longpress_threshold -longpress_cmd { streamline_entry_page_button c } 


	# font to use
	dui aspect set -theme streamline -type dbutton label_font Inter-HeavyBold30

	
	dui aspect set -theme streamline -type dbutton fill $::data_card_background_color
	dui aspect set -theme streamline -type dbutton outline $::data_card_background_color
	dui aspect set -theme streamline -type dbutton width 0

	set ::streamline_data_entry_label_cancel [subst "CANCEL"]
	dui add dbutton "streamline_entry streamline_entry_integer" 1640 65 1850 225 -tags streamline_plus_grind_btn_cancel -label $::streamline_data_entry_label_cancel  -command { page_show $::streamline_entry_return_to_page } 


	# font color
	dui aspect set -theme streamline -type dbutton fill $::data_card_confirm_button
	dui aspect set -theme streamline -type dbutton outline $::data_card_confirm_button
	dui aspect set -theme streamline -type dbutton label_fill $::data_card_confirm_button_text
	set ::streamline_data_entry_label_confirm [subst "CONFIRM"]
	dui add dbutton "streamline_entry streamline_entry_integer" 1970 65 2460 225 -tags streamline_plus_grind_btn_confirm -label $::streamline_data_entry_label_confirm  -command { streamline_entry_save_value ; page_show $::streamline_entry_return_to_page } 


	# inside button color
	dui aspect set -theme streamline -type dbutton fill $::data_card_previous_color
	dui aspect set -theme streamline -type dbutton outline $::data_card_previous_outline_color
	dui aspect set -theme streamline -type dbutton label_fill $::datacard_number_text_color
	dui aspect set -theme streamline -type dbutton label_font Inter-HeavyBold35
	dui aspect set -theme streamline -type dbutton radius 100

	set pentryheight 160
	set pentrywidth 340

 	set prow1 1078
 	set prow2 1297

 	set pcol1 261
 	set pcol2 672
 	#set pcol3 676
 	#set pcol4 946
	

	dui add dbutton "streamline_entry streamline_entry_integer" $pcol1 $prow1 [expr {$pcol1+$pentrywidth}] [expr {$prow1+$pentryheight}] -tags streamline_data_entry_prev_1 -labelvariable {[lindex $::streamline_entry_previous 0]}  -command { streamline_previous 0 } 
	dui add dbutton [list streamline_entry streamline_entry_integer] $pcol2 $prow1 [expr {$pcol2+$pentrywidth}] [expr {$prow1+$pentryheight}] -tags streamline_data_entry_prev_2 -labelvariable {[lindex $::streamline_entry_previous 1]}  -command { streamline_previous 1 } 
	dui add dbutton "streamline_entry streamline_entry_integer" $pcol1 $prow2 [expr {$pcol1+$pentrywidth}] [expr {$prow2+$pentryheight}] -tags streamline_data_entry_prev_3 -labelvariable {[lindex $::streamline_entry_previous 2]}  -command { streamline_previous 2 } 
	dui add dbutton "streamline_entry streamline_entry_integer" $pcol2 $prow2 [expr {$pcol2+$pentrywidth}] [expr {$prow2+$pentryheight}] -tags streamline_data_entry_prev_4 -labelvariable {[lindex $::streamline_entry_previous 3]}  -command { streamline_previous 3 } 

	#dui add dbutton "streamline_entry streamline_entry_integer" $pcol1 $prow2 [expr {$pcol1+$pentrywidth}] [expr {$prow2+$pentryheight}] -tags streamline_plus_grind_prev_5 -labelvariable {[lindex $::streamline_entry_previous 4]}  -command { streamline_previous 4 } 
	#dui add dbutton "streamline_entry streamline_entry_integer" $pcol2 $prow2 [expr {$pcol2+$pentrywidth}] [expr {$prow2+$pentryheight}] -tags streamline_plus_grind_prev_6 -labelvariable {[lindex $::streamline_entry_previous 5]}  -command { streamline_previous 5 } 
	#dui add dbutton "streamline_entry streamline_entry_integer" $pcol3 $prow2 [expr {$pcol3+$pentrywidth}] [expr {$prow2+$pentryheight}] -tags streamline_plus_grind_prev_7 -labelvariable {[lindex $::streamline_entry_previous 6]}  -command { streamline_previous 6 } 
	#dui add dbutton "streamline_entry streamline_entry_integer" $pcol4 $prow2 [expr {$pcol4+$pentrywidth}] [expr {$prow2+$pentryheight}] -tags streamline_plus_grind_prev_8 -labelvariable {[lindex $::streamline_entry_previous 7]}  -command { streamline_previous 7 } 

}
streamline_entry_page_setup

# not needed in this skin
proc update_temperature_charts_y_axis {} {}
streamline_load_currently_selected_history_shot


#exit
#after 1000 set_next_page off $::zoomed_pages; page_show off_zoomed
#set_next_page off "off_zoomed"
#after 1000 page_show off_zoomed
#after 100 page_show streamline_entry

# revert to default DUI theme, so that other code that relies on current theme=default does not break
dui theme set default
add_de1_button "saver" {say [translate {awake}] $::settings(sound_button_out); set_next_page off $::off_page; page_show off; start_idle; de1_send_waterlevel_settings;} 0 0 2560 1600 "buttonnativepress"
add_de1_button "descaling cleaning" {say [translate {awake}] $::settings(sound_button_out); set_next_page off $::off_page; page_show off; start_idle; de1_send_waterlevel_settings;} 0 0 2560 1600 "buttonnativepress"

