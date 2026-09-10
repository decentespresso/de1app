# de1_usb.tcl -- app-level glue for the USB-C serial transport.
#
# Sourced from de1_comms.tcl. Bridges the generic DE1 command layer (which is
# transport-neutral: everything funnels through de1_comm) to the `usb` command
# (usb/usb.tcl). Two directions:
#
#   SEND     de1_comm write/read/enable/disable  ->  de1_usb  ->  usb write "<X>.."
#   RECEIVE  usb reader  ->  de1_usb_frame_received  ->  de1_ble_handler (shared
#            characteristic decode; zero duplication of the BLE decode logic)
#
# The DE1's USB-C protocol mirrors GATT exactly (see usb/usb.tcl), so an inbound
# serial frame [X]hex is turned back into the identical (cuuid, binary-value)
# pair a BLE notification would carry, then handed to the existing maintained
# decode in de1_ble_handler. That keeps a single source of truth for parsing
# ShotSample / StateInfo / MMR reads / calibration / version / water levels.

# --- letter <-> characteristic helpers -------------------------------------

# Map a DE1 command name (e.g. "ShotSample") to its serial letter (e.g. "M").
# The command-names->cuuids array stores VALUES as the literal string
# "$::de1(cuuid_0D)" (an array-set quirk this file relies on elsewhere), so we
# pull the two hex digits straight out of that literal: cuuid_0D -> 0x0D -> 'M'.
proc de1_usb_command_to_letter {command_name} {
	if {![info exists ::de1_command_names_to_cuuids($command_name)]} {
		error "de1_usb: no cuuid mapping for command '$command_name'"
	}
	set literal $::de1_command_names_to_cuuids($command_name)
	if {![regexp {cuuid_([0-9A-Fa-f]{2})} $literal -> hh]} {
		error "de1_usb: cannot derive letter from '$literal' for '$command_name'"
	}
	# letter = 'A' + (byte - 1):  0x01->A, 0x0D->M, 0x13->S
	return [format %c [expr {65 + [scan $hh %x] - 1}]]
}

# Map an inbound serial letter back to its full characteristic UUID string,
# matching the values in ::de1(cuuid_XX). 'A'->cuuid_01, 'M'->cuuid_0D, ...
proc de1_usb_letter_to_cuuid {letter} {
	set byte [expr {[scan $letter %c] - 65 + 1}]
	set key cuuid_[format %02X $byte]
	if {![info exists ::de1($key)]} {
		return ""
	}
	return $::de1($key)
}

# --- send adapter (called from de1_comm when connectivity == "usb") ----------

proc de1_usb {action command_name {data ""}} {
	# The command queue is transport-neutral, so a command can arrive here after
	# the USB link went away, or while ::de1(connectivity) is momentarily out of
	# sync with the live handle (e.g. a BLE connect set ::de1(device_handle) to a
	# ble* handle). Writing to a non-usb / closed channel would fail every time
	# and, with an eager re-drain, spin the CPU. So verify we truly have a live
	# usb channel; if not, tear down cleanly so the queue drops (not retries) the
	# command, and do NOT re-nudge the queue.
	set h $::de1(device_handle)
	if {$h == 0 || $h == 1 || ![::usb::is_open $h]} {
		comms_msg -DEBUG "de1_usb: no live usb channel ($h); dropping $action $command_name"
		de1_usb_mark_disconnected
		return ""
	}

	set letter [de1_usb_command_to_letter $command_name]
	set ok 0
	switch -- $action {
		write {
			# payload bytes -> lowercase hex, no separators
			set hex [string tolower [binary encode hex $data]]
			set ok [usb write $h "<$letter>$hex"]
		}
		read -
		enable {
			# start the characteristic's notifications; one-shot reads (Version,
			# Temperatures) arrive as a single [X] frame handled by the receiver.
			set ok [usb write $h "<+$letter>"]
		}
		disable {
			set ok [usb write $h "<-$letter>"]
		}
		default {
			error "de1_usb: unknown action '$action' for '$command_name'"
		}
	}

	# There is no per-write ACK on serial (unlike BLE, where a 'w' characteristic
	# event resets ::de1(wrote) and pumps the next command). So on a SUCCESSFUL
	# write, clear the write gate ourselves and nudge the queue to drain the next
	# command promptly. Async (after 0) avoids re-entrancy: run_next_userdata_cmd,
	# our caller, has not yet advanced ::de1(cmdstack) when this returns. On a
	# FAILED write we deliberately do NOT re-nudge -- that is what would spin.
	if {$ok == 1} {
		set ::de1(wrote) 0
		after 0 run_next_userdata_cmd
	}
	return $ok
}

