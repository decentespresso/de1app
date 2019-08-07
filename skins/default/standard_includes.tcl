set ::skindebug 0

##############################################################################################################################################################################################################################################################################
# the graphics for each of the main espresso machine modes
add_de1_page "off" "nothing_on.png"
add_de1_page "espresso" "espresso_on.png"
add_de1_page "steam" "steam_on.png"
add_de1_page "water" "tea_on.png"

# most skins will not bother replacing these graphics
add_de1_page "sleep" "sleep.jpg" "default"
add_de1_page "tankfilling" "filling_tank.jpg" "default"
add_de1_page "tankempty refill" "fill_tank.jpg" "default"
add_de1_page "cleaning" "cleaning.jpg" "default"
add_de1_page "message calibrate" "settings_message.png" "default"
add_de1_page "create_preset" "settings_3_choices.png" "default"
add_de1_page "descaling" "descaling.jpg" "default"
add_de1_page "cleaning" "cleaning.jpg" "default"
add_de1_page "travel_prepare" "travel_prepare.jpg" "default"
add_de1_page "travel_do" "travel_do.jpg" "default"
add_de1_page "descalewarning" "descalewarning.jpg" "default"


add_de1_text "tankempty refill" 1280 750 -text [translate "Please add water"] -font Helv_20_bold -fill "#AAAAAA" -justify "center" -anchor "center" -width 900
add_de1_text "cleaning" 1280 80 -text [translate "Cleaning"] -font Helv_20_bold -fill "#EEEEEE" -justify "center" -anchor "center" -width 900
add_de1_text "descaling" 1280 80 -text [translate "Descaling"] -font Helv_20_bold -fill "#CCCCCC" -justify "center" -anchor "center" -width 900

add_de1_text "descalewarning" 1280 1310 -text [translate "Your steam wand is clogging up"] -font Helv_17_bold -fill "#FFFFFF" -justify "center" -anchor "center" -width 900
add_de1_text "descalewarning" 1280 1480 -text [translate "It needs to be descaled soon"] -font Helv_15_bold -fill "#FFFFFF" -justify "center" -anchor "center" -width 900
add_de1_button "descalewarning" {say [translate {descale}] $::settings(sound_button_in); show_settings settings_4;} 0 0 2560 1600 

set_de1_screen_saver_directory "[homedir]/saver"

# include the generic settings features for all DE1 skins.  
source "[homedir]/skins/default/de1_skin_settings.tcl"

#et_next_page off tankempty
