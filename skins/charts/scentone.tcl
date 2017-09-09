
#######################
# scent one aroma system

add_de1_page "scentone_1" "[skin_directory_graphics]/scentone_1.jpg"
add_de1_page "scentone_tropical" "[skin_directory_graphics]/scentone_tropical.jpg"
add_de1_page "scentone_berry" "[skin_directory_graphics]/scentone_berry.jpg"
add_de1_page "scentone_citrus" "[skin_directory_graphics]/scentone_citrus.jpg"
add_de1_page "scentone_stone" "[skin_directory_graphics]/scentone_stone.jpg"
add_de1_page "scentone_cereal" "[skin_directory_graphics]/scentone_cereal.jpg"
add_de1_page "scentone_chocolate" "[skin_directory_graphics]/scentone_chocolate.jpg"
add_de1_page "scentone_flower" "[skin_directory_graphics]/scentone_flower.jpg"
add_de1_page "scentone_spice" "[skin_directory_graphics]/scentone_spice.jpg"
add_de1_page "scentone_vegetable" "[skin_directory_graphics]/scentone_vegetable.jpg"
add_de1_page "scentone_savory" "[skin_directory_graphics]/scentone_savory.jpg"


add_de1_button "espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" {say [translate {scent one}] $::settings(sound_button_in); set_next_page off scentone_1; page_show off} 2285 665 2560 900
add_de1_text "scentone_1 scentone_tropical scentone_berry scentone_citrus scentone_stone scentone_cereal scentone_chocolate scentone_flower scentone_spice scentone_vegetable scentone_savory" 2275 1520 -text [translate "Save"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
add_de1_text "scentone_1 scentone_tropical scentone_berry scentone_citrus scentone_stone scentone_cereal scentone_chocolate scentone_flower scentone_spice scentone_vegetable scentone_savory" 1760 1520 -text [translate "Cancel"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"

add_de1_button "scentone_1" {say [translate {save}] $::settings(sound_button_in); set_next_page off espresso_3; page_show off } 2016 1406 2560 1600
add_de1_button "scentone_1" {say [translate {save}] $::settings(sound_button_in); set_next_page off espresso_3; page_show off } 1505 1406 2015 1600
add_de1_button "scentone_tropical scentone_berry scentone_citrus scentone_stone scentone_cereal scentone_chocolate scentone_flower scentone_spice scentone_vegetable scentone_savory" {say [translate {save}] $::settings(sound_button_in); set_next_page off scentone_1; page_show off } 2016 1406 2560 1600
add_de1_button "scentone_tropical scentone_berry scentone_citrus scentone_stone scentone_cereal scentone_chocolate scentone_flower scentone_spice scentone_vegetable scentone_savory" {say [translate {save}] $::settings(sound_button_in); set_next_page off scentone_1; page_show off } 1505 1406 2015 1600


###
# main scentone categories

# row 1
add_de1_text "scentone_1" 300 800 -text [translate "Tropical fruit"] -font Helv_9_bold -fill "#BBBBBB" -anchor "center"
add_de1_text "scentone_1" 830 800 -text [translate "Berry"] -font Helv_10_bold -font Helv_9_bold -fill "#BBBBBB" -anchor "center"
add_de1_text "scentone_1" 1370 800 -text [translate "Citrus"] -font Helv_9_bold -fill "#BBBBBB" -anchor "center"
add_de1_text "scentone_1" 1850 800 -text [translate "Stone fruit"] -font Helv_9_bold -fill "#BBBBBB" -anchor "center"
add_de1_text "scentone_1" 2280 800 -text [translate "Nut & cereal"] -font Helv_9_bold -fill "#BBBBBB" -anchor "center"

# row 2
add_de1_text "scentone_1" 300 1380 -text [translate "Chocolate & caramel"] -font Helv_9_bold -fill "#BBBBBB" -anchor "center"
add_de1_text "scentone_1" 830 1380 -text [translate "Flower & herb"] -font Helv_9_bold -fill "#BBBBBB" -anchor "center"
add_de1_text "scentone_1" 1370 1380 -text [translate "Spice"] -font Helv_9_bold -fill "#BBBBBB" -anchor "center"
add_de1_text "scentone_1" 1931 1380 -text [translate "Vegetable"] -font Helv_9_bold -fill "#BBBBBB" -anchor "center"
add_de1_text "scentone_1" 2330 1380 -text [translate "Savory"] -font Helv_9_bold -fill "#BBBBBB" -anchor "center"

# row 1 
add_de1_button "scentone_1" {say [translate {Tropical fruit}] $::settings(sound_button_in); set_next_page off scentone_tropical; page_show off } 15 290 520 860
add_de1_button "scentone_1" {say [translate {Berry}] $::settings(sound_button_in); set_next_page off scentone_berry; page_show off } 522 290 1100 860
add_de1_button "scentone_1" {say [translate {Citrus}] $::settings(sound_button_in); set_next_page off scentone_citrus; page_show off } 1102 290 1660 860
add_de1_button "scentone_1" {say [translate {Stone fruit}] $::settings(sound_button_in); set_next_page off scentone_stone; page_show off } 1662 290 2050 860
add_de1_button "scentone_1" {say [translate {Nut & cereal}] $::settings(sound_button_in); set_next_page off scentone_cereal; page_show off } 2052 290 2550 860
# row 2
add_de1_button "scentone_1" {say [translate {Chocolate & caramel}] $::settings(sound_button_in); set_next_page off scentone_chocolate; page_show off } 15 862 560 1400
add_de1_button "scentone_1" {say [translate {Flower & herb}] $::settings(sound_button_in); set_next_page off scentone_flower; page_show off } 562 862 1070 1400
add_de1_button "scentone_1" {say [translate {Spice}] $::settings(sound_button_in); set_next_page off scentone_spice; page_show off } 1072 862 1690 1400
add_de1_button "scentone_1" {say [translate {Vegetable}] $::settings(sound_button_in); set_next_page off scentone_vegetable; page_show off } 1692 862 2140 1400
add_de1_button "scentone_1" {say [translate {Savory}] $::settings(sound_button_in); set_next_page off scentone_savory; page_show off } 2142 862 2550 1400
###

set_next_page off scentone_1
#######################

