add_de1_command "steam" do_steam 104 308 404 706 
add_de1_command "espresso" do_espresso 474 293 803 721
add_de1_command "water" do_water 875 307 1175 706 
add_de1_command "exit" app_exit 1133 0 1280 142

.can create text 255 573 -anchor "center" -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -tag .weight_setting_units_label
.can create text 640 573 -anchor "center" -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -tag .weight_setting_units_label2
.can create text 1024 573 -anchor "center" -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -tag .weight_setting_units_label3


.can create text 256 598 -justify center -anchor "n" -text [translate "Capuccino, Latte, Macchiato, Cortado, Flat White"] -font Helv_8 -fill "#7f879a" -tag .weight_setting_units_label4 -width 300
.can create text 641 598 -justify center -anchor "n" -text [translate "Single, Double, Triple, Ristretto, Lungo"] -font Helv_8 -fill "#7f879a" -tag .weight_setting_units_label4 -width 250
.can create text 1024 598 -justify center -anchor "n" -text [translate "Americano, Tea"] -font Helv_8 -fill "#7f879a" -tag .weight_setting_units_label4 -width 300
