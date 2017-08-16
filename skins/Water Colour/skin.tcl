
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

load_font "gruss" "[skin_directory]/gruss.ttf" 38

# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off" 395 1400  -text [translate "ESPRESSO"] -font {gruss} -fill "#ca3b3b" -anchor "center" 
add_de1_text "off" 1280 1400  -text [translate "STEAM"] -font {gruss} -fill "#d69a27" -anchor "center" 
add_de1_text "off" 2150 1400 -text [translate "HOT WATER"] -font {gruss} -fill "#1388be" -anchor "center" 

add_de1_text "off" 2015 160 -text [translate "SETTINGS"] -font {gruss} -fill "#21292d" -anchor "center" 


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 100 450 745 1300
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 850 450 1600 1250
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1800 450 2400 1250


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 11 15 1150 250
add_de1_button "off" {backup_settings; page_to_show_when_off settings_1} 1925 15 2555 250

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

