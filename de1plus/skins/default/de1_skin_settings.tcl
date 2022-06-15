
##############################################################################################################################################################################################################################################################################
# DE1 SETTINGS pages

##############################################################################################################################################################################################################################################################################
# the graphics for each of the main espresso machine modes


set settings_tab_font "Helv_10_bold"
set botton_button_font "Helv_10_bold"
set listbox_font "Helv_10"
if {[language] == "ar"} {
	set green_button_font "Helv_17_bold"
	set settings_tab_font "Helv_15_bold"
	set botton_button_font "Helv_15_bold"
	set listbox_font "Helv_7_bold"
} elseif {[language] == "he"} {
	set green_button_font "Helv_17_bold"
	set settings_tab_font "Helv_10_bold"
	set botton_button_font "Helv_12_bold"
	set listbox_font "Helv_8_bold"
} elseif {[language] == "zh-hans" || [language] == "zh-hant" || [language] == "kr"} {
	set green_button_font "Helv_17_bold"
	set settings_tab_font "Helv_15_bold"
	set botton_button_font "Helv_15_bold"
} elseif {[language] != "en" && [language] != "kr" && [language] != "zh-hans" && [language] != "zh-hant"} {
	set settings_tab_font "Helv_8_bold"
}

add_de1_page "settings_1" "settings_1.png" "default"

#add_de1_page "settings_2a" "settings_2a.png" "default"
#add_de1_page "settings_2b" "settings_2b.png" "default"
#if {$::settings(scale_bluetooth_address) == ""} {
#} else {
	add_de1_page "settings_2a" "settings_2a2.png" "default"
	add_de1_page "settings_2b" "settings_2b2.png" "default"
#}
add_de1_page "settings_2c" "settings_2c.png" "default"
add_de1_page "settings_2c2" "settings_2c2.png" "default"
add_de1_page "settings_2czoom" "settings_2c.png" "default"

if {$::settings(settings_profile_type) == "settings_2"} {
	# this happens if you switch to the de1 gui, which then saves the de1 settings default, so we need to reset it to this de1+ default
	set ::settings(settings_profile_type) "settings_2a"
}


add_de1_page "settings_3" "settings_3.png" "default"
add_de1_page "settings_4" "settings_4.png" "default"

set ::settings(minimum_water_temperature) 1	


#set ::active_settings_tab settings_1

# this is the message page
set ::message_label [add_de1_text "message" 1280 800 -text "" -font Helv_15_bold -fill "#2d3046" -justify "center" -anchor "center" -width 1000]
set ::message_longertxt [add_de1_text "message" 1280 875 -text "" -font Helv_6 -fill "#2d3046" -justify "center" -anchor "center" -width 1000]
set ::message_button_label [add_de1_text "message" 1280 1310 -text "" -font Helv_10_bold -fill "#fAfBff" -anchor "center"]
set ::message_button [add_de1_button "message" {say [translate {Quit}] $::settings(sound_button_in); exit} 980 1210 1580 1410 ""]

set ::infopage_label [add_de1_text "infopage" 1280 800 -text "" -font Helv_10_bold -fill "#2d3046" -justify "center" -anchor "center" -width 900]
set ::infopage_button_label [add_de1_text "infopage" 1280 1310 -text "" -font Helv_10_bold -fill "#fAfBff" -anchor "center"]
set ::infopage_button [add_de1_button "infopage" {say [translate {Ok}] $::settings(sound_button_in); page_show off} 980 1210 1580 1410 ""]

set ::versionpage_label [add_de1_text "versionpage" 1280 800 -text "" -font Helv_10_bold -fill "#2d3046" -justify "center" -anchor "center" -width 900]
set ::versionpage_button_label [add_de1_text "versionpage" 1280 1310 -text "" -font Helv_10_bold -fill "#fAfBff" -anchor "center"]
set ::versionpage_link [add_de1_button "versionpage" {if {[ifexists ::changelog_link] != ""} {web_browser $::changelog_link}} 80 60 2480 1160  ""]
set ::versionpage_button [add_de1_button "versionpage" {say [translate {Ok}] $::settings(sound_button_in); set_next_page off off; page_show off} 980 1210 1580 1410 ""]

set slider_trough_color #EAEAEA
set chart_background_color #F8F8F8
##############################################################################################################################################################################################################################################################################

proc set_scrollbar_dimensions { scrollbar_widget listbox_widget } {	
	# set the height of the scrollbar to be the same as the listbox, and locate it on its right side.
	# BEWARE this depends on the canvas being able to retrieve the 2 widgets by pathname instead of tag or id.
	# Listbox height is exactly 1 whenever it has not been drawn yet.	
	lassign [.can bbox $listbox_widget] x0 y0 x1 y1
	if { [expr {$y1-$y0}] > 1 } {
		$scrollbar_widget configure -length [expr {$y1-$y0}]
		.can coords $scrollbar_widget [list $x1 $y0]
	}	
}

############################
# pressure controlled shots

proc settings_flow_label {} {
	if {$::settings(maximum_flow) > 0} {
		return "$::settings(maximum_flow) [translate "mL/s"]"
	}
	return [translate "off"]
}

# preinfusing
add_de1_text "settings_2a settings_2b" 45 755 -text [translate "1: preinfuse"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
	# pressure profile preinfusion
	add_de1_widget "settings_2a" scale 47 850 {} -from 0 -to 60 -background $::settings(color_stage_1) -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 600] -width [rescale_y_skin 150] -variable ::settings(preinfusion_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 
	add_de1_variable "settings_2a" 47 1000 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[canvas_hide_if_zero $::settings(preinfusion_time) [list $::preinfusion_pressure_widget $::preinfusion_pressure_widget_label $::preinfusion_pressure_flow_widget $::preinfusion_pressure_flow_widget_label];  preinfusion_seconds_text $::settings(preinfusion_time)]}

	set ::preinfusion_pressure_widget [add_de1_widget "settings_2a" scale 670 850 {} -from $::de1(maxpressure) -to 0 -background $::settings(color_stage_1) -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution .1 -length [rescale_y_skin 470] -width [rescale_y_skin 150] -variable ::settings(preinfusion_stop_pressure) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 ]
	set ::preinfusion_pressure_widget_label [add_de1_variable "settings_2a" 820 1325 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {< $::settings(preinfusion_stop_pressure) [translate bar]}]
	add_de1_button "settings_2a" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(preinfusion_stop_pressure) -n_decimals 1 -min 1 -max $::de1(maxpressure) -default $::settings(preinfusion_stop_pressure) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Pressure"] -return_callback profile_has_changed_set  } 650 1325 840 1425 ""   
	

	# flow profile preinfusion
	add_de1_widget "settings_2b" scale 47 850 {} -from 0 -to 60 -background $::settings(color_stage_1) -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 600] -width [rescale_y_skin 150] -variable ::settings(preinfusion_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 
	add_de1_variable "settings_2b" 47 1000 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[canvas_hide_if_zero $::settings(preinfusion_time) [list $::preinfusion_flow_widget $::preinfusion_flow_widget_label $::preinfusion_flow_pressure_widget $::preinfusion_flow_pressure_widget_label];  preinfusion_seconds_text $::settings(preinfusion_time)]}
	add_de1_button "settings_2a settings_2b" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(preinfusion_time) -n_decimals 0 -min 1 -max 60 -default $::settings(preinfusion_time) -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Time"] -return_callback profile_has_changed_set  } 37 1000 600 1100 ""   



	#add_de1_button "settings_2b" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(preinfusion_time) -n_decimals 0 -min 1 -max 60 -default $::settings(preinfusion_time) -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Time"] -return_callback profile_has_changed_set  } 37 1000 600 1100 ""   
	
	set ::preinfusion_flow_widget [add_de1_widget "settings_2b" scale 670 850 {} -from $::de1(max_flowrate_v11) -to 0 -tickinterval 0  -showvalue 0 -background $::settings(color_stage_1)  -bigincrement 1 -resolution 0.1 -length [rescale_y_skin 470] -width [rescale_y_skin 150] -variable ::settings(preinfusion_flow_rate) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #000000 -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 ]
	set ::preinfusion_flow_widget_label [add_de1_variable "settings_2b" 820 1325 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_flow_measurement $::settings(preinfusion_flow_rate)]}]



	set ::preinfusion_flow_pressure_widget [add_de1_widget "settings_2b" scale 47 1115 {} -to $::de1(maxpressure) -from 0  -background $::settings(color_stage_1) -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution .1 -length [rescale_x_skin 600] -width [rescale_y_skin 150] -variable ::settings(preinfusion_stop_pressure) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal ]
	set ::preinfusion_flow_pressure_widget_label [add_de1_variable "settings_2b" 47 1265 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {< $::settings(preinfusion_stop_pressure) [translate bar]}]
	add_de1_button "settings_2b" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(preinfusion_stop_pressure) -n_decimals 1 -min 1 -max $::de1(maxpressure) -default $::settings(preinfusion_stop_pressure) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Pressure"] -return_callback profile_has_changed_set  } 37 1265 437 1345 ""   

	set ::preinfusion_pressure_flow_widget [add_de1_widget "settings_2a" scale 47 1175 {} -to $::de1(max_flowrate_v11) -from 0 -tickinterval 0  -showvalue 0 -background $::settings(color_stage_1)  -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 600] -width [rescale_y_skin 150] -variable ::settings(preinfusion_flow_rate) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #000000 -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal ]
	set ::preinfusion_pressure_flow_widget_label [add_de1_variable "settings_2a" 47 1325 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[return_flow_measurement $::settings(preinfusion_flow_rate)]}]

	add_de1_button "settings_2a" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(preinfusion_flow_rate) -n_decimals 1 -min 1 -max $::de1(max_flowrate_v11) -default $::settings(preinfusion_flow_rate) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Flow rate"] -return_callback profile_has_changed_set  } 37 1325 547 1425 ""   
	add_de1_button "settings_2b" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(preinfusion_flow_rate) -n_decimals 1 -min 1 -max $::de1(max_flowrate_v11) -default $::settings(preinfusion_flow_rate) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Flow rate"] -return_callback profile_has_changed_set  } 650 1325 840 1425 ""   


add_de1_text "settings_2a" 890 755 -text [translate "2: rise and hold"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
	add_de1_widget "settings_2a" scale 892 850 {} -from 0 -to 60 -background $::settings(color_stage_2) -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 600] -width [rescale_y_skin 150] -variable ::settings(espresso_hold_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 
	add_de1_variable "settings_2 settings_2a" 892 1000 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[canvas_hide_if_zero $::settings(espresso_hold_time) [list $::espresso_pressure_widget $::espresso_pressure_widget_label]; seconds_text $::settings(espresso_hold_time)]}


	#add_de1_text "settings_2 settings_2a" 942 1000 -text "-" -font Helv_8 -fill "#888888" -anchor "nw" -width 600 -justify "left" 
	#add_de1_text "settings_2 settings_2a" 1440 1000 -text "+" -font Helv_8 -fill "#888888" -anchor "ne" -width 600 -justify "left" 
	#add_de1_button "settings_2a" {say [translate {minus}] $::settings(sound_button_in); incr ::settings(espresso_hold_time) -1; profile_has_changed_set; update_de1_explanation_chart_soon} 892 1000 1100 1200 
	#add_de1_button "settings_2a" {say [translate {plus}] $::settings(sound_button_in); incr ::settings(espresso_hold_time); profile_has_changed_set; update_de1_explanation_chart_soon } 1290 1000 1490 1200

	set ::espresso_pressure_widget [add_de1_widget "settings_2a" scale 1516 850 {} -to 0 -from $::de1(maxpressure) -tickinterval 0  -showvalue 0 -background $::settings(color_stage_2)  -bigincrement 1 -resolution 0.1 -length [rescale_y_skin 470] -width [rescale_y_skin 150] -variable ::settings(espresso_pressure) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #000000 -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0]
	set ::espresso_pressure_widget_label [add_de1_variable "settings_2 settings_2a" 1667 1325 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_pressure_measurement $::settings(espresso_pressure)]}]
	add_de1_button "settings_2a" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(espresso_pressure) -n_decimals 1 -min 1 -max $::de1(maxpressure) -default $::settings(espresso_pressure) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Pressure"] -return_callback profile_has_changed_set  } 1500 1325 1680 1405 ""   
	add_de1_button "settings_2a" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(espresso_) -n_decimals 1 -min 1 -max $::de1(max_flowrate) -default $::settings(espresso_pressure) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Pressure"] -return_callback profile_has_changed_set  } 1500 1325 1680 1405 ""   



# Flow limit
add_de1_text "settings_2a" 890 1120 -text [translate "Limit flow"] -font Helv_8_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
	add_de1_widget "settings_2a" scale 892 1175 {} -from 0 -to 8 -background $::settings(color_stage_2)  -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 546] -width [rescale_y_skin 150] -variable ::settings(maximum_flow) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "" -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0  -command "profile_has_changed_set"
	add_de1_button "settings_2a" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(maximum_flow) -n_decimals 1 -min 1 -max $::de1(max_flowrate_v11) -default $::settings(maximum_flow) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Flow rate"] -return_callback profile_has_changed_set  } 882 1325 1372 1425 ""   
	add_de1_button "settings_2b" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(maximum_pressure) -n_decimals 1 -min 1 -max $::de1(max_pressure) -default $::settings(maximum_pressure) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Pressyre"] -return_callback profile_has_changed_set  } 882 1325 1372 1425 ""   


add_de1_variable "settings_2a" 892 1325 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[settings_flow_label]}


add_de1_text "settings_2 settings_2a" 1730 755 -text [translate "3: decline"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
	add_de1_widget "settings_2 settings_2a" scale 1730 850 {} -from 0 -to 60 -background $::settings(color_stage_3) -borderwidth 1 -showvalue 0 -bigincrement 1 -resolution 1 -length [rescale_x_skin 605] -width [rescale_y_skin 150] -variable ::settings(espresso_decline_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 
	add_de1_variable "settings_2 settings_2a" 1735 1000 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[canvas_hide_if_zero $::settings(espresso_decline_time) [list $::espresso_pressure_decline_widget $::espresso_pressure_decline_widget_label]; seconds_text $::settings(espresso_decline_time)]}

	
	set ::espresso_pressure_decline_widget [add_de1_widget "settings_2a" scale 2360 850 {} -from $::de1(maxpressure) -to 0 -background $::settings(color_stage_3) -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 0.1 -length [rescale_y_skin 470]  -width [rescale_y_skin 150] -variable ::settings(pressure_end) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 ]
	set ::espresso_pressure_decline_widget_label [add_de1_variable "settings_2 settings_2a" 2510 1325 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_pressure_measurement $::settings(pressure_end)]}]
	add_de1_button "settings_2a" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(pressure_end) -n_decimals 1 -min 1 -max $::de1(max_pressure) -default $::settings(pressure_end) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Pressure"] -return_callback profile_has_changed_set  } 2350 1325 2550 1405 ""   

# display each temperature step, and if you tap on a number, allow editing of all at once
add_de1_button "settings_2a settings_2b" {say [translate {temperature}] $::settings(sound_button_in); change_espresso_temperature 0.5; profile_has_changed_set } 2404 192 2590 320
	add_de1_button "settings_2a settings_2b" {say [translate {temperature}] $::settings(sound_button_in); change_espresso_temperature -0.5; profile_has_changed_set } 2404 600 2590 730
	add_de1_button "settings_2a settings_2b" {say [translate {temperature}] $::settings(sound_button_in); ; toggle_espresso_steps_option; profile_has_changed_set; } 2404 370 2590 560

	add_de1_variable "settings_2a settings_2b" 2470 600 -text "" -font Helv_8_bold -fill "#4e85f4" -anchor "center" -textvariable {[round_and_return_temperature_setting ::settings(espresso_temperature)]}
	add_de1_variable "settings_2a settings_2b" 820 760 -text "" -font Helv_8_bold -fill "#4e85f4" -anchor "ne" -textvariable {[if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} { return [subst {[round_and_return_step_temperature_setting ::settings(espresso_temperature_0)] / [round_and_return_step_temperature_setting ::settings(espresso_temperature_1)]}]} else {return ""}]}
	#add_de1_variable "settings_2a settings_2b" 674 790 -text "" -font Helv_8 -fill "#AAAAAA" -anchor "center" -textvariable {[if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} { return "/" } else { return "" }]}
	#add_de1_variable "settings_2a settings_2b" 744 790 -text "" -font Helv_8 -fill "#4e85f4" -anchor "center" -textvariable {[round_and_return_step_temperature_setting ::settings(espresso_temperature_1)]}
	add_de1_variable "settings_2a settings_2b" 1666 760 -text "" -font Helv_8_bold -fill "#4e85f4" -anchor "ne" -textvariable {[round_and_return_step_temperature_setting ::settings(espresso_temperature_2)]}
	add_de1_variable "settings_2a settings_2b" 2510 760 -text "" -font Helv_8_bold -fill "#4e85f4" -anchor "ne" -textvariable {[round_and_return_step_temperature_setting ::settings(espresso_temperature_3)]}

	add_de1_button "settings_2a settings_2b" {say [translate {temperature}] $::settings(sound_button_in); if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} { page_to_show_when_off temperature_steps } } 500 750 840 830
	add_de1_button "settings_2a settings_2b" {say [translate {temperature}] $::settings(sound_button_in); if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} { page_to_show_when_off temperature_steps } } 1460 750 1680 830
	add_de1_button "settings_2a settings_2b" {say [translate {temperature}] $::settings(sound_button_in); if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} { page_to_show_when_off temperature_steps } } 2300 750 2530 830


add_de1_text "temperature_steps" 1280 290 -text [translate "Temperature Steps"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center" 
	add_de1_text "temperature_steps" 1280 1310 -text [translate "Done"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"
	add_de1_button "temperature_steps" {say [translate {Done}] $::settings(sound_button_in); set ::settings(espresso_temperature) $::settings(espresso_temperature_0); profile_has_changed_set; page_to_show_when_off $::settings(settings_profile_type); } 980 1210 1580 1410 ""
	add_de1_widget "temperature_steps" scale 800 460 {} -from -30 -to 135 -background $::settings(color_stage_2) -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 0.5 -length [rescale_x_skin 970] -width [rescale_y_skin 150] -variable ::settings(espresso_temperature_0) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "" -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -command "range_check_shot_variables; profile_has_changed_set; update_de1_explanation_chart_soon"
	add_de1_widget "temperature_steps" scale 800 640 {} -from -30 -to 135 -background $::settings(color_stage_2) -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 0.5 -length [rescale_x_skin 970] -width [rescale_y_skin 150] -variable ::settings(espresso_temperature_1) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "" -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -command "range_check_shot_variables; profile_has_changed_set; update_de1_explanation_chart_soon"
	add_de1_widget "temperature_steps" scale 800 820 {} -from -30 -to 135 -background $::settings(color_stage_2) -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 0.5 -length [rescale_x_skin 970] -width [rescale_y_skin 150] -variable ::settings(espresso_temperature_2) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "" -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -command "range_check_shot_variables; profile_has_changed_set; update_de1_explanation_chart_soon"
	add_de1_widget "temperature_steps" scale 800 1000 {} -from -30 -to 135 -background $::settings(color_stage_2) -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 0.5 -length [rescale_x_skin 970] -width [rescale_y_skin 150] -variable ::settings(espresso_temperature_3) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "" -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -command "range_check_shot_variables; profile_has_changed_set; update_de1_explanation_chart_soon"
	add_de1_text "temperature_steps" 780 500 -text [translate "Start"] -font Helv_10_bold -fill "#444444" -anchor "ne"
	add_de1_text "temperature_steps" 780 680 -text [translate "Preinfusion"] -font Helv_10_bold -fill "#444444" -anchor "ne"
	add_de1_text "temperature_steps" 780 860 -text [translate "Hold"] -font Helv_10_bold -fill "#444444" -anchor "ne"
	add_de1_text "temperature_steps" 780 1040 -text [translate "Decline"] -font Helv_10_bold -fill "#444444" -anchor "ne"

	add_de1_variable "temperature_steps" 1800 500 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -textvariable {[round_and_return_step_temperature_setting ::settings(espresso_temperature_0)]}
	add_de1_variable "temperature_steps" 1800 680 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -textvariable {[round_and_return_step_temperature_setting ::settings(espresso_temperature_1)]}
	add_de1_variable "temperature_steps" 1800 860 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -textvariable {[round_and_return_step_temperature_setting ::settings(espresso_temperature_2)]}
	add_de1_variable "temperature_steps" 1800 1040 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -textvariable {[round_and_return_step_temperature_setting ::settings(espresso_temperature_3)]}

############################
# flow controlled shots

proc settings_pressure_label {} {
	if {$::settings(maximum_pressure) > 0 && $::settings(maximum_pressure) != {}} {
		return "$::settings(maximum_pressure) [translate "bar"]"
	}
	return [translate "off"]
}


add_de1_text "settings_2b" 890 755 -text [translate "2: hold"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
	add_de1_widget "settings_2b" scale 892 850 {} -from 0 -to 60 -background $::settings(color_stage_2) -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 600] -width [rescale_y_skin 150] -variable ::settings(espresso_hold_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 
	add_de1_variable "settings_2b" 892 1000 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[canvas_hide_if_zero $::settings(espresso_hold_time) [list $::flow_hold_widget $::flow_hold_widget_label]; seconds_text $::settings(espresso_hold_time)]}
	add_de1_button "settings_2 settings_2a settings_2b" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(espresso_hold_time) -n_decimals 0 -min 1 -max 60 -default $::settings(espresso_hold_time) -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Time"] -return_callback profile_has_changed_set  } 882 1000 1400 1100 ""   

	set ::flow_hold_widget [add_de1_widget "settings_2b" scale 1516 850 {} -from $::de1(max_flowrate_v11) -to 0 -tickinterval 0  -showvalue 0 -background $::settings(color_stage_2)  -bigincrement 1 -resolution 0.1 -length [rescale_y_skin 470] -width [rescale_y_skin 150] -variable ::settings(flow_profile_hold) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #000000 -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 ]
	set ::flow_hold_widget_label [add_de1_variable "settings_2b" 1667 1325 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_flow_measurement $::settings(flow_profile_hold)]}]
	add_de1_button "settings_2b" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(flow_profile_hold) -n_decimals 1 -min 1 -max $::de1(max_flowrate_v11) -default $::settings(flow_profile_hold) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Flow rate"] -return_callback profile_has_changed_set  } 1500 1325 1700 1405 ""   

add_de1_text "settings_2b" 890 1120 -text [translate "Limit pressure"] -font Helv_8_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
	add_de1_widget "settings_2b" scale 892 1175 {} -from 0 -to 12 -background $::settings(color_stage_2)  -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 546] -width [rescale_y_skin 150] -variable ::settings(maximum_pressure) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "" -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -command "profile_has_changed_set"
	add_de1_variable "settings_2b" 892 1325 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[settings_pressure_label]}

