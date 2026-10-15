package require tcltest
namespace import ::tcltest::*

foreach {package version} {
	lambda 1.0
	de1_event 1.0
	de1_logging 1.2
	de1_gui 1.3
	de1_bluetooth 1.0
	de1_profile 2.0
} {
	package provide $package $version
}

namespace eval ::event::listener {
	proc _init_callback_list {args} {}
	proc _generic_add {args} {}
}

namespace eval ::event::apply {
	proc _generic {callbacks args} {
		if {$callbacks eq "::device::scale::event::listener::_on_disconnect_lists"} {
			::device::scale::callbacks::on_disconnect {*}$args
		}
	}
}

namespace eval ::gui::notify {
	proc scale_event {event args} {
		lappend ::scale_events $event
	}
}

namespace eval ::bt {
	proc msg {args} {}
}

proc msg {args} {}
proc lambda {arguments body} { list apply [list $arguments $body] }
proc ifexists {name {default ""}} {
	upvar 1 $name value
	if {[info exists value]} { return $value }
	return $default
}
set ::test_app_dir [file normalize [file join [file dirname [info script]] .. de1plus]]
proc homedir {} { return $::test_app_dir }
proc scale_enable_weight_notifications {} {}
proc ble {command handle} {
	if {$command eq "close" && $handle != 0} {
		lappend ::closed_handles $handle
	}
}
proc ble_connect_to_scale {} {
	incr ::reconnects
	set ::currently_connecting_scale_handle ble2
}

source [file join $::test_app_dir de1_de1.tcl]
source [file join $::test_app_dir device_scale.tcl]
source [file join $::test_app_dir de1_comms.tcl]
source [file join $::test_app_dir binary.tcl]

rename ::device::scale::process_weight_update ::device::scale::process_weight_update_real
proc ::device::scale::process_weight_update {weight {event_time 0}} {
	lappend ::processed_weights [list $weight $event_time]
}

rename after tcl_after
proc after {args} {
	if {[lindex $args 0] eq "cancel"} {
		lappend ::cancelled [lindex $args 1]
		return
	}
	lappend ::scheduled [lrange $args 1 end]
	return watchdog-next
}

proc reset_watchdog {handle} {
	set ::de1(scale_device_handle) $handle
	set ::device::scale::_watchdog_id watchdog-current
	set ::device::scale::_watchdog_updates_seen False
	set ::device::scale::_handled_disconnect_handle ""
	set ::closed_handles {}
	set ::cancelled {}
	set ::scale_events {}
	set ::reconnects 0
	set ::blink_water_weight 1
	set ::currently_connecting_scale_handle 0
	set ::de1(bluetooth_scale_connection_attempts_tried) 0
	set ::de1(scale_max_connection_retry_attempts) 10
	set ::processed_weights {}
	set ::scheduled {}
	set ::de1(ble_protocol_version) 1
	set ::de1(scale_connectivity) ble
	set ::settings(scale_type) decentscale
	set ::settings(scale_bluetooth_address) scale-address
	set ::settings(usb_scale_address) serial-port
}

test scale-watchdog-exhaustion-1 {} -body {
	reset_watchdog ble1
	::device::scale::_watchdog_first_fire ble1 10
	list $::closed_handles $::reconnects $::de1(scale_device_handle) $::currently_connecting_scale_handle
} -result {ble1 1 0 ble2}

test scale-watchdog-stale-handle-1 {} -body {
	reset_watchdog ble2
	::device::scale::_watchdog_first_fire ble1 10
	list $::closed_handles $::reconnects $::de1(scale_device_handle)
} -result {{} 0 ble2}

test scale-disconnect-late-callback-1 {} -body {
	reset_watchdog ble1
	::device::scale::_watchdog_first_fire ble1 10
	scale_disconnect_handler ble1
	list $::closed_handles $::reconnects $::currently_connecting_scale_handle
} -result {ble1 1 ble2}

test scale-disconnect-late-connected-callback-1 {} -body {
	reset_watchdog ble1
	::device::scale::_watchdog_first_fire ble1 10
	set ::de1(scale_device_handle) ble2
	set ::currently_connecting_scale_handle 0
	scale_disconnect_handler ble1
	list $::closed_handles $::reconnects $::de1(scale_device_handle)
} -result {ble1 1 ble2}

test scale-disconnect-stale-active-handle-1 {} -body {
	reset_watchdog ble2
	scale_disconnect_handler ble1
	list $::closed_handles $::reconnects $::de1(scale_device_handle)
} -result {{} 0 ble2}

test scale-disconnect-stale-connecting-handle-1 {} -body {
	reset_watchdog 0
	set ::currently_connecting_scale_handle ble2
	scale_disconnect_handler ble1
	list $::closed_handles $::reconnects $::currently_connecting_scale_handle
} -result {{} 0 ble2}

test scale-cached-weight-1 {} -body {
	reset_watchdog ble1
	set accepted [::device::scale::process_decentscale_weight_update ble1 0xCA 1.2 3.4]
	list $accepted $::processed_weights $::device::scale::_watchdog_updates_seen
} -result {True {{1.2 3.4}} False}

