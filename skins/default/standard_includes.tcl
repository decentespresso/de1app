set ::skindebug 0

##############################################################################################################################################################################################################################################################################
# the graphics for each of the main espresso machine modes
add_de1_page "off" "[skin_directory_graphics]/nothing_on.png"
add_de1_page "espresso" "[skin_directory_graphics]/espresso_on.png"
add_de1_page "steam" "[skin_directory_graphics]/steam_on.png"
add_de1_page "water" "[skin_directory_graphics]/tea_on.png"
add_de1_page "sleep" "[skin_directory_graphics]/sleep.jpg"
add_de1_page "tankfilling" "[skin_directory_graphics]/filling_tank.jpg"
add_de1_page "tankempty" "[skin_directory_graphics]/fill_tank.jpg"
set_de1_screen_saver_directory "[homedir]/saver"

# include the generic settings features for all DE1 skins.  
source "[homedir]/skins/default/de1_skin_settings.tcl"
