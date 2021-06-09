
##############################################
# scent one aroma system
##############################################

add_de1_page "scentone_1" "scentone_1.jpg" "Insight"
add_de1_page "scentone_tropical" "scentone_tropical.jpg" "Insight"
add_de1_page "scentone_berry" "scentone_berry.jpg" "Insight"
add_de1_page "scentone_citrus" "scentone_citrus.jpg" "Insight"
add_de1_page "scentone_stone" "scentone_stone.jpg" "Insight"
add_de1_page "scentone_cereal" "scentone_cereal.jpg" "Insight"
add_de1_page "scentone_chocolate" "scentone_chocolate.jpg" "Insight"
add_de1_page "scentone_flower" "scentone_flower.jpg" "Insight"
add_de1_page "scentone_spice" "scentone_spice.jpg" "Insight"
add_de1_page "scentone_vegetable" "scentone_vegetable.jpg" "Insight"
add_de1_page "scentone_savory" "scentone_savory.jpg" "Insight"

add_de1_page "describe_espresso" "describe_espresso.jpg" "Insight"
add_de1_page "describe_espresso2" "describe_espresso2.jpg" "Insight"
add_de1_page "describe_espresso0" "describe_espresso0.jpg" "Insight"

# saving an exiting from each of the aroma categories

add_de1_text "describe_espresso describe_espresso0 describe_espresso2" 2275 1520 -text [translate "Ok"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
add_de1_text "describe_espresso describe_espresso0 describe_espresso2" 1760 1520 -text [translate "Cancel"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"

add_de1_button "describe_espresso" {say [translate {Scent One}] $::settings(sound_button_in); set_next_page off scentone_1; page_show off } 2016 1206 2560 1400

add_de1_text "scentone_1" 2275 1520 -text [translate "Save"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
add_de1_text "scentone_tropical scentone_berry scentone_citrus scentone_stone scentone_cereal scentone_chocolate scentone_flower scentone_spice scentone_vegetable scentone_savory" 2275 1520 -text [translate "Ok"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
add_de1_text "scentone_1" 1760 1520 -text [translate "Reset"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
add_de1_button "scentone_tropical scentone_berry scentone_citrus scentone_stone scentone_cereal scentone_chocolate scentone_flower scentone_spice scentone_vegetable scentone_savory" {say [translate {save}] $::settings(sound_button_in); set_next_page off scentone_1; page_show off } 2016 1406 2560 1600

add_de1_button "scentone_1" {say [translate {Scent One}] $::settings(sound_button_in); web_browser "https://decentespresso.com/scentone" } 10 1406 560 1600
add_de1_button "scentone_1" {say [translate {reset}] $::settings(sound_button_in); set ::settings(scentone) "" } 1505 1406 2015 1600
add_de1_button "scentone_1" {say [translate {save}] $::settings(sound_button_in); set_next_page off describe_espresso; page_show off } 2016 1406 2560 1600

add_de1_button "describe_espresso describe_espresso0 describe_espresso2" {say [translate {save}] $::settings(sound_button_in); save_settings; save_espresso_rating_to_history; 
	if {$::settings(has_scale) != $::settings_backup(has_scale) || $::settings(has_refractometer) != $::settings_backup(has_refractometer) } {
		.can itemconfigure $::message_label -text [translate "Please quit and restart this app to apply your changes."]
		set_next_page off message; page_show message
	} else {
		set_next_page off off; page_show off
	}
 } 2016 1406 2560 1600
add_de1_button "describe_espresso describe_espresso0 describe_espresso2" {say [translate {cancel}] $::settings(sound_button_in); array unset ::settings {\*}; array set ::settings [array get ::settings_backup]; fill_god_shots_listbox; set_next_page off off; page_show off} 1505 1406 2015 1600


#add_de1_text "scentone_1" 1245 1520 -text [translate "Reset"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"


##################################################################################################################################################################################################################
# god shot page


add_de1_widget "describe_espresso0" graph 1382 314 {
	$widget element create god_line_espresso_flow_2x  -xdata espresso_elapsed -ydata god_espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 24] -color #e4edff -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 
	if {$::settings(scale_bluetooth_address) != ""} {
		$widget element create god_line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata god_espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 16] -color #edd4c1 -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 
	}
	$widget element create god_line2_espresso_pressure -xdata espresso_elapsed -ydata god_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 24] -color #c5ffe7  -smooth $::settings(profile_graph_smoothing_technique) -pixels 0; 
} -plotbackground #FFFFFF -width [rescale_x_skin 1130] -height [rescale_y_skin 700] -borderwidth 1 -background #FFFFFF -plotrelief flat

add_de1_text "describe_espresso0" 70 346 -text [translate "Your God shots"] -font Helv_9_bold -fill "#7f879a" -justify "left" -anchor "nw" 
add_de1_text "describe_espresso0" 70 1222 -text [translate "Save your current shot"] -font Helv_9_bold -fill "#7f879a" -justify "left" -anchor "nw" 
add_de1_widget "describe_espresso0" entry 70 1282  {
	set ::globals(widget_god_shot_save) $widget
	bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); save_to_god_shots; hide_android_keyboard}
	bind $widget <Leave> hide_android_keyboard
	} -width [expr {int(45 * $::globals(entry_length_multiplier))}] -font Helv_8  -borderwidth 1 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(god_espresso_name)


add_de1_button "describe_espresso0" {say [translate {delete}] $::settings(sound_button_in); delete_current_god_shot} 1180 350 1380 600
add_de1_button "describe_espresso0" {say [translate {add}] $::settings(sound_button_in); save_to_god_shots} 1180 1200 1380 1400

set godshots_listbox_height [expr {int(11 * $::globals(listbox_length_multiplier))}]
#if {$::settings(scale_bluetooth_address) != ""} {
#	set godshots_listbox_height 9
#}

add_de1_widget "describe_espresso0" listbox 80 420 { 
	set ::globals(god_shots_widget) $widget
	fill_god_shots_listbox
	#load_advanced_profile_step 1
	bind $widget <<ListboxSelect>> ::load_god_shot


} -background #fbfaff -yscrollcommand {scale_scroll ::gotshots_slider} -font $listbox_font -bd 0 -height $godshots_listbox_height -width 33 -foreground #d3dbf3 -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single  -selectbackground #c0c4e1

set ::gotshots_slider 0

# draw the scrollbar off screen so that it gets resized and moved to the right place on the first draw
set ::god_shots_scrollbar [add_de1_widget "describe_espresso0" scale 1000 1000 {} -from 0 -to .50 -bigincrement 0.2 -background "#d3dbf3" -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 400] -width [rescale_y_skin 150] -variable ::advsteps -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::globals(god_shots_widget) $::gotshots_slider}  -foreground #FFFFFF -troughcolor "#f7f6fa" -borderwidth 0  -highlightthickness 0]

