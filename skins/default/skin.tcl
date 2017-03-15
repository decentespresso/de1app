##############################################################################################################################################################################################################################################################################
# DECENT ESPRESSO DEFAULT SKIN
##############################################################################################################################################################################################################################################################################

# use the standard graphic filenames and standard settings pages
source "[homedir]/skins/default/standard_includes.tcl"

##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is idle

add_de1_text "off water" 510 1076 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off steam" 2048 1076 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off espresso" 1280 1076 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 210 612 808 1416
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 1748 616 2346 1414
add_de1_button "off" "say [translate {esspresso}] $::settings(sound_button_in);start_espresso" 948 584 1606 1444

add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 400 400
add_de1_button "off" {backup_settings; page_to_show_when_off settings_1} 2000 0 2560 500
add_de1_variable "off" 1280 1236 -justify right -anchor "center" -text "" -font Helv_8 -fill "#7f879a" -width 520 -textvariable {[group_head_heating_text]} 

##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is doing steam, hot water or espresso

add_de1_button "steam" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 2560 1600
add_de1_button "water" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 2560 1600
add_de1_variable "espresso" 1280 1136 -text "" -font Helv_9_bold -fill "#7f879a" -anchor "center" -textvariable {"[translate [de1_substate_text]]"} 
add_de1_variable "espresso" 1285 1226 -justify left -anchor "center" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[pour_timer][translate "s"]} 
add_de1_button "espresso" "say [translate {stop}] $::settings(sound_button_in);start_idle" 0 0 2560 1600


##############################################################################################################################################################################################################################################################################
# when the SCREEN SAVER is on or about to come on
add_de1_button "saver" "say [translate {awake}] $::settings(sound_button_in);start_idle" 0 0 2560 1600
add_de1_text "sleep" 2500 1450 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_button "sleep" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 2560 1600

# tapping the logo exits the app
add_de1_button "off" "exit" 800 0 1750 500
