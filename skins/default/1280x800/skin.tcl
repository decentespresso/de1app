######################################################
# the STEAM button and translatable text for it
add_de1_text "off" 255 573 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 255 573 -text [translate "STEAMING"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 245 598 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_text "steam" 247 598 -justify left -anchor "nw" -text "12 [translate seconds]" -font Helv_8 -fill "#2d3046" -width 260
add_de1_text "steam" 245 622 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_text "steam" 247 622 -justify left -anchor "nw" -text [translate "145ºC"] -font Helv_8 -fill "#2d3046" -width 260
add_de1_text "steam" 245 647 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_text "steam" 247 647 -justify left -anchor "nw" -text "3.12 [translate bar]" -font Helv_8 -fill "#2d3046" -width 260

add_de1_button "off" "steam" 105 306 404 708
add_btn_screen "steam" "off"
add_de1_action "steam" "do_steam"

######################################################
# the ESPRESSO button and translatable text for it
add_de1_text "off" 640 573 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso" 640 573 -text [translate "MAKING ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso" 637 598 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_text "espresso" 640 598 -justify left -anchor "nw" -text "12 [translate seconds]" -font Helv_8 -fill "#2d3046" -width 260
add_de1_text "espresso" 637 622 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_text "espresso" 640 622 -justify left -anchor "nw" -text [translate "91.8ºC"] -font Helv_8 -fill "#2d3046" -width 260
add_de1_text "espresso" 637 647 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_text "espresso" 640 647 -justify left -anchor "nw" -text "9.2 [translate bar]" -font Helv_8 -fill "#2d3046" -width 260
add_de1_text "espresso" 637 671 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_text "espresso" 640 671 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -fill "#2d3046" -width 260
add_de1_button "off" "espresso" 474 292 803 722
add_btn_screen "espresso" "off"
add_de1_action "espresso" "do_espresso"

######################################################
# the HOT WATER button and translatable text for it
add_de1_text "off" 1024 573 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 1024 573 -text [translate "POURING HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 1016 598 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_text "water" 1019 598 -justify left -anchor "nw" -text "12 [translate seconds]" -font Helv_8 -fill "#2d3046" -width 260
add_de1_text "water" 1016 622 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_text "water" 1019 622 -justify left -anchor "nw" -text [translate "65.2ºC"] -font Helv_8 -fill "#2d3046" -width 260
add_de1_text "water" 1016 647 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_text "water" 1019 647 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -fill "#2d3046" -width 260
add_de1_text "water" 1016 671 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_text "water" 1019 671 -justify left -anchor "nw" -text "94 [translate ml]" -font Helv_8 -fill "#2d3046" -width 260
add_de1_button "off" "water" 874 308 1173 707
add_btn_screen "water" "off"
add_de1_action "water" "do_water"

######################################################
add_de1_action "off" "de1_stop_all"

# the SETTINGS button
#add_de1_button "off" "settings" 1125 0 1279 142
#add_de1_action "settings" "app_exit"

