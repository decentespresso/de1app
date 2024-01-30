package require de1 1.0

set ::settings(ghc_is_installed) 1

set ghc_pos_pffset 0
if {$::settings(ghc_is_installed) == 0} { 
	set ghc_pos_pffset 217
}

##############################################################################################################################################################################################################################################################################
# STREAMLINE SKIN
##############################################################################################################################################################################################################################################################################

# you should replace the JPG graphics in the 2560x1600/ directory with your own graphics. 
source "[homedir]/skins/default/standard_includes.tcl"

#load_font "Inter-Regular10" "[skin_directory]/Inter-Regular.ttf" 11

# Left column labels
load_font "Inter-Bold16" "[skin_directory]/Inter-SemiBold.ttf" 13

# GHC buttons
load_font "Inter-Bold12" "[skin_directory]/Inter-SemiBold.ttf" 12

# Profile buttons
load_font "Inter-Bold11" "[skin_directory]/Inter-SemiBold.ttf" 11

# status
load_font "Inter-Bold18" "[skin_directory]/Inter-SemiBold.ttf" 11

# status bold
load_font "Inter-SemiBold18" "[skin_directory]/Inter-Bold.ttf" 11

# +/- buttons
load_font "Inter-Bold24" "[skin_directory]/Inter-ExtraLight.ttf" 29

# profile 
load_font "Inter-HeavyBold24" "[skin_directory]/Inter-SemiBold.ttf" 17

# X and Y axis font
load_font "Inter-Regular20" "[skin_directory]/Inter-Regular.ttf" 12

# X and Y axis font
load_font "Inter-Regular12" "[skin_directory]/Inter-Regular.ttf" 11

# X and Y axis font
load_font "Inter-Regular10" "[skin_directory]/Inter-Regular.ttf" 10

# Scale disconnected msg
load_font "Inter-Black18" "[skin_directory]/Inter-SemiBold.ttf" 14

# Vertical bar in top right buttons
load_font "Inter-Thin14" "[skin_directory]/Inter-Thin.ttf" 14

# button icon font
load_font "icomoon" "[skin_directory]/icomoon.ttf" 30


set ::left_label_color #05386c
set scale_disconnected_color #cd5360

set ::pages [list off steam espresso water flush info hotwaterrinse]
set ::pages_not_off [list steam espresso water flush info hotwaterrinse]

set ::streamline_hotwater_btn_mode "ml"

dui page add $::pages -bg_color "#FFFFFF"
#add_de1_page $::pages "pumijo3.jpg"

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
streamline_rectangle $::pages 0 0 2560 1600 #ffffff

# top grey box
streamline_rectangle $::pages 0 0 2560 220 #f6f8fa

# left grey box
streamline_rectangle $::pages 0 220 626 1600 #f6f8fa

#  grey line on the left
streamline_rectangle $::pages 626 220 626 1600 #c9c9c9

# grey lines on the left bar
streamline_rectangle $::pages 0 687 626 687 #c9c9c9
streamline_rectangle $::pages 0 913 626 913 #c9c9c9
streamline_rectangle $::pages 0 1139 626 1139 #c9c9c9
streamline_rectangle $::pages 0 1365 626 1365 #c9c9c9


# grey horizontal line 
streamline_rectangle $::pages  626 418 2560 418 #c9c9c9

#  grey line on the bottom
streamline_rectangle $::pages 626 1274 2560 1274 #c9c9c9

#  vertical grey line in data card
streamline_rectangle $::pages 1151 1274 1151 1600 #c9c9c9



if {$::settings(ghc_is_installed) == 0} { 
	streamline_rectangle $::pages 2319 220 2600 1274 #f6f8fa
	streamline_rectangle $::pages 2319 220 2319 1274 #c9c9c9
}


streamline_rectangle $::pages 0 220 2560 220 #c9c9c9

# far left grey area where buttons appear
#streamline_rectangle $::pages 0 0 657 1600 #efefef

# empty area on 2/3rd of the right side
#streamline_rectangle $::pages 657 0 2560 1600 #ffffff

# set ::settings(ghc_is_installed) 1

# lower horizontal bar where shot data is shown
if {$::settings(ghc_is_installed) == 0} { 
#	streamline_rectangle $::pages 687 1220 2130 1566 #efefef
	#streamline_rectangle $::pages 687 1220 2480 1566 #efefef
	#dui add shape round $::pages 687 1220 -bwidth 1443 -bheight 346 -radius {20 20 20 20} -fill "#efefef"

} else {
	#streamline_rectangle $::pages 687 1220 2480 1566 #efefef
	#dui add shape round $::pages 687 1220 -bwidth 1848 -bheight 346 -radius {20 20 20 20} -fill "#efefef"
}

#line separating the left grey box
#streamline_rectangle $::pages 0 824 660 836 #ffffff

#streamline_rectangle $::pages 58 603 590 604 #CCCCCC
#streamline_rectangle $::pages 58 1061 590 1062 #CCCCCC
#streamline_rectangle $::pages 58 1282 590 1283 #CCCCCC

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

	save_profile 0
	#puts "ERROR streamline_adjust_grind $args"

	#::refresh_$::toprightbtns
}

############################################################################################################################################################################################################
# top right line with profile name and various text labels that are buttons


	#[list -text "Tare" -font "Inter-Bold11" -foreground $::left_label_color -exec "puts 1" ] \
	#[list -text "        " -font "Inter-Bold11"] \

	#[list -text "Clean" -font "Inter-Bold11" -foreground $::left_label_color -exec  { say [translate {settings}] $::settings(sound_button_in); show_settings} ] \
	#[list -text "        " -font "Inter-Bold11"] \
	#[list -text "Grind @ 15" -font "Inter-Bold11" -foreground $::left_label_color -exec "puts 1" ] \
	#[list -text "     |     " -font "Inter-Thin14"] \

if {[ifexists ::settings(grinder_setting)] == ""} {
	set ::settings(grinder_setting) 0
}
#set ::toprightbtns [add_de1_rich_text $::pages 2500 -10 right 0 2 40 "#FFFFFF" [list \
#	$dyebtns  \
#	[list -text " -   " -font "Inter-HeavyBold24" -foreground "#FFFFFF" -exec "streamline_adjust_grind -" ] \
#	[list -text "Grind " -font "Inter-Bold12" -foreground "#FFFFFF" ] \
#	[list -text {$::settings(grinder_setting)} -font "Inter-Bold12" -foreground "#FFFFFF" ] \
#	[list -text "   + " -font "Inter-Black18" -foreground "#FFFFFF" -exec "streamline_adjust_grind +" ] \
#	[list -text {        } -font "Inter-Bold12"] \
#	[list -text "Settings" -font "Inter-Bold12" -foreground "#FFFFFF" -exec  { say [translate {settings}] $::settings(sound_button_in); show_settings} ] \
#	[list -text {        } -font "Inter-Bold12"] \
#	[list -text "Sleep" -font "Inter-Bold12" -foreground "#FFFFFF" -exec "say [translate {sleep}] $::settings(sound_button_in);start_sleep" ] \
#	[list -text "\n" -font "Inter-Bold12"] \
#	[list -text " -   " -font "Inter-HeavyBold24" -foreground $::left_label_color -exec "streamline_adjust_grind -" ] \
#	[list -text "Grind " -font "Inter-Bold12" -foreground $::left_label_color ] \
#	[list -text {$::settings(grinder_setting)} -font "Inter-Bold12" -foreground $::left_label_color ] \
#	[list -text "   + " -font "Inter-Black18" -foreground $::left_label_color -exec "streamline_adjust_grind +" ] \
#	[list -text {        } -font "Inter-Bold12"] \
#	[list -text "Settings" -font "Inter-Bold12" -foreground $::left_label_color -exec  { say [translate {settings}] $::settings(sound_button_in); show_settings} ] \
#	[list -text {        } -font "Inter-Bold12"] \
#	[list -text "Sleep" -font "Inter-Bold12" -foreground $::left_label_color -exec "say [translate {sleep}] $::settings(sound_button_in);start_sleep" ] \
#]]

add_de1_variable $::pages 690 256 -justify left -anchor "nw" -font Inter-HeavyBold24 -fill $::left_label_color -width [rescale_x_skin 1200] -textvariable {[ifexists settings(profile_title)]} 


############################################################################################################################################################################################################
# The status message on the top right. Might be clickable.

# testing
#after 1000 {set ::streamline_global(status_msg_text) [translate "Scale Disconnected!"]}
#after 1000 {set ::streamline_global(status_msg_clickable) [translate "Reconnect"]}

set ::streamline_global(status_msg_text) ""
set ::streamline_global(status_msg_clickable) ""

proc streamline_status_msg_click {} {
	puts "ERROR TAPPED $::streamline_global(status_msg_clickable)"	
}

set streamline_status_msg [add_de1_rich_text $::pages [expr {2500 - $ghc_pos_pffset}] 305 right 0 1 40 "#FFFFFF" [list \
	[list -text {$::streamline_global(status_msg_text)}  -font "Inter-Black18" -foreground $scale_disconnected_color  ] \
	[list -text "   " -font "Inter-Black18"] \
	[list -text {$::streamline_global(status_msg_clickable)}  -font "Inter-Black18" -foreground "#1967d4" -exec "streamline_status_msg_click" ] \
]]

trace add variable ::streamline_global(status_msg_clickable) write ::refresh_$streamline_status_msg

############################################################################################################################################################################################################




############################################################################################################################################################################################################



############################################################################################################################################################################################################
# The Mix/Group/Steam/Tank status line


