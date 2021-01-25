
proc iconik_wakeup {} {
	set_next_page "off" "off"
	page_show "off"
	start_idle
}

proc iconik_get_final_weight {} {
	if {$::settings(settings_profile_type) == "settings_2c"} {
    	return $::settings(final_desired_shot_weight_advanced)
    } else {
    	return $::settings(final_desired_shot_weight)
    }
}

add_background "off"

# Return from screensaver
set_de1_screen_saver_directory "[homedir]/saver"
add_de1_button "saver" {say [translate "wake"] $::settings(sound_button_in); iconik_wakeup} 0 0 2560 1600

# Profile QuickSettings
create_button "settings_1" 1140 1020 1240 1120 "1" $::font_big $::color_button $::color_button_text_light {iconik_save_profile 1}
create_button "settings_1" 1140 1150 1240 1250 "2" $::font_big $::color_button $::color_button_text_light {iconik_save_profile 2}
create_button "settings_1" 1140 1280 1240 1380 "3" $::font_big $::color_button $::color_button_text_light {iconik_save_profile 3}


# Upper buttons
## Background
rectangle "off" 0 0 2560 180 $::color_background_highlight

## Time
rounded_rectangle "off"  80 30 480 150 [rescale_x_skin 80] $::color_button_secondary
add_de1_variable "off" [expr (80 + 480) / 2.0 ] [expr (30 + 150) / 2.0 ] -width [rescale_x_skin 280]  -text "" -font $::font_tiny -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Time:\n[total_pour_timer_text]} 


## Espresso Temperature
rounded_rectangle "off" 580 30 980 150 [rescale_x_skin 80] $::color_button_secondary
add_de1_variable "off" [expr (580 + 980) / 2.0 ] [expr (30 + 150) / 2.0 ] -width [rescale_x_skin 280]  -text "" -font $::font_tiny -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Temp:\n[round_to_one_digits $::settings(espresso_temperature)]°C} 
create_button "off" 580 50 660 130 [translate "-"] $::font_tiny $::color_button_secondary $::color_button_text_light {  set ::settings(espresso_temperature) [expr {[round_to_one_digits $::settings(espresso_temperature)] - 0.5}]; profile_has_changed_set; save_profile; save_settings_to_de1; save_settings}
create_button "off" 900 50 980 130 [translate "+"] $::font_tiny $::color_button_secondary $::color_button_text_light {  set ::settings(espresso_temperature) [expr {[round_to_one_digits $::settings(espresso_temperature)] + 0.5}]; profile_has_changed_set; save_profile; save_settings_to_de1; save_settings}

## Espresso Target Weight
rounded_rectangle "off" 1080 30 1480 150 [rescale_x_skin 80] $::color_button_secondary
add_de1_variable "off" [expr (1080 + 1480) / 2.0 ] [expr (30 + 150) / 2.0 ] -width [rescale_x_skin 280]  -text "" -font $::font_tiny -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Bev. weight:\n[round_to_one_digits [iconik_get_final_weight]]} 
create_button "off" 1080 50 1160 130 [translate "-"] $::font_tiny $::color_button_secondary $::color_button_text_light { set ::settings(final_desired_shot_weight) [expr {$::settings(final_desired_shot_weight) - 1}];set ::settings(final_desired_shot_weight_advanced) [expr {$::settings(final_desired_shot_weight_advanced) - 1}]; profile_has_changed_set; save_profile; save_settings_to_de1; save_settings}
create_button "off" 1400 50 1480 130 [translate "+"] $::font_tiny $::color_button_secondary $::color_button_text_light { set ::settings(final_desired_shot_weight) [expr {$::settings(final_desired_shot_weight) + 1}];set ::settings(final_desired_shot_weight_advanced) [expr {$::settings(final_desired_shot_weight_advanced) + 1}]; profile_has_changed_set; save_profile; save_settings_to_de1; save_settings}


