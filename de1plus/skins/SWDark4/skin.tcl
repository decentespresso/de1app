#SWDark4 theme by Spencer Webb, 30th April 2020
#Adapted and inspired by the Insight & Modernist themes.  Thanks John, Damian & David V!  

source "[homedir]/skins/default/standard_includes.tcl"

set ::skindebug 0
set ::debugging 0

##### Colour variables for chart lines#####
set chartbackgroundcol "#242424"
set ::chartaxiscol "#aaaaaa"
set ::chartgridcol "#343434"
set ::chartprofilestepcol "#4E4E4E"
set ::chartpressurelinecol "#86C240"
set ::chartpressurelinerescale "6"
set ::chartpressuregoallinecol "#86C240"
set ::chartpressuregoallinerescale "12" 
set ::chartflowlinecol "#43B1E3"
set ::chartflowlinerescale "12"
set ::chartflowgoallinecol "#87c6e3"
set ::chartflowgoallinerescale "6"
set ::charttemplinecol "#FF2600"
set ::charttemplinerescale "12"
set ::charttempgoallinecol "#ff674c"
set ::charttempgoallinerescale "6"
set ::chartweightlinecol "#ff6a00"
set ::chartweightlinerescale "12"
set ::chartprofilestepzoomcol "#ffffff"
#set ::chartresistancecol "#ffc000"
set ::chartresistancecol "#ffcc33"
set ::chartgodpressurecol "#CAF795"
set ::chartgodflowcol "#A1E2FF"
set ::chartgodweightcol "#FFD1B0"
set ::chartgodtempcol "#FFB9AD"
set ::detailtextcol "#9f9f9f"
set ::detailtextheadingcol "#ffffff"
set ::de1(widget_current_profile_name_color_normal) "#FF2600"
set ::de1(widget_current_profile_name_color_changed) "#9f9f9f"

load_font "helveticabold12" "[skin_directory]/helveticabold12.ttf" 12
load_font "helveticabold16" "[skin_directory]/helveticabold16.ttf" 16
load_font "helveticabold17" "[skin_directory]/helveticabold17.ttf" 17
load_font "helveticabold18" "[skin_directory]/helveticabold18.ttf" 18
load_font "helveticabold20" "[skin_directory]/helveticabold20.ttf" 20
load_font "helveticabold24" "[skin_directory]/helveticabold24.ttf" 24

#puts "debugging: $::debugging"

#Loads functions
package require de1plus 1.0
package ifneeded swdark_functions 4.0 [list source [file join "[skin_directory]/swdark_functions.tcl"]]
package require swdark_functions 4.0

#swdark_filename
load_swdark_settings

#Sets Y axis zoom scale
swdark_setyaxis
set ::zoomed_y2_axis_scale [expr {$::swdark_settings(sw_y_axisscale) / 2}]

#swdark4 check for empTy variables
swdark4varscheck


##############################################################################################################################################################################################################################################################################
# the graphics for each of the main espresso machine modes

#Espresso
set ::settings(display_rate_espresso) 1
add_de1_page "home" "home.png"
if {$::settings(display_rate_espresso) == 1} {
	add_de1_page "off espresso_3" "home.png"
} else {
	# no need to display the heart icon after espresso is finished, if "Rate espresso" is disabled
	add_de1_page "off" "home.png"
	add_de1_page "espresso_3" "home.png"
}
add_de1_page "espresso espresso_zoomed espresso_zoomed_temperature" "home_2.png"
add_de1_page "espresso_2" "home_2.png"
add_de1_page "off_zoomed off_zoomed_temperature" "home.png"

#swsettings
add_de1_page "swsettings" "swsettings.png"
add_de1_page "swbrewsettings" "swbrewsettings.png"

#Steam
add_de1_page "steam steam_zoom" "home_2.png"
add_de1_page "off_steam_zoom steam_1" "home.png"
add_de1_page "steam_2" "home.png"
add_de1_page "steam_3" "home.png"

#Water
add_de1_page "water" "home_2.png"
add_de1_page "water_1" "home.png"
add_de1_page "water_2" "home.png"
add_de1_page "water_3" "home.png"

#Preheat
add_de1_page "preheat preheat_1 hotwaterrinse" "home_2.png"
add_de1_page "preheat_2" "home_2.png"
add_de1_page "preheat_3" "home.png"
add_de1_page "preheat_4" "home.png"


# most skins will not bother replacing these graphics
#add_de1_page "sleep" "sleep.jpg" "default"
#add_de1_page "tankfilling" "filling_tank.jpg" "default"
#add_de1_page "tankempty refill" "fill_tank.jpg" "default"
#add_de1_page "cleaning" "cleaning.jpg" "default"
#add_de1_page "message calibrate infopage tabletstyles languages profile_notes measurements" "settings_message.png" "default"
#add_de1_page "create_preset" "settings_3_choices.png" "default"
#add_de1_page "firmware_update_3" "firmware_upgrade.jpg" "default"
#add_de1_page "firmware_update_1 firmware_update_4" "firmware_upgrade_off.jpg" "default"
#add_de1_page "firmware_update_2 firmware_update_5" "firmware_upgrade_on.jpg" "default"
#add_de1_page "descaling" "descaling.jpg" "default"
#add_de1_page "descale_prepare" "descale_prepare.jpg" "default"
#add_de1_page "ghc" "ghc.jpg" "default"
#add_de1_page "travel_prepare" "travel_prepare.jpg" "default"
#add_de1_page "travel_do" "travel_do.jpg" "default"
#add_de1_page "descalewarning" "descalewarning.jpg" "default"
#add_de1_page "message calibrate calibrate2 infopage tabletstyles languages profile_notes measurements" "settings_message.png" "default"
#add_de1_page "message calibrate calibrate2 infopage tabletstyles languages profile_notes measurements temperature_steps" "settings_message.png" "default"

#add_de1_text "tankempty refill" 1280 750 -text [translate "Please add water"] -font Helv_20_bold -fill "#AAAAAA" -justify "center" -anchor "center" -width 900
#add_de1_text "cleaning" 1280 80 -text [translate "Cleaning"] -font Helv_20_bold -fill "#EEEEEE" -justify "center" -anchor "center" -width 900
#add_de1_text "descaling" 1280 80 -text [translate "Descaling"] -font Helv_20_bold -fill "#CCCCCC" -justify "center" -anchor "center" -width 900

#add_de1_text "descalewarning" 1280 1310 -text [translate "Your steam wand is clogging up"] -font Helv_17_bold -fill "#FFFFFF" -justify "center" -anchor "center" -width 900
#add_de1_text "descalewarning" 1280 1480 -text [translate "It needs to be descaled soon"] -font Helv_15_bold -fill "#FFFFFF" -justify "center" -anchor "center" -width 900
#add_de1_button "descalewarning" {say [translate {Descale}] $::settings(sound_button_in); show_settings descale_prepare;} 0 0 2560 1600 


# group head controller FYI messages
#add_de1_page "ghc_steam ghc_espresso ghc_flush ghc_hotwater" "ghc.jpg" "default"
#	add_de1_text "ghc_steam" 1990 680 -text "\[      \]\n[translate {Tap here for steam}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 950
#	add_de1_text "ghc_espresso" 1936 950 -text "\[      \]\n[translate {Tap here for espresso}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 950
#	add_de1_text "ghc_flush" 1520 840 -text "\[      \]\n[translate {Tap here to flush}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 750
#	add_de1_text "ghc_hotwater" 1630 600 -text "\[      \]\n[translate {Tap here for hot water}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 820
#	add_de1_button "ghc_steam ghc_espresso ghc_flush ghc_hotwater" {say [translate {Ok}] $::settings(sound_button_in); page_show off;} 0 0 2560 1600 


# out of water page
#add_de1_button "tankempty refill" {say [translate {awake}] $::settings(sound_button_in);start_refill_kit} 0 0 2560 1400 
#	add_de1_text "tankempty refill" 1280 750 -text [translate "Please add water"] -font Helv_20_bold -fill "#CCCCCC" -justify "center" -anchor "center" -width 900
#	add_de1_variable "tankempty refill" 1280 900 -justify center -anchor "center" -text "" -font Helv_10 -fill "#CCCCCC" -width 520 -textvariable {[refill_kit_retry_button]} 
#	add_de1_text "tankempty" 340 1504 -text [translate "Exit App"] -font Helv_10_bold -fill "#AAAAAA" -anchor "center" 
#	add_de1_text "tankempty" 2220 1504 -text [translate "Ok"] -font Helv_10_bold -fill "#AAAAAA" -anchor "center" 
#	add_de1_button "tankempty" {say [translate {Exit}] $::settings(sound_button_in); .can itemconfigure $::message_label -text [translate "Going to sleep"]; .can itemconfigure $::message_button_label -text [translate "Wait"]; after 10000 {.can itemconfigure $::message_button_label -text [translate "Ok"]; }; set_next_page off message; page_show message; after 500 app_exit} 0 1402 800 1600
#	add_de1_button "tankempty refill" {say [translate {awake}] $::settings(sound_button_in);start_refill_kit} 1760 1402 2560 1600
#

# new screensavers while we're at it. 
set_de1_screen_saver_directory "[skin_directory]/screen_saver"

# include the generic settings features for all DE1 skins.  
#source "[homedir]/skins/default/de1_skin_settings.tcl"

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
#source "[homedir]/skins/default/standard_stop_buttons.tcl"



# the font used in the big round green buttons needs to fit appropriately inside the circle, 
# and thus is dependent on the translation of the words inside the circle
set green_button_font "Helv_19_bold"
if {[language] == "fr" || [language] == "es" || [language] == "sv"} {
	set green_button_font "Helv_16_bold"
}

set ::current_espresso_page "off"


#Labels
#Main Action Buttons when doing nothing
add_de1_text "home off off_zoomed off_steam_zoom off_zoomed_temperature espresso_1 espresso_2 espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature preheat_1 preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3" 2356 179 -text [translate "ESPRESSO"] -font helveticabold20 -fill "#ffffff" -anchor "center" 

add_de1_text "off_zoomed off_steam_zoom off_zoomed_temperature off espresso_1 espresso_2 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_2 steam_3 steam_zoom_3 water_1 water_2 water_3" 2356 519 -text [translate "STEAM"] -font helveticabold20 -fill "#ffffff" -anchor "center" 

add_de1_text "off_zoomed off_steam_zoom off_zoomed_temperature off espresso_1 espresso_2 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3" 1971 179  -text [translate "WATER"] -font helveticabold20 -fill "#ffffff" -anchor "center" 

add_de1_text "off_zoomed off_steam_zoom off_zoomed_temperature off espresso_1 espresso_2 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3" 1971 519  -text [translate "FLUSH"] -font helveticabold20 -fill "#ffffff" -anchor "center" 


