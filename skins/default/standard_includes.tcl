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
add_de1_page "tankempty" "fill_tank.jpg" "default"
add_de1_page "cleaning" "cleaning.jpg" "default"
add_de1_page "message calibrate" "settings_message.png" "default"
add_de1_page "descaling" "descaling.jpg" "default"
add_de1_page "cleaning" "cleaning.jpg" "default"

set_de1_screen_saver_directory "[homedir]/saver"

# include the generic settings features for all DE1 skins.  
source "[homedir]/skins/default/de1_skin_settings.tcl"
