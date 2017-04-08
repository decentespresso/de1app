
##############################################################################################################################################################################################################################################################################
# DECENT ESPRESSO EXAMPLE SKIN FOR NEW SKIN DEVELOPERS
##############################################################################################################################################################################################################################################################################

# you should replace the JPG graphics in the 2560x1600/ directory with your own graphics. 
source "[homedir]/skins/default/standard_includes.tcl"

# example of loading a custom font (you need to indicate the TTF file and the font size)
#load_font "Northwood High" "[skin_directory]/sample.ttf" 60
#add_de1_text "off" 1280 500 -text "An important message" -font {Northwood High} -fill "#2d3046" -anchor "center"


##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is idle

load_font "Diablo" "[skin_directory]/diablo-light.ttf" 31

# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off" 379 1375  -text [translate "ESPRESSO"] -font {Diablo} -fill "#fdd45b" -anchor "center" 
add_de1_text "espresso" 1295 1355  -text [translate "ESPRESSO"] -font {Diablo} -fill "#fdd45b" -anchor "center" 

add_de1_text "off" 970 1375  -text [translate "STEAM"] -font {Diablo} -fill "#fdd45b" -anchor "center" 
add_de1_text "steam" 1295 1355  -text [translate "STEAM"] -font {Diablo} -fill "#fdd45b" -anchor "center" 

add_de1_text "off" 1550 1375 -text [translate "WATER"] -font {Diablo} -fill "#fdd45b" -anchor "center" 
add_de1_text "water" 1295 1350 -text [translate "WATER"] -font {Diablo} -fill "#fdd45b" -anchor "center" 


add_de1_text "off settings" 2176 1375  -text [translate "SETTINGS"] -font {Diablo} -fill "#fdd45b" -anchor "center" 


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {esspresso}] $::settings(sound_button_in);start_espresso" 80 380 680 1480
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 725 400 1265 1480
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1305 400 1810 1480


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 2080 85 2300 225
add_de1_button "off" {backup_settings; page_to_show_when_off settings_1} 1870 375 2500 1480

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

