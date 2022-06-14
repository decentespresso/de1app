set ::debugging 0

#msg "rtl $::de1(language_rtl)"

package require de1plus 1.0

source "[homedir]/skins/default/standard_includes.tcl"

namespace eval ::skin::insight::graph {}

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

# the font used in the big round green buttons needs to fit appropriately inside the circle, 
# and thus is dependent on the translation of the words inside the circle
set green_button_font "Helv_18_bold"
set label_font "Helv_10_bold"
set listbox_font "Helv_10"

if {[language] == "ar"} {
	set green_button_font "Helv_17_bold"
	set label_font "Helv_15_bold"
	set listbox_font "Helv_7_bold"
} elseif {[language] == "zh-hans" || [language] == "zh-hant" || [language] == "kr"} {
	set green_button_font "Helv_17_bold"
	set label_font "Helv_15_bold"
} elseif {[language] == "he"} {
	set green_button_font "Helv_15_bold"
	set label_font "Helv_15_bold"
	set listbox_font "Helv_7_bold"
} elseif {[language] != "en" && [language] != "kr" && [language] != "zh-hans" && [language] != "zh-hant"} {
	set green_button_font "Helv_15_bold"
}

# lighter grey, matches icons
set toptab_selected_color "#2d3046"
set toptab_unselected_color "#8c8d96"
set startbutton_font_color "#2d3046"
set chart_background "#FFFFFF"
set steam_control_background "#d7d9e5"
set steam_control_foreground "#e8e1df"
set water_level_widget_background "#f2f2fc"
set water_level_widget_background_espresso "#ededfa"
set progress_text_color "#5a5d75"
set tappable_text_color "#4e85f4"
set noprogress_text_color "#b1b9cd"
set dark "#5a5d75"
set ::lighter "#969eb1"
set lightest "#bec7db"

set ::pressurelinecolor "#00b672"
set ::flow_line_color "#6c9bff"
set ::temperature_line_color "#ff7880"

set ::pressurelinecolor_god "#5deea6"
set ::flow_line_color_god "#a7d1ff"
set ::temperature_line_color_god "#ffafb4"

set ::pressurelabelcolor "#00b672"
set ::temperature_label_color "#ff7880"
set ::flow_label_color "#6c9bff"
set ::grid_color "#E0E0E0"
set datacard_data_color "#42465c"


if {[ifexists ::insight_dark_mode] == 1} {
	set ::pressurelinecolor "#50c17b"
	set ::flow_line_color "#7ca8ff"
	set ::temperature_line_color "#ff5a67"

	set ::pressurelinecolor_god "#007032"
	set ::flow_line_color_god "#175baa"
	set ::temperature_line_color_god "#a10024"


	set ::pressurelabelcolor "#50c17b"
	set ::temperature_label_color "#ff5a67"
	set ::flow_label_color "#7ca8ff"

	set dark "#c2c5e1"
	set ::lighter "#a3abbf"
	set lightest "#bec7db"
	set toptab_selected_color "#aeb0b1"
	set toptab_unselected_color "#4f5254"
	set startbutton_font_color "#aeb0b1"
	set chart_background "#272d32"
	set steam_control_background "#14181b"
	set steam_control_foreground "#676b6e"
	set water_level_widget_background "#22272c"
	set water_level_widget_background_espresso "#1f2429"
	set ::grid_color "#444444"
	set progress_text_color "#b1b9cd"
	set datacard_data_color "#8b90a8"
	set noprogress_text_color "#5a5d75"
}


set ::current_espresso_page "off"

# the position of each text string is somewhat dependent on the icon to the left of it, and how much space that icon takes up
set flush_button_text_position 380
set espresso_button_text_position 1040
set steam_button_text_position 1646
set hotwater_button_text_position 2276


# darker grey, easier to read
#set toptab_unselected_color "#5a5d75"

# labels for PREHEAT tab on
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" $flush_button_text_position 100 -text [translate "FLUSH"] -font $label_font -fill $toptab_selected_color -anchor "center" 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" $espresso_button_text_position 100 -text [translate "ESPRESSO"] -font $label_font -fill $toptab_unselected_color -anchor "center" 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" $steam_button_text_position 100 -text [translate "STEAM"] -font $label_font -fill $toptab_unselected_color -anchor "center" 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" $hotwater_button_text_position 100 -text [translate "WATER"] -font $label_font -fill $toptab_unselected_color -anchor "center" 


# labels for ESPRESSO tab on
add_de1_text "off espresso espresso_3" $flush_button_text_position 100 -text [translate "FLUSH"] -font $label_font -fill $toptab_unselected_color -anchor "center" 
add_de1_text "off espresso espresso_3" $espresso_button_text_position 100 -text [translate "ESPRESSO"] -font $label_font -fill $toptab_selected_color -anchor "center" 
add_de1_text "off espresso espresso_3" $steam_button_text_position 100 -text [translate "STEAM"] -font $label_font -fill $toptab_unselected_color -anchor "center" 
add_de1_text "off_zoomed espresso_3_zoomed espresso_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" 2350 90 -text [translate "STEAM"] -font $label_font -fill $toptab_unselected_color -anchor "center" 
add_de1_text "off espresso espresso_3" $hotwater_button_text_position 100 -text [translate "WATER"] -font $label_font -fill $toptab_unselected_color -anchor "center" 

# labels for STEAM tab on
add_de1_text "steam steam_1 steam_3 steam_zoom_3 steam_zoom" $flush_button_text_position 100 -text [translate "FLUSH"] -font $label_font -fill $toptab_unselected_color -anchor "center" 
add_de1_text "steam steam_1 steam_3 steam_zoom_3 steam_zoom" $espresso_button_text_position 100 -text [translate "ESPRESSO"] -font $label_font -fill $toptab_unselected_color -anchor "center" 
add_de1_text "steam steam_1 steam_3 steam_zoom_3 steam_zoom" $steam_button_text_position 100 -text [translate "STEAM"] -font $label_font -fill $toptab_selected_color -anchor "center" 
add_de1_text "steam steam_1 steam_3 steam_zoom_3 steam_zoom" $hotwater_button_text_position 100 -text [translate "WATER"] -font $label_font -fill $toptab_unselected_color -anchor "center" 

# labels for HOT WATER tab on
add_de1_text "water water_1 water_3" $flush_button_text_position 100 -text [translate "FLUSH"] -font $label_font -fill $toptab_unselected_color -anchor "center" 
add_de1_text "water water_1 water_3" $espresso_button_text_position 100 -text [translate "ESPRESSO"] -font $label_font -fill $toptab_unselected_color -anchor "center" 
add_de1_text "water water_1 water_3" $steam_button_text_position 100 -text [translate "STEAM"] -font $label_font -fill $toptab_unselected_color -anchor "center" 
add_de1_text "water water_1 water_3" $hotwater_button_text_position 100 -text [translate "WATER"] -font $label_font -fill $toptab_selected_color -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "off espresso_3 steam_1 steam_3 steam_zoom_3 water_1 water_3 water_4" {say [translate {Flush}] $::settings(sound_button_in); set_next_page off preheat_1; page_show preheat_1; if {$::settings(one_tap_mode) == 1} { set_next_page hotwaterrinse preheat_2; start_flush } } 0 0 641 188
add_de1_button "preheat_1 preheat_3 preheat_4 steam_1 steam_3 steam_zoom_3 water_1 water_3 water_4" {say [translate {espresso}] $::settings(sound_button_in); set_next_page off $::current_espresso_page; if {$::settings(one_tap_mode) == 1} { start_espresso }; page_show off;  } 642 0 1277 188
add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 water_1 water_3 water_4" {say [translate {steam}] $::settings(sound_button_in); set_next_page off steam_1; page_show off; if {$::settings(one_tap_mode) == 1} { start_steam } } 1278 0 1904 188
add_de1_button "off_zoomed espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {steam}] $::settings(sound_button_in); set_next_page off steam_1; page_show off; if {$::settings(one_tap_mode) == 1} { start_steam } } 2020 0 2550 180
add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 steam_zoom_3" {say [translate {water}] $::settings(sound_button_in); set_next_page off water_1; page_show off; if {$::settings(one_tap_mode) == 1} { start_water } } 1905 0 2560 188

# when the espresso machine is doing something, the top tabs have to first stop that function, then the tab can change
add_de1_button "steam steam_zoom water espresso espresso_3" {say [translate {Heat up}] $::settings(sound_button_in);set_next_page off preheat_1; start_idle; if {$::settings(one_tap_mode) == 1} { set_next_page hotwaterrinse preheat_2; start_flush } } 0 0 641 188
add_de1_button "preheat_2 steam steam_zoom water" {say [translate {espresso}] $::settings(sound_button_in);set ::current_espresso_page off; set_next_page $::current_espresso_page off; start_idle; if {$::settings(one_tap_mode) == 1} { start_espresso } } 642 0 1277 188
add_de1_button "preheat_2 water espresso espresso_3 steam steam_zoom" {say [translate {steam}] $::settings(sound_button_in);set_next_page off steam_1; start_idle; if {$::settings(one_tap_mode) == 1} { start_steam } } 1278 0 1904 188
add_de1_button "espresso_zoomed espresso_zoomed_temperature" {say [translate {steam}] $::settings(sound_button_in); set_next_page off steam_1; page_show off; start_idle; if {$::settings(one_tap_mode) == 1} { start_steam } } 2020 0 2550 180
add_de1_button "preheat_2 steam steam_zoom espresso espresso_3" {say [translate {water}] $::settings(sound_button_in);set_next_page off water_1; start_idle; if {$::settings(one_tap_mode) == 1} { start_water } } 1905 0 2560 188


