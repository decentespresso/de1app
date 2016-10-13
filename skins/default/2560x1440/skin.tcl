set ::skindebug 0

#add_de1_variable "off" 20 1197.001197001197 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520  -textvariable {[accelerometer_angle_text]} 


##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it

if {[has_flowmeter] == 0} {

	add_de1_text "steam" 2048 968.4009684009684 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
	add_de1_variable "steam" 2048 1022.4010224010224 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

	# variables to display during steam
	add_de1_text "steam" 2053 1058.4010584010584 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "steam" 2058 1058.4010584010584 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 520  -textvariable {[timer_text]} 
	add_de1_text "steam" 2053 1103.4011034011035 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "steam" 2058 1103.4011034011035 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 520  -textvariable {[setting_steam_max_time_text]} 
	add_de1_text "steam" 2053 1148.4011484011482 -justify right -anchor "ne" -text [translate "Steam Temp:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "steam" 2058 1148.4011484011482 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 520  -textvariable {[steamtemp_text]} 
	add_de1_text "steam" 2053 1193.4011934011933 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "steam" 2058 1193.4011934011933 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 520  -textvariable {[pressure_text]} 

} else {
	add_de1_text "steam" 1790 576.000576000576 -text [translate "STEAM"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" 
	add_de1_variable "steam" 1790 630.0006300006299 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "nw" -textvariable {[translate [de1_substate_text]]} 

	# variables to display during steam
	add_de1_text "steam" 1790 720.00072000072 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width 520 

	add_de1_text "steam" 1790 765.000765000765 -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "steam" 2310 765.000765000765 -justify left -anchor "ne" -font Helv_8 -text "-" -fill "#42465c" -width 520  -textvariable {[timer][translate "s"]} 
	add_de1_text "steam" 1790 810.00081000081 -justify right -anchor "nw" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "steam" 2310 810.00081000081 -justify left -anchor "ne" -font Helv_8 -text "-" -fill "#42465c" -width 520  -textvariable {[setting_steam_max_time][translate "s"]} 

	add_de1_text "steam" 1790 900.0009000009 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width 520 
	add_de1_text "steam" 1790 945.000945000945 -justify right -anchor "nw" -text [translate "Steam Temp:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "steam" 2310 945.000945000945 -justify left -anchor "ne" -font Helv_8 -text "-" -fill "#42465c" -width 520  -textvariable {[steamtemp_text]} 
	add_de1_text "steam" 1790 990.00099000099 -justify right -anchor "nw" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "steam" 2310 990.00099000099 -justify left -anchor "ne" -font Helv_8 -text "-" -fill "#42465c" -width 520  -textvariable {[pressure_text]} 

	add_de1_text "steam" 1790 1035.001035001035 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "steam" 2310 1035.001035001035 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[waterflow_text]} 
	add_de1_text "steam" 1790 1080.00108000108 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "steam" 2310 1080.00108000108 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[watervolume_text]} 
}


# 
#add_de1_action "steam" "do_steam"
# when it steam mode, tapping anywhere on the screen tells the DE1 to stop.
add_de1_button "steam" "start_idle" 0 0.0 2560 1440.00144000144

# STEAM related info to display when the espresso machine is idle
add_de1_text "off" 2048 968.4009684009684 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 2053 1040.4010404010403 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 2058 1040.4010404010403 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 520  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 2053 1085.4010854010853 -justify right -anchor "ne" -text [translate "Steam Temp:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 2058 1085.4010854010853 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 520  -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 2053 1130.4011304011303 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 520  -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 2058 1130.4011304011303 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520  -textvariable {[steam_heater_temperature_text]} 

# when someone taps on the steam button
add_de1_button "off" "start_steam" 1748 554.4005544005544 2346 1272.6012726012725

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it

if {[has_flowmeter] == 0} {

	add_de1_text "espresso" 1280 968.4009684009684 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
	add_de1_variable "espresso" 1280 1022.4010224010224 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 


	add_de1_text "espresso" 1280 1058.4010584010584 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1400 1058.4010584010584 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[timer][translate "s"]} 

	add_de1_text "espresso" 1280 1103.4011034011035 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1280 1103.4011034011035 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520  -textvariable {[setting_espresso_max_time][translate "s"]} 

	add_de1_text "espresso" 1280 1148.4011484011482 -justify right -anchor "ne" -text [translate "Pre-infusion:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1280 1148.4011484011482 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520  -textvariable {[setting_espresso_max_time][translate "s"]} 

	add_de1_text "espresso" 1280 1193.4011934011933 -justify right -anchor "ne" -text [translate "Pouring:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1280 1193.4011934011933 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520  -textvariable {[setting_espresso_max_time][translate "s"]} 

	add_de1_text "espresso" 1280 1238.4012384012383 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1280 1238.4012384012383 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[pressure_text]} 
	add_de1_text "espresso" 1280 1283.4012834012833 -justify right -anchor "ne" -text [translate "Basket Temp:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1280 1283.4012834012833 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[watertemp_text]} 
	add_de1_text "espresso" 1280 1328.4013284013283 -justify right -anchor "ne" -text [translate "Mix Temp:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1280 1328.4013284013283 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[watertemp_text]} 

} else {

	add_de1_text "espresso" 980 558.0005580005579 -text [translate "ESPRESSO"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" 
	add_de1_variable "espresso" 980 612.000612000612 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "nw" -textvariable {[translate [de1_substate_text]]} 

	add_de1_text "espresso" 980 720.00072000072 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width 520 

	add_de1_text "espresso" 980 765.000765000765 -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1570 765.000765000765 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[timer][translate "s"]} 

	add_de1_text "espresso" 980 810.00081000081 -justify right -anchor "nw" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1570 810.00081000081 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width 520  -textvariable {[setting_espresso_max_time][translate "s"]} 

	add_de1_text "espresso" 980 855.0008550008549 -justify right -anchor "nw" -text [translate "Pre-infusion:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1570 855.0008550008549 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width 520  -textvariable {4[translate "s"]} 

	add_de1_text "espresso" 980 900.0009000009 -justify right -anchor "nw" -text [translate "Pouring:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1570 900.0009000009 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width 520  -textvariable {0[translate "s"]} 


	add_de1_text "espresso" 980 990.00099000099 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width 520 

	add_de1_text "espresso" 980 1035.001035001035 -justify right -anchor "nw" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1570 1035.001035001035 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[pressure_text]} 
	add_de1_text "espresso" 980 1080.00108000108 -justify right -anchor "nw" -text [translate "Basket Temp:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1570 1080.00108000108 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[watertemp_text]} 
	add_de1_text "espresso" 980 1125.001125001125 -justify right -anchor "nw" -text [translate "Mix Temp:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1570 1125.001125001125 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[watertemp_text]} 


	add_de1_text "espresso" 980 1170.00117000117 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1570 1170.00117000117 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[waterflow_text]} 
	add_de1_text "espresso" 980 1215.0012150012149 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "espresso" 1570 1215.0012150012149 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[watervolume_text]} 
}

add_de1_button "espresso" "start_idle" 0 0.0 2560 1440.00144000144

#add_btn_screen "espresso" "stop"
#add_de1_action "espresso" "do_espresso"


add_de1_text "off" 1280 968.4009684009684 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1275 1040.4010404010403 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 1280 1040.4010404010403 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "off" 1275 1085.4010854010853 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 1280 1085.4010854010853 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[setting_espresso_pressure_text]} 


add_de1_text "off" 1275 1130.4011304011303 -justify right -anchor "ne" -text [translate "Head Temp:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 1280 1130.4011304011303 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520  -textvariable {[setting_espresso_temperature_text]} 

add_de1_variable "off" 1275 1175.4011754011754 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 520  -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 1280 1175.4011754011754 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[group_head_heater_temperature_text]} 
add_de1_button "off" "start_espresso" 948 525.6005256005255 1606 1299.6012996012996


#add_de1_text "espresso" 1275 1175.4011754011754 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 520 
#add_de1_variable "espresso" 1280 1175.4011754011754 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "-" -fill "#2d3046" -width 520  -textvariable {[waterflow_text]} 

##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
if {[has_flowmeter] == 0} {
	add_de1_text "water" 510 968.4009684009684 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
	add_de1_variable "water" 510 1022.4010224010224 -text "" -font Helv_9_bold -fill "#73768f" -anchor "center" -textvariable {[translate [de1_substate_text]]} 

	add_de1_text "water" 500 1058.4010584010584 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "water" 505 1058.4010584010584 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520  -text "-" -textvariable {[timer_text]z} 
	add_de1_text "water" 500 1103.4011034011035 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "water" 505 1103.4011034011035 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520  -text "-" -textvariable {[setting_water_max_time_text]} 
	add_de1_text "water" 500 1148.4011484011482 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "water" 505 1148.4011484011482 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520  -text "-" -textvariable {[watertemp_text]} 

} else {

	add_de1_text "water" 240 576.000576000576 -text [translate "HOT WATER"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" 
	add_de1_variable "water" 240 630.0006300006299 -text "" -font Helv_9_bold -fill "#73768f" -anchor "nw" -textvariable {[translate [de1_substate_text]]} 

	add_de1_text "water" 240 720.00072000072 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width 520 
	#add_de1_text "water" 500 828.0008280008279 -justify right -anchor "center" -text [translate "- Time -"] -font Helv_10_bold -fill "#42465c" -width 520 
	add_de1_text "water" 240 765.000765000765 -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "water" 770 765.000765000765 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width 520  -text "-" -textvariable {[timer][translate "s"]} 
	add_de1_text "water" 240 810.00081000081 -justify right -anchor "nw" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "water" 770 810.00081000081 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width 520  -text "-" -textvariable {[setting_water_max_time][translate "s"]} 

	add_de1_text "water" 240 900.0009000009 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width 520 
	#add_de1_text "water" 500 1008.001008001008 -justify right -anchor "center" -text [translate "- Characteristics -"] -font Helv_10_bold -fill "#42465c" -width 520 

	add_de1_text "water" 240 945.000945000945 -justify right -anchor "nw" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "water" 770 945.000945000945 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width 520  -text "-" -textvariable {[watertemp_text]} 


	add_de1_text "water" 240 990.00099000099 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "water" 770 990.00099000099 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[waterflow_text]} 
	add_de1_text "water" 240 1035.001035001035 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 520 
	add_de1_variable "water" 770 1035.001035001035 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520  -textvariable {[watervolume_text]} 
}

add_de1_button "water" "start_idle" 0 0.0 2560 1440.00144000144




add_de1_text "off" 510 968.4009684009684 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 500 1040.4010404010403 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 505 1040.4010404010403 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520  -text "-" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 500 1085.4010854010853 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 520 
add_de1_variable "off" 505 1085.4010854010853 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520  -text "-" -textvariable {[setting_water_temperature_text]} 

#add_de1_text "water" 2053 1130.4011304011303 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 520 
#add_de1_variable "water" 2058 1130.4011304011303 -justify left -anchor "nw"  -font Helv_8 -fill "#42465c" -width 520  -text "-" -textvariable {[waterflow_text]} 
#add_de1_text "water" 2053 1175.4011754011754 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 520 
#add_de1_variable "water" 2058 1175.4011754011754 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520  -text "-" -textvariable {[watervolume_text]} 
add_de1_button "off" "start_water" 210 550.8005508005508 808 1274.4012744012743
#add_btn_screen "water" "stop"
#add_de1_action "water" "start_water"

##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
#add_de1_action "off" "stop"

# tapping the power button tells the DE1 to go to sleep, and it will after a few seconds, at which point we display the screen saver
add_de1_button "off" "start_sleep" 0 0.0 400 360.00036000036
add_de1_text "sleep" 2500 1305.001305001305 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
#add_de1_action "sleep" "do_sleep"

add_de1_button "off" "exit" 800 0.0 1750 450.00045000045
#add_de1_action "exit" "app_exit"


# Sleeping cafe photo obtained under creative commons from https://www.flickr.com/photos/curious_e/16300930781/

# turn the screen saver or splash screen off by tapping the page
add_de1_button "saver" "start_idle" 0 0.0 2560 1440.00144000144

#add_btn_screen "saver" "off"
#add_btn_screen "splash" "off"

# the SETTINGS button currently exits the app
add_de1_button "off" "app_exit" 2200 0.0 2600 360.00036000036
#add_de1_action "settings" "do_settings"

