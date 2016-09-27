set ::skindebug 0

######################################################
# the STEAM button and translatable text for it
add_de1_text "off" 255 523 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 255 523 -text [translate "STEAMING"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 250 548 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "steam" 252 548 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[timer_text]} 
add_de1_text "steam" 250 572 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "steam" 252 572 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[watertemp_text]} 
add_de1_text "steam" 250 597 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "steam" 252 597 -justify left -anchor "nw" -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[pressure_text]} 

add_de1_button "off" "steam" 104 256 404 656
add_btn_screen "steam" "off"
add_de1_action "steam" "do_steam"

######################################################
# the ESPRESSO button and translatable text for it
add_de1_text "off" 640 523 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso" 640 523 -text [translate "MAKING ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso" 637 548 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "espresso" 640 548 -justify left -anchor "nw" -text "12 [translate seconds]" -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[timer_text]} 
add_de1_text "espresso" 637 572 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "espresso" 640 572 -justify left -anchor "nw" -text [translate "91.8ºC"] -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[watertemp_text]} 
add_de1_text "espresso" 637 597 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "espresso" 640 597 -justify left -anchor "nw" -text "9.2 [translate bar]" -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[pressure_text]} 
add_de1_text "espresso" 637 621 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "espresso" 640 621 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -text "-" -fill "#2d3046" -width 260 -textvariable {[waterflow_text]} 
add_de1_button "off" "espresso" 474 241 804 671
add_btn_screen "espresso" "off"
add_de1_action "espresso" "do_espresso"

######################################################
# the HOT WATER button and translatable text for it
add_de1_text "off" 1024 523 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 1029 523 -text [translate "POURING WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 1026 547 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "water" 1029 547 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 260 -text "-" -textvariable {[timer_text]} 
add_de1_text "water" 1026 570 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "water" 1029 570 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 260 -text "-" -textvariable {[watertemp_text]} 
add_de1_text "water" 1026 595 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "water" 1029 595 -justify left -anchor "nw"  -font Helv_8 -fill "#2d3046" -width 260 -text "-" -textvariable {[waterflow_text]} 
add_de1_text "water" 1026 619 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_variable "water" 1029 619 -justify left -anchor "nw" -font Helv_8 -fill "#2d3046" -width 260 -text "-" -textvariable {[watervolume_text]} 
add_de1_button "off" "water" 874 256 1174 656
add_btn_screen "water" "off"
add_de1_action "water" "do_water"

######################################################
add_de1_action "off" "de1_stop_all"

# the SETTINGS button
add_de1_button "off" "settings" 1125 0 1279 142
add_de1_action "settings" "app_exit"


