
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

load_font "chap" "[skin_directory]/chap.ttf" 22

# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off" 535 1070  -text [translate "ESPRESSO"] -font {chap} -fill "#7d1517" -anchor "center" 
add_de1_text "off" 1022 1070  -text [translate "STEAM"] -font {chap} -fill "#7d1517" -anchor "center" 
add_de1_text "off" 1524 1070 -text [translate "WATER"] -font {chap} -fill "#7d1517" -anchor "center" 
add_de1_text "off" 2025 1070 -text [translate "SETTINGS"] -font {chap} -fill "#7d1517" -anchor "center" 



# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 313 525 759 1150
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 805 525 1251 1150
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1297 525 1735 1150


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 1185 1360 1375 1555
add_de1_button "off" {show_settings} 1785 525 2225 1150

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

