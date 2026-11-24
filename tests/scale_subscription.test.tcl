package require tcltest
namespace import ::tcltest::*

package provide de1_bluetooth 1.1
package provide de1_device_scale 1.0
package provide de1_logging 1.2
package provide lambda 1.0
set ::has_bluetooth 0
set ::appDir [file normalize [file join [file dirname [info script]] .. de1plus]]
proc homedir {} {return $::appDir}
source [file join $::appDir de1_comms.tcl]

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

proc userdata_append {description command vital args} {
	set action [lindex $command 1]
	if {$action eq "write"} {
		lappend ::operations [binary encode hex [lindex $command end]]
	} else {
		lappend ::operations $action
	}
}

proc ble_queue_ack {handle args} {lappend ::ackHandles $handle}

source [file join $::appDir bluetooth.tcl]

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
	set ::ackHandles {}
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

test android-scale-releases-display-on-short-cccd {} -setup setupScale -body {
	decentscale_start_notifications
	descriptorAck ble1 0100 2902
	list $::operations $::ackHandles
} -result {{enable 030a0101000108} ble1}

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
	if {$command eq "connect"} {
		lassign $args address callback autoconnect
		lappend ::nativeCalls [list $command $address $autoconnect]
		set handle ble[incr ::nextHandle]
		dict set ::nativeCallbacks $handle $callback
		return $handle
	}
	lappend ::nativeCalls [list $command {*}$args]
	if {$command eq "stop" && $::failStop} {error "stop failed"}
	if {$command eq "info"} {return [dict create state $::nativeScanState]}
	if {$command eq "scanner"} {return scanner2}
}

proc setupScan {} {
	after cancel [ifexists ::scale_scan_timeout]
	clear_scale_connect_attempt
	setupScale
	array set ::de1 {scale_device_handle 0 device_handle 0 cmdstack {blocked machine work}
		bluetooth_scale_connection_attempts_tried 0 scale_max_connection_retry_attempts 10
		scale_connectivity ble wrote 1}
	array set ::settings {bluetooth_address {} scale_bluetooth_address AA:BB:CC:DD:EE:FF
		scale_bluetooth_name {Decent Scale}}
	set ::currently_connecting_de1_handle 0
	set ::peripheral_device_list {}
	set ::ble_scanner scanner1
	set ::scanning 1
	set ::scale_scan_handoff {}
	set ::nativeCalls {}
	set ::nativeCallbacks {}
	set ::nextHandle 0
	set ::failStop 0
	set ::nativeScanState scanning
	set ::has_bluetooth 0
}

proc runScanTimeout {} {
	set callback [lindex [after info $::scale_scan_timeout] 0]
	after cancel $::scale_scan_timeout
	{*}$callback
}

proc scanSettle {} {
	after 325 {set ::scanSettled 1}
	vwait ::scanSettled
}

test android-scale-connect-waits-for-current-scan-stop {} -setup setupScan -body {
	ble_connect_to_scale
	ble_connect_to_scale
	de1_ble_handler connection {handle old-scanner state idle}
	set before [list $::nativeCalls $::scanning]
	de1_ble_handler connection {handle scanner1 state idle}
	de1_ble_handler connection {handle scanner1 state idle}
	set settling [list $::nativeCalls $::scanning]
	scanSettle
	list $before $settling $::nativeCalls
} -result {{{{stop scanner1}} 1} {{{stop scanner1}} 0} {{stop scanner1} {connect AA:BB:CC:DD:EE:FF false}}}

test android-scale-retries-stop-and-accepts-late-idle {} -setup setupScan -body {
	set ::failStop 1
	ble_connect_to_scale
	set afterFailure [list $::nativeCalls [lrange $::scale_scan_handoff 2 end]]
	set ::failStop 0
	runScanTimeout
	de1_ble_handler connection {handle scanner1 state idle}
	scanSettle
	list $afterFailure $::nativeCalls
} -result {{{{stop scanner1}} {stopping 1}} {{stop scanner1} {info scanner1} {stop scanner1} {connect AA:BB:CC:DD:EE:FF false}}}

