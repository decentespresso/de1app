##############################################################################################################################################################################################################################################################################
# GENERIC DE1 SETTINGS page



##############################################################################################################################################################################################################################################################################
# the graphics for each of the main espresso machine modes

if {[de1plus]} {
	add_de1_page "settings_profile_pressure settings_1" "[defaultskin_directory_graphics]/settings_1p.jpg"
	add_de1_page "settings_profile_flow" "[defaultskin_directory_graphics]/settings_1pa.jpg"
	add_de1_page "settings_profile_advanced" "[defaultskin_directory_graphics]/settings_1pb.jpg"
	if {$::settings(settings_profile_type) == "settings_1"} {
		# this happens if you switch to the de1 gui, which then saves the de1 settings default, so we need to reset it to this de1+ default
		set ::settings(settings_profile_type) "settings_profile_pressure"
	}
	#set ::settings(settings_profile_type) "settings_profile_pressure"
} else {
	set ::settings(settings_profile_type) "settings_1"
	add_de1_page "settings_1" "[defaultskin_directory_graphics]/settings_1.jpg"
	add_de1_page "settings_1a" "[defaultskin_directory_graphics]/settings_1a.jpg"
}

add_de1_page "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" "[defaultskin_directory_graphics]/settings_2.jpg"
add_de1_page "settings_3" "[defaultskin_directory_graphics]/settings_3.jpg"
add_de1_page "settings_4" "[defaultskin_directory_graphics]/settings_4.jpg"

# this is the message page
set ::message_label [add_de1_text "message" 1280 750 -text "" -font Helv_15_bold -fill "#2d3046" -justify "center" -anchor "center" -width 900]
set ::message_button_label [add_de1_text "message" 1280 1090 -text [translate "Quit"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"]
set ::message_button [add_de1_button "message" {say [translate {Quit}] $::settings(sound_button_in);exit} 980 990 1580 1190 ""]

##############################################################################################################################################################################################################################################################################

############################
# pressure controlled shots
add_de1_text "settings_1 settings_profile_pressure" 45 755 -text [translate "1: preinfuse"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
if {[de1plus]} {
	add_de1_widget "settings_1 settings_profile_pressure" scale 47 850 {} -to 0.1 -from 5 -tickinterval 0  -showvalue 0 -background #e4d1c1  -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 470] -width [rescale_y_skin 150] -variable ::settings(preinfusion_flow_rate) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #000000 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
	add_de1_variable "settings_1 settings_profile_pressure" 47 1335 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[return_flow_measurement $::settings(preinfusion_flow_rate)]}
	add_de1_widget "settings_1 settings_profile_pressure" scale 220 850 {} -from 0 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 330] -width [rescale_y_skin 150] -variable ::settings(preinfusion_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
	add_de1_variable "settings_1 settings_profile_pressure" 220 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(preinfusion_time) [translate "seconds"]}
} else {
	add_de1_widget "settings_1 settings_profile_pressure" scale 47 850 {} -from 0 -to 10 -tickinterval 0  -showvalue 0 -background #e4d1c1  -bigincrement 1 -resolution 1 -length [rescale_x_skin 500] -width [rescale_y_skin 150] -variable ::settings(preinfusion_time) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command {update_de1_explanation_chart_soon} -foreground #000000 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 -orient horizontal 
	add_de1_variable "settings_1 settings_profile_pressure" 50 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(preinfusion_time) [translate "seconds"]}
}
#add_de1_widget "settings_1 settings_profile_pressure" scale 47 850 {} -from 0 -to 10 -tickinterval 0  -showvalue 0 -background #e4d1c1  -bigincrement 1 -resolution 1 -length [rescale_x_skin 500] -width [rescale_y_skin 150] -variable ::settings(preinfusion_time) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command {update_de1_explanation_chart_soon} -foreground #000000 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 -orient horizontal 
#add_de1_variable "settings_1 settings_profile_pressure" 50 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(preinfusion_time) [translate "seconds"]}


