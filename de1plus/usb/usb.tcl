# usb/usb.tcl -- pure-Tcl USB-C serial transport for the DE1 / Bengle.
#
# The sibling of the `ble` command (de1plus/ble). Where `ble` speaks
# CoreBluetooth GATT, this speaks the DE1's USB-C CDC-ACM line protocol, which
# deliberately mirrors GATT: every characteristic 0xA001..0xA013 has a single
# letter A..S (letter = 'A' + (uuid-0xA001)). The wire framing (validated against
# a live DE1, and ported from decaid's serial transport) is:
#
#   outbound write        <X>HH...        (X = letter, HH = hex payload)
#   outbound enable/notify <+X>           (start streaming characteristic X)
#   outbound disable       <-X>           (stop streaming characteristic X)
#   inbound  notify/reply  [X]HH...       (note: '<>' out, '[]' in)
#
# Each outbound line is newline-terminated. Inbound frames are delimited by the
# next '[' or a newline. No length field, no checksum, no escaping. Port is
# CDC-ACM 115200 8N1, no flow control, DTR low.
#
# This file provides the `usb` command; app-level glue (mapping DE1 command
# names <-> letters, feeding inbound frames into the shared receive decode) lives
# in de1_usb.tcl. load_usb_command (utils.tcl) sources this and reports success
# via [info commands usb], exactly like load_ble_command does for `ble`.

package provide de1_usb_transport 1.0

namespace eval ::usb {
	variable ports_cache {}
	# per-handle read buffers, keyed by channel name
	variable buffers
	array set buffers {}
	# per-handle inbound-frame callbacks, keyed by channel name
	variable callbacks
	array set callbacks {}
	# device path currently open per channel (so ports/probe never re-opens a
	# port that is already connected)
	variable opened
	array set opened {}
	# cache of probe identities, keyed by device path: dict {product model}
	variable probed
	array set probed {}
}

# ::usb::log -- route through the app's comms logger when present, else stderr.
proc ::usb::log {severity args} {
	if {[llength [info commands ::comms::msg]]} {
		::comms::msg $severity usb {*}$args
	} else {
		catch { puts stderr "usb $severity: $args" }
	}
}

# ::usb::ports -- enumerate connected DE1/Bengle serial ports.
#
# Returns a list of dicts: {device <path> product <name> vendor <name> serial <sn>}.
#
# Pure Tcl, no external processes: macOS has no userspace API for USB descriptors
# (that's why an earlier version shelled out to `ioreg`), and the DE1 can enumerate
# as a plain "USB Serial" gadget anyway (the Bengle does, over two interfaces where
# only one speaks the protocol). So we identify a DE1/Bengle the authoritative way
# -- by talking to it: briefly PROBE each candidate serial node (open, arm the
# streams, MMR-read the model, listen ~900ms). Any protocol reply confirms a DE1;
# the model reply (or a BengleShotSample) says DE1 vs Bengle. This is also how
# decaid does it. The device NODE globs cover macOS (/dev/cu.usbmodem*) and Linux
# (/dev/ttyACM*, /dev/ttyUSB*), so the same enumeration works on both.
#
# A port already open by us (a live connection) is never re-probed; its cached
# identity is reused. Probe results are cached per node so repeated Searches don't
# re-poke devices; the cache is pruned when a node disappears (unplug), so a
# re-plugged device is probed afresh.
proc ::usb::ports {} {
	variable opened
	variable probed
	set result {}
	set nodes [lsort -unique [glob -nocomplain \
		/dev/cu.usbmodem* /dev/cu.usbserial* /dev/ttyACM* /dev/ttyUSB*]]

	# prune cache entries whose node is gone, so a re-plug re-probes
	foreach n [array names probed] {
		if {[lsearch -exact $nodes $n] < 0} { unset probed($n) }
	}
	if {$nodes eq ""} { return {} }

	# device paths currently open by us (never re-open these)
	array set openpaths {}
	foreach ch [array names opened] { set openpaths($opened($ch)) 1 }

	foreach node $nodes {
		if {[info exists openpaths($node)]} {
			# connected right now: reuse cached identity, don't reopen
			if {[info exists probed($node)] && [dict get $probed($node) product] ne "none"} {
				lappend result [dict create device $node \
					product [dict get $probed($node) product] vendor "" serial ""]
			}
			continue
		}
		if {![info exists probed($node)]} {
			# first time we've seen this node: probe it (cache positive AND negative
			# so we don't re-poke non-DE1 devices on every Search)
			set p [::usb::_probe $node]
			set probed($node) [expr {$p ne "" ? $p : [dict create product none]}]
		}
		if {[dict get $probed($node) product] ne "none"} {
			lappend result [dict create device $node \
				product [dict get $probed($node) product] vendor "" serial ""]
		}
	}
	set ::usb::ports_cache $result
	return $result
}

