#SWDark3 theme by Spencer Webb, V0, April 12 2019
#Adapted and inspired by the Insight & Modernist themes.  Thanks John & David V!  

set ::skindebug 0
set ::debugging 0


source "[homedir]/skins/default/standard_includes.tcl"

##### Colour variables for chart lines#####
#set green-dotted "#8fd0af"
#set green-solid "#458c6f"
#set blue-dotted "#7aaaff"
#set blue-solid "#526fa9"
#set blue-light "#bec7db"
#set red-solid "#a04b56"
#set red-dotted "#ffcccd"

set chartbackgroundcol "#242424"
set ::chartaxiscol "#aaaaaa"
set ::chartgridcol "#343434"
set ::chartprofilestepcol "#4E4E4E"
set ::chartpressurelinecol "#86C240"
set ::chartpressurelinerescale "6"
set ::chartpressuregoallinecol "#86C240"
set ::chartpressuregoallinerescale "12" 
set ::chartflowlinecol "#43B1E3"
set ::chartflowlinerescale "12"
set ::chartflowgoallinecol "#87c6e3"
set ::chartflowgoallinerescale "6"
set ::charttemplinecol "#FF2600"
set ::charttemplinerescale "12"
set ::charttempgoallinecol "#ff674c"
set ::charttempgoallinerescale "6"
set ::chartweightlinecol "#ff6a00"
set ::chartweightlinerescale "12"
set ::chartprofilestepzoomcol "#ffffff"
set ::chartgodpressurecol "#CAF795"
set ::chartgodflowcol "#A1E2FF"
set ::chartgodweightcol "#FFD1B0"
set ::chartgodtempcol "#FFB9AD"
#set ::detailtextcol "#969eb1"
set ::detailtextcol "#9f9f9f"
set ::detailtextheadingcol "#ffffff"


load_font_obsolete "helveticabold" "[skin_directory]/helveticabold.ttf" 24
load_font_obsolete "helveticabold2" "[skin_directory]/helveticabold2.ttf" 16

    if {$::settings(settings_profile_type) == "settings_2c"} {
    set ::stopatweight $::settings(final_desired_shot_weight_advanced)g
    } else {
    set ::stopatweight $::settings(final_desired_shot_weight)g
    }


#puts "debugging: $::debugging"

package require de1plus 1.0
package ifneeded swdark2_functions 1.0 [list source [file join "[skin_directory]/swdark2_functions.tcl"]]
#package ifneeded swdark2_usersettings 1.0 [list source [file join "./skins/SWDark2/userdata/" swdark2_usersettings.tdb]]
package require swdark2_functions 1.0
#package require swdark2_usersettings 1.0

#swdark2_filename
load_swdark2_settings

#set zoomed graph y/y2 axis
swdark_setyaxis
set ::zoomed_y2_axis_scale [expr {$::swdark2_settings(sw_y_axisscale) / 2}]

# example of loading a custom font (you need to indicate the TTF file and the font size)
#load_font "Northwood High" "[skin_directory]/sample.ttf" 60
#add_de1_text "off" 1280 500 -text "An important message" -font {Northwood High} -fill "#2d3046" -anchor "center"

#this fucker isn't working so doing this on-screen instead of programatically for now 
#load_font "Gotham Bold" "[skin_directory]/fonts/GothamOffice-Regular.ttf" 20

##############################################################################################################################################################################################################################################################################
# the graphics for each of the main espresso machine modes

set ::settings(display_rate_espresso) 1
if {$::settings(display_rate_espresso) == 1} {
	add_de1_page "off espresso_3" "espresso_3.png"
	add_de1_page "off_zoomed off_zoomed_temperature espresso_3_zoomed espresso_3_zoomed_temperature" "espresso_3_zoomed.png"
} else {
	# no need to display the heart icon after espresso is finished, if "Rate espresso" is disabled
	add_de1_page "off" "espresso_1.png"
	add_de1_page "off_zoomed off_zoomed_temperature" "espresso_1_zoomed.png"

	add_de1_page "espresso_3" "espresso_1.png"
	add_de1_page "espresso_3_zoomed espresso_3_zoomed_temperature" "espresso_1_zoomed.png"
}

add_de1_page "espresso" "espresso_2.png"
add_de1_page "espresso_zoomed espresso_zoomed_temperature" "espresso_2_zoomed.png" 

add_de1_page "steam steam_zoom" "steam_2.png"
add_de1_page "steam_1" "steam_1.png"
add_de1_page "steam_3 steam_zoom_3" "steam_3.png"

add_de1_page "water" "water_2.png"
add_de1_page "water_1" "water_1.png"
add_de1_page "water_3" "water_3.png"

add_de1_page "preheat_1" "preheat_1.png"
add_de1_page "preheat_2" "preheat_2.png"
add_de1_page "preheat_3" "preheat_3.png"
add_de1_page "preheat_4" "preheat_4.png"

#add_de1_page "sleep" "sleep.png"
#add_de1_page "tankempty refill" "fill_tank.png"

# most skins will not bother replacing these graphics
#add_de1_page "sleep" "sleep.jpg" "default"
#add_de1_page "tankfilling" "filling_tank.jpg" "default"
#add_de1_page "tankempty refill" "fill_tank.jpg" "default"
#add_de1_page "message calibrate infopage tabletstyles languages measurements" "settings_message.png" "default"
#add_de1_page "create_preset" "settings_3_choices.png" "default"
#add_de1_page "descalewarning" "descalewarning.jpg" "default"

#add_de1_page "cleaning" "cleaning.jpg" "default"
#add_de1_page "descaling" "descaling.jpg" "default"
#add_de1_page "descale_prepare" "descale_prepare.jpg" "default"

#add_de1_page "travel_prepare" "travel_prepare.jpg" "default"
#add_de1_page "travel_do" "travel_do.jpg" "default"

#add_de1_page "ghc_steam ghc_espresso ghc_flush ghc_hotwater" "ghc.jpg" "default"
#add_de1_text "ghc_steam" 1990 680 -text "\[      \]\n[translate {Tap here for steam}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 950
#add_de1_text "ghc_espresso" 1936 950 -text "\[      \]\n[translate {Tap here for espresso}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 950
#add_de1_text "ghc_flush" 1520 840 -text "\[      \]\n[translate {Tap here to flush}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 750
#add_de1_text "ghc_hotwater" 1630 600 -text "\[      \]\n[translate {Tap here for hot water}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 820
#add_de1_button "ghc_steam ghc_espresso ghc_flush ghc_hotwater" {say [translate {Ok}] $::settings(sound_button_in); page_show off;} 0 0 2560 1600 

# out of water page
#add_de1_button "tankempty refill" {say [translate {awake}] $::settings(sound_button_in);start_refill_kit} 0 0 2560 1400 
#	add_de1_text "tankempty refill" 1280 750 -text [translate "Please add water"] -font Helv_20_bold -fill "#CCCCCC" -justify "center" -anchor "center" -width 900
#	add_de1_variable "tankempty refill" 1280 900 -justify center -anchor "center" -text "" -font Helv_10 -fill "#CCCCCC" -width 520 -textvariable {[refill_kit_retry_button]} 
#	add_de1_text "tankempty" 340 1504 -text [translate "Exit App"] -font Helv_10_bold -fill "#AAAAAA" -anchor "center" 
#	add_de1_text "tankempty" 2220 1504 -text [translate "Ok"] -font Helv_10_bold -fill "#AAAAAA" -anchor "center" 
#	add_de1_button "tankempty" {say [translate {Exit}] $::settings(sound_button_in); .can itemconfigure $::message_label -text [translate "Going to sleep"]; .can itemconfigure $::message_button_label -text [translate "Wait"]; after 10000 {.can itemconfigure $::message_button_label -text [translate "Ok"]; }; set_next_page off message; page_show message; after 500 app_exit} 0 1402 800 1600
#	add_de1_button "tankempty refill" {say [translate {awake}] $::settings(sound_button_in);start_refill_kit} 1760 1402 2560 1600

# show descale warning after steam, if clogging of the steam wand is detected
#add_de1_text "descalewarning" 1280 1310 -text [translate "Your steam wand is clogging up"] -font Helv_17_bold -fill "#FFFFFF" -justify "center" -anchor "center" -width 900
#add_de1_text "descalewarning" 1280 1480 -text [translate "It needs to be descaled soon"] -font Helv_15_bold -fill "#FFFFFF" -justify "center" -anchor "center" -width 900
#add_de1_button "descalewarning" {say [translate {descale}] $::settings(sound_button_in); show_settings descale_prepare} 0 0 2560 1600 

# cleaning and descaling
#add_de1_text "cleaning" 1280 80 -text [translate "Cleaning"] -font Helv_20_bold -fill "#EEEEEE" -justify "center" -anchor "center" -width 900
#add_de1_text "descaling" 1280 80 -text [translate "Descaling"] -font Helv_20_bold -fill "#CCCCCC" -justify "center" -anchor "center" -width 900


# new screensavers while we're at it. 
#set_de1_screen_saver_directory "[skin_directory]/screen_saver"
 
#source "[homedir]/skins/default/de1_skin_settings.tcl"

# the standard behavior when the DE1 is doing something is for tapping anywhere on the screen to stop that. This "source" command does that.
#source "[homedir]/skins/default/standard_includes.tcl"