proc set_god_shot_scrollbar_dimensions {} {
	# set the height of the scrollbar to be the same as the listbox
	$::god_shots_scrollbar configure -length [winfo height $::globals(god_shots_widget)]
	set coords [.can coords $::globals(god_shots_widget) ]
	set newx [expr {[winfo width $::globals(god_shots_widget)] + [lindex $coords 0]}]
	.can coords $::god_shots_scrollbar "$newx [lindex $coords 1]"

	if {$::settings(god_espresso_name) == "" || $::settings(god_espresso_name) == [translate "None"]} {
		set ::settings(god_espresso_name) $::settings(profile_title)
	}
}



##################################################################################################################################################################################################################
# main espresso description page

set slider_trough_color1 #e2e2e2 
set slider_trough_color2 #f3f3f3 



# from http://www.iconarchive.com/show/shiny-smiley-icons-by-iconicon.html
lassign [metadata get espresso_enjoyment n_decimals min max bigincrement] n_dec min max biginc
add_de1_text "describe_espresso" 80 360 -text [translate "Enjoyment"] -font Helv_8_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "left"
	add_de1_widget "describe_espresso" scale 300 450 {} -to $max -from $min -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement $biginc -resolution 1 -length [rescale_x_skin 1000]  -width [rescale_y_skin 150] -variable ::settings(espresso_enjoyment) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color1 -borderwidth 0  -highlightthickness 0 -orient horizontal 
	add_de1_variable "describe_espresso" 1300 600 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {$::settings(espresso_enjoyment)}



#add_de1_text "describe_espresso" 50 700 -text [translate "Details (optional):"] -font Helv_8_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "left"

#	add_de1_text "describe_espresso" 90 780 -text [translate "Sweetness:"] -font Helv_8 -fill "#7f879a" -anchor "nw" -width 800 -justify "left"
#	add_de1_widget "describe_espresso" scale 90 830 {} -to 100 -from 0 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 10 -resolution 1 -length [rescale_x_skin 670]  -width [rescale_y_skin 150] -variable ::settings(espresso_sweetness) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color2 -borderwidth 0  -highlightthickness 0 -orient horizontal 
#	add_de1_variable "describe_espresso" 760 980 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_off_if_zero $::settings(espresso_sweetness)]}

#	add_de1_text "describe_espresso" 90 1010 -text [translate "Acidity:"] -font Helv_8 -fill "#7f879a" -anchor "nw" -width 800 -justify "left"
#	add_de1_widget "describe_espresso" scale 90 1060 {} -to 100 -from 0 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 10 -resolution 1 -length [rescale_x_skin 670]  -width [rescale_y_skin 150] -variable ::settings(espresso_acidity) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color2 -borderwidth 0  -highlightthickness 0 -orient horizontal 
#	add_de1_variable "describe_espresso" 760 1210 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_off_if_zero $::settings(espresso_acidity)]}

#	add_de1_text "describe_espresso" 830 780 -text [translate "Aftertaste:"] -font Helv_8 -fill "#7f879a" -anchor "nw" -width 800 -justify "left"
#	add_de1_widget "describe_espresso" scale 830 830 {} -to 100 -from 0 -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement 10 -resolution 1 -length [rescale_x_skin 670]  -width [rescale_y_skin 150] -variable ::settings(espresso_aftertaste) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color2 -borderwidth 0  -highlightthickness 0 -orient horizontal 
#	add_de1_variable "describe_espresso" 1500 980 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_off_if_zero $::settings(espresso_aftertaste)]}

	add_de1_text "describe_espresso" 80 740 -text [translate "Notes"] -font Helv_8_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "left"
	add_de1_widget "describe_espresso" multiline_entry 80 820 {
			bind $widget <Leave> hide_android_keyboard
	} -width 50 -height 8 -font Helv_8  -borderwidth 2 -bg #fbfaff  -foreground #4e85f4 -textvariable ::settings(espresso_notes) -relief flat -highlightthickness 1 -highlightcolor #000000 


add_de1_text "describe_espresso2" 80 360 -text [translate "Grinder"] -font Helv_8_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "left"

	add_de1_text "describe_espresso2" 540 440 -text [translate "Model"] -font Helv_8 -fill "#7f879a" -anchor "ne" -width 800 -justify "center"
	add_de1_widget "describe_espresso2" entry 550 430 {
			bind $widget <Leave> hide_android_keyboard
	} -width [expr {int(28 * $::globals(entry_length_multiplier))}] -font Helv_8 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(grinder_model) 

	add_de1_text "describe_espresso2" 540 530 -text [translate "Setting"] -font Helv_8 -fill "#7f879a" -anchor "ne" -width 800 -justify "left"
	add_de1_widget "describe_espresso2" entry 550 520 {
		bind $widget <Leave> hide_android_keyboard
	} -width [expr {int(28 * $::globals(entry_length_multiplier))}] -font Helv_8 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(grinder_setting) 

	#set slider_trough_color2 #EAEAEA
	add_de1_text "describe_espresso2" 540 620 -text [translate "Dose weight"] -font Helv_8 -fill "#7f879a" -anchor "ne" -width 800 -justify "center"
	
	lassign [metadata get grinder_dose_weight n_decimals min max bigincrement] n_dec min max biginc
	add_de1_widget "describe_espresso2" scale 550 610 {} -to $max -from $min -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement $biginc -resolution [expr {1.0/(10.0*$n_dec)}] -length [rescale_x_skin 630]  -width [rescale_y_skin 150] -variable ::settings(grinder_dose_weight) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color2 -borderwidth 0  -highlightthickness 0 -orient horizontal 
	add_de1_variable "describe_espresso2" 1160 760 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_stop_at_weight_measurement_precise $::settings(grinder_dose_weight)]}




