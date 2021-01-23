
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
create_button "settings_1" 1140 1020 1240 1120 "1" $::font_button $::color_button $::color_button_text_dark {set ::iconik_settings(profile1) $settings(profile_filename); set ::iconik_settings(profile1_title) $settings(profile_title); iconik_save_settings; borg toast [translate "Saved in slot 1"]}
create_button "settings_1" 1140 1220 1240 1320 "2" $::font_button $::color_button $::color_button_text_dark {set ::iconik_settings(profile2) $settings(profile_filename); set ::iconik_settings(profile2_title) $settings(profile_title); iconik_save_settings; borg toast [translate "Saved in slot 2"]}


## Upper buttons

rectangle "off" 0 0 2560 360 $::color_button_text_light

rounded_rectangle "off" 80 60 380 300 [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (80 + 380) / 2.0 ] [expr (80 + 300) / 2.0 ] -width 300  -text "" -font $::font_button -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Target:\n[round_to_one_digits [iconik_get_final_weight]]} 
create_button "off" 400 60 500 160 [translate "+"] $::font_button $::color_button_up $::color_button_text_dark { say [translate "steam"] $::settings(sound_button_in); set ::settings(final_desired_shot_weight) [expr {$::settings(final_desired_shot_weight) + 1}];set ::settings(final_desired_shot_weight_advanced) [expr {$::settings(final_desired_shot_weight_advanced) + 1}]; profile_has_changed_set; save_profile; save_settings}
create_button "off" 400 200 500 300 [translate "-"] $::font_button $::color_button_down $::color_button_text_dark { say [translate "steam"] $::settings(sound_button_in); set ::settings(final_desired_shot_weight) [expr {$::settings(final_desired_shot_weight) - 1}];set ::settings(final_desired_shot_weight_advanced) [expr {$::settings(final_desired_shot_weight_advanced) - 1}]; profile_has_changed_set; save_profile; save_settings}

rounded_rectangle "off" 580 60 880 300 [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (580 + 880) / 2.0 ] [expr (80 + 300) / 2.0 ] -width 300  -text "" -font $::font_button -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Temp:\n[round_to_one_digits $::settings(espresso_temperature)]°C} 
create_button "off" 900 60 1000 160 [translate "+"] $::font_button $::color_button_up $::color_button_text_dark { say [translate "steam"] $::settings(sound_button_in); set ::settings(espresso_temperature) [expr {[round_to_one_digits $::settings(espresso_temperature)] + 0.5}]; profile_has_changed_set; save_profile; save_settings}
create_button "off" 900 200 1000 300 [translate "-"] $::font_button $::color_button_down $::color_button_text_dark { say [translate "steam"] $::settings(sound_button_in); set ::settings(espresso_temperature) [expr {[round_to_one_digits $::settings(espresso_temperature)] - 0.5}]; profile_has_changed_set; save_profile; save_settings}

rounded_rectangle "off"  1080 60 1480 300 [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (1080 + 1480) / 2.0 ] [expr (80 + 300) / 2.0 ] -width 300  -text "" -font $::font_button -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Time:\n[total_pour_timer_text]} 

rounded_rectangle "off" 1580 60 2480 170  [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (1580 + 2480) / 2.0 ] [expr (80 + 170) / 2.0 ] -width 300  -text "" -font $::font_button_small -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {$::iconik_settings(profile1_title)} 
add_de1_button "off" { say [translate "steam"] $::settings(sound_button_in); select_profile $::iconik_settings(profile1); save_settings} 1580 60 2480 160

rounded_rectangle "off" 1580 190 2480 300 [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (1580 + 2480) / 2.0 ] [expr (190 + 300) / 2.0 ] -width 300  -text "" -font $::font_button_small -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {$::iconik_settings(profile2_title)} 
add_de1_button "off" { say [translate "steam"] $::settings(sound_button_in); select_profile $::iconik_settings(profile2); save_settings} 1580 200 2480 300

## Recipe

rounded_rectangle "off" 80 400 680 1100 [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (80 + 680) / 2.0 ] [expr (400 + 1220) / 2.0 ] -width 280  -text "" -font $::font_description -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {$::settings(profile_notes)}

rounded_rectangle "off" 80 1120 680 1220 [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (80 + 680) / 2.0 ] [expr (1120 + 1220) / 2.0 ] -width 280  -text "" -font $::font_description -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {[iconik_get_status_text]}


## Bottom buttons

rectangle "off" 0 1260 2560 1600 $::color_button_text_light