# The usb link is gone: reset handle/sinstance so run_next_userdata_cmd's
# "DE1 not connected -> drop, do not retry" path fires, and future de1_usb calls
# short-circuit at the top guard instead of erroring.
proc de1_usb_mark_disconnected {} {
	set ::de1(device_handle) 0
	catch { unset ::sinstance($::de1(suuid)) }
}

# --- receive adapter ---------------------------------------------------------

# Called by the usb reader for each complete inbound frame [<letter>]<hex>.
# Rebuilds the binary value and replays it through the shared BLE characteristic
# decode by synthesizing the same event dict a CoreBluetooth notification would
# produce (state connected, access c = change/notification).
proc de1_usb_frame_received {letter hex} {
	set cuuid [de1_usb_letter_to_cuuid $letter]
	if {$cuuid eq ""} {
		comms_msg -DEBUG "de1_usb: ignoring frame for unknown letter '$letter'"
		return
	}
	# tolerate whitespace / odd nibble defensively
	regsub -all {[^0-9A-Fa-f]} $hex "" hex
	if {[string length $hex] % 2 != 0} {
		set hex [string range $hex 0 end-1]
	}
	set value [binary decode hex $hex]

	# Drop undersized frames. Unlike BLE (where GATT delivers a whole
	# characteristic value atomically), a serial link can hand us a partial or
	# garbage frame -- e.g. leftover bytes right after the port opens. Decoding a
	# short ShotSample/StateInfo/etc. leaves array fields unset and crashes the
	# parser downstream, so gate on the minimum payload length per characteristic
	# (mirrors decaid's serial min-length checks). Letters not listed have no
	# fixed minimum and always pass.
	set minmap {M 19 N 2 Q 2 R 14 S 28 A 1 E 4}
	set minbytes [expr {[dict exists $minmap $letter] ? [dict get $minmap $letter] : 0}]
	if {[string length $value] < $minbytes} {
		comms_msg -DEBUG "de1_usb: dropping short \[$letter\] frame ([string length $value]B < ${minbytes}B): $hex"
		return
	}

	set synth [dict create \
		state connected \
		access c \
		suuid $::de1(suuid) \
		cuuid $cuuid \
		value $value]

	de1_ble_handler characteristic $synth
}

# --- connection lifecycle ----------------------------------------------------

# Prime the DE1 exactly like decaid does: the machine is silent on serial until
# each characteristic's stream is armed with <+X>, then <B>02 wakes it to Idle.
proc de1_usb_prime_streams {} {
	set h $::de1(device_handle)
	foreach line {<+N> <+M> <+Q> <+K> <+E> <+I> <+R>} {
		usb write $h $line
	}
	# wake to Idle (RequestedState = 0x02)
	usb write $h "<B>02"
}

