set ::skindebug 0

#add_de1_variable "off" 10 665 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[accelerometer_angle_text]} 

##############################################################################################################################################################################################################################################################################
# SETTINGS page

# tapping the logo exits the app
add_de1_button "off" "exit" 400 0 875 250 
add_de1_button "settings_1 settings_2 settings_3 settings_4" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 712 175 800 


# 1st batch of settings
add_de1_widget "settings_1" checkbutton 20 390 {} -text [translate "Preinfusion"] -indicatoron true  -font Helv_15_bold -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(preinfusion_enabled) -command update_de1_explanation_chart -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_1" scale 280 410 {} -to 1 -from 10 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 250  -width 75  -variable ::settings(espresso_pressure) -font Helv_15_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 340 662 -text [translate "Hold pressure"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" -width 300  -justify "left"

add_de1_widget "settings_1" scale 425 375 {} -from 0 -to 60 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 400  -width 75  -variable ::settings(pressure_hold_time) -font Helv_10_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 625 490 -text [translate "Hold time"] -font Helv_15_bold -fill "#2d3046" -anchor "n" -width 190  -justify "center"

add_de1_widget "settings_1" scale 850 375 {} -from 0 -to 60 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 400  -width 75  -variable ::settings(espresso_decline_time) -font Helv_10_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 1005 490 -text [translate "Decline time"] -font Helv_15_bold -fill "#2d3046" -anchor "n" -width 490  -justify "center"

add_de1_widget "settings_1" scale 1113 492 {} -to 0 -from 10 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 165   -width 75  -variable ::settings(pressure_end) -font Helv_15_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 1247 662 -text [translate "Final pressure"] -font Helv_15_bold -fill "#2d3046" -anchor "ne" -width 350  -justify "left"

add_de1_button "settings_1" {say [translate {temperature}] $::settings(sound_button_in);vertical_slider ::settings(espresso_temperature) 80 95 %x %y %x0 %y0 %x1 %y1} 0 430 225 700 "mousemove"
add_de1_text "settings_1" 160 545  -text [translate "TEMP"] -font Helv_8 -fill "#7f879a" -anchor "center" 
add_de1_variable "settings_1" 160 585 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}

add_de1_widget "settings_1" graph 12 110 { 
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth 5  -color #4e85f4  -smooth quadratic -pixels 15; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure) -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12} -title [translate "pressure (bar)"] -titlefont Helv_10;

	bind $widget [platform_button_press] { 
		say [translate {refresh chart}] $::settings(sound_button_in); 
		update_de1_explanation_chart} 
	} -plotbackground #EEEEEE -width 1250  -height 250  -borderwidth 1 -background #FFFFFF -plotrelief raised