add_de1_text "settings_1 settings_profile_pressure" 615 755 -text [translate "2: hold"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
add_de1_widget "settings_1 settings_profile_pressure" scale 610 850 {} -to 1 -from 10 -tickinterval 0  -showvalue 0 -background #e4d1c1  -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 470] -width [rescale_y_skin 150] -variable ::settings(espresso_pressure) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #000000 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_1 settings_profile_pressure" 610 1335 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[commify $::settings(espresso_pressure)] [translate "bar"]}
add_de1_widget "settings_1 settings_profile_pressure" scale 790 850 {} -from 0 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 740] -width [rescale_y_skin 150] -variable ::settings(pressure_hold_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_1 settings_profile_pressure" 790 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(pressure_hold_time) [translate "seconds"]}

add_de1_text "settings_1 settings_profile_pressure" 1605 755 -text [translate "3: decline"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
add_de1_widget "settings_1 settings_profile_pressure" scale 1600 850 {} -from 0 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0 -bigincrement 1 -resolution 1 -length [rescale_x_skin 735] -width [rescale_y_skin 150] -variable ::settings(espresso_decline_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_1 settings_profile_pressure" 1605 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(espresso_decline_time) [translate "seconds"]}
add_de1_widget "settings_1 settings_profile_pressure" scale 2360 850 {} -to 0 -from 10 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 470]  -width [rescale_y_skin 150] -variable ::settings(pressure_end) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_1 settings_profile_pressure" 2510 1335 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[commify $::settings(pressure_end)] [translate "bar"]}

if {[de1plus]} {
	add_de1_button "settings_1 settings_profile_pressure settings_profile_flow" {say [translate {temperature}] $::settings(sound_button_in);vertical_clicker 1 .1 ::settings(espresso_temperature) 80 95 %x %y %x0 %y0 %x1 %y1} 2404 210 2550 665 ""
	add_de1_variable "settings_1 settings_profile_pressure settings_profile_flow" 2460 690 -text "" -font Helv_8_bold -fill "#4e85f4" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}
} else {
	add_de1_button "settings_1 settings_profile_pressure" {say [translate {temperature}] $::settings(sound_button_in);vertical_clicker 1 1 ::settings(espresso_temperature) 80 95 %x %y %x0 %y0 %x1 %y1} 2404 210 2550 665 ""
	add_de1_variable "settings_1 settings_profile_pressure" 2460 690 -text "" -font Helv_8_bold -fill "#4e85f4" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}
}

add_de1_widget "settings_1 settings_profile_pressure" graph 24 220 { 
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth quadratic -pixels [rescale_x_skin 30]; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max [expr { 0.4 + $::de1(max_pressure)}] -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12} -title [translate "pressure (bar)"] -titlefont Helv_10 -titlecolor #5a5d75;

	bind $widget [platform_button_press] { 
		say [translate {refresh chart}] $::settings(sound_button_in); 
		update_de1_explanation_chart
	} 
} -plotbackground #EEEEEE -width [rescale_x_skin 2375] -height [rescale_y_skin 500] -borderwidth 1 -background #FFFFFF -plotrelief raised
############################


