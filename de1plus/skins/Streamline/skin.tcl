package require de1 1.0

##############################################################################################################################################################################################################################################################################
# STREAMLINE SKIN
##############################################################################################################################################################################################################################################################################

# you should replace the JPG graphics in the 2560x1600/ directory with your own graphics. 
source "[homedir]/skins/default/standard_includes.tcl"

load_font "Inter-Regular10" "[skin_directory]/Inter-Regular.ttf" 10
load_font "Inter-Bold12" "[skin_directory]/Inter-SemiBold.ttf" 12


set pages [list off steam espresso water flush info hotwaterrinse]
add_de1_page $pages "pumijo.jpg"



############################################################################################################################################################################################################
# Four GHC buttons on bottom right

# color of the button icons
dui aspect set -theme default -type dbutton_symbol fill #121212

# font size of the button icons
dui aspect set -theme default -type dbutton_symbol font_size 24

# position of the button icons
dui aspect set -theme default -type dbutton_symbol pos ".50 .38"

# Four GHC buttons on bottom right
dui add dbutton $pages 2159 1216 2316 1384 -tags espresso_btn -shape round_outline -symbol "mug"  -label_pos ".50 .75" -radius 18 -label_font Inter-Bold12 -fill "#FFFFFF" -width 2 -outline "#121212" -label [translate "Coffee"]  -label_fill "#121212" -command {say [translate {Espresso}] $::settings(sound_button_in); start_espresso} 
dui add dbutton $pages 2159 1401 2316 1566 -tags steam_btn -shape round_outline -symbol clouds  -label_pos ".50 .75"  -radius 18 -label_font Inter-Bold12 -fill "#FFFFFF" -width 2 -outline "#121212" -label [translate "Steam"]  -label_fill "#121212" -command {say [translate {Steam}] $::settings(sound_button_in); start_steam} 
dui add dbutton $pages 2336 1216 2497 1384 -tags water_btn -shape round_outline -symbol droplet  -label_pos ".50 .75" -radius 18 -label_font Inter-Bold12 -fill "#FFFFFF" -width 2 -outline "#121212" -label [translate "Water"]  -label_fill "#121212" -command {say [translate {Water}] $::settings(sound_button_in); start_water} 
dui add dbutton $pages 2336 1401 2497 1566 -tags flush_btn -shape round_outline -symbol shower-down  -label_pos ".50 .75" -radius 18 -label_font Inter-Bold12 -fill "#FFFFFF" -width 2 -outline "#121212" -label [translate "Flush"]  -label_fill "#121212" -command {say [translate {Flush}] $::settings(sound_button_in); start_flush} 

############################################################################################################################################################################################################

