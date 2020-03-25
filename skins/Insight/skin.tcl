set ::skindebug 0
set ::debugging 0

#puts "debugging: $::debugging"

package require de1plus 1.0

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
set_next_page "hotwaterrinse" "preheat_2"


# most skins will not bother replacing these graphics
add_de1_page "sleep" "sleep.jpg" "default"
add_de1_page "tankfilling" "filling_tank.jpg" "default"
add_de1_page "tankempty refill" "fill_tank.jpg" "default"
add_de1_page "message calibrate infopage tabletstyles languages measurements showprofiles" "settings_message.png" "default"
add_de1_page "create_preset" "settings_3_choices.png" "default"
add_de1_page "descalewarning" "descalewarning.jpg" "default"

add_de1_page "cleaning" "cleaning.jpg" "default"
add_de1_page "descaling" "descaling.jpg" "default"
add_de1_page "descale_prepare" "descale_prepare.jpg" "default"

add_de1_page "travel_prepare" "travel_prepare.jpg" "default"
add_de1_page "travel_do" "travel_do.jpg" "default"

add_de1_page "ghc_steam ghc_espresso ghc_flush ghc_hotwater" "ghc.jpg" "default"
add_de1_text "ghc_steam" 1990 680 -text "\[      \]\n[translate {Tap here for steam}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 950
add_de1_text "ghc_espresso" 1936 950 -text "\[      \]\n[translate {Tap here for espresso}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 950
add_de1_text "ghc_flush" 1520 840 -text "\[      \]\n[translate {Tap here to flush}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 750
add_de1_text "ghc_hotwater" 1630 600 -text "\[      \]\n[translate {Tap here for hot water}]" -font Helv_30_bold -fill "#FFFFFF" -anchor "ne" -justify right  -width 820
add_de1_button "ghc_steam ghc_espresso ghc_flush ghc_hotwater" {say [translate {Ok}] $::settings(sound_button_in); page_show off;} 0 0 2560 1600 


set_de1_screen_saver_directory "[homedir]/saver"

# include the generic settings features for all DE1 skins.  
source "[homedir]/skins/default/de1_skin_settings.tcl"

# out of water page
add_de1_button "tankempty refill" {say [translate {awake}] $::settings(sound_button_in);start_refill_kit} 0 0 2560 1400 
	add_de1_text "tankempty refill" 1280 750 -text [translate "Please add water"] -font Helv_20_bold -fill "#CCCCCC" -justify "center" -anchor "center" -width 900
	add_de1_variable "tankempty refill" 1280 900 -justify center -anchor "center" -text "" -font Helv_10 -fill "#CCCCCC" -width 520 -textvariable {[refill_kit_retry_button]} 
	add_de1_text "tankempty" 340 1504 -text [translate "Exit App"] -font Helv_10_bold -fill "#AAAAAA" -anchor "center" 
	add_de1_text "tankempty" 2220 1504 -text [translate "Ok"] -font Helv_10_bold -fill "#AAAAAA" -anchor "center" 
	add_de1_button "tankempty" {say [translate {Exit}] $::settings(sound_button_in); .can itemconfigure $::message_label -text [translate "Going to sleep"]; .can itemconfigure $::message_button_label -text [translate "Wait"]; after 10000 {.can itemconfigure $::message_button_label -text [translate "Ok"]; }; set_next_page off message; page_show message; after 500 app_exit} 0 1402 800 1600
	add_de1_button "tankempty refill" {say [translate {awake}] $::settings(sound_button_in);start_refill_kit} 1760 1402 2560 1600

# show descale warning after steam, if clogging of the steam wand is detected
add_de1_text "descalewarning" 1280 1310 -text [translate "Your steam wand is clogging up"] -font Helv_17_bold -fill "#FFFFFF" -justify "center" -anchor "center" -width 900
add_de1_text "descalewarning" 1280 1480 -text [translate "It needs to be descaled soon"] -font Helv_15_bold -fill "#FFFFFF" -justify "center" -anchor "center" -width 900
add_de1_button "descalewarning" {say [translate {descale}] $::settings(sound_button_in); show_settings descale_prepare} 0 0 2560 1600 



# cleaning and descaling
add_de1_text "cleaning" 1280 80 -text [translate "Cleaning"] -font Helv_20_bold -fill "#EEEEEE" -justify "center" -anchor "center" -width 900
add_de1_text "descaling" 1280 80 -text [translate "Descaling"] -font Helv_20_bold -fill "#CCCCCC" -justify "center" -anchor "center" -width 900

# the font used in the big round green buttons needs to fit appropriately inside the circle, 
# and thus is dependent on the translation of the words inside the circle
set green_button_font "Helv_18_bold"
if {[language] != "en" && [language] != "kr" && [language] != "zh-hans" && [language] != "zh-hant"} {
	set green_button_font "Helv_15_bold"
}

set ::current_espresso_page "off"

# the position of each text string is somewhat dependent on the icon to the left of it, and how much space that icon takes up
set flush_button_text_position 380
set espresso_button_text_position 1040
set steam_button_text_position 1646
set hotwater_button_text_position 2276

# lighter grey, matches icons
set toptab_unselected_color "#8c8d96"

# darker grey, easier to read
#set toptab_unselected_color "#5a5d75"

# labels for PREHEAT tab on
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" $flush_button_text_position 100 -text [translate "FLUSH"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" $espresso_button_text_position 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill $toptab_unselected_color -anchor "center" 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" $steam_button_text_position 100 -text [translate "STEAM"] -font Helv_10_bold -fill $toptab_unselected_color -anchor "center" 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" $hotwater_button_text_position 100 -text [translate "WATER"] -font Helv_10_bold -fill $toptab_unselected_color -anchor "center" 

# labels for ESPRESSO tab on
add_de1_text "off espresso espresso_3" $flush_button_text_position 100 -text [translate "FLUSH"] -font Helv_10_bold -fill $toptab_unselected_color -anchor "center" 
add_de1_text "off espresso espresso_3" $espresso_button_text_position 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off espresso espresso_3" $steam_button_text_position 100 -text [translate "STEAM"] -font Helv_10_bold -fill $toptab_unselected_color -anchor "center" 
add_de1_text "off_zoomed espresso_3_zoomed espresso_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" 2350 90 -text [translate "STEAM"] -font Helv_10_bold -fill $toptab_unselected_color -anchor "center" 
add_de1_text "off espresso espresso_3" $hotwater_button_text_position 100 -text [translate "WATER"] -font Helv_10_bold -fill $toptab_unselected_color -anchor "center" 

# labels for STEAM tab on
add_de1_text "steam steam_1 steam_3 steam_zoom_3 steam_zoom" $flush_button_text_position 100 -text [translate "FLUSH"] -font Helv_10_bold -fill $toptab_unselected_color -anchor "center" 
add_de1_text "steam steam_1 steam_3 steam_zoom_3 steam_zoom" $espresso_button_text_position 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill $toptab_unselected_color -anchor "center" 
add_de1_text "steam steam_1 steam_3 steam_zoom_3 steam_zoom" $steam_button_text_position 100 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam steam_1 steam_3 steam_zoom_3 steam_zoom" $hotwater_button_text_position 100 -text [translate "WATER"] -font Helv_10_bold -fill $toptab_unselected_color -anchor "center" 

