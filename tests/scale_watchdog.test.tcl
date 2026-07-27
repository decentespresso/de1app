package require tcltest
namespace import ::tcltest::*

foreach {package version} {
	de1_de1 1.1
	de1_event 1.0
	de1_logging 1.2
	de1_gui 1.3
	de1_bluetooth 1.0
} {
	package provide $package $version
}

namespace eval ::de1::event::listener {
	proc on_major_state_change_add {args} {}
	proc after_flow_complete_add {args} {}
	proc on_flow_change_add {args} {}
}

namespace eval ::event::listener {
	proc _init_callback_list {args} {}
	proc _generic_add {args} {}
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

source [file join [file dirname [info script]] .. de1plus device_scale.tcl]
source [file join [file dirname [info script]] .. de1plus de1_comms.tcl]

rename after tcl_after
proc after {args} {
	if {[lindex $args 0] eq "cancel"} {
		lappend ::cancelled [lindex $args 1]
		return
	}
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
	::device::scale::watchdog_tickle ble1 0xCA
	list $::device::scale::_watchdog_updates_seen $::cancelled
} -result {False {}}

test scale-stale-live-weight-1 {} -body {
	reset_watchdog ble1
	::device::scale::watchdog_tickle ble2 0xCE
	list $::device::scale::_watchdog_updates_seen $::cancelled
} -result {False {}}

test scale-first-live-weight-1 {} -body {
	reset_watchdog ble1
	::device::scale::watchdog_tickle ble1 0xCE
	list $::device::scale::_watchdog_updates_seen $::blink_water_weight $::scale_events $::cancelled
} -result {True 0 scale_reporting watchdog-current}

cleanupTests
