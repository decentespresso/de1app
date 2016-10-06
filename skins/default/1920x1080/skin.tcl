set ::skindebug 0

#add_de1_variable "off" 15.000003750000936 897.7499999887782 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390.00009750002437  -textvariable {[accelerometer_angle_text]} 


##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it
add_de1_text "steam" 1536.000384000096 726.2999999909213 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "steam" 1536.000384000096 766.799999990415 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

# variables to display during steam
add_de1_text "steam" 1539.7503849375962 793.7999999900776 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "steam" 1543.5003858750963 793.7999999900776 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 390.00009750002437  -textvariable {[timer_text]} 
add_de1_text "steam" 1539.7503849375962 827.5499999896557 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "steam" 1543.5003858750963 827.5499999896557 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "steam" 1539.7503849375962 861.2999999892338 -justify right -anchor "ne" -text [translate "Steam Temp:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "steam" 1543.5003858750963 861.2999999892338 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 390.00009750002437  -textvariable {[steamtemp_text]} 
add_de1_text "steam" 1539.7503849375962 895.0499999888119 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "steam" 1543.5003858750963 895.0499999888119 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 390.00009750002437  -textvariable {[pressure_text]} 

if {[has_flowmeter] == 1} {
	add_de1_text "steam" 1539.7503849375962 928.79999998839 -justify right -anchor "ne" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
	add_de1_variable "steam" 1543.5003858750963 928.79999998839 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[waterflow_text]} 
	add_de1_text "steam" 1539.7503849375962 962.5499999879681 -justify right -anchor "ne" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
	add_de1_variable "steam" 1543.5003858750963 962.5499999879681 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[watervolume_text]} 
}


# 
#add_de1_action "steam" "do_steam"
# when it steam mode, tapping anywhere on the screen tells the DE1 to stop.
add_de1_button "steam" "start_idle" 0.0 0.0 1920.0004800001198 1079.9999999865001

# STEAM related info to display when the espresso machine is idle
add_de1_text "off" 1536.000384000096 726.2999999909213 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1539.7503849375962 780.2999999902463 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 1543.5003858750963 780.2999999902463 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 1539.7503849375962 814.0499999898244 -justify right -anchor "ne" -text [translate "Steam Temp:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 1543.5003858750963 814.0499999898244 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 1539.7503849375962 847.7999999894025 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 390.00009750002437  -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 1543.5003858750963 847.7999999894025 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390.00009750002437  -textvariable {[steam_heater_temperature_text]} 

# when someone taps on the steam button
add_de1_button "off" "start_steam" 1311.0003277500819 415.79999999480253 1759.5004398751098 954.4499999880694

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it
add_de1_text "espresso" 960.0002400000599 726.2999999909213 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "espresso" 960.0002400000599 766.799999990415 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 
add_de1_text "espresso" 956.2502390625597 793.7999999900776 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "espresso" 960.0002400000599 793.7999999900776 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[timer_text]} 
add_de1_text "espresso" 956.2502390625597 827.5499999896557 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "espresso" 960.0002400000599 827.5499999896557 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_espresso_max_time_text]} 
add_de1_text "espresso" 956.2502390625597 861.2999999892338 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "espresso" 960.0002400000599 861.2999999892338 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[pressure_text]} 
add_de1_text "espresso" 956.2502390625597 895.0499999888119 -justify right -anchor "ne" -text [translate "Brew Temp:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "espresso" 960.0002400000599 895.0499999888119 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[watertemp_text]} 

if {[has_flowmeter] == 1} {
	add_de1_text "espresso" 956.2502390625597 928.79999998839 -justify right -anchor "ne" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
	add_de1_variable "espresso" 960.0002400000599 928.79999998839 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[waterflow_text]} 
	add_de1_text "espresso" 956.2502390625597 962.5499999879681 -justify right -anchor "ne" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
	add_de1_variable "espresso" 960.0002400000599 962.5499999879681 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[watervolume_text]} 
}

add_de1_button "espresso" "start_idle" 0.0 0.0 1920.0004800001198 1079.9999999865001

#add_btn_screen "espresso" "stop"
#add_de1_action "espresso" "do_espresso"


