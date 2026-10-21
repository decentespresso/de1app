if {[llength $argv] != 2 || [lindex $argv 0] ni {bengle hds bengle-load hds-load}} {
	puts stderr "Usage: tclsh tests/scale_hardware.tcl bengle|hds|bengle-load|hds-load COM-port"
	exit 2
}

set kind [lindex $argv 0]
set integrated [expr {$kind in {bengle bengle-load}}]
set port [lindex $argv 1]
set app_dir [file normalize [file join [file dirname [info script]] .. de1plus]]
set events {}
set errors {}
set samples 0
set weights {}
set recovery_count 0
set drop_updates 0
set requested_settings_updates 0
set partial_frames 0
set expected_abandonments 0

foreach {name version} {lambda 1.0 de1_logging 1.2 de1_gui 1.3 de1_bluetooth 1.0 de1_profile 2.0} {
	package provide $name $version
}

proc lambda {arguments body} { list apply [list $arguments $body] }
proc ifexists {name {default ""}} {
	upvar 1 $name value
	if {[info exists value]} { return $value }
	return $default
}
proc homedir {} { return $::app_dir }
proc round_to_two_digits {value} { expr {round($value * 100) / 100.0} }
proc msg {level args} {
	if {$level eq "-ERROR"} {
		set message [join $args " "]
		if {$::kind eq "hds" && $::drop_updates && [string match {Scale updates not seen, *ABANDONING} $message]} {
			incr ::expected_abandonments
		} else {
			lappend ::errors $message
		}
	}
	if {$level in {-ERROR -WARNING -NOTICE}} { puts [list log $level {*}$args] }
}
proc bgerror {message} { lappend ::errors $message }
proc ble {args} { error "BLE access is forbidden in this USB-only test" }
proc start_idle {} { error "Machine control is forbidden in this test" }
proc scale_enable_weight_notifications {} { de1_usb_scale_enable }

namespace eval ::gui::notify {
	proc scale_event {event args} {
		lappend ::events $event
		puts [list scale_event $event {*}$args]
	}
}

source [file join $app_dir event.tcl]
source [file join $app_dir de1_de1.tcl]
source [file join $app_dir device_scale.tcl]
source [file join $app_dir de1_comms.tcl]
source [file join $app_dir binary.tcl]
source [file join $app_dir usb usb.tcl]

proc de1_send_steam_hotwater_settings {} { incr ::requested_settings_updates }

if {$::tcl_platform(platform) eq "windows"} {
	rename open native_open
	proc open {path mode args} {
		if {$path eq $::port && $mode eq "RDWR NONBLOCK"} { set mode RDWR }
		native_open $path $mode {*}$args
	}
}

proc ::comms::msg {level args} { ::msg $level {*}$args }
namespace eval ::bt {}
proc ::bt::msg {level args} { ::msg $level {*}$args }
rename ::usb::write ::usb::write_real
proc ::usb::write {handle line} {
	if {$line ni {<+N> <+S> <-N> <-S>}} { error "Forbidden machine write: $line" }
	::usb::write_real $handle $line
}
rename ::usb::write_raw ::usb::write_raw_real
proc ::usb::write_raw {handle bytes} {
	if {[binary encode hex $bytes] ne "03200101"} { error "Forbidden scale write" }
	::usb::write_raw_real $handle $bytes
}

set ::settings(scale_type) decentscale
set ::settings(scale_bluetooth_address) ""
set ::settings(usb_scale_address) $port
set ::settings(scale_stop_at_half_shot) 0
set ::settings(high_vibration_scale_filtering) 0
set ::de1(scale_device_handle) 0
set ::de1(scale_connectivity) usb
set ::de1(ble_protocol_version) [expr {$integrated ? 2 : 1}]
set ::de1(state) 0
set ::de1(substate) 0
set ::de1(current_frame_number) 0
set ::de1(volume) 0
set ::de1(preinfusion_volume) 0
set ::de1(pour_volume) 0
set ::de1_num_state(0) Sleep
set ::de1_substate_types(0) ready
set ::currently_connecting_scale_handle 0
set ::blink_water_weight 1

proc record_sample {event} {
	incr ::samples
	lappend ::weights [dict get $event reported_weight]
}
::device::scale::event::listener::on_update_available_add -sync record_sample