# the font used in the big round green buttons needs to fit appropriately inside the circle, 
# and thus is dependent on the translation of the words inside the circle
set green_button_font "Helv_19_bold"
if {[language] == "fr" || [language] == "es" || [language] == "sv"} {
	set green_button_font "Helv_16_bold"
}

set ::current_espresso_page "off"

################################################################################################################################################################################################################################################################################################
# Labels temp disabled while working through font issues, inserted via background images instead of programatically

# labels for PREHEAT tab on
#add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 405 100 -text [translate "FLUSH"] -font Helv_10_bold -fill "#000000" -anchor "center" 
#add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 1035 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#8b8b8b" -anchor "center" 
#add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 1665 100 -text [translate "STEAM"] -font Helv_10_bold -fill "#8b8b8b" -anchor "center" 
#add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 2290 100 -text [translate "WATER"] -font Helv_10_bold -fill "#8b8b8b" -anchor "center" 

# labels for ESPRESSO tab on
#add_de1_text "off espresso espresso_3" 1035 100 -text [translate "FLUSH"] -font helveticabold -fill "#8b8b8b" -anchor "center" 
#add_de1_text "off espresso espresso_3" 2290 100 -text [translate "ESPRESSO"] -font helveticabold2 -fill "#000000" -anchor "center" 
#add_de1_text "off espresso espresso_3" 1665 100 -text [translate "STEAM"] -font helveticabold -fill "#8b8b8b" -anchor "center" 
#add_de1_text "off_zoomed espresso_3_zoomed espresso_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" 2350 90 -text [translate "STEAM"] -font helveticabold -fill "#8b8b8b" -anchor "center" 
#add_de1_text "off espresso espresso_3" 405 100  -text [translate "WATER"] -font helveticabold -fill "#8b8b8b" -anchor "center" 

# labels for STEAM tab on
#add_de1_text "steam steam_1 steam_3 steam_zoom_3 steam_zoom" 405 100 -text [translate "FLUSH"] -font Helv_10_bold -fill "#8b8b8b" -anchor "center" 
#add_de1_text "steam steam_1 steam_3 steam_zoom_3 steam_zoom" 1035 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#8b8b8b" -anchor "center" 
#add_de1_text "steam steam_1 steam_3 steam_zoom_3 steam_zoom" 1665 100 -text [translate "STEAM"] -font Helv_10_bold -fill "#000000" -anchor "center" 
#add_de1_text "steam steam_1 steam_3 steam_zoom_3 steam_zoom" 2290 100 -text [translate "WATER"] -font Helv_10_bold -fill "#8b8b8b" -anchor "center" 

# labels for HOT WATER tab on
#add_de1_text "water water_1 water_3" 405 100 -text [translate "FLUSH"] -font Helv_10_bold -fill "#8b8b8b" -anchor "center" 
#add_de1_text "water water_1 water_3" 1035 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#8b8b8b" -anchor "center" 
#add_de1_text "water water_1 water_3" 1665 100 -text [translate "STEAM"] -font Helv_10_bold -fill "#8b8b8b" -anchor "center" 
#add_de1_text "water water_1 water_3" 2290 100 -text [translate "WATER"] -font Helv_10_bold -fill "#000000" -anchor "center" 

################################################################################################################################################################################################################################################################################################


# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
#Flush
add_de1_button "off off_zoomed off_zoomed_temperature espresso espresso_1 espresso_1_zoomed espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature steam_1 steam_3 steam_zoom_3 water_1 water_3 water_4" {say [translate {Flush}] $::settings(sound_button_in); set_next_page off preheat_1; page_show preheat_1; if {$::settings(one_tap_mode) == 1} { set_next_page hotwaterrinse preheat_2; start_hot_water_rinse } } 642 0 1277 188
#Espresso
add_de1_button "preheat_1 preheat_3 preheat_4 steam_1 steam_3 steam_zoom_3 water_1 water_3 water_4" {say [translate {espresso}] $::settings(sound_button_in); set_next_page off $::current_espresso_page; if {$::settings(one_tap_mode) == 1} { start_espresso }; page_show off;  } 1905 0 2560 188
#Steam
add_de1_button "off off_zoomed off_zoomed_temperature espresso espresso_1 espresso_1_zoomed espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature preheat_1 preheat_3 preheat_4 water_1 water_3 water_4" {say [translate {steam}] $::settings(sound_button_in); set_next_page off steam_1; page_show off; if {$::settings(one_tap_mode) == 1} { start_steam } } 1278 0 1904 188
#Water
add_de1_button "off off_zoomed off_zoomed_temperature espresso espresso_1 espresso_1_zoomed espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature preheat_1 preheat_3 preheat_4 steam_1 steam_3 steam_zoom_3" {say [translate {water}] $::settings(sound_button_in); set_next_page off water_1; page_show off; if {$::settings(one_tap_mode) == 1} { start_water } } 0 0 641 188

# when the espresso machine is doing something, the top tabs have to first stop that function, then the tab can change
#Pre-Heat
add_de1_button "steam steam_zoom water espresso espresso_3" {say [translate {pre-heat}] $::settings(sound_button_in);set_next_page off preheat_1; start_idle; if {$::settings(one_tap_mode) == 1} { set_next_page hotwaterrinse preheat_2; start_hot_water_rinse } } 642 0 1277 188
#Espresso
add_de1_button "preheat_2 steam steam_zoom water" {say [translate {espresso}] $::settings(sound_button_in);set ::current_espresso_page off; set_next_page $::current_espresso_page off; start_idle; if {$::settings(one_tap_mode) == 1} { start_espresso } } 1905 0 2560 188
#Steam
add_de1_button "preheat_2 water espresso espresso_3 steam steam_zoom" {say [translate {steam}] $::settings(sound_button_in);set_next_page off steam_1; start_idle; if {$::settings(one_tap_mode) == 1} { start_steam } } 1278 0 1904 188
#Water
add_de1_button "preheat_2 steam steam_zoom espresso espresso_3" {say [translate {water}] $::settings(sound_button_in);set_next_page off water_1; start_idle; if {$::settings(one_tap_mode) == 1} { start_water } } 0 0 641 188

################################################################################################################################################################################################################################################################################################
#button for steam no longer needed during zoomed view because of button reordering
#add_de1_button "espresso_zoomed espresso_zoomed_temperature" {say [translate {steam}] $::settings(sound_button_in); set_next_page off steam_1; page_show off; start_idle; if {$::settings(one_tap_mode) == 1} { start_steam } } 2020 0 2550 180
#add_de1_button "off_zoomed espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {steam}] $::settings(sound_button_in); set_next_page off steam_1; page_show off; if {$::settings(one_tap_mode) == 1} { start_steam } } 2020 0 2550 180
################################################################################################################################################################################################################################################################################################


################################################################################################################################################################################################################################################################################################
# espresso charts

set charts_width 1830

	
	# not yet ready to be used, still needs some work
	#set ::settings(display_pressure_delta_line) 0
	#set ::settings(display_flow_delta_line) 0

#######################
# 3 equal sized charts
# add_de1_widget "off espresso espresso_1 espresso_2 espresso_3" graph 22 267 { 
add_de1_widget "off espresso espresso_1 espresso_2 espresso_3" graph 22 267 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed; 
		set_next_page espresso espresso_zoomed; 
		set_next_page espresso_3 espresso_3_zoomed; 
		page_show $::de1(current_context);
	}
	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartpressuregoallinecol -smooth $::settings(profile_graph_smoothing_technique)  -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::chartpressurelinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create god_line_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodpressurecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color $::chartprofilestepcol  -pixels 0 ; 

	# show the explanation
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 0] -color #ffffff  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part1 -xdata espresso_de1_explanation_chart_elapsed_1 -ydata espresso_de1_explanation_chart_pressure_1 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartpressurelinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part2 -xdata espresso_de1_explanation_chart_elapsed_2 -ydata espresso_de1_explanation_chart_pressure_2 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartweightlinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part3 -xdata espresso_de1_explanation_chart_elapsed_3 -ydata espresso_de1_explanation_chart_pressure_3 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::charttemplinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 

	if {$::settings(display_pressure_delta_line) == 1} {
		$widget element create line_espresso_pressure_delta2  -xdata espresso_elapsed -ydata espresso_pressure_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #40dc94 -pixels 0 -smooth $::settings(profile_graph_smoothing_technique) 
	}

	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	$widget axis configure y -color $::chartaxiscol	-tickfont Helv_6 -min 0.0 -max [expr {$::de1(max_pressure) + 0.01}] -subdivisions 5 -majorticks {1 3 5 7 9 11} 
	
	# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
		$widget grid configure -color $::chartgridcol
	}
} -plotbackground $chartbackgroundcol -width [rescale_x_skin $charts_width] -height [rescale_y_skin 406] -borderwidth 1 -background $chartbackgroundcol -plotrelief flat 

#updated 22 273 to new coords to align axis

