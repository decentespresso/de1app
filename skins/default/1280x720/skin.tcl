set ::skindebug 1

#add_de1_variable "off" 10 598.5005985005985 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[accelerometer_angle_text]} 

##############################################################################################################################################################################################################################################################################
# SETTINGS page

# tapping the logo exits the app
add_de1_button "off" "exit" 400 0.0 875 225.000225000225 


# 1st batch of settings
#add_de1_widget "settings_1" scale 25 315.00031500031497 {} -to 0 -from 20 -background #FFFFFF -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 270.00027000027  -width 75  -variable ::settings(preinfusion_time) -font Helv_15_bold -sliderlength 100 -relief flat
#add_de1_text "settings_1" 120 612.000612000612 -text [translate "Preinfusion time"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"
add_de1_widget "settings_1" checkbutton 40 351.000351000351 {} -text [translate "Preinfusion"] -indicatoron true  -font Helv_15_bold -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(preinfusion_enabled) -command update_de1_explanation_chart


add_de1_widget "settings_1" scale 280 366.3003663003663 {} -to 1 -from 10 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 225.000225000225  -width 75  -variable ::settings(espresso_pressure) -font Helv_15_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -foreground #4e85f4 -troughcolor #EEEEEE
add_de1_text "settings_1" 340 596.2505962505962 -text [translate "Hold pressure"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" -width 190  -justify "left"

add_de1_widget "settings_1" scale 425 337.5003375003375 {} -from 0 -to 60 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 360.00036000036  -width 75  -variable ::settings(pressure_hold_time) -font Helv_10_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE
add_de1_text "settings_1" 625 441.00044100044096 -text [translate "Hold time"] -font Helv_15_bold -fill "#2d3046" -anchor "n" -width 190  -justify "center"

add_de1_widget "settings_1" scale 850 337.5003375003375 {} -from 0 -to 60 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 360.00036000036  -width 75  -variable ::settings(espresso_decline_time) -font Helv_10_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE
add_de1_text "settings_1" 1005 441.00044100044096 -text [translate "Decline time"] -font Helv_15_bold -fill "#2d3046" -anchor "n" -width 490  -justify "center"

add_de1_widget "settings_1" scale 1113 443.25044325044325 {} -to 0 -from 10 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 148.5001485001485   -width 75  -variable ::settings(pressure_end) -font Helv_15_bold -sliderlength 75 -relief flat -command update_de1_explanation_chart -foreground #4e85f4 -troughcolor #EEEEEE
add_de1_text "settings_1" 1250 596.2505962505962 -text [translate "Final pressure"] -font Helv_15_bold -fill "#2d3046" -anchor "ne" -width 190  -justify "left"

#add_de1_text "settings_1" 775 495.000495000495 -text [translate "Your Espresso Profile"] -font Helv_20_bold -fill "#5a5d75" -anchor "n" -width 600  -justify "center"

add_de1_button "settings_1" {say [translate {temperature}] $::settings(sound_button_in);vertical_slider ::settings(espresso_temperature) 80 95 %x %y %x0 %y0 %x1 %y1} 0 387.000387000387 225 630.0006300006299 "mousemove"
add_de1_text "settings_1" 160 490.50049050049046  -text [translate "TEMP"] -font Helv_8 -fill "#7f879a" -anchor "center" 
add_de1_variable "settings_1" 160 526.5005265005265 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(espresso_temperature)]}

#add_de1_text "settings_1" 262 607.5006075006074  -text "(Step 1)" -font Helv_8 -fill "#7f879a" -anchor "center" -anchor ne
#add_de1_text "settings_1" 825 607.5006075006074  -text "(Step 2)" -font Helv_8 -fill "#7f879a" -anchor "center" -anchor ne
#add_de1_text "settings_1" 852 607.5006075006074  -text "(Step 3)" -font Helv_8 -fill "#7f879a" -anchor "center" -anchor nw 

add_de1_widget "settings_1" graph 12 99.000099000099 { 
	update_de1_explanation_chart;
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth 5  -color #4e85f4  -smooth quadratic -pixels 15; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -command graph_seconds_axis_format; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure) -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12} -title [translate "pressure (bar)"] -titlefont Helv_8;

	bind $widget [platform_button_press] { 
		say [translate {refresh chart}] $::settings(sound_button_out); 
		update_de1_explanation_chart} 
	} -plotbackground #EEEEEE -width 1250  -height 225.000225000225  -borderwidth 1 -background #FFFFFF -plotrelief raised


