set ::skindebug 0

#add_de1_variable "off" 20 1330 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[accelerometer_angle_text]} 

##############################################################################################################################################################################################################################################################################
# SETTINGS page

# tapping the logo exits the app
add_de1_button "off" "exit" 800 0 1750 500


# 1st batch of settings
add_de1_widget "settings_1" checkbutton 40 780 {} -text [translate "Preinfusion"] -indicatoron true  -font Helv_15_bold -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(preinfusion_enabled) -command update_de1_explanation_chart -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_1" scale 560 820 {} -to 1 -from 10 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 500 -width 150 -variable ::settings(espresso_pressure) -font Helv_15_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 680 1325 -text [translate "Hold pressure"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" -width 600 -justify "left"

add_de1_widget "settings_1" scale 850 750 {} -from 0 -to 60 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 800 -width 150 -variable ::settings(pressure_hold_time) -font Helv_10_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 1250 980 -text [translate "Hold time"] -font Helv_15_bold -fill "#2d3046" -anchor "n" -width 380 -justify "center"

add_de1_widget "settings_1" scale 1700 750 {} -from 0 -to 60 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 800 -width 150 -variable ::settings(espresso_decline_time) -font Helv_10_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 2010 980 -text [translate "Decline time"] -font Helv_15_bold -fill "#2d3046" -anchor "n" -width 980 -justify "center"

add_de1_widget "settings_1" scale 2226 985 {} -to 0 -from 10 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 330  -width 150 -variable ::settings(pressure_end) -font Helv_15_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 2495 1325 -text [translate "Final pressure"] -font Helv_15_bold -fill "#2d3046" -anchor "ne" -width 700 -justify "left"

add_de1_button "settings_1" {say [translate {temperature}] $::settings(sound_button_in);vertical_slider ::settings(espresso_temperature) 80 95 %x %y %x0 %y0 %x1 %y1} 0 860 450 1400 "mousemove"
add_de1_text "settings_1" 320 1090  -text [translate "TEMP"] -font Helv_8 -fill "#7f879a" -anchor "center" 
add_de1_variable "settings_1" 320 1170 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}

add_de1_widget "settings_1" graph 24 220 { 
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth 10 -color #4e85f4  -smooth quadratic -pixels 15; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure) -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12} -title [translate "pressure (bar)"] -titlefont Helv_10;

	bind $widget [platform_button_press] { 
		say [translate {refresh chart}] $::settings(sound_button_out); 
		update_de1_explanation_chart} 
	} -plotbackground #EEEEEE -width 2500 -height 500 -borderwidth 1 -background #FFFFFF -plotrelief raised