################################################################################################################################################################################################################################################################################################
# espresso charts

set charts_width 1990

	
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
	set ::skin::insight::graph::pressure $widget

	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color $::pressurelinecolor  -smooth $::settings(live_graph_smoothing_technique)  -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::pressurelinecolor  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create god_line_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 20] -color $::pressurelinecolor_god  -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0 ; 

	# show the explanation
	$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure  -label "" -linewidth [rescale_x_skin 15] -color $::pressurelinecolor  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 
	
	#$widget element create line_espresso_de1_explanation_chart_pressure_part1 -xdata espresso_de1_explanation_chart_elapsed_1 -ydata espresso_de1_explanation_chart_pressure_1 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	#$widget element create line_espresso_de1_explanation_chart_pressure_part2 -xdata espresso_de1_explanation_chart_elapsed_2 -ydata espresso_de1_explanation_chart_pressure_2 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	#$widget element create line_espresso_de1_explanation_chart_pressure_part3 -xdata espresso_de1_explanation_chart_elapsed_3 -ydata espresso_de1_explanation_chart_pressure_3 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 

	if {$::settings(display_pressure_delta_line) == 1} {
		$widget element create line_espresso_pressure_delta2  -xdata espresso_elapsed -ydata espresso_pressure_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #40dc94 -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	gridconfigure $widget 

	$widget axis configure x -color $::pressurelabelcolor -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	#msg "axis [join [lsort [$widget configure]] \n]"
	$widget axis configure y -color $::pressurelabelcolor -tickfont Helv_6 -min 0.0 -max [expr {$::de1(max_pressure) + 0.01}] -subdivisions 5 -majorticks {1 3 5 7 9 11} 
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -max 10
} -plotbackground $chart_background -width [rescale_x_skin $charts_width] -height [rescale_y_skin 406] -borderwidth 1 -background $chart_background -plotrelief flat -plotpady 0 -plotpadx 10  

add_de1_widget "off espresso espresso_1 espresso_2 espresso_3" graph 20 723 {
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed; 
		set_next_page espresso espresso_zoomed; 
		set_next_page espresso_3 espresso_3_zoomed; 
		page_show $::de1(current_context);
	}
	set ::skin::insight::graph::flow $widget

	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color $::flow_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5}; 

	$widget element create line_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::flow_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  


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

	$widget element create god_line_espresso_flow  -xdata espresso_elapsed -ydata god_espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 24] -color $::flow_line_color_god -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0; 
	$widget axis configure x -color $::flow_label_color -tickfont Helv_6 ; 

	$widget axis configure y -color $::flow_label_color -tickfont Helv_6 -min 0.0 -max 8.01 -subdivisions 2 -majorticks {1 2 3 4 5 6 7 8}
	gridconfigure $widget 

	# show the shot configuration
	$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -label "" -linewidth [rescale_x_skin 15] -color $::flow_line_color  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 
	#$widget element create line_espresso_de1_explanation_chart_flow_part1 -xdata espresso_de1_explanation_chart_elapsed_flow_1 -ydata espresso_de1_explanation_chart_flow_1 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	#$widget element create line_espresso_de1_explanation_chart_flow_part2 -xdata espresso_de1_explanation_chart_elapsed_flow_2 -ydata espresso_de1_explanation_chart_flow_2 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	#$widget element create line_espresso_de1_explanation_chart_flow_part3 -xdata espresso_de1_explanation_chart_elapsed_flow_3 -ydata espresso_de1_explanation_chart_flow_3 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 

} -width [rescale_x_skin $charts_width] -height [rescale_y_skin 410]  -plotbackground $chart_background -borderwidth 1 -background $chart_background -plotrelief flat  -plotpady 0  -plotpady 0 -plotpadx 10 


add_de1_widget "off espresso espresso_1 espresso_2 espresso_3" graph 20 1174 {
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page off off_zoomed_temperature; 
		set_next_page espresso espresso_zoomed_temperature; 
		set_next_page espresso_3 espresso_3_zoomed_temperature; 
		page_show $::de1(current_context);
	}
	set ::skin::insight::graph::temperature $widget

	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 8] -color $::temperature_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 12] -color $::temperature_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	#$widget element create line_espresso_temperature_mix -xdata espresso_elapsed -ydata espresso_temperature_mix -symbol none -label ""  -linewidth [rescale_x_skin 2] -color #ffc2c1 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 
	#-dashes $::settings(chart_dashes_temperature_mix);  

	$widget element create line_espresso_de1_explanation_chart_temp -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_temperature  -label "" -linewidth [rescale_x_skin 15] -color $::temperature_line_color  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 


	$widget element create god_line_espresso_temperature_basket -xdata espresso_elapsed -ydata god_espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 24] -color $::temperature_line_color_god -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0 ; 


	$widget axis configure x -color $::temperature_label_color -tickfont Helv_6; 
	$widget axis configure y -color $::temperature_label_color -tickfont Helv_6 -subdivisions 5; 
	set ::temperature_chart_widget $widget
	gridconfigure $widget 
} -width [rescale_x_skin $charts_width] -height [rescale_y_skin 410]  -plotbackground $chart_background -borderwidth 0 -background $chart_background -plotrelief flat -plotpady 0 -plotpadx 10


####

add_de1_text "off_zoomed espresso_zoomed espresso_3_zoomed" 40 30 -text [translate "Flow (mL/s)"] -font Helv_7_bold -fill $::flow_label_color -justify "left" -anchor "nw"
#add_de1_text "off_zoomed espresso_zoomed espresso_3_zoomed" 1600 30 -text [translate "Puck resistance"] -font Helv_7_bold -fill "#d2d200" -justify "left" -anchor "ne"
add_de1_widget "off_zoomed espresso_zoomed espresso_3_zoomed" checkbutton 1300 30 {} -text [translate "Resistance"] -indicatoron true  -font Helv_7_bold -bg $chart_background -anchor nw -foreground #d2d200 -variable ::settings(resistance_curve)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground $chart_background  -bd 0 -activeforeground #d2d200 -relief flat -bd 0 -justify "left"  -command {should_hide_show_puck_resistance_line; save_settings } 

add_de1_text "off_zoomed espresso_zoomed espresso_3_zoomed" 1970 30 -text [translate "Pressure (bar)"] -font Helv_7_bold -fill $::pressurelabelcolor -justify "left" -anchor "ne"

add_de1_text "off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" 40 30 -text [translate "Temperature ([return_html_temperature_units])"] -font Helv_7_bold -fill $::temperature_label_color -justify "left" -anchor "nw"

add_de1_text "off espresso espresso_3" 40 220 -text [translate "Pressure (bar)"] -font Helv_7_bold -fill $::pressurelabelcolor -justify "left" -anchor "nw"

add_de1_text "off espresso espresso_3" 40 677 -text [translate "Flow (mL/s)"] -font Helv_7_bold -fill $::flow_label_color -justify "left" -anchor "nw"
if {$::settings(scale_bluetooth_address) != ""} {
	add_de1_text "off espresso espresso_3" 1970 677 -text [translate "Weight (g/s)"] -font Helv_7_bold -fill "#a2693d" -justify "left" -anchor "ne" 


	#add_de1_text "off_zoomed espresso_zoomed espresso_3_zoomed" 700 30 -text [translate "Weight (g/s)"] -font Helv_7_bold -fill "#a2693d" -justify "left" -anchor "ne" 	
	add_de1_widget "off_zoomed espresso_zoomed espresso_3_zoomed" checkbutton 480 30 {} -text [translate "Weight (g/s)"] -indicatoron true  -font Helv_7_bold -bg $chart_background -anchor nw -foreground #a2693d -variable ::settings(weight_detail_curve)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground $chart_background  -bd 0 -activeforeground #a2693d -relief flat -bd 0 -justify "left"  -command {should_hide_show_weight_detail_line; save_settings } 
}

add_de1_text "off espresso espresso_3" 40 1128 -text [translate "Temperature ([return_html_temperature_units])"] -font Helv_7_bold -fill $::temperature_label_color -justify "left" -anchor "nw"



