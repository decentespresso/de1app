##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is doing steam, hot water or espresso

add_de1_button "steam" {say [translate {stop}] $::settings(sound_button_in);start_idle} 0 0 2560 1600
add_de1_button "water" {say [translate {stop}] $::settings(sound_button_in);start_idle} 0 0 2560 1600
add_de1_button "espresso" {say [translate {stop}] $::settings(sound_button_in);start_idle} 0 0 2560 1600

##############################################################################################################################################################################################################################################################################
# when the SCREEN SAVER is on or about to come on
add_de1_button "saver descaling cleaning" {say [translate {awake}] $::settings(sound_button_in);start_idle} 0 0 2560 1600
add_de1_button "tankempty refill" {say [translate {awake}] $::settings(sound_button_in);start_refill_kit} 0 0 2560 1600 
add_de1_variable "tankempty refill" 1280 900 -justify center -anchor "center" -text "" -font Helv_10 -fill "#CCCCCC" -width 520 -textvariable {[refill_kit_retry_button]} 

add_de1_text "sleep" 2500 1450 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_button "sleep" {say [translate {sleep}] $::settings(sound_button_in);start_sleep} 0 0 2560 1600