#add_de1_widget "settings_3" scale 25 112.5001125001125 {} -to $::de1(water_min_temperature) -from $::de1(water_max_temperature) -background #FFFFFF -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 450.00045000045  -width 100  -variable ::settings(water_temperature) -font Helv_15_bold -sliderlength 100
#add_de1_text "settings_3" 155 612.000612000612 -text [translate "Hot water temperature"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"

add_de1_text "settings_4" 45 112.5001125001125 -text [translate "Other"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 675 112.5001125001125 -text [translate "Flight mode"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_text "settings_4" 65 180.00018000018 -text [translate "Version: 1.0 beta 4"] -font Helv_10_bold -fill "#2d3046" -anchor "nw" -width 400  -justify "left"
add_de1_text "settings_4" 65 225.000225000225 -text [translate "Serial number"] -font Helv_10_bold -fill "#2d3046" -anchor "nw" -width 400  -justify "left"
#add_de1_text "settings_4" 155 180.00018000018 -text [translate "Wifi"] -font Helv_10_bold -fill "#2d3046" -anchor "left" -width 200  -justify "left"
add_de1_text "settings_4" 695 315.00031500031497 -text [translate "Enable flight mode"] -font Helv_10_bold -fill "#2d3046" -anchor "nw" -width 400  -justify "left"
add_de1_text "settings_4" 695 360.00036000036 -text [translate "Flight mode start angle"] -font Helv_10_bold -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_text "settings_4" 155 360.00036000036 -text [translate "Name"] -font Helv_10_bold -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

#enable_fluid_ounces
add_de1_text "settings_4" 155 315.00031500031497 -text [translate "Use fluid ounces"] -font Helv_10_bold -fill "#2d3046" -anchor "nw" -width 400  -justify "left"
add_de1_text "settings_4" 155 360.00036000036 -text [translate "Use Fahrenheit"] -font Helv_10_bold -fill "#2d3046" -anchor "nw" -width 400  -justify "left"


add_de1_text "settings_3" 45 112.5001125001125 -text [translate "Screen settings"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_3" 675 112.5001125001125 -text [translate "Speaking"] -font Helv_10_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_widget "settings_3" scale 45 139.50013950013948 {} -from 0 -to 100 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 495.000495000495  -width 67  -variable ::settings(app_brightness) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE
add_de1_text "settings_3" 45 236.25023625023624 -text [translate "App brightness"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_widget "settings_3" scale 45 261.000261000261 {} -from 0 -to 100 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 495.000495000495  -width 67  -variable ::settings(saver_brightness) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE
add_de1_text "settings_3" 45 353.2503532503532 -text [translate "Screen saver brightness"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_widget "settings_3" scale 45 378.00037800037796 {} -from 0 -to 120 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 495.000495000495  -width 67  -variable ::settings(screen_saver_delay) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE
add_de1_text "settings_3" 45 470.25047025047024 -text [translate "Screen saver delay"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_widget "settings_3" scale 45 495.000495000495 {} -from 1 -to 120 -background #FFFFFF -borderwidth 1 -bigincrement 1 -resolution 1 -length 495.000495000495  -width 67  -variable ::settings(screen_saver_change_interval) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE
add_de1_text "settings_3" 45 587.2505872505873 -text [translate "Screen saver change interval"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_widget "settings_3" checkbutton 675 180.00018000018 {} -text [translate "Enable spoken prompts"] -indicatoron true  -font Helv_10 -bg #FFFFFF -anchor nw -foreground #2d3046 -variable ::settings(enable_spoken_prompts) 

add_de1_widget "settings_3" scale 675 261.000261000261 {} -from 0 -to 4 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length 495.000495000495  -width 67  -variable ::settings(speaking_rate) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE
add_de1_text "settings_3" 675 353.2503532503532 -text [translate "Speaking speed"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

add_de1_widget "settings_3" scale 675 378.00037800037796 {} -from 0 -to 3 -background #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length 495.000495000495  -width 67  -variable ::settings(speaking_pitch) -font Helv_10_bold -sliderlength 75 -relief flat -orient horizontal -foreground #4e85f4 -troughcolor #EEEEEE
add_de1_text "settings_3" 675 470.25047025047024 -text [translate "Speaking pitch"] -font Helv_9 -fill "#2d3046" -anchor "nw" -width 400  -justify "left"

#add_de1_text "settings_3" 675 225.000225000225 -text [translate "Tick sound"] -font Helv_10_bold -fill "#2d3046" -anchor "nw" -width 400  -justify "left"
#add_de1_text "settings_3" 675 270.00027000027 -text [translate "Tock sound"] -font Helv_10_bold -fill "#2d3046" -anchor "nw" -width 400  -justify "left"



add_de1_button "off" "set_next_page off settings_1; page_show settings_1" 1000 0.0 1280 225.000225000225 
add_de1_text "settings_1 settings_2 settings_3 settings_4" 1137 684.0006840006839 -text [translate "Save"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"
add_de1_text "settings_1 settings_2 settings_3 settings_4" 880 684.0006840006839 -text [translate "Cancel"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"



# labels for PREHEAT tab on
add_de1_text "settings_1" 165 45.000045000045 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_1" 480 45.000045000045 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 795 45.000045000045 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 1107 45.000045000045 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

########################################
# labels for WATER/STEAM tab on
add_de1_text "settings_2" 165 45.000045000045 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 480 45.000045000045 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_2" 795 45.000045000045 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 1107 45.000045000045 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

add_de1_button "settings_2" {say [translate {water temperature}] $::settings(sound_button_in);vertical_slider ::settings(water_temperature) $::de1(water_min_temperature) $::de1(water_max_temperature) %x %y %x0 %y0 %x1 %y1} 25 306.000306000306 285 567.000567000567 "mousemove"
add_de1_variable "settings_2" 190 594.000594000594 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}

add_de1_button "settings_2" {say [translate {water time}] $::settings(sound_button_in);vertical_slider ::settings(water_max_time) $::de1(water_time_min) $::de1(water_time_max) %x %y %x0 %y0 %x1 %y1} 285 225.000225000225 625 567.000567000567 "mousemove"
add_de1_variable "settings_2" 450 594.000594000594 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(water_max_time)] [translate "seconds"]}

add_de1_button "settings_2" {say [translate {steam temperature}] $::settings(sound_button_in);vertical_slider ::settings(steam_temperature) $::de1(steam_min_temperature) $::de1(steam_max_temperature) %x %y %x0 %y0 %x1 %y1} 665 306.000306000306 925 567.000567000567 "mousemove"
add_de1_variable "settings_2" 820 594.000594000594 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(steam_temperature)]}

add_de1_button "settings_2" {say [translate {steam time}] $::settings(sound_button_in);vertical_slider ::settings(steam_max_time) $::de1(steam_time_min) $::de1(steam_time_max) %x %y %x0 %y0 %x1 %y1} 925 225.000225000225 1250 567.000567000567 "mousemove"
add_de1_variable "settings_2" 1085 594.000594000594 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::settings(steam_max_time)] [translate "seconds"]}

add_de1_text "settings_2" 115 126.000126000126 -text [translate "Hot water"] -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "settings_2" 755 126.000126000126 -text [translate "Steam"] -font Helv_15_bold -fill "#7f879a" -justify "left" -anchor "nw"

#add_de1_widget "settings_2" scale 25 112.5001125001125 {} -to $::de1(steam_min_temperature) -from $::de1(steam_max_temperature) -background #FFFFFF -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 450.00045000045  -width 100  -variable ::settings(steam_temperature) -font Helv_15_bold -sliderlength 100
#add_de1_text "settings_2" 155 612.000612000612 -text [translate "Steam temperature"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"



########################################

# labels for STEAM tab on
add_de1_text "settings_3" 165 45.000045000045 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 480 45.000045000045 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 795 45.000045000045 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_3" 1107 45.000045000045 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for HOT WATER tab on
add_de1_text "settings_4" 165 45.000045000045 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 480 45.000045000045 -text [translate "WATER/STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 795 45.000045000045 -text [translate "SCREEN/SOUNDS"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 1107 45.000045000045 -text [translate "OTHER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_1; page_show settings_1} 0 0.0 320 84.6000846000846 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_2; page_show settings_2} 321 0.0 638 84.6000846000846 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_3; page_show settings_3} 639 0.0 952 84.6000846000846 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_4; page_show settings_4} 952 0.0 1280 84.6000846000846 

