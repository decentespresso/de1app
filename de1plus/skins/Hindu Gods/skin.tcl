package require de1 1.0

##############################################################################################################################################################################################################################################################################
# DECENT ESPRESSO EXAMPLE SKIN FOR NEW SKIN DEVELOPERS
##############################################################################################################################################################################################################################################################################

# you should replace the JPG graphics in the 2560x1600/ directory with your own graphics. 
source "[homedir]/skins/default/standard_includes.tcl"

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

# example of loading a custom font (you need to indicate the TTF file and the font size)
#load_font "Northwood High" "[skin_directory]/sample.ttf" 60
#add_de1_text "off" 1280 500 -text "An important message" -font {Northwood High} -fill "#2d3046" -anchor "center"


##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is idle

load_font "samark" "[skin_directory]/samark.ttf" 32


# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off" 380 1455  -text [translate "ESPRESSO"] -font {samark} -fill "#ffffff" -anchor "center" 


add_de1_text "off" 1012 1455  -text [translate "STEAM"] -font {samark} -fill "#ffffff" -anchor "center" 


add_de1_text "off" 1585 1455 -text [translate "WATER"] -font {samark} -fill "#ffffff" -anchor "center" 


add_de1_text "off" 2186 1455  -text [translate "SETTINGS"] -font {samark} -fill "#ffffff" -anchor "center" 




# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 70 520 635 1500
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 780 520 1230 1500
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1350 520 1825 1500


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 125 80 950 330
add_de1_button "off" {show_settings} 1950 520 2425 1500

##############################################################################################################################################################################################################################################################################

