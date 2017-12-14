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


load_font "leaguegoth" "[skin_directory]/leaguegoth.ttf" 62


# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off water" 1985 1250 -text [translate "WATER"] -font {leaguegoth} -fill "#eaf4e4" -anchor "center" 
add_de1_text "off espresso" 570 1250  -text [translate "ESPRESSO"] -font {leaguegoth} -fill "#eaf4e4" -anchor "center" 
add_de1_text "off steam" 1275 1250  -text [translate "STEAM"] -font {leaguegoth} -fill "#eaf4e4" -anchor "center" 

# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 210 450 900 1444
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1650 450 2346 1444
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 948 450 1606 1444

# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 330 325
add_de1_button "off" {show_settings} 2200 0 2560 325

# show whether the espresso machine is ready to make an espresso, or heating, or the tablet is disconnected
add_de1_variable "off" 20 1440 -justify left -anchor "nw" -text "" -font leaguegoth -fill "#888888" -width 1520 -textvariable {[de1_connected_state 5]} 


##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