add_de1_text "describe_espresso2" 80 790 -text [translate "Beans"] -font Helv_8_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "left"

	add_de1_text "describe_espresso2" 540 860 -text [translate "Brand"] -font Helv_8 -fill "#7f879a" -anchor "ne" -width 800 -justify "left"
	add_de1_widget "describe_espresso2" entry 550 850 {
		bind $widget <Leave> hide_android_keyboard		
	} -width [expr {int(28 * $::globals(entry_length_multiplier))}] -font Helv_8 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(bean_brand) 

	add_de1_text "describe_espresso2" 540 940 -text [translate "Type"] -font Helv_8 -fill "#7f879a" -anchor "ne" -width 800 -justify "left"
	add_de1_widget "describe_espresso2" entry 550 930 {
		bind $widget <Leave> hide_android_keyboard
	} -width [expr {int(28 * $::globals(entry_length_multiplier))}] -font Helv_8 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(bean_type) 

	add_de1_text "describe_espresso2" 540 1020 -text [translate "Roast date"] -font Helv_8 -fill "#7f879a" -anchor "ne" -width 800 -justify "left"
	add_de1_widget "describe_espresso2" entry 550 1010 {
		bind $widget <Leave> hide_android_keyboard		
	} -width [expr {int(28 * $::globals(entry_length_multiplier))}] -font Helv_8 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(roast_date) 

	add_de1_text "describe_espresso2" 540 1100 -text [translate "Roast level"] -font Helv_8 -fill "#7f879a" -anchor "ne" -width 800 -justify "left"
	add_de1_widget "describe_espresso2" entry 550 1090 {
		bind $widget <Leave> hide_android_keyboard		
	} -width [expr {int(28 * $::globals(entry_length_multiplier))}] -font Helv_8 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(roast_level) 

	add_de1_text "describe_espresso2" 540 1180 -text [translate "Notes"] -font Helv_8 -fill "#7f879a" -anchor "ne" -width 800 -justify "left"
	add_de1_widget "describe_espresso2" multiline_entry 550 1180 {
		bind $widget <Leave> hide_android_keyboard
	} -width [expr {int(22 * $::globals(entry_length_multiplier))}] -height 3 -font Helv_8  -borderwidth 2 -bg #fbfaff  -foreground #4e85f4 -textvariable ::settings(bean_notes) -relief flat -highlightthickness 1 -highlightcolor #000000 


	add_de1_text "describe_espresso2" 1340 360 -text [translate "Your name"] -font Helv_8_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "left"
	add_de1_widget "describe_espresso2" entry 1340 430 {
		bind $widget <Leave> hide_android_keyboard
	} -width 40 -font Helv_8 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::settings(my_name) 

add_de1_text "describe_espresso2" 1340 560 -text [translate "Enable these features"] -font Helv_8_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "left"
	add_de1_widget "describe_espresso2" checkbutton 1360 630 { } -command {} -padx 0 -pady 0 -bg #FFFFFF -text [translate "I weigh my drinks"] -indicatoron true -font Helv_8  -anchor nw -foreground #4e85f4 -activeforeground #4e85f4 -variable ::settings(has_scale)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF
	add_de1_widget "describe_espresso2" checkbutton 1360 690 { } -command {} -padx 0 -pady 0 -bg #FFFFFF -text [translate "I use a refractometer"] -indicatoron true -font Helv_8  -anchor nw -foreground #4e85f4 -activeforeground #4e85f4 -variable ::settings(has_refractometer)  -borderwidth 0 -selectcolor #FFFFFF -highlightthickness 0 -activebackground #FFFFFF



	#add_de1_text "describe_espresso2" 1340 850 -text [translate "God shot"] -font Helv_8_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "left"
	#	add_de1_text "describe_espresso2" 1650 1016 -text [translate "Save"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
	#	add_de1_text "describe_espresso2" 2250 1016 -text [translate "Erase"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
	#	add_de1_button "describe_espresso2" {say [translate {Saved}] $::settings(sound_button_in); god_shot_save; set_next_page off off; page_show off} 1300 900 1900 1116
	#	add_de1_button "describe_espresso2" {say [translate {Cancel}] $::settings(sound_button_in); god_shot_clear; set_next_page off off; page_show off} 1910 900 2550 1116




if {$::settings(has_refractometer) == 1 || $::settings(has_scale) == 1} {
	add_de1_text "describe_espresso" 1630 360 -text [translate "Technical: (optional)"] -font Helv_8_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "left"
}

	add_de1_text "describe_espresso" 1630 440 -text [translate "Weight"] -font Helv_8 -fill "#7f879a" -anchor "nw" -width 800 -justify "left"
	
	lassign [metadata get drink_weight n_decimals min max bigincrement] n_dec min max biginc
	add_de1_widget "describe_espresso" scale 1630 500 {} -to $max -from $min -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement $biginc -resolution [expr {1.0/(10.0*$n_dec)}] -length [rescale_x_skin 850]  -width [rescale_y_skin 140] -variable ::settings(drink_weight) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color2 -borderwidth 0  -highlightthickness 0 -orient horizontal 
	
	add_de1_variable "describe_espresso" 2480 640 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_shot_weight_measurement $::settings(drink_weight)]}
	#add_de1_variable "describe_espresso" 2480 640 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {$::settings(drink_weight)}

	if {$::settings(has_refractometer) == 1} {
		add_de1_text "describe_espresso" 1630 670 -text [translate "Total dissolved solids (TDS)"] -font Helv_8 -fill "#7f879a" -anchor "nw" -width 800 -justify "left"
		
		lassign [metadata get drink_tds n_decimals min max bigincrement] n_dec min max biginc
		add_de1_widget "describe_espresso" scale 1630 730 {} -to $max -from $min -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement $biginc -resolution [expr {1.0/(10.0*$n_dec)}] -length [rescale_x_skin 850]  -width [rescale_y_skin 140] -variable ::settings(drink_tds) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color2 -borderwidth 0  -highlightthickness 0 -orient horizontal 
		add_de1_variable "describe_espresso" 2480 870 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_percent_off_if_zero $::settings(drink_tds)]}

		add_de1_text "describe_espresso" 1630 900 -text [translate "Extraction yield (EY)"] -font Helv_8 -fill "#7f879a" -anchor "nw" -width 800 -justify "left"
		
		lassign [metadata get drink_ey n_decimals min max bigincrement] n_dec min max biginc
		add_de1_widget "describe_espresso" scale 1630 960 {} -to $max -from $min -background #e4d1c1 -showvalue 0 -borderwidth 1 -bigincrement $biginc -resolution [expr {1.0/(10.0*$n_dec)}] -length [rescale_x_skin 850]  -width [rescale_y_skin 140] -variable ::settings(drink_ey) -font Helv_15_bold -sliderlength [rescale_x_skin 125] -relief flat -command {} -foreground #FFFFFF -troughcolor $slider_trough_color2 -borderwidth 0  -highlightthickness 0 -orient horizontal 
		add_de1_variable "describe_espresso" 2480 1100 -text "" -font Helv_8 -fill "#4e85f4" -anchor "ne" -width 600 -justify "left" -textvariable {[return_percent_off_if_zero $::settings(drink_ey)]}
	}


add_de1_text "describe_espresso" 1610 1230 -text [translate "Flavors"] -font Helv_8_bold -fill "#7f879a" -anchor "nw" -width 800 -justify "left"
add_de1_variable "describe_espresso" 1610 1280 -text "" -font Helv_6 -width 200 -fill "#7f879a" -anchor "nw" -textvariable {[scentone_translated_selection]} 


##################################################################################################################################################################################################################


##################################################################################################################################################################################################################
# describe your espresso

