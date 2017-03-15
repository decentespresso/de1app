##############################################################################################################################################################################################################################################################################
# GENERIC DE1 SETTINGS page


##############################################################################################################################################################################################################################################################################
# the graphics for each of the main espresso machine modes
add_de1_page "settings_1" "[skin_directory_graphics]/settings_1.png"
add_de1_page "settings_1a" "[skin_directory_graphics]/settings_1a.png"
add_de1_page "settings_2" "[skin_directory_graphics]/settings_2.png"
add_de1_page "settings_3" "[skin_directory_graphics]/settings_3.png"
add_de1_page "settings_4" "[skin_directory_graphics]/settings_4.png"


##############################################################################################################################################################################################################################################################################

#add_de1_button "settings_1 settings_2 settings_3 settings_4" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 1424 350 1600


# 1st batch of settings
#add_de1_widget "settings_1" checkbutton 40 1325 {} -text [translate "Preinfusion"] -indicatoron true  -font Helv_15_bold -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(preinfusion_enabled) -command update_de1_explanation_chart -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_1" scale 47 850 {} -from 0 -to 10 -tickinterval 0  -showvalue 0 -background #e4d1c1  -bigincrement 1 -resolution 1 -length [rescale_x_skin 500] -width [rescale_y_skin 150] -variable ::settings(preinfusion_time) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart -foreground #000000 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 -orient horizontal 
add_de1_text "settings_1" 45 755 -text [translate "1: preinfuse"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
add_de1_variable "settings_1" 50 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(preinfusion_time) [translate "seconds"]}



#add_de1_variable "settings_1" 680 1325 -text [translate "Hold pressure"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" -width 600 -justify "left" -textvariable {[translate "Hold pressure:"] $::settings(espresso_pressure) [translate "bar"]}


add_de1_text "settings_1" 615 755 -text [translate "2: hold"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 


add_de1_widget "settings_1" scale 610 850 {} -to 1 -from 10 -tickinterval 0  -showvalue 0 -background #e4d1c1  -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 480] -width [rescale_y_skin 150] -variable ::settings(espresso_pressure) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart -foreground #000000 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_1" 685 1360 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -width 600 -justify "left" -textvariable {$::settings(espresso_pressure) [translate "bar"]}

add_de1_widget "settings_1" scale 790 850 {} -from 0 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0  -bigincrement 1 -resolution 1 -length [rescale_x_skin 740] -width [rescale_y_skin 150] -variable ::settings(pressure_hold_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
#add_de1_text "settings_1" 1250 980 -text [translate "Hold time"] -font Helv_15_bold -fill "#2d3046" -anchor "n" -width 380 -justify "center"
add_de1_variable "settings_1" 790 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(pressure_hold_time) [translate "seconds"]}

#add_de1_text "settings_1" 2010 980 -text [translate "Decline time"] -font Helv_15_bold -fill "#2d3046" -anchor "n" -width 980 -justify "center"

add_de1_text "settings_1" 1605 755 -text [translate "3: decline"] -font Helv_10_bold -fill "#7f879a" -anchor "nw" -width 600 -justify "left" 
add_de1_widget "settings_1" scale 1600 850 {} -from 0 -to 60 -background #e4d1c1 -borderwidth 1 -showvalue 0 -bigincrement 1 -resolution 1 -length [rescale_x_skin 735] -width [rescale_y_skin 150] -variable ::settings(espresso_decline_time) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_1" 1605 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "nw" -width 600 -justify "left" -textvariable {$::settings(espresso_decline_time) [translate "seconds"]}

add_de1_widget "settings_1" scale 2360 850 {} -to 0 -from 10 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 1 -resolution 0.1 -length [rescale_x_skin 480]  -width [rescale_y_skin 150] -variable ::settings(pressure_end) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command update_de1_explanation_chart -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_1" 2435 1360 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -width 600 -justify "left" -textvariable {$::settings(pressure_end) [translate "bar"]}

#add_de1_text "settings_1" 2495 1325 -text [translate "Final pressure"] -font Helv_15_bold -fill "#2d3046" -anchor "ne" -width 700 -justify "left"

add_de1_button "settings_1" {say [translate {temperature}] $::settings(sound_button_in);vertical_clicker 1 1 ::settings(espresso_temperature) 80 95 %x %y %x0 %y0 %x1 %y1} 2404 210 2550 665 ""


#add_de1_text "settings_1" 320 1090  -text [translate "TEMP"] -font Helv_8 -fill "#7f879a" -anchor "center" 
add_de1_variable "settings_1" 2460 690 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}