# labels for HOT WATER tab on
add_de1_text "water water_1 water_3" $flush_button_text_position 100 -text [translate "FLUSH"] -font Helv_10_bold -fill $toptab_unselected_color -anchor "center" 
add_de1_text "water water_1 water_3" $espresso_button_text_position 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill $toptab_unselected_color -anchor "center" 
add_de1_text "water water_1 water_3" $steam_button_text_position 100 -text [translate "STEAM"] -font Helv_10_bold -fill $toptab_unselected_color -anchor "center" 
add_de1_text "water water_1 water_3" $hotwater_button_text_position 100 -text [translate "WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "off espresso_3 steam_1 steam_3 steam_zoom_3 water_1 water_3 water_4" {say [translate {Flush}] $::settings(sound_button_in); set_next_page off preheat_1; page_show preheat_1; if {$::settings(one_tap_mode) == 1} { set_next_page hotwaterrinse preheat_2; start_hot_water_rinse } } 0 0 641 188
add_de1_button "preheat_1 preheat_3 preheat_4 steam_1 steam_3 steam_zoom_3 water_1 water_3 water_4" {say [translate {espresso}] $::settings(sound_button_in); set_next_page off $::current_espresso_page; if {$::settings(one_tap_mode) == 1} { start_espresso }; page_show off;  } 642 0 1277 188
add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 water_1 water_3 water_4" {say [translate {steam}] $::settings(sound_button_in); set_next_page off steam_1; page_show off; if {$::settings(one_tap_mode) == 1} { start_steam } } 1278 0 1904 188
add_de1_button "off_zoomed espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {steam}] $::settings(sound_button_in); set_next_page off steam_1; page_show off; if {$::settings(one_tap_mode) == 1} { start_steam } } 2020 0 2550 180
add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 steam_zoom_3" {say [translate {water}] $::settings(sound_button_in); set_next_page off water_1; page_show off; if {$::settings(one_tap_mode) == 1} { start_water } } 1905 0 2560 188

# when the espresso machine is doing something, the top tabs have to first stop that function, then the tab can change
add_de1_button "steam steam_zoom water espresso espresso_3" {say [translate {Heat up}] $::settings(sound_button_in);set_next_page off preheat_1; start_idle; if {$::settings(one_tap_mode) == 1} { set_next_page hotwaterrinse preheat_2; start_hot_water_rinse } } 0 0 641 188
add_de1_button "preheat_2 steam steam_zoom water" {say [translate {espresso}] $::settings(sound_button_in);set ::current_espresso_page off; set_next_page $::current_espresso_page off; start_idle; if {$::settings(one_tap_mode) == 1} { start_espresso } } 642 0 1277 188
add_de1_button "preheat_2 water espresso espresso_3 steam steam_zoom" {say [translate {steam}] $::settings(sound_button_in);set_next_page off steam_1; start_idle; if {$::settings(one_tap_mode) == 1} { start_steam } } 1278 0 1904 188
add_de1_button "espresso_zoomed espresso_zoomed_temperature" {say [translate {steam}] $::settings(sound_button_in); set_next_page off steam_1; page_show off; start_idle; if {$::settings(one_tap_mode) == 1} { start_steam } } 2020 0 2550 180
add_de1_button "preheat_2 steam steam_zoom espresso espresso_3" {say [translate {water}] $::settings(sound_button_in);set_next_page off water_1; start_idle; if {$::settings(one_tap_mode) == 1} { start_water } } 1905 0 2560 188


################################################################################################################################################################################################################################################################################################
# espresso charts

set charts_width 1990
if {$::debugging == 1} {
	set charts_width 400
	add_de1_variable "off espresso espresso_3" 450 220 -text "" -font Helv_6 -fill "#5a5d75" -anchor "nw" -justify left -width [rescale_y_skin 1560] -textvariable {$::debuglog}
	add_de1_variable "steam steam_1 steam_3 preheat_1 preheat_2 preheat_3 preheat_4 water water_1 water_3" 50 220 -text "" -font Helv_6 -fill "#5a5d75" -anchor "nw" -justify left -width [rescale_y_skin 1560] -textvariable {$::debuglog}
}

	
	# not yet ready to be used, still needs some work
	#set ::settings(display_pressure_delta_line) 0
	#set ::settings(display_flow_delta_line) 0

#######################
# 3 equal sized charts
add_de1_widget "off espresso espresso_1 espresso_2 espresso_3" graph 20 267 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed; 
		set_next_page espresso espresso_zoomed; 
		set_next_page espresso_3 espresso_3_zoomed; 
		page_show $::de1(current_context);
	}
	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color #69fdb3  -smooth $::settings(live_graph_smoothing_technique)  -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create god_line_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 20] -color #c5ffe7  -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0 ; 

	# show the explanation
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 5] -color #888888  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part1 -xdata espresso_de1_explanation_chart_elapsed_1 -ydata espresso_de1_explanation_chart_pressure_1 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part2 -xdata espresso_de1_explanation_chart_elapsed_2 -ydata espresso_de1_explanation_chart_pressure_2 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part3 -xdata espresso_de1_explanation_chart_elapsed_3 -ydata espresso_de1_explanation_chart_pressure_3 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 

	if {$::settings(display_pressure_delta_line) == 1} {
		$widget element create line_espresso_pressure_delta2  -xdata espresso_elapsed -ydata espresso_pressure_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #40dc94 -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	$widget axis configure x -color #008c4c -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -max [expr {$::de1(max_pressure) + 0.01}] -subdivisions 5 -majorticks {1 3 5 7 9 11} 
} -plotbackground #FFFFFF -width [rescale_x_skin $charts_width] -height [rescale_y_skin 406] -borderwidth 1 -background #FFFFFF -plotrelief flat 

add_de1_widget "off espresso espresso_1 espresso_2 espresso_3" graph 20 723 {
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed; 
		set_next_page espresso espresso_zoomed; 
		set_next_page espresso_3 espresso_3_zoomed; 
		page_show $::de1(current_context);
	} 
	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color #7aaaff -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5}; 

	$widget element create line_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 12] -color #4e85f4 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  


	if {$::settings(display_flow_delta_line) == 1} {
		$widget element create line_espresso_flow_delta  -xdata espresso_elapsed -ydata espresso_flow_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #98c5ff -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	if {$::settings(scale_bluetooth_address) != ""} {
		$widget element create line_espresso_flow_weight  -xdata espresso_elapsed -ydata espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 6] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
		$widget element create god_line_espresso_flow_weight  -xdata espresso_elapsed -ydata god_espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 12] -color #edd4c1 -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 

		if {$::settings(chart_total_shot_weight) == 2} {
			$widget element create line_espresso_weight  -xdata espresso_elapsed -ydata espresso_weight_chartable -symbol none -label "" -linewidth [rescale_x_skin 4] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);  
		}


	}

	$widget element create god_line_espresso_flow  -xdata espresso_elapsed -ydata god_espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 24] -color #e4edff -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0; 
	$widget axis configure x -color #206ad4 -tickfont Helv_6 ; 

	$widget axis configure y -color #206ad4 -tickfont Helv_6 -min 0.0 -max 8.01 -subdivisions 2 -majorticks {1 2 3 4 5 6 7 8}

	# show the shot configuration
	$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 5] -color #888888  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part1 -xdata espresso_de1_explanation_chart_elapsed_flow_1 -ydata espresso_de1_explanation_chart_flow_1 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part2 -xdata espresso_de1_explanation_chart_elapsed_flow_2 -ydata espresso_de1_explanation_chart_flow_2 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part3 -xdata espresso_de1_explanation_chart_elapsed_flow_3 -ydata espresso_de1_explanation_chart_flow_3 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 

} -width [rescale_x_skin $charts_width] -height [rescale_y_skin 410]  -plotbackground #FFFFFF -borderwidth 1 -background #FFFFFF -plotrelief flat


add_de1_widget "off espresso espresso_1 espresso_2 espresso_3" graph 20 1174 {
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed_temperature; 
		set_next_page espresso espresso_zoomed_temperature; 
		set_next_page espresso_3 espresso_3_zoomed_temperature; 
		page_show $::de1(current_context);
	}

	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 8] -color #ffa5a6 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 12] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	#$widget element create line_espresso_temperature_mix -xdata espresso_elapsed -ydata espresso_temperature_mix -symbol none -label ""  -linewidth [rescale_x_skin 2] -color #ffc2c1 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 
	#-dashes $::settings(chart_dashes_temperature_mix);  



	$widget element create god_line_espresso_temperature_basket -xdata espresso_elapsed -ydata god_espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 24] -color #ffe4e7 -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0 ; 


	$widget axis configure x -color #e73249 -tickfont Helv_6; 
	$widget axis configure y -color #e73249 -tickfont Helv_6 -subdivisions 5; 
	set ::temperature_chart_widget $widget
} -width [rescale_x_skin $charts_width] -height [rescale_y_skin 410]  -plotbackground #FFFFFF -borderwidth 0 -background #FFFFFF -plotrelief flat


####

