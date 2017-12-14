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


load_font "orbitron" "[skin_directory]/orbitron.ttf" 19


# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
if {[language] != "en"} {
	add_de1_text "off espresso" 362 1205 -text [translate "ESPRESSO"] -font {orbitron} -fill "#CCCCCC" -anchor "center" 
	add_de1_text "off steam" 1289 1215  -text [translate "STEAM"] -font {orbitron} -fill "#CCCCCC" -anchor "center" 
	add_de1_text "off water" 2048 1225 -text [translate "WATER"] -font {orbitron} -fill "#CCCCCC" -anchor "center" 
}


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 115 250 680 1290
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1780 250 2275 1290
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 1050 250 1570 1290

# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 1330 400 1590
add_de1_button "off" {show_settings} 2220 1320 2559 1590

# show whether the espresso machine is ready to make an espresso, or heating, or the tablet is disconnected
add_de1_variable "off" 20 1520 -justify left -anchor "nw" -text "" -font orbitron -fill "#CCCCCC" -width 1520 -textvariable {[de1_connected_state 5]} 

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

