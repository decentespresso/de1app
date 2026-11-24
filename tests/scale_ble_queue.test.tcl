package require tcltest
namespace import ::tcltest::*

namespace eval ::logging {
	proc ble_log_enabled {level} {return 0}
	proc format_asc_bin {value} {binary encode hex $value}
}

proc ifexists {name {default ""}} {
	upvar 1 $name value
	if {[info exists value]} {return $value}
	return $default
}

proc ble {action handle service serviceInstance characteristic args} {
	lappend ::issued [list $action $handle $characteristic]
	if {$action eq "write"} {
		lappend ::packets [list $handle [binary encode hex [lindex $args end]]]
	}
	return 1
}

proc scale_disconnect_handler {handle} {
	lappend ::disconnected $handle
	::comms::discard_scale_ble_queue $handle
}

set file [open [file join [file dirname [info script]] .. de1plus de1_comms.tcl]]
try {set sourceText [read $file]} finally {close $file}
set script ""
foreach line [split $sourceText \n] {
	append script $line \n
	if {![info complete $script]} {continue}
	if {[regexp {^(namespace eval ::comms|proc (::comms::\S+|userdata_append|run_next_userdata_cmd|ble_queue_ack) )} [string trimleft $script]]} {
		uplevel #0 $script
	}
	set script ""
}

proc resetQueues {} {
	if {[llength [info commands ::comms::discard_scale_ble_queue]]} {
		::comms::discard_scale_ble_queue $::comms::scale_ble_handle
	}
	foreach id [after info] {after cancel $id}
	array unset ::de1
	array set ::de1 {device_handle ble0 scale_device_handle ble1 wrote 1 cmdstack {}}
	array set ::settings {scale_type decentscale comms_debugging 0}
	set ::currently_connecting_de1_handle 0
	set ::has_bluetooth 1
	set ::android 1
	set ::issued {}
	set ::packets {}
	set ::disconnected {}
	set ::acknowledged {}
	set ::canSubscribe 1
}

proc writeTo {handle {characteristic 36f5}} {
	return [list ble write $handle fff0 1 $characteristic 2 packet]
}

test scale-ble-dispatch-is-independent-of-machine {} -setup resetQueues -body {
	userdata_append machine [writeTo ble0]
	userdata_append heartbeat [writeTo ble1]
	list $::issued $::de1(wrote) [lindex $::de1(cmdstack) 0 0]
} -cleanup resetQueues -result {{{write ble1 36f5}} 1 machine}

test scale-ble-old-ack-does-not-release-new-lane {} -setup resetQueues -body {
	userdata_append old-in-flight [writeTo ble1]
	userdata_append old-queued [writeTo ble1]
	::comms::discard_scale_ble_queue ble1
	set ::de1(scale_device_handle) ble2
	userdata_append replacement [writeTo ble2]
	userdata_append following [writeTo ble2]
	ble_queue_ack ble1 characteristic w 36f5
	ble_queue_ack ble2 characteristic c 36f5
	ble_queue_ack ble2 characteristic w fff4
	set before $::issued
	ble_queue_ack ble2 characteristic w 36f5
	list $before $::issued $::de1(wrote)
} -cleanup resetQueues -result {{{write ble1 36f5} {write ble2 36f5}} {{write ble1 36f5} {write ble2 36f5} {write ble2 36f5}} 1}

test scale-ble-cccd-cannot-be-released-by-other-descriptor {} -setup resetQueues -body {
	userdata_append subscribe {ble enable ble1 fff0 1 fff4 2} 1
	userdata_append status [writeTo ble1]
	ble_queue_ack ble1 descriptor w fff4 2901
	set before $::issued
	ble_queue_ack ble1 descriptor w fff4 00002902-0000-1000-8000-00805F9B34FB
	list $before $::issued
} -cleanup resetQueues -result {{{enable ble1 fff4}} {{enable ble1 fff4} {write ble1 36f5}}}

test scale-ble-completion-waits-for-matching-dispatched-cccd {} -setup resetQueues -body {
	userdata_append heartbeat [writeTo ble1]
	userdata_append resubscribe {ble enable ble1 fff0 1 fff4 2} 1 {} {lappend ::acknowledged resubscribed}
	ble_queue_ack ble1 descriptor w fff4 2902
	set before [list $::issued $::acknowledged]
	ble_queue_ack ble1 characteristic w 36f5
	ble_queue_ack ble0 descriptor w fff4 2902
	ble_queue_ack ble1 descriptor w fff4 2901
	set during [list $::issued $::acknowledged]
	ble_queue_ack ble1 descriptor w FFF4 00002902-0000-1000-8000-00805F9B34FB
	ble_queue_ack ble1 descriptor w fff4 2902
	list $before $during $::acknowledged
} -cleanup resetQueues -result {{{{write ble1 36f5}} {}} {{{write ble1 36f5} {enable ble1 fff4}} {}} resubscribed}

