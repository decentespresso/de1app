# the STEAM buton and translatable text for it
add_de1_button_text "steam" 383 786 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "" 383 824 -justify center -anchor "n" -text [translate "Cappuccino, Latte, Macchiato, Cortado, Flat White"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_command "steam" do_steam 159 386 607 986

# the ESPRESSO buton and translatable text for it
add_de1_button_text "espresso" 962 786 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "" 962 824 -justify center -anchor "n" -text [translate "Single, Double, Triple, Ristretto, Lungo"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_command "espresso" do_espresso 714 363 1209 1007

# the HOT WATER buton and translatable text for it
add_de1_button_text "water" 1539 786 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "" 1539 824 -justify center -anchor "n" -text [translate "Americano, Tea"] -font Helv_8 -fill "#7f879a" -width 390
add_de1_command "water" do_water 1315 386 1765 986

# the SETTINGS button
add_de1_command "settings" app_exit 1709 0 1921 219

