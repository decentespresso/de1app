##############################################################################################################################################################################################################################################################################
# DE1 SETTINGS pages

##############################################################################################################################################################################################################################################################################
# the graphics for each of the main espresso machine modes

add_de1_page "settings_1" "[defaultskin_directory_graphics]/settings_1.jpg"

if {[de1plus]} {

	add_de1_page "settings_1" "[defaultskin_directory_graphics]/settings_1.jpg"
	add_de1_page "settings_2a" "[defaultskin_directory_graphics]/settings_2a.jpg"
	add_de1_page "settings_2b" "[defaultskin_directory_graphics]/settings_2b.jpg"
	add_de1_page "settings_2c" "[defaultskin_directory_graphics]/settings_2c.jpg"

	if {$::settings(settings_profile_type) == "settings_2"} {
		# this happens if you switch to the de1 gui, which then saves the de1 settings default, so we need to reset it to this de1+ default
		set ::settings(settings_profile_type) "settings_2a"
	}
} else {
	set ::settings(settings_profile_type) "settings_2"
	add_de1_page "settings_1" "[defaultskin_directory_graphics]/settings_1.jpg"
	add_de1_page "settings_2" "[defaultskin_directory_graphics]/settings_2.jpg"
}

add_de1_page "settings_3" "[defaultskin_directory_graphics]/settings_3.jpg"
add_de1_page "settings_4" "[defaultskin_directory_graphics]/settings_4.jpg"

# this is the message page
set ::message_label [add_de1_text "message" 1280 750 -text "" -font Helv_15_bold -fill "#2d3046" -justify "center" -anchor "center" -width 900]
set ::message_button_label [add_de1_text "message" 1280 1090 -text [translate "Quit"] -font Helv_10_bold -fill "#fAfBff" -anchor "center"]
set ::message_button [add_de1_button "message" {say [translate {Quit}] $::settings(sound_button_in);exit} 980 990 1580 1190 ""]

##############################################################################################################################################################################################################################################################################

############################
# pressure controlled shots
add_de1_text "settings_2 settings_profile_pressure" 45 755 -text [translate "1: preinfuse"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
if {[de1plus]} {
	add_de1_widget "settings_2a settings_profile_pressure" scale 47 850 {} -to 0.1 -from 5 -tickinterval 0  -showvalue 0 -background #e4d1c1  -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 470] -width [rescale_y_skin 150] -variable ::settings(preinfusion_flow_rate) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #000000 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
	add_de1_variable "settings_2a settings_profile_pressure" 47 1335 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[return_flow_measurement $::settings(preinfusion_flow_rate)]}
	add_de1_widget "settings_2a settings_profile_pressure" scale 220 850 {} -from 0 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 330] -width [rescale_y_skin 150] -variable ::settings(preinfusion_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
	add_de1_variable "settings_2a settings_profile_pressure" 220 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[seconds_text $::settings(preinfusion_time)]}
} else {
	add_de1_widget "settings_2 settings_profile_pressure" scale 47 850 {} -from 0 -to 10 -tickinterval 0  -showvalue 0 -background #e4d1c1  -bigincrement 1 -resolution 1 -length [rescale_x_skin 500] -width [rescale_y_skin 150] -variable ::settings(preinfusion_time) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command {update_de1_explanation_chart_soon} -foreground #000000 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 -orient horizontal 
	add_de1_variable "settings_2 settings_profile_pressure" 50 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[seconds_text $::settings(preinfusion_time)]}
}


