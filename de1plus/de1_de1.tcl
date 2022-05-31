#
# This breaks existing naming convention as de1.tcl already exists
# as a script to start de1app.tcl
#
#
# These are not in machine.tcl due to apparent assumptions on inclusion order
#

package provide de1_de1 1.4

package require lambda

package require de1_event 1.0
package require de1_logging 1.0



###
### ::de1::event::listener
###

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
	# $::settings(after_flow_complete_delay) seconds
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



###
### ::de1::event::apply
###

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


	proc after_flow_complete_is_pending {} {

		variable _after_flow_complete_after_id
		variable _after_flow_complete_holding_for_idle

		expr { $_after_flow_complete_after_id != "" \
			       || $_after_flow_complete_holding_for_idle }
	}

	# It's not clear that these always should be cancelled on the start of a new flow cycle
	# Though saving the shot history is one use case (which gets reset on a new Espresso cycle)
	# there may be others that should be allowed to run to completion

	# after_flow_complete_cancel_pending provided should there be a "good" use case for it in the future

	proc after_flow_complete_cancel_pending {} {

		variable _after_flow_complete_after_id
		variable _after_flow_complete_holding_for_idle

		if { [::de1::after_flow_complete_is_pending] } {

			after cancel $_after_flow_complete_after_id
			set _after_flow_complete_after_id ""

			set _after_flow_complete_holding_for_idle False

			msg -WARNING "Cancelled after_flow_complete callbacks. " \
				[format "Second flow started before %g seconds?" \
					 $::settings(after_flow_complete_delay)]
		}
	}



	# TODO: Consider if and how to deal with pending "after ID" if another shot is started

	proc _maybe_after_flow_complete_callbacks {args} {

		# Timer has fired, defer if still in a flow phase (such as "ending")

		set ::de1::event::apply::_after_flow_complete_after_id ""

		# args represent state at time scheduled, not now

		if { ! [::de1::state::is_flow_state [::de1::state::current_state]] } {

			set ::de1::event::apply::_after_flow_complete_holding_for_idle False

			::de1::event::apply::after_flow_complete_callbacks {*}${args}

			msg -DEBUG [format "after_flow_complete: Applied during %s,%s by apply::_maybe_after..." \
					    [::de1::state::current_state] [::de1::state::current_substate]]


		} else {

			set ::de1::event::apply::_after_flow_complete_holding_for_idle True

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



###
### ::de1::event::listener
###

namespace eval ::de1 {

	proc init {} {

		::de1::state::init
		msg -DEBUG "::de1::init done"
	}

	::de1::event::listener::on_connect_add [lambda {args} ::de1::init]

	proc line_voltage_nom {} {

		# string is double "" returns 1, expr {double("")} is an error

		if {[info exists ::settings(heater_voltage)] \
			    && [string is double $::settings(heater_voltage)] \
			    && $::settings(heater_voltage) != "" } {
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

		if {[::de1::line_voltage_nom] == 230} {
			if {[info exists ::settings(language)] && $::settings(language) == "kr" } {
				return 60.0
			} else {
				return 50.0
			}
		} elseif {[::de1::line_voltage_nom] == 120} {
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



###
### ::de1::state
###

namespace eval ::de1::state {

	proc init {} {

		::de1::state::reset_framenumbers
		unset -nocomplain ::de1::state::_previous_shotsample_update_time

		msg -DEBUG "::de1::state::init done"
	}

	proc current_state {} {

		expr { $::de1_num_state($::de1(state)) }
	}

	proc current_substate {} {
		set s "unknown substate"
		catch {
			set s [expr { $::de1_substate_types($::de1(substate)) }]
		}
		return $s
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

	proc reset_framenumbers {} {
		set ::de1(current_frame_number) 0
	}

	# Use the existing global
	proc current_framenumber {} {
		return $::de1(current_frame_number)
	}

} ;# ::de1::state



###
### ::de1::state::update
###

namespace eval ::de1::state::update {

	proc from_shotvalue {packed {update_received 0}} {

		if { $update_received == 0 } { set update_received [expr {[clock milliseconds] / 1000.0}] }

		# TODO: Consider capturing early (on packet arrival) along with update_received
		#       in a generic way for all packets

		# Capture for downstreaam consumers of events as well as local use

		set this_state [::de1::state::current_state]
		set this_substate [::de1::state::current_substate]

		array set ShotSample {}

		::de1::packet::shotsample_parse $packed ShotSample

		if {[array size ShotSample] == 0} {
			# shotsample_parse can return with a blank, if the packet is invalid
			msg -WARN "Invalid shot sample received, ignoring"			
			return
		}

		# SampleTime not present in prior code
		set ::de1(pressure) 			$ShotSample(GroupPressure)
		set ::de1(flow)				$ShotSample(GroupFlow)
		set ::de1(mix_temperature)		$ShotSample(MixTemp)
		set ::de1(head_temperature)		$ShotSample(HeadTemp)
		# SetMixTemp not present in prior code
		set ::de1(goal_temperature)		$ShotSample(SetHeadTemp)
		set ::de1(goal_pressure)		$ShotSample(SetGroupPressure)
		set ::de1(goal_flow)			$ShotSample(SetGroupFlow)
		set ::de1(current_frame_number)		$ShotSample(FrameNumber)
		set ::de1(steam_heater_temperature)	$ShotSample(SteamTemp)



		# TODO: Determine if excessive change in SampleTime should invalidate all deltas
		#       Probably should include determined intersample time in event_dict

		# SampleTime, at least during a shot, is measured in half-cycles; 100 or 120 Hz
		# During sleep, it has been observed to drop to 1/3 of the "awake" rate

		# Unwrap 16-bit unsigned int SampleTime
		# Much of this proc could be refactored into ::de1 and ::gui
		# Neither ::previous_timer nor ShotSample(Timer) were used elsewhere in prior code

		if { [info exists ::de1::_previous_shotsample_update_time] } {

			set dhc [expr { $ShotSample(SampleTime) \
						- $::de1::_previous_shotsample_update_time }]
			if { $dhc < 0 } { set dhc [expr { $dhc + 65536 }] }
			set intersample_time [expr { $dhc / ( 2.0 * [::de1::line_frequency_nom] ) }]

		} else {
			set intersample_time 0.0
		}

		set ::de1::_previous_shotsample_update_time $ShotSample(SampleTime)


		set water_volume_dispensed_since_last_update \
			[expr { $ShotSample(GroupFlow) * $intersample_time }]
		#
		# Properly unwrapping the 16-bit value for the time delta
		# should prevent the conditions previously seen in the code
		# retain the checks in case there is something else going on
		#

		if {$water_volume_dispensed_since_last_update < 0} {
			msg -WARN "Negative water volume dispensed, setting to 0:" \
				"$ShotSample(GroupFlow) * $intersample_time =" \
				"$water_volume_dispensed_since_last_update" \
				"during $this_state,$this_substate"
			set water_volume_dispensed_since_last_update 0

		} elseif {$water_volume_dispensed_since_last_update > 1000} {
			msg -WARN "Excessive water volume dispensed, setting to 0:" \
				"$ShotSample(GroupFlow) * $intersample_time =" \
				"$water_volume_dispensed_since_last_update" \
				"during $this_state,$this_substate"
			set water_volume_dispensed_since_last_update 0
		}

		set ::de1(volume) [expr {$::de1(volume) + $water_volume_dispensed_since_last_update}]

		# TODO: Are there any ill effects of capturing flow for other states???
		#       If not, do so (and probably share active states with SAW)

		if { [::de1::sav::is_tracking_state $this_state] } {

			switch -exact -- $this_state {

				Espresso {

					switch -- $this_substate {

						preinfusion {
							set ::de1(preinfusion_volume) \
								[expr {$::de1(preinfusion_volume) \
									       + $water_volume_dispensed_since_last_update}]
						}

						pouring {
							set ::de1(pour_volume) \
								[expr {$::de1(pour_volume) \
									       + $water_volume_dispensed_since_last_update}]
						}
					}
				}

				default {

					set ::de1(pour_volume) \
						[expr {$::de1(pour_volume) \
							       + $water_volume_dispensed_since_last_update}]
				}
			}

			::de1::sav::check_for_sav

		}


		set event_dict [dict create \
					event_time [expr {[clock milliseconds] / 1000.0}] \
					update_received $update_received \
					{*}[array get ShotSample] \
					volume_dispensed \
					    [expr { $::de1(preinfusion_volume) \
							+ $::de1(pour_volume) }] \
					this_state $this_state \
					this_substate $this_substate \
				       ]

		::de1::event::apply::on_shotvalue_available_callbacks $event_dict

		return

	} ;# from_shotvalue

} ;# ::de1::state::update



###
### ::de1::packet
###

namespace eval ::de1::packet {

	# No uses of former ::ble_spec found in code as of 2020-02
	# other than within parsing of ShotSample in binary.tcl
	# Logic around ble_spec detection retained from prior code
	# TODO: This should be rewritten to use versions from the DE1

	set ::de1::packet::ble_spec 1.0

	proc use_old_ble_spec {} {

		# Extracted from binary.tcl - 2021-02

		if {$::de1::packet::ble_spec < 1.0} {
			return 1
		}
		return 0
	}


	proc shotsample_parse {t_shotsample target_array_name} {

		upvar $target_array_name ShotSample

		# Extracted from update_de1_shotvalue in binary.tcl - 2021-02
		# Logic retained from that code at this time

		if {[string length $t_shotsample] < 7} {
			# this should never happen
			msg -ERROR [format "::de1::packet::shotsample_parse:" \
					    "short t_shotsample message: %d < 7" \
					    [string length $t_shotsample]]
			return
		}

		set spec_old {
			SampleTime {Short {} {} {unsigned} {}}
			GroupPressure {char {} {} {unsigned} {$val / 16.0}}
			GroupFlow {char {} {} {unsigned} {$val / 16.0}}
			MixTemp {Short {} {} {unsigned} {$val / 256.0}}
			HeadTemp {Short {} {} {unsigned} {$val / 256.0}}
			SetMixTemp {Short {} {} {unsigned} {$val / 256.0}}
			SetHeadTemp {Short {} {} {unsigned} {$val / 256.0}}
			SetGroupPressure {char {} {} {unsigned} {$val / 16.0}}
			SetGroupFlow {char {} {} {unsigned} {$val / 16.0}}
			FrameNumber {char {} {} {unsigned} {}}
			SteamTemp {Short {} {} {unsigned} {$val / 256.0}}
		}

		# HeadTemp is a 24bit number, which Tcl doesn't have
		# Grab it as 3 chars and manually convert it to a number

		set spec {
			SampleTime {Short {} {} {unsigned} {}}
			GroupPressure {Short {} {} {unsigned} {$val / 4096.0}}
			GroupFlow {Short {} {} {unsigned} {$val / 4096.0}}
			MixTemp {Short {} {} {unsigned} {$val / 256.0}}
			HeadTemp1 {char {} {} {unsigned} {}}
			HeadTemp2 {char {} {} {unsigned} {}}
			HeadTemp3 {char {} {} {unsigned} {}}
			SetMixTemp {Short {} {} {unsigned} {$val / 256.0}}
			SetHeadTemp {Short {} {} {unsigned} {$val / 256.0}}
			SetGroupPressure {char {} {} {unsigned} {$val / 16.0}}
			SetGroupFlow {char {} {} {unsigned} {$val / 16.0}}
			FrameNumber {char {} {} {unsigned} {}}
			SteamTemp {char {} {} {unsigned} {}}
		}

		if {[use_old_ble_spec] == 1} {
			array set specarr $spec_old
			::fields::unpack $t_shotsample $spec_old ShotSample bigeendian
		} else {
			array set specarr $spec
			::fields::unpack $t_shotsample $spec ShotSample bigeendian
		}

		foreach {field val} [array get ShotSample] {
			set specparts $specarr($field)
			set extra [lindex $specparts 4]
			if {$extra != ""} {
				set ShotSample($field) [expr $extra]
			}
		}

		if {[info exists ShotSample(SteamTemp)] != 1} {
			# Logic around ble_spec detection retained from prior code (2021-02):
			# If we get no steam temp then this is the old BLE spec
			# auto-adjust to doing so, but discard this first temperature report
			# as part of this auto-adjusting
			set ::de1::packet::ble_spec 0.9
			return
		}

		# Update logic to have ShotSample(HeadTemp) always be available

		if {[use_old_ble_spec] == 1} {
			# pass
		} else {
			set ShotSample(HeadTemp) [convert_3_char_to_U24P16 \
				$ShotSample(HeadTemp1) \
				$ShotSample(HeadTemp2) \
				$ShotSample(HeadTemp3)]
		}

	} ;# shotsample_parse

} ;# ::de1::packet



###
### ::de1::sav
###

namespace eval ::de1::sav {

	variable _target 0
	variable _is_active_flag False

	proc init {} {

		set ::de1::sav::_is_active_flag False
	}

	# TODO: Unify SAV and SAW tracing_state definitions
	# TODO: Confirm no ill effects and implement for HotWater
	#       See ::de1::state::update::fro_shotvalue

	proc is_tracking_state {{state_text "None"} {substate_text "None"}} {

		if { $state_text == "None" } { set state_text $::de1_num_state($::de1(state)) }

		expr { $state_text in {{Espresso} {HotWater}} }
	}

	proc is_active {} {

		expr {$::de1::sav::_is_active_flag}
	}


	proc start_active {} {

		if { [::de1::sav::is_active] } {
			msg -NOTICE "::de1::sav::start_active: already active"

		} else {
			set ::de1::sav::_is_active_flag True
			msg -DEBUG "::de1::sav::start_active"
		}
	}

	proc stop_active {} {

		if { ! [::de1::sav::is_active] } {
			msg -NOTICE "::de1::sav::stop_active: already not active"

		} else {
			set  ::de1::sav::_is_active_flag False
			msg -DEBUG "::de1::sav::stop_active"
		}
	}

	proc on_espresso_start {args} {

		variable _target

		switch $::settings(settings_profile_type) {
			settings_2c	{ set _target $::settings(final_desired_shot_volume_advanced) }
			default 	{ set _target $::settings(final_desired_shot_volume) }
		}
		# Ensure testable with > 0
		set _target [scan $_target %g]

		if { $_target > 0 } { set ::de1(app_autostop_triggered) False }

		msg -DEBUG "::de1::sav::on_espresso_start"
	}

	proc on_hotwater_start {args} {

		variable _target

		set _target $::settings(water_volume)

		# Ensure testable with > 0
		set _target [scan $_target %g]

		if { $_target > 0 } { set ::de1(app_autostop_triggered) False }

		msg -DEBUG "::de1::sav::on_hotwater_start"
	}

	proc on_major_state_change {event_dict} {

		set this_state [dict get $event_dict this_state]

		switch -exact $this_state {

			Espresso {
				::de1::sav::on_espresso_start
			}

			HotWater {
				::de1::sav::on_hotwater_start
			}

			default {
				return
			}
		}
	}

	::de1::event::listener::on_major_state_change_add -noidle \
		::de1::sav::on_major_state_change


	proc on_flow_change {event_dict} {

		set this_state [dict get $event_dict this_state]

		if { [::de1::sav::is_tracking_state $this_state] } {

			set this_flow  [::de1::state::flow_phase \
						    $this_state \
						    [dict get $event_dict this_substate] ]

			set previous_flow  [::de1::state::flow_phase \
						    [dict get $event_dict previous_state] \
						    [dict get $event_dict previous_substate] ]

			if { $this_flow == "during" && $previous_flow != "during" } {

				::de1::sav::start_active

			} elseif { $this_flow != "during" && $previous_flow == "during" } {

				::de1::sav::stop_active
			}
		}
	}

	::de1::event::listener::on_flow_change_add -noidle \
		::de1::sav::on_flow_change


	# Beta testing revealed challenges with "basic" profiles
	# triggering early due to unrealistically low SAV levels
	# and a cumbersome UX for changing those levels at this time,
	# requiring "deleting" the scale and multiple app restarts.

	# Disabing in-app SAV for basic profiles:
	#   settings_2a -- basic pressure
	#   settings_2b -- basic flow
	# when a scale is expected to be present
	# (should preserve ability to use with HotWater)

	# ::de1::sav::skip_sav_check can be overriden by skins or extensions

	proc skip_sav_check {} {

		expr { $::settings(settings_profile_type) in {{settings_2a} {settings_2b}} \
			       && [::device::scale::expecting_present] }
	}


	proc check_for_sav {} {

		# Previous logic only enabled SAV for "non-advanced" profiles
		# if there was no bluetooth address for the scale configured.
		# It did not check for connectivity or updates from the scale.
		# This was counter to the consistent guidance on Diaspora
		# that the logic is "which ever trips first, SAV or SAW".

		# Use the existing ::de1(app_autostop_triggered) flag

		variable _target

		if {[::de1::sav::is_tracking_state] && $_target > 0 \
			    && ! [::de1::sav::skip_sav_check] \
			    && ! $::de1(app_autostop_triggered) } {

			if { $::de1(pour_volume) >= $_target } {

				start_idle
				set ::de1(app_autostop_triggered) True

				msg -INFO "Volume based stop was triggered at:" \
					"${::de1(pour_volume)} ml for" \
					"${_target} ml target"

				::gui::notify::de1_event sav_stop
			}
		}
	}

	::de1::sav::init

} ;# ::de1::sav

#
# As the DE1 events aren't available when logging is enabled,
# set up a log flush on Sleep here
#

::de1::event::listener::on_major_state_change_add [lambda {event_dict} {
	if { [dict get $event_dict this_state] == "Sleep" } {
		after idle ::logging::flush_log
	}
}]
