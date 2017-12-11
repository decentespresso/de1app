
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

load_font "Birdy" "[skin_directory]/Birdy.ttf" 26

# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off" 345 1450  -text [translate "ESPRESSO"] -font {Birdy} -fill "#f4f4f4" -anchor "center" 
add_de1_text "off" 945 1450  -text [translate "STEAM"] -font {Birdy} -fill "#f4f4f4" -anchor "center" 
add_de1_text "off" 1552 1450 -text [translate "WATER"] -font {Birdy} -fill "#f4f4f4" -anchor "center" 
add_de1_text "off" 2215 1450  -text [translate "SETTINGS"] -font {Birdy} -fill "#f4f4f4" -anchor "center" 


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 25 220 620 1555
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 630 220 1270 1555
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1290 220 1890 1555


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 650 20 1850 155
add_de1_button "off" {backup_settings; page_to_show_when_off settings_1} 1920 220 2515 1555

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

