package provide de1_history_viewer 1.1
#
# Setup Code
#
namespace eval ::history_viewer {
	namespace export init open
    namespace ensemble create
	#
	# Data Vectors
	#
	namespace eval vectors {
		namespace eval left {
			proc init {} {
				blt::vector create history_elapsed history_pressure_goal history_flow_goal history_temperature_goal
				blt::vector create history_pressure history_flow history_flow_weight
				blt::vector create history_weight
				blt::vector create history_state_change
				blt::vector create history_resistance_weight history_resistance
				blt::vector create history_temperature_basket history_temperature_mix  history_temperature_goal
			}
		}

		namespace eval right {
			proc init {} {
				blt::vector create history_elapsed history_pressure_goal history_flow_goal history_temperature_goal
				blt::vector create history_pressure history_flow history_flow_weight
				blt::vector create history_weight
				blt::vector create history_state_change
				blt::vector create history_resistance_weight history_resistance
				blt::vector create history_temperature_basket history_temperature_mix  history_temperature_goal
			}
		}

		proc init {} {
			left::init
			right::init
		}
	}

	proc init {} {
		dui page add history_viewer -namespace ::history_viewer::pages::history_viewer

		vectors::init
	}

	#
	# UI
	#
	namespace eval pages {
		namespace eval history_viewer {
			variable widgets
			array set widgets {}

			variable data
			array set data {
				left_shot {}
				right_shot {}
				history_files {}
				history_entries {}
				history_match_profile no

				show_temperature no
				show_goals yes
				show_steps yes
				show_resistance no

				show_overlay no
			}

			proc setup {} {
				variable widgets
				set page [namespace tail [namespace current]]

				set current_theme [dui theme get]
				dui theme set default

				dui add listbox $page 40   1000 -tags history_left  -canvas_width 450 -canvas_height 550 -yscrollbar yes -font_size -1 -listvariable history_entries
				dui add listbox $page 1940 1000 -tags history_right -canvas_width 450 -canvas_height 550 -yscrollbar yes -font_size -1 -listvariable history_entries

				bind [dui item get_widget $page history_left]  <<ListboxSelect>> {::history_viewer::load_selected_shot left [dui item get_widget history_viewer history_left]}
				bind [dui item get_widget $page history_right] <<ListboxSelect>> {::history_viewer::load_selected_shot right [dui item get_widget history_viewer history_right]}

				dui add dbutton $page 1101 1440 -tags done_btn \
					-symbol chevron_left -label [translate "Done"] \
					-command { dui page load off current } -bwidth 350

				dui add dbutton $page 696 1010  -tags done_btn2  -bwidth 364 -bheight 170 -label [translate "Match current profile"] \
					-label_pos {0.5 0.38} -label1variable history_match_profile -label1_pos {0.5 0.7}        \
					-command { %NS::flip_setting history_match_profile; %NS::update_data}
	
				dui add dbutton $page 696 1210  -tags done_btn3  -bwidth 364 -bheight 170 -label [translate "Goals"]                 \
					-label_pos {0.5 0.38} -label1variable show_goals -label1_pos {0.5 0.7}        \
				    -command {%NS::flip_setting show_goals}
				
				dui add dbutton $page 1101 1010 -tags done_btn4  -bwidth 364 -bheight 170 -label [translate "Steps"]                 \
					-label_pos {0.5 0.38} -label1variable show_steps -label1_pos {0.5 0.7}        \
					-command {%NS::flip_setting show_steps}

				dui add dbutton $page 1101 1210 -tags done_btn1  -bwidth 364 -bheight 170 -label [translate "Resitance"]                 \
					-label_pos {0.5 0.38} -label1variable show_resistance -label1_pos {0.5 0.7}        \
					-command {%NS::flip_setting show_resistance}

				dui add dbutton $page 1501 1010 -tags done_btn5  -bwidth 364 -bheight 170 -label [translate "Overlay"] \
					-label_pos {0.5 0.38} -label1variable show_overlay -label1_pos {0.5 0.7}        \
					-command {%NS::flip_setting show_overlay}
	
				dui add dbutton $page 1501 1210 -tags btn1       -bwidth 364 -bheight 170 -label [translate "Temperature"]                 \
					-label_pos {0.5 0.38} -label1variable show_temperature -label1_pos {0.5 0.7}        \
					-command {%NS::flip_setting show_temperature}


				dui add graph $page   40 80 -tags graph_left  -plotbackground #DDD -width 1220 -height 820 -borderwidth 1 -background #DDD -plotrelief flat
				create_graph_entries $widgets(graph_left) left true
				dui add graph $page 1300 80 -tags graph_right -plotbackground #DDD -width 1220 -height 820 -borderwidth 1 -background #DDD -plotrelief flat
				create_graph_entries $widgets(graph_right) right true

				dui add graph $page 40 80 -tags graph_overlay -plotbackground #DDD -width 2480 -height 820 -borderwidth 1 -background #DDD -plotrelief flat
				create_graph_entries $widgets(graph_overlay) left true
				create_graph_entries $widgets(graph_overlay) right false

				dui add variable $page 640 0 -textvariable {[%NS::get_past_elem ${%NS::data(left_shot)} profile title]} -tags left_title
				dui add variable $page 1900 0 -textvariable {[%NS::get_past_elem ${%NS::data(right_shot)} profile title]} -tags right_title

				dui add variable $page 40 900 -textvariable {[%NS::get_past_elem ${%NS::data(left_shot)} meta in]} -tags left_in
				dui add variable $page 240 900 -textvariable {[%NS::get_past_elem ${%NS::data(left_shot)} meta out]g out} -tags left_out
				dui add variable $page 440 900 -textvariable {[%NS::get_past_elem ${%NS::data(left_shot)} meta time]s} -tags left_time

				dui add variable $page 1300 900 -textvariable {[%NS::get_past_elem ${%NS::data(right_shot)} meta in]} -tags right_in
				dui add variable $page 1500 900 -textvariable {[%NS::get_past_elem ${%NS::data(right_shot)} meta out]g out} -tags right_out
				dui add variable $page 1700 900 -textvariable {[%NS::get_past_elem ${%NS::data(right_shot)} meta time]s} -tags right_time

			}