############################
# flow controlled shots
add_de1_text "settings_profile_flow" 45 755 -text [translate "1: preinfuse"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left"
add_de1_widget "settings_profile_flow" scale 47 850 {} -to 0.1 -from 5 -tickinterval 0  -showvalue 0 -background #e4d1c1  -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 470] -width [rescale_y_skin 150] -variable ::settings(preinfusion_flow_rate) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #000000 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_profile_flow" 47 1335 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[return_flow_measurement $::settings(preinfusion_flow_rate)]}
add_de1_widget "settings_profile_flow" scale 220 850 {} -from 0 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 330] -width [rescale_y_skin 150] -variable ::settings(preinfusion_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_profile_flow" 220 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(preinfusion_time) [translate "seconds"]}

add_de1_text "settings_profile_flow" 615 755 -text [translate "2: hold"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
add_de1_widget "settings_profile_flow" scale 610 850 {} -to 0 -from 5 -tickinterval 0  -showvalue 0 -background #e4d1c1  -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 470] -width [rescale_y_skin 150] -variable ::settings(flow_profile_hold) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #000000 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_profile_flow" 610 1335 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[return_flow_measurement $::settings(flow_profile_hold)]}
add_de1_widget "settings_profile_flow" scale 790 850 {} -from 0 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 740] -width [rescale_y_skin 150] -variable ::settings(flow_profile_hold_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_profile_flow" 790 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(flow_profile_hold_time) [translate "seconds"]}

#add_de1_widget "settings_profile_flow" scale 790 1100 {} -from 4 -to 10 -background #e4d1c1 -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 740] -width [rescale_y_skin 150] -variable ::settings(flow_profile_minimum_pressure) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_widget "settings_profile_flow" scale 1380 1020 {} -from 10 -to 0 -background #e4d1c1 -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 300] -width [rescale_y_skin 150] -variable ::settings(espresso_pressure) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_profile_flow" 1530 1335 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {$::settings(espresso_pressure) [translate "bar start"]}

add_de1_text "settings_profile_flow" 1605 755 -text [translate "3: decline"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
add_de1_widget "settings_profile_flow" scale 2360 850 {} -to 0 -from 5 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 470]  -width [rescale_y_skin 150] -variable ::settings(flow_profile_decline) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_profile_flow" 2510 1335 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_flow_measurement $::settings(flow_profile_decline)]}

add_de1_widget "settings_profile_flow" scale 1600 850 {} -from 0 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0 -bigincrement 1 -resolution 1 -length [rescale_x_skin 735] -width [rescale_y_skin 150] -variable ::settings(flow_profile_decline_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_profile_flow" 1605 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(flow_profile_decline_time) [translate "seconds"]}

#add_de1_button "settings_profile_flow" {say [translate {temperature}] $::settings(sound_button_in);vertical_clicker 1 1 ::settings(espresso_temperature) 80 95 %x %y %x0 %y0 %x1 %y1} 2404 210 2550 665 ""
#add_de1_variable "settings_profile_flow" 2460 690 -text "" -font Helv_8_bold -fill "#4e85f4" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}

add_de1_widget "settings_profile_flow" graph 24 220 { 
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth quadratic -pixels [rescale_x_skin 30]; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max 5.5 -majorticks {0 1 2 3 4 5 6} -title [translate "flow rate"] -titlefont Helv_10 -titlecolor #5a5d75;

	bind $widget [platform_button_press] { 
		say [translate {refresh chart}] $::settings(sound_button_in); 
		update_de1_explanation_chart
	} 
} -plotbackground #EEEEEE -width [rescale_x_skin 2375] -height [rescale_y_skin 500] -borderwidth 1 -background #FFFFFF -plotrelief raised

############################



############################
# advanced flow profiling
#add_de1_text "settings_profile_advanced" 45 755 -text [translate "1: preinfuse"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left"
add_de1_text "settings_profile_advanced" 330 1100 -text "Temperature" -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

############################


set ::table_style_preview_image [add_de1_image "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" 1330 960 "[skin_directory_graphics]/icon.jpg"]

add_de1_widget "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" listbox 70 340 { 
	fill_profiles_listbox $widget
	} -background #fbfaff -font Helv_10 -bd 0 -height 6 -width 36 -foreground #d3dbf3 -borderwidth 0


add_de1_widget "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" listbox 1330 340 { 
	fill_skin_listbox $widget
	} -background #fbfaff -font Helv_10 -bd 0 -height 8 -width 42 -foreground #d3dbf3 -borderwidth 0 -selectborderwidth 0  -relief raised


#add_de1_text "settings_2" 2250 1020 -text [translate "Load"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"
#add_de1_button "settings_2" {save_new_tablet_skin_setting} 1980 950 2520 1100


add_de1_widget "settings_2 settings_1_preview settings_profile_pressure_preview" graph 30 815 { 
	set ::preview_graph_pressure $widget
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth quadratic -pixels [rescale_x_skin 20]; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max [expr { 0.4 + $::de1(max_pressure)}] -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12} -title "" -titlefont Helv_10 -titlecolor #5a5d75;
	bind $widget [platform_button_press] { after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off $::settings(settings_profile_type); page_show off 	} 
	} -plotbackground #EEEEEE -width [rescale_x_skin 1100] -height [rescale_y_skin 450] -borderwidth 1 -background #FFFFFF -plotrelief raised

add_de1_widget "settings_profile_flow_preview settings_profile_advanced_preview" graph 30 815 { 
	set ::preview_graph_flow $widget
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth quadratic -pixels [rescale_x_skin 30]; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max 6 -majorticks {0 1 2 3 4 5 6} -title [translate "flow rate"] -titlefont Helv_10 -titlecolor #5a5d75;
	bind $widget [platform_button_press] { after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off $::settings(settings_profile_type); page_show off 	} 
	} -plotbackground #EEEEEE -width [rescale_x_skin 1100] -height [rescale_y_skin 450] -borderwidth 1 -background #FFFFFF -plotrelief raised



#set ::table_style_preview_image [add_de1_image "settings_2" 1330 960 "[skin_directory_graphics]/icon.jpg"]

add_de1_variable "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" 1198 1180 -text "" -font Helv_6 -fill "#5a5d75" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}

#add_de1_widget "settings_4" checkbutton 90 600 {} -text [translate "Enable flight mode"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(flight_mode_enable)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

#add_de1_widget "settings_4" scale 90 700 {} -from 1 -to 90 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 1100] -width [rescale_y_skin 135] -variable ::settings(flight_mode_angle) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
#add_de1_text "settings_4" 90 905 -text [translate "Flight mode: start angle"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

#add_de1_text "settings_4" 90 905 -text [translate "Flight mode: start angle"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"
add_de1_text "settings_4" 400 1300 -text [translate "Espresso"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
add_de1_text "settings_4" 1000 1300 -text [translate "Steam"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"

add_de1_text "settings_4" 400 980 -text [translate "Update"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
add_de1_text "settings_4" 1020 980 -text [translate "Reset"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
add_de1_text "settings_4" 2280 980 -text [translate "Pair"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center" -width 200 -justify "center"

# future clean steam feature
add_de1_button "settings_4" {} 30 1206 630 1406
# future clean espresso feature
add_de1_button "settings_4" {} 640 1206 1260 1406


# firmware update
add_de1_button "settings_4" {} 30 890 630 1080
# firmware reset
add_de1_button "settings_4" {} 640 890 1260 1080

# firmware reset
add_de1_button "settings_4" {} 1900 890 2520 1080



#add_de1_text "settings_4" 90 250 -text [translate "Other settings"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_widget "settings_4" entry 1340 380 {} -width 30 -font Helv_15 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(machine_name) 
add_de1_text "settings_4" 1350 480 -text [translate "Name your machine"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

add_de1_text "settings_4" 1320 240 -text [translate "Information"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 1350 600 -text "[translate {Version:}] 1.0 beta 5" -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"
add_de1_text "settings_4" 1350 660 -text "[translate {Serial number:}] 0000001" -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

add_de1_button "settings_3" {say [translate {awake time}] $::settings(sound_button_in);vertical_clicker 600 60 ::settings(alarm_wake) 0 86400 %x %y %x0 %y0 %x1 %y1} 1330 340 1650 820 ""
add_de1_text "settings_3" 1505 880 -text [translate "Heat up"] -font Helv_9 -fill "#7f879a" -anchor "center" -width 800 -justify "center"
add_de1_variable "settings_3" 1505 970 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -textvariable {[format_alarm_time $::settings(alarm_wake)]}

add_de1_button "settings_3" {say [translate {sleep time}] $::settings(sound_button_in);vertical_clicker 600 60 ::settings(alarm_sleep) 0 86400 %x %y %x0 %y0 %x1 %y1} 1690 340 2010 820 ""
add_de1_text "settings_3" 1840 880 -text [translate "Cool down"] -font Helv_9 -fill "#7f879a" -anchor "center" -width 800 -justify "center"
add_de1_variable "settings_3" 1840 970 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -textvariable {[format_alarm_time $::settings(alarm_sleep)]}

add_de1_text "settings_3" 2310 880 -text [translate "Temperature"] -font Helv_9 -fill "#7f879a" -anchor "center" -width 800 -justify "center"


#add_de1_text "settings_3" 1400 250 -text [translate "Scheduler"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 2130 250 -text [translate "Hot water"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 70 250 -text [translate "Screen Brightness"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 70 570 -text [translate "Energy Saver"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 690 570 -text [translate "Screen Saver"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 70 920 -text [translate "Measurements"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 70 1140 -text [translate "Clean"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 70 820 -text [translate "Firmware"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 1320 820 -text [translate "Available machines:"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"



add_de1_widget "settings_4" listbox 1320 900 { 
	fill_ble_listbox $widget
	} -background #fbfaff -font Helv_10 -bd 0 -height 7 -width 20 -foreground #d3dbf3 -borderwidth 0




#add_de1_text "settings_3" 1350 250 -text [translate "Speaking"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_widget "settings_3" scale 70 330 {} -from 0 -to 100 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 550] -width [rescale_y_skin 135] -variable ::settings(app_brightness) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_3" 70 470 -text "" -font Helv_7 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "App:"] $::settings(app_brightness)%}

add_de1_widget "settings_3" scale 670 330 {} -from 0 -to 100 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 550] -width [rescale_y_skin 135] -variable ::settings(saver_brightness) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_3" 670 470 -text "" -font Helv_7 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Screen saver:"] $::settings(saver_brightness)%}

add_de1_widget "settings_3" scale 70 650 {} -from 0 -to 120 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 550] -width [rescale_y_skin 135] -variable ::settings(screen_saver_delay) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_3" 70 790 -text "" -font Helv_7 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Cool down after:"] $::settings(screen_saver_delay) [translate "minutes"]}

add_de1_widget "settings_3" scale 690 650 {} -from 1 -to 120 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 530] -width [rescale_y_skin 135] -variable ::settings(screen_saver_change_interval) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_3" 690 790 -text "" -font Helv_7 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Change every:"] $::settings(screen_saver_change_interval) [translate "minutes"]}