#######################
# zoomed espresso
add_de1_widget "off_zoomed espresso_zoomed espresso_3_zoomed" graph 20 78 {

	set ::espresso_zoomed_graph $widget

	bind $widget [platform_button_press] { 

		set x [translate_coordinates_finger_down_x %x]
		set y [translate_coordinates_finger_down_y %y]

		#msg "100 = [rescale_y_skin 200] = %y = [rescale_y_skin 726]"
		if {$x < [rescale_y_skin 800]} {
			# left column clicked on chart, indicates zoom

			if {$y > [rescale_y_skin 726]} {
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
	set ::skin::insight::graph::combined_zoomed $widget


	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color $::pressurelinecolor  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::pressurelinecolor  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 

	if {$::settings(display_pressure_delta_line) == 1} {
		$widget element create line_espresso_pressure_delta_1  -xdata espresso_elapsed -ydata espresso_pressure_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color #40dc94 -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	$widget element create line_espresso_flow_goal_2x  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color $::flow_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5}; 
	$widget element create line_espresso_flow_2x  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::flow_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes $::settings(chart_dashes_flow);   
	$widget element create god_line_espresso_flow_2x  -xdata espresso_elapsed -ydata god_espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 24] -color $::flow_line_color_god -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 



	if {$::settings(chart_total_shot_flow) == 1} {
		$widget element create line_espresso_total_flow  -xdata espresso_elapsed -ydata espresso_water_dispensed -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::flow_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);
		
	}


	if {$::settings(display_flow_delta_line) == 1} {
		$widget element create line_espresso_flow_delta_1  -xdata espresso_elapsed -ydata espresso_flow_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color $::flow_line_color -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	if {$::settings(scale_bluetooth_address) != ""} {
		$widget element create line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 8] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
		$widget element create line_espresso_flow_weight_raw_2x  -xdata espresso_elapsed -ydata espresso_flow_weight_raw -symbol none -label "" -linewidth [rescale_x_skin 2] -color #f8b888 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -hide yes; 
		$widget element create god_line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata god_espresso_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 16] -color #edd4c1 -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 

		if {$::settings(chart_total_shot_weight) == 1 || $::settings(chart_total_shot_weight) == 2} {
			$widget element create line_espresso_weight_2x  -xdata espresso_elapsed -ydata espresso_weight_chartable -symbol none -label "" -linewidth [rescale_x_skin 6] -color #f8b888 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);  
		}

		# when using Resistance calculated from the flowmeter, use a solid line to indicate it is well measured
		#$widget element create line_espresso_resistance  -xdata espresso_elapsed -ydata espresso_resistance_weight -symbol none -label "" -linewidth [rescale_x_skin 4] -color #e5e500 -smooth $::settings(live_graph_smoothing_technique) -pixels 0  

	} else {

		# when using Resistance calculated from the flowmeter, use a dashed line to indicate it is approximately measured
	}

	$widget element create line_espresso_resistance_dashed  -xdata espresso_elapsed -ydata espresso_resistance -symbol none -label "" -linewidth [rescale_x_skin 4] -color #e5e500 -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {6 2} -hide no 

	$widget element create god_line2_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 24] -color $::pressurelinecolor_god  -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0 ; 

	$widget axis configure x -color $::lighter -tickfont Helv_7_bold; 
	#$widget axis configure y2 -color #008c4c -tickfont Helv_7_bold -min 0.0 -max $::de1(max_pressure) -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12}  -hide 0;
	$widget axis configure y -color $::lighter -tickfont Helv_7_bold -min 0.0 -max $::settings(zoomed_y_axis_scale) -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20} -hide 0; 

	# show the explanation for pressure
	$widget element create line_espresso_de1_explanation_chart_pressure_zoomed -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure  -label "" -linewidth [rescale_x_skin 16] -color $::pressurelinecolor  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 

	#$widget element create line_espresso_de1_explanation_chart_pressure_part1 -xdata espresso_de1_explanation_chart_elapsed_1 -ydata espresso_de1_explanation_chart_pressure_1 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	#$widget element create line_espresso_de1_explanation_chart_pressure_part2 -xdata espresso_de1_explanation_chart_elapsed_2 -ydata espresso_de1_explanation_chart_pressure_2 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	#$widget element create line_espresso_de1_explanation_chart_pressure_part3 -xdata espresso_de1_explanation_chart_elapsed_3 -ydata espresso_de1_explanation_chart_pressure_3 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 

	# show the explanation for flow
	#$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow -symbol circle -label "" -linewidth [rescale_x_skin 5] -color #888888  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	$widget element create line_espresso_de1_explanation_chart_flow_zoom -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow  -label "" -linewidth [rescale_x_skin 18] -color $::flow_line_color  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 

	#$widget element create line_espresso_de1_explanation_chart_flow_part1 -xdata espresso_de1_explanation_chart_elapsed_flow_1 -ydata espresso_de1_explanation_chart_flow_1 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_1)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	#$widget element create line_espresso_de1_explanation_chart_flow_part2 -xdata espresso_de1_explanation_chart_elapsed_flow_2 -ydata espresso_de1_explanation_chart_flow_2 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_2)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	#$widget element create line_espresso_de1_explanation_chart_flow_part3 -xdata espresso_de1_explanation_chart_elapsed_flow_3 -ydata espresso_de1_explanation_chart_flow_3 -symbol circle -label "" -linewidth [rescale_x_skin 50] -color $::settings(color_stage_3)  -smooth $::settings(profile_graph_smoothing_technique) -pixels [rescale_x_skin 30]; 
	gridconfigure $widget 

	#$widget axis configure y2 -color #206ad4 -tickfont Helv_6 -gridminor 0 -min 0.0 -max $::de1(max_flowrate) -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6} -hide 0; 
} -plotbackground $chart_background -width [rescale_x_skin 1990] -height [rescale_y_skin 1510] -borderwidth 1 -background $chart_background -plotrelief flat -plotpady 0 -plotpadx 10


proc obs_toggle_hide_show_puck_resistance_line {} {
	if {[ifexists ::settings(resistance_curve)] == 1} {
		set ::settings(resistance_curve) 0
	} else {
		set ::settings(resistance_curve) 1
	}

	should_hide_show_puck_resistance_line
}

proc should_hide_show_puck_resistance_line {} {

	if {[ifexists ::settings(resistance_curve)] == 1} {
		catch {
			$::espresso_zoomed_graph element configure line_espresso_resistance_dashed -hide no
		}
	} else {
		catch {
			$::espresso_zoomed_graph element configure line_espresso_resistance_dashed -hide yes
		}
	}
}
should_hide_show_puck_resistance_line


proc should_hide_show_weight_detail_line {} {
	if {$::settings(scale_bluetooth_address) != ""} {
		if {[ifexists ::settings(weight_detail_curve)] == 1} {
			catch {
				$::espresso_zoomed_graph element configure line_espresso_flow_weight_raw_2x -hide no
			}
		} else {
			catch {
				$::espresso_zoomed_graph element configure line_espresso_flow_weight_raw_2x -hide yes
			}
		}
	}
}
should_hide_show_weight_detail_line

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
	set ::skin::insight::graph::temperature_zoomed $widget

	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 6] -color $::temperature_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color $::temperature_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	$widget element create god_line_espresso_temperature_basket -xdata espresso_elapsed -ydata god_espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 20] -color $::temperature_line_color_god -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_temperature_mix2 -xdata espresso_elapsed -ydata espresso_temperature_mix -symbol none -label ""  -linewidth [rescale_x_skin 2] -color $::temperature_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0 
	$widget element create line_espresso_de1_explanation_chart_temp -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_temperature  -label "" -linewidth [rescale_x_skin 15] -color $::temperature_line_color  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 

	$widget element create line_espresso_state_change_4 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0 ; 
	$widget axis configure x -color $::temperature_label_color -tickfont Helv_6; 
	$widget axis configure y -color $::temperature_label_color -tickfont Helv_6 -subdivisions 5; 
	set ::temperature_chart_zoomed_widget $widget

	gridconfigure $widget 	

} -plotbackground $chart_background -width [rescale_x_skin 1990] -height [rescale_y_skin 1516] -borderwidth 1 -background $chart_background -plotrelief flat -plotpady 0 -plotpadx 10

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
} 1 100 2012 1135

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
#
# using a buttonnativepress so that if running on Android, we can use the OS based filtering on spurious taps
add_de1_button "saver sleep descaling cleaning" {say [translate {awake}] $::settings(sound_button_in); set_next_page off off; page_show off; start_idle; de1_send_waterlevel_settings; } 0 0 2560 1600 "buttonnativepress"


if {$::debugging == 1} {
	#add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4 off_zoomed espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {sleep}] $::settings(sound_button_in); app_exit} 2014 1420 2284 1600
	add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 steam_zoom_3 water_1 water_3 water_4 off_zoomed espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {sleep}] $::settings(sound_button_in); set ::current_espresso_page "off"; start_sleep} 2014 1420 2284 1600
} else {
	add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 steam_zoom_3 water_1 water_3 water_4 off_zoomed espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {sleep}] $::settings(sound_button_in); set ::current_espresso_page "off"; start_sleep} 2014 1420 2284 1600
}
add_de1_text "sleep" 2500 1440 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 

# settings button 
add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed steam_1 water_1 preheat_1 steam_3 steam_zoom_3 water_3 preheat_3 preheat_4 off_zoomed_temperature espresso_3_zoomed_temperature" { say [translate {settings}] $::settings(sound_button_in); show_settings } 2285 1420 2560 1600

add_de1_variable "off off_zoomed off_zoomed_temperature" 2290 390 -text [translate "START"] -font $green_button_font -fill $startbutton_font_color -anchor "center" -textvariable {[start_text_if_espresso_ready]} 
add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" 2290 390 -text [translate "STOP"] -font $green_button_font -fill $startbutton_font_color -anchor "center" -textvariable {[stop_text_if_espresso_stoppable]} 
add_de1_variable "espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" 2290 390 -text [translate "RESTART"] -font $green_button_font -fill $startbutton_font_color -anchor "center" -textvariable {[espresso_history_save_from_gui]} 

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
	set ::skin::insight::graph::steam $widget

	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::pressurelinecolor  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::flow_line_color  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	$widget element create line_steam_flow_goal -xdata steam_elapsed -ydata steam_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::flow_line_color  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};

	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature100th -symbol none -label ""  -linewidth [rescale_x_skin 6] -color $::temperature_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color #888888 -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	$widget axis configure y -color #888888 -tickfont Helv_6 -min 0.0 
	gridconfigure $widget 
} -plotbackground $chart_background -width [rescale_x_skin 700] -height [rescale_y_skin 300] -borderwidth 1 -background $chart_background -plotrelief flat  -plotpady 0 -plotpadx 10

