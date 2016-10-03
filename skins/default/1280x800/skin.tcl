set ::skindebug 0

##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it
add_de1_text "steam" 1024 538 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "steam" 1024 568 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

# variables to display during steam
add_de1_text "steam" 1026 588 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 588 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[timer_text]} 
add_de1_text "steam" 1026 613 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 613 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "steam" 1026 638 -justify right -anchor "ne" -text [translate "Steam Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 638 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[steamtemp_text]} 
add_de1_text "steam" 1026 663 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 663 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[pressure_text]} 

# what will be made when you press the steam button
add_de1_text "off" 1024 538 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1026 578 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 1029 578 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 1026 603 -justify right -anchor "ne" -text [translate "Steam Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 1029 603 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 1026 628 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 260  -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 1029 628 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[steam_heater_temperature_text]} 

add_de1_button "off" "steam" 874 308 1173 707
add_btn_screen "steam" "off"
add_de1_action "steam" "do_steam"

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it
add_de1_text "espresso" 640 538 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "espresso" 640 568 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 
add_de1_text "espresso" 637 588 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 640 588 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[timer_text]} 
add_de1_text "espresso" 637 613 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 640 613 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time_text]} 
add_de1_text "espresso" 637 638 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 640 638 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[pressure_text]} 

add_de1_text "espresso" 637 663 -justify right -anchor "ne" -text [translate "Brew Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 640 663 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[watertemp_text]} 

add_de1_text "off" 640 538 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 637 578 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 578 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "off" 637 603 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 603 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[setting_espresso_pressure_text]} 


add_de1_text "off" 637 628 -justify right -anchor "ne" -text [translate "Brew Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 628 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_temperature_text]} 

add_de1_variable "off" 637 653 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 260  -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 640 653 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[group_head_heater_temperature_text]} 


#add_de1_text "espresso" 637 653 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "espresso" 640 653 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "-" -fill "#2d3046" -width 260  -textvariable {[waterflow_text]} 
add_de1_button "off" "espresso" 474 292 803 722
add_btn_screen "espresso" "off"
add_de1_action "espresso" "do_espresso"

##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
add_de1_text "water" 255 538 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "water" 255 568 -text "" -font Helv_9_bold -fill "#73768f" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

add_de1_text "water" 250 588 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "water" 252 588 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[timer_text]} 
add_de1_text "water" 250 613 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "water" 252 613 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[setting_water_max_time_text]} 
add_de1_text "water" 250 638 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "water" 252 638 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[watertemp_text]} 

add_de1_text "off" 255 538 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 250 578 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 252 578 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 250 603 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 252 603 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[setting_water_temperature_text]} 

#add_de1_text "water" 1026 628 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "water" 1029 628 -justify left -anchor "nw"  -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[waterflow_text]} 
#add_de1_text "water" 1026 653 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "water" 1029 653 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[watervolume_text]} 
add_de1_button "off" "water" 105 306 404 708
add_btn_screen "water" "off"
add_de1_action "water" "do_water"

##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
add_de1_action "off" "de1_stop_all"

# tapping the power button tells the DE1 to go to sleep, and it will after a few seconds, at which point we display the screen saver
add_de1_button "off" "sleep" 0 0 200 200
add_de1_text "sleep" 1250 725 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_action "sleep" "do_sleep"

add_de1_button "off" "exit" 400 0 875 250
add_de1_action "exit" "app_exit"


# Sleeping cafe photo obtained under creative commons from https://www.flickr.com/photos/curious_e/16300930781/

# turn the screen saver or splash screen off by tapping the page
add_btn_screen "saver" "off"
add_btn_screen "splash" "off"

# the SETTINGS button
add_de1_button "off" "off" 1100 0 1300 200
add_de1_action "settings" "do_settings"

