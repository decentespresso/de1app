package require tcltest
namespace import ::tcltest::*

namespace eval ::logging {
	proc ble_log_enabled {level} {return 0}
}

proc ifexists {name {default ""}} {
	upvar 1 $name value
	if {[info exists value]} {return $value}
	return $default
}

proc ble {action handle service serviceInstance characteristic args} {
	lappend ::issued [list $action $handle $characteristic]
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
	set ::disconnected {}
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

cleanupTests
