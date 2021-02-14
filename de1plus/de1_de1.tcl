#
# This breaks existing naming convention as de1.tcl already exists
# as a script to start de1app.tcl
#
#
# These are not in machine.tcl due to apparent assumptions on inclusion order
#

package provide de1_de1 1.0

package require lambda

package require de1_event 1.0
package require de1_logging 1.0

namespace eval ::de1::event::listener {

	# Comments for reference, see code for exact conditions (binary.tcl)

	# When changing from, for example, "Idle" to "Espresso"

	proc on_major_state_change_add {args} {

		::event::listener::_generic_add ::de1::event::listener::_on_major_state_change_lists {*}$args
	}


	# Any time the state or substate changes, including from, for example "heating" to "final heating"

	proc on_all_state_change_add {args} {

		::event::listener::_generic_add ::de1::event::listener::_on_all_state_change_lists {*}$args
	}


	# When the ::de1::state::flow_phase changes from, for example, "during" to "after" or "" to "before"

	proc on_flow_change_add {args} {

		::event::listener::_generic_add ::de1::event::listener::_on_flow_change_lists {*}$args
	}


	#
	# after_flow_complete will trigger for ::de1::is_flow_state after
	# $::settings(seconds_after_espresso_stop_to_continue_weighing)
	#     after transition to ending, but not before leaving a flow state
	#     after transition out of a flow state, if not already pending or triggered
	#

	proc after_flow_complete_add {args} {

		::event::listener::_generic_add ::de1::event::listener::_after_flow_complete_lists {*}$args
	}

	proc on_connect_add {args} {

		::event::listener::_generic_add ::de1::event::listener::_on_connect_lists {*}$args
	}

	proc on_disconnect_add {args} {

		::event::listener::_generic_add ::de1::event::listener::_on_disconnect_lists {*}$args
	}

	proc on_shotvalue_available_add {args} {

		::event::listener::_generic_add ::de1::event::listener::_on_shotvalue_available_lists {*}$args
	}




	foreach callback_list [list \
				       ::de1::event::listener::_on_major_state_change_lists \
				       ::de1::event::listener::_on_all_state_change_lists \
				       ::de1::event::listener::_on_flow_change_lists \
				       ::de1::event::listener::_after_flow_complete_lists \
				       ::de1::event::listener::_on_connect_lists \
				       ::de1::event::listener::_on_disconnect_lists \
				       ::de1::event::listener::_on_shotvalue_available_lists \
				      ] {

		::event::listener::_init_callback_list $callback_list
	}

} ;# ::de1::event::listener


namespace eval ::de1::event::apply {

	proc on_major_state_change_callbacks {args} {

		::event::apply::_generic ::de1::event::listener::_on_major_state_change_lists {*}$args
	}

	proc on_all_state_change_callbacks {args} {

		::event::apply::_generic ::de1::event::listener::_on_all_state_change_lists {*}$args
	}

	proc on_flow_change_callbacks {args} {

		::event::apply::_generic ::de1::event::listener::_on_flow_change_lists {*}$args
	}

	variable _after_flow_complete_after_id ""
	variable _after_flow_complete_holding_for_idle False


	proc after_flow_complete_callbacks {args} {

		variable _after_flow_complete_after_id
		variable _after_flow_complete_holding_for_idle

		::event::apply::_generic ::de1::event::listener::_after_flow_complete_lists {*}$args

		set _after_flow_complete_after_id ""
		set _after_flow_complete_holding_for_idle False
	}


	proc after_flow_is_pending {} {

		variable _after_flow_complete_after_id
		variable _after_flow_complete_holding_for_idle

		expr { $_after_flow_complete_after_id != "" }
	}

	# It's not clear that these always should be cancelled on the start of a new flow cycle
	# Though saving the shot history is one use case (which gets reset on a new Espresso cycle)
	# there may be others that should be allowed to run to completion

	# after_flow_cancel_pending provided should there be a "good" use case for it in the future

	proc after_flow_cancel_pending {} {

		variable _after_flow_complete_after_id
		variable _after_flow_complete_holding_for_idle

		if { [after_flow_is_pending] } {
			after cancel $_after_flow_complete_after_id
			set _after_flow_complete_after_id ""

			msg -WARNING "Cancelled after_flow_complete callbacks. " \
				[format "Second flow started before %g seconds?" \
					 $::settings(seconds_after_espresso_stop_to_continue_weighing)]
		}
	}



	# TODO: Consider if and how to deal with pending "after ID" if another shot is started