add_de1_widget "off espresso espresso_1 espresso_2 espresso_3" graph 42 723 {
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in);  
		set_next_page off off_zoomed; 
		set_next_page espresso espresso_zoomed;
		set_next_page espresso_3 espresso_3_zoomed;
		page_show $::de1(current_context);
	} 
	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartflowgoallinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0  -dashes {5 5}; 

	$widget element create line_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::chartflowlinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  


	if {$::settings(display_flow_delta_line) == 1} {
		$widget element create line_espresso_flow_delta  -xdata espresso_elapsed -ydata espresso_flow_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #98c5ff -pixels 0 -smooth $::settings(profile_graph_smoothing_technique) 
	}

	if {$::settings(scale_bluetooth_address) != ""} {
		$widget element create line_espresso_flow_weight  -xdata espresso_elapsed -ydata espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::chartweightlinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 
		$widget element create god_line_espresso_flow_weight  -xdata espresso_elapsed -ydata god_espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodweightcol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 
		
		if {$::settings(chart_total_shot_weight) == 2} {
			$widget element create line_espresso_weight  -xdata espresso_elapsed -ydata espresso_weight_chartable -symbol none -label "" -linewidth [rescale_x_skin 4] -color #a2693d -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);  
		}
		
	}
	$widget element create god_line_espresso_flow  -xdata espresso_elapsed -ydata god_espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodflowcol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color $::chartprofilestepcol  -pixels 0; 
	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6 ; 

	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -min 0.0 -max 8.01 -subdivisions 2 -majorticks {1 2 3 4 5 6 7 8}

	# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
	    $widget grid configure -color $::chartgridcol
	}

	# show the shot configuration
	$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 0] -color #ffffff  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part1 -xdata espresso_de1_explanation_chart_elapsed_flow_1 -ydata espresso_de1_explanation_chart_flow_1 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartpressurelinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part2 -xdata espresso_de1_explanation_chart_elapsed_flow_2 -ydata espresso_de1_explanation_chart_flow_2 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartweightlinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part3 -xdata espresso_de1_explanation_chart_elapsed_flow_3 -ydata espresso_de1_explanation_chart_flow_3 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::charttemplinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 

} -width [rescale_x_skin $charts_width] -height [rescale_y_skin 410]  -plotbackground $chartbackgroundcol -borderwidth 1 -background $chartbackgroundcol -plotrelief flat


add_de1_widget "off espresso espresso_1 espresso_2 espresso_3" graph 25 1170 {
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed_temperature; 
		set_next_page espresso espresso_zoomed_temperature; 
		set_next_page espresso_3 espresso_3_zoomed_temperature; 
		page_show $::de1(current_context);
	}

	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 6] -color $::charttempgoallinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 12] -color $::charttemplinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget element create god_line_espresso_temperature_basket -xdata espresso_elapsed -ydata god_espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 6] -color $::chartgodtempcol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color $::chartprofilestepcol  -pixels 0 ; 


	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6; 
	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -subdivisions 2;

	# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
		$widget grid configure -color $::chartgridcol
	}

	set ::temperature_chart_widget $widget
} -width [rescale_x_skin $charts_width] -height [rescale_y_skin 410]  -plotbackground $chartbackgroundcol -borderwidth 0 -background $chartbackgroundcol -plotrelief flat


####

add_de1_text "off_zoomed espresso_zoomed espresso_3_zoomed" 1820 220 -text [translate "Flow (mL/s)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "ne"
add_de1_text "off_zoomed espresso_zoomed espresso_3_zoomed" 40 220 -text [translate "Pressure (bar)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"
add_de1_text "off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" 40 220 -text [translate "Temperature ([return_html_temperature_units])"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"

add_de1_text "off espresso espresso_3" 40 220 -text [translate "Pressure (bar)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"

add_de1_text "off espresso espresso_3" 40 677 -text [translate "Flow (mL/s)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"
if {$::settings(scale_bluetooth_address) != ""} {
	#set distance [font_width "Flow (mL/s)" Helv_7_bold]
	add_de1_text "off espresso espresso_3" 1860 672 -text [translate "Weight (g/s)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "ne" 
	
	#set distance [font_width "Weight (g/s)" Helv_7_bold]
	add_de1_text "off_zoomed espresso_zoomed espresso_3_zoomed" 1600 220 -text [translate "Weight (g/s)"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "ne" 	
}

add_de1_text "off espresso espresso_3" 40 1122 -text [translate "Temperature ([return_html_temperature_units])"] -font Helv_7_bold -fill "#FFFFFF" -justify "left" -anchor "nw"




#######################
# zoomed espresso
# edit this 
add_de1_widget "off_zoomed espresso_zoomed espresso_3_zoomed" graph 20 300 {
	bind $widget [platform_button_press] { 
		#msg "100 = [rescale_y_skin 200] = %y = [rescale_y_skin 726]"
		set x [translate_coordinates_finger_down_x %x]
		set y [translate_coordinates_finger_down_y %y]

		if {$x < [rescale_y_skin 800]} {
			# left column clicked on chart, indicates zoom

			if {$y > [rescale_y_skin 726]} {
				if {$::swdark2_settings(sw_y_axisscale) < 14} {
					# 14 is the max Y axis allowed
					incr ::swdark2_settings(sw_y_axisscale) 2
					incr ::zoomed_y2_axis_scale
					save_swdark2_settings
				}
			} else {
				if {$::swdark2_settings(sw_y_axisscale) > 2} {
					incr ::swdark2_settings(sw_y_axisscale) -2
					incr ::zoomed_y2_axis_scale -1
					save_swdark2_settings
				}
			}
			%W axis configure y -max $::swdark2_settings(sw_y_axisscale)
			%W axis configure y2 -max $::zoomed_y2_axis_scale
			
		}  else {
			say [translate {zoom}] $::settings(sound_button_in); 
			set_next_page espresso_3 espresso_3; 
			set_next_page espresso_3_zoomed espresso_3; 
			set_next_page espresso espresso; 
			set_next_page espresso_zoomed espresso; 
			set_next_page off off; 
			set_next_page off_zoomed off; 
			page_show $::de1(current_context)
		}
	}

	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color $::chartpressuregoallinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::chartpressurelinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 

	if {$::settings(display_pressure_delta_line) == 1} {
		$widget element create line_espresso_pressure_delta_1  -xdata espresso_elapsed -ydata espresso_pressure_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #40dc94 -pixels 0 -smooth $::settings(profile_graph_smoothing_technique) 
	}

	$widget element create line_espresso_flow_goal_2x  -xdata espresso_elapsed -ydata espresso_flow_goal_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color $::chartflowgoallinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0  -dashes {5 5}; 
	$widget element create line_espresso_flow_2x  -xdata espresso_elapsed -ydata espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::chartflowlinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0  -dashes $::settings(chart_dashes_flow);   
	$widget element create god_line_espresso_flow_2x  -xdata espresso_elapsed -ydata god_espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodflowcol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 

	if {$::settings(display_flow_delta_line) == 1} {
		$widget element create line_espresso_flow_delta_1  -xdata espresso_elapsed -ydata espresso_flow_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #98c5ff -pixels 0 -smooth $::settings(profile_graph_smoothing_technique) 
	}

	if {$::settings(scale_bluetooth_address) != ""} {
		$widget element create line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color $::chartweightlinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 
		$widget element create god_line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata god_espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodweightcol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 

		if {$::settings(chart_total_shot_weight) == 1 || $::settings(chart_total_shot_weight) == 2} {
			$widget element create line_espresso_weight_2x  -xdata espresso_elapsed -ydata espresso_weight_chartable -symbol none -label "" -linewidth [rescale_x_skin 4] -color #a2693d -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);  
		}

	}

	$widget element create god_line2_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::chartgodpressurecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color $::chartprofilestepzoomcol -pixels 0 ; 

	$widget axis configure x -color #8b8b8b -tickfont Helv_7_bold; 
	$widget axis configure y -color #008c4c -tickfont Helv_7_bold -min 0.0 -max $::swdark2_settings(sw_y_axisscale) -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14}  -hide 0;
	$widget axis configure y2 -color #206ad4 -tickfont Helv_7_bold -min 0.0 -max $::zoomed_y2_axis_scale -subdivisions 2 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7} -hide 0;

	# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
		$widget grid configure -color $::chartgridcol
	}

	# show the explanation for pressure
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 0] -color #ffffff  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part1 -xdata espresso_de1_explanation_chart_elapsed_1 -ydata espresso_de1_explanation_chart_pressure_1 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartpressurelinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part2 -xdata espresso_de1_explanation_chart_elapsed_2 -ydata espresso_de1_explanation_chart_pressure_2 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::chartweightlinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part3 -xdata espresso_de1_explanation_chart_elapsed_3 -ydata espresso_de1_explanation_chart_pressure_3 -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::charttemplinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 

	# show the explanation for flow
	$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow_2x -symbol circle -label "" -linewidth [rescale_x_skin 0] -color #ffffff  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part1 -xdata espresso_de1_explanation_chart_elapsed_flow_1 -ydata espresso_de1_explanation_chart_flow_1_2x -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part2 -xdata espresso_de1_explanation_chart_elapsed_flow_2 -ydata espresso_de1_explanation_chart_flow_2_2x -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part3 -xdata espresso_de1_explanation_chart_elapsed_flow_3 -ydata espresso_de1_explanation_chart_flow_3_2x -symbol circle -label "" -linewidth [rescale_x_skin 12] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 15]; 


	#$widget axis configure y2 -color #206ad4 -tickfont Helv_6 -gridminor 0 -min 0.0 -max $::de1(max_flowrate) -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6} -hide 0; 
} -plotbackground $chartbackgroundcol -width [rescale_x_skin 1840] -height [rescale_y_skin 1200] -borderwidth 1 -background $chartbackgroundcol -plotrelief flat

#######################



#######################
# zoomed temperature
add_de1_widget "off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" graph 20 300 {
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page espresso_3 espresso_3; 
		set_next_page espresso_3_zoomed_temperature espresso_3; 
		set_next_page espresso espresso; 
		set_next_page espresso_zoomed_temperature espresso; 
		set_next_page off off; 
		set_next_page off_zoomed_temperature off; 
		page_show $::de1(current_context)
	} 
	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 6] -color $::charttempgoallinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color $::charttemplinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	$widget element create god_line_espresso_temperature_basket -xdata espresso_elapsed -ydata god_espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 6] -color $::chartgodtempcol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_4 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color $::chartprofilestepzoomcol -pixels 0 ; 
	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6; 
	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -subdivisions 5;

	# grid command not always available outside of Android, so catch it so that it doesn't break the app when running-non-android
	catch {
		$widget grid configure -color $::chartgridcol
	}
	
	set ::temperature_chart_zoomed_widget $widget
} -plotbackground $chartbackgroundcol -width [rescale_x_skin 1830] -height [rescale_y_skin 1200] -borderwidth 1 -background $chartbackgroundcol -plotrelief flat

proc update_temperature_charts_y_axis args {
	#puts "update_temperature_charts_y_axis $::settings(espresso_temperature)"
	if {[ifexists ::settings(settings_profile_type)] == "settings_2c"} {	
		set mintmp 100
		set maxtmp 0

		foreach step $::settings(advanced_shot) {
			unset -nocomplain props
			array set props $step

			if {$props(temperature) > $maxtmp} {
				set maxtmp $props(temperature)
			}
			if {$props(temperature) < $mintmp} {
				set mintmp $props(temperature)
			}
		}

		#puts "scaling chart for advanced shot $mintmp<x<$maxtmp"

		# in advanced shots, we might have temperature profiling, so set the temperature chart differently.

		$::temperature_chart_widget axis configure y -min [expr {[return_temperature_number $mintmp] - [return_temp_offset $::settings(espresso_chart_under)]}] -max [expr {[return_temperature_number $maxtmp] + [return_temp_offset $::settings(espresso_chart_over)] }]; 
		$::temperature_chart_zoomed_widget axis configure y -min [expr {[return_temperature_number $mintmp] - [return_temp_offset $::settings(espresso_chart_under)]}] -max [expr {[return_temperature_number $maxtmp] + [return_temp_offset $::settings(espresso_chart_over)] }]; 
	} else {
		$::temperature_chart_widget axis configure y -min [expr {[return_temperature_number $::settings(espresso_temperature)] - [return_temp_offset $::settings(espresso_chart_under)]}] -max [expr {[return_temperature_number $::settings(espresso_temperature)] + [return_temp_offset $::settings(espresso_chart_over)] }]; 
		$::temperature_chart_zoomed_widget axis configure y -min [expr {[return_temperature_number $::settings(espresso_temperature)] - [return_temp_offset $::settings(espresso_chart_under)]}] -max [expr {[return_temperature_number $::settings(espresso_temperature)] + [return_temp_offset $::settings(espresso_chart_over)] }]; 
	}
	#puts [stacktrace]
}
update_temperature_charts_y_axis

#trace add variable ::settings(espresso_temperature) write update_temperature_charts_y_axis
#trace add variable ::current_adv_step write update_temperature_charts_y_axis


#######################

# click anywhere on the chart to zoom pressure/flow.  This button is only to cover the parts that aren't overlaid by the charts, such as the text labels
add_de1_button "off espresso espresso_3" {
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed; 
		set_next_page espresso espresso_zoomed; 
		set_next_page espresso_3 espresso_3_zoomed; 
		page_show $::de1(current_context);
		set ::settings(zoomed_y_axis_scale) "12";
		set ::zoomed_y2_axis_scale "6";
} 40 210 1880 1110

# click anywhere on the chart to zoom pressure/flow.  This button is only to cover the parts that aren't overlaid by the charts, such as the text labels
add_de1_button "off espresso espresso_3" {
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed_temperature;
		set_next_page espresso espresso_zoomed_temperature;
		set_next_page espresso_3 espresso_3_zoomed_temperature;
		page_show $::de1(current_context);
} 40 210 1880 1110

add_de1_button "off_zoomed espresso_zoomed espresso_3_zoomed" {
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page espresso_3 espresso_3; 
		set_next_page espresso_3_zoomed espresso_3; 
		set_next_page espresso espresso; 
		set_next_page espresso_zoomed espresso; 
		set_next_page off off; 
		set_next_page off_zoomed off; 
		page_show $::de1(current_context);
} 40 210 1880 1110

add_de1_button "off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" {
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page espresso_3 espresso_3; 
		set_next_page espresso_3_zoomed_temperature espresso_3; 
		set_next_page espresso espresso; 
		set_next_page espresso_zoomed_temperature espresso; 
		set_next_page off off; 
		set_next_page off_zoomed_temperature off; 
		page_show $::de1(current_context);
} 40 1115 1880 1560


# the "go to sleep" button and the whole-screen button for coming back awake
add_de1_button "saver descaling cleaning" {say [translate {awake}] $::settings(sound_button_in); set_next_page off off; start_idle} 0 0 2560 1600

if {$::debugging == 1} {
	#add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4 off_zoomed espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {sleep}] $::settings(sound_button_in); app_exit} 2014 1420 2284 1600
	add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 steam_zoom_3 water_1 water_3 water_4 off_zoomed espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {sleep}] $::settings(sound_button_in); set ::current_espresso_page "off"; start_sleep} 1919 1430 2219 1580
} else {
	add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 steam_zoom_3 water_1 water_3 water_4 off_zoomed espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {sleep}] $::settings(sound_button_in); set ::current_espresso_page "off"; start_sleep} 1919 1430 2219 1580
}
#add_de1_text "sleep" 2500 1440 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_10_bold -fill "#DDDDDD" 