add_de1_text "describe_espresso" 1330 230 -text [translate "This espresso"] -font Helv_10_bold -width 1200 -fill "#7f879a" -anchor "center" -justify "center" 
add_de1_text "describe_espresso describe_espresso0" 2160 230 -text [translate "Your setup"] -font Helv_10_bold -width 1200 -fill "#BBBBBB" -anchor "center" -justify "center" 

add_de1_text "describe_espresso2 describe_espresso0" 1330 230 -text [translate "This espresso"] -font Helv_10_bold -width 1200 -fill "#BBBBBB" -anchor "center" -justify "center" 
add_de1_text "describe_espresso2" 2160 230 -text [translate "Your setup"] -font Helv_10_bold -width 1200 -fill "#7f879a" -anchor "center" -justify "center" 
add_de1_text "describe_espresso0" 460 230 -text [translate "God shot"] -font Helv_10_bold -width 1200 -fill "#7f879a" -anchor "center" -justify "center" 
add_de1_text "describe_espresso2 describe_espresso" 460 230 -text [translate "God shot"] -font Helv_10_bold -width 1200 -fill "#BBBBBB" -anchor "center" -justify "center" 

#add_de1_text "describe_espresso" 1280 90 -text [translate "Describe this espresso"] -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" 
#add_de1_text "describe_espresso2" 1280 90 -text [translate "Describe your setup"] -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" 
#add_de1_text "describe_espresso0" 1280 90 -text [translate "Your God shots"] -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" 

add_de1_button "describe_espresso0 describe_espresso2" {say [translate {this espresso}] $::settings(sound_button_in); set_next_page off describe_espresso; page_show off} 860 0 1680 300
add_de1_button "describe_espresso0 describe_espresso" {say [translate {your setup}] $::settings(sound_button_in); set_next_page off describe_espresso2; page_show off} 1710 0 2560 300
add_de1_button "describe_espresso describe_espresso2" {say [translate {God shot}] $::settings(sound_button_in); set_next_page off describe_espresso0; page_show off} 0 0 850 300


##################################################################################################################################################################################################################
# main scentone categories



add_de1_variable "scentone_1" 1280 140 -text "" -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" -textvariable {[scentone_selected]} 

set ::scentone(Tropical\ fruit) {"Guava" "Mangosteen" "Mango" "Banana" "Coconut" "Passion fruit" "Watermelon" "Papaya" "Tropical fruits" "Pineapple" "Melon" "Lychee"}
set ::scentone(Berry) {"Strawberry" "Blueberry" "Raspberry" "Cranberry" "Blackberry" "Acai berry" "Black currant" "White grape" "Muscat grape" "Red grape"}
set ::scentone(Citrus) {"Pomegranate" "Aloe" "Lemon" "Orange" "Lime" "Yuzu" "Grapefruit" "Chinese pear" "Apple" "Quince"}
set ::scentone(Stone\ fruit) {"Acerola" "Light cherry" "Dark cherry" "Peach" "Plum" "Apricot"}
set ::scentone(Nut\ &\ cereal) {"Hazelnut" "Walnut" "Pine nut" "Almond" "Peanut" "Pistachio" "Sesame" "Red bean" "Malt" "Toasted rice" "Roasted"}
set ::scentone(Chocolate\ &\ caramel) {"Caramel" "Brown sugar" "Honey" "Maple syrup" "Milk chocolate" "Dark chocolate" "Mocha" "Cream" "Butter" "Yogurt" "Vanilla"}
set ::scentone(Flower\ &\ herb) {"Pine" "Hawthorn" "Earl grey" "Rose" "Jasmin" "Acacia" "Elderflower" "Lavender" "Bergamot" "Chrysanthemum" "Hibiscus" "Eucalyptus"}
set ::scentone(Spice) {"Basil" "Thyme" "Cinnamon" "Nutmeg" "Clove" "Cardamon" "Star anise" "Cumin" "Black pepper" "Garlic" "Ginger"}
set ::scentone(Vegetable) {"Date" "Pumpkin" "Tomato" "Cucumber" "Mushroom" "Taro" "Arrowroot" "Ginseng" "Paprika"}
set ::scentone(Savory) {"Cheddar" "Soy sauce" "Mustard" "Mayonnaise" "Musk" "Amber" "Smoke" "Beef"}

# row 1 text labels 
add_de1_variable "scentone_1" 300 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Tropical fruit"]} 
add_de1_variable "scentone_1" 830 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Berry" ]} 
add_de1_variable "scentone_1" 1370 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Citrus" ]} 
add_de1_variable "scentone_1" 1850 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Stone fruit" ]} 
add_de1_variable "scentone_1" 2280 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Nut & cereal" ]} 

# row 2 text labels 
add_de1_variable "scentone_1" 300 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Chocolate & caramel" ]} 
add_de1_variable "scentone_1" 830 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Flower & herb" ]} 
add_de1_variable "scentone_1" 1370 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Spice" ]} 
add_de1_variable "scentone_1" 1931 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Vegetable" ]} 
add_de1_variable "scentone_1" 2330 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_category "Savory" ]} 

# row 1 tap areas
add_de1_button "scentone_1" {say [translate {Tropical fruit}] $::settings(sound_button_in); set_next_page off scentone_tropical; page_show off } 15 290 520 860
add_de1_button "scentone_1" {say [translate {Berry}] $::settings(sound_button_in); set_next_page off scentone_berry; page_show off } 522 290 1100 860
add_de1_button "scentone_1" {say [translate {Citrus}] $::settings(sound_button_in); set_next_page off scentone_citrus; page_show off } 1102 290 1660 860
add_de1_button "scentone_1" {say [translate {Stone fruit}] $::settings(sound_button_in); set_next_page off scentone_stone; page_show off } 1662 290 2050 860
add_de1_button "scentone_1" {say [translate {Nut & cereal}] $::settings(sound_button_in); set_next_page off scentone_cereal; page_show off } 2052 290 2550 860

# row 2 tap areas
add_de1_button "scentone_1" {say [translate {Chocolate & caramel}] $::settings(sound_button_in); set_next_page off scentone_chocolate; page_show off } 15 862 560 1400
add_de1_button "scentone_1" {say [translate {Flower & herb}] $::settings(sound_button_in); set_next_page off scentone_flower; page_show off } 562 862 1070 1400
add_de1_button "scentone_1" {say [translate {Spice}] $::settings(sound_button_in); set_next_page off scentone_spice; page_show off } 1072 862 1690 1400
add_de1_button "scentone_1" {say [translate {Vegetable}] $::settings(sound_button_in); set_next_page off scentone_vegetable; page_show off } 1692 862 2140 1400
add_de1_button "scentone_1" {say [translate {Savory}] $::settings(sound_button_in); set_next_page off scentone_savory; page_show off } 2142 862 2550 1400
##################################################################################################################################################################################################################

##################################################################################################################################################################################################################
# tropical fruits