proc de1_usb_connect {device} {
	if {[llength [info commands usb]] == 0} {
		::comms::msg -ERROR "de1_usb_connect: usb transport not loaded"
		return 0
	}
	# already connected to this device?
	if {$::de1(device_handle) ni {0 1} && $::de1(connectivity) eq "usb"} {
		::comms::msg -NOTICE "de1_usb_connect: already connected ($::de1(device_handle))"
		return 1
	}

	# Preliminary product label for the connect handler + device-list entry. The
	# AUTHORITATIVE model (DE1 vs Bengle) is determined later from the MMR v13Model
	# read (is_bengle_model), so this is only an initial label. Take it from the
	# already-known device-list entry rather than calling ::usb::ports here, which
	# actively opens/arms EVERY serial port and blocks the UI for several seconds
	# at startup (the connect runs in the startup path when a USB machine is paired).
	set product "DE1"
	foreach d $::de1_device_list {
		if {[dict get $d address] eq $device && [dict get $d name] ne ""} {
			set product [dict get $d name]
			break
		}
	}

	# If a BLE DE1 was the live link, close it first so we never hold two
	# connections at once (which is how connectivity and the handle drift apart).
	if {$::de1(device_handle) ni {0 1} && $::de1(connectivity) eq "ble"} {
		catch { set ::de1(disable_de1_reconnect) 1 }
		catch { ble close $::de1(device_handle) }
		set ::de1(device_handle) 0
	}

	set ch ""
	if {[catch { set ch [usb connect $device de1_usb_frame_received] } err]} {
		::comms::msg -ERROR "de1_usb_connect: cannot open $device: $err"
		return 0
	}

	set ::de1(connectivity) "usb"
	# Satisfy the BLE-era readiness checks (de1_ble / mmr_read / senders gate on
	# a non-empty ::sinstance($::de1(suuid))). A sentinel makes the transport-
	# neutral senders treat the DE1 as reachable over USB.
	set ::sinstance($::de1(suuid)) "usb"

	# Enable MMR reads. mmr_available() normally decides this from the Version
	# characteristic's BLE-API number, but the DE1 does not answer the version
	# arm (<+A>) over USB serial, so ::de1(version) stays empty and mmr_available
	# would fall back to the persisted settings(mmr_enabled) -- which is 0 on a
	# fresh install, blocking every MMR read (model / firmware / serial / GHC)
	# before it is sent. Any DE1/Bengle that speaks USB-C serial is new enough to
	# support MMR, so force it on here.
	set ::mmr_enabled 1
	set ::settings(mmr_enabled) 1

	# Arm the streams first, then run the standard connect handler (version read,
	# MMR model/GHC reads, etc.) which enqueues further de1_comm calls that also
	# route through de1_usb.
	set ::de1(device_handle) $ch
	de1_usb_prime_streams

	set addr $device
	de1_connect_handler $ch $addr $product

	# de1_connect_handler tags the device list entry as "ble"; fix it to "usb".
	append_to_de1_list $addr $product "usb"

	# Over BLE, the machine-identity reads (model / firmware / serial / GHC, and
	# the profile/settings push) are all kicked off by later_new_de1_connection_setup,
	# which runs when the Version characteristic (0xA001 / [A]) notification lands.
	# The DE1 does NOT answer the version-arm (<+A>) over USB serial, so that
	# trigger never fires and the Machine page stays blank. MMR reads themselves
	# work fine over serial, so drive the same setup explicitly here. Deferred a
	# little so the initial connect/stream priming settles first.
	after 1500 later_new_de1_connection_setup

	::comms::msg -NOTICE "de1_usb_connect: connected to $product on $device ($ch)"
	return 1
}

proc de1_usb_disconnect {} {
	if {$::de1(connectivity) ne "usb"} { return }
	set h $::de1(device_handle)
	catch { de1_usb_prime_streams_off }
	if {$h ni {0 1}} { catch { usb close $h } }
	set ::de1(device_handle) 0
	catch { unset ::sinstance($::de1(suuid)) }
	::comms::msg -NOTICE "de1_usb_disconnect: closed $h"
}

# --- device discovery for the pairing screen --------------------------------

# Add any connected DE1/Bengle USB-C serial ports to the DE1 device list, so
# they appear (tagged type "usb") in the pairing listbox alongside BLE devices.
# Called from scanning_restart. No-op when the usb transport isn't loaded.
proc add_usb_devices_to_list {} {
	if {![info exists ::has_usb] || !$::has_usb} { return }
	if {[llength [info commands usb]] == 0} { return }
	if {[catch { set ports [usb ports] } err]} {
		::comms::msg -DEBUG "add_usb_devices_to_list: usb ports failed: $err"
		return
	}
	foreach p $ports {
		# Only espresso machines belong in the DE1 list -- a Decent Scale (also
		# returned by `usb ports`) goes in the scale/peripheral list instead
		# (add_usb_scales_to_list).
		if {[dict get $p product] in {DE1 Bengle}} {
			append_to_de1_list [dict get $p device] [dict get $p product] "usb"
		}
	}
}

proc de1_usb_prime_streams_off {} {
	set h $::de1(device_handle)
	if {$h in {0 1}} { return }
	foreach line {<-N> <-M> <-Q> <-K> <-E> <-I> <-R>} {
		catch { usb write $h $line }
	}
}