add_de1_text "settings_2b" 1730 755 -text [translate "3: decline"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
	add_de1_widget "settings_2b" scale 1730 850 {} -from 0 -to 60 -background $::settings(color_stage_3) -borderwidth 1 -showvalue 0 -bigincrement 1 -resolution 1 -length [rescale_x_skin 600] -width [rescale_y_skin 150] -variable ::settings(espresso_decline_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 
	add_de1_variable "settings_2b" 1735 1000 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[canvas_hide_if_zero $::settings(espresso_decline_time) [list $::flow_decline_widget $::flow_decline_widget_label]; seconds_text $::settings(espresso_decline_time)]}
	add_de1_button "settings_2 settings_2a settings_2b" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(espresso_decline_time) -n_decimals 0 -min 1 -max 60 -default $::settings(espresso_decline_time) -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Time"] -return_callback profile_has_changed_set  } 1720 1000 2300 1100 ""   
	
	set ::flow_decline_widget [add_de1_widget "settings_2b" scale 2360 850 {} -from $::de1(max_flowrate_v11) -to 0  -background $::settings(color_stage_3) -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 0.1 -length [rescale_y_skin 470]  -width [rescale_y_skin 150] -variable ::settings(flow_profile_decline) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 ]
	set ::flow_decline_widget_label [add_de1_variable "settings_2b" 2510 1325 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_flow_measurement $::settings(flow_profile_decline)]}]
	add_de1_button "settings_2b" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(flow_profile_decline) -n_decimals 1 -min 1 -max $::de1(max_flowrate_v11) -default $::settings(flow_profile_decline) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Flow rate"] -return_callback profile_has_changed_set  } 2340 1325 2610 1405 ""   


add_de1_widget "settings_2b" graph 24 220 { 
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 5] -color #888888  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max 8.5 -majorticks {0 1 2 3 4 5 6 7 8} -title [translate "Flow rate"] -titlefont Helv_10 -titlecolor #5a5d75;
	$widget element create line_espresso_de1_explanation_chart_flow_part1 -xdata espresso_de1_explanation_chart_elapsed_flow_1 -ydata espresso_de1_explanation_chart_flow_1 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part2 -xdata espresso_de1_explanation_chart_elapsed_flow_2 -ydata espresso_de1_explanation_chart_flow_2 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part3 -xdata espresso_de1_explanation_chart_elapsed_flow_3 -ydata espresso_de1_explanation_chart_flow_3 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 

	bind $widget [platform_button_press] { 
		say [translate {refresh chart}] $::settings(sound_button_in); 
		update_de1_explanation_chart
	} 
} -plotbackground $chart_background_color -width [rescale_x_skin 2375] -height [rescale_y_skin 500] -borderwidth 1 -background #FFFFFF -plotrelief raised -plotpady 0 -plotpadx 10

############################


# preheat tank temperature
add_de1_text "settings_2c2" 70 230 -text [translate "Preheat water tank"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "center"
	add_de1_widget "settings_2c2" scale 70 300 {} -to 45 -from 0 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 2400]  -width [rescale_y_skin 120] -variable ::settings(tank_desired_water_temperature) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
	add_de1_variable "settings_2c2" 70 420 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[return_temperature_setting_or_off $::settings(tank_desired_water_temperature)]}
	add_de1_button "settings_2c2" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(tank_desired_water_temperature) -n_decimals 0 -min 1 -max 45 -default $::settings(tank_desired_water_temperature) -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Preheat water tank"] -return_callback callback_after_adv_profile_data_entry  } 50 210 600 294 ""   
	add_de1_button "settings_2c2" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(tank_desired_water_temperature) -n_decimals 0 -min 1 -max 45 -default $::settings(tank_desired_water_temperature) -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Preheat water tank"] -return_callback callback_after_adv_profile_data_entry  } 50 424 600 500 ""   



# total water volume stopping of shots
add_de1_text "settings_2c2" 70 530 -text [translate "Stop at water volume"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "center"
	add_de1_widget "settings_2c2" scale 70 600 {} -to 2000 -from 0 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 1500]  -width [rescale_y_skin 120] -variable ::settings(final_desired_shot_volume_advanced) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
	add_de1_variable "settings_2c2" 70 720 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[return_stop_at_volume_measurement $::settings(final_desired_shot_volume_advanced)]}
	add_de1_button "settings_2c2" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(final_desired_shot_volume_advanced) -n_decimals 0 -min 1 -max 2000 -default $::settings(final_desired_shot_volume_advanced) -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Stop at water volume"] -return_callback callback_after_adv_profile_data_entry  } 50 504 600 592 ""   
	add_de1_button "settings_2c2" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(final_desired_shot_volume_advanced) -n_decimals 0 -min 1 -max 2000 -default $::settings(final_desired_shot_volume_advanced) -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Stop at water volume"] -return_callback callback_after_adv_profile_data_entry  } 50 722 600 798 ""   


#	dui add dclicker "settings_2c2" 1670 930 -bwidth 610  -bheight 75 -tags final_desired_shot_volume_advanced -orient h -style default \
#		-labelvariable {[return_stop_at_volume_measurement $::settings(final_desired_shot_volume_advanced)]} \
#		-variable ::settings(final_desired_shot_volume_advanced) -min 0 -max 2000 -default 5 -n_decimals 0 \
#		-smallincrement 1 -bigincrement 10 -editor_page yes -editor_page_title [translate "Stop at water volume"]	
	
	add_de1_text "settings_2c2" 1670 530 -text [translate "Track water volume"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "center"
	add_de1_widget "settings_2c2" scale 1670 600 {} -to 10 -from 0 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 800]  -width [rescale_y_skin 120] -variable ::settings(final_desired_shot_volume_advanced_count_start) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
	add_de1_variable "settings_2c2" 1670 720 -text "" -font Helv_8 -fill "#7f879a" -anchor "nw" -width 600 -justify "left" -textvariable {[when_to_start_pour_tracking_advanced]}

proc apply_range_to_all_steps {ignored} {
	set new_profile {}
	foreach step $::settings(advanced_shot) {
		array set step_array $step
		if {$step_array(pump) == "pressure"} {
			set value $::settings(maximum_flow_range_advanced)
		} else {
			set value $::settings(maximum_pressure_range_advanced)
		}
		set step_array(max_flow_or_pressure_range) $value
		lappend new_profile [array get step_array]
	}
	set ::settings(advanced_shot) $new_profile
	profile_has_changed_set
}

# limits
add_de1_text "settings_2c2" 70 830 -text [translate "Limit flow range"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "center"
add_de1_widget "settings_2c2" scale 70 900  {} -from 0 -to 8  -background $::settings(color_stage_2)  -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 700] -width [rescale_y_skin 120] -variable ::settings(maximum_flow_range_advanced)     -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "apply_range_to_all_steps" -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
add_de1_variable "settings_2c2" 70 1020 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(maximum_flow_range_advanced) mL/s}
add_de1_button "settings_2c2" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(maximum_flow_range_advanced) -n_decimals 1 -min 0.1 -max 8 -default $::settings(maximum_flow_range_advanced) -smallincrement 0.1 -bigincrement 1 -use_biginc 1 -page_title [translate "Limit flow range"] -return_callback callback_after_adv_profile_data_entry  } 50 830 600 894 ""   
add_de1_button "settings_2c2" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(maximum_flow_range_advanced) -n_decimals 1 -min 0.1 -max 8 -default $::settings(maximum_flow_range_advanced) -smallincrement 0.1 -bigincrement 1 -use_biginc 1 -page_title [translate "Limit flow range"] -return_callback callback_after_adv_profile_data_entry  } 50 1024 600 1100 ""   



add_de1_text "settings_2c2" 800 830 -text [translate "Limit pressure range"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "center"
add_de1_widget "settings_2c2" scale 800 900 {} -from 0 -to 8 -background $::settings(color_stage_2)  -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 700] -width [rescale_y_skin 120] -variable ::settings(maximum_pressure_range_advanced) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "apply_range_to_all_steps" -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
add_de1_variable "settings_2c2" 800 1020 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(maximum_pressure_range_advanced) bar}
add_de1_button "settings_2c2" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(maximum_pressure_range_advanced) -n_decimals 1 -min 0.1 -max 8 -default $::settings(maximum_pressure_range_advanced) -smallincrement 0.1 -bigincrement 1 -use_biginc 1 -page_title [translate "Limit pressure range"] -return_callback callback_after_adv_profile_data_entry  } 780 830 1330 894 ""   
add_de1_button "settings_2c2" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(maximum_pressure_range_advanced) -n_decimals 1 -min 0.1 -max 8 -default $::settings(maximum_pressure_range_advanced) -smallincrement 0.1 -bigincrement 1 -use_biginc 1 -page_title [translate "Limit pressure range"] -return_callback callback_after_adv_profile_data_entry  } 780 1024 1330 1100 ""   


# (beta) weight based shot ending, only displayed if a skale is connected
if {$::settings(scale_bluetooth_address) != ""} {
	add_de1_text "settings_2a settings_2b" 1730 1100 -text [translate "4: stop at weight:"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "center"
	add_de1_widget "settings_2a settings_2b" scale 1730 1175 {} -to 100 -from 0 -background $::settings(color_stage_3)  -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 0.2 -length [rescale_x_skin 546]  -width [rescale_y_skin 150] -variable ::settings(final_desired_shot_weight) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
	add_de1_variable "settings_2a settings_2b" 1730 1325 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[return_stop_at_weight_measurement $::settings(final_desired_shot_weight)]}

	add_de1_button "settings_2a settings_2b" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(final_desired_shot_weight) -n_decimals 1 -min 1 -max 100 -default $::settings(final_desired_shot_weight) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Pressure"] -return_callback profile_has_changed_set  } 1720 1325 2110 1405 ""   


	# 1/18/19 support for weight-bsaed ending of advanced shots
	add_de1_text "settings_2c2" 70 1130 -text [translate "Stop at weight"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "center"
	add_de1_widget "settings_2c2" scale 70 1200 {} -to 2000 -from 0 -background $::settings(color_stage_3)  -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 0.2 -length [rescale_x_skin 2400]  -width [rescale_y_skin 120] -variable ::settings(final_desired_shot_weight_advanced) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
	add_de1_variable "settings_2c2" 70 1320 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[return_stop_at_weight_measurement $::settings(final_desired_shot_weight_advanced)]}

	add_de1_button "settings_2c2" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(final_desired_shot_weight_advanced) -n_decimals 1 -min 0.1 -max 2000 -default $::settings(final_desired_shot_weight_advanced) -smallincrement 0.1 -bigincrement 1 -use_biginc 1 -page_title [translate "Stop at weight"] -return_callback callback_after_adv_profile_data_entry  } 50 1130 600 1194 ""   
	add_de1_button "settings_2c2" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(final_desired_shot_weight_advanced) -n_decimals 1 -min 0.1 -max 2000 -default $::settings(final_desired_shot_weight_advanced) -smallincrement 0.1 -bigincrement 1 -use_biginc 1 -page_title [translate "Stop at weight"] -return_callback callback_after_adv_profile_data_entry  } 50 1324 600 1400 ""   


} else {
	add_de1_text "settings_2a settings_2b" 1730 1100 -text [translate "4: stop at pour:"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "center"
	add_de1_widget "settings_2a settings_2b" scale 1730 1175 {} -to 100 -from 0 -background $::settings(color_stage_3)  -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 546]  -width [rescale_y_skin 150] -variable ::settings(final_desired_shot_volume) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "profile_has_changed_set; update_de1_explanation_chart_soon" -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
	add_de1_variable "settings_2a settings_2b" 1730 1325 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[return_stop_at_volume_measurement $::settings(final_desired_shot_volume)]}
}


add_de1_text "settings_2c settings_2c2 settings_2czoom" 240 1485 -text [translate "Steps"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
add_de1_text "settings_2c settings_2c2 settings_2czoom" 735 1485 -text [translate "Limits"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
#add_de1_text "settings_2c" 1220 1485 -text [translate "Advanced"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

add_de1_button "settings_2c2 settings_2czoom" {say [translate {Steps}] $::settings(sound_button_in); set ::settings(settings_profile_type) "settings_2c"; set_next_page off $::settings(settings_profile_type); page_show off; update_de1_explanation_chart; set ::settings(active_settings_tab) $::settings(settings_profile_type) } 1 1410 495 1600
add_de1_button "settings_2c settings_2czoom" {say [translate {Limits}] $::settings(sound_button_in); set ::settings(settings_profile_type) "settings_2c2"; set_next_page off $::settings(settings_profile_type); page_show off; update_de1_explanation_chart; set ::settings(active_settings_tab) $::settings(settings_profile_type) } 496 1410 972 1600


add_de1_widget "settings_2 settings_2a" graph 24 220 { 
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 5] -color #888888  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max [expr {0.1 + $::de1(maxpressure)}] -stepsize 2 -majorticks {1 3 5 7 9 11} -title [translate "pressure (bar)"] -titlefont Helv_10 -titlecolor #5a5d75;

	$widget element create line_espresso_de1_explanation_chart_pressure_part1 -xdata espresso_de1_explanation_chart_elapsed_1 -ydata espresso_de1_explanation_chart_pressure_1 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part2 -xdata espresso_de1_explanation_chart_elapsed_2 -ydata espresso_de1_explanation_chart_pressure_2 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part3 -xdata espresso_de1_explanation_chart_elapsed_3 -ydata espresso_de1_explanation_chart_pressure_3 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 

	bind $widget [platform_button_press] { 
		say [translate {refresh chart}] $::settings(sound_button_in); 
		update_de1_explanation_chart
	} 
} -plotbackground $chart_background_color -width [rescale_x_skin 2375] -height [rescale_y_skin 500] -borderwidth 1 -background #FFFFFF -plotrelief raised -plotpady 0 -plotpadx 10


############################


############################
# advanced flow profiling
add_de1_text "settings_2c" 70 230 -text [translate "Steps"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" 

add_de1_text "settings_2c" 984 240 -text [translate "1: Temperature"] -font Helv_9_bold -fill "#7f879a" -anchor "nw" 
add_de1_variable "settings_2c" 1600 240 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "nw" -textvariable {[if {[ifexists ::current_adv_step(pump)] == "flow"} {return [translate "2: Flow rate goal"]} else {return [translate "2: Pressure goal"]}]}

add_de1_text "settings_2c" 984 830 -text [translate "3: Maximum"] -font Helv_9_bold -fill "#7f879a" -anchor "nw" 


#add_de1_widget "settings_2c" checkbutton 1600 830 {} -text [translate "4: Move on if..."] -padx 0 -pady 0 -indicatoron true  -font Helv_9_bold -anchor nw -foreground #7f879a -activeforeground #7f879a -variable ::current_adv_step(exit_if)  -borderwidth 0  -highlightthickness 0  -command save_current_adv_shot_step -selectcolor #f9f9f9 -activebackground #f9f9f9 -bg #f9f9f9 -relief flat 
# for some reason, use of a dtoggle here is buggy below, the dtoggle does not update its visual state, but otherwise works fine, using a shadow variable to work around it. Might be due to ::current_adv_step being deleted/recreated and thus breaking the trace function
proc flip_adv_step_move_on_if {} {
	set ::current_adv_step(exit_if) [expr {!$::current_adv_step(exit_if)}]; 
	save_current_adv_shot_step
	set ::current_adv_step_exit_if $::current_adv_step(exit_if)
}

add_de1_variable "settings_2c" 1700 830 -text [translate "4: Move on if..."] -font Helv_9_bold -fill "#7f879a" -anchor "nw" -textvariable {[set ::current_adv_step_exit_if $::current_adv_step(exit_if); return [translate "4: Move on if..."]]}
dui add dtoggle "settings_2c"  1600 840 -width 80 -height 40 -anchor nw  -variable ::current_adv_step_exit_if
add_de1_button "settings_2c" { flip_adv_step_move_on_if } 1580 820 2200 890

set adv_listbox_height [expr {int(7 * $::globals(listbox_length_multiplier))}]

add_de1_widget "settings_2c" listbox 70 310 { 
	set ::advanced_shot_steps_widget $widget
	fill_advanced_profile_steps_listbox
	load_advanced_profile_step 1
	bind $widget <<ListboxSelect>> {::load_advanced_profile_step; update_de1_explanation_chart}

} -background #fbfaff -yscrollcommand {scale_scroll_new $::advanced_shot_steps_widget ::advsteps_slider} -xscrollcommand {scale_prevent_horiz_scroll $::advanced_shot_steps_widget} -font $listbox_font -bd 0 -height $adv_listbox_height -width 18 -foreground #d3dbf3 -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single  -selectbackground #c0c4e1

set ::advsteps_slider 0

# draw the scrollbar off screen so that it gets resized and moved to the right place on the first draw
set ::advsteps_scrollbar [add_de1_widget "settings_2c" scale 10000 1 {} -from 0 -to 1.0 -bigincrement 0.2 -background "#d3dbf3" -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 400] -width [rescale_y_skin 150] -variable ::advsteps_slider -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::advanced_shot_steps_widget $::advsteps_slider}  -foreground #FFFFFF -troughcolor "#f7f6fa" -borderwidth 0  -highlightthickness 0]

proc set_advsteps_scrollbar_dimensions {} {
	set_scrollbar_dimensions $::advsteps_scrollbar $::advanced_shot_steps_widget
}



add_de1_widget "settings_2c" entry 70 822  {
	set ::globals(widget_profile_step_save) $widget
	bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); change_current_adv_shot_step_name; profile_has_changed_set; hide_android_keyboard}
	bind $widget <Leave> hide_android_keyboard
	} -width [expr {int(27 * $::globals(entry_length_multiplier))}] -font Helv_8  -borderwidth 1 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::profile_step_name_to_add


add_de1_button "settings_2c" {say [translate {delete}] $::settings(sound_button_in); delete_current_adv_step; profile_has_changed_set; update_de1_explanation_chart} 740 250 920 500
add_de1_button "settings_2c" {say [translate {add}] $::settings(sound_button_in); add_to_current_adv_step; profile_has_changed_set; update_de1_explanation_chart} 740 750 920 950

