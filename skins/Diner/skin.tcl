
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

load_font "bellerose" "[skin_directory]/bellerose.ttf" 30

# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off espresso" 436 1350  -text [translate "ESPRESSO"] -font {bellerose} -fill "#a4f1fa" -anchor "center" 
#add_de1_text "espresso" 436 1350  -text [translate "ESPRESSO"] -font {bellerose} -fill "#a4f1fa" -anchor "center" 

add_de1_text "off steam" 1026 1350  -text [translate "STEAM"] -font {bellerose} -fill "#a4f1fa" -anchor "center" 
#add_de1_text "steam" 1026 1350  -text [translate "STEAM"] -font {bellerose} -fill "#a4f1fa" -anchor "center" 


add_de1_text "off water hotwaterrinse" 1604 1350 -text [translate "WATER"] -font {bellerose} -fill "#a4f1fa" -anchor "center" 
#add_de1_text "water" 1604 1350  -text [translate "WATER"] -font {bellerose} -fill "#a4f1fa" -anchor "center" 

add_de1_text "off" 2164 1350  -text [translate "SETTINGS"] -font {bellerose} -fill "#a4f1fa" -anchor "center" 



# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 30 700 730 1555
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 735 700 1290 1555
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1295 700 1890 1555


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 10 10 2620 690
add_de1_button "off" {show_settings} 1895 700 2515 1555

# show whether the espresso machine is ready to make an espresso, or heating, or the tablet is disconnected
add_de1_variable "off" 436 1420 -justify left -anchor "center" -text "" -font bellerose -fill "#a4f1fa" -width 1520 -textvariable {[de1_connected_state 5]} 


##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