add_de1_widget "settings_4" checkbutton 90 400 {} -text [translate "Use Fahrenheit"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_fahrenheit)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_4" checkbutton 90 600 {} -text [translate "Use fluid ounces"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_fluid_ounces)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_4" checkbutton 90 800 {} -text [translate "Enable flight mode"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(flight_mode_enable)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_4" scale 90 900 {} -from 1 -to 90 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 1100 -width 135 -variable ::settings(flight_mode_angle) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_4" 90 1105 -text [translate "Flight mode: start angle"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

add_de1_text "settings_4" 90 250 -text [translate "Other settings"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_widget "settings_4" entry 1340 380 {} -width 60 -font Helv_15_bold -bg #FFFFFF  -foreground #2d3046 -textvariable ::settings(machine_name) 
add_de1_text "settings_4" 1350 470 -text [translate "Name your machine"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

add_de1_text "settings_4" 1350 250 -text [translate "Information"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 1350 600 -text [translate "Version: 1.0 beta 4"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"
add_de1_text "settings_4" 1350 660 -text [translate "Serial number: 0000001"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

#add_de1_text "settings_4" 310 400 -text [translate "Wifi"] -font Helv_10_bold -fill "#2d3046" -anchor "left" -width 400 -justify "left"




add_de1_text "settings_3" 90 250 -text [translate "Screen settings"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 1350 250 -text [translate "Speaking"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_widget "settings_3" scale 90 310 {} -from 0 -to 100 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 1100 -width 135 -variable ::settings(app_brightness) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 90 525 -text [translate "App brightness"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

add_de1_widget "settings_3" scale 90 580 {} -from 0 -to 100 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 1100 -width 135 -variable ::settings(saver_brightness) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 90 785 -text [translate "Screen saver brightness"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

add_de1_widget "settings_3" scale 90 840 {} -from 0 -to 120 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 1100 -width 135 -variable ::settings(screen_saver_delay) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 90 1045 -text [translate "Screen saver delay"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

add_de1_widget "settings_3" scale 90 1100 {} -from 1 -to 120 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 1100 -width 135 -variable ::settings(screen_saver_change_interval) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 90 1305 -text [translate "Screen saver change interval"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

add_de1_widget "settings_3" checkbutton 1350 400 {} -text [translate "Enable spoken prompts"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_spoken_prompts)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_3" scale 1350 580 {} -from 0 -to 4 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length 1100 -width 135 -variable ::settings(speaking_rate) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 1350 785 -text [translate "Speaking speed"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

add_de1_widget "settings_3" scale 1350 840 {} -from 0 -to 3 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length 1100 -width 135 -variable ::settings(speaking_pitch) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 1350 1045 -text [translate "Speaking pitch"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800 -justify "left"

#add_de1_text "settings_3" 1350 500 -text [translate "Tick sound"] -font Helv_10_bold -fill "#2d3046" -anchor "nw" -width 800 -justify "left"
#add_de1_text "settings_3" 1350 600 -text [translate "Tock sound"] -font Helv_10_bold -fill "#2d3046" -anchor "nw" -width 800 -justify "left"



add_de1_button "off" "after 300 update_de1_explanation_chart;set_next_page off settings_1; page_show settings_1" 2000 0 2560 500
add_de1_text "settings_1 settings_2 settings_3 settings_4" 2275 1520 -text [translate "Save"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"
add_de1_text "settings_1 settings_2 settings_3 settings_4" 1760 1520 -text [translate "Cancel"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"



# labels for PREHEAT tab on
add_de1_text "settings_1" 330 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_1" 960 100 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 1590 100 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 2215 100 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

########################################
# labels for WATER/STEAM tab on
add_de1_text "settings_2" 330 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 960 100 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_2" 1590 100 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 2215 100 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

add_de1_button "settings_2" {say [translate {water temperature}] $::settings(sound_button_in);vertical_slider ::settings(water_temperature) $::de1(water_min_temperature) $::de1(water_max_temperature) %x %y %x0 %y0 %x1 %y1} 50 680 570 1260 "mousemove"
add_de1_variable "settings_2" 380 1320 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}

add_de1_button "settings_2" {say [translate {water time}] $::settings(sound_button_in);vertical_slider ::settings(water_max_time) $::de1(water_time_min) $::de1(water_time_max) %x %y %x0 %y0 %x1 %y1} 571 500 1250 1260 "mousemove"
add_de1_variable "settings_2" 900 1320 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(water_max_time)] [translate "seconds"]}

add_de1_button "settings_2" {say [translate {steam temperature}] $::settings(sound_button_in);vertical_slider ::settings(steam_temperature) $::de1(steam_min_temperature) $::de1(steam_max_temperature) %x %y %x0 %y0 %x1 %y1} 1330 680 1850 1260 "mousemove"
add_de1_variable "settings_2" 1640 1320 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(steam_temperature)]}

add_de1_button "settings_2" {say [translate {steam time}] $::settings(sound_button_in);vertical_slider ::settings(steam_max_time) $::de1(steam_time_min) $::de1(steam_time_max) %x %y %x0 %y0 %x1 %y1} 1851 500 2500 1260 "mousemove"
add_de1_variable "settings_2" 2170 1320 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(steam_max_time)] [translate "seconds"]}

add_de1_text "settings_2" 230 280 -text [translate "Hot water"] -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_2" 1510 280 -text [translate "Steam"] -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"


########################################

# labels for STEAM tab on
add_de1_text "settings_3" 330 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 960 100 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 1590 100 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_3" 2215 100 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for HOT WATER tab on
add_de1_text "settings_4" 330 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 960 100 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 1590 100 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 2215 100 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "settings_1 settings_2 settings_3 settings_4" {after 300 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_1; page_show settings_1} 0 0 641 188
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_2; page_show settings_2} 642 0 1277 188
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_3; page_show settings_3} 1278 0 1904 188
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_4; page_show settings_4} 1905 0 2560 188

add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {save}] $::settings(sound_button_out); save_settings; set_next_page off off; page_show off} 2016 1430 2560 1600
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {cancel}] $::settings(sound_button_out); set_next_page off off; page_show off} 1505 1430 2015 1600



##############################################################################################################################################################################################################################################################################


##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it

add_de1_text "steam" 2048 1076 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "steam" 2048 1136 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

# variables to display during steam
add_de1_text "steam" 2053 1176 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 2058 1176 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[steam_timer][translate "s"]} 
add_de1_text "steam" 2053 1226 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 2058 1226 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[setting_steam_max_time_text]} 
add_de1_text "steam" 2053 1276 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 2058 1276 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[steamtemp_text]} 
#add_de1_text "steam" 2053 1326 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
#add_de1_variable "steam" 2058 1326 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[pressure_text]} 


