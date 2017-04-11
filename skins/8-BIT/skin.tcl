
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

load_font "PressStart2P" "[skin_directory]/PressStart2P.ttf" 26


# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off water" 2150 1125 -text [translate "HOT WATER"] -font {PressStart2P} -fill "#ffffff" -anchor "center" 
add_de1_text "off espresso" 455 1125 -text [translate "ESPRESSO"] -font {PressStart2P} -fill "#ffffff" -anchor "center" 
add_de1_text "off" 1325 1125  -text [translate "STEAM"] -font {PressStart2P} -fill "#ffffff" -anchor "center" 
add_de1_text "steam" 2055 1125  -text [translate "STEAM"] -font {PressStart2P} -fill "#ffffff" -anchor "center" 


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 75 385 775 1250
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1800 385 2500 1250
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 960 385 1650 1250

# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 300 270
add_de1_button "off" {backup_settings; page_to_show_when_off settings_1} 2250 0 2560 270

#when Espresso is running this will show the geeky info

add_de1_text "espresso" 1835 350 -text [translate "ESPRESSO"] -font PressStart2P -fill "#2d3046" -anchor "center" 
add_de1_variable "espresso" 1850 420 -text "" -font PressStart2P_50 -fill "#ffffff" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 

add_de1_text "espresso" 1765 550 -justify right -anchor "ne" -text [translate "Elapsed:"] -font PressStart2P -fill "#ffffff" -width 520
add_de1_variable "espresso" 1780 550 -justify left -anchor "nw" -text "" -font PressStart2P -fill "#ffffff" -width 520 -textvariable {[pour_timer][translate "s"]} 

add_de1_text "espresso" 1765 600 -justify right -anchor "ne" -text [translate "Auto off:"] -font PressStart2P -fill "#7f879a" -width 520
add_de1_variable "espresso" 1755 600 -justify left -anchor "nw" -text "" -font PressStart2P  -fill "#42465c" -width 520 -textvariable {[setting_espresso_max_time_text]} 

add_de1_text "espresso" 1765 750 -justify right -anchor "ne" -text [translate "Pressure:"] -font PressStart2P -fill "#7f879a" -width 520
add_de1_variable "espresso" 1755 750 -justify left -anchor "nw" -text "" -font PressStart2P -fill "#42465c" -width 520 -textvariable {[pressure_text]} 

add_de1_text "espresso" 1765 900 -justify right -anchor "ne" -text [translate "Water temp:"] -font PressStart2P -fill "#7f879a" -width 520
add_de1_variable "espresso" 1755 900 -justify left -anchor "nw" -text "" -font PressStart2P -fill "#42465c" -width 520 -textvariable {[watertemp_text]} 




##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

