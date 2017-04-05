
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

load_font "Heroes Legend" "[skin_directory]/Heroes Legend.ttf" 21

# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off " 1600 1495 -text [translate "HOT WATER"] -font {Heroes Legend} -fill "#ffffff" -anchor "center" 
add_de1_text "water" 744 1495 -text [translate "HOT WATER"] -font {Heroes Legend} -fill "#ffffff" -anchor "center" 


add_de1_text "off" 350 1495 -text [translate "ESPRESSO"] -font {Heroes Legend} -fill "#ffffff" -anchor "center" 
add_de1_text "espresso" 820 1495 -text [translate "ESPRESSO"] -font {Heroes Legend} -fill "#ffffff" -anchor "center" 

add_de1_text "off" 970 1495  -text [translate "STEAM"] -font {Heroes Legend} -fill "#ffffff" -anchor "center" 
add_de1_text "steam" 955 1495  -text [translate "STEAM"] -font {Heroes Legend} -fill "#ffffff" -anchor "center" 


add_de1_text "off settings" 2230 1495  -text [translate "SETTINGS"] -font {Heroes Legend} -fill "#ffffff" -anchor "center" 



# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {esspresso}] $::settings(sound_button_in);start_espresso" 95 221 613 1541
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1335	 221 1865 1541
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 712 221 1243 1541

# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 650 0 1900 135 
add_de1_button "off" {backup_settings; page_to_show_when_off settings_1} 1953 221 2483 1541

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