#add_de1_widget "settings_3" checkbutton 1350 400 {} -text [translate "Enable spoken prompts"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_spoken_prompts)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_3" checkbutton 70 1000 {} -text [translate "Fahrenheit"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_fahrenheit)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_3" checkbutton 690 1000 {} -text [translate "AM/PM"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_ampm)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_3" checkbutton 70 1080 {} -text [translate "Fluid ounces"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_fluid_ounces)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_3" checkbutton 690 1080 {} -text [translate "1.234,56"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_commanumbers)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF


add_de1_widget "settings_3" checkbutton 1330 252 {} -text [translate "Scheduler"] -indicatoron true  -font Helv_10_bold -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(timer_enable)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

#add_de1_widget "settings_3" scale 1350 580 {} -from 0 -to 4 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1100] -width [rescale_y_skin 135] -variable ::settings(speaking_rate) -font Helv_10_bold -sliderlength [rescale_x_skin 75] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
#add_de1_text "settings_3" 1350 785 -text [translate "Speaking speed"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

#add_de1_widget "settings_3" scale 1350 840 {} -from 0 -to 3 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1100] -width [rescale_y_skin 135] -variable ::settings(speaking_pitch) -font Helv_10_bold -sliderlength [rescale_x_skin 75] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
#add_de1_text "settings_3" 1350 1045 -text [translate "Speaking pitch"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