	proc _maybe_after_flow_complete_callbacks {args} {

		# Timer has fired, defer if still in a flow phase (such as "ending")

		# args represent state at time scheduled, not now

		if { ! [::de1::state::is_flow_state [::de1::state::current_state]] } {

			set $::de1::event::apply::_after_flow_complete_holding_for_idle false

			::de1::event::apply::after_flow_complete_callbacks {*}${args}

			msg -DEBUG [format "after_flow_complete: Applied during %s,%s by apply::_maybe_after..." \
					    [::de1::state::current_state] [::de1::state::current_substate]]


		} else {

			set $::de1::event::apply::_after_flow_complete_holding_for_idle true

			msg -DEBUG [format "after_flow_complete: Deferred for non-flow during %s,%s by apply::_maybe_after..." \
					    [::de1::state::current_state] [::de1::state::current_substate]]
		}
	}

	proc on_connect_callbacks {args} {

		::event::apply::_generic ::de1::event::listener::_on_connect_lists {*}$args
	}

	proc on_disconnect_callbacks {args} {

		::event::apply::_generic ::de1::event::listener::_on_disconnect_lists {*}$args
	}

	proc on_shotvalue_available_callbacks {args} {

		::event::apply::_generic ::de1::event::listener::_on_shotvalue_available_lists {*}$args
	}

} ;# ::de1::event::apply


namespace eval ::de1 {

	proc line_voltage_nom {} {

		if {[info exists ::settings(heater_voltage)]} {
			return [expr { double($::settings(heater_voltage)) }]
		} else {
			return False
		}
	}

	# When line frequency is reported by the firmware,
	# prefer over estimation from arrival times

	proc line_frequency_nom {} {

		if {[info exists ::settings(line_frequency)] && $::settings(line_frequency)} {

			return [expr { double($::settings(line_frequency)) }]
		} else {

			return [::de1::_line_frequency_guess]
		}
	}

	proc _line_frequency_guess {} {

		# Korea, Peru, Philippines, and some other nations run ~230 V, 60 Hz
		# Try to catch Korea, even if likely called before a user has a chance to set language

		if {[::de1_line_voltage_nom] == 230} {
			if {[info exists ::settings(language)] && $::settings(language) == "kr" } {
				return 60.0
			} else {
				return 50.0
			}
		} else if {[::de1_line_voltage_nom] == 120} {
			return 60.0
		} else {
			return 50.0
		}
	}


	#
	# Line-frequency estimation (determines DE1's firmware shot-reporting period as of 2021-02)
	#

	# ::settings() hasn't been loaded at this point in execution, so have to check on connect
	# See proc load_settings {} in utils.tcl and load_settings_vars {} in vars.tcl as of 2021-02

	proc _maybe_start_line_frequency_estimator {args} {

		if {   ! [info exists ::settings(line_frequency)] \
			       || ( $::settings(line_frequency) != 50 && $::settings(line_frequency) != 60 ) \
			       || (    [info exists ::settings(line_frequency_always_estimate)] \
					       && $::settings(line_frequency_always_estimate) ) } {

			::de1::_start_line_frequency_estimator
		}
	}

	::de1::event::listener::on_connect_add -idle ::de1::_maybe_start_line_frequency_estimator

	variable _line_frequency_estimator_registered False

	proc _start_line_frequency_estimator {{restart False}} {

		if { [info exists ::de1::_line_frequency_estimate_running] } {
			if { $restart } {
				msg -INFO "_start_line_frequency_estimator: Restarting."
			} else {
				msg -NOTICE "_start_line_frequency_estimator: Already running. Not restarting."
				return
			}
		}

		set ::de1::_line_frequency_estimate_start_time 0
		set ::de1::_line_frequency_estimate_start_count 0
		set ::de1::_line_frequency_estimate_skip_updates False
		set ::de1::_line_frequency_estimate_running True

		if { ! $::de1::_line_frequency_estimator_registered } {
			::de1::event::listener::on_shotvalue_available_add ::de1::_line_frequency_estimator
			set ::de1::_line_frequency_estimator_registered True
			msg -DEBUG "::de1::_start_line_frequency_estimator, registered listener"
		}

		msg -DEBUG "::de1::_start_line_frequency_estimator, waiting for updates"
	}

