
# the STEAM buton and translatable text for it
add_de1_button_text "steam" 255 573 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "steam" 255 598 -justify center -anchor "n" -text [translate "Cappuccino, Latte, Macchiato, Cortado, Flat White"] -font Helv_8 -fill "#7f879a" -width 280
add_de1_command "steam" do_steam 104 308 404 706 

# the ESPRESSO buton and translatable text for it
add_de1_button_text "espresso" 640 573 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "espresso" 640 598 -justify center -anchor "n" -text [translate "Single, Double, Triple, Ristretto, Lungo"] -font Helv_8 -fill "#7f879a" -width 250
add_de1_command "espresso" do_espresso 474 293 803 721

# the HOT WATER buton and translatable text for it
add_de1_button_text "water" 1024 573 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_button_text "water" 1024 598 -justify center -anchor "n" -text [translate "Americano, Tea"] -font Helv_8 -fill "#7f879a" -width 280
add_de1_command "water" do_water 875 307 1175 706 

# the SETTINGS button
add_de1_command "settings" app_exit 1133 0 1280 142