add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {save}] $::settings(sound_button_out); save_settings; set_next_page off off; page_show off} 1008 643.5006435006435 1280 720.00072000072 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {cancel}] $::settings(sound_button_out); set_next_page off off; page_show off} 752 643.5006435006435 1007 720.00072000072 



##############################################################################################################################################################################################################################################################################


##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it

add_de1_text "steam" 1024 484.2004842004842 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "steam" 1024 511.2005112005112 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

# variables to display during steam
add_de1_text "steam" 1026 529.2005292005292 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 529.2005292005292 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[steam_timer][translate "s"]} 
add_de1_text "steam" 1026 551.7005517005517 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 551.7005517005517 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "steam" 1026 574.2005742005741 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 574.2005742005741 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[steamtemp_text]} 
#add_de1_text "steam" 1026 596.7005967005966 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "steam" 1029 596.7005967005966 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[pressure_text]} 


# 
#add_de1_action "steam" "do_steam"
# when it steam mode, tapping anywhere on the screen tells the DE1 to stop.
add_de1_button "steam" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0.0 1280 720.00072000072 

# STEAM related info to display when the espresso machine is idle
add_de1_text "off" 1024 484.2004842004842 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1026 520.2005202005201 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 1029 520.2005202005201 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 1026 542.7005427005427 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 1029 542.7005427005427 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 1026 565.2005652005652 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 260  -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 1029 565.2005652005652 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[steam_heater_temperature_text]} 

