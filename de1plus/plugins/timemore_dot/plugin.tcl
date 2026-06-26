set plugin_name "timemore_dot"

namespace eval ::plugins::${plugin_name} {

	variable author "DE1 Community"
	variable contact ""
	variable version 1.0
	variable description "Timemore Dot scale support via BLE (Service 0xFFF0)"
	variable name "Timemore Dot Scale"

	# BLE protocol constants (extracted from HCI snoop log of official Timemore app)
	variable SVC_UUID "0000FFF0-0000-1000-8000-00805F9B34FB"
	variable NTF_UUID "0000FFF1-0000-1000-8000-00805F9B34FB"
	variable WRT_UUID "0000FFF2-0000-1000-8000-00805F9B34FB"

	proc preload {} {
	}

	proc main {} {

		# ──────────────────────────────────────────
		# 1. Register BLE UUID constants into ::de1 array
		# ──────────────────────────────────────────
		set ::de1(suuid_timemore_dot)        $::plugins::timemore_dot::SVC_UUID
		set ::de1(cuuid_timemore_dot_status) $::plugins::timemore_dot::NTF_UUID
		set ::de1(cuuid_timemore_dot_cmd)    $::plugins::timemore_dot::WRT_UUID

		# ──────────────────────────────────────────
		# 2. Wrap generic scale dispatch functions
		#    (rename originals, insert timemore_dot branch)
		# ──────────────────────────────────────────
		wrap_scale_dispatch

		# ──────────────────────────────────────────
		# 3. Patch de1_ble_handler for scan/connect/notify
		#    (dynamic proc body rewrite at load time)
		# ──────────────────────────────────────────
		patch_ble_handler

		msg -NOTICE "Timemore Dot scale plugin loaded (v$::plugins::timemore_dot::version)"
	}

	# ══════════════════════════════════════════════════════
	# Dispatch function wrapping via rename
	# ══════════════════════════════════════════════════════

	proc wrap_scale_dispatch {} {

		# -- scale_timer_start --
		rename ::scale_timer_start ::plugins::timemore_dot::_orig_scale_timer_start
		proc ::scale_timer_start {} {
			if {$::settings(scale_type) == "timemore_dot"} {
				::plugins::timemore_dot::start_timer
			} else {
				::plugins::timemore_dot::_orig_scale_timer_start
			}
		}

		# -- scale_timer_stop --
		rename ::scale_timer_stop ::plugins::timemore_dot::_orig_scale_timer_stop
		proc ::scale_timer_stop {} {
			if {$::settings(scale_type) == "timemore_dot"} {
				::plugins::timemore_dot::stop_timer
			} else {
				::plugins::timemore_dot::_orig_scale_timer_stop
			}
		}

		# -- scale_timer_reset --
		rename ::scale_timer_reset ::plugins::timemore_dot::_orig_scale_timer_reset
		proc ::scale_timer_reset {} {
			if {$::settings(scale_type) == "timemore_dot"} {
				::plugins::timemore_dot::reset_timer
			} else {
				::plugins::timemore_dot::_orig_scale_timer_reset
			}
		}

		# -- scale_enable_weight_notifications --
		rename ::scale_enable_weight_notifications ::plugins::timemore_dot::_orig_scale_enable_weight_notifications
		proc ::scale_enable_weight_notifications {} {
			if {$::settings(scale_type) == "timemore_dot"} {
				::plugins::timemore_dot::enable_weight_notifications
			} else {
				::plugins::timemore_dot::_orig_scale_enable_weight_notifications
			}
		}

		# -- ::device::scale::tare --
		rename ::device::scale::tare ::plugins::timemore_dot::_orig_device_scale_tare
		proc ::device::scale::tare {args} {
			if {$::settings(scale_type) == "timemore_dot"} {
				::plugins::timemore_dot::tare
			} else {
				::plugins::timemore_dot::_orig_device_scale_tare {*}$args
			}
		}

		msg -NOTICE "Timemore Dot: wrapped 5 scale dispatch functions"
	}