add_de1_text "off_zoomed espresso_zoomed espresso_3_zoomed" 40 30 -text [translate "Flow (mL/s)"] -font Helv_7_bold -fill "#206ad4" -justify "left" -anchor "nw"
add_de1_text "off_zoomed espresso_zoomed espresso_3_zoomed" 1970 30 -text [translate "Pressure (bar)"] -font Helv_7_bold -fill "#008c4c" -justify "left" -anchor "ne"

add_de1_text "off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" 40 30 -text [translate "Temperature ([return_html_temperature_units])"] -font Helv_7_bold -fill "#e73249" -justify "left" -anchor "nw"

add_de1_text "off espresso espresso_3" 40 220 -text [translate "Pressure (bar)"] -font Helv_7_bold -fill "#008c4c" -justify "left" -anchor "nw"

add_de1_text "off espresso espresso_3" 40 677 -text [translate "Flow (mL/s)"] -font Helv_7_bold -fill "#206ad4" -justify "left" -anchor "nw"
if {$::settings(scale_bluetooth_address) != ""} {
	add_de1_text "off espresso espresso_3" 1970 677 -text [translate "Weight (g/s)"] -font Helv_7_bold -fill "#a2693d" -justify "left" -anchor "ne" 
	add_de1_text "off_zoomed espresso_zoomed espresso_3_zoomed" 700 30 -text [translate "Weight (g/s)"] -font Helv_7_bold -fill "#a2693d" -justify "left" -anchor "ne" 	
}

add_de1_text "off espresso espresso_3" 40 1128 -text [translate "Temperature ([return_html_temperature_units])"] -font Helv_7_bold -fill "#e73249" -justify "left" -anchor "nw"





#######################
# zoomed espresso
add_de1_widget "off_zoomed espresso_zoomed espresso_3_zoomed" graph 20 74 {
	bind $widget [platform_button_press] { 
		#msg "100 = [rescale_y_skin 200] = %y = [rescale_y_skin 726]"
		if {%x < [rescale_y_skin 800]} {
			# left column clicked on chart, indicates zoom

			if {%y > [rescale_y_skin 726]} {
				if {$::settings(zoomed_y_axis_scale) < 15} {
					# 15 is the max Y axis allowed
					incr ::settings(zoomed_y_axis_scale)
				}
			} else {
				if {$::settings(zoomed_y_axis_scale) > 1} {
					incr ::settings(zoomed_y_axis_scale) -1
				}
			}
			%W axis configure y -max $::settings(zoomed_y_axis_scale)
			
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


	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color #69fdb3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 12] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 

	if {$::settings(display_pressure_delta_line) == 1} {
		$widget element create line_espresso_pressure_delta_1  -xdata espresso_elapsed -ydata espresso_pressure_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #40dc94 -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	$widget element create line_espresso_flow_goal_2x  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color #7aaaff -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5}; 
	$widget element create line_espresso_flow_2x  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 12] -color #4e85f4 -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes $::settings(chart_dashes_flow);   
	$widget element create god_line_espresso_flow_2x  -xdata espresso_elapsed -ydata god_espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 24] -color #e4edff -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 

	if {$::settings(chart_total_shot_flow) == 1} {
		$widget element create line_espresso_total_flow  -xdata espresso_elapsed -ydata espresso_water_dispensed -symbol none -label "" -linewidth [rescale_x_skin 6] -color #98c5ff -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);
		
	}


	if {$::settings(display_flow_delta_line) == 1} {
		$widget element create line_espresso_flow_delta_1  -xdata espresso_elapsed -ydata espresso_flow_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #98c5ff -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	if {$::settings(scale_bluetooth_address) != ""} {
		$widget element create line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 8] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
		$widget element create line_espresso_flow_weight_raw_2x  -xdata espresso_elapsed -ydata espresso_flow_weight_raw -symbol none -label "" -linewidth [rescale_x_skin 2] -color #f8b888 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 ; 
		$widget element create god_line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata god_espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 16] -color #edd4c1 -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 

		if {$::settings(chart_total_shot_weight) == 1 || $::settings(chart_total_shot_weight) == 2} {
			$widget element create line_espresso_weight_2x  -xdata espresso_elapsed -ydata espresso_weight_chartable -symbol none -label "" -linewidth [rescale_x_skin 6] -color #f8b888 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);  
		}


	}

	$widget element create god_line2_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 24] -color #c5ffe7  -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0 ; 

	$widget axis configure x -color #5a5d75 -tickfont Helv_7_bold; 
	#$widget axis configure y2 -color #008c4c -tickfont Helv_7_bold -min 0.0 -max $::de1(max_pressure) -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12}  -hide 0;
	$widget axis configure y -color #5a5d75 -tickfont Helv_7_bold -min 0.0 -max $::settings(zoomed_y_axis_scale) -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20} -hide 0; 

	# show the explanation for pressure
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure -symbol circle -label "" -linewidth [rescale_x_skin 5] -color #888888  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part1 -xdata espresso_de1_explanation_chart_elapsed_1 -ydata espresso_de1_explanation_chart_pressure_1 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part2 -xdata espresso_de1_explanation_chart_elapsed_2 -ydata espresso_de1_explanation_chart_pressure_2 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_pressure_part3 -xdata espresso_de1_explanation_chart_elapsed_3 -ydata espresso_de1_explanation_chart_pressure_3 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 

	# show the explanation for flow
	$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 5] -color #888888  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part1 -xdata espresso_de1_explanation_chart_elapsed_flow_1 -ydata espresso_de1_explanation_chart_flow_1 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part2 -xdata espresso_de1_explanation_chart_elapsed_flow_2 -ydata espresso_de1_explanation_chart_flow_2 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_flow_part3 -xdata espresso_de1_explanation_chart_elapsed_flow_3 -ydata espresso_de1_explanation_chart_flow_3 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 


	#$widget axis configure y2 -color #206ad4 -tickfont Helv_6 -gridminor 0 -min 0.0 -max $::de1(max_flowrate) -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6} -hide 0; 
} -plotbackground #FFFFFF -width [rescale_x_skin 1990] -height [rescale_y_skin 1516] -borderwidth 1 -background #FFFFFF -plotrelief flat

#######################



#######################
# zoomed temperature
add_de1_widget "off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" graph 20 74 {
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
	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 6] -color #ffa5a6 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	$widget element create god_line_espresso_temperature_basket -xdata espresso_elapsed -ydata god_espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 20] -color #ffe4e7 -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_temperature_mix2 -xdata espresso_elapsed -ydata espresso_temperature_mix -symbol none -label ""  -linewidth [rescale_x_skin 2] -color #ffc2c1 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 

	$widget element create line_espresso_state_change_4 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0 ; 
	$widget axis configure x -color #e73249 -tickfont Helv_6; 
	$widget axis configure y -color #e73249 -tickfont Helv_6 -subdivisions 5; 
	set ::temperature_chart_zoomed_widget $widget
} -plotbackground #FFFFFF -width [rescale_x_skin 1990] -height [rescale_y_skin 1516] -borderwidth 1 -background #FFFFFF -plotrelief flat

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
} 10 240 2012 1135

# click anywhere on the chart to zoom pressure/flow.  This button is only to cover the parts that aren't overlaid by the charts, such as the text labels
add_de1_button "off espresso espresso_3" {
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed_temperature;
		set_next_page espresso espresso_zoomed_temperature;
		set_next_page espresso_3 espresso_3_zoomed_temperature;
		page_show $::de1(current_context);
} 10 1136 2012 1600

add_de1_button "off_zoomed espresso_zoomed espresso_3_zoomed" {
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page espresso_3 espresso_3; 
		set_next_page espresso_3_zoomed espresso_3; 
		set_next_page espresso espresso; 
		set_next_page espresso_zoomed espresso; 
		set_next_page off off; 
		set_next_page off_zoomed off; 
		page_show $::de1(current_context);
} 1 1 2012 1135

add_de1_button "off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" {
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page espresso_3 espresso_3; 
		set_next_page espresso_3_zoomed_temperature espresso_3; 
		set_next_page espresso espresso; 
		set_next_page espresso_zoomed_temperature espresso; 
		set_next_page off off; 
		set_next_page off_zoomed_temperature off; 
		page_show $::de1(current_context);
} 1 1 2012 1600