set btns [list \
	[list -text "Time" -font "Inter-Bold18" -foreground #121212  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[time_format [clock seconds]]} -font "Inter-SemiBold18" -foreground #121212   ] \
	[list -text "   " -font "Inter-SemiBold18"] \
	[list -text "Mix" -font "Inter-Bold18" -foreground #121212  ] \
	[list -text " " -font "Inter-Bold18"] \
	[list -text {[mixtemp_text 1]} -font "Inter-SemiBold18" -foreground #121212   ] \
	[list -text "   " -font "Inter-SemiBold18"] \
	[list -text "Group" -font "Inter-Bold18" -foreground #121212  ] \
	[list -text " " -font "Inter-SemiBold18"] \
	[list -text {[group_head_heater_temperature_text 1]} -font "Inter-SemiBold18" -foreground #121212  ] \
	[list -text "   " -font "Inter-Bold16"] \
	[list -text "Steam" -font "Inter-Bold18" -foreground #121212  ] \
	[list -text " " -font "Inter-SemiBold18"] \
	[list -text {[steam_heater_temperature_text 1]} -font "Inter-SemiBold18" -foreground #121212 ] \
	[list -text "   " -font "Inter-Bold16"] \
	[list -text "Tank" -font "Inter-Bold18" -foreground #121212  ] \
	[list -text " " -font "Inter-Bold16"] \
	[list -text {[round_to_tens [water_tank_level_to_milliliters $::de1(water_level)]] [translate ml]} -font "Inter-SemiBold18" -foreground #121212  ] \
	[list -text "   " -font "Inter-Bold16"] \
]

if {$::settings(scale_bluetooth_address) != ""} {
	lappend btns [list -text "Weight" -font "Inter-Bold18" -foreground #1967d4  -exec "::device::scale::tare" ] 
	lappend btns [list -text " " -font "Inter-Bold16"  -exec "puts tare" ]
	lappend btns [list -text {[drink_weight_text]} -font "Inter-Bold18" -foreground #1967d4  -exec "::device::scale::tare" ]
	lappend btns [list -text "   " -font "Inter-Bold16"]



	

}

set streamline_status_msg [add_de1_rich_text $::pages 690 330 left 1 1 50 "#FFFFFF" $btns ]

# GH temp
#trace add variable ::de1(head_temperature) write ::refresh_$streamline_status_msg

# steam temp
#trace add variable ::de1(steam_heater_temperature) write ::refresh_$streamline_status_msg

# mix temp
#trace add variable ::de1(mix_temperature) write ::refresh_$streamline_status_msg

# tank level
#trace add variable ::de1(water_level) write ::refresh_$streamline_status_msg

if {$::settings(scale_bluetooth_address) == ""} {
	#trace add variable ::de1(scale_weight) write ::refresh_$streamline_status_msg
}
############################################################################################################################################################################################################



############################################################################################################################################################################################################
# draw text labels for the buttons on the left margin


# blink the hot water presets 
streamline_rectangle $::pages 0 1521 626 1555  #f6f8fa hotwater_presets_rectangle

# blink the hot water presets 
#streamline_rectangle $::pages 365 1396 468 1442  #f6f8fa hotwater_setting_rectangle

# hot water
streamline_rounded_rectangle $::pages 360 1396 478 1439  #f6f8fa  20 hotwater_setting_rectangle

# flush 
streamline_rounded_rectangle $::pages 360 1192 478 1235  #f6f8fa  20 flush_setting_rectangle

# stream 
streamline_rounded_rectangle $::pages 360 966 478 1008  #f6f8fa  20 steam_setting_rectangle

# temp 
streamline_rounded_rectangle $::pages 360 738 478 781  #f6f8fa  20 temp_setting_rectangle

# drink out
streamline_rounded_rectangle $::pages 360 492 478 535  #f6f8fa  20 weight_setting_rectangle

# dose in
streamline_rounded_rectangle $::pages 360 398 478 442  #f6f8fa  20 dose_setting_rectangle

# grind
streamline_rounded_rectangle $::pages 360 282 478 325  #f6f8fa  20 grind_setting_rectangle



set ::left_label_color #385992
# labels
add_de1_text $::pages 50 282 -justify left -anchor "nw" -text [translate "Grind"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200] 
add_de1_text $::pages 50 398 -justify left -anchor "nw" -text [translate "Dose in"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200]
add_de1_text $::pages 50 516 -justify left -anchor "nw" -text [translate "Drink out"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200]
add_de1_text $::pages 50 741 -justify left -anchor "nw" -text [translate "Temp"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200]
add_de1_text $::pages 50 967 -justify left -anchor "nw" -text [translate "Steam"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200]
add_de1_text $::pages 50 1194 -justify left -anchor "nw" -text [translate "Flush"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200]
add_de1_text $::pages 50 1397 -justify left -anchor "nw" -text [translate "Hot Water"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200]


set ::hw_temp_vol_part1 ""
set ::hw_temp_vol_part2 ""
set ::hw_temp_vol_part3 ""
set ::hw_temp_vol_part4 ""
set ::hw_temp_vol_part5 ""
set ::hw_temp_vol_part6 ""

set ::hw_temp_vol [add_de1_rich_text $::pages 50 1444 left 0 1 8 "#f6f8fa" [list \
	[list -text {$::hw_temp_vol_part1} -font Inter-Bold11 -foreground $::left_label_color -exec hw_temp_vol_flip] \
	[list -text {$::hw_temp_vol_part2} -font Inter-Bold11 -foreground "#777777" -exec hw_temp_vol_flip] \
	[list -text {$::hw_temp_vol_part3} -font Inter-Bold11 -foreground  "#777777" -exec hw_temp_vol_flip] \
	[list -text {$::hw_temp_vol_part4} -font Inter-Bold11 -foreground "#777777" -exec hw_temp_vol_flip ] \
	[list -text {$::hw_temp_vol_part5} -font Inter-Bold11 -foreground "#777777" -exec hw_temp_vol_flip ] \
	[list -text {$::hw_temp_vol_part6} -font Inter-Bold11 -foreground  $::left_label_color -exec hw_temp_vol_flip ] \
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

	#.can itemconfigure hotwater_presets_rectangle -fill "#375a92"
	#after 50 refresh_favorite_hw_button_labels
	#after 100 .can itemconfigure hotwater_presets_rectangle -fill "#f6f8fa"
	


	catch {
		refresh_favorite_hw_button_labels
		streamline_hot_water_setting_change

	}
	#refresh_favorite_hw_button_labels	
}
hw_temp_vol_flip



#.can itemconfigure $::hw_temp_vol -pady -10

#add_de1_rich_text "settings_1" 40 1470 left 0 2 40 "#d4d3e1" [list \
#	[list -text "Assign to favorite:" -font "Helv_10_bold" -foreground "#7c8599"  ] \
#	[list -text " 1, " -font "Helv_10_bold" -foreground $fave_btn_color -exec "save_favorite_profile 1" ] \
#	[list -text " 2, " -font "Helv_10_bold" -foreground $fave_btn_color -exec "save_favorite_profile 2" ] \
#	[list -text " 3, " -font "Helv_10_bold" -foreground $fave_btn_color -exec "save_favorite_profile 3" ] \
#	[list -text " 4. " -font "Helv_10_bold" -foreground $fave_btn_color -exec "save_favorite_profile 4" ] \
#]

# tap areas
#add_de1_button "off" {puts "Dose"} 37 292 236 388 ""
#add_de1_button "off" {puts "Beverage"} 37 407 236 503 ""
#add_de1_button "off" {puts "Temp"} 37 628 236 724 ""
#add_de1_button "off" {puts "Steam"} 37 866 236 962 ""
#add_de1_button "off" {puts "Flush"} 37 1089 236 1185 ""
add_de1_button "off" {hw_temp_vol_flip} 0 1376 222 1498 ""

############################################################################################################################################################################################################


############################################################################################################################################################################################################
# data card on the bottom center

# labels
set ::streamline_current_history_profile_name ""
set ::streamline_current_history_profile_clock ""

add_de1_text $::pages 890 1345 -justify center -anchor "center" -text [translate "SHOT HISTORY"] -font Inter-Bold18 -fill #121212 -width [rescale_x_skin 400]

add_de1_variable $::pages 890 1415 -justify center -anchor "center" -text [translate "14 Sep, 18:45"] -font Inter-Bold16 -fill #121212  -width [rescale_x_skin 300] -textvariable {[time_format $::streamline_current_history_profile_clock 0 2]}
add_de1_variable $::pages 890 1484 -justify center -anchor "center" -text [translate "Extractamundo"] -font Inter-Regular20 -fill #121212 -width [rescale_x_skin 1000] -textvariable {$::streamline_current_history_profile_name} 


add_de1_text $::pages 1364 1328 -justify right -anchor "ne" -text [translate "SHOT DATA"] -font Inter-Bold18 -fill #121212 -width [rescale_x_skin 400]
add_de1_text $::pages 1364 1390 -justify right -anchor "ne" -text [translate "Preinfusion"] -font Inter-Bold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 1364 1454 -justify right -anchor "ne" -text [translate "Extraction"] -font Inter-Bold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 1364 1516 -justify right -anchor "ne" -text [translate "Total"] -font Inter-Bold18 -fill #121212 -width [rescale_x_skin 200]


# rounded rectangle color 
#dui aspect set -theme default -type dbutton outline "#A0A0A0"

# inside button color
#dui aspect set -theme default -type dbutton fill "#A0A0A0"

# font color
#dui aspect set -theme default -type dbutton label_fill "#121212"

dui aspect set -theme default -type dbutton fill "#FFFFFF"
dui aspect set -theme default -type dbutton outline "#FFFFFF"
dui aspect set -theme default -type dbutton_symbol fill #121212
dui aspect set -theme default -type dbutton label_fill "#121212"
dui aspect set -theme default -type dbutton_symbol font_size 12
dui aspect set -theme default -type dbutton_symbol pos ".50 .5"

if {$::android == 1 || $::undroid == 1} {
	#dui aspect set -theme default -type dbutton fill "#121212"
	dui add dbutton $::pages 660 1369 755 1465 -tags profile_back -symbol "arrow-left"  -command { streamline_history_profile_back } 
	dui add dbutton $::pages 1025 1369 1121 1465 -tags profile_fwd -symbol "arrow-right"  -command { streamline_history_profile_fwd } 
} else {

	
	dui add dbutton $::pages 690 1399 725 1435  -tags profile_back -label "<"  -command { streamline_history_profile_back } 
	dui add dbutton $::pages 1065 1399 1101 1435  -tags profile_fwd -label ">"  -command { streamline_history_profile_fwd } 
}


#dui add dbutton $::pages 702 1244 763 1298 -tags profile_back -label "asdf"  -command { puts profile_back } 
#dui add dbutton $::pages 980 1244 1041 1298 -tags profile_fwd -label "asdf"  -command { puts profile_fwd } 
# rounded rectangle color 
#dui aspect set -theme default -type dbutton outline "#D8D8D8"
dui aspect set -theme default -type dbutton outline "#EDEDED"

# inside button color
dui aspect set -theme default -type dbutton fill "#EDEDED"

# font color
dui aspect set -theme default -type dbutton label_fill "#121212"

# font to use
dui aspect set -theme default -type dbutton label_font Inter-Bold11

# rounded retangle radius
dui aspect set -theme default -type dbutton radius 18

# rounded retangle line width
dui aspect set -theme default -type dbutton width 2 

# button shape
dui aspect set -theme default -type dbutton shape round_outline 

# label position is higher because we're using a _ as a minus symbol
dui aspect set -theme default -type dbutton label_pos ".50 .5" 




add_de1_text $::pages 1416 1328 -justify right -anchor "nw" -text [translate "Time"] -font Inter-Bold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 1416 1390 -justify right -anchor "nw" -text [translate "15s"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 1416 1454 -justify right -anchor "nw" -text [translate "30s"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 1416 1516 -justify right -anchor "nw" -text [translate "45s"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 200]

add_de1_text $::pages 1542 1328 -justify right -anchor "nw" -text [translate "Weight"] -font Inter-Bold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 1542 1390 -justify right -anchor "nw" -text [translate "10g"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 1542 1454 -justify right -anchor "nw" -text [translate "29g"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 1542 1516 -justify right -anchor "nw" -text [translate "39g"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 200]

add_de1_text $::pages 1734 1328 -justify right -anchor "nw" -text [translate "Volume"] -font Inter-Bold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 1734 1390 -justify right -anchor "nw" -text [translate "17ml"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 1734 1454 -justify right -anchor "nw" -text [translate "30ml"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 1734 1516 -justify right -anchor "nw" -text [translate "47ml"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 200]

add_de1_text $::pages 1888 1328 -justify right -anchor "nw" -text [translate "Temp"] -font Inter-Bold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 1888 1390 -justify right -anchor "nw" -text [translate "90ºC"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 1888 1454 -justify right -anchor "nw" -text [translate "90ºC-86ºC"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 200]

add_de1_text $::pages 2075 1328 -justify right -anchor "nw" -text [translate "Flow"] -font Inter-Bold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 2075 1390 -justify right -anchor "nw" -text [translate "1.5ml/s"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 200]
add_de1_text $::pages 2075 1454 -justify right -anchor "nw" -text [translate "3.8ml/s"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 200]

add_de1_text $::pages 2232 1328 -justify right -anchor "nw" -text [translate "Pressure"] -font Inter-Bold18 -fill #121212 -width [rescale_x_skin 300]
add_de1_text $::pages 2232 1390 -justify right -anchor "nw" -text [translate "0.9 bar (1.3 peak)"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 300]
add_de1_text $::pages 2232 1454 -justify right -anchor "nw" -text [translate "6.0 bar (6.5 peak)"] -font Inter-SemiBold18 -fill #121212 -width [rescale_x_skin 300]

#streamline_rectangle $::pages 718 1316 2089 1316 #CCCCCC


############################################################################################################################################################################################################




############################################################################################################################################################################################################
# draw current setting numbers on the left margin

set ::left_label_color #121212

if {[ifexists ::settings(grinder_dose_weight)] == "" || [ifexists ::settings(grinder_dose_weight)] == "0"} {
	set ::settings(grinder_dose_weight) 15
}
#	set ::settings(grinder_dose_weight) 15

# labels
#set ::settings(grinder_setting) 1.4
add_de1_variable $::pages 418 304 -justify center -anchor "center" -text [translate "20g"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {[ifexists ::settings(grinder_setting)]}
add_de1_variable $::pages 418 418 -justify center -anchor "center" -text [translate "20g"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200] -tags dose_label_1st -textvariable {[return_weight_measurement $::settings(grinder_dose_weight) 2]}
add_de1_variable $::pages 418 512 -justify center -anchor "center" -text [translate "45g"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200] -tags weight_label_1st -textvariable {[return_weight_measurement [determine_final_weight] 2]}
add_de1_variable $::pages 418 558 -justify center -anchor "center" -text [translate "1:2.3"] -font Inter-Regular12 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {([dose_weight_ratio])}
add_de1_variable $::pages 418 761 -justify center -anchor "center" -text [translate "92ºC"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200] -tags temp_label_1st -textvariable {[setting_espresso_temperature_text 1]}   
add_de1_variable $::pages 418 988 -justify center -anchor "center" -text [translate "31s"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200] -tags steam_label_1st -textvariable {[seconds_text_very_abbreviated $::settings(steam_timeout)]}
add_de1_variable $::pages 418 1215 -justify center -anchor "center" -text [translate "5s"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200] -tags flush_label_1st -textvariable {[seconds_text_very_abbreviated $::settings(flush_seconds)]}
add_de1_variable $::pages 418 1417 -justify center -anchor "center" -text [translate "75ml"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200] -tags hotwater_label_1st -textvariable {$::streamline_hotwater_label_1st}
add_de1_variable $::pages 418 1460 -justify center -anchor "center" -text [translate "75ml"] -font Inter-Regular12 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_hotwater_label_2nd}


#add_de1_text $::pages 50 282 -justify left -anchor "nw" -text [translate "Grind"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 50 398 -justify left -anchor "nw" -text [translate "Dose in"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 50 516 -justify left -anchor "nw" -text [translate "Drink out"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 50 741 -justify left -anchor "nw" -text [translate "Temp"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 50 967 -justify left -anchor "nw" -text [translate "Steam"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 50 1194 -justify left -anchor "nw" -text [translate "Flush"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 50 1397 -justify left -anchor "nw" -text [translate "Hot Water"] -font Inter-Bold16 -fill $::left_label_color -width [rescale_x_skin 200]

# tap areas
#add_de1_button "off" {puts "Dose value"} 359 292 496 388 ""
#add_de1_button "off" {puts "Beverage value"} 359 407 496 503 ""
#add_de1_button "off" {puts "Temp value"} 359 628 496 724 ""
#add_de1_button "off" {puts "Steam value"} 359 866 496 962 ""
#add_de1_button "off" {puts "Flush value"} 359 1089 496 1185 ""
#add_de1_button "off" {puts "Hot Water value"} 359 1310 496 1406 ""

############################################################################################################################################################################################################

############################################################################################################################################################################################################
# draw current setting numbers on the left margin

set ::left_label_color_selected #121212
set ::left_label_color #777777
#set ::left_label_color #ff0000

#dui aspect set -theme default -type dbutton fill "#ff0000"

#########
# dose/beverage presets
#dui add dbutton $::pages 24 508 164 600 -tags dosebev_1_btn -labelvariable {$::streamline_favorite_dosebev_buttons(label_1)}  -command { streamline_dosebev_select 1 } -longpress_cmd {streamline_set_dosebev_preset 1 }
#dui add dbutton $::pages 164 508 314 600 -tags dosebev_2_btn -labelvariable {$::streamline_favorite_dosebev_buttons(label_2)}  -command { streamline_dosebev_select 2 } -longpress_cmd {streamline_set_dosebev_preset 2 }
#dui add dbutton $::pages 318 508 458 600 -tags dosebev_3_btn -labelvariable {$::streamline_favorite_dosebev_buttons(label_3)}  -command { streamline_dosebev_select 3 } -longpress_cmd {streamline_set_dosebev_preset 3 }
#dui add dbutton $::pages 484 508 624 600 -tags dosebev_4_btn -labelvariable {$::streamline_favorite_dosebev_buttons(label_4)}  -command { streamline_dosebev_select 4 } -longpress_cmd {streamline_set_dosebev_preset 4 }

add_de1_variable $::pages 50 616  -justify left -anchor "nw" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_1)}
add_de1_variable $::pages 251 630  -justify center -anchor "center" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_2)}
add_de1_variable $::pages 406 630  -justify center -anchor "center" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_3)}
add_de1_variable $::pages 580 616  -justify right -anchor "ne" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_dosebev_buttons(label_4)}

dui add dbutton $::pages 0 594 148 672 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_dosebev_select 1 } -theme none  -longpress_cmd { streamline_set_dosebev_preset 1 } 
dui add dbutton $::pages 148 594 310 672 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_dosebev_select 2 } -theme none  -longpress_cmd {streamline_set_dosebev_preset 2 } 
dui add dbutton $::pages 310 594 474 672 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_dosebev_select 3 } -theme none  -longpress_cmd {streamline_set_dosebev_preset 3 } 
dui add dbutton $::pages 474 594 624 672 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_dosebev_select 4 } -theme none  -longpress_cmd {streamline_set_dosebev_preset 4 } 



#########
# temp presets
#dui add dbutton $::pages 24 728 164 820 -tags temperature_1_btn -labelvariable {$::streamline_favorite_temperature_buttons(label_1)}  -command { streamline_temperature_select 1 } -longpress_cmd {streamline_set_temperature_preset 1 }
#dui add dbutton $::pages 164 728 314 820 -tags temperature_2_btn -labelvariable {$::streamline_favorite_temperature_buttons(label_2)}  -command { streamline_temperature_select 2 } -longpress_cmd {streamline_set_temperature_preset 2 }
#dui add dbutton $::pages 318 728 458 820 -tags temperature_3_btn -labelvariable {$::streamline_favorite_temperature_buttons(label_3)}  -command { streamline_temperature_select 3 } -longpress_cmd {streamline_set_temperature_preset 3 }
#dui add dbutton $::pages 484 728 624 820 -tags temperature_4_btn -labelvariable {$::streamline_favorite_temperature_buttons(label_4)}  -command { streamline_temperature_select 4 } -longpress_cmd {streamline_set_temperature_preset 4 }

add_de1_variable $::pages 50 842  -justify left -anchor "nw" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_1)}
add_de1_variable $::pages 251 856  -justify center -anchor "center" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_2)}
add_de1_variable $::pages 406 856  -justify center -anchor "center" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_3)}
add_de1_variable $::pages 580 842  -justify right -anchor "ne" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_temperature_buttons(label_4)}

dui add dbutton $::pages 0 822 148 900 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_temperature_select 1 } -theme none  -longpress_cmd { streamline_set_temperature_preset 1 } 
dui add dbutton $::pages 148 822 310 900 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_temperature_select 2 } -theme none  -longpress_cmd {streamline_set_temperature_preset 2 } 
dui add dbutton $::pages 310 822 474 900 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_temperature_select 3 } -theme none  -longpress_cmd {streamline_set_temperature_preset 3 } 
dui add dbutton $::pages 474 822 624 900 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_temperature_select 4 } -theme none  -longpress_cmd {streamline_set_temperature_preset 4 } 




