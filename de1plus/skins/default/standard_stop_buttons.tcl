##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is doing steam, hot water or espresso

# the graphics for each of the main espresso machine modes
add_de1_page "off" "nothing_on.png"
add_de1_page "espresso" "espresso_on.png"
add_de1_page "steam" "steam_on.png"
add_de1_page "water hotwaterrinse" "tea_on.png"


add_de1_button "steam" {say [translate {stop}] $::settings(sound_button_in); start_idle; check_if_steam_clogged} 0 0 2560 1600
add_de1_button "water" {say [translate {stop}] $::settings(sound_button_in); start_idle} 0 0 2560 1600
add_de1_button "espresso" {say [translate {stop}] $::settings(sound_button_in); start_idle} 0 0 2560 1600

##############################################################################################################################################################################################################################################################################
# when the SCREEN SAVER is on or about to come on
#
# using a buttonnativepress so that if running on Android, we can use the OS based filtering on spurious taps
add_de1_button "saver descaling cleaning" {say [translate {awake}] $::settings(sound_button_in);start_idle; de1_send_waterlevel_settings} 0 0 2560 1600 "buttonnativepress"

add_de1_button "tankempty refill" {say [translate {awake}] $::settings(sound_button_in);start_refill_kit} 0 0 2560 1400 
	add_de1_text "tankempty refill" 1280 750 -text [translate "Please add water"] -font Helv_20_bold -fill "#CCCCCC" -justify "center" -anchor "center" -width 900
	add_de1_variable "tankempty refill" 1280 900 -justify center -anchor "center" -text "" -font Helv_10 -fill "#CCCCCC" -width 520 -textvariable {[refill_kit_retry_button]} 
	add_de1_text "tankempty" 340 1504 -text [translate "Exit App"] -font Helv_10_bold -fill "#AAAAAA" -anchor "center" 
	add_de1_text "tankempty" 2220 1504 -text [translate "Ok"] -font Helv_10_bold -fill "#AAAAAA" -anchor "center" 
	add_de1_button "tankempty" {say [translate {Exit}] $::settings(sound_button_in); .can itemconfigure $::message_label -text [translate "Going to sleep"]; .can itemconfigure $::message_button_label -text [translate "Wait"]; after 10000 {.can itemconfigure $::message_button_label -text [translate "Ok"]; }; set_next_page off message; page_show message; after 500 app_exit} 0 1402 800 1600
	add_de1_button "tankempty refill" {say [translate {awake}] $::settings(sound_button_in);start_refill_kit} 1760 1402 2560 1600


add_de1_text "sleep" 2500 1450 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 
add_de1_button "sleep" {say [translate {sleep}] $::settings(sound_button_in);start_sleep} 0 0 2560 1600

#bind Canvas <ButtonPress-1> {+; focus %W}

focus .can
bind Canvas <KeyPress> {handle_keypress %k}