#Main Action Buttons when doing something
add_de1_text "espresso espresso_zoomed espresso_temperature espresso_zoomed_temperature" 2162.825 178.88 -text [translate "ADVANCE"] -font helveticabold20 -fill "#ffffff" -anchor "center" 

add_de1_text "steam steam_zoom" 2162.825 178.88 -text [translate "STEAM"] -font helveticabold20 -fill "#ffffff" -anchor "center" 

add_de1_text "water" 2162.825 178.88  -text [translate "WATER"] -font helveticabold20 -fill "#ffffff" -anchor "center" 

add_de1_text "preheat preheat_2 hotwaterrinse" 2162.825 178.88  -text [translate "FLUSH"] -font helveticabold20 -fill "#ffffff" -anchor "center" 


# indicate whether we are connected to the DE1+ or not
add_de1_variable "off off_zoomed off_zoomed_temperature" 2356 215 -justify center -anchor "center" -text "" -font Helv_6 -fill $::detailtextcol -width 520 -textvariable {[de1_connected_state]} 

# labels for Power/Settings
if { [language] == "de" || [language] == "da" || [language] == "sv" || [language] == "pt" || [language] == "nl" } {
	add_de1_text "home swsettings swbrewsettings off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" 2356 1503 -text [translate "POWER"] -font helveticabold12 -fill "#ffffff" -anchor "center"
	add_de1_text "home swsettings swbrewsettings off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" 1971 1503 -text [translate "SETTINGS"] -font helveticabold12 -fill "#ffffff" -anchor "center"
} elseif { [language] == "it" || [language] == "de-ch" || [language] == "fr" || [language] == "pl" || [language] == "sk" || [language] == "hu" }  {
	add_de1_text "home swsettings swbrewsettings off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" 2356 1503 -text [translate "POWER"] -font helveticabold16 -fill "#ffffff" -anchor "center"
	add_de1_text "home swsettings swbrewsettings off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" 1971 1505.5 -text [translate "SETTINGS"] -font helveticabold16 -fill "#ffffff" -anchor "center"
} else {
	add_de1_text "home swsettings swbrewsettings off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" 2356 1505.5 -text [translate "POWER"] -font helveticabold18 -fill "#ffffff" -anchor "center"
	add_de1_text "home swsettings swbrewsettings off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" 1971 1505.5 -text [translate "SETTINGS"] -font helveticabold18 -fill "#ffffff" -anchor "center"
	
}



################################################################################################################################################################################################################################################################################################

#Main Buttons

add_de1_button "steam espresso preheat hotwaterrinse water espresso_2 preheat_2 steam_2 water_2 espresso_zoomed espresso_zoomed_temperature steam_zoom_3 steam_zoom" {say [translate {stop}] $::settings(sound_button_in); set_next_page off off; start_idle} 2028 296 2298 401

add_de1_variable "steam espresso preheat hotwaterrinse water espresso_2 preheat_2 steam_2 water_2 espresso_zoomed espresso_zoomed_temperature steam_zoom_3 steam_zoom" 2162.825 518.88 -text [translate "stop"] -font helveticabold18 -fill "#FFFFFF" -anchor "center" -textvariable {[stop_text_if_espresso_stoppable]} 

# make and stop espresso button
if {$::swdark_settings(swbrewsettings) == 1} {
  if {$::settings(scale_bluetooth_address) != ""} {
	add_de1_button "home off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" { say [translate {swbrewsettings}] $::settings(sound_button_in); set_next_page off swbrewsettings; start_idle} 2173 20 2538 338
	add_de1_text "swbrewsettings" 2163.33 300 -text [translate "START"] -font helveticabold24 -fill "#ffffff" -anchor "center"
	add_de1_variable "swbrewsettings" 2163.33 350 -anchor "center" -text "" -font Helv_7 -fill #cccccc -width [rescale_x_skin 650] -textvariable {$::settings(profile_title)}
	add_de1_button "swbrewsettings" {say [translate {espresso}] $::settings(sound_button_in); save_settings ; set ::current_espresso_page espresso; set_next_page off off; start_espresso} 1788.65 20 2538 677.76
  } else {
	add_de1_button "home off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" {say [translate {espresso}] $::settings(sound_button_in);set ::current_espresso_page espresso; set_next_page off off; start_espresso} 2173 20 2538 338
  }
} else {
	add_de1_button "home off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" {say [translate {espresso}] $::settings(sound_button_in);set ::current_espresso_page espresso; set_next_page off off; start_espresso} 2173 20 2538 338
}


#Dispense hot water button
add_de1_button "home off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" {say [translate {Hot water}] $::settings(sound_button_in); set_next_page water water; start_water} 1788 20 2154 337
#add_de1_button "steam espresso preheat water espresso_2 preheat_2 steam_2 water_2 espresso_zoomed espresso_zoomed_temperature steam_zoom_3 steam_zoom" {say [translate {stop}] $::settings(sound_button_in); set_next_page off off; start_idle} 1788 20 2154 337

#Flush Button
add_de1_button "home off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" {say [translate {pre-heat cup}] $::settings(sound_button_in); set ::settings(preheat_temperature) 90; set_next_page hotwaterrinse preheat_2; start_hot_water_rinse} 1788 360 2154 678
#add_de1_button "steam preheat water espresso espresso_2 preheat_2 steam_2 water_2 espresso_zoomed espresso_zoomed_temperature steam_zoom_3 steam_zoom" {say [translate {stop}] $::settings(sound_button_in); set_next_page off off; start_idle} 1788 360 2154 678

#Steam button
add_de1_button "home off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" {say [translate {steam}] $::settings(sound_button_in); set_next_page steam steam; start_steam} 2173 360 2538 678
#add_de1_button "steam espresso preheat water espresso_2 preheat_2 steam_2 water_2 espresso_zoomed espresso_zoomed_temperature steam_zoom_3 steam_zoom" {say [translate {stop}] $::settings(sound_button_in); set_next_page off off; start_idle} 2173 360 2538 678

#STOP Button when doing something
add_de1_button "steam steam_zoom_3 preheat hotwaterrinse water preheat_2 steam_2 water_2 steam_zoom" {after cancel {set_next_page off off; start_idle}; set_next_page off off; start_idle} 1789 20 2539 678

add_de1_button "espresso espresso_zoomed espresso_zoomed_temperature espresso_2" {after cancel {set_next_page off off; start_idle}; set_next_page off off; start_idle} 1789 360 2539 678


#Manual Shot Advance Button - full credits to Damian for the code
add_de1_button "espresso espresso_2 espresso_zoomed espresso_zoomed_temperature" {say [translate {advance}] $::settings(sound_button_in); DSx_next_step} 1789 20 2539 337



#Power / Settings Buttons

# the "go to sleep" button and the whole-screen button for coming back awake
add_de1_button "saver descaling cleaning" {say [translate {awake}] $::settings(sound_button_in); set_next_page off off; start_idle} 0 0 2560 1600

if {$::debugging == 1} {
	add_de1_button "home swsettings swbrewsettings off espresso_1 espresso_2 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" {say [translate {sleep}] $::settings(sound_button_in); set ::current_espresso_page "off"; start_sleep} 2173 1430 2538 1580
} else {
	add_de1_button "home swsettings swbrewsettings off espresso_1 espresso_2 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" {say [translate {sleep}] $::settings(sound_button_in); set ::current_espresso_page "off"; start_sleep} 2173 1430 2538 1580
}

# settings button 
add_de1_button "home swsettings swbrewsettings off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" { say [translate {settings}] $::settings(sound_button_in); show_settings } 1788 1430 2153 1580 

#SWSettings Button
add_de1_button "home off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" { say [translate {swsettings}] $::settings(sound_button_in); set_next_page off swsettings; start_idle} 2336 1270 2475 1410

#Profile Edit Button
add_de1_button "home off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" {say [translate {}] $::settings(sound_button_in); show_settings; after 500 update_de1_explanation_chart;  set_next_page off $::settings(settings_profile_type); page_show off;  set ::settings(active_settings_tab) $::settings(settings_profile_type); fill_advanced_profile_steps_listbox; set_advsteps_scrollbar_dimensions ; start_idle} 1836 1270 1981 1410


#Scale Reconnect/Tare button
	if {$::settings(scale_bluetooth_address) != ""} {
		add_de1_button "home off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {connect}] $::settings(sound_button_in); catch {ble_connect_to_scale}; skale_tare; update_onscreen_variables} 2087 1270 2240 1410 
	} else {
		add_de1_button "home off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {connect}] $::settings(sound_button_in); page_show settings_4; scanning_restart; catch {ble_connect_to_scale}; update_onscreen_variables} 2087 1270 2240 1410
	}
		


#add_de1_variable "off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3" 2162 352 -text [translate "#"] -font helveticabold18 -fill "#FFFFFF" -anchor "center" -textvariable {[start_text_if_espresso_ready]} 
add_de1_variable "home swsettings off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 off_zoomed off_steam_zoom off_zoomed_temperature steam espresso preheat hotwaterrinse water espresso_2 preheat_2 steam_2 water_2 espresso_zoomed espresso_zoomed_temperature steam_zoom_3 steam_zoom" 2162 350 -text [translate "#"] -font helveticabold16 -fill "#FFFFFF" -anchor "center" -textvariable {[de1_substate_text]}

#add_de1_variable "steam espresso preheat water espresso_2 preheat_2 steam_2 water_2 espresso_zoomed espresso_zoomed_temperature steam_zoom_3 steam_zoom" 2162 452 -text [translate "stop"] -font helveticabold18 -fill "#FFFFFF" -anchor "center" -textvariable {[stop_text_if_espresso_stoppable]} 



################################################################################################################################################################################################################################################################################################
# espresso charts

set charts_width 1700

	
	# not yet ready to be used, still needs some work
	#set ::settings(display_pressure_delta_line) 0
	#set ::settings(display_flow_delta_line) 0