#########
# steam presets
#dui add dbutton $::pages 24 966 164 1058 -tags steam_1_btn -labelvariable {$::streamline_favorite_steam_buttons(label_1)}  -command { streamline_steam_select 1 } -longpress_cmd {streamline_set_steam_preset 1 }
#dui add dbutton $::pages 164 966 314 1058 -tags steam_2_btn -labelvariable {$::streamline_favorite_steam_buttons(label_2)}  -command { streamline_steam_select 2 } -longpress_cmd {streamline_set_steam_preset 2 }
#dui add dbutton $::pages 318 966 458 1058 -tags steam_3_btn -labelvariable {$::streamline_favorite_steam_buttons(label_3)}  -command { streamline_steam_select 3 } -longpress_cmd {streamline_set_steam_preset 3 }
#dui add dbutton $::pages 484 966 624 1058 -tags steam_4_btn -labelvariable {$::streamline_favorite_steam_buttons(label_4)}  -command { streamline_steam_select 4 } -longpress_cmd {streamline_set_steam_preset 4 }

add_de1_variable $::pages 50 1068  -justify left -anchor "nw" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_1)}
add_de1_variable $::pages 251 1082  -justify center -anchor "center" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_2)}
add_de1_variable $::pages 406 1082  -justify center -anchor "center" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_3)}
add_de1_variable $::pages 580 1068  -justify right -anchor "ne" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_steam_buttons(label_4)}


dui add dbutton $::pages 0 1050 148 1128 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_steam_select 1 } -theme none  -longpress_cmd { streamline_set_steam_preset 1 } 
dui add dbutton $::pages 148 1050 310 1128 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_steam_select 2 } -theme none  -longpress_cmd {streamline_set_steam_preset 2 } 
dui add dbutton $::pages 310 1050 474 1128 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_steam_select 3 } -theme none  -longpress_cmd {streamline_set_steam_preset 3 } 
dui add dbutton $::pages 474 1050 624 1128 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_steam_select 4 } -theme none  -longpress_cmd {streamline_set_steam_preset 4 } 