test android-scale-reconciles-missing-idle-with-native-state {} -setup setupScan -body {
	ble_connect_to_scale
	set ::nativeScanState idle
	runScanTimeout
	scanSettle
	list $::nativeCalls $::scanning
} -result {{{stop scanner1} {info scanner1} {connect AA:BB:CC:DD:EE:FF false}} 0}

test android-scale-stop-retries-are-bounded-but-accept-late-idle {} -setup setupScan -body {
	ble_connect_to_scale
	runScanTimeout
	runScanTimeout
	set stalled [list [lindex $::scale_scan_handoff 2] $::scanning $::nativeCalls]
	de1_ble_handler connection {handle scanner1 state idle}
	scanSettle
	list $stalled [lindex $::nativeCalls end]
} -result {{stalled 1 {{stop scanner1} {info scanner1} {stop scanner1} {info scanner1}}} {connect AA:BB:CC:DD:EE:FF false}}

proc android_scan_permission_missing {} {return {}}

test android-search-retires-stalled-scanner-and-waits-for-new-idle {} -setup setupScan -body {
	ble_connect_to_scale
	runScanTimeout
	runScanTimeout
	set ::has_bluetooth 1
	scanning_restart
	ble_connect_to_scale
	de1_ble_handler connection {handle scanner1 state idle}
	set before [lrange $::nativeCalls 4 end]
	de1_ble_handler connection {handle scanner2 state idle}
	scanSettle
	list $before $::ble_scanner [lindex $::nativeCalls end]
} -result {{{close scanner1} {scanner de1_ble_handler} {start scanner2} {stop scanner2}} scanner2 {connect AA:BB:CC:DD:EE:FF false}}

proc update_de1_state {value} {set ::machineState [binary encode hex $value]}
proc usb {args} {
	lappend ::usbCalls $args
	if {[lindex $args 0] eq "connect_raw"} {return serial1}
}
namespace eval ::comms {
	proc msg {args} {}
	proc uses_scale_ble_queue {handle} {expr {[ifexists ::de1(scale_connectivity)] eq "ble"}}
}
namespace eval ::device::scale {
	proc should_handle_disconnect {handle} {expr {$handle eq $::de1(scale_device_handle)}}
}
namespace eval ::device::scale::event::apply {
	proc on_connect_callbacks {args} {}
}

proc scaleConnectionEvent {handle state} {
	{*}[dict get $::nativeCallbacks $handle] connection \
		[dict create handle $handle state $state address $::settings(scale_bluetooth_address)]
}

proc scaleDeadline {} {
	lindex [after info $::scale_connect_deadline] 0
}

test android-scale-reconnect-times-out-and-restarts-through-handoff {} -setup setupScan -body {
	set ::de1(scale_device_handle) ble-old
	set ::scanning 0
	scale_disconnect_handler ble-old
	set deadline [scaleDeadline]
	scaleConnectionEvent ble1 discovery
	set discoveryStillPending [expr {$deadline eq [scaleDeadline]}]
	set ::scanning 1
	{*}$deadline
	scaleConnectionEvent ble1 connected
	scaleConnectionEvent ble1 disconnected
	set stalled [list $::currently_connecting_scale_handle $::de1(scale_device_handle) [lindex $::nativeCalls end]]
	de1_ble_handler connection {handle scanner1 state idle}
	scanSettle
	{*}$deadline
	scaleConnectionEvent ble1 connected
	scaleConnectionEvent ble1 disconnected
	set replacement [list $::currently_connecting_scale_handle $::de1(scale_device_handle)]
	set replacementDeadline $::scale_connect_deadline
	scaleConnectionEvent ble2 connected
	{*}[dict get $::nativeCallbacks ble2] descriptor \
		[dict create handle ble2 state connected access w suuid fff0 cuuid fff4 duuid 2902 value [binary decode hex 0100]]
	after cancel $::decentscale_send_heartbeat_id
	list $discoveryStillPending $stalled $replacement $::de1(scale_device_handle) \
		[catch {after info $replacementDeadline}] $::ackHandles [lindex $::operations end]
} -result {1 {0 0 {stop scanner1}} {ble2 0} ble2 1 ble2 030a0101000108}