#######################
# 4 equal sized charts
add_de1_widget "home off espresso_1 espresso_2 espresso_3" graph 30 68 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed; 
		set_next_page espresso espresso_zoomed; 
		set_next_page espresso_3 espresso_3_zoomed; 
		page_show $::de1(current_context);
	}
	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartpressuregoallinecol -smooth $::settings(live_graph_smoothing_technique)  -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::chartpressurelinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create god_line_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodpressurecol  -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color $::chartprofilestepcol  -pixels 0 ; 
	# show the explanation
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartpressuregoallinecol -smooth $::settings(preview_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part1 -xdata espresso_de1_explanation_chart_elapsed_1 -ydata espresso_de1_explanation_chart_pressure_1 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartpressurelinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part2 -xdata espresso_de1_explanation_chart_elapsed_2 -ydata espresso_de1_explanation_chart_pressure_2 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartweightlinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part3 -xdata espresso_de1_explanation_chart_elapsed_3 -ydata espresso_de1_explanation_chart_pressure_3 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::charttemplinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 


	if {$::settings(display_pressure_delta_line) == 1} {
		$widget element create line_espresso_pressure_delta2  -xdata espresso_elapsed -ydata espresso_pressure_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #40dc94 -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	$widget axis configure y -color $::chartaxiscol	-tickfont Helv_6 -min 0.0 -max [expr {$::de1(max_pressure) + 0.01}] -subdivisions 5 -majorticks {1 3 5 7 9 11} 
	
	# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
		$widget grid configure -color $::chartgridcol
	}
} -plotbackground $chartbackgroundcol -width [rescale_x_skin $charts_width] -height [rescale_y_skin 400] -borderwidth 1 -background $chartbackgroundcol -plotrelief flat 


add_de1_widget "home off espresso_1 espresso_2 espresso_3" graph 47 500 {
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in);  
		set_next_page off off_zoomed; 
		set_next_page espresso espresso_zoomed;
		set_next_page espresso_3 espresso_3_zoomed;
		page_show $::de1(current_context);
	} 
	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartflowgoallinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5}; 

	$widget element create line_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::chartflowlinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  


	if {$::settings(display_flow_delta_line) == 1} {
		$widget element create line_espresso_flow_delta -xdata espresso_elapsed -ydata espresso_flow_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #98c5ff -pixels 0 -smooth $::settings(live_graph_smoothing_technique)
	}

	if {$::settings(scale_bluetooth_address) != ""} {
		$widget element create line_espresso_flow_weight  -xdata espresso_elapsed -ydata espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::chartweightlinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
		$widget element create god_line_espresso_flow_weight  -xdata espresso_elapsed -ydata god_espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodweightcol -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
		
		if {$::settings(chart_total_shot_weight) == 2} {
			$widget element create line_espresso_weight  -xdata espresso_elapsed -ydata espresso_weight_chartable -symbol none -label "" -linewidth [rescale_x_skin 4] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);  
		}
		
	}
	$widget element create god_line_espresso_flow  -xdata espresso_elapsed -ydata god_espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodflowcol -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color $::chartprofilestepcol  -pixels 0; 
	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6 ; 

	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -min 0.0 -max 8.01 -subdivisions 2 -majorticks {1 2 3 4 5 6 7 8}

	# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
	    $widget grid configure -color $::chartgridcol
	}

	# show the shot configuration
	$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartflowlinecol  -smooth $::settings(preview_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part1 -xdata espresso_de1_explanation_chart_elapsed_flow_1 -ydata espresso_de1_explanation_chart_flow_1 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartpressurelinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part2 -xdata espresso_de1_explanation_chart_elapsed_flow_2 -ydata espresso_de1_explanation_chart_flow_2 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartweightlinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part3 -xdata espresso_de1_explanation_chart_elapsed_flow_3 -ydata espresso_de1_explanation_chart_flow_3 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::charttemplinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 

} -width [rescale_x_skin $charts_width] -height [rescale_y_skin 400]  -plotbackground $chartbackgroundcol -borderwidth 1 -background $chartbackgroundcol -plotrelief flat




add_de1_widget "home off espresso_1 espresso_2 espresso_3" graph 30 940 {
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed_temperature; 
		set_next_page espresso espresso_zoomed_temperature; 
		set_next_page espresso_3 espresso_3_zoomed_temperature; 
		page_show $::de1(current_context);
	}

	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 6] -color $::charttempgoallinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 12] -color $::charttemplinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget element create god_line_espresso_temperature_basket -xdata espresso_elapsed -ydata god_espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 6] -color $::chartgodtempcol -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color $::chartprofilestepcol  -pixels 0 ; 

	$widget element create line_espresso_de1_explanation_chart_temp -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_temperature  -label "" -linewidth [rescale_x_skin 12] -color $::charttemplinecol  -smooth $::settings(preview_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 

	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6; 
	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -subdivisions 2;

	# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
		$widget grid configure -color $::chartgridcol
	}

	set ::temperature_chart_widget $widget
} -width [rescale_x_skin $charts_width] -height [rescale_y_skin 300]  -plotbackground $chartbackgroundcol -borderwidth 0 -background $chartbackgroundcol -plotrelief flat


####





#######################
# 3 equal sized charts for espresso pouring
# add_de1_widget "off espresso espresso_1 espresso_2 espresso_3" graph 22 267 { 
add_de1_widget "espresso" graph 30 100 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed; 
		set_next_page espresso espresso_zoomed; 
		set_next_page espresso_3 espresso_3_zoomed; 
		page_show $::de1(current_context);
	}
	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartpressuregoallinecol -smooth $::settings(live_graph_smoothing_technique)  -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::chartpressurelinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create god_line_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodpressurecol  -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color $::chartprofilestepcol  -pixels 0 ; 

	# show the explanation
	$widget element create line_espresso_de1_explanation_chart_pressureb -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 0] -color #ffffff  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part1b -xdata espresso_de1_explanation_chart_elapsed_1 -ydata espresso_de1_explanation_chart_pressure_1 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartpressurelinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part2b -xdata espresso_de1_explanation_chart_elapsed_2 -ydata espresso_de1_explanation_chart_pressure_2 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartweightlinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part3b -xdata espresso_de1_explanation_chart_elapsed_3 -ydata espresso_de1_explanation_chart_pressure_3 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::charttemplinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 

	if {$::settings(display_pressure_delta_line) == 1} {
		$widget element create line_espresso_pressure_delta2  -xdata espresso_elapsed -ydata espresso_pressure_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #40dc94 -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	$widget axis configure y -color $::chartaxiscol	-tickfont Helv_6 -min 0.0 -max [expr {$::de1(max_pressure) + 0.01}] -subdivisions 5 -majorticks {1 3 5 7 9 11} 
	
	# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
		$widget grid configure -color $::chartgridcol
	}
} -plotbackground $chartbackgroundcol -width [rescale_x_skin $charts_width] -height [rescale_y_skin 500] -borderwidth 1 -background $chartbackgroundcol -plotrelief flat 


add_de1_widget "espresso" graph 42 650 {
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in);  
		set_next_page off off_zoomed; 
		set_next_page espresso espresso_zoomed;
		set_next_page espresso_3 espresso_3_zoomed;
		page_show $::de1(current_context);
	} 
	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartflowgoallinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5}; 

	$widget element create line_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::chartflowlinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  


	if {$::settings(display_flow_delta_line) == 1} {
		$widget element create line_espresso_flow_delta  -xdata espresso_elapsed -ydata espresso_flow_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #98c5ff -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	if {$::settings(scale_bluetooth_address) != ""} {
		$widget element create line_espresso_flow_weight  -xdata espresso_elapsed -ydata espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::chartweightlinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
		$widget element create god_line_espresso_flow_weight  -xdata espresso_elapsed -ydata god_espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodweightcol -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
		
		if {$::settings(chart_total_shot_weight) == 2} {
			$widget element create line_espresso_weight  -xdata espresso_elapsed -ydata espresso_weight_chartable -symbol none -label "" -linewidth [rescale_x_skin 4] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);  
		}
		
	}
	$widget element create god_line_espresso_flow  -xdata espresso_elapsed -ydata god_espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodflowcol -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color $::chartprofilestepcol  -pixels 0; 
	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6 ; 

	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -min 0.0 -max 8.01 -subdivisions 2 -majorticks {1 2 3 4 5 6 7 8}

	# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
	    $widget grid configure -color $::chartgridcol
	}

	# show the shot configuration
	$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 0] -color #ffffff  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part1 -xdata espresso_de1_explanation_chart_elapsed_flow_1 -ydata espresso_de1_explanation_chart_flow_1 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartpressurelinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part2 -xdata espresso_de1_explanation_chart_elapsed_flow_2 -ydata espresso_de1_explanation_chart_flow_2 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartweightlinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part3 -xdata espresso_de1_explanation_chart_elapsed_flow_3 -ydata espresso_de1_explanation_chart_flow_3 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::charttemplinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 

} -width [rescale_x_skin $charts_width] -height [rescale_y_skin 500]  -plotbackground $chartbackgroundcol -borderwidth 1 -background $chartbackgroundcol -plotrelief flat


add_de1_widget "espresso" graph 25 1190 {
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed_temperature; 
		set_next_page espresso espresso_zoomed_temperature; 
		set_next_page espresso_3 espresso_3_zoomed_temperature; 
		page_show $::de1(current_context);
	}

	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 6] -color $::charttempgoallinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 12] -color $::charttemplinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget element create god_line_espresso_temperature_basket -xdata espresso_elapsed -ydata god_espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 6] -color $::chartgodtempcol -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color $::chartprofilestepcol  -pixels 0 ; 


	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6; 
	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -subdivisions 2;

	# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
		$widget grid configure -color $::chartgridcol
	}

	set ::temperature_chart_widget2 $widget
} -width [rescale_x_skin $charts_width] -height [rescale_y_skin 380]  -plotbackground $chartbackgroundcol -borderwidth 0 -background $chartbackgroundcol -plotrelief flat


####