#########
# flush presets
#dui add dbutton $::pages 24 1196 164 1272 -tags flush_1_btn -labelvariable {$::streamline_favorite_flush_buttons(label_1)}  -command { streamline_flush_select 1 } -longpress_cmd {streamline_set_flush_preset 1 }
#dui add dbutton $::pages 164 1196 314 1272 -tags flush_2_btn -labelvariable {$::streamline_favorite_flush_buttons(label_2)}  -command { streamline_flush_select 2 } -longpress_cmd {streamline_set_flush_preset 2 }
#dui add dbutton $::pages 318 1196 458 1272 -tags flush_3_btn -labelvariable {$::streamline_favorite_flush_buttons(label_3)}  -command { streamline_flush_select 3 } -longpress_cmd {streamline_set_flush_preset 3 }
#dui add dbutton $::pages 484 1196 624 1272 -tags flush_4_btn -labelvariable {$::streamline_favorite_flush_buttons(label_4)}  -command { streamline_flush_select 4 } -longpress_cmd {streamline_set_flush_preset 4 }

add_de1_variable $::pages 50 1296  -justify left -anchor "nw" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_1)}
add_de1_variable $::pages 251 1310  -justify center -anchor "center" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_2)}
#add_de1_variable $::pages 265 1296  -justify center -anchor "ne" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_2)}
add_de1_variable $::pages 406 1310  -justify center -anchor "center" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_3)}
add_de1_variable $::pages 580 1296  -justify right -anchor "ne" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_flush_buttons(label_4)}


dui add dbutton $::pages 0 1272 148 1350 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_flush_select 1 } -theme none  -longpress_cmd { streamline_set_flush_preset 1 } 
dui add dbutton $::pages 148 1272 310 1350 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_flush_select 2 } -theme none  -longpress_cmd {streamline_set_flush_preset 2 } 
dui add dbutton $::pages 310 1272 474 1350 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_flush_select 3 } -theme none  -longpress_cmd {streamline_set_flush_preset 3 } 
dui add dbutton $::pages 474 1272 624 1350 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_flush_select 4 } -theme none  -longpress_cmd {streamline_set_flush_preset 4 } 


#########
# hot water presets

#dui add dbutton $::pages 24 1527 164 1600 -tags hwvol_1_btn -labelvariable {$::streamline_favorite_hwvol_buttons(label_1)}  -command { streamline_hwvol_select 1 } -longpress_cmd {streamline_set_hwvol_preset 1 } 
#dui add dbutton $::pages 164 1527 314 1600 -tags hwvol_2_btn -labelvariable {$::streamline_favorite_hwvol_buttons(label_2)}  -command { streamline_hwvol_select 2 } -longpress_cmd {streamline_set_hwvol_preset 2 }
#dui add dbutton $::pages 318 1527 458 1600 -tags hwvol_3_btn -labelvariable {$::streamline_favorite_hwvol_buttons(label_3)}  -command { streamline_hwvol_select 3 } -longpress_cmd {streamline_set_hwvol_preset 3 }
#dui add dbutton $::pages 484 1527 624 1600 -tags hwvol_4_btn -labelvariable {$::streamline_favorite_hwvol_buttons(label_4)}  -command { streamline_hwvol_select 4 } -longpress_cmd {streamline_set_hwvol_preset 4 }

add_de1_variable $::pages 50 1520  -justify left -tags hw_1_btn -anchor "nw" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_1)}
add_de1_variable $::pages 251 1534  -justify center -tags hw_2_btn -anchor "center" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_2)}
add_de1_variable $::pages 406 1534  -justify center -tags hw_3_btn -anchor "center" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_3)}
add_de1_variable $::pages 580 1520  -justify right -tags hw_4_btn -anchor "ne" -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200] -textvariable {$::streamline_favorite_hw_buttons(label_4)}

#add_de1_button $::pages {say [translate {Preset}] $::settings(sound_button_in); streamline_hw_preset_select 1 } 0 1510 148 1600 

dui add dbutton $::pages 0 1500 148 1600 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_hw_preset_select 1 } -theme none  -longpress_cmd {streamline_set_hw_preset 1 } 
dui add dbutton $::pages 148 1500 310 1600 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_hw_preset_select 2 } -theme none  -longpress_cmd {streamline_set_hw_preset 2 } 
dui add dbutton $::pages 310 1500 474 1600 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_hw_preset_select 3 } -theme none  -longpress_cmd {streamline_set_hw_preset 3 } 
dui add dbutton $::pages 474 1500 624 1600 -command {say [translate {Preset}] $::settings(sound_button_in); streamline_hw_preset_select 4 } -theme none  -longpress_cmd {streamline_set_hw_preset 4 } 


#add_de1_button $::pages {say [translate {Preset}] $::settings(sound_button_in); streamline_hw_preset_select 2 } 148 1510 310 1600
#add_de1_button $::pages {say [translate {Preset}] $::settings(sound_button_in); streamline_hw_preset_select 3 } 310 1510 454 1600
#add_de1_button $::pages {say [translate {Preset}] $::settings(sound_button_in); streamline_hw_preset_select 4 } 454 1510 639 1600

#add_de1_text $::pages 234 1454 -justify center -anchor "center" -text [translate "120ml"] -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 388 1454 -justify center -anchor "center" -text [translate "180ml"] -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 554 1454 -justify center -anchor "center" -text [translate "200ml"] -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200]


#dui add dbutton $::pages 24 1506 164 1578 -tags hwtemp_1_btn -labelvariable {$::streamline_favorite_hwtemp_buttons(label_1)}  -command { streamline_hwtemp_select 1 } -longpress_cmd {streamline_set_hwtemp_preset 1 }
#dui add dbutton $::pages 164 1506 314 1578 -tags hwtemp_2_btn -labelvariable {$::streamline_favorite_hwtemp_buttons(label_2)}  -command { streamline_hwtemp_select 2 } -longpress_cmd {streamline_set_hwtemp_preset 2 }
#dui add dbutton $::pages 318 1506 458 1578 -tags hwtemp_3_btn -labelvariable {$::streamline_favorite_hwtemp_buttons(label_3)}  -command { streamline_hwtemp_select 3 } -longpress_cmd {streamline_set_hwtemp_preset 3 }
#dui add dbutton $::pages 484 1506 624 1578 -tags hwtemp_4_btn -labelvariable {$::streamline_favorite_hwtemp_buttons(label_4)}  -command { streamline_hwtemp_select 4 } -longpress_cmd {streamline_set_hwtemp_preset 4 }


#add_de1_text $::pages 94 1454 -justify center -anchor "center" -text [translate "75ml"] -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 234 1454 -justify center -anchor "center" -text [translate "120ml"] -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 388 1454 -justify center -anchor "center" -text [translate "180ml"] -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 554 1454 -justify center -anchor "center" -text [translate "200ml"] -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200]

#add_de1_text $::pages 94 1534 -justify center -anchor "center" -text [translate "75ºC"] -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 234 1534 -justify center -anchor "center" -text [translate "80ºC"] -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 388 1534 -justify center -anchor "center" -text [translate "85ºC"] -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200]
#add_de1_text $::pages 554 1534 -justify center -anchor "center" -text [translate "90ºC"] -font Inter-Bold11 -fill $::left_label_color -width [rescale_x_skin 200]


# hot water tap areas
#add_de1_button "off" {puts "hot water value 1"} 37 1424 169 1489 ""
#add_de1_button "off" {puts "hot water value 2"} 169 1424 301 1489 ""
#add_de1_button "off" {puts "hot water value 3"} 301 1424 466 1489 ""
#add_de1_button "off" {puts "hot water value 4"} 466 1424 613 1489 ""

#add_de1_button "off" {puts "hot water value 5"} 37 1489 169 1566 ""
#add_de1_button "off" {puts "hot water value 6"} 169 1489 301 1566 ""
#add_de1_button "off" {puts "hot water value 7"} 301 1489 466 1566 ""
#add_de1_button "off" {puts "hot water value 8"} 466 1489 613 1566 ""
#########



############################################################################################################################################################################################################



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

	set b1 ""
	set b2 ""
	set b3 ""
	set b4 ""
	set b5 ""

	catch {
		set b1 [dict get $profiles 1 title]
	}
	catch {
		set b2 [dict get $profiles 2 title]
	}
	catch {
		set b3 [dict get $profiles 3 title]
	}
	catch {
		set b4 [dict get $profiles 4 title]
	}
	catch {
		set b5 [dict get $profiles 5 title]
	}

	set changed 0
	if {$b1 == ""} {
		set b1 "Default"
		set t1 "default"
		dict set profiles 1 name $t1
		dict set profiles 1 title $b1
		set changed 1
	}

	if {$b2 == ""} {
		set b2 "Adaptive (for medium roasts)"
		set t2 "best_practice"		
		dict set profiles 2 name $t2
		dict set profiles 2 title $b2
		set changed 1
	}

	if {$b3 == ""} {
		set b3 "Rao Allongé"
		set t3 "rao_allonge"		
		dict set profiles 3 name $t3
		dict set profiles 3 title $b3
		set changed 1
	}

	if {$b4 == ""} {
		set b4 "80's Espresso"
		set t4 "80s_Espresso"		
		dict set profiles 4 name $t4
		dict set profiles 4 title $b4
		set changed 1
	}

	if {$b5 == ""} {
		set b5 "Cleaning/ Forward Flush x5"
		set t5 "Cleaning_forward_flush_x5"		
		dict set profiles 5 name $t5
		dict set profiles 5 title $b5
		set changed 1
	}


	if {$changed == 1} {
		set ::settings(favorite_profiles) $profiles	
		save_settings	
	}

	set ::streamline_favorite_profile_buttons(label_1) $b1
	set ::streamline_favorite_profile_buttons(label_2) $b2
	set ::streamline_favorite_profile_buttons(label_3) $b3
	set ::streamline_favorite_profile_buttons(label_4) $b4
	set ::streamline_favorite_profile_buttons(label_5) $b5

	set b1c "#ffffff"
	set b2c "#ffffff"
	set b3c "#ffffff"
	set b4c "#ffffff"
	set b5c "#ffffff"

	set lb1c "#607aa7"
	set lb2c "#607aa7"
	set lb3c "#607aa7"
	set lb4c "#607aa7"
	set lb5c "#607aa7"

	set ob1c "#c5ddda"
	set ob2c "#c5ddda"
	set ob3c "#c5ddda"
	set ob4c "#c5ddda"
	set ob5c "#c5ddda"

	if {$streamline_selected_favorite_profile == 1} {
		set b1c "#385992"
		set lb1c "#ffffff"
		set ob1c "#385992"
	} elseif {$streamline_selected_favorite_profile == 2} {
		set b2c "#385992"
		set lb2c "#ffffff"
		set ob2c "#385992"
	} elseif {$streamline_selected_favorite_profile == 3} {
		set b3c "#385992"
		set lb3c "#ffffff"
		set ob3c "#385992"
	} elseif {$streamline_selected_favorite_profile == 4} {
		set b4c "#385992"
		set lb4c "#ffffff"
		set ob4c "#385992"
	} elseif {$streamline_selected_favorite_profile == 5} {
		set b5c "#385992"
		set lb5c "#ffffff"
		set ob5c "#385992"
	}
	.can itemconfigure profile_1_btn-btn -fill $b1c
	.can itemconfigure profile_2_btn-btn -fill $b2c
	.can itemconfigure profile_3_btn-btn -fill $b3c
	.can itemconfigure profile_4_btn-btn -fill $b4c
	.can itemconfigure profile_5_btn-btn -fill $b5c

	.can itemconfigure profile_1_btn-lbl -fill $lb1c
	.can itemconfigure profile_2_btn-lbl -fill $lb2c
	.can itemconfigure profile_3_btn-lbl -fill $lb3c
	.can itemconfigure profile_4_btn-lbl -fill $lb4c
	.can itemconfigure profile_5_btn-lbl -fill $lb5c

	.can itemconfigure profile_1_btn-out -fill $ob1c
	dui item config "off" profile_1_btn-out-ne  -outline $ob1c
	dui item config "off" profile_1_btn-out-nw  -outline $ob1c
	dui item config "off" profile_1_btn-out-se  -outline $ob1c
	dui item config "off" profile_1_btn-out-sw  -outline $ob1c

	.can itemconfigure profile_2_btn-out -fill $ob2c
	dui item config "off" profile_2_btn-out-ne  -outline $ob2c
	dui item config "off" profile_2_btn-out-nw  -outline $ob2c
	dui item config "off" profile_2_btn-out-se  -outline $ob2c
	dui item config "off" profile_2_btn-out-sw  -outline $ob2c

	.can itemconfigure profile_3_btn-out -fill $ob3c
	dui item config "off" profile_3_btn-out-ne  -outline $ob3c
	dui item config "off" profile_3_btn-out-nw  -outline $ob3c
	dui item config "off" profile_3_btn-out-se  -outline $ob3c
	dui item config "off" profile_3_btn-out-sw  -outline $ob3c

	.can itemconfigure profile_4_btn-out -fill $ob4c
	dui item config "off" profile_4_btn-out-ne  -outline $ob4c
	dui item config "off" profile_4_btn-out-nw  -outline $ob4c
	dui item config "off" profile_4_btn-out-se  -outline $ob4c
	dui item config "off" profile_4_btn-out-sw  -outline $ob4c

	.can itemconfigure profile_5_btn-out -fill $ob5c
	dui item config "off" profile_5_btn-out-ne  -outline $ob5c
	dui item config "off" profile_5_btn-out-nw  -outline $ob5c
	dui item config "off" profile_5_btn-out-se  -outline $ob5c
	dui item config "off" profile_5_btn-out-sw  -outline $ob5c

}


