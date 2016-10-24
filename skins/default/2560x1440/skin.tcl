set ::skindebug 0

#add_de1_variable "off" 20 1197.001197001197 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520  -textvariable {[accelerometer_angle_text]} 

##############################################################################################################################################################################################################################################################################
# SETTINGS page

# tapping the logo exits the app
add_de1_button "off" "exit" 800 0.0 1750 450.00045000045 

# 1st batch of settings
add_de1_widget "settings_1" scale 50 225.000225000225 {} -to 0 -from 20 -background #eaeafa -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 900.0009000009  -width 150  -variable ::settings(preinfusion_time) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 240 1170.00117000117 -text [translate "Preinfusion time"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"

add_de1_widget "settings_1" scale 450 225.000225000225 {} -to 0 -from 60 -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 900.0009000009  -width 150  -variable ::settings(pressure_hold_time) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 640 1170.00117000117 -text [translate "Hold time"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"

add_de1_widget "settings_1" scale 850 225.000225000225 {} -to 0 -from 60 -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 900.0009000009  -width 150  -variable ::settings(espresso_decline_time) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 1040 1170.00117000117 -text [translate "Decline time"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"

add_de1_widget "settings_1" scale 1250 225.000225000225 {} -to 0 -from 10 -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 900.0009000009  -width 150  -variable ::settings(pressure_goal) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 1440 1170.00117000117 -text [translate "Pressure goal"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"

add_de1_widget "settings_1" scale 1650 225.000225000225 {} -to 0 -from 10 -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 900.0009000009  -width 150  -variable ::settings(pressure_end) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 1840 1170.00117000117 -text [translate "Final pressure"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"

add_de1_widget "settings_1" scale 2050 225.000225000225 {} -to $::de1(min_temperature) -from $::de1(max_temperature)  -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 900.0009000009  -width 150  -variable ::settings(espresso_temperature) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 2240 1170.00117000117 -text [translate "Temperature"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"


add_de1_widget "settings_2" scale 50 225.000225000225 {} -to $::de1(steam_min_temperature) -from $::de1(steam_max_temperature) -background #eaeafa -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 900.0009000009  -width 200  -variable ::settings(steam_temperature) -font Helv_15_bold -sliderlength 100
add_de1_text "settings_2" 310 1170.00117000117 -text [translate "Steam temperature"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"

add_de1_widget "settings_3" scale 50 225.000225000225 {} -to $::de1(water_min_temperature) -from $::de1(water_max_temperature) -background #eaeafa -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 900.0009000009  -width 200  -variable ::settings(water_temperature) -font Helv_15_bold -sliderlength 100
add_de1_text "settings_3" 310 1170.00117000117 -text [translate "Hot water temperature"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"


add_de1_text "settings_4" 310 1170.00117000117 -text [translate "Celsius vs Fahrenheit"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"
add_de1_text "settings_4" 310 990.00099000099 -text [translate "ml vs oz"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"
add_de1_text "settings_4" 310 810.00081000081 -text [translate "Name"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"
add_de1_text "settings_4" 310 630.0006300006299 -text [translate "Serial number"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"
add_de1_text "settings_4" 310 450.00045000045 -text [translate "Wifi"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"
add_de1_text "settings_4" 310 270.00027000027 -text [translate "versions"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 400  -justify "center"


add_de1_button "off" "set_next_page off settings_1; page_show settings_1" 2000 0.0 2560 450.00045000045 
add_de1_text "settings_1 settings_2 settings_3 settings_4" 2275 1368.0013680013678 -text [translate "Done"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"

# labels for PREHEAT tab on
add_de1_text "settings_1" 330 90.00009000009 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_1" 960 90.00009000009 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 1590 90.00009000009 -text [translate "WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 2215 90.00009000009 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for ESPRESSO tab on
add_de1_text "settings_2" 330 90.00009000009 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 960 90.00009000009 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_2" 1590 90.00009000009 -text [translate "WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 2215 90.00009000009 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for STEAM tab on
add_de1_text "settings_3" 330 90.00009000009 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 960 90.00009000009 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 1590 90.00009000009 -text [translate "WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_3" 2215 90.00009000009 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for HOT WATER tab on
add_de1_text "settings_4" 330 90.00009000009 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 960 90.00009000009 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 1590 90.00009000009 -text [translate "WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 2215 90.00009000009 -text [translate "OTHER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_1; page_show settings_1} 0 0.0 641 169.2001692001692 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_2; page_show settings_2} 642 0.0 1277 169.2001692001692 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_3; page_show settings_3} 1278 0.0 1904 169.2001692001692 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_4; page_show settings_4} 1905 0.0 2560 169.2001692001692 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {done}] $::settings(sound_button_out); save_settings; set_next_page off off; page_show off} 1905 1287.001287001287 2560 1440.00144000144 



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
add_de1_variable "espresso" 1285 1103.4011034011035 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520  -textvariable {[setting_espresso_max_time][translate "s"]} 

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

add_de1_text "off" 1275 1085.4010854010853 -justify right -anchor "ne" -text [translate "Peak pressure:"] -font Helv_8 -fill "#7f879a" -width 520 
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

