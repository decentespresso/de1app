package require tcltest
namespace import ::tcltest::*

package provide de1_comms 1.1
package provide de1_device_scale 1.0
package provide de1_logging 1.2
set ::has_bluetooth 0

namespace eval ::logging {
	proc ble_log_enabled {level} {return 0}
	proc format_asc_bin {value} {binary encode hex $value}
}
namespace eval ::device::scale {
	proc invalidate_hds_readiness {handle} {}
}

set appDir [file join [file dirname [info script]] .. de1plus]
source [file join $appDir bluetooth.tcl]

proc userdata_append {description command vital guard} {
	lappend ::writes [list [binary encode hex [lindex $command end]] $guard]
}

proc scale_disconnect_handler {link} {
	lappend ::reconnects $link
}

proc ifexists {name {default ""}} {
	upvar 1 $name value
	if {[info exists value]} {return $value}
	return $default
}

proc setupHds {} {
	::hds_sleep::connected 0 ""
	array set ::de1 {scale_device_handle ble1 suuid_decentscale fff0 cuuid_decentscale_write 36f5}
	set ::sinstance(fff0) 1
	set ::cinstance(36f5) 3
	set ::de1(decentscale_notification_handle) ble1
	set ::android 1
	array set ::settings {scale_type decentscale scale_bluetooth_address A1 keep_scale_on 1 enable_fluid_ounces 0}
	set ::writes {}
	set ::reconnects {}
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

proc fireHdsTimeout {} {
	set callback [lindex [after info $::hds_sleep::timer] 0]
	{*}$callback
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

test invalid-status-does-not-erase-hds-evidence {} -setup setupHds -body {
	proveHds
	foreach frame {030a03ffff000a 030a03ffff000a 030a0000640210 030a0000643110 030a0000643a10 030a0000650310} {
		hdsFrame $frame
	}
	list [::hds_sleep::supportsSoftSleep] $::hds_sleep::major [::hds_sleep::setIntent 1] [nextHdsWrite]
} -result {1 3 1 030a040100000c}

test waiting-behind-other-ble-operations-spends-no-deadline {} -setup setupHds -body {
	proveHds
	::hds_sleep::setIntent 1
	set entryQueued [list $::hds_sleep::phase $::hds_sleep::timer]
	hdsAck [nextHdsWrite]
	::hds_sleep::setIntent 0
	set exitQueued [list $::hds_sleep::phase $::hds_sleep::attempt $::hds_sleep::timer]
	set exit [nextHdsWrite]
	set exitTimer $::hds_sleep::timer
	set exitDeadline [lindex [after info $exitTimer] 0]
	hdsAck $exit
	set statusQueued [list $::hds_sleep::phase $::hds_sleep::timer]
	{*}$exitDeadline
	list $entryQueued $exitQueued $exit [catch {after info $exitTimer}] $statusQueued $::hds_sleep::phase [nextHdsWrite]
} -result {{enterQueued {}} {exitQueued 1 {}} 030a040000000d 1 {statusQueued {}} statusQueued 030a0101000108}

test status-ack-starts-an-independent-response-deadline {} -setup setupHds -body {
	proveHds
	::hds_sleep::setIntent 1
	hdsAck [nextHdsWrite]
	::hds_sleep::setIntent 0
	hdsAck [nextHdsWrite]
	set status [nextHdsWrite]
	set pending $::hds_sleep::timer
	set oldDeadline [lindex [after info $pending] 0]
	hdsAck 030a03ffff000a
	set unrelated [expr {$pending eq $::hds_sleep::timer}]
	hdsAck $status
	set responseDeadline [expr {$pending ne $::hds_sleep::timer}]
	{*}$oldDeadline
	set awaiting $::hds_sleep::phase
	hdsFrame 030a0000640310
	list $unrelated $responseDeadline $awaiting $::hds_sleep::phase [::hds_sleep::isQuiet ble1]
} -result {1 1 statusFrame awakeConfirmed 0}

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

test wake-exhaustion-reconnects-once-per-intent-and-keeps-weight-quiet {} -setup setupHds -body {
	proveHds
	::hds_sleep::setIntent 1
	hdsAck [nextHdsWrite]
	::hds_sleep::setIntent 0
	set attempts {}
	foreach link {ble1 ble2} {
		if {$link ne "ble1"} {
			set ::de1(scale_device_handle) $link
			::hds_sleep::connected $link A1
			::hds_sleep::subscribed $link
		}
		for {set i 0} {$i < 2} {incr i} {
			set exit [nextHdsWrite]
			lappend attempts $exit
			hdsAck $exit $link
			hdsAck [nextHdsWrite] $link
			fireHdsTimeout
			if {$i == 0} {fireHdsTimeout}
		}
	}
	::hds_sleep::setIntent 0
	set afterDuplicate [nextHdsWrite]
	set ::de1(scale_device_handle) ble3
	::hds_sleep::connected ble3 A1
	set ownsStartup [::hds_sleep::subscribed ble3]
	list $attempts $::reconnects $afterDuplicate $ownsStartup [::hds_sleep::isQuiet ble3] [nextHdsWrite]
} -result {{030a040000000d 030a040000000d 030a040000000d 030a040000000d} ble1 none 1 1 none}

test transport-reconnect-uses-the-same-wake-recovery-budget {} -setup setupHds -body {
	proveHds
	::hds_sleep::setIntent 1
	hdsAck [nextHdsWrite]
	::hds_sleep::setIntent 0
	nextHdsWrite
	set oldDeadline [lindex [after info $::hds_sleep::timer] 0]
	set ::de1(scale_device_handle) ble2
	::hds_sleep::connected ble2 A1
	::hds_sleep::subscribed ble2
	{*}$oldDeadline
	for {set i 0} {$i < 2} {incr i} {
		hdsAck [nextHdsWrite] ble2
		hdsAck [nextHdsWrite] ble2
		fireHdsTimeout
		if {$i == 0} {fireHdsTimeout}
	}
	list $::hds_sleep::phase [::hds_sleep::isQuiet ble2] $::reconnects [nextHdsWrite]
} -result {unconfirmed 1 {} none}

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

test sleep-cancels-delayed-and-queued-legacy-lcd-on {} -setup setupHds -body {
	proveHds
	scale_enable_lcd
	set timer $::de1(decentscale_display_retry)
	set retry [lindex [after info $timer] 0]
	scale_sleep_display
	{*}$retry
	list [catch {after info $timer}] [nextHdsWrite] [nextHdsWrite] [nextHdsWrite]
} -result {1 dropped 030a040100000c none}

::hds_sleep::connected 0 ""
cleanupTests