test scale-stale-live-weight-1 {} -body {
	reset_watchdog ble1
	set accepted [::device::scale::process_decentscale_weight_update ble2 0xCE 1.2 3.4]
	list $accepted $::processed_weights $::device::scale::_watchdog_updates_seen
} -result {False {} False}

test scale-first-live-weight-1 {} -body {
	reset_watchdog ble1
	set accepted [::device::scale::process_decentscale_weight_update ble1 0xCE 1.2 3.4]
	list $accepted $::processed_weights $::device::scale::_watchdog_updates_seen $::blink_water_weight $::scale_events $::cancelled
} -result {True {{1.2 3.4}} True 0 scale_reporting watchdog-current}

test scale-disconnect-clears-reporting-once-1 {} -body {
	reset_watchdog ble1
	set ::device::scale::_watchdog_updates_seen True
	scale_disconnect_handler ble1
	scale_disconnect_handler ble1
	list $::device::scale::_watchdog_updates_seen $::scale_events $::cancelled
} -result {False not_connected watchdog-current}

rename ::device::scale::process_weight_update {}
rename ::device::scale::process_weight_update_real ::device::scale::process_weight_update

proc round_to_two_digits {value} { expr {round($value * 100) / 100.0} }
proc round_to_one_digits {value} { expr {round($value * 10) / 10.0} }
proc start_idle {} { incr ::idle_requests }
proc espresso_timer {} { return 10 }
proc water_pour_timer {} { return 10 }
proc number_of_preinfusion_steps {} { return 0 }
namespace eval ::gui::state {
	proc current_framenumber {} { return 0 }
}

proc reset_pipeline {handle scale_type {protocol 1}} {
	reset_watchdog $handle
	set ::settings(scale_type) $scale_type
	set ::de1(ble_protocol_version) $protocol
	set ::settings(scale_stop_at_half_shot) 0
	set ::settings(advanced_shot) {{name test weight 0}}
	set ::de1_num_state(0) Idle
	set ::de1_num_state(1) Espresso
	set ::de1_num_state(2) HotWater
	set ::de1_substate_types(0) ready
	set ::de1_substate_types(1) pouring
	set ::de1(state) 0
	set ::de1(substate) 0
	set ::de1(current_frame_number) 0
	set ::de1(volume) 0
	set ::de1(preinfusion_volume) 0
	set ::de1(pour_volume) 0
	set ::de1(app_autostop_triggered) False
	set ::de1(app_stepskip_triggered) False
	set ::device::scale::_last_weight_update_time 0
	set ::device::scale::history::_is_recording_flag False
	set ::device::scale::_tare_awaiting_zero False
	set ::idle_requests 0
	::device::scale::init
}

foreach scale_type {
	atomaxskale acaiascale acaiapyxis felicita bookoo atomheart_eclair
	hiroiajimmy eureka_precisa solo_barista smartchef difluid varia_aku timemore_dot
} {
	test scale-shared-pipeline-$scale_type-1 {} -body {
		reset_pipeline ble1 $scale_type
		::device::scale::process_weight_update 12.3 100
		list [::device::scale::is_operational] $::device::scale::_last_weight_update_time \
			$::de1(scale_sensor_weight) $::scale_events $::blink_water_weight
	} -result {1 100 12.3 scale_reporting 0}
}

test scale-bengle-operational-without-ble-1 {} -body {
	reset_pipeline 0 decentscale 2
	list [::device::scale::is_connected] [::device::scale::is_operational]
} -result {1 1}

foreach scale_type {{} decentscale bookoo} {
	test scale-bengle-shotsample-$scale_type-1 {} -body {
		reset_pipeline 0 $scale_type 2
		array set shot {
			GroupPressure 0 GroupFlow 0 MixTemp 90 HeadTemp 90 SetHeadTemp 90
			SetGroupPressure 0 SetGroupFlow 0 SteamTemp 150 FrameNumber 0
			SampleTime 100 Weight 12.5 GFlow 1.5
		}
		::de1::state::update::_apply_shotvalue shot 100
		list [::device::scale::is_operational] $::device::scale::_watchdog_updates_seen \
			$::de1(scale_sensor_weight) $::de1(scale_weight_rate) $::scale_events
	} -result {1 True 12.5 1.5 scale_reporting}
}

test scale-bengle-external-scale-still-needs-live-packet-1 {} -body {
	reset_pipeline ble1 decentscale 2
	set before [::device::scale::is_operational]
	::device::scale::process_decentscale_weight_update ble1 0xCA 12.3 100
	set cached [::device::scale::is_operational]
	::device::scale::process_decentscale_weight_update ble1 0xCE 12.3 101
	list $before $cached [::device::scale::is_operational]
} -result {0 0 1}

test scale-bengle-no-ble-recovery-1 {} -body {
	reset_pipeline 0 decentscale 2
	set ::device::scale::_watchdog_id ""
	::device::scale::watchdog_first
	::device::scale::_watchdog_first_fire 0 10
	list $::scheduled $::closed_handles $::reconnects
} -result {{} {} 0}