# ::usb::_probe -- briefly open a generic serial port and decide whether a DE1 /
# Bengle is on it. Arms state + shot-sample + MMR streams, sends an MMR read of
# the v13Model register (0x80000C), and waits up to ~900ms. Any inbound frame
# confirms a DE1; a BengleShotSample [S] or model value >= 128 means a Bengle.
# Returns a dict {product <DE1|Bengle>} on success, or "" if nothing answered.
proc ::usb::_probe {device} {
	if {[catch { set ch [open $device {RDWR NONBLOCK}] }]} { return "" }
	fconfigure $ch -mode 115200,n,8,1 -translation binary -buffering none -blocking 0
	catch { fconfigure $ch -handshake none }
	catch { fconfigure $ch -ttycontrol {DTR 0 RTS 0} }

	set ::usb::_probe_buf ""
	array unset ::usb::_probe_seen
	array set ::usb::_probe_seen {}
	fileevent $ch readable [list ::usb::_probe_read $ch]

	catch { puts -nonewline $ch "<+N>\n<+M>\n<+S>\n<B>02\n<E>0480000c00000000000000000000000000000000\n"; flush $ch }

	set ::usb::_probe_done 0
	set aid [after 900 { set ::usb::_probe_done 1 }]
	vwait ::usb::_probe_done
	catch { after cancel $aid }
	catch { fileevent $ch readable {} }
	catch { ::close $ch }

	set letters [array names ::usb::_probe_seen]
	if {[llength $letters] == 0} { return "" }
	# Bengle if it streams the high-res superset [S], or the v13Model reply >= 128.
	set is_bengle 0
	if {[info exists ::usb::_probe_seen(S)]} { set is_bengle 1 }
	if {[info exists ::usb::_probe_mmr8000C] && $::usb::_probe_mmr8000C >= 128} { set is_bengle 1 }
	return [dict create product [expr {$is_bengle ? "Bengle" : "DE1"}]]
}

