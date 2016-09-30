set ::skindebug 0

##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it
add_de1_text "steam" 510 1076 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "steam" 510 1136 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

# variables to display during steam
add_de1_text "steam" 500 1176 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 505 1176 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[timer_text]} 
add_de1_text "steam" 500 1226 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 505 1226 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[setting_steam_max_time_text]} 
add_de1_text "steam" 500 1276 -justify right -anchor "ne" -text [translate "Steam Temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 505 1276 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[steamtemp_text]} 
add_de1_text "steam" 500 1326 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 505 1326 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[pressure_text]} 

# what will be made when you press the steam button
add_de1_text "off" 510 1076 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 500 1156 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 505 1156 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 500 1206 -justify right -anchor "ne" -text [translate "Steam Temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 505 1206 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 500 1256 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 520 -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 505 1256 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#2d3046" -width 520 -textvariable {[steam_heater_temperature_text]} 

add_de1_button "off" "steam" 210 612 808 1416
add_btn_screen "steam" "off"
add_de1_action "steam" "do_steam"

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it
add_de1_text "espresso" 1280 1076 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "espresso" 1280 1136 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 
add_de1_text "espresso" 1275 1176 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 1280 1176 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#2d3046" -width 520 -textvariable {[timer_text]} 
add_de1_text "espresso" 1275 1226 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 1280 1226 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#2d3046" -width 520 -textvariable {[setting_espresso_max_time_text]} 
add_de1_text "espresso" 1275 1276 -justify right -anchor "ne" -text [translate "Brew Temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 1280 1276 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#2d3046" -width 520 -textvariable {[watertemp_text]} 
add_de1_text "espresso" 1275 1326 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 1280 1326 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#2d3046" -width 520 -textvariable {[pressure_text]} 

add_de1_text "off" 1280 1076 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1275 1156 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 1280 1156 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#2d3046" -width 520 -textvariable {[setting_espresso_max_time_text]} 
add_de1_text "off" 1275 1206 -justify right -anchor "ne" -text [translate "Brew Temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 1280 1206 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#2d3046" -width 520 -textvariable {[setting_espresso_temperature_text]} 
add_de1_text "off" 1275 1256 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 1280 1256 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#2d3046" -width 520 -textvariable {[setting_espresso_pressure_text]} 
add_de1_variable "off" 1275 1306 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 520 -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 1280 1306 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#2d3046" -width 520 -textvariable {[group_head_heater_temperature_text]} 

#add_de1_text "espresso" 1275 1306 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 520
#add_de1_variable "espresso" 1280 1306 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[waterflow_text]} 
add_de1_button "off" "espresso" 948 584 1606 1444
add_btn_screen "espresso" "off"
add_de1_action "espresso" "do_espresso"

##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
add_de1_text "water" 2048 1076 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "water" 2048 1136 -text "" -font Helv_9_bold -fill "#73768f" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 
add_de1_text "water" 2053 1176 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 2058 1176 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 520 -text "-" -textvariable {[timer_text]} 
add_de1_text "water" 2053 1226 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 2058 1226 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 520 -text "-" -textvariable {[setting_water_max_time_text]} 
add_de1_text "water" 2053 1276 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 2058 1276 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 520 -text "-" -textvariable {[watertemp_text]} 

add_de1_text "off" 2048 1076 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 2053 1156 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 2058 1156 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 520 -text "-" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 2053 1206 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 2058 1206 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 520 -text "-" -textvariable {[setting_water_temperature_text]} 

#add_de1_text "water" 2053 1256 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 520
#add_de1_variable "water" 2058 1256 -justify left -anchor "nw"  -font Helv_8 -fill "#2d3046" -width 520 -text "-" -textvariable {[waterflow_text]} 
#add_de1_text "water" 2053 1306 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 520
#add_de1_variable "water" 2058 1306 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 520 -text "-" -textvariable {[watervolume_text]} 
add_de1_button "off" "water" 1748 616 2346 1414
add_btn_screen "water" "off"
add_de1_action "water" "do_water"

##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
add_de1_action "off" "de1_stop_all"

# tapping any of the 3 corners of the screen turn the screen saver on (all the corners except the one with settings) and puts the machine into sleep mode
add_de1_button "off" "saver" 0 0 400 400


# turn the screen saver or splash screen off by tapping the page
add_btn_screen "saver" "off"
add_btn_screen "splash" "off"

# the SETTINGS button
add_de1_button "off" "settings" 2200 0 2600 400
add_de1_action "settings" "app_exit"
