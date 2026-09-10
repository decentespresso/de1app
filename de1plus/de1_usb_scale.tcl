# de1_usb_scale.tcl -- Decent Scale / Half Decent Scale over USB-C serial.
#
# Sourced from de1_comms.tcl. The DE1/Bengle USB path (de1_usb.tcl) uses the
# letter protocol; a Decent Scale instead speaks its RAW BLE wire protocol over
# serial (per decaid's HDSSerial): commands are [0x03, payload..., xor] written
# as raw bytes, weight arrives as 7-byte "03 CE hi lo 00 00 xor" frames. We reuse
# de1app's own parse_decent_scale_recv (binary.tcl) to decode, then feed the
# SAME ::device::scale::process_weight_update pipeline a BLE scale uses -- so
# weight display, SAW, history and tare all work identically over USB.
#
# The scale is silent-ish until told: sending raw "03 20 01 01" switches it to
# streaming binary 03 CE frames (it otherwise emits human-readable text). We
# re-send that enable as a keep-alive, matching decaid's watchdog.

namespace eval ::de1_usb_scale {
	variable buf ""
	variable keepalive_afterid ""
	variable last_frame_ms 0
}

# --- helpers ---------------------------------------------------------------

# XOR checksum of a list of byte values (used to build 03..xor commands),
# mirroring de1app's decent_scale_calc_xor but for an arbitrary payload.
proc de1_usb_scale_cmd {payload_bytes} {
	set frame [linsert $payload_bytes 0 0x03]
	set x 0
	foreach b $frame { set x [expr {$x ^ ($b & 0xff)}] }
	lappend frame $x
	return [binary format c* $frame]
}

# --- connection lifecycle --------------------------------------------------

proc de1_usb_scale_connect {device} {
	if {[llength [info commands usb]] == 0} {
		::comms::msg -ERROR "de1_usb_scale_connect: usb transport not loaded"
		return 0
	}
	if {$::de1(scale_device_handle) ni {0 1} && [ifexists ::de1(scale_connectivity)] eq "usb"} {
		::comms::msg -NOTICE "de1_usb_scale_connect: already connected ($::de1(scale_device_handle))"
		return 1
	}

	set ::de1_usb_scale::buf ""
	set ch ""
	if {[catch { set ch [usb connect_raw $device de1_usb_scale_bytes_received] } err]} {
		::comms::msg -ERROR "de1_usb_scale_connect: cannot open $device: $err"
		return 0
	}

	set ::de1(scale_device_handle) $ch
	set ::de1(scale_connectivity) "usb"
	set ::settings(scale_type) "decentscale"
	# NB: deliberately do NOT set ::sinstance($::de1(suuid_decentscale)). That is
	# the BLE readiness sentinel the decentscale_* command procs gate on; leaving
	# it unset makes every one of them safely early-return over USB (they build
	# BLE `ble write ... $cinstance(...)` calls that would crash otherwise). USB
	# commands are sent directly via de1_usb_scale_* / the scale_* USB branches.
	set ::currently_connecting_scale_handle 0
	catch { incr ::successful_scale_connection_count }

	# Enable binary weight streaming (decaid: raw 03 20 01 01), and initialise the
	# scale pipeline (period estimator etc.) the way a BLE-scale connect would.
	de1_usb_scale_enable
	catch { ::device::scale::init }
	catch { ::device::scale::event::apply::on_connect_callbacks [dict create address $device name "Decent Scale (USB)"] }

	de1_usb_scale_start_keepalive
	::comms::msg -NOTICE "de1_usb_scale_connect: connected Decent Scale on $device ($ch)"
	return 1
}

proc de1_usb_scale_enable {} {
	set h $::de1(scale_device_handle)
	if {$h in {0 1}} { return }
	# already a complete 4-byte frame (not xor-wrapped), per decaid
	catch { usb write_raw $h [binary format c* {0x03 0x20 0x01 0x01}] }
}

proc de1_usb_scale_start_keepalive {} {
	de1_usb_scale_stop_keepalive
	set ::de1_usb_scale::last_frame_ms [clock milliseconds]
	# Poll every 2s; only re-send the enable command after a real stall in the
	# weight stream. Once enabled the Decent Scale streams continuously, so an
	# unconditional re-enable would needlessly stutter the stream (and flap the
	# scale-reporting toast). This matches decaid's HDSSerial watchdog: warn/
	# re-enable after 6s of silence.
	set ::de1_usb_scale::keepalive_afterid [after 2000 de1_usb_scale_keepalive_tick]
}
proc de1_usb_scale_stop_keepalive {} {
	if {$::de1_usb_scale::keepalive_afterid ne ""} {
		catch { after cancel $::de1_usb_scale::keepalive_afterid }
		set ::de1_usb_scale::keepalive_afterid ""
	}
}
proc de1_usb_scale_keepalive_tick {} {
	if {[ifexists ::de1(scale_connectivity)] ne "usb" || $::de1(scale_device_handle) in {0 1}} { return }
	set silent_ms [expr {[clock milliseconds] - $::de1_usb_scale::last_frame_ms}]
	if {$silent_ms >= 6000} {
		::comms::msg -NOTICE "de1_usb_scale: no weight frames for ${silent_ms}ms, re-sending enable"
		de1_usb_scale_enable
		# push last_frame forward so we don't re-blast every 2s while still silent
		set ::de1_usb_scale::last_frame_ms [clock milliseconds]
	}
	set ::de1_usb_scale::keepalive_afterid [after 2000 de1_usb_scale_keepalive_tick]
}