test scale-ble-completion-drops-stale-undispatched-resubscribe {} -setup resetQueues -body {
	userdata_append heartbeat [writeTo ble1]
	userdata_append resubscribe {ble enable ble1 fff0 1 fff4 2} 1 {expr {$::canSubscribe}} {lappend ::acknowledged stale}
	set ::canSubscribe 0
	ble_queue_ack ble1 characteristic w 36f5
	ble_queue_ack ble1 descriptor w fff4 2902
	list $::issued $::acknowledged
} -cleanup resetQueues -result {{{write ble1 36f5}} {}}

test scale-ble-completion-discards-in-flight-owner-on-replacement {} -setup resetQueues -body {
	userdata_append old {ble enable ble1 fff0 1 fff4 2} 1 {} {lappend ::acknowledged old}
	::comms::discard_scale_ble_queue ble1
	set ::de1(scale_device_handle) ble2
	userdata_append new {ble enable ble2 fff0 1 fff4 2} 1 {} {lappend ::acknowledged new}
	ble_queue_ack ble1 descriptor w fff4 2902
	ble_queue_ack ble2 descriptor w fff4 2902
	list $::issued $::acknowledged
} -cleanup resetQueues -result {{{enable ble1 fff4} {enable ble2 fff4}} new}

test scale-ble-unowned-machine-ack-does-not-unblock {} -setup resetQueues -body {
	userdata_append machine [writeTo ble0]
	ble_queue_ack unknown characteristic w 36f5
	set before $::issued
	ble_queue_ack ble0 characteristic c state
	list $before $::issued
} -cleanup resetQueues -result {{} {{write ble0 36f5}}}

test scale-ble-obsolete-guarded-write-is-not-dispatched {} -setup resetQueues -body {
	userdata_append first [writeTo ble1]
	userdata_append stale [writeTo ble1] 0 {expr {0}}
	userdata_append following [writeTo ble1 fff4]
	ble_queue_ack ble1 characteristic w 36f5
	list $::issued $::de1(wrote)
} -cleanup resetQueues -result {{{write ble1 36f5} {write ble1 fff4}} 1}

test scale-ble-timeout-retires-only-its-own-attempt {} -setup resetQueues -body {
	userdata_append old [writeTo ble1]
	set old [lindex $::comms::scale_ble_pending 0]
	::comms::discard_scale_ble_queue ble1
	set ::de1(scale_device_handle) ble2
	userdata_append replacement [writeTo ble2]
	userdata_append following [writeTo ble2]
	::comms::scale_ble_ack_timeout ble1 $old
	set before $::disconnected
	::comms::scale_ble_ack_timeout ble2 [lindex $::comms::scale_ble_pending 0]
	list $before $::disconnected $::issued $::de1(wrote)
} -cleanup resetQueues -result {{} ble2 {{write ble1 36f5} {write ble2 36f5}} 1}

test scale-ble-other-platform-retains-shared-queue {} -setup resetQueues -body {
	set ::android 0
	userdata_append heartbeat [writeTo ble1]
	list $::issued [lindex $::de1(cmdstack) 0 0]
} -cleanup resetQueues -result {{} heartbeat}

package provide de1_comms 1.1
package provide de1_event 1.0
package provide de1_gui 1.3
package provide de1_logging 1.2
package provide lambda 1.0
namespace eval ::event::listener {
	proc _init_callback_list {args} {}
	proc _generic_add {args} {}
}
namespace eval ::gui::notify {
	proc scale_event {event args} {lappend ::scaleEvents $event}
}
proc lambda {arguments body} {list apply [list $arguments $body]}
proc msg {args} {}
set appDir [file join [file dirname [info script]] .. de1plus]
source [file join $appDir de1_de1.tcl]
source [file join $appDir device_scale.tcl]
set ::has_bluetooth 0
source [file join $appDir bluetooth.tcl]

proc ::device::scale::process_weight_update {weight eventTime} {}

proc setupHdsQueue {} {
	resetQueues
	set ::de1(suuid_decentscale) fff0
	set ::de1(cuuid_decentscale_read) fff4
	set ::de1(cuuid_decentscale_write) 36f5
	foreach key {05 10 11 decentscale_writeback} {set ::de1(cuuid_$key) other}
	set ::sinstance(fff0) 1
	set ::cinstance(fff4) 1
	set ::cinstance(36f5) 2
	array set ::settings {scale_bluetooth_address A1 keep_scale_on 1 enable_fluid_ounces 0}
	::hds_sleep::connected ble1 A1
	::hds_sleep::subscribed ble1
	hdsQueueFrame ble1 030a0000640310
	hdsQueueAck ble1 03220000000021
	hdsQueueFrame ble1 03220025000004
}