# the "go to sleep" button and the whole-screen button for coming back awake
add_de1_button "saver descaling cleaning" {say [translate {awake}] $::settings(sound_button_in); set_next_page off off; start_idle; de1_send_waterlevel_settings; } 0 0 2560 1600

if {$::debugging == 1} {
	#add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4 off_zoomed espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {sleep}] $::settings(sound_button_in); app_exit} 2014 1420 2284 1600
	add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 steam_zoom_3 water_1 water_3 water_4 off_zoomed espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {sleep}] $::settings(sound_button_in); set ::current_espresso_page "off"; start_sleep} 2014 1420 2284 1600
} else {
	add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 steam_zoom_3 water_1 water_3 water_4 off_zoomed espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {sleep}] $::settings(sound_button_in); set ::current_espresso_page "off"; start_sleep} 2014 1420 2284 1600
}
add_de1_text "sleep" 2500 1440 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 

# settings button 
add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed steam_1 water_1 preheat_1 steam_3 steam_zoom_3 water_3 preheat_3 preheat_4 off_zoomed_temperature espresso_3_zoomed_temperature" { say [translate {settings}] $::settings(sound_button_in); show_settings } 2285 1420 2560 1600

add_de1_variable "off off_zoomed off_zoomed_temperature" 2290 390 -text [translate "START"] -font $green_button_font -fill "#2d3046" -anchor "center" -textvariable {[start_text_if_espresso_ready]} 
add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" 2290 390 -text [translate "STOP"] -font $green_button_font -fill "#2d3046" -anchor "center" -textvariable {[stop_text_if_espresso_stoppable]} 
add_de1_variable "espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" 2290 390 -text [translate "RESTART"] -font $green_button_font -fill "#2d3046" -anchor "center" -textvariable {[espresso_history_save_from_gui]} 

add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed espresso espresso_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" 2295 470 -text [translate "ESPRESSO"] -font Helv_10 -fill "#7f879a" -anchor "center" 
add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" 2295 520 -text "" -font Helv_7 -fill "#999999" -anchor "center" -textvariable {[de1_substate_text]} 

# indicate whether we are connected to the DE1+ or not
add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" 2295 560 -justify center -anchor "center" -text "" -font Helv_6 -fill "#CCCCCC" -width 520 -textvariable {[de1_connected_state]} 


add_de1_widget "steam" graph 1810 1090 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam_zoom; 
		set_next_page steam steam_zoom; 
		page_show $::de1(current_context);
	}
	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 6] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 6] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 6] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color #008c4c -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {1 2 3} 
	$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 
} -plotbackground #FFFFFF -width [rescale_x_skin 700] -height [rescale_y_skin 300] -borderwidth 1 -background #FFFFFF -plotrelief flat 

add_de1_widget "steam_3" graph 1810 1090 { 
	bind $widget [platform_button_press] { 
		say [translate {stop}] $::settings(sound_button_in); 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam_zoom_3; 
		set_next_page steam_3 steam_zoom_3; 
		page_show $::de1(current_context);
	}
	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 6] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 6] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);   

	$widget axis configure x -color #008c4c -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {1 2 3} 
	$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0
} -plotbackground #FFFFFF -width [rescale_x_skin 700] -height [rescale_y_skin 300] -borderwidth 1 -background #FFFFFF -plotrelief flat 


add_de1_widget "steam_zoom_3" graph 34 214 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam_3; 
		#set_next_page steam_zoom_3 steam_3; 
		set_next_page steam steam; 
		set_next_page steam_zoom_3 steam_3; 
		page_show $::de1(current_context);
	}
	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249  -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color #008c4c -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3}  -title "[translate "Flow rate"] - [translate "Temperature"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #5a5d75;
	$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -title "[translate "Flow rate"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #5a5d75;
} -plotbackground #FFFFFF -width [rescale_x_skin 2490] -height [rescale_y_skin 700] -borderwidth 1 -background #FFFFFF -plotrelief flat 


add_de1_widget "steam_zoom_3" graph 34 914 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam_3; 
		#set_next_page steam_zoom_3 steam_3; 
		set_next_page steam steam; 
		set_next_page steam_zoom_3 steam_3; 
		page_show $::de1(current_context);
	}
	#$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	#$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249  -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color #008c4c -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3}  -title "[translate "Flow rate"] - [translate "Temperature"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #5a5d75;
	
	if {$::settings(enable_fahrenheit) == 1} {
		$widget axis configure y -color #008c4c -tickfont Helv_6 -min 250 -max 350 -title "[translate "Temperature"]" -titlefont Helv_7 -titlecolor #5a5d75;
	} else {
		$widget axis configure y -color #008c4c -tickfont Helv_6 -min 130 -max 180 -title "[translate "Temperature"]" -titlefont Helv_7 -titlecolor #5a5d75;
	}
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 130 -max 180 -title "[translate "Temperature"]" -titlefont Helv_7 -titlecolor #5a5d75;
} -plotbackground #FFFFFF -width [rescale_x_skin 2490] -height [rescale_y_skin 490] -borderwidth 1 -background #FFFFFF -plotrelief flat 




add_de1_widget "steam_zoom" graph 34 214 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam; 
		#set_next_page steam_zoom_3 steam_3; 
		set_next_page steam steam; 
		set_next_page steam_zoom steam; 
		page_show $::de1(current_context);
	}
	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color #008c4c -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3}  -title "[translate "Flow rate"] - [translate "Temperature"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #5a5d75;
	$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -title "[translate "Flow rate"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #5a5d75;
} -plotbackground #FFFFFF -width [rescale_x_skin 2490] -height [rescale_y_skin 700] -borderwidth 1 -background #FFFFFF -plotrelief flat 



add_de1_widget "steam_zoom" graph 34 914 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam; 
		#set_next_page steam_zoom_3 steam_3; 
		set_next_page steam steam; 
		set_next_page steam_zoom steam; 
		page_show $::de1(current_context);
	}
	#$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	#$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color #008c4c -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3}  -title "[translate "Flow rate"] - [translate "Temperature"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #5a5d75;
	if {$::settings(enable_fahrenheit) == 1} {
		$widget axis configure y -color #008c4c -tickfont Helv_6 -min 250 -max 350 -title "[translate "Temperature"]" -titlefont Helv_7 -titlecolor #5a5d75;
	} else {
		$widget axis configure y -color #008c4c -tickfont Helv_6 -min 130 -max 180 -title "[translate "Temperature"]" -titlefont Helv_7 -titlecolor #5a5d75;
	}
} -plotbackground #FFFFFF -width [rescale_x_skin 2490] -height [rescale_y_skin 490] -borderwidth 1 -background #FFFFFF -plotrelief flat 


##########################################################################################################################################################################################################################################################################
# data card displayed during espresso making

set pos_top 720
set spacer 38
#set paragraph 20

set column2 2195
if {$::settings(enable_fahrenheit) == 1} {
	set column2 2210
}

set dark "#5a5d75"
set lighter "#969eb1"
set lightest "#bec7db"
set column1_pos 2060
set column3_pos 2512

if {$::settings(waterlevel_indicator_on) == 1} {
	# water level sensor on espresso page
#	add_de1_widget "off espresso espresso_3 off_zoomed espresso_zoomed espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" scale 2528 694 {after 1000 water_level_color_check $widget} -from 40 -to 5 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 594] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor #ffffff -borderwidth 0  -highlightthickness 0
#	add_de1_widget "off espresso espresso_3 off_zoomed espresso_zoomed espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" scale 2528 696 {after 1000 water_level_color_check $widget} -from $::settings(water_level_sensor_max) -to 5 -background "#7ad2ff" -foreground #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_y_skin 704] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor #FFFFFF -borderwidth 0  -highlightthickness 0
	add_de1_widget "off espresso espresso_3 off_zoomed espresso_zoomed espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" scale 2546 190 {after 1000 water_level_color_check $widget} -from $::settings(water_level_sensor_max) -to 10 -background "#7ad2ff" -foreground #FFFFFF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_y_skin 496] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor #ededfa -borderwidth 0  -highlightthickness 0

	# water level sensor on other tabs page (white background)
	add_de1_widget "preheat_2 preheat_3 preheat_4 steam steam_3 steam_zoom steam_zoom_3 water water_3 water_4" scale 2510 226 {after 1000 water_level_color_check $widget} -from $::settings(water_level_sensor_max) -to 10 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_y_skin 1166] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor #ffffff -borderwidth 0  -highlightthickness 0

	# water level sensor on other tabs page (light blue background)
	add_de1_widget "preheat_1 steam_1 water_1" scale 2510 226 {after 1000 water_level_color_check $widget} -from $::settings(water_level_sensor_max) -to 10 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_y_skin 1166] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor #f2f2fc -borderwidth 0  -highlightthickness 0
}