add_de1_widget "settings_1" graph 24 220 { 
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth quadratic -pixels [rescale_x_skin 20]; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max [expr { 0.4 + $::de1(max_pressure)}] -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12} -title [translate "pressure (bar)"] -titlefont Helv_10 -titlecolor #5a5d75;

	bind $widget [platform_button_press] { 
		say [translate {refresh chart}] $::settings(sound_button_in); 
		update_de1_explanation_chart} 
	} -plotbackground #EEEEEE -width [rescale_x_skin 2375] -height [rescale_y_skin 500] -borderwidth 1 -background #FFFFFF -plotrelief raised

add_de1_widget "settings_2" listbox 70 350 { 
	$widget insert 0 {9 bar} {8.4 bar} {6 bar}
	$widget itemconfigure 1 -foreground blue
	} -background #f7f6ff -font Helv_10_bold -bd 0 -height 8 -width 44 -foreground #b2bad0


add_de1_widget "settings_2" listbox 1330 340 { 
	fill_skin_listbox $widget
	} -background #f7f6ff -font Helv_10_bold -bd 0 -height 10 -width 44 -foreground #b2bad0

add_de1_text "settings_2" 2250 1020 -text [translate "Load"] -font Helv_10_bold -fill "#f9f9f9" -anchor "center"
add_de1_button "settings_2" {save_new_tablet_skin_setting} 1980 950 2520 1100


add_de1_widget "settings_2" graph 30 950 { 
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth quadratic -pixels [rescale_x_skin 20]; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max [expr { 0.4 + $::de1(max_pressure)}] -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12} -title "" -titlefont Helv_10 -titlecolor #5a5d75;
	} -plotbackground #EEEEEE -width [rescale_x_skin 1235] -height [rescale_y_skin 450] -borderwidth 1 -background #FFFFFF -plotrelief raised

set ::table_style_preview_image [add_de1_image "settings_2" 1330 960 "[skin_directory_graphics]/icon.jpg"]


#add_de1_widget "settings_4" checkbutton 90 500 {} -text [translate "Use fluid ounces"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_fluid_ounces)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
#add_de1_widget "settings_4" checkbutton 90 600 {} -text [translate "Enable flight mode"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(flight_mode_enable)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

#add_de1_widget "settings_4" scale 90 700 {} -from 1 -to 90 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length [rescale_x_skin 1100] -width [rescale_y_skin 135] -variable ::settings(flight_mode_angle) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
#add_de1_text "settings_4" 90 905 -text [translate "Flight mode: start angle"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

#add_de1_text "settings_4" 90 905 -text [translate "Flight mode: start angle"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"
add_de1_text "settings_4" 400 1300 -text [translate "Espresso"] -font Helv_10_bold -fill "#f9f9f9" -anchor "center"
add_de1_text "settings_4" 1000 1300 -text [translate "Steam"] -font Helv_10_bold -fill "#f9f9f9" -anchor "center"

add_de1_text "settings_4" 400 980 -text [translate "Update"] -font Helv_10_bold -fill "#f9f9f9" -anchor "center"
add_de1_text "settings_4" 1000 980 -text [translate "Reset"] -font Helv_10_bold -fill "#f9f9f9" -anchor "center"
add_de1_text "settings_4" 2270 980 -text [translate "Connect"] -font Helv_10_bold -fill "#f9f9f9" -anchor "center"

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