add_de1_variable "scentone_tropical" 1280 140 -text "" -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" -textvariable {[scentone_selected "Tropical fruit"]} 
#add_de1_variable "scentone_1" 1280 150 -text "" -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" -textvariable {[scentone_selected]} 

# row 1 text labels 
add_de1_variable "scentone_tropical" 220 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Guava"]} 
add_de1_variable "scentone_tropical" 680 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Mangosteen"]} 
add_de1_variable "scentone_tropical" 1080 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Mango"]} 
add_de1_variable "scentone_tropical" 1450 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Banana"]} 
add_de1_variable "scentone_tropical" 1900 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Coconut"]} 
add_de1_variable "scentone_tropical" 2300 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Passion fruit"]} 

# row 2 text labels 
add_de1_variable "scentone_tropical" 260 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Watermelon"]} 
add_de1_variable "scentone_tropical" 660 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Papaya"]} 
add_de1_variable "scentone_tropical" 1090 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Tropical fruits"]} 
add_de1_variable "scentone_tropical" 1480 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Pineapple"]} 
add_de1_variable "scentone_tropical" 1900 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Melon"]} 
add_de1_variable "scentone_tropical" 2300 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Lychee"]} 

# row 1 tap areas
add_de1_button "scentone_tropical" {say [translate {Guava}] $::settings(sound_button_in); scentone_toggle "Guava"} 15 290 470 860
add_de1_button "scentone_tropical" {say [translate {Mangosteen}] $::settings(sound_button_in); scentone_toggle "Mangosteen" } 472 290 870 860
add_de1_button "scentone_tropical" {say [translate {Mango}] $::settings(sound_button_in); scentone_toggle "Mango" } 872 290 1270 860
add_de1_button "scentone_tropical" {say [translate {Banana}] $::settings(sound_button_in); scentone_toggle "Banana" } 1272 290 1700 860
add_de1_button "scentone_tropical" {say [translate {Coconut}] $::settings(sound_button_in); scentone_toggle "Coconut" } 1702 290 2100 860
add_de1_button "scentone_tropical" {say [translate {Passion fruit}] $::settings(sound_button_in); scentone_toggle "Passion fruit" } 2102 290 2550 860

# row 2 tap areas
add_de1_button "scentone_tropical" {say [translate {Watermelon}] $::settings(sound_button_in); scentone_toggle "Watermelon" } 15 862 450 1400
add_de1_button "scentone_tropical" {say [translate {Papaya}] $::settings(sound_button_in); scentone_toggle "Papaya" } 452 862 876 1400
add_de1_button "scentone_tropical" {say [translate {Tropical fruits}] $::settings(sound_button_in); scentone_toggle "Tropical fruits" } 878 862 1300 1400
add_de1_button "scentone_tropical" {say [translate {Pineapple}] $::settings(sound_button_in); scentone_toggle "Pineapple" } 1302 862 1750 1400
add_de1_button "scentone_tropical" {say [translate {Melon}] $::settings(sound_button_in); scentone_toggle "Melon" } 1752 862 2130 1400
add_de1_button "scentone_tropical" {say [translate {Lychee}] $::settings(sound_button_in); scentone_toggle "Lychee" } 2132 862 2550 1400
##################################################################################################################################################################################################################

##################################################################################################################################################################################################################
# berry fruits

add_de1_variable "scentone_berry" 1280 140 -text "" -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" -textvariable {[scentone_selected "Berry"]} 

# row 1 text labels 
add_de1_variable "scentone_berry" 285 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Strawberry"]} 
add_de1_variable "scentone_berry" 800 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Blueberry"]} 
add_de1_variable "scentone_berry" 1310 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Raspberry"]} 
add_de1_variable "scentone_berry" 1740 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Cranberry"]} 
add_de1_variable "scentone_berry" 2300 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Blackberry"]} 

# row 2 text labels 
add_de1_variable "scentone_berry" 304 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Acai berry"]} 
add_de1_variable "scentone_berry" 820 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Black currant"]} 
add_de1_variable "scentone_berry" 1300 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "White grape"]} 
add_de1_variable "scentone_berry" 1760 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Muscat grape"]} 
add_de1_variable "scentone_berry" 2270 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Red grape"]} 

# row 1 tap areas
add_de1_button "scentone_berry" {say [translate {Strawberry}] $::settings(sound_button_in); scentone_toggle "Strawberry"} 15 290 508 860
add_de1_button "scentone_berry" {say [translate {Blueberry}] $::settings(sound_button_in); scentone_toggle "Blueberry" } 510 290 1060 860
add_de1_button "scentone_berry" {say [translate {Raspberry}] $::settings(sound_button_in); scentone_toggle "Raspberry" } 1062 290 1560 860
add_de1_button "scentone_berry" {say [translate {Cranberry}] $::settings(sound_button_in); scentone_toggle "Cranberry" } 1562 290 2060 860
add_de1_button "scentone_berry" {say [translate {Blackberry}] $::settings(sound_button_in); scentone_toggle "Blackberry" } 2062 290 2558 860

# row 2 tap areas
add_de1_button "scentone_berry" {say [translate {Acai berry}] $::settings(sound_button_in); scentone_toggle "Acai berry" } 15 862 570 1400
add_de1_button "scentone_berry" {say [translate {Black currant}] $::settings(sound_button_in); scentone_toggle "Black currant" } 572 862 1050 1400
add_de1_button "scentone_berry" {say [translate {White grape}] $::settings(sound_button_in); scentone_toggle "White grape" } 1052 862 1550 1400
add_de1_button "scentone_berry" {say [translate {Muscat grape}] $::settings(sound_button_in); scentone_toggle "Muscat grape" } 1552 862 2000 1400
add_de1_button "scentone_berry" {say [translate {Red grape}] $::settings(sound_button_in); scentone_toggle "Red grape" } 2002 862 2550 1400
##################################################################################################################################################################################################################


##################################################################################################################################################################################################################
# citrus fruits

add_de1_variable "scentone_citrus" 1280 140 -text "" -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" -textvariable {[scentone_selected "Citrus"]} 

# row 1 text labels 
add_de1_variable "scentone_citrus" 300 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Pomegranate"]} 
add_de1_variable "scentone_citrus" 700 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Aloe"]} 
add_de1_variable "scentone_citrus" 1160 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Lemon"]} 
add_de1_variable "scentone_citrus" 1752 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Orange"]} 
add_de1_variable "scentone_citrus" 2268 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Lime"]} 

# row 2 text labels 
add_de1_variable "scentone_citrus" 422 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Yuzu"]} 
add_de1_variable "scentone_citrus" 960 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Grapefruit"]} 
add_de1_variable "scentone_citrus" 1422 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Chinese pear"]} 
add_de1_variable "scentone_citrus" 1800 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Apple"]} 
add_de1_variable "scentone_citrus" 2160 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Quince"]} 

