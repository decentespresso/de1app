namespace eval ::pr351 {
	variable control_dir /data/user/0/tk.tcl.wish/files/pr351
	variable settings_hooked 0
	variable blocked_writes 0
	variable drop_live 0
	variable dropped_packets 0
	variable samples 0
	variable minimum ""
	variable maximum ""
	variable errors {}
	variable last_command startup
	variable ready 0
}

proc ::pr351::uuid {value} { string tolower [string map {- ""} $value] }

proc ::pr351::allowed_write {characteristic data} {
	set id [::pr351::uuid $characteristic]
	if {$id eq "0000a00500001000800000805f9b34fb"} { return [expr {[string length $data] == 20}] }
	if {$id ne "000036f500001000800000805f9b34fb"} { return 0 }
	set hex [binary encode hex $data]
	expr {$hex in {030a03ffff000a 030a0101000108 030a0101010109}}
}

set ::pr351::guard_checks {
	0000A005-0000-1000-8000-00805F9B34FB 0480000c00000000000000000000000000000000 1
	0000a00500001000800000805f9b34fb 0480000c00000000000000000000000000000000 1
	0000A005-0000-1000-8000-00805F9B34FB 02 0
	0000A002-0000-1000-8000-00805F9B34FB 02 0
	0000A004-0000-1000-8000-00805F9B34FB 008038ac01000000 0
	000036F5-0000-1000-8000-00805F9B34FB 030a03ffff000a 1
	000036F5-0000-1000-8000-00805F9B34FB 030a0101000108 1
	000036F5-0000-1000-8000-00805F9B34FB 030a0101010109 1
	000036F5-0000-1000-8000-00805F9B34FB 030f000000010d 0
	000036F5-0000-1000-8000-00805F9B34FB 030a0000000009 0
	000036F5-0000-1000-8000-00805F9B34FB 030a020000000b 0
	000036F5-0000-1000-8000-00805F9B34FB 030a0101 0
	000036F5-0000-1000-8000-00805F9B34FB 030a03ffff000a00 0
	000036F5-0000-1000-8000-00805F9B34FB 030a0101000109 0
	0000FFF4-0000-1000-8000-00805F9B34FB 030a03ffff000a 0
}
foreach {characteristic data expected} $::pr351::guard_checks {
	if {[::pr351::allowed_write $characteristic [binary decode hex $data]] != $expected} {
		error "Unsafe lab write guard: $characteristic $data"
	}
}
if {[info exists argv] && "--check-guard" in $argv} {
	puts "PASS: [expr {[llength $::pr351::guard_checks] / 3}] tablet write-guard checks"
	exit 0
}

set ::home [file dirname [file normalize [info script]]]
if {[file tail $::home] ne "de1plus-pr351-lab"} { error "Run only from the isolated de1plus-pr351-lab copy" }
puts stderr "WARNING: Supervise hardware; connecting may change machine state despite the write guard."
set ::data_home $::home
set ::argv {}
cd $::home
file mkdir $::pr351::control_dir

proc ::pr351::save {name value} {
	set path [file join $::pr351::control_dir $name]
	set channel [open "${path}.tmp" w]
	try { puts $channel $value } finally { close $channel }
	file rename -force "${path}.tmp" $path
}

proc ::pr351::release_write_queue {} {
	set ::de1(wrote) 0
	if {[llength [info commands run_next_userdata_cmd]]} { run_next_userdata_cmd }
}

package require ble
rename ::ble ::pr351::native_ble
proc ::ble {action args} {
	if {$action eq "write"} {
		if {[llength $args] != 6} { error "Unexpected BLE write signature" }
		if {![::pr351::allowed_write [lindex $args 3] [lindex $args 5]]} {
			incr ::pr351::blocked_writes
			after 0 ::pr351::release_write_queue
			return 1
		}
	}
	::pr351::native_ble $action {*}$args
}

proc ::pr351::preferences {command code result operation} {
	if {$code != 0} { return }
	set ::settings(skin) Streamline
	set ::settings(enabled_plugins) {}
	set ::settings(bluetooth_address) ""
	set ::settings(usb_address) ""
	set ::settings(scale_bluetooth_address) ""
	set pairing [file join $::pr351::control_dir pairing]
	if {[file exists $pairing]} {
		set channel [open $pairing r]
		try {
			set ::settings(scale_bluetooth_address) [::pr351::address [read $channel]]
		} finally { close $channel }
	}
	set ::settings(usb_scale_address) ""
	set ::settings(scale_type) decentscale
	set ::settings(app_updates_beta_enabled) 2
	set ::settings(last_version) 99.99.99
	set ::settings(enable_spoken_prompts) 0
	set ::de1(first_connection_was_made) 1
}

proc ::pr351::source_finished {command code result operation} {
	if {!$::pr351::settings_hooked && [llength [info commands ::load_settings]]} {
		trace add execution ::load_settings leave ::pr351::preferences
		set ::pr351::settings_hooked 1
	}
}
trace add execution ::source leave ::pr351::source_finished