add_de1_text "settings_2 settings_2a" 615 755 -text [translate "2: rise and hold"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
set ::maxpressure 10
if {[de1plus]} { 
	set ::maxpressure 12 
	add_de1_widget "settings_2a" scale 610 850 {} -to 1 -from $::maxpressure -tickinterval 0  -showvalue 0 -background #e4d1c1  -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 470] -width [rescale_y_skin 150] -variable ::settings(espresso_pressure) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #000000 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
	add_de1_widget "settings_2a" scale 790 850 {} -from 0 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 740] -width [rescale_y_skin 150] -variable ::settings(espresso_hold_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
	add_de1_widget "settings_2a" scale 2360 850 {} -to 0 -from 10 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 470]  -width [rescale_y_skin 150] -variable ::settings(pressure_end) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 

} else {
	add_de1_widget "settings_2" scale 610 850 {} -to 1 -from $::maxpressure -tickinterval 0  -showvalue 0 -background #e4d1c1  -bigincrement 1 -resolution 1 -length [rescale_x_skin 470] -width [rescale_y_skin 150] -variable ::settings(espresso_pressure) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #000000 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
	add_de1_widget "settings_2" scale 790 850 {} -from 5 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 740] -width [rescale_y_skin 150] -variable ::settings(espresso_hold_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
	add_de1_widget "settings_2 settings_2a" scale 2360 850 {} -to 0 -from 10 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 470]  -width [rescale_y_skin 150] -variable ::settings(pressure_end) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
}
add_de1_variable "settings_2 settings_2a" 610 1335 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[commify $::settings(espresso_pressure)] [translate "bar"]}
add_de1_variable "settings_2 settings_2a" 790 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[seconds_text $::settings(espresso_hold_time)]}

add_de1_text "settings_2 settings_2a" 1605 755 -text [translate "3: decline"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
add_de1_widget "settings_2 settings_2a" scale 1600 850 {} -from 0 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0 -bigincrement 1 -resolution 1 -length [rescale_x_skin 735] -width [rescale_y_skin 150] -variable ::settings(espresso_decline_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_2 settings_2a" 1605 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {[seconds_text $::settings(espresso_decline_time)]}
add_de1_variable "settings_2 settings_2a" 2510 1335 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[commify $::settings(pressure_end)] [translate "bar"]}

if {[de1plus]} {
	add_de1_button "settings_2 settings_2a settings_2b" {say [translate {temperature}] $::settings(sound_button_in);vertical_clicker 1 .1 ::settings(espresso_temperature) 80 95 %x %y %x0 %y0 %x1 %y1} 2404 210 2550 665 ""
	add_de1_variable "settings_2 settings_2a settings_2b" 2460 690 -text "" -font Helv_8_bold -fill "#4e85f4" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}
} else {
	add_de1_button "settings_2" {say [translate {temperature}] $::settings(sound_button_in);vertical_clicker 1 1 ::settings(espresso_temperature) 80 95 %x %y %x0 %y0 %x1 %y1} 2404 210 2550 665 ""
	add_de1_variable "settings_2" 2460 690 -text "" -font Helv_8_bold -fill "#4e85f4" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}
}

