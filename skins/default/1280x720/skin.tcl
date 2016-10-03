set ::skindebug 0

##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it
add_de1_text "steam" 1024 484.2004842004842 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "steam" 1024 511.2005112005112 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

# variables to display during steam
add_de1_text "steam" 1026 529.2005292005292 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 529.2005292005292 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[timer_text]} 
add_de1_text "steam" 1026 551.7005517005517 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 551.7005517005517 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "steam" 1026 574.2005742005741 -justify right -anchor "ne" -text [translate "Steam Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 574.2005742005741 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[steamtemp_text]} 
add_de1_text "steam" 1026 596.7005967005966 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "steam" 1029 596.7005967005966 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[pressure_text]} 

# what will be made when you press the steam button
add_de1_text "off" 1024 484.2004842004842 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1026 520.2005202005201 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 1029 520.2005202005201 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 1026 542.7005427005427 -justify right -anchor "ne" -text [translate "Steam Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 1029 542.7005427005427 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 1026 565.2005652005652 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 260  -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 1029 565.2005652005652 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[steam_heater_temperature_text]} 

add_de1_button "off" "steam" 874 277.2002772002772 1173 636.3006363006363
add_btn_screen "steam" "off"
add_de1_action "steam" "do_steam"

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it
add_de1_text "espresso" 640 484.2004842004842 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "espresso" 640 511.2005112005112 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 
add_de1_text "espresso" 637 529.2005292005292 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 640 529.2005292005292 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[timer_text]} 
add_de1_text "espresso" 637 551.7005517005517 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 640 551.7005517005517 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time_text]} 
add_de1_text "espresso" 637 574.2005742005741 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 640 574.2005742005741 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[pressure_text]} 

add_de1_text "espresso" 637 596.7005967005966 -justify right -anchor "ne" -text [translate "Brew Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "espresso" 640 596.7005967005966 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[watertemp_text]} 

add_de1_text "off" 640 484.2004842004842 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 637 520.2005202005201 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 520.2005202005201 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "off" 637 542.7005427005427 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 542.7005427005427 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[setting_espresso_pressure_text]} 


add_de1_text "off" 637 565.2005652005652 -justify right -anchor "ne" -text [translate "Brew Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 565.2005652005652 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_temperature_text]} 

add_de1_variable "off" 637 587.7005877005877 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 260  -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 640 587.7005877005877 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[group_head_heater_temperature_text]} 


#add_de1_text "espresso" 637 587.7005877005877 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "espresso" 640 587.7005877005877 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "-" -fill "#2d3046" -width 260  -textvariable {[waterflow_text]} 
add_de1_button "off" "espresso" 474 262.8002628002628 803 649.8006498006498
add_btn_screen "espresso" "off"
add_de1_action "espresso" "do_espresso"

##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
add_de1_text "water" 255 484.2004842004842 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "water" 255 511.2005112005112 -text "" -font Helv_9_bold -fill "#73768f" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

add_de1_text "water" 250 529.2005292005292 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "water" 252 529.2005292005292 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[timer_text]} 
add_de1_text "water" 250 551.7005517005517 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "water" 252 551.7005517005517 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[setting_water_max_time_text]} 
add_de1_text "water" 250 574.2005742005741 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "water" 252 574.2005742005741 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[watertemp_text]} 

add_de1_text "off" 255 484.2004842004842 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 250 520.2005202005201 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 252 520.2005202005201 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 250 542.7005427005427 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 252 542.7005427005427 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[setting_water_temperature_text]} 

#add_de1_text "water" 1026 565.2005652005652 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "water" 1029 565.2005652005652 -justify left -anchor "nw"  -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[waterflow_text]} 
#add_de1_text "water" 1026 587.7005877005877 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "water" 1029 587.7005877005877 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[watervolume_text]} 
add_de1_button "off" "water" 105 275.4002754002754 404 637.2006372006372
add_btn_screen "water" "off"
add_de1_action "water" "do_water"

##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
add_de1_action "off" "de1_stop_all"

# tapping the power button tells the DE1 to go to sleep, and it will after a few seconds, at which point we display the screen saver
add_de1_button "off" "sleep" 0 0.0 200 180.00018000018
add_de1_text "sleep" 1250 652.5006525006524 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_action "sleep" "do_sleep"

add_de1_button "off" "exit" 400 0.0 875 225.000225000225
add_de1_action "exit" "app_exit"


# Sleeping cafe photo obtained under creative commons from https://www.flickr.com/photos/curious_e/16300930781/

# turn the screen saver or splash screen off by tapping the page
add_btn_screen "saver" "off"
add_btn_screen "splash" "off"

# the SETTINGS button
add_de1_button "off" "off" 1100 0.0 1300 180.00018000018
add_de1_action "settings" "do_settings"