# when someone taps on the steam button
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 874 277.2002772002772 1173 636.3006363006363 

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it

add_de1_text "espresso" 640 484.2004842004842 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "espresso" 640 511.2005112005112 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

add_de1_text "espresso" 640 529.2005292005292 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 642 529.2005292005292 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[pour_timer][translate "s"]} 

add_de1_text "espresso" 640 551.7005517005517 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 642 551.7005517005517 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "espresso" 640 574.2005742005741 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 642 574.2005742005741 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[pressure_text]} 

add_de1_text "espresso" 640 596.7005967005966 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 642 596.7005967005966 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[watertemp_text]} 

add_de1_button "espresso" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0.0 1280 720.00072000072 

#add_btn_screen "espresso" "stop"
#add_de1_action "espresso" "do_espresso"


add_de1_text "off" 640 484.2004842004842 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 637 520.2005202005201 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 520.2005202005201 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "off" 637 542.7005427005427 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 542.7005427005427 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[setting_espresso_pressure_text]} 


add_de1_text "off" 637 565.2005652005652 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 565.2005652005652 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_temperature_text]} 

add_de1_variable "off" 637 587.7005877005877 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 260  -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 640 587.7005877005877 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[group_head_heater_temperature_text]} 

# we spell espresso with two SSs so that it is pronounced like Italians say it
add_de1_button "off" "say [translate {esspresso}] $::settings(sound_button_in);start_espresso" 474 262.8002628002628 803 649.8006498006498 


#add_de1_text "espresso" 637 587.7005877005877 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "espresso" 640 587.7005877005877 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "" -fill "#2d3046" -width 260  -textvariable {[waterflow_text]} 

##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
add_de1_text "water" 255 484.2004842004842 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "water" 255 511.2005112005112 -text "" -font Helv_9_bold -fill "#73768f" -anchor "center" -textvariable {[translate [de1_substate_text]]} 

add_de1_text "water" 250 529.2005292005292 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "water" 252 529.2005292005292 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[water_timer][translate "s"]} 
add_de1_text "water" 250 551.7005517005517 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "water" 252 551.7005517005517 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "water" 250 574.2005742005741 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "water" 252 574.2005742005741 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[watertemp_text]} 

add_de1_button "water" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0.0 1280 720.00072000072 




add_de1_text "off" 255 484.2004842004842 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 250 520.2005202005201 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 252 520.2005202005201 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 250 542.7005427005427 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 252 542.7005427005427 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[setting_water_temperature_text]} 

#add_de1_text "water" 1026 565.2005652005652 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "water" 1029 565.2005652005652 -justify left -anchor "nw"  -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[waterflow_text]} 
#add_de1_text "water" 1026 587.7005877005877 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "water" 1029 587.7005877005877 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "" -textvariable {[watervolume_text]} 
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 105 275.4002754002754 404 637.2006372006372 
#add_btn_screen "water" "stop"
#add_de1_action "water" "start_water"

##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
#add_de1_action "off" "stop"

# tapping the power button tells the DE1 to go to sleep, and it will after a few seconds, at which point we display the screen saver
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0.0 200 180.00018000018 
add_de1_button "settings_1 settings_2 settings_3 settings_4" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 640.8006408006407 175 720.00072000072 

add_de1_button "saver" "say [translate {awake}] $::settings(sound_button_in);start_idle" 0 0.0 1280 720.00072000072 

add_de1_text "sleep" 1250 652.5006525006524 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_button "sleep" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0.0 1280 720.00072000072 
#add_de1_action "sleep" "do_sleep"

add_de1_action "exit" "app_exit"


# Sleeping cafe photo obtained under creative commons from https://www.flickr.com/photos/curious_e/16300930781/

# turn the screen saver or splash screen off by tapping the page

#add_btn_screen "saver" "off"
#add_btn_screen "splash" "off"

# the SETTINGS button currently exits the app
#add_de1_button "off" "app_exit" 1100 0.0 1300 180.00018000018 
#add_de1_action "settings" "do_settings"

