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

load_font "moonflower" "[skin_directory]/moonflower.ttf" 54


# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off espresso" 378 1240  -text [translate "ESPRESSO"] -font {moonflower} -fill "#654734" -anchor "center" 
add_de1_text "off steam" 1343 1378  -text [translate "STEAM"] -font {moonflower} -fill "#654734" -anchor "center" 
add_de1_text "off water" 2278 1379 -text [translate "WATER"] -font {moonflower} -fill "#654734" -anchor "center" 
add_de1_text "off settings" 2145 155  -text [translate "SETTINGS"] -font {moonflower} -fill "#654734" -anchor "center" 


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 70 425 750 1350
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 925 425 1615 1500
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1950 425 2500 1500


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 15 1195 265
add_de1_button "off" {backup_settings; page_to_show_when_off settings_1} 1950 65 2450 250

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