add_de1_text "off_zoomed espresso_zoomed espresso_3_zoomed" 1750 30 -text [translate "Flow (mL/s)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "ne"
add_de1_text "off_zoomed espresso_zoomed espresso_3_zoomed" 975 30 -text [translate "Resistance"] -font Helv_7_bold -fill $::chartresistancecol -justify "left" -anchor "ne"
add_de1_text "off_zoomed espresso_zoomed espresso_3_zoomed" 40 30 -text [translate "Pressure (bar)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"
add_de1_text "off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" 40 30 -text [translate "Temperature ([return_html_temperature_units])"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"

add_de1_text "home off espresso_3" 40 28 -text [translate "Pressure (bar)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"
add_de1_text "home off espresso_3" 40 458 -text [translate "Flow (mL/s)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"

add_de1_text "espresso" 40 30 -text [translate "Pressure (bar)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"
add_de1_text "espresso" 40 600 -text [translate "Flow (mL/s)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"

if {$::settings(scale_bluetooth_address) != ""} {
	#set distance [font_width "Flow (mL/s)" Helv_7_bold]
	add_de1_text "home off espresso_3" 1740 453 -text [translate "Weight (g/s)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "ne" 
	add_de1_text "espresso" 1740 600 -text [translate "Weight (g/s)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "ne"
	
	#set distance [font_width "Weight (g/s)" Helv_7_bold]
	add_de1_text "home off_zoomed espresso_zoomed espresso_3_zoomed" 1600 220 -text [translate "Weight (g/s)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "ne" 	
}

add_de1_text "home off espresso espresso_3" 40 890 -text [translate "Temperature ([return_html_temperature_units])"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"
add_de1_text "espresso" 40 1140 -text [translate "Temperature ([return_html_temperature_units])"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"
add_de1_text "home off espresso_3" 40 1230 -text [translate "Steam"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"
add_de1_text "steam_zoom_off steam_zoom" 40 30 -text [translate "Steam"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"

#######################################################################################


#######################
# zoomed espresso
# edit this 

#Insight Code
#add_de1_widget "off_zoomed espresso_zoomed espresso_3_zoomed" graph 40 100 {
#	bind $widget [platform_button_press] { 
#		#msg "100 = [rescale_y_skin 200] = %y = [rescale_y_skin 726]"
#		if {%x < [rescale_y_skin 800]} {
#			# left column clicked on chart, indicates zoom
#
#			if {%y > [rescale_y_skin 726]} {
#				if {$::settings(zoomed_y_axis_scale) < 14} {
#					# 12 is the max Y axis allowed
#					incr ::settings(zoomed_y_axis_scale) 2
#					incr ::zoomed_y2_axis_scale
#				}
#			} else {
#				if {$::settings(zoomed_y_axis_scale) > 2} {
#					incr ::settings(zoomed_y_axis_scale) -2
#					incr ::zoomed_y2_axis_scale -1
#				}
#			}
#			%W axis configure y -max $::settings(zoomed_y_axis_scale)
#			%W axis configure y2 -max $::zoomed_y2_axis_scale

#Adds support for SWDark Variable
add_de1_widget "off_zoomed espresso_zoomed espresso_3_zoomed" graph 40 100 {
	bind $widget [platform_button_press] { 
		#msg "100 = [rescale_y_skin 200] = %y = [rescale_y_skin 726]"

		set x [translate_coordinates_finger_down_x %x]
		set y [translate_coordinates_finger_down_y %y]

		if {$x < [rescale_y_skin 800]} {
			# left column clicked on chart, indicates zoom

			if {$y > [rescale_y_skin 726]} {
				if {$::swdark_settings(sw_y_axisscale) < 14} {
					# 12 is the max Y axis allowed
					incr ::swdark_settings(sw_y_axisscale) 2
					incr ::zoomed_y2_axis_scale
					save_swdark_settings
				}
			} else {
				if {$::swdark_settings(sw_y_axisscale) > 2} {
					incr ::swdark_settings(sw_y_axisscale) -2
					incr ::zoomed_y2_axis_scale -1
					save_swdark_settings
				}
			}
			%W axis configure y -max $::swdark_settings(sw_y_axisscale)
			%W axis configure y2 -max $::zoomed_y2_axis_scale
		

		}  else {
			say [translate {zoom}] $::settings(sound_button_in); 
			set_next_page espresso_3 espresso_3; 
			set_next_page espresso_3_zoomed espresso_3; 
			set_next_page espresso espresso; 
			set_next_page espresso_zoomed espresso; 
			set_next_page off off; 
			set_next_page off_zoomed off; 
			page_show $::de1(current_context)
		}
	}

	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color $::chartpressuregoallinecol  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::chartpressurelinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	if {$::settings(display_pressure_delta_line) == 1} {
		$widget element create line_espresso_pressure_delta_1  -xdata espresso_elapsed -ydata espresso_pressure_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #40dc94 -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	$widget element create line_espresso_flow_goal_2x  -xdata espresso_elapsed -ydata espresso_flow_goal_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color $::chartflowgoallinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5}; 
	$widget element create line_espresso_flow_2x  -xdata espresso_elapsed -ydata espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::chartflowlinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes $::settings(chart_dashes_flow);   
	$widget element create god_line_espresso_flow_2x  -xdata espresso_elapsed -ydata god_espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodflowcol -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
#	$widget element create line_espresso_resistance  -xdata espresso_elapsed -ydata espresso_resistance -symbol none -label "" -linewidth [rescale_x_skin 4] -color #e5e500 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 

	$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartflowlinecol  -smooth $::settings(preview_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartpressuregoallinecol -smooth $::settings(preview_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 

	if {$::settings(display_flow_delta_line) == 1} {
		$widget element create line_espresso_flow_delta_1  -xdata espresso_elapsed -ydata espresso_flow_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #98c5ff -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	if {$::settings(chart_total_shot_flow) == 1} {
		$widget element create line_espresso_total_flow  -xdata espresso_elapsed -ydata espresso_water_dispensed -symbol none -label "" -linewidth [rescale_x_skin 6] -color #98c5ff -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);
		
	}


	if {$::settings(scale_bluetooth_address) != ""} {
		$widget element create line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color $::chartweightlinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
		$widget element create god_line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata god_espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodweightcol -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 

		if {$::settings(chart_total_shot_weight) == 1 || $::settings(chart_total_shot_weight) == 2} {
			$widget element create line_espresso_weight_2x  -xdata espresso_elapsed -ydata espresso_weight_chartable -symbol none -label "" -linewidth [rescale_x_skin 4] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);  
		}

		# when using Resistance calculated from the flowmeter, use a solid line to indicate it is well measured
		$widget element create line_espresso_resistance  -xdata espresso_elapsed -ydata espresso_resistance_weight -symbol none -label "" -linewidth [rescale_x_skin 4] -color $::chartresistancecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0  

	} else {
	
	# when using Resistance calculated from the flowmeter, use a dashed line to indicate it is approximately measured
	$widget element create line_espresso_resistance_dashed  -xdata espresso_elapsed -ydata espresso_resistance -symbol none -label "" -linewidth [rescale_x_skin 4] -color $::chartresistancecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {6 2}; 
	
	}

	$widget element create god_line2_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodpressurecol  -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color $::chartprofilestepcol -pixels 0 ; 

	$widget axis configure x -color #8b8b8b -tickfont Helv_7_bold; 
	$widget axis configure y -color #008c4c -tickfont Helv_7_bold -min 0 -max $::swdark_settings(sw_y_axisscale) -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14}  -hide 0;
	$widget axis configure y2 -color #206ad4 -tickfont Helv_7_bold -min 0 -max $::zoomed_y2_axis_scale -subdivisions 2 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7} -hide 0; 

	# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
		$widget grid configure -color $::chartgridcol
	}

	# show the explanation for pressure
	$widget element create line_espresso_de1_explanation_chart_pressurec -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 0] -color #ffffff  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part1c -xdata espresso_de1_explanation_chart_elapsed_1 -ydata espresso_de1_explanation_chart_pressure_1 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartpressurelinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part2c -xdata espresso_de1_explanation_chart_elapsed_2 -ydata espresso_de1_explanation_chart_pressure_2 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartweightlinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part3c -xdata espresso_de1_explanation_chart_elapsed_3 -ydata espresso_de1_explanation_chart_pressure_3 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::charttemplinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 

	# show the explanation for flow
	$widget element create line_espresso_de1_explanation_chart_flowc -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow_2x -symbol circle -label "" -linewidth [rescale_x_skin 0] -color #ffffff  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part1c -xdata espresso_de1_explanation_chart_elapsed_flow_1 -ydata espresso_de1_explanation_chart_flow_1_2x -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part2c -xdata espresso_de1_explanation_chart_elapsed_flow_2 -ydata espresso_de1_explanation_chart_flow_2_2x -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part3c -xdata espresso_de1_explanation_chart_elapsed_flow_3 -ydata espresso_de1_explanation_chart_flow_3_2x -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 


	#$widget axis configure y2 -color #206ad4 -tickfont Helv_6 -gridminor 0 -min 0.0 -max $::de1(max_flowrate) -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6} -hide 0; 
} -plotbackground $chartbackgroundcol -width [rescale_x_skin $charts_width] -height [rescale_y_skin 1450] -borderwidth 1 -background $chartbackgroundcol -plotrelief flat

#######################



#######################
# zoomed temperature
add_de1_widget "off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" graph 40 100 {
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page espresso_3 espresso_3; 
		set_next_page espresso_3_zoomed_temperature espresso_3; 
		set_next_page espresso espresso; 
		set_next_page espresso_zoomed_temperature espresso; 
		set_next_page off off; 
		set_next_page off_zoomed_temperature off; 
		page_show $::de1(current_context)
	} 
	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 6] -color $::charttempgoallinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color $::charttemplinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	$widget element create god_line_espresso_temperature_basket -xdata espresso_elapsed -ydata god_espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 6] -color $::chartgodtempcol -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_4 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color $::chartprofilestepcol -pixels 0 ; 
	$widget element create line_espresso_de1_explanation_chart_temp -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_temperature  -label "" -linewidth [rescale_x_skin 12] -color $::charttemplinecol  -smooth $::settings(preview_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6; 
	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -subdivisions 5;

	# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
		$widget grid configure -color $::chartgridcol
	}
	
	set ::temperature_chart_zoomed_widget $widget
} -plotbackground $chartbackgroundcol -width [rescale_x_skin $charts_width] -height [rescale_y_skin 1450] -borderwidth 1 -background $chartbackgroundcol -plotrelief flat

proc update_temperature_charts_y_axis args {
	#puts "update_temperature_charts_y_axis $::settings(espresso_temperature)"
	if {[ifexists ::settings(settings_profile_type)] == "settings_2c"} {	
		set mintmp 100
		set maxtmp 0

		foreach step $::settings(advanced_shot) {
			unset -nocomplain props
			array set props $step

			if {$props(temperature) > $maxtmp} {
				set maxtmp $props(temperature)
			}
			if {$props(temperature) < $mintmp} {
				set mintmp $props(temperature)
			}
		}

		#puts "scaling chart for advanced shot $mintmp<x<$maxtmp"

		# in advanced shots, we might have temperature profiling, so set the temperature chart differently.

		$::temperature_chart_widget axis configure y -min [expr {[return_temperature_number $mintmp] - [return_temp_offset $::settings(espresso_chart_under)]}] -max [expr {[return_temperature_number $maxtmp] + [return_temp_offset $::settings(espresso_chart_over)] }]; 
		$::temperature_chart_zoomed_widget axis configure y -min [expr {[return_temperature_number $mintmp] - [return_temp_offset $::settings(espresso_chart_under)]}] -max [expr {[return_temperature_number $maxtmp] + [return_temp_offset $::settings(espresso_chart_over)] }]; 
	} else {
		$::temperature_chart_widget axis configure y -min [expr {[return_temperature_number $::settings(espresso_temperature)] - [return_temp_offset $::settings(espresso_chart_under)]}] -max [expr {[return_temperature_number $::settings(espresso_temperature)] + [return_temp_offset $::settings(espresso_chart_over)] }]; 
		$::temperature_chart_zoomed_widget axis configure y -min [expr {[return_temperature_number $::settings(espresso_temperature)] - [return_temp_offset $::settings(espresso_chart_under)]}] -max [expr {[return_temperature_number $::settings(espresso_temperature)] + [return_temp_offset $::settings(espresso_chart_over)] }]; 
	}
	#puts [stacktrace]
}
update_temperature_charts_y_axis

#trace add variable ::settings(espresso_temperature) write update_temperature_charts_y_axis
#trace add variable ::current_adv_step write update_temperature_charts_y_axis




proc update_temperature_charts_y_axis args {
	#puts "update_temperature_charts_y_axis $::settings(espresso_temperature)"
	if {[ifexists ::settings(settings_profile_type)] == "settings_2c"} {	
		set mintmp 100
		set maxtmp 0

		foreach step $::settings(advanced_shot) {
			unset -nocomplain props
			array set props $step

			if {$props(temperature) > $maxtmp} {
				set maxtmp $props(temperature)
			}
			if {$props(temperature) < $mintmp} {
				set mintmp $props(temperature)
			}
		}

		#puts "scaling chart for advanced shot $mintmp<x<$maxtmp"

		# in advanced shots, we might have temperature profiling, so set the temperature chart differently.

		$::temperature_chart_widget2 axis configure y -min [expr {[return_temperature_number $mintmp] - [return_temp_offset $::settings(espresso_chart_under)]}] -max [expr {[return_temperature_number $maxtmp] + [return_temp_offset $::settings(espresso_chart_over)] }]; 
		$::temperature_chart_zoomed_widget axis configure y -min [expr {[return_temperature_number $mintmp] - [return_temp_offset $::settings(espresso_chart_under)]}] -max [expr {[return_temperature_number $maxtmp] + [return_temp_offset $::settings(espresso_chart_over)] }]; 
	} else {
		$::temperature_chart_widget2 axis configure y -min [expr {[return_temperature_number $::settings(espresso_temperature)] - [return_temp_offset $::settings(espresso_chart_under)]}] -max [expr {[return_temperature_number $::settings(espresso_temperature)] + [return_temp_offset $::settings(espresso_chart_over)] }]; 
		$::temperature_chart_zoomed_widget axis configure y -min [expr {[return_temperature_number $::settings(espresso_temperature)] - [return_temp_offset $::settings(espresso_chart_under)]}] -max [expr {[return_temperature_number $::settings(espresso_temperature)] + [return_temp_offset $::settings(espresso_chart_over)] }]; 
	}
	#puts [stacktrace]
}
update_temperature_charts_y_axis





#######################

# click anywhere on the chart to zoom pressure/flow.  This button is only to cover the parts that aren't overlaid by the charts, such as the text labels
add_de1_button "home swsettings off espresso espresso_3" {
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed; 
		set_next_page espresso espresso_zoomed; 
		set_next_page espresso_3 espresso_3_zoomed; 
		page_show $::de1(current_context);
		#set ::settings(zoomed_y_axis_scale) "12";
		#set ::zoomed_y2_axis_scale "6";
} 30 72 1700 900

# click anywhere on the chart to zoom temperature.  This button is only to cover the parts that aren't overlaid by the charts, such as the text labels
add_de1_button "home swsettings off espresso espresso_3" {
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed_temperature;
		set_next_page espresso espresso_zoomed_temperature;
		set_next_page espresso_3 espresso_3_zoomed_temperature;
		page_show $::de1(current_context);
} 30 20 1771 1580

add_de1_button "off_zoomed espresso_zoomed espresso_3_zoomed" {
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page espresso_3 espresso_3; 
		set_next_page espresso_3_zoomed espresso_3; 
		set_next_page espresso espresso; 
		set_next_page espresso_zoomed espresso; 
		set_next_page off off; 
		set_next_page off_zoomed off; 
		page_show $::de1(current_context);
} 30 20 1771 1580

add_de1_button "off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" {
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page espresso_3 espresso_3; 
		set_next_page espresso_3_zoomed_temperature espresso_3; 
		set_next_page espresso espresso; 
		set_next_page espresso_zoomed_temperature espresso; 
		set_next_page off off; 
		set_next_page off_zoomed_temperature off; 
		page_show $::de1(current_context);
} 30 20 1771 1580

#############################

#Steam Charts

#proc steamtemp {} {
#    if {$::de1_num_state($::de1(state)) == "Steam"} {
#			if {$::de1(substate) == $::de1_substate_types_reversed(pouring) || $::de1(substate) == $::de1_substate_types_reversed(preinfusion)} {
#				steam_temperature [expr {$::de1(steam_heater_temperature)/100.0}]
#			}
#		return
#	} elseif {
#	}
#}
#add_de1_variable "off steam steam_zoomed" 0 2000 -font Helv_6 -fill #000 -textvariable {[steamtemp]}

add_de1_widget "off espresso_3" graph 50 1270 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_steam_zoom; 
		set_next_page steam steam_zoom; 
		page_show $::de1(current_context);
	}
	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color #86C240  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 6] -color #43B1E3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow); 
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 6] -color #e73249 -pixels 0 -dashes $::settings(chart_dashes_temperature); 	
	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label "" -linewidth [rescale_x_skin 6] -color #FF2600 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	#$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {1 2 3}
	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -min 0 -max 4 -subdivisions 5 -majorticks {1 2 3 4}	

	catch {
		$widget grid configure -color $::chartgridcol
	}

} -plotbackground #242424 -width [rescale_x_skin $charts_width] -height [rescale_y_skin 300] -borderwidth 1 -background #242424 -plotrelief flat

add_de1_widget "steam_3" graph 50 1250 { 
	bind $widget [platform_button_press] { 
		say [translate {stop}] $::settings(sound_button_in); 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam_zoom_3; 
		set_next_page steam_3 steam_zoom_3; 
		page_show $::de1(current_context);
	}
	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color #86C240  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 6] -color #43B1E3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata [expr steam_temperature / 100] -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -pixels 0 -dashes $::settings(chart_dashes_temperature); 
	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label "" -linewidth [rescale_x_skin 6] -color #FF2600 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);   

	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
#	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {1 2 3 4} 
	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -min 0 -max 4 -subdivisions 5 -majorticks {1 2 3 4} 
		# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
		$widget grid configure -color $::chartgridcol
	}
} -plotbackground $chartbackgroundcol -width [rescale_x_skin $charts_width] -height [rescale_y_skin 300] -borderwidth 1 -background $chartbackgroundcol -plotrelief flat 


add_de1_widget "steam_zoom_3 off_steam_zoom steam" graph 40 100 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam_3; 
		#set_next_page steam_zoom_3 steam_3; 
		set_next_page off_steam_zoom off; 
		set_next_page steam_zoom_3 off;
		page_show $::de1(current_context);
	}
	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::chartpressurelinecol  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::chartflowlinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata [expr steam_temperature / 100] -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -pixels 0 -dashes $::settings(chart_dashes_temperature); 
	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color $::charttemplinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -min 0.0 -max 4 -subdivisions 5 -majorticks {0.5 1 1.5 2 2.5 3 3.5 4}  -title "[translate "Flow rate"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #ffffff;
		# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
		$widget grid configure -color $::chartgridcol
	}
} -plotbackground $chartbackgroundcol -width [rescale_x_skin $charts_width] -height [rescale_y_skin 1450] -borderwidth 1 -background $chartbackgroundcol -plotrelief flat 

add_de1_widget "steam_zoom" graph 40 100 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam; 
		#set_next_page steam_zoom_3 steam_3; 
		#set_next_page steam off; 
		set_next_page steam_zoom steam; 
		page_show $::de1(current_context);
	}
	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::chartpressurelinecol  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::chartflowlinecol  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata [expr steam_temperature / 100] -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -pixels 0 -dashes $::settings(chart_dashes_temperature); 
	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color $::charttemplinecol -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -min 0.0 -max 4 -subdivisions 5 -majorticks {0.5 1 1.5 2 2.5 3 3.5 4}  -title "[translate "Flow rate"] - [translate "Temperature"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #ffffff;
		# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
		$widget grid configure -color $::chartgridcol
	}
} -plotbackground $chartbackgroundcol -width [rescale_x_skin $charts_width] -height [rescale_y_skin 1450] -borderwidth 1 -background $chartbackgroundcol -plotrelief flat 




##########################################################################################################################################################################################################################################################################
# data card

set pos_top_orig 841
set pos_top 725
set spacer 38
#set paragraph 20

set column2 1950
if {$::settings(enable_fahrenheit) == 1} {
	set column2 1950
}

set dark "#8b8b8b"
set lighter "#9f9f9f"
set lightest "#d5d5d5"
set column1_pos 1820
set column3_pos 2220


if {$::settings(waterlevel_indicator_on) == 1} {
	# water level sensor on espresso page

	add_de1_widget "off espresso espresso_3 off_zoomed espresso_zoomed espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" scale 2544 190 {after 1000 water_level_color_check $widget} -from $::settings(water_level_sensor_max) -to 5 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1410] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor $chartbackgroundcol -borderwidth 0  -highlightthickness 0

	# water level sensor on other tabs page (white background)
	add_de1_widget "preheat_2 preheat_3 preheat_4 steam steam_3 steam_zoom steam_zoom_3 water water_3 water_4" scale 2544 226 {after 1000 water_level_color_check $widget} -from $::settings(water_level_sensor_max) -to 5 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1166] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor $chartbackgroundcol -borderwidth 0  -highlightthickness 0

	# water level sensor on other tabs page (light blue background)
	add_de1_widget "preheat_1 steam_1 water_1" scale 2544 226 {after 1000 water_level_color_check $widget} -from $::settings(water_level_sensor_max) -to 5 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1166] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor $chartbackgroundcol -borderwidth 0  -highlightthickness 0
}