# settings button 
add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed steam_1 water_1 preheat_1 steam_3 steam_zoom_3 water_3 preheat_3 preheat_4 off_zoomed_temperature espresso_3_zoomed_temperature" { say [translate {settings}] $::settings(sound_button_in); show_settings } 2239 1430 2539 1580 

add_de1_variable "off off_zoomed off_zoomed_temperature" 2225 455 -text [translate "START"] -font $green_button_font -fill "#FFFFFF" -anchor "center" -textvariable {[start_text_if_espresso_ready]} 
add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" 2225 455 -text [translate "STOP"] -font $green_button_font -fill "#FFFFFF" -anchor "center" -textvariable {[stop_text_if_espresso_stoppable]} 
add_de1_variable "espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" 2225 455 -text [translate "RESTART"] -font $green_button_font -fill "#FFFFFF" -anchor "center" -textvariable {[espresso_history_save_from_gui]} 

add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed espresso espresso_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" 2225 525 -text [translate "ESPRESSO"] -font Helv_10 -fill "#9f9f9f" -anchor "center" 
add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" 2225 575 -text "" -font Helv_7 -fill "#999999" -anchor "center" -textvariable {[de1_substate_text]} 

# indicate whether we are connected to the DE1+ or not
add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" 2225 620 -justify center -anchor "center" -text "" -font Helv_6 -fill "#CCCCCC" -width 520 -textvariable {[de1_connected_state]} 


add_de1_widget "steam" graph 50 640 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam_zoom; 
		set_next_page steam steam_zoom; 
		page_show $::de1(current_context);
	}
	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color #86C240  -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 6] -color #43B1E3  -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 6] -color #FF2600 -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color #ffffff -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	$widget axis configure y -color #ffffff -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {1 2 3} 
} -plotbackground #242424 -width [rescale_x_skin 1658] -height [rescale_y_skin 877] -borderwidth 1 -background #242424 -plotrelief flat 

add_de1_widget "steam_3" graph 50 640 { 
	bind $widget [platform_button_press] { 
		say [translate {stop}] $::settings(sound_button_in); 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam_zoom_3; 
		set_next_page steam_3 steam_zoom_3; 
		page_show $::de1(current_context);
	}
	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color #86C240  -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 6] -color #43B1E3  -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 6] -color #FF2600 -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);   

	$widget axis configure x -color #ffffff -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	$widget axis configure y -color #ffffff -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {1 2 3} 
} -plotbackground $chartbackgroundcol -width [rescale_x_skin 1658] -height [rescale_y_skin 877] -borderwidth 1 -background $chartbackgroundcol -plotrelief flat 


add_de1_widget "steam_zoom_3" graph 20 300 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam_3; 
		#set_next_page steam_zoom_3 steam_3; 
		set_next_page steam steam; 
		set_next_page steam_zoom_3 steam_3; 
		page_show $::de1(current_context);
	}
	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::chartpressurelinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::chartflowlinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color $::charttemplinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3}  -title "[translate "Flow rate"] - [translate "Temperature"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #8b8b8b;
} -plotbackground $chartbackgroundcol -width [rescale_x_skin 1840] -height [rescale_y_skin 1200] -borderwidth 1 -background $chartbackgroundcol -plotrelief flat 

