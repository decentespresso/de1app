set ::skindebug 0

package require de1plus 1.0


##############################################################################################################################################################################################################################################################################
# the graphics for each of the main espresso machine modes
add_de1_page "off" "[skin_directory_graphics]/espresso_1.jpg"

add_de1_page "espresso" "[skin_directory_graphics]/espresso_2.jpg"
add_de1_page "espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" "[skin_directory_graphics]/espresso_zoomed.jpg" 
add_de1_page "espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" "[skin_directory_graphics]/espresso_3_zoomed.jpg"
add_de1_page "espresso_3" "[skin_directory_graphics]/espresso_3.jpg"

add_de1_page "steam" "[skin_directory_graphics]/steam_2.jpg"
add_de1_page "steam_1" "[skin_directory_graphics]/steam_1.jpg"
add_de1_page "steam_3" "[skin_directory_graphics]/steam_3.jpg"

add_de1_page "water" "[skin_directory_graphics]/water_2.jpg"
add_de1_page "water_1" "[skin_directory_graphics]/water_1.jpg"
add_de1_page "water_3" "[skin_directory_graphics]/water_3.jpg"

add_de1_page "preheat_1" "[skin_directory_graphics]/preheat_1.jpg"
add_de1_page "preheat_2" "[skin_directory_graphics]/preheat_2.jpg"
add_de1_page "preheat_3" "[skin_directory_graphics]/preheat_3.jpg"
add_de1_page "preheat_4" "[skin_directory_graphics]/preheat_4.jpg"

# most skins will not bother replacing these graphics
add_de1_page "sleep" "[defaultskin_directory_graphics]/sleep.jpg"
add_de1_page "tankfilling" "[defaultskin_directory_graphics]/filling_tank.jpg"
add_de1_page "tankempty" "[defaultskin_directory_graphics]/fill_tank.jpg"
add_de1_page "message" "[defaultskin_directory_graphics]/settings_message.jpg"
set_de1_screen_saver_directory "[homedir]/saver"

# include the generic settings features for all DE1 skins.  
source "[homedir]/skins/default/de1_skin_settings.tcl"


