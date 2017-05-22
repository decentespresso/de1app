package require de1 1.0

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

load_font "diablolight" "[skin_directory]/diablolight.ttf" 31 31

# these 3 text labels are for the three main DE1 functions, and diablolight X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off" 379 1375  -text [translate "ESPRESSO"] -font {diablolight} -fill "#a66220" -anchor "center" 
add_de1_text "espresso" 1295 1355  -text [translate "ESPRESSO"] -font {diablolight} -fill "#a66220" -anchor "center" 

add_de1_text "off" 975 1375  -text [translate "STEAM"] -font {diablolight} -fill "#a66220" -anchor "center" 
add_de1_text "steam" 1295 1355  -text [translate "STEAM"] -font {diablolight} -fill "#a66220" -anchor "center" 

add_de1_text "off" 1550 1375 -text [translate "WATER"] -font {diablolight} -fill "#a66220" -anchor "center" 
add_de1_text "water" 1295 1350 -text [translate "WATER"] -font {diablolight} -fill "#a66220" -anchor "center" 


add_de1_text "off settings" 2177 1375  -text [translate "SETTINGS"] -font {diablolight} -fill "#a66220" -anchor "center" 


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 80 380 680 1480
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 725 400 1265 1480
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1305 400 1810 1480


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 2250 150 2490 335
add_de1_button "off" {backup_settings; page_to_show_when_off settings_1} 1870 375 2500 1480

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

