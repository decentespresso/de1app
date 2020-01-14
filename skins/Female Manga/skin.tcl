package require de1 1.0

##############################################################################################################################################################################################################################################################################
# DECENT ESPRESSO EXAMPLE SKIN FOR NEW SKIN DEVELOPERS
##############################################################################################################################################################################################################################################################################

# you should replace the JPG graphics in the 2560x1600/ directory with your own graphics. 
source "[homedir]/skins/default/standard_includes.tcl"

# example of loading a custom font (you need to indicate the TTF file and the font size)
#load_font "Northwood High" "[skin_directory]/sample.ttf" 60
#add_de1_text "off" 1280 500 -text "An important message" -font {Northwood High} -fill "#2d3046" -anchor "center"


# SKIN NAME: 8 BIT


##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is idle

load_font "KG Les Bouquinistes de Paris" "[skin_directory]/KGLesBouquinistesdeParis.ttf" 47 40
load_font "KG The Last Time" "[skin_directory]/KGTheLastTime.ttf" 47 40
load_font "KG TRIBECA STAMP" "[skin_directory]/KGTribecaStamp.ttf" 47 40
load_font "KG Havent Slept in Two Days Sha" "[skin_directory]/KGHaventSleptShadow.ttf" 47 40


# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off water hotwaterrinse" 1635 1510 -text [translate "WATER"] -font {KG Les Bouquinistes de Paris} -fill "#ffffff" -anchor "center" 

add_de1_text "off" 335 1500 -text [translate "ESPRESSO"] -font {KG The Last Time} -fill "#ff7f24" -anchor "center" 
add_de1_text "espresso" 350 1500 -text [translate "ESPRESSO"] -font {KG The Last Time} -fill "#ff7f24" -anchor "center" 

add_de1_text "off steam" 985 1495  -text [translate "STEAM"] -font {KG TRIBECA STAMP} -fill "#ffffff" -anchor "center" 

add_de1_text "off settings" 2275 1480  -text [translate "SETTINGS"] -font {KG Havent Slept in Two Days Sha} -fill "#cd0000" -anchor "center" 

# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 5 295 660 1595
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1330 295 1950 1595
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 672 295 1320 1595

# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 725 0 1905 250
add_de1_button "off" {show_settings} 1950 295 2550 1595

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

