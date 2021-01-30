
#
# Logic
#

blt::vector create history_elapsed history_pressure_goal history_flow_goal
blt::vector create history_pressure history_flow
blt::vector create history_weight

proc show_history_page {} {
	fill_history_listbox
	page_to_show_when_off "history"
	set_history_scrollbar_dimensions
}

proc fill_history_listbox {} {
	#puts "fill_history_listbox $widget"
	set widget $::history_widget
	$widget delete 0 99999
	set cnt 0

	set ::history_files [lsort -dictionary -decreasing [glob -nocomplain -tails -directory "[homedir]/history/" *.shot]]

    foreach shot_file $::history_files {
        set tailname [file tail $shot_file]
        set newfile [file rootname $tailname]
        set fname "history/$newfile.csv"

		array unset -nocomplain shot
		catch {
			array set shot [read_file "history/$shot_file"]
		}
		if {[array size shot] == 0} {
			msg "Corrupted shot history item: 'history/$shot_file'"
			continue
		}
		set dbg [array get shot]
		msg "Read history item: $fname"

		$widget insert $cnt $newfile
		incr cnt
	}

	set $::history_widget widget
}

proc show_past_shot {} {
	set stepnum [$::history_widget curselection]
	if {$stepnum == ""} {
		return
	}

	set shotfile [lindex $::history_files $stepnum]
	set fn "[homedir]/history/$shotfile"

	array set past_shot [encoding convertfrom utf-8 [read_binary_file $fn]]

	msg "Read shot $fn"

	history_elapsed set $past_shot(espresso_elapsed)
	history_pressure_goal set $past_shot(espresso_pressure_goal)
	history_flow_goal set $past_shot(espresso_flow_goal)
	history_pressure set $past_shot(espresso_pressure)
	history_flow set $past_shot(espresso_flow)
	history_weight set $past_shot(espresso_weight)

}


#
# UI
#

add_background "history"


add_de1_widget "history" graph 680 80 {
	#Target
	$widget element create line_history_espresso_pressure_goal -xdata history_elapsed -ydata history_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color [theme primary_light]  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
	$widget element create line_history_espresso_flow_goal -xdata history_elapsed -ydata history_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color [theme secondary_light] -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5};
	$widget element create line_history_espresso_pressure -xdata history_elapsed -ydata history_pressure  -symbol none -label "" -linewidth [rescale_x_skin 12] -color [theme primary]  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure);
	$widget element create line_history_espresso_flow -xdata history_elapsed -ydata history_flow -symbol none -label "" -linewidth [rescale_x_skin 12] -color  [theme secondary] -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes $::settings(chart_dashes_flow);

	$widget element create line_history_espresso_weight -xdata history_elapsed -ydata history_weight -symbol none -label "" -linewidth [rescale_x_skin 6] -color #f8b888 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);
	$widget axis configure x -color [theme background_text] -tickfont Helv_7 -min 0.0;
	$widget axis configure y -color [theme background_text] -tickfont Helv_7 -min 0.0 -max 12 -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12}  -hide 0;
	$widget grid configure -color [theme background_text]

} -plotbackground [theme background] -width [rescale_x_skin 1860] -height [rescale_y_skin 1340] -borderwidth 1 -background [theme background] -plotrelief flat

add_de1_widget "history" listbox 80	80 {
	set ::history_widget $widget
	bind $::history_widget <<ListboxSelect>> ::show_past_shot
	fill_history_listbox
} -background #fbfaff -font Helv_9 -bd 0 -height 18 -width 16 -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single -foreground [theme primary] -selectbackground [theme primary_dark]  -selectforeground [theme button_text_light] -yscrollcommand {scale_scroll_new $::history_widget ::history_slider}

set ::history_slider 0
set ::history_scrollbar [add_de1_widget "history" scale 10000 1 {} -from 0 -to .90 -bigincrement 0.2 -background [theme primary] -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 400] -width [rescale_y_skin 150] -variable ::history_slider -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::history_widget $::history_slider}  -foreground [theme background] -troughcolor [theme background] -borderwidth 2  -highlightthickness 0]

proc set_history_scrollbar_dimensions {} {
	set_scrollbar_dimensions $::history_scrollbar $::history_widget
}

create_button "history" 580 1440 1880 1560 [translate "Done"] $::font_tiny [theme button_tertiary] [theme button_text_light] { say [translate "settings"] $::settings(sound_button_in); page_to_show_when_off "off" }