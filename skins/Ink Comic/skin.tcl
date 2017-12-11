
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

load_font "DSEraserCyr" "[skin_directory]/DSEraserCyr.ttf" 20 

# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off espresso" 977 405  -text [translate "Ah, 
nothin' 
like 
Espresso 
to start 
the 
day"] -font {DSEraserCyr} -fill "#7a542f" -anchor "center" 

add_de1_text "off steam" 1605 635 -text [translate "Bloody hell! 
The STEAM
is busted"] -font {DSEraserCyr} -fill "#1f72c7" -anchor "center" 

add_de1_text "off water" 880 980 -text [translate "And there's
WATER
all over
the floor!"] -font {DSEraserCyr} -fill "#ff1717" -anchor "center" 

add_de1_text "off settings" 1550 1440 -text [translate "No problem, 
I can FIX this"] -font {DSEraserCyr} -fill "#000000" -anchor "center" 



# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 95 10 1180 800
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 1350 40 2425 800
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 130 865 1200 1560


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 5 1000 80 1550
add_de1_button "off" {backup_settings; page_to_show_when_off settings_1} 1350 845 2425 1560

##############################################################################################################################################################################################################################################################################

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"

