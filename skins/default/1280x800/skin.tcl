
text 255 573 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
text 256 598 -justify center -anchor "n" -text [translate "Capuccino, Latte, Macchiato, Cortado, Flat White"] -font Helv_8 -fill "#7f879a" -width 280

text 640 573 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
text 641 598 -justify center -anchor "n" -text [translate "Single, Double, Triple, Ristretto, Lungo"] -font Helv_8 -fill "#7f879a" -width 250

text 1024 573 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
text 1024 598 -justify center -anchor "n" -text [translate "Americano, Tea"] -font Helv_8 -fill "#7f879a" -width 280


.can create text 255 573 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
.can create text 256 598 -justify center -anchor "n" -text [translate "Capuccino, Latte, Macchiato, Cortado, Flat White"] -font Helv_8 -fill "#7f879a" -width 280

.can create text 640 573 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
.can create text 641 598 -justify center -anchor "n" -text [translate "Single, Double, Triple, Ristretto, Lungo"] -font Helv_8 -fill "#7f879a" -width 250

.can create text 1024 573 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
.can create text 1024 598 -justify center -anchor "n" -text [translate "Americano, Tea"] -font Helv_8 -fill "#7f879a" -width 280

add_de1_command "steam" do_steam 104 308 404 706 
add_de1_command "espresso" do_espresso 474 293 803 721
add_de1_command "water" do_water 875 307 1175 706 
add_de1_command "exit" app_exit 1133 0 1280 142