add_de1_text "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "nw" -text [translate "Time"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]
	add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $lighter -width [rescale_x_skin 520] -textvariable {[espresso_preinfusion_timer][translate "s"] [translate "preinfusion"]} 
		
	add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (3 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[if {$::settings(final_desired_shot_volume_advanced) > 0 && $::settings(settings_profile_type) == "settings_2c"} {
			return "[espresso_elapsed_timer][translate {s}] [translate {total}] < [return_liquid_measurement [round_to_integer $::settings(final_desired_shot_volume_advanced)]]"
		} else {
			return "[espresso_elapsed_timer][translate {s}] [translate {total}]"
		}]}  
	add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (4 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -text "" -fill $lighter -width [rescale_x_skin 520] -textvariable {[if {[espresso_done_timer] < $::settings(seconds_to_display_done_espresso)} {return "[espresso_done_timer][translate s] [translate done]"} else { return ""}]} 
	add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $lighter -width [rescale_x_skin 520] -textvariable {[if {$::settings(scale_bluetooth_address) == "" && $::settings(final_desired_shot_volume) > 0 && ($::settings(settings_profile_type) == "settings_2a" || $::settings(settings_profile_type) == "settings_2b")} {
			return "[espresso_pour_timer][translate {s}] [translate {pouring}] < [return_liquid_measurement [round_to_integer $::settings(final_desired_shot_volume)]]"
		} else {
			return "[espresso_pour_timer][translate {s}] [translate {pouring}]"
		}]}  

#if {$::settings(display_volumetric_usage) == 1} {
	# temporarily disabled, because these use a different measurement technique than the DE1+ does, so they'll always be off
	add_de1_text "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "ne" -text [translate "Volume"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]
		add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7  -fill $lighter -width [rescale_x_skin 520] -textvariable {[preinfusion_volume]} 
		add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7  -fill $lighter -width [rescale_x_skin 520] -textvariable {[pour_volume]}
		add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (3 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 
#}


#######################
# temperature
add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (5.5 * $spacer)}] -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]
add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (4.5 * $spacer)}] -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]
	add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column2 [expr {$pos_top + (5.5 * $spacer)}] -justify right -anchor "nw" -text [translate "goal"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column2 [expr {$pos_top + (6.5 * $spacer)}] -justify right -anchor "nw" -text [translate "goal"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (5.5 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[espresso_goal_temp_text]} 
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[espresso_goal_temp_text]} 

	add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column2 [expr {$pos_top + (7.5 * $spacer)}] -justify right -anchor "nw" -text [translate "metal"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature"  $column1_pos [expr {$pos_top + (7.5 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[group_head_heater_temperature_text]} 
	#add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature"  $column1_pos [expr {$pos_top + (9 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {$::settings(settings_profile_type)} 

	if {$::settings(display_group_head_delta_number) == 1} {
		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" 2380 [expr {$pos_top + (7.5 * $spacer)}] -justify left -anchor "ne" -font Helv_7 -fill $lightest -width [rescale_x_skin 520] -textvariable {[return_delta_temperature_measurement [diff_group_temp_from_goal]]} 
	}

	add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column2 [expr {$pos_top + (6.5 * $spacer)}] -justify right -anchor "nw" -text [translate "coffee"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[watertemp_text]} 

	if {$::settings(show_mixtemp_during_espresso) == 1} {
		add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column2 [expr {$pos_top + (7.5 * $spacer)}] -justify right -anchor "nw" -text [translate "water"] -font Helv_7 -fill $lighter -width [rescale_x_skin 520]
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (7.5 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[mixtemp_text]} 
	}

	
	if {$::settings(display_espresso_water_temp_difference) == 1} {
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7 -fill $lightest -width [rescale_x_skin 520] -textvariable {[return_delta_temperature_measurement [diff_espresso_temp_from_goal]]} 
			add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top + (7.5 * $spacer)}] -justify left -anchor "ne" -font Helv_7 -fill $lightest -width [rescale_x_skin 520] -textvariable {[return_delta_temperature_measurement [diff_brew_temp_from_goal] ]} 
			# thermometer widget from http://core.tcl.tk/bwidget/doc/bwidget/BWman/index.html
		    add_de1_widget "espresso espresso_zoomed espresso_zoomed_temperature" ProgressBar 2390 [expr {$pos_top + (8.7 * $spacer)}] {} -width [rescale_y_skin 108] -height [rescale_x_skin 16] -type normal  -variable ::positive_diff_brew_temp_from_goal -fg #ff8888 -bg #FFFFFF -maximum 10 -borderwidth 1 -relief flat
	}
#######################
	#add_de1_widget "off espresso espresso_3 off_zoomed espresso_zoomed espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" scale 2528 694 {after 1000 water_level_color_check $widget} -from 40 -to 5 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 594] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor #ffffff -borderwidth 0  -highlightthickness 0



#######################
# flow 
add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (8 * $spacer)}] -justify right -anchor "nw" -text [translate "Flow"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]
	#add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[watervolume_text] [translate "total"]} 
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (9 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (10 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[pressure_text]} 
#######################

#######################
# weight
add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (12.5 * $spacer)}] -justify right -anchor "nw" -font Helv_7_bold -fill $dark -width [rescale_x_skin 520] -textvariable {[waterweight_label_text]}
	#add_de1_variable "" $column1_pos [expr {$pos_top + (14 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[finalwaterweight_text]}
	add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (13.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[if {$::de1(scale_weight) == ""} { return "" } elseif {$::settings(scale_bluetooth_address) != "" && $::settings(final_desired_shot_weight) > 0 && ($::settings(settings_profile_type) == "settings_2a" || $::settings(settings_profile_type) == "settings_2b")} {
			return "[waterweight_text] < [return_stop_at_weight_measurement $::settings(final_desired_shot_weight)]"			
		} elseif {$::settings(scale_bluetooth_address) != "" && $::settings(final_desired_shot_weight_advanced) > 0 && $::settings(settings_profile_type) == "settings_2c"} {
			return "[finalwaterweight_text] < [return_stop_at_weight_measurement $::settings(final_desired_shot_weight_advanced)]"			
		} else {
			return "[finalwaterweight_text]"
		}]}  


	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (17.5 * $spacer)}] -justify right -anchor "nw" -font Helv_7_bold -fill $dark -width [rescale_x_skin 520] -textvariable {[waterweight_label_text]}
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (18.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[waterweightflow_text]} 
	
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (19.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 520] -textvariable {[if {$::de1(scale_weight) == ""} { return "" } elseif {$::settings(scale_bluetooth_address) != "" && $::settings(final_desired_shot_weight) > 0 && ($::settings(settings_profile_type) == "settings_2a" || $::settings(settings_profile_type) == "settings_2b")} {
			return "[waterweight_text] < [return_stop_at_weight_measurement $::settings(final_desired_shot_weight)]"			
		} elseif {$::settings(scale_bluetooth_address) != "" && $::settings(final_desired_shot_weight_advanced) > 0 && $::settings(settings_profile_type) == "settings_2c"} {
			return "[waterweight_text] < [return_stop_at_weight_measurement $::settings(final_desired_shot_weight_advanced)]"			
		} else {
			return "[waterweight_text]"
		}]}  


			

		add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $lighter -width [rescale_x_skin 520] -textvariable {[if {$::settings(scale_bluetooth_address) == "" && $::settings(final_desired_shot_volume) > 0 && ($::settings(settings_profile_type) == "settings_2a" || $::settings(settings_profile_type) == "settings_2b")} {
				return "[espresso_pour_timer][translate {s}] [translate {pouring}] < [return_liquid_measurement [round_to_integer $::settings(final_desired_shot_volume)]]"
			} else {
				return "[espresso_pour_timer][translate {s}] [translate {pouring}]"
			}]}  


		# progress bar docs http://npg.dl.ac.uk/MIDAS/manual/ActiveTcl8.5.7.0.290198-html/bwidget/ProgressBar.html
		add_de1_widget "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" ProgressBar $column1_pos 1310 {} -relief "flat" -troughcolor "#FFFFFF" -width [rescale_y_skin 420] -height [rescale_x_skin 2] -type normal  -variable ::de1(scale_weight_rate) -fg #a2693d -bg #ffffff -maximum 6 -borderwidth 0 -relief flat
	
	if {$::settings(scale_bluetooth_address) != ""} {
		set ::de1(scale_weight_rate) -1
		
		if {$::settings(insight_skin_show_weight_activity_bar) == 1} {
			add_de1_widget "espresso espresso_zoomed espresso_zoomed_temperature" ProgressBar 2390 [expr {$pos_top + (12.3 * $spacer)}] {} -width [rescale_y_skin 108] -height [rescale_x_skin 16] -type normal  -variable ::de1(scale_weight_rate) -fg #a2693d -bg #ffffff -maximum 6 -borderwidth 0 -relief flat
		}
	
		# scale ble reconnection button
		add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {connect}] $::settings(sound_button_in); catch {ble_connect_to_scale}} 2040 1220 2400 1400
	}