add_de1_widget "steam_3" graph 1810 1090 { 
	bind $widget [platform_button_press] { 
		say [translate {stop}] $::settings(sound_button_in); 
		say [translate {zoom}] $::settings(sound_button_in); 
		set_next_page steam_3 steam_zoom_3; 
		page_show $::de1(current_context);
	}
	set ::skin::insight::graph::steam_done $widget

	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::pressurelinecolor  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::flow_line_color  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	$widget element create line_steam_flow_goal -xdata steam_elapsed -ydata steam_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::flow_line_color  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature100th -symbol none -label ""  -linewidth [rescale_x_skin 6] -color $::temperature_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);   

	$widget axis configure x -color #888888 -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {1 2 3} 
	$widget axis configure y -color #888888 -tickfont Helv_6 -min 0.0
	gridconfigure $widget 
} -plotbackground $chart_background -width [rescale_x_skin 700] -height [rescale_y_skin 300] -borderwidth 1 -background $chart_background -plotrelief flat  -plotpady 0 -plotpadx 10


add_de1_widget "steam_zoom_3" graph 34 214 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam_3; 
		#set_next_page steam_zoom_3 steam_3; 
		set_next_page steam steam; 
		set_next_page steam_zoom_3 steam_3; 
		page_show $::de1(current_context);
	}
	set ::skin::insight::graph::steam_done_zoomed $widget

	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::pressurelinecolor  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::flow_line_color  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	$widget element create line_steam_flow_goal -xdata steam_elapsed -ydata steam_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::flow_line_color  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249  -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color #888888 -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3}  -title "[translate "Flow rate"] - [translate "Temperature"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #5a5d75;
	$widget axis configure y -color #888888 -tickfont Helv_6 -min 0.0 -title "[translate "Flow rate"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor $::lighter;
	gridconfigure $widget 
} -plotbackground $chart_background -width [rescale_x_skin 2490] -height [rescale_y_skin 700] -borderwidth 1 -background $chart_background -plotrelief flat  -plotpady 0 -plotpadx 10


add_de1_widget "steam_zoom_3" graph 34 914 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam_3; 
		#set_next_page steam_zoom_3 steam_3; 
		set_next_page steam steam; 
		set_next_page steam_zoom_3 steam_3; 
		page_show $::de1(current_context);
	}
	set ::skin::insight::graph::steam_done_temperature_zoomed $widget

	#$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	#$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color $::temperature_line_color  -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color #008c4c -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3}  -title "[translate "Flow rate"] - [translate "Temperature"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #5a5d75;
	
	if {$::settings(enable_fahrenheit) == 1} {
		$widget axis configure y -color #888888 -tickfont Helv_6 -min 250 -max 350 -title "[translate "Temperature"]" -titlefont Helv_7 -titlecolor $::lighter;
	} else {
		$widget axis configure y -color #888888 -tickfont Helv_6 -min 130 -max 180 -title "[translate "Temperature"]" -titlefont Helv_7 -titlecolor $::lighter;
	}
	gridconfigure $widget 
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 130 -max 180 -title "[translate "Temperature"]" -titlefont Helv_7 -titlecolor #5a5d75;
} -plotbackground $chart_background -width [rescale_x_skin 2490] -height [rescale_y_skin 490] -borderwidth 1 -background $chart_background -plotrelief flat  -plotpady 0 -plotpadx 10




add_de1_widget "steam_zoom" graph 34 214 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam; 
		#set_next_page steam_zoom_3 steam_3; 
		set_next_page steam steam; 
		set_next_page steam_zoom steam; 
		page_show $::de1(current_context);
	}
	set ::skin::insight::graph::steam_zoomed $widget

	$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::pressurelinecolor  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color $::flow_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	$widget element create line_steam_flow_goal -xdata steam_elapsed -ydata steam_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 6] -color $::flow_line_color -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color #888888 -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3}  -title "[translate "Flow rate"] - [translate "Temperature"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #5a5d75;
	$widget axis configure y -color #888888 -tickfont Helv_6 -min 0.0 -title "[translate "Flow rate"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor $::lighter;
	gridconfigure $widget 
} -plotbackground $chart_background -width [rescale_x_skin 2490] -height [rescale_y_skin 700] -borderwidth 1 -background $chart_background -plotrelief flat  -plotpady 0 -plotpadx 10



add_de1_widget "steam_zoom" graph 34 914 { 
	bind $widget [platform_button_press] { 
		say [translate {zoom}] $::settings(sound_button_in); 
		#set_next_page off steam; 
		#set_next_page steam_zoom_3 steam_3; 
		set_next_page steam steam; 
		set_next_page steam_zoom steam; 
		page_show $::de1(current_context);
	}
	set ::skin::insight::graph::steam_temperature_zoomed $widget

	#$widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 
	#$widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_flow);  
	$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color $::temperature_line_color	 -pixels 0 -dashes $::settings(chart_dashes_temperature);  
	#$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  

	$widget axis configure x -color #888888 -tickfont Helv_6 -linewidth [rescale_x_skin 2] 
	#$widget axis configure y -color #008c4c -tickfont Helv_6 -min 0.0 -max [expr {$::settings(max_steam_pressure) + 0.01}] -subdivisions 5 -majorticks {0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3}  -title "[translate "Flow rate"] - [translate "Temperature"] - [translate {pressure (bar)}]" -titlefont Helv_7 -titlecolor #5a5d75;
	if {$::settings(enable_fahrenheit) == 1} {
		$widget axis configure y -color #888888 -tickfont Helv_6 -min 250 -max 350 -title "[translate "Temperature"]" -titlefont Helv_7 -titlecolor $::lighter;
	} else {
		$widget axis configure y -color #888888 -tickfont Helv_6 -min 130 -max 180 -title "[translate "Temperature"]" -titlefont Helv_7 -titlecolor $::lighter;
	}
	gridconfigure $widget 
} -plotbackground $chart_background -width [rescale_x_skin 2490] -height [rescale_y_skin 490] -borderwidth 1 -background $chart_background -plotrelief flat  -plotpady 0 -plotpadx 10


##########################################################################################################################################################################################################################################################################
# data card displayed during espresso making

set pos_top 720
set spacer 38
#set paragraph 20

set column2 2195
if {$::settings(enable_fahrenheit) == 1} {
	set column2 2210
}

set column1_pos 2060
set column3_pos 2512

if {$::settings(waterlevel_indicator_on) == 1} {
	# water level sensor on espresso page

	add_de1_widget "off espresso espresso_3 off_zoomed espresso_zoomed espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" scale 2546 190 {water_level_color_check $widget} -from $::settings(water_level_sensor_max) -to 10 -background $chart_background -foreground $chart_background -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_y_skin 496] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor $water_level_widget_background_espresso -borderwidth 0  -highlightthickness 0

	# water level sensor on other tabs page (white background)
	add_de1_widget "preheat_2 preheat_3 preheat_4 steam steam_3 steam_zoom steam_zoom_3 water water_3 water_4" scale 2510 226 {after 1000 water_level_color_check $widget} -from $::settings(water_level_sensor_max) -to 10 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_y_skin 1166] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor $water_level_widget_background -borderwidth 0  -highlightthickness 0

	# water level sensor on other tabs page (light blue background)
	add_de1_widget "preheat_1 steam_1 water_1" scale 2510 226 {after 1000 water_level_color_check $widget} -from $::settings(water_level_sensor_max) -to 10 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_y_skin 1166] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor $water_level_widget_background -borderwidth 0  -highlightthickness 0
}


add_de1_text "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "nw" -text [translate "Time"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]
	add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $::lighter -width [rescale_x_skin 520] -textvariable {[preinfusion_pour_timer_text]} 
	add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (3 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[total_pour_timer_text]}  
	add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (4 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -text "" -fill $::lighter -width [rescale_x_skin 520] -textvariable {[espresso_done_timer_text]} 
	add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $::lighter -width [rescale_x_skin 520] -textvariable {[pouring_timer_text]}  

#if {$::settings(display_volumetric_usage) == 1} {
	# temporarily disabled, because these use a different measurement technique than the DE1+ does, so they'll always be off
	add_de1_text "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (0 * $spacer)}] -justify right -anchor "ne" -text [translate "Volume"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]
		add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (1 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7  -fill $::lighter -width [rescale_x_skin 520] -textvariable {[preinfusion_volume]} 
		add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7  -fill $::lighter -width [rescale_x_skin 520] -textvariable {[pour_volume]}
		add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column3_pos [expr {$pos_top + (3 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 
#}


#######################
# temperature
add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (5.5 * $spacer)}] -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]
add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (4.5 * $spacer)}] -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]
	#add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column2 [expr {$pos_top + (5.5 * $spacer)}] -justify right -anchor "nw" -text [translate "goal"] -font Helv_7 -fill $::lighter -width [rescale_x_skin 520]
	#add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column2 [expr {$pos_top + (6.5 * $spacer)}] -justify right -anchor "nw" -text [translate "goal"] -font Helv_7 -fill $::lighter -width [rescale_x_skin 520]
	
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (5.5 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[espresso_goal_temp_text_rtl_aware]} 
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[espresso_goal_temp_text_rtl_aware]} 

	#add_de1_text "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column2 [expr {$pos_top + (7.5 * $spacer)}] -justify right -anchor "nw" -text [translate "metal"] -font Helv_7 -fill $::lighter -width [rescale_x_skin 520]
	add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature"  $column1_pos [expr {$pos_top + (7.5 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[group_head_heater_temperature_text_rtl_aware]} 
	#add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature"  $column1_pos [expr {$pos_top + (9 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {$::settings(settings_profile_type)} 

	if {$::settings(display_group_head_delta_number) == 1} {
		add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" 2380 [expr {$pos_top + (7.5 * $spacer)}] -justify left -anchor "ne" -font Helv_7 -fill $lightest -width [rescale_x_skin 520] -textvariable {[return_delta_temperature_measurement [diff_group_temp_from_goal]]} 
	}

	#add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column2 [expr {$pos_top + (6.5 * $spacer)}] -justify right -anchor "nw" -text [translate "coffee"] -font Helv_7 -fill $::lighter -width [rescale_x_skin 520]
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[coffee_temp_text_rtl_aware]} 

	#if {$::settings(show_mixtemp_during_espresso) == 1} {
	#	add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column2 [expr {$pos_top + (7.5 * $spacer)}] -justify right -anchor "nw" -text [translate "water"] -font Helv_7 -fill $::lighter -width [rescale_x_skin 520]