	proc _line_frequency_estimator {event_dict} {

		if { $::de1::_line_frequency_estimate_skip_updates } { return }

		if { [::de1::_bluetooth_xmit_queue_depth] > 1 } {
			set qd [::de1::_bluetooth_xmit_queue_depth]
			set holdoff_time_ms [expr { max( 1000, [expr { $qd * 100 + 100 }] ) }]
			msg -INFO [format "::de1::_line_frequency_estimator: Bluetooth too busy for accuracy (%d). Rescheduling in %d ms." \
					   $qd $holdoff_time_ms]
			set ::de1::_line_frequency_estimate_skip_updates True
			after $holdoff_time_ms ::de1::_start_line_frequency_estimator True
			return
		}

		# Need to distinguish 250 ms from 208.3 ms period, ~ 20 ms threshold
		# Standard deviation of arrivals ~ 40 ms; 5 sigma => ~ 4 ms, ~100 samples, ~25 seconds
		# However, if samples are within 250 ms of "mark", then worst-case for two is 500 ms
		# 500 ms on a 10 second time base is 5%, less than half the 20% rate difference.

		set min_window 10.0


		set sample_time [dict get $event_dict SampleTime]
		set update_received [dict get $event_dict update_received]

		if { $::de1::_line_frequency_estimate_start_time == 0  } {

			set ::de1::_line_frequency_estimate_start_time $update_received
			set ::de1::_line_frequency_estimate_start_count $sample_time

			msg -DEBUG "::de1::_line_frequency_estimator: First update received"

		} elseif { $update_received - $::de1::_line_frequency_estimate_start_time < $min_window } {

			# pass

		} else {

			set dt [expr { $update_received - $::de1::_line_frequency_estimate_start_time }]
			set dc [expr { $sample_time - $::de1::_line_frequency_estimate_start_count }]

			# Manage 16-bit counter roll of the "zero-cross" counter (100 or 120 Hz)
			if { $dc < 0 } { set dc [expr { $dc + 65535 }]}

			set hz_est [expr { ( $dc / 2 ) / $dt }]

			if { 45.0 < $hz_est && $hz_est < 55.0 } {

				set ::settings(line_frequency) 50.0
				msg -INFO [format "::de1::_line_frequency_estimator: %.0f Hz inferred from %6.3f estimate" \
						   $::settings(line_frequency) $hz_est]

			} elseif { 55.0 < $hz_est && $hz_est < 65.0 } {

				set ::settings(line_frequency) 60.0
				msg -INFO [format "::de1::_line_frequency_estimator: %.0f Hz inferred from %6.3f estimate" \
						   $::settings(line_frequency) $hz_est]

			} else {
				msg -ERROR [format "::de1::_line_frequency_estimator: Time not set from %6.3f estimate" \
						    $hz_est]

			}

			set ::de1::_line_frequency_estimate_skip_updates True
			unset -nocomplain ::de1::_line_frequency_estimate_running
		}
	}

	#
	# Used for empirical test for "too busy to get good timing"
	#
	# TODO: This depends on what is presently in de1_comms.tcl
	#

	proc _bluetooth_xmit_queue_depth {} {

		return [llength $::de1(cmdstack)]
	}

} ;# ::de1


namespace eval ::de1::state {

	proc current_state {} {

		expr { $::de1_num_state($::de1(state)) }
	}

	proc current_substate {} {

		expr { $::de1_substate_types($::de1(substate)) }
	}

	proc is_flow_state {{state_text "None"} {substate_text "None"}} {

		if { $state_text == "None" } { set state_text [::de1::state::current_state] }
		if { $substate_text == "None" } { set substate_text [::de1::state::current_substate] }

		expr { $state_text in { {Espresso} {Steam} {HotWater} {HotWaterRinse} } }
	}

	proc flow_phase {{state_text "None"} {substate_text "None"}} {

		if { $state_text == "None" } { set state_text [::de1::state::current_state] }
		if { $substate_text == "None" } { set substate_text [::de1::state::current_substate] }

		if { ! [is_flow_state $state_text] } { return "" }

		switch $substate_text {

			starting 	{ return "before" }
			ready 		{ return "before" }
			heating 	{ return "before" }
			"final heating"	{ return "before" }
			stabilising 	{ return "before" }

			preinfusion 	{ return "during" }
			pouring 	{ return "during" }

			ending 		{ return "after" }

			default		{ return "" }
		}
	}

	proc is_flow_before_state {{state_text "None"} {substate_text "None"}} {

		if { $state_text == "None" } { set state_text [::de1::state::current_state] }
		if { $substate_text == "None" } { set substate_text [::de1::state::current_substate] }

		expr { [flow_phase $state_text $substate_text] == "before" }
	}

	proc is_flow_during_state {{state_text "None"} {substate_text "None"}} {

		if { $state_text == "None" } { set state_text [::de1::state::current_state] }
		if { $substate_text == "None" } { set substate_text [::de1::state::current_substate] }

		expr { [flow_phase $state_text $substate_text] == "during" }

	}

	proc is_flow_after_state {{state_text "None"} {substate_text "None"}} {

		if { $state_text == "None" } { set state_text [::de1::state::current_state] }
		if { $substate_text == "None" } { set substate_text [::de1::state::current_substate] }

		expr { [flow_phase $state_text $substate_text] == "after" }

	}

} ;# ::de1::state
