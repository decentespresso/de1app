set ::skindebug 0

#add_de1_variable "off" 15 898 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390  -textvariable {[accelerometer_angle_text]} 

##############################################################################################################################################################################################################################################################################
# SETTINGS page

# tapping the logo exits the app
add_de1_button "off" "exit" 600 0 1313 337 
add_de1_button "settings_1 settings_2 settings_3 settings_4" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 961 263 1080 


# 1st batch of settings
add_de1_widget "settings_1" checkbutton 30 526 {} -text [translate "Preinfusion"] -indicatoron true  -font Helv_15_bold -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(preinfusion_enabled) -command update_de1_explanation_chart -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_1" scale 420 553 {} -to 1 -from 10 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 337  -width 113  -variable ::settings(espresso_pressure) -font Helv_15_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 510 894 -text [translate "Hold pressure"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" -width 450  -justify "left"

add_de1_widget "settings_1" scale 638 506 {} -from 0 -to 60 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 540  -width 113  -variable ::settings(pressure_hold_time) -font Helv_10_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 938 661 -text [translate "Hold time"] -font Helv_15_bold -fill "#2d3046" -anchor "n" -width 285  -justify "center"

add_de1_widget "settings_1" scale 1275 506 {} -from 0 -to 60 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 540  -width 113  -variable ::settings(espresso_decline_time) -font Helv_10_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 1508 661 -text [translate "Decline time"] -font Helv_15_bold -fill "#2d3046" -anchor "n" -width 735  -justify "center"

add_de1_widget "settings_1" scale 1670 665 {} -to 0 -from 10 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 223   -width 113  -variable ::settings(pressure_end) -font Helv_15_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 1871 894 -text [translate "Final pressure"] -font Helv_15_bold -fill "#2d3046" -anchor "ne" -width 525  -justify "left"

add_de1_button "settings_1" {say [translate {temperature}] $::settings(sound_button_in);vertical_slider ::settings(espresso_temperature) 80 95 %x %y %x0 %y0 %x1 %y1} 0 580 338 945 "mousemove"
add_de1_text "settings_1" 240 736  -text [translate "TEMP"] -font Helv_8 -fill "#7f879a" -anchor "center" 
add_de1_variable "settings_1" 240 790 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}

add_de1_widget "settings_1" graph 18 148 { 
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth 8  -color #4e85f4  -smooth quadratic -pixels 15; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure) -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12} -title [translate "pressure (bar)"] -titlefont Helv_10;

	bind $widget [platform_button_press] { 
		say [translate {refresh chart}] $::settings(sound_button_in); 
		update_de1_explanation_chart} 
	} -plotbackground #EEEEEE -width 1875  -height 337  -borderwidth 1 -background #FFFFFF -plotrelief raised


