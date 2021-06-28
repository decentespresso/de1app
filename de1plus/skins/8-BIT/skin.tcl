package require de1 1.0

##############################################################################################################################################################################################################################################################################
# DECENT ESPRESSO EXAMPLE SKIN FOR NEW SKIN DEVELOPERS
##############################################################################################################################################################################################################################################################################

# you should replace the JPG graphics in the 2560x1600/ directory with your own graphics. 
source "[homedir]/skins/default/standard_includes.tcl"

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
source "[homedir]/skins/default/standard_stop_buttons.tcl"




##############################################################################################################################################################################################################################################################################
# the graphics for each of the main espresso machine modes
#add_de1_page "off" "nothing_on.png"
#add_de1_page "espresso" "espresso_on_plus.png"
#add_de1_page "steam" "steam_on.png"
#add_de1_page "water hotwaterrinse" "tea_on.png"

# most skins will not bother replacing these graphics
#add_de1_page "sleep" "sleep.jpg" "default"
#add_de1_page "tankfilling" "filling_tank.jpg" "default"
#add_de1_page "tankempty" "fill_tank.jpg" "default"
#add_de1_page "cleaning" "cleaning.jpg" "default"
#add_de1_page "message" "settings_message.png" "default"
#add_de1_page "descaling" "descaling.jpg" "default"
#add_de1_page "cleaning" "cleaning.jpg" "default"

#set_de1_screen_saver_directory "[homedir]/saver"

# include the generic settings features for all DE1 skins.  
#source "[homedir]/skins/default/de1_skin_settings.tcl"


# example of loading a custom font (you need to indicate the TTF file and the font size)
#load_font "Northwood High" "[skin_directory]/sample.ttf" 60
#add_de1_text "off" 1280 500 -text "An important message" -font {Northwood High} -fill "#2d3046" -anchor "center"


# SKIN NAME: 8 BIT


##############################################################################################################################################################################################################################################################################
# text and buttons to display when the DE1 is idle

load_font "pixel" "[skin_directory]/pixel.ttf" 26
load_font "pixel2" "[skin_directory]/pixel2.ttf" 16
#load_font "eightbit" "[skin_directory]/eightbit.ttf" 24 12

# these 3 text labels are for the three main DE1 functions, and they X,Y coordinates need to be adjusted for your skin graphics
add_de1_text "off" 455 1100 -text [translate "ESPRESSO"] -font {pixel} -fill "#ffffff" -anchor "center" 

add_de1_text "off steam" 1318 1100  -text [translate "STEAM"] -font {pixel} -fill "#ffffff" -anchor "center" 
add_de1_text "off water hotwaterrinse" 2110 1100 -text [translate "WATER"] -font {pixel} -fill "#ffffff" -anchor "center" 

# these 3 buttons are rectangular areas, where tapping the rectangle causes a major DE1 action (steam/espresso/water)
add_de1_button "off" "say [translate {espresso}] $::settings(sound_button_in);start_espresso" 75 385 775 1250
add_de1_button "off" "say [translate {water}] $::settings(sound_button_in);start_water" 1800 385 2500 1250
add_de1_button "off" "say [translate {steam}] $::settings(sound_button_in);start_steam" 960 385 1650 1250

# these 2 buttons are rectangular areas for putting the machine to sleep or starting settings.  Traditionally, tapping one of the corners of the screen puts it to sleep.
add_de1_button "off" "say [translate {sleep}] $::settings(sound_button_in);start_sleep" 0 0 300 270
add_de1_button "off" {show_settings} 2250 0 2560 270

# show whether the espresso machine is ready to make an espresso, or heating, or the tablet is disconnected
add_de1_variable "off" 1320 100 -justify left -anchor "center" -text "" -font pixel -fill "#ffffff" -width 1520 -textvariable {[de1_connected_state 5]} 


if {$::settings(waterlevel_indicator_on) == 1} {
	# water level sensor 
	add_de1_widget "off espresso steam hotwaterrinse water" scale 2544 0 {after 1000 water_level_color_check $widget} -from 40 -to 5 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1600] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor #000000 -borderwidth 0  -highlightthickness 0
}


#######################
# zoomed espresso
add_de1_widget "espresso" graph 900 24 {
	bind $widget [platform_button_press] { 
		say [translate {stop}] $::settings(sound_button_in); 
		start_idle
	} 
	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color #69fdb3  -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 12] -color #18c37e  -smooth quadratic -pixels 0; 

	if {$::settings(display_pressure_delta_line) == 1} {
		$widget element create line_espresso_pressure_delta_1  -xdata espresso_elapsed -ydata espresso_pressure_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #40dc94 -pixels 0 -smooth quadratic 
	}

	$widget element create line_espresso_flow_goal_2x  -xdata espresso_elapsed -ydata espresso_flow_goal_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #7aaaff -smooth quadratic -pixels 0  -dashes {5 5}; 
	$widget element create line_espresso_flow_2x  -xdata espresso_elapsed -ydata espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 12] -color #4e85f4 -smooth quadratic -pixels 0; 
	$widget element create god_line_espresso_flow_2x  -xdata espresso_elapsed -ydata god_espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 24] -color #e4edff -smooth quadratic -pixels 0; 

	if {$::settings(display_weight_delta_line) == 1} {	
		$widget element create line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #a2693d -smooth quadratic -pixels 0; 
		$widget element create god_line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata god_espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 16] -color #edd4c1 -smooth quadratic -pixels 0; 
	}

	$widget element create god_line2_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 24] -color #c5ffe7  -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0 ; 

	$widget axis configure x -color #5a5d75 -tickfont pixel2; 
	$widget axis configure y -color #008c4c -tickfont pixel2 -min 0.0 -max $::de1(max_pressure) -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12}  -hide 0;
	$widget axis configure y2 -color #206ad4 -tickfont pixel2 -min 0.0 -max 6 -subdivisions 2 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6} -hide 0; 
	#$widget axis configure y2 -color #206ad4 -tickfont pixel2 -gridminor 0 -min 0.0 -max $::de1(max_flowrate) -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6} -hide 0; 
} -plotbackground #FFFFFF -width [rescale_x_skin 1620] -height [rescale_y_skin 1216] -borderwidth 1 -background #FFFFFF -plotrelief flat