####
# favorite profile buttons


# rounded rectangle color 
dui aspect set -theme default -type dbutton outline "#c5cdd8"

# inside button color
dui aspect set -theme default -type dbutton fill "#d8d8d8"
#d8d8d8


# font to use
dui aspect set -theme default -type dbutton label_font Inter-Bold11

# rounded retangle radius
dui aspect set -theme default -type dbutton radius 18

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

# button color
#dui aspect set -theme default -type dbutton fill "#3e5682"
dui aspect set -theme default -type dbutton fill "#d8d8d8"

# font color
#dui aspect set -theme default -type dbutton label_fill "#ffffff"
dui aspect set -theme default -type dbutton label_fill "#3c5782"

# width of text of profile selection button
dui aspect set -theme default -type dbutton_label width 220


# button color
dui aspect set -theme default -type dbutton fill "#d8d8d8"

# font color
dui aspect set -theme default -type dbutton label_fill "#3c5782"

#  -longpress_cmd { puts "ERRORlongpress" }
dui add dbutton $::pages 50 50 350 170 -tags profile_1_btn -labelvariable {$::streamline_favorite_profile_buttons(label_1)}  -command { streamline_profile_select 1 }
dui add dbutton $::pages 370 50 670 170 -tags profile_2_btn -labelvariable {$::streamline_favorite_profile_buttons(label_2)}  -command { streamline_profile_select 2 } 
dui add dbutton $::pages 690 50 990 170 -tags profile_3_btn -labelvariable {$::streamline_favorite_profile_buttons(label_3)} -command { streamline_profile_select 3 } 
dui add dbutton $::pages 1010 50 1310 170 -tags profile_4_btn -labelvariable {$::streamline_favorite_profile_buttons(label_4)}   -command { streamline_profile_select 4 } 
dui add dbutton $::pages 1330 50 1630 170 -tags profile_5_btn -labelvariable {$::streamline_favorite_profile_buttons(label_5)}   -command { streamline_profile_select 5 } 



# button color
dui aspect set -theme default -type dbutton fill "#ffffff"

# rounded rectangle color 
dui aspect set -theme default -type dbutton outline "#c5cdda"

dui aspect set -theme default -type dbutton width 2

# rounded retangle radius
#dui aspect set -theme default -type dbutton radius 36
dui aspect set -theme default -type dbutton radius 28




############################################################################################################################################################################################################
# DYE support

set dyebtns ""

if { [plugins enabled DYE] } {
	package require sqlite3
	if { [plugins available SDB] } {
		plugins enable SDB
	}
	dui page load DYE current 

	dui add dbutton $::pages 1900 76 2090 145 -tags dye_btn -label "DYE"  -command { show_DYE_page }

}

proc show_DYE_page {} {
	if { [plugins enabled DYE] } {
		plugins::DYE::open -which_shot default -theme MimojaCafe -coords {700 250} -anchor nw
	}
}
############################################################################################################################################################################################################


dui add dbutton $::pages 2120 76 2300 145 -tags settings_btn -label "Settings"  -command { say [translate {settings}] $::settings(sound_button_in); show_settings }
dui add dbutton $::pages 2330 76 2510 145 -tags sleep_btn -label "Sleep"  -command { say [translate {sleep}] $::settings(sound_button_in);start_sleep }

	#.can itemconfigure settings_btn-out -fill "#bbc2cc" -width 2
	#.can itemconfigure settings_btn-out-ne  -width 2 -fill "#c5cdda"
	#.can itemconfigure settings_btn-out-nw  -width 2 -fill "#c5cdda"
	#.can itemconfigure settings_btn-out-se  -width 2 -fill "#c5cdda"
	#.can itemconfigure settings_btn-out-sw  -width 2 -fill "#c5cdda"

	#.can itemconfigure sleep_btn-out -fill "#bbc2cc" -width 2
	#.can itemconfigure sleep_btn-out-ne  -width 2 -fill "#c5cdda"
	#.can itemconfigure sleep_btn-out-nw  -width 2 -fill "#c5cdda"
	#.can itemconfigure sleep_btn-out-se  -width 2 -fill "#c5cdda"
	#.can itemconfigure sleep_btn-out-sw  -width 2 -fill "#c5cdda"

	#dui item config "off" profile_1_btn-out-ne  -outline $ob1c
	#dui item config "off" profile_1_btn-out-nw  -outline $ob1c
	#dui item config "off" profile_1_btn-out-se  -outline $ob1c
	#dui item config "off" profile_1_btn-out-sw  -outline $ob1c


refresh_favorite_profile_button_labels

#set ::toprightbtns [add_de1_rich_text $::pages 2500 -10 right 0 2 40 "#FFFFFF" [list \
#	$dyebtns  \
#	[list -text " -   " -font "Inter-HeavyBold24" -foreground "#FFFFFF" -exec "streamline_adjust_grind -" ] \
#	[list -text "Grind " -font "Inter-Bold12" -foreground "#FFFFFF" ] \
#	[list -text {$::settings(grinder_setting)} -font "Inter-Bold12" -foreground "#FFFFFF" ] \
#	[list -text "   + " -font "Inter-Black18" -foreground "#FFFFFF" -exec "streamline_adjust_grind +" ] \
#	[list -text {        } -font "Inter-Bold12"] \
#	[list -text "Settings" -font "Inter-Bold12" -foreground "#FFFFFF" -exec  { say [translate {settings}] $::settings(sound_button_in); show_settings} ] \
#	[list -text {        } -font "Inter-Bold12"] \
#	[list -text "Sleep" -font "Inter-Bold12" -foreground "#FFFFFF" -exec "say [translate {sleep}] $::settings(sound_button_in);start_sleep" ] \
#	[list -text "\n" -font "Inter-Bold12"] \
#	[list -text " -   " -font "Inter-HeavyBold24" -foreground $::left_label_color -exec "streamline_adjust_grind -" ] \
#	[list -text "Grind " -font "Inter-Bold12" -foreground $::left_label_color ] \
#	[list -text {$::settings(grinder_setting)} -font "Inter-Bold12" -foreground $::left_label_color ] \
#	[list -text "   + " -font "Inter-Black18" -foreground $::left_label_color -exec "streamline_adjust_grind +" ] \
#	[list -text {        } -font "Inter-Bold12"] \
#	[list -text "Settings" -font "Inter-Bold12" -foreground $::left_label_color -exec  { say [translate {settings}] $::settings(sound_button_in); show_settings} ] \
#	[list -text {        } -font "Inter-Bold12"] \
#	[list -text "Sleep" -font "Inter-Bold12" -foreground $::left_label_color -exec "say [translate {sleep}] $::settings(sound_button_in);start_sleep" ] \
#]]


#dui add dbutton "off" 58 157 311 267 -tags profile_3_btn -labelvariable {$::streamline_favorite_profile_buttons(label_3)} -command { streamline_profile_select 3 } 
#.can itemconfigure profile_3_btn-btn -fill "#ff0000"
#.can itemconfigure $::streamline_favorite_profile_buttons(2) -fill "#3e5682"

#dui item config $::streamline_favorite_profile_buttons(1) label -fill "#3e5682"

#puts "ERROR [dui item config $::streamline_favorite_profile_buttons(3)]"


############################################################################################################################################################################################################


############################################################################################################################################################################################################
# plus/minus +/- buttons on the left hand side for changing parameters

# rounded rectangle color 
dui aspect set -theme default -type dbutton outline "#efefef"
#dui aspect set -theme default -type dbutton outline "#ff0000"

# inside button color
set ::plus_minus_flash_on_color  "#b8b8b8"
set ::plus_minus_flash_on_color2  "#cfcfcf"
set ::plus_minus_flash_off_color "#ededed"
set ::plus_minus_flash_refused_color "#e34e4e"
#set ::plus_minus_disabled_color "#e34e4e"

dui aspect set -theme default -type dbutton fill $::plus_minus_flash_off_color

# font color
dui aspect set -theme default -type dbutton label_fill "#121212"

# font to use
dui aspect set -theme default -type dbutton label_font Inter-Bold24 

# rounded retangle radius
dui aspect set -theme default -type dbutton radius 18

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
dui aspect set -theme default -type dbutton label_pos ".50 .44" 

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
	.can itemconfigure $buttontag-btn -fill $::plus_minus_flash_on_color2 
	after 40 .can itemconfigure $buttontag-btn -fill $::plus_minus_flash_on_color
	after 120 .can itemconfigure $buttontag-btn -fill $::plus_minus_flash_on_color2 
	after 160 .can itemconfigure $buttontag-btn -fill $::plus_minus_flash_off_color
}

