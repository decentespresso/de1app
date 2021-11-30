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
		pages::setup_default_styles
		
		dui page add history_viewer -namespace ::history_viewer::pages::history_viewer -type fpdialog
	
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
				previous_page {}
				callback_cmd {}
				left_shot {}
				right_shot {}
				history_files {}
				history_entries {}
				history_shots {}
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
				
				dui add listbox $page 60 1000 -tags history_left -style hv_listbox -listvariable history_entries -select_cmd {::history_viewer::load_selected_shot left %W}

				# Align the right listbox so its right side matches the right side of the right graph 
				set yscrollbar_width [dui aspect get scrollbar width]
				dui add listbox $page [expr {2500-$yscrollbar_width}] 1000 -tags history_right -style hv_listbox -listvariable history_entries -canvas_anchor ne -select_cmd {::history_viewer::load_selected_shot right %W}
								
				dui add dbutton $page 1101 1425 -tags done_btn -style hv_done_button -label [translate "Done"] \
					-command page_done

				dui add dbutton $page 696 1010  -tags match_current_btn -style hv_button -label [translate "Match current profile"] \
					-label1variable history_match_profile -command { %NS::flip_setting history_match_profile; %NS::update_data} \
					-label_pos {0.5 0.35} -label1_pos {0.5 0.8}
	
				dui add dbutton $page 696 1210  -tags show_goals_btn -style hv_button -label [translate "Goals"] \
					-label1variable show_goals -command {%NS::flip_setting show_goals}
				
				dui add dbutton $page 1101 1010 -tags show_steps_btn -style hv_button -label [translate "Steps"] \
					-label1variable show_steps -command {%NS::flip_setting show_steps}

				dui add dbutton $page 1101 1210 -tags show_resistance_btn -style hv_button -label [translate "Resistance"] \
					-label1variable show_resistance -command {%NS::flip_setting show_resistance}

				dui add dbutton $page 1501 1010 -tags show_overlay_btn -style hv_button -label [translate "Overlay"] \
					-label1variable show_overlay -command {%NS::flip_setting show_overlay}
	
				dui add dbutton $page 1501 1210 -tags show_temperature_btn -style hv_button -label [translate "Temperature"] \
					-label1variable show_temperature -command {%NS::flip_setting show_temperature}


				dui add graph $page 40 80 -tags graph_left -style hv_graph 
				create_graph_entries $widgets(graph_left) left true
				
				dui add graph $page 1300 80 -tags graph_right -style hv_graph
				create_graph_entries $widgets(graph_right) right true

				dui add graph $page 40 80 -tags graph_overlay -style hv_graph -width 2480 -initial_state hidden
				create_graph_entries $widgets(graph_overlay) left true
				create_graph_entries $widgets(graph_overlay) right false

				dui add variable $page 640 40 -textvariable {[%NS::get_past_elem ${%NS::data(left_shot)} profile title]} -tags left_title -style hv_graph_title
				dui add variable $page 1900 40 -textvariable {[%NS::get_past_elem ${%NS::data(right_shot)} profile title]} -tags right_title -style hv_graph_title

				dui add variable $page 60 780 -textvariable {[%NS::get_past_elem ${%NS::data(left_shot)} meta in]} -tags left_in -style hv_shot_params
				dui add variable $page 260 780 -textvariable {[%NS::get_past_elem ${%NS::data(left_shot)} meta out]g out} -tags left_out -style hv_shot_params
				dui add variable $page 440 780 -textvariable {[%NS::get_past_elem ${%NS::data(left_shot)} meta time]s} -tags left_time -style hv_shot_params

				dui add variable $page 1340 780 -textvariable {[%NS::get_past_elem ${%NS::data(right_shot)} meta in]} -tags right_in -style hv_shot_params
				dui add variable $page 1540 780 -textvariable {[%NS::get_past_elem ${%NS::data(right_shot)} meta out]g out} -tags right_out -style hv_shot_params
				dui add variable $page 1740 780 -textvariable {[%NS::get_past_elem ${%NS::data(right_shot)} meta time]s} -tags right_time -style hv_shot_params

			}

			# Named options:
			# -callback_cmd: Tcl code to run when the "Done" button is clicked and control is returned to the invoking page.  
			proc load {page_to_hide page_to_show args} {
				variable data
				array set opts $args 
				
				set data(previous_page) $page_to_hide
				set data(callback_cmd) [value_or_default opts(-callback_cmd) ""]
				
				update_data
			}

			proc show {args} {
				redraw_graph
			}

			proc page_done {} {
				variable data
				
				if { $data(callback_cmd) ne "" } {
					# CallbackS from the history viewer that return control to the invoking page have to take as arguments the left and right clock values.
					set left_clock ""
					set right_clock ""
					if {[dict exists [set data(left_shot)] clock]} {
						set left_clock [dict get [set data(left_shot)] clock]
					}
					if {[dict exists [set data(right_shot)] clock]} {
						set right_clock [dict get [set data(right_shot)] clock]
					}

					uplevel #0 [list $data(callback_cmd) $left_clock $right_clock]
				} elseif { $data(previous_page) ne "" }  {
					dui page load $data(previous_page)
				} else {
					dui page load off
				}
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
					$widget axis configure temp {*}[dui aspect list -type graph_axis -style hv_graph_axis -as_options yes]
					$widget axis configure x {*}[dui aspect list -type graph_xaxis -style hv_graph_axis -as_options yes]
					$widget axis configure y {*}[dui aspect list -type graph_yaxis -style hv_graph_axis -as_options yes]
				}

				foreach lt {temperature_goal temperature_basket temperature_mix} {
					$widget element create line_history_${target}_espresso_${lt} -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_${lt} -mapy temp {*}[dui aspect list -type graph_line -style hv_${lt} -as_options yes]
				}
				
				foreach lt {pressure_goal flow_goal pressure flow flow_weight weight} {
					$widget element create line_history_${target}_espresso_${lt} -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_${lt} {*}[dui aspect list -type graph_line -style hv_${lt} -as_options yes]
				}
				
				foreach lt {state_change resistance} {
					$widget element create line_history_${target}_${lt} -xdata ::history_viewer::vectors::${target}::history_elapsed -ydata ::history_viewer::vectors::${target}::history_${lt} {*}[dui aspect list -type graph_line -style hv_${lt} -as_options yes]
				}
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

				dui item show_or_hide [string is false $data(show_overlay)] $page [list $left $right]
				dui item show_or_hide [string is true $data(show_overlay)] $page $overlay
				
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

				set data(history_files) [::shot::list_last 100]
				set data(history_entries) {}
				set data(history_shots) {}

				::history_viewer::pages::history_viewer::parse_next_shotfile
			}

			proc first {ls} {
				upvar 1 $ls LIST
				if {[llength $LIST]} {
					set ret [lindex $LIST 0]
					set LIST [lreplace $LIST 0 0]
					return $ret
				} else {
					error "Ran out of list elements."
				}
			}

			proc parse_next_shotfile {} {
				variable data

				set matching_profile ""
				if {$data(history_match_profile)} {
					set matching_profile $::settings(profile_title)
				}

				if {[llength $data(history_files)]} {
					set shot_file [first data(history_files)]
					msg "Parsing $shot_file"
					after idle ::history_viewer::pages::history_viewer::parse_next_shotfile

					set shot [shot::parse_file $shot_file]
					if {$shot != {}} {

						set profile_title [dict get $shot profile title]
						if {$matching_profile ne "" && $profile_title eq $matching_profile} {
							msg -DEBUG [namespace current] "Profile not matching, skipping"
							return
						}
						msg -DEBUG [namespace current] "Adding $profile_title to the history list"

						set date [string range [dict get $shot date] 0 18]
						lappend data(history_entries) $date
						lappend data(history_shots) $shot
						return
					} else {
						msg -INFO "Parsing failed: $shot_file"
						return
					}
				}
			}

			proc past_title {target} {
				if {[dict exists [set data(${target}_shot)] title]} {
					return [dict get [set data(${target}_shot)] title]
				}

				return ""
			}

		}
		
		proc setup_default_styles {} {
			set bg_color [dui aspect get page bg_color -theme default -default "#DDD"]
			set smooth $::settings(live_graph_smoothing_technique)
			
			dui aspect set -theme default [subst {
				listbox.width.hv_listbox 18
				listbox.canvas_height.hv_listbox 550 
				listbox.yscrollbar.hv_listbox yes 
				listbox.font_size.hv_listox -1
				
				dbutton.shape.hv_button round 
				dbutton.bwidth.hv_button 364 
				dbutton.bheight.hv_button 170 
				dbutton_label.pos.hv_button {0.5 0.38} 
				dbutton_label.width.hv_button 360 
				dbutton_label1.pos.hv_button {0.5 0.7}

				dbutton.shape.hv_done_button round 
				dbutton.bwidth.hv_done_button 364 
				dbutton.bheight.hv_done_button 140 
				dbutton.symbol.hv_done_button chevron-left
				dbutton_label.pos.hv_done_button {0.6 0.5} 
				dbutton_label.width.hv_done_button 360
				
				dtext.font_size.hv_shot_params -1
				
				dtext.anchor.hv_graph_title center 
				dtext.justify.hv_graph_title center 
				
				graph.background.hv_graph $bg_color 
				graph.plotbackground.hv_graph $bg_color 
				graph.width.hv_graph 1220 
				graph.height.hv_graph 700 
				graph.borderwidth.hv_graph 1 
				graph.plotrelief.hv_graph flat
				
				graph_axis.color.hv_graph_axis #333 
				graph_axis.min.hv_graph_axis 0.0
				graph_axis.max.hv_graph_axis [expr 12 * 10]
				
				graph_xaxis.color.hv_graph_axis #333 
				graph_xaxis.tickfont.hv_graph_axis Helv_7 
				graph_xaxis.min.hv_graph_axis 0.0
				 
				graph_yaxis.color.hv_graph_axis #333 
				graph_yaxis.tickfont.hv_graph_axis Helv_7 
				graph_yaxis.min.hv_graph_axis 0.0 
				graph_yaxis.max.hv_graph_axis 12
				graph_yaxis.subdivisions.hv_graph_axis 5 
				graph_yaxis.majorticks.hv_graph_axis {0 1 2 3 4 5 6 7 8 9 10 11 12} 
				graph_yaxis.hide.hv_graph_axis 0
				
				graph_line.linewidth.hv_temperature_goal [dui platform rescale_x 8] 
				graph_line.color.hv_temperature_goal #ffa5a6 
				graph_line.smooth.hv_temperature_goal $smooth 
				graph_line.dashes.hv_temperature_goal {5 5}
				
				graph_line.linewidth.hv_temperature_basket [dui platform rescale_x 12] 
				graph_line.color.hv_temperature_basket #e73249
				graph_line.smooth.hv_temperature_basket $smooth 
				graph_line.dashes.hv_temperature_basket [list $::settings(chart_dashes_temperature)]

				graph_line.linewidth.hv_temperature_mix [dui platform rescale_x 15] 
				graph_line.color.hv_temperature_mix #ff888c
				graph_line.smooth.hv_temperature_mix $smooth 

				graph_line.linewidth.hv_pressure_goal [dui platform rescale_x 8] 
				graph_line.color.hv_pressure_goal #69fdb3
				graph_line.smooth.hv_pressure_goal $smooth 
				graph_line.dashes.hv_pressure_goal {5 5}

				graph_line.linewidth.hv_flow_goal [dui platform rescale_x 8] 
				graph_line.color.hv_flow_goal #7aaaff
				graph_line.smooth.hv_flow_goal $smooth 
				graph_line.dashes.hv_flow_goal {5 5}
					
				graph_line.linewidth.hv_pressure [dui platform rescale_x 12] 
				graph_line.color.hv_pressure #18c37e
				graph_line.smooth.hv_pressure $smooth 
				graph_line.dashes.hv_pressure [list $::settings(chart_dashes_pressure)]
					
				graph_line.linewidth.hv_flow [dui platform rescale_x 12] 
				graph_line.color.hv_flow #4e85f4
				graph_line.smooth.hv_flow $smooth 
				graph_line.dashes.hv_flow [list $::settings(chart_dashes_flow)]

				graph_line.linewidth.hv_flow_weight [dui platform rescale_x 12] 
				graph_line.color.hv_flow_weight #a2693d
				graph_line.smooth.hv_flow_weight $smooth 
				graph_line.dashes.hv_flow_weight [list $::settings(chart_dashes_flow)]

				graph_line.linewidth.hv_weight [dui platform rescale_x 6] 
				graph_line.color.hv_weight #a2693d
				graph_line.smooth.hv_weight $smooth 
				graph_line.dashes.hv_weight [list $::settings(chart_dashes_espresso_weight)]

				graph_line.linewidth.hv_state_change [dui platform rescale_x 6] 
				graph_line.color.hv_state_change #AAAAAA

				graph_line.linewidth.hv_resistance [dui platform rescale_x 4] 
				graph_line.color.hv_resistance #e5e500
				graph_line.smooth.hv_resistance $smooth 
				graph_line.dashes.hv_resistance {6 2}
				
			}]
		}
	}

	proc open { args } {
		dui page load history_viewer {*}$args
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

		set past_shot [lindex $data(history_shots) $stepnum]
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