# labels for PREHEAT tab on
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 405 100 -text [translate "PRE-HEAT CUP"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 1035 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 1665 100 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 2290 100 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for ESPRESSO tab on
add_de1_text "off espresso espresso_3 espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" 405 100 -text [translate "PRE-HEAT CUP"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "off espresso espresso_3 espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" 1035 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off espresso espresso_3 espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" 1665 100 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "off espresso espresso_3 espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" 2290 100 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for STEAM tab on
add_de1_text "steam steam_1 steam_3" 405 100 -text [translate "PRE-HEAT CUP"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "steam steam_1 steam_3" 1035 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "steam steam_1 steam_3" 1665 100 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam steam_1 steam_3" 2290 100 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for HOT WATER tab on
add_de1_text "water water_1 water_3" 405 100 -text [translate "PRE-HEAT CUP"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "water water_1 water_3" 1035 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "water water_1 water_3" 1665 100 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "water water_1 water_3" 2290 100 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" {say [translate {pre-heat}] $::settings(sound_button_in); set_next_page off preheat_1; page_show preheat_1} 0 0 641 188
add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" {say [translate {espresso}] $::settings(sound_button_in); set_next_page off off; page_show off} 642 0 1277 188
add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" {say [translate {steam}] $::settings(sound_button_in); set_next_page off steam_1; page_show steam_1} 1278 0 1904 188
add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" {say [translate {water}] $::settings(sound_button_in); set_next_page off water_1; page_show water_1} 1905 0 2560 188

# when the espresso machine is doing something, the top tabs have to first stop that function, then the tab can change
add_de1_button "preheat_2 steam water espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" {say [translate {pre-heat}] $::settings(sound_button_in);set_next_page off preheat_1; start_idle} 0 0 641 188
add_de1_button "preheat_2 steam water espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" {say [translate {espresso}] $::settings(sound_button_in);set_next_page off off; start_idle} 642 0 1277 188
add_de1_button "preheat_2 steam water espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" {say [translate {steam}] $::settings(sound_button_in);set_next_page off steam_1; start_idle} 1278 0 1904 188
add_de1_button "preheat_2 steam water espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" {say [translate {water}] $::settings(sound_button_in);set_next_page off water_1; start_idle} 1905 0 2560 188

################################################################################################################################################################################################################################################################################################
# espresso charts

  
#######################
# 3 equal sized charts
add_de1_widget "espresso" graph 30 265 { 
	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #69fdb3  -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #40dc94  -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0 ; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 ; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure); 
	bind $widget [platform_button_press] { 
		say [translate {pressure zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_pressure; 
		set_next_page off espresso_3_zoom_pressure; 
		page_show espresso_zoom_pressure} 
	} -plotbackground #FFFFFF -width [rescale_x_skin 1649] -height [rescale_y_skin 328] -borderwidth 1 -background #FFFFFF -plotrelief flat

add_de1_widget "espresso" graph 30 667 {
	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #7aaaff -smooth quadratic -pixels 0  -dashes {5 5}; 
	$widget element create line_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 ; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_flowrate); 
	bind $widget [platform_button_press] { 
		say [translate {flow zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_flow; 
		set_next_page off espresso_3_zoom_flow; 
		page_show espresso_zoom_flow} 
	} -width [rescale_x_skin 1649] -height [rescale_y_skin 328]  -plotbackground #FFFFFF -borderwidth 1 -background #FFFFFF -plotrelief flat

#	$widget element create line_espresso_temperature_mix -xdata espresso_elapsed -ydata espresso_temperature_mix -label "" -linewidth [rescale_x_skin 6] -color #ffa5a6 -smooth quadratic -pixels 0; 
# -min $::de1(min_temperature) -max $::de1(max_temperature);
#
add_de1_widget "espresso" graph 30 1070 {
	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 4] -color #ffa5a6 -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -color #5a5d75 -tickfont Helv_6; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min [expr {[return_temperature_number $::settings(espresso_temperature)] - 4}] -max [expr {[return_temperature_number $::settings(espresso_temperature)] + 4}]; 
	bind $widget [platform_button_press] { 
		say [translate {pressure zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_temperature; 
		set_next_page off espresso_3_zoom_temperature; 
		page_show espresso_zoom_temperature} 
	} -width [rescale_x_skin 1649] -height [rescale_y_skin 328]  -plotbackground #FFFFFF -borderwidth 0 -background #FFFFFF -plotrelief flat
####


# and when the shot is done

add_de1_widget "espresso_3" graph 30 265 { 
	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #69fdb3  -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #40dc94  -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0 ; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 ; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure); 
	bind $widget [platform_button_press] { 
		say [translate {pressure zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_pressure; 
		set_next_page off espresso_3_zoom_pressure; 
		page_show espresso_3_zoom_pressure} 
	} -plotbackground #FFFFFF -width [rescale_x_skin 1649] -height [rescale_y_skin 328] -borderwidth 1 -background #FFFFFF -plotrelief flat

add_de1_widget "espresso_3" graph 30 667 {
	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #7aaaff -smooth quadratic -pixels 0  -dashes {5 5}; 
	$widget element create line_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 ; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_flowrate); 
	bind $widget [platform_button_press] { 
		say [translate {flow zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_flow; 
		set_next_page off espresso_3_zoom_flow; 
		page_show espresso_3_zoom_flow} 
	} -width [rescale_x_skin 1649] -height [rescale_y_skin 328]  -plotbackground #FFFFFF -borderwidth 1 -background #FFFFFF -plotrelief flat

#	$widget element create line_espresso_temperature_mix -xdata espresso_elapsed -ydata espresso_temperature_mix -label "" -linewidth [rescale_x_skin 6] -color #ffa5a6 -smooth quadratic -pixels 0; 
# -min $::de1(min_temperature) -max $::de1(max_temperature)
add_de1_widget "espresso_3" graph 30 1070 {
	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 4] -color #ffa5a6 -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -color #5a5d75 -tickfont Helv_6 ; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min [expr {[return_temperature_number $::settings(espresso_temperature)] - 4}] -max [expr {[return_temperature_number $::settings(espresso_temperature)] + 4}]; 
	bind $widget [platform_button_press] { 
		say [translate {pressure zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_temperature; 
		set_next_page off espresso_3_zoom_temperature; 
		page_show espresso_3_zoom_temperature} 
	} -width [rescale_x_skin 1649] -height [rescale_y_skin 328]  -plotbackground #FFFFFF -borderwidth 0 -background #FFFFFF -plotrelief flat
#######################



#add_de1_button "espresso espresso_3" {say [translate {pressure flow}] $::settings(sound_button_in);set_next_page espresso espresso_zoom_flow; page_show espresso_zoom_flow} 30 667 1679 1060
#add_de1_button "espresso espresso_3" {say [translate {pressure temperature}] $::settings(sound_button_in);set_next_page espresso espresso_zoom_temperature; page_show espresso_zoom_temperature} 30 1070 1679 921


#######################
# zoomed pressure chart big
add_de1_widget "espresso_zoom_pressure" graph 30 270 {
	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #69fdb3  -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #40dc94  -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0 ; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure) -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12}; 
	bind $widget [platform_button_press] { 
		say [translate {zoom back}] $::settings(sound_button_in); 
		set_next_page espresso espresso; 
		set_next_page off espresso_3; 
		page_show espresso} 
	} -plotbackground #FFFFFF -width [rescale_x_skin 1649] -height [rescale_y_skin 583] -borderwidth 1 -background #FFFFFF -plotrelief flat

add_de1_widget "espresso_zoom_pressure" graph 30 885 {
	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #7aaaff -smooth quadratic -pixels 0  -dashes {5 5}; 
	$widget element create line2_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_1 -hide 0; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_flowrate) ; 
	bind $widget [platform_button_press] { 
		say [translate {flow zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_flow; 
		set_next_page off espresso_3_zoom_flow; 
		page_show espresso_zoom_flow} 
	} -width [rescale_x_skin 1649] -height [rescale_y_skin 240]  -plotbackground #FFFFFF -borderwidth 1 -background #FFFFFF -plotrelief flat

#	$widget element create line_espresso_temperature_mix -xdata espresso_elapsed -ydata espresso_temperature_mix -label "" -linewidth [rescale_x_skin 6] -color #ffa5a6 -smooth quadratic -pixels 0; 
# -min $::de1(min_temperature) -max $::de1(max_temperature)
add_de1_widget "espresso_zoom_pressure" graph 30 1165 {
	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 4] -color #ffa5a6 -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -color #5a5d75 -tickfont Helv_1 -hide 0; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min [expr {[return_temperature_number $::settings(espresso_temperature)] - 4}] -max [expr {[return_temperature_number $::settings(espresso_temperature)] + 4}]; 
	bind $widget [platform_button_press] { 
		say [translate {pressure zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_temperature; 
		set_next_page off espresso_3_zoom_temperature; 
		page_show espresso_zoom_temperature} 
	} -width [rescale_x_skin 1649] -height [rescale_y_skin 240]  -plotbackground #FFFFFF -borderwidth 0 -background #FFFFFF -plotrelief flat

# and when the shot is done

add_de1_widget "espresso_3_zoom_pressure" graph 30 270 {
	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #69fdb3  -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #40dc94  -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0 ; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure) -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12}; 
	bind $widget [platform_button_press] { 
		say [translate {zoom back}] $::settings(sound_button_in); 
		set_next_page espresso espresso; 
		set_next_page off espresso_3; 
		page_show espresso_3} 
	} -plotbackground #FFFFFF -width [rescale_x_skin 1649] -height [rescale_y_skin 583] -borderwidth 1 -background #FFFFFF -plotrelief flat

add_de1_widget "espresso_3_zoom_pressure" graph 30 885 {
	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #7aaaff -smooth quadratic -pixels 0  -dashes {5 5}; 
	$widget element create line2_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_1 -hide 0; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_flowrate) ; 
	bind $widget [platform_button_press] { 
		say [translate {flow zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_flow; 
		set_next_page off espresso_3_zoom_flow; 
		page_show espresso_3_zoom_flow} 
	} -width [rescale_x_skin 1649] -height [rescale_y_skin 240]  -plotbackground #FFFFFF -borderwidth 1 -background #FFFFFF -plotrelief flat

#	$widget element create line_espresso_temperature_mix -xdata espresso_elapsed -ydata espresso_temperature_mix -label "" -linewidth [rescale_x_skin 6] -color #ffa5a6 -smooth quadratic -pixels 0; 
# -min $::de1(min_temperature) -max $::de1(max_temperature)
add_de1_widget "espresso_3_zoom_pressure" graph 30 1165 {
	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 4] -color #ffa5a6 -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -color #5a5d75 -tickfont Helv_1 -hide 0; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6c -min [expr {$::settings(espresso_temperature) - 4}] -max [expr {$::settings(espresso_temperature) + 4}]; 
	bind $widget [platform_button_press] { 
		say [translate {pressure zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_temperature; 
		set_next_page off espresso_3_zoom_temperature; 
		page_show espresso_3_zoom_temperature} 
	} -width [rescale_x_skin 1649] -height [rescale_y_skin 240]  -plotbackground #FFFFFF -borderwidth 0 -background #FFFFFF -plotrelief flat

#######################




#######################
# zoomed flow chart big
add_de1_widget "espresso_zoom_flow" graph 30 270 {
	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #69fdb3  -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #40dc94  -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0 ; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_1; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure);
	bind $widget [platform_button_press] { 
		say [translate {pressure zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_pressure; 
		set_next_page off espresso_3_zoom_pressure; 
		page_show espresso_zoom_pressure} 
	} -plotbackground #FFFFFF -width [rescale_x_skin 1649] -height [rescale_y_skin 240] -borderwidth 1 -background #FFFFFF -plotrelief flat

add_de1_widget "espresso_zoom_flow" graph 30 555 {
	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #7aaaff -smooth quadratic -pixels 0  -dashes {5 5}; 
	$widget element create line2_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -hide 0; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_flowrate) ; 
	bind $widget [platform_button_press] { 
		say [translate {zoom back}] $::settings(sound_button_in); 
		set_next_page espresso espresso; 
		set_next_page off espresso_3; 
		page_show espresso} 
	} -width [rescale_x_skin 1649] -height [rescale_y_skin 570]  -plotbackground #FFFFFF -borderwidth 1 -background #FFFFFF -plotrelief flat

#	$widget element create line_espresso_temperature_mix -xdata espresso_elapsed -ydata espresso_temperature_mix -label "" -linewidth [rescale_x_skin 6] -color #ffa5a6 -smooth quadratic -pixels 0; 
# -min $::de1(min_temperature) -max $::de1(max_temperature)
add_de1_widget "espresso_zoom_flow" graph 30 1155 {
	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 4] -color #ffa5a6 -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -color #5a5d75 -tickfont Helv_1 -hide 0; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min [expr {[return_temperature_number $::settings(espresso_temperature)] - 4}] -max [expr {[return_temperature_number $::settings(espresso_temperature)] + 4}]; 
	bind $widget [platform_button_press] { 
		say [translate {pressure zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_temperature; 
		set_next_page off espresso_3_zoom_temperature; 
		page_show espresso_zoom_temperature} 
	} -width [rescale_x_skin 1649] -height [rescale_y_skin 240]  -plotbackground #FFFFFF -borderwidth 0 -background #FFFFFF -plotrelief flat

# and when the shot is done
add_de1_widget "espresso_3_zoom_flow" graph 30 270 {
	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #69fdb3  -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #40dc94  -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0 ; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_1; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure);
	bind $widget [platform_button_press] { 
		say [translate {pressure zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_pressure; 
		set_next_page off espresso_3_zoom_pressure; 
		page_show espresso_3_zoom_pressure} 
	} -plotbackground #FFFFFF -width [rescale_x_skin 1649] -height [rescale_y_skin 240] -borderwidth 1 -background #FFFFFF -plotrelief flat

add_de1_widget "espresso_3_zoom_flow" graph 30 555 {
	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #7aaaff -smooth quadratic -pixels 0  -dashes {5 5}; 
	$widget element create line2_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_6 -hide 0; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_flowrate) ; 
	bind $widget [platform_button_press] { 
		say [translate {zoom back}] $::settings(sound_button_in); 
		set_next_page espresso espresso; 
		set_next_page off espresso_3; 
		page_show espresso_3} 
	} -width [rescale_x_skin 1649] -height [rescale_y_skin 570]  -plotbackground #FFFFFF -borderwidth 1 -background #FFFFFF -plotrelief flat

#	$widget element create line_espresso_temperature_mix -xdata espresso_elapsed -ydata espresso_temperature_mix -label "" -linewidth [rescale_x_skin 6] -color #ffa5a6 -smooth quadratic -pixels 0; 
# -min $::de1(min_temperature) -max $::de1(max_temperature)
add_de1_widget "espresso_3_zoom_flow" graph 30 1155 {
	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 4] -color #ffa5a6 -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -color #5a5d75 -tickfont Helv_1 -hide 0; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min [expr {[return_temperature_number $::settings(espresso_temperature)] - 4}] -max [expr {[return_temperature_number $::settings(espresso_temperature)] + 4}]; 
	bind $widget [platform_button_press] { 
		say [translate {pressure zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_temperature; 
		set_next_page off espresso_3_zoom_temperature; 
		page_show espresso_3_zoom_temperature} 
	} -width [rescale_x_skin 1649] -height [rescale_y_skin 240]  -plotbackground #FFFFFF -borderwidth 0 -background #FFFFFF -plotrelief flat

#######################


#######################
# zoomed temperature chart big
add_de1_widget "espresso_zoom_temperature" graph 30 270 {
	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #69fdb3  -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #40dc94  -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0 ; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_1; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure);
	bind $widget [platform_button_press] { 
		say [translate {pressure zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_pressure; 
		set_next_page off espresso_3_zoom_pressure; 
		page_show espresso_zoom_pressure} 
	} -plotbackground #FFFFFF -width [rescale_x_skin 1649] -height [rescale_y_skin 240] -borderwidth 1 -background #FFFFFF -plotrelief flat

add_de1_widget "espresso_zoom_temperature" graph 30 555 {
	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #7aaaff -smooth quadratic -pixels 0  -dashes {5 5}; 
	$widget element create line2_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_1 -hide 0; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_flowrate) ; 
	bind $widget [platform_button_press] { 
		say [translate {flow zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_flow; 
		set_next_page off espresso_3_zoom_flow; 
		page_show espresso_zoom_flow} 
	} -width [rescale_x_skin 1625] -height [rescale_y_skin 240]  -plotbackground #FFFFFF -borderwidth 1 -background #FFFFFF -plotrelief flat

#	$widget element create line_espresso_temperature_mix -xdata espresso_elapsed -ydata espresso_temperature_mix -label "" -linewidth [rescale_x_skin 6] -color #ffa5a6 -smooth quadratic -pixels 0; 
# -min $::de1(min_temperature) -max $::de1(max_temperature)
add_de1_widget "espresso_zoom_temperature" graph 30 825 {
	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 4] -color #ffa5a6 -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -color #5a5d75 -tickfont Helv_6 -hide 0; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min [expr {[return_temperature_number $::settings(espresso_temperature)] - 4}] -max [expr {[return_temperature_number $::settings(espresso_temperature)] + 4}]; 
	bind $widget [platform_button_press] { 
		say [translate {zoom back}] $::settings(sound_button_in); 
		set_next_page espresso espresso; 
		set_next_page off espresso_3; 
		page_show espresso} 
	} -width [rescale_x_skin 1625] -height [rescale_y_skin 563]  -plotbackground #FFFFFF -borderwidth 0 -background #FFFFFF -plotrelief flat

# and when the shot is done
add_de1_widget "espresso_3_zoom_temperature" graph 30 270 {
	$widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #69fdb3  -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #40dc94  -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0 ; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_1; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure);
	bind $widget [platform_button_press] { 
		say [translate {pressure zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_pressure; 
		set_next_page off espresso_3_zoom_pressure; 
		page_show espresso_3_zoom_pressure} 
	} -plotbackground #FFFFFF -width [rescale_x_skin 1649] -height [rescale_y_skin 240] -borderwidth 1 -background #FFFFFF -plotrelief flat

add_de1_widget "espresso_3_zoom_temperature" graph 30 535 {
	$widget element create line_espresso_flow_goal  -xdata espresso_elapsed -ydata espresso_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #7aaaff -smooth quadratic -pixels 0  -dashes {5 5}; 
	$widget element create line2_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -tickfont Helv_1 -hide 0; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_flowrate) ; 
	bind $widget [platform_button_press] { 
		say [translate {flow zoom}] $::settings(sound_button_in); 
		set_next_page espresso espresso_zoom_flow; 
		set_next_page off espresso_3_zoom_flow; 
		page_show espresso_3_zoom_flow} 
	} -width [rescale_x_skin 1625] -height [rescale_y_skin 240]  -plotbackground #FFFFFF -borderwidth 1 -background #FFFFFF -plotrelief flat

	#$widget element create line_espresso_temperature_mix -xdata espresso_elapsed -ydata espresso_temperature_mix -label "" -linewidth [rescale_x_skin 6] -color #ffa5a6 -smooth quadratic -pixels 0; 
	#-min $::de1(min_temperature) -max $::de1(max_temperature)
add_de1_widget "espresso_3_zoom_temperature" graph 30 825 {
	$widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata espresso_temperature_goal -symbol none -label ""  -linewidth [rescale_x_skin 4] -color #ffa5a6 -smooth quadratic -pixels 0 -dashes {5 5}; 
	$widget element create line2_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth quadratic -pixels 0; 
	$widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; 
	$widget axis configure x -color #5a5d75 -color #5a5d75 -tickfont Helv_6 -hide 0; 
	$widget axis configure y -color #5a5d75 -tickfont Helv_6 -min [expr {[return_temperature_number $::settings(espresso_temperature)] - 4}] -max [expr {[return_temperature_number $::settings(espresso_temperature)] + 4}]; 
	bind $widget [platform_button_press] { 
		say [translate {zoom back}] $::settings(sound_button_in); 
		set_next_page espresso espresso; 
		set_next_page off espresso_3; 
		page_show espresso_3} 
	} -width [rescale_x_skin 1625] -height [rescale_y_skin 563]  -plotbackground #FFFFFF -borderwidth 0 -background #FFFFFF -plotrelief flat


#######################


# make flow chart big
#add_de1_widget "espresso_zoom_flow espresso_3_zoom_flow" graph 30 265 {$widget element create line_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #40dc94  -smooth quadratic -pixels 0; $widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0 ; $widget axis configure x -color #5a5d75 -tickfont Helv_6 ; $widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure);} -plotbackground #FFFFFF -width 1649 -height 164 -borderwidth 1 -background #FFFFFF -plotrelief flat
#add_de1_widget "espresso_zoom_flow espresso_3_zoom_flow" graph 30 467 {$widget element create line_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #7aaaff -smooth quadratic -pixels 0; $widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; $widget axis configure x -color #5a5d75 -tickfont Helv_6 ; $widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_flowrate); } -width 1649 -height 656 -plotbackground #FFFFFF -borderwidth 1 -background #FFFFFF -plotrelief flat
#add_de1_widget "espresso_zoom_flow espresso_3_zoom_flow" graph 30 1870 {$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth quadratic -pixels 0; $widget element create line_espresso_temperature_mix -xdata espresso_elapsed -ydata espresso_temperature_mix -label "" -linewidth [rescale_x_skin 6] -color #ffa5a6 -smooth quadratic -pixels 0; $widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; $widget axis configure x -color #5a5d75 -color #5a5d75 -tickfont Helv_6 ; $widget axis configure y -color #5a5d75 -tickfont Helv_6 -min $::de1(min_temperature) -max $::de1(max_temperature); } -width 1649 -height 164  -plotbackground #FFFFFF -borderwidth 0 -background #FFFFFF -plotrelief flat

# make temperature chart big
#add_de1_widget "espresso_zoom_temperature espresso_3_zoom_temperature" graph 30 265 {$widget element create line_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #40dc94  -smooth quadratic -pixels 0; $widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0 ; $widget axis configure x -color #5a5d75 -tickfont Helv_6 ; $widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_pressure);} -plotbackground #FFFFFF -width 1649 -height 164 -borderwidth 1 -background #FFFFFF -plotrelief flat
#add_de1_widget "espresso_zoom_temperature espresso_3_zoom_temperature" graph 30 467 {$widget element create line_espresso_flow  -xdata espresso_elapsed -ydata espresso_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4 -smooth quadratic -pixels 0; $widget element create line_espresso_state_change_2 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; $widget axis configure x -color #5a5d75 -tickfont Helv_6 ; $widget axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max $::de1(max_flowrate); } -width 1649 -height 164 -plotbackground #FFFFFF -borderwidth 1 -background #FFFFFF -plotrelief flat
#add_de1_widget "espresso_zoom_temperature espresso_3_zoom_temperature" graph 30 669 {$widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata espresso_temperature_basket -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249 -smooth quadratic -pixels 0; $widget element create line_espresso_temperature_mix -xdata espresso_elapsed -ydata espresso_temperature_mix -label "" -linewidth [rescale_x_skin 6] -color #ffa5a6 -smooth quadratic -pixels 0; $widget element create line_espresso_state_change_3 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 6] -color #888888  -pixels 0; $widget axis configure x -color #5a5d75 -color #5a5d75 -tickfont Helv_6 ; $widget axis configure y -color #5a5d75 -tickfont Helv_6 -min $::de1(min_temperature) -max $::de1(max_temperature); } -width 1649 -height 656 -plotbackground #FFFFFF -borderwidth 0 -background #FFFFFF -plotrelief flat
################################################################################################################################################################################################################################################################################################

# save/load/clear buttons
add_de1_text "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" 1240 1520 -text [translate "Clear"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 
add_de1_text "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" 1760 1520 -text [translate "Load"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 
add_de1_text "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" 2275 1520 -text [translate "Save"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 

# the "go to sleep" button and the whole-screen button for coming back awake
add_de1_button "off espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" {say [translate {sleep}] $::settings(sound_button_in); start_sleep} 0 1424 350 1600
add_de1_button "saver" {say [translate {awake}] $::settings(sound_button_in); start_idle} 0 0 2560 1600
add_de1_text "sleep" 2500 1450 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 

# temporary exit button to quit app
add_de1_button "off espresso_3 steam_1 water_1 preheat_1 steam_3 water_3 preheat_3 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" {after 700 update_de1_explanation_chart;unset -nocomplain ::settings_backup; array set ::settings_backup [array get ::settings]; set_next_page off settings_1; page_show settings_1} 351 1424 800 1600

# text on the first espresso page
add_de1_text "off" 65 240 -text [translate "1) Preinfuse the coffee puck with hot water"] -font Helv_9 -fill "#5a5d75" -justify "left" -anchor "nw"
add_de1_text "off" 65 870 -text [translate "2) Make espresso"] -font Helv_9 -fill "#5a5d75" -justify "left" -anchor "nw"
add_de1_text "off" 80 330 -text [translate "PREINFUSE AT:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "off" 735 330 -text [translate "STOP PREINFUSION WHEN..."] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 2200 417 -text [translate "STOP"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso_3 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" 2200 417 -text [translate "DONE"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 2205 430 -text [translate "START"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off" 2205 765 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 
add_de1_text "espresso_3 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" 2205 715 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 

add_de1_variable "off" 2230 480 -justify right -anchor "ne" -text "" -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520] -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off" 2235 480 -justify left -anchor "nw" -text "" -font Helv_7 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[group_head_heater_temperature_text]} 


add_de1_variable "off" 232 757 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[return_flow_measurement $::settings(preinfusion_flow_rate)]}
add_de1_variable "off" 490 490 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(preinfusion_temperature)]}
add_de1_variable "off" 835 757 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[setting_espresso_stop_flow_text]}
add_de1_variable "off" 1132 757 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[setting_espresso_stop_pressure_text]}
#add_de1_variable "off" 1132 757 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_one_digits $::settings(preinfusion_stop_pressure)] [translate "bar"]}

add_de1_variable "off" 1423 757 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[return_liquid_measurement $::settings(preinfusion_stop_volumetric)]}
add_de1_variable "off" 1717 757 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_one_digits $::settings(preinfusion_stop_timeout)][translate "s"]}


add_de1_text "off" 232 703  -text [translate "FLOW RATE"] -font Helv_7 -fill "#7f879a" -anchor "center" 
add_de1_text "off" 490 432 -text [translate "TEMP"] -font Helv_7 -fill "#7f879a" -anchor "center" 

add_de1_text "off" 835 670 -text [translate "FLOW RATE SLOWS TO"] -font Helv_7 -fill "#7f879a" -anchor "center"  -width [rescale_x_skin 250] -justify center
add_de1_text "off" 980 722 -text [translate "OR"] -font Helv_7 -fill "#7f879a" -anchor "center"

add_de1_text "off" 1132 670 -text [translate "PRESSURE GOES OVER"] -font Helv_7 -fill "#7f879a" -anchor "center"  -width [rescale_x_skin 250] -justify center
add_de1_text "off" 1280 722 -text [translate "OR"] -font Helv_7 -fill "#7f879a" -anchor "center"

add_de1_text "off" 1423 670 -text [translate "WATER REACHES"] -font Helv_7 -fill "#7f879a" -anchor "center"  -width [rescale_x_skin 250] -justify center
add_de1_text "off" 1570 722 -text [translate "OR"] -font Helv_7 -fill "#7f879a" -anchor "center"

add_de1_text "off" 1717 670 -text [translate "TIME-OUT"] -font Helv_7 -fill "#7f879a" -anchor "center"  -width [rescale_x_skin 250] -justify center

# the espresso recipe steps
add_de1_text "off" 76 957 -text [espresso_frame_title 1] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width [rescale_x_skin 760]
add_de1_text "off" 76 997 -text [espresso_frame_description 1] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width [rescale_x_skin 760] -justify left

add_de1_text "off" 76 1174 -text [espresso_frame_title 2] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width [rescale_x_skin 760]
add_de1_text "off" 76 1214 -text [espresso_frame_description 2] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width [rescale_x_skin 760] -justify left

add_de1_text "off" 893 957 -text [espresso_frame_title 3] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width [rescale_x_skin 760]
add_de1_text "off" 893 997 -text [espresso_frame_description 3] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width [rescale_x_skin 760] -justify left

add_de1_text "off" 893 1174 -text [espresso_frame_title 4] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width [rescale_x_skin 760]
add_de1_text "off" 893 1214 -text [espresso_frame_description 4] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width [rescale_x_skin 760] -justify left

add_de1_text "off" 1710 957 -text [espresso_frame_title 5] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width [rescale_x_skin 760]
add_de1_text "off" 1710 997 -text [espresso_frame_description 5] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width [rescale_x_skin 760] -justify left

add_de1_text "off" 1710 1174 -text [espresso_frame_title 6] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width [rescale_x_skin 760]
add_de1_text "off" 1710 1214 -text [espresso_frame_description 6] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width [rescale_x_skin 760] -justify left


##########################################################################################################################################################################################################################################################################
# making espresso now

# make and stop espresso button
add_de1_button "off" {say [translate {esspresso}] $::settings(sound_button_in);set_next_page off espresso_3; start_espresso} 1900 200 2560 690
add_de1_button "off" {say [translate {rinse}] $::settings(sound_button_in);set_next_page off espresso_3; start_espresso} 1900 691 2560 855
add_de1_button "espresso_3 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" {say [translate {rinse}] $::settings(sound_button_in);set_next_page off espresso_3; start_espresso} 1900 621 2560 855
add_de1_button "off" {say "" $::settings(sound_button_in);vertical_slider ::settings(preinfusion_flow_rate) 0.1 6 %x %y %x0 %y0 %x1 %y1} 0 320 400 830 "mousemove"
add_de1_button "off" {say "" $::settings(sound_button_in);vertical_slider ::settings(preinfusion_temperature) 80 96 %x %y %x0 %y0 %x1 %y1} 401 320 700 830 "mousemove"
add_de1_button "off" {say "" $::settings(sound_button_in); set ::settings(preinfusion_stop_pressure) {0}; vertical_slider ::settings(preinfusion_stop_flow_rate) 0.1 6 %x %y %x0 %y0 %x1 %y1} 701 320 980 830 "mousemove"
add_de1_button "off" {say "" $::settings(sound_button_in); set ::settings(preinfusion_stop_flow_rate) {0}; vertical_slider ::settings(preinfusion_stop_pressure) 0 6 %x %y %x0 %y0 %x1 %y1} 981 320 1280 830 "mousemove"
add_de1_button "off" {say "" $::settings(sound_button_in);vertical_slider ::settings(preinfusion_stop_volumetric) 0.1 50 %x %y %x0 %y0 %x1 %y1} 1281 320 1570 830 "mousemove"
add_de1_button "off" {say "" $::settings(sound_button_in);vertical_slider ::settings(preinfusion_stop_timeout) 0 120 %x %y %x0 %y0 %x1 %y1} 1571 320 1870 830 "mousemove"

#add_de1_button "off" {say [translate {flow rate}] $::settings(sound_button_in);puts "tap: -width %x -length %y %X %Y %h %w"} 0 320 400 800


# example of creating a widget on the page, to change a variable
#add_de1_widget "off" scale 100 300 -from 6.0 -to 0.1 -background #f1f1f1 -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 400 -width 50 

#graph .g -title "Graph of Flow Rate and Total Weight" 
#.g configure -width 50 -font ConsoleFont 

add_de1_button "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" {say [translate {stop}] $::settings(sound_button_in);start_idle} 1900 201 2560 1400
add_de1_button "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" {say [translate {stop}] $::settings(sound_button_in);start_idle} 0 189 2560 200
add_de1_button "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" {say [translate {next step}] $::settings(sound_button_in); next_espresso_step } 0 1405 2560 1600
add_de1_button "espresso_3 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" "set_next_page off off; page_show off" 1900 189 2560 620

add_de1_text "espresso espresso_3" 43 220 -text [translate "PRESSURE:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "espresso espresso_3" 43 628 -text [translate "FLOW:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "espresso espresso_3" 43 1030 -text [translate "TEMPERATURE:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "espresso_zoom_temperature espresso_3_zoom_temperature" 43 787 -text [translate "TEMPERATURE:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_text "espresso_zoom_pressure espresso_3_zoom_pressure espresso_zoom_flow espresso_3_zoom_flow espresso_zoom_temperature espresso_3_zoom_temperature" 43 220 -text [translate "PRESSURE:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "espresso_zoom_flow espresso_3_zoom_flow" 43 507 -text [translate "FLOW:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "espresso_zoom_temperature espresso_3_zoom_temperature" 43 500 -text [translate "FLOW:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_text "espresso_zoom_pressure espresso_3_zoom_pressure " 43 844 -text [translate "FLOW:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "espresso_zoom_pressure espresso_3_zoom_pressure espresso_zoom_flow espresso_3_zoom_flow" 43 1116 -text [translate "TEMPERATURE:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"



add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 40 1425 -text [espresso_frame_title 1] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width [rescale_x_skin 1600]
add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 40 1470 -text [espresso_frame_description 1] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width [rescale_x_skin 1600] -justify left

add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1720 1453 -text [espresso_frame_title 2] -font Helv_6_bold -fill "#5a5d75" -anchor "nw" -justify "left" -width [rescale_x_skin 800]
add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1720 1535 -text [espresso_frame_title 3] -font Helv_6_bold -fill "#5a5d75" -anchor "nw" -justify "left" -width [rescale_x_skin 800]

##########################################################################################################################################################################################################################################################################


##########################################################################################################################################################################################################################################################################
# data card displayed during espresso making
add_de1_variable "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1900 710 -text "" -font Helv_8_bold -fill "#2d3046" -anchor "nw" -textvariable {[string toupper [translate [de1_substate_text]]]} 

add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1900 785 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]

add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1900 840 -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 2500 840 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[timer][translate "s"]} 

add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1900 890 -justify right -anchor "nw" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 2500 890 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[setting_espresso_max_time][translate "s"]} 

add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1900 940 -justify right -anchor "nw" -text [translate "Preinfusion:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 2500 940 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[preinfusion_timer][translate "s"]} 

add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1900 990 -justify right -anchor "nw" -text [translate "Pouring:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 2500 990 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[pour_timer][translate "s"]} 


add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1900 1070 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]

add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1900 1120 -justify right -anchor "nw" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 2500 1120 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[pressure_text]} 
add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1900 1170 -justify right -anchor "nw" -text [translate "Basket temp:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 2500 1170 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watertemp_text]} 
add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1900 1220 -justify right -anchor "nw" -text [translate "Mix temp:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]

add_de1_variable "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 2500 1220 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[mixtemp_text]} 
#add_de1_variable "espresso" 2500 1220 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[mixtemp_text]} 
#add_de1_variable "espresso_zoom_pressure" 2500 1220 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[mixtemp_text]} 
#add_de1_variable "espresso_zoom_flow" 2500 1220 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[mixtemp_text]} 
#add_de1_variable "espresso_zoom_temperature" 2500 1220 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[mixtemp_text]} 

#add_de1_variable "espresso espresso_zoom_temperature" 2500 1220 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[mixtemp_text]} 


add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1900 1270 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 2500 1270 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 
add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1900 1320 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 2500 1320 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 

if {$::settings(flight_mode_enable) == 1} {
	add_de1_text "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 1900 1370 -justify right -anchor "nw" -text [translate "Flight mode:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
	add_de1_variable "espresso espresso_zoom_pressure espresso_zoom_flow espresso_zoom_temperature" 2500 1370 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[accelerometer_angle]º} 
}

add_de1_text "espresso_3 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" 1920 1270 -justify right -anchor "nw" -text [translate "Finished:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "espresso_3 espresso_3_zoom_pressure espresso_3_zoom_flow espresso_3_zoom_temperature" 2460 1270 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[timer][translate "s"]} 

##########################################################################################################################################################################################################################################################################


##########################################################################################################################################################################################################################################################################
# settings for preheating a cup

add_de1_text "preheat_1" 1390 805 -text [translate "START"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "preheat_2" 1390 805 -text [translate "STOP"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "preheat_3" 1390 805 -text [translate "DONE"] -font Helv_20_bold -fill "#7f879a" -anchor "center" 

add_de1_button "preheat_1" {say [translate {pre-heat cup}] $::settings(sound_button_in); set_next_page water preheat_2; start_water} 1030 210 2560 1400
add_de1_button "preheat_2" {say [translate {stop}] $::settings(sound_button_in); set_next_page off preheat_3; start_idle} 0 189 2560 1600
add_de1_button "preheat_3" "set_next_page off preheat_1; page_show preheat_1" 0 189 2560 1422

add_de1_button "preheat_1" {say "" $::settings(sound_button_in);vertical_slider ::settings(preheat_volume) 1 400 %x %y %x0 %y0 %x1 %y1} 0 210 550 1400 "mousemove"
add_de1_button "preheat_1" {say "" $::settings(sound_button_in);vertical_slider ::settings(preheat_temperature) 20 96 %x %y %x0 %y0 %x1 %y1} 551 210 1029 1400 "mousemove"

add_de1_text "preheat_1" 70 250 -text [translate "1) How much water and how hot"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 900]
add_de1_text "preheat_1 preheat_2" 1070 250 -text [translate "2) Water will pour into your cup"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "preheat_1" 1840 250 -text [translate "3) Hot water warms your cup"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 680]
add_de1_text "preheat_3" 1840 250 -text [translate "3) Hot water warms your cup"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 680]

add_de1_variable "preheat_1" 300 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_liquid_measurement $::settings(preheat_volume)]}
add_de1_text "preheat_1" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#7f879a" -anchor "center" 
add_de1_variable "preheat_1" 755 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(preheat_temperature)]}
add_de1_text "preheat_1" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill "#7f879a" -anchor "center" 

add_de1_variable "preheat_2 preheat_3" 300 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[return_liquid_measurement $::settings(preheat_volume)]}
add_de1_text "preheat_2 preheat_3" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 
add_de1_variable "preheat_2 preheat_3" 755 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[return_temperature_measurement $::settings(preheat_temperature)]}
add_de1_text "preheat_2 preheat_3" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 


add_de1_text "preheat_3" 1880 1270 -justify right -anchor "nw" -text [translate "Finished:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "preheat_3" 2460 1270 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[timer][translate "s"]} 


##########################################################################################################################################################################################################################################################################

##########################################################################################################################################################################################################################################################################
# settings for dispensing hot water

add_de1_text "water_1" 1390 1270 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 
add_de1_text "water_1" 1390 805 -text [translate "START"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 1390 805 -text [translate "STOP"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water_3" 1390 805 -text [translate "DONE"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_button "water_1" {say [translate {hot water}] $::settings(sound_button_in); set_next_page water water; start_water} 1030 210 2560 1100
add_de1_button "water" {say [translate {stop}] $::settings(sound_button_in); set_next_page off water_3 ; start_idle} 0 189 2560 1600
add_de1_button "water_3" {set_next_page off water_1; page_show water_1} 0 189 2560 1422
add_de1_button "water_1" {say [translate {rinse}] $::settings(sound_button_in); set_next_page water water; start_water} 1030 1101 1760 1400


add_de1_button "water_1" {say "" $::settings(sound_button_in);vertical_slider ::settings(water_volume) 1 400 %x %y %x0 %y0 %x1 %y1} 0 210 550 1400 "mousemove"
add_de1_button "water_1" {say "" $::settings(sound_button_in);vertical_slider ::settings(water_temperature) 20 96 %x %y %x0 %y0 %x1 %y1} 551 210 1029 1400 "mousemove"

#add_de1_text "water_1" 70 250 -text [translate "1) Choose: how much water and how hot"] -font Helv_10 -fill "#5a5d75" -anchor "nw" -width 900
add_de1_text "water_1" 1070 250 -text [translate "2) Water will pour into your cup"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "water" 70 250 -text [translate "1) How much water and how hot"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 900]

add_de1_variable "water_1" 300 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center"  -textvariable {[return_liquid_measurement $::settings(water_volume)]}
add_de1_text "water_1" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#7f879a" -anchor "center" 
add_de1_variable "water_1" 755 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}
add_de1_text "water_1" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill "#7f879a" -anchor "center" 

add_de1_variable "water" 300 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center"  -textvariable {[return_liquid_measurement $::settings(water_volume)]}
add_de1_text "water" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 
add_de1_variable "water" 755 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[return_temperature_measurement $::settings(water_temperature)]}
add_de1_text "water" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 

# data card
add_de1_text "water" 1100 280 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]
add_de1_text "water" 1100 330 -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "water" 1720 330 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[water_timer][translate "s"]} 
add_de1_text "water" 1100 380 -justify right -anchor "nw" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "water" 1720 380 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[setting_water_max_time][translate "s"]} 

add_de1_text "water" 1100 1150 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]

add_de1_text "water" 1100 1200 -justify right -anchor "nw" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "water" 1720 1200 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -text "" -textvariable {[watertemp_text]} 


add_de1_text "water" 1100 1250 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "water" 1720 1250 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 
add_de1_text "water" 1100 1300 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "water" 1720 1300 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 


add_de1_text "water_3" 1110 1270 -justify right -anchor "nw" -text [translate "Finished:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "water_3" 1670 1270 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[timer][translate "s"]} 



##########################################################################################################################################################################################################################################################################



##########################################################################################################################################################################################################################################################################
# settings for steam

add_de1_text "steam_1" 1390 1270 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 
add_de1_text "steam_3" 2180 1280 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 
add_de1_text "steam_1" 1390 790 -text [translate "START"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 1390 805 -text [translate "STOP"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam_2" 1390 805 -text [translate "DONE"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam_3" 1390 805 -text [translate "DONE"] -font Helv_20_bold -fill "#7f879a" -anchor "center" 
add_de1_button "steam_1" {say [translate {steam}] $::settings(sound_button_in); start_steam} 1030 210 2560 1100
add_de1_button "steam_1" {say [translate {rinse}] $::settings(sound_button_in); start_steam} 1030 1101 1760 1400
add_de1_button "steam" {say [translate {stop}] $::settings(sound_button_in); set_next_page off steam_3; start_idle} 0 189 2560 1600
add_de1_button "steam_3" {say [translate {steam}] $::settings(sound_button_in); set_next_page off steam_1; page_show steam_1} 0 189 1810 1422
add_de1_button "steam_3" {say [translate {steam}] $::settings(sound_button_in); start_steam} 1811 189 2560 1422

add_de1_variable "steam_1" 1405 840 -justify right -anchor "ne" -text "" -font Helv_7 -fill "#7f879a" -width [rescale_x_skin 520] -textvariable {[steam_heater_action_text]} 
add_de1_variable "steam_1" 1410 840 -justify left -anchor "nw" -font Helv_7 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[setting_steam_temperature_text]} 

add_de1_button "steam_1" {say [translate ""] $::settings(sound_button_in);vertical_slider ::settings(steam_temperature) 140 170 %x %y %x0 %y0 %x1 %y1} 0 210 450 1400 "mousemove"
add_de1_button "steam_1" {say [translate ""] $::settings(sound_button_in);vertical_slider ::settings(steam_timeout) 1 500 %x %y %x0 %y0 %x1 %y1} 451 210 1029 1400 "mousemove"

add_de1_text "steam_1" 70 250 -text [translate "1) Steam temperature and auto-off time"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 900]
add_de1_text "steam_1" 1070 250 -text [translate "2) Steam will start"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 650]
add_de1_text "steam_1" 1840 250 -text [translate "3) Pour amazing latte art"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 680]
add_de1_text "steam_3" 1840 250 -text [translate "3) Pour amazing latte art"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width [rescale_x_skin 680]
add_de1_text "steam" 70 250 -text [translate "1) Steam temperature and auto-off time"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 900]
add_de1_text "steam" 1840 250 -text [translate "3) Make amazing latte art"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width [rescale_x_skin 680]

add_de1_variable "steam_1" 300 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[return_temperature_measurement $::settings(steam_temperature)]}
add_de1_text "steam_1" 300 1300  -text [translate "TEMP"] -font Helv_7 -fill "#7f879a" -anchor "center" 
add_de1_variable "steam_1" 720 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center"  -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}
add_de1_text "steam_1" 720 1300 -text [translate "AUTO-OFF"] -font Helv_7 -fill "#7f879a" -anchor "center" 


#add_de1_variable "off" 1717 757 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_one_digits $::settings(preinfusion_stop_timeout)][translate "s"]}

add_de1_variable "steam" 300 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[return_temperature_measurement $::settings(steam_temperature)]}
add_de1_text "steam" 300 1300  -text [translate "TEMP"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 
add_de1_variable "steam" 720 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center"  -textvariable {[round_to_integer $::settings(steam_timeout)][translate "s"]}
add_de1_text "steam" 720 1300 -text [translate "AUTO-OFF"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 

# variables to display during steam
add_de1_text "steam" 1100 280 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]

add_de1_text "steam" 1100 330  -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "steam" 1720 330 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[steam_timer][translate "s"]} 
add_de1_text "steam" 1100 380 -justify right -anchor "nw" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "steam" 1720 380 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[setting_steam_max_time][translate "s"]} 

add_de1_text "steam" 1100 1100 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width [rescale_x_skin 520]
add_de1_text "steam" 1100 1150 -justify right -anchor "nw" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "steam" 1720 1150 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[steamtemp_text]} 
add_de1_text "steam" 1100 1200 -justify right -anchor "nw" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "steam" 1720 1200 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[pressure_text]} 

add_de1_text "steam" 1100 1250 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "steam" 1720 1250 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[waterflow_text]} 
add_de1_text "steam" 1100 1300 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width [rescale_x_skin 520]
add_de1_variable "steam" 1720 1300 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width [rescale_x_skin 520] -textvariable {[watervolume_text]} 



##########################################################################################################################################################################################################################################################################