proc ::pr351::sample {event} {
	set weight [dict get $event reported_weight]
	incr ::pr351::samples
	if {$::pr351::minimum eq "" || $weight < $::pr351::minimum} { set ::pr351::minimum $weight }
	if {$::pr351::maximum eq "" || $weight > $::pr351::maximum} { set ::pr351::maximum $weight }
}

proc ::pr351::publish {} {
	catch { streamline_ui_weight_refresh }
	set status [dict create time [clock seconds] home [homedir] data [data_directory] \
		command $::pr351::last_command skin $::settings(skin) \
		connected [::device::scale::is_connected] operational [::device::scale::is_operational] \
		reporting [::device::scale::is_reporting] handle $::de1(scale_device_handle) \
		connecting $::currently_connecting_scale_handle protocol $::de1(ble_protocol_version) \
		machine_state $::de1_num_state($::de1(state)) machine_substate $::de1_substate_types($::de1(substate)) \
		weight $::de1(scale_sensor_weight) samples $::pr351::samples \
		minimum $::pr351::minimum maximum $::pr351::maximum \
		blocked_writes $::pr351::blocked_writes dropped_packets $::pr351::dropped_packets \
		label [ifexists ::streamline_dataline_weight_label_blue] \
		errors $::pr351::errors devices $::de1_device_list peripherals $::peripheral_device_list]
	::pr351::save status.tcl $status
}

proc ::pr351::disconnect {} {
	set ::settings(bluetooth_address) ""
	set ::settings(scale_bluetooth_address) ""
	foreach handle [list $::de1(device_handle) $::de1(scale_device_handle)] {
		if {$handle != 0} { catch { ble close $handle } }
	}
	set ::de1(device_handle) 0
	set ::de1(scale_device_handle) 0
	set ::currently_connecting_de1_handle 0
	set ::currently_connecting_scale_handle 0
	set ::pr351::samples 0
	set ::pr351::minimum ""
	set ::pr351::maximum ""
	set ::settings(machine_model) 0
}

proc ::pr351::address {request} {
	if {[llength $request] != 2 || ![regexp {^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$} [lindex $request 1]]} {
		error "Expected one Bluetooth MAC address"
	}
	string toupper [lindex $request 1]
}

proc ::pr351::command {request} {
	set ::pr351::last_command [lindex $request 0]
	switch -- [lindex $request 0] {
		status { ::pr351::publish }
		scan { scanning_restart }
		scale {
			set address [::pr351::address $request]
			::pr351::disconnect
			set ::de1(scale_connectivity) ble
			set ::settings(scale_bluetooth_address) $address
			set ::settings(scale_type) decentscale
			ble_connect_to_scale
		}
		bengle {
			set address [::pr351::address $request]
			::pr351::disconnect
			set ::de1(connectivity) ble
			set ::settings(bluetooth_address) $address
			ble_connect_to_de1
		}
		fault {
			if {$::de1(scale_device_handle) == 0} { error "No external BLE scale is connected" }
			set ::pr351::drop_live 1
			::device::scale::callbacks::on_connect {}
			after 11500 { set ::pr351::drop_live 0 }
		}
		stop { ::pr351::disconnect; after 0 exit }
		default { error "Unknown lab command" }
	}
}

proc ::pr351::poll {} {
	set path [file join $::pr351::control_dir command]
	if {[file exists $path]} {
		try {
			if {[file size $path] > 4096} { error "Lab command is too large" }
			set channel [open $path r]
			try { set request [read $channel] } finally { close $channel }
			file delete $path
			::pr351::command $request
		} on error {message options} {
			lappend ::pr351::errors $message
		}
	}
	catch { ::pr351::publish }
	after 1000 ::pr351::poll
}

proc ::pr351::ready {} {
	if {$::pr351::ready} { return }
	if {!$::pr351::settings_hooked} { error "Lab settings isolation was not installed" }
	rename ::de1_ble_handler ::pr351::packet_handler
	proc ::de1_ble_handler {event data} {
		if {$::pr351::drop_live && $event eq "characteristic" \
				&& [dict exists $data value] && [dict exists $data cuuid] \
				&& [::pr351::uuid [dict get $data cuuid]] eq "0000fff400001000800000805f9b34fb" \
				&& [string match {03c[ae]*} [binary encode hex [dict get $data value]]]} {
			incr ::pr351::dropped_packets
			return
		}
		::pr351::packet_handler $event $data
	}
	::device::scale::event::listener::on_update_available_add -sync ::pr351::sample
	proc bgerror {message} {
		lappend ::pr351::errors $message
		puts stderr $::errorInfo
	}
	trace remove execution ::source leave ::pr351::source_finished
	set ::pr351::ready 1
	after 0 ::pr351::poll
}

proc ::pr351::before_wait {command operation} {
	if {[lindex $command 1] eq "forever"} {
		::pr351::ready
		trace remove execution ::vwait enter ::pr351::before_wait
	}
}
trace add execution ::vwait enter ::pr351::before_wait

::pr351::save status.tcl [dict create phase starting home $::home]
try {
	source [file join $::home de1app.tcl]
	::pr351::ready
} on error {message options} {
	::pr351::save status.tcl [dict create phase failed error $message details [dict get $options -errorinfo]]
	error $message
}