# 
#add_de1_action "steam" "do_steam"
# when it steam mode, tapping anywhere on the screen tells the DE1 to stop.
add_de1_button "steam" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 2560 1600

# STEAM related info to display when the espresso machine is idle
add_de1_text "off" 2048 1076 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 2053 1156 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 2058 1156 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 2053 1206 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 2058 1206 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 2053 1256 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 520 -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 2058 1256 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[steam_heater_temperature_text]} 

# when someone taps on the steam button
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 1748 616 2346 1414

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it

add_de1_text "espresso" 1280 1076 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "espresso" 1280 1136 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

add_de1_text "espresso" 1280 1176 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 1285 1176 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[pour_timer][translate "s"]} 

add_de1_text "espresso" 1280 1226 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 1285 1226 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520 -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "espresso" 1280 1276 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 1285 1276 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[pressure_text]} 

add_de1_text "espresso" 1280 1326 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 1285 1326 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[watertemp_text]} 

add_de1_button "espresso" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 2560 1600

#add_btn_screen "espresso" "stop"
#add_de1_action "espresso" "do_espresso"


add_de1_text "off" 1280 1076 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1275 1156 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 1280 1156 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520 -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "off" 1275 1206 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 1280 1206 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[setting_espresso_pressure_text]} 


add_de1_text "off" 1275 1256 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 1280 1256 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520 -textvariable {[setting_espresso_temperature_text]} 

add_de1_variable "off" 1275 1306 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 520 -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 1280 1306 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[group_head_heater_temperature_text]} 

# we spell espresso with two SSs so that it is pronounced like Italians say it
add_de1_button "off" "say [translate {esspresso}] $::settings(sound_button_in);start_espresso" 948 584 1606 1444


#add_de1_text "espresso" 1275 1306 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 520
#add_de1_variable "espresso" 1280 1306 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "" -fill "#2d3046" -width 520 -textvariable {[waterflow_text]} 

##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
add_de1_text "water" 510 1076 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "water" 510 1136 -text "" -font Helv_9_bold -fill "#73768f" -anchor "center" -textvariable {[translate [de1_substate_text]]} 

add_de1_text "water" 500 1176 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 505 1176 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520 -text "" -textvariable {[water_timer][translate "s"]} 
add_de1_text "water" 500 1226 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 505 1226 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520 -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "water" 500 1276 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 505 1276 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520 -text "" -textvariable {[watertemp_text]} 

add_de1_button "water" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 2560 1600




add_de1_text "off" 510 1076 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 500 1156 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 505 1156 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520 -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 500 1206 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 505 1206 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520 -text "" -textvariable {[setting_water_temperature_text]} 

#add_de1_text "water" 2053 1256 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 520
#add_de1_variable "water" 2058 1256 -justify left -anchor "nw"  -font Helv_8 -fill "#42465c" -width 520 -text "" -textvariable {[waterflow_text]} 
#add_de1_text "water" 2053 1306 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 520
#add_de1_variable "water" 2058 1306 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520 -text "" -textvariable {[watervolume_text]} 
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 210 612 808 1416
#add_btn_screen "water" "stop"
#add_de1_action "water" "start_water"

##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
#add_de1_action "off" "stop"

# tapping the power button tells the DE1 to go to sleep, and it will after a few seconds, at which point we display the screen saver
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 400 400
add_de1_button "settings_1 settings_2 settings_3 settings_4" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 1424 350 1600

add_de1_button "saver" "say [translate {awake}] $::settings(sound_button_in);start_idle" 0 0 2560 1600

add_de1_text "sleep" 2500 1450 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_button "sleep" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 2560 1600
#add_de1_action "sleep" "do_sleep"

add_de1_action "exit" "app_exit"


# Sleeping cafe photo obtained under creative commons from https://www.flickr.com/photos/curious_e/16300930781/

# turn the screen saver or splash screen off by tapping the page

#add_btn_screen "saver" "off"
#add_btn_screen "splash" "off"

# the SETTINGS button currently exits the app
#add_de1_button "off" "app_exit" 2200 0 2600 400
#add_de1_action "settings" "do_settings"
