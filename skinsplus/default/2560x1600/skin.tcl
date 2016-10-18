set ::skindebug 0

##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it

	add_de1_text "steam" 1790 640 -text [translate "STEAM"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" 
	add_de1_variable "steam" 1790 700 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "nw" -textvariable {[translate [de1_substate_text]]} 

	# variables to display during steam
	add_de1_text "steam" 1790 780 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width 520

	add_de1_text "steam" 1790 830 -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "steam" 2310 830 -justify left -anchor "ne" -font Helv_8 -text "-" -fill "#42465c" -width 520 -textvariable {[steam_timer][translate "s"]} 
	add_de1_text "steam" 1790 880 -justify right -anchor "nw" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "steam" 2310 880 -justify left -anchor "ne" -font Helv_8 -text "-" -fill "#42465c" -width 520 -textvariable {[setting_steam_max_time][translate "s"]} 

	add_de1_text "steam" 1790 970 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width 520
	add_de1_text "steam" 1790 1020 -justify right -anchor "nw" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "steam" 2310 1020 -justify left -anchor "ne" -font Helv_8 -text "-" -fill "#42465c" -width 520 -textvariable {[steamtemp_text]} 
	add_de1_text "steam" 1790 1070 -justify right -anchor "nw" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "steam" 2310 1070 -justify left -anchor "ne" -font Helv_8 -text "-" -fill "#42465c" -width 520 -textvariable {[pressure_text]} 

	add_de1_text "steam" 1790 1120 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "steam" 2310 1120 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[waterflow_text]} 
	add_de1_text "steam" 1790 1170 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "steam" 2310 1170 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[watervolume_text]} 

# when it steam mode, tapping anywhere on the screen tells the DE1 to stop.
add_de1_button "steam" "say [translate {stop}] $::settings(sound_button_out);start_idle" 0 0 2560 1600

# STEAM related info to display when the espresso machine is idle
add_de1_text "off" 2048 1076 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 2053 1156 -justify right -anchor "ne" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 2058 1156 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 520 -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 2053 1206 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 2058 1206 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#42465c" -width 520 -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 2053 1256 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 520 -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 2058 1256 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[steam_heater_temperature_text]} 

# when someone taps on the steam button
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_out);start_steam" 1748 616 2346 1414

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it

	add_de1_text "espresso" 980 620 -text [translate "ESPRESSO"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" 
	add_de1_variable "espresso" 980 680 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "nw" -textvariable {[translate [de1_substate_text]]} 

	add_de1_text "espresso" 980 785 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width 520

	add_de1_text "espresso" 980 840 -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "espresso" 1570 840 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[timer][translate "s"]} 

	add_de1_text "espresso" 980 890 -justify right -anchor "nw" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "espresso" 1570 890 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width 520 -textvariable {[setting_espresso_max_time][translate "s"]} 

	add_de1_text "espresso" 980 940 -justify right -anchor "nw" -text [translate "Preinfusion:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "espresso" 1570 940 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width 520 -textvariable {[preinfusion_timer][translate "s"]} 

	add_de1_text "espresso" 980 990 -justify right -anchor "nw" -text [translate "Pouring:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "espresso" 1570 990 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width 520 -textvariable {[pour_timer][translate "s"]} 


	add_de1_text "espresso" 980 1070 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width 520

	add_de1_text "espresso" 980 1120 -justify right -anchor "nw" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "espresso" 1570 1120 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[pressure_text]} 
	add_de1_text "espresso" 980 1170 -justify right -anchor "nw" -text [translate "Basket temp:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "espresso" 1570 1170 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[watertemp_text]} 
	add_de1_text "espresso" 980 1220 -justify right -anchor "nw" -text [translate "Mix temp:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "espresso" 1570 1220 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[mixtemp_text]} 


	add_de1_text "espresso" 980 1270 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "espresso" 1570 1270 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[waterflow_text]} 
	add_de1_text "espresso" 980 1320 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "espresso" 1570 1320 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[watervolume_text]} 

	if {$::settings(flight_mode_enable) == 1} {
		add_de1_text "espresso" 980 1370 -justify right -anchor "nw" -text [translate "Flight mode:"] -font Helv_8 -fill "#7f879a" -width 520
		add_de1_variable "espresso" 1570 1370 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[accelerometer_angle]º} 
	}