add_de1_widget "steam_zoom" graph 20 300 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam; 
		#set_next_page steam_zoom_3 steam_3; 
		set_next_page steam steam; 
		set_next_page steam_zoom steam; 
		page_show $::de1(current_context);
	}
	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::chartpressurelinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::chartflowlinecol  -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color $::charttemplinecol -smooth $::settings(profile_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color $::chartaxiscol -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	$widget axis configure y -color $::chartaxiscol -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3}  -title "[translate "Flow rate"] - [translate "Temperature"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #8b8b8b;
} -plotbackground $chartbackgroundcol -width [rescale_x_skin 1840] -height [rescale_y_skin 1200] -borderwidth 1 -background $chartbackgroundcol -plotrelief flat 


##########################################################################################################################################################################################################################################################################
# data card displayed during espresso making

set pos_top_orig 841
set pos_top 975
set spacer 38
#set paragraph 20

set column2 2069
if {$::settings(enable_fahrenheit) == 1} {
	set column2 2084
}

set dark "#8b8b8b"
set lighter "#9f9f9f"
set lightest "#d5d5d5"
set column1_pos 1950
set column3_pos 2374


if {$::settings(waterlevel_indicator_on) == 1} {
	# water level sensor on espresso page
#	add_de1_widget "off espresso espresso_3 off_zoomed espresso_zoomed espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" scale 2528 694 {after 1000 water_level_color_check $widget} -from 40 -to 5 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 594] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor #ffffff -borderwidth 0  -highlightthickness 0
	add_de1_widget "off espresso espresso_3 off_zoomed espresso_zoomed espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" scale 2544 190 {after 1000 water_level_color_check $widget} -from $::settings(water_level_sensor_max) -to 5 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1410] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor $chartbackgroundcol -borderwidth 0  -highlightthickness 0

	# water level sensor on other tabs page (white background)
	add_de1_widget "preheat_2 preheat_3 preheat_4 steam steam_3 steam_zoom steam_zoom_3 water water_3 water_4" scale 2544 226 {after 1000 water_level_color_check $widget} -from $::settings(water_level_sensor_max) -to 5 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1166] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor $chartbackgroundcol -borderwidth 0  -highlightthickness 0

	# water level sensor on other tabs page (light blue background)
	add_de1_widget "preheat_1 steam_1 water_1" scale 2544 226 {after 1000 water_level_color_check $widget} -from $::settings(water_level_sensor_max) -to 5 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 1166] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor $chartbackgroundcol -borderwidth 0  -highlightthickness 0
}


add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "nw" -text [translate "Time"] -font Helv_7_bold -fill $::detailtextheadingcol -width [rescale_x_skin 520]
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[espresso_preinfusion_timer][translate "s"] [translate "preinfusion"]} 
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[espresso_pour_timer][translate "s"] [translate "pouring"]} 
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (3 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[espresso_elapsed_timer][translate "s"] [translate "total"]} 
	add_de1_variable "espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (4 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[if {[espresso_done_timer] < $::settings(seconds_to_display_done_espresso)} {return "[espresso_done_timer][translate s] [translate done]"} else { return ""}]} 
	
	
add_de1_text "espresso espresso_zoomed" $column1_pos [expr {$pos_top_orig + (0 * $spacer)}] -justify right -anchor "nw" -text [translate "Time"] -font Helv_7_bold -fill $::detailtextheadingcol -width [rescale_x_skin 520]
	add_de1_variable "espresso espresso_zoomed" $column1_pos [expr {$pos_top_orig + (1 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[espresso_preinfusion_timer][translate "s"] [translate "preinfusion"]} 
	add_de1_variable "espresso espresso_zoomed" $column1_pos [expr {$pos_top_orig + (2 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[espresso_pour_timer][translate "s"] [translate "pouring"]} 
	add_de1_variable "espresso espresso_zoomed" $column1_pos [expr {$pos_top_orig + (3 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[espresso_elapsed_timer][translate "s"] [translate "total"]} 

# temporarily disabled, because these use a different measurement technique than the DE1+ does, so they'll always be off
#add_de1_text "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "ne" -text [translate "Volume"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]
#	add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7  -fill $lighter -width [rescale_x_skin 520] -textvariable {[preinfusion_volume]} 
#	add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7  -fill $lighter -width [rescale_x_skin 520] -textvariable {[pour_volume]} 
#	add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (3 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 


#######################
# temperature
add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (5 * $spacer)}] -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top_orig + (5 * $spacer)}] -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
	add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column2 [expr {$pos_top_orig + (6 * $spacer)}] -justify right -anchor "nw" -text [translate "goal"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column2 [expr {$pos_top + (6 * $spacer)}] -justify right -anchor "nw" -text [translate "goal"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top_orig + (6 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[espresso_goal_temp_text]} 
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (6 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[espresso_goal_temp_text]} 

	add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column2 [expr {$pos_top + (7 * $spacer)}] -justify right -anchor "nw" -text [translate "metal"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature"  $column1_pos [expr {$pos_top + (7 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[group_head_heater_temperature_text]} 

	if {$::settings(display_group_head_delta_number) == 1} {
		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" 2380 [expr {$pos_top + (7 * $spacer)}] -justify left -anchor "ne" -font Helv_7 -fill $lightest -width [rescale_x_skin 520] -textvariable {[return_delta_temperature_measurement [diff_group_temp_from_goal]]} 
	}

	add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column2 [expr {$pos_top_orig + (7 * $spacer)}] -justify right -anchor "nw" -text [translate "coffee"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top_orig + (7 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[watertemp_text]} 
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top_orig + (7 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7 -fill $lightest -width [rescale_x_skin 520] -textvariable {[return_delta_temperature_measurement [diff_espresso_temp_from_goal]]} 

	add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column2 [expr {$pos_top_orig + (8 * $spacer)}] -justify right -anchor "nw" -text [translate "water"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top_orig + (8 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[mixtemp_text]} 
	
	if {$::settings(display_espresso_water_delta_number) == 1} {
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top_orig + (8 * $spacer)}] -justify left -anchor "ne" -font Helv_7 -fill $lightest -width [rescale_x_skin 520] -textvariable {[return_delta_temperature_measurement [diff_brew_temp_from_goal] ]} 
		# thermometer widget from http://core.tcl.tk/bwidget/doc/bwidget/BWman/index.html
	    add_de1_widget "espresso espresso_zoomed espresso_zoomed_temperature" ProgressBar 2390 [expr {$pos_top_orig + (8.5 * $spacer)}] {} -width [rescale_y_skin 108] -height [rescale_x_skin 16] -type normal  -variable ::positive_diff_brew_temp_from_goal -fg #ff8888 -bg #FFFFFF -maximum 10 -borderwidth 1 -relief flat
	}
#######################
	#add_de1_widget "off espresso espresso_3 off_zoomed espresso_zoomed espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" scale 2528 694 {after 1000 water_level_color_check $widget} -from 40 -to 5 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 594] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor #ffffff -borderwidth 0  -highlightthickness 0



#######################
# flow 
add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top_orig + (10.5 * $spacer)}] -justify right -anchor "nw" -text [translate "Flow"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
	#add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[watervolume_text] [translate "total"]} 
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top_orig + (11.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top_orig + (12.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[pressure_text]} 
#######################

#######################
# weight
add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (5 * $spacer)}] -justify right -anchor "ne" -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520] -textvariable {[waterweight_label_text]}
add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top_orig + (10.5 * $spacer)}] -justify right -anchor "ne" -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520] -textvariable {[waterweight_label_text]}
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (6 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[drink_weight_text]} 
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top_orig + (11.5 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[waterweight_text]} 
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top_orig + (12.5 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[waterweightflow_text]} 

#Set the target weight depending on Profile Type

	if {$::settings(scale_bluetooth_address) != ""} {
		set ::de1(scale_weight_rate) -1		
		add_de1_widget "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" ProgressBar 2390 [expr {$pos_top + (6.5 * $spacer)}] {} -width [rescale_y_skin 108] -height [rescale_x_skin 16] -type normal  -variable ::de1(scale_weight_rate) -fg #FF6A00 -bg #4e4e4e -maximum 6 -borderwidth 1 -relief flat
		add_de1_widget "espresso espresso_zoomed espresso_zoomed_temperature" ProgressBar 2390 [expr {$pos_top_orig + (13 * $spacer)}] {} -width [rescale_y_skin 108] -height [rescale_x_skin 16] -type normal  -variable ::de1(scale_weight_rate) -fg #FF6A00 -bg #4e4e4e -maximum 6 -borderwidth 1 -relief flat
		#scale Tare Button
        add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {connect}] $::settings(sound_button_in); scale_tare; catch {ble_connect_to_scale}} 2132 805 2325 945
		#scale Display Toggle
		add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {switch}] $::settings(sound_button_in); scale_display_toggle; set_next_page off off; start_idle} 2345 805 2538.5 945
		# scale ble reconnection button
		add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {connect}] $::settings(sound_button_in); catch {ble_connect_to_scale}} 1918 805 2111.5 945
		#Stop at weight value
		add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "ne" -text [translate "Target"] -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520]
		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (1 * $spacer)}] -justify right -anchor "ne" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {$::stopatweight}
	}