#######################


set pos_top 20
set spacer 78
#set paragraph 20

set column1 060
set column2 280
set column2b 710
set column3 830
set font "pixel2"
if {$::settings(enable_fahrenheit) == 1} {
	set column2 195
}

set dark "#000000"
set lighter "#EEEEEE"
set lightest "#FFFFFF"

add_de1_text "espresso" $column1 [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "nw" -text [translate "Time"] -font $font -fill $dark -width [rescale_x_skin 620]
	add_de1_variable "espresso" $column1 [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "nw" -text "" -font $font  -fill $lighter -width [rescale_x_skin 620] -textvariable {[espresso_preinfusion_timer][translate "s"] [translate "preinfusion"]} 
	add_de1_variable "espresso" $column1 [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -text "" -font $font  -fill $lighter -width [rescale_x_skin 620] -textvariable {[espresso_pour_timer][translate "s"] [translate "pouring"]} 
	add_de1_variable "espresso" $column1 [expr {$pos_top + (3 * $spacer)}] -justify left -anchor "nw" -text "" -font $font -fill $lighter -width [rescale_x_skin 620] -textvariable {[espresso_elapsed_timer][translate "s"] [translate "total"]} 

add_de1_text "espresso" $column3 [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "ne" -text [translate "Volume"] -font $font -fill $dark -width [rescale_x_skin 520]
	add_de1_variable "espresso" $column3 [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "ne" -text "" -font $font  -fill $lighter -width [rescale_x_skin 520] -textvariable {[preinfusion_volume]} 
	add_de1_variable "espresso" $column3 [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "ne" -text "" -font $font  -fill $lighter -width [rescale_x_skin 520] -textvariable {[pour_volume]} 
	add_de1_variable "espresso" $column3 [expr {$pos_top + (3 * $spacer)}] -justify left -anchor "ne" -text "" -font $font -fill $lighter -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 



#######################
# flow 
add_de1_text "espresso" $column1 [expr {$pos_top + (4.5 * $spacer)}] -justify right -anchor "nw" -text [translate "Flow"] -font $font -fill $dark -width [rescale_x_skin 520]
	add_de1_variable "espresso" $column1 [expr {$pos_top + (5.5 * $spacer)}] -justify left -anchor "nw" -text "" -font $font -fill $lighter -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 
	add_de1_variable "espresso" $column1 [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "nw" -text "" -font $font -fill $lighter -width [rescale_x_skin 520] -textvariable {[pressure_text]} 
#######################

#######################
# weight
add_de1_variable "espresso" $column3 [expr {$pos_top + (4.5 * $spacer)}] -justify right -anchor "ne" -font $font -fill $dark -width [rescale_x_skin 620] -textvariable {[waterweight_label_text]}
	#add_de1_variable "off" $column3 [expr {$pos_top + (4 * $spacer)}] -justify left -anchor "ne" -text "" -font $font -fill $lighter -width [rescale_x_skin 520] -textvariable {[drink_weight_text]} 
	add_de1_variable "espresso" $column3 [expr {$pos_top + (5.5 * $spacer)}] -justify left -anchor "ne" -text "" -font $font -fill $lighter -width [rescale_x_skin 620] -textvariable {[waterweight_text]} 
	add_de1_variable "espresso" $column3 [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "ne" -text "" -font $font -fill $lighter -width [rescale_x_skin 620] -textvariable {[waterweightflow_text]} 

	if {$::settings(skale_bluetooth_address) != ""} {
		set ::de1(scale_weight_rate) -1
		#add_de1_widget "off" ProgressBar 0 1580 {} -width [rescale_y_skin 2540] -height [rescale_x_skin 20] -type normal  -variable ::de1(scale_weight) -fg #6b2c03 -bg #894419 -maximum 2000 -borderwidth 1 -relief flat -troughcolor #894419
		add_de1_widget "off" ProgressBar 0 1580 {} -width [rescale_y_skin 2540] -height [rescale_x_skin 20] -type normal  -variable ::de1(scale_weight_rate) -fg #6b2c03 -bg #894419 -maximum 1000 -borderwidth 1 -relief flat -troughcolor #894419
		#add_de1_widget "off espresso" scale 306 656 {} -from $::de1(water_level_full_point) -to $::de1(water_level_empty_point) -background #ab6439 -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 78] -showvalue 0 -width [rescale_y_skin 286] -variable ::de1(scale_weight_rate) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 10] -relief flat -troughcolor #FFFFF0 -borderwidth 0  -highlightthickness 0
	}
#######################




##############################################################################################################################################################################################################################################################################

