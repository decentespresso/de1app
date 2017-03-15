set ::skindebug 0

##############################################################################################################################################################################################################################################################################
# the graphics for each of the main espresso machine modes
add_de1_page "off" "[defaultskin_directory_graphics]/nothing_on.jpg"
add_de1_page "espresso" "[defaultskin_directory_graphics]/espresso_on.jpg"
add_de1_page "steam" "[defaultskin_directory_graphics]/steam_on.jpg"
add_de1_page "water" "[defaultskin_directory_graphics]/tea_on.jpg"
add_de1_page "sleep" "[defaultskin_directory_graphics]/sleep.jpg"
add_de1_page "tankfilling" "[defaultskin_directory_graphics]/filling_tank.jpg"
add_de1_page "tankempty" "[defaultskin_directory_graphics]/fill_tank.jpg"
set_de1_screen_saver_directory "[homedir]/saver"

# include the generic settings features for all DE1 skins.  
source "[homedir]/skins/default/de1_skin_settings.tcl"