#		add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {connect}] $::settings(sound_button_in); catch {ble_connect_to_scale}} 1919 1270 2059 1410





#######################

#######################
# profile name 
if {$::settings(insight_skin_show_embedded_profile) == 1} {
	# not yet complete implementation of idea of showing the espresso shot profile on the Insight skin's ESPRESSO tab
	# what is not yet finished is that this is only showing the pressure profile, and instead this needs to show
	# a flow profile if that's selected, or nothing is displayed if this is an advanced profile
	add_de1_widget "off espresso_3" graph 2030 1080 { 
		update_de1_explanation_chart;
		$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 2] -color #888888  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 10]; 
		$widget axis configure x -color #8b8b8b -tickfont Helv_6 
		#-command graph_seconds_axis_format; 
		$widget axis configure y -color #8b8b8b -tickfont Helv_6 -min 0.0 -max [expr {0.1 + $::de1(maxpressure)}] -stepsize 4 -majorticks {4 8} -title "" -titlefont Helv_10 -titlecolor #8b8b8b;

		$widget element create line_espresso_de1_explanation_chart_pressure_part1 -xdata espresso_de1_explanation_chart_elapsed_1 -ydata espresso_de1_explanation_chart_pressure_1 -symbol circle -label "" -linewidth [rescale_x_skin 16] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 10]; 
		$widget element create line_espresso_de1_explanation_chart_pressure_part2 -xdata espresso_de1_explanation_chart_elapsed_2 -ydata espresso_de1_explanation_chart_pressure_2 -symbol circle -label "" -linewidth [rescale_x_skin 16] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 10]; 
		$widget element create line_espresso_de1_explanation_chart_pressure_part3 -xdata espresso_de1_explanation_chart_elapsed_3 -ydata espresso_de1_explanation_chart_pressure_3 -symbol circle -label "" -linewidth [rescale_x_skin 16] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 10]; 

		bind $widget [platform_button_press] { 
			show_settings $::settings(settings_profile_type)
		} 
	} -plotbackground $chartbackgroundcol -width [rescale_x_skin 430] -height [rescale_y_skin 200] -borderwidth 1 -background $chartbackgroundcol -plotrelief raised
} else {
	# we can display the profile name if the embedded chart is not displayed.
	add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (8.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520] -textvariable {[profile_type_text]} 
	add_de1_variable "espresso espresso_zoomed" $column1_pos [expr {$pos_top_orig + (15 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7_bold -fill #ffffff -width [rescale_x_skin 520] -textvariable {[profile_type_text]} 
	

	set ::globals(widget_current_profile_name) [add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (9.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 730] -textvariable {$::settings(profile_title)} ]
	

	set ::globals(widget_current_profile_name_espresso) [add_de1_variable "espresso espresso_zoomed" $column1_pos [expr {$pos_top_orig + (16 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 730] -textvariable {$::settings(profile_title)} ]
	
	#hard coded location versus varibales of  $column1_pos [expr {$pos_top + (15.5 * $spacer)}]

	# current frame description, not yet implemented
	 add_de1_variable "espresso espresso_zoomed" 1950 1487 -justify left -anchor "nw" -text "" -font Helv_7 -fill $::detailtextcol -width [rescale_x_skin 5730] -textvariable {$::settings(current_frame_description)} 


	#add_de1_variable "espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (9 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7_bold -fill $dark -width [rescale_x_skin 520] -textvariable {[profile_type_text]} 
		#add_de1_variable "espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (10 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 470] -textvariable {$::settings(profile)} 
}
#######################


# this feature is always on now
set ::settings(display_rate_espresso) 1
if {$::settings(display_rate_espresso) == 1} {
	add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {describe}] $::settings(sound_button_in); unset -nocomplain ::settings_backup; array set ::settings_backup [array get ::settings]; set_next_page off describe_espresso0; page_show off; set_god_shot_scrollbar_dimensions; } 2443 990 2529 1076
	source "[homedir]/skins/Insight/scentone.tcl"
}


##########################################################################################################################################################################################################################################################################


##########################################################################################################################################################################################################################################################################
# making espresso now

# make and stop espresso button
add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {espresso}] $::settings(sound_button_in);set ::current_espresso_page espresso_3; set_next_page off espresso_3; start_espresso} 1929 190 2529 790
add_de1_button "espresso" {say [translate {stop}] $::settings(sound_button_in);set_next_page off espresso_3; start_idle;} 1929 190 2529 790
add_de1_button "espresso_zoomed" {say [translate {stop}] $::settings(sound_button_in); set_next_page off espresso_3_zoomed; start_idle;} 1929 190 2529 790
add_de1_button "espresso_zoomed_temperature" {say [translate {stop}] $::settings(sound_button_in); set_next_page off espresso_3_zoomed_temperature; start_idle;} 1929 190 2529 790

##########################################################################################################################################################################################################################################################################


##########################################################################################################################################################################################################################################################################
# settings for preheating a cup or flushing

add_de1_variable "preheat_1" 2225 455 -text [translate "START"] -font $green_button_font -fill "#FFFFFF" -anchor "center" -textvariable {[start_text_if_espresso_ready]} 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 2225 525 -text [translate "FLUSH"] -font Helv_10 -fill "#9f9f9f" -anchor "center" 
add_de1_variable "preheat_2" 2225 455 -text [translate "STOP"] -font $green_button_font -fill "#FFFFFF" -anchor "center"  -textvariable {[stop_text_if_espresso_stoppable]} 
add_de1_variable "preheat_3 preheat_4" 2225 455 -text [translate "RESTART"] -font $green_button_font -fill "#FFFFFF" -anchor "center" -textvariable {[restart_text_if_espresso_ready]} 

#1030 210 1800 1400
add_de1_button "preheat_1 preheat_3 preheat_4" {say [translate {pre-heat cup}] $::settings(sound_button_in); set ::settings(preheat_temperature) 90; set_next_page hotwaterrinse preheat_2; start_hot_water_rinse} 1929 190 2529 790
add_de1_button "preheat_2" {say [translate {stop}] $::settings(sound_button_in); set_next_page off preheat_4; start_idle} 1929 190 2529 790


set preheat_water_volume_feature_enabled 0
if {$preheat_water_volume_feature_enabled == 1} {
	add_de1_button "preheat_3 preheat_4" {say "" $::settings(sound_button_in); set_next_page off preheat_1; start_idle} 1929 190 2529 790
	add_de1_button "preheat_1" {say "" $::settings(sound_button_in);vertical_clicker 50 10 ::settings(preheat_volume) 10 250 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings} 1929 190 2529 790 ""
	add_de1_text "preheat_1" 70 250 -text [translate "1) How much water?"] -font Helv_9 -fill "#8b8b8b" -anchor "nw" -width [rescale_x_skin 900]
	add_de1_text "preheat_2 preheat_3 preheat_4" 70 250 -text [translate "1) How much water?"] -font Helv_9 -fill "#9f9f9f" -anchor "nw" -width [rescale_x_skin 900]
}
#############################
#disabled these additional decriptors during espresso pouring for elegance

#add_de1_text "preheat_1" 1070 250 -text [translate "1) Hot water will pour out"] -font Helv_9 -fill "#8b8b8b" -anchor "nw" -width [rescale_x_skin 650]
#add_de1_text "preheat_2" 1070 250 -text [translate "1) Hot water is pouring out"] -font Helv_9 -fill "#8b8b8b" -anchor "nw" -width [rescale_x_skin 650]
#add_de1_text "preheat_3 preheat_4" 1070 250 -text [translate "1) Hot water will pour out"] -font Helv_9 -fill "#9f9f9f" -anchor "nw" -width [rescale_x_skin 650]

#add_de1_text "preheat_1" 1840 250 -text [translate "2) Done"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 680]
#add_de1_text "preheat_3 preheat_4" 1840 250 -text [translate "2) Done"] -font Helv_9 -fill "#8b8b8b" -anchor "nw" -width [rescale_x_skin 680]
#############################


if {$preheat_water_volume_feature_enabled == 1} {
	add_de1_variable "preheat_1" 540 1250 -text "" -font Helv_10_bold -fill "#000000" -anchor "center" -textvariable {[return_liquid_measurement $::settings(preheat_volume)]}
	add_de1_variable "preheat_2 preheat_3 preheat_4" 540 1250 -text "" -font Helv_10_bold -fill "#9f9f9f" -anchor "center" -textvariable {[return_liquid_measurement $::settings(preheat_volume)]}
	add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 540 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#9f9f9f" -anchor "center" 

	# feature disabled until flowmeter reporting over BLE is implemented
	#add_de1_text "preheat_2" 1880 1300 -justify right -anchor "nw" -text [translate "Total volume"] -font Helv_8 -fill "#9f9f9f" -width [rescale_x_skin 520]
	#add_de1_variable "preheat_2" 2470 1300 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 
}

#add_de1_text "preheat_2 preheat_4" 1870 1200 -justify right -anchor "nw" -text [translate "Information"] -font Helv_8_bold -fill "#8b8b8b" -width [rescale_x_skin 520]

#add_de1_text "preheat_2" 1870 1250 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#8b8b8b" -width [rescale_x_skin 520]
#add_de1_text "preheat_4" 1870 1200 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#8b8b8b" -width [rescale_x_skin 520]
add_de1_variable "preheat_3 preheat_4" 1950 841 -justify right -anchor "nw" -text [translate "Done"] -font Helv_8 -fill $::detailtextheadingcol -width [rescale_x_skin 520] -textvariable {[if {[flush_done_timer] < $::settings(seconds_to_display_done_flush)} {return [translate Done]} else { return ""}]} 
add_de1_variable "preheat_3 preheat_4" 2480 841 -justify left -anchor "ne" -font Helv_8 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[if {[flush_done_timer] < $::settings(seconds_to_display_done_flush)} {return "[flush_done_timer][translate s]"} else { return ""}]} 