## Steam
rounded_rectangle "off" 1580 30 1980 150 [rescale_x_skin 80] $::color_button_secondary
add_de1_variable "off" [expr (1580 + 1980) / 2.0 ] [expr (30 + 150) / 2.0 ] -width [rescale_x_skin 280]  -text "" -font $::font_tiny -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Steam $::iconik_settings(steam_active_slot):\n[round_to_one_digits $::settings(steam_timeout)]s} 
create_button "off" 1580 50 1660 130 [translate "-"] $::font_tiny $::color_button_secondary $::color_button_text_light {iconic_steam_tap down}
create_button "off" 1900 50 1980 130 [translate "+"] $::font_tiny $::color_button_secondary $::color_button_text_light {iconic_steam_tap up}

## Water Volume
rounded_rectangle "off" 2080 30 2480 150 [rescale_x_skin 80] $::color_button_secondary
add_de1_variable "off" [expr (2080 + 2480) / 2.0 ] [expr (30 + 150) / 2.0 ] -width [rescale_x_skin 280]  -text "" -font $::font_tiny -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Water $::settings(water_temperature)°C:\n[round_to_one_digits $::settings(water_volume)]ml} 
create_button "off" 2080 50 2160 130 [translate "-"] $::font_tiny $::color_button_secondary $::color_button_text_light {  set ::settings(water_volume) [expr {$::settings(water_volume) - 1}]; de1_send_steam_hotwater_settings; save_settings}
create_button "off" 2400 50 2480 130 [translate "+"] $::font_tiny $::color_button_secondary $::color_button_text_light {  set ::settings(water_volume) [expr {$::settings(water_volume) + 1}]; de1_send_steam_hotwater_settings; save_settings}

# Recipe
rounded_rectangle "off" 80 210 760 1110 [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (80 + 760) / 2.0 ] [expr (240 + 240) / 2.0 ] -width [rescale_x_skin 640]  -text "" -font $::font_big -fill $::color_button_text_light -anchor "n" -justify "center" -state "hidden" -textvariable {$::settings(profile_title)}
add_de1_variable "off" [expr (80 + 760) / 2.0 ] [expr (320 + 1110) / 2.0 ] -width [rescale_x_skin 640]  -text "" -font $::font_small -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {$::settings(profile_notes)}

# Presets

## Coffee
rounded_rectangle "off" 80 1140 480 1380  [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (80 + 480) / 2.0 ] [expr (1140 + 1380) / 2.0 ] -width 180  -text "" -font $::font_tiny -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Coffee:\n$::iconik_settings(profile1_title)} 
add_de1_button "off" {  select_profile $::iconik_settings(profile1); save_settings_to_de1; save_settings} 80 1140 480 1380

rounded_rectangle "off" 580 1140 980 1380 [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (580 + 980) / 2.0 ] [expr (1140 + 1380) / 2.0 ] -width 180  -text "" -font $::font_tiny -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Coffee:\n$::iconik_settings(profile2_title)} 
add_de1_button "off" {  select_profile $::iconik_settings(profile2); save_settings_to_de1; save_settings} 580 1140 980 1380

rounded_rectangle "off" 1080 1140 1480 1380 [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (1080 + 1480) / 2.0 ] [expr (1140 + 1380) / 2.0 ] -width 180  -text "" -font $::font_tiny -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Coffee:\n$::iconik_settings(profile3_title)} 
add_de1_button "off" {  select_profile $::iconik_settings(profile3); save_settings_to_de1; save_settings} 1080 1140 1480 1380

## Steam Presets

rounded_rectangle "off" 1580 1140 1980 1380 [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (1580 + 1980) / 2.0 ] [expr (1140 + 1380) / 2.0 ] -width 100  -text "" -font $::font_tiny -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Steam 1:\n$::iconik_settings(steam_timeout1)s} 
add_de1_button "off" {iconik_toggle_steam_settings 1} 1580 1140 1980 1380

rounded_rectangle "off" 2080 1140 2480 1380 [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (2080 + 2480) / 2.0 ] [expr (1140 + 1380) / 2.0 ] -width 100  -text "" -font $::font_tiny -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Steam 2:\n$::iconik_settings(steam_timeout2)s} 
add_de1_button "off" {iconik_toggle_steam_settings 2} 2080 1140 2480 1380 


## Bottom buttons

rectangle "off" 0 1410 2560 1600 $::color_background_highlight

