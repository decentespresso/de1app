set ::skindebug 0

######################################################
# the STEAM button and translatable text for it
add_de1_text "off" 510 1046 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 510 1046 -text [translate "STEAMING"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 500 1096 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 505 1096 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[timer_text]} 
add_de1_text "steam" 500 1144 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 505 1144 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[watertemp_text]} 
add_de1_text "steam" 500 1194 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 505 1194 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[pressure_text]} 

add_de1_button "off" "steam" 209 512 808 1312
add_btn_screen "steam" "off"
add_de1_action "steam" "do_steam"

######################################################
# the ESPRESSO button and translatable text for it
add_de1_text "off" 1280 1046 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso" 1280 1046 -text [translate "MAKING ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso" 1275 1096 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 1280 1096 -justify left -anchor "nw" -text "12 [translate seconds]" -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[timer_text]} 
add_de1_text "espresso" 1275 1144 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 1280 1144 -justify left -anchor "nw" -text [translate "91.8ºC"] -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[watertemp_text]} 
add_de1_text "espresso" 1275 1194 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 1280 1194 -justify left -anchor "nw" -text "9.2 [translate bar]" -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[pressure_text]} 
add_de1_text "espresso" 1275 1242 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 1280 1242 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "-" -fill "#2d3046" -width 520 -textvariable {[waterflow_text]} 
add_de1_button "off" "espresso" 948 482 1608 1343
add_btn_screen "espresso" "off"
add_de1_action "espresso" "do_espresso"

######################################################
# the HOT WATER button and translatable text for it
add_de1_text "off" 2048 1046 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 2058 1046 -text [translate "POURING WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 2053 1094 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 2058 1094 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 520 -text "-" -textvariable {[timer_text]} 
add_de1_text "water" 2053 1140 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 2058 1140 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 520 -text "-" -textvariable {[watertemp_text]} 
add_de1_text "water" 2053 1190 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 2058 1190 -justify left -anchor "nw"  -font Helv_8 -fill "#2d3046" -width 520 -text "-" -textvariable {[waterflow_text]} 
add_de1_text "water" 2053 1238 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 2058 1238 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 520 -text "-" -textvariable {[watervolume_text]} 
add_de1_button "off" "water" 1748 512 2348 1312
add_btn_screen "water" "off"
add_de1_action "water" "do_water"

######################################################
add_de1_action "off" "de1_stop_all"

# the SETTINGS button
add_de1_button "off" "settings" 2250 0 2558 284
add_de1_action "settings" "app_exit"