proc streamline_dose_btn { args } {
	if {$args == "-"} {
		if {$::settings(grinder_dose_weight) > 1} {
			set ::settings(grinder_dose_weight) [round_to_one_digits [expr {$::settings(grinder_dose_weight) - .1}]]
			flash_button "streamline_minus_dose_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			save_profile_and_update_de1_soon
		}
	} elseif {$args == "+"} {
		if {$::settings(grinder_dose_weight) < 30} {
			set ::settings(grinder_dose_weight) [round_to_one_digits [expr {$::settings(grinder_dose_weight) + .1}]]
			flash_button "streamline_plus_dose_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			save_profile_and_update_de1_soon
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
			set ::settings(espresso_temperature) [expr {$::settings(espresso_temperature) - 1}]
			flash_button "streamline_minus_temp_btn" $::plus_minus_flash_on_color $::plus_minus_flash_off_color
			save_profile_and_update_de1_soon
		}
	} elseif {$args == "+"} {
		if {$::settings(espresso_temperature) < 110} {
			set ::settings(espresso_temperature) [expr {$::settings(espresso_temperature) + 1}]
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
dui aspect set -theme default -type dbutton label_fill "#ffffff"

# rounded rectangle color 
dui aspect set -theme default -type dbutton outline "#394a75"

# inside button color
dui aspect set -theme default -type dbutton fill "#394a75"

dui aspect set -theme default -type dbutton radius 26

dui add dbutton "settings_1" 50 1452 160 1580  -tags profile_btn_1 -label "1"  -command { save_favorite_profile 1 } 
dui add dbutton "settings_1" 180 1452 290 1580   -tags profile_btn_2 -label "2"  -command { save_favorite_profile 2 } 
dui add dbutton "settings_1" 310 1452 420 1580  -tags profile_btn_3 -label "3"  -command { save_favorite_profile 3} 
dui add dbutton "settings_1" 440 1452 550 1580  -tags profile_btn_4 -label "4"  -command { save_favorite_profile 4 } 
dui add dbutton "settings_1" 570 1452 680 1580  -tags profile_btn_5 -label "5"  -command { save_favorite_profile 5 } 


#set fave_btn_color "#394a75"
#add_de1_rich_text "settings_1" 40 1470 left 0 2 40 "#d4d3e1" [list \
#	[list -text "Assign to favorite:" -font "Helv_10_bold" -foreground "#7c8599"  ] \
#	[list -text " 1, " -font "Helv_10_bold" -foreground $fave_btn_color -exec "save_favorite_profile 1" ] \
#	[list -text " 2, " -font "Helv_10_bold" -foreground $fave_btn_color -exec "save_favorite_profile 2" ] \
#	[list -text " 3, " -font "Helv_10_bold" -foreground $fave_btn_color -exec "save_favorite_profile 3" ] \
#	[list -text " 4. " -font "Helv_10_bold" -foreground $fave_btn_color -exec "save_favorite_profile 4" ] \
#]

	



#add_de1_rich_text settings_1 2500 4 left 0 2 40 "#FFFFFF" [list \
#	[list -text "Assign to favorite:" -font "Inter-Bold12" -foreground "#FFFFFF"  ] \
#	[list -text { 1 } -font "Inter-Bold12"]  -foreground "#FFFFFF" -exec "save_favorite_profile 1" ] \
#	[list -text {, 2 } -font "Inter-Bold12"]  -foreground "#FFFFFF" -exec "save_favorite_profile 2" ] \
#	[list -text {, 3 } -font "Inter-Bold12"]  -foreground "#FFFFFF" -exec "save_favorite_profile 3" ] \
#	[list -text {, 4 } -font "Inter-Bold12"]  -foreground "#FFFFFF" -exec "save_favorite_profile 4" ] \
#]#


proc streamline_profile_select { slot } {

	if {[dui page current] != "off"} {
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
	dict set profiles $slot title $::settings(profile_title)

	set ::settings(favorite_profiles) $profiles
	#refresh_favorite_profile_button_labels
	refresh_favorite_profile_button_labels
	save_settings
	borg toast [translate "Saved"]
}

############################################################################################################################################################################################################



############################################################################################################################################################################################################
# Four GHC buttons on bottom right

if {$::settings(ghc_is_installed) == 0} { 

	# color of the button icons
	dui aspect set -theme default -type dbutton_symbol fill #375a92

	# font size of the button icons
	dui aspect set -theme default -type dbutton_symbol font_size 24

	# position of the button icons
	dui aspect set -theme default -type dbutton_symbol pos ".50 .38"

	# rounded rectangle color 
	dui aspect set -theme default -type dbutton outline "#375a92"

	# inside button color
	dui aspect set -theme default -type dbutton fill "#FFFFFF"

	# font color
	dui aspect set -theme default -type dbutton label_fill "#375a92"
	dui aspect set -theme default -type dbutton label1_fill "#375a92"

	# font to use
	dui aspect set -theme default -type dbutton label_font Inter-Bold12 
	
	dui aspect set -theme default -type dbutton label1_font icomoon
	# rounded retangle radius
	dui aspect set -theme default -type dbutton radius 18

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

		dui add dbutton "off" [expr {2560 - $ghc_pos_pffset + 20}] 258 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 425 -tags espresso_btn -label1 $s1 -label [translate "Coffee"]   -command {say [translate {Espresso}] $::settings(sound_button_in); start_espresso} 
		dui add dbutton "off" [expr {2560 - $ghc_pos_pffset + 20}] 463 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 630 -tags water_btn -label1 $s3 -label [translate "Water"]   -command {say [translate {Water}] $::settings(sound_button_in); start_water} 
		dui add dbutton "off" [expr {2560 - $ghc_pos_pffset + 20}] 668 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 835 -tags flush_btn -label1 $s4 -label [translate "Flush"]  -command {say [translate {Flush}] $::settings(sound_button_in); start_flush} 
		dui add dbutton "off" [expr {2560 - $ghc_pos_pffset + 20}] 873 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 1040 -tags steam_btn -label1 $s2 -label [translate "Steam"]   -command {say [translate {Steam}] $::settings(sound_button_in); start_steam} 


		# disabled
		dui aspect set -theme default -type dbutton outline "#c5d0df"
		dui aspect set -theme default -type dbutton fill "#f8fafb"
		dui aspect set -theme default -type dbutton label_fill "#c5d0df"
		dui aspect set -theme default -type dbutton label1_fill "#c5d0df"
		dui aspect set -theme default -type dbutton_symbol fill "#c5d0df"
		dui add dbutton "espresso water steam hotwaterrinse" [expr {2560 - $ghc_pos_pffset + 20}] 258 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 425 -tags espresso_btn_disabled -label1 $s1 -label [translate "Coffee"]  
		dui add dbutton "espresso water steam hotwaterrinse" [expr {2560 - $ghc_pos_pffset + 20}] 463 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 630 -tags water_btn_disabled -label1 $s3 -label [translate "Water"]  
		dui add dbutton "espresso water steam hotwaterrinse" [expr {2560 - $ghc_pos_pffset + 20}] 668 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 835 -tags flush_btn_disabled -label1 $s4 -label [translate "Flush"]  
		dui add dbutton "espresso water steam hotwaterrinse" [expr {2560 - $ghc_pos_pffset + 20}] 873 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 1040 -tags steam_btn_disabled -label1 $s2 -label [translate "Steam"] 

		# stop button
		#dui add dbutton "espresso water steam hotwaterrinse" 2159 1216 2494 1566 -tags espresso_btn -symbol $s5  -label [translate "Stop"] -command {say [translate {Stop}] $::settings(sound_button_in); start_idle} 
		dui aspect set -theme default -type dbutton outline "#efd7db"
		dui aspect set -theme default -type dbutton fill "#efd7db"
		dui aspect set -theme default -type dbutton label_fill "#f9f8fc"
		dui aspect set -theme default -type dbutton_symbol fill "#f9f8fc"
		dui add dbutton "off" [expr {2560 - $ghc_pos_pffset + 20}] 1079 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 1246 -tags off_btn_disabled -symbol $s5  -label [translate "Stop"] -command {say [translate {Stop}] $::settings(sound_button_in); start_idle} 
		dui aspect set -theme default -type dbutton fill "#db515d"
		dui add dbutton "espresso water steam hotwaterrinse" [expr {2560 - $ghc_pos_pffset + 20}] 1079 [expr {2560 - $ghc_pos_pffset + 157 + 20}] 1246 -tags off_btn -symbol $s5  -label [translate "Stop"] -command {say [translate {Stop}] $::settings(sound_button_in); start_idle} 
	}
}

############################################################################################################################################################################################################

proc streamline_set_temperature_preset { slot } {
	set temperatures [ifexists ::settings(favorite_temperatures)]
	dict set temperatures $slot value $::settings(espresso_temperature)
	set ::settings(favorite_temperatures) $temperatures	
	save_settings	
	refresh_favorite_temperature_button_labels

	#.can itemconfigure temperature_${slot}_btn-btn -fill "#3e5682"
	#after 100 .can itemconfigure temperature_${slot}_btn-btn -fill "#efefef"
	#after 200 .can itemconfigure temperature_${slot}_btn-btn -fill "#3e5682"
	#after 300 .can itemconfigure temperature_${slot}_btn-btn -fill "#efefef"
	borg toast [translate "Saved"]
	
}


proc streamline_set_steam_preset { slot } {
	set steams [ifexists ::settings(favorite_steams)]
	dict set steams $slot value $::settings(steam_timeout)
	set ::settings(favorite_steams) $steams	
	save_settings	
	refresh_favorite_steam_button_labels

	#.can itemconfigure steam_${slot}_btn-btn -fill "#3e5682"
	#after 100 .can itemconfigure steam_${slot}_btn-btn -fill "#efefef"
	#after 200 .can itemconfigure steam_${slot}_btn-btn -fill "#3e5682"
	#after 300 .can itemconfigure steam_${slot}_btn-btn -fill "#efefef"
	borg toast [translate "Saved"]
	
}


proc streamline_set_flush_preset { slot } {
	set flushs [ifexists ::settings(favorite_flushs)]
	dict set flushs $slot value $::settings(flush_seconds)
	set ::settings(favorite_flushs) $flushs	
	save_settings	
	refresh_favorite_flush_button_labels

	#.can itemconfigure flush_${slot}_btn-btn -fill "#3e5682"
	#after 100 .can itemconfigure flush_${slot}_btn-btn -fill "#efefef"
	#after 200 .can itemconfigure flush_${slot}_btn-btn -fill "#3e5682"
	#after 300 .can itemconfigure flush_${slot}_btn-btn -fill "#efefef"
	borg toast [translate "Saved"]
	
}


proc streamline_set_hw_preset { slot }  {
	if {$::streamline_hotwater_btn_mode == "ml"} {
		streamline_set_hwvol_preset $slot
	} else {
		streamline_set_hwtemp_preset $slot
	}

	# optionally change the color temporarily of the label. Probably blinking rectangle would be better.
	#.can itemconfigure hw_${slot}_btn -fill "#375a92"
	#after 500 .can itemconfigure hw_${slot}_btn -fill "#777777"

	
}

proc streamline_set_hwvol_preset { slot } {
	set hwvols [ifexists ::settings(favorite_hwvols)]
	dict set hwvols $slot value $::settings(water_volume)
	set ::settings(favorite_hwvols) $hwvols	
	save_settings	
	streamline_hot_water_setting_change

	#.can itemconfigure hwvol_${slot}_btn-btn -fill "#3e5682"
	#after 100 .can itemconfigure hwvol_${slot}_btn-btn -fill "#efefef"
	#after 200 .can itemconfigure hwvol_${slot}_btn-btn -fill "#3e5682"
	#after 300 .can itemconfigure hwvol_${slot}_btn-btn -fill "#efefef"
	borg toast [translate "Saved"]
	
	refresh_favorite_hw_button_labels
}


proc streamline_set_hwtemp_preset { slot } {
	set hwtemps [ifexists ::settings(favorite_hwtemps)]
	dict set hwtemps $slot value $::settings(water_temperature)
	set ::settings(favorite_hwtemps) $hwtemps	
	save_settings	
	streamline_hot_water_setting_change

	#.can itemconfigure hwtemp_${slot}_btn-btn -fill "#3e5682"
	#after 100 .can itemconfigure hwtemp_${slot}_btn-btn -fill "#efefef"
	#after 200 .can itemconfigure hwtemp_${slot}_btn-btn -fill "#3e5682"
	#after 300 .can itemconfigure hwtemp_${slot}_btn-btn -fill "#efefef"
	borg toast [translate "Saved"]

	refresh_favorite_hw_button_labels	
}



proc streamline_set_dosebev_preset { slot } {
	set dosebevs [ifexists ::settings(favorite_dosebevs)]
	dict set dosebevs $slot value [round_to_two_digits $::settings(grinder_dose_weight)]
	dict set dosebevs $slot value2 [round_to_two_digits [determine_final_weight] ]
	set ::settings(favorite_dosebevs) $dosebevs	
	save_settings	
	refresh_favorite_dosebev_button_labels

	#.can itemconfigure dosebev_${slot}_btn-btn -fill "#3e5682"
	#after 100 .can itemconfigure dosebev_${slot}_btn-btn -fill "#efefef"
	#after 200 .can itemconfigure dosebev_${slot}_btn-btn -fill "#3e5682"
	#after 300 .can itemconfigure dosebev_${slot}_btn-btn -fill "#efefef"
	borg toast [translate "Saved"]
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


	set b1c "#d8d8d8"
	set b2c "#d8d8d8"
	set b3c "#d8d8d8"
	set b4c "#d8d8d8"

	set lb1c $::left_label_color
	set lb2c $::left_label_color
	set lb3c $::left_label_color
	set lb4c $::left_label_color


	if {$::settings(espresso_temperature) == [dict get $temperatures 1 value]} {
		set b1c "#3e5682"
		set lb1c "#000000"
	} 
	if {$::settings(espresso_temperature) == [dict get $temperatures 2 value]} {
		set b2c "#3e5682"
		set lb2c "#000000"
	} 
	if {$::settings(espresso_temperature) == [dict get $temperatures 3 value]} {
		set b3c "#3e5682"
		set lb3c "#000000"
	} 
	if {$::settings(espresso_temperature) == [dict get $temperatures 4 value]} {
		set b4c "#3e5682"
		set lb4c "#000000"
	}

	.can itemconfigure temperature_1_btn-lbl -fill $lb1c
	.can itemconfigure temperature_2_btn-lbl -fill $lb2c
	.can itemconfigure temperature_3_btn-lbl -fill $lb3c
	.can itemconfigure temperature_4_btn-lbl -fill $lb4c
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


	set b1c "#d8d8d8"
	set b2c "#d8d8d8"
	set b3c "#d8d8d8"
	set b4c "#d8d8d8"

	set lb1c $::left_label_color
	set lb2c $::left_label_color
	set lb3c $::left_label_color
	set lb4c $::left_label_color


	if {$::settings(steam_timeout) == [dict get $steams 1 value]} {
		set b1c "#3e5682"
		set lb1c "#000000"
	} 
	if {$::settings(steam_timeout) == [dict get $steams 2 value]} {
		set b2c "#3e5682"
		set lb2c "#000000"
	} 
	if {$::settings(steam_timeout) == [dict get $steams 3 value]} {
		set b3c "#3e5682"
		set lb3c "#000000"
	} 
	if {$::settings(steam_timeout) == [dict get $steams 4 value]} {
		set b4c "#3e5682"
		set lb4c "#000000"
	}

	.can itemconfigure steam_1_btn-lbl -fill $lb1c
	.can itemconfigure steam_2_btn-lbl -fill $lb2c
	.can itemconfigure steam_3_btn-lbl -fill $lb3c
	.can itemconfigure steam_4_btn-lbl -fill $lb4c
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



	set b1c "#d8d8d8"
	set b2c "#d8d8d8"
	set b3c "#d8d8d8"
	set b4c "#d8d8d8"

	set lb1c $::left_label_color
	set lb2c $::left_label_color
	set lb3c $::left_label_color
	set lb4c $::left_label_color

	set b1c2 "#d8d8d8"
	set b2c2 "#d8d8d8"
	set b3c2 "#d8d8d8"
	set b4c2 "#d8d8d8"

	set lb1c2 $::left_label_color
	set lb2c2 $::left_label_color
	set lb3c2 $::left_label_color
	set lb4c2 $::left_label_color


	if {$::streamline_hotwater_btn_mode == "ml"} {
		if {[round_to_two_digits $::settings(water_volume)] == [dict get $hwvols 1 value]} {
			set b1c "#3e5682"
			set lb1c "#000000"
		} 
		if {[round_to_two_digits $::settings(water_volume)] == [dict get $hwvols 2 value]} {
			set b2c "#3e5682"
			set lb2c "#000000"
		} 
		if {[round_to_two_digits $::settings(water_volume)] == [dict get $hwvols 3 value]} {
			set b3c "#3e5682"
			set lb3c "#000000"
		} 
		if {[round_to_two_digits $::settings(water_volume)] == [dict get $hwvols 4 value]} {
			set b4c "#3e5682"
			set lb4c "#000000"
		}
	} else {

		
		if {[round_to_two_digits $::settings(water_temperature)] == [dict get $hwtemps 1 value]} {
			set b1c "#3e5682"
			set lb1c "#000000"
		} 
		if {[round_to_two_digits $::settings(water_temperature)] == [dict get $hwtemps 2 value]} {
			set b2c "#3e5682"
			set lb2c "#000000"
		} 
		if {[round_to_two_digits $::settings(water_temperature)] == [dict get $hwtemps 3 value]} {
			set b3c "#3e5682"
			set lb3c "#000000"
		} 
		if {[round_to_two_digits $::settings(water_temperature)] == [dict get $hwtemps 4 value]} {
			set b4c "#3e5682"
			set lb4c "#000000"
		}
	}

	.can itemconfigure hw_1_btn -fill $lb1c
	.can itemconfigure hw_2_btn -fill $lb2c
	.can itemconfigure hw_3_btn -fill $lb3c
	.can itemconfigure hw_4_btn -fill $lb4c

	#.can itemconfigure hwtemp_1_btn-lbl -fill $lb1c2
	#.can itemconfigure hwtemp_2_btn-lbl -fill $lb2c2
	#.can itemconfigure hwtemp_3_btn-lbl -fill $lb3c2
	#.can itemconfigure hwtemp_4_btn-lbl -fill $lb4c2

}


proc OBSOLETE_refresh_favorite_hw_button_labels {} {

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

	set ::streamline_favorite_hwvol_buttons(label_1) "[return_liquid_measurement_ml $t1]"
	set ::streamline_favorite_hwvol_buttons(label_2) "[return_liquid_measurement_ml $t2]"
	set ::streamline_favorite_hwvol_buttons(label_3) "[return_liquid_measurement_ml $t3]"
	set ::streamline_favorite_hwvol_buttons(label_4) "[return_liquid_measurement_ml $t4]"

	set ::streamline_favorite_hwtemp_buttons(label_1) "[return_temperature_measurement $bt1 1]"
	set ::streamline_favorite_hwtemp_buttons(label_2) "[return_temperature_measurement $bt2 1]"
	set ::streamline_favorite_hwtemp_buttons(label_3) "[return_temperature_measurement $bt3 1]"
	set ::streamline_favorite_hwtemp_buttons(label_4) "[return_temperature_measurement $bt4 1]"


	set b1c "#d8d8d8"
	set b2c "#d8d8d8"
	set b3c "#d8d8d8"
	set b4c "#d8d8d8"

	set lb1c $::left_label_color
	set lb2c $::left_label_color
	set lb3c $::left_label_color
	set lb4c $::left_label_color

	set b1c2 "#d8d8d8"
	set b2c2 "#d8d8d8"
	set b3c2 "#d8d8d8"
	set b4c2 "#d8d8d8"

	set lb1c2 $::left_label_color
	set lb2c2 $::left_label_color
	set lb3c2 $::left_label_color
	set lb4c2 $::left_label_color


	
	if {[round_to_two_digits $::settings(water_volume)] == [dict get $hwvols 1 value]} {
		set b1c "#3e5682"
		set lb1c "#000000"
	} 
	if {[round_to_two_digits $::settings(water_volume)] == [dict get $hwvols 2 value]} {
		set b2c "#3e5682"
		set lb2c "#000000"
	} 
	if {[round_to_two_digits $::settings(water_volume)] == [dict get $hwvols 3 value]} {
		set b3c "#3e5682"
		set lb3c "#000000"
	} 
	if {[round_to_two_digits $::settings(water_volume)] == [dict get $hwvols 4 value]} {
		set b4c "#3e5682"
		set lb4c "#000000"
	}


	
	if {[round_to_two_digits $::settings(water_temperature)] == [dict get $hwtemps 1 value]} {
		set b1c2 "#3e5682"
		set lb1c2 "#000000"
	} 
	if {[round_to_two_digits $::settings(water_temperature)] == [dict get $hwtemps 2 value]} {
		set b2c2 "#3e5682"
		set lb2c2 "#000000"
	} 
	if {[round_to_two_digits $::settings(water_temperature)] == [dict get $hwtemps 3 value]} {
		set b3c2 "#3e5682"
		set lb3c2 "#000000"
	} 
	if {[round_to_two_digits $::settings(water_temperature)] == [dict get $hwtemps 4 value]} {
		set b4c2 "#3e5682"
		set lb4c2 "#000000"
	}

	.can itemconfigure hwvol_1_btn-lbl -fill $lb1c
	.can itemconfigure hwvol_2_btn-lbl -fill $lb2c
	.can itemconfigure hwvol_3_btn-lbl -fill $lb3c
	.can itemconfigure hwvol_4_btn-lbl -fill $lb4c

	.can itemconfigure hwtemp_1_btn-lbl -fill $lb1c2
	.can itemconfigure hwtemp_2_btn-lbl -fill $lb2c2
	.can itemconfigure hwtemp_3_btn-lbl -fill $lb3c2
	.can itemconfigure hwtemp_4_btn-lbl -fill $lb4c2

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


	set b1c "#d8d8d8"
	set b2c "#d8d8d8"
	set b3c "#d8d8d8"
	set b4c "#d8d8d8"

	set lb1c $::left_label_color
	set lb2c $::left_label_color
	set lb3c $::left_label_color
	set lb4c $::left_label_color


	
	if {[round_to_two_digits $::settings(grinder_dose_weight)] == [dict get $dosebevs 1 value] && [round_to_two_digits [determine_final_weight] ] == [dict get $dosebevs 1 value2]} {
		set b1c "#3e5682"
		set lb1c "#000000"
	} 
	if {[round_to_two_digits $::settings(grinder_dose_weight)] == [dict get $dosebevs 2 value] && [round_to_two_digits [determine_final_weight] ] == [dict get $dosebevs 2 value2]} {
		set b2c "#3e5682"
		set lb2c "#000000"
	} 
	if {[round_to_two_digits $::settings(grinder_dose_weight)] == [dict get $dosebevs 3 value] && [round_to_two_digits [determine_final_weight] ] == [dict get $dosebevs 3 value2]} {
		set b3c "#3e5682"
		set lb3c "#000000"
	} 
	if {[round_to_two_digits $::settings(grinder_dose_weight)] == [dict get $dosebevs 4 value] && [round_to_two_digits [determine_final_weight] ] == [dict get $dosebevs 4 value2]} {
		set b4c "#3e5682"
		set lb4c "#000000"
	}

	.can itemconfigure dosebev_1_btn-lbl -fill $lb1c
	.can itemconfigure dosebev_2_btn-lbl -fill $lb2c
	.can itemconfigure dosebev_3_btn-lbl -fill $lb3c
	.can itemconfigure dosebev_4_btn-lbl -fill $lb4c
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


	set b1c "#d8d8d8"
	set b2c "#d8d8d8"
	set b3c "#d8d8d8"
	set b4c "#d8d8d8"

	set lb1c $::left_label_color
	set lb2c $::left_label_color
	set lb3c $::left_label_color
	set lb4c $::left_label_color


	if {$::settings(flush_seconds) == [dict get $flushs 1 value]} {
		set b1c "#3e5682"
		set lb1c "#000000"
	} 
	if {$::settings(flush_seconds) == [dict get $flushs 2 value]} {
		set b2c "#3e5682"
		set lb2c "#000000"
	} 
	if {$::settings(flush_seconds) == [dict get $flushs 3 value]} {
		set b3c "#3e5682"
		set lb3c "#000000"
	} 
	if {$::settings(flush_seconds) == [dict get $flushs 4 value]} {
		set b4c "#3e5682"
		set lb4c "#000000"
	}

	.can itemconfigure flush_1_btn-lbl -fill $lb1c
	.can itemconfigure flush_2_btn-lbl -fill $lb2c
	.can itemconfigure flush_3_btn-lbl -fill $lb3c
	.can itemconfigure flush_4_btn-lbl -fill $lb4c
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
		set ::settings(espresso_temperature) [dict get $temperatures $slot value]

		# save the new selected button 
		dict set temperatures selected number $slot
		set ::settings(favorite_temperatures) $temperatures	
		save_profile_and_update_de1_soon	


	}

	refresh_favorite_temperature_button_labels
	streamline_blink_rounded_setting "temp_setting_rectangle" "temp_label_1st"

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
}

refresh_favorite_steam_button_labels


proc streamline_dosebev_select { slot } {
	puts "streamline_dosebev_select { $slot } "

	if {[dui page current] != "off"} {
		return ""
	}

	catch {
		# get the favoritae button values
		set dosebevs [ifexists ::settings(favorite_dosebevs)]

		# set the setting
		set ::settings(grinder_dose_weight) [dict get $dosebevs $slot value]

		# setting the final weight is more complicated, as it is stored in a few different places depending on the profile
		set desired_weight [dict get $dosebevs $slot value2]
		set weight_diff [expr {$desired_weight - [determine_final_weight]}]
		determine_final_weight $weight_diff

		# save the new selected button 
		dict set dosebevs selected number $slot
		set ::settings(favorite_dosebevs) $dosebevs	
		save_profile_and_update_de1_soon	


	}
	streamline_blink_rounded_setting "dose_setting_rectangle" "dose_label_1st"
	streamline_blink_rounded_setting "weight_setting_rectangle" "weight_label_1st"

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
}

proc streamline_blink_rounded_setting { rect txt } {
	.can itemconfigure $rect -fill "#395ab9"
	.can itemconfigure $txt -fill "#ffffff"
	after 400 .can itemconfigure $rect -fill "#f6f8fa"
	after 400 .can itemconfigure $txt -fill #121212

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

set ::pressurelinecolor "#17c29a"
set ::flow_line_color "#0358cf"
set ::pressurelinecolor_goal "#a0e0d1"
set ::flow_line_color_goal "#bed9ff"
set ::temperature_line_color "#ff97a1"
set ::temperature_line_color_goal "#ffd1d5"
#set ::weightlinecolor "#a06539"
set ::weightlinecolor "#e9d3c3"
set ::state_change_color "#7c7c7c"

set ::state_change_dashes "8 8"
set ::temp_goal_dashes "8 8"
set ::pressure_goal_dashes "4 4"
set ::flow_goal_dashes "4 4"

#set ::pressurelinecolor_god "#5deea6"
#set ::flow_line_color_god "#a7d1ff"
#set ::temperature_line_color_god "#ffafb4"
#set ::weightlinecolor_god "#edd4c1"
set ::chart_background "#FFFFFF"

set ::pressurelabelcolor "#959595"
set ::temperature_label_color "#959595"
set ::flow_label_color "#1767d4"
set ::grid_color "#E0E0E0"

set charts_width 1818



add_de1_widget $::pages graph 692 458 { 

	set ::streamline_chart $widget


	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color $::pressurelinecolor_goal  -smooth $::settings(live_graph_smoothing_technique)  -pixels 0 -dashes $::pressure_goal_dashes; 
	$widget element create line_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::pressurelinecolor  -smooth $::settings(live_graph_smoothing_technique) -pixels 0
	

	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color $::flow_line_color_goal -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes $::flow_goal_dashes; 
	$widget element create line_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::flow_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0

	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal10th -symbol none -label ""  -linewidth [rescale_x_skin 2] -color $::temperature_line_color_goal -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::temp_goal_dashes; 
	$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket10th -symbol none -label ""  -linewidth [rescale_x_skin 4] -color $::temperature_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0 


	$widget element create line_espresso_flow_weight  -xdata espresso_elapsed -ydata espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::weightlinecolor -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 

	# show the explanation
	#$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure  -label "" -linewidth [rescale_x_skin 15] -color $::pressurelinecolor  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 
	#$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -label "" -linewidth [rescale_x_skin 15] -color $::flow_line_color  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 
	#$widget element create line_espresso_de1_explanation_chart_temp -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_temperature  -label "" -linewidth [rescale_x_skin 15] -color $::temperature_line_color  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 

	gridconfigure $widget 

	$widget axis configure x -color $::pressurelabelcolor -tickfont Inter-Regular10 -linewidth [rescale_x_skin 1] -subdivisions 5 -majorticks {0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250} 
	$widget axis configure y -color $::pressurelabelcolor -tickfont Inter-Regular10 -min 0 -max 10 -subdivisions 5 -majorticks {1 2 3 4 5 6 7 8 9 10} 

	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 2] -color $::state_change_color  -pixels 0  -dashes $::state_change_dashes

} -plotbackground $::chart_background -width [rescale_x_skin [expr {$charts_width - $ghc_pos_pffset}]] -height [rescale_y_skin 784] -borderwidth 1 -background $::chart_background -plotrelief flat -plotpady 10 -plotpadx 10  
############################################################################################################################################################################################################


proc streamline_adjust_chart_x_axis {} {

	set widget $::streamline_chart
	#set sz [espresso_elapsed length]

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

add_de1_button "saver descaling cleaning" {say [translate {awake}] $::settings(sound_button_in); set_next_page off off; page_show off; start_idle; de1_send_waterlevel_settings;} 0 0 2560 1600 "buttonnativepress"

#add_de1_button "sleep" {say [translate {sleep}] $::settings(sound_button_in);set_next_page off off; after 1000 start_idle} 0 0 2560 1600


#after 1000 "show_settings settings_1"



	#puts "[homedir]/history/$current_shot_filename"
	#set past_shot [array get past_shot_array]

proc streamline_load_history_shot {current_shot_filename} {

	puts "ERROR streamline_load_history_shot"

#espresso_pressure length 0
#espresso_elapsed length 0

	array set past_shot_array [read_file "[homedir]/history/$current_shot_filename"]
	espresso_elapsed clear
	#puts $past_shot
	espresso_elapsed set [ifexists past_shot_array(espresso_elapsed)]



	#set ::settings(espresso_elapsed) [ifexists past_shot_array(espresso_elapsed)]
	#puts $::settings(espresso_elapsed)

	set ::de1(espresso_elapsed) [lindex [ifexists past_shot_array(espresso_elapsed)] end]
	#puts "final: $::de1(espresso_elapsed)"

	#puts "vec enc: [espresso_elapsed index [expr {[espresso_elapsed length]-1}]]"

	#espresso_elapsed clear
	#puts $past_shot
	#espresso_elapsed set [ifexists past_shot_array(espresso_elapsed)]
#	exit

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

	array set profile_data [ifexists past_shot_array(settings)]
	set ::streamline_current_history_profile_name [ifexists profile_data(profile_title)]

	#streamline_adjust_chart_x_axis
	#set ::streamline_current_history_profile_name [clock seconds]
	#exit
	streamline_adjust_chart_x_axis

}
proc streamline_load_currently_selected_history_shot {} {
	set current_shot_filename [lindex $::streamline_history_files $::streamline_history_file_selected_number]
	streamline_load_history_shot $current_shot_filename
}

proc streamline_init_history_files {} {
	set ::streamline_history_files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/history/" *.shot]]
	set ::streamline_history_file_selected_number [expr {[llength $::streamline_history_files] -1}]
}

proc streamline_history_profile_back {} {
	set ::streamline_history_file_selected_number [expr {$::streamline_history_file_selected_number	 - 1}]
	if {$::streamline_history_file_selected_number < 0} {
		set ::streamline_history_file_selected_number [expr {[llength $::streamline_history_files] -1}]
	}
	streamline_load_currently_selected_history_shot
}

proc streamline_history_profile_fwd {} {
	set ::streamline_history_file_selected_number [expr {$::streamline_history_file_selected_number	 + 1}]
	if {$::streamline_history_file_selected_number > [llength $::streamline_history_files]-1} {
		set ::streamline_history_file_selected_number 0
	}
	streamline_load_currently_selected_history_shot
}

streamline_init_history_files
streamline_load_currently_selected_history_shot
#	exit