# row 1 tap areas
add_de1_button "scentone_citrus" {say [translate {Pomegranate}] $::settings(sound_button_in); scentone_toggle "Pomegranate"} 15 290 500 860
add_de1_button "scentone_citrus" {say [translate {Aloe}] $::settings(sound_button_in); scentone_toggle "Aloe" } 502 290 880 860
add_de1_button "scentone_citrus" {say [translate {Lemon}] $::settings(sound_button_in); scentone_toggle "Lemon" } 882 290 1460 860
add_de1_button "scentone_citrus" {say [translate {Orange}] $::settings(sound_button_in); scentone_toggle "Orange" } 1462 290 2006 860
add_de1_button "scentone_citrus" {say [translate {Lime}] $::settings(sound_button_in); scentone_toggle "Lime" } 2006 290 2558 860

# row 2 tap areas
add_de1_button "scentone_citrus" {say [translate {Yuzu}] $::settings(sound_button_in); scentone_toggle "Yuzu" } 15 862 670 1400
add_de1_button "scentone_citrus" {say [translate {Grapefruit}] $::settings(sound_button_in); scentone_toggle "Grapefruit" } 672 862 1230 1400
add_de1_button "scentone_citrus" {say [translate {Chinese pear}] $::settings(sound_button_in); scentone_toggle "Chinese pear" } 1232 862 1620 1400
add_de1_button "scentone_citrus" {say [translate {Apple}] $::settings(sound_button_in); scentone_toggle "Apple" } 1622 862 2000 1400
add_de1_button "scentone_citrus" {say [translate {Quince}] $::settings(sound_button_in); scentone_toggle "Quince" } 2002 862 2550 1400
##################################################################################################################################################################################################################


##################################################################################################################################################################################################################
# stone fruits

add_de1_variable "scentone_stone" 1280 140 -text "" -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" -textvariable {[scentone_selected "Stone fruit"]} 

# row 1 text labels 
add_de1_variable "scentone_stone" 500 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Acerola"]} 
add_de1_variable "scentone_stone" 1350 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Light cherry"]} 
add_de1_variable "scentone_stone" 2120 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Dark cherry"]} 

# row 2 text labels 
add_de1_variable "scentone_stone" 470 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Peach"]} 
add_de1_variable "scentone_stone" 1330 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Plum"]} 
add_de1_variable "scentone_stone" 2130 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Apricot"]} 

# row 1 tap areas
add_de1_button "scentone_stone" {say [translate {Acerola}] $::settings(sound_button_in); scentone_toggle "Acerola"} 15 290 900 860
add_de1_button "scentone_stone" {say [translate {Light cherry}] $::settings(sound_button_in); scentone_toggle "Light cherry" } 902 290 1770 860
add_de1_button "scentone_stone" {say [translate {Dark cherry}] $::settings(sound_button_in); scentone_toggle "Dark cherry" } 1772 290 2550 860

# row 2 tap areas
add_de1_button "scentone_stone" {say [translate {Peach}] $::settings(sound_button_in); scentone_toggle "Peach" } 15 862 920 1400
add_de1_button "scentone_stone" {say [translate {Plum}] $::settings(sound_button_in); scentone_toggle "Plum" } 922 862 1700 1400
add_de1_button "scentone_stone" {say [translate {Apricot}] $::settings(sound_button_in); scentone_toggle "Apricot" } 1702 862 2550 1400
##################################################################################################################################################################################################################


##################################################################################################################################################################################################################
# cereal and nuts

add_de1_variable "scentone_cereal" 1280 140 -text "" -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" -textvariable {[scentone_selected "Nut & cereal"]} 

# row 1 text labels 
add_de1_variable "scentone_cereal" 275 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Hazelnut"]} 
add_de1_variable "scentone_cereal" 685 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Walnut"]} 
add_de1_variable "scentone_cereal" 1060 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Pine nut"]} 
add_de1_variable "scentone_cereal" 1450 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Almond"]} 
add_de1_variable "scentone_cereal" 1850 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Peanut"]} 
add_de1_variable "scentone_cereal" 2285 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Pistachio"]} 

# row 2 text labels 
add_de1_variable "scentone_cereal" 350 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Sesame"]} 
add_de1_variable "scentone_cereal" 850 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Red bean"]} 
add_de1_variable "scentone_cereal" 1310 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Malt"]} 
add_de1_variable "scentone_cereal" 1790 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Toasted rice"]} 
add_de1_variable "scentone_cereal" 2265 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Roasted"]} 

# row 1 tap areas
add_de1_button "scentone_cereal" {say [translate {Hazelnut}] $::settings(sound_button_in); scentone_toggle "Hazelnut"} 15 290 484 860
add_de1_button "scentone_cereal" {say [translate {Walnut}] $::settings(sound_button_in); scentone_toggle "Walnut" } 486 290 860 860
add_de1_button "scentone_cereal" {say [translate {Pine nut}] $::settings(sound_button_in); scentone_toggle "Pine nut" } 862 290 1260 860
add_de1_button "scentone_cereal" {say [translate {Almond}] $::settings(sound_button_in); scentone_toggle "Almond" } 1262 290 1650 860
add_de1_button "scentone_cereal" {say [translate {Peanut}] $::settings(sound_button_in); scentone_toggle "Peanut" } 1652 290 2050 860
add_de1_button "scentone_cereal" {say [translate {Pistachio}] $::settings(sound_button_in); scentone_toggle "Pistachio" } 2052 290 2550 860

# row 2 tap areas
add_de1_button "scentone_cereal" {say [translate {Sesame}] $::settings(sound_button_in); scentone_toggle "Sesame" } 15 862 634 1400
add_de1_button "scentone_cereal" {say [translate {Red bean}] $::settings(sound_button_in); scentone_toggle "Red bean" } 636 862 1060 1400
add_de1_button "scentone_cereal" {say [translate {Malt}] $::settings(sound_button_in); scentone_toggle "Malt" } 1062 862 1525 1400
add_de1_button "scentone_cereal" {say [translate {Toasted rice}] $::settings(sound_button_in); scentone_toggle "Toasted rice" } 1527 862 2000 1400
add_de1_button "scentone_cereal" {say [translate {Roasted}] $::settings(sound_button_in); scentone_toggle "Roasted" } 2002 862 2550 1400
##################################################################################################################################################################################################################


##################################################################################################################################################################################################################
# chocolate and caramel

add_de1_variable "scentone_chocolate" 1280 140 -text "" -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" -textvariable {[scentone_selected "Chocolate\ &\ caramel"]} 