add_de1_widget "settings_2 settings_2a" graph 24 220 { 
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth quadratic -pixels [rescale_x_skin 30]; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max [expr {0.1 + $::maxpressure}] -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12} -title [translate "pressure (bar)"] -titlefont Helv_10 -titlecolor #5a5d75;

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
add_de1_widget "settings_profile_flow" scale 790 850 {} -from 0 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 740] -width [rescale_y_skin 150] -variable ::settings(espresso_hold_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_profile_flow" 790 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(espresso_hold_time) [translate "seconds"]}

add_de1_widget "settings_profile_pressure settings_profile_flow" scale 390 1070 {} -from $::maxpressure -to 1 -background #e4d1c1 -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution .1 -length [rescale_x_skin 250] -width [rescale_y_skin 150] -variable ::settings(preinfusion_stop_pressure) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_profile_pressure settings_profile_flow" 560 1335 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {$::settings(preinfusion_stop_pressure) [translate "bar"]}
add_de1_text "settings_profile_pressure settings_profile_flow" 290 1335 -text [translate "or"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 400 -justify "center" 


add_de1_widget "settings_profile_flow" scale 1380 1020 {} -from $::maxpressure -to 1 -background #e4d1c1 -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution .1 -length [rescale_x_skin 300] -width [rescale_y_skin 150] -variable ::settings(espresso_pressure) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_profile_flow" 1530 1335 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {$::settings(espresso_pressure) [translate "bar start"]}


add_de1_text "settings_profile_flow" 1605 755 -text [translate "3: decline"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
add_de1_widget "settings_profile_flow" scale 2360 850 {} -to 0 -from 5 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 470]  -width [rescale_y_skin 150] -variable ::settings(flow_profile_decline) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_profile_flow" 2510 1335 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_flow_measurement $::settings(flow_profile_decline)]}

add_de1_widget "settings_profile_flow" scale 1600 850 {} -from 0 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0 -bigincrement 1 -resolution 1 -length [rescale_x_skin 735] -width [rescale_y_skin 150] -variable ::settings(espresso_decline_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart_soon -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_profile_flow" 1605 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(espresso_decline_time) [translate "seconds"]}

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
add_de1_text "settings_2c" 70 230 -text "Step" -font Helv_10_bold -fill "#5a5d75" -anchor "nw" 
add_de1_text "settings_2c" 960 230 -text "Temperature" -font Helv_10_bold -fill "#5a5d75" -anchor "nw" 
add_de1_text "settings_2c" 1580 230 -text "Water speed" -font Helv_10_bold -fill "#5a5d75" -anchor "nw" 

add_de1_text "settings_2c" 240 1318 -text "Add" -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2c" 740 1318 -text "Remove" -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

add_de1_text "settings_2c" 960 820 -text "Exit when" -font Helv_10_bold -fill "#5a5d75" -anchor "nw" 
add_de1_text "settings_2c" 1960 820 -text "Maximum" -font Helv_10_bold -fill "#5a5d75" -anchor "nw" 

add_de1_widget "settings_2c" listbox 70 320 { 
	fill_profile_steps_listbox $widget

} -background #fbfaff -font Helv_10 -bd 0 -height 10 -width 32 -foreground #d3dbf3 -borderwidth 0


add_de1_widget "settings_2c" entry 70 1100  {set ::globals(widget_profile_step_save) $widget} -width 35 -font Helv_8  -borderwidth 1 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(profile_step) 

add_de1_button "settings_2c" {say [translate {temperature}] $::settings(sound_button_in);vertical_clicker 1 .1 ::settings(espresso_temperature) 80 95 %x %y %x0 %y0 %x1 %y1} 980 310 1120 680 ""
add_de1_variable "settings_2c" 1055 744 -text "" -font Helv_8_bold -fill "#4e85f4" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}

add_de1_button "settings_2c" {say [translate {boiler}] $::settings(sound_button_in);set ::settings(temperature_target) "boiler"; update_onscreen_variables} 1200 310 1360 680 ""
add_de1_button "settings_2c" {say [translate {portafilter}] $::settings(sound_button_in);set ::settings(temperature_target) "portafilter"; update_onscreen_variables} 1361 310 1550 680 ""
add_de1_variable "settings_2c" 1360 744 -text "" -font Helv_8_bold -fill "#4e85f4" -anchor "center" -textvariable {[translate $::settings(temperature_target)]}

add_de1_button "settings_2c" {say [translate {boiler}] $::settings(sound_button_in);set ::settings(flow_rate_transition) "fast"; update_onscreen_variables} 2200 310 2350 680 ""
add_de1_button "settings_2c" {say [translate {portafilter}] $::settings(sound_button_in);set ::settings(flow_rate_transition) "smooth"; update_onscreen_variables} 2351 310 2500 680 ""
add_de1_variable "settings_2c" 2345 744 -text "" -font Helv_8_bold -fill "#4e85f4" -anchor "center" -textvariable {[translate $::settings(flow_rate_transition)]}

add_de1_button "settings_2c" {say [translate {boiler}] $::settings(sound_button_in);set ::settings(water_speed_type) "flow"; vertical_clicker 1 .1 ::settings(flow_profile_hold) 0 6 %x %y %x0 %y0 %x1 %y1; update_onscreen_variables} 1580 410 1800 680 ""
add_de1_button "settings_2c" {say [translate {portafilter}] $::settings(sound_button_in);set ::settings(water_speed_type) "pressure"; vertical_clicker 1 .1 ::settings(espresso_pressure) 0 12 %x %y %x0 %y0 %x1 %y1; update_onscreen_variables} 1900 380 2120 680 ""
add_de1_variable "settings_2c" 1690 844 -text "" -font Helv_8_bold -fill "#4e85f4" -anchor "center" -textvariable {[translate $::settings(water_speed_type)]}
add_de1_variable "settings_2c" 1694 744 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -justify "center" -textvariable {[if {$::settings(water_speed_type) == "flow"} {return $::settings(flow_profile_hold)} else { return "" }] }
add_de1_variable "settings_2c" 2010 744 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -textvariable {[if {$::settings(water_speed_type) == "pressure"} {return $::settings(espresso_pressure)} else { return "" }] }

add_de1_text "settings_2c" 1840 710 -text [translate "or"] -font Helv_7 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 

add_de1_text "settings_2c" 1070 1340 -text "6.4 bar" -font Helv_10_bold -fill "#4e85f4" -anchor "center" 
add_de1_text "settings_2c" 2090 1340 -text "60 ml" -font Helv_10_bold -fill "#4e85f4" -anchor "center" 
add_de1_text "settings_2c" 2385 1340 -text "30s" -font Helv_10_bold -fill "#4e85f4" -anchor "center" 

add_de1_text "settings_2c" 1360 680 -text [translate "target"] -font Helv_8 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
add_de1_text "settings_2c" 1694 680 -text [translate "flow"] -font Helv_8 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
add_de1_text "settings_2c" 2010 680 -text [translate "pressure"] -font Helv_8 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
add_de1_text "settings_2c" 2345 680 -text [translate "transition"] -font Helv_8 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 


add_de1_text "settings_2c" 1180 1270 -text [translate "or"] -font Helv_7 -fill "#7f879a" -anchor "nw" -width 400 -justify "center" 
add_de1_text "settings_2c" 1666 1270 -text [translate "or"] -font Helv_7 -fill "#7f879a" -anchor "nw" -width 400 -justify "center" 
add_de1_text "settings_2c" 1426 1270 -text [translate "or"] -font Helv_7 -fill "#7f879a" -anchor "nw" -width 400 -justify "center" 

add_de1_text "settings_2c" 1070 1260 -text [translate "over"] -font Helv_8 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
add_de1_text "settings_2c" 1320 1260 -text [translate "under"] -font Helv_8 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 


add_de1_text "settings_2c" 1570 1260 -text [translate "over"] -font Helv_8 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
add_de1_text "settings_2c" 1820 1260 -text [translate "under"] -font Helv_8 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 


add_de1_text "settings_2c" 2085 1260 -text [translate "volume"] -font Helv_8 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 
add_de1_text "settings_2c" 2384 1260 -text [translate "time"] -font Helv_8 -fill "#7f879a" -anchor "center" -width 400 -justify "center" 

############################

set ::table_style_preview_image [add_de1_image "settings_3" 1860 310 "[skin_directory_graphics]/icon.jpg"]

add_de1_widget "settings_1" listbox 50 310 { 
	fill_profiles_listbox $widget
	} -background #fbfaff -font Helv_10 -bd 0 -height 15 -width 36 -foreground #d3dbf3 -borderwidth 0


add_de1_widget "settings_3" listbox 1310 310 { 
	fill_skin_listbox $widget
	} -background #fbfaff -font Helv_10 -bd 0 -height 15 -width 18 -foreground #d3dbf3 -borderwidth 0 -selectborderwidth 0  -relief raised

add_de1_widget "settings_1" graph 1330 300 { 
	set ::preview_graph_pressure $widget
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth quadratic -pixels [rescale_x_skin 20]; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max [expr {0.1 + $::maxpressure}] -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12} -title "" -titlefont Helv_10 -titlecolor #5a5d75;
	bind $widget [platform_button_press] { after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off $::settings(settings_profile_type); page_show off 	} 
	} -plotbackground #EEEEEE -width [rescale_x_skin 1100] -height [rescale_y_skin 450] -borderwidth 1 -background #FFFFFF -plotrelief raised

add_de1_widget "settings_2a settings_2b" graph 30 815 { 
	set ::preview_graph_flow $widget
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth quadratic -pixels [rescale_x_skin 30]; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max 6 -majorticks {0 1 2 3 4 5 6} -title [translate "flow rate"] -titlefont Helv_10 -titlecolor #5a5d75;
	bind $widget [platform_button_press] { after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off $::settings(settings_profile_type); page_show off 	} 
	} -plotbackground #EEEEEE -width [rescale_x_skin 1100] -height [rescale_y_skin 450] -borderwidth 1 -background #FFFFFF -plotrelief raised


add_de1_variable "settings_1" 2460 670 -text "" -font Helv_6 -fill "#7f879a" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}

