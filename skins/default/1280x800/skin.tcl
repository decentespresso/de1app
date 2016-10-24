set ::skindebug 0

#add_de1_variable "off" 10 665 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[accelerometer_angle_text]} 

##############################################################################################################################################################################################################################################################################
# SETTINGS page

# tapping the logo exits the app
add_de1_button "off" "exit" 400 0 875 250 

# 1st batch of settings
add_de1_widget "settings_1" scale 25 125 {} -to 0 -from 20 -background #eaeafa -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 500  -width 75  -variable ::settings(preinfusion_time) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 120 650 -text [translate "Preinfusion time"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"

add_de1_widget "settings_1" scale 225 125 {} -to 0 -from 60 -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 500  -width 75  -variable ::settings(pressure_hold_time) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 320 650 -text [translate "Hold time"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"

add_de1_widget "settings_1" scale 425 125 {} -to 0 -from 60 -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 500  -width 75  -variable ::settings(espresso_decline_time) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 520 650 -text [translate "Decline time"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"

add_de1_widget "settings_1" scale 625 125 {} -to 0 -from 10 -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 500  -width 75  -variable ::settings(pressure_goal) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 720 650 -text [translate "Pressure goal"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"

add_de1_widget "settings_1" scale 825 125 {} -to 0 -from 10 -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 500  -width 75  -variable ::settings(pressure_end) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 920 650 -text [translate "Final pressure"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"

add_de1_widget "settings_1" scale 1025 125 {} -to $::de1(min_temperature) -from $::de1(max_temperature)  -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 500  -width 75  -variable ::settings(espresso_temperature) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 1120 650 -text [translate "Temperature"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"


add_de1_widget "settings_2" scale 25 125 {} -to $::de1(steam_min_temperature) -from $::de1(steam_max_temperature) -background #eaeafa -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 500  -width 100  -variable ::settings(steam_temperature) -font Helv_15_bold -sliderlength 100
add_de1_text "settings_2" 155 650 -text [translate "Steam temperature"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"

add_de1_widget "settings_3" scale 25 125 {} -to $::de1(water_min_temperature) -from $::de1(water_max_temperature) -background #eaeafa -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 500  -width 100  -variable ::settings(water_temperature) -font Helv_15_bold -sliderlength 100
add_de1_text "settings_3" 155 650 -text [translate "Hot water temperature"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"


add_de1_text "settings_4" 155 650 -text [translate "Celsius vs Fahrenheit"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"
add_de1_text "settings_4" 155 550 -text [translate "ml vs oz"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"
add_de1_text "settings_4" 155 450 -text [translate "Name"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"
add_de1_text "settings_4" 155 350 -text [translate "Serial number"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"
add_de1_text "settings_4" 155 250 -text [translate "Wifi"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"
add_de1_text "settings_4" 155 150 -text [translate "versions"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 200  -justify "center"


add_de1_button "off" "set_next_page off settings_1; page_show settings_1" 1000 0 1280 250 
add_de1_text "settings_1 settings_2 settings_3 settings_4" 1137 760 -text [translate "Done"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"

# labels for PREHEAT tab on
add_de1_text "settings_1" 165 50 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_1" 480 50 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 795 50 -text [translate "WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 1107 50 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for ESPRESSO tab on
add_de1_text "settings_2" 165 50 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 480 50 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_2" 795 50 -text [translate "WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 1107 50 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for STEAM tab on
add_de1_text "settings_3" 165 50 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 480 50 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 795 50 -text [translate "WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_3" 1107 50 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for HOT WATER tab on
add_de1_text "settings_4" 165 50 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 480 50 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 795 50 -text [translate "WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 1107 50 -text [translate "OTHER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_1; page_show settings_1} 0 0 320 94 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_2; page_show settings_2} 321 0 638 94 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_3; page_show settings_3} 639 0 952 94 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_4; page_show settings_4} 952 0 1280 94 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {done}] $::settings(sound_button_out); save_settings; set_next_page off off; page_show off} 952 715 1280 800 



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
add_de1_variable "espresso" 642 613 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time][translate "s"]} 

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

add_de1_text "off" 637 603 -justify right -anchor "ne" -text [translate "Peak pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
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