add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "nw" -text [translate "Espresso"] -font Helv_7_bold -fill $::detailtextheadingcol -width [rescale_x_skin 520]
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[espresso_preinfusion_timer][translate "s"] [translate "preinfusion"]} 
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[espresso_pour_timer][translate "s"] [translate "pouring"]} 
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (3 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[espresso_elapsed_timer][translate "s"] [translate "total"]} 
	#add_de1_variable "espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (4 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[if {[espresso_done_timer] < $::settings(seconds_to_display_done_espresso)} {return "[espresso_done_timer][translate s] [translate done]"} else { return ""}]} 
	
	
add_de1_text "espresso espresso_zoomed" $column1_pos [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "nw" -text [translate "Time"] -font Helv_7_bold -fill $::detailtextheadingcol -width [rescale_x_skin 520]
	add_de1_variable "espresso espresso_zoomed" $column1_pos [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[espresso_preinfusion_timer][translate "s"] [translate "preinfusion"]} 
	add_de1_variable "espresso espresso_zoomed" $column1_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[espresso_pour_timer][translate "s"] [translate "pouring"]} 
	add_de1_variable "espresso espresso_zoomed" $column1_pos [expr {$pos_top + (3 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[espresso_elapsed_timer][translate "s"] [translate "total"]} 



#######################
# data card temperature
	add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
	add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (5 * $spacer)}] -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
	add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column2 [expr {$pos_top + (6 * $spacer)}] -justify left -anchor "nw" -text [translate "goal"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	#add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column2 [expr {$pos_top + (5.5 * $spacer)}] -justify left -anchor "nw" -text [translate "goal"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (6 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[espresso_goal_temp_text]} 
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[update_swcoffeetemp][translate " goal"]} 

	#add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column2 [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "nw" -text [translate "group"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature"  $column3_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[group_head_heater_temperature_text][translate " group"]} 

