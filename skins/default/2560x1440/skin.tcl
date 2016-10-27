set ::skindebug 0

#add_de1_variable "off" 20 1197.001197001197 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520  -textvariable {[accelerometer_angle_text]} 

##############################################################################################################################################################################################################################################################################
# SETTINGS page

# tapping the logo exits the app
add_de1_button "off" "exit" 800 0.0 1750 450.00045000045 


# 1st batch of settings
add_de1_widget "settings_1" checkbutton 40 702.000702000702 {} -text [translate "Preinfusion"] -indicatoron true  -font Helv_15_bold -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(preinfusion_enabled) -command update_de1_explanation_chart -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_1" scale 560 738.000738000738 {} -to 1 -from 10 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 450.00045000045  -width 150  -variable ::settings(espresso_pressure) -font Helv_15_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 680 1192.5011925011925 -text [translate "Hold pressure"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" -width 600  -justify "left"

add_de1_widget "settings_1" scale 850 675.000675000675 {} -from 0 -to 60 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 720.00072000072  -width 150  -variable ::settings(pressure_hold_time) -font Helv_10_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 1250 882.0008820008819 -text [translate "Hold time"] -font Helv_15_bold -fill "#2d3046" -anchor "n" -width 380  -justify "center"

add_de1_widget "settings_1" scale 1700 675.000675000675 {} -from 0 -to 60 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 720.00072000072  -width 150  -variable ::settings(espresso_decline_time) -font Helv_10_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 2010 882.0008820008819 -text [translate "Decline time"] -font Helv_15_bold -fill "#2d3046" -anchor "n" -width 980  -justify "center"

add_de1_widget "settings_1" scale 2226 886.5008865008865 {} -to 0 -from 10 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 297.000297000297   -width 150  -variable ::settings(pressure_end) -font Helv_15_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_1" 2495 1192.5011925011925 -text [translate "Final pressure"] -font Helv_15_bold -fill "#2d3046" -anchor "ne" -width 700  -justify "left"

add_de1_button "settings_1" {say [translate {temperature}] $::settings(sound_button_in);vertical_slider ::settings(espresso_temperature) 80 95 %x %y %x0 %y0 %x1 %y1} 0 774.000774000774 450 1260.0012600012599 "mousemove"
add_de1_text "settings_1" 320 981.0009810009809  -text [translate "TEMP"] -font Helv_8 -fill "#7f879a" -anchor "center" 
add_de1_variable "settings_1" 320 1053.001053001053 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}

add_de1_widget "settings_1" graph 24 198.000198000198 { 
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth 10  -color #4e85f4  -smooth quadratic -pixels 15; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure) -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12} -title [translate "pressure (bar)"] -titlefont Helv_10;

	bind $widget [platform_button_press] { 
		say [translate {refresh chart}] $::settings(sound_button_in); 
		update_de1_explanation_chart} 
	} -plotbackground #EEEEEE -width 2500  -height 450.00045000045  -borderwidth 1 -background #FFFFFF -plotrelief raised


