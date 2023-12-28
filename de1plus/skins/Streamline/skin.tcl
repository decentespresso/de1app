package require de1 1.0

##############################################################################################################################################################################################################################################################################
# STREAMLINE SKIN
##############################################################################################################################################################################################################################################################################

# you should replace the JPG graphics in the 2560x1600/ directory with your own graphics. 
source "[homedir]/skins/default/standard_includes.tcl"

load_font "Inter-Regular10" "[skin_directory]/Inter-Regular.ttf" 11

# Left column labels
load_font "Inter-Bold16" "[skin_directory]/Inter-SemiBold.ttf" 13

# GHC buttons
load_font "Inter-Bold12" "[skin_directory]/Inter-SemiBold.ttf" 12

# Profile buttons
load_font "Inter-Bold11" "[skin_directory]/Inter-SemiBold.ttf" 11

# +/- buttons
load_font "Inter-Bold24" "[skin_directory]/Inter-ExtraLight.ttf" 29

# X and Y axis font
load_font "Inter-Regular20" "[skin_directory]/Inter-Regular.ttf" 14


set pages [list off steam espresso water flush info hotwaterrinse]
#add_de1_page $pages ""
dui page add $pages -bg_color "#FFFFFF"
#add_de1_page $pages "pumijo.jpg"



############################################################################################################################################################################################################
# draw the background shapes

# far left grey area where buttons appear
rectangle $pages 0 0 657 1600 #efefef

# lower horizontal bar where shot data is shown
rectangle $pages 687 1220 2130 1566 #efefef
rectangle $pages 0 824 660 836 #ffffff

rectangle $pages 58 603 590 604 #121212
rectangle $pages 58 1061 590 1062 #121212
rectangle $pages 58 1282 590 1283 #121212

############################################################################################################################################################################################################



############################################################################################################################################################################################################
# draw text labels for the buttons on the left margin

set left_label_color #05386c

# labels
add_de1_text $pages 60 318 -justify left -anchor "nw" -text [translate "Dose"] -font Inter-Bold16 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 60 434 -justify left -anchor "nw" -text [translate "Beverage"] -font Inter-Bold16 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 60 655 -justify left -anchor "nw" -text [translate "Temp"] -font Inter-Bold16 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 60 892 -justify left -anchor "nw" -text [translate "Steam"] -font Inter-Bold16 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 60 1117 -justify left -anchor "nw" -text [translate "Flush"] -font Inter-Bold16 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 60 1338 -justify left -anchor "nw" -text [translate "Hot Water"] -font Inter-Bold16 -fill $left_label_color -width [rescale_x_skin 200]

# tap areas
add_de1_button "off" {puts "Dose"} 37 292 236 388 ""
add_de1_button "off" {puts "Beverage"} 37 407 236 503 ""
add_de1_button "off" {puts "Temp"} 37 628 236 724 ""
add_de1_button "off" {puts "Steam"} 37 866 236 962 ""
add_de1_button "off" {puts "Flush"} 37 1089 236 1185 ""
add_de1_button "off" {puts "Hot Water"} 37 1310 236 1406 ""

############################################################################################################################################################################################################

############################################################################################################################################################################################################
# draw current setting numbers on the left margin

set left_label_color #121212

# labels
add_de1_text $pages 426 341 -justify center -anchor "center" -text [translate "20g"] -font Inter-Bold16 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 426 459 -justify center -anchor "center" -text [translate "46g\n(1:2.3)"] -font Inter-Bold16 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 426 679 -justify left -anchor "center" -text [translate "92ºC"] -font Inter-Bold16 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 426 917 -justify left -anchor "center" -text [translate "31s"] -font Inter-Bold16 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 426 1137 -justify left -anchor "center" -text [translate "5s"] -font Inter-Bold16 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 426 1358 -justify left -anchor "center" -text [translate "75ml"] -font Inter-Bold16 -fill $left_label_color -width [rescale_x_skin 200]

# tap areas
add_de1_button "off" {puts "Dose value"} 359 292 496 388 ""
add_de1_button "off" {puts "Beverage value"} 359 407 496 503 ""
add_de1_button "off" {puts "Temp value"} 359 628 496 724 ""
add_de1_button "off" {puts "Steam value"} 359 866 496 962 ""
add_de1_button "off" {puts "Flush value"} 359 1089 496 1185 ""
add_de1_button "off" {puts "Hot Water value"} 359 1310 496 1406 ""

############################################################################################################################################################################################################

############################################################################################################################################################################################################
# draw current setting numbers on the left margin