proc ::usb::_probe_read {ch} {
	if {[catch { set d [read $ch] }]} { return }
	if {$d eq ""} { return }
	append ::usb::_probe_buf $d
	while {[regexp -indices {(\[[A-Z]\][0-9A-Fa-f]*?)(?=\[|\n|\r)} $::usb::_probe_buf whole]} {
		set s [lindex $whole 0]; set e [lindex $whole 1]
		set frame [string range $::usb::_probe_buf $s $e]
		set ::usb::_probe_buf [string range $::usb::_probe_buf [expr {$e+1}] end]
		set L [string index $frame 1]
		set ::usb::_probe_seen($L) 1
		if {$L eq "E"} {
			set hex [string tolower [string range $frame 3 end]]
			# v13Model reply for 0x80000C: int32 little-endian at byte offset 4
			if {[string length $hex] >= 16 && [string toupper [string range $hex 2 7]] eq "80000C"} {
				scan [string range $hex 8 9] %x b0
				set ::usb::_probe_mmr8000C $b0
			}
		}
	}
	set lb [string first "\[" $::usb::_probe_buf]
	if {$lb > 0} { set ::usb::_probe_buf [string range $::usb::_probe_buf $lb end] }
}

# ::usb::connect -- open a serial port and start reading DE1 frames.
#
#   callback is invoked for every complete inbound frame as:
#       {*}$callback $letter $hexpayload
#
# Returns the channel handle (used as the "device handle" everywhere else), or
# throws on failure.
proc ::usb::connect {device callback} {
	variable buffers
	variable callbacks

	set ch [open $device {RDWR NONBLOCK}]
	# 115200 8N1, binary, unbuffered. Flow control off; DTR/RTS forced low to
	# match decaid (harmless if the platform rejects -ttycontrol).
	fconfigure $ch -mode 115200,n,8,1 -translation binary -buffering none -blocking 0
	catch { fconfigure $ch -handshake none }
	catch { fconfigure $ch -ttycontrol {DTR 0 RTS 0} }

	set buffers($ch) ""
	set callbacks($ch) $callback
	set ::usb::opened($ch) $device
	fileevent $ch readable [list ::usb::_on_readable $ch]
	::usb::log -NOTICE "opened $device as $ch ([fconfigure $ch -mode])"
	return $ch
}

# ::usb::_on_readable -- drain the channel, split complete [X]hex frames, and
# dispatch each to the handle's callback. Mirrors decaid's frame regex: a frame
# is "[A-Z]" + hex, terminated by the next '[' or a newline/CR.
proc ::usb::_on_readable {ch} {
	variable buffers
	variable callbacks

	if {[catch { set chunk [read $ch] } err]} {
		::usb::log -ERROR "read error on $ch: $err"
		return
	}
	if {$chunk eq ""} {
		if {[eof $ch]} { ::usb::log -ERROR "eof on $ch" }
		return
	}
	append buffers($ch) $chunk

	while {[regexp -indices {(\[[A-Z]\][0-9A-Fa-f]*?)(?=\[|\n|\r)} $buffers($ch) whole]} {
		set start [lindex $whole 0]
		set end   [lindex $whole 1]
		set frame [string range $buffers($ch) $start $end]
		# consume up to and including this frame
		set buffers($ch) [string range $buffers($ch) [expr {$end + 1}] end]
		set letter [string index $frame 1]
		set hex    [string range $frame 3 end]
		if {[info exists callbacks($ch)] && $callbacks($ch) ne ""} {
			if {[catch { uplevel #0 [list {*}$callbacks($ch) $letter $hex] } cberr]} {
				::usb::log -ERROR "frame callback error ($letter): $cberr"
			}
		}
	}

	# Drop anything before the first '[' (partial/garbage), and guard against an
	# unbounded buffer if we never see a well-formed frame.
	set lb [string first "\[" $buffers($ch)]
	if {$lb > 0} { set buffers($ch) [string range $buffers($ch) $lb end] }
	if {[string length $buffers($ch)] > 4096} { set buffers($ch) "" }
}

# ::usb::write -- send one already-formed protocol line (e.g. "<B>02", "<+N>").
# Appends the newline terminator. Returns 1 on success (like `ble write`), 0 on
# failure, so the command-queue drain treats it as a completed write.
proc ::usb::write {ch line} {
	if {[catch {
		puts -nonewline $ch "$line\n"
		flush $ch
	} err]} {
		::usb::log -ERROR "write error on $ch ($line): $err"
		return 0
	}
	return 1
}

# Is $ch a live usb serial channel this driver opened and still has open? Used by
# the app layer to guard against writing to a stale/closed/non-usb handle.
proc ::usb::is_open {ch} {
	variable callbacks
	return [expr {[info exists callbacks($ch)] && [lsearch -exact [chan names] $ch] >= 0}]
}

proc ::usb::close {ch} {
	variable buffers
	variable callbacks
	variable opened
	catch { fileevent $ch readable {} }
	catch { ::close $ch }
	catch { unset buffers($ch) }
	catch { unset callbacks($ch) }
	catch { unset opened($ch) }
	return 1
}

# Expose a single `usb` command, so load_usb_command can detect us via
# [info commands usb], just as the app detects the `ble` command. Only the
# public subcommands are dispatched; helpers (_on_readable, log) stay private.
proc usb {subcmd args} {
	switch -- $subcmd {
		ports   { return [::usb::ports] }
		connect { return [::usb::connect {*}$args] }
		write   { return [::usb::write {*}$args] }
		close   { return [::usb::close {*}$args] }
		default { error "usb: unknown subcommand \"$subcmd\" (ports|connect|write|close)" }
	}
}