#######################


#######################
# profile name 
	# we can display the profile name if the embedded chart is not displayed.
	add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (9 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7_bold -fill $dark -width [rescale_x_skin 520] -textvariable {[profile_type_text]} 
		set ::globals(widget_current_profile_name1) [add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (10 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -textvariable {[wrapped_string_part [profile_title] 29 0]} ]
		set ::globals(widget_current_profile_name2) [add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (11 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -textvariable {[wrapped_string_part [profile_title] 29 1]} ]

	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (11.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7_bold -fill $dark -width [rescale_x_skin 520] -textvariable {[profile_type_text]} 
		set ::globals(widget_current_profile_name_espresso1) [add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (12.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -textvariable {[wrapped_string_part [profile_title] 29 0]} ]
		set ::globals(widget_current_profile_name_espresso2) [add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (13.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -textvariable {[wrapped_string_part [profile_title] 29 1]} ]

	# tap on profile name to go directly to settings choose page
	add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {describe}] $::settings(sound_button_in); if {$::settings(profile_has_changed) == 1} { save_profile } else { backup_settings; set_next_page off settings_1; page_show off; set_profiles_scrollbar_dimensions }
} 2040 1072 2400 1218

	# current step description
	add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos  [expr {$pos_top + (15 * $spacer)}] -justify right -anchor "nw" -text [translate "Current step"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos  [expr {$pos_top + (16 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill "#8297be" -width [rescale_x_skin 440] -textvariable {$::settings(current_frame_description)} 


	
#add_de1_text "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "ne" -text [translate "Volume"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]


	#add_de1_variable "espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (9 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7_bold -fill $dark -width [rescale_x_skin 520] -textvariable {[profile_type_text]} 
		#add_de1_variable "espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (10 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $lighter -width [rescale_x_skin 470] -textvariable {$::settings(profile)} 
#######################


# atap on temperature or time to get to settings edit page
add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {describe}] $::settings(sound_button_in); backup_settings; set_next_page off $::settings(settings_profile_type); page_show off; set_profiles_scrollbar_dimensions} 2040 720 2560 1070

# this heart icon feature is always on now
set ::settings(display_rate_espresso) 1
if {$::settings(display_rate_espresso) == 1} {
	add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {describe}] $::settings(sound_button_in); backup_settings; set_next_page off describe_espresso0; page_show off; set_god_shot_scrollbar_dimensions; } 2420 1200 2560 1400
	source "[homedir]/skins/Insight/scentone.tcl"
}


##########################################################################################################################################################################################################################################################################


##########################################################################################################################################################################################################################################################################
# making espresso now

# make and stop espresso button
add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {espresso}] $::settings(sound_button_in);set ::current_espresso_page espresso_3; set_next_page off espresso_3; start_espresso} 2020 240 2560 700
add_de1_button "espresso" {say [translate {stop}] $::settings(sound_button_in);set_next_page off espresso_3; start_idle;} 2020 240 2560 1600
add_de1_button "espresso_zoomed" {say [translate {stop}] $::settings(sound_button_in); set_next_page off espresso_3_zoomed; start_idle;} 2020 240 2560 1600
add_de1_button "espresso_zoomed_temperature" {say [translate {stop}] $::settings(sound_button_in); set_next_page off espresso_3_zoomed_temperature; start_idle;} 2020 240 2560 1600

##########################################################################################################################################################################################################################################################################


##########################################################################################################################################################################################################################################################################
# settings for preheating a cup

add_de1_variable "preheat_1" 1390 775 -text [translate "START"] -font $green_button_font -fill "#2d3046" -anchor "center" -textvariable {[start_text_if_espresso_ready]} 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 1390 865 -text [translate "FLUSH"] -font Helv_10 -fill "#7f879a" -anchor "center" 
add_de1_variable "preheat_2" 1390 775 -text [translate "STOP"] -font $green_button_font -fill "#2d3046" -anchor "center"  -textvariable {[stop_text_if_espresso_stoppable]} 
add_de1_variable "preheat_3 preheat_4" 1390 775 -text [translate "RESTART"] -font $green_button_font -fill "#2d3046" -anchor "center" -textvariable {[restart_text_if_espresso_ready]} 

#1030 210 1800 1400
add_de1_button "preheat_1 preheat_3 preheat_4" {say [translate {Heat up}] $::settings(sound_button_in); set ::settings(preheat_temperature) 90; set_next_page hotwaterrinse preheat_2; start_hot_water_rinse} 0 240 2560 1400
add_de1_button "preheat_2" {say [translate {stop}] $::settings(sound_button_in); set_next_page off preheat_4; start_idle} 0 240 2560 1600


set preheat_water_volume_feature_enabled 0
if {$preheat_water_volume_feature_enabled == 1} {
	add_de1_button "preheat_3 preheat_4" {say "" $::settings(sound_button_in); set_next_page off preheat_1; start_idle} 0 210 1000 1400
	add_de1_button "preheat_1" {say "" $::settings(sound_button_in);vertical_clicker 40 10 ::settings(preheat_volume) 10 250 %x %y %x0 %y0 %x1 %y1 %b; save_settings; de1_send_steam_hotwater_settings} 100 510 900 1200 ""
	add_de1_text "preheat_1" 70 250 -text [translate "1) How much water?"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 900]
	add_de1_text "preheat_2 preheat_3 preheat_4" 70 250 -text [translate "1) How much water?"] -font Helv_9 -fill "#7f879a" -anchor "nw" -width [rescale_x_skin 900]
}
add_de1_text "preheat_1" 1070 250 -text [translate "1) Hot water will pour out"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "preheat_2" 1070 250 -text [translate "1) Hot water is pouring out"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "preheat_3 preheat_4" 1070 250 -text [translate "1) Hot water will pour out"] -font Helv_9 -fill "#7f879a" -anchor "nw" -width [rescale_x_skin 650]

#add_de1_text "preheat_1" 1840 250 -text [translate "2) Done"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 680]
add_de1_text "preheat_3 preheat_4" 1840 250 -text [translate "2) Done"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 680]

if {$preheat_water_volume_feature_enabled == 1} {
	add_de1_variable "preheat_1" 540 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_liquid_measurement $::settings(preheat_volume)]}
	add_de1_variable "preheat_2 preheat_3 preheat_4" 540 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[return_liquid_measurement $::settings(preheat_volume)]}
	add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 540 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#7f879a" -anchor "center" 

	# feature disabled until flowmeter reporting over BLE is implemented
	#add_de1_text "preheat_2" 1880 1300 -justify right -anchor "nw" -text [translate "Total volume"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
	#add_de1_variable "preheat_2" 2470 1300 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 
}

#add_de1_text "preheat_2 preheat_4" 1870 1200 -justify right -anchor "nw" -text [translate "Information"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]

#add_de1_text "preheat_2" 1870 1250 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]
#add_de1_text "preheat_4" 1870 1200 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]
add_de1_variable "preheat_3 preheat_4" 1870 1250 -justify right -anchor "nw" -text [translate "Done"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520] -textvariable {[if {[flush_done_timer] < $::settings(seconds_to_display_done_flush)} {return [translate Done]} else { return ""}]} 
add_de1_variable "preheat_3 preheat_4" 2470 1250 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[if {[flush_done_timer] < $::settings(seconds_to_display_done_flush)} {return "[flush_done_timer][translate s]"} else { return ""}]} 