#	if {$::settings(display_group_head_delta_number) == 1} {
#		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" 2380 [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "ne" -font Helv_7 -fill $lightest -width [rescale_x_skin 520] -textvariable {[return_delta_temperature_measurement [diff_group_temp_from_goal]]} 
#	}

	add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column2 [expr {$pos_top + (7 * $spacer)}] -justify right -anchor "nw" -text [translate "coffee"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (7 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[watertemp_text]} 
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top + (7 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7 -fill $lightest -width [rescale_x_skin 520] -textvariable {[return_delta_temperature_measurement [diff_espresso_temp_from_goal]]} 

	add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column2 [expr {$pos_top + (8 * $spacer)}] -justify right -anchor "nw" -text [translate "water"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (8 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[mixtemp_text]} 
	
	if {$::settings(display_espresso_water_delta_number) == 1} {
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top + (8 * $spacer)}] -justify left -anchor "ne" -font Helv_7 -fill $lightest -width [rescale_x_skin 520] -textvariable {[return_delta_temperature_measurement [diff_brew_temp_from_goal] ]} 
		# thermometer widget from http://core.tcl.tk/bwidget/doc/bwidget/BWman/index.html
	    add_de1_widget "espresso espresso_zoomed espresso_zoomed_temperature" ProgressBar 2390 [expr {$pos_top + (8.5 * $spacer)}] {} -width [rescale_y_skin 108] -height [rescale_x_skin 16] -type normal  -variable ::positive_diff_brew_temp_from_goal -fg #ff8888 -bg #FFFFFF -maximum 10 -borderwidth 1 -relief flat
	}
##########################
# data card volume when doing nothing
	if {$::settings(scale_bluetooth_address) != ""} {
		add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (4 * $spacer)}] -justify left -anchor "nw" -text [translate "Volume"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $lighter -width [rescale_x_skin 520] -textvariable {[preinfusion_volume][translate " preinfusion"]} 
		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (6 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $lighter -width [rescale_x_skin 520] -textvariable {[pour_volume][translate " pouring"]}
		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (7 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[watervolume_text][translate " total"]} 
	} else {
	add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (4.5 * $spacer)}] -justify left -anchor "nw" -text [translate "Volume"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (5.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $lighter -width [rescale_x_skin 520] -textvariable {[preinfusion_volume][translate " preinfusion"]} 
		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (6.6 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $lighter -width [rescale_x_skin 520] -textvariable {[pour_volume][translate " pouring"]}
		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (7.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[watervolume_text][translate " total"]} 
	}

#Volume when running a shot

	add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "nw" -text [translate "Volume"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $lighter -width [rescale_x_skin 520] -textvariable {[preinfusion_volume][translate " preinfusion"]} 
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $lighter -width [rescale_x_skin 520] -textvariable {[pour_volume][translate " pouring"]}
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top + (3 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[watervolume_text][translate " total"]} 

#######################
# data card flow 
add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (10.5 * $spacer)}] -justify right -anchor "nw" -text [translate "Flow"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (11.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (12.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[pressure_text]} 
#######################




#######################
# data card preheat
add_de1_text "off" $column3_pos [expr {$pos_top + (8.75 * $spacer)}] -justify left -anchor "nw" -text [translate "Flush"] -font Helv_7_bold -fill "#ffffff" -width [rescale_x_skin 520]
add_de1_text "preheat_2 hotwaterrinse" $column1_pos [expr {$pos_top + (0 * $spacer)}] -justify left -anchor "nw" -text [translate "Flush"] -font Helv_7_bold -fill "#ffffff" -width [rescale_x_skin 520]
#add_de1_variable "off preheat_2" $column3_pos [expr {$pos_top + (10 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -text "" -textvariable {[watertemp_text]}
#add_de1_variable "off preheat_2" $column3_pos [expr {$pos_top + (10 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -text "" -textvariable {[flush_pour_timer]}

#add_de1_text "off" $column3_pos [expr {$pos_top + (10 * $spacer)}] -justify left -anchor "nw" -text [translate "Pouring"] -font Helv_7_bold -fill "#ffffff" -width [rescale_x_skin 520]
#add_de1_variable "off" $column3_pos [expr {$pos_top + (11 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -text "" -textvariable {[flush_pour_timer][translate "s"]} 

#add_de1_text "preheat_2 preheat_4" $column1_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -text [translate "Pouring"] -font Helv_7_bold -fill "#ffffff" -width [rescale_x_skin 520]
add_de1_variable "preheat_2 preheat_4 hotwaterrinse" $column1_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -text "" -textvariable {[translate "Pouring "][flush_pour_timer][translate "s"]} 
add_de1_variable "preheat_2 preheat_4 hotwaterrinse" $column1_pos [expr {$pos_top + (3 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -text "" -textvariable {[translate "Water Temp "][watertemp_text]}

#if {$preheat_water_volume_feature_enabled == 1} {
#	add_de1_variable "off preheat_1" $column3_pos [expr {$pos_top + (12 * $spacer)}] -text "" -font Helv_7 -fill $lighter -anchor "center" -textvariable {[return_liquid_measurement $::settings(preheat_volume)]}
	add_de1_variable "off" $column3_pos [expr {$pos_top + (9.75 * $spacer)}] -justify left -text "" -font Helv_7 -fill $lighter -anchor "nw" -textvariable {[round_to_integer $::settings(preheat_volume)][translate "s"]}
	add_de1_variable "preheat_2 hotwaterrinse" $column1_pos [expr {$pos_top + (1 * $spacer)}] -justify left -text "" -font Helv_7 -fill $lighter -anchor "nw" -textvariable {[translate "Target Time "][round_to_integer $::settings(preheat_volume)][translate "s"]}
#}

#######################
# data card weight
	#add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" 2075 [expr {$pos_top + (8 * $spacer)}] -justify right -anchor "ne" -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520] -textvariable {[waterweight_label_text]}
	
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top + (10.5 * $spacer)}] -justify right -anchor "ne" -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520] -textvariable {[waterweight_label_text]}
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top + (11.5 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[waterweight_text]} 
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top + (12.5 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[waterweightflow_text]} 


	if {$::settings(scale_bluetooth_address) != ""} {
		set ::de1(scale_weight_rate) -1	
		
		add_de1_widget "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" ProgressBar 2117 1360 {} -width [rescale_y_skin 95] -height [rescale_x_skin 16] -type normal  -variable ::de1(scale_weight_rate) -fg #FF6A00 -bg #4e4e4e -maximum 6 -borderwidth 1 -relief flat
		
		add_de1_widget "espresso espresso_zoomed espresso_zoomed_temperature" ProgressBar 2390 [expr {$pos_top + (13 * $spacer)}] {} -width [rescale_y_skin 108] -height [rescale_x_skin 16] -type normal  -variable ::de1(scale_weight_rate) -fg #FF6A00 -bg #4e4e4e -maximum 6 -borderwidth 1 -relief flat
		
		add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (8.25 * $spacer)}] -justify left -anchor "nw" -text [translate "Recipe"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
		
		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (9.25 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[round_to_one_digits $::swdark_settings(swcoffeedose)][translate "g @ 1:"][round_to_one_digits $::swdark_settings(swbrewratio)][translate " to "][round_to_integer [update_swcoffeeweight]][translate "g"]}
		
		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (10.25 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[drink_weight_text]} 
		
		add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (14.5 * $spacer)}] -justify left -anchor "nw" -text [translate "Recipe"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
		
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (15.5 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[round_to_one_digits $::swdark_settings(swcoffeedose)][translate "g @ 1:"][round_to_one_digits $::swdark_settings(swbrewratio)][translate " to "][round_to_integer [update_swcoffeeweight]][translate "g"]}
		
	} else {
		
		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (8.5 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[translate "Stop @ "][round_to_integer [update_swcoffeevolume]][translate "mL"]}	
		
		#add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (14.5 * $spacer)}] -justify left -anchor "nw" -text [translate "Recipe"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
		
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (14.5 * $spacer)}] -justify left -anchor "nw" -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520] -textvariable {[translate "Stop @ "][round_to_integer [update_swcoffeevolume]][translate "mL"]}	
	}


#######################

