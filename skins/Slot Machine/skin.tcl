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

load_font "renogare" "[skin_directory]/renogare.ttf" 24


# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off" 562 1425  -text [translate "ESPRESSO"] -font {renogare} -fill "#000000" -anchor "center" 
add_de1_text "espresso" 562 1435  -text [translate "ESPRESSO"] -font {renogare} -fill "#000000" -anchor "center" 

add_de1_text "off" 1275 1425  -text [translate "STEAM"] -font {renogare} -fill "#000000" -anchor "center" 
add_de1_text "steam" 1275 1435  -text [translate "STEAM"] -font {renogare} -fill "#000000" -anchor "center" 

add_de1_text "off" 2067 1425 -text [translate "WATER"] -font {renogare} -fill "#000000" -anchor "center" 
add_de1_text "water" 2067 1435 -text [translate "WATER"] -font {renogare} -fill "#000000" -anchor "center" 

add_de1_text "off settings" 2245 122  -text [translate "SETTINGS"] -font {renogare} -fill "#000000" -anchor "center" 


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 240 270 850 1550
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 970 270 1575 1550
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1720 285 2320 1550


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 2400 1435 2550 1585
add_de1_button "off" {show_settings} 1950 25 2550 250

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