proc hdsQueueAck {handle hex} {
	de1_ble_handler characteristic [dict create handle $handle state connected access w cuuid 36f5 value [binary decode hex $hex]]
}

proc hdsQueueFrame {handle hex} {
	::hds_sleep::notification $handle [binary decode hex $hex]
}

proc hdsQueueHeartbeat {} {
	decentscale_send_heartbeat
	after cancel $::decentscale_send_heartbeat_id
}

proc hdsQueueTimeout {} {
	lindex [after info $::hds_sleep::timer] 0
}

test scale-ble-softsleep-wake-waits-for-dispatch-and-bounds-reconnect {} -setup setupHdsQueue -body {
	set heartbeat 030a03ffff000a
	set exit 030a040000000d
	set status 030a0101000108
	::hds_sleep::setIntent 1
	hdsQueueAck ble1 030a040100000c
	hdsQueueHeartbeat
	::hds_sleep::setIntent 0
	set blockedExit [list $::hds_sleep::phase $::hds_sleep::timer [lindex $::packets end]]
	hdsQueueAck ble1 $heartbeat
	set exitTimer [hdsQueueTimeout]
	hdsQueueHeartbeat
	hdsQueueAck ble1 $exit
	set blockedStatus [list $::hds_sleep::phase $::hds_sleep::timer [lindex $::packets end]]
	{*}$exitTimer
	hdsQueueAck ble1 $heartbeat
	set writeTimer [hdsQueueTimeout]
	hdsQueueFrame ble1 $heartbeat
	set echo [list $::hds_sleep::phase [::hds_sleep::isQuiet ble1] [expr {[hdsQueueTimeout] eq $writeTimer}]]
	hdsQueueAck ble1 $status
	{*}$writeTimer
	set response [list $::hds_sleep::phase [expr {[hdsQueueTimeout] ne $writeTimer}] $::disconnected]
	{*}[hdsQueueTimeout]
	{*}[hdsQueueTimeout]
	hdsQueueAck ble1 $exit
	hdsQueueAck ble1 $status
	{*}[hdsQueueTimeout]
	set ::de1(scale_device_handle) ble2
	::hds_sleep::connected ble2 A1
	::hds_sleep::subscribed ble2
	for {set attempt 1} {$attempt <= 2} {incr attempt} {
		hdsQueueAck ble2 $exit
		hdsQueueAck ble2 $status
		{*}[hdsQueueTimeout]
		if {$attempt == 1} {{*}[hdsQueueTimeout]}
	}
	set exitedLinks [lmap packet $::packets {
		if {[lindex $packet 1] ne $exit} {continue}
		lindex $packet 0
	}]
	list $blockedExit $blockedStatus $echo $response $exitedLinks $::disconnected $::hds_sleep::phase [::hds_sleep::isQuiet ble2]
} -cleanup {
	::hds_sleep::connected 0 ""
	resetQueues
} -result {{exitQueued {} {ble1 030a03ffff000a}} {statusQueued {} {ble1 030a03ffff000a}} {statusAck 1 1} {statusFrame 1 {}} {ble1 ble1 ble2 ble2} ble1 unconfirmed 1}

test scale-ble-softsleep-queued-entry-pauses-readiness-and-can-be-canceled {} -setup setupHdsQueue -body {
	set ::de1(decentscale_notification_handle) ble1
	set ::scaleEvents {}
	::device::scale::process_decentscale_weight_update ble1 0xCE 12.3 100
	set before [::device::scale::is_operational]
	set id $::device::scale::_watchdog_id
	set watchdog [lindex [after info $id] 0]
	after cancel $id
	hdsQueueHeartbeat
	scale_sleep_display
	set queued [list $::hds_sleep::phase [::device::scale::is_operational] $::hds_sleep::exitRequired]
	{*}$watchdog
	set ignored [::device::scale::process_decentscale_weight_update ble1 0xCE 12.4 101]
	scale_wake_display
	hdsQueueAck ble1 030a03ffff000a
	set beforeWeight [::device::scale::is_operational]
	::device::scale::process_decentscale_weight_update ble1 0xCE 12.5 102
	list $before $queued $ignored $beforeWeight [::device::scale::is_operational] $::scaleEvents $::packets
} -cleanup {
	::device::scale::_watchdog_cancel
	::hds_sleep::connected 0 ""
	resetQueues
} -result {1 {enterQueued 0 0} False 0 1 {scale_reporting scale_reporting} {{ble1 03220000000021} {ble1 030a03ffff000a} {ble1 030a0101000108}}}

cleanupTests
