package require tcltest
namespace import ::tcltest::*

package provide de1_comms 1.1
package provide de1_device_scale 1.0
package provide de1_logging 1.2
set ::has_bluetooth 0

namespace eval ::logging {
	proc ble_log_enabled {level} {return 0}
}
namespace eval ::device::scale {
	proc invalidate_hds_readiness {handle} {}
}

set appDir [file join [file dirname [info script]] .. de1plus]
source [file join $appDir bluetooth.tcl]

proc userdata_append {description command vital guard} {
	lappend ::writes [list [binary encode hex [lindex $command end]] $guard]
}

proc setupHds {} {
	::hds_sleep::connected 0 ""
	array set ::de1 {scale_device_handle ble1 suuid_decentscale fff0 cuuid_decentscale_write 36f5}
	set ::sinstance(fff0) 1
	set ::cinstance(36f5) 3
	array set ::settings {scale_type decentscale scale_bluetooth_address A1 keep_scale_on 1 enable_fluid_ounces 0}
	set ::writes {}
	::hds_sleep::connected ble1 A1
}

proc hdsFrame {hex {link ble1}} {
	::hds_sleep::notification $link [binary decode hex $hex]
}

proc hdsAck {hex {link ble1}} {
	::hds_sleep::writeAck $link [binary decode hex $hex]
}

proc nextHdsWrite {} {
	if {![llength $::writes]} {return "none"}
	lassign [lindex $::writes 0] hex guard
	set ::writes [lrange $::writes 1 end]
	if {![{*}$guard]} {return "dropped"}
	return $hex
}

proc proveHds {} {
	::hds_sleep::subscribed ble1
	hdsFrame 030a0000640310
	set probe [nextHdsWrite]
	hdsFrame 03220025000004
	return $probe
}

test soft-sleep-needs-live-probe-and-major {} -setup setupHds -body {
	hdsFrame 030a0000640310
	set beforeSubscription [nextHdsWrite]
	::hds_sleep::subscribed ble1
	hdsFrame 030a0000640210
	set oldMajor [nextHdsWrite]
	hdsFrame 030a0000640310
	set probe [nextHdsWrite]
	hdsFrame 03220025000004 ble0
	hdsFrame 03220025000005
	set noEvidence [::hds_sleep::setIntent 1]
	hdsFrame 03220025000004
	list $beforeSubscription $oldMajor $probe $noEvidence [nextHdsWrite] [::hds_sleep::isQuiet ble1]
} -result {none none 03220000000021 0 030a040100000c 1}

test wake-requires-exit-ack-and-post-dispatch-status {} -setup setupHds -body {
	proveHds
	::hds_sleep::setIntent 1
	set enter [nextHdsWrite]
	hdsAck $enter
	::hds_sleep::setIntent 0
	set exit [nextHdsWrite]
	hdsFrame 030a0000640310
	hdsAck $exit ble0
	set beforeAck [nextHdsWrite]
	hdsAck $exit
	hdsFrame 030a0000640310
	set beforeStatusRequest [::hds_sleep::isQuiet ble1]
	set status [nextHdsWrite]
	hdsFrame 030a03ffff000a
	set afterHeartbeat [::hds_sleep::isQuiet ble1]
	hdsFrame 030a0000640310
	list $enter $exit $beforeAck $beforeStatusRequest $status $afterHeartbeat [::hds_sleep::isQuiet ble1]
} -result {030a040100000c 030a040000000d none 1 030a0101000108 1 0}

test reconnect-retains-wake-obligation-only-for-same-scale {} -setup setupHds -body {
	proveHds
	::hds_sleep::setIntent 1
	hdsAck [nextHdsWrite]
	set ::de1(scale_device_handle) 0
	::hds_sleep::setIntent 0
	set ::de1(scale_device_handle) ble2
	::hds_sleep::connected ble2 A1
	set ownsStartup [::hds_sleep::subscribed ble2]
	set samePeer [nextHdsWrite]
	set ::de1(scale_device_handle) ble3
	::hds_sleep::connected ble3 B2
	list $ownsStartup $samePeer [::hds_sleep::subscribed ble3] [nextHdsWrite] [::hds_sleep::isQuiet ble3]
} -result {1 030a040000000d 0 none 0}

test superseded-enter-never-reaches-ble {} -setup setupHds -body {
	proveHds
	::hds_sleep::setIntent 1
	set wake [::hds_sleep::setIntent 0]
	list $wake [nextHdsWrite] [::hds_sleep::isQuiet ble1]
} -result {0 dropped 0}

test wake-failure-retries-once-and-preserves-quiet {} -setup setupHds -body {
	proveHds
	::hds_sleep::setIntent 1
	hdsAck [nextHdsWrite]
	::hds_sleep::setIntent 0
	set first [nextHdsWrite]
	set epoch $::hds_sleep::generation
	::hds_sleep::timeout ble1 $epoch 1
	::hds_sleep::timeout ble1 $epoch 1
	set second [nextHdsWrite]
	::hds_sleep::timeout ble1 $epoch 2
	list $first $second [nextHdsWrite] [::hds_sleep::isQuiet ble1]
} -result {030a040000000d 030a040000000d none 1}

test sleeping-reconnect-reasserts-sleep-and-wake-renegotiates {} -setup setupHds -body {
	proveHds
	::hds_sleep::setIntent 1
	hdsAck [nextHdsWrite]
	set ::de1(scale_device_handle) ble2
	::hds_sleep::connected ble2 A1
	set ownsStartup [::hds_sleep::subscribed ble2]
	set enter [nextHdsWrite]
	hdsAck $enter ble2
	::hds_sleep::setIntent 0
	set ::settings(enable_fluid_ounces) 1
	hdsAck [nextHdsWrite] ble2
	set status [nextHdsWrite]
	hdsFrame 030a0000640310 ble2
	list $ownsStartup $enter $status [::hds_sleep::isQuiet ble2] [nextHdsWrite]
} -result {1 030a040100000c 030a0101010109 0 03220000000021}

test keep-scale-off-preserves-legacy-power-choice {} -setup setupHds -body {
	proveHds
	set ::settings(keep_scale_on) 0
	list [::hds_sleep::setIntent 1] [nextHdsWrite] [::hds_sleep::isQuiet ble1]
} -result {0 none 0}

::hds_sleep::connected 0 ""
cleanupTests
