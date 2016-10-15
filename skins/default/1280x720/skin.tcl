set ::skindebug 0

#add_de1_variable "off" 10 598.5005985005985 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[accelerometer_angle_text]} 


##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it

if {[has_flowmeter] == 0} {

	add_de1_text "steam" 1024 484.2004842004842 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
	add_de1_variable "steam" 1024 511.2005112005112 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

	# variables to display during steam
	add_de1_text "steam" 1026 529.2005292005292 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "steam" 1029 529.2005292005292 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[timer_text]} 
	add_de1_text "steam" 1026 551.7005517005517 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "steam" 1029 551.7005517005517 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[setting_steam_max_time_text]} 
	add_de1_text "steam" 1026 574.2005742005741 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "steam" 1029 574.2005742005741 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[steamtemp_text]} 
	add_de1_text "steam" 1026 596.7005967005966 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "steam" 1029 596.7005967005966 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[pressure_text]} 

} else {
	add_de1_text "steam" 895 288.000288000288 -text [translate "STEAM"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" 
	add_de1_variable "steam" 895 315.00031500031497 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "nw" -textvariable {[translate [de1_substate_text]]} 

	# variables to display during steam
	add_de1_text "steam" 895 360.00036000036 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width 260 

	add_de1_text "steam" 895 382.5003825003825 -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "steam" 1155 382.5003825003825 -justify left -anchor "ne" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[timer][translate "s"]} 
	add_de1_text "steam" 895 405.000405000405 -justify right -anchor "nw" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "steam" 1155 405.000405000405 -justify left -anchor "ne" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[setting_steam_max_time][translate "s"]} 

	add_de1_text "steam" 895 450.00045000045 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width 260 
	add_de1_text "steam" 895 472.5004725004725 -justify right -anchor "nw" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "steam" 1155 472.5004725004725 -justify left -anchor "ne" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[steamtemp_text]} 
	add_de1_text "steam" 895 495.000495000495 -justify right -anchor "nw" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "steam" 1155 495.000495000495 -justify left -anchor "ne" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[pressure_text]} 

	add_de1_text "steam" 895 517.5005175005175 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "steam" 1155 517.5005175005175 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[waterflow_text]} 
	add_de1_text "steam" 895 540.00054000054 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "steam" 1155 540.00054000054 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[watervolume_text]} 
}


# 
#add_de1_action "steam" "do_steam"
# when it steam mode, tapping anywhere on the screen tells the DE1 to stop.
add_de1_button "steam" "say [translate {stop}] $::settings(sound_button_out);start_idle" 0 0.0 1280 720.00072000072

# STEAM related info to display when the espresso machine is idle
add_de1_text "off" 1024 484.2004842004842 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1026 520.2005202005201 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 1029 520.2005202005201 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 1026 542.7005427005427 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 1029 542.7005427005427 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 260  -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 1026 565.2005652005652 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 260  -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 1029 565.2005652005652 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 260  -textvariable {[steam_heater_temperature_text]} 

# when someone taps on the steam button
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_out);start_steam" 874 277.2002772002772 1173 636.3006363006363

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it

