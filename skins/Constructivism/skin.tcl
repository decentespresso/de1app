
##############################################################################################################################################################################################################################################################################
# DECENT ESPRESSO EXAMPLE SKIN FOR NEW SKIN DEVELOPERS
##############################################################################################################################################################################################################################################################################

# you should replace the JPG graphics in the 2560x1600/ directory with your own graphics. 
source "[homedir]/skins/default/standard_includes.tcl"

# example of loading a custom font (you need to indicate the TTF file and the font size)
#load_font "Northwood High" "[skin_directory]/sample.ttf" 60
#add_de1_text "off" 1280 500 -text "An important message" -font {Northwood High} -fill "#2d3046" -anchor "center"


# SKIN NAME: 8 BIT


##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is idle

load_font "Orbitron" "[skin_directory]/orbitron.ttf" 19 9

# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off water" 2048 1215 -text [translate "HOT WATER"] -font {Orbitron} -fill "#ffffff" -anchor "center" 
add_de1_text "off espresso" 362 1215 -text [translate "ESPRESSO"] -font {Orbitron} -fill "#ffffff" -anchor "center" 
add_de1_text "off steam" 1289 1215  -text [translate "STEAM"] -font {Orbitron} -fill "#ffffff" -anchor "center" 


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 95 250 725 1300
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1750 250 2300 1300
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 975 250 1600 1300

# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 200 190
add_de1_button "off" {backup_settings; page_to_show_when_off settings_1} 2220 1320 2559 1500

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