add_de1_text "off" 960.0002400000599 726.2999999909213 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 956.2502390625597 780.2999999902463 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 960.0002400000599 780.2999999902463 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "off" 956.2502390625597 814.0499999898244 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 960.0002400000599 814.0499999898244 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_espresso_pressure_text]} 


add_de1_text "off" 956.2502390625597 847.7999999894025 -justify right -anchor "ne" -text [translate "Brew Temp:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 960.0002400000599 847.7999999894025 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_espresso_temperature_text]} 

add_de1_variable "off" 956.2502390625597 881.5499999889806 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 390.00009750002437  -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 960.0002400000599 881.5499999889806 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[group_head_heater_temperature_text]} 
add_de1_button "off" "start_espresso" 711.0001777500444 394.1999999950725 1204.500301125075 974.6999999878163


#add_de1_text "espresso" 956.2502390625597 881.5499999889806 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
#add_de1_variable "espresso" 960.0002400000599 881.5499999889806 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "-" -fill "#2d3046" -width 390.00009750002437  -textvariable {[waterflow_text]} 

##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
add_de1_text "water" 382.5000956250239 726.2999999909213 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "water" 382.5000956250239 766.799999990415 -text "" -font Helv_9_bold -fill "#73768f" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

add_de1_text "water" 375.0000937500234 793.7999999900776 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "water" 378.75009468752364 793.7999999900776 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "-" -textvariable {[timer_text]} 
add_de1_text "water" 375.0000937500234 827.5499999896557 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "water" 378.75009468752364 827.5499999896557 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "-" -textvariable {[setting_water_max_time_text]} 
add_de1_text "water" 375.0000937500234 861.2999999892338 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "water" 378.75009468752364 861.2999999892338 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "-" -textvariable {[watertemp_text]} 

if {[has_flowmeter] == 1} {
	add_de1_text "water" 375.0000937500234 895.0499999888119 -justify right -anchor "ne" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
	add_de1_variable "water" 378.75009468752364 895.0499999888119 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[waterflow_text]} 
	add_de1_text "water" 375.0000937500234 928.79999998839 -justify right -anchor "ne" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
	add_de1_variable "water" 378.75009468752364 928.79999998839 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[watervolume_text]} 
}

add_de1_button "water" "start_idle" 0.0 0.0 1920.0004800001198 1079.9999999865001




add_de1_text "off" 382.5000956250239 726.2999999909213 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 375.0000937500234 780.2999999902463 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 378.75009468752364 780.2999999902463 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "-" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 375.0000937500234 814.0499999898244 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 378.75009468752364 814.0499999898244 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "-" -textvariable {[setting_water_temperature_text]} 

#add_de1_text "water" 1539.7503849375962 847.7999999894025 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
#add_de1_variable "water" 1543.5003858750963 847.7999999894025 -justify left -anchor "nw"  -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "-" -textvariable {[waterflow_text]} 
#add_de1_text "water" 1539.7503849375962 881.5499999889806 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
#add_de1_variable "water" 1543.5003858750963 881.5499999889806 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "-" -textvariable {[watervolume_text]} 
add_de1_button "off" "start_water" 157.50003937500983 413.09999999483625 606.0001515000379 955.7999999880526
#add_btn_screen "water" "stop"
#add_de1_action "water" "start_water"

##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
#add_de1_action "off" "stop"

# tapping the power button tells the DE1 to go to sleep, and it will after a few seconds, at which point we display the screen saver
add_de1_button "off" "start_sleep" 0.0 0.0 300.00007500001874 269.99999999662504
add_de1_text "sleep" 1875.000468750117 978.7499999877657 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
#add_de1_action "sleep" "do_sleep"

add_de1_button "off" "exit" 600.0001500000375 0.0 1312.500328125082 337.49999999578125
#add_de1_action "exit" "app_exit"


# Sleeping cafe photo obtained under creative commons from https://www.flickr.com/photos/curious_e/16300930781/

# turn the screen saver or splash screen off by tapping the page
add_de1_button "saver" "start_idle" 0.0 0.0 1920.0004800001198 1079.9999999865001

#add_btn_screen "saver" "off"
#add_btn_screen "splash" "off"

# the SETTINGS button currently exits the app
add_de1_button "off" "app_exit" 1650.000412500103 0.0 1950.0004875001218 269.99999999662504
#add_de1_action "settings" "do_settings"