	# ══════════════════════════════════════════════════════
	# BLE handler patching
	# Dynamically rewrites de1_ble_handler proc body to add:
	#   - Scan detection for "TIMEMORE" BLE name prefix
	#   - Connection init handler for timemore_dot scale_type
	#   - Notification routing for timemore_dot characteristic
	# ══════════════════════════════════════════════════════

	proc patch_ble_handler {} {

		set body [info body de1_ble_handler]

		# Preserve full argument specification including defaults
		set args_spec {}
		foreach arg [info args de1_ble_handler] {
			if {[info default de1_ble_handler $arg default_val]} {
				lappend args_spec [list $arg $default_val]
			} else {
				lappend args_spec $arg
			}
		}

		set patch_count 0

		# Tab helpers (must match bluetooth.tcl indentation exactly)
		set t4 "\t\t\t\t"
		set t5 "\t\t\t\t\t"
		set t6 "\t\t\t\t\t\t"
		set t7 "\t\t\t\t\t\t\t"

		# ── Patch 1: Scan detection ──
		# Inject TIMEMORE name check before "} else { return }" in the scan section
		# Anchor: 5-tab difluid line + newline + 4-tab "} else {"
		set scan_old "${t5}append_to_peripheral_list \$address \$name \"ble\" \"scale\" \"difluid\"\n${t4}} else {"
		set scan_new "${t5}append_to_peripheral_list \$address \$name \"ble\" \"scale\" \"difluid\"\n${t4}} elseif {\[string first \"TIMEMORE\" \$name\] == 0 } {\n${t5}append_to_peripheral_list \$address \$name \"ble\" \"scale\" \"timemore_dot\"\n${t4}} else {"

		set new_body [string map [list $scan_old $scan_new] $body]
		if {$new_body ne $body} {
			set body $new_body
			incr patch_count
			msg -NOTICE "Timemore Dot: scan detection patch applied"
		} else {
			msg -ERROR "Timemore Dot: scan detection patch FAILED - anchor not found"
		}

		# ── Patch 2: Connection handler ──
		# Inject timemore_dot init branch before "error unknown scale"
		# Anchor: 7-tab varia_aku line + newline + 6-tab "} else {" + newline + 7-tab error
		set conn_old "${t7}after 200 varia_aku_enable_weight_notifications\n${t6}} else {\n${t7}error \"unknown scale: '\$::settings(scale_type)'\""
		set conn_new "${t7}after 200 varia_aku_enable_weight_notifications\n${t6}} elseif {\$::settings(scale_type) == \"timemore_dot\"} {\n${t7}append_to_peripheral_list \$address \$::settings(scale_bluetooth_name) \"ble\" \"scale\" \"timemore_dot\"\n${t7}after 200 ::plugins::timemore_dot::enable_weight_notifications\n${t7}after 500 ::plugins::timemore_dot::send_init_sequence\n${t6}} else {\n${t7}error \"unknown scale: '\$::settings(scale_type)'\""

		set new_body [string map [list $conn_old $conn_new] $body]
		if {$new_body ne $body} {
			set body $new_body
			incr patch_count
			msg -NOTICE "Timemore Dot: connection handler patch applied"
		} else {
			msg -ERROR "Timemore Dot: connection handler patch FAILED - anchor not found"
		}

		# ── Patch 3: Notification handler ──
		# Inject timemore_dot UUID check before difluid handler
		# Since FFF1 UUID is shared, also checks scale_type
		# Anchor: 7-tab smartchef line + newline + 7-tab "} elseif {cuuid_difluid}"
		set ntf_old "${t7}smartchef_parse_response \$value\n${t7}} elseif {\$cuuid eq \$::de1(cuuid_difluid)} {"
		set ntf_new "${t7}smartchef_parse_response \$value\n${t6}} elseif {\$cuuid eq \$::de1(cuuid_timemore_dot_status) && \$::settings(scale_type) == \"timemore_dot\"} {\n${t7}::plugins::timemore_dot::parse_response \$value\n${t7}} elseif {\$cuuid eq \$::de1(cuuid_difluid)} {"

		set new_body [string map [list $ntf_old $ntf_new] $body]
		if {$new_body ne $body} {
			set body $new_body
			incr patch_count
			msg -NOTICE "Timemore Dot: notification handler patch applied"
		} else {
			msg -ERROR "Timemore Dot: notification handler patch FAILED - anchor not found"
		}

		# Rebuild the proc with patched body
		if {$patch_count > 0} {
			proc ::de1_ble_handler $args_spec $body
			msg -NOTICE "Timemore Dot: patched de1_ble_handler ($patch_count/3 patches applied)"
		} else {
			msg -ERROR "Timemore Dot: NO patches applied - BLE handler unchanged"
		}
	}

