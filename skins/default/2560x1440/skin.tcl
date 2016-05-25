# the STEAM buton and translatable text for it
add_de1_button_text "steam" 510 1046 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "" 510 1096 -justify center -anchor "n" -text [translate "Cappuccino, Latte, Macchiato, Cortado, Flat White"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_command "steam" do_steam 212 514 808 1312

# the ESPRESSO buton and translatable text for it
add_de1_button_text "espresso" 1280 1046 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "" 1280 1096 -justify center -anchor "n" -text [translate "Single, Double, Triple, Ristretto, Lungo"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_command "espresso" do_espresso 950 484 1608 1340

# the HOT WATER buton and translatable text for it
add_de1_button_text "water" 2048 1046 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "" 2048 1096 -justify center -anchor "n" -text [translate "Americano, Tea"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_command "water" do_water 1750 514 2348 1312

# the SETTINGS button
add_de1_command "settings" app_exit 2274 1 2555 292