proc receive_bengle {letter hex} {
	if {$letter eq "N"} {
		set state [string range $hex 0 1]
		if {$state ni {00 02}} { lappend ::errors "Machine is not sleeping/idle: $hex" }
		puts [list state_info $hex]
	} elseif {$letter eq "S"} {
		if {[string length $hex] < 56} { incr ::partial_frames; return }
		::de1::state::update::from_bengleshotvalue [binary decode hex $hex]
	}
}

rename de1_usb_scale_bytes_received de1_usb_scale_bytes_received_real
proc de1_usb_scale_bytes_received {bytes} {
	if {!$::drop_updates} { de1_usb_scale_bytes_received_real $bytes }
}
rename de1_usb_scale_connect de1_usb_scale_connect_real
proc de1_usb_scale_connect {device} {
	incr ::recovery_count
	de1_usb_scale_connect_real $device
}

proc wait_ms {duration} {
	set ::wait_done 0
	after $duration { set ::wait_done 1 }
	vwait ::wait_done
}
proc require_condition {condition message} {
	if {![uplevel 1 [list expr $condition]]} { error $message }
}
proc report {stage} {
	puts [list result $stage samples $::samples \
		operational [::device::scale::is_operational] \
		reporting [::device::scale::is_reporting] \
		weight [ifexists ::de1(scale_sensor_weight)] \
		watchdog $::device::scale::_watchdog_updates_seen]
	flush stdout
}

set handle ""
set failed 0
try {
	if {$integrated} {
		::device::scale::init
		set handle [usb connect $port receive_bengle]
		usb write $handle <+N>
		usb write $handle <+S>
	} else {
		require_condition {[de1_usb_scale_connect $port]} "Cannot open HDS"
		set handle $::de1(scale_device_handle)
	}

	wait_ms 5000
	report initial
	require_condition {$samples > 10} "Too few live weight samples"
	require_condition {[::device::scale::is_operational]} "Live scale is not operational"
	require_condition {[::device::scale::is_reporting]} "Live scale is not reporting"
	puts "Move a cup or weight on the scale during the next 45 seconds."
	flush stdout
	wait_ms 45000
	report weight_change
	set sorted [lsort -real $weights]
	puts [list observed_weight_range [lindex $sorted 0] [lindex $sorted end]]
	puts [list weight_change_detected [expr {[lindex $sorted end] - [lindex $sorted 0] >= 5.0}]]

	if {$kind eq "bengle"} {
		usb write $handle <-S>
		wait_ms 3500
		report interrupted
		require_condition {!$::device::scale::_watchdog_updates_seen} "Notification interruption was not detected"
		require_condition {[::device::scale::is_operational]} "Bengle incorrectly became unavailable"
		set before $samples
		usb write $handle <+S>
		wait_ms 3500
		require_condition {$samples > $before + 10} "Bengle notifications did not recover"
	} elseif {$kind eq "hds"} {
		set before $samples
		set drop_updates 1
		::device::scale::callbacks::on_connect {}
		require_condition {![::device::scale::is_operational]} "Missing first updates did not clear readiness"
		wait_ms 11500
		require_condition {$recovery_count == 2} "Watchdog did not perform exactly one USB reconnect"
		require_condition {$expected_abandonments == 1 && "abandoning_updates" in $events && "not_connected" in $events} \
			"Expected watchdog exhaustion and disconnect were not observed"
		require_condition {$samples == $before} "Fault injection unexpectedly delivered weight"
		set drop_updates 0
		wait_ms 3500
		require_condition {$samples > $before + 10} "HDS live reporting did not recover"
		set handle $::de1(scale_device_handle)
	} else {
		require_condition {[lindex $sorted end] - [lindex $sorted 0] >= 5.0} "No changed load was observed"
	}
	report [expr {$kind in {bengle-load hds-load} ? "load_confirmed" : "recovered"}]
	require_condition {[::device::scale::is_operational] && [::device::scale::is_reporting]} "Recovered scale is not ready"
	require_condition {[llength $errors] == 0} "Callback errors: $errors"
	puts [list PASS $kind $port samples $samples partial_frames $partial_frames \
		reconnects [expr {$recovery_count > 0 ? $recovery_count - 1 : 0}]]
} on error {message options} {
	set failed 1
	puts stderr [list FAIL $kind $port $message]
	puts stderr [dict get $options -errorinfo]
} finally {
	foreach id [after info] { after cancel $id }
	if {$integrated && $handle ne "" && [::usb::is_open $handle]} {
		usb write $handle <-N>
		usb write $handle <-S>
	}
	foreach channel [array names ::usb::opened] { usb close $channel }
}
exit $failed