add_de1_text "settings_4" 380 1300 -text [translate "Clean"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
add_de1_text "settings_4" 1000 1300 -text [translate "Descale"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"

add_de1_text "settings_4" 400 980 -text [translate "Update"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
add_de1_text "settings_4" 1020 980 -text [translate "Reset"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
#add_de1_text "settings_4" 2280 980 -text [translate "Pair"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center" -width 200 -justify "center"

# future clean steam feature
add_de1_button "settings_4" {} 30 1206 630 1406

# future clean espresso feature
#add_de1_button "settings_4" {} 640 1206 1260 1406


# firmware update
add_de1_button "settings_4" {} 30 890 630 1080

# firmware reset
add_de1_button "settings_4" {} 640 890 1260 1080

# firmware reset
#add_de1_button "settings_4" {} 1900 890 2520 1080



#add_de1_text "settings_4" 90 250 -text [translate "Other settings"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_widget "settings_4" entry 1340 380 {} -width 30 -font Helv_15 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(machine_name) 
add_de1_text "settings_4" 1350 480 -text [translate "Name your machine"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"
add_de1_text "settings_4" 1320 240 -text [translate "Information"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 1350 600 -text "[translate {Version:}] 1.0 beta 6" -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"
#add_de1_text "settings_4" 1350 660 -text "[translate {Serial number:}] 0000001" -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

# future feature to have scheduled power up/down
set scheduler_enabled 0
if {$scheduler_enabled == 1} {
	add_de1_widget "settings_3" checkbutton 1330 252 {} -text [translate "Scheduler"] -indicatoron true  -font Helv_10_bold -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(timer_enable)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
	add_de1_button "settings_3" {say [translate {awake time}] $::settings(sound_button_in);vertical_clicker 600 60 ::settings(alarm_wake) 0 86400 %x %y %x0 %y0 %x1 %y1} 1330 340 1650 820 ""
	add_de1_text "settings_3" 1505 880 -text [translate "Heat up"] -font Helv_9 -fill "#7f879a" -anchor "center" -width 800 -justify "center"
	add_de1_variable "settings_3" 1505 970 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -textvariable {[format_alarm_time $::settings(alarm_wake)]}
	add_de1_button "settings_3" {say [translate {sleep time}] $::settings(sound_button_in);vertical_clicker 600 60 ::settings(alarm_sleep) 0 86400 %x %y %x0 %y0 %x1 %y1} 1690 340 2010 820 ""
	add_de1_text "settings_3" 1840 880 -text [translate "Cool down"] -font Helv_9 -fill "#7f879a" -anchor "center" -width 800 -justify "center"
	add_de1_variable "settings_3" 1840 970 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -textvariable {[format_alarm_time $::settings(alarm_sleep)]}
	add_de1_text "settings_3" 1400 250 -text [translate "Scheduler"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
}

#add_de1_text "settings_3" 2310 880 -text [translate "Temperature"] -font Helv_9 -fill "#7f879a" -anchor "center" -width 800 -justify "center"


add_de1_text "settings_3" 50 1120 -text [translate "Hot water"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 50 220 -text [translate "Screen Brightness"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 50 540 -text [translate "Energy Saver"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 680 540 -text [translate "Screen Saver"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 50 860 -text [translate "Measurements"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 50 1140 -text [translate "Maintenance"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 50 820 -text [translate "Firmware"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 1320 820 -text [translate "Available machines:"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"



add_de1_widget "settings_4" listbox 1320 900 { 
	set ::ble_listbox_widget $widget
	fill_ble_listbox $widget
} -background #fbfaff -font Helv_15 -bd 0 -height 5 -width 32 -foreground #d3dbf3 -borderwidth 0



set enable_spoken_buttons 0
if {$enable_spoken_buttons == 1} {
	add_de1_widget "settings_3" scale 1350 580 {} -from 0 -to 4 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1100] -width [rescale_y_skin 135] -variable ::settings(speaking_rate) -font Helv_10_bold -sliderlength [rescale_x_skin 75] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
	add_de1_text "settings_3" 1350 785 -text [translate "Speaking speed"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

	add_de1_widget "settings_3" scale 1350 840 {} -from 0 -to 3 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1100] -width [rescale_y_skin 135] -variable ::settings(speaking_pitch) -font Helv_10_bold -sliderlength [rescale_x_skin 75] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
	add_de1_text "settings_3" 1350 1045 -text [translate "Speaking pitch"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"
	add_de1_text "settings_3" 1350 250 -text [translate "Speaking"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
	add_de1_widget "settings_3" checkbutton 1350 400 {} -text [translate "Enable spoken prompts"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_spoken_prompts)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
}

add_de1_widget "settings_3" scale 50 300 {} -from 0 -to 100 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 550] -width [rescale_y_skin 135] -variable ::settings(app_brightness) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_3" 50 440 -text "" -font Helv_7 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "App:"] $::settings(app_brightness)%}

add_de1_widget "settings_3" scale 670 300 {} -from 0 -to 100 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 550] -width [rescale_y_skin 135] -variable ::settings(saver_brightness) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_3" 670 440 -text "" -font Helv_7 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Screen saver:"] $::settings(saver_brightness)%}

add_de1_widget "settings_3" scale 50 620 {} -from 0 -to 120 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 550] -width [rescale_y_skin 135] -variable ::settings(screen_saver_delay) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_3" 50 760 -text "" -font Helv_7 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Cool down after:"] $::settings(screen_saver_delay) [translate "minutes"]}

add_de1_widget "settings_3" scale 690 620 {} -from 1 -to 120 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 530] -width [rescale_y_skin 135] -variable ::settings(screen_saver_change_interval) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_3" 690 760 -text "" -font Helv_7 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Change every:"] $::settings(screen_saver_change_interval) [translate "minutes"]}


add_de1_widget "settings_3" checkbutton 70 940 {} -text [translate "Fahrenheit"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_fahrenheit)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_3" checkbutton 690 940 {} -text [translate "AM/PM"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_ampm)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_3" checkbutton 70 1000 {} -text [translate "Fluid ounces"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_fluid_ounces)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_3" checkbutton 690 1000 {} -text [translate "1.234,56"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_commanumbers)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_text "settings_1 settings_2 settings_2a settings_2b settings_2c settings_3 settings_4" 2275 1520 -text [translate "Save"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
add_de1_text "settings_1 settings_2 settings_2a settings_2b settings_2c settings_3 settings_4" 1760 1520 -text [translate "Cancel"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"


add_de1_button "settings_1" {say [translate {save}] $::settings(sound_button_in); save_profile} 2300 1220 2550 1410
add_de1_button "settings_1" {say [translate {cancel}] $::settings(sound_button_in); delete_selected_profile} 1100 280 1300 500

set settings_label1 [translate "PRESSURE"]
set settings_label2 [translate "Pressure profiles"]


#add_de1_text "settings_1" 50 220 -text $settings_label2 -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw" 
add_de1_text "settings_1" 50 230 -text [translate "Load a preset"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw" 
add_de1_text "settings_1" 1360 230 -text [translate "Preview"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw" 
add_de1_text "settings_1" 1360 830 -text [translate "Description"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw" 
add_de1_text "settings_1" 1360 1240 -text [translate "Name and save"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw" 
add_de1_widget "settings_1" multiline_entry 1360 900 {} -width 40 -height 4 -font Helv_9  -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -textvariable ::settings(profile_notes) 
add_de1_widget "settings_1" entry 1360 1310  {set ::globals(widget_profile_name_to_save) $widget} -width 32 -font Helv_9  -borderwidth 1 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(profile_to_save) 


add_de1_text "settings_3" 1310 220 -text [translate "Tablet styles"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"




# labels for PREHEAT tab on

if {[de1plus]} {
	set settings_label1 [translate "PROFILE"]
	set settings_label2 [translate "Profiles"]

	# types of profiles available on DE1+
	add_de1_text "settings_2a" 240 1485 -text [translate "PRESSURE"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
	add_de1_text "settings_2a" 735 1485 -text [translate "FLOW"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
	add_de1_text "settings_2a" 1220 1485 -text [translate "ADVANCED"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 

	add_de1_text "settings_2b" 240 1485 -text [translate "PRESSURE"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
	add_de1_text "settings_2b" 735 1485 -text [translate "FLOW"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
	add_de1_text "settings_2b" 1220 1485 -text [translate "ADVANCED"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 

	add_de1_text "settings_2c" 240 1485 -text [translate "PRESSURE"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
	add_de1_text "settings_2c" 735 1485 -text [translate "FLOW"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
	add_de1_text "settings_2c" 1220 1485 -text [translate "ADVANCED"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

	add_de1_button "settings_2a settings_2b settings_2c" {after 500 update_de1_explanation_chart; say [translate {PRESSURE}] $::settings(sound_button_in); set ::settings(settings_profile_type) "settings_2a"; set_next_page off $::settings(settings_profile_type); page_show off} 1 1410 495 1600
	add_de1_button "settings_2a settings_2b settings_2c" {after 500 update_de1_explanation_chart; say [translate {FLOW}] $::settings(sound_button_in); set ::settings(settings_profile_type) "settings_2b"; set_next_page off $::settings(settings_profile_type); page_show off} 496 1410 972 1600
	add_de1_button "settings_2a settings_2b settings_2c" {after 500 update_de1_explanation_chart; say [translate {ADVANCED}] $::settings(sound_button_in); set ::settings(settings_profile_type) "settings_2c"; set_next_page off $::settings(settings_profile_type); page_show off} 974 1410 1500 1600
}



########################################
# labels for tab1
add_de1_text "settings_1" 330 100 -text [translate "PRESETS"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "settings_1" 960 100 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[setting_profile_type_to_text $::settings(settings_profile_type)]}
add_de1_text "settings_1" 1590 100 -text [translate "OTHER"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
add_de1_text "settings_1" 2215 100 -text [translate "MACHINE"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 

########################################
# labels for tab2
add_de1_text "settings_2 settings_2a settings_2b settings_2c" 330 100 -text [translate "PRESETS"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
add_de1_variable "settings_2 settings_2a settings_2b settings_2c" 960 100 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[setting_profile_type_to_text $::settings(settings_profile_type)]}
add_de1_text "settings_2 settings_2a settings_2b settings_2c" 1590 100 -text [translate "OTHER"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
add_de1_text "settings_2 settings_2a settings_2b settings_2c" 2215 100 -text [translate "MACHINE"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 

########################################
# top labels for tab3 
add_de1_text "settings_3" 330 100 -text [translate "PRESETS"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
add_de1_variable "settings_3" 960 100 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[setting_profile_type_to_text $::settings(settings_profile_type)]}
add_de1_text "settings_3" 1590 100 -text [translate "OTHER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_3" 2215 100 -text [translate "MACHINE"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 

# top labels for tab4
add_de1_text "settings_4" 330 100 -text [translate "PRESETS"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
add_de1_variable "settings_4" 960 100 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[setting_profile_type_to_text $::settings(settings_profile_type)]}
add_de1_text "settings_4" 1590 100 -text [translate "OTHER"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
add_de1_text "settings_4" 2215 100 -text [translate "MACHINE"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "settings_1 settings_2 settings_2a settings_2b settings_2c settings_3 settings_4" {after 500 update_de1_explanation_chart; fill_skin_listbox $::globals(tablet_styles_listbox); say [translate {settings}] $::settings(sound_button_in); set_next_page off "settings_1"; page_show off; } 0 0 641 188
add_de1_button "settings_1 settings_2 settings_2a settings_2b settings_2c settings_3 settings_4" {after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off $::settings(settings_profile_type); page_show off} 642 0 1277 188 
add_de1_button "settings_1 settings_2 settings_2a settings_2b settings_2c settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_3; page_show settings_3} 1278 0 1904 188
add_de1_button "settings_1 settings_2 settings_2a settings_2b settings_2c settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); fill_ble_listbox $::ble_listbox_widget; set_next_page off settings_4; page_show settings_4} 1905 0 2560 188

add_de1_button "settings_1 settings_2 settings_2a settings_2b settings_2c settings_3 settings_4" {say [translate {save}] $::settings(sound_button_in); save_settings; 
	if {$::settings(skin) != $::settings_backup(skin) } {
		.can itemconfigure $::message_label -text [translate "Please quit and restart this app to apply your changes."]
		set_next_page off message; page_show message
	} else {
		set_next_page off off; page_show off
	}
} 2016 1430 2560 1600
add_de1_button "settings_1 settings_2 settings_2a settings_2b settings_2c settings_3 settings_4" {unset -nocomplain ::settings; array set ::settings [array get ::settings_backup]; update_de1_explanation_chart; fill_ble_listbox $::globals(ble_listbox); fill_profiles_listbox $::globals(profiles_listbox); fill_skin_listbox $::globals(tablet_styles_listbox); say [translate {Cancel}] $::settings(sound_button_in); set_next_page off off; page_show off} 1505 1430 2015 1600


#add_de1_button "settings_3" {say [translate {water temperature}] $::settings(sound_button_in);vertical_clicker 1 1 ::settings(water_temperature) $::de1(water_min_temperature) $::de1(water_max_temperature) %x %y %x0 %y0 %x1 %y1} 2130 340 2500 820 ""

add_de1_widget "settings_3" scale 50 1200 {} -from 60 -to 99 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 1150] -width [rescale_y_skin 135] -variable ::settings(water_temperature) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
#add_de1_variable "settings_3" 310 1350 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}
add_de1_variable "settings_3" 50 1340 -text "" -font Helv_7 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Temperature:"] [return_temperature_measurement $::settings(water_temperature)]}



# END OF SETTINGS page
##############################################################################################################################################################################################################################################################################

proc setting_profile_type_to_text { in } {
	if {$in == "settings_2a"} {
		return [translate "PRESSURE PROFILE"]
	} elseif {$in == "settings_2b"} {
		return [translate "FLOW PROFILE"]
	} elseif {$in == "2c"} {
		return [translate "ADVANCED PROFILE"]
	} else {
		return [translate "PROFILE"]
	}
}