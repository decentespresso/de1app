package require de1 1.0

##############################################################################################################################################################################################################################################################################
# DECENT ESPRESSO EXAMPLE SKIN FOR NEW SKIN DEVELOPERS
##############################################################################################################################################################################################################################################################################

# you should replace the JPG graphics in the 2560x1600/ directory with your own graphics. 
source "[homedir]/skins/default/standard_includes.tcl"

# example of loading a custom font (you need to indicate the TTF file and the font size)
#load_font "Northwood High" "[skin_directory]/sample.ttf" 60
#add_de1_text "off" 1280 500 -text "An important message" -font {Northwood High} -fill "#2d3046" -anchor "center"


##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is idle


load_font "mangaspeak" "[skin_directory]/mangaspeak.ttf" 28


# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off espresso" 272 350  -text [translate "ESPRESSO"] -font {mangaspeak} -fill "#CCCCCC" -anchor "center" 
add_de1_text "off steam" 865 350  -text [translate "STEAM"] -font {mangaspeak} -fill "#CCCCCC" -anchor "center" 
add_de1_text "off water" 1462 350 -text [translate "WATER"] -font {mangaspeak} -fill "#CCCCCC" -anchor "center" 
add_de1_text "off settings" 2055 350  -text [translate "SETTINGS"] -font {mangaspeak} -fill "#CCCCCC" -anchor "center" 


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 75 222 455 1350
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 630 222 1075 1350
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1245 222 1650 1350


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 750 1445 1900 1600
add_de1_button "off" {backup_settings; page_to_show_when_off settings_1} 1850 222 2405 1350

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

