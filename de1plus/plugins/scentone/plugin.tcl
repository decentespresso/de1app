
set plugin_name "scentone"

# These are chown in the plugin selection page
set ::plugins::${plugin_name}::author "Decent Espresso"
set ::plugins::${plugin_name}::contact "decentespresso.com"
set ::plugins::${plugin_name}::version 1.0
set ::plugins::${plugin_name}::description "Describe your espresso using the scentone system"

proc ::plugins::${plugin_name}::preload_tab {page_name} {
    set settings_tab_font "Helv_10_bold"
    set botton_button_font "Helv_10_bold"
    set listbox_font "Helv_10"

    set ::scentone_ui_return $page_name

    add_de1_image "$page_name" 50 180 "[homedir]/[plugin_directory]/scentone/scentone_1.png"

    add_de1_text $page_name 1250 1520 -text [translate "Save"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
    add_de1_button $page_name {say [translate {save}] $::settings(sound_button_in); set_next_page off off; save_espresso_rating_to_history; page_show off } 980 1480 1680 1610

    add_de1_text $page_name 1760 1520 -text [translate "Reset"] -font Helv_10_bold -fill "#000" -anchor "center"
    add_de1_button $page_name {say [translate {reset}] $::settings(sound_button_in); set ::settings(scentone) "" } 1505 1406 2015 1600

    set ::scentone(Tropical\ fruit) {"Guava" "Mangosteen" "Mango" "Banana" "Coconut" "Passion fruit" "Watermelon" "Papaya" "Tropical fruits" "Pineapple" "Melon" "Lychee"}
    set ::scentone(Berry) {"Strawberry" "Blueberry" "Raspberry" "Cranberry" "Blackberry" "Acai berry" "Black currant" "White grape" "Muscat grape" "Red grape"}
    set ::scentone(Citrus) {"Pomegranate" "Aloe" "Lemon" "Orange" "Lime" "Yuzu" "Grapefruit" "Chinese pear" "Apple" "Quince"}
    set ::scentone(Stone\ fruit) {"Acerola" "Light cherry" "Dark cherry" "Peach" "Plum" "Apricot"}
    set ::scentone(Nut\ &\ cereal) {"Hazelnut" "Walnut" "Pine nut" "Almond" "Peanut" "Pistachio" "Sesame" "Red bean" "Malt" "Toasted rice" "Roasted"}
    set ::scentone(Chocolate\ &\ caramel) {"Caramel" "Brown sugar" "Honey" "Maple syrup" "Milk chocolate" "Dark chocolate" "Mocha" "Cream" "Butter" "Yogurt" "Vanilla"}
    set ::scentone(Flower\ &\ herb) {"Pine" "Hawthorn" "Earl grey" "Rose" "Jasmin" "Acacia" "Elderflower" "Lavender" "Bergamot" "Chrysanthemum" "Hibiscus" "Eucalyptus"}
    set ::scentone(Spice) {"Basil" "Thyme" "Cinnamon" "Nutmeg" "Clove" "Cardamon" "Star anise" "Cumin" "Black pepper" "Garlic" "Ginger"}
    set ::scentone(Vegetable) {"Date" "Pumpkin" "Tomato" "Cucumber" "Mushroom" "Taro" "Arrowroot" "Ginseng" "Paprika"}
    set ::scentone(Savory) {"Cheddar" "Soy sauce" "Mustard" "Mayonnaise" "Musk" "Amber" "Smoke" "Beef"}

    # row 1 text labels 
    add_de1_variable "$page_name" 300 680 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Tropical fruit"]} 
    add_de1_variable "$page_name" 830 680 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Berry" ]} 
    add_de1_variable "$page_name" 1370 680 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Citrus" ]} 
    add_de1_variable "$page_name" 1850 680 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Stone fruit" ]} 
    add_de1_variable "$page_name" 2280 680 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Nut & cereal" ]} 

    # row 2 text labels 
    add_de1_variable "$page_name" 300 1260 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Chocolate & caramel" ]} 
    add_de1_variable "$page_name" 830 1260 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Flower & herb" ]} 
    add_de1_variable "$page_name" 1370 1260 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Spice" ]} 
    add_de1_variable "$page_name" 1931 1260 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Vegetable" ]} 
    add_de1_variable "$page_name" 2330 1260 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Savory" ]} 

    # row 1 tap areas
    add_de1_button "$page_name" {say [translate {Tropical fruit}] $::settings(sound_button_in); set_next_page off scentone_tropical; page_show off } 15 290 520 860
    add_de1_button "$page_name" {say [translate {Berry}] $::settings(sound_button_in); set_next_page off scentone_berry; page_show off } 522 290 1100 860
    add_de1_button "$page_name" {say [translate {Citrus}] $::settings(sound_button_in); set_next_page off scentone_citrus; page_show off } 1102 290 1660 860
    add_de1_button "$page_name" {say [translate {Stone fruit}] $::settings(sound_button_in); set_next_page off scentone_stone; page_show off } 1662 290 2050 860
    add_de1_button "$page_name" {say [translate {Nut & cereal}] $::settings(sound_button_in); set_next_page off scentone_cereal; page_show off } 2052 290 2550 860

    # row 2 tap areas
    add_de1_button "$page_name" {say [translate {Chocolate & caramel}] $::settings(sound_button_in); set_next_page off scentone_chocolate; page_show off } 15 862 560 1400
    add_de1_button "$page_name" {say [translate {Flower & herb}] $::settings(sound_button_in); set_next_page off scentone_flower; page_show off } 562 862 1070 1400
    add_de1_button "$page_name" {say [translate {Spice}] $::settings(sound_button_in); set_next_page off scentone_spice; page_show off } 1072 862 1690 1400
    add_de1_button "$page_name" {say [translate {Vegetable}] $::settings(sound_button_in); set_next_page off scentone_vegetable; page_show off } 1692 862 2140 1400
    add_de1_button "$page_name" {say [translate {Savory}] $::settings(sound_button_in); set_next_page off scentone_savory; page_show off } 2142 862 2550 1400

    source [homedir]/[plugin_directory]/scentone/scentone.tcl

    return $page_name
}

proc ::plugins::${plugin_name}::main {} {
    msg "Scentone Plugin loaded"
}