#add_de1_text "preheat_2"  1870 1250 -justify right -anchor "nw" -text [translate "Metal temperature"] -font Helv_8 -fill  "#7f879a"  -width [rescale_x_skin 520]
#add_de1_variable "preheat_2"  2470 1250  -justify left -anchor "ne" -font Helv_8 -fill  "#42465c"  -width [rescale_x_skin 520] -textvariable {[group_head_heater_temperature_text]} 
#add_de1_text "preheat_4"  1870 1200 -justify right -anchor "nw" -text [translate "Metal temperature"] -font Helv_8 -fill  "#7f879a"  -width [rescale_x_skin 520]
#add_de1_variable "preheat_4"  2470 1200  -justify left -anchor "ne" -font Helv_8 -fill  "#42465c"  -width [rescale_x_skin 520] -textvariable {[group_head_heater_temperature_text]} 

add_de1_text "preheat_2" 1870 1250 -justify right -anchor "nw" -text [translate "Water temperature"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "preheat_2" 2470 1250 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[watertemp_text]} 


add_de1_text "preheat_2 preheat_4" 1870 1300 -justify right -anchor "nw" -text [translate "Pouring"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "preheat_2 preheat_4" 2470 1300 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[flush_pour_timer][translate "s"]} 

#add_de1_text "preheat_4" 1870 1250 -justify right -anchor "nw" -text [translate "Pouring"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
#add_de1_variable "preheat_4" 2470 1250 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[flush_pour_timer][translate "s"]} 

# feature disabled until flowmeter reporting over BLE is implemented
#add_de1_text "preheat_3" 1880 1250 -justify right -anchor "nw" -text [translate "Total volume"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
#add_de1_variable "preheat_3" 2470 1250 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 

##########################################################################################################################################################################################################################################################################

##########################################################################################################################################################################################################################################################################
# settings for dispensing hot water

# future feature
# add_de1_text "water_1 water_3" 1390 1270 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 

add_de1_variable "water_1" 1390 775 -text [translate "START"] -font $green_button_font -fill "#2d3046" -anchor "center" -textvariable {[start_text_if_espresso_ready]} 
add_de1_variable "water_3" 1390 775 -text [translate "RESTART"] -font $green_button_font -fill "#2d3046" -anchor "center" -textvariable {[restart_text_if_espresso_ready]} 
add_de1_variable "water" 1390 775 -text [translate "STOP"] -font $green_button_font -fill "#2d3046" -anchor "center"  -textvariable {[stop_text_if_espresso_stoppable]} 

add_de1_text "water_1 water water_3" 1390 865 -text [translate "WATER"] -font Helv_10 -fill "#7f879a" -anchor "center" 
add_de1_button "water_1 water_3" {say [translate {Hot water}] $::settings(sound_button_in); set_next_page water water; start_water} 1030 240 2560 1400
add_de1_button "water" {say [translate {stop}] $::settings(sound_button_in); set_next_page off water_3 ; start_idle} 0 240 2560 1600

# future feature
#add_de1_button "water_1 water_3" {say [translate {rinse}] $::settings(sound_button_in); set_next_page water water; start_water} 1030 1101 1760 1400

add_de1_button "water_1" {say "" $::settings(sound_button_in);vertical_clicker 40 10 ::settings(water_volume) 10 250 %x %y %x0 %y0 %x1 %y1 %b; save_settings; de1_send_steam_hotwater_settings} 0 560 520 1170 ""
add_de1_button "water_1" {say "" $::settings(sound_button_in);vertical_clicker 9 1 ::settings(water_temperature) 60 100 %x %y %x0 %y0 %x1 %y1 %b; save_settings; de1_send_steam_hotwater_settings} 551 450 1000 1180 ""

#add_de1_button "water_1" {say "" $::settings(sound_button_in);vertical_slider ::settings(water_volume) 1 400 %x %y %x0 %y0 %x1 %y1} 0 210 550 1400 "mousemove"
#add_de1_button "water_1" {say "" $::settings(sound_button_in);vertical_slider ::settings(water_temperature) 20 96 %x %y %x0 %y0 %x1 %y1} 551 210 1029 1400 "mousemove"

add_de1_text "water_1" 70 250 -text [translate "1) Settings"] -font Helv_10 -fill "#5a5d75" -anchor "nw" -width 900

add_de1_text "water_1" 1070 250 -text [translate "2) Hot water will pour"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "water" 1070 250 -text [translate "2) Hot water is pouring"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "water_3" 1840 250 -text [translate "3) Done"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 650]


add_de1_text "water water_3" 70 250 -text [translate "1) Settings"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 900]
add_de1_text "water_3" 1070 250 -text [translate "2) Hot water will pour"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 650]

add_de1_variable "water_1" 300 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center"  -textvariable {[return_liquid_measurement $::settings(water_volume)]}
add_de1_text "water_1" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#7f879a" -anchor "center" 
add_de1_variable "water_1" 755 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}
add_de1_text "water_1" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill "#7f879a" -anchor "center" 

add_de1_variable "water water_3" 300 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center"  -textvariable {[return_liquid_measurement $::settings(water_volume)]}
add_de1_text "water water_3" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 
add_de1_variable "water water_3" 755 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}
add_de1_text "water water_3" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 
add_de1_button "water_3" {say "" $::settings(sound_button_in); set_next_page off water_1; start_idle} 0 240 1000 1400

# data card
#add_de1_text "water" 1870 1250 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]
#add_de1_text "water_3" 1870 1200 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]
add_de1_text "water water_3" 1870 1300 -justify right -anchor "nw" -text [translate "Pouring"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "water water_3" 2470 1300 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[water_pour_timer][translate "s"]} 

#add_de1_text "water_3" 1870 1250 -justify right -anchor "nw" -text [translate "Pouring"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
#add_de1_variable "water_3" 2470 1250 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[water_pour_timer][translate "s"]} 


add_de1_variable "water_3" 1870 1250 -justify right -anchor "nw" -text [translate "Done"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520] -textvariable {[if {[water_done_timer] < $::settings(seconds_to_display_done_hotwater)} {return [translate Done]} else { return ""}]} 
add_de1_variable "water_3" 2470 1250 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[if {[water_done_timer] < $::settings(seconds_to_display_done_hotwater)} {return "[water_done_timer][translate s]"} else { return ""}]} 


# current water temperature - not getting this via BLE at the moment 1/4/19 so do not display in the UI
	#add_de1_text "water" 1870 300 -justify right -anchor "nw" -text [translate "Water temperature"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
	#add_de1_variable "water" 2470 300 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[watertemp_text]} 
	#add_de1_text "water_3" 1870 350 -justify right -anchor "nw" -text [translate "Information"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]
	#add_de1_text "water_3" 1870 400 -justify right -anchor "nw" -text [translate "Water temperature"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
	#add_de1_variable "water_3" 2470 400 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[watertemp_text]} 
	#add_de1_text "water" 1870 250 -justify right -anchor "nw" -text [translate "Information"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]