#		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (7.5 * $spacer)}] -justify left -anchor "nw" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[mixtemp_text]} 
	#}

	
	if {$::settings(display_espresso_water_temp_difference) == 1} {
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "ne" -text "" -font Helv_7 -fill $lightest -width [rescale_x_skin 520] -textvariable {[return_delta_temperature_measurement [diff_espresso_temp_from_goal]]} 
			add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos [expr {$pos_top + (7.5 * $spacer)}] -justify left -anchor "ne" -font Helv_7 -fill $lightest -width [rescale_x_skin 520] -textvariable {[return_delta_temperature_measurement [diff_brew_temp_from_goal] ]} 
			# thermometer widget from http://core.tcl.tk/bwidget/doc/bwidget/BWman/index.html
		    add_de1_widget "espresso espresso_zoomed espresso_zoomed_temperature" ProgressBar 2390 [expr {$pos_top + (8.7 * $spacer)}] {} -width [rescale_y_skin 108] -height [rescale_x_skin 16] -type normal  -variable ::positive_diff_brew_temp_from_goal -fg #ff8888 -bg $chart_background -maximum 10 -borderwidth 1 -relief flat
	}
#######################
	#add_de1_widget "off espresso espresso_3 off_zoomed espresso_zoomed espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" scale 2528 694 {after 1000 water_level_color_check $widget} -from 40 -to 5 -background #7ad2ff -foreground #0000FF -borderwidth 1 -bigincrement .1 -resolution .1 -length [rescale_x_skin 594] -showvalue 0 -width [rescale_y_skin 16] -variable ::de1(water_level) -state disabled -sliderrelief flat -font Helv_10_bold -sliderlength [rescale_x_skin 50] -relief flat -troughcolor $chart_background -borderwidth 0  -highlightthickness 0



#######################
# flow 
add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (8 * $spacer)}] -justify right -anchor "nw" -text [translate "Flow"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]
	#add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (6.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[watervolume_text] [translate "total"]} 
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (9 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 
	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (10 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[pressure_text]} 
#######################

#######################
# weight
add_de1_variable "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (12.5 * $spacer)}] -justify right -anchor "nw" -font Helv_7_bold -fill $dark -width [rescale_x_skin 520] -textvariable {[waterweight_label_text]}
	#add_de1_variable "" $column1_pos [expr {$pos_top + (14 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[drink_weight_text]}
	add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (13.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[if {$::de1(scale_sensor_weight) == ""} { return "" } elseif {$::settings(scale_bluetooth_address) != "" && $::settings(final_desired_shot_weight) > 0 && ($::settings(settings_profile_type) == "settings_2a" || $::settings(settings_profile_type) == "settings_2b")} {
			return "[finalwaterweight_text] < [return_stop_at_weight_measurement $::settings(final_desired_shot_weight)]"
		} elseif {$::settings(scale_bluetooth_address) != "" && $::settings(final_desired_shot_weight_advanced) > 0 && $::settings(settings_profile_type) == "settings_2c"} {
			return "[drink_weight_text] < [return_stop_at_weight_measurement $::settings(final_desired_shot_weight_advanced)]"			
		} else {
			return "[drink_weight_text]"
		}]}  


	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (17.5 * $spacer)}] -justify right -anchor "nw" -font Helv_7_bold -fill $dark -width [rescale_x_skin 520] -textvariable {[waterweight_label_text]}
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (18.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[waterweightflow_text]} 
	
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (19.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::lighter -width [rescale_x_skin 520] -textvariable {[if {$::de1(scale_sensor_weight) == ""} { return "" } elseif {$::settings(scale_bluetooth_address) != "" && $::settings(final_desired_shot_weight) > 0 && ($::settings(settings_profile_type) == "settings_2a" || $::settings(settings_profile_type) == "settings_2b")} {
			return "[waterweight_text] < [return_stop_at_weight_measurement $::settings(final_desired_shot_weight)]"			
		} elseif {$::settings(scale_bluetooth_address) != "" && $::settings(final_desired_shot_weight_advanced) > 0 && $::settings(settings_profile_type) == "settings_2c"} {
			return "[waterweight_text] < [return_stop_at_weight_measurement $::settings(final_desired_shot_weight_advanced)]"			
		} else {
			return "[waterweight_text]"
		}]}  


			

		add_de1_variable "off off_zoomed espresso espresso_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_zoomed_temperature espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (2 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7  -fill $::lighter -width [rescale_x_skin 520] -textvariable {[pouring_timer_text]}  


		# progress bar docs http://npg.dl.ac.uk/MIDAS/manual/ActiveTcl8.5.7.0.290198-html/bwidget/ProgressBar.html
		add_de1_widget "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" ProgressBar $column1_pos 1310 {} -relief "flat" -troughcolor $chart_background -width [rescale_y_skin 420] -height [rescale_x_skin 2] -type normal  -variable ::de1(scale_weight_rate) -fg #a2693d -bg $chart_background -maximum 6 -borderwidth 0 -relief flat
	
	if {$::settings(scale_bluetooth_address) != ""} {
		set ::de1(scale_weight_rate) -1
		
		if {$::settings(insight_skin_show_weight_activity_bar) == 1} {
			add_de1_widget "espresso espresso_zoomed espresso_zoomed_temperature" ProgressBar 2390 [expr {$pos_top + (12.3 * $spacer)}] {} -width [rescale_y_skin 108] -height [rescale_x_skin 16] -type normal  -variable ::de1(scale_weight_rate) -fg #a2693d -bg $chart_background -maximum 6 -borderwidth 0 -relief flat
		}
	
		# scale ble reconnection button
		add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {connect}] $::settings(sound_button_in); catch {ble_connect_to_scale}} 2040 1190 2400 1400
	}

#######################


