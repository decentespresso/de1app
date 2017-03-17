set ::skindebug 1

##############################################################################################################################################################################################################################################################################
# the graphics for each of the main espresso machine modes
add_de1_page "off" "[skin_directory_graphics]/nothing_on.jpg"
add_de1_page "espresso" "[skin_directory_graphics]/espresso_on.jpg"
add_de1_page "steam" "[skin_directory_graphics]/steam_on.jpg"
add_de1_page "water" "[skin_directory_graphics]/tea_on.jpg"

# most skins will not bother replacing these graphics
add_de1_page "sleep" "[defaultskin_directory_graphics]/sleep.jpg"
add_de1_page "tankfilling" "[defaultskin_directory_graphics]/filling_tank.jpg"
add_de1_page "tankempty" "[defaultskin_directory_graphics]/fill_tank.jpg"
add_de1_page "message" "[defaultskin_directory_graphics]/settings_message.jpg"
set_de1_screen_saver_directory "[homedir]/saver"

# include the generic settings features for all DE1 skins.  
source "[homedir]/skins/default/de1_skin_settings.tcl"
