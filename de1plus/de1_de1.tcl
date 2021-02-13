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


	foreach callback_list [list \
				       ::de1::event::listener::_on_major_state_change_lists \
				       ::de1::event::listener::_on_all_state_change_lists \
				       ::de1::event::listener::_on_flow_change_lists \
				       ::de1::event::listener::_after_flow_complete_lists \
				       ::de1::event::listener::_on_connect_lists \
				       ::de1::event::listener::_on_disconnect_lists \
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

} ;# ::de1::event::apply


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

} ;# ::de1:::state