#######################
# data card profile name 
if {$::settings(insight_skin_show_embedded_profile) == 1} {
	# not yet complete implementation of idea of showing the espresso shot profile on the Insight skin's ESPRESSO tab
	# what is not yet finished is that this is only showing the pressure profile, and instead this needs to show
	# a flow profile if that's selected, or nothing is displayed if this is an advanced profile
	add_de1_widget "off espresso_3" graph 2030 1080 { 
		update_de1_explanation_chart;
		$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 2] -color #888888  -smooth $::settings(live_graph_smoothing_technique) -pixels [rescale_x_skin 10]; 
		$widget axis configure x -color #8b8b8b -tickfont Helv_6 
		#-command graph_seconds_axis_format; 
		$widget axis configure y -color #8b8b8b -tickfont Helv_6 -min 0.0 -max [expr {0.1 + $::de1(maxpressure)}] -stepsize 4 -majorticks {4 8} -title "" -titlefont Helv_10 -titlecolor #8b8b8b;

		$widget element create line_espresso_de1_explanation_chart_pressure_part1 -xdata espresso_de1_explanation_chart_elapsed_1 -ydata espresso_de1_explanation_chart_pressure_1 -symbol circle -label "" -linewidth [rescale_x_skin 16] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 10]; 
		$widget element create line_espresso_de1_explanation_chart_pressure_part2 -xdata espresso_de1_explanation_chart_elapsed_2 -ydata espresso_de1_explanation_chart_pressure_2 -symbol circle -label "" -linewidth [rescale_x_skin 16] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 10]; 
		$widget element create line_espresso_de1_explanation_chart_pressure_part3 -xdata espresso_de1_explanation_chart_elapsed_3 -ydata espresso_de1_explanation_chart_pressure_3 -symbol circle -label "" -linewidth [rescale_x_skin 16] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 10]; 

		bind $widget [platform_button_press] { 
			show_settings $::settings(settings_profile_type)
		} 
	} -plotbackground $chartbackgroundcol -width [rescale_x_skin 430] -height [rescale_y_skin 200] -borderwidth 1 -background $chartbackgroundcol -plotrelief raised
} else {
	# we can display the profile name if the embedded chart is not displayed.
	add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (11.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520] -textvariable {[profile_type_text]} 
	add_de1_variable "espresso espresso_zoomed" $column1_pos [expr {$pos_top + (17.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7_bold -fill #ffffff -width 730 -textvariable {[profile_type_text]} 
	
	set ::globals(widget_current_profile_name) [add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (12.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill #ffffff -width [rescale_x_skin 650] -textvariable {$::settings(profile_title)} ]
	

	set ::globals(widget_current_profile_name_espresso) [add_de1_variable "espresso espresso_zoomed" $column1_pos [expr {$pos_top + (18.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill #ffffff -width 730 -textvariable {$::settings(profile_title)} ]

	add_de1_variable "espresso espresso_zoomed" $column1_pos [expr {$pos_top + (19.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill "#8297be" -width 730 -textvariable {$::settings(current_frame_description)} 

}


#Select Profile Button
#add_de1_button "home off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" {say [translate {}] $::settings(sound_button_in); show_settings; set_next_page off settings_1; page_show off;  set ::settings(active_settings_tab) settings_1 ; start_idle} 1789 1155 2380 1270

add_de1_button "home off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" {say [translate {describe}] $::settings(sound_button_in); if {$::settings(profile_has_changed) == 1} { save_profile } else { backup_settings; set_next_page off settings_1; page_show off; set_profiles_scrollbar_dimensions }
} 1789 1155 2380 1270

#######################


#Water info on Data card

add_de1_text "water water_3" $column1_pos [expr {$pos_top + (0 * $spacer)}] -justify left -anchor "nw" -text [translate "Water"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]

add_de1_variable "water water_3" $column1_pos [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -text "" -textvariable {[translate "Pouring "][water_pour_timer][translate "s"]} 

add_de1_variable "water" $column1_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[translate "Flow "][waterflow_text]} 

#water in data tab

	add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "nw" -text [translate "Water"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
	
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (7.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {$::swdark_settings(swwatervol)[translate "mL"][translate " @ "][return_temperature_measurement [round_to_integer $::settings(water_temperature)]]}

	#add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {$::swdark_settings(swwatertemp)[translate "\u00BAC"]}


#Steam in Data Tab

	add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (3.25 * $spacer)}] -justify left -anchor "nw" -text [translate "Steam"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]

	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (4.25 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"][translate " "][translate "auto-off"]}

	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (5.25 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[steam_pour_timer][translate "s"][translate " "][translate "duration"]} 




#swsettings button over data card
add_de1_button "home off espresso_1 espresso_2 espresso_3 preheat_1  preheat_3 preheat_4 steam_1 steam_2 steam_3 water_1 water_2 water_3 off_zoomed off_steam_zoom off_zoomed_temperature" { say [translate {swsettings}] $::settings(sound_button_in); set_next_page off swsettings; start_idle} 1798 697 2538 1141


#God Shot
# this feature is always on now
set ::settings(display_rate_espresso) 1
if {$::settings(display_rate_espresso) == 1} {
	add_de1_image "off off_zoomed off_zoomed_temperature" 2420 1170 "[skin_directory]/img/hearticon.png"
	add_de1_button "off off_zoomed off_zoomed_temperature" {say [translate {describe}] $::settings(sound_button_in); unset -nocomplain ::settings_backup; array set ::settings_backup [array get ::settings]; set_next_page off describe_espresso0; page_show off; set_god_shot_scrollbar_dimensions; } 2410 1160 2510 1260
	source "[homedir]/skins/Insight/scentone.tcl"
}

##############################
#End of data card
##############################





##########################################################################################################################################################################################################################################################################
# settings for steam


	add_de1_variable "steam_1" 959.74 829 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}
	add_de1_variable "steam steam_3" 959.74 829 -text "" -font Helv_10_bold -fill "#9f9f9f" -anchor "center"  -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}

	add_de1_text "steam" $column1_pos [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "nw" -text [translate "Steaming"] -font Helv_7_bold -fill $::detailtextheadingcol -width [rescale_x_skin 520]
	add_de1_variable "steam" $column1_pos [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[translate "Duration "][steam_pour_timer][translate "s"]} 
	add_de1_text "steam_3" 1950 841 -justify right -anchor "nw" -text [translate "Steaming"] -font Helv_7_bold -fill $::detailtextheadingcol -width [rescale_x_skin 520]
	add_de1_variable "steam_3" 2481 841 -justify left -anchor "ne" -font Helv_7 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[steam_pour_timer][translate "s"]} 

	add_de1_variable "steam_3" 1950 881 -justify right -anchor "nw" -text [translate "Done"] -font Helv_7_bold -fill $::detailtextheadingcol -width [rescale_x_skin 520] -textvariable {[if {[steam_done_timer] < $::settings(seconds_to_display_done_steam)} {return [translate Done]} else { return ""}]} 
	add_de1_variable "steam_3" 2480 881 -justify left -anchor "ne" -font Helv_7 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[if {[steam_done_timer] < $::settings(seconds_to_display_done_steam)} {return "[steam_done_timer][translate s]"} else { return ""}]} 
	#add_de1_text "steam" 1950 881 -justify right -anchor "nw" -text [translate "Auto-Off"] -font Helv_7_bold -fill $::detailtextheadingcol -width [rescale_x_skin 520]
	add_de1_variable "steam" $column1_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[translate "Auto-Off "][round_to_integer $::settings(steam_timeout)][translate "s"]}

	#add_de1_text "steam" 1950 961 -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_7_bold -fill $::detailtextheadingcol -width [rescale_x_skin 520]
		add_de1_variable "steam" $column1_pos [expr {$pos_top + (4 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[translate "Temperature "][steamtemp_text]} 
	#add_de1_text "steam" 1950 1001 -justify right -anchor "nw" -text [translate "Pressure (bar)"] -font Helv_7_bold -fill $::detailtextheadingcol -width [rescale_x_skin 520]
		add_de1_variable "steam" $column1_pos [expr {$pos_top + (5 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[translate "Pressure "][pressure_text]} 
	#add_de1_text "steam" 1950 1041 -justify right -anchor "nw" -text [translate "Flow rate"] -font Helv_7_bold -fill $::detailtextheadingcol -width [rescale_x_skin 520]
		add_de1_variable "steam" $column1_pos [expr {$pos_top + (6 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[translate "Flow "][waterflow_text]} 

profile_has_changed_set_colors

#add_de1_text "home swsettings off espresso espresso_1 espresso_2 espresso_3 preheat preheat_1 preheat_2 preheat_3 preheat_4 steam steam_1 steam_2 steam_3 water water_1 water_2 water_3" 0 0 -text $::current_espresso_page -font helveticabold18 -fill "#ffffff" -anchor "nw"



###############################
#SWDark Settings Page

#swsettings button
add_de1_button "swsettings" {say [translate {home}] $::settings(sound_button_in); set_next_page off off; start_idle} 1787 697 2537 1407

#Labels
add_de1_text "swsettings" 458.5	121.5 -text [translate "Water Volume"] -font helveticabold20 -fill "#ffffff" -anchor "center"
add_de1_text "swsettings" 458.5	486.5 -text [translate "Water Temperature"] -font helveticabold20 -fill "#ffffff" -anchor "center"
add_de1_text "swsettings" 458.5	851.5 -text [translate "Steam Auto-Off"] -font helveticabold20 -fill "#ffffff" -anchor "center"
add_de1_text "swsettings" 458.5	1216.5 -text [translate "Flush Timer"] -font helveticabold20 -fill "#ffffff" -anchor "center"

if {$::settings(scale_bluetooth_address) != ""} {
	add_de1_text "swsettings" 1333.5 121.5 -text [translate "Coffee Dose"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	add_de1_text "swsettings" 1333.5 486.5 -text [translate "Coffee Output"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	add_de1_text "swsettings" 1333.5 851.5 -text [translate "Brew Ratio"] -font helveticabold20 -fill "#ffffff" -anchor "center"

	add_de1_text "swsettings" 1156.5 1271.5 -text [translate "1:3"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	add_de1_text "swsettings" 1156.5 1444.5 -text [translate "1:2"] -font helveticabold20 -fill "#ffffff" -anchor "center"

	add_de1_text "swsettings" 1510.5 1271.5 -text [translate "1:2.5"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	add_de1_text "swsettings" 1510.5 1444.5 -text [translate "1:1"] -font helveticabold20 -fill "#ffffff" -anchor "center"
} else {
	add_de1_text "swsettings" 1333.5 121.5 -text [translate "Stop @ Volume"] -font helveticabold20 -fill "#ffffff" -anchor "center"
}
#water settings
#clicker
add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 10 10 ::settings(water_volume) 10 250 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings; set ::swdark_settings(swwatervol) [round_to_integer $::settings(water_volume)]; save_swdark_settings} 115 165 802 360 ""
add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 ::settings(water_volume) 10 250 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings; set ::swdark_settings(swwatervol) [round_to_integer $::settings(water_volume)]; save_swdark_settings} 235 165 682 360 ""

add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 10 10 ::settings(water_temperature) 60 100 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings; set ::swdark_settings(swwatertemp) $::settings(water_temperature); save_swdark_settings} 115 530 802 725 ""
add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 ::settings(water_temperature) 60 100 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings; set ::swdark_settings(swwatertemp) $::settings(water_temperature); save_swdark_settings} 235 530 682 725 ""

add_de1_variable "swsettings" 458.75 262 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[return_liquid_measurement $::settings(water_volume)]}
add_de1_variable "swsettings" 458.75 627 -text "" -font Helv_10_bold -fill "#000000" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}

#Steam Settings
add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 10 10 ::settings(steam_timeout) 1 250 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings; set ::swdark_settings(swsteamoff) [round_to_integer $::settings(steam_timeout)]; save_swdark_settings} 115 895 802 1090 ""
add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 ::settings(steam_timeout) 1 250 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings; set ::swdark_settings(swsteamoff) [round_to_integer $::settings(steam_timeout)]; save_swdark_settings} 235 895 682 1090 ""
add_de1_variable "swsettings" 458.75 992 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}

#Flush Settings
add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 10 10 ::settings(preheat_volume) 1 100 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings; set ::swdark_settings(swflushvol) [round_to_integer $::settings(preheat_volume)]; save_swdark_settings} 115 1260 802 1455 ""
add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 ::settings(preheat_volume) 1 100 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings; set ::swdark_settings(swflushvol) [round_to_integer $::settings(preheat_volume)]; save_swdark_settings} 235 1260 682 1455 ""

add_de1_variable "swsettings" 458.75 1357 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[round_to_integer $::settings(preheat_volume)][translate "s"]}


#Coffee Dose Settings
if {$::settings(scale_bluetooth_address) != ""} {
	add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 ::swdark_settings(swcoffeedose) 1 30 %x %y %x0 %y0 %x1 %y1; updateswbrewratio; save_swdark_settings} 990 165 1677 360 ""
	
	add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 0.1 0.1 ::swdark_settings(swcoffeedose) 1 30 %x %y %x0 %y0 %x1 %y1; updateswbrewratio; save_swdark_settings} 1110 165 1557 360 ""

	add_de1_variable "swsettings" 1333.75 262 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[round_to_one_digits $::swdark_settings(swcoffeedose)][translate "g"]} 
} else {
	add_de1_variable "swsettings" 1333.75 262 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[round_to_integer [update_swcoffeevolume]][translate "mL"]}
	add_de1_variable "swsettings" 3000 3000 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[swvoltype2]}
	add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 10 10 $::swdark_settings(swvoltype) 1 2000 %x %y %x0 %y0 %x1 %y1; updateswbrewvol; save_swdark_settings} 990 165 1677 360 ""
	add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 $::swdark_settings(swvoltype) 1 2000 %x %y %x0 %y0 %x1 %y1; updateswbrewvol; save_swdark_settings} 1110 165 1557 360 "" 
}