add_de1_widget "settings_4" checkbutton 90 360.00036000036 {} -text [translate "Use Fahrenheit"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_fahrenheit)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_4" checkbutton 90 540.00054000054 {} -text [translate "Use fluid ounces"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_fluid_ounces)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
add_de1_widget "settings_4" checkbutton 90 720.00072000072 {} -text [translate "Enable flight mode"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(flight_mode_enable)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_4" scale 90 810.00081000081 {} -from 1 -to 90 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 990.00099000099  -width 135  -variable ::settings(flight_mode_angle) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_4" 90 994.5009945009945 -text [translate "Flight mode: start angle"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800  -justify "left"

add_de1_text "settings_4" 90 225.000225000225 -text [translate "Other settings"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_widget "settings_4" entry 1340 342.00034200034196 {} -width 60  -font Helv_15_bold -bg #FFFFFF  -foreground #2d3046 -textvariable ::settings(machine_name) 
add_de1_text "settings_4" 1350 423.000423000423 -text [translate "Name your machine"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800  -justify "left"

add_de1_text "settings_4" 1350 225.000225000225 -text [translate "Information"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_4" 1350 540.00054000054 -text [translate "Version: 1.0 beta 4"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800  -justify "left"
add_de1_text "settings_4" 1350 594.000594000594 -text [translate "Serial number: 0000001"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 800  -justify "left"

add_de1_button "settings_4" {say [translate {awake time}] $::settings(sound_button_in);vertical_slider ::settings(alarm_wake) 0 86400 %x %y %x0 %y0 %x1 %y1} 1330 720.00072000072 1925 1134.001134001134 "mousemove"
add_de1_text "settings_4" 1700 1098.001098001098 -text [translate "Awake"] -font Helv_9 -fill "#2d3046" -anchor "center" -width 800  -justify "center"
add_de1_variable "settings_4" 1700 1170.00117000117 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[format_alarm_time $::settings(alarm_wake)]}

add_de1_button "settings_4" {say [translate {sleep time}] $::settings(sound_button_in);vertical_slider ::settings(alarm_sleep) 0 86400 %x %y %x0 %y0 %x1 %y1} 1925 720.00072000072 2500 1134.001134001134 "mousemove"
add_de1_text "settings_4" 2150 1098.001098001098 -text [translate "Asleep"] -font Helv_9 -fill "#2d3046" -anchor "center" -width 800  -justify "center"
add_de1_variable "settings_4" 2150 1170.00117000117 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[format_alarm_time $::settings(alarm_sleep)]}


#add_de1_text "settings_4" 310 360.00036000036 -text [translate "Wifi"] -font Helv_10_bold -fill "#2d3046" -anchor "left" -width 400  -justify "left"




add_de1_text "settings_3" 90 225.000225000225 -text [translate "Screen settings"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 1350 225.000225000225 -text [translate "Speaking"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_widget "settings_3" scale 90 279.00027900027897 {} -from 0 -to 100 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 990.00099000099  -width 135  -variable ::settings(app_brightness) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 90 472.5004725004725 -text [translate "App brightness"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800  -justify "left"

add_de1_widget "settings_3" scale 90 522.000522000522 {} -from 0 -to 100 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 990.00099000099  -width 135  -variable ::settings(saver_brightness) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 90 706.5007065007064 -text [translate "Screen saver brightness"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800  -justify "left"

add_de1_widget "settings_3" scale 90 756.0007560007559 {} -from 0 -to 120 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 990.00099000099  -width 135  -variable ::settings(screen_saver_delay) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 90 940.5009405009405 -text [translate "Screen saver delay"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800  -justify "left"

add_de1_widget "settings_3" scale 90 990.00099000099 {} -from 1 -to 120 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 990.00099000099  -width 135  -variable ::settings(screen_saver_change_interval) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 90 1174.5011745011745 -text [translate "Screen saver change interval"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800  -justify "left"

add_de1_widget "settings_3" checkbutton 1350 360.00036000036 {} -text [translate "Enable spoken prompts"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_spoken_prompts)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF

add_de1_widget "settings_3" scale 1350 522.000522000522 {} -from 0 -to 4 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length 990.00099000099  -width 135  -variable ::settings(speaking_rate) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 1350 706.5007065007064 -text [translate "Speaking speed"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800  -justify "left"

add_de1_widget "settings_3" scale 1350 756.0007560007559 {} -from 0 -to 3 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length 990.00099000099  -width 135  -variable ::settings(speaking_pitch) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE -borderwidth 0  -highlightthickness 0 
add_de1_text "settings_3" 1350 940.5009405009405 -text [translate "Speaking pitch"] -font Helv_8 -fill "#2d3046" -anchor "nw" -width 800  -justify "left"

#add_de1_text "settings_3" 1350 450.00045000045 -text [translate "Tick sound"] -font Helv_10_bold -fill "#2d3046" -anchor "nw" -width 800  -justify "left"
#add_de1_text "settings_3" 1350 540.00054000054 -text [translate "Tock sound"] -font Helv_10_bold -fill "#2d3046" -anchor "nw" -width 800  -justify "left"



add_de1_button "off" {after 300 update_de1_explanation_chart;unset -nocomplain ::settings_backup; array set ::settings_backup [array get ::settings]; set_next_page off settings_1; page_show settings_1} 2000 0.0 2560 450.00045000045 
add_de1_text "settings_1 settings_2 settings_3 settings_4" 2275 1368.0013680013678 -text [translate "Save"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"
add_de1_text "settings_1 settings_2 settings_3 settings_4" 1760 1368.0013680013678 -text [translate "Cancel"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"



# labels for PREHEAT tab on
add_de1_text "settings_1" 330 90.00009000009 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_1" 960 90.00009000009 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 1590 90.00009000009 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 2215 90.00009000009 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

########################################
# labels for WATER/STEAM tab on
add_de1_text "settings_2" 330 90.00009000009 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 960 90.00009000009 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_2" 1590 90.00009000009 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 2215 90.00009000009 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

add_de1_button "settings_2" {say [translate {water temperature}] $::settings(sound_button_in);vertical_slider ::settings(water_temperature) $::de1(water_min_temperature) $::de1(water_max_temperature) %x %y %x0 %y0 %x1 %y1} 50 612.000612000612 570 1134.001134001134 "mousemove"
add_de1_variable "settings_2" 380 1188.001188001188 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}

add_de1_button "settings_2" {say [translate {water time}] $::settings(sound_button_in);vertical_slider ::settings(water_max_time) $::de1(water_time_min) $::de1(water_time_max) %x %y %x0 %y0 %x1 %y1} 571 450.00045000045 1250 1134.001134001134 "mousemove"
add_de1_variable "settings_2" 900 1188.001188001188 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(water_max_time)] [translate "seconds"]}

add_de1_button "settings_2" {say [translate {steam temperature}] $::settings(sound_button_in);vertical_slider ::settings(steam_temperature) $::de1(steam_min_temperature) $::de1(steam_max_temperature) %x %y %x0 %y0 %x1 %y1} 1330 612.000612000612 1850 1134.001134001134 "mousemove"
add_de1_variable "settings_2" 1640 1188.001188001188 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(steam_temperature)]}

add_de1_button "settings_2" {say [translate {steam time}] $::settings(sound_button_in);vertical_slider ::settings(steam_max_time) $::de1(steam_time_min) $::de1(steam_time_max) %x %y %x0 %y0 %x1 %y1} 1851 450.00045000045 2500 1134.001134001134 "mousemove"
add_de1_variable "settings_2" 2170 1188.001188001188 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(steam_max_time)] [translate "seconds"]}

add_de1_text "settings_2" 230 252.000252000252 -text [translate "Hot water"] -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_2" 1510 252.000252000252 -text [translate "Steam"] -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"


########################################

# labels for STEAM tab on
add_de1_text "settings_3" 330 90.00009000009 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 960 90.00009000009 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 1590 90.00009000009 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_3" 2215 90.00009000009 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for HOT WATER tab on
add_de1_text "settings_4" 330 90.00009000009 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 960 90.00009000009 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 1590 90.00009000009 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 2215 90.00009000009 -text [translate "OTHER/INFO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "settings_1 settings_2 settings_3 settings_4" {after 300 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_1; page_show settings_1} 0 0.0 641 169.2001692001692 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_2; page_show settings_2} 642 0.0 1277 169.2001692001692 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_3; page_show settings_3} 1278 0.0 1904 169.2001692001692 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_4; page_show settings_4} 1905 0.0 2560 169.2001692001692 

add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {save}] $::settings(sound_button_in); save_settings; set_next_page off off; page_show off} 2016 1287.001287001287 2560 1440.00144000144 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {unset -nocomplain ::settings; array set ::settings [array get ::settings_backup]; say [translate {cancel}] $::settings(sound_button_in); set_next_page off off; page_show off} 1505 1287.001287001287 2015 1440.00144000144 



##############################################################################################################################################################################################################################################################################


##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it

add_de1_text "steam" 2048 968.4009684009684 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "steam" 2048 1022.4010224010224 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

# variables to display during steam
add_de1_text "steam" 2053 1058.4010584010584 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "steam" 2058 1058.4010584010584 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520  -textvariable {[steam_timer][translate "s"]} 
add_de1_text "steam" 2053 1103.4011034011035 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "steam" 2058 1103.4011034011035 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "steam" 2053 1148.4011484011482 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "steam" 2058 1148.4011484011482 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520  -textvariable {[steamtemp_text]} 
#add_de1_text "steam" 2053 1193.4011934011933 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520 
#add_de1_variable "steam" 2058 1193.4011934011933 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520  -textvariable {[pressure_text]} 


# 
#add_de1_action "steam" "do_steam"
# when it steam mode, tapping anywhere on the screen tells the DE1 to stop.
add_de1_button "steam" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0.0 2560 1440.00144000144 

# STEAM related info to display when the espresso machine is idle
add_de1_text "off" 2048 968.4009684009684 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 2053 1040.4010404010403 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 2058 1040.4010404010403 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 2053 1085.4010854010853 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 2058 1085.4010854010853 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520  -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 2053 1130.4011304011303 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 520  -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 2058 1130.4011304011303 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520  -textvariable {[steam_heater_temperature_text]} 

# when someone taps on the steam button
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 1748 554.4005544005544 2346 1272.6012726012725 

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it

add_de1_text "espresso" 1280 968.4009684009684 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "espresso" 1280 1022.4010224010224 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

add_de1_text "espresso" 1280 1058.4010584010584 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "espresso" 1285 1058.4010584010584 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[pour_timer][translate "s"]} 

add_de1_text "espresso" 1280 1103.4011034011035 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "espresso" 1285 1103.4011034011035 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "espresso" 1280 1148.4011484011482 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "espresso" 1285 1148.4011484011482 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[pressure_text]} 

add_de1_text "espresso" 1280 1193.4011934011933 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "espresso" 1285 1193.4011934011933 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[watertemp_text]} 

add_de1_button "espresso" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0.0 2560 1440.00144000144 

#add_btn_screen "espresso" "stop"
#add_de1_action "espresso" "do_espresso"


add_de1_text "off" 1280 968.4009684009684 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1275 1040.4010404010403 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 1280 1040.4010404010403 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "off" 1275 1085.4010854010853 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 1280 1085.4010854010853 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[setting_espresso_pressure_text]} 


add_de1_text "off" 1275 1130.4011304011303 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 1280 1130.4011304011303 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520  -textvariable {[setting_espresso_temperature_text]} 

add_de1_variable "off" 1275 1175.4011754011754 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 520  -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 1280 1175.4011754011754 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[group_head_heater_temperature_text]} 