add_de1_widget "settings_4" checkbutton 45 200 {} -text [translate "Use Fahrenheit"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_fahrenheit)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_4" checkbutton 45 250 {} -text [translate "Use fluid ounces"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_fluid_ounces)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_4" checkbutton 45 300 {} -text [translate "Enable flight mode"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(flight_mode_enable)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_4" scale 45 350 {} -from 1 -to 90 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 550  -width 67  -variable ::settings(flight_mode_angle) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_4" 45 452 -text [translate "Flight mode: start angle"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_text "settings_4" 45 452 -text [translate "Flight mode: start angle"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"
add_de1_text "settings_4" 155 653 -text [translate "Clean: steam"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"
add_de1_text "settings_4" 497 653 -text [translate "Clean: espresso"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"

# future clean steam feature
add_de1_button "settings_4" {} 15 603 295 703 
# future clean espresso feature
add_de1_button "settings_4" {} 350 603 630 703 


add_de1_text "settings_4" 45 125 -text [translate "Other settings"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_widget "settings_4" entry 670 190 {} -width 30  -font Helv_15_bold -bg #FFFFFF  -foreground #2d3046 -textvariable ::settings(machine_name) 
add_de1_text "settings_4" 675 235 -text [translate "Name your machine"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_text "settings_4" 675 125 -text [translate "Information"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 675 300 -text [translate "Version: 1.0 beta 4"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"
add_de1_text "settings_4" 675 330 -text [translate "Serial number: 0000001"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_button "settings_4" {say [translate {awake time}] $::settings(sound_button_in);vertical_slider ::settings(alarm_wake) 0 86400 %x %y %x0 %y0 %x1 %y1} 665 400 962 630 "mousemove"
add_de1_text "settings_4" 850 610 -text [translate "Awake"] -font Helv_9 -fill "#2d3046" -anchor "center" -width 400  -justify "center"
add_de1_variable "settings_4" 850 650 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[format_alarm_time $::settings(alarm_wake)]}

add_de1_button "settings_4" {say [translate {sleep time}] $::settings(sound_button_in);vertical_slider ::settings(alarm_sleep) 0 86400 %x %y %x0 %y0 %x1 %y1} 962 400 1250 630 "mousemove"
add_de1_text "settings_4" 1075 610 -text [translate "Asleep"] -font Helv_9 -fill "#2d3046" -anchor "center" -width 400  -justify "center"
add_de1_variable "settings_4" 1075 650 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[format_alarm_time $::settings(alarm_sleep)]}

add_de1_text "settings_3" 45 125 -text [translate "Screen settings"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 675 125 -text [translate "Speaking"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_widget "settings_3" scale 45 155 {} -from 0 -to 100 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 550  -width 67  -variable ::settings(app_brightness) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 45 262 -text [translate "App brightness"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_widget "settings_3" scale 45 290 {} -from 0 -to 100 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 550  -width 67  -variable ::settings(saver_brightness) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 45 392 -text [translate "Screen saver brightness"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_widget "settings_3" scale 45 420 {} -from 0 -to 120 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 550  -width 67  -variable ::settings(screen_saver_delay) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 45 522 -text [translate "Screen saver delay"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_widget "settings_3" scale 45 550 {} -from 1 -to 120 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 550  -width 67  -variable ::settings(screen_saver_change_interval) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 45 652 -text [translate "Screen saver change interval"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_widget "settings_3" checkbutton 675 200 {} -text [translate "Enable spoken prompts"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_spoken_prompts)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_3" scale 675 290 {} -from 0 -to 4 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length 550  -width 67  -variable ::settings(speaking_rate) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 675 392 -text [translate "Speaking speed"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_widget "settings_3" scale 675 420 {} -from 0 -to 3 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length 550  -width 67  -variable ::settings(speaking_pitch) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 675 522 -text [translate "Speaking pitch"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_button "off" {after 300 update_de1_explanation_chart;unset -nocomplain ::settings_backup; array set ::settings_backup [array get ::settings]; set_next_page off settings_1; page_show settings_1} 1000 0 1280 250 
add_de1_text "settings_1 settings_2 settings_3 settings_4" 1137 760 -text [translate "Save"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"
add_de1_text "settings_1 settings_2 settings_3 settings_4" 880 760 -text [translate "Cancel"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"

# labels for PREHEAT tab on
add_de1_text "settings_1" 165 50 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_1" 480 50 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 795 50 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 1107 50 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

########################################
# labels for WATER/STEAM tab on
add_de1_text "settings_2" 165 50 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 480 50 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_2" 795 50 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 1107 50 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

add_de1_button "settings_2" {say [translate {water temperature}] $::settings(sound_button_in);vertical_slider ::settings(water_temperature) $::de1(water_min_temperature) $::de1(water_max_temperature) %x %y %x0 %y0 %x1 %y1} 25 340 285 630 "mousemove"
add_de1_variable "settings_2" 190 660 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}

add_de1_button "settings_2" {say [translate {water time}] $::settings(sound_button_in);vertical_slider ::settings(water_max_time) $::de1(water_time_min) $::de1(water_time_max) %x %y %x0 %y0 %x1 %y1} 285 250 625 630 "mousemove"
add_de1_variable "settings_2" 450 660 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(water_max_time)] [translate "seconds"]}

add_de1_button "settings_2" {say [translate {steam temperature}] $::settings(sound_button_in);vertical_slider ::settings(steam_temperature) $::de1(steam_min_temperature) $::de1(steam_max_temperature) %x %y %x0 %y0 %x1 %y1} 665 340 925 630 "mousemove"
add_de1_variable "settings_2" 820 660 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(steam_temperature)]}

add_de1_button "settings_2" {say [translate {steam time}] $::settings(sound_button_in);vertical_slider ::settings(steam_max_time) $::de1(steam_time_min) $::de1(steam_time_max) %x %y %x0 %y0 %x1 %y1} 925 250 1250 630 "mousemove"
add_de1_variable "settings_2" 1085 660 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(steam_max_time)] [translate "seconds"]}

add_de1_text "settings_2" 115 140 -text [translate "Hot water"] -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_2" 755 140 -text [translate "Steam"] -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"

########################################

# labels for STEAM tab on
add_de1_text "settings_3" 165 50 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 480 50 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 795 50 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_3" 1107 50 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for HOT WATER tab on
add_de1_text "settings_4" 165 50 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 480 50 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 795 50 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 1107 50 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "settings_1 settings_2 settings_3 settings_4" {after 300 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_1; page_show settings_1} 0 0 320 94 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_2; page_show settings_2} 321 0 638 94 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_3; page_show settings_3} 639 0 952 94 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_4; page_show settings_4} 952 0 1280 94 

add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {save}] $::settings(sound_button_in); save_settings; set_next_page off off; page_show off} 1008 715 1280 800 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {unset -nocomplain ::settings; array set ::settings [array get ::settings_backup]; say [translate {cancel}] $::settings(sound_button_in); set_next_page off off; page_show off} 752 715 1007 800 

# END OF SETTINGS page
##############################################################################################################################################################################################################################################################################



##############################################################################################################################################################################################################################################################################


##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it

add_de1_text "steam" 1024 538 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "steam" 1024 568 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

# variables to display during steam
add_de1_text "steam" 1026 588 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 588 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[steam_timer][translate "s"]} 
add_de1_text "steam" 1026 613 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 613 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "steam" 1026 638 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 638 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[steamtemp_text]} 
#add_de1_text "steam" 1026 663 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "steam" 1029 663 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[pressure_text]} 


# 
#add_de1_action "steam" "do_steam"
# when it steam mode, tapping anywhere on the screen tells the DE1 to stop.
add_de1_button "steam" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 1280 800 

# STEAM related info to display when the espresso machine is idle
add_de1_text "off" 1024 538 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1026 578 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 1029 578 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 1026 603 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 1029 603 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 1026 628 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 260  -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 1029 628 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[steam_heater_temperature_text]} 

# when someone taps on the steam button
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 874 308 1173 707 

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it

add_de1_text "espresso" 640 538 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "espresso" 640 568 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

add_de1_text "espresso" 640 588 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 642 588 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[pour_timer][translate "s"]} 