if {[has_flowmeter] == 0} {

	add_de1_text "espresso" 640 484.2004842004842 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
	add_de1_variable "espresso" 640 511.2005112005112 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 


	add_de1_text "espresso" 640 529.2005292005292 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 700 529.2005292005292 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[timer][translate "s"]} 

	add_de1_text "espresso" 640 551.7005517005517 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 640 551.7005517005517 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time][translate "s"]} 

	add_de1_text "espresso" 640 574.2005742005741 -justify right -anchor "ne" -text [translate "Preinfusion:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 640 574.2005742005741 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time][translate "s"]} 

	add_de1_text "espresso" 640 596.7005967005966 -justify right -anchor "ne" -text [translate "Pouring:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 640 596.7005967005966 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time][translate "s"]} 

	add_de1_text "espresso" 640 619.2006192006191 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 640 619.2006192006191 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[pressure_text]} 
	add_de1_text "espresso" 640 641.7006417006417 -justify right -anchor "ne" -text [translate "Basket Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 640 641.7006417006417 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[watertemp_text]} 
	add_de1_text "espresso" 640 664.2006642006642 -justify right -anchor "ne" -text [translate "Mix Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 640 664.2006642006642 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[watertemp_text]} 

} else {

	add_de1_text "espresso" 490 279.00027900027897 -text [translate "ESPRESSO"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" 
	add_de1_variable "espresso" 490 306.000306000306 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "nw" -textvariable {[translate [de1_substate_text]]} 

	add_de1_text "espresso" 490 360.00036000036 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width 260 

	add_de1_text "espresso" 490 382.5003825003825 -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 785 382.5003825003825 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[timer][translate "s"]} 

	add_de1_text "espresso" 490 405.000405000405 -justify right -anchor "nw" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 785 405.000405000405 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time][translate "s"]} 

	add_de1_text "espresso" 490 427.50042750042746 -justify right -anchor "nw" -text [translate "Preinfusion:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 785 427.50042750042746 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {4[translate "s"]} 

	add_de1_text "espresso" 490 450.00045000045 -justify right -anchor "nw" -text [translate "Pouring:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 785 450.00045000045 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {0[translate "s"]} 


	add_de1_text "espresso" 490 495.000495000495 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width 260 

	add_de1_text "espresso" 490 517.5005175005175 -justify right -anchor "nw" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 785 517.5005175005175 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[pressure_text]} 
	add_de1_text "espresso" 490 540.00054000054 -justify right -anchor "nw" -text [translate "Basket temp:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 785 540.00054000054 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[watertemp_text]} 
	add_de1_text "espresso" 490 562.5005625005625 -justify right -anchor "nw" -text [translate "Mix temp:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 785 562.5005625005625 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[watertemp_text]} 


	add_de1_text "espresso" 490 585.000585000585 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 785 585.000585000585 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[waterflow_text]} 
	add_de1_text "espresso" 490 607.5006075006074 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "espresso" 785 607.5006075006074 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[watervolume_text]} 
}

add_de1_button "espresso" "say [translate {stop}] $::settings(sound_button_out);start_idle" 0 0.0 1280 720.00072000072

#add_btn_screen "espresso" "stop"
#add_de1_action "espresso" "do_espresso"


add_de1_text "off" 640 484.2004842004842 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 637 520.2005202005201 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 520.2005202005201 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "off" 637 542.7005427005427 -justify right -anchor "ne" -text [translate "Peak pressure:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 542.7005427005427 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[setting_espresso_pressure_text]} 


add_de1_text "off" 637 565.2005652005652 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 640 565.2005652005652 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 260  -textvariable {[setting_espresso_temperature_text]} 

add_de1_variable "off" 637 587.7005877005877 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 260  -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 640 587.7005877005877 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[group_head_heater_temperature_text]} 

# we spell espresso with two SSs so that it is pronounced like Italians say it
add_de1_button "off" "say [translate {esspresso}] $::settings(sound_button_out);start_espresso" 474 262.8002628002628 803 649.8006498006498


#add_de1_text "espresso" 637 587.7005877005877 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "espresso" 640 587.7005877005877 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "-" -fill "#2d3046" -width 260  -textvariable {[waterflow_text]} 

##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
if {[has_flowmeter] == 0} {
	add_de1_text "water" 255 484.2004842004842 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
	add_de1_variable "water" 255 511.2005112005112 -text "" -font Helv_9_bold -fill "#73768f" -anchor "center" -textvariable {[translate [de1_substate_text]]} 

	add_de1_text "water" 250 529.2005292005292 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "water" 252 529.2005292005292 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[timer_text]z} 
	add_de1_text "water" 250 551.7005517005517 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "water" 252 551.7005517005517 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[setting_water_max_time_text]} 
	add_de1_text "water" 250 574.2005742005741 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "water" 252 574.2005742005741 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[watertemp_text]} 

} else {

	add_de1_text "water" 120 288.000288000288 -text [translate "HOT WATER"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" 
	add_de1_variable "water" 120 315.00031500031497 -text "" -font Helv_9_bold -fill "#73768f" -anchor "nw" -textvariable {[translate [de1_substate_text]]} 

	add_de1_text "water" 120 360.00036000036 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width 260 
	#add_de1_text "water" 250 414.00041400041397 -justify right -anchor "center" -text [translate "- Time -"] -font Helv_10_bold -fill "#42465c" -width 260 
	add_de1_text "water" 120 382.5003825003825 -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "water" 385 382.5003825003825 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[timer][translate "s"]} 
	add_de1_text "water" 120 405.000405000405 -justify right -anchor "nw" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "water" 385 405.000405000405 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[setting_water_max_time][translate "s"]} 

	add_de1_text "water" 120 450.00045000045 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width 260 
	#add_de1_text "water" 250 504.000504000504 -justify right -anchor "center" -text [translate "- Characteristics -"] -font Helv_10_bold -fill "#42465c" -width 260 

	add_de1_text "water" 120 472.5004725004725 -justify right -anchor "nw" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "water" 385 472.5004725004725 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[watertemp_text]} 


	add_de1_text "water" 120 495.000495000495 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "water" 385 495.000495000495 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[waterflow_text]} 
	add_de1_text "water" 120 517.5005175005175 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 260 
	add_de1_variable "water" 385 517.5005175005175 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 260  -textvariable {[watervolume_text]} 
}

add_de1_button "water" "say [translate {stop}] $::settings(sound_button_out);start_idle" 0 0.0 1280 720.00072000072




add_de1_text "off" 255 484.2004842004842 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 250 520.2005202005201 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 252 520.2005202005201 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 250 542.7005427005427 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 260 
add_de1_variable "off" 252 542.7005427005427 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[setting_water_temperature_text]} 

#add_de1_text "water" 1026 565.2005652005652 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "water" 1029 565.2005652005652 -justify left -anchor "nw"  -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[waterflow_text]} 
#add_de1_text "water" 1026 587.7005877005877 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 260 
#add_de1_variable "water" 1029 587.7005877005877 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 260  -text "-" -textvariable {[watervolume_text]} 
add_de1_button "off" "say [translate {water}] $::settings(sound_button_out);start_water" 105 275.4002754002754 404 637.2006372006372
#add_btn_screen "water" "stop"
#add_de1_action "water" "start_water"

##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
#add_de1_action "off" "stop"

# tapping the power button tells the DE1 to go to sleep, and it will after a few seconds, at which point we display the screen saver
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_out);start_sleep" 0 0.0 200 180.00018000018
add_de1_button "saver" "say [translate {awake}] $::settings(sound_button_out);start_idle" 0 0.0 1280 720.00072000072

add_de1_text "sleep" 1250 652.5006525006524 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_button "sleep" "say [translate {sleep}] $::settings(sound_button_out);start_sleep" 0 0.0 1280 720.00072000072
#add_de1_action "sleep" "do_sleep"

add_de1_button "off" "exit" 400 0.0 875 225.000225000225
#add_de1_action "exit" "app_exit"


# Sleeping cafe photo obtained under creative commons from https://www.flickr.com/photos/curious_e/16300930781/

# turn the screen saver or splash screen off by tapping the page

#add_btn_screen "saver" "off"
#add_btn_screen "splash" "off"

# the SETTINGS button currently exits the app
#add_de1_button "off" "app_exit" 1100 0.0 1300 180.00018000018
#add_de1_action "settings" "do_settings"

