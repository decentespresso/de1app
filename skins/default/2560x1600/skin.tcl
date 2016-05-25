
#add_de1_button_text "" 1280 446 -text [translate "Tap on a button below"] -font Helv_10_bold -fill "#7f879a" -anchor "center" 
#add_de1_button_text "espresso" 1280 446 -text [translate "TAP ANYWHERE TO STOP"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# the STEAM buton and translatable text for it
add_de1_button_text "steam" 510 1146 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "steam" 510 1196 -justify center -anchor "n" -text [translate "Cappuccino, Latte, Macchiato, Cortado, Flat White"] -font Helv_8 -fill "#7f879a" -width 550
add_de1_command "steam" do_steam 210 612 808 1416

# the ESPRESSO buton and translatable text for it
add_de1_button_text "espresso" 1280 1146 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "espresso" 1280 1196 -justify center -anchor "n" -text [translate "Single, Double, Triple, Ristretto, Lungo"] -font Helv_8 -fill "#7f879a" -width 550
add_de1_command "espresso" do_espresso 948 584 1606 1444

# the HOT WATER buton and translatable text for it
add_de1_button_text "water" 2048 1146 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "water" 2048 1196 -justify center -anchor "n" -text [translate "Americano, Tea"] -font Helv_8 -fill "#7f879a" -width 550
add_de1_command "water" do_water 1748 616 2346 1414

# the SETTINGS button
add_de1_command "settings" app_exit 2250 0 2558 284
