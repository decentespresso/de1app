
##############################################################################################################################################################################################################################################################################
# DECENT ESPRESSO EXAMPLE SKIN FOR NEW SKIN DEVELOPERS
##############################################################################################################################################################################################################################################################################

# you should replace the JPG graphics in the 2560x1600/ directory with your own graphics. 
source "[homedir]/skins/default/standard_includes.tcl"

##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is idle

# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 1600 950 2560 1550
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 1600 200 2560 900
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 450 600 1000 1100


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 1050 440 1590
add_de1_button "off" {backup_settings; page_to_show_when_off settings_1} 0 0 1000 590

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

