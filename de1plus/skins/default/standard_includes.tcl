#set ::dui::settings(debug_buttons) 1

##############################################################################################################################################################################################################################################################################

# most skins will not bother replacing these graphics
add_de1_page "sleep" "sleep.jpg" "default"
add_de1_page "tankfilling" "filling_tank.jpg" "default"
add_de1_page "tankempty refill" "fill_tank.jpg" "default"
add_de1_page "cleaning" "cleaning.jpg" "default"
add_de1_page "message calibrate calibrate2 calibrate3 infopage versionpage tabletstyles languages extensions profile_notes measurements temperature_steps" "settings_message.png" "default"
add_de1_page "create_preset" "settings_3_choices.png" "default"
add_de1_page "firmware_update_3" "firmware_upgrade.jpg" "default"
add_de1_page "firmware_update_1 firmware_update_4" "firmware_upgrade_off.jpg" "default"
add_de1_page "firmware_update_2 firmware_update_5" "firmware_upgrade_on.jpg" "default"
add_de1_page "descaling" "descaling.jpg" "default"
add_de1_page "descale_prepare" "descale_prepare.jpg" "default"
add_de1_page "ghc" "ghc.jpg" "default"
add_de1_page "travel_prepare" "travel_prepare.jpg" "default"
add_de1_page "travel_do" "travel_do.jpg" "default"
add_de1_page "descalewarning" "descalewarning.jpg" "default"


#add_de1_text "tankempty refill" 1280 750 -text [translate "Please add water"] -font Helv_20_bold -fill "#AAAAAA" -justify "center" -anchor "center" -width 900
add_de1_text "cleaning" 1280 80 -text [translate "Cleaning"] -font Helv_20_bold -fill "#EEEEEE" -justify "center" -anchor "center" -width 900
add_de1_text "descaling" 1280 80 -text [translate "Descaling"] -font Helv_20_bold -fill "#CCCCCC" -justify "center" -anchor "center" -width 900

# you need to descale your steam wand
add_de1_text "descalewarning" 1280 1310 -text [translate "Your steam wand is clogging up"] -font Helv_17_bold -fill "#FFFFFF" -justify "center" -anchor "center" -width 900
add_de1_text "descalewarning" 1280 1480 -text [translate "It needs to be descaled soon"] -font Helv_15_bold -fill "#FFFFFF" -justify "center" -anchor "center" -width 900
add_de1_button "descalewarning" {say [translate {Descale}] $::settings(sound_button_in); show_settings descale_prepare;} 0 0 2560 1600 


# group head controller FYI messages
add_de1_page "ghc_steam ghc_espresso ghc_flush ghc_hotwater" "ghc.jpg" "default"
	add_de1_text "ghc_steam" 1990 680 -text "\[      \]\n[translate {Tap here for steam}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 950
	add_de1_text "ghc_espresso" 1936 950 -text "\[      \]\n[translate {Tap here for espresso}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 950
	add_de1_text "ghc_flush" 1520 840 -text "\[      \]\n[translate {Tap here to flush}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 750
	add_de1_text "ghc_hotwater" 1630 600 -text "\[      \]\n[translate {Tap here for hot water}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 820
	add_de1_button "ghc_steam ghc_espresso ghc_flush ghc_hotwater" {say [translate {Ok}] $::settings(sound_button_in); page_show off;} 0 0 2560 1600 


# out of water page
add_de1_button "tankempty refill" {say [translate {awake}] $::settings(sound_button_in);start_refill_kit} 0 0 2560 1400 
	add_de1_text "tankempty refill" 1280 750 -text [translate "Please add water"] -font Helv_20_bold -fill "#CCCCCC" -justify "center" -anchor "center" -width 900
	add_de1_variable "tankempty refill" 1280 900 -justify center -anchor "center" -text "" -font Helv_10 -fill "#CCCCCC" -width 520 -textvariable {[refill_kit_retry_button]} 
	add_de1_text "tankempty" 340 1504 -text [translate "Exit App"] -font Helv_10_bold -fill "#AAAAAA" -anchor "center" 
	add_de1_text "tankempty" 2220 1504 -text [translate "Ok"] -font Helv_10_bold -fill "#AAAAAA" -anchor "center" 
	add_de1_button "tankempty" {say [translate {Exit}] $::settings(sound_button_in); .can itemconfigure $::message_label -text [translate "Going to sleep"]; .can itemconfigure $::message_button_label -text [translate "Wait"]; after 10000 {.can itemconfigure $::message_button_label -text [translate "Ok"]; }; set_next_page off message; page_show message; after 500 app_exit} 0 1402 800 1600
	add_de1_button "tankempty refill" {say [translate {awake}] $::settings(sound_button_in);start_refill_kit} 1760 1402 2560 1600


set_de1_screen_saver_directory "[homedir]/saver"

# include the generic settings features for all DE1 skins.  
source "[homedir]/skins/default/de1_skin_settings.tcl"