add_de1_widget "settings_4" entry 1340 380 {} -width [rescale_x_skin 60] -font Helv_15_bold -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(machine_name) 
add_de1_text "settings_4" 1350 470 -text [translate "Name your machine"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

add_de1_text "settings_4" 1320 240 -text [translate "Information"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 1350 600 -text [translate "Version: 1.0 beta 5"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"
add_de1_text "settings_4" 1350 660 -text [translate "Serial number: 0000001"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

add_de1_button "settings_3" {say [translate {awake time}] $::settings(sound_button_in);vertical_clicker 600 60 ::settings(alarm_wake) 0 86400 %x %y %x0 %y0 %x1 %y1} 1330 350 1650 700 ""
add_de1_text "settings_3" 1505 740 -text [translate "Power on"] -font Helv_9 -fill "#7f879a" -anchor "center" -width 800 -justify "center"
add_de1_variable "settings_3" 1505 805 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -textvariable {[format_alarm_time $::settings(alarm_wake)]}

add_de1_button "settings_3" {say [translate {sleep time}] $::settings(sound_button_in);vertical_clicker 600 60 ::settings(alarm_sleep) 0 86400 %x %y %x0 %y0 %x1 %y1} 1690 350 2010 700 ""
add_de1_text "settings_3" 1840 740 -text [translate "Power off"] -font Helv_9 -fill "#7f879a" -anchor "center" -width 800 -justify "center"
add_de1_variable "settings_3" 1840 805 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -textvariable {[format_alarm_time $::settings(alarm_sleep)]}

add_de1_text "settings_3" 1330 250 -text [translate "Timer"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 2130 250 -text [translate "Hot water"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 70 250 -text [translate "Brightness"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 70 570 -text [translate "Screen Saver"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 70 920 -text [translate "Measurements"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 70 1140 -text [translate "Clean"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 70 820 -text [translate "Firmware"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 1320 820 -text [translate "Connection"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"



add_de1_widget "settings_4" listbox 1320 900 { 
	$widget insert 0 " C1:80:A7:32:CD:A3" " C5:80:EC:A5:F9:72" " F2:C3:43:60:AB:F5"
	$widget itemconfigure 1 -foreground blue
	} -background #f7f6ff -font Helv_10_bold -bd 0 -height 8 -width 20 -foreground #b2bad0


#add_de1_text "settings_3" 1350 250 -text [translate "Speaking"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_widget "settings_3" scale 70 330 {} -from 0 -to 100 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 550] -width [rescale_y_skin 135] -variable ::settings(app_brightness) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_3" 70 470 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "App:"] $::settings(app_brightness)%}

add_de1_widget "settings_3" scale 670 330 {} -from 0 -to 100 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 550] -width [rescale_y_skin 135] -variable ::settings(saver_brightness) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_3" 670 470 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Screen saver:"] $::settings(saver_brightness)%}

add_de1_widget "settings_3" scale 70 650 {} -from 0 -to 120 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 550] -width [rescale_y_skin 135] -variable ::settings(screen_saver_delay) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_3" 70 790 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Start after:"] $::settings(screen_saver_delay) [translate "minutes"]}

add_de1_widget "settings_3" scale 670 650 {} -from 1 -to 120 -background #e4d1c1 -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 550] -width [rescale_y_skin 135] -variable ::settings(screen_saver_change_interval) -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_variable "settings_3" 670 790 -text "" -font Helv_8 -fill "#4e85f4" -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Change after:"] $::settings(screen_saver_change_interval) [translate "minutes"]}

#add_de1_widget "settings_3" checkbutton 1350 400 {} -text [translate "Enable spoken prompts"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_spoken_prompts)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_3" checkbutton 70 1000 {} -text [translate "Use Fahrenheit"] -indicatoron true  -font Helv_8 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_fahrenheit)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_3" checkbutton 500 1000 {} -text [translate "Use AM/PM"] -indicatoron true  -font Helv_8 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(enable_ampm)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_3" checkbutton 1330 1000 {} -text [translate "Enable"] -indicatoron true  -font Helv_8 -bg #FFFFFF -anchor nw -foreground #4e85f4 -variable ::settings(timer_enable)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

#add_de1_widget "settings_3" scale 1350 580 {} -from 0 -to 4 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1100] -width [rescale_y_skin 135] -variable ::settings(speaking_rate) -font Helv_10_bold -sliderlength [rescale_x_skin 75] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
#add_de1_text "settings_3" 1350 785 -text [translate "Speaking speed"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

#add_de1_widget "settings_3" scale 1350 840 {} -from 0 -to 3 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1100] -width [rescale_y_skin 135] -variable ::settings(speaking_pitch) -font Helv_10_bold -sliderlength [rescale_x_skin 75] -relief flat -orient horizontal -foreground #FFFFFF -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
#add_de1_text "settings_3" 1350 1045 -text [translate "Speaking pitch"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

#add_de1_button "off" {after 300 update_de1_explanation_chart;unset -nocomplain ::settings_backup; array set ::settings_backup [array get ::settings]; set_next_page off settings_1; page_show settings_1} 2000 0 2560 500
add_de1_text "settings_1 settings_2 settings_3 settings_4" 2275 1520 -text [translate "Ok"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"
add_de1_text "settings_1 settings_2 settings_3 settings_4" 1760 1520 -text [translate "Cancel"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"

add_de1_text "settings_2" 960 890 -text [translate "Load"] -font Helv_10_bold -fill "#f9f9f9" -anchor "center"
#add_de1_text "settings_1 settings_2 settings_3 settings_4" 1245 1520 -text [translate "Load"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"

# labels for PREHEAT tab on
add_de1_text "settings_1" 330 100 -text [translate "PRESSURE"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_1" 960 100 -text [translate "PRESETS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 1590 100 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 2215 100 -text [translate "MACHINE"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

########################################
# labels for WATER/STEAM tab on
add_de1_text "settings_2" 330 100 -text [translate "PRESSURE"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 960 100 -text [translate "PRESETS"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_2" 1590 100 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 2215 100 -text [translate "MACHINE"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

add_de1_button "settings_3" {say [translate {water temperature}] $::settings(sound_button_in);vertical_clicker 1 1 ::settings(water_temperature) $::de1(water_min_temperature) $::de1(water_max_temperature) %x %y %x0 %y0 %x1 %y1} 2130 340 2500 870 ""
add_de1_variable "settings_3" 2340 1000 -text "" -font Helv_10_bold -fill "#4e85f4" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}

#add_de1_button "settings_2" {say [translate {water time}] $::settings(sound_button_in);vertical_clicker 1 1 ::settings(water_max_time) $::de1(water_time_min) $::de1(water_time_max) %x %y %x0 %y0 %x1 %y1} 571 500 1250 1260 ""
#add_de1_variable "settings_2" 900 1320 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(water_max_time)] [translate "seconds"]}

#add_de1_button "settings_2" {say [translate {steam temperature}] $::settings(sound_button_in);vertical_clicker 1 1 ::settings(steam_temperature) $::de1(steam_min_temperature) $::de1(steam_max_temperature) %x %y %x0 %y0 %x1 %y1} 1330 680 1850 1260 ""
#add_de1_variable "settings_2" 1640 1320 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(steam_temperature)]}

#add_de1_button "settings_2" {say [translate {steam time}] $::settings(sound_button_in);vertical_clicker 1 1 ::settings(steam_max_time) $::de1(steam_time_min) $::de1(steam_time_max) %x %y %x0 %y0 %x1 %y1} 1851 500 2500 1260 ""
#add_de1_variable "settings_2" 2170 1320 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(steam_max_time)] [translate "seconds"]}

add_de1_text "settings_2" 70 240 -text [translate "Pressure profiles"] -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_2" 1330 240 -text [translate "Tablet styles"] -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"

########################################

# labels for STEAM tab on
add_de1_text "settings_3" 330 100 -text [translate "PRESSURE"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 960 100 -text [translate "PRESETS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 1590 100 -text [translate "OTHER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_3" 2215 100 -text [translate "MACHINE"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for HOT WATER tab on
add_de1_text "settings_4" 330 100 -text [translate "PRESSURE"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 960 100 -text [translate "PRESETS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 1590 100 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 2215 100 -text [translate "MACHINE"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "settings_1 settings_2 settings_3 settings_4" {after 300 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_1; page_show settings_1} 0 0 641 188
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_2; page_show settings_2} 642 0 1277 188
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_3; page_show settings_3} 1278 0 1904 188
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_4; page_show settings_4} 1905 0 2560 188

add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {save}] $::settings(sound_button_in); save_settings; set_next_page off off; page_show off} 2016 1430 2560 1600
add_de1_button "settings_1 settings_2 settings_3 settings_4" {unset -nocomplain ::settings; array set ::settings [array get ::settings_backup]; say [translate {cancel}] $::settings(sound_button_in); set_next_page off off; page_show off} 1505 1430 2015 1600

# END OF SETTINGS page
##############################################################################################################################################################################################################################################################################

