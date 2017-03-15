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

