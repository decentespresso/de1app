######################################################
# the STEAM button and translatable text for it
add_de1_text "off" 255 573 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 255 573 -text [translate "STEAMING"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 250 598 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "steam" 505 1196 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[timer_text]} 
add_de1_text "steam" 250 622 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "steam" 505 1244 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[watertemp_text]} 
add_de1_text "steam" 250 647 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "steam" 505 1294 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[pressure_text]} 

add_de1_button "off" "steam" 105 306 404 708
add_btn_screen "steam" "off"
add_de1_action "steam" "do_steam"

######################################################
# the ESPRESSO button and translatable text for it
add_de1_text "off" 640 573 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso" 640 573 -text [translate "MAKING ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso" 637 598 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "espresso" 1280 1196 -justify left -anchor "nw" -text "12 [translate seconds]" -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[timer_text]} 
add_de1_text "espresso" 637 622 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "espresso" 1280 1244 -justify left -anchor "nw" -text [translate "91.8ºC"] -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[watertemp_text]} 
add_de1_text "espresso" 637 647 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "espresso" 1280 1294 -justify left -anchor "nw" -text "9.2 [translate bar]" -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[pressure_text]} 
add_de1_text "espresso" 637 671 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "espresso" 1280 1342 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[waterflow_text]} 
add_de1_button "off" "espresso" 474 292 803 722
add_btn_screen "espresso" "off"
add_de1_action "espresso" "do_espresso"

######################################################
# the HOT WATER button and translatable text for it
add_de1_text "off" 1024 573 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 1029 573 -text [translate "POURING WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 1026 597 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "water" 2058 1194 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 260 -text "-" -textvariable {[timer_text]} 
add_de1_text "water" 1026 620 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "water" 2058 1240 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 260 -text "-" -textvariable {[watertemp_text]} 
add_de1_text "water" 1026 645 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "water" 2058 1290 -justify left -anchor "nw"  -font Helv_8 -fill "#2d3046" -width 260 -text "-" -textvariable {[waterflow_text]} 
add_de1_text "water" 1026 669 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "water" 2058 1338 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 260 -text "-" -textvariable {[watervolume_text]} 
add_de1_button "off" "water" 874 308 1173 707
add_btn_screen "water" "off"
add_de1_action "water" "do_water"

######################################################
add_de1_action "off" "de1_stop_all"

# the SETTINGS button
add_de1_button "off" "settings" 1125 0 1279 142
add_de1_action "settings" "app_exit"

