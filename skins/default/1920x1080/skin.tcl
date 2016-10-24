set ::skindebug 0

#add_de1_variable "off" 15.000003750000936 897.7499999887782 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390.00009750002437  -textvariable {[accelerometer_angle_text]} 

##############################################################################################################################################################################################################################################################################
# SETTINGS page

# tapping the logo exits the app
add_de1_button "off" "exit" 600.0001500000375 0.0 1312.500328125082 337.49999999578125 

# 1st batch of settings
add_de1_widget "settings_1" scale 37.50000937500234 168.74999999789063 {} -to 0 -from 20 -background #eaeafa -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 674.9999999915625  -width 112.50002812500702  -variable ::settings(preinfusion_time) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 180.00004500001123 877.4999999890313 -text [translate "Preinfusion time"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"

add_de1_widget "settings_1" scale 337.50008437502106 168.74999999789063 {} -to 0 -from 60 -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 674.9999999915625  -width 112.50002812500702  -variable ::settings(pressure_hold_time) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 480.00012000002994 877.4999999890313 -text [translate "Hold time"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"

add_de1_widget "settings_1" scale 637.5001593750397 168.74999999789063 {} -to 0 -from 60 -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 674.9999999915625  -width 112.50002812500702  -variable ::settings(espresso_decline_time) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 780.0001950000487 877.4999999890313 -text [translate "Decline time"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"

add_de1_widget "settings_1" scale 937.5002343750585 168.74999999789063 {} -to 0 -from 10 -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 674.9999999915625  -width 112.50002812500702  -variable ::settings(pressure_goal) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 1080.0002700000675 877.4999999890313 -text [translate "Pressure goal"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"

add_de1_widget "settings_1" scale 1237.5003093750772 168.74999999789063 {} -to 0 -from 10 -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 674.9999999915625  -width 112.50002812500702  -variable ::settings(pressure_end) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 1380.000345000086 877.4999999890313 -text [translate "Final pressure"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"

add_de1_widget "settings_1" scale 1537.500384375096 168.74999999789063 {} -to $::de1(min_temperature) -from $::de1(max_temperature)  -background #eaeafa -borderwidth 1 -bigincrement 1 -resolution 0.1 -length 674.9999999915625  -width 112.50002812500702  -variable ::settings(espresso_temperature) -font Helv_15_bold -sliderlength 100 -relief flat
add_de1_text "settings_1" 1680.000420000105 877.4999999890313 -text [translate "Temperature"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"


add_de1_widget "settings_2" scale 37.50000937500234 168.74999999789063 {} -to $::de1(steam_min_temperature) -from $::de1(steam_max_temperature) -background #eaeafa -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 674.9999999915625  -width 150.00003750000937  -variable ::settings(steam_temperature) -font Helv_15_bold -sliderlength 100
add_de1_text "settings_2" 232.5000581250145 877.4999999890313 -text [translate "Steam temperature"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"

add_de1_widget "settings_3" scale 37.50000937500234 168.74999999789063 {} -to $::de1(water_min_temperature) -from $::de1(water_max_temperature) -background #eaeafa -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 674.9999999915625  -width 150.00003750000937  -variable ::settings(water_temperature) -font Helv_15_bold -sliderlength 100
add_de1_text "settings_3" 232.5000581250145 877.4999999890313 -text [translate "Hot water temperature"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"


add_de1_text "settings_4" 232.5000581250145 877.4999999890313 -text [translate "Celsius vs Fahrenheit"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"
add_de1_text "settings_4" 232.5000581250145 742.4999999907188 -text [translate "ml vs oz"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"
add_de1_text "settings_4" 232.5000581250145 607.4999999924063 -text [translate "Name"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"
add_de1_text "settings_4" 232.5000581250145 472.4999999940938 -text [translate "Serial number"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"
add_de1_text "settings_4" 232.5000581250145 337.49999999578125 -text [translate "Wifi"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"
add_de1_text "settings_4" 232.5000581250145 202.49999999746876 -text [translate "versions"] -font Helv_10_bold -fill "#2d3046" -anchor "center" -width 300.00007500001874  -justify "center"


add_de1_button "off" "set_next_page off settings_1; page_show settings_1" 1500.0003750000935 0.0 1920.0004800001198 337.49999999578125 
add_de1_text "settings_1 settings_2 settings_3 settings_4" 1706.2504265626064 1025.999999987175 -text [translate "Done"] -font Helv_10_bold -fill "#eae9e9" -anchor "center"

# labels for PREHEAT tab on
add_de1_text "settings_1" 247.50006187501546 67.49999999915626 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_1" 720.0001800000449 67.49999999915626 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 1192.5002981250746 67.49999999915626 -text [translate "WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_1" 1661.2504153126038 67.49999999915626 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for ESPRESSO tab on
add_de1_text "settings_2" 247.50006187501546 67.49999999915626 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 720.0001800000449 67.49999999915626 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_2" 1192.5002981250746 67.49999999915626 -text [translate "WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_2" 1661.2504153126038 67.49999999915626 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for STEAM tab on
add_de1_text "settings_3" 247.50006187501546 67.49999999915626 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 720.0001800000449 67.49999999915626 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_3" 1192.5002981250746 67.49999999915626 -text [translate "WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "settings_3" 1661.2504153126038 67.49999999915626 -text [translate "OTHER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for HOT WATER tab on
add_de1_text "settings_4" 247.50006187501546 67.49999999915626 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 720.0001800000449 67.49999999915626 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 1192.5002981250746 67.49999999915626 -text [translate "WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "settings_4" 1661.2504153126038 67.49999999915626 -text [translate "OTHER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_1; page_show settings_1} 0.0 0.0 480.75012018753 126.89999999841376 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_2; page_show settings_2} 481.50012037503006 0.0 957.7502394375598 126.89999999841376 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_3; page_show settings_3} 958.5002396250599 0.0 1428.0003570000893 126.89999999841376 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {settings}] $::settings(sound_button_out); set_next_page off settings_4; page_show settings_4} 1428.750357187589 0.0 1920.0004800001198 126.89999999841376 
add_de1_button "settings_1 settings_2 settings_3 settings_4" {say [translate {done}] $::settings(sound_button_out); save_settings; set_next_page off off; page_show off} 1428.750357187589 965.2499999879344 1920.0004800001198 1079.9999999865001 



##############################################################################################################################################################################################################################################################################


##############################################################################################################################################################################################################################################################################
# the STEAM button and translatable text for it

add_de1_text "steam" 1536.000384000096 726.2999999909213 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "steam" 1536.000384000096 766.799999990415 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

# variables to display during steam
add_de1_text "steam" 1539.7503849375962 793.7999999900776 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "steam" 1543.5003858750963 793.7999999900776 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390.00009750002437  -textvariable {[steam_timer][translate "s"]} 
add_de1_text "steam" 1539.7503849375962 827.5499999896557 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "steam" 1543.5003858750963 827.5499999896557 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "steam" 1539.7503849375962 861.2999999892338 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "steam" 1543.5003858750963 861.2999999892338 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390.00009750002437  -textvariable {[steamtemp_text]} 
#add_de1_text "steam" 1539.7503849375962 895.0499999888119 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
#add_de1_variable "steam" 1543.5003858750963 895.0499999888119 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390.00009750002437  -textvariable {[pressure_text]} 


# 
#add_de1_action "steam" "do_steam"
# when it steam mode, tapping anywhere on the screen tells the DE1 to stop.
add_de1_button "steam" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0.0 0.0 1920.0004800001198 1079.9999999865001 

# STEAM related info to display when the espresso machine is idle
add_de1_text "off" 1536.000384000096 726.2999999909213 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1539.7503849375962 780.2999999902463 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 1543.5003858750963 780.2999999902463 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_steam_max_time_text]} 
add_de1_text "off" 1539.7503849375962 814.0499999898244 -justify right -anchor "ne" -text [translate "Steam temp:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 1543.5003858750963 814.0499999898244 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_steam_temperature_text]} 
add_de1_variable "off" 1539.7503849375962 847.7999999894025 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 390.00009750002437  -textvariable {[steam_heater_action_text]} 
add_de1_variable "off" 1543.5003858750963 847.7999999894025 -justify left -anchor "nw" -font Helv_8 -text "" -fill "#42465c" -width 390.00009750002437  -textvariable {[steam_heater_temperature_text]} 

# when someone taps on the steam button
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 1311.0003277500819 415.79999999480253 1759.5004398751098 954.4499999880694 

##############################################################################################################################################################################################################################################################################
# the ESPRESSO button and translatable text for it

add_de1_text "espresso" 960.0002400000599 726.2999999909213 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "espresso" 960.0002400000599 766.799999990415 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

add_de1_text "espresso" 960.0002400000599 793.7999999900776 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "espresso" 963.7502409375602 793.7999999900776 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[pour_timer][translate "s"]} 

add_de1_text "espresso" 960.0002400000599 827.5499999896557 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "espresso" 963.7502409375602 827.5499999896557 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_espresso_max_time][translate "s"]} 

add_de1_text "espresso" 960.0002400000599 861.2999999892338 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "espresso" 963.7502409375602 861.2999999892338 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[pressure_text]} 

add_de1_text "espresso" 960.0002400000599 895.0499999888119 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "espresso" 963.7502409375602 895.0499999888119 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[watertemp_text]} 

add_de1_button "espresso" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0.0 0.0 1920.0004800001198 1079.9999999865001 

#add_btn_screen "espresso" "stop"
#add_de1_action "espresso" "do_espresso"


add_de1_text "off" 960.0002400000599 726.2999999909213 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 956.2502390625597 780.2999999902463 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 960.0002400000599 780.2999999902463 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "off" 956.2502390625597 814.0499999898244 -justify right -anchor "ne" -text [translate "Peak pressure:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 960.0002400000599 814.0499999898244 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_espresso_pressure_text]} 


add_de1_text "off" 956.2502390625597 847.7999999894025 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 960.0002400000599 847.7999999894025 -justify left -anchor "nw" -text "" -font Helv_8  -fill "#42465c" -width 390.00009750002437  -textvariable {[setting_espresso_temperature_text]} 

add_de1_variable "off" 956.2502390625597 881.5499999889806 -justify right -anchor "ne" -text "" -font Helv_8 -fill "#7f879a" -width 390.00009750002437  -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 960.0002400000599 881.5499999889806 -justify left -anchor "nw" -text "" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -textvariable {[group_head_heater_temperature_text]} 

# we spell espresso with two SSs so that it is pronounced like Italians say it
add_de1_button "off" "say [translate {esspresso}] $::settings(sound_button_in);start_espresso" 711.0001777500444 394.1999999950725 1204.500301125075 974.6999999878163 


#add_de1_text "espresso" 956.2502390625597 881.5499999889806 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
#add_de1_variable "espresso" 960.0002400000599 881.5499999889806 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "" -fill "#2d3046" -width 390.00009750002437  -textvariable {[waterflow_text]} 

##############################################################################################################################################################################################################################################################################
# the HOT WATER button and translatable text for it
add_de1_text "water" 382.5000956250239 726.2999999909213 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_variable "water" 382.5000956250239 766.799999990415 -text "" -font Helv_9_bold -fill "#73768f" -anchor "center" -textvariable {[translate [de1_substate_text]]} 

add_de1_text "water" 375.0000937500234 793.7999999900776 -justify right -anchor "ne" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "water" 378.75009468752364 793.7999999900776 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "" -textvariable {[water_timer][translate "s"]} 
add_de1_text "water" 375.0000937500234 827.5499999896557 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "water" 378.75009468752364 827.5499999896557 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "water" 375.0000937500234 861.2999999892338 -justify right -anchor "ne" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "water" 378.75009468752364 861.2999999892338 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "" -textvariable {[watertemp_text]} 

add_de1_button "water" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0.0 0.0 1920.0004800001198 1079.9999999865001 




add_de1_text "off" 382.5000956250239 726.2999999909213 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 375.0000937500234 780.2999999902463 -justify right -anchor "ne" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 378.75009468752364 780.2999999902463 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "" -textvariable {[setting_water_max_time_text]} 
add_de1_text "off" 375.0000937500234 814.0499999898244 -justify right -anchor "ne" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
add_de1_variable "off" 378.75009468752364 814.0499999898244 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "" -textvariable {[setting_water_temperature_text]} 

#add_de1_text "water" 1539.7503849375962 847.7999999894025 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
#add_de1_variable "water" 1543.5003858750963 847.7999999894025 -justify left -anchor "nw"  -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "" -textvariable {[waterflow_text]} 
#add_de1_text "water" 1539.7503849375962 881.5499999889806 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 390.00009750002437 
#add_de1_variable "water" 1543.5003858750963 881.5499999889806 -justify left -anchor "nw" -font Helv_8 -fill "#42465c" -width 390.00009750002437  -text "" -textvariable {[watervolume_text]} 
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 157.50003937500983 413.09999999483625 606.0001515000379 955.7999999880526 
#add_btn_screen "water" "stop"
#add_de1_action "water" "start_water"

##############################################################################################################################################################################################################################################################################
# when state change to "off", send the command to the DE1 to go idle
#add_de1_action "off" "stop"

# tapping the power button tells the DE1 to go to sleep, and it will after a few seconds, at which point we display the screen saver
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0.0 0.0 300.00007500001874 269.99999999662504 
add_de1_button "saver" "say [translate {awake}] $::settings(sound_button_in);start_idle" 0.0 0.0 1920.0004800001198 1079.9999999865001 

add_de1_text "sleep" 1875.000468750117 978.7499999877657 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_button "sleep" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0.0 0.0 1920.0004800001198 1079.9999999865001 
#add_de1_action "sleep" "do_sleep"

add_de1_action "exit" "app_exit"


# Sleeping cafe photo obtained under creative commons from https://www.flickr.com/photos/curious_e/16300930781/

# turn the screen saver or splash screen off by tapping the page

#add_btn_screen "saver" "off"
#add_btn_screen "splash" "off"

# the SETTINGS button currently exits the app
#add_de1_button "off" "app_exit" 1650.000412500103 0.0 1950.0004875001218 269.99999999662504 
#add_de1_action "settings" "do_settings"