#add_de1_text "preheat_2"  1870 1250 -justify right -anchor "nw" -text [translate "Metal temperature"] -font Helv_8 -fill  "#9f9f9f"  -width [rescale_x_skin 520]
#add_de1_variable "preheat_2"  2470 1250  -justify left -anchor "ne" -font Helv_8 -fill  "#42465c"  -width [rescale_x_skin 520] -textvariable {[group_head_heater_temperature_text]} 
#add_de1_text "preheat_4"  1870 1200 -justify right -anchor "nw" -text [translate "Metal temperature"] -font Helv_8 -fill  "#9f9f9f"  -width [rescale_x_skin 520]
#add_de1_variable "preheat_4"  2470 1200  -justify left -anchor "ne" -font Helv_8 -fill  "#42465c"  -width [rescale_x_skin 520] -textvariable {[group_head_heater_temperature_text]} 

add_de1_text "preheat_2" 1950 841 -justify right -anchor "nw" -text [translate "Water temperature"] -font Helv_8 -fill $::detailtextheadingcol -width [rescale_x_skin 520]
add_de1_variable "preheat_2" 2480 841 -justify left -anchor "ne" -font Helv_8 -fill $::detailtextcol -width [rescale_x_skin 520] -text "" -textvariable {[watertemp_text]} 


add_de1_text "preheat_2 preheat_4" 1950 881 -justify right -anchor "nw" -text [translate "Pouring"] -font Helv_8 -fill $::detailtextheadingcol -width [rescale_x_skin 520]
add_de1_variable "preheat_2 preheat_4" 2480 881 -justify left -anchor "ne" -font Helv_8 -fill $::detailtextcol -width [rescale_x_skin 520] -text "" -textvariable {[flush_pour_timer][translate "s"]} 

#add_de1_text "preheat_4" 1870 1250 -justify right -anchor "nw" -text [translate "Pouring"] -font Helv_8 -fill "#9f9f9f" -width [rescale_x_skin 520]
#add_de1_variable "preheat_4" 2470 1250 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[flush_pour_timer][translate "s"]} 

# feature disabled until flowmeter reporting over BLE is implemented
#add_de1_text "preheat_3" 1880 1250 -justify right -anchor "nw" -text [translate "Total volume"] -font Helv_8 -fill "#9f9f9f" -width [rescale_x_skin 520]
#add_de1_variable "preheat_3" 2470 1250 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 

##########################################################################################################################################################################################################################################################################

##########################################################################################################################################################################################################################################################################
# settings for dispensing hot water

# future feature
# add_de1_text "water_1 water_3" 1390 1270 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 

add_de1_variable "water_1" 2225 455 -text [translate "START"] -font $green_button_font -fill "#FFFFFF" -anchor "center" -textvariable {[start_text_if_espresso_ready]} 
add_de1_variable "water_3" 2225 455 -text [translate "RESTART"] -font $green_button_font -fill "#FFFFFF" -anchor "center" -textvariable {[restart_text_if_espresso_ready]} 
add_de1_variable "water" 2225 455 -text [translate "STOP"] -font $green_button_font -fill "#FFFFFF" -anchor "center"  -textvariable {[stop_text_if_espresso_stoppable]} 

add_de1_text "water_1 water water_3" 2225 525 -text [translate "WATER"] -font Helv_10 -fill "#9f9f9f" -anchor "center" 
add_de1_button "water_1 water_3" {say [translate {Hot water}] $::settings(sound_button_in); set_next_page water water; start_water} 1929 190 2529 790
add_de1_button "water" {say [translate {stop}] $::settings(sound_button_in); set_next_page off water_1 ; start_idle} 1929 190 2529 790

# future feature
#add_de1_button "water_1 water_3" {say [translate {rinse}] $::settings(sound_button_in); set_next_page water water; start_water} 1030 1101 1760 1400

#
add_de1_button "water_1" {say "" $::settings(sound_button_in);horizontal_clicker 10 10 ::settings(water_volume) 10 250 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings} 650 584 1270 750 ""
add_de1_button "water_1" {say "" $::settings(sound_button_in);horizontal_clicker 10 10 ::settings(water_temperature) 60 100 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings} 650 947 1270 1113 ""

add_de1_button "water_1" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 ::settings(water_volume) 10 250 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings} 750 584 1168 750 ""
add_de1_button "water_1" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 ::settings(water_temperature) 60 100 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings} 750 947 1168 1113 ""

#add_de1_button "water_1" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 ::settings(water_volume) 10 250 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings} 739 479 1199 579 ""
#add_de1_button "water_1" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 ::settings(water_temperature) 60 100 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings} 739 665 1199 765 ""

#add_de1_button "water_1" {say "" $::settings(sound_button_in);vertical_slider ::settings(water_volume) 1 400 %x %y %x0 %y0 %x1 %y1} 0 210 550 1400 "mousemove"
#add_de1_button "water_1" {say "" $::settings(sound_button_in);vertical_slider ::settings(water_temperature) 20 96 %x %y %x0 %y0 %x1 %y1} 551 210 1029 1400 "mousemove"

#add_de1_text "water_1" 70 250 -text [translate "1) Settings"] -font Helv_10 -fill "#8b8b8b" -anchor "nw" -width 900

#add_de1_text "water_1" 1070 250 -text [translate "2) Hot water will pour"] -font Helv_9 -fill "#8b8b8b" -anchor "nw" -width [rescale_x_skin 650]
#add_de1_text "water" 1070 250 -text [translate "2) Hot water is pouring"] -font Helv_9 -fill "#8b8b8b" -anchor "nw" -width [rescale_x_skin 650]
#add_de1_text "water_3" 1840 250 -text [translate "3) Done"] -font Helv_9 -fill "#8b8b8b" -anchor "nw" -width [rescale_x_skin 650]


#add_de1_text "water water_3" 70 250 -text [translate "1) Settings"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 900]
#add_de1_text "water_3" 1070 250 -text [translate "2) Hot water will pour"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 650]

add_de1_variable "water_1" 959.735 666 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[return_liquid_measurement $::settings(water_volume)]}
#add_de1_text "water_1" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#9f9f9f" -anchor "center" 
add_de1_variable "water_1" 959.735 1030 -text "" -font Helv_10_bold -fill "#000000" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}
#add_de1_text "water_1" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill "#9f9f9f" -anchor "center" 

add_de1_variable "water water_3" 959.735 666 -text "" -font Helv_10_bold -fill "#9f9f9f" -anchor "center"  -textvariable {[return_liquid_measurement $::settings(water_volume)]}
#add_de1_text "water water_3" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 
add_de1_variable "water water_3" 959.735 1030 -text "" -font Helv_10_bold -fill "#9f9f9f" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}
#add_de1_text "water water_3" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 

#restart button?  do you need this?
#add_de1_button "water_3" {say "" $::settings(sound_button_in); set_next_page off water_1; start_idle} 1929 190 2529 790

# data card
#add_de1_text "water" 1870 1250 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#8b8b8b" -width [rescale_x_skin 520]
#add_de1_text "water_3" 1870 1200 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#8b8b8b" -width [rescale_x_skin 520]
add_de1_text "water water_3" 1950 841 -justify right -anchor "nw" -text [translate "Pouring"] -font Helv_8 -fill $::detailtextheadingcol -width [rescale_x_skin 520]
add_de1_variable "water water_3" 2480 841 -justify left -anchor "ne" -font Helv_8 -fill $::detailtextcol -width [rescale_x_skin 520] -text "" -textvariable {[water_pour_timer][translate "s"]} 

#add_de1_text "water_3" 1870 1250 -justify right -anchor "nw" -text [translate "Pouring"] -font Helv_8 -fill "#9f9f9f" -width [rescale_x_skin 520]
#add_de1_variable "water_3" 2470 1250 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[water_pour_timer][translate "s"]} 


add_de1_variable "water_3" 1950 881 -justify right -anchor "nw" -text [translate "Done"] -font Helv_8 -fill $::detailtextheadingcol -width [rescale_x_skin 520] -textvariable {[if {[water_done_timer] < $::settings(seconds_to_display_done_hotwater)} {return [translate Done]} else { return ""}]} 
add_de1_variable "water_3" 2480 881 -justify left -anchor "ne" -font Helv_8 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[if {[water_done_timer] < $::settings(seconds_to_display_done_hotwater)} {return "[water_done_timer][translate s]"} else { return ""}]} 


