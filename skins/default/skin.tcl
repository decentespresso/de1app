package require de1 1.0

##############################################################################################################################################################################################################################################################################
# DECENT ESPRESSO DEFAULT SKIN
##############################################################################################################################################################################################################################################################################

# use the standard graphic filenames and standard settings pages
source "[homedir]/skins/default/standard_includes.tcl"

##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is idle

add_de1_text "splash" 510 1240 -text [translate "START"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 


# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off" 510 1240 -text [translate "WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 1280 1240 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 2048 1240 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

add_de1_text "water" 510 1240 -text [translate "WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 2048 1240 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso" 1280 1240 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 210 612 808 1416
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 1748 616 2346 1414
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 948 584 1606 1444

# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 400 400
add_de1_button "off" { say [translate {settings}] $::settings(sound_button_in); show_settings } 2000 0 2560 500
add_de1_variable "off" 1280 1320 -justify right -anchor "center" -text "" -font Helv_9_bold -fill "#7f879a" -width 520 -textvariable {[group_head_heating_text]} 

# during espresso we show the current state of things (heating, waiting, flushing, etc)
add_de1_variable "espresso" 1280 1320 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {[translate [de1_substate_text]]} 

# show whether the espresso machine is ready to make an espresso, or heating, or the tablet is disconnected
add_de1_variable "off" 20 1520 -justify left -anchor "nw" -text "" -font Helv_10 -fill "#666666" -width 1520 -textvariable {[de1_connected_state 5]} 

##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is doing steam, hot water or espresso

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"
