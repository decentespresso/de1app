set ::skindebug 1

##############################################################################################################################################################################################################################################################################
# the graphics for each of the main espresso machine modes
add_de1_page "off" "[skin_directory_graphics]/nothing_on.png"
add_de1_page "espresso" "[skin_directory_graphics]/espresso_on.png"
add_de1_page "steam" "[skin_directory_graphics]/steam_on.png"
add_de1_page "water" "[skin_directory_graphics]/tea_on.png"
add_de1_page "settings_1" "[skin_directory_graphics]/settings_1.png"
add_de1_page "settings_1a" "[skin_directory_graphics]/settings_1a.png"
add_de1_page "settings_2" "[skin_directory_graphics]/settings_2.png"
add_de1_page "settings_3" "[skin_directory_graphics]/settings_3.png"
add_de1_page "settings_4" "[skin_directory_graphics]/settings_4.png"
add_de1_page "sleep" "[skin_directory_graphics]/sleep.jpg"
add_de1_page "tankfilling" "[skin_directory_graphics]/filling_tank.jpg"
add_de1_page "tankempty" "[skin_directory_graphics]/fill_tank.jpg"
add_de1_page "saver" [random_saver_file]


# include the generic settings features for all DE1 skins.  
source "[homedir]/de1_skin_settings.tcl"


##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it

add_de1_text "off" 640 538 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 637 578 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "off" 640 578 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260 -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "off" 637 603 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "off" 640 603 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260 -textvariable {[setting_espresso_pressure_text]} 


add_de1_text "off" 637 628 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "off" 640 628 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260 -textvariable {[setting_espresso_temperature_text]} 

add_de1_variable "off" 637 653 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 260 -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 640 653 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260 -textvariable {[group_head_heater_temperature_text]} 

# we spell espresso with two SSs so that it is pronounced like Italians say it
add_de1_button "off" "say [translate {esspresso}] $::settings(sound_button_in);start_espresso" 474 292 803 722

add_de1_text "off" 255 538 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 250 578 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "off" 252 578 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260 -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 250 603 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "off" 252 603 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260 -text "" -textvariable {[setting_water_temperature_text]} 

add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 105 306 404 708


##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it

add_de1_text "steam" 1024 538 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "steam" 1024 568 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

# variables to display during steam
add_de1_text "steam" 1026 588 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "steam" 1029 588 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260 -textvariable {[steam_timer][translate "s"]} 
add_de1_text "steam" 1026 613 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "steam" 1029 613 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260 -textvariable {[setting_steam_max_time_text]} 
add_de1_text "steam" 1026 638 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "steam" 1029 638 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260 -textvariable {[steamtemp_text]} 


# 
# when it steam mode, tapping anywhere on the screen tells the DE1 to stop.
add_de1_button "steam" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 1280 800

# STEAM related info to display when the espresso machine is idle
add_de1_text "off" 1024 538 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1026 578 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "off" 1029 578 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260 -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 1026 603 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "off" 1029 603 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260 -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 1026 628 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 260 -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 1029 628 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260 -textvariable {[steam_heater_temperature_text]} 

# when someone taps on the steam button
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 874 308 1173 707

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it

add_de1_text "espresso" 640 538 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "espresso" 640 568 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

add_de1_text "espresso" 640 588 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "espresso" 642 588 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260 -textvariable {[pour_timer][translate "s"]} 

add_de1_text "espresso" 640 613 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "espresso" 642 613 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260 -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "espresso" 640 638 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "espresso" 642 638 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260 -textvariable {[pressure_text]} 

add_de1_text "espresso" 640 663 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "espresso" 642 663 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260 -textvariable {[watertemp_text]} 

add_de1_button "espresso" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 1280 800




##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
add_de1_text "water" 255 538 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "water" 255 568 -text "" -font Helv_9_bold -fill "#73768f" -anchor "center" -textvariable {[translate [de1_substate_text]]} 

add_de1_text "water" 250 588 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "water" 252 588 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260 -text "" -textvariable {[water_timer][translate "s"]} 
add_de1_text "water" 250 613 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "water" 252 613 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260 -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "water" 250 638 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "water" 252 638 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260 -text "" -textvariable {[watertemp_text]} 

add_de1_button "water" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 1280 800



##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
# tapping the power button tells the DE1 to go to sleep, and it will after a few seconds, at which point we display the screen saver
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 200 200

add_de1_button "saver" "say [translate {awake}] $::settings(sound_button_in);start_idle" 0 0 1280 800

add_de1_text "sleep" 1250 725 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_button "sleep" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 1280 800
add_de1_action "exit" "app_exit"

