
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

load_font "lighthouse" "[skin_directory]/lighthouse.ttf" 20

# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off espresso" 395 1197  -text [translate "ESPRESSO"] -font {lighthouse} -fill "#ffffff" -anchor "center" 
add_de1_text "off steam" 1305 1197  -text [translate "STEAM"] -font {lighthouse} -fill "#ffffff" -anchor "center" 
add_de1_text "off water hotwaterrinse" 2180 1197 -text [translate "WATER"] -font {lighthouse} -fill "#ffffff" -anchor "center" 


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {esspresso}] $::settings(sound_button_in);start_espresso" 150 600 660 1295
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 1000 600 1600 1295
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1880 600 2530 1295


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 120 65 450 350
add_de1_button "off" {show_settings} 2110 65 2425 350

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