			proc load {args} {
				update_data
			}

			proc show {args} {
				redraw_graph
			}

			proc get_past_elem {target args} {
				if {[dict exists $target {*}$args]} {
					return [dict get $target {*}$args]
				}
				return ""
			}

			proc create_graph_entries {widget target create_axis} {
				if {$create_axis} {
					$widget axis create temp
					$widget axis configure temp -color #333 -min 0.0 -max [expr 12 * 10]
					$widget axis configure x -color #333 -tickfont Helv_7 -min 0.0;
					$widget axis configure y -color #333 -tickfont Helv_7 -min 0.0 -max 12 -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12}  -hide 0;
				}

				$widget element create line_history_${target}_espresso_temperature_goal -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_temperature_goal -mapy temp  -symbol none -label ""  -linewidth [rescale_x_skin 8] -color #ffa5a6 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5}; 
				$widget element create line_history_${target}_espresso_temperature_basket -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_temperature_basket -mapy temp -symbol none -label ""  -linewidth [rescale_x_skin 12] -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_temperature);  
				$widget element create line_history_${target}_espresso_temperature_mix -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_temperature_mix -mapy temp -label "" -linewidth [rescale_x_skin 15] -color #ff888c  -smooth $::settings(live_graph_smoothing_technique) -pixels 0; 
	
				$widget element create line_history_${target}_espresso_pressure_goal -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color #3D5682  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
				$widget element create line_history_${target}_espresso_flow_goal -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_flow_goal -symbol none -label "" -linewidth [rescale_x_skin 8] -color #F27405  -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5};
				$widget element create line_history_${target}_espresso_pressure -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_pressure  -symbol none -label "" -linewidth [rescale_x_skin 12] -color #417491 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_pressure);
				$widget element create line_history_${target}_espresso_flow -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_flow -symbol none -label "" -linewidth [rescale_x_skin 12] -color  #F27405 -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes $::settings(chart_dashes_flow);
				$widget element create line_history_${target}_espresso_flow_weight -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_flow_weight -symbol none -label "" -linewidth [rescale_x_skin 12] -color  #F28705 -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes $::settings(chart_dashes_flow);
				$widget element create line_history_${target}_espresso_weight -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_weight -symbol none -label "" -linewidth [rescale_x_skin 6] -color #f8b888 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);
				$widget element create line_history_${target}_state_change -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_state_change -label "" -linewidth [rescale_x_skin 6] -color #AAAAAA  -pixels 0 ;
				$widget element create line_history_${target}_resistance  -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_resistance -symbol none -label "" -linewidth [rescale_x_skin 4] -color #e5e500 -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {6 2};


			}

			proc get_settings {name} {
				variable data

				set val [set data($name)]
				if {$val == 1} {
					return "on"
				} else {
					return "off"
				}
			}