# row 1 text labels 
add_de1_variable "scentone_chocolate" 218 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Dark chocolate"]} 
add_de1_variable "scentone_chocolate" 680 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Caramel"]} 
add_de1_variable "scentone_chocolate" 1120 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Honey"]} 
add_de1_variable "scentone_chocolate" 1550 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Brown sugar"]} 
add_de1_variable "scentone_chocolate" 1950 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Maple syrup"]} 
add_de1_variable "scentone_chocolate" 2320 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Milk chocolate"]} 

# row 2 text labels 
add_de1_variable "scentone_chocolate" 290 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Mocha"]} 
add_de1_variable "scentone_chocolate" 840 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Cream"]} 
add_de1_variable "scentone_chocolate" 1360 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Butter"]} 
add_de1_variable "scentone_chocolate" 1840 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Yogurt"]} 
add_de1_variable "scentone_chocolate" 2280 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Vanilla"]} 

# row 1 tap areas
add_de1_button "scentone_chocolate" {say [translate {Dark chocolate}] $::settings(sound_button_in); scentone_toggle "Dark chocolate" } 10 290 400 860
add_de1_button "scentone_chocolate" {say [translate {Caramel}] $::settings(sound_button_in); scentone_toggle "Caramel"} 402 290 984 860
add_de1_button "scentone_chocolate" {say [translate {Honey}] $::settings(sound_button_in); scentone_toggle "Honey" } 986 290 1280 860
add_de1_button "scentone_chocolate" {say [translate {Brown sugar}] $::settings(sound_button_in); scentone_toggle "Brown sugar" } 1282 290 1816 860
add_de1_button "scentone_chocolate" {say [translate {Maple syrup}] $::settings(sound_button_in); scentone_toggle "Maple syrup" } 1818 290 2100 860
add_de1_button "scentone_chocolate" {say [translate {Milk chocolate}] $::settings(sound_button_in); scentone_toggle "Milk chocolate" } 2102 290 2550 860

# row 2 tap areas
add_de1_button "scentone_chocolate" {say [translate {Mocha}] $::settings(sound_button_in); scentone_toggle "Mocha" } 15 862 590 1400
add_de1_button "scentone_chocolate" {say [translate {Cream}] $::settings(sound_button_in); scentone_toggle "Cream" } 592 862 1150 1400
add_de1_button "scentone_chocolate" {say [translate {Butter}] $::settings(sound_button_in); scentone_toggle "Butter" } 1152 862 1600 1400
add_de1_button "scentone_chocolate" {say [translate {Yogurt}] $::settings(sound_button_in); scentone_toggle "Yogurt" } 1602 862 2090 1400
add_de1_button "scentone_chocolate" {say [translate {Vanilla}] $::settings(sound_button_in); scentone_toggle "Vanilla" } 2092 862 2550 1400
##################################################################################################################################################################################################################


##################################################################################################################################################################################################################
# flower

add_de1_variable "scentone_flower" 1280 140 -text "" -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" -textvariable {[scentone_selected "Flower & herb"]} 

# row 1 text labels 
add_de1_variable "scentone_flower" 200 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Pine"]} 
add_de1_variable "scentone_flower" 550 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Hawthorn"]} 
add_de1_variable "scentone_flower" 920 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Earl grey"]} 
add_de1_variable "scentone_flower" 1330 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Rose"]} 
add_de1_variable "scentone_flower" 1750 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Jasmin"]} 
add_de1_variable "scentone_flower" 2240 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Acacia"]} 

# row 2 text labels 
add_de1_variable "scentone_flower" 275 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Elderflower"]} 
add_de1_variable "scentone_flower" 720 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Lavender"]} 
add_de1_variable "scentone_flower" 1030 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Bergamot"]} 
add_de1_variable "scentone_flower" 1380 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Chrysanthemum"]} 
add_de1_variable "scentone_flower" 1800 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Hibiscus"]} 
add_de1_variable "scentone_flower" 2320 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Eucalyptus"]} 

# row 1 tap areas
add_de1_button "scentone_flower" {say [translate {Pine}] $::settings(sound_button_in); scentone_toggle "Pine"} 15 290 400 860
add_de1_button "scentone_flower" {say [translate {Hawthorn}] $::settings(sound_button_in); scentone_toggle "Hawthorn" } 402 290 710 860
add_de1_button "scentone_flower" {say [translate {Earl grey}] $::settings(sound_button_in); scentone_toggle "Earl grey" } 712 290 1130 860
add_de1_button "scentone_flower" {say [translate {Rose}] $::settings(sound_button_in); scentone_toggle "Rose" } 1132 290 1520 860
add_de1_button "scentone_flower" {say [translate {Jasmin}] $::settings(sound_button_in); scentone_toggle "Jasmin" } 1522 290 2000 860
add_de1_button "scentone_flower" {say [translate {Acacia}] $::settings(sound_button_in); scentone_toggle "Acacia" } 2002 290 2550 860

# row 2 tap areas
add_de1_button "scentone_flower" {say [translate {Elderflower}] $::settings(sound_button_in); scentone_toggle "Elderflower" } 15 862 540 1400
add_de1_button "scentone_flower" {say [translate {Lavender}] $::settings(sound_button_in); scentone_toggle "Lavender" } 542 862 860 1400
add_de1_button "scentone_flower" {say [translate {Bergamot}] $::settings(sound_button_in); scentone_toggle "Bergamot" } 862 862 1200 1400
add_de1_button "scentone_flower" {say [translate {Chrysanthemum}] $::settings(sound_button_in); scentone_toggle "Chrysanthemum" } 1202 862 1575 1400
add_de1_button "scentone_flower" {say [translate {Hibiscus}] $::settings(sound_button_in); scentone_toggle "Hibiscus" } 1577 862 2040 1400
add_de1_button "scentone_flower" {say [translate {Eucalyptus}] $::settings(sound_button_in); scentone_toggle "Eucalyptus" } 2042 862 2550 1400
##################################################################################################################################################################################################################



##################################################################################################################################################################################################################
# spice

add_de1_variable "scentone_spice" 1280 140 -text "" -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" -textvariable {[scentone_selected "Spice"]} 

# row 1 text labels 
add_de1_variable "scentone_spice" 240 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Basil"]} 
add_de1_variable "scentone_spice" 550 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Thyme"]} 
add_de1_variable "scentone_spice" 880 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Cinnamon"]} 
add_de1_variable "scentone_spice" 1280 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Nutmeg"]} 
add_de1_variable "scentone_spice" 1740 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Clove"]} 
add_de1_variable "scentone_spice" 2260 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Cardamon"]} 

# row 2 text labels 
add_de1_variable "scentone_spice" 200 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Star anise"]} 
add_de1_variable "scentone_spice" 640 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Cumin"]} 
add_de1_variable "scentone_spice" 1140 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Black pepper"]} 
add_de1_variable "scentone_spice" 1690 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Garlic"]} 
add_de1_variable "scentone_spice" 2220 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Ginger"]} 