add_de1_text "water " 1870 1250 -justify right -anchor "nw" -text [translate "Flow rate"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "water" 2470 1250 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 

# feature disabled until flowmeter reporting over BLE is implemented
	#add_de1_text "water " 1870 350 -justify right -anchor "nw" -text [translate "Total volume"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
	#add_de1_variable "water" 2470 350 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 


# feature disabled until flowmeter reporting over BLE is implemented
	#add_de1_text "water_3" 1870 450 -justify right -anchor "nw" -text [translate "Total volume"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
	#add_de1_variable "water_3" 2470 450 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 




##########################################################################################################################################################################################################################################################################



##########################################################################################################################################################################################################################################################################
# settings for steam

# future feature
#add_de1_text "steam_1 steam_3" 1390 1270 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 

#add_de1_text "steam_3" 2180 1280 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 

add_de1_variable "steam_1" 1390 775 -text [translate "START"] -font $green_button_font -fill "#2d3046" -anchor "center" -textvariable {[start_text_if_espresso_ready]} 
add_de1_variable "steam" 1390 775 -text [translate "STOP"] -font $green_button_font -fill "#2d3046" -anchor "center"  -textvariable {[stop_text_if_espresso_stoppable]} 
add_de1_variable "steam_3" 1390 775 -text [translate "RESTART"] -font $green_button_font -fill "#2d3046" -anchor "center" -textvariable {[restart_text_if_espresso_ready]} 

add_de1_text "steam_1 steam steam_3" 1390 865 -text [translate "STEAM"] -font Helv_10 -fill "#7f879a" -anchor "center" 

add_de1_button "steam_1" {say [translate {steam}] $::settings(sound_button_in); set_next_page steam steam; start_steam} 1030 240 2560 1400
add_de1_button "steam_3" {say [translate {steam}] $::settings(sound_button_in); set_next_page steam steam; start_steam} 1030 240 2560 1070


# future feature
#add_de1_button "steam_1" {say [translate {rinse}] $::settings(sound_button_in); start_steam} 1030 1101 1760 1400

add_de1_button "steam" {say [translate {stop}] $::settings(sound_button_in); set_next_page off steam_3; start_idle} 0 240 2560 1600
add_de1_button "steam_3" {say "" $::settings(sound_button_in); set_next_page off steam_1; start_idle} 0 240 1000 1400
add_de1_button "steam_1" {say "" $::settings(sound_button_in);vertical_clicker 9 1 ::settings(steam_timeout) 1 250 %x %y %x0 %y0 %x1 %y1 %b; save_settings; de1_send_steam_hotwater_settings} 200 580 900 1150 ""


add_de1_text "steam_1" 70 250 -text [translate "1) Choose auto-off time"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 900]
add_de1_text "steam steam_3" 70 250 -text [translate "1) Choose auto-off time"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 900]
add_de1_text "steam_1" 1070 250 -text [translate "2) Steam your milk"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "steam" 1070 250 -text [translate "2) Steaming your milk"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "steam_3" 1070 250 -text [translate "2) Steam your milk"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "steam_3" 1840 250 -text [translate "3) Make amazing latte art"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 680]

add_de1_variable "steam_1" 537 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center"  -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}
add_de1_variable "steam steam_3" 537 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center"  -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}
add_de1_text "steam_1 steam steam_3" 537 1300 -text [translate "AUTO-OFF"] -font Helv_7 -fill "#7f879a" -anchor "center" 


add_de1_text "steam" 1840 250 -justify right -anchor "nw" -text [translate "Information"] -font Helv_9 -fill "#5a5d75" -width [rescale_x_skin 520]

	#add_de1_text "steam steam_3" 1870 1200 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]
	add_de1_text "steam" 1870 350 -justify right -anchor "nw" -text [translate "Steaming"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam" 2470 350 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[steam_pour_timer][translate "s"]} 
	add_de1_text "steam_3" 1870 350 -justify right -anchor "nw" -text [translate "Steaming"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam_3" 2470 350 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[steam_pour_timer][translate "s"]} 

	add_de1_variable "steam_3" 1870 400 -justify right -anchor "nw" -text [translate "Done"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520] -textvariable {[if {[steam_done_timer] < $::settings(seconds_to_display_done_steam)} {return [translate Done]} else { return ""}]} 
		add_de1_variable "steam_3" 2470 400 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[if {[steam_done_timer] < $::settings(seconds_to_display_done_steam)} {return "[steam_done_timer][translate s]"} else { return ""}]} 
	add_de1_text "steam" 1870 400 -justify right -anchor "nw" -text [translate "Auto-Off"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam" 2470 400 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}

	add_de1_text "steam" 1870 470 -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam" 2470 470 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[steamtemp_text]} 
	add_de1_text "steam" 1870 520 -justify right -anchor "nw" -text [translate "Pressure (bar)"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam" 2470 520 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[pressure_text]} 
	add_de1_text "steam" 1870 570 -justify right -anchor "nw" -text [translate "Flow rate"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam" 2470 570 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 


	# zoomed steam chart
	add_de1_text "steam_zoom_3 steam_zoom" 250 1440 -justify right -anchor "nw" -text [translate "Steaming"] -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam_zoom_3 steam_zoom" 230 1440 -justify left -anchor "ne" -font Helv_7 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[steam_pour_timer][translate "s"]} 
	add_de1_variable "steam_zoom_3 steam_zoom" 250 1490 -justify right -anchor "nw" -text [translate "Done"] -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520] -textvariable {[if {[steam_done_timer] < $::settings(seconds_to_display_done_steam)} {return [translate Done]} else { return ""}]} 
		add_de1_variable "steam_zoom_3 steam_zoom" 230 1490 -justify left -anchor "ne" -font Helv_7 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[if {[steam_done_timer] < $::settings(seconds_to_display_done_steam)} {return "[steam_done_timer][translate s]"} else { return ""}]} 
	add_de1_text "steam_zoom_3 steam_zoom" 250 1540 -justify right -anchor "nw" -text [translate "Auto-Off"] -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam_zoom_3 steam_zoom" 230 1540 -justify left -anchor "ne" -font Helv_7 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}

	add_de1_text "steam_zoom_3 steam_zoom" 870 1440 -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam_zoom_3 steam_zoom" 850 1440 -justify left -anchor "ne" -font Helv_7 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[steamtemp_text]} 
		#add_de1_variable "steam_zoom_3 steam_zoom" 700 1440 -justify left -anchor "ne" -font Helv_7 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[round_to_integer $::de1(steam_heater_temperature)]} 

	add_de1_text "steam_zoom_3 steam_zoom" 870 1490 -justify right -anchor "nw" -text [translate "Pressure (bar)"] -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam_zoom_3 steam_zoom" 850 1490 -justify left -anchor "ne" -font Helv_7 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[pressure_text]} 
	add_de1_text "steam_zoom_3 steam_zoom" 870 1540 -justify right -anchor "nw" -text [translate "Flow rate"] -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam_zoom_3 steam_zoom" 850 1540 -justify left -anchor "ne" -text "" -font Helv_7 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 

	# stop button when zoomed on steam
	add_de1_variable "steam_zoom" 2100 1510 -text "\[ [translate "STOP"] \]" -font $green_button_font -fill "#2d3046" -anchor "center"  -textvariable {\[ [stop_text_if_espresso_stoppable] \]} 
	add_de1_button "steam_zoom" {say [translate {stop}] $::settings(sound_button_in); set_next_page off steam_3; start_idle; check_if_steam_clogged} 0 1410 2560 1600


	# when steam is off, display current steam heater temp
	add_de1_text "steam_1" 1100 1270 -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_8 -fill "#969eb1" -width [rescale_x_skin 520]
		add_de1_variable "steam_1" 1680 1270 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#969eb1" -width [rescale_x_skin 520] -textvariable {[steamtemp_text]} 


# optional keyboard bindings
focus .can
bind Canvas <KeyPress> {handle_keypress %k}

profile_has_changed_set_colors

proc skins_page_change_due_to_de1_state_change { textstate } {
	page_change_due_to_de1_state_change $textstate

	if {$textstate == "Steam"} {
		set_next_page off steam_3; 
	} elseif {$textstate == "Espresso"} {
		set_next_page off espresso_3; 
	} elseif {$textstate == "HotWater"} {
		set_next_page off water_3; 
	} elseif {$textstate == "HotWaterRinse"} {
		set_next_page off preheat_3; 
	}
}


# feature disabled until flowmeter reporting over BLE is implemented
#add_de1_text "steam" 1870 450 -justify right -anchor "nw" -text [translate "Total volume"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
#add_de1_variable "steam" 2470 450 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 

#set_next_page off steam_zoom;
##