			proc flip_setting {name} {
				variable data
				
				set val [set data($name)]
				if {$val == yes} {
					set data($name) no
				} else {
					set data($name) yes
				}

				redraw_graph
			}

			proc redraw_graph {} {
				variable data
				variable widgets

				set page history_viewer
				set left $widgets(graph_left)
				set right $widgets(graph_right)

				set overlay $widgets(graph_overlay)

				if {$data(show_overlay) == yes} {
					dui item hide $page $left
					dui item hide $page $right
					dui item show $page $overlay
				} else {
					dui item show $page $left
					dui item show $page $right
					dui item hide $page $overlay
				}

				configure_graph left $left 
				configure_graph right $right 
				configure_graph left  $overlay 
				configure_graph right $overlay 
			}

			proc configure_graph {target widget} {
				variable data

				$widget element configure line_history_${target}_espresso_pressure_goal -hide [expr !$data(show_goals)]
				$widget element configure line_history_${target}_espresso_flow_goal -hide [expr !$data(show_goals)]

				$widget element configure line_history_${target}_state_change -hide [expr !$data(show_steps)]
				$widget element configure line_history_${target}_resistance   -hide [expr !$data(show_resistance)]

				$widget element configure line_history_${target}_espresso_temperature_goal -hide [expr !$data(show_temperature)]
				$widget element configure line_history_${target}_espresso_temperature_basket -hide [expr !$data(show_temperature)]
				$widget element configure line_history_${target}_espresso_temperature_mix -hide [expr !$data(show_temperature)]
			}

			proc update_data {} {
				variable data

				set matching_profile ""
				if {$data(history_match_profile)} {
					set matching_profile $::settings(profile_title)
				}
				set data(history_files) [::shot::list_last $::iconik_settings(max_history_items) $matching_profile]
				set data(history_entries) {}
				foreach shot $data(history_files) {
					set date [string range [dict get $shot date] 0 18]
					lappend data(history_entries) $date
				}
			}

			proc past_title {target} {
				if {[dict exists [set data(${target}_shot)] title]} {
					return [dict get [set data(${target}_shot)] title]
				}

				return ""
			}

		}
	}

	proc open {} {
		dui page load history_viewer
	}

	proc load_history_field {target data args} {
		catch {
			if {[dict exists $data {*}$args]} {
				set val [dict get $data {*}$args]
				$target set [list {*}$val]
				msg -DEBUG "got" {*}$args "from shot: " $val
			} else {
				msg -DEBUG {*}$args "does not exist"
			}
		}
	}

	proc load_selected_shot {target widget} {
		variable ::history_viewer::pages::history_viewer::data

		set stepnum [$widget curselection]
		if {$stepnum == ""} {
			return
		}

		set past_shot [lindex $data(history_files) $stepnum]
		load_shot $target $widget $past_shot
	}

	proc load_shot {target widget past_shot} {
		variable ::history_viewer::pages::history_viewer::data

		set last_title [dict get $past_shot profile title]
		set filename [dict get $past_shot filename]
		msg -DEBUG "loading $last_title from $filename"
		load_history_field ::history_viewer::vectors::${target}::history_elapsed            $past_shot elapsed
		load_history_field ::history_viewer::vectors::${target}::history_pressure_goal      $past_shot pressure goal
		load_history_field ::history_viewer::vectors::${target}::history_pressure           $past_shot pressure pressure
		load_history_field ::history_viewer::vectors::${target}::history_flow_goal          $past_shot flow goal
		load_history_field ::history_viewer::vectors::${target}::history_flow               $past_shot flow flow
		load_history_field ::history_viewer::vectors::${target}::history_flow_weight        $past_shot flow by_weight
		load_history_field ::history_viewer::vectors::${target}::history_weight             $past_shot totals weight
		load_history_field ::history_viewer::vectors::${target}::history_temperature_basket $past_shot temperature basket
		load_history_field ::history_viewer::vectors::${target}::history_temperature_mix    $past_shot temperature mix
		load_history_field ::history_viewer::vectors::${target}::history_temperature_goal   $past_shot temperature goal
		# New 1.34.5 shot fields
		load_history_field ::history_viewer::vectors::${target}::history_state_change       $past_shot state_change
		load_history_field ::history_viewer::vectors::${target}::history_resistance_weight  $past_shot resistance by_weight
		load_history_field ::history_viewer::vectors::${target}::history_resistance         $past_shot resistance resistance

		set data(${target}_shot) $past_shot
	}

}