set left_label_color_selected #121212
set left_label_color #777777

#########
# dose/beverage labels
add_de1_text $pages 94 552 -justify center -anchor "center" -text [translate "18:36"] -font Inter-Bold11 -fill $left_label_color_selected -width [rescale_x_skin 200]
add_de1_text $pages 234 552 -justify center -anchor "center" -text [translate "19:39"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 388 552 -justify center -anchor "center" -text [translate "20.5:42"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 554 552 -justify center -anchor "center" -text [translate "21:44"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]

# dose/beverage tap areas
add_de1_button "off" {puts "Dose value 1"} 37 521 169 584 ""
add_de1_button "off" {puts "Dose value 2"} 169 521 301 584 ""
add_de1_button "off" {puts "Dose value 3"} 301 521 466 584 ""
add_de1_button "off" {puts "Dose value 4"} 466 521 613 584 ""
#########

#########
# temp labels
add_de1_text $pages 94 774 -justify center -anchor "center" -text [translate "75ºC"] -font Inter-Bold11 -fill $left_label_color_selected -width [rescale_x_skin 200]
add_de1_text $pages 234 774 -justify center -anchor "center" -text [translate "80ºC"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 388 774 -justify center -anchor "center" -text [translate "92ºC"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 554 774 -justify center -anchor "center" -text [translate "85ºC"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]

# temp tap areas
add_de1_button "off" {puts "Temp value 1"} 37 743 169 806 ""
add_de1_button "off" {puts "Temp value 2"} 169 743 301 806 ""
add_de1_button "off" {puts "Temp value 3"} 301 743 466 806 ""
add_de1_button "off" {puts "Temp value 4"} 466 743 613 806 ""
#########

#########
# steam labels
add_de1_text $pages 94 1014 -justify center -anchor "center" -text [translate "25s"] -font Inter-Bold11 -fill $left_label_color_selected -width [rescale_x_skin 200]
add_de1_text $pages 234 1014 -justify center -anchor "center" -text [translate "29s"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 388 1014 -justify center -anchor "center" -text [translate "31s"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 554 1014 -justify center -anchor "center" -text [translate "40s"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]

# steam tap areas
add_de1_button "off" {puts "steam value 1"} 37 983 169 1046 ""
add_de1_button "off" {puts "steam value 2"} 169 983 301 1046 ""
add_de1_button "off" {puts "steam value 3"} 301 983 466 1046 ""
add_de1_button "off" {puts "steam value 4"} 466 983 613 1046 ""
#########

#########
# flush labels
add_de1_text $pages 94 1230 -justify center -anchor "center" -text [translate "2s"] -font Inter-Bold11 -fill $left_label_color_selected -width [rescale_x_skin 200]
add_de1_text $pages 234 1230 -justify center -anchor "center" -text [translate "5s"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 388 1230 -justify center -anchor "center" -text [translate "10s"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 554 1230 -justify center -anchor "center" -text [translate "15s"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]

# flush tap areas
add_de1_button "off" {puts "flush value 1"} 37 1194 169 1257 ""
add_de1_button "off" {puts "flush value 2"} 169 1194 301 1257 ""
add_de1_button "off" {puts "flush value 3"} 301 1194 466 1257 ""
add_de1_button "off" {puts "flush value 4"} 466 1194 613 1257 ""
#########


#########
# hot water labels
add_de1_text $pages 94 1454 -justify center -anchor "center" -text [translate "75ml"] -font Inter-Bold11 -fill $left_label_color_selected -width [rescale_x_skin 200]
add_de1_text $pages 234 1454 -justify center -anchor "center" -text [translate "120ml"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 388 1454 -justify center -anchor "center" -text [translate "180ml"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 554 1454 -justify center -anchor "center" -text [translate "200ml"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]

add_de1_text $pages 94 1534 -justify center -anchor "center" -text [translate "75ºC"] -font Inter-Bold11 -fill $left_label_color_selected -width [rescale_x_skin 200]
add_de1_text $pages 234 1534 -justify center -anchor "center" -text [translate "80ºC"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 388 1534 -justify center -anchor "center" -text [translate "85ºC"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]
add_de1_text $pages 554 1534 -justify center -anchor "center" -text [translate "90ºC"] -font Inter-Bold11 -fill $left_label_color -width [rescale_x_skin 200]


# hot water tap areas
add_de1_button "off" {puts "hot water value 1"} 37 1424 169 1489 ""
add_de1_button "off" {puts "hot water value 2"} 169 1424 301 1489 ""
add_de1_button "off" {puts "hot water value 3"} 301 1424 466 1489 ""
add_de1_button "off" {puts "hot water value 4"} 466 1424 613 1489 ""

add_de1_button "off" {puts "hot water value 5"} 37 1489 169 1566 ""
add_de1_button "off" {puts "hot water value 6"} 169 1489 301 1566 ""
add_de1_button "off" {puts "hot water value 7"} 301 1489 466 1566 ""
add_de1_button "off" {puts "hot water value 8"} 466 1489 613 1566 ""
#########



############################################################################################################################################################################################################



############################################################################################################################################################################################################
# four ESPRESSO PROFILE shotcut buttons at the top left

# rounded rectangle color 
dui aspect set -theme default -type dbutton outline "#D8D8D8"

# inside button color
dui aspect set -theme default -type dbutton fill "#d8d8d8"
#d8d8d8


# font to use
dui aspect set -theme default -type dbutton label_font Inter-Bold11

# rounded retangle radius
dui aspect set -theme default -type dbutton radius 18

# rounded retangle line width
dui aspect set -theme default -type dbutton width 2 


# width of the text, to enable auto-wrapping
dui aspect set -theme default -type dbutton_label width [rescale_x_skin 480]

# button shape
dui aspect set -theme default -type dbutton shape round_outline 

# label position
dui aspect set -theme default -type dbutton label_pos ".50 .50" 

####
# the selected profile button

# button color
dui aspect set -theme default -type dbutton fill "#3e5682"

# font color
dui aspect set -theme default -type dbutton label_fill "#ffffff"

dui add dbutton $pages 58 27 311 136 -tags profile_1_btn -label "Damian's LRv2 Long Name"  -command { puts profile_1_btn } 

####
# NOT selected profile buttons

# button color
dui aspect set -theme default -type dbutton fill "#d8d8d8"

# font color
dui aspect set -theme default -type dbutton label_fill "#3c5782"

dui add dbutton $pages 341 27 592 136 -tags profile_2_btn -label "Default"  -command { puts profile_2_btn } 
dui add dbutton $pages 58 157 311 267 -tags profile_3_btn -label "Rao Allonge"  -command { puts profile_3_btn } 
dui add dbutton $pages 341 157 592 267 -tags profile_4_btn -label "Extramundo Dos!"  -command { puts profile_4_btn } 



############################################################################################################################################################################################################


############################################################################################################################################################################################################
# plus/minus buttons on the left hand side for changing parameters

# rounded rectangle color 
dui aspect set -theme default -type dbutton outline "#D8D8D8"

# inside button color
dui aspect set -theme default -type dbutton fill "#d8d8d8"

# font color
dui aspect set -theme default -type dbutton label_fill "#121212"

# font to use
dui aspect set -theme default -type dbutton label_font Inter-Bold24 

# rounded retangle radius
dui aspect set -theme default -type dbutton radius 18

# rounded retangle line width
dui aspect set -theme default -type dbutton width 2 

# button shape
dui aspect set -theme default -type dbutton shape round_outline 

# label position
dui aspect set -theme default -type dbutton label_pos ".50 .44" 


# the - buttons
dui add dbutton $pages 262 292 359 388 -tags minus_dose_btn -label "-"  -command { puts plus_dose_btn } 
dui add dbutton $pages 262 407 359 503 -tags minus_beverage_btn -label "-"  -command { puts minus_beverage_btn } 
dui add dbutton $pages 262 629 359 725 -tags minus_temp_btn -label "-"  -command { puts minus_temp_btn } 
dui add dbutton $pages 262 866 359 962 -tags minus_steam_btn -label "-"  -command { puts minus_steam_btn } 
dui add dbutton $pages 262 1089 359 1185 -tags minus_flush_btn -label "-"  -command { puts minus_flush_btn } 
dui add dbutton $pages 262 1310 359 1406 -tags minus_hotwater_btn -label "-"  -command { puts minus_hotwater_btn } 

# the + buttons
dui add dbutton $pages 495 292 591 388 -tags plus_dose_btn -label "+"  -command { puts plus_dose_btn } 
dui add dbutton $pages 495 407 591 503 -tags plus_beverage_btn -label "+"  -command { puts plus_beverage_btn } 
dui add dbutton $pages 495 629 591 725 -tags plus_temp_btn -label "+"  -command { puts plus_temp_btn } 
dui add dbutton $pages 495 866 591 962 -tags plus_steam_btn -label "+"  -command { puts plus_steam_btn } 
dui add dbutton $pages 495 1089 591 1185 -tags plus_flush_btn -label "+"  -command { puts plus_flush_btn } 
dui add dbutton $pages 495 1310 591 1406 -tags plus_hotwater_btn -label "+"  -command { puts plus_hotwater_btn } 

############################################################################################################################################################################################################




############################################################################################################################################################################################################
# Four GHC buttons on bottom right

# color of the button icons
dui aspect set -theme default -type dbutton_symbol fill #121212

# font size of the button icons
dui aspect set -theme default -type dbutton_symbol font_size 24

# position of the button icons
dui aspect set -theme default -type dbutton_symbol pos ".50 .38"

# rounded rectangle color 
dui aspect set -theme default -type dbutton outline "#121212"

# inside button color
dui aspect set -theme default -type dbutton fill "#FFFFFF"

# font color
dui aspect set -theme default -type dbutton label_fill "#121212"

# font to use
dui aspect set -theme default -type dbutton label_font Inter-Bold12 

# rounded retangle radius
dui aspect set -theme default -type dbutton radius 18

# rounded retangle line width
dui aspect set -theme default -type dbutton width 2 

# button shape
dui aspect set -theme default -type dbutton shape round_outline 

# label position
dui aspect set -theme default -type dbutton label_pos ".50 .75" 


# Four GHC buttons on bottom right
if {$::android == 1 || $::undroid == 1} {
	set s1 "mug"
	set s2 "clouds"
	set s3 "droplet"
	set s4 "shower-down"
	set s5 "hand"
} else {
	set s1 "C"
	set s2 "S"
	set s3 "W"
	set s4 "F"
	set s5 "S"
}
dui add dbutton "off" 2159 1216 2316 1384 -tags espresso_btn -symbol $s1 -label [translate "Coffee"]   -command {say [translate {Espresso}] $::settings(sound_button_in); start_espresso} 
dui add dbutton "off" 2159 1401 2316 1566 -tags steam_btn -symbol $s2 -label [translate "Steam"]   -command {say [translate {Steam}] $::settings(sound_button_in); start_steam} 
dui add dbutton "off" 2336 1216 2497 1384 -tags water_btn -symbol $s3 -label [translate "Water"]   -command {say [translate {Water}] $::settings(sound_button_in); start_water} 
dui add dbutton "off" 2336 1401 2497 1566 -tags flush_btn -symbol $s4 -label [translate "Flush"]  -command {say [translate {Flush}] $::settings(sound_button_in); start_flush} 

# stop button
dui add dbutton "espresso water steam hotwaterrinse" 2159 1216 2494 1566 -tags espresso_btn -symbol $s5  -label [translate "Stop"] -command {say [translate {Stop}] $::settings(sound_button_in); start_idle} 

############################################################################################################################################################################################################



############################################################################################################################################################################################################
# the espresso chart

set ::pressurelinecolor "#0ba581"
set ::flow_line_color "#6c9bff"
set ::temperature_line_color "#ff7880"

set ::pressurelinecolor_god "#5deea6"
set ::flow_line_color_god "#a7d1ff"
set ::temperature_line_color_god "#ffafb4"
set ::weightlinecolor_god "#edd4c1"
set ::chart_background "#FFFFFF"

set ::pressurelabelcolor "#121212"
set ::temperature_label_color "#ff7880"
set ::flow_label_color "#6c9bff"
set ::grid_color "#E0E0E0"

set charts_width 1830

add_de1_widget $pages graph 680 250 { 

	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color $::pressurelinecolor  -smooth $::settings(live_graph_smoothing_technique)  -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::pressurelinecolor  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create god_line_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 20] -color $::pressurelinecolor_god  -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0 ; 

	# show the explanation
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure  -label "" -linewidth [rescale_x_skin 15] -color $::pressurelinecolor  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 

	if {$::settings(display_pressure_delta_line) == 1} {
		$widget element create line_espresso_pressure_delta2  -xdata espresso_elapsed -ydata espresso_pressure_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #40dc94 -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	gridconfigure $widget 

	$widget axis configure x -color $::pressurelabelcolor -tickfont Inter-Regular20 -linewidth [rescale_x_skin 2] 
	$widget axis configure y -color $::pressurelabelcolor -tickfont Inter-Regular20 -min 0.0 -max [expr {$::de1(max_pressure) + 0.01}] -subdivisions 5 -majorticks {1 3 5 7 9 11} 
} -plotbackground $::chart_background -width [rescale_x_skin $charts_width] -height [rescale_y_skin 943] -borderwidth 1 -background $::chart_background -plotrelief flat -plotpady 0 -plotpadx 10  
############################################################################################################################################################################################################

