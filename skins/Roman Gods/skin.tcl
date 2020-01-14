
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

load_font "renaissance" "[skin_directory]/renaissance.ttf" 24

# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off" 342 1484  -text [translate "ESPRESSO"] -font {renaissance} -fill "#a7534e" -anchor "center" 
add_de1_text "espresso" 342 1484  -text [translate "ESPRESSO"] -font {renaissance} -fill "#a7534e" -anchor "center" 

add_de1_text "off" 948 1484  -text [translate "STEAM"] -font {renaissance} -fill "#a7534e" -anchor "center" 
add_de1_text "steam" 948 1484  -text [translate "STEAM"] -font {renaissance} -fill "#a7534e" -anchor "center" 


add_de1_text "off" 1568 1484 -text [translate "WATER"] -font {renaissance} -fill "#a7534e" -anchor "center" 
add_de1_text "water hotwaterrinse" 1568 1484  -text [translate "WATER"] -font {renaissance} -fill "#a7534e" -anchor "center" 

add_de1_text "off" 2208 1484  -text [translate "SETTINGS"] -font {renaissance} -fill "#a7534e" -anchor "center" 



# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 30 450 650 1555
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 665 450 1270 1555
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1290 450 1890 1555


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 1300 170 2220 420
add_de1_button "off" {show_settings} 1920 450 2515 1555

# show whether the espresso machine is ready to make an espresso, or heating, or the tablet is disconnected
add_de1_variable "off" 1280 1576 -justify left -anchor "center" -text "" -font renaissance -fill "#444444" -width 1520 -textvariable {[de1_connected_state 5]} 

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