#add_de1_button "off" {after 300 update_de1_explanation_chart;unset -nocomplain ::settings_backup; array set ::settings_backup [array get ::settings]; set_next_page off settings_1; page_show settings_1} 2000 0 2560 500
add_de1_text "settings_1 settings_profile_pressure settings_profile_flow settings_profile_advanced settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview settings_3 settings_4" 2275 1520 -text [translate "Save"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
add_de1_text "settings_1 settings_profile_pressure settings_profile_flow settings_profile_advanced settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview settings_3 settings_4" 1760 1520 -text [translate "Cancel"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"

#add_de1_text "settings_2" 1025 1328 -text [translate "Save"] -font Helv_10_bold -fill "#f1f1f9" -anchor "center"
add_de1_widget "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" entry 70 1290  {set ::globals(widget_profile_name_to_save) $widget} -width 38 -font Helv_8  -borderwidth 1 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(profile_to_save) 

add_de1_button "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" {say [translate {save}] $::settings(sound_button_in); save_profile} 1040 1265 1260 1400
add_de1_button "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" {say [translate {cancel}] $::settings(sound_button_in); delete_selected_profile} 1100 300 1270 500

# labels for PREHEAT tab on

set settings_label1 [translate "PRESSURE"]
set settings_label2 [translate "Pressure profiles"]

if {[de1plus]} {
	set settings_label1 [translate "PROFILE"]
	set settings_label2 [translate "Profiles"]

	# types of profiles available on DE1+
	add_de1_text "settings_profile_pressure settings_1" 240 1485 -text [translate "PRESSURE"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
	add_de1_text "settings_profile_pressure settings_1" 735 1485 -text [translate "FLOW"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
	add_de1_text "settings_profile_pressure settings_1" 1220 1485 -text [translate "ADVANCED"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 

	add_de1_text "settings_profile_flow" 240 1485 -text [translate "PRESSURE"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
	add_de1_text "settings_profile_flow" 735 1485 -text [translate "FLOW"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
	add_de1_text "settings_profile_flow" 1220 1485 -text [translate "ADVANCED"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 

	add_de1_text "settings_profile_advanced" 240 1485 -text [translate "PRESSURE"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
	add_de1_text "settings_profile_advanced" 735 1485 -text [translate "FLOW"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
	add_de1_text "settings_profile_advanced" 1220 1485 -text [translate "ADVANCED"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 


#add_de1_button "settings_1 settings_2 settings_3 settings_4" {after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_1; page_show settings_1} 0 0 641 188
#add_de1_button "settings_1 settings_2 settings_3 settings_4" {after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_1; page_show settings_1} 0 189 641 499


add_de1_button "settings_profile_pressure settings_profile_flow settings_profile_advanced settings_1" {after 500 update_de1_explanation_chart; say [translate {PRESSURE}] $::settings(sound_button_in); set ::settings(settings_profile_type) "settings_profile_pressure"; set_next_page off $::settings(settings_profile_type); page_show off} 1 1410 495 1600
add_de1_button "settings_profile_pressure settings_profile_flow settings_profile_advanced settings_1" {after 500 update_de1_explanation_chart; say [translate {FLOW}] $::settings(sound_button_in); set ::settings(settings_profile_type) "settings_profile_flow"; set_next_page off $::settings(settings_profile_type); page_show off} 496 1410 972 1600
add_de1_button "settings_profile_pressure settings_profile_flow settings_profile_advanced settings_1" {after 500 update_de1_explanation_chart; say [translate {ADVANCED}] $::settings(sound_button_in); set ::settings(settings_profile_type) "settings_profile_advanced"; set_next_page off $::settings(settings_profile_type); page_show off} 974 1410 1500 1600

#add_de1_button "settings_1 settings_1a settings_1b" {after 500 update_de1_explanation_chart; say [translate {Flow}] $::settings(sound_button_in); set_next_page off settings_1a; page_show settings_1a} 1 1601 495 1800
#add_de1_button "settings_1 settings_1a settings_1b" {say [translate {save}] $::settings(sound_button_in); save_profile} 1 1410 495 1600
#add_de1_button "settings_2" {say [translate {cancel}] $::settings(sound_button_in); delete_selected_profile} 1100 300 1270 500

}


#add_de1_text "settings_1 settings_profile_pressure settings_profile_flow settings_profile_advanced" 330 100 -text $settings_label1 -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "settings_1 settings_profile_pressure settings_profile_flow settings_profile_advanced" 330 100 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[setting_profile_type_to_text $::settings(settings_profile_type)]}

add_de1_text "settings_1 settings_profile_pressure settings_profile_flow settings_profile_advanced" 960 100 -text [translate "PRESETS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1 settings_profile_pressure settings_profile_flow settings_profile_advanced" 1590 100 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1 settings_profile_pressure settings_profile_flow settings_profile_advanced" 2215 100 -text [translate "MACHINE"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

########################################
# labels for WATER/STEAM tab on
#add_de1_text "settings_2" 330 100 -text $settings_label1 -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_variable "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" 330 100 -text "" -font Helv_10_bold -fill "#5a5d75" -anchor "center" -textvariable {[setting_profile_type_to_text $::settings(settings_profile_type)]}
add_de1_text "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" 960 100 -text [translate "PRESETS"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" 1590 100 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" 2215 100 -text [translate "MACHINE"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

add_de1_button "settings_3" {say [translate {water temperature}] $::settings(sound_button_in);vertical_clicker 1 1 ::settings(water_temperature) $::de1(water_min_temperature) $::de1(water_max_temperature) %x %y %x0 %y0 %x1 %y1} 2130 340 2500 820 ""
add_de1_variable "settings_3" 2310 970 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}

#add_de1_button "settings_2" {say [translate {water time}] $::settings(sound_button_in);vertical_clicker 1 1 ::settings(water_max_time) $::de1(water_time_min) $::de1(water_time_max) %x %y %x0 %y0 %x1 %y1} 571 500 1250 1260 ""
#add_de1_variable "settings_2" 900 1320 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(water_max_time)] [translate "seconds"]}

#add_de1_button "settings_2" {say [translate {steam temperature}] $::settings(sound_button_in);vertical_clicker 1 1 ::settings(steam_temperature) $::de1(steam_min_temperature) $::de1(steam_max_temperature) %x %y %x0 %y0 %x1 %y1} 1330 680 1850 1260 ""
#add_de1_variable "settings_2" 1640 1320 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(steam_temperature)]}

#add_de1_button "settings_2" {say [translate {steam time}] $::settings(sound_button_in);vertical_clicker 1 1 ::settings(steam_max_time) $::de1(steam_time_min) $::de1(steam_time_max) %x %y %x0 %y0 %x1 %y1} 1851 500 2500 1260 ""
#add_de1_variable "settings_2" 2170 1320 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(steam_max_time)] [translate "seconds"]}

add_de1_text "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" 70 240 -text $settings_label2 -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"
#add_de1_variable "settings_2" 70 240 -text "" -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw" -textvariable {[setting_profile_type_to_text $::settings(settings_profile_type)]}
add_de1_text "settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview" 1330 240 -text [translate "Tablet styles"] -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"

########################################

# labels for STEAM tab on
#add_de1_text "settings_3" 330 100 -text $settings_label1 -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_variable "settings_3" 330 100 -text "" -font Helv_10_bold -fill "#5a5d75" -anchor "center" -textvariable {[setting_profile_type_to_text $::settings(settings_profile_type)]}
 
add_de1_text "settings_3" 960 100 -text [translate "PRESETS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 1590 100 -text [translate "OTHER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_3" 2215 100 -text [translate "MACHINE"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for HOT WATER tab on
#add_de1_text "settings_4" 330 100 -text $settings_label1 -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_variable "settings_4" 330 100 -text "" -font Helv_10_bold -fill "#5a5d75" -anchor "center" -textvariable {[setting_profile_type_to_text $::settings(settings_profile_type)]}
add_de1_text "settings_4" 960 100 -text [translate "PRESETS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 1590 100 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 2215 100 -text [translate "MACHINE"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "settings_1 settings_profile_pressure settings_profile_flow settings_profile_advanced settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview settings_3 settings_4" {after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off $::settings(settings_profile_type); page_show off} 0 0 641 188
add_de1_button "settings_1 settings_profile_pressure settings_profile_flow settings_profile_advanced settings_1b settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview settings_3 settings_4" {after 500 update_de1_explanation_chart; fill_skin_listbox $::globals(tablet_styles_listbox); say [translate {settings}] $::settings(sound_button_in); set_next_page off "$::settings(settings_profile_type)_preview"; page_show off; } 642 0 1277 188
add_de1_button "settings_1 settings_profile_pressure settings_profile_flow settings_profile_advanced settings_1b settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_3; page_show settings_3} 1278 0 1904 188
add_de1_button "settings_1 settings_profile_pressure settings_profile_flow settings_profile_advanced settings_1b settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_4; page_show settings_4} 1905 0 2560 188

add_de1_button "settings_1 settings_profile_pressure settings_profile_flow settings_profile_advanced settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview settings_3 settings_4" {say [translate {save}] $::settings(sound_button_in); save_settings; 
	if {$::settings(skin) != $::settings_backup(skin) } {
		.can itemconfigure $::message_label -text [translate "Please quit and restart this app to apply your changes."]
		set_next_page off message; page_show message
	} else {
		set_next_page off off; page_show off
	}
} 2016 1430 2560 1600
#add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {save}] $::settings(sound_button_in); save_settings; set_next_page off off; page_show off} 2016 1430 2560 1600
add_de1_button "settings_1 settings_profile_pressure settings_profile_flow settings_profile_advanced settings_2 settings_1_preview settings_profile_pressure_preview settings_profile_flow_preview settings_profile_advanced_preview settings_3 settings_4" {unset -nocomplain ::settings; array set ::settings [array get ::settings_backup]; update_de1_explanation_chart; fill_ble_listbox $::globals(ble_listbox); fill_profiles_listbox $::globals(profiles_listbox); fill_skin_listbox $::globals(tablet_styles_listbox); say [translate {Cancel}] $::settings(sound_button_in); set_next_page off off; page_show off} 1505 1430 2015 1600

# END OF SETTINGS page
##############################################################################################################################################################################################################################################################################

proc setting_profile_type_to_text { in } {
	if {$in == "settings_profile_pressure"} {
		return [translate "PRESSURE PROFILE"]
	} elseif {$in == "settings_profile_flow"} {
		return [translate "FLOW PROFILE"]
	} elseif {$in == "settings_profile_advanced"} {
		return [translate "ADVANCED PROFILE"]
	} else {
		return [translate "PROFILE"]
	}

}