test android-scale-startup-fallback-only-cancels-scale-before-machine-scan {} -setup setupScan -body {
	set ::scanning 0
	set ::has_bluetooth 1
	set ::de1(device_handle) ble-machine
	ble_connect_to_scale
	set deadline [scaleDeadline]
	check_if_initial_connect_didnt_happen_quickly
	set activeMachine [list $::currently_connecting_scale_handle [expr {$deadline eq [scaleDeadline]}] $::nativeCalls]
	set ::de1(device_handle) 0
	set ::currently_connecting_de1_handle ble-machine
	check_if_initial_connect_didnt_happen_quickly
	{*}$deadline
	scaleConnectionEvent ble1 disconnected
	list $activeMachine $::currently_connecting_scale_handle $::scale_connect_deadline $::nativeCalls
} -result {{ble1 1 {{connect AA:BB:CC:DD:EE:FF false}}} 0 {} {{connect AA:BB:CC:DD:EE:FF false} {close ble-machine} {close ble1} {start scanner1}}}

test android-scale-retired-pending-attempt-respects-retry-limit {} -setup setupScan -body {
	set ::scanning 0
	set ::de1(scale_max_connection_retry_attempts) 1
	ble_connect_to_scale
	set deadline [scaleDeadline]
	scaleConnectionEvent ble1 disconnected
	{*}$deadline
	{*}[scaleDeadline]
	list $::currently_connecting_scale_handle $::scale_connect_deadline \
		$::de1(bluetooth_scale_connection_attempts_tried) $::nativeCalls
} -result {0 {} 1 {{connect AA:BB:CC:DD:EE:FF false} {close ble1} {connect AA:BB:CC:DD:EE:FF false} {close ble2}}}

test usb-machine-state-callback-does-not-require-ble-handle {} -setup setupScale -body {
	foreach key {0D 13 15 14 0A 05 01 12 11 09 0B 0C 0F 10} {
		set ::de1(cuuid_$key) other
	}
	set ::de1(suuid) machine
	set ::de1(cuuid_0E) state-info
	set ::ackHandles {}
	de1_usb_frame_received N 0100
	list $::machineState $::ackHandles
} -result {0100 {{}}}

test usb-scale-disconnect-then-ble-adoption-selects-ble-queue {} -setup setupScan -body {
	set ::de1(scale_device_handle) serial1
	set ::de1(scale_connectivity) usb
	set ::scanning 0
	set ::usbCalls {}
	de1_usb_scale_disconnect
	ble_connect_to_scale
	scaleConnectionEvent ble1 connected
	after cancel $::decentscale_send_heartbeat_id
	list $::usbCalls $::de1(scale_connectivity) $::de1(scale_device_handle) $::de1(wrote)
} -result {{{close serial1}} ble ble1 1}

test usb-scale-adoption-cancels-pending-android-ble-attempt {} -setup setupScan -body {
	set ::scanning 0
	set ::usbCalls {}
	ble_connect_to_scale
	set deadline [scaleDeadline]
	de1_usb_scale_connect port1
	{*}$deadline
	scaleConnectionEvent ble1 disconnected
	scaleConnectionEvent ble1 connected
	de1_usb_scale_stop_keepalive
	list $::de1(scale_device_handle) $::de1(scale_connectivity) \
		$::currently_connecting_scale_handle $::scale_connect_deadline $::nativeCalls
} -result {serial1 usb 0 {} {{connect AA:BB:CC:DD:EE:FF false} {close ble1}}}

cleanupTests
