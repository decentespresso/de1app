
##############################################################################################################################################################################################################################################################################
# DECENT ESPRESSO EXAMPLE SKIN FOR NEW SKIN DEVELOPERS
##############################################################################################################################################################################################################################################################################

# you should replace the JPG graphics in the 2560x1600/ directory with your own graphics. 
source "[homedir]/skins/default/standard_includes.tcl"

##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is idle

proc labels_on {} {
	set ::espresso_label [translate "ESPRESSO"]
	set ::steam_label [translate "STEAM"]
	set ::water_label [translate "WATER"]
	set ::settings_label [translate "SETTINGS"]
	set ::off_label [translate "OFF"]
	after 10000 labels_off
}
labels_on

proc labels_off {} {
	set ::espresso_label {}
	set ::steam_label {}
	set ::water_label {}
	set ::settings_label {}
	set ::off_label {}
}

add_de1_variable "off" 2000 1520  -font Helv_10_bold -fill "#888888" -anchor "center" -textvariable {[return $::espresso_label]}
add_de1_variable "off" 2260 370  -font Helv_10_bold -fill "#888888" -anchor "center" -textvariable {$::steam_label}
add_de1_variable "off" 670 1100 -font Helv_10_bold -fill "#CCCCCC" -anchor "center" -textvariable {$::water_label}
add_de1_variable "off" 390 86 -font Helv_10_bold -fill "#888888" -anchor "center" -textvariable {$::settings_label}
add_de1_variable "off" 150 1330  -font Helv_10_bold -fill "#888888" -anchor "center" -textvariable {$::off_label}


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso; " 1600 950 2560 1550
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam; " 1600 200 2560 900
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water; " 450 600 1000 1100


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 1050 440 1590
add_de1_button "off" {show_settings; after 2000 labels_on} 0 0 1000 590

# show whether the espresso machine is ready to make an espresso, or heating, or the tablet is disconnected
add_de1_variable "off" 1280 700 -justify left -anchor "nw" -text "" -font Helv_20_bold -fill "#DDDDDD" -width 1520 -textvariable {[de1_connected_state 5]} 

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