# current water temperature - not getting this via BLE at the moment 1/4/19 so do not display in the UI
	#add_de1_text "water" 1870 300 -justify right -anchor "nw" -text [translate "Water temperature"] -font Helv_8 -fill "#9f9f9f" -width [rescale_x_skin 520]
	#add_de1_variable "water" 2470 300 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[watertemp_text]} 
	#add_de1_text "water_3" 1870 350 -justify right -anchor "nw" -text [translate "Information"] -font Helv_8_bold -fill "#8b8b8b" -width [rescale_x_skin 520]
	#add_de1_text "water_3" 1870 400 -justify right -anchor "nw" -text [translate "Water temperature"] -font Helv_8 -fill "#9f9f9f" -width [rescale_x_skin 520]
	#add_de1_variable "water_3" 2470 400 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[watertemp_text]} 
	#add_de1_text "water" 1870 250 -justify right -anchor "nw" -text [translate "Information"] -font Helv_8_bold -fill "#8b8b8b" -width [rescale_x_skin 520]

add_de1_text "water " 1950 881 -justify right -anchor "nw" -text [translate "Flow rate"] -font Helv_8 -fill $::detailtextheadingcol -width [rescale_x_skin 520]
add_de1_variable "water" 2481 881 -justify left -anchor "ne" -text "" -font Helv_8 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 

# feature disabled until flowmeter reporting over BLE is implemented
	#add_de1_text "water " 1870 350 -justify right -anchor "nw" -text [translate "Total volume"] -font Helv_8 -fill "#9f9f9f" -width [rescale_x_skin 520]
	#add_de1_variable "water" 2470 350 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 


# feature disabled until flowmeter reporting over BLE is implemented
	#add_de1_text "water_3" 1870 450 -justify right -anchor "nw" -text [translate "Total volume"] -font Helv_8 -fill "#9f9f9f" -width [rescale_x_skin 520]
	#add_de1_variable "water_3" 2470 450 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 




##########################################################################################################################################################################################################################################################################



##########################################################################################################################################################################################################################################################################
# settings for steam

# future feature
#add_de1_text "steam_1 steam_3" 1390 1270 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 

#add_de1_text "steam_3" 2180 1280 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 

add_de1_variable "steam_1" 2225 455 -text [translate "START"] -font $green_button_font -fill "#FFFFFF" -anchor "center" -textvariable {[start_text_if_espresso_ready]} 
add_de1_variable "steam" 2225 455 -text [translate "STOP"] -font $green_button_font -fill "#FFFFFF" -anchor "center"  -textvariable {[stop_text_if_espresso_stoppable]} 
add_de1_variable "steam_3" 2225 455 -text [translate "RESTART"] -font $green_button_font -fill "#FFFFFF" -anchor "center" -textvariable {[restart_text_if_espresso_ready]} 

add_de1_text "steam_1 steam steam_3" 2225 525 -text [translate "STEAM"] -font Helv_10 -fill "#9f9f9f" -anchor "center" 

add_de1_button "steam_1" {say [translate {steam}] $::settings(sound_button_in); set_next_page steam steam; start_steam} 1929 190 2529 790
add_de1_button "steam_3" {say [translate {steam}] $::settings(sound_button_in); set_next_page steam steam; start_steam} 1929 190 2529 790

# future feature
#add_de1_button "steam_1" {say [translate {rinse}] $::settings(sound_button_in); start_steam} 1030 1101 1760 1400

add_de1_button "steam" {say [translate {stop}] $::settings(sound_button_in); set_next_page off steam_3; start_idle} 0 189 2560 1600
#add_de1_button "steam_3" {say "" $::settings(sound_button_in); set_next_page off steam_1; start_idle} 0 210 1000 1400
add_de1_button "steam_1" {say "" $::settings(sound_button_in);horizontal_clicker 10 10 ::settings(steam_timeout) 1 250 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings} 650 747 1270 913 ""
add_de1_button "steam_1" {say "" $::settings(sound_button_in);horizontal_clicker 1 1 ::settings(steam_timeout) 1 250 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings} 750 747 1168 913 ""

#add_de1_text "steam_1" 70 250 -text [translate "1) Choose auto-off time"] -font Helv_9 -fill "#8b8b8b" -anchor "nw" -width [rescale_x_skin 900]
#add_de1_text "steam steam_3" 70 250 -text [translate "1) Choose auto-off time"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 900]
#add_de1_text "steam_1" 1070 250 -text [translate "2) Steam your milk"] -font Helv_9 -fill "#8b8b8b" -anchor "nw" -width [rescale_x_skin 650]
#add_de1_text "steam" 1070 250 -text [translate "2) Steaming your milk"] -font Helv_9 -fill "#8b8b8b" -anchor "nw" -width [rescale_x_skin 650]
#add_de1_text "steam_3" 1070 250 -text [translate "2) Steam your milk"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 650]
#add_de1_text "steam_3" 1840 250 -text [translate "3) Make amazing latte art"] -font Helv_9 -fill "#8b8b8b" -anchor "nw" -width [rescale_x_skin 680]

add_de1_variable "steam_1" 959.74 829 -text "" -font Helv_10_bold -fill "#000000" -anchor "center"  -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}
add_de1_variable "steam steam_3" 959.74 829 -text "" -font Helv_10_bold -fill "#9f9f9f" -anchor "center"  -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}
#add_de1_text "steam_1 steam steam_3" 537 1300 -text [translate "AUTO-OFF"] -font Helv_7 -fill "#9f9f9f" -anchor "center" 


#add_de1_text "steam" 1840 250 -justify right -anchor "nw" -text [translate "Information"] -font Helv_9 -fill "#8b8b8b" -width [rescale_x_skin 520]

	#add_de1_text "steam steam_3" 1870 1200 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#8b8b8b" -width [rescale_x_skin 520]
	add_de1_text "steam" 1950 841 -justify right -anchor "nw" -text [translate "Steaming"] -font Helv_8 -fill $::detailtextheadingcol -width [rescale_x_skin 520]
		add_de1_variable "steam" 2480 841 -justify left -anchor "ne" -font Helv_8 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[steam_pour_timer][translate "s"]} 
	add_de1_text "steam_3" 1950 841 -justify right -anchor "nw" -text [translate "Steaming"] -font Helv_8 -fill $::detailtextheadingcol -width [rescale_x_skin 520]
		add_de1_variable "steam_3" 2481 841 -justify left -anchor "ne" -font Helv_8 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[steam_pour_timer][translate "s"]} 

	add_de1_variable "steam_3" 1950 881 -justify right -anchor "nw" -text [translate "Done"] -font Helv_8 -fill $::detailtextheadingcol -width [rescale_x_skin 520] -textvariable {[if {[steam_done_timer] < $::settings(seconds_to_display_done_steam)} {return [translate Done]} else { return ""}]} 
		add_de1_variable "steam_3" 2480 881 -justify left -anchor "ne" -font Helv_8 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[if {[steam_done_timer] < $::settings(seconds_to_display_done_steam)} {return "[steam_done_timer][translate s]"} else { return ""}]} 
	add_de1_text "steam" 1950 881 -justify right -anchor "nw" -text [translate "Auto-Off"] -font Helv_8 -fill $::detailtextheadingcol -width [rescale_x_skin 520]
		add_de1_variable "steam" 2480 881 -justify left -anchor "ne" -font Helv_8 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}

	add_de1_text "steam" 1950 961 -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_8 -fill $::detailtextheadingcol -width [rescale_x_skin 520]
		add_de1_variable "steam" 2480 961 -justify left -anchor "ne" -font Helv_8 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[steamtemp_text]} 
	add_de1_text "steam" 1950 1001 -justify right -anchor "nw" -text [translate "Pressure (bar)"] -font Helv_8 -fill $::detailtextheadingcol -width [rescale_x_skin 520]
		add_de1_variable "steam" 2480 1001 -justify left -anchor "ne" -font Helv_8 -text "" -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[pressure_text]} 
	add_de1_text "steam" 1950 1041 -justify right -anchor "nw" -text [translate "Flow rate"] -font Helv_8 -fill $::detailtextheadingcol -width [rescale_x_skin 520]
		add_de1_variable "steam" 2480 1041 -justify left -anchor "ne" -text "" -font Helv_8 -fill $::detailtextcol -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 


proc skins_page_change_due_to_de1_state_change { textstate } {
	page_change_due_to_de1_state_change $textstate

	if {$textstate == "Steam"} {
		set_next_page off steam_1; 
	} elseif {$textstate == "Espresso"} {
		set_next_page off espresso_3; 
	} elseif {$textstate == "HotWater"} {
		set_next_page off water_1; 
	} elseif {$textstate == "HotWaterRinse"} {
		set_next_page off preheat_1; 
		after [expr "\[round_to_integer $::settings(preheat_volume)] * 1000"] {set_next_page off preheat_1; start_idle}
	}
}


profile_has_changed_set_colors
# feature disabled until flowmeter reporting over BLE is implemented
#add_de1_text "steam" 1870 450 -justify right -anchor "nw" -text [translate "Total volume"] -font Helv_8 -fill "#9f9f9f" -width [rescale_x_skin 520]
#add_de1_variable "steam" 2470 450 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 

#set_next_page off refill;
#

# optional keyboard bindings
focus .can
bind Canvas <KeyPress> {handle_keypress %k}