test scale-usb-live-packet-1 {} -body {
	reset_pipeline serial1 decentscale
	set ::de1(scale_connectivity) usb
	set ::de1_usb_scale::buf ""
	de1_usb_scale_bytes_received [de1_usb_scale_cmd {0xCE 0x00 0x7B 0x00 0x00}]
	list [::device::scale::is_operational] $::de1(scale_sensor_weight) $::scale_events
} -result {1 12.3 scale_reporting}

test scale-bengle-hotwater-readiness-1 {} -body {
	reset_pipeline 0 decentscale 2
	set ::settings(water_volume) 36
	set ::settings(water_stop_on_scale) 1
	::device::scale::saw::on_hotwater_start
	::de1::sav::on_hotwater_start
	list $::device::scale::saw::_target $::de1::sav::_target
} -result {36.0 250.0}

test scale-unready-hotwater-volume-fallback-1 {} -body {
	reset_pipeline ble1 decentscale
	set ::settings(water_volume) 36
	set ::settings(water_stop_on_scale) 1
	::device::scale::saw::on_hotwater_start
	::de1::sav::on_hotwater_start
	list $::device::scale::saw::_target $::de1::sav::_target
} -result {0.0 36.0}

test scale-bengle-stop-at-weight-1 {} -body {
	reset_pipeline 0 decentscale 2
	set ::de1(state) 1
	set ::de1(substate) 1
	set ::device::scale::saw::_target 36
	set ::device::scale::saw::_early_by_grams 0
	set ::device::scale::saw::_early_by_flow 0
	set ::device::scale::saw::_ignore_first_seconds 5
	set ::device::scale::saw::_mode_timer espresso_timer
	::device::scale::process_weight_update 37 100
	::device::scale::saw::check_for_saw
	list $::idle_requests $::de1(app_autostop_triggered)
} -result {1 True}

test scale-usb-watchdog-reconnect-1 {} -setup {
	rename de1_usb_scale_connect de1_usb_scale_connect_real
	proc de1_usb_scale_connect {device} {
		lappend ::usb_connections $device
		set ::de1(scale_device_handle) serial2
	}
	proc usb {command handle} {
		if {$command ne "close"} { error "Unexpected USB operation: $command" }
		lappend ::usb_closed $handle
	}
	proc ::comms::msg {args} {}
} -body {
	reset_pipeline serial1 decentscale
	set ::de1(scale_connectivity) usb
	set ::usb_connections {}
	set ::usb_closed {}
	::device::scale::_watchdog_first_fire serial1 10
	scale_disconnect_handler serial1
	list $::usb_closed $::usb_connections $::reconnects $::de1(scale_device_handle) $::scale_events
} -cleanup {
	rename de1_usb_scale_connect {}
	rename de1_usb_scale_connect_real de1_usb_scale_connect
	rename usb {}
} -result {serial1 serial-port 0 serial2 {abandoning_updates not_connected}}

proc load_tested_procs {path names} {
	set channel [open $path r]
	try { set lines [split [read $channel] \n] } finally { close $channel }
	set script ""
	foreach line $lines {
		if {$script eq "" && (![regexp {^proc ([^ ]+) } $line -> name] || $name ni $names)} { continue }
		append script $line \n
		if {[info complete $script]} {
			uplevel #0 $script
			set script ""
		}
	}
}

load_tested_procs [file join $::test_app_dir skins Streamline skin.tcl] {streamline_ui_weight_refresh}
load_tested_procs [file join $::test_app_dir vars.tcl] {waterweight_label_text}
load_tested_procs [file join $::test_app_dir machine.tcl] {start_espresso}
proc translate {text} { return $text }
proc return_weight_measurement_grams {weight args} { list $weight g }
proc info_page {args} { incr ::blocked_starts }
proc de1_send_state {args} { incr ::espresso_starts }
proc ghc_required {} { return 0 }
proc espresso_simulation_active {} { return 0 }

test scale-bengle-weight-ui-1 {} -body {
	reset_pipeline 0 decentscale 2
	set ::de1(language_rtl) 0
	set ::de1(scale_sensor_weight) 12.5
	streamline_ui_weight_refresh
	list $::streamline_dataline_weight_label_blue $::streamline_dataline_weight_value \
		[waterweight_label_text]
} -result {Weight 12.5 Weight}

foreach {protocol expected} {1 {0 1} 2 {1 0}} {
	test scale-required-espresso-start-$protocol-1 {} -body {
		reset_pipeline 0 decentscale $protocol
		set ::settings(start_espresso_only_if_scale_connected) 1
		set ::settings(go_idle_before_all_operations) 0
		set ::de1_state(Espresso) 1
		set ::espresso_starts 0
		set ::blocked_starts 0
		start_espresso
		list $::espresso_starts $::blocked_starts
	} -result $expected
}

set failed $::tcltest::numTests(Failed)
cleanupTests
exit [expr {$failed > 0}]
