set ::skindebug 0

######################################################
# the STEAM button and translatable text for it
add_de1_text "off" 383 786 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 383 786 -text [translate "STEAMING"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 375 824 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_variable "steam" 379 824 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 390 -textvariable {[timer_text]} 
add_de1_text "steam" 375 860 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_variable "steam" 379 860 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 390 -textvariable {[watertemp_text]} 
add_de1_text "steam" 375 897 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_variable "steam" 379 897 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 390 -textvariable {[pressure_text]} 

add_de1_button "off" "steam" 157 384 607 986
add_btn_screen "steam" "off"
add_de1_action "steam" "do_steam"

######################################################
# the ESPRESSO button and translatable text for it
add_de1_text "off" 962 786 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso" 962 786 -text [translate "MAKING ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso" 958 824 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_variable "espresso" 962 824 -justify left -anchor "nw" -text "12 [translate seconds]" -font Helv_8 -text "-" -fill "#2d3046" -width 390 -textvariable {[timer_text]} 
add_de1_text "espresso" 958 860 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_variable "espresso" 962 860 -justify left -anchor "nw" -text [translate "91.8ºC"] -font Helv_8 -text "-" -fill "#2d3046" -width 390 -textvariable {[watertemp_text]} 
add_de1_text "espresso" 958 897 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_variable "espresso" 962 897 -justify left -anchor "nw" -text "9.2 [translate bar]" -font Helv_8 -text "-" -fill "#2d3046" -width 390 -textvariable {[pressure_text]} 
add_de1_text "espresso" 958 933 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_variable "espresso" 962 933 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "-" -fill "#2d3046" -width 390 -textvariable {[waterflow_text]} 
add_de1_button "off" "espresso" 712 362 1209 1009
add_btn_screen "espresso" "off"
add_de1_action "espresso" "do_espresso"

######################################################
# the HOT WATER button and translatable text for it
add_de1_text "off" 1539 786 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 1547 786 -text [translate "POURING WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 1543 822 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_variable "water" 1547 822 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 390 -text "-" -textvariable {[timer_text]} 
add_de1_text "water" 1543 857 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_variable "water" 1547 857 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 390 -text "-" -textvariable {[watertemp_text]} 
add_de1_text "water" 1543 894 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_variable "water" 1547 894 -justify left -anchor "nw"  -font Helv_8 -fill "#2d3046" -width 390 -text "-" -textvariable {[waterflow_text]} 
add_de1_text "water" 1543 930 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_variable "water" 1547 930 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 390 -text "-" -textvariable {[watervolume_text]} 
add_de1_button "off" "water" 1314 384 1765 986
add_btn_screen "water" "off"
add_de1_action "water" "do_water"

######################################################
add_de1_action "off" "de1_stop_all"

# the SETTINGS button
add_de1_button "off" "settings" 1691 0 1923 213
add_de1_action "settings" "app_exit"