	# ══════════════════════════════════════════════════════
	# BLE communication helper
	# ══════════════════════════════════════════════════════

	proc write_cmd {cmd} {
		if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "timemore_dot"} {
			return
		}
		if {[ifexists ::sinstance($::de1(suuid_timemore_dot))] == ""} {
			return
		}
		userdata_append "SCALE: Timemore Dot cmd" [list ble write \
			$::de1(scale_device_handle) \
			$::de1(suuid_timemore_dot) $::sinstance($::de1(suuid_timemore_dot)) \
			$::de1(cuuid_timemore_dot_cmd) $::cinstance($::de1(cuuid_timemore_dot_cmd)) \
			$cmd] 0
	}

	# ══════════════════════════════════════════════════════
	# Weight notification enable
	# ══════════════════════════════════════════════════════

	proc enable_weight_notifications {} {
		if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "timemore_dot"} {
			return
		}
		if {[ifexists ::sinstance($::de1(suuid_timemore_dot))] == ""} {
			msg -DEBUG "Timemore Dot not connected, cannot enable weight notifications"
			return
		}
		userdata_append "SCALE: enable Timemore Dot weight notifications" [list ble enable \
			$::de1(scale_device_handle) \
			$::de1(suuid_timemore_dot) $::sinstance($::de1(suuid_timemore_dot)) \
			$::de1(cuuid_timemore_dot_status) $::cinstance($::de1(cuuid_timemore_dot_status))] 1
	}

	# ══════════════════════════════════════════════════════
	# Init sequence (from HCI snoop log of official Timemore app)
	# Sent twice with delays, then state poll, then periodic polling
	# ══════════════════════════════════════════════════════

	proc send_init_sequence {} {
		if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "timemore_dot"} {
			return
		}
		if {[ifexists ::sinstance($::de1(suuid_timemore_dot))] == ""} {
			msg -DEBUG "Timemore Dot not connected, cannot send init sequence"
			return
		}

		msg -NOTICE "Timemore Dot: sending init sequence"

		set init_cmds [list \
			[binary decode hex "A55A021300000000"] \
			[binary decode hex "A55A020800000000"] \
			[binary decode hex "A55A020500000000"] \
			[binary decode hex "A55A020200000000"] \
			[binary decode hex "A55A020600000000"] \
			[binary decode hex "A55A020C00000000"] \
		]

		# First pass
		set delay 100
		foreach cmd $init_cmds {
			after $delay [list ::plugins::timemore_dot::write_cmd $cmd]
			incr delay 150
		}

		# Second pass (official app sends init commands twice)
		incr delay 300
		foreach cmd $init_cmds {
			after $delay [list ::plugins::timemore_dot::write_cmd $cmd]
			incr delay 150
		}

		# Initial state poll
		incr delay 300
		after $delay ::plugins::timemore_dot::send_poll

		# Start periodic keepalive polling (10 second interval)
		after [expr {$delay + 500}] ::plugins::timemore_dot::start_polling

		msg -NOTICE "Timemore Dot: init sequence scheduled"
	}

	# ══════════════════════════════════════════════════════
	# Periodic polling / keepalive
	# Official app polls ~15 sec; we poll every 10 sec for reliability
	# ══════════════════════════════════════════════════════

	proc send_poll {} {
		if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "timemore_dot"} {
			return
		}
		if {[ifexists ::sinstance($::de1(suuid_timemore_dot))] == ""} {
			return
		}
		set poll1 [binary decode hex "A55A020800000000"]
		set poll2 [binary decode hex "A55A030800020100000025"]

		write_cmd $poll1
		after 100 [list ::plugins::timemore_dot::write_cmd $poll2]
	}

	proc start_polling {} {
		if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "timemore_dot"} {
			return
		}
		catch {after cancel ::plugins::timemore_dot::poll_tick}
		poll_tick
	}

	proc poll_tick {} {
		if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "timemore_dot"} {
			return
		}
		send_poll
		after 10000 ::plugins::timemore_dot::poll_tick
	}

	# ══════════════════════════════════════════════════════
	# Tare command
	# A5 5A 03 0D 00 02 00 00 00 71 (10 bytes)
	# Confirmed from HCI snoop log: write #20689, #21285
	# Sends poll first to ensure scale is responsive
	# ══════════════════════════════════════════════════════

	proc tare {} {
		if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "timemore_dot"} {
			return
		}
		if {[ifexists ::sinstance($::de1(suuid_timemore_dot))] == ""} {
			msg -ERROR "Timemore Dot not connected, cannot send tare cmd"
			return
		}

		msg -NOTICE "Timemore Dot: sending tare command"

		set tare_cmd [binary decode hex "A55A030D000200000071"]

		send_poll
		after 200 [list ::plugins::timemore_dot::write_cmd $tare_cmd]
	}

	# ══════════════════════════════════════════════════════
	# Timer control
	# ══════════════════════════════════════════════════════

	proc start_timer {} {
		if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "timemore_dot"} {
			return
		}
		if {[ifexists ::sinstance($::de1(suuid_timemore_dot))] == ""} {
			msg -DEBUG "Timemore Dot not connected, cannot start timer"
			return
		}
		# A5 5A 03 02 00 01 01 00 20
		set cmd [binary decode hex "A55A03020001010020"]
		write_cmd $cmd
	}

	proc stop_timer {} {
		if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "timemore_dot"} {
			return
		}
		if {[ifexists ::sinstance($::de1(suuid_timemore_dot))] == ""} {
			msg -DEBUG "Timemore Dot not connected, cannot stop timer"
			return
		}
		# A5 5A 03 02 00 01 02 FF D0
		set cmd [binary decode hex "A55A030200010200FFD0"]
		write_cmd $cmd
	}

	proc reset_timer {} {
		if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "timemore_dot"} {
			return
		}
		if {[ifexists ::sinstance($::de1(suuid_timemore_dot))] == ""} {
			msg -DEBUG "Timemore Dot not connected, cannot reset timer"
			return
		}
		# A5 5A 03 02 00 01 03 FF 81
		set cmd [binary decode hex "A55A030200010300FF81"]
		write_cmd $cmd
	}

	# ══════════════════════════════════════════════════════
	# Packet parsing
	# Notify packet: A5 5A [type] [stat] .. .. .. .. [WH] [WL] ...
	#   type 0x01 = weight data (other types: 0x02=response, 0x03=ACK)
	#   Weight: bytes[8:9], signed 16-bit big-endian, /10.0 for grams
	# ══════════════════════════════════════════════════════

	proc parse_response { value } {

		if {[string length $value] < 10} {
			return
		}

		binary scan $value cucucucucucucucucucu b0 b1 pktType b3 b4 b5 b6 b7 wH wL

		# Validate A5 5A header
		if {$b0 != 0xA5 || $b1 != 0x5A} {
			return
		}

		# Only process weight packets (type 0x01)
		if {$pktType != 0x01} {
			return
		}

		# Combine bytes 8-9 as signed 16-bit big-endian
		set raw_weight [expr {($wH << 8) | $wL}]
		if {$raw_weight > 32767} {
			set raw_weight [expr {$raw_weight - 65536}]
		}

		# Convert to grams (raw is in 0.1g units)
		set weight [expr {$raw_weight / 10.0}]

		::device::scale::process_weight_update $weight
	}

}