# Settings Target Output (Stop at weight)

	add_de1_variable "off" 3000 3000 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[swautoupdateratio]}
if {$::settings(scale_bluetooth_address) != ""} {
	add_de1_variable "swsettings" 1333.75 627 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[swreturnweight][translate "g"]}
}
	add_de1_variable "swsettings" 3000 3000 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[swweighttype2][translate "g"]}
if {$::settings(scale_bluetooth_address) != ""} {
	add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 10 10 $::swdark_settings(swweighttype) 1 2000	%x %y %x0 %y0 %x1 %y1;updateswbrewratio2; save_swdark_settings} 990 530 1677 725 ""
	add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 $::swdark_settings(swweighttype) 1 2000 %x %y %x0 %y0 %x1 %y1;updateswbrewratio2; save_swdark_settings} 1110 530 1557 725 ""
   }

#Brew Ratio Settings
if {$::settings(scale_bluetooth_address) != ""} {
	add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 ::swdark_settings(swbrewratio) 1 100 %x %y %x0 %y0 %x1 %y1;updateswbrewratio; save_swdark_settings} 990 895 1677 1090 ""
	add_de1_button "swsettings" {say "" $::settings(sound_button_in);horizontal_clicker 0.1 0.1 ::swdark_settings(swbrewratio) 1 100 %x %y %x0 %y0 %x1 %y1;updateswbrewratio; save_swdark_settings} 1110 895 1557 1090 ""
	add_de1_variable "swsettings" 1333.75 992 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[translate "1:"][round_to_one_digits $::swdark_settings(swbrewratio)]}
   }

#Ratio Buttons
if {$::settings(scale_bluetooth_address) != ""} {
#1:1
	add_de1_button "swsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swbrewratio) "1" ; updateswbrewratio } 1344 1368 1677 1521
#1:2
	add_de1_button "swsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swbrewratio) "2"  ; updateswbrewratio } 990 1368 1323 1521
#1:2.5
	add_de1_button "swsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swbrewratio) "2.5"  ; updateswbrewratio } 1344 1195 1677 1348
#1:3
	add_de1_button "swsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swbrewratio) "3"  ; updateswbrewratio } 990 1195 1323 1348
   }






###############################
#SWDark Brew Settings Page

#swhome button
add_de1_button "swbrewsettings" {say [translate {home}] $::settings(sound_button_in); set_next_page off off; start_idle} 1787 697 2537 1407

#labels
if {$::settings(scale_bluetooth_address) != ""} {
	add_de1_text "swbrewsettings" 457.5 417.5 -text [translate "Dose"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	add_de1_text "swbrewsettings" 896.5 77 -text [translate "Target"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	add_de1_text "swbrewsettings" 1332.5 417.5 -text [translate "Ratio"] -font helveticabold20 -fill "#ffffff" -anchor "center"

	#brew ratio labels
	add_de1_text "swbrewsettings" 1155.5 882 -text [translate "1:1.5"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	add_de1_text "swbrewsettings" 1509.5 882 -text [translate "1:2"] -font helveticabold20 -fill "#ffffff" -anchor "center"

	add_de1_text "swbrewsettings" 1155.5 1133 -text [translate "1:2.5"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	add_de1_text "swbrewsettings" 1509.5 1133 -text [translate "1:3"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	
	add_de1_text "swbrewsettings" 1155.5 1384 -text [translate "1:4"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	add_de1_text "swbrewsettings" 1509.5 1384 -text [translate "1:5"] -font helveticabold20 -fill "#ffffff" -anchor "center"

	#dose button labels
	add_de1_text "swbrewsettings" 280.5 882 -text [translate "15g"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	add_de1_text "swbrewsettings" 634.5 882 -text [translate "16g"] -font helveticabold20 -fill "#ffffff" -anchor "center"

	add_de1_text "swbrewsettings" 280.5 1133 -text [translate "17g"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	add_de1_text "swbrewsettings" 634.5 1133 -text [translate "18g"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	
	add_de1_text "swbrewsettings" 280.5 1384 -text [translate "19g"] -font helveticabold20 -fill "#ffffff" -anchor "center"
	add_de1_text "swbrewsettings" 634.5 1384 -text [translate "20g"] -font helveticabold20 -fill "#ffffff" -anchor "center"


#Coffee Dose
	add_de1_button "swbrewsettings" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 ::swdark_settings(swcoffeedose) 1 30 %x %y %x0 %y0 %x1 %y1; updateswbrewratio; save_swdark_settings} 110 465 805 664 ""
	add_de1_button "swbrewsettings" {say "" $::settings(sound_button_in);horizontal_clicker 0.1 0.1 ::swdark_settings(swcoffeedose) 1 30 %x %y %x0 %y0 %x1 %y1; updateswbrewratio; save_swdark_settings} 235 465 680 664 ""
	add_de1_variable "swbrewsettings" 457.735 563 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[round_to_one_digits $::swdark_settings(swcoffeedose)][translate "g"]} 

#Coffee Dose Buttons

	#15
		add_de1_button "swbrewsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swcoffeedose) "15" ; updateswbrewratio } 114 767 447 997
	#16
		add_de1_button "swbrewsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swcoffeedose) "16"  ; updateswbrewratio } 468 767 801 997
	#17
		add_de1_button "swbrewsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swcoffeedose) "17"  ; updateswbrewratio } 114 1018 447 1248
	#18
		add_de1_button "swbrewsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swcoffeedose) "18"  ; updateswbrewratio } 468 1018 801 1248
	#19
		add_de1_button "swbrewsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swcoffeedose) "19"  ; updateswbrewratio } 114 1269 447 1499
	#20
		add_de1_button "swbrewsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swcoffeedose) "20"  ; updateswbrewratio } 468 1269 801 1499

#Coffee Output
	add_de1_variable "swbrewsettings" 896.735 224 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[swreturnweight][translate "g"]}
	add_de1_variable "swbrewsettings" 3000 3000 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[swweighttype2][translate "g"]}
	add_de1_button "swbrewsettings" {say "" $::settings(sound_button_in);horizontal_clicker 10 10 $::swdark_settings(swweighttype) 1 2000	%x %y %x0 %y0 %x1 %y1;updateswbrewratio2; save_swdark_settings} 549 125 1244 324 ""
	add_de1_button "swbrewsettings" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 $::swdark_settings(swweighttype) 1 2000 %x %y %x0 %y0 %x1 %y1;updateswbrewratio2; save_swdark_settings} 674 125 1119 324 ""
	
#Brew Ratio

	add_de1_button "swbrewsettings" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 ::swdark_settings(swbrewratio) 1 100 %x %y %x0 %y0 %x1 %y1;updateswbrewratio; save_swdark_settings} 985 465 1680 664 ""
	add_de1_button "swbrewsettings" {say "" $::settings(sound_button_in);horizontal_clicker 0.1 0.1 ::swdark_settings(swbrewratio) 1 100 %x %y %x0 %y0 %x1 %y1;updateswbrewratio; save_swdark_settings} 1110 465 1555 664 ""
	add_de1_variable "swbrewsettings" 1332.735 563 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[translate "1:"][round_to_one_digits $::swdark_settings(swbrewratio)]}

#Brew Ratio Buttons

	#1:1.5
		add_de1_button "swbrewsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swbrewratio) "1.5" ; updateswbrewratio } 989 767 1322 997
	#1:2
		add_de1_button "swbrewsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swbrewratio) "2"  ; updateswbrewratio } 1343 767 1676 997
	#1:2.5
		add_de1_button "swbrewsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swbrewratio) "2.5"  ; updateswbrewratio } 989 1018 1322 1248
	#1:3
		add_de1_button "swbrewsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swbrewratio) "3"  ; updateswbrewratio } 1343 1018 1676 1248
	#1:4
		add_de1_button "swbrewsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swbrewratio) "4"  ; updateswbrewratio } 989 1269 1322 1499
	#1:5
		add_de1_button "swbrewsettings" {say [translate {settings}] $::settings(sound_button_in); set ::swdark_settings(swbrewratio) "5"  ; updateswbrewratio } 1343 1269 1676 1499

} else {}

###############################


proc skins_page_change_due_to_de1_state_change { textstate } {
	page_change_due_to_de1_state_change $textstate

	if {$textstate == "Steam"} {
		set_next_page off off; 
	} elseif {$textstate == "Espresso"} {
		set_next_page off off; 
	} elseif {$textstate == "HotWater"} {
		set_next_page off off; 
	} elseif {$textstate == "HotWaterRinse"} {
		set_next_page off off;
		after [expr "\[round_to_integer $::settings(preheat_volume)] * 1000"] {set_next_page off off; start_idle}
	}
}


# optional keyboard bindings
focus .can
bind Canvas <KeyPress> {handle_keypress %k}