add_de1_text "settings_2c" 1070 680 -text [translate "goal"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
	add_de1_variable "settings_2c" 1070 744 -text "" -font Helv_7_bold -fill "#4e85f4" -anchor "center" -textvariable {[return_temperature_setting [ifexists ::current_adv_step(temperature)]]}
	add_de1_button "settings_2c" {say [translate {temperature}] $::settings(sound_button_in);vertical_clicker 1.5 .5 ::current_adv_step(temperature) $::settings(minimum_water_temperature) 105 %x %y %x0 %y0 %x1 %y1 %b; save_current_adv_shot_step; update_de1_explanation_chart} 980 310 1150 640 ""
	
	#dui add dclicker "settings_2c" 980 310 -bwidth 200  -bheight 320 -tags temperature -orient v -style default -variable ::current_adv_step(temperature) -min $::settings(minimum_water_temperature) -max 105 -default 5 -n_decimals 1  -smallincrement 0.5 -bigincrement 10 -use_biginc false -editor_page yes -editor_page_title [translate "Temperature"] -command ::after_temp_dclicker

#proc ::after_temp_dclicker {} {
#	save_current_adv_shot_step
#	profile_has_changed_set
#}	


add_de1_text "settings_2c" 1380 680 -text [translate "sensor"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
	add_de1_button "settings_2c" { say [translate {sensor}] $::settings(sound_button_in); if {[ifexists ::current_adv_step(sensor)] == "water"} {  set ::current_adv_step(sensor) "coffee" } else { set ::current_adv_step(sensor) "water" }; save_current_adv_shot_step } 1200 310 1550 680 ""
	add_de1_variable "settings_2c" 1380 744 -text "" -font Helv_7_bold -fill "#4e85f4" -anchor "center" -textvariable {[translate [ifexists ::current_adv_step(sensor)]]}

proc settings2c_pressure_button {direction} {

	say [translate {pressure}] $::settings(sound_button_in)

	if {[ifexists ::current_adv_step(pump)] == ""} {
		set ::current_adv_step(pump) pressure
	}

	if {[ifexists ::current_adv_step(pressure)] == ""} {
		set ::current_adv_step(pressure) 0
	}

	if {[ifexists ::current_adv_step(pump)] == "pressure"} {
		if {$direction eq "up"} {
			set ::current_adv_step(pressure) [round_to_one_digits [expr {$::current_adv_step(pressure) + 0.1}]];

			if {$::current_adv_step(pressure) > $::de1(max_pressure)} {
				set ::current_adv_step(pressure) $::de1(max_pressure)
			}

		} else {
			set ::current_adv_step(pressure) [round_to_one_digits [expr {$::current_adv_step(pressure) - 0.1}]];
		}
	} else { 
		if {$direction eq "up"} {
			set ::current_adv_step(max_flow_or_pressure) [round_to_one_digits [expr {$::current_adv_step(max_flow_or_pressure) + 0.1}]];

			if {$::current_adv_step(max_flow_or_pressure) > $::de1(max_pressure)} {
				set ::current_adv_step(max_flow_or_pressure) $::de1(max_pressure)
			}
			
		} else {
			set ::current_adv_step(max_flow_or_pressure) [round_to_one_digits [expr {$::current_adv_step(max_flow_or_pressure) - 0.1}]];
		}
	}

	if {[ifexists ::current_adv_step(max_flow_or_pressure)] < 0} {
		set ::current_adv_step(max_flow_or_pressure) 0
	}

	if {[ifexists ::current_adv_step(pressure)] < 0} {
		set ::current_adv_step(pressure) 0
	}

	update_onscreen_variables
	save_current_adv_shot_step
	update_de1_explanation_chart
}

proc settings2c_flow_button {direction} {
	say [translate {pressure}] $::settings(sound_button_in)

	if {[ifexists ::current_adv_step(pump)] == ""} {
		set ::current_adv_step(pump) flow
	}

	if {[ifexists ::current_adv_step(flow)] == ""} {
		set ::current_adv_step(flow) 0
	}

	if {[ifexists ::current_adv_step(pump)] == "flow"} {
		if {$direction eq "up"} {
			set ::current_adv_step(flow) [round_to_one_digits [expr {$::current_adv_step(flow) + 0.1}]];

			if {$::current_adv_step(flow) > $::de1(max_flowrate)} {
				set ::current_adv_step(flow) $::de1(max_flowrate)
			}

		} else {
			set ::current_adv_step(flow) [round_to_one_digits [expr {$::current_adv_step(flow) - 0.1}]];
		}
	} else { 
		if {$direction eq "up"} {
			set ::current_adv_step(max_flow_or_pressure) [round_to_one_digits [expr {$::current_adv_step(max_flow_or_pressure) + 0.1}]];

			if {$::current_adv_step(max_flow_or_pressure) > $::de1(max_flowrate)} {
				set ::current_adv_step(max_flow_or_pressure) $::de1(max_flowrate)
			}

		} else {
			set ::current_adv_step(max_flow_or_pressure) [round_to_one_digits [expr {$::current_adv_step(max_flow_or_pressure) - 0.1}]];
		}
	}

	if {[ifexists ::current_adv_step(max_flow_or_pressure)] < 0} {
		set ::current_adv_step(max_flow_or_pressure) 0
	}

	if {[ifexists ::current_adv_step(flow)] < 0} {
		set ::current_adv_step(flow) 0
	}

	update_onscreen_variables
	save_current_adv_shot_step
	update_de1_explanation_chart
}

proc settings2c_pressure_label {} {

	if {[ifexists ::current_adv_step(max_flow_or_pressure)] > 0} {
		return "$::current_adv_step(max_flow_or_pressure) bar"
	}
	return [translate "off"]
}

proc settings2c_flow_label {} {
	if {[ifexists ::current_adv_step(max_flow_or_pressure)] > 0} {
		return "$::current_adv_step(max_flow_or_pressure) [translate mL/s]"
	}
	return [translate "off"]
}



add_de1_variable "settings_2c" 1710 680 -text ""  -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center"  -textvariable {[if {[ifexists ::current_adv_step(pump)] == "flow"} {return [translate "flow"]} else { return [translate "flow limit"] }]}
add_de1_variable "settings_2c" 2010 680 -text ""  -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center"  -textvariable {[if {[ifexists ::current_adv_step(pump)] == "pressure"} {return [translate "pressure"]} else { return [translate "pressure limit"] }]}
	add_de1_button "settings_2c" { settings2c_flow_button up } 1580 310 1820 410 ""
	add_de1_button "settings_2c" { tap_flow_central_button } 1580 430 1820 520 ""
	add_de1_button "settings_2c" { settings2c_flow_button down } 1580 540 1820 640 ""



proc tap_pressure_central_button {} {
	say [translate {pressure}] $::settings(sound_button_in);
	if {$::current_adv_step(pump) != "pressure"} {
		set ::current_adv_step(pump) "pressure"; 
	} else {
		# john disabled 2nd tap causing data entry page, because this is not consistently done in all icons on this page, so can cause confusion
		#dui page open_dialog dui_number_editor ::current_adv_step(pressure) -n_decimals 1 -min 0 -max $::de1(max_pressure) -default $::current_adv_step(pressure) -smallincrement 1 -bigincrement 5 -use_biginc 0 -page_title [translate "Pressure goal"] -return_callback callback_after_adv_profile_data_entry
	}

	profile_has_changed_set
	update_onscreen_variables; 
	save_current_adv_shot_step; 
	update_de1_explanation_chart
}

proc tap_flow_central_button {} {

	profile_has_changed_set

	say [translate {pressure}] $::settings(sound_button_in);
	if {$::current_adv_step(pump) != "flow"} {
		set ::current_adv_step(pump) "flow"; 
	} else {
		# john disabled 2nd tap causing data entry page, because this is not consistently done in all icons on this page, so can cause confusion
		# dui page open_dialog dui_number_editor ::current_adv_step(flow) -n_decimals 1 -min 0 -max $::de1(max_flowrate_v11) -default $::current_adv_step(flow) -smallincrement 1 -bigincrement 2 -use_biginc 0 -page_title [translate "Flow rate goal"] -return_callback callback_after_adv_profile_data_entry
	}
	
	
	update_onscreen_variables; 
	save_current_adv_shot_step; 
	update_de1_explanation_chart
	profile_has_changed_set
}

proc tap_flow_text_label {} {
	profile_has_changed_set
	if {$::current_adv_step(pump) != "flow"} {
		dui page open_dialog dui_number_editor ::current_adv_step(max_flow_or_pressure) -n_decimals 1 -min 0 -max $::de1(max_flowrate_v11) -default $::current_adv_step(max_flow_or_pressure) -smallincrement 1 -bigincrement 2 -use_biginc 0 -page_title [translate "Flow limit"] -return_callback callback_after_adv_profile_data_entry
	} else {
		dui page open_dialog dui_number_editor ::current_adv_step(flow) -n_decimals 1 -min 0 -max $::de1(max_flowrate_v11) -default $::current_adv_step(flow) -smallincrement 1 -bigincrement 2 -use_biginc 0 -page_title [translate "Flow rate goal"] -return_callback callback_after_adv_profile_data_entry
	}
	

}
proc tap_pressure_text_label {} {
	if {$::current_adv_step(pump) != "pressure"} {
		dui page open_dialog dui_number_editor ::current_adv_step(max_flow_or_pressure) -n_decimals 1 -min 0 -max $::de1(max_flowrate_v11) -default $::current_adv_step(max_flow_or_pressure) -smallincrement 1 -bigincrement 2 -use_biginc 0 -page_title [translate "Pressure limit"] -return_callback callback_after_adv_profile_data_entry
	} else {
		dui page open_dialog dui_number_editor ::current_adv_step(pressure) -n_decimals 1 -min 0 -max $::de1(max_pressure) -default $::current_adv_step(pressure) -smallincrement 1 -bigincrement 5 -use_biginc 0 -page_title [translate "Pressure goal"] -return_callback callback_after_adv_profile_data_entry
	}
	profile_has_changed_set
	save_current_adv_shot_step
}

	add_de1_button "settings_2c" { settings2c_pressure_button up } 1890 310 2120 410 ""
	add_de1_button "settings_2c" { tap_pressure_central_button } 1890 430 2120 520 ""
	add_de1_button "settings_2c" { settings2c_pressure_button down } 1890 540 2120 640 ""


	add_de1_variable "settings_2c" 1710 744 -text "" -font Helv_7_bold -fill "#4e85f4" -anchor "center" -justify "center" -textvariable { [ if {[ifexists ::current_adv_step(pump)] == "flow"} { return [return_flow_measurement $::current_adv_step(flow)] } else { settings2c_flow_label } ]  }
	add_de1_variable "settings_2c" 2010 744 -text "" -font Helv_7_bold -fill "#4e85f4" -anchor "center" -justify "center" -textvariable {[if {[ifexists ::current_adv_step(pump)] == "pressure"} {return_pressure_measurement $::current_adv_step(pressure)} else { settings2c_pressure_label }] }

	add_de1_button "settings_2c" { tap_flow_text_label } 1580 650 1820 780 ""
	add_de1_button "settings_2c" { tap_pressure_text_label } 1890 650 2120 780 "" 

proc temp_entry_callback { {discard {}} } {
	set ::current_adv_step(temperature) [fahrenheit_to_celsius $::fahrenheit_water]
	save_current_adv_shot_step
	profile_has_changed_set
}


proc callback_after_adv_profile_data_entry  { {discard {}} } {
	save_current_adv_shot_step
	profile_has_changed_set
}

# tap temperature label to do data entry
if {$::settings(enable_fahrenheit) == 1} {
	add_de1_button "settings_2c" { set ::fahrenheit_water [round_to_integer [celsius_to_fahrenheit $::current_adv_step(temperature)]]; profile_has_changed_set; dui page open_dialog dui_number_editor ::fahrenheit_water -n_decimals 0 -min 0 -max [celsius_to_fahrenheit 105]  -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Temperature"] -return_callback temp_entry_callback  } 980 650 1150 780 ""   
} else {
	add_de1_button "settings_2c" { profile_has_changed_set; dui page open_dialog dui_number_editor ::current_adv_step(temperature) -n_decimals 1 -min 0 -max 105 -default $::current_adv_step(temperature) -smallincrement 0.5 -bigincrement 10 -use_biginc 1 -page_title [translate "Temperature"] -return_callback callback_after_adv_profile_data_entry  } 980 650 1150 780 ""   
}


add_de1_text "settings_2c" 2345 680 -text [translate "transition"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
	add_de1_button "settings_2c" {say [translate {boiler}] $::settings(sound_button_in); if {[ifexists ::current_adv_step(transition)] == "fast"} {  set ::current_adv_step(transition) "smooth" } else { set ::current_adv_step(transition) "fast" }; save_current_adv_shot_step; update_de1_explanation_chart } 2200 310 2500 680 ""
	add_de1_variable "settings_2c" 2345 744 -text "" -font Helv_7_bold -fill "#4e85f4" -anchor "center" -textvariable {[translate [ifexists ::current_adv_step(transition)]]}


add_de1_text "settings_2c" 1060 1270 -text [translate "time"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
	add_de1_button "settings_2c" {say [translate {time}] $::settings(sound_button_in);vertical_clicker 9 1 ::current_adv_step(seconds) 0 127 %x %y %x0 %y0 %x1 %y1 %b; save_current_adv_shot_step; update_de1_explanation_chart } 960 900 1140 1240 ""
	add_de1_variable "settings_2c" 1060 1340 -text "" -font Helv_7_bold -fill "#4e85f4" -anchor "center" -textvariable {[seconds_text_abbreviated [round_to_integer [ifexists ::current_adv_step(seconds)]]]}
	add_de1_button "settings_2c" { profile_has_changed_set; dui page open_dialog dui_number_editor ::current_adv_step(seconds) -n_decimals 0 -min 0 -max 127 -default $::current_adv_step(seconds) -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Time"] -return_callback callback_after_adv_profile_data_entry  } 960 1250 1140 1380 ""   


add_de1_text "settings_2c" 1260 1270 -text [translate "volume"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
	add_de1_button "settings_2c" {say [translate {time}] $::settings(sound_button_in);vertical_clicker 9 1 ::current_adv_step(volume) 0 1023 %x %y %x0 %y0 %x1 %y1; save_current_adv_shot_step } 1144 900 1344 1240 ""
	add_de1_variable "settings_2c" 1260 1340 -text "" -font Helv_7_bold -fill "#4e85f4" -anchor "center" -textvariable {[return_stop_at_volume_measurement [ifexists ::current_adv_step(volume)]]}
	add_de1_button "settings_2c" { profile_has_changed_set; dui page open_dialog dui_number_editor ::current_adv_step(volume) -n_decimals 0 -min 0 -max 1023 -default $::current_adv_step(volume) -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Volume"] -return_callback callback_after_adv_profile_data_entry  } 1144 1250 1344 1380 ""   

add_de1_text "settings_2c" 1450 1270 -text [translate "weight"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
	add_de1_button "settings_2c" {say [translate {time}] $::settings(sound_button_in);vertical_clicker 9 1 ::current_adv_step(weight) 0 1000 %x %y %x0 %y0 %x1 %y1; save_current_adv_shot_step } 1354 900 1540 1240 ""
	add_de1_variable "settings_2c" 1450 1340 -text "-" -font Helv_7_bold -fill "#4e85f4" -anchor "center" -textvariable {[return_stop_at_weight_measurement [ifexists ::current_adv_step(weight)]]}
	add_de1_button "settings_2c" { profile_has_changed_set; dui page open_dialog dui_number_editor ::current_adv_step(weight) -n_decimals 0 -min 0 -max 1000 -default $::current_adv_step(weight) -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Weight"] -return_callback callback_after_adv_profile_data_entry  } 1354 1250 1540 1380 ""   


add_de1_text "settings_2c" 1700 1240 -text [translate "pressure"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
add_de1_text "settings_2c" 1700 1270 -text [translate "is over"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
	add_de1_variable "settings_2c" 1700 1340 -text "" -font Helv_7_bold -fill "#4e85f4" -anchor "center" -textvariable { [ if {[ifexists ::current_adv_step(exit_if)] == 1 && [ifexists ::current_adv_step(exit_type)] == "pressure_over"} { return_pressure_measurement [ifexists ::current_adv_step(exit_pressure_over) 11] } else  { return "-" } ] }
	add_de1_button "settings_2c" { say [translate {pressure is over}] $::settings(sound_button_in); set ::current_adv_step(exit_if) 1; if { [ifexists ::current_adv_step(exit_type)] != "pressure_over" } { set ::current_adv_step(exit_type) "pressure_over" } else { vertical_clicker 1.9 .1 ::current_adv_step(exit_pressure_over) 0 13 %x %y %x0 %y0 %x1 %y1 %b}; save_current_adv_shot_step; } 1580 900 1780 1240 ""
	add_de1_button "settings_2c" { profile_has_changed_set; dui page open_dialog dui_number_editor ::current_adv_step(exit_pressure_over) -n_decimals 1 -min 0 -max 11 -default $::current_adv_step(exit_pressure_over) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Pressure is over"] -return_callback callback_after_adv_profile_data_entry  } 1580 1250 1780 1380 ""   



add_de1_text "settings_2c" 1930 1240 -text [translate "pressure"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
add_de1_text "settings_2c" 1930 1270 -text [translate "is under"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
	add_de1_variable "settings_2c" 1930 1340 -text "" -font Helv_7_bold -fill "#4e85f4" -anchor "center" -textvariable { [ if {[ifexists ::current_adv_step(exit_if)] == 1 && [ifexists ::current_adv_step(exit_type)] == "pressure_under"} { return_pressure_measurement [ifexists ::current_adv_step(exit_pressure_under) 0] } else  { return "-" } ] }
	add_de1_button "settings_2c" { say [translate {pressure is under}] $::settings(sound_button_in); set ::current_adv_step(exit_if) 1; if { [ifexists ::current_adv_step(exit_type)] != "pressure_under" } { set ::current_adv_step(exit_type) "pressure_under" } else { vertical_clicker 1.9 .1 ::current_adv_step(exit_pressure_under) 0 13 %x %y %x0 %y0 %x1 %y1 %b}; save_current_adv_shot_step; } 1790 900 2010 1240 ""
	add_de1_button "settings_2c" { profile_has_changed_set; dui page open_dialog dui_number_editor ::current_adv_step(exit_pressure_under) -n_decimals 1 -min 0 -max 11 -default $::current_adv_step(exit_pressure_under) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Pressure is under"] -return_callback callback_after_adv_profile_data_entry  } 1790 1250 2010 1380 ""   


add_de1_text "settings_2c" 2154 1240 -text [translate "flow"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
add_de1_text "settings_2c" 2154 1270 -text [translate "is over"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
	add_de1_variable "settings_2c" 2154 1340 -text "" -font Helv_7_bold -fill "#4e85f4" -anchor "center" -textvariable { [ if {[ifexists ::current_adv_step(exit_if)] == 1 && [ifexists ::current_adv_step(exit_type)] == "flow_over"} { return_flow_measurement [ifexists ::current_adv_step(exit_flow_over) 6]} else  { return "-" } ] }
	add_de1_button "settings_2c" { say [translate {flow is over}] $::settings(sound_button_in); set ::current_adv_step(exit_if) 1; if {[ifexists ::current_adv_step(exit_type)] != "flow_over" } { set ::current_adv_step(exit_type) "flow_over" } else { vertical_clicker 1.9 .1 ::current_adv_step(exit_flow_over) 0 6 %x %y %x0 %y0 %x1 %y1 %b}; save_current_adv_shot_step; } 2020 900 2260 1240 ""
	add_de1_button "settings_2c" { profile_has_changed_set; dui page open_dialog dui_number_editor ::current_adv_step(exit_flow_over) -n_decimals 1 -min 0 -max 6 -default $::current_adv_step(exit_flow_over) -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Flow is over"] -return_callback callback_after_adv_profile_data_entry  } 2020 1250 2260 1380 ""   

add_de1_text "settings_2c" 2388 1240 -text [translate "flow"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
add_de1_text "settings_2c" 2388 1270 -text [translate "is under"] -font Helv_6 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
	add_de1_variable "settings_2c" 2388 1340 -text "" -font Helv_7_bold -fill "#4e85f4" -anchor "center" -textvariable { [ if {[ifexists ::current_adv_step(exit_if)] == 1 && [ifexists ::current_adv_step(exit_type)] == "flow_under"} { return_flow_measurement [ifexists ::current_adv_step(exit_flow_under) 0] } else  { return "-" } ] }
	add_de1_button "settings_2c" { say [translate {flow is under}] $::settings(sound_button_in); set ::current_adv_step(exit_if) 1; if { [ifexists ::current_adv_step(exit_type)] != "flow_under" } { set ::current_adv_step(exit_type) "flow_under" } else { vertical_clicker 1.9 .1 ::current_adv_step(exit_flow_under) 0 6 %x %y %x0 %y0 %x1 %y1 %b}; save_current_adv_shot_step; } 2270 900 2500 1240 ""
	add_de1_button "settings_2c" { profile_has_changed_set; dui page open_dialog dui_number_editor ::current_adv_step(exit_flow_under) -n_decimals 1 -min 0 -max 6 -default $::current_adv_step(exit_flow_under) -smallincrement 1 -bigincrement 10 -use_biginc 1 -page_title [translate "Flow is under"] -return_callback callback_after_adv_profile_data_entry  } 2270 1250 2500 1380 ""   


############################

#set ::table_style_preview_image [add_de1_image "settings_3" 1860 310 "[skin_directory_graphics]/icon.jpg"]

set profiles_listbox_length [expr {int(15 * $::globals(listbox_length_multiplier))}]

add_de1_widget "settings_1" listbox 50 305 { 
	 	set ::globals(profiles_listbox) $widget
		fill_profiles_listbox
		bind $::globals(profiles_listbox) <<ListboxSelect>> ::preview_profile
	} -background #fbfaff -xscrollcommand {scale_prevent_horiz_scroll $::globals(profiles_listbox)} -yscrollcommand {scale_scroll_new $::globals(profiles_listbox) ::profiles_slider} -font $listbox_font -bd 0 -height $profiles_listbox_length -width 32 -foreground #d3dbf3 -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single  -selectbackground #c0c4e1 

set ::profiles_slider 0

# draw the scrollbar off screen so that it gets resized and moved to the right place on the first draw
set ::profiles_scrollbar [add_de1_widget "settings_1" scale 10000 1 {} -from 0 -to 1.0 -bigincrement 0.2 -background "#d3dbf3" -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 400] -width [rescale_y_skin 150] -variable ::profiles_slider -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::globals(profiles_listbox) $::profiles_slider}  -foreground #FFFFFF -troughcolor "#f7f6fa" -borderwidth 0  -highlightthickness 0]

proc set_profiles_scrollbar_dimensions {} {
	set_scrollbar_dimensions $::profiles_scrollbar $::globals(profiles_listbox)
}


# experimental feature to also load god shots with profiles
# add_de1_widget "settings_1" checkbutton 50 1310 {} -text [translate "Also load God Shot"] -indicatoron true  -font Helv_8 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(also_load_god_shot)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF  -bd 0 -activeforeground #4e85f4 -relief flat -bd 0

add_de1_widget "settings_1" graph 1330 300 { 
		set ::preview_graph_pressure $widget
		update_de1_explanation_chart;
		$::preview_graph_pressure element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #47e098  -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 
		$::preview_graph_pressure axis configure x -color #5a5d75 -tickfont Helv_6 ; 
		$::preview_graph_pressure axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max 11.5 -stepsize 2 -majorticks {1 3 5 7 9 11} -title [translate "pressure (bar)"] -titlefont Helv_8 -titlecolor #5a5d75;
		$::preview_graph_pressure element create line_espresso_de1_explanation_chart_temp2 -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_temperature_10  -label "" -linewidth [rescale_x_skin 10] -color #ff888c  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 
		bind $::preview_graph_pressure [platform_button_press] { after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off $::settings(settings_profile_type); page_show off; set ::settings(active_settings_tab) $::settings(settings_profile_type) } 
	} -plotbackground $chart_background_color -width [rescale_x_skin 1050] -height [rescale_y_skin 450] -borderwidth 1 -background #FFFFFF -plotrelief raised -plotpady 0 -plotpadx 10

add_de1_widget "settings_1b" graph 1330 300 { 
		set ::preview_graph_flow $widget
		update_de1_explanation_chart;
		$::preview_graph_flow element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #98c5ff  -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 
		$::preview_graph_flow axis configure x -color #5a5d75 -tickfont Helv_6; 
		$::preview_graph_flow axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max 10 -majorticks {1 2 3 4 5 6 7 8 9 10} -title [translate "Flow rate"] -titlefont Helv_8 -titlecolor #5a5d75;
		$::preview_graph_flow element create line_espresso_de1_explanation_chart_temp -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_temperature_10  -label "" -linewidth [rescale_x_skin 10] -color #ff888c  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 
		bind $::preview_graph_flow [platform_button_press] { after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off $::settings(settings_profile_type); page_show off; set ::settings(active_settings_tab) $::settings(settings_profile_type) } 
	} -plotbackground $chart_background_color -width [rescale_x_skin 1050] -height [rescale_y_skin 450] -borderwidth 1 -background #FFFFFF -plotrelief raised  -plotpady 0 -plotpadx 10


add_de1_widget "settings_1c" graph 1330 300 { 
		set ::preview_graph_advanced $widget
		update_de1_explanation_chart;
		#$::preview_graph_flow element create line_espresso_de1_explanation_chart_flow_adv -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #4ef485  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
		#$::preview_graph_pressure element create line_espresso_de1_explanation_chart_pressure_adv -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 20]; 

		$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure  -label "" -linewidth [rescale_x_skin 10] -color #47e098  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 
		$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow  -label "" -linewidth [rescale_x_skin 12] -color #98c5ff  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 
		$widget element create line_espresso_de1_explanation_chart_temp -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_temperature_10  -label "" -linewidth [rescale_x_skin 10] -color #ff888c  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 

		#$::preview_graph_advanced element create line_espresso_de1_explanation_chart_adv -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth $::settings(profile_graph_smoothing_technique)$::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
		$::preview_graph_advanced axis configure x -color #5a5d75 -tickfont Helv_6; 
		$::preview_graph_advanced axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max 12 -majorticks {1 2 3 4 5 6 7 8 9 10 11 12} -title [translate "Advanced"] -titlefont Helv_8 -titlecolor #5a5d75;
		bind $::preview_graph_advanced [platform_button_press] { after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off $::settings(settings_profile_type); page_show off; set ::settings(active_settings_tab) $::settings(settings_profile_type); fill_advanced_profile_steps_listbox } 
	} -plotbackground $chart_background_color -width [rescale_x_skin 1050] -height [rescale_y_skin 450] -borderwidth 1 -background #FFFFFF -plotrelief raised  -plotpady 0 -plotpadx 10


add_de1_widget "settings_2c" graph 8 960 { 
		#set ::preview_graph_advanced $widget
		update_de1_explanation_chart;
		
		$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure  -label "" -linewidth [rescale_x_skin 10] -color #47e098  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 
		$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow  -label "" -linewidth [rescale_x_skin 12] -color #98c5ff  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 
		$widget element create line_espresso_de1_explanation_chart_temp -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_temperature_10  -label "" -linewidth [rescale_x_skin 10] -color #ff888c  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 

		$widget element create line_espresso_de1_explanation_chart_selected_step -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_selected_step  -label "" -linewidth [rescale_x_skin 20] -color #FFFF66  -smooth $::settings(preview_graph_smoothing_technique) -pixels [rescale_x_skin 15] ; 


		$widget axis configure x -color #5a5d75 -tickfont Helv_6; 
		$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max 12 -majorticks {1 2 3 4 5 6 7 8 9 10 11 12} -titlefont Helv_8 -titlecolor #5a5d75;
		bind $widget [platform_button_press] { page_to_show_when_off settings_2czoom } 
	} -plotbackground $chart_background_color -width [rescale_x_skin 920] -height [rescale_y_skin 450] -borderwidth 1 -background #ededfa -plotrelief raised  -plotpady 0 -plotpadx 10


add_de1_widget "settings_2czoom" graph 8 200 { 
		#set ::preview_graph_advanced $widget
		update_de1_explanation_chart;
		
		$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure  -label "" -linewidth [rescale_x_skin 10] -color #47e098  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 
		$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow  -label "" -linewidth [rescale_x_skin 12] -color #98c5ff  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 
		$widget element create line_espresso_de1_explanation_chart_temp -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_temperature_10  -label "" -linewidth [rescale_x_skin 10] -color #ff888c  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 

		$widget element create line_espresso_de1_explanation_chart_selected_step -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_selected_step  -label "" -linewidth [rescale_x_skin 20] -color #FFFF66  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0 ; 


		$widget axis configure x -color #5a5d75 -tickfont Helv_6; 
		$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max 12 -majorticks {1 2 3 4 5 6 7 8 9 10 11 12} -titlefont Helv_8 -titlecolor #5a5d75;
		bind $widget [platform_button_press] { page_to_show_when_off settings_2c } 
	} -plotbackground $chart_background_color -width [rescale_x_skin 2540] -height [rescale_y_skin 1220] -borderwidth 1 -background #ededfa -plotrelief raised  -plotpady 0 -plotpadx 10



add_de1_button "settings_1" {say [translate {edit}] $::settings(sound_button_in); set_next_page off $::settings(settings_profile_type); page_show off; set ::settings(active_settings_tab) $::settings(settings_profile_type); fill_advanced_profile_steps_listbox } 1330 220 2360 800

add_de1_variable "settings_1" 2466 740 -text "" -font Helv_7 -fill "#7f879a" -anchor "center" -textvariable {[return_temperature_setting $::settings(espresso_temperature)]}
add_de1_button "settings_1" {say [translate {temperature}] $::settings(sound_button_in); change_espresso_temperature 0.5; profile_has_changed_set } 2380 230 2590 480
	add_de1_button "settings_1" {say [translate {temperature}] $::settings(sound_button_in); change_espresso_temperature -0.5; profile_has_changed_set } 2380 490 2590 800


add_de1_text "settings_3" 1304 220 -text [translate "Maintenance"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

	# prepare for transport button
	add_de1_text "settings_3" 2290 610 -text [translate "Transport"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
		add_de1_button "settings_3" {say [translate {Transport}] $::settings(sound_button_in); de1_send_shot_frames "cool"; set_next_page off travel_prepare; page_show travel_prepare; } 1910 516 2540 720


	# calibrate feature
	add_de1_text "settings_3" 1640 610 -text [translate "Calibrate"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
		add_de1_button "settings_3" {say [translate {Calibrate}] $::settings(sound_button_in); calibration_gui_init; info_page [translate "Bad calibration settings might make your espresso machine unuseable.  Only proceed if you have been told to or have read the relevant manual sections and know what you are doing."] [translate "Ok"] "calibrate" }  1280 516 1900 720


	# clean feature
	add_de1_text "settings_3" 1640 420 -text [translate "Clean"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
		add_de1_button "settings_3" {say [translate {Clean}] $::settings(sound_button_in); start_cleaning}  1280 310 1900 510

	# descale button
	add_de1_text "settings_3" 2290 420 -text [translate "Descale"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
		add_de1_button "settings_3" {say [translate {Descale}] $::settings(sound_button_in); set_next_page off descale_prepare; page_show descale_prepare;} 1910 310 2540 510
	 
add_de1_text "settings_3" 1304 750 -text [translate "Firmware"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
	# firmware update
	add_de1_variable "settings_3" 1960 926 -text "" -width [rescale_y_skin 1000] -font Helv_10_bold -fill "#FFFFFF" -justify "center" -anchor "center" -textvariable {[check_firmware_update_is_available][translate $::de1(firmware_update_button_label)]} 
	#add_de1_variable "settings_3" 1960 964 -font Helv_8 -fill "#FFFFFF" -anchor "center" -width 500 -justify "center" -textvariable {[firmware_uploaded_label]} 
	#add_de1_button "settings_3" {start_firmware_update} 1280 820 2540 1020
	add_de1_button "settings_3" {set ::de1(in_fw_update_mode) 1; page_to_show_when_off firmware_update_1} 1280 850 2540 1020
	
	# hidden button to force a firmware update even if it is currently disabled.
	add_de1_button "settings_3" {set ::settings(force_fw_update) 1; set ::de1(in_fw_update_mode) 1; page_to_show_when_off firmware_update_1} 1280 750 1800 810


# app update
add_de1_text "settings_4" 50 220 -text [translate "Update App"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
	set ::de1(app_update_button_label) [translate "Update"]
	add_de1_text "settings_4" 1240 226 -text "[app_updates_policy_as_text] v[package version de1app]" -width [rescale_y_skin 1000] -font Helv_8 -fill "#7f879a"  -justify "center" -anchor "ne"
	add_de1_variable "settings_4" 700 416 -text $::de1(app_update_button_label) -width [rescale_y_skin 1000] -font Helv_10_bold -fill "#FFFFFF"  -justify "center" -anchor "center" -textvariable {$::de1(app_update_button_label)} 
	add_de1_button "settings_4" {set ::de1(app_update_button_label) [translate "Updating"]; update; start_app_update} 20 320 1250 526
	
	# tap on version number on "app settings" tab, to visit a web page of this version's changelog
	add_de1_button "settings_4" {if {[ifexists ::changelog_link] != ""} {web_browser $::changelog_link}} 750 220 1250 290   ""



	set pos_vert 1300
	set pos_top 940
	set spacer 60
	set optionfont "Helv_8"


##############################################################################
# buttons to other settings pages
	add_de1_text "settings_4" 1656 416 -text [translate "Skin"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center" 

		#add_de1_widget "tabletstyles" checkbutton 1300 860 {} -text [translate "Only show most popular skins"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(show_only_most_popular_skins)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF  -bd 0 -activeforeground #4e85f4 -relief flat -bd 0 -command {refresh_skin_directories; fill_skin_listbox}
		add_de1_text "tabletstyles" 1450 1060 -justify left -anchor "nw" -font $optionfont -text [translate "Only show most popular skins"]  -fill "#4e85f4" -width [rescale_x_skin 1000] 
		dui add dtoggle "tabletstyles" 1300 1060 -height 60 -width 120 -anchor nw -variable ::settings(show_only_most_popular_skins) -command { if {1 == 1} { toggle_show_only_popular_skins } }
		add_de1_button "tabletstyles" { set ::settings(show_only_most_popular_skins) [expr {!$::settings(show_only_most_popular_skins)}]; toggle_show_only_popular_skins } 1300 1060 2100 1120

		
		proc toggle_show_only_popular_skins {} {
			refresh_skin_directories
			fill_skin_listbox
		}


		add_de1_button "settings_4" {say [translate {Styles}] $::settings(sound_button_in); set_next_page off tabletstyles; page_show tabletstyles; preview_tablet_skin; set_skins_scrollbar_dimensions }  1290 306 1900 510
		set ::table_style_preview_image [add_de1_image "tabletstyles" 1300 450 ""]

		add_de1_text "tabletstyles" 1280 300 -text [translate "Skin"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center" 
		set tabletstyles_listbox_length [expr {int(10 * $::globals(listbox_length_multiplier))}]

		add_de1_widget "tabletstyles" listbox 260 450 { 
				set ::globals(tablet_styles_listbox) $widget
				fill_skin_listbox
				bind $::globals(tablet_styles_listbox) <<ListboxSelect>> ::preview_tablet_skin
			} -background #fbfaff -xscrollcommand {scale_prevent_horiz_scroll $::globals(tablet_styles_listbox)} -yscrollcommand {scale_scroll_new $::globals(tablet_styles_listbox) ::skin_slider} -font global_font -bd 0 -height $tabletstyles_listbox_length -width 30 -foreground #d3dbf3 -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single -selectbackground #c0c4e1

		set ::skin_slider 0
		set ::skin_scrollbar [add_de1_widget "tabletstyles" scale 10000 1 {} -from 0 -to 1.0 -bigincrement 0.2 -background "#d3dbf3" -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 400] -width [rescale_y_skin 150] -variable ::skin_slider -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::globals(tablet_styles_listbox) $::skin_slider}  -foreground #FFFFFF -troughcolor "#f7f6fa" -borderwidth 0  -highlightthickness 0]

		proc set_skins_scrollbar_dimensions {} {
			set_scrollbar_dimensions $::skin_scrollbar $::globals(tablet_styles_listbox)
		}




		#if {[ifexists ::settings(has_ghc)] != 1} {
			# the new group head controller stops the stress test feature from working, since bluetooth starting of dangerous functions is no longer permitted for UL compliance
		#}

	add_de1_text "firmware_update_1" 40 20 -text [translate "Turn your DE1 off"] -font Helv_16_bold -width 1200 -fill "#444444" -anchor "nw" -justify "left" 
		add_de1_text "firmware_update_1" 40 1500 -text "[translate "Firmware Update"] - [translate "Page"] 1/5" -font Helv_12_bold -fill "#888888" -anchor "nw" -justify "left"

		add_de1_text "firmware_update_1" 40 1300 -text [translate "Your DE1 will need to reboot in a special way to have its firmware updated."] -font Helv_10 -width 600 -fill "#444444" -anchor "nw" -justify "left" 

		add_de1_text "firmware_update_1" 2290 1508 -text [translate "Cancel"] -font Helv_10_bold -fill "#DDDDDD" -anchor "center"
		add_de1_button "firmware_update_1" {say [translate {Cancel}] $::settings(sound_button_in); set ::de1(in_fw_update_mode) 0; page_to_show_when_off settings_3;} 1960 1200 2560 1600 ""
		add_de1_variable "firmware_update_1" 2030 300 -text "" -font Helv_16_bold -fill "#222222" -anchor "center" -width [rescale_y_skin 700] -justify "center" -textvariable {[if {$::de1(device_handle) == 0} { page_show firmware_update_2; }; return ""]}

	add_de1_text "firmware_update_2" 40 20 -text [translate "Turn your DE1 on"] -font Helv_16_bold -width 1200 -fill "#444444" -anchor "nw" -justify "left" 
		add_de1_text "firmware_update_2" 40 1500 -text "[translate "Firmware Update"] - [translate "Page"]  2/5" -font Helv_12_bold -fill "#888888" -anchor "nw" -justify "left"
		add_de1_text "firmware_update_2" 2290 1508 -text [translate "Cancel"] -font Helv_10_bold -fill "#DDDDDD" -anchor "center"
		add_de1_button "firmware_update_2" {say [translate {Cancel}] $::settings(sound_button_in); app_exit} 1960 1200 2560 1600 ""
		add_de1_variable "firmware_update_2" 40 120 -text [translate "It can take one minute to start"] -font Helv_8 -fill "#222222" -anchor "nw" -width [rescale_y_skin 900] -justify "left" -textvariable {[if {$::de1(device_handle) != 0} { start_firmware_update; disable_de1_reconnect; page_show firmware_update_3}; return [translate "It can take one minute to start"]]}

	add_de1_variable "firmware_update_3" 40 20 -text "" -font Helv_16_bold -width 1200 -fill "#444444" -anchor "nw" -justify "left" -textvariable {[check_firmware_update_is_available][translate $::de1(firmware_update_button_label)]} 
		add_de1_text "firmware_update_3" 40 1500 -text "[translate "Firmware Update"] - [translate "Page"]  3/5" -font Helv_12_bold -fill "#888888" -anchor "nw" -justify "left"
		add_de1_text "firmware_update_3" 2290 1508 -text [translate "Cancel"] -font Helv_10_bold -fill "#DDDDDD" -anchor "center"
		add_de1_button "firmware_update_3" {say [translate {Exit}] $::settings(sound_button_in); app_exit} 1960 1200 2560 1600 ""
		add_de1_variable "firmware_update_3" 730 700 -text "" -font Helv_10 -fill "#222222" -anchor "ne" -width [rescale_y_skin 700] -justify "right" -textvariable {[if {$::de1(currently_erasing_firmware) != 1 && $::de1(currently_updating_firmware) != 1} {page_show firmware_update_4}; return [firmware_uploaded_label]]} 
		add_de1_variable "firmware_update_3" 730 750 -text "" -font Helv_10 -fill "#222222" -anchor "ne" -width [rescale_y_skin 700] -justify "right" -textvariable {[firmware_update_eta_label]} 

	add_de1_text "firmware_update_4" 40 20 -text [translate "Turn your DE1 off"] -font Helv_16_bold -width 1200 -fill "#444444" -anchor "nw" -justify "left" 
		
		#add_de1_variable "firmware_update_4" 40 1400 -text "" -font Helv_10 -width 1200 -fill "#444444" -anchor "nw" -justify "left" -textvariable {[check_firmware_update_is_available][translate $::de1(firmware_update_button_label)]} 
		add_de1_text "firmware_update_4" 40 1400 -text [translate "Your DE1 firmware is now ready to be applied"] -font Helv_10 -width 1200 -fill "#444444" -anchor "nw" -justify "left" 
		add_de1_text "firmware_update_4" 40 1500 -text "[translate "Firmware Update"] - [translate "Page"]  4/5" -font Helv_12_bold -fill "#888888" -anchor "nw" -justify "left"
		add_de1_text "firmware_update_4" 2290 1508 -text [translate "Cancel"] -font Helv_10_bold -fill "#DDDDDD" -anchor "center"
		add_de1_button "firmware_update_4" {say [translate {Exit}] $::settings(sound_button_in); app_exit} 1960 1200 2560 1600 ""
		#add_de1_variable "firmware_update_5" 60 120 -text "" -font Helv_10_bold -fill "#222222" -anchor "nw" -width [rescale_y_skin 700] -justify "left" -textvariable {[if {$::de1(currently_updating_firmware) == 0} { page_show firmware_update_5 }; return [firmware_uploaded_label]]} 
		#add_de1_text "firmware_update_4" 730 800 -text [subst {[translate "Turn your DE1 off. Wait a few seconds. Turn your DE1 on."]\n\n[translate "Please be patient. It can take several minutes for your DE1 to update."]}] -font Helv_8 -fill "#222222" -anchor "ne" -width [rescale_y_skin 700] -justify "right" 
		add_de1_variable "firmware_update_4" 2030 300 -text "" -font Helv_16_bold -fill "#222222" -anchor "center" -width [rescale_y_skin 700] -justify "center" -textvariable {[if {$::de1(device_handle) == 0} { after 120000 enable_de1_reconnect; after 600000 app_exit; page_show firmware_update_5; }; return ""]}

	add_de1_text "firmware_update_5" 40 20 -text [translate "Turn your DE1 on"] -font Helv_16_bold -width 1200 -fill "#444444" -anchor "nw" -justify "left" 
		add_de1_text "firmware_update_5" 40 1500 -text "[translate "Firmware Update"] - [translate "Page"]  5/5" -font Helv_12_bold -fill "#888888" -anchor "nw" -justify "left"
		add_de1_text "firmware_update_5" 2290 1508 -text [translate "Exit"] -font Helv_10_bold -fill "#DDDDDD" -anchor "center"
		add_de1_button "firmware_update_5" {say [translate {Cancel}] $::settings(sound_button_in); app_exit} 1960 1200 2560 1600 ""
		add_de1_variable "firmware_update_5" 40 120 -text [translate "Please be patient. It can take several minutes for your DE1 to update."] -font Helv_8 -fill "#222222" -anchor "nw" -width [rescale_y_skin 840] -justify "left" -textvariable {[if {$::de1(device_handle) != 0} { app_exit }; return [translate "Please be patient. It can take several minutes for your DE1 to update."]]}
		#add_de1_text "firmware_update_6" 730 800 -text [translate "Please be patient. It can take several minutes for your DE1 to update."] -font Helv_8 -fill "#222222" -anchor "ne" -width [rescale_y_skin 700] -justify "right" 



		#add_de1_variable "firmware_update_4" 730 700 -text "" -font Helv_10_bold -fill "#222222" -anchor "ne" -width [rescale_y_skin 700] -justify "right" -textvariable {[if {$::de1(device_handle) == 0 && $::android == 1} { app_exit }; return [firmware_uploaded_label]]} 
		#add_de1_text "firmware_update_4" 730 800 -text [subst {[translate "Turn your DE1 off. Wait a few seconds. Turn your DE1 on."]\n\n[translate "Please be patient. It can take several minutes for your DE1 to update."]}] -font Helv_8 -fill "#222222" -anchor "ne" -width [rescale_y_skin 700] -justify "right" 

	if {$::android == 0} {
		# cheat buttons when running on not-android, so as to be able to advance to the next screen
		# purely for debugging the GUI
		add_de1_button "firmware_update_1" {set ::de1(device_handle) 0} 0 1200 100 1600 ""
		add_de1_button "firmware_update_2" {set ::de1(device_handle) 1 } 0 1200 100 1600 ""
		add_de1_button "firmware_update_4" {set ::de1(device_handle) 0 } 0 1200 100 1600 ""
		add_de1_button "firmware_update_5" {set ::de1(device_handle) 1 } 0 1200 100 1600 ""
	}

	
	#set ::de1(currently_updating_firmware) 0

	add_de1_text "settings_4" 2290 416 -text [translate "Language"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center" 
		add_de1_button "settings_4" {say [translate {Language}] $::settings(sound_button_in); page_to_show_when_off languages; ; set_languages_scrollbar_dimensions}  1910 306 2530 510

		add_de1_text "languages" 1280 300 -text [translate "Language"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center" 
		add_de1_widget "languages" listbox 900 480 { 
			set ::languages_widget $widget
			bind $widget <<ListboxSelect>> ::load_language
			fill_languages_listbox
		} -background #fbfaff -xscrollcommand {scale_prevent_horiz_scroll $::languages_widget} -yscrollcommand {scale_scroll_new $::languages_widget ::language_slider} -font global_font -bd 0 -height [expr {int(9 * $::globals(listbox_length_multiplier))}] -width 26 -foreground #d3dbf3 -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single  -selectbackground #c0c4e1


		set ::language_slider 0
		set ::languages_scrollbar [add_de1_widget "languages" scale 10000 1 {} -from 0 -to 1.0 -bigincrement 0.2 -background "#d3dbf3" -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 400] -width [rescale_y_skin 150] -variable ::language_slider -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::languages_widget $::language_slider}  -foreground #FFFFFF -troughcolor "#f7f6fa" -borderwidth 0  -highlightthickness 0]


		# this moves the scrollbar to the right of the languages listbox, and sets its height correctly
		# this can't be done until the page is rendered, because the windowing system doesn't know ahead of time the true dimensions of the listbox, not until it is rendered
		proc set_languages_scrollbar_dimensions {} {
			set_scrollbar_dimensions $::languages_scrollbar $::languages_widget
		}


	add_de1_text "settings_4" 1656 616 -text [translate "Misc"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center" 
		add_de1_button "settings_4" {say [translate {Misc}] $::settings(sound_button_in); page_to_show_when_off measurements; }  1290 520 1900 720
		add_de1_text "measurements" 1280 300 -text [translate "Misc"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center" 
		
		#add_de1_text "measurements" 1300 480 -text [translate "Units"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
			#add_de1_widget "measurements" checkbutton 1300 560 {} -text [translate "Fahrenheit"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_fahrenheit)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF  -bd 0 -activeforeground #4e85f4 -relief flat -bd 0
			dui add dselector "measurements" 2280 480 -bwidth 600 -bheight 80 -orient h -anchor ne -values {0 1} -variable ::settings(enable_fahrenheit) -labels [list [translate "Celsius"] [translate "Fahrenheit"]] -width 2 -fill "#f8f8f8" -selectedfill "#4d85f4" 
			



			#add_de1_widget "measurements" checkbutton 1650 60 {} -text [translate "AM/PM"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_ampm)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat 
			dui add dtoggle "measurements" 1280 504 -height 60 -anchor nw -variable ::settings(enable_ampm) 
			add_de1_text "measurements" 1420 504 -text [translate "AM/PM"] -font $optionfont -width 1200 -fill "#4e85f4" -anchor "nw" 
			add_de1_button "measurements" { set ::settings(enable_ampm) [expr {!$::settings(enable_ampm)}] } 1280 504 1650 564

			#add_de1_widget "measurements" checkbutton 2000 560 {} -text [translate "1.234,56"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_commanumbers)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat 

			dui add dtoggle "measurements" 1280 604 -height 60 -anchor nw -variable ::settings(enable_commanumbers) 
			add_de1_text "measurements" 1420 604 -text [translate "1.234,56"] -font $optionfont -width 1200 -fill "#4e85f4" -anchor "nw" 
			add_de1_button "measurements" { set ::settings(enable_commanumbers) [expr {!$::settings(enable_commanumbers)}] } 1280 604 1670 664

	
		
	


		#if {$::settings(display_fluid_ounces_option) == 1} {
		#	add_de1_widget "measurements" checkbutton 690 1000 {} -text [translate "Fluid ounces"] -indicatoron true  -font Helv_9 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_fluid_ounces)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4 -relief flat  
		#}

		#add_de1_text "measurements" 1300 660 -text [translate "Optional features"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

			if {[ifexists ::settings(skin)] == "Insight" && [ghc_required] != 1} {
				# this feature is specific to the Insight skin
				#add_de1_widget "measurements" checkbutton 1800 40 {} -text [translate "One-tap mode"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(one_tap_mode)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat 

				# obsoleted by GHC
				#dui add dtoggle "measurements" 1700 504 -height 60 -anchor nw -variable ::settings(one_tap_mode) 
				#add_de1_text "measurements" 1840 504 -text [translate "One-tap mode"] -font $optionfont -width 1200 -fill "#4e85f4" -anchor "nw" 

			}

			if {[ghc_required] == 0} {
				# this feature requires NO GHC to be installed because UL requires that all dangerous operations be started on the GHC. 
				# The way this feature currently works is by sending a bluetooth start command after the command ends. With a GHC installed, that bluetooth command is ignored
				# note: we could likely replicate this feature in the future with a firmware requiest to repeat the command indefinitely, and this would be UL compliant as the first time would need to be GHC started.
				#add_de1_widget "measurements" checkbutton 1800 80  {} -text [translate "Repeat last command"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(stress_test)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat 

				dui add dtoggle "measurements"  1740 604 -height 60 -anchor nw -variable ::settings(stress_test) 
				add_de1_text "measurements" 1880 604 -text [translate "Repeat last command"] -font $optionfont -width 1200 -fill "#4e85f4" -anchor "nw" 
			}

			#set ::_placebo_true 1
			#add_de1_widget "measurements" checkbutton 1300 740  {} -text [translate "Logging is enabled"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable _placebo_true -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat  -state disabled

			#add_de1_widget "measurements" checkbutton 950 90  {} -text [translate "clock"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor ne -foreground #4e85f4 -variable ::settings(display_time_in_screen_saver)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat 

			dui add dtoggle "measurements" 1140 510 -height 40 -width 80 -anchor ne -variable ::settings(display_time_in_screen_saver) 
			add_de1_text "measurements" 1040 498 -text [translate "clock"] -font $optionfont -width 1200 -fill "#4e85f4" -anchor "ne" 
			add_de1_button "measurements" { set ::settings(display_time_in_screen_saver) [expr {!$::settings(display_time_in_screen_saver)}] } 840 504 1140 550


			#if {$::android != 1} {
				# for tablets, allow "finger down" to be a "tap" instead of the default "mousedown" OS-defined action
			#add_de1_widget "measurements" checkbutton 1300 800  {} -text [translate "Fast tap mode"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor ne -foreground #4e85f4 -variable ::settings(use_finger_down_for_tap)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat 

			dui add dtoggle "measurements" 1280 704 -height 60 -anchor nw -variable ::settings(use_finger_down_for_tap) 
			add_de1_text "measurements" 1420 704 -text [translate "Fast tap mode"] -font $optionfont -width 1200 -fill "#4e85f4" -anchor "nw" 
			add_de1_button "measurements" { set ::settings(use_finger_down_for_tap) [expr {!$::settings(use_finger_down_for_tap)}] } 1280 704 1700 764

			dui add dtoggle "measurements" 1280 804 -height 60 -anchor nw -variable ::settings(smart_battery_charging) 
			add_de1_text "measurements" 1420 804 -text [translate "Smart charging"] -font $optionfont -width 1200 -fill "#4e85f4" -anchor "nw" 
			add_de1_button "measurements" { set ::settings(smart_battery_charging) [expr {!$::settings(smart_battery_charging)}] } 1280 804 1700 864


			#}

		add_de1_text "measurements" 1300 940 -text [translate "Font size"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
			add_de1_widget "measurements" scale 1300 1000 {} -from 0.1 -to 2 -background #e4d1c1 -borderwidth 1 -bigincrement 0.05 -showvalue 0 -resolution 0.05 -length [rescale_x_skin 400] -width [rescale_y_skin 100] -variable ::settings(default_font_calibration) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 
			add_de1_variable "measurements" 1300 1100 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {$::settings(default_font_calibration)}

proc calculate_screen_flip_value {} {
	#puts calculate_screen_flip_value
	# a checkbox turns the "screen flip" setting on/off. We then convert that into into reverselandscape/landscape
	if {[info exists ::globals(screen_flip)] != 1} {
		# global var has not yet been set, so set it from the saved settings variable
		if {[ifexists ::settings(orientation)] == "landscape"} {
			set ::globals(screen_flip) 0
		} else {
			set ::globals(screen_flip) 1
		}
	} else {
		if {$::globals(screen_flip) == 0} {
			set ::settings(orientation) "landscape"
		} else {
			set ::settings(orientation) "reverselandscape"
		}
	}
	#puts $::settings(orientation)
	
	return 0
}

		add_de1_text "measurements" 1800 940 -text [translate "Resolution"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
			add_de1_widget "measurements" scale 1800 1000 {} -from 320 -to 2800 -background #e4d1c1 -borderwidth 1 -bigincrement 400 -showvalue 0 -resolution 1 -length [rescale_x_skin 500] -width [rescale_y_skin 100] -variable ::settings(screen_size_width) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0  -command set_resolution_height_from_width
			add_de1_variable "measurements" 1800 1100 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {$::settings(screen_size_width) x $::settings(screen_size_height)}
			calculate_screen_flip_value
			#add_de1_widget "measurements" checkbutton 2100 1320  {} -text [translate "flip"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor ne -foreground #4e85f4 -variable ::globals(screen_flip)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat -command calculate_screen_flip_value

			dui add dtoggle "measurements" 2300 954 -height 40 -width 80 -anchor ne -variable ::globals(screen_flip)
			add_de1_text "measurements" 2210 940 -text [translate "flip"] -font $optionfont -width 1200 -fill "#4e85f4" -anchor "ne" 
			add_de1_button "measurements" { set ::globals(screen_flip) [expr {!$::globals(screen_flip)}] ; calculate_screen_flip_value} 2010 946 2310 990 



			
		add_de1_text "measurements" 340 480 -text [translate "Screen saver"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
			add_de1_widget "measurements" scale 340 560 {} -from 0 -to 100 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 800] -width [rescale_y_skin 100] -variable ::settings(saver_brightness) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 
			add_de1_variable "measurements" 340 660 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Brightness"] $::settings(saver_brightness)%}

			add_de1_variable "measurements" 20 1540 -text "" -font Helv_6 -fill "#888888" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Battery"] [battery_percent]% : [battery_state] : $::de1(usb_charger_on)}
			add_de1_button "measurements" {say [translate {USB}] $::settings(sound_button_in); toggle_usb_charger_on} 0 1400 600 1600

			add_de1_widget "measurements" scale 340 740 {} -from 0 -to 120 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 800] -width [rescale_y_skin 100] -variable ::settings(screen_saver_change_interval) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0
			add_de1_variable "measurements" 340 840 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[screen_saver_change_minutes $::settings(screen_saver_change_interval)]}

			add_de1_text "measurements" 340 940 -text [translate "App version"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
				dui add dselector "measurements" 340 1020 -bwidth 800 -bheight 80 -orient h -anchor nw -values {0 1 2} -variable ::settings(app_updates_beta_enabled) -labels [list [translate "stable"] [translate "beta"] [translate "nightly"]]  -width 2 -fill "#f8f8f8" -selectedfill "#4d85f4"

	add_de1_text "settings_4" 2290 616 -text [translate "Extensions"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center" 
	add_de1_button "settings_4" {say [translate {Extensions}] $::settings(sound_button_in); fill_extensions_listbox; page_to_show_when_off extensions; ; set_extensions_scrollbar_dimensions}  1910 520 2530 720

		add_de1_text "extensions" 1280 300 -text [translate "Extensions"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center" 
		add_de1_widget "extensions" listbox 340 480 { 
			set ::extensions_widget $widget
			bind $widget <<ListboxSelect>> ::highlight_extension
		} -background #fbfaff -xscrollcommand {scale_prevent_horiz_scroll $::extensions_widget} -yscrollcommand {scale_scroll_new $::extensions_widget ::extensions_slider} -font global_font -bd 0 -height [expr {int(9 * $::globals(listbox_length_multiplier))}] -width 26 -foreground #666666 -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single  -selectbackground #c0c4e1		
		set ::extension_highlighted -1

		# Old -fill "#444444"
		set ::extensions_metadata [add_de1_text "extensions" 1200 480 -text  "" -font global_font -width 550 -fill "#7f879a" -anchor "nw" -justify "left" ]

		set ::extensions_slider 0
		set ::extensions_scrollbar [add_de1_widget "extensions" scale 10000 1 {} -from 0 -to 1.0 -bigincrement 0.2 -background "#d3dbf3" -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 400] -width [rescale_y_skin 150] -variable ::language_slider -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::extensions_widget $::extensions_slider}  -foreground #FFFFFF -troughcolor "#f7f6fa" -borderwidth 0  -highlightthickness 0]

		set ::extensions_settings [add_de1_text "extensions" 2180 1150 -text "⚙️ [translate "Settings"]" -font Helv_11_bold -fill "#000000" -anchor "center"]
		set ::extensions_settings_button [add_de1_button "extensions" {fill_plugin_settings}  2100 1010 2330 1310]

		# this moves the scrollbar to the right of the extensions listbox, and sets its height correctly
		# this can't be done until the page is rendered, because the windowing system doesn't know ahead of time the true dimensions of the listbox, not until it is rendered
		# NOTE: This can be removed, because 'after_show_extensions' makes it redundant. Left at the moment to not
		#	break existing plugins code.
		proc set_extensions_scrollbar_dimensions {} {
			set_scrollbar_dimensions $::extensions_scrollbar $::extensions_widget
		}

		proc after_show_extensions {} {
			set_scrollbar_dimensions $::extensions_scrollbar $::extensions_widget
			fill_extensions_listbox
			set stepnum [$::extensions_widget curselection]	
		}
		::add_de1_action "extensions" ::after_show_extensions

# grid [radiobutton .gender.maleBtn -text "Male"   -variable gender -value "Male"-command "set  myLabel1 Male"] -row 1 -column 2
# grid [radiobutton .gender.femaleBtn -text "Female" -variable gender -value "Female"   -command "set  myLabel1 Female"] -row 1 -column 3				
				#add_de1_widget "measurements" scale 340 1010 {} -to 30 -from 0 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 800]  -width [rescale_y_skin 100] -variable ::settings(app_update_delay_notification) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command "" -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 

				#add_de1_variable "measurements" 340 1110 -text "" -font Helv_7 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Once stable for:"] [days_text $::settings(app_update_delay_notification)]}

	# "done" button for all these sub-pages.
	add_de1_text "tabletstyles languages measurements extensions" 1280 1310 -text [translate "Done"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"
	add_de1_button "tabletstyles languages measurements extensions" {say [translate {Done}] $::settings(sound_button_in); page_to_show_when_off settings_4;} 980 1210 1580 1410 ""
##############################################################################


# exit app feature
add_de1_text "settings_4" 1310 1130 -text [translate "Exit app"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
	add_de1_text "settings_4" 1900 1290 -text [translate "Exit"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center" 
	add_de1_button "settings_4" {say [translate {Exit}] $::settings(sound_button_in); .can itemconfigure $::message_label -text [translate "Going to sleep"]; .can itemconfigure $::message_button_label -text [translate "Wait"]; after 10000 {.can itemconfigure $::message_button_label -text [translate "Ok"]; }; page_to_show_when_off message; save_settings; after 500 app_exit} 1290 1120 2550 1400


add_de1_text "settings_3" 55 544 -text [translate {Version}] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width [rescale_y_skin 1220] -justify "left" 
	add_de1_variable "settings_3" 55 616 -text "" -font Helv_7 -fill "#7f879a" -anchor "nw" -width [rescale_y_skin 1180] -justify "left" -textvariable {[de1_version_string]} 

#add_de1_text "settings_3" 1310 380 -text [translate "Water level"] -font Helv_7_bold -fill "#7f879a" -anchor "nw" -width [rescale_y_skin 1000] -justify "left" 
#	add_de1_variable "settings_3" 1600 380 -text "" -font Helv_7 -fill "#7f879a" -anchor "nw" -width [rescale_y_skin 1000] -justify "left" -textvariable {[round_to_integer $::de1(water_level)][translate mm]}

	#add_de1_text "settings_3" 1310 350 -text [translate "Counter"] -font Helv_7_bold -fill "#7f879a" -anchor "nw" -width [rescale_y_skin 1000] -justify "left"

	add_de1_text "settings_3" 55 220 -text [translate "Counter"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
		add_de1_text "settings_3" 55 310 -text [translate "Espresso"] -font Helv_8 -fill "#7f879a" -anchor "nw" -width [rescale_y_skin 1000] -justify "left" 
		add_de1_text "settings_3" 55 370 -text [translate "Steam"] -font Helv_8 -fill "#7f879a" -anchor "nw" -width [rescale_y_skin 1000] -justify "left"
		add_de1_text "settings_3" 55 430 -text [translate "Hot water"] -font Helv_8 -fill "#7f879a" -anchor "nw" -width [rescale_y_skin 1000] -justify "left"
		add_de1_variable "settings_3" 400 310 -text "" -font Helv_8 -fill "#7f879a" -anchor "nw" -width [rescale_y_skin 1000] -justify "right" -textvariable {[round_to_integer $::settings(espresso_count)]}
		add_de1_variable "settings_3" 400 370 -text "" -font Helv_8 -fill "#7f879a" -anchor "nw" -width [rescale_y_skin 1000] -justify "right" -textvariable {[round_to_integer $::settings(steaming_count)]}
		add_de1_variable "settings_3" 400 430 -text "" -font Helv_8 -fill "#7f879a" -anchor "nw" -width [rescale_y_skin 1000] -justify "right" -textvariable {[round_to_integer $::settings(water_count)]}

proc scheduler_feature_hide_show_refresh {  } {
	puts "scheduler_feature_hide_show_refresh $::settings(scheduler_enable)"
	if {[ifexists ::settings(scheduler_enable)] == 1} {
		dui item show settings_3 scheduler
	} else {
		dui item hide settings_3 scheduler
	}
}

#add_de1_widget "settings_2c" checkbutton 1538 830 {} -text [translate "4: Move on if..."] -padx 0 -pady 0 -indicatoron true  -font Helv_9_bold -anchor nw -foreground #7f879a -activeforeground #7f879a -variable ::current_adv_step(exit_if)  -borderwidth 0  -highlightthickness 0  -command save_current_adv_shot_step -selectcolor #f9f9f9 -activebackground #f9f9f9 -bg #f9f9f9 -relief flat 
# scheduled power up/down
#add_de1_widget "settings_3" checkbutton 50 1440 {} -text [translate "Keep hot"] -padx 0 -pady 0 -indicatoron true  -font Helv_8_bold -bg #FFFFFF -anchor nw -foreground #7f879a -activeforeground #7f879a -variable ::settings(scheduler_enable)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -command scheduler_feature_hide_show_refresh -relief flat 
add_de1_text "settings_3" 180 1134 -justify left -anchor "nw" -font $optionfont -text [translate "Keep hot"]  -fill "#4e85f4" -width [rescale_x_skin 1000] 
dui add dtoggle "settings_3" 50 1140 -height 50 -width 100 -anchor nw -variable ::settings(scheduler_enable) -command scheduler_feature_hide_show_refresh 
add_de1_button "settings_3" { set ::settings(scheduler_enable) [expr {! $::settings(scheduler_enable)}]; scheduler_feature_hide_show_refresh } 50 1140 500 1190

# hack used because the -command to dtoggle command above is not working
#trace add variable ::settings(scheduler_enable) write scheduler_feature_hide_show_refresh


	add_de1_widget "settings_3" scale 50 1200 {} -from 0 -to 85800 -background #e4d1c1 -borderwidth 1 -bigincrement 3600 -showvalue 0 -resolution 600 -length [rescale_x_skin 570] -width [rescale_y_skin 135] -variable ::settings(scheduler_wake) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -tags [list scheduler_scale_start scheduler]
	add_de1_variable "settings_3" 50 1340 -text "" -font Helv_7 -fill "#7f879a" -anchor "nw"  -tags [list scheduler_start_time scheduler] -textvariable {[translate "Start"] [format_alarm_time $::settings(scheduler_wake)]}
	add_de1_widget "settings_3" scale 670 1200 {} -from 0 -to 85800 -background #e4d1c1 -borderwidth 1 -bigincrement 3600 -showvalue 0 -resolution 600 -length [rescale_x_skin 570] -width [rescale_y_skin 135] -variable ::settings(scheduler_sleep) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -tags [list scheduler_scale_end scheduler]
	add_de1_variable "settings_3" 670 1340 -text "" -font Helv_7 -fill "#7f879a" -anchor "nw" -tags [list scheduler_end_time scheduler] -textvariable {[translate "End"] [format_alarm_time $::settings(scheduler_sleep)]} 
	add_de1_variable "settings_3" 1240 1140 -text "" -font Helv_7 -fill "#7f879a" -anchor "ne" -width [rescale_y_skin 1000] -justify "right" -tags [list scheduler_scale_now_time scheduler] -textvariable {[translate "Now"] [time_format [clock seconds]]}
	dui add dbutton "settings_3" 900 1100 1240 1190 -command {say [translate {Settings}] $::settings(sound_button_in); launch_os_time_setting}  -tags [list scheduler_settings_button scheduler]

	set_alarms_for_de1_wake_sleep

add_de1_text "settings_4" 55 970 -text [translate "Connect"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

	add_de1_variable "settings_4" 980 1016 -text {} -font Helv_8_bold -fill "#FFFFFF" -anchor "center"  -textvariable {[scanning_state_text]} 
		add_de1_button "settings_4" {say [translate {Search}] $::settings(sound_button_in); scanning_restart} 650 960 1260 1070

	add_de1_text "settings_4" 60 1100 -text [translate "Espresso machine"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"
		add_de1_widget "settings_4" listbox 55 1150 { 
				set ::ble_listbox_widget $widget
				bind $::ble_listbox_widget <<ListboxSelect>> ::change_bluetooth_device
				fill_ble_listbox
			} -background #fbfaff -font Helv_9 -bd 0 -height 3 -width 15 -foreground #d3dbf3 -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single -selectbackground #c0c4e1 -yscrollcommand {scale_scroll_new $::ble_listbox_widget ::ble_slider}

		set ::ble_slider 0
		set ::ble_scrollbar [add_de1_widget "settings_4" scale 10000 1 {} -from 0 -to 1.0 -bigincrement 0.2 -background "#d3dbf3" -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 400] -width [rescale_y_skin 150] -variable ::ble_slider -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::ble_listbox_widget $::ble_slider}  -foreground #FFFFFF -troughcolor "#f7f6fa" -borderwidth 0  -highlightthickness 0]

		proc set_ble_scrollbar_dimensions {} {
			set_scrollbar_dimensions $::ble_scrollbar $::ble_listbox_widget
		}

	add_de1_text "settings_4" 680 1100 -text [translate "Scale"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"
		add_de1_variable "settings_4" 1240 1100 -text \[[translate "Remove"]\] -font Helv_7 -fill "#bec7db" -justify "right" -anchor "ne" -textvariable {[if {$::settings(scale_bluetooth_address) != ""} { return \[[translate "Remove"]\]} else {return "" } ] }
		add_de1_variable "settings_4" 900 1100 -font Helv_7 -fill "#bec7db" -justify "left" -anchor "nw" -textvariable {[if {$::settings(scale_bluetooth_address) != ""} { return [return_weight_measurement [ifexists ::de1(scale_weight)]] } else {return "" } ] }
		
		# optionally display timestamp from the decent scale
		# add_de1_variable "settings_4" 900 1050 -font Helv_7 -fill "#bec7db" -justify "left" -anchor "nw" -textvariable {[if {$::settings(scale_bluetooth_address) != ""} { return [return_scale_timer] } else {return "" } ] }
		
		add_de1_button "settings_4" {say [translate {Remove}] $::settings(sound_button_in); remove_peripheral $::settings(scale_bluetooth_address) ; set ::settings(scale_bluetooth_address) ""; fill_peripheral_listbox} 1030 1100 1250 1140 ""
		add_de1_button "settings_4" {say [translate {Tare}] $::settings(sound_button_in); ::device::scale::tare; borg toast [translate "Tare"]} 800 1100 1026 1140 ""
		add_de1_widget "settings_4" listbox 670 1150 { 
				set ::ble_scale_listbox_widget $widget
				bind $widget <<ListboxSelect>> ::change_scale_bluetooth_device
				fill_peripheral_listbox
			} -background #fbfaff -font Helv_9 -bd 0 -height 3 -width 15  -foreground #d3dbf3 -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single -selectbackground #c0c4e1 -yscrollcommand {scale_scroll_new $::ble_scale_listbox_widget ::ble_scale_slider}

		set ::ble_scale_slider 0
		set ::ble_scale_scrollbar [add_de1_widget "settings_4" scale 10000 1 {} -from 0 -to .90 -bigincrement 0.2 -background "#d3dbf3" -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 400] -width [rescale_y_skin 150] -variable ::ble_scale_slider -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::ble_scale_listbox_widget $::ble_scale_slider}  -foreground #FFFFFF -troughcolor "#f7f6fa" -borderwidth 0  -highlightthickness 0]

		proc set_ble_scale_scrollbar_dimensions {} {
			set_scrollbar_dimensions $::ble_scale_scrollbar $::ble_scale_listbox_widget
		}

#set_next_page off settings_4

#add_de1_widget "settings_4" checkbutton 70 [expr {$pos_top + (0 * $spacer)}] {} -text [translate "Calibrate"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::calibrate_toggle  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat -command {
#	calibration_gui_init; set ::calibrate_toggle 0; set_next_page off calibrate; page_show calibrate; 
#}


#add_de1_widget "settings_4" checkbutton 70 [expr {$pos_top + (2 * $spacer)}] {} -text [translate "Prepare for transport"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::prepare_for_suitcase_toggle  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat -command {
#	set ::prepare_for_suitcase_toggle 0; set_next_page off travel_prepare; page_show travel_prepare; 
#}

# advanced features that are normally disabled
#add_de1_widget "settings_4" checkbutton 70 [expr {$pos_top + (1 * $spacer)}] {} -text [translate "Show water level"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(waterlevel_indicator_on)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat 
#add_de1_widget "settings_4" checkbutton 70 [expr {$pos_top + (1 * $spacer)}] {} -text [translate "Blinking low water warning"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(waterlevel_indicator_blink)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat 
#add_de1_widget "settings_4" checkbutton 70 [expr {$pos_top + (2 * $spacer)}] {} -text [translate "Show adaptive water temperature"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(display_espresso_water_delta_number)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat 
#add_de1_widget "settings_4" checkbutton 70 [expr {$pos_top + (3 * $spacer)}] {} -text [translate "Rate your espresso shots"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(display_rate_espresso)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat 

# not yet ready to be used, still needs some work
#add_de1_widget "settings_4" checkbutton 70 [expr {$pos_top + (4 * $spacer)}] {} -text [translate "Chart pressure changes"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(display_pressure_delta_line)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat 
#add_de1_widget "settings_4" checkbutton 70 [expr {$pos_top + (5 * $spacer)}] {} -text [translate "Chart flow rate changes"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(display_flow_delta_line)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat 

# this feature is now automatically enabled if you have a bluetooth scale connected
#if {$::settings(skale_bluetooth_address) != ""} {
	#add_de1_widget "settings_4" checkbutton 70 [expr {$pos_top + (7 * $spacer)}] {} -text [translate "Chart weight changes"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(display_weight_delta_line)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF -bd 0 -activeforeground #4e85f4  -relief flat 
#}


add_de1_text "travel_prepare" 1280 120 -text [translate "Prepare your espresso machine for transport"] -font Helv_15_bold -fill "#a77171" -anchor "center" -width 1000
	add_de1_text "travel_prepare" 1520 1000 -text [translate "After you press Ok, pull the water tank forward as shown in this photograph."] -font Helv_10_bold -fill "#a77171" -anchor "nw" -width 500
	add_de1_text "travel_prepare" 280 1504 -text [translate "Cancel"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
	add_de1_text "travel_prepare" 2300 1504 -text [translate "Ok"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
	add_de1_button "travel_prepare" {say [translate {Cancel}] $::settings(sound_button_in); de1_send_shot_frames; page_to_show_when_off settings_3;} 0 1200 600 1600 ""
	add_de1_button "travel_prepare" {say [translate {Ok}] $::settings(sound_button_in); set_next_page off settings_3; start_air_purge} 1960 1200 2560 1600 ""
	add_de1_text "travel_do" 1280 120 -text [translate "Now removing water from your espresso machine."] -font Helv_15_bold -fill "#a77171" -anchor "center" -width 1000
	add_de1_text "travel_do" 1520 1000 -text [translate "You can turn your machine off once it is out of water. It will then be ready for transport."] -font Helv_10_bold -fill "#a77171" -anchor "nw" -width 500
	#add_de1_text "travel_do" 1280 1520 -text [translate "It will then be ready for transport."] -font Helv_10_bold -fill "#000000" -anchor "center" -width 1000


add_de1_text "descale_prepare" 70 50 -text [translate "Prepare to descale"] -font Helv_20_bold -fill "#a77171" -anchor "nw" -width 1000
	add_de1_text "descale_prepare" 1050 280 -text [translate "1) Remove the drip tray and its cover."] -font Helv_8_bold -fill "#a77171" -anchor "sw" -justify left -width 400
	add_de1_text "descale_prepare" 1050 670 -text [translate "2) In the water tank, mix 1.5 liter hot water with 300g citric acid powder."] -font Helv_8_bold -fill "#a77171" -anchor "sw" -justify left -width 400
	add_de1_text "descale_prepare" 1050 970 -text [subst {[translate "3) Put a blind basket in the portafilter."] [translate "Lower the steam wand."]}] -font Helv_8_bold -fill "#a77171" -anchor "sw" -justify left -width 400
	add_de1_text "descale_prepare" 1050 1350 -text [translate "4) Push back the water tank.  Place the drip tray back without its cover."] -font Helv_8_bold -fill "#a77171" -anchor "sw" -justify left -width 400
	add_de1_text "descale_prepare" 340 1504 -text [translate "Cancel"] -font Helv_10_bold -fill "#444444" -anchor "center"
	add_de1_text "descale_prepare" 2233 1504 -text [translate "Descale now"] -font Helv_10_bold -fill "#444444" -anchor "center"
	add_de1_button "descale_prepare" {say [translate {Cancel}] $::settings(sound_button_in);page_to_show_when_off settings_3;} 0 1200 700 1600 ""
	add_de1_button "descale_prepare" {say [translate {Ok}] $::settings(sound_button_in); start_decaling} 1860 1200 2560 1600 ""
	#add_de1_text "travel_do" 1280 120 -text [translate "Now removing water from your espresso machine."] -font Helv_15_bold -fill "#000000" -anchor "center" -width 1000
	#add_de1_text "travel_do" 1520 1000 -text [translate "You can turn your machine off once it is out of water. It will then be ready for transport."] -font Helv_10_bold -fill "#000000" -anchor "nw" -width 500
	#add_de1_text "travel_do" 1280 1520 -text [translate "It will then be ready for transport."] -font Helv_10_bold -fill "#000000" -anchor "center" -width 1000

add_de1_text "settings_3" 1304 1080  -text [translate "Water level"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
	add_de1_widget "settings_3" scale 1304 1170 {} -from 3 -to 70 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 1190] -width [rescale_y_skin 115] -variable ::settings(water_refill_point) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 
	add_de1_variable "settings_3" 1304 1300 -text "" -font Helv_7 -fill "#7f879a" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Refill at:"] [water_tank_level_to_milliliters $::settings(water_refill_point)] [translate mL] ([expr {$::settings(water_refill_point) + $::de1(water_level_mm_correction)}][translate mm])}
	add_de1_variable "settings_3" 2488 1120 -text "" -font Helv_7 -fill "#7f879a" -anchor "ne" -width [rescale_y_skin 1000] -justify "right" -textvariable {[translate "Now:"] [water_tank_level_to_milliliters $::de1(water_level)] [translate mL] ([round_to_integer $::de1(water_level)][translate mm])}
	#add_de1_button "settings_3" {start_refill_kit }  0 760 620 820

	#add_de1_variable "settings_4" 50 760 -text "" -font Helv_7 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Refill at:"] $::settings(water_refill_point)[translate mm]}
	#add_de1_variable "settings_4" 1240 760 -text "" -font Helv_7 -fill "#7f879a" -anchor "ne" -width [rescale_y_skin 1000] -justify "right" -textvariable {[translate "Now:"] [round_to_integer $::de1(water_level)][translate mm]}

# bluetooth scan
#add_de1_text "settings_4" 2230 980 -text [translate "Search"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
#add_de1_button "settings_4" {set ::de1_device_list ""; say [translate {search}] $::settings(sound_button_in); ble_find_de1s} 1910 890 2550 1080

set enable_spoken_buttons 0
if {$enable_spoken_buttons == 1} {
	add_de1_widget "settings_3" scale 1350 580 {} -from 0 -to 4 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1100] -width [rescale_y_skin 135] -variable ::settings(speaking_rate) -font Helv_10_bold -sliderlength [rescale_x_skin 75] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 
	add_de1_text "settings_3" 1350 785 -text [translate "Speaking speed"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

	add_de1_widget "settings_3" scale 1350 840 {} -from 0 -to 3 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1100] -width [rescale_y_skin 135] -variable ::settings(speaking_pitch) -font Helv_10_bold -sliderlength [rescale_x_skin 75] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 
	add_de1_text "settings_3" 1350 1045 -text [translate "Speaking pitch"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"
	add_de1_text "settings_3" 1350 250 -text [translate "Speaking"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
	add_de1_widget "settings_3" checkbutton 1350 400 {} -text [translate "Enable spoken prompts"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_spoken_prompts)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
}

add_de1_text "settings_4" 50 566 -text [translate "Screen brightness"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
	add_de1_widget "settings_4" scale 50 660 {} -from 0 -to 100 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 1170] -width [rescale_y_skin 135] -variable ::settings(app_brightness) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -command {display_brightness}
	add_de1_variable "settings_4" 50 800 -text "" -font Helv_7 -fill "#7f879a" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "App:"] $::settings(app_brightness)%}


add_de1_text "settings_3" 50 770 -text [translate "Energy saver"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
	add_de1_widget "settings_3" scale 50 870 {} -from 0 -to 120 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 1170] -width [rescale_y_skin 135] -variable ::settings(screen_saver_delay) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 
	add_de1_variable "settings_3" 50 1020 -text "" -font Helv_7 -fill "#7f879a" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Cool down after:"] [minutes_text $::settings(screen_saver_delay)]}


add_de1_button "settings_1" {say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; save_profile} 2300 1220 2550 1410

# trash can icon to delete a preset
add_de1_button "settings_1" {say [translate {Cancel}] $::settings(sound_button_in); delete_selected_profile} 1120 280 1300 460

# plus icon to create a new preset
add_de1_button "settings_1" {say [translate {new}] $::settings(sound_button_in); page_to_show_when_off "create_preset"; } 1120 530 1300 730

# eyeball icon to show or hide preset
add_de1_button "settings_1" {say [translate {Choose which presets to show}] $::settings(sound_button_in); if {[ifexists ::profiles_hide_mode] != 1} { set ::profiles_hide_mode 1 } else { unset -nocomplain ::profiles_hide_mode } ; fill_profiles_listbox} 1120 800 1300 1000

#############################

#############################
# create a new preset
add_de1_text "create_preset" 2275 1520 -text [translate "Cancel"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
	add_de1_button "create_preset" {set_next_page off "settings_1"; page_show off;} 2016 1430 2560 1600


	add_de1_text "create_preset" 1280 90 -text [translate "New Preset"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center" 
	add_de1_text "create_preset" 1280 650 -text [translate "What kind of preset?"] -font Helv_15_bold -width 1200 -fill "#444444" -anchor "center" -justify "center" 
	
	#add_de1_text "create_preset" 520 1090 -text [translate "Pressure"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

	add_de1_text "create_preset" 520 910 -text [translate "Pressure"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
	add_de1_text "create_preset" 1280 910 -text [translate "Flow"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
	add_de1_text "create_preset" 2060 910 -text [translate "Advanced"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

	add_de1_text "create_preset" 2060 1060 -text [translate "Your existing profile will be automatically copied.";] -font Helv_7 -width 300 -fill "#5a5d75" -anchor "center" -justify "center"

	add_de1_button "create_preset" {say [translate {PRESSURE}] $::settings(sound_button_in); set ::settings(settings_profile_type) "settings_2a"; set_next_page off $::settings(settings_profile_type); page_show off; set ::settings(profile_title) ""; update_de1_explanation_chart; set ::settings(active_settings_tab) $::settings(settings_profile_type) ; set_profile_title_untitled } 220 690 800 1190
	add_de1_button "create_preset" {say [translate {FLOW}] $::settings(sound_button_in); set ::settings(settings_profile_type) "settings_2b"; set_next_page off $::settings(settings_profile_type); page_show off; set ::settings(preinfusion_guarantee) 0; set ::settings(profile_title) ""; update_de1_explanation_chart; set ::settings(active_settings_tab) $::settings(settings_profile_type) ; set_profile_title_untitled } 980 690 1580 1190
	add_de1_button "create_preset" {say [translate {ADVANCED}] $::settings(sound_button_in); 
		if {$::settings(settings_profile_type) == "settings_2a"} { profile::advanced_list_to_settings [profile::pressure_to_advanced_list]; } elseif {$::settings(settings_profile_type) == "settings_2b"} {profile::advanced_list_to_settings [profile::flow_to_advanced_list]; }
		set ::settings(settings_profile_type) "settings_2c"; set_next_page off $::settings(settings_profile_type); page_show off; set ::settings(profile_title) ""; 
		set ::settings(final_desired_shot_volume_advanced) [ifexists ::settings(final_desired_shot_volume)]; 		
		set ::settings(final_desired_shot_weight_advanced) [ifexists ::settings(final_desired_shot_weight)]; 		; 
		set ::settings(final_desired_shot_volume_advanced_count_start) 2; 
		set ::settings(tank_desired_water_temperature) 0; 
		set ::settings(active_settings_tab) $::settings(settings_profile_type); 	
		fill_advanced_profile_steps_listbox; 
		update_de1_explanation_chart;
		profile_has_changed_set; 
		set_advsteps_scrollbar_dimensions; 
		set_profile_title_untitled} 1760 690 2350 1190

#############################

set settings_label1 [translate "PRESSURE"]
set settings_label2 [translate "Pressure profiles"]

#add_de1_text "settings_1" 50 220 -text $settings_label2 -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw" 
add_de1_variable "settings_1" 50 230 -text [translate "Load a preset"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw" -textvariable {[if {[ifexists ::profiles_hide_mode] == 1} { return [translate "Choose which presets to show"] } else { return [translate "Load a preset"] }]}
add_de1_text "settings_1" 1360 230 -text [translate "Preview"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw" 
add_de1_text "settings_1" 1360 830 -text [translate "Description"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw" 

# removed this "helpful video about profile" feature as a button, as being too loud.
# dui add dbutton "settings_1" 1140 1084 -tags [list xxx profile_video_help_button] -shape round -symbol_fill white -radius 32 -fill "#c0c5e2" -bwidth 126 -bheight 126 -symbol_pos {0.5 0.5} -symbol "photo-video"  -label_fill white -command {say [translate {video}] $::settings(sound_button_in); web_browser [ifexists ::settings(profile_video_help)]} 

add_de1_variable "settings_1" 1360 1240 -text "" -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"  -textvariable {[profile_has_changed_set_colors; return [translate "Name and save"]]}
	add_de1_variable "settings_1" 1360 900 -text "" -font Helv_6 -fill "#7f879a" -justify "left" -anchor "nw"  -width [rescale_y_skin 1150] -textvariable {[maxstring_with_crlf_count $::settings(profile_notes) 380 80 " \[[translate {Tap here for more}]\]" ]}
	add_de1_widget "settings_1" entry 1360 1310  {
			set ::globals(widget_profile_name_to_save) $widget
			bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; save_profile; hide_android_keyboard}
			bind $widget <Leave> hide_android_keyboard
		} -width [expr {int(38 * $::globals(entry_length_multiplier))}] -font Helv_8  -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -textvariable ::settings(profile_title) -relief flat  -highlightthickness 1 -highlightcolor #000000 


	add_de1_text "profile_notes" 1280 1310 -text [translate "Done"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"
	add_de1_button "settings_1" {say [translate {Notes}] $::settings(sound_button_in); page_to_show_when_off profile_notes}  1350 820 2530 1180

	add_de1_button "profile_notes" {say [translate {Done}] $::settings(sound_button_in); profile_has_changed_set; page_to_show_when_off settings_1;} 0 0 2560 1600 ""
	add_de1_text "profile_notes" 1280 300 -text [translate "Notes"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center" 
	set profile_notes_widget [add_de1_widget "profile_notes" multiline_entry 250 440 {} -canvas_height 730 -canvas_width 2070 -wrap word -font Helv_8 -borderwidth 0 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(profile_notes) -relief flat -highlightthickness 1 -highlightcolor #000000]




# labels for PREHEAT tab on

set settings_label1 [translate "PROFILE"]
set settings_label2 [translate "Profiles"]

set pos_preset_label 380
set pos_profile_label 1010
set pos_machine_label 1650
set pos_app_label 2270

# wraps the profile description based on the / character, which is the category
# and also moves the label of the profile type, up or down, based on how many lines of text the profile takes
proc wrapped_profile_title {} {

	set newheight [rescale_y_skin 80]
	set final [ifexists ::settings(profile_title)]

	set slashpos [string first / [ifexists ::settings(profile_title)]]
	if {$slashpos != -1} {
		# if there is a slash in this profile name, then add a CR after the slash
		# limit each line to 25 characters so it fits onscreen
		# and move the profile type up to make space
		set newheight [rescale_y_skin 50]
		set final [subst {[string range [string range [ifexists ::settings(profile_title)] 0 $slashpos] 0 25]\n[string range [string range [ifexists ::settings(profile_title)] $slashpos+1 end] 0 25]}]
	} else {
		set final [wrap_string [ifexists ::settings(profile_title)] 25]

		if {[string first \n $final] != -1} {
			set newheight [rescale_y_skin 50]
		}

	}

	.can coords $::tab1_profile_label [lindex [.can coords $::tab1_profile_label] 0] $newheight
	.can coords $::tab2_profile_label [lindex [.can coords $::tab2_profile_label] 0] $newheight
	.can coords $::tab3_profile_label [lindex [.can coords $::tab3_profile_label] 0] $newheight
	.can coords $::tab4_profile_label [lindex [.can coords $::tab4_profile_label] 0] $newheight

	return [string trim $final "\n/"]
}


########################################
# labels for tab1
add_de1_text "settings_1" $pos_preset_label 100 -text [translate "PRESETS"] -font $settings_tab_font -fill "#2d3046" -anchor "center" 
set ::tab1_profile_label [add_de1_variable "settings_1" $pos_profile_label 60 -text "" -font $settings_tab_font -fill "#7f879a" -anchor "center" -justify "center" -textvariable {[setting_profile_type_to_text]}]
add_de1_variable "settings_1" $pos_profile_label 130 -text "" -font Helv_7 -fill "#7f879a" -anchor "center" -justify "center" -textvariable {[wrapped_profile_title]}
add_de1_text "settings_1" $pos_machine_label 100 -text [translate "MACHINE"] -font $settings_tab_font -fill "#7f879a" -anchor "center" 
add_de1_text "settings_1" $pos_app_label 100 -text [translate "APP"] -font $settings_tab_font -fill "#7f879a" -anchor "center" 

########################################
# labels for tab2
add_de1_text "settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2" $pos_preset_label 100 -text [translate "PRESETS"] -font $settings_tab_font -fill "#7f879a" -anchor "center" 
set ::tab2_profile_label [add_de1_variable "settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2" $pos_profile_label 80 -text "" -font $settings_tab_font -fill "#2d3046"  -justify "center" -anchor "center" -textvariable {[setting_profile_type_to_text]}]
add_de1_variable "settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2" $pos_profile_label 130 -text "" -font Helv_7 -fill "#2d3046"  -justify "center" -anchor "center" -textvariable {[wrapped_profile_title]}
add_de1_text "settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2" $pos_machine_label 100 -text [translate "MACHINE"] -font $settings_tab_font -fill "#7f879a" -anchor "center" 
add_de1_text "settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2" $pos_app_label 100 -text [translate "APP"] -font $settings_tab_font -fill "#7f879a" -anchor "center" 

########################################
# top labels for tab3 
add_de1_text "settings_3" $pos_preset_label 100 -text [translate "PRESETS"] -font $settings_tab_font -fill "#7f879a" -anchor "center" 
set ::tab3_profile_label [add_de1_variable "settings_3" $pos_profile_label 80 -text "" -font $settings_tab_font -fill "#7f879a" -anchor "center"  -justify "center" -textvariable {[setting_profile_type_to_text]}]
add_de1_variable "settings_3" $pos_profile_label 130 -text "" -font Helv_7 -fill "#7f879a" -anchor "center" -justify "center" -textvariable {[wrapped_profile_title]}
add_de1_text "settings_3" $pos_machine_label 100 -text [translate "MACHINE"] -font $settings_tab_font -fill "#2d3046" -anchor "center" 
add_de1_text "settings_3" $pos_app_label 100 -text [translate "APP"] -font $settings_tab_font -fill "#7f879a" -anchor "center" 

# top labels for tab4
add_de1_text "settings_4" $pos_preset_label 100 -text [translate "PRESETS"] -font $settings_tab_font -fill "#7f879a" -anchor "center" 
set ::tab4_profile_label [add_de1_variable "settings_4" $pos_profile_label 80 -text "" -font $settings_tab_font -fill "#7f879a" -anchor "center"  -justify "center" -textvariable {[setting_profile_type_to_text]}]
add_de1_variable "settings_4" $pos_profile_label 130 -text "" -font Helv_7 -fill "#7f879a" -anchor "center" -justify "center" -textvariable {[wrapped_profile_title]}
add_de1_text "settings_4" $pos_machine_label 100 -text [translate "MACHINE"] -font $settings_tab_font -fill "#7f879a" -anchor "center" 
add_de1_text "settings_4" $pos_app_label 100 -text [translate "APP"] -font $settings_tab_font -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2 settings_3 settings_4" {after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off "settings_1"; page_show off; set ::settings(active_settings_tab) "settings_1"; set_profiles_scrollbar_dimensions} 0 0 641 188
add_de1_button "settings_1 settings_3 settings_4" {after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off $::settings(settings_profile_type); page_show off; set ::settings(active_settings_tab) $::settings(settings_profile_type); fill_advanced_profile_steps_listbox; set_advsteps_scrollbar_dimensions} 642 0 1277 188 
add_de1_button "settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2" {say [translate {save}] $::settings(sound_button_in); if {$::settings(profile_has_changed) == 1} { borg toast [translate "Saved"]; save_profile } } 642 0 1277 188 
add_de1_button "settings_1 settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_3; page_show settings_3; scheduler_feature_hide_show_refresh; set ::settings(active_settings_tab) "settings_3"} 1278 0 1904 188
add_de1_button "settings_1 settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2 settings_3" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_4; page_show settings_4; set ::settings(active_settings_tab) "settings_4"; set_ble_scrollbar_dimensions; set_ble_scale_scrollbar_dimensions} 1905 0 2560 188

#wrapped_profile_title

add_de1_text "settings_1 settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2 settings_3 settings_4" 2275 1520 -text [translate "Ok"] -font $botton_button_font -fill "#FFFFFF" -anchor "center"
add_de1_text "settings_1 settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2 settings_3 settings_4" 1760 1520 -text [translate "Cancel"] -font $botton_button_font -fill "#FFFFFF" -anchor "center"
	add_de1_button "settings_1 settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2 settings_3 settings_4" {save_settings_to_de1; set_alarms_for_de1_wake_sleep; say [translate {save}] $::settings(sound_button_in); save_settings; profile_has_changed_set_colors;
			if {[ifexists ::profiles_hide_mode] == 1} {
				unset -nocomplain ::profiles_hide_mode 
				fill_profiles_listbox
			}
			if {[ifexists ::settings_backup(calibration_flow_multiplier)] != [ifexists ::settings(calibration_flow_multiplier)]} {				
				set_calibration_flow_multiplier $::settings(calibration_flow_multiplier)
			}
			if {[ifexists ::settings_backup(fan_threshold)] != [ifexists ::settings(fan_threshold)]} {				
				set_fan_temperature_threshold $::settings(fan_threshold)
			}
			if {[ifexists ::settings_backup(water_refill_point)] != [ifexists ::settings(water_refill_point)]} {				
				de1_send_waterlevel_settings
			}
			if {[array_item_difference ::settings ::settings_backup "steam_temperature steam_flow"] == 1} {
				# resend the calibration settings if they were changed
				de1_send_steam_hotwater_settings
				de1_enable_water_level_notifications
			}
			if {[array_item_difference ::settings ::settings_backup "enable_fahrenheit orientation screen_size_width saver_brightness use_finger_down_for_tap log_enabled hot_water_idle_temp espresso_warmup_timeout language skin waterlevel_indicator_on default_font_calibration waterlevel_indicator_blink display_rate_espresso display_espresso_water_delta_number display_group_head_delta_number display_pressure_delta_line display_flow_delta_line display_weight_delta_line allow_unheated_water display_time_in_screen_saver enabled_plugins plugin_tabs"] == 1  || [ifexists ::app_has_updated] == 1} {
				# changes that effect the skin require an app restart
				.can itemconfigure $::message_label -text [translate "Please quit and restart this app to apply your changes."]
				.can itemconfigure $::message_button_label -text [translate "Wait"]

				set_next_page off message; page_show message
				after 200 app_exit

			} elseif {[ifexists ::settings_backup(scale_bluetooth_address)] == "" && [ifexists ::settings(scale_bluetooth_address)] != ""} {
				# if no scale was previously defined, and there is one now, then force an app restart
				# but if there was a scale previously, and now there is a new one, let that be w/o an app restart

				# changes that effect the skin require an app restart
				.can itemconfigure $::message_label -text [translate "Please quit and restart this app to apply your changes."]
				.can itemconfigure $::message_button_label -text [translate "Wait"]

				set_next_page off message; page_show message
				after 200 app_exit

			} else {

				if {[ifexists ::settings(settings_profile_type)] == "settings_2c2"} {
					# if they were on the LIMITS tab of the Advanced profiles, reset the ui back to the main tab
					set ::settings(settings_profile_type) "settings_2c"
				}

				set_next_page off off; page_show off
			}
		} 2016 1430 2560 1600

	# cancel button
	add_de1_button "settings_1 settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2 settings_3 settings_4" {if {[ifexists ::profiles_hide_mode] == 1} { unset -nocomplain ::profiles_hide_mode; fill_profiles_listbox }; array unset ::settings {\*}; array set ::settings [array get ::settings_backup]; update_de1_explanation_chart; fill_skin_listbox; profile_has_changed_set_colors; say [translate {Cancel}] $::settings(sound_button_in); set_next_page off off; page_show off; fill_advanced_profile_steps_listbox;restore_espresso_chart; save_settings_to_de1; fill_profiles_listbox ; fill_extensions_listbox} 1505 1430 2015 1600

set enable_flow_calibration 1
if {[ifexists ::settings(firmware_version_number)] >= 1238} {
	set enable_flow_calibration 1
}

set calibration_labels_row 350
set calibration_row_spacing 120


# (re)calibration page
add_de1_text "calibrate calibrate2 calibrate3" 1280 290 -text [translate "Calibrate"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center" 

	#add_de1_text "calibrate" 2520 1510 -text [subst {\[ [translate "Page 1 of 3"] \]}] -font Helv_10_bold -fill "#666666" -anchor "ne"
	#add_de1_text "calibrate2" 2520 1510 -text [subst {\[ [translate "Page 2 of 3"] \]}] -font Helv_10_bold -fill "#666666" -anchor "ne"
	#add_de1_text "calibrate3" 2520 1510 -text [subst {\[ [translate "Page 3 of 3"] \]}] -font Helv_10_bold -fill "#666666" -anchor "ne"

	dui add dbutton "calibrate" 2050 1460 -style insight_ok -anchor nw -command show_page_calibrate_2 -label [subst {[translate "Page 1 of 3"] >}]
	dui add dbutton "calibrate2" 2050 1460 -style insight_ok -anchor nw -command show_page_calibrate_3 -label [subst {[translate "Page 2 of 3"] >}]
	dui add dbutton "calibrate3" 2050 1460 -style insight_ok -anchor nw -command show_page_calibrate -label [subst {[translate "Page 3 of 3"] >}]

proc show_page_calibrate {} {
	say [translate {Done}] $::settings(sound_button_in)
	set_heater_tweaks; 
	page_to_show_when_off calibrate
}	

proc show_page_calibrate_2 {} {
	say [translate {Done}] $::settings(sound_button_in)
	get_heater_voltage; 
	page_to_show_when_off calibrate2
}	

proc show_page_calibrate_3 {} {
	say [translate {Done}] $::settings(sound_button_in)
	page_to_show_when_off calibrate3
}	

		#add_de1_button "calibrate" {show_page_calibrate_2} 2200 1400 2560 1600 ""		
		#add_de1_button "calibrate2" {say [translate {Done}] $::settings(sound_button_in); page_to_show_when_off calibrate3;} 2200 1400 2560 1600 ""
		#add_de1_button "calibrate3" {say [translate {Done}] $::settings(sound_button_in); set_heater_tweaks; page_to_show_when_off calibrate;} 2200 1400 2560 1600 ""

		###############################################################################################
		# Nominal heater voltage. (Address 803834)
		#  On 1.1 or 1.3 machines, it's assumed to be in the same range as the measured voltage.
		#  On 1.0 machines, we can't measure voltage, so:
		#    Return 0 for unknown
		#    Return 1120 or 1230 if we've been set to 120 or 230
		#
		#  Summary for reads:
		#      0 : We don't know nominal heater voltage
		#    120 : We think we have 120V heaters
		#    230 : We think we have 230V heaters
		#   1120 : We've been told we have 120V heaters
		#   1230 : We've been told we have 230V heaters
		#
		#   Summary for writes:
		#     IF you read 0, 1120, or 1230, you can write a new nominal voltage, which may be 120 or 230V

		add_de1_text "calibrate2" 350 450  -text [translate "Voltage"] -font Helv_11_bold -fill "#7f879a" -anchor "nw" -justify "left" 
		add_de1_variable "calibrate2" 1000 450  -text "" -font Helv_11_bold -fill "#4e85f4" -anchor "nw" -textvariable {[if {$::settings(heater_voltage) != "1120" || $::settings(heater_voltage) == "0" || $::settings(heater_voltage) == "" } { return [subst {\[ [translate "Set to 120V"] \]}] } else { return "" }]}
		add_de1_variable "calibrate2" 1600 450  -text "" -font Helv_11_bold -fill "#4e85f4" -anchor "nw" -textvariable {[if {$::settings(heater_voltage) != "1230" || $::settings(heater_voltage) == "0" || $::settings(heater_voltage) == "" } { return [subst {\[ [translate "Set to 230V"] \]}] } else { return "" }]}
		
		add_de1_button "calibrate2" {if {$::settings(heater_voltage) != "1120" || $::settings(heater_voltage) == "0" || $::settings(heater_voltage) == "" } { if {$::android == 0} { set ::settings(heater_voltage) "1120" }; set_heater_voltage "120"; get_heater_voltage} } 1000 450 1450 600 ""
		add_de1_button "calibrate2" {if {$::settings(heater_voltage) != "1230" || $::settings(heater_voltage) == "0" || $::settings(heater_voltage) == "" } { if {$::android == 0} { set ::settings(heater_voltage) "1230" }; set_heater_voltage "230"; get_heater_voltage} } 1600 450 2050 600 ""

		add_de1_variable "calibrate2" 700 450  -text [translate "Voltage"] -font Helv_11 -fill "#7f879a" -anchor "nw" -justify "left"  -textvariable {[if {$::settings(heater_voltage) == "120" || $::settings(heater_voltage) == "1120"} {
				return "120V"
			} elseif {$::settings(heater_voltage) == "230" || $::settings(heater_voltage) == "1230" } {
				return "230V"
			} elseif {$::settings(heater_voltage) > "50" && $::settings(heater_voltage) < "300"} {
				return "$::settings(heater_voltage)V"
			} else {
				return [translate "unknown"]
			}]
		}
		###############################################################################################

		add_de1_text "calibrate2" 350 600  -text [translate "Heater idle temperature"] -font Helv_9_bold -fill "#7f879a" -anchor "nw" -justify "left" 
		add_de1_widget "calibrate2" scale 350 660  {} -to 990 -from 0 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 5 -resolution 5 -length [rescale_x_skin 600]  -width [rescale_y_skin 90] -variable ::settings(hot_water_idle_temp) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
		add_de1_variable "calibrate2" 970 680  -text "" -font Helv_8 -fill "#7f879a" -anchor "nw" -textvariable {[return_temperature_setting [expr {0.1 * $::settings(hot_water_idle_temp)}]]}

		add_de1_text "calibrate2" 1350 600  -text [translate "Heater test time-out"] -font Helv_9_bold -fill "#7f879a" -anchor "nw" -justify "left" 
		add_de1_widget "calibrate2" scale 1350 660  {} -to 300 -from 10 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 600]  -width [rescale_y_skin 90] -variable ::settings(espresso_warmup_timeout) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
		add_de1_variable "calibrate2" 1970 680  -text "" -font Helv_8 -fill "#7f879a" -anchor "nw" -textvariable {[return_seconds_divided_by_ten $::settings(espresso_warmup_timeout)]}

		add_de1_text "calibrate2" 350 800  -text [translate "Heater warmup flow rate"] -font Helv_9_bold -fill "#7f879a" -anchor "nw" -justify "left" 
		add_de1_widget "calibrate2" scale 350 860  {} -to 60 -from 5 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 600]  -width [rescale_y_skin 90] -variable ::settings(phase_1_flow_rate) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
		add_de1_variable "calibrate2" 970 880  -text "" -font Helv_8 -fill "#7f879a" -anchor "nw" -textvariable {[return_flow_calibration_measurement $::settings(phase_1_flow_rate)]}

		add_de1_text "calibrate2" 1350 800  -text [translate "Heater test flow rate"] -font Helv_9_bold -fill "#7f879a" -anchor "nw" -justify "left" 
		add_de1_widget "calibrate2" scale 1350 860  {} -to 80 -from 5 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 600]  -width [rescale_y_skin 90] -variable ::settings(phase_2_flow_rate) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
		add_de1_variable "calibrate2" 1970 880  -text "" -font Helv_8 -fill "#7f879a" -anchor "nw" -textvariable {[return_flow_calibration_measurement $::settings(phase_2_flow_rate)]}

		#add_de1_text "calibrate2" 350 1000  -text [translate "Presets:"] -font Helv_9_bold -fill "#7f879a" -anchor "nw" -justify "left" 
		add_de1_text "calibrate2" 350 1000  -text "\[ [translate "Defaults for home"] \]" -font Helv_8_bold -fill "#4e85f4" -anchor "nw" -justify "left" 
		add_de1_text "calibrate2" 350 1080 -text "\[ [translate "Defaults for cafe"] \]" -font Helv_8_bold -fill "#4e85f4" -anchor "nw" -justify "left" 
		add_de1_button "calibrate2" {set ::settings(hot_water_idle_temp) 850; set ::settings(espresso_warmup_timeout) 100; set ::settings(phase_1_flow_rate) 10; set ::settings(phase_2_flow_rate) 40; } 300 980 840 1060 ""		
		add_de1_button "calibrate2" {set ::settings(hot_water_idle_temp) 990; set ::settings(espresso_warmup_timeout) 10; set ::settings(phase_1_flow_rate) 20; set ::settings(phase_2_flow_rate) 40; } 300 1070 840 1150 ""		
		
		#add_de1_widget "calibrate3" checkbutton 1350 860 {} -text [translate "Two tap steam stop"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(steam_two_tap_stop)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF  -bd 0 -activeforeground #4e85f4 -relief flat -bd 0 
		#add_de1_widget "calibrate3" checkbutton 1350 960 {} -text [translate "Slow start"] -indicatoron true  -font $optionfont -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(insert_preinfusion_pause)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF  -bd 0 -activeforeground #4e85f4 -relief flat -bd 0 

		dui add dtoggle "calibrate3" 1350 560 -height 60 -anchor nw -variable ::settings(steam_two_tap_stop) 
		add_de1_text "calibrate3" 1500 560 -text [translate "Two tap steam stop"] -font $optionfont -width 1200 -fill "#4e85f4" -anchor "nw" 
		add_de1_button "calibrate3" { set ::settings(steam_two_tap_stop) [expr {!$::settings(steam_two_tap_stop)}] } 1350 560 1950 620

		dui add dtoggle "calibrate3" 1350 660 -height 60 -anchor nw -variable ::settings(insert_preinfusion_pause) 
		add_de1_text "calibrate3" 1500 660 -text [translate "Slow start"] -font $optionfont -width 1200 -fill "#4e85f4" -anchor "nw" 
		add_de1_button "calibrate3" { set ::settings(insert_preinfusion_pause) [expr {!$::settings(insert_preinfusion_pause)}] } 1350 660 1950 720

		add_de1_variable "calibrate3" 1350 756  -text [translate "Refill kit: detected"] -font Helv_9_bold -fill "#7f879a" -anchor "nw" -justify "left" -textvariable {[if {$::de1(refill_kit_detected) == ""} {return [translate "Refill kit: unable to detect"]} elseif {$::de1(refill_kit_detected) == "0"} {	return [translate "Refill kit: not detected"]} elseif {$::de1(refill_kit_detected) == "1"} { return [translate "Refill kit: detected"] } ]}
		dui add dselector "calibrate3" 1350 820 -bwidth 900 -bheight 80 -orient h -anchor nw -values {-1 0 1} -variable ::settings(refill_kit_override) -default {-1} -labels [list [translate "auto-detect"] [translate "force off"] [translate "force on"]] -width 3 -fill "#f8f8f8" -selectedfill "#4d85f4" -command send_refill_kit_override_from_gui

proc send_refill_kit_override_from_gui {args} {
	send_refill_kit_override
}
		add_de1_text "calibrate3" 350 500  -text [translate "Hot water flow rate"] -font Helv_9_bold -fill "#7f879a" -anchor "nw" -justify "left" 
		add_de1_widget "calibrate3" scale 350 560  {} -to 10 -from 1 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution .1 -length [rescale_x_skin 600]  -width [rescale_y_skin 90] -variable ::settings(hotwater_flow) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
		add_de1_variable "calibrate3" 970 580  -text "" -font Helv_8 -fill "#7f879a" -anchor "nw" -textvariable {[return_flow_measurement $::settings(hotwater_flow)]}

		add_de1_text "calibrate3" 350 700  -text [translate "Flush flow rate"] -font Helv_9_bold -fill "#7f879a" -anchor "nw" -justify "left" 
		add_de1_widget "calibrate3" scale 350 760  {} -to 10 -from 1 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution .1 -length [rescale_x_skin 600]  -width [rescale_y_skin 90] -variable ::settings(flush_flow) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
		add_de1_variable "calibrate3" 970 780  -text "" -font Helv_8 -fill "#7f879a" -anchor "nw" -textvariable {[return_flow_measurement $::settings(flush_flow)]}

		add_de1_text "calibrate3" 350 900  -text [translate "Flush timeout"] -font Helv_9_bold -fill "#7f879a" -anchor "nw" -justify "left" 
		add_de1_widget "calibrate3" scale 350 960  {} -to 120 -from 3 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution .1 -length [rescale_x_skin 600]  -width [rescale_y_skin 90] -variable ::settings(flush_seconds) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
		add_de1_variable "calibrate3" 970 980  -text "" -font Helv_8 -fill "#7f879a" -anchor "nw" -textvariable {[seconds_text $::settings(flush_seconds)]}



	add_de1_text "calibrate calibrate2 calibrate3" 1280 1310 -text [translate "Done"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"
		add_de1_button "calibrate calibrate2 calibrate3" {say [translate {Done}] $::settings(sound_button_in); 
		if {[ifexists ::calibration_disabled_fahrenheit] == 1} {
			set ::settings(enable_fahrenheit) 1
			unset -nocomplain ::calibration_disabled_fahrenheit
			msg "Calibration re-enabled Fahrenheit"
		}

		save_settings; set_next_page off settings_3; 
		set_heater_tweaks;
		page_show settings_3;} 980 1210 1580 1410 ""
		

	add_de1_text "calibrate" 500 $calibration_labels_row -text [translate "Saved"] -font Helv_8_bold -fill "#c0c4e1" -anchor "ne" 
		add_de1_variable "calibrate" 500 [expr {(1 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_plus_or_minus_number $::de1(calibration_temperature)]}
		add_de1_variable "calibrate" 500 [expr {(2 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_plus_or_minus_number $::de1(calibration_pressure)]}
		if {$enable_flow_calibration == 1} {
			#add_de1_variable "calibrate" 500 [expr {(3 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_plus_or_minus_number $::de1(calibration_flow)]}
		}
		add_de1_variable "calibrate" 500 [expr {(4 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_steam_heater_calibration $::settings(steam_temperature)]}
		add_de1_variable "calibrate" 500 [expr {(5 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_steam_flow_calibration $::settings(steam_flow)]}

	add_de1_text "calibrate" 760 $calibration_labels_row -text [translate "Factory"] -font Helv_8_bold -fill "#c0c4e1" -anchor "ne" 
		add_de1_variable "calibrate" 760 [expr {(1 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_plus_or_minus_number $::de1(factory_calibration_temperature)]}
		add_de1_variable "calibrate" 760 [expr {(2 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_plus_or_minus_number $::de1(factory_calibration_pressure)]}
		if {$enable_flow_calibration == 1} {
			#add_de1_variable "calibrate" 760 [expr {(3 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_plus_or_minus_number $::de1(factory_calibration_flow)]}
		}
		add_de1_variable "calibrate" 760 [expr {(4 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_steam_heater_calibration $::settings(steam_temperature)]}
		add_de1_variable "calibrate" 760 [expr {(5 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_steam_flow_calibration $::settings(steam_flow)]}


	add_de1_text "calibrate" 850 $calibration_labels_row -text [translate "Sensor"] -font Helv_8_bold -fill "#c0c4e1" -anchor "nw" 
		add_de1_text "calibrate" 850 [expr {(1 * $calibration_row_spacing) + $calibration_labels_row}]  -text [translate "Temperature"] -font Helv_11_bold -fill "#7f879a" -anchor "nw"
		add_de1_text "calibrate" 850 [expr {(2 * $calibration_row_spacing) + $calibration_labels_row}]  -text [translate "Pressure"] -font Helv_11_bold -fill "#7f879a" -anchor "nw" 
		if {$enable_flow_calibration == 1} {
			add_de1_text "calibrate" 850 [expr {(3 * $calibration_row_spacing) + $calibration_labels_row}]  -text [translate "Flow"] -font Helv_11_bold -fill "#7f879a" -anchor "nw" 
		}
		add_de1_text "calibrate" 850 [expr {(4 * $calibration_row_spacing) + $calibration_labels_row}]  -text [translate "Steam temperature"] -font Helv_11_bold -fill "#7f879a" -anchor "nw" 
		add_de1_text "calibrate" 850 [expr {(5 * $calibration_row_spacing) + $calibration_labels_row}]  -text [translate "Steam flow rate"] -font Helv_11_bold -fill "#7f879a" -anchor "nw" 
		add_de1_text "calibrate2" 1350 1000 -text [translate "Stop at weight offset"] -font Helv_9_bold -fill "#7f879a" -anchor "nw"
		add_de1_text "calibrate" 850 [expr {(6 * $calibration_row_spacing) + $calibration_labels_row}]  -text [translate "Fan turns on at:"] -font Helv_11_bold -fill "#7f879a" -anchor "nw" 


	# tap on factory number in order to reset to factory values
	#add_de1_button "calibrate" {say [translate {reset}] $::settings(sound_button_in); de1_send_calibration "temperature" 0 0 3; de1_read_calibration "temperature"} 600 500 800 600
	#add_de1_button "calibrate" {say [translate {reset}] $::settings(sound_button_in); de1_send_calibration "pressure" 0 0 3; de1_read_calibration "pressure"} 600 650 800 750
	#add_de1_button "calibrate" {say [translate {reset}] $::settings(sound_button_in); de1_send_calibration "flow" 0 0 3; de1_read_calibration "flow"} 600 800 800 900

	# goal values
	add_de1_text "calibrate" 1750 $calibration_labels_row -text [translate "Goal"] -font Helv_8_bold -fill "#c0c4e1" -anchor "ne" 
		add_de1_variable "calibrate" 1750 [expr {(1 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_temperature_setting $::settings(espresso_temperature)]}
		add_de1_variable "calibrate" 1750 [expr {(2 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_pressure_measurement $::settings(espresso_pressure)]}
		if {$enable_flow_calibration == 1} {
			# add_de1_variable "calibrate" 1750 [expr {(3 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_flow_measurement $::settings(flow_profile_hold)]}
			add_de1_variable "calibrate" 1750 [expr {(3 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {x $::settings(calibration_flow_multiplier)}
		}

		#add_de1_variable "calibrate" 1750 750 -text "" -font Helv_15 -fill "#7f879a" -anchor "ne" -textvariable {[return_temperature_measurement $::settings(steam_temperature)]}
		add_de1_variable "calibrate" 1750 [expr {(4 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_steam_heater_calibration $::settings(steam_temperature)]}
		set ::steam_flow_rate_calibration_label [add_de1_variable "calibrate" 1750 [expr {(5 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_steam_flow_calibration $::settings(steam_flow)]}]


	# entry fields
	add_de1_text "calibrate" 1880 $calibration_labels_row -text [translate "Measured"] -font Helv_8_bold -fill "#c0c4e1" -anchor "nw" 
		add_de1_widget "calibrate" entry 1880 [expr {(1 * $calibration_row_spacing) + $calibration_labels_row - [rescale_y_skin 32]}]   {
			set ::settings(espresso_temperature) [round_to_half_integer $::settings(espresso_temperature)]

			set ::globals(widget_calibrate_temperature) $widget
			bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); $::globals(widget_calibrate_temperature) configure -state disabled; de1_send_calibration "temperature" $::settings(espresso_temperature) $::globals(calibration_espresso_temperature); de1_read_calibration "temperature"; hide_android_keyboard }
			bind $widget <Leave> hide_android_keyboard

		} -width [expr {int(10 * $::globals(entry_length_multiplier))}] -state normal -font Helv_15_bold -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -textvariable ::globals(calibration_espresso_temperature) -relief flat  -highlightthickness 1 -highlightcolor #000000 

		add_de1_widget "calibrate" entry 1880 [expr {(2 * $calibration_row_spacing) + $calibration_labels_row - [rescale_y_skin 32]}]   {
			set ::globals(widget_calibrate_pressure) $widget
			bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); $::globals(widget_calibrate_pressure) configure -state disabled; de1_send_calibration "pressure" $::settings(espresso_pressure) $::globals(calibration_espresso_pressure); de1_read_calibration "pressure"; hide_android_keyboard }
			bind $widget <Leave> hide_android_keyboard

		} -width [expr {int(10 * $::globals(entry_length_multiplier))}] -state normal -font Helv_15_bold -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -textvariable ::globals(calibration_espresso_pressure) -relief flat  -highlightthickness 1 -highlightcolor #000000 

		if {$enable_flow_calibration == 1} {

			# add_de1_widget "calibrate" entry 1880 [expr {(3 * $calibration_row_spacing) + $calibration_labels_row - [rescale_y_skin 32]}]   {
			# 	set ::globals(widget_calibrate_flow) $widget
			# 	bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); $::globals(widget_calibrate_flow) configure -state disabled; de1_send_calibration "flow" $::settings(flow_profile_hold) $::globals(calibration_espresso_flow); de1_read_calibration "flow"; hide_android_keyboard }
			# 	bind $widget <Leave> hide_android_keyboard
			# } -width 10 -state normal -font Helv_15_bold -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -textvariable ::globals(calibration_espresso_flow) -relief flat  -highlightthickness 1 -highlightcolor #000000 

			add_de1_widget "calibrate" scale 1880 [expr {(3 * $calibration_row_spacing) + $calibration_labels_row - [rescale_y_skin 16]}]  {} -to 2 -from 0.13 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement .1 -resolution .01 -length [rescale_x_skin 400]  -width [rescale_y_skin 90] -variable ::settings(calibration_flow_multiplier) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 			
		}		
		
		#add_de1_widget "calibrate" scale 1880 875 {} -to 100 -from 60 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 400]  -width [rescale_y_skin 100] -variable ::settings(shot_weight_percentage_stop) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 

		add_de1_widget "calibrate" scale 1880 [expr {(4 * $calibration_row_spacing) + $calibration_labels_row - [rescale_y_skin 16]}]  {} -to 170 -from 129 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 400]  -width [rescale_y_skin 90] -variable ::settings(steam_temperature) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
		
		set max_steam_flow_rate 250
		if {[ifexists ::settings(machine_model)] >= 5} {
			# the de1xxl and de1xxxl models have a higher maximum flow rate for steam because of higher powered heaters
			set max_steam_flow_rate 400
		}

		add_de1_widget "calibrate" scale 1880 [expr {(5 * $calibration_row_spacing) + $calibration_labels_row - [rescale_y_skin 16]}]  { set ::steam_flow_calibration_widget $widget } -to $max_steam_flow_rate -from 40 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 10 -resolution 10 -length [rescale_x_skin 400]  -width [rescale_y_skin 90] -variable ::settings(steam_flow) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 

		add_de1_variable "calibrate" 1550 [expr {(5 * $calibration_row_spacing) + $calibration_labels_row - [rescale_y_skin 24]}]  -width [rescale_y_skin 750]  -text "" -font Helv_6 -fill "#7f879a" -anchor "nw" -textvariable {[if {[ifexists ::settings(skin)] == "Insight" || [ifexists ::settings(skin)] == "Insight Dark" || [ifexists ::settings(skin)] == "Metric" || [ifexists ::settings(skin)] == "MiniMetric"} {
				.can itemconfigure $::steam_flow_calibration_widget -state hidden
				.can itemconfigure $::steam_flow_rate_calibration_label -state hidden

				#.can itemconfigure $::steam_flow_calibration_note -state normal
				return [translate {With the skin you are using, the steam flow rate is set in real time while steaming.  It is not set on this page.}]
			} else {
				.can itemconfigure $::steam_flow_calibration_widget -state normal
				.can itemconfigure $::steam_flow_rate_calibration_label -state normal
				#.can itemconfigure $::steam_flow_calibration_note -state hidden
				return ""
			}]}

		add_de1_widget "calibrate2" scale 1350 1060  {} -to 1.5 -from -1.0 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement .1 -resolution .01 -length [rescale_x_skin 600]  -width [rescale_y_skin 90] -variable ::settings(stop_weight_before_seconds) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal
		add_de1_variable "calibrate2" 1970 1080  -text "" -font Helv_8 -fill "#7f879a" -anchor "nw" -textvariable {[format "%.2f %s" $::settings(stop_weight_before_seconds) [translate {seconds}]]}

#add_de1_widget "calibrate2" scale 1350 860  {} -to 80 -from 5 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 600]  -width [rescale_y_skin 90] -variable ::settings(phase_2_flow_rate) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
#add_de1_variable "calibrate2" 1970 880  -text "" -font Helv_8 -fill "#7f879a" -anchor "nw" -textvariable {[return_flow_calibration_measurement $::settings(phase_2_flow_rate)]}


		add_de1_widget "calibrate" scale 1880 [expr {(6 * $calibration_row_spacing) + $calibration_labels_row - [rescale_y_skin 16]}]  {} -to 60 -from 0 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 400]  -width [rescale_y_skin 90] -variable ::settings(fan_threshold) -font Helv_15_bold -sliderlength [rescale_x_skin 100] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color -borderwidth 0  -highlightthickness 0 -orient horizontal 
		add_de1_variable "calibrate" 1750 [expr {(6 * $calibration_row_spacing) + $calibration_labels_row}]  -text "" -font Helv_10 -fill "#7f879a" -anchor "ne" -textvariable {[return_fan_threshold_calibration $::settings(fan_threshold)]}

		

# END OF SETTINGS page
##############################################################################################################################################################################################################################################################################

set ::settings(active_settings_tab) $::settings(settings_profile_type)

proc setting_profile_type_to_text { } {

	# if the current profile has changed, display a * to the right of its name
	# tapping on that tab, while editing it, will auto-save that profile to the samena,e
	if {$::settings(profile_has_changed) == 1} {
		set changedicon "*"
	} else {
		set changedicon ""
	}

	set in $::settings(settings_profile_type)
	if {$in == "settings_2a"} {
		if {$::de1(current_context) == "settings_1"} {
			.can itemconfigure $::preview_graph_flow -state hidden
			.can itemconfigure $::preview_graph_pressure -state normal
			.can itemconfigure $::preview_graph_advanced -state hidden
		}
		#return [translate "Pressure profile"]
		return [translate "PRESSURE"]$changedicon
	} elseif {$in == "settings_2b"} {
		if {$::de1(current_context) == "settings_1"} {
			.can itemconfigure $::preview_graph_pressure -state hidden
			.can itemconfigure $::preview_graph_flow -state normal
			.can itemconfigure $::preview_graph_advanced -state hidden
		}
		#return [translate "Flow profile"]
		return [translate "FLOW"]$changedicon
	} elseif {$in == "settings_2c" || $in == "settings_2c2"} {
		if {$::de1(current_context) == "settings_1"} {
			.can itemconfigure $::preview_graph_pressure -state hidden
			.can itemconfigure $::preview_graph_flow -state hidden
			.can itemconfigure $::preview_graph_advanced -state normal
		}
		return [translate "ADVANCED"]$changedicon
		#return [translate "Advanced profile"]
	} else {
		return [translate "PROFILE"]$changedicon
	}
}

#after 2 show_settings calibrate


# enable for debugging
proc flush_log_loop {} {
	::logging::flush_log
	#::flush $::logging::_log_fh
	after 100 flush_log_loop

}

#after 100 flush_log_loop