#######################
# profile name 
	# we can display the profile name if the embedded chart is not displayed.
	add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (9 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7_bold -fill $dark -width [rescale_x_skin 520] -textvariable {[profile_type_text]} 
		set ::globals(widget_current_profile_name1) [add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (10 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::lighter -textvariable {[wrapped_profile_string_part [profile_title] 29 0]} ]
		set ::globals(widget_current_profile_name2) [add_de1_variable "off off_zoomed off_zoomed_temperature espresso_3 espresso_3_zoomed espresso_3_zoomed_temperature" $column1_pos [expr {$pos_top + (11 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::lighter -textvariable {[wrapped_profile_string_part [profile_title] 29 1]} ]

	add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (11.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7_bold -fill $dark -width [rescale_x_skin 520] -textvariable {[profile_type_text]} 
		set ::globals(widget_current_profile_name_espresso1) [add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (12.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::lighter -textvariable {[wrapped_profile_string_part [profile_title] 29 0]} ]
		set ::globals(widget_current_profile_name_espresso2) [add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos [expr {$pos_top + (13.5 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill $::lighter -textvariable {[wrapped_profile_string_part [profile_title] 29 1]} ]

	# tap on profile name to go directly to settings choose page
	add_de1_button "off off_zoomed espresso_3 espresso_3_zoomed off_zoomed_temperature espresso_3_zoomed_temperature" {say [translate {describe}] $::settings(sound_button_in); if {$::settings(profile_has_changed) == 1} { save_profile } else { backup_settings; set_next_page off settings_1; page_show off; set_profiles_scrollbar_dimensions } } 2040 1072 2400 1180

	# current step description
	add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos  [expr {$pos_top + (15 * $spacer)}] -justify right -anchor "nw" -text [translate "Current step"] -font Helv_7_bold -fill $dark -width [rescale_x_skin 520]
		add_de1_variable "espresso espresso_zoomed espresso_zoomed_temperature" $column1_pos  [expr {$pos_top + (16 * $spacer)}] -justify left -anchor "nw" -text "" -font Helv_7 -fill "#8297be" -width [rescale_x_skin 440] -textvariable {$::settings(current_frame_description)} 
		add_de1_text "espresso espresso_zoomed espresso_zoomed_temperature" $column3_pos  [expr {$pos_top + (16 * $spacer)}] -justify left -anchor "ne" -text [translate "\[skip\]"] -font Helv_7 -fill "#8297be" -width [rescale_x_skin 440] 

	# optionally skip this step by tapping on the page curl graphic (bottom right corner)
	add_de1_button "espresso espresso_zoomed espresso_zoomed_temperature" {say [translate {skip}] $::settings(sound_button_in); borg toast [translate "Moved to next step"]; start_next_step;} 2020 1204 2560 1600



	
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
add_de1_button "espresso" {say [translate {stop}] $::settings(sound_button_in);set_next_page off espresso_3; start_idle;} 2020 240 2560 1200
add_de1_button "espresso_zoomed" {say [translate {stop}] $::settings(sound_button_in); set_next_page off espresso_3_zoomed; start_idle;} 2020 240 2560 1200
add_de1_button "espresso_zoomed_temperature" {say [translate {stop}] $::settings(sound_button_in); set_next_page off espresso_3_zoomed_temperature; start_idle;} 2020 240 2560 1200



##########################################################################################################################################################################################################################################################################


##########################################################################################################################################################################################################################################################################
# settings for preheating a cup

add_de1_variable "preheat_1" 1396 775 -text [translate "START"] -font $green_button_font -fill $startbutton_font_color -anchor "center" -textvariable {[start_text_if_espresso_ready]} 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 1396 865 -text [translate "FLUSH"] -font Helv_10 -fill "#7f879a" -anchor "center" 
add_de1_variable "preheat_2" 1396 775 -text [translate "STOP"] -font $green_button_font -fill $startbutton_font_color -anchor "center"  -textvariable {[stop_text_if_espresso_stoppable]} 
add_de1_variable "preheat_3 preheat_4" 1396 775 -text [translate "RESTART"] -font $green_button_font -fill $startbutton_font_color -anchor "center" -textvariable {[restart_text_if_espresso_ready]} 

#1030 210 1800 1400
add_de1_button "preheat_1 preheat_3 preheat_4" {say [translate {Heat up}] $::settings(sound_button_in); set ::settings(preheat_temperature) 90; set_next_page hotwaterrinse preheat_2; start_flush} 0 240 2560 1400
add_de1_button "preheat_2" {say [translate {stop}] $::settings(sound_button_in); set_next_page off preheat_4; start_idle} 0 240 2560 1600


set preheat_water_volume_feature_enabled 0
if {$preheat_water_volume_feature_enabled == 1} {
	add_de1_button "preheat_3 preheat_4" {say "" $::settings(sound_button_in); set_next_page off preheat_1; start_idle} 0 210 1000 1400
	add_de1_button "preheat_1" {say "" $::settings(sound_button_in);vertical_clicker 40 10 ::settings(preheat_volume) 10 250 %x %y %x0 %y0 %x1 %y1 %b; save_settings; de1_send_steam_hotwater_settings} 100 510 900 1200 ""
	add_de1_text "preheat_1" 70 250 -text [translate "1) How much water?"] -font Helv_9_bold -fill $progress_text_color -anchor "nw" -width [rescale_x_skin 900]
	add_de1_text "preheat_2 preheat_3 preheat_4" 70 250 -text [translate "1) How much water?"] -font Helv_9_bold -fill "#7f879a" -anchor "nw" -width [rescale_x_skin 900]
}
add_de1_text "preheat_1" 1070 250 -text [translate "1) Hot water will pour out"] -font Helv_9_bold -fill $progress_text_color -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "preheat_2" 1070 250 -text [translate "1) Hot water is pouring out"] -font Helv_9_bold -fill $progress_text_color -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "preheat_3 preheat_4" 1070 250 -text [translate "1) Hot water will pour out"] -font Helv_9_bold -fill $noprogress_text_color -anchor "nw" -width [rescale_x_skin 650]

#add_de1_text "preheat_1" 1840 250 -text [translate "2) Done"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 680]
add_de1_text "preheat_3 preheat_4" 1840 250 -text [translate "2) Done"] -font Helv_9_bold -fill $progress_text_color -anchor "nw" -width [rescale_x_skin 680]

if {$preheat_water_volume_feature_enabled == 1} {
	add_de1_variable "preheat_1" 540 1250 -text "" -font Helv_10_bold -fill $startbutton_font_color -anchor "center" -textvariable {[return_liquid_measurement $::settings(preheat_volume)]}
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
add_de1_variable "preheat_3 preheat_4" 2470 1250 -justify left -anchor "ne" -font Helv_8 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[if {[flush_done_timer] < $::settings(seconds_to_display_done_flush)} {return "[flush_done_timer][translate s]"} else { return ""}]} 

add_de1_text "preheat_3 preheat_4"  1870 1200 -justify right -anchor "nw" -text [translate "Metal temperature"] -font Helv_8 -fill  "#7f879a"  -width [rescale_x_skin 520]
add_de1_variable "preheat_3 preheat_4"  2470 1200  -justify left -anchor "ne" -font Helv_8 -fill  $datacard_data_color  -width [rescale_x_skin 520] -textvariable {[group_head_heater_temperature_text]} 
#add_de1_text "preheat_4"  1870 1200 -justify right -anchor "nw" -text [translate "Metal temperature"] -font Helv_8 -fill  "#7f879a"  -width [rescale_x_skin 520]
#add_de1_variable "preheat_4"  2470 1200  -justify left -anchor "ne" -font Helv_8 -fill  "#42465c"  -width [rescale_x_skin 520] -textvariable {[group_head_heater_temperature_text_rtl_aware]} 

add_de1_text "preheat_2" 1870 1250 -justify right -anchor "nw" -text [translate "Water temperature"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "preheat_2" 2470 1250 -justify left -anchor "ne" -font Helv_8 -fill $datacard_data_color -width [rescale_x_skin 520] -text "" -textvariable {[watertemp_text]} 

#add_de1_text "preheat_3" 1870 1250 -justify right -anchor "nw" -text [translate "Water temperature"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
#add_de1_variable "preheat_3" 2470 1250 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[watertemp_text]} 


add_de1_text "preheat_2 preheat_4" 1870 1300 -justify right -anchor "nw" -text [translate "Pouring"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "preheat_2 preheat_4" 2470 1300 -justify left -anchor "ne" -font Helv_8 -fill $datacard_data_color -width [rescale_x_skin 520] -text "" -textvariable {[flush_pour_timer][translate "s"]} 

#add_de1_text "preheat_4" 1870 1250 -justify right -anchor "nw" -text [translate "Pouring"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
#add_de1_variable "preheat_4" 2470 1250 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[flush_pour_timer][translate "s"]} 

# feature disabled until flowmeter reporting over BLE is implemented
#add_de1_text "preheat_3" 1880 1250 -justify right -anchor "nw" -text [translate "Total volume"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
#add_de1_variable "preheat_3" 2470 1250 -justify left -anchor "ne" -text "" -font Helv_8 -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 

##########################################################################################################################################################################################################################################################################

##########################################################################################################################################################################################################################################################################
# settings for dispensing hot water

# future feature
# add_de1_text "water_1 water_3" 1390 1270 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 

add_de1_variable "water_1" 1396 775 -text [translate "START"] -font $green_button_font -fill $startbutton_font_color -anchor "center" -textvariable {[start_text_if_espresso_ready]} 
add_de1_variable "water_3" 1396 775 -text [translate "RESTART"] -font $green_button_font -fill $startbutton_font_color -anchor "center" -textvariable {[restart_text_if_espresso_ready]} 
add_de1_variable "water" 1396 775 -text [translate "STOP"] -font $green_button_font -fill $startbutton_font_color -anchor "center"  -textvariable {[stop_text_if_espresso_stoppable]} 

add_de1_text "water_1 water water_3" 1396 865 -text [translate "WATER"] -font Helv_10 -fill "#7f879a" -anchor "center" 
add_de1_button "water_1 water_3" {say [translate {Hot water}] $::settings(sound_button_in); set_next_page water water; start_water} 1030 240 2560 1400
add_de1_button "water" {say [translate {stop}] $::settings(sound_button_in); set_next_page off water_3 ; start_idle} 0 240 2560 1600

# future feature
#add_de1_button "water_1 water_3" {say [translate {rinse}] $::settings(sound_button_in); set_next_page water water; start_water} 1030 1101 1760 1400

proc change_water_steam_settings { {discard {}} } {
	#puts change_water_steam_settings
	save_settings
	de1_send_steam_hotwater_settings
}

add_de1_button "water_1" {say "" $::settings(sound_button_in);vertical_clicker 40 10 ::settings(water_volume) 10 250 %x %y %x0 %y0 %x1 %y1 %b; change_water_steam_settings} 0 560 520 1170 ""
add_de1_button "water_1" {say "" $::settings(sound_button_in);vertical_clicker 9 1 ::settings(water_temperature) 20 110 %x %y %x0 %y0 %x1 %y1 %b; change_water_steam_settings} 551 450 1000 1180 ""

#add_de1_button "water_1" {say "" $::settings(sound_button_in);vertical_slider ::settings(water_volume) 1 400 %x %y %x0 %y0 %x1 %y1} 0 210 550 1400 "mousemove"
#add_de1_button "water_1" {say "" $::settings(sound_button_in);vertical_slider ::settings(water_temperature) 20 96 %x %y %x0 %y0 %x1 %y1} 551 210 1029 1400 "mousemove"

add_de1_text "water_1" 70 250 -text [translate "1) Settings"] -font Helv_9_bold -fill $progress_text_color -anchor "nw" -width 900

add_de1_text "water_1" 1070 250 -text [translate "2) Hot water will pour"] -font Helv_9_bold -fill $progress_text_color -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "water" 1070 250 -text [translate "2) Hot water is pouring"] -font Helv_9_bold -fill $progress_text_color -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "water_3" 1840 250 -text [translate "3) Done"] -font Helv_9_bold -fill $progress_text_color -anchor "nw" -width [rescale_x_skin 650]


add_de1_text "water water_3" 70 250 -text [translate "1) Settings"] -font Helv_9_bold -fill $noprogress_text_color -anchor "nw" -width [rescale_x_skin 900]
add_de1_text "water_3" 1070 250 -text [translate "2) Hot water will pour"] -font Helv_9_bold -fill $noprogress_text_color -anchor "nw" -width [rescale_x_skin 650]


if {$::settings(scale_bluetooth_address) != ""} {
	# hot water - stop on weight, optional feature when scale is connected
	add_de1_text "water_1" 300 1300  -text [translate "WEIGHT"] -font Helv_7 -fill $tappable_text_color -anchor "center" 
	add_de1_variable "water_1" 300 1250 -text "" -font Helv_10_bold -fill $tappable_text_color -anchor "center"  -textvariable {[return_weight_measurement $::settings(water_volume)]}

	add_de1_button "water_1" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(water_volume) -n_decimals 0 -min 10 -max 250 -default $::settings(water_volume) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "WEIGHT"] -return_callback change_water_steam_settings } 137 1200 460 1370 ""   

} else {
	add_de1_text "water_1" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill $tappable_text_color -anchor "center" 
	add_de1_variable "water_1" 300 1250 -text "" -font Helv_10_bold -fill $tappable_text_color -anchor "center"  -textvariable {[return_liquid_measurement $::settings(water_volume)]}

	add_de1_button "water_1" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(water_volume) -n_decimals 0 -min 10 -max 250 -default $::settings(water_volume) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "VOLUME"] -return_callback change_water_steam_settings } 137 1200 460 1370 ""   

}

add_de1_variable "water_1" 755 1250 -text "" -font Helv_10_bold -fill $tappable_text_color -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}
add_de1_text "water_1" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill $tappable_text_color -anchor "center" 
add_de1_button "water_1" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(water_temperature) -n_decimals 0 -min 20 -max 110 -default $::settings(water_temperature) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "Temperature"] -return_callback change_water_steam_settings } 590 1200 920 1380  ""   



if {$::settings(scale_bluetooth_address) != ""} {
	# hot water - stop on weight, optional feature when scale is connected
	add_de1_text "water water_3" 300 1300  -text [translate "WEIGHT"] -font Helv_7 -fill $noprogress_text_color -anchor "center" 
	add_de1_variable "water water_3" 300 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center"  -textvariable {[return_weight_measurement $::settings(water_volume)]}
} else {
	add_de1_text "water water_3" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill $noprogress_text_color -anchor "center" 
	add_de1_variable "water water_3" 300 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center"  -textvariable {[return_liquid_measurement $::settings(water_volume)]}
}

add_de1_variable "water water_3" 755 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}

add_de1_text "water water_3" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill $noprogress_text_color -anchor "center" 
add_de1_button "water_3" {say "" $::settings(sound_button_in); set_next_page off water_1; start_idle} 0 240 1000 1400

# data card
#add_de1_text "water" 1870 1250 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]
#add_de1_text "water_3" 1870 1200 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]
add_de1_text "water water_3" 1870 1250 -justify right -anchor "nw" -text [translate "Pouring"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "water water_3" 2470 1250 -justify left -anchor "ne" -font Helv_8 -fill $datacard_data_color -width [rescale_x_skin 520] -text "" -textvariable {[water_pour_timer][translate "s"]} 

#add_de1_text "water_3" 1870 1250 -justify right -anchor "nw" -text [translate "Pouring"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
#add_de1_variable "water_3" 2470 1250 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[water_pour_timer][translate "s"]} 


add_de1_variable "water_3" 1870 1200 -justify right -anchor "nw" -text [translate "Done"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520] -textvariable {[if {[water_done_timer] < $::settings(seconds_to_display_done_hotwater)} {return [translate Done]} else { return ""}]} 
add_de1_variable "water_3" 2470 1200 -justify left -anchor "ne" -font Helv_8 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[if {[water_done_timer] < $::settings(seconds_to_display_done_hotwater)} {return "[water_done_timer][translate s]"} else { return ""}]} 


# current water temperature - not getting this via BLE at the moment 1/4/19 so do not display in the UI
	#add_de1_text "water" 1870 300 -justify right -anchor "nw" -text [translate "Water temperature"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
	#add_de1_variable "water" 2470 300 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[watertemp_text]} 
	#add_de1_text "water_3" 1870 350 -justify right -anchor "nw" -text [translate "Information"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]
	#add_de1_text "water_3" 1870 400 -justify right -anchor "nw" -text [translate "Water temperature"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
	#add_de1_variable "water_3" 2470 400 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[watertemp_text]} 
	#add_de1_text "water" 1870 250 -justify right -anchor "nw" -text [translate "Information"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]

if {$::settings(scale_bluetooth_address) != ""} {
	# hot water - optional feature when scale is connected
	add_de1_text "water " 1870 1200 -justify right -anchor "nw" -text [translate "Flow rate"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
	add_de1_variable "water" 2470 1200 -justify left -anchor "ne" -text "" -font Helv_8 -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[waterweightflow_text]} 
	add_de1_text "water water_3" 1870 1300 -justify right -anchor "nw" -text [translate "Total Weight"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
	add_de1_variable "water water_3" 2470 1300 -justify left -anchor "ne" -text "" -font Helv_8 -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[drink_weight_text]} 
} else {
	add_de1_text "water " 1870 1200 -justify right -anchor "nw" -text [translate "Flow rate"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
	add_de1_variable "water" 2470 1200 -justify left -anchor "ne" -text "" -font Helv_8 -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 
	#add_de1_text "water " 1870 1300 -justify right -anchor "nw" -text [translate "Total Volume"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
	#add_de1_variable "water" 2470 1300 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 
}


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

add_de1_variable "steam_1" 1396 775 -text [translate "START"] -font $green_button_font -fill $startbutton_font_color -anchor "center" -textvariable {[start_text_if_steam_ready]} 
add_de1_variable "steam" 1396 775 -text [translate "STOP"] -font $green_button_font -fill $startbutton_font_color -anchor "center"  -textvariable {[stop_text_if_espresso_stoppable]} 
add_de1_variable "steam_3" 1396 775 -text [translate "RESTART"] -font $green_button_font -fill $startbutton_font_color -anchor "center" -textvariable {[restart_text_if_steam_ready]} 

add_de1_text "steam_1 steam steam_3" 1396 865 -text [translate "STEAM"] -font Helv_10 -fill "#7f879a" -anchor "center" 

add_de1_button "steam_1" {say [translate {steam}] $::settings(sound_button_in); if {$::settings(steam_disabled) == 0} { set_next_page steam steam; start_steam} else {set ::settings(steam_disabled) 0; set ::de1(steam_disable_toggle) [expr {!$::settings(steam_disabled)}]; de1_send_steam_hotwater_settings } } 1030 240 2560 1100
add_de1_button "steam_3" {say [translate {steam}] $::settings(sound_button_in); if {$::settings(steam_disabled) == 0} { set_next_page steam steam; start_steam} else {set ::settings(steam_disabled) 0; set ::de1(steam_disable_toggle) [expr {!$::settings(steam_disabled)}]; de1_send_steam_hotwater_settings } } 1030 240 2560 1070


# future feature
#add_de1_button "steam_1" {say [translate {rinse}] $::settings(sound_button_in); start_steam} 1030 1101 1760 1400

add_de1_button "steam" {say [translate {stop}] $::settings(sound_button_in); set_next_page off steam_3; start_idle} 0 240 2560 1400
add_de1_button "steam_3" {say "" $::settings(sound_button_in); set_next_page off steam_1; start_idle} 0 240 1000 1400
add_de1_button "steam_1" {say "" $::settings(sound_button_in);vertical_clicker 9 1 ::settings(steam_timeout) 1 255 %x %y %x0 %y0 %x1 %y1 %b; change_water_steam_settings} 200 580 900 1150 ""


add_de1_text "steam_1" 70 250 -text [translate "1) Choose auto-off time"] -font Helv_9_bold -fill $progress_text_color -anchor "nw" -width [rescale_x_skin 900]
add_de1_text "steam steam_3" 70 250 -text [translate "1) Choose auto-off time"] -font Helv_9_bold -fill $noprogress_text_color -anchor "nw" -width [rescale_x_skin 900]
add_de1_text "steam_1" 1070 250 -text [translate "2) Steam your milk"] -font Helv_9_bold -fill $progress_text_color -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "steam" 1070 250 -text [translate "2) Steaming your milk"] -font Helv_9_bold -fill $progress_text_color -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "steam_3" 1070 250 -text [translate "2) Steam your milk"] -font Helv_9_bold -fill $noprogress_text_color -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "steam_3" 1840 250 -text [translate "3) Make amazing latte art"] -font Helv_9_bold -fill $progress_text_color -anchor "nw" -width [rescale_x_skin 680]

add_de1_variable "steam_1" 537 1250 -text "" -font Helv_10_bold -fill $tappable_text_color -anchor "center"  -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}

	add_de1_variable "steam steam_3" 537 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center"  -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}
	add_de1_text "steam_1" 537 1300 -text [translate "AUTO-OFF"] -font Helv_7 -fill $tappable_text_color -anchor "center" 
	add_de1_text "steam steam_3" 537 1300 -text [translate "AUTO-OFF"] -font Helv_7 -fill "#7f879a" -anchor "center" 
	add_de1_button "steam_1" { profile_has_changed_set; dui page open_dialog dui_number_editor ::settings(steam_timeout) -n_decimals 0 -min 1 -max 255 -default $::settings(steam_timeout) -smallincrement .1 -bigincrement 1 -use_biginc 1 -page_title [translate "AUTO-OFF"] -return_callback change_water_steam_settings } 337 1180 737 1370 ""   


add_de1_text "steam" 1840 250 -justify right -anchor "nw" -text [translate "Information"] -font Helv_9_bold -fill $progress_text_color -width [rescale_x_skin 520]

	#add_de1_text "steam steam_3" 1870 1200 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]
	add_de1_text "steam" 1870 350 -justify right -anchor "nw" -text [translate "Steaming"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam" 2470 350 -justify left -anchor "ne" -font Helv_8 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[steam_pour_timer][translate "s"]} 
	add_de1_text "steam_3" 1870 350 -justify right -anchor "nw" -text [translate "Steaming"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam_3" 2470 350 -justify left -anchor "ne" -font Helv_8 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[steam_pour_timer][translate "s"]} 

	add_de1_variable "steam_3" 1870 400 -justify right -anchor "nw" -text [translate "Done"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520] -textvariable {[if {[steam_done_timer] < $::settings(seconds_to_display_done_steam)} {return [translate Done]} else { return ""}]} 
		add_de1_variable "steam_3" 2470 400 -justify left -anchor "ne" -font Helv_8 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[if {[steam_done_timer] < $::settings(seconds_to_display_done_steam)} {return "[steam_done_timer][translate s]"} else { return ""}]} 
	add_de1_text "steam" 1870 400 -justify right -anchor "nw" -text [translate "Auto-Off"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam" 2470 400 -justify left -anchor "ne" -font Helv_8 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}

	add_de1_text "steam" 1870 450 -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam" 2470 450 -justify left -anchor "ne" -font Helv_8 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[steamtemp_text]} 
	add_de1_text "steam" 1870 500 -justify right -anchor "nw" -text [translate "Pressure (bar)"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam" 2470 500 -justify left -anchor "ne" -font Helv_8 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[pressure_text]} 
	add_de1_text "steam" 1870 550 -justify right -anchor "nw" -text [translate "Flow rate max"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam" 2470 550 -justify left -anchor "ne" -text "" -font Helv_8 -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[dui platform hide_android_keyboard; return_steam_flow_calibration $::settings(steam_flow)]}
	add_de1_text "steam" 1870 600 -justify right -anchor "nw" -text [translate "Flow rate now"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam" 2470 600 -justify left -anchor "ne" -text "" -font Helv_8 -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 


	# zoomed steam chart
	add_de1_text "steam_zoom_3 steam_zoom" 250 1440 -justify right -anchor "nw" -text [translate "Steaming"] -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam_zoom_3 steam_zoom" 230 1440 -justify left -anchor "ne" -font Helv_7 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[steam_pour_timer][translate "s"]} 
	add_de1_variable "steam_zoom_3 steam_zoom" 250 1490 -justify right -anchor "nw" -text [translate "Done"] -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520] -textvariable {[if {[steam_done_timer] < $::settings(seconds_to_display_done_steam)} {return [translate Done]} else { return ""}]} 
		add_de1_variable "steam_zoom_3 steam_zoom" 230 1490 -justify left -anchor "ne" -font Helv_7 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[if {[steam_done_timer] < $::settings(seconds_to_display_done_steam)} {return "[steam_done_timer][translate s]"} else { return ""}]} 
	add_de1_text "steam_zoom_3 steam_zoom" 250 1540 -justify right -anchor "nw" -text [translate "Auto-Off"] -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam_zoom_3 steam_zoom" 230 1540 -justify left -anchor "ne" -font Helv_7 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}

	add_de1_text "steam_zoom_3 steam_zoom" 870 1440 -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam_zoom_3 steam_zoom" 850 1440 -justify left -anchor "ne" -font Helv_7 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[steamtemp_text]} 
		#add_de1_variable "steam_zoom_3 steam_zoom" 700 1440 -justify left -anchor "ne" -font Helv_7 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[round_to_integer $::de1(steam_heater_temperature)]} 

	add_de1_text "steam_zoom_3 steam_zoom" 870 1490 -justify right -anchor "nw" -text [translate "Pressure (bar)"] -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam_zoom_3 steam_zoom" 850 1490 -justify left -anchor "ne" -font Helv_7 -text "" -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[pressure_text]} 
	add_de1_text "steam_zoom_3 steam_zoom" 870 1540 -justify right -anchor "nw" -text [translate "Flow rate now"] -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520]
		add_de1_variable "steam_zoom_3 steam_zoom" 850 1540 -justify left -anchor "ne" -text "" -font Helv_7 -fill $datacard_data_color -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 

	# stop button when zoomed on steam
	#add_de1_variable "steam_zoom" 2100 1510 -text "\[ [translate "STOP"] \]" -font $green_button_font -fill $startbutton_font_color -anchor "center"  -textvariable {\[ [stop_text_if_espresso_stoppable] \]} 
	#add_de1_button "steam_zoom" {say [translate {stop}] $::settings(sound_button_in); set_next_page off steam_3; start_idle; check_if_steam_clogged} 0 1410 2560 1600
	if {[ifexists ::insight_dark_mode] == 1} {
		dui add dbutton "steam_zoom" 2100 1450 2540 1560 -tags circle_stop_btn -shape round_outline -label_font Helv_10_bold -fill "#3c4043" -width 7 -outline "#f5454f" -label [translate "STOP"]  -label_fill "#adaeb2" -command {say [translate {stop}] $::settings(sound_button_in); set_next_page off steam_3; start_idle; check_if_steam_clogged} 
	} else {
		dui add dbutton "steam_zoom" 2100 1450 2540 1560 -tags circle_stop_btn -shape round_outline -label_font Helv_10_bold -fill "#ebedfa" -width 7 -outline "#f50623" -label [translate "STOP"]  -label_fill black -command {say [translate {stop}] $::settings(sound_button_in); set_next_page off steam_3; start_idle; check_if_steam_clogged} 
	}



	# realtime control over the steam flow rate
	add_de1_widget "steam steam_1 steam_3" scale 10 1436 {} -from 40 -to 250 -background $steam_control_foreground -borderwidth 1 -showvalue 0  -bigincrement 100 -resolution 10 -length [rescale_x_skin 2000] -width [rescale_y_skin 150] -variable ::settings(steam_flow) -font Helv_10_bold -sliderlength [rescale_x_skin 500] -relief flat -command {dui platform hide_android_keyboard; set_steam_flow} -orient horizontal -foreground #FFFFFF -troughcolor $steam_control_background  -borderwidth 0  -highlightthickness 0
	#dui add dscale "steam steam_1 steam_3" 40 1510 {} -from 40 -to 250 -bigincrement 100 -smallincrement 10 -resolution 10 -length 1950 -width 14 -sliderlength 120 -variable ::settings(steam_flow) -command {set_steam_flow} -orient horizontal

	# when steam is off, display current steam heater temp
	add_de1_text "steam_1 steam_3" 1100 1250 -justify right -anchor "nw" -text [translate "Temperature"] -font Helv_8 -fill "#969eb1" -width [rescale_x_skin 520] 
		add_de1_variable "steam_1 steam_3" 1700 1250 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#969eb1" -width [rescale_x_skin 520] -textvariable {[steamtemp_text]} 
	add_de1_text "steam_1 steam_3" 1100 1200 -justify right -anchor "nw" -text [translate "Preheat to"] -font Helv_8 -fill "#969eb1" -width [rescale_x_skin 520]
		add_de1_variable "steam_1 steam_3" 1700 1200 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#969eb1" -width [rescale_x_skin 520] -textvariable {[if {$::settings(steam_disabled) != 1} { return_steam_temperature_measurement $::settings(steam_temperature)} else { return [translate "off"] }]} 

		add_de1_text "steam_1 steam_3" 1100 1150 -justify right -anchor "nw" -text [translate "Enabled"] -font Helv_8 -fill "#969eb1" -width [rescale_x_skin 520]
		dui add dtoggle "steam_1 steam_3" 1700 1150 -height 36 -width 80 -anchor ne -variable ::de1(steam_disable_toggle) -command disable_steam_toggle 


		set ::de1(steam_disable_toggle) [expr {!$::settings(steam_disabled)}]
		proc disable_steam_toggle {} {
			set ::settings(steam_disabled)  [expr {!$::de1(steam_disable_toggle)}]
		}


		add_de1_text "steam_1 steam_3" 1100 1300 -justify right -anchor "nw" -text [translate "Flow rate max"] -font Helv_8 -fill "#969eb1" -width [rescale_x_skin 520]
			# hide the android toolbar if it is shown during steaming, because it obscures the flow rate slider
			add_de1_variable "steam_1" 1700 1300 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#969eb1" -width [rescale_x_skin 520] -textvariable {[dui platform hide_android_keyboard; ; return_steam_flow_calibration $::settings(steam_flow)] }
			add_de1_variable "steam_3" 1700 1300 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#969eb1" -width [rescale_x_skin 520] -textvariable  {[return_steam_flow_calibration $::settings(steam_flow)] }

		add_de1_button "steam_1 steam_3" {if {$::settings(steam_disabled) != 1} { set ::settings(steam_disabled) 1 } else { set ::settings(steam_disabled) 0};  de1_send_steam_hotwater_settings; set ::de1(steam_disable_toggle) [expr {!$::settings(steam_disabled)}] } 1040 1160 1760 1400


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

#set_next_page off steam_zoom;