add_de1_widget "settings_4" checkbutton 68 270 {} -text [translate "Use Fahrenheit"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_fahrenheit)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_4" checkbutton 68 337 {} -text [translate "Use fluid ounces"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_fluid_ounces)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_4" checkbutton 68 405 {} -text [translate "Enable flight mode"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(flight_mode_enable)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_4" scale 68 472 {} -from 1 -to 90 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 742  -width 101  -variable ::settings(flight_mode_angle) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_4" 68 611 -text [translate "Flight mode: start angle"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 600  -justify "left"

add_de1_text "settings_4" 68 611 -text [translate "Flight mode: start angle"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 600  -justify "left"
add_de1_text "settings_4" 233 882 -text [translate "Clean: steam"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"
add_de1_text "settings_4" 746 882 -text [translate "Clean: espresso"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"

# future clean steam feature
add_de1_button "settings_4" {} 23 814 443 949 
# future clean espresso feature
add_de1_button "settings_4" {} 525 814 945 949 


add_de1_text "settings_4" 68 169 -text [translate "Other settings"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_widget "settings_4" entry 1005 256 {} -width 45  -font Helv_15_bold -bg #FFFFFF  -foreground #2d3046 -textvariable ::settings(machine_name) 
add_de1_text "settings_4" 1013 317 -text [translate "Name your machine"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 600  -justify "left"

add_de1_text "settings_4" 1013 169 -text [translate "Information"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 1013 405 -text [translate "Version: 1.0 beta 4"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 600  -justify "left"
add_de1_text "settings_4" 1013 445 -text [translate "Serial number: 0000001"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 600  -justify "left"

add_de1_button "settings_4" {say [translate {awake time}] $::settings(sound_button_in);vertical_slider ::settings(alarm_wake) 0 86400 %x %y %x0 %y0 %x1 %y1} 998 540 1444 850 "mousemove"
add_de1_text "settings_4" 1275 823 -text [translate "Awake"] -font Helv_9 -fill "#2d3046" -anchor "center" -width 600  -justify "center"
add_de1_variable "settings_4" 1275 877 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[format_alarm_time $::settings(alarm_wake)]}

add_de1_button "settings_4" {say [translate {sleep time}] $::settings(sound_button_in);vertical_slider ::settings(alarm_sleep) 0 86400 %x %y %x0 %y0 %x1 %y1} 1444 540 1875 850 "mousemove"
add_de1_text "settings_4" 1613 823 -text [translate "Asleep"] -font Helv_9 -fill "#2d3046" -anchor "center" -width 600  -justify "center"
add_de1_variable "settings_4" 1613 877 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[format_alarm_time $::settings(alarm_sleep)]}

add_de1_text "settings_3" 68 169 -text [translate "Screen settings"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 1013 169 -text [translate "Speaking"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_widget "settings_3" scale 68 209 {} -from 0 -to 100 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 742  -width 101  -variable ::settings(app_brightness) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 68 354 -text [translate "App brightness"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 600  -justify "left"

add_de1_widget "settings_3" scale 68 391 {} -from 0 -to 100 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 742  -width 101  -variable ::settings(saver_brightness) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 68 530 -text [translate "Screen saver brightness"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 600  -justify "left"

add_de1_widget "settings_3" scale 68 567 {} -from 0 -to 120 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 742  -width 101  -variable ::settings(screen_saver_delay) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 68 705 -text [translate "Screen saver delay"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 600  -justify "left"

add_de1_widget "settings_3" scale 68 742 {} -from 1 -to 120 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 742  -width 101  -variable ::settings(screen_saver_change_interval) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 68 881 -text [translate "Screen saver change interval"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 600  -justify "left"

add_de1_widget "settings_3" checkbutton 1013 270 {} -text [translate "Enable spoken prompts"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_spoken_prompts)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_3" scale 1013 391 {} -from 0 -to 4 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length 742  -width 101  -variable ::settings(speaking_rate) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 1013 530 -text [translate "Speaking speed"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 600  -justify "left"

add_de1_widget "settings_3" scale 1013 567 {} -from 0 -to 3 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length 742  -width 101  -variable ::settings(speaking_pitch) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 1013 705 -text [translate "Speaking pitch"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 600  -justify "left"

add_de1_button "off" {after 300 update_de1_explanation_chart;unset -nocomplain ::settings_backup; array set ::settings_backup [array get ::settings]; set_next_page off settings_1; page_show settings_1} 1500 0 1920 337 
add_de1_text "settings_1 settings_2 settings_3 settings_4" 1706 1026 -text [translate "Save"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"
add_de1_text "settings_1 settings_2 settings_3 settings_4" 1320 1026 -text [translate "Cancel"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"

# labels for PREHEAT tab on
add_de1_text "settings_1" 248 67 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_1" 720 67 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 1193 67 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 1661 67 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

########################################
# labels for WATER/STEAM tab on
add_de1_text "settings_2" 248 67 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 720 67 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_2" 1193 67 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 1661 67 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

add_de1_button "settings_2" {say [translate {water temperature}] $::settings(sound_button_in);vertical_slider ::settings(water_temperature) $::de1(water_min_temperature) $::de1(water_max_temperature) %x %y %x0 %y0 %x1 %y1} 38 459 428 850 "mousemove"
add_de1_variable "settings_2" 285 891 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}

add_de1_button "settings_2" {say [translate {water time}] $::settings(sound_button_in);vertical_slider ::settings(water_max_time) $::de1(water_time_min) $::de1(water_time_max) %x %y %x0 %y0 %x1 %y1} 428 337 938 850 "mousemove"
add_de1_variable "settings_2" 675 891 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(water_max_time)] [translate "seconds"]}

add_de1_button "settings_2" {say [translate {steam temperature}] $::settings(sound_button_in);vertical_slider ::settings(steam_temperature) $::de1(steam_min_temperature) $::de1(steam_max_temperature) %x %y %x0 %y0 %x1 %y1} 998 459 1388 850 "mousemove"
add_de1_variable "settings_2" 1230 891 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(steam_temperature)]}

add_de1_button "settings_2" {say [translate {steam time}] $::settings(sound_button_in);vertical_slider ::settings(steam_max_time) $::de1(steam_time_min) $::de1(steam_time_max) %x %y %x0 %y0 %x1 %y1} 1388 337 1875 850 "mousemove"
add_de1_variable "settings_2" 1628 891 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(steam_max_time)] [translate "seconds"]}

add_de1_text "settings_2" 173 189 -text [translate "Hot water"] -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_2" 1133 189 -text [translate "Steam"] -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"

########################################

# labels for STEAM tab on
add_de1_text "settings_3" 248 67 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 720 67 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 1193 67 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_3" 1661 67 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for HOT WATER tab on
add_de1_text "settings_4" 248 67 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 720 67 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 1193 67 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 1661 67 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "settings_1 settings_2 settings_3 settings_4" {after 300 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_1; page_show settings_1} 0 0 481 127 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_2; page_show settings_2} 482 0 958 127 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_3; page_show settings_3} 959 0 1428 127 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_4; page_show settings_4} 1429 0 1920 127 

add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {save}] $::settings(sound_button_in); save_settings; set_next_page off off; page_show off} 1512 965 1920 1080 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {unset -nocomplain ::settings; array set ::settings [array get ::settings_backup]; say [translate {cancel}] $::settings(sound_button_in); set_next_page off off; page_show off} 1129 965 1511 1080 

# END OF SETTINGS page
##############################################################################################################################################################################################################################################################################



##############################################################################################################################################################################################################################################################################


##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it

add_de1_text "steam" 1536 726 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "steam" 1536 767 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

# variables to display during steam
add_de1_text "steam" 1540 794 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "steam" 1544 794 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390  -textvariable {[steam_timer][translate "s"]} 
add_de1_text "steam" 1540 828 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "steam" 1544 828 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "steam" 1540 861 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "steam" 1544 861 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390  -textvariable {[steamtemp_text]} 
#add_de1_text "steam" 1540 895 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 390 
#add_de1_variable "steam" 1544 895 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390  -textvariable {[pressure_text]} 


# 
#add_de1_action "steam" "do_steam"
# when it steam mode, tapping anywhere on the screen tells the DE1 to stop.
add_de1_button "steam" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 1920 1080 

# STEAM related info to display when the espresso machine is idle
add_de1_text "off" 1536 726 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1540 780 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "off" 1544 780 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 1540 814 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "off" 1544 814 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390  -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 1540 848 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 390  -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 1544 848 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390  -textvariable {[steam_heater_temperature_text]} 

# when someone taps on the steam button
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 1311 416 1760 954 

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it

add_de1_text "espresso" 960 726 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "espresso" 960 767 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

add_de1_text "espresso" 960 794 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "espresso" 964 794 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390  -textvariable {[pour_timer][translate "s"]} 

add_de1_text "espresso" 960 828 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "espresso" 964 828 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 390  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "espresso" 960 861 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "espresso" 964 861 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390  -textvariable {[pressure_text]} 

add_de1_text "espresso" 960 895 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "espresso" 964 895 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390  -textvariable {[watertemp_text]} 

add_de1_button "espresso" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 1920 1080 

#add_btn_screen "espresso" "stop"
#add_de1_action "espresso" "do_espresso"


add_de1_text "off" 960 726 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 956 780 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "off" 960 780 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 390  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "off" 956 814 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "off" 960 814 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390  -textvariable {[setting_espresso_pressure_text]} 


add_de1_text "off" 956 848 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "off" 960 848 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 390  -textvariable {[setting_espresso_temperature_text]} 

add_de1_variable "off" 956 882 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 390  -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 960 882 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390  -textvariable {[group_head_heater_temperature_text]} 

# we spell espresso with two SSs so that it is pronounced like Italians say it
add_de1_button "off" "say [translate {esspresso}] $::settings(sound_button_in);start_espresso" 711 394 1205 975 


#add_de1_text "espresso" 956 882 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 390 
#add_de1_variable "espresso" 960 882 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "" -fill "#2d3046" -width 390  -textvariable {[waterflow_text]} 

##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
add_de1_text "water" 383 726 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "water" 383 767 -text "" -font Helv_9_bold -fill "#73768f" -anchor "center" -textvariable {[translate [de1_substate_text]]} 

add_de1_text "water" 375 794 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "water" 379 794 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390  -text "" -textvariable {[water_timer][translate "s"]} 
add_de1_text "water" 375 828 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "water" 379 828 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390  -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "water" 375 861 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "water" 379 861 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390  -text "" -textvariable {[watertemp_text]} 

add_de1_button "water" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 1920 1080 




add_de1_text "off" 383 726 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 375 780 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "off" 379 780 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390  -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 375 814 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 390 
add_de1_variable "off" 379 814 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390  -text "" -textvariable {[setting_water_temperature_text]} 

#add_de1_text "water" 1540 848 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 390 
#add_de1_variable "water" 1544 848 -justify left -anchor "nw"  -font Helv_8 -fill "#42465c" -width 390  -text "" -textvariable {[waterflow_text]} 
#add_de1_text "water" 1540 882 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 390 
#add_de1_variable "water" 1544 882 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390  -text "" -textvariable {[watervolume_text]} 
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 158 413 606 956 
#add_btn_screen "water" "stop"
#add_de1_action "water" "start_water"

##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
#add_de1_action "off" "stop"

# tapping the power button tells the DE1 to go to sleep, and it will after a few seconds, at which point we display the screen saver
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 300 270 

add_de1_button "saver" "say [translate {awake}] $::settings(sound_button_in);start_idle" 0 0 1920 1080 

add_de1_text "sleep" 1875 979 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_button "sleep" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 1920 1080 
#add_de1_action "sleep" "do_sleep"

add_de1_action "exit" "app_exit"


# Sleeping cafe photo obtained under creative commons from https://www.flickr.com/photos/curious_e/16300930781/

# turn the screen saver or splash screen off by tapping the page

#add_btn_screen "saver" "off"
#add_btn_screen "splash" "off"

# the SETTINGS button currently exits the app
#add_de1_button "off" "app_exit" 1650 0 1950 270 
#add_de1_action "settings" "do_settings"