# we spell espresso with two SSs so that it is pronounced like Italians say it
add_de1_button "off" "say [translate {esspresso}] $::settings(sound_button_in);start_espresso" 948 525.6005256005255 1606 1299.6012996012996 


#add_de1_text "espresso" 1275 1175.4011754011754 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 520 
#add_de1_variable "espresso" 1280 1175.4011754011754 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "" -fill "#2d3046" -width 520  -textvariable {[waterflow_text]} 

##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
add_de1_text "water" 510 968.4009684009684 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "water" 510 1022.4010224010224 -text "" -font Helv_9_bold -fill "#73768f" -anchor "center" -textvariable {[translate [de1_substate_text]]} 

add_de1_text "water" 500 1058.4010584010584 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "water" 505 1058.4010584010584 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520  -text "" -textvariable {[water_timer][translate "s"]} 
add_de1_text "water" 500 1103.4011034011035 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "water" 505 1103.4011034011035 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520  -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "water" 500 1148.4011484011482 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "water" 505 1148.4011484011482 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520  -text "" -textvariable {[watertemp_text]} 

add_de1_button "water" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0.0 2560 1440.00144000144 




add_de1_text "off" 510 968.4009684009684 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 500 1040.4010404010403 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 505 1040.4010404010403 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520  -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 500 1085.4010854010853 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 505 1085.4010854010853 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520  -text "" -textvariable {[setting_water_temperature_text]} 