rounded_rectangle "off" 200 1320 380 1560 [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (200 + 380) / 2.0 ] [expr (1320 + 1560) / 2.0 ] -width 300  -text "" -font $::font_button -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Steam:\n[round_to_one_digits $::settings(steam_timeout)]s} 
create_button "off" 400 1320 500 1420 [translate "+"] $::font_button $::color_button_up $::color_button_text_dark { say [translate "steam"] $::settings(sound_button_in); set ::settings(steam_timeout) [expr {$::settings(steam_timeout) + 1}]; de1_send_steam_hotwater_settings}
create_button "off" 400 1460 500 1560 [translate "-"] $::font_button $::color_button_down $::color_button_text_dark { say [translate "steam"] $::settings(sound_button_in); set ::settings(steam_timeout) [expr {$::settings(steam_timeout) - 1}]; de1_send_steam_hotwater_settings}

rounded_rectangle "off" 80 1320 180 1420 [rescale_x_skin 80] $::color_button_up
add_de1_variable "off" [expr (80 + 180) / 2.0 ] [expr (1320 + 1420) / 2.0 ] -width 100  -text "" -font $::font_description -fill $::color_button_text_dark -anchor "center" -justify "center" -state "hidden" -textvariable {$::iconik_settings(steam_timeout1)} 
add_de1_button "off" {iconik_toggle_steam_settings 1} 80 1320 180 1420

rounded_rectangle "off" 80 1460 180 1560 [rescale_x_skin 80] $::color_button_up
add_de1_variable "off" [expr (80 + 180) / 2.0 ] [expr (1460 + 1560) / 2.0 ] -width 100  -text "" -font $::font_description -fill $::color_button_text_dark -anchor "center" -justify "center" -state "hidden" -textvariable {$::iconik_settings(steam_timeout2)} 
add_de1_button "off" {iconik_toggle_steam_settings 2} 80 1460 180 1560 

rounded_rectangle "off" 580 1320 880 1560 [rescale_x_skin 80] $::color_button
add_de1_variable "off" [expr (580 + 880) / 2.0 ] [expr (1320 + 1560) / 2.0 ] -width 300  -text "" -font $::font_button -fill $::color_button_text_light -anchor "center" -justify "center" -state "hidden" -textvariable {Flush:\n[round_to_one_digits $::iconik_settings(flush_timeout)]s} 
create_button "off" 900 1320 1000 1420 [translate "+"] $::font_button $::color_button_up $::color_button_text_dark { say [translate "steam"] $::settings(sound_button_in); set ::iconik_settings(flush_timeout) [expr {$::iconik_settings(flush_timeout) + 0.5}]; iconik_save_settings}
create_button "off" 900 1460 1000 1560 [translate "-"] $::font_button $::color_button_down $::color_button_text_dark { say [translate "steam"] $::settings(sound_button_in); set ::iconik_settings(flush_timeout) [expr {$::iconik_settings(flush_timeout) - 0.5}]; iconik_save_settings}

create_button "off" 1080 1320 1480 1560 [translate "Clean"] $::font_button $::color_button $::color_button_text_light { say [translate "settings"] $::settings(sound_button_in); iconik_toggle_cleaning }
create_button "off" 1580 1320 1980 1560 [translate "Settings"] $::font_button $::color_button $::color_button_text_light { say [translate "settings"] $::settings(sound_button_in); show_settings }
create_button "off" 2080 1320 2480 1560 [translate "Sleep"] $::font_button $::color_button $::color_button_text_light { say [translate "settings"] $::settings(sound_button_in); start_sleep }

## Graph

add_de1_widget "off" graph 780 400 {

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

		# when using Resistance calculated from the flowmeter, use a solid line to indicate it is well measured
		$widget element create line_espresso_resistance  -xdata espresso_elapsed -ydata espresso_resistance_weight -symbol none -label "" -linewidth [rescale_x_skin 4] -color #e5e500 -smooth $::settings(live_graph_smoothing_technique) -pixels 0  

	}

	$widget element create line_espresso_resistance_dashed  -xdata espresso_elapsed -ydata espresso_resistance -symbol none -label "" -linewidth [rescale_x_skin 4] -color #e5e500 -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {6 2}; 

	$widget element create god_line2_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 24] -color #c5ffe7  -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0 ; 

	$widget axis configure x -color #5a5d75 -tickfont Helv_7_bold; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_7_bold -min 0.0 -max $::settings(zoomed_y_axis_scale) -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20} -hide 0; 

	# show the explanation for pressure
	$widget element create line_espresso_de1_explanation_chart_pressure_zoomed -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure  -label "" -linewidth [rescale_x_skin 16] -color #47e098  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 

	# show the explanation for flow
	$widget element create line_espresso_de1_explanation_chart_flow_zoom -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow  -label "" -linewidth [rescale_x_skin 18] -color #98c5ff  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0; 


} -plotbackground $::color_background -width [rescale_x_skin 1700] -height [rescale_y_skin 840] -borderwidth 1 -background $::color_background -plotrelief flat -plotpady 0 -plotpadx 10