proc de1_usb_scale_disconnect {} {
	if {[ifexists ::de1(scale_connectivity)] ne "usb"} { return }
	de1_usb_scale_stop_keepalive
	set h $::de1(scale_device_handle)
	if {$h ni {0 1}} { catch { usb close $h } }
	set ::de1(scale_device_handle) 0
	::comms::msg -NOTICE "de1_usb_scale_disconnect: closed $h"
}

# --- send (commands routed here when the scale is on USB) -------------------

proc de1_usb_scale_send_raw {bytes} {
	set h $::de1(scale_device_handle)
	if {$h in {0 1}} { return 0 }
	return [usb write_raw $h $bytes]
}
proc de1_usb_scale_tare {} {
	# Decent Scale tare: 03 0F 00 00 00 01 xor (decaid)
	de1_usb_scale_send_raw [de1_usb_scale_cmd {0x0F 0x00 0x00 0x00 0x01}]
}

# --- receive ---------------------------------------------------------------

# Raw bytes from the serial port: reassemble 7-byte 03 CE weight frames, XOR-
# check, and run them through de1app's own parser + weight pipeline. Non-frame
# bytes (the scale's text lines / other command echoes) are skipped.
proc de1_usb_scale_bytes_received {raw} {
	append ::de1_usb_scale::buf $raw
	set update_received [expr {[clock milliseconds] / 1000.0}]
	while {1} {
		set n [string length $::de1_usb_scale::buf]
		if {$n < 7} { break }
		# find a 03 CE frame start
		set start -1
		for {set i 0} {$i <= $n-2} {incr i} {
			binary scan [string range $::de1_usb_scale::buf $i [expr {$i+1}]] cucu b0 b1
			if {$b0 == 0x03 && $b1 == 0xCE} { set start $i; break }
		}
		if {$start < 0} {
			# no frame start; keep only the last byte (in case a 0x03 is mid-arrival)
			set ::de1_usb_scale::buf [string range $::de1_usb_scale::buf end end]
			break
		}
		if {[expr {$n - $start}] < 7} {
			set ::de1_usb_scale::buf [string range $::de1_usb_scale::buf $start end]
			break
		}
		set frame [string range $::de1_usb_scale::buf $start [expr {$start+6}]]
		set ::de1_usb_scale::buf [string range $::de1_usb_scale::buf [expr {$start+7}] end]
		# XOR of first 6 bytes must equal byte 6
		binary scan $frame cu7 fb
		set x 0
		foreach v [lrange $fb 0 5] { set x [expr {$x ^ $v}] }
		if {$x != [lindex $fb 6]} { continue }
		set ::de1_usb_scale::last_frame_ms [clock milliseconds]
		# decode via de1app's own parser and feed the shared weight pipeline
		if {[catch {
			parse_decent_scale_recv $frame arr
			if {[ifexists arr(parsed)] eq "weight" && [info exists arr(weight)]} {
				set sensorweight [expr {$arr(weight) / 10.0}]
				::device::scale::process_weight_update $sensorweight $update_received
			}
		} perr]} {
			::comms::msg -DEBUG "de1_usb_scale: parse error: $perr"
		}
	}
}

# --- discovery for the pairing screen ---------------------------------------

# Add any connected Decent Scale USB-C serial ports to the peripheral (scale)
# list, tagged connectiontype "usb", so they appear in the pairing screen's
# Scale box alongside BLE scales. Called from scanning_restart.
proc add_usb_scales_to_list {} {
	if {![info exists ::has_usb] || !$::has_usb} { return }
	if {[llength [info commands usb]] == 0} { return }
	set seen {}
	if {![catch { set ports [usb ports] }]} {
		foreach p $ports {
			if {[dict get $p product] eq "decentscale"} {
				set dev [dict get $p device]
				append_to_peripheral_list $dev "Decent Scale (USB)" "usb" "scale" "decentscale"
				lappend seen $dev
			}
		}
	}
	# A currently-paired/connected USB scale holds its serial port open, so the
	# passive `usb ports` probe above can't open it and skips it. Add it back from
	# the persisted address so it still appears (checked) in the pairing list --
	# otherwise the user can't see it's paired, nor un-pair it.
	set paired [ifexists ::settings(usb_scale_address)]
	if {$paired ne "" && $paired ni $seen} {
		append_to_peripheral_list $paired "Decent Scale (USB)" "usb" "scale" "decentscale"
	}
}
