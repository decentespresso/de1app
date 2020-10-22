package require de1 1.0

##############################################################################################################################################################################################################################################################################
# DECENT ESPRESSO EXAMPLE SKIN FOR NEW SKIN DEVELOPERS
##############################################################################################################################################################################################################################################################################

# you should replace the JPG graphics in the 2560x1600/ directory with your own graphics. 
source "[homedir]/skins/default/standard_includes.tcl"

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"


# example of loading a custom font (you need to indicate the TTF file and the font size)
#load_font "Northwood High" "[skin_directory]/sample.ttf" 60
#add_de1_text "off" 1280 500 -text "An important message" -font {Northwood High} -fill "#2d3046" -anchor "center"


##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is idle

load_font "rothenburgd" "[skin_directory]/rothenburgd.ttf" 33

# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off espresso" 420 1508  -text [translate "Espresso"] -font {rothenburgd} -fill "#ffffff" -anchor "center" 
add_de1_text "off steam" 1290 1508  -text [translate "Steam"] -font {rothenburgd} -fill "#ffffff" -anchor "center" 
add_de1_text "off water hotwaterrinse" 2115 1508 -text [translate "Water"] -font {rothenburgd} -fill "#ffffff" -anchor "center" 
add_de1_text "off settings" 1965 150  -text [translate "Settings"] -font {rothenburgd} -fill "#ffffff" -anchor "center" 


# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 70 425 775 1500
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 925 425 1615 1500
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1780 425 2500 1500


# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 15 1350 300
add_de1_button "off" {show_settings} 1750 80 2150 250

##############################################################################################################################################################################################################################################################################

