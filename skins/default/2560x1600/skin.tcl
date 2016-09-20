######################################################
# the STEAM button and translatable text for it
add_de1_text "off" 510 1146 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 510 1146 -text [translate "STEAMING"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 490 1196 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_text "steam" 495 1196 -justify left -anchor "nw" -text "12 [translate seconds]" -font Helv_8 -fill "#2d3046" -width 520
add_de1_text "steam" 490 1244 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_text "steam" 495 1244 -justify left -anchor "nw" -text [translate "145ºC"] -font Helv_8 -fill "#2d3046" -width 520
add_de1_text "steam" 490 1294 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_text "steam" 495 1294 -justify left -anchor "nw" -text "3.12 [translate bar]" -font Helv_8 -fill "#2d3046" -width 520

add_de1_button "off" "steam" 210 612 808 1416
add_btn_screen "steam" "off"
add_de1_action "steam" "do_steam"

######################################################
# the ESPRESSO button and translatable text for it
add_de1_text "off" 1280 1146 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso" 1280 1146 -text [translate "MAKING ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso" 1275 1196 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_text "espresso" 1280 1196 -justify left -anchor "nw" -text "12 [translate seconds]" -font Helv_8 -fill "#2d3046" -width 520
add_de1_text "espresso" 1275 1244 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_text "espresso" 1280 1244 -justify left -anchor "nw" -text [translate "91.8ºC"] -font Helv_8 -fill "#2d3046" -width 520
add_de1_text "espresso" 1275 1294 -justify right -anchor "ne" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_text "espresso" 1280 1294 -justify left -anchor "nw" -text "9.2 [translate bar]" -font Helv_8 -fill "#2d3046" -width 520
add_de1_text "espresso" 1275 1342 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_text "espresso" 1280 1342 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -fill "#2d3046" -width 520
add_de1_button "off" "espresso" 948 584 1606 1444
add_btn_screen "espresso" "off"
add_de1_action "espresso" "do_espresso"

######################################################
# the HOT WATER button and translatable text for it
add_de1_text "off" 2048 1146 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 2048 1146 -text [translate "POURING HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 2033 1196 -justify right -anchor "ne" -text [translate "Timer:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_text "water" 2038 1196 -justify left -anchor "nw" -text "12 [translate seconds]" -font Helv_8 -fill "#2d3046" -width 520
add_de1_text "water" 2033 1244 -justify right -anchor "ne" -text [translate "Temperature:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_text "water" 2038 1244 -justify left -anchor "nw" -text [translate "65.2ºC"] -font Helv_8 -fill "#2d3046" -width 520
add_de1_text "water" 2033 1294 -justify right -anchor "ne" -text [translate "Flow:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_text "water" 2038 1294 -justify left -anchor "nw" -text "1.12 [translate ml/sec]" -font Helv_8 -fill "#2d3046" -width 520
add_de1_text "water" 2033 1342 -justify right -anchor "ne" -text [translate "Total:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_text "water" 2038 1342 -justify left -anchor "nw" -text "94 [translate ml]" -font Helv_8 -fill "#2d3046" -width 520
add_de1_button "off" "water" 1748 616 2346 1414
add_btn_screen "water" "off"
add_de1_action "water" "do_water"

######################################################
add_de1_action "off" "de1_stop_all"

# the SETTINGS button
#add_de1_button "off" "settings" 2250 0 2558 284
#add_de1_action "settings" "app_exit"
