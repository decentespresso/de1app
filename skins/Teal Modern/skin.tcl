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


load_font "novocento" "[skin_directory]/novocento.ttf" 29


# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off espresso" 450 1225  -text [translate "ESPRESSO"] -font {novocento} -fill "#a5e2e3" -anchor "center" 
add_de1_text "off steam" 975 1225  -text [translate "STEAM"] -font {novocento} -fill "#a5e2e3" -anchor "center" 
add_de1_text "off water hotwaterrinse" 1572 1225 -text [translate "WATER"] -font {novocento} -fill "#a5e2e3" -anchor "center" 
add_de1_text "off settings" 2180 1225  -text [translate "SETTINGS"] -font {novocento} -fill "#a5e2e3" -anchor "center" 


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 250 800 650 1350
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 770 800 1150 1350
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1400 800 1750 1350


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 850 250 1800 555
add_de1_button "off" {show_settings} 2000 800 2350 1350

# show whether the espresso machine is ready to make an espresso, or heating, or the tablet is disconnected
add_de1_variable "off" 1310 760 -justify left -anchor "center" -text "" -font novocento -fill "#444444" -width 1520 -textvariable {[de1_connected_state 5]} 

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