#add_de1_text "water" 2053 1130.4011304011303 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 520 
#add_de1_variable "water" 2058 1130.4011304011303 -justify left -anchor "nw"  -font Helv_8 -fill "#42465c" -width 520  -text "" -textvariable {[waterflow_text]} 
#add_de1_text "water" 2053 1175.4011754011754 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 520 
#add_de1_variable "water" 2058 1175.4011754011754 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520  -text "" -textvariable {[watervolume_text]} 
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 210 550.8005508005508 808 1274.4012744012743 
#add_btn_screen "water" "stop"
#add_de1_action "water" "start_water"

##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
#add_de1_action "off" "stop"

# tapping the power button tells the DE1 to go to sleep, and it will after a few seconds, at which point we display the screen saver
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0.0 400 360.00036000036 
add_de1_button "settings_1 settings_2 settings_3 settings_4" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 1281.6012816012815 350 1440.00144000144 

add_de1_button "saver" "say [translate {awake}] $::settings(sound_button_in);start_idle" 0 0.0 2560 1440.00144000144 

add_de1_text "sleep" 2500 1305.001305001305 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_button "sleep" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0.0 2560 1440.00144000144 
#add_de1_action "sleep" "do_sleep"

add_de1_action "exit" "app_exit"


# Sleeping cafe photo obtained under creative commons from https://www.flickr.com/photos/curious_e/16300930781/

# turn the screen saver or splash screen off by tapping the page

#add_btn_screen "saver" "off"
#add_btn_screen "splash" "off"

# the SETTINGS button currently exits the app
#add_de1_button "off" "app_exit" 2200 0.0 2600 360.00036000036 
#add_de1_action "settings" "do_settings"