add_de1_text "espresso" 640 613 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 642 613 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "espresso" 640 638 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 642 638 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[pressure_text]} 

add_de1_text "espresso" 640 663 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 642 663 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[watertemp_text]} 

add_de1_button "espresso" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 1280 800 

#add_btn_screen "espresso" "stop"
#add_de1_action "espresso" "do_espresso"


add_de1_text "off" 640 538 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 637 578 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 578 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "off" 637 603 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 603 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[setting_espresso_pressure_text]} 


add_de1_text "off" 637 628 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 628 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_temperature_text]} 

add_de1_variable "off" 637 653 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 260  -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 640 653 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[group_head_heater_temperature_text]} 

# we spell espresso with two SSs so that it is pronounced like Italians say it
add_de1_button "off" "say [translate {esspresso}] $::settings(sound_button_in);start_espresso" 474 292 803 722 


#add_de1_text "espresso" 637 653 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "espresso" 640 653 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "" -fill "#2d3046" -width 260  -textvariable {[waterflow_text]} 

##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
add_de1_text "water" 255 538 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "water" 255 568 -text "" -font Helv_9_bold -fill "#73768f" -anchor "center" -textvariable {[translate [de1_substate_text]]} 

add_de1_text "water" 250 588 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "water" 252 588 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[water_timer][translate "s"]} 
add_de1_text "water" 250 613 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "water" 252 613 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "water" 250 638 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "water" 252 638 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[watertemp_text]} 

add_de1_button "water" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 1280 800 




add_de1_text "off" 255 538 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 250 578 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 252 578 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 250 603 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 252 603 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[setting_water_temperature_text]} 

#add_de1_text "water" 1026 628 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "water" 1029 628 -justify left -anchor "nw"  -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[waterflow_text]} 
#add_de1_text "water" 1026 653 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "water" 1029 653 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[watervolume_text]} 
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 105 306 404 708 
#add_btn_screen "water" "stop"
#add_de1_action "water" "start_water"

##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
#add_de1_action "off" "stop"

# tapping the power button tells the DE1 to go to sleep, and it will after a few seconds, at which point we display the screen saver
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 200 200 

add_de1_button "saver" "say [translate {awake}] $::settings(sound_button_in);start_idle" 0 0 1280 800 

add_de1_text "sleep" 1250 725 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_button "sleep" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 1280 800 
#add_de1_action "sleep" "do_sleep"

add_de1_action "exit" "app_exit"


# Sleeping cafe photo obtained under creative commons from https://www.flickr.com/photos/curious_e/16300930781/

# turn the screen saver or splash screen off by tapping the page

#add_btn_screen "saver" "off"
#add_btn_screen "splash" "off"

# the SETTINGS button currently exits the app
#add_de1_button "off" "app_exit" 1100 0 1300 200 
#add_de1_action "settings" "do_settings"