## Flush
rounded_rectangle "off" 80 1440 480 1560 [rescale_x_skin 80] $::color_button_tertiary
add_de1_variable "off" [expr (80 + 480) / 2.0 ] [expr (1440 + 1560) / 2.0 ] -width 200  -text "" -font $::font_tiny -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Flush:\n[round_to_one_digits $::iconik_settings(flush_timeout)]s} 
create_button "off" 80 1460 160 1540 [translate "-"] $::font_tiny $::color_button_tertiary $::color_button_text_light {  set ::iconik_settings(flush_timeout) [expr {$::iconik_settings(flush_timeout) - 0.5}]; iconik_save_settings}
create_button "off" 400 1460 480 1540 [translate "+"] $::font_tiny $::color_button_tertiary $::color_button_text_light {  set ::iconik_settings(flush_timeout) [expr {$::iconik_settings(flush_timeout) + 0.5}]; iconik_save_settings}

## Status
rounded_rectangle "off" 580 1440 980 1560 [rescale_x_skin 80] $::color_button_tertiary
add_de1_variable "off" [expr (580 + 980) / 2.0 ] [expr (1440 + 1560) / 2.0 ] -width 280  -text "" -font $::font_tiny -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {[iconik_get_status_text]}
add_de1_button "off" { iconik_status_tap } 580 1440 980 1560

## MISC buttons
create_button "off" 1080 1440 1480 1560 [translate "Clean"] $::font_tiny $::color_button_tertiary $::color_button_text_light { say [translate "settings"] $::settings(sound_button_in); iconik_toggle_cleaning }
create_button "off" 1580 1440 1980 1560 [translate "Settings"] $::font_tiny $::color_button_tertiary $::color_button_text_light { say [translate "settings"] $::settings(sound_button_in); show_settings }
create_button "off" 2080 1440 2480 1560 [translate "Sleep"] $::font_tiny $::color_button_tertiary $::color_button_text_light { say [translate "settings"] $::settings(sound_button_in); start_sleep }

## Graph

add_de1_widget "off" graph 780 230 {

	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color $::color_primary_light  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 12] -color $::color_primary  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure); 

	if {$::settings(display_pressure_delta_line) == 1} {
		$widget element create line_espresso_pressure_delta_1  -xdata espresso_elapsed -ydata espresso_pressure_delta -symbol none -label "" -linewidth [rescale_x_skin 2] -color $::color_primary_dark -pixels 0 -smooth $::settings(live_graph_smoothing_technique) 
	}

	$widget element create line_espresso_flow_goal_2x  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color $::color_secondary_light -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5}; 
	$widget element create line_espresso_flow_2x  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 12] -color  $::color_secondary -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes $::settings(chart_dashes_flow);   
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

		# when using Resistance calculated from the flowmeter, use a solid line to indicate it is well measured
		$widget element create line_espresso_resistance  -xdata espresso_elapsed -ydata espresso_resistance_weight -symbol none -label "" -linewidth [rescale_x_skin 4] -color #e5e500 -smooth $::settings(live_graph_smoothing_technique) -pixels 0  

	}

	$widget element create line_espresso_resistance_dashed  -xdata espresso_elapsed -ydata espresso_resistance -symbol none -label "" -linewidth [rescale_x_skin 4] -color #e5e500 -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {6 2}; 

	$widget element create god_line2_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 24] -color #c5ffe7  -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0 ; 

	$widget axis configure x -color #5a5d75 -tickfont Helv_7_bold; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_7_bold -min 0.0 -max $::settings(zoomed_y_axis_scale) -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20} -hide 0; 

	# show the explanation for pressure
	$widget element create line_espresso_de1_explanation_chart_pressure_zoomed -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure  -label "" -linewidth [rescale_x_skin 16] -color $::color_primary  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 

	# show the explanation for flow
	$widget element create line_espresso_de1_explanation_chart_flow_zoom -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow  -label "" -linewidth [rescale_x_skin 18] -color $::color_secondary  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 


} -plotbackground $::color_background -width [rescale_x_skin 1680] -height [rescale_y_skin 900] -borderwidth 1 -background $::color_background -plotrelief flat -plotpady 0 -plotpadx 10
