# the STEAM buton and translatable text for it
add_de1_button_text "steam" 255 573 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "" 255 598 -justify center -anchor "n" -text [translate "Cappuccino, Latte, Macchiato, Cortado, Flat White"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_command "steam" do_steam 105 306 404 708

# the ESPRESSO buton and translatable text for it
add_de1_button_text "espresso" 640 573 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "" 640 598 -justify center -anchor "n" -text [translate "Single, Double, Triple, Ristretto, Lungo"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_command "espresso" do_espresso 474 292 803 722

# the HOT WATER buton and translatable text for it
add_de1_button_text "water" 1024 573 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "" 1024 598 -justify center -anchor "n" -text [translate "Americano, Tea"] -font Helv_8 -fill "#7f879a" -width 260
add_de1_command "water" do_water 874 308 1173 707

# the SETTINGS button
add_de1_command "settings" app_exit 1125 0 1279 142