add_de1_button "espresso" "say [translate {stop}] $::settings(sound_button_out);start_idle" 0 0 2560 1600

add_de1_text "off" 1280 1076 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1275 1156 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 1280 1156 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520 -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "off" 1275 1206 -justify right -anchor "ne" -text [translate "Peak pressure:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 1280 1206 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[setting_espresso_pressure_text]} 


add_de1_text "off" 1275 1256 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 1280 1256 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 520 -textvariable {[setting_espresso_temperature_text]} 

add_de1_variable "off" 1275 1306 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 520 -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 1280 1306 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[group_head_heater_temperature_text]} 

# we spell espresso with two SSs so that it is pronounced like Italians say it
add_de1_button "off" "say [translate {esspresso}] $::settings(sound_button_out);start_espresso" 948 584 1606 1444

##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
	add_de1_text "water" 240 640 -text [translate "HOT WATER"] -font Helv_15_bold -fill "#2d3046" -anchor "nw" 
	add_de1_variable "water" 240 700 -text "" -font Helv_9_bold -fill "#73768f" -anchor "nw" -textvariable {[translate [de1_substate_text]]} 

	add_de1_text "water" 240 780 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width 520
	#add_de1_text "water" 500 920 -justify right -anchor "center" -text [translate "- Time -"] -font Helv_10_bold -fill "#42465c" -width 520
	add_de1_text "water" 240 830 -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "water" 770 830 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width 520 -text "-" -textvariable {[water_timer][translate "s"]} 
	add_de1_text "water" 240 880 -justify right -anchor "nw" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "water" 770 880 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width 520 -text "-" -textvariable {[setting_water_max_time][translate "s"]} 

	add_de1_text "water" 240 970 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width 520
	#add_de1_text "water" 500 1120 -justify right -anchor "center" -text [translate "- Characteristics -"] -font Helv_10_bold -fill "#42465c" -width 520

	add_de1_text "water" 240 1020 -justify right -anchor "nw" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "water" 770 1020 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width 520 -text "-" -textvariable {[watertemp_text]} 


	add_de1_text "water" 240 1070 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "water" 770 1070 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[waterflow_text]} 
	add_de1_text "water" 240 1120 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "water" 770 1120 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[watervolume_text]} 

add_de1_button "water" "say [translate {stop}] $::settings(sound_button_out);start_idle" 0 0 2560 1600




add_de1_text "off" 510 1076 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 500 1156 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 505 1156 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520 -text "-" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 500 1206 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "off" 505 1206 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520 -text "-" -textvariable {[setting_water_temperature_text]} 

#add_de1_text "water" 2053 1256 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 520
#add_de1_variable "water" 2058 1256 -justify left -anchor "nw"  -font Helv_8 -fill "#42465c" -width 520 -text "-" -textvariable {[waterflow_text]} 
#add_de1_text "water" 2053 1306 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 520
#add_de1_variable "water" 2058 1306 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 520 -text "-" -textvariable {[watervolume_text]} 
add_de1_button "off" "say [translate {water}] $::settings(sound_button_out);start_water" 210 612 808 1416
#add_btn_screen "water" "stop"
#add_de1_action "water" "start_water"

##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
#add_de1_action "off" "stop"

# tapping the power button tells the DE1 to go to sleep, and it will after a few seconds, at which point we display the screen saver
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_out);start_sleep" 0 0 400 400
add_de1_button "saver" "say [translate {awake}] $::settings(sound_button_out);start_idle" 0 0 2560 1600

add_de1_text "sleep" 2500 1450 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_button "sleep" "say [translate {sleep}] $::settings(sound_button_out);start_sleep" 0 0 2560 1600
#add_de1_action "sleep" "do_sleep"

add_de1_button "off" "exit" 800 0 1750 500
#add_de1_action "exit" "app_exit"


# Sleeping cafe photo obtained under creative commons from https://www.flickr.com/photos/curious_e/16300930781/

# turn the screen saver or splash screen off by tapping the page

#add_btn_screen "saver" "off"
#add_btn_screen "splash" "off"

# the SETTINGS button currently exits the app
#add_de1_button "off" "app_exit" 2200 0 2600 400
#add_de1_action "settings" "do_settings"