# row 1 tap areas
add_de1_button "scentone_spice" {say [translate {Basil}] $::settings(sound_button_in); scentone_toggle "Basil" } 10 290 460 860
add_de1_button "scentone_spice" {say [translate {Thyme}] $::settings(sound_button_in); scentone_toggle "Thyme"} 462 290 750 860
add_de1_button "scentone_spice" {say [translate {Cinnamon}] $::settings(sound_button_in); scentone_toggle "Cinnamon" } 752 290 1080 860
add_de1_button "scentone_spice" {say [translate {Nutmeg}] $::settings(sound_button_in); scentone_toggle "Nutmeg" } 1082 290 1500 860
add_de1_button "scentone_spice" {say [translate {Clove}] $::settings(sound_button_in); scentone_toggle "Clove" } 1502 290 1980 860
add_de1_button "scentone_spice" {say [translate {Cardamon}] $::settings(sound_button_in); scentone_toggle "Cardamon" } 1982 290 2550 860

# row 2 tap areas
add_de1_button "scentone_spice" {say [translate {Star anise}] $::settings(sound_button_in); scentone_toggle "Star anise" } 15 862 414 1400
add_de1_button "scentone_spice" {say [translate {Cumin}] $::settings(sound_button_in); scentone_toggle "Cumin" } 416 862 890 1400
add_de1_button "scentone_spice" {say [translate {Black pepper}] $::settings(sound_button_in); scentone_toggle "Black pepper" } 892 862 1390 1400
add_de1_button "scentone_spice" {say [translate {Garlic}] $::settings(sound_button_in); scentone_toggle "Garlic" } 1392 862 1920 1400
add_de1_button "scentone_spice" {say [translate {Ginger}] $::settings(sound_button_in); scentone_toggle "Ginger" } 1922 862 2550 1400
##################################################################################################################################################################################################################


##################################################################################################################################################################################################################
# vegetable

add_de1_variable "scentone_vegetable" 1280 140 -text "" -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" -textvariable {[scentone_selected "Vegetable"]} 

# row 1 text labels 
add_de1_variable "scentone_vegetable" 300 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Date"]} 
add_de1_variable "scentone_vegetable" 890 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Pumpkin"]} 
add_de1_variable "scentone_vegetable" 1520 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Tomato"]} 
add_de1_variable "scentone_vegetable" 2220 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Cucumber"]} 

# row 2 text labels 
add_de1_variable "scentone_vegetable" 220 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Mushroom"]} 
add_de1_variable "scentone_vegetable" 700 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Taro"]} 
add_de1_variable "scentone_vegetable" 1300 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Arrowroot"]} 
add_de1_variable "scentone_vegetable" 1820 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Ginseng"]} 
add_de1_variable "scentone_vegetable" 2280 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Paprika"]} 

# row 1 tap areas
add_de1_button "scentone_vegetable" {say [translate {Date}] $::settings(sound_button_in); scentone_toggle "Date"} 15 290 570 860
add_de1_button "scentone_vegetable" {say [translate {Pumpkin}] $::settings(sound_button_in); scentone_toggle "Pumpkin" } 572 290 1160 860
add_de1_button "scentone_vegetable" {say [translate {Tomato}] $::settings(sound_button_in); scentone_toggle "Tomato" } 1162 290 1860 860
add_de1_button "scentone_vegetable" {say [translate {Cucumber}] $::settings(sound_button_in); scentone_toggle "Cucumber" } 1862 290 2558 860

# row 2 tap areas
add_de1_button "scentone_vegetable" {say [translate {Mushroom}] $::settings(sound_button_in); scentone_toggle "Mushroom" } 15 862 400 1400
add_de1_button "scentone_vegetable" {say [translate {Taro}] $::settings(sound_button_in); scentone_toggle "Taro" } 402 862 1020 1400
add_de1_button "scentone_vegetable" {say [translate {Arrowroot}] $::settings(sound_button_in); scentone_toggle "Arrowroot" } 1022 862 1590 1400
add_de1_button "scentone_vegetable" {say [translate {Ginseng}] $::settings(sound_button_in); scentone_toggle "Ginseng" } 1592 862 2055 1400
add_de1_button "scentone_vegetable" {say [translate {Paprika}] $::settings(sound_button_in); scentone_toggle "Paprika" } 2057 862 2550 1400
##################################################################################################################################################################################################################



##################################################################################################################################################################################################################
# vegetable

add_de1_variable "scentone_savory" 1280 140 -text "" -font Helv_15_bold -width 1200 -fill "#595d78" -anchor "center" -justify "center" -textvariable {[scentone_selected "Savory"]} 

# row 1 text labels 
add_de1_variable "scentone_savory" 350 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Cheddar"]} 
add_de1_variable "scentone_savory" 950 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Soy sauce"]} 
add_de1_variable "scentone_savory" 1590 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Mustard"]} 
add_de1_variable "scentone_savory" 2190 800 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Mayonnaise"]} 

# row 2 text labels 
add_de1_variable "scentone_savory" 330 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Musk"]} 
add_de1_variable "scentone_savory" 950 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Amber"]} 
add_de1_variable "scentone_savory" 1580 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Smoke"]} 
add_de1_variable "scentone_savory" 2180 1380 -text "" -font Helv_8_bold -fill "#BBBBBB" -anchor "center" -textvariable {[scentone_choice "Beef"]} 

# row 1 tap areas
add_de1_button "scentone_savory" {say [translate {Cheddar}] $::settings(sound_button_in); scentone_toggle "Cheddar"} 15 290 660 860
add_de1_button "scentone_savory" {say [translate {Soy sauce}] $::settings(sound_button_in); scentone_toggle "Soy sauce" } 662 290 1260 860
add_de1_button "scentone_savory" {say [translate {Mustard}] $::settings(sound_button_in); scentone_toggle "Mustard" } 1262 290 1840 860
add_de1_button "scentone_savory" {say [translate {Mayonnaise}] $::settings(sound_button_in); scentone_toggle "Mayonnaise" } 1842 290 2558 860

# row 2 tap areas
add_de1_button "scentone_savory" {say [translate {Musk}] $::settings(sound_button_in); scentone_toggle "Musk" } 15 862 600 1400
add_de1_button "scentone_savory" {say [translate {Amber}] $::settings(sound_button_in); scentone_toggle "Amber" } 602 862 1180 1400
add_de1_button "scentone_savory" {say [translate {Smoke}] $::settings(sound_button_in); scentone_toggle "Smoke" } 1182 862 1880 1400
add_de1_button "scentone_savory" {say [translate {Beef}] $::settings(sound_button_in); scentone_toggle "Beef" } 1882 862 2550 1400
##################################################################################################################################################################################################################



#####################################################################
# end
#####################################################################

#set_next_page off describe_espresso0
#after 100 set_god_shot_scrollbar_dimensions
