package require tcltest
namespace import ::tcltest::*

package provide de1_comms 1.1
package provide de1_device_scale 1.0
package provide de1_logging 1.2
set ::has_bluetooth 0

namespace eval ::logging {
	proc ble_log_enabled {level} {return 0}
	proc format_asc_bin {value} {binary encode hex $value}
	proc format_ble_event_short {data} {return ""}
}

proc ifexists {name {default ""}} {
	upvar 1 $name value
	if {[info exists value]} {return $value}
	return $default
}

proc userdata_append {description command vital} {
	set action [lindex $command 1]
	if {$action eq "write"} {
		lappend ::operations [binary encode hex [lindex $command end]]
	} else {
		lappend ::operations $action
	}
}

proc ble_queue_ack {args} {}

source [file join [file dirname [info script]] .. de1plus bluetooth.tcl]

proc setupScale {} {
	after cancel [ifexists ::de1(decentscale_display_retry)]
	array unset ::de1
	array set ::de1 {
		scale_device_handle ble1
		suuid_decentscale fff0
		cuuid_decentscale_read fff4
		cuuid_decentscale_write 36f5
	}
	foreach key {0D 0E 12 05 11 skale_EF81 skale_EF82 acaia_ips_age acaia_pyxis_status} {
		set ::de1(cuuid_$key) other
	}
	set ::sinstance(fff0) 1
	set ::cinstance(fff4) 2
	set ::cinstance(36f5) 3
	array set ::settings {scale_type decentscale enable_fluid_ounces 0 keep_scale_on 1}
	set ::android 1
	set ::operations {}
}

proc descriptorAck {handle {hex ""} {duuid 00002902-0000-1000-8000-00805F9B34FB}} {
	de1_ble_handler descriptor [dict create handle $handle state connected access w suuid fff0 cuuid fff4 duuid $duuid value [binary decode hex $hex]]
}

test android-scale-waits-for-cccd {} -setup setupScale -body {
	decentscale_send_heartbeat
	after cancel $::decentscale_send_heartbeat_id
	decentscale_start_notifications
	set before $::operations
	descriptorAck ble1
	descriptorAck ble1 0100
	list $before $::operations
} -result {{030a03ffff000a enable} {030a03ffff000a enable 030a0101000108}}

test android-scale-ignores-unrelated-and-disabled-cccd {} -setup setupScale -body {
	decentscale_start_notifications
	descriptorAck ble0 0100
	descriptorAck ble1 0100 00002901-0000-1000-8000-00805F9B34FB
	descriptorAck ble1 0000
	set before $::operations
	descriptorAck ble1 0100
	set ::de1(scale_device_handle) ble2
	decentscale_start_notifications
	descriptorAck ble1 0100
	list $before $::operations
} -result {enable {enable 030a0101000108 enable}}

test android-scale-retains-latest-display-intent {} -setup setupScale -body {
	decentscale_start_notifications
	decentscale_disable_lcd
	set before $::operations
	descriptorAck ble1 0100
	list $before $::operations
} -result {enable {enable 030a0000000009}}

test android-scale-keeps-startup-display-retry {} -setup setupScale -body {
	decentscale_start_notifications
	descriptorAck ble1 0100
	set timer $::de1(decentscale_display_retry)
	set retry [lindex [after info $timer] 0]
	after cancel $timer
	{*}$retry
	set ::operations
} -result {enable 030a0101000108 030a0101000108}

test android-power-off-supersedes-pending-display {} -setup setupScale -body {
	set ::settings(keep_scale_on) 0
	decentscale_start_notifications
	decentscale_disable_lcd
	descriptorAck ble1 0100
	set ::operations
} -result {enable 030a020000000b}

test non-android-display-unchanged {} -setup setupScale -body {
	set ::android 0
	decentscale_enable_lcd
	set ::operations
} -result 030a0101000108

proc is_bengle_model {} {return 0}
proc ble {command args} {
	lappend ::nativeCalls [list $command {*}$args]
	if {$command eq "stop" && $::failStop} {error "stop failed"}
	if {$command eq "connect"} {return ble1}
}

proc setupScan {} {
	setupScale
	set ::de1(scale_device_handle) 0
	set ::de1(device_handle) 0
	set ::de1(cmdstack) {blocked machine work}
	set ::settings(scale_bluetooth_address) AA:BB:CC:DD:EE:FF
	set ::currently_connecting_scale_handle 0
	set ::ble_scanner scanner1
	set ::scanning 1
	set ::scale_scan_handoff {}
	set ::nativeCalls {}
	set ::failStop 0
}

test android-scale-connect-waits-for-current-scan-stop {} -setup setupScan -body {
	ble_connect_to_scale
	ble_connect_to_scale
	de1_ble_handler connection {handle old-scanner state idle}
	set before [list $::nativeCalls $::scanning]
	de1_ble_handler connection {handle scanner1 state idle}
	de1_ble_handler connection {handle scanner1 state idle}
	set settling [list $::nativeCalls $::scanning]
	after 325 {set ::scanSettled 1}
	vwait ::scanSettled
	list $before $settling $::nativeCalls
} -result {{{{stop scanner1}} 1} {{{stop scanner1}} 0} {{stop scanner1} {connect AA:BB:CC:DD:EE:FF de1_ble_handler false}}}

test android-scale-does-not-connect-if-scan-stop-fails {} -setup setupScan -body {
	set ::failStop 1
	ble_connect_to_scale
	list $::nativeCalls $::scale_scan_handoff $::scanning
} -result {{{stop scanner1}} {} 1}

cleanupTests
