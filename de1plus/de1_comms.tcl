package provide de1_comms 1.1

package require de1_bluetooth
package require de1_logging 1.2
package require lambda

### Globals
set ::failed_attempt_count_connecting_to_de1 0
set ::successful_de1_connection_count 0

## Helper

proc int_to_hex {in} {
	return [format %02X $in]
}

proc long_to_little_endian_hex {in} {
	set i [format %04X $in]
	set i2 "[string range $i 2 3][string range $i 0 1]"
	return $i2
}

# 4-byte little-endian hex for a 32-bit unsigned int. Companion to
# long_to_little_endian_hex above (which only handles 16 bits despite the name).
proc long32_to_little_endian_hex {val} {
	set v [expr {$val & 0xFFFFFFFF}]
	set b0 [expr {$v & 0xFF}]
	set b1 [expr {($v >> 8) & 0xFF}]
	set b2 [expr {($v >> 16) & 0xFF}]
	set b3 [expr {($v >> 24) & 0xFF}]
	return [format "%02X%02X%02X%02X" $b0 $b1 $b2 $b3]
}

# msg -DEBUG "::comms exists: [namespace exists ::comms]" (no)

namespace eval ::comms {

	proc ::comms::msg {first args} {

		if { ![::logging::ble_log_enabled $first] } return
		::logging::default_logger $first "de1_comms:" {*}$args
	}
}

proc comms_msg {args} {
	if {$::settings(comms_debugging) == 1} {
		::comms::msg {*}$args
	}
}

proc userdata_append {comment cmd {vital 0} } {
	#set cmds [ble userdata $::de1(device_handle)]
	#lappend cmds $cmd
	#ble userdata $::de1(device_handle) $cmds
	lappend ::de1(cmdstack) [list $comment $cmd $vital]

	set qlen [llength $::de1(cmdstack)]

	::comms::msg -INFO "ENQ ($qlen): $comment"

	if {$qlen >= 50} {
		::comms::msg -WARNING "Warning, BLE queue is $qlen long"
	}
	run_next_userdata_cmd
}


proc run_next_userdata_cmd {} {
	if {$::has_bluetooth} {
		# with real BLE, only write one BLE command at a time
		if {$::de1(wrote) == 1} {
			return
		}
	}
	if {($::de1(device_handle) == "0" || $::de1(device_handle) == "1") && $::de1(scale_device_handle) == "0"} {
		comms_msg -DEBUG "run_next_userdata_cmd error: de1 not connected"
		return
	}

	if {$::de1(cmdstack) ne {}} {

		set cmd [lindex $::de1(cmdstack) 0]
		set cmds [lrange $::de1(cmdstack) 1 end]
		set vital [lindex $cmd 2]

		set result 0

		set _comment [lindex $cmd 0]
		set _cmd [lindex $cmd 1]
		set _cmd_command [lindex $_cmd 0]
		set _readable ""

		# PERF: $_readable is used ONLY in the -INFO "DEQ" log line just below,
		# which is suppressed at the default BLE log level. Building it
		# (format_ble_command / format_map_asc_bin / format_mmr) ran on every
		# dequeued command and was then discarded -- wasted work right on the BLE
		# write path that backs up the command queue. Build it only when that log
		# line would actually be emitted. Behavior-preserving.
		if { [::logging::ble_log_enabled -INFO] } {
			if { $_cmd_command == "ble" } {

			    set _readable [::logging::format_ble_command $_cmd]

			} elseif { $_cmd_command == "de1_comm" \
					   && [lindex $_cmd 2] in {
					       "WriteToMMR"
					       "ReadFromMMR"
					   } } {

			    set _readable [format "%s %s" \
						   [lindex $_cmd 2] \
						   [::logging::format_mmr [lindex $_cmd 3]] ]
			} else {

			    set _readable  [::logging::format_map_asc_bin $_cmd]
			}
		}

		::comms::msg -INFO "DEQ ([llength $::de1(cmdstack)]) >>>" \
			[expr { [string length $_comment] \
					? "$_comment: " : "" }] \
			"$_readable"


		# setting "wrote" to 1 before running the command, so that if the command is not a BLE operation, it can choose to unset "wrote" and cause the cmd stack to continue unspooling
		set ::de1(wrote) 1

		set eer ""
		set errcode [catch {
			set result [{*}[lindex $cmd 1]]
		} eer]

		if {$errcode != 0} {
			catch {
				::comms::msg -ERROR "run_next_userdata_cmd catch error: $::errorInfo"
			}
		}

		if {$result != 1} {
			set ::de1(wrote) 0

			# $::errorInfo is a global. It only reflects THIS command when the
			# command actually threw (errcode != 0). When errcode == 0 (e.g. the
			# write function simply returned "" because the DE1 is not connected),
			# $::errorInfo still holds a stale, unrelated error from elsewhere in
			# the app, so we must neither log it nor match against it -- otherwise
			# we report misleading garbage (this is what produced the bogus
			# "!::debugging" / "round($in)" messages on the ShotSettings retries).
			set threw [expr {$errcode != 0}]
			if {$threw} {
				msg -ERROR "BLE error info $::errorInfo"
			}

			if {[ifexists ::sinstance($::de1(suuid))] == ""} {
				# The DE1 is not connected, so this command could not be sent.
				# That is not a command failure: do NOT retry a vital command in
				# a tight 500ms loop (which spams the log forever, e.g. when a
				# scale is connected but no DE1 is). Drop it and let the queue
				# drain; settings are re-sent when the DE1 reconnects.
				::comms::msg -NOTICE "Preceeding command not sent because the DE1 is not connected; not retrying:" \
					[::logging::format_map_asc_bin [lindex $cmd 1]]

			} elseif {$threw && [string first "invalid handle" $::errorInfo] != -1 } {
				::comms::msg -INFO "Not retrying this command because BLE handle for the device is now invalid, 1='[lindex $cmds 1]' 2='[lindex $cmds 2]' 3='[lindex $cmds 3]' vital='$vital'"

				if {[string first {$::de1(device_handle)} $::errorInfo] != -1 } {
					::comms::msg -INFO "Processing DE1 disconnect/bad handle"
					de1_disconnect_handler $::de1(device_handle)
					set ::de1(device_handle) 0
					#return
				}

				if {[string first {$::de1(scale_device_handle)} $::errorInfo] != -1 } {
					::comms::msg -INFO "Processing scale disconnect/bad handle"
					scale_disconnect_handler $::de1(scale_device_handle)
					return
				}

				#after 500 run_next_userdata_cmd
			} elseif {$vital != 1 } {
				::comms::msg -NOTICE "Preceeding command failed; not retrying as not tagged as vital"
				#after 500 run_next_userdata_cmd
			} else {

				::comms::msg -WARNING "BLE command failed, will retry ($result):" \
					[::logging::format_map_asc_bin [lindex $cmd 1]] \
					"($eer)" \
					[expr { $threw ?  $::errorInfo : "" }]

				# test idea to keep scale from interference with DE1
				#if {$::de1(scale_device_handle) != 0} {
				#	ble abort $::de1(scale_device_handle)
				#}

				# john 4/28/18 not sure if we should give up on the command if it fails, or retry it
				# retrying a command that will forever fail kind of kills the BLE abilities of the app

				after 500 run_next_userdata_cmd
				#update
				return
			}
		}

		set ::de1(cmdstack) $cmds
		set ::de1(previouscmd) [lindex $cmd 1]
		if {[llength $::de1(cmdstack)] == 0} {
			::comms::msg -INFO "command queue is now empty"
		} else {
			::comms::msg -INFO "HEAD ([llength $::de1(cmdstack)]) >>>" \
			[lindex [lindex $::de1(cmdstack) 0] 0] 
		}

		# try the bluetooth stack in a second, in case there were no bluetooth commands succeeded
		# and thus the queue doesn't keep getting tried
		after 1000 run_next_userdata_cmd

	} else {
		#
	}
}

### Generics
proc de1_comm {action command_name {data 0}} {
	comms_msg -DEBUG "de1_comm sending action $action command $command_name data \"$data\""
	if {$::de1(connectivity) == "ble"} {
		return [de1_ble $action $command_name $data]
	} else {
		error "Unknown connectivity: $::de1(connectivity)"
	}
}

proc append_to_de1_list {address name type} {

	# Replace any existing entry for the same address rather than
	# early-returning -- the legacy "duplicate skip" behaviour caused
	# stale names to persist across firmware swaps (e.g. the Bengle_BLE
	# Mynewt port renamed the advertised device "DE1" -> "Bengle", but
	# the list was seeded from settings.tdb at startup with the old
	# name and the scan never overwrote it, so settings(model) stayed
	# "DE1" -> use_ble_v2 returned false -> v1 protocol decoding was
	# applied to v2-encoded ShotSample fields).
	set newlist {}
	foreach { entry } $::de1_device_list {
		if { [dict get $entry address] ne $address} {
			lappend newlist $entry
		}
	}
	lappend newlist [dict create address $address name $name type $type]
	::comms::msg -NOTICE "Scan found DE1: $address ($name)"
	set ::de1_device_list $newlist
	catch {
		fill_ble_listbox
	}
}

### Handler
proc de1_connect_handler { handle address name} {

	if {$::settings(scale_bluetooth_address) != ""} {
		ble_connect_to_scale
	}

	incr ::successful_de1_connection_count
	set ::failed_attempt_count_connecting_to_de1 0

	set ::de1(wrote) 0
	set ::de1(cmdstack) {}
	set ::de1(connect_time) [clock seconds]
	set ::de1(last_ping) [clock seconds]
	set ::currently_connecting_de1_handle 0

	set ::de1(device_handle) $handle
	append_to_de1_list $address $name "ble"

	if {[ifexists ::de1(in_fw_update_mode)] == 1} {
		::comms::msg -NOTICE "in_fw_update_mode : de1 connected"

		::comms::msg -NOTICE "Tell DE1 to start to go to SLEEP (so it's asleep during firmware upgrade)"
		de1_send_state "go to sleep" $::de1_state(Sleep)
		set_fan_temperature_threshold 60
	} else {
		de1_enable_mmr_notifications

		set dothis 1
		if {$dothis == 1} {
			de1_enable_temp_notifications
			de1_enable_bengleshotsample_notifications ;# Additive: 0xA013 (no-op on a stock DE1)

			if {[info exists ::de1(first_connection_was_made)] != 1} {
				# on app startup, wake the machine up
				set ::de1(first_connection_was_made) 1
				start_idle
			}

			read_de1_state
		}

		read_de1_version

	}
}

proc de1_event_handler { command_name value {update_received 0}} {

	if { $update_received == 0 } { set update_received [expr {[clock milliseconds] / 1000.0}] }

	set previous_wrote 0
	set previous_wrote [ifexists ::de1(wrote)]

	error "Got de1_event_handler command: $command_name"

	# change notification or read request
	#de1_comm_new_value $cuuid $value
	# change notification or read request
	#de1_comm_new_value $cuuid $value

	if {$command_name eq "ShotSample"} {
		set ::de1(last_ping) [clock seconds]
		::de1::state::update::from_shotvalue $value $update_received
		#set ::de1(wrote) 0
		#run_next_userdata_cmd
		set do_this 0
		if {$do_this == 1} {
			# this tries to handle bad write situations, but it might have side effects if it is not working correctly.
			# probably this should be adding a command to the top of the write queue
			if {$previous_wrote == 1} {
				::comms::msg -ERROR "BLE: bad write reported"
				{*}$::de1(previouscmd)
				set ::de1(wrote) 1
				return
			}
		}
	} elseif {$command_name eq "ReadFromMMR"} {
		# MMR read

		::comms::msg -NOTICE "MMR read: '[::logging::format_mmr $value]'"

		parse_binary_mmr_read $value arr
		set mmr_id [string to upper $arr(Address)]
		set mmr_val [ifexists arr(Data0)]

		parse_binary_mmr_read_int $value arr2

		::comms::msg -NOTICE "MMR ID: '$mmr_id'"

		if {$mmr_id == "80381C"} {
			::comms::msg -INFO "Read: GHC is installed: '$mmr_val'"
			set_ghc_is_installed_from_machine $mmr_val

		} elseif {$mmr_id == "803808"} {
			set ::de1(fan_threshold) $mmr_val
			set ::settings(fan_threshold) $mmr_val
			::comms::msg -INFO "MMRead: Fan threshold: '$mmr_val'"

		} elseif {$mmr_id == "80380C"} {
			::comms::msg -INFO "MMRead: tank temperature threshold: '$mmr_val'"
			set ::de1(tank_temperature_threshold) $mmr_val

		} elseif {$mmr_id == "803820"} {
			::comms::msg -INFO "MMRead: group head control mode: '$mmr_val'"
			set ::settings(ghc_mode) $mmr_val

		} elseif {$mmr_id == "803828"} {
			::comms::msg -INFO "MMRead: steam flow: '$mmr_val'"
			set ::settings(steam_flow) $mmr_val

		} elseif {$mmr_id == "803830"} {
			::comms::msg  -INFO "MMR read: sn: '$mmr_val' [array get arr2]"

			set sn [ifexists arr2(Data0)]
			
			if {$sn != "" && $sn != 0} {
				set ::settings(sn) $sn
			}

			# dupe copy, of what we receive via firmware so we can NOT let them change it if we did receive it via BLE
			set ::de1(sn) $sn

		} elseif {$mmr_id == "8038AC"} {
			# CupWarmerMode (0=Off, 1=On). RAM only on FW side.
			::comms::msg -INFO "MMRead: cupwarmer_mode: '$mmr_val'"
			set ::de1(cupwarmer_mode) $mmr_val

		} elseif {$mmr_id == "8038B4"} {
			# MatHeaterDrivePct 0-100. Shown on the cup warmer page as "Heating - N%".
			set ::de1(mat_heater_drive) $mmr_val

		} elseif {$mmr_id == "8038B8"} {
			# MatTempFault 0=OK, 1=OpenOrShort, 2=Runaway. Shown on the cup
			# warmer page as the NTC-disconnected warning.
			::comms::msg -INFO "MMRead: mat_temp_fault: '$mmr_val'"
			set ::de1(mat_temp_fault) $mmr_val
		} elseif {$mmr_id == "803890"} {
			# FrontLEDColor. Diagnostic only — app settings are source-of-truth.
			set led_int [ifexists arr2(Data0)]
			::comms::msg -INFO "MMRead: FrontLEDColor: [::led::int_to_hex $led_int] (raw $led_int)"

		} elseif {$mmr_id == "803894"} {
			# RearLEDColor. Diagnostic only.
			set led_int [ifexists arr2(Data0)]
			::comms::msg -INFO "MMRead: RearLEDColor: [::led::int_to_hex $led_int] (raw $led_int)"

		} elseif {$mmr_id == "80385C"} {
			::comms::msg -NOTICE "MMRead: get_refill_kit_present: '$mmr_val'"

			set ::de1(refill_kit_detected) $mmr_val

		} elseif {$mmr_id == "803818"} {
			::comms::msg -INFO "MMRead: hot_water_idle_temp: '[ifexists arr2(Data0)]'"
			set ::settings(hot_water_idle_temp) [ifexists arr2(Data0)]

			#mmr_read "espresso_warmup_timeout" "803838" "00"

		} elseif {$mmr_id == "803838"} {
			::comms::msg -INFO "MMRead: espresso_warmup_timeout: '[ifexists arr2(Data0)]'"
			set ::settings(espresso_warmup_timeout) [ifexists arr2(Data0)]

		} elseif {$mmr_id == "803810"} {
			::comms::msg -INFO "MMRead: phase_1_flow_rate: '[ifexists arr2(Data0)]'"
			set ::settings(phase_1_flow_rate) [ifexists arr2(Data0)]

			if {[ifexists arr(Len)] >= 4} {
			::comms::msg -INFO "MMRead: phase_2_flow_rate: '[ifexists arr2(Data1)]'"
				set ::settings(phase_2_flow_rate) [ifexists arr2(Data1)]
			}
			if {[ifexists arr(Len)] >= 8} {
				::comms::msg -INFO "MMRead: hot_water_idle_temp: '[ifexists arr2(Data2)]'"
				set ::settings(hot_water_idle_temp) [ifexists arr2(Data2)]
			}

		} elseif {$mmr_id == "803834"} {
			#parse_binary_mmr_read_int $value arr2

			::comms::msg -INFO "MMRead: heater voltage: '[ifexists arr2(Data0)]' len=[ifexists arr(Len)]"
			set ::settings(heater_voltage) [ifexists arr2(Data0)]

			catch {
				if {[ifexists ::settings(firmware_version_number)] != ""} {
					if {$::settings(firmware_version_number) >= 1142} {
						if {$::settings(heater_voltage) == 0} {
							::comms::msg -WARNING "Heater voltage is unknown, please set it"
							show_settings calibrate2
						}
					}
				}
			}

			if {[ifexists arr(Len)] >= 8} {
				::comms::msg -INFO "MMRead: espresso_warmup_timeout2: '[ifexists arr2(Data1)]'"
				set ::settings(espresso_warmup_timeout) [ifexists arr2(Data1)]

				#mmr_read "hot_water_idle_temp" "803818" "00"
				mmr_read "phase_1_flow_rate" "803810" "02"
			}


		} elseif {$mmr_id == "800008"} {
			#parse_binary_mmr_read_int $value arr2

			if {[ifexists arr(Len)] == 12} {
				# it's possibly to read all 3 MMR characteristics at once

				# CPU Board Model * 1000. eg: 1100 = 1.1
				::comms::msg -INFO "MMRead: CPU board model: '[ifexists arr2(Data0)]'"
				set ::settings(cpu_board_model) [ifexists arr2(Data0)]

				# v1.3+ Firmware Model (Unset = 0, DE1 = 1, DE1Plus = 2, DE1Pro = 3, DE1XL = 4, DE1Cafe = 5)
				::comms::msg -INFO "MMRead: machine model:  '[ifexists arr2(Data1)]'"
				set ::settings(machine_model) [ifexists arr2(Data1)]

				# CPU Board Firmware build number. (Starts at 1000 for 1.3, increments by 1 for every build)
				::comms::msg -INFO "MMRead: firmware version number: '[ifexists arr2(Data2)]'"
				set ::settings(firmware_version_number) [ifexists arr2(Data2)]

			} else {
				# CPU Board Model * 1000. eg: 1100 = 1.1
				::comms::msg -INFO "MMRead: CPU board model: '[ifexists arr2(Data0)]'"
				set ::settings(cpu_board_model) [ifexists arr2(Data0)]
			}

		} elseif {$mmr_id == "80000C"} {
			parse_binary_mmr_read_int $value arr2

			# v1.3+ Firmware Model (Unset = 0, DE1 = 1, DE1Plus = 2, DE1Pro = 3, DE1XL = 4, DE1Cafe = 5)
			::comms::msg -INFO "MMRead: machine model:  '[ifexists arr2(Data0)]'"
			set ::settings(machine_model) [ifexists arr2(Data0)]

		} elseif {$mmr_id == "800010"} {
			parse_binary_mmr_read_int $value arr2

			# CPU Board Firmware build number. (Starts at 1000 for 1.3, increments by 1 for every build)
			::comms::msg -INFO "MMRead: firmware version number: '[ifexists arr2(Data0)]'"
			set ::settings(firmware_version_number) [ifexists arr2(Data0)]

		} elseif {$mmr_id == "80382C"} {
			::comms::msg -INFO "MMRead: steam_highflow_start: '$mmr_val'"
			set ::settings(steam_highflow_start) $mmr_val

		} elseif {$mmr_id == "803874"} {
			::comms::msg -INFO "MMRead: cupwarmer_temp: '$mmr_val'"
			set ::de1(cupwarmer_temp) $mmr_val

		} else {
		    ::comms::msg -INFO "MMR read (undecoded): '[::logging::format_mmr $value]'"
		}

	} elseif {$command_name eq "Version"} {
		set ::de1(last_ping) [clock seconds]
		#update_de1_state $value
		parse_binary_version_desc $value arr2
		set ::de1(version) [array get arr2]

		set v [de1_version_string]

		::comms::msg -DEBUG "version data received: '$v' from [::logging::format_asc_hex $value]"

		# run stuff that depends on the BLE API version
		later_new_de1_connection_setup

		set ::de1(wrote) 0
		run_next_userdata_cmd

	} elseif {$command_name eq "Calibration"} {
		#set ::de1(last_ping) [clock seconds]
		calibration_received $value

	} elseif {$command_name eq "WaterLevels"} {
		set ::de1(last_ping) [clock seconds]
		parse_binary_water_level $value arr2

		# compensate for the fact that we measure water level a few mm higher than the water uptake point
		set mm [expr {$arr2(Level) + $::de1(water_level_mm_correction)}]
		set ::de1(water_level) $mm

	} elseif {$command_name eq "FWMapRequest"} {
		#set ::de1(last_ping) [clock seconds]
		parse_map_request $value arr2
		::comms::msg -DEBUG "FWMapRequest (a009): [array get arr2]"

		if {$::de1(currently_erasing_firmware) == 1 && [ifexists arr2(FWToErase)] == 0} {
			::comms::msg -NOTICE "BLE recv: finished erasing fw '[ifexists arr2(FWToMap)]'"
			set ::de1(currently_erasing_firmware) 0
			#write_firmware_now

		} elseif {$::de1(currently_erasing_firmware) == 1 && [ifexists arr2(FWToErase)] == 1} {
			::comms::msg -NOTICE "BLE recv: currently erasing fw '[ifexists arr2(FWToMap)]'"
			#after 1000 read_fw_erase_progress

		} elseif {$::de1(currently_erasing_firmware) == 0 && [ifexists arr2(FWToErase)] == 0} {
			::comms::msg -ERROR "BLE firmware find error BLE recv: '$value' [array get arr2]'"

		    if {[ifexists arr2(FirstError1)] == [expr 0xFF] \
				&& [ifexists arr2(FirstError2)] == [expr 0xFF] \
				&& [ifexists arr2(FirstError3)] == [expr 0xFD]} {
				set ::de1(firmware_update_button_label) "Updated"

			} else {
				set ::de1(firmware_update_button_label) "Update failed"
			}

			set ::de1(currently_updating_firmware) 0

		} else {
		    ::comms::msg -ERROR "unknown firmware cmd ack:" \
			    [::logging::format_asc_bin $value] \
			    ": [array get arr2]"
		}

	} elseif {$command_name eq "ShotSettings"} {
		set ::de1(last_ping) [clock seconds]
		#update_de1_state $value
		parse_binary_hotwater_desc $value arr2
		::comms::msg -INFO "hotwater data received:" \
			    [::logging::format_asc_bin $value] \
			    ": [array get arr2]"

		#update_de1_substate $value

	} elseif {$command_name eq "DeprecatedShotDesc"} {
		set ::de1(last_ping) [clock seconds]
		#update_de1_state $value
		parse_binary_shot_desc $value arr2
		::comms::msg -INFO "shot data received:" \
			[::logging::format_asc_bin $value] \
			": [array get arr2]"

	} elseif {$command_name eq "HeaderWrite"} {
		set ::de1(last_ping) [clock seconds]
		#update_de1_state $value
		parse_binary_shotdescheader $value arr2
		::comms::msg -INFO "READ shot header success:" \
			[::logging::format_asc_bin $value] \
			": [array get arr2]"

	} elseif {$command_name eq "FrameWrite"} {
		set ::de1(last_ping) [clock seconds]
		#update_de1_state $value
		parse_binary_shotframe $value arr2
		::comms::msg -INFO "shot frame received" \
			[::logging::format_adc_bin $value] \
			": [array get arr2]"

	} elseif {$command_name eq "StateInfo"} {
		set ::de1(last_ping) [clock seconds]
		update_de1_state $value

		#if {[info exists ::globals(if_in_sleep_move_to_idle)] == 1} {
		#	unset ::globals(if_in_sleep_move_to_idle)
		#	if {$::de1_num_state($::de1(state)) == "Sleep"} {
				# when making a new connection to the espresso machine, if the machine is currently asleep, then take it out of sleep
				# but only do this check once, right after connection establisment
		#		start_idle
		#	}
		#}
		#update_de1_substate $value

		set ::de1(wrote) 0

		run_next_userdata_cmd
	}
}

proc scale_disconnect_handler { handle } {
	catch {
		ble close $handle
	}

	# if the skale connection closed in the currentl one, then reset it
	set ::de1(scale_device_handle) 0

	if {$::currently_connecting_scale_handle == 0} {
		#ble_connect_to_scale
	}

	catch {
		ble close $::currently_connecting_scale_handle
	}

	set ::currently_connecting_scale_handle 0
	# 2021-11-25 Johanna: Removed to see if it is the cause for the lunar connection issues
	#remove_matching_ble_queue_entries {^SCALE:}

	catch {
		set event_dict [dict create \
			event_time $event_time \
			address $address \
		]

		::device::scale::event::apply::on_disconnect_callbacks $event_dict
	}

	if {$::de1(bluetooth_scale_connection_attempts_tried) < $::de1(scale_max_connection_retry_attempts)} {
		incr ::de1(bluetooth_scale_connection_attempts_tried)
		::bt::msg -INFO "Disconnected from scale, trying again automatically.  Attempts=$::de1(bluetooth_scale_connection_attempts_tried)"
		ble_connect_to_scale
	} else {
		# after 5 minutes, reset the scale retrier count back to zero that when coming back 
		# to the DE1 after some time away, we can again retry scale connection 
		::bt::msg -INFO "Resetting scale connect retries back to zero, after 300 second waiting"
		after 300000 "set ::de1(bluetooth_scale_connection_attempts_tried) 0"
	}
}

proc de1_disconnect_handler { handle } {
	set ::de1(wrote) 0
	set ::de1(cmdstack) {}

	# close the associated handle
	catch {
		ble close $handle
	}

	set ::de1(device_handle) 0

	# Invalidate the LED write-dedup cache — if the machine is power-cycled
	# or externally reset while we're disconnected, its MMRs may come back
	# with different values. Forcing the next push to actually write avoids
	# leaving the hardware in a stale state that matches our cache.
	if {[info exists ::led::_last_written]} {
		array set ::led::_last_written {front "" rear ""}
	}


	catch {
		# this should no longer be necessary since we're now explicitly closing the BLE handle associated with this disconnection notice
		if {$handle != $::currently_connecting_de1_handle} {
			::comms::msg -ERROR "Disconnected handle is not currently_connecting_de1_handle - closing it now though, something might not be right"
			ble close $::currently_connecting_de1_handle
		}
	}

	set ::currently_connecting_de1_handle 0

	::comms::msg -NOTICE "de1 disconnected"
	set ::de1(device_handle) 0

	# temporarily disable this feature as it's not clear that it's needed.
	#set ::settings(max_ble_connect_attempts) 99999999
	set ::settings(max_ble_connect_attempts) 10

	if {[android_8_or_newer] == 1} {
		set ::settings(max_ble_connect_attempts) 99999999
	}

	incr ::failed_attempt_count_connecting_to_de1
	if {$::failed_attempt_count_connecting_to_de1 > $::settings(max_ble_connect_attempts) && $::successful_de1_connection_count > 0} {
		# if we have previously been connected to a DE1 but now can't connect, then make the UI go to Sleep
		# and we'll try again to reconnect when the user taps the screen to leave sleep mode

		# set this to zero so that when we come back from sleep we try several times to connect
		set ::failed_attempt_count_connecting_to_de1 0

		update_de1_state "$::de1_state(Sleep)\x0"
	} else {

		if {[ifexists ::de1(disable_de1_reconnect)] != 1} {
			ble_connect_to_de1
		}
	}
}

### Commands
proc read_de1_version {} {
	::comms::msg -NOTICE "read_de1_version"
	catch {
		userdata_append "read_de1_version" [list de1_comm read Version] 1
	}
}

# repeatedly request de1 state
# DEAD CODE as of 2026-08-18: nothing in the tree calls this, and it must stay
# that way. It re-reads StateInfo every second FOREVER (it re-arms itself and has
# no stop condition), which on a real BLE connection means a permanent 1 Hz command
# in the userdata queue competing with genuine traffic. The one-shot read at
# connect (later_new_de1_connection_setup -> `after 5000 read_de1_state`) is what
# the app actually needs. If this warning ever appears, find the caller and delete
# it rather than letting the poll run.
proc poll_de1_state {} {
	set _caller "top level or after-timer"
	catch { set _caller [info level -1] }
	::comms::msg -WARNING "poll_de1_state: DEAD CODE CALLED --" \
		"this starts a permanent 1 Hz StateInfo poll and should not be used." \
		"Caller: '$_caller'"
	::comms::msg -DEBUG "poll_de1_state"
	read_de1_state
	after 1000 poll_de1_state
}

proc read_de1_state {} {
	::comms::msg -NOTICE "read_de1_state"
	if {!$::has_bluetooth} {
		return
	}
	if {[catch {
		userdata_append "read de1 state" [list de1_comm read StateInfo] 1
	} err] != 0} {
		::comms::msg -ERROR "Failed to 'read de1 state' in DE1 BLE because: '$err'"
	}
}


# calibration change notifications ENABLE
proc de1_enable_calibration_notifications {} {
	::comms::msg -NOTICE "de1_enable_calibration_notifications"
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 1"
		return
	}
	userdata_append "enable de1 calibration notifications" [list de1_comm enable Calibration] 1
}

# calibration change notifications DISABLE
proc de1_disable_calibration_notifications {} {
	::comms::msg -NOTICE de1_disable_calibration_notifications
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 2"
		return
	}
	userdata_append "disable de1 calibration notifications" [list de1_comm disable Calibration)] 1
}

# temp changes
proc de1_enable_temp_notifications {} {
	::comms::msg -NOTICE de1_enable_temp_notifications
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 3"
		return
	}
	userdata_append "enable de1 temp notifications" [list de1_comm  enable "ShotSample"] 1
}

# Additive BLE: subscribe to the Bengle high-resolution shot sample
# characteristic (BengleShotSample, 0xA013).  Only a Bengle exposes it; a stock
# DE1 does not, so we must NOT enqueue the enable there.  The enable is vital,
# and on a stock DE1 de1_ble would throw on the unset ::cinstance(0xA013); the
# vital-retry path then re-runs it every 500ms WITHOUT advancing the FIFO,
# permanently stalling the whole BLE command queue (blocking the version/state
# reads, profile/MMR writes, etc.).  Gate on the discovered characteristic
# instance -- discovery populates ::cinstance for present characteristics before
# this connect-time enable runs (the temp/state enables rely on the same).
proc de1_enable_bengleshotsample_notifications {} {
	::comms::msg -NOTICE de1_enable_bengleshotsample_notifications
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot enable BengleShotSample notifications"
		return
	}
	if {![info exists ::cinstance($::de1(cuuid_13))]} {
		::comms::msg -DEBUG "BengleShotSample (0xA013) not present on this machine (stock DE1); skipping enable"
		return
	}
	userdata_append "enable de1 bengleshotsample notifications" [list de1_comm  enable "BengleShotSample"] 1
}

# status changes
proc de1_enable_state_notifications {} {
	::comms::msg -NOTICE de1_enable_state_notifications
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 4"
		return
	}
	userdata_append "enable de1 state notifications" [list de1_comm  enable "StateInfo"] 1
}

proc de1_disable_temp_notifications {} {
	::comms::msg -NOTICE de1_disable_temp_notifications
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 5"
		return
	}
	userdata_append "disable temp notifications" [list de1_comm  disable "ShotSample"] 1
}

proc de1_disable_state_notifications {} {
	::comms::msg -NOTICE de1_disable_state_notifications
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 6"
		return
	}
	userdata_append "disable state notifications" [list de1_comm  disable "StateInfo"] 1
}

set ::mmr_enabled ""
proc mmr_available {} {
	#return 0

	if {$::mmr_enabled == ""} {

		if {$::de1(version) == ""} {
			# if the version hasn't been loaded yet, use what's in the saved settings from the last time the app ran
			return $::settings(mmr_enabled)
		} else {
			# look for the version string to determin if MMR is available
			if {[de1_version_bleapi] > 3} {
				# mmr feature became available at this version number
				set ::settings(mmr_enabled) 1
			} else {
				::comms::msg -NOTICE "MMR is not enabled on this DE1 BLE API <4 #: [de1_version_bleapi]"
				set ::settings(mmr_enabled) 0
			}

			save_settings

			set ::mmr_enabled $::settings(mmr_enabled)
		}

	}
	return $::mmr_enabled
}

proc de1_enable_mmr_notifications {} {
	::comms::msg -NOTICE de1_enable_mmr_notifications
	if {[mmr_available] == 0} {
		::comms::msg -NOTICE "Unable to de1_enable_mmr_notifications because MMR not available"
		return
	}

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 7"
		return
	}

	#userdata_append "enable MMR write notifications" [list de1_comm  enable "WriteToMMR"] 1
	userdata_append "enable MMR read notifications" [list de1_comm enable "ReadFromMMR"] 1
}

# water level notifications
proc de1_enable_water_level_notifications {} {
	::comms::msg -NOTICE de1_enable_water_level_notifications
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 7"
		return
	}
	userdata_append "enable de1 water level notifications" [list de1_comm  enable "WaterLevels"] 1
}

proc de1_disable_water_level_notifications {} {
	::comms::msg -NOTICE de1_disable_water_level_notifications
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 8"
		return
	}
	userdata_append "disable state notifications" [list de1_comm  disable "WaterLevels"] 1
}

# firmware update command notifications (not writing new fw, this is for erasing and switching firmware)
proc de1_enable_maprequest_notifications {} {
	::comms::msg -NOTICE de1_enable_maprequest_notifications
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 9"
		return
	}
	userdata_append "enable de1 maprequest notifications" [list de1_comm  enable "FWMapRequest"] 1
}

proc fwfile {} {
	::comms::msg -NOTICE fwfile
	# Pick the firmware image for the connected machine model. Bengle (BLE
	# protocol v2) uses benglefw.dat; the DE1 uses bootfwupdate.dat.
	if {[is_bengle_model]} {
		set fw "[homedir]/fw/benglefw.dat"
	} else {
		set fw "[homedir]/fw/bootfwupdate.dat"
	}

	# Parse the header for Firmware_file_Version (drives the "firmware update
	# available" comparison) whenever the target file changes — so switching
	# between a DE1 and a Bengle re-reads the version of the image we'd upload,
	# rather than keeping the first machine's cached value.
	if {![info exists ::de1(Firmware_file_path)] || $::de1(Firmware_file_path) ne $fw \
			|| [info exists ::de1(Firmware_file_Version)] != 1} {
		set ::de1(Firmware_file_path) $fw
		::comms::msg -INFO "reading firmware file metadata: $fw"
		parse_firmware_file_header [read_binary_file $fw] arr
		foreach {k v} [array get arr] {
			set varname "Firmware_file_$k"
			set ::de1($varname) $v
			::comms::msg -INFO "$varname : $v"
		}
	}

	return $fw
}


proc start_firmware_update {} {
	::comms::msg -NOTICE "start_firmware_update"

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		if {$::has_bluetooth} {
			::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 10"
			return
		}
	}

	if {$::settings(ghc_is_installed) != 0} {
		# ok to do v1.3 fw update
		#if {$::settings(force_fw_update) != 1} {
	#		set ::de1(firmware_update_button_label) "Up to date"
	#		return
	#	}
	} else {
		#if {$::settings(force_fw_update) != 1} {
		#	set ::de1(firmware_update_button_label) "Up to date"
		#	return
		#}
	}

	if {$::de1(currently_erasing_firmware) == 1} {
		::comms::msg -INFO "Already erasing firmware"
		return
	}

	if {$::de1(currently_updating_firmware) == 1} {
		::comms::msg -INFO "Already updating firmware"
		return
	}


	#de1_enable_maprequest_notifications

	set ::de1(firmware_bytes_uploaded) 0
	set ::de1(firmware_update_size) [file size [fwfile]]

	if {!$::has_bluetooth} {
		set ::sinstance($::de1(suuid)) 0
		set ::de1(cuuid_09) 0
		set ::de1(cuuid_06) 0
		set ::cinstance($::de1(cuuid_09)) 0
	}

	set arr(WindowIncrement) 0
	set arr(FWToErase) 1
	set arr(FWToMap) 1
	set arr(FirstError1) 0
	set arr(FirstError2) 0
	set arr(FirstError3) 0
	set data [make_packed_maprequest arr]

	#set ::de1(firmware_update_button_label) "Updating"

	# it'd be useful here to test that the maprequest was correctly packed

	set ::de1(currently_erasing_firmware) 1
	set ::de1(currently_updating_firmware) 0

	set ::de1(firmware_update_button_label) "Starting"

	#de1_send_state "go to sleep" $::de1_state(Sleep)

	#set ::de1(firmware_update_binary) [read_binary_file [fwfile]]
	#set ::de1(firmware_bytes_uploaded) 0


	if {$::has_bluetooth} {
		userdata_append "Erase firmware do: [array get arr]" [list de1_comm  write "FWMapRequest" $data] 1
		after 10000 write_firmware_now

		# if the firmware erase does not return in 15 seconds, try again, until eventually we stop trying because it succeeeded.
		#after 15000 start_firmware_update


	} else {
		after 1000 write_firmware_now
	}
}

#proc get_firmware_file_specs {} {
#	parse_firmware_file_header [read_binary_file [fwfile]] arr
#}

proc write_firmware_now {} {
	::comms::msg -NOTICE write_firmware_now
	set ::de1(currently_updating_firmware) 1
	set ::de1(currently_erasing_firmware) 0
	set ::de1(firmware_update_start_time) [clock milliseconds]
	::comms::msg -NOTICE "Start writing firmware now"

	set ::de1(firmware_update_binary) [read_binary_file [fwfile]]
	set ::de1(firmware_bytes_uploaded) 0

	firmware_upload_next
}


proc firmware_upload_next {} {
	::comms::msg -NOTICE "firmware_upload_next $::de1(firmware_bytes_uploaded)"

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 11"
		return
	}

	#delay_screen_saver

	if  {$::de1(firmware_bytes_uploaded) >= $::de1(firmware_update_size)} {
		set ::settings(firmware_crc) [crc::crc32 -filename [fwfile]]
		save_settings

		if {!$::has_bluetooth} {
			set ::de1(firmware_update_button_label) "Updated"
			set ::de1(currently_updating_firmware) 0

		} else {
			# finished
			de1_enable_maprequest_notifications

			set ::de1(firmware_update_button_label) "Testing"

			#set ::de1(firmware_update_size) 0
			unset -nocomplain ::de1(firmware_update_binary)
			#set ::de1(firmware_bytes_uploaded) 0

			#write_FWMapRequest(self.FWMapRequest, 0, 0, 1, 0xFFFFFF, True)
			#def write_FWMapRequest(ctic, WindowIncrement=0, FWToErase=0, FWToMap=0, FirstError=0, withResponse=True):

			set arr(WindowIncrement) 0
			set arr(FWToErase) 0
			set arr(FWToMap) 1
			set arr(FirstError1) [expr 0xFF]
			set arr(FirstError2) [expr 0xFF]
			set arr(FirstError3) [expr 0xFF]
			set data [make_packed_maprequest arr]
			userdata_append "Find first error in firmware update: [array get arr]" [list de1_comm write "FWMapRequest" $data] 1
		}
	} else {
		set ::de1(firmware_update_button_label) "Updating"

	    set data "\x10[make_U24P0 $::de1(firmware_bytes_uploaded)][string range $::de1(firmware_update_binary) $::de1(firmware_bytes_uploaded) [expr {15 + $::de1(firmware_bytes_uploaded)}]]"

		userdata_append "Write firmware: [::logging::format_mmr_short $data]" \
			[list de1_comm write "WriteToMMR" $data] 1

		set ::de1(firmware_bytes_uploaded) [expr {$::de1(firmware_bytes_uploaded) + 16}]
		if {!$::has_bluetooth} {
			set ::de1(firmware_bytes_uploaded) [expr {$::de1(firmware_bytes_uploaded) + 160}]
			after 1 firmware_upload_next
			#firmware_upload_next
		}
	}
}


proc mmr_read {note address length} {
	if {[mmr_available] == 0} {
		::comms::msg -NOTICE "Unable to mmr_read because MMR not available"
		return
	}


	set mmrlen [binary decode hex $length]
	set mmrloc [binary decode hex $address]
	set data "$mmrlen${mmrloc}[binary decode hex 00000000000000000000000000000000]"

	set cmt "MMR Read: '$note': [::logging::format_mmr $data]"

	if {!$::has_bluetooth} {
		::comms::msg -DEBUG "No BLE: $cmt"
	}

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command: $cmt"
		return
	}

	userdata_append $note [list de1_comm write "ReadFromMMR" $data] 1
}

proc mmr_write { note address length value} {

	if {$::de1(currently_erasing_firmware) == 1 && $::de1(currently_updating_firmware) == 0} {
		::comms::msg -NOTICE "Unable to mmr_write because currently upgrading firmware"
		return
	}

	if {[mmr_available] == 0} {
		::comms::msg -NOTICE "Unable to mmr_write because MMR not available"
		return
	}

	set mmrlen [binary decode hex $length]
	set mmrloc [binary decode hex $address]
	set mmrval [binary decode hex $value]
	set data "$mmrlen${mmrloc}${mmrval}[binary decode hex 0000000000000000000000000000000000]"

	if {[string length $data] > 20} {
		set data [string range $data 0 19]
	}

	set cmt "MMR Write: '$note': [::logging::format_mmr $data]"

	if {!$::has_bluetooth} {
		::comms::msg -DEBUG "No BLE: $cmt"
	}

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command: $cmt"
		return
	}

	userdata_append "$note" [list de1_comm write "WriteToMMR" $data] 1
}

# Bengle-only: target weight at which the machine auto-ends the shot using
# its integrated scale. 0 disables. Value persists to disk in the firmware,
# so we always write on shot start to keep it aligned with the app setting.
proc set_end_of_shot_weight {weight_grams} {
	if {![::de1::packet::use_ble_v2]} { return }

	if {$weight_grams eq "" || ![string is double -strict $weight_grams] || $weight_grams < 0} {
		set weight_grams 0
	}
	# MMR value = grams * 100; firmware clamps to 0..1_000_000 (10 kg).
	set scaled [expr {int(round($weight_grams * 100))}]
	if {$scaled < 0}        { set scaled 0 }
	if {$scaled > 1000000}  { set scaled 1000000 }

	::comms::msg -NOTICE "set_end_of_shot_weight '${weight_grams}g' (raw=${scaled})"
	remove_matching_ble_queue_entries {^MMR set_end_of_shot_weight}
	mmr_write "set_end_of_shot_weight ${weight_grams}g" "803864" "04" [long32_to_little_endian_hex $scaled]
}

# Bengle integrated-scale instant tare (ScaleTare, 0x0080388C). Lives here
# rather than in the calibration wizard so the ordinary scale tare path can
# reach it without loading the wizard. Matches tareIntegratedScale in
# decentespresso/decaid, which writes the same value to the same register.
proc set_bengle_scale_tare {} {
	if {![::de1::packet::use_ble_v2]} { return }
	::comms::msg -NOTICE set_bengle_scale_tare
	mmr_write "ScaleTare" "80388C" "04" [long32_to_little_endian_hex 1]
}

proc set_tank_temperature_threshold {temp} {
	::comms::msg -NOTICE set_tank_temperature_threshold "'$temp'"

	###
	### NB: The BLE queue is not thread safe
	###


	if {[info exists ::_pending_tank_temperature_change] == 1} {
		catch { after cancel $::_pending_tank_temperature_change }
	}
	remove_matching_ble_queue_entries {^MMR set_tank_temperature_threshold}

	if {$temp < 10} {
		# no point in circulating the water if the desired temp is <10ºC, or no preheating.
		mmr_write "set_tank_temperature_threshold" "80380C" "04" [zero_pad [int_to_hex $temp] 2]
	} else {
		# if the water temp is being set, then set the water temp temporarily to 60º in order to force a water circulation for 2 seconds
		# then a few seconds later, set it to the real, desired value
		set hightemp 60
		mmr_write "set_tank_temperature_threshold" "80380C" "04" [zero_pad [int_to_hex $hightemp] 2]

		# Retain existing logic here
		# NB: This  does not guarantee a 4-second water-circulation period
		#     especially when the queue has a significant depth to it

		set ::_pending_tank_temperature_change \
			[after 4000 [list mmr_write "set_tank_temperature_threshold" \
					     "80380C" "04" [zero_pad [int_to_hex $temp] 2] ] ]
	}
}



# /*
#  *  Memory Mapped Registers
#  *
#  *  RangeNum Position	   Len  Desc
#  *  -------- --------	   ---  ----
#  *		 1 0x0080 0000	  4  : HWConfig
#  *		 2 0x0080 0004	  4  : Model
#  *		 3 0x0080 2800	  4  : How many characters in debug buffer are valid. Accessing this pauses BLE debug logging.
#  *		 4 0x0080 2804 0x1000  : Last 4K of output. Zero terminated if buffer not full yet. Pauses BLE debug logging.
#  *		 6 0x0080 3808	  4  : Fan threshold.
#  *		 7 0x0080 380C	  4  : Tank water threshold.
#  *		11 0x0080 381C	  4  : GHC Info Bitmask, 0x1 = GHC Present, 0x2 = GHC Active
#  *
#  */


proc get_heater_tweaks_obs {} {
	#mmr_read "hot_water_idle_temp" "803818" "00"
	#after 3000 mmr_read "espresso_warmup_timeout" "803838" "00"
}

proc get_heater_voltage {} {
	::comms::msg -NOTICE get_heater_voltage
	mmr_read "get_heater_voltage" "803834" "01"
}


# 4 - 121. (2020-07-09 20:43:40) >>> MMR hot_water_idle_temp 800 writing 04 bytes of firmware data to 80 38 18 with value 03 20 : with comment 04 80 38 18 03 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 (-2) : ble write ble1 0000A000-0000-1000-8000-00805F9B34FB 12 0000A006-0000-1000-8000-00805F9B34FB 29 {8
# 2 - 130. (2020-07-09 20:45:57) >>> MMR hot_water_idle_temp 790 writing 04 bytes of firmware data to 80 38 18 with value 31 :	with comment 04 80 38 18 31 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 (-2) : ble write ble2 0000A000-0000-1000-8000-00805F9B34FB 12 0000A006-0000-1000-8000-00805F9B34FB 29 81
proc set_heater_tweaks {} {
	::comms::msg -NOTICE set_heater_tweaks
	#set ::settings(hot_water_idle_temp) 790

	mmr_write "phase_1_flow_rate $::settings(phase_1_flow_rate)" "803810" "04" [zero_pad [long_to_little_endian_hex $::settings(phase_1_flow_rate)] 4]
	mmr_write "phase_2_flow_rate $::settings(phase_2_flow_rate)" "803814" "04" [zero_pad [long_to_little_endian_hex $::settings(phase_2_flow_rate)] 4]
	mmr_write "hot_water_idle_temp $::settings(hot_water_idle_temp)" "803818" "04" [zero_pad [long_to_little_endian_hex $::settings(hot_water_idle_temp)] 4]
	mmr_write "espresso_warmup_timeout $::settings(espresso_warmup_timeout)" "803838" "04" [zero_pad [long_to_little_endian_hex $::settings(espresso_warmup_timeout)] 4]

	# aka SteamPurgeMode - set to 1 to have two taps to turn steam off.  First tap goes to puffs, second tap goes to steam purge
	mmr_write "steam_two_tap_stop $::settings(steam_two_tap_stop)" "803850" "04" [zero_pad [long_to_little_endian_hex $::settings(steam_two_tap_stop)] 4]

	set_flush_timeout $::settings(flush_seconds)
	set_flush_flow_rate $::settings(flush_flow)
	set_hotwater_flow_rate $::settings(hotwater_flow)
}

proc toggle_usb_charger_on {} {

	if {$::de1(usb_charger_on) == 0} {
		set ::de1(usb_charger_on) 1
	} else {
		set ::de1(usb_charger_on) 0
	}
	set_usb_charger_on $::de1(usb_charger_on)
}

proc set_usb_charger_on {usbon} {
	#dump_stack
	set ::de1(usb_charger_on) $usbon
	::comms::msg -NOTICE set_usb_charger_on "'$usbon'"
	remove_matching_ble_queue_entries {^MMR set_usb_charger_on}
	::comms::msg -INFO "Setting usb charger on to '$usbon'"
	mmr_write "set_usb_charger_on" "803854" "04" [zero_pad [int_to_hex $usbon] 2]

	# this is a cached variable to find out the current usb charge state it should be in, but not necessarily to be 100% trusted
	set ::de1(usb_charger_on) $usbon
}


proc set_user_present {} {
	remove_matching_ble_queue_entries {^MMR set_user_present}
	::comms::msg -INFO "Setting user is present"
	mmr_write "set_user_present" "803860" "04" [zero_pad [int_to_hex 1] 2]
}

proc set_hotwater_flow_rate {rate} {
	::comms::msg -NOTICE set_hotwater_flow_rate "'$rate'"
	remove_matching_ble_queue_entries {^MMR set_hotwater_flow_rate}
	::comms::msg -INFO "Setting hot water flow rate to '$rate'"
	mmr_write "set_hotwater_flow_rate" "80384C" "04" [zero_pad [long_to_little_endian_hex [expr {int(10 * $rate)}] ] 2]
}


proc set_cupwarmer_temperature {temp} {
	if {[is_bengle_model] != 1} {
		return 
	}
	::comms::msg -NOTICE set_cupwarmer_temperature "'$temp'"
	remove_matching_ble_queue_entries {^MMR set_cupwarmer_temperature}
	::comms::msg -INFO "Setting cup warmer temperature '$temp'"
	mmr_write "set_cupwarmer_temperature" "803874" "04" [zero_pad [long_to_little_endian_hex $temp] 2]
}


proc set_flush_flow_rate {rate} {
	::comms::msg -NOTICE set_flush_flow_rate "'$rate'"
	remove_matching_ble_queue_entries {^MMR set_flush_flow_rate}
	::comms::msg -INFO "Setting flush flow rate to '$rate'"
	mmr_write "set_flush_flow_rate" "803840" "04" [zero_pad [long_to_little_endian_hex [expr {int(10 * $rate)}] ] 2]
}

# Cup warmer enable: 0=Off, 1=On. Not persisted on firmware side — must be
# (re)sent on every BLE reconnect and whenever the user toggles it.
proc set_cupwarmer_mode {mode} {
	if {[is_bengle_model] != 1} {
		return
	}
	set mode [expr {$mode ? 1 : 0}]
	::comms::msg -NOTICE set_cupwarmer_mode "'$mode'"
	remove_matching_ble_queue_entries {^MMR set_cupwarmer_mode}
	mmr_write "set_cupwarmer_mode" "8038AC" "04" [zero_pad [long_to_little_endian_hex $mode] 2]
}

# Read the cup warmer's live status. Nothing polled these before, so the
# warmer page's heater percentage and NTC-fault warning could never update.
# Called on connect and whenever the cup warmer page is opened.
proc get_cupwarmer_status {} {
	if {[is_bengle_model] != 1} {
		return
	}
	remove_matching_ble_queue_entries {^MMR get_cupwarmer_status}
	mmr_read "get_cupwarmer_status drive" "8038B4" "00"
	mmr_read "get_cupwarmer_status fault" "8038B8" "00"
}

# Verification test: the cup warmer must not be heating while it is disabled in
# the app. Called with the live MatHeaterDrivePct (0x8038B4) each time we read
# it. If the machine reports drive > 0 while ::settings(cupwarmer_enable) is 0,
# that is a bug (the machine kept an old CupWarmerMode=1, or firmware pre-warm
# fired) -- surface it as a toast so it is caught in the field. Detection only:
# it deliberately does NOT correct the state, so the underlying bug stays
# visible. Throttled to at most one toast per 30 s to avoid spamming the poll.
proc check_cupwarmer_not_heating_while_disabled {drive} {
	if {[is_bengle_model] != 1} { return }
	if {[ifexists ::settings(cupwarmer_enable) 0] != 0} { return }
	if {![string is integer -strict $drive] || $drive <= 0} { return }

	::comms::msg -ERROR "CUP WARMER BUG: heating at ${drive}% while disabled (cupwarmer_enable=0)"

	set now [clock seconds]
	if {[ifexists ::de1(_cupwarmer_bug_toast_at) 0] + 30 <= $now} {
		set ::de1(_cupwarmer_bug_toast_at) $now
		catch { popup "[translate_toast {Cup warmer is heating while OFF — this is a bug}] (${drive}%)" }
	}
}

# Cup-warmer pre-warm. The FIRMWARE owns the timing: with MatPreheatEnable set
# it starts the mat MatPreheatLeadMin minutes before a scheduled wake, and it
# does so with no tablet connected. Both registers are flash-persisted, so this
# only needs sending on connect and when the user changes the setting.
#
# Write order matters and matches decentespresso/decaid: when enabling, send
# the lead first so the firmware never acts on a stale one; when disabling,
# clear the enable first.
proc set_cupwarmer_preheat {enabled lead_minutes} {
	if {[is_bengle_model] != 1} {
		return
	}
	set lead [expr {int(round($lead_minutes))}]
	if {$lead < 0}   { set lead 0 }
	if {$lead > 120} { set lead 120 }
	set on [expr {$enabled ? 1 : 0}]
	::comms::msg -NOTICE set_cupwarmer_preheat "enabled=$on lead=$lead min"
	remove_matching_ble_queue_entries {^MMR set_cupwarmer_preheat}
	if {$on} {
		mmr_write "set_cupwarmer_preheat lead" "8038D4" "04" [zero_pad [long_to_little_endian_hex $lead] 2]
		mmr_write "set_cupwarmer_preheat on"   "8038D0" "04" [zero_pad [long_to_little_endian_hex 1] 2]
	} else {
		mmr_write "set_cupwarmer_preheat off"  "8038D0" "04" [zero_pad [long_to_little_endian_hex 0] 2]
		mmr_write "set_cupwarmer_preheat lead" "8038D4" "04" [zero_pad [long_to_little_endian_hex $lead] 2]
	}
}

# Send the machine's autonomous inactivity-sleep timeout (whole minutes).
# The firmware self-sleeps after this long idle WHEN NO TABLET IS CONNECTED, so
# the machine sleeps even if the tablet is off/disconnected. We reuse the tablet's
# existing screen_saver_delay value (already in minutes) as the source. 0 = the
# firmware never auto-sleeps. Firmware default (when never set) is 60.
proc set_sleep_timeout_minutes {minutes} {
	if {[is_bengle_model] != 1} {
		return
	}
	set raw [expr {int(round($minutes))}]
	if {$raw < 0}   { set raw 0 }
	if {$raw > 240} { set raw 240 }
	::comms::msg -NOTICE set_sleep_timeout_minutes "'$minutes' (raw $raw)"
	remove_matching_ble_queue_entries {^MMR set_sleep_timeout_minutes}
	mmr_write "set_sleep_timeout_minutes" "8038BC" "04" [zero_pad [long_to_little_endian_hex $raw] 2]
}

# ---------------------------------------------------------------------------
# Phase 2: tablet-synced firmware clock + weekly wake schedule.
#
# The firmware keeps its own software wall-clock and weekly wake schedule so it
# can wake / keep warm on schedule and self-sleep off-schedule even with NO
# tablet connected. The tablet is just the source: it pushes the current local
# time (re-synced periodically) and the schedule (on connect and on edit). There
# is no battery-backed RTC, so the firmware clock is lost on a full power cut and
# re-synced the moment a tablet reconnects; until then only the Phase-1
# inactivity timer runs. dow convention 0 = Sunday matches Tcl %w and the firmware.
# ---------------------------------------------------------------------------

# Push the firmware's local wall-clock as seconds-since-Sunday-00:00:00 (local).
proc set_machine_clock {} {
	if {[is_bengle_model] != 1} {
		return
	}
	set now [clock seconds]
	set w [scan [clock format $now -format %w] %d]   ;# 0=Sun .. 6=Sat
	set h [scan [clock format $now -format %H] %d]
	set m [scan [clock format $now -format %M] %d]
	set s [scan [clock format $now -format %S] %d]
	set sow [expr {($w * 86400) + ($h * 3600) + ($m * 60) + $s}]
	::comms::msg -NOTICE set_machine_clock "sec-of-week=$sow"
	remove_matching_ble_queue_entries {^set_machine_clock}
	mmr_write "set_machine_clock" "8038C0" "04" [long32_to_little_endian_hex $sow]
}

# Push the current clock now, and re-arm a periodic re-sync so the firmware clock
# does not drift while a tablet stays connected for a long time.
proc machine_clock_resync {} {
	if {[info exists ::machine_clock_resync_handle]} {
		after cancel $::machine_clock_resync_handle
	}
	set_machine_clock
	set ::machine_clock_resync_handle [after [expr {30 * 60 * 1000}] machine_clock_resync]
}

proc dow_from_dayname {day} {
	switch -- $day {
		Sun {return 0}
		Mon {return 1}
		Tue {return 2}
		Wed {return 3}
		Thu {return 4}
		Fri {return 5}
		Sat {return 6}
	}
	return -1
}

# Build the firmware's weekly wake schedule from the app's scheduler settings and
# push it (clear -> entries -> enable). Each firmware window is packed as
# (dow<<22)|(startMin<<11)|endMin, minutes after local midnight, endMin exclusive.
proc set_wake_schedule {} {
	if {[is_bengle_model] != 1} {
		return
	}
	remove_matching_ble_queue_entries {^sched_}
	# Clear the firmware table + disable while we (re)load it.
	mmr_write "sched_clear" "8038C8" "04" [long32_to_little_endian_hex 0]

	set count 0

	# D_Scheduler per-weekday WAKE times -> short wake windows [t, t+1): the
	# firmware wakes at t, then the Phase-1 inactivity timer sleeps it.
	foreach day {Sun Mon Tue Wed Thu Fri Sat} {
		set dow [dow_from_dayname $day]
		if {[info exists ::D_scheduler_minutes($day)]} {
			foreach t $::D_scheduler_minutes($day) {
				if {$count >= 32} { break }
				set t [scan $t %d]
				if {$t eq "" || $t < 0 || $t > 1439} { continue }
				set endm [expr {$t + 1}]
				set packed [expr {($dow << 22) | ($t << 11) | $endm}]
				mmr_write "sched_entry" "8038C4" "04" [long32_to_little_endian_hex $packed]
				incr count
			}
		}
	}

	# Built-in scheduler keep-warm window [wake,sleep) (seconds-since-midnight),
	# same every day, only when enabled. The D_Scheduler plugin disables
	# scheduler_enable, so in practice these two sources do not double up.
	if {[info exists ::settings(scheduler_enable)] && $::settings(scheduler_enable) == 1} {
		set ws [expr {int($::settings(scheduler_wake)  / 60)}]
		set se [expr {int($::settings(scheduler_sleep) / 60)}]
		if {$ws >= 0 && $ws < $se && $se <= 1440} {
			foreach dow {0 1 2 3 4 5 6} {
				if {$count >= 32} { break }
				set packed [expr {($dow << 22) | ($ws << 11) | $se}]
				mmr_write "sched_entry" "8038C4" "04" [long32_to_little_endian_hex $packed]
				incr count
			}
		}
	}

	if {$count > 0} {
		mmr_write "sched_enable" "8038C8" "04" [long32_to_little_endian_hex 1]
	}
	::comms::msg -NOTICE set_wake_schedule "pushed $count window(s)"
}

proc set_flush_timeout {seconds} {
	::comms::msg -NOTICE set_flush_timeout "'$seconds'"
	remove_matching_ble_queue_entries {^MMR set_flush_timeout}
	::comms::msg -INFO "Setting flush timeout seconds to '$seconds'"
	mmr_write "set_flush_timeout" "803848" "04" [zero_pad [long_to_little_endian_hex [expr {int(10 * $seconds)}] ] 2]
}

proc set_feature_flags {UserNotPresent} {
	::comms::msg -NOTICE set_feature_flags "'$UserNotPresent'"
	remove_matching_ble_queue_entries {^MMR set_feature_flags}
	::comms::msg -INFO "Setting feature flags '$UserNotPresent'"
	mmr_write "set_feature_flags" "803858" "04" [zero_pad [long_to_little_endian_hex $UserNotPresent] 2]
}


proc set_steam_flow {desired_flow} {
	::comms::msg -NOTICE set_steam_flow "'$desired_flow'"
	remove_matching_ble_queue_entries {^MMR set_steam_flow}
	::comms::msg -INFO "Setting steam flow rate to '$desired_flow'"
	mmr_write "set_steam_flow" "803828" "04" [zero_pad [int_to_hex $desired_flow] 2]
}

# Milk auto-stop target in C (stored on firmware as C*10). 0 disables.
# Gated and clamped to match the reaprime/decaid contract for this register
# (TargetMilkTemp 0x008038A8, raw 0..850).
proc set_target_milk_temp {temp_c} {
	if {[is_bengle_model] != 1} {
		return
	}
	set raw [expr {int(round($temp_c * 10))}]
	if {$raw < 0}   { set raw 0 }
	if {$raw > 850} { set raw 850 }
	::comms::msg -NOTICE set_target_milk_temp "'$temp_c' (raw $raw)"
	remove_matching_ble_queue_entries {^MMR set_target_milk_temp}
	mmr_write "set_target_milk_temp" "8038A8" "04" [zero_pad [long_to_little_endian_hex $raw] 2]
}

proc send_refill_kit_override {} {
	if {$::settings(refill_kit_override) == 0} {
		set_refill_kit_present 0
	} elseif {$::settings(refill_kit_override) == 1} {
		set_refill_kit_present 1
	} elseif {$::settings(refill_kit_override) == 2 || $::settings(refill_kit_override) == -1} {
		set_refill_kit_present 2
	} else {
		if {$::de1(refill_kit_detected) != ""} {
			set_refill_kit_present $::de1(refill_kit_detected)
		} else {
			# if nothing detected, but they want automatic, set refill kit to on
			set_refill_kit_present 1
		}
	}
}

proc set_refill_kit_present {number} {
	::comms::msg -NOTICE set_refill_kit_present "'$number'"
	remove_matching_ble_queue_entries {^MMR set_refill_kit_present}
	::comms::msg -INFO "Setting refill_kit_present to '$number'"
	mmr_write "set_refill_kit_present $::settings(steam_two_tap_stop)" "80385C" "04" [zero_pad [long_to_little_endian_hex $number] 4]	
}


proc get_refill_kit_present {} {
	::comms::msg -NOTICE get_refill_kit_present
	mmr_read "get_refill_kit_present" "80385C" "00"
}


proc get_steam_flow {} {
	::comms::msg -NOTICE get_steam_flow
	mmr_read "get_steam_flow" "803828" "00"
}

proc get_sn {} {
	::comms::msg -NOTICE get_sn
	mmr_read "get_sn" "803830" "00"
}

proc get_3_mmr_cpuboard_machinemodel_firmwareversion {} {
	::comms::msg -NOTICE get_3_mmr_cpuboard_machinemodel_firmwareversion
	mmr_read "cpuboard_machinemodel_firmwareversion" "800008" "02"

}

proc get_cpu_board_model {} {
	::comms::msg -NOTICE get_cpu_board_model
	mmr_read "get_cpu_board_model" "800008" "00"
}

proc get_machine_model {} {
	::comms::msg -NOTICE get_machine_model
	mmr_read "get_machine_model" "80000C" "00"
}

proc get_firmware_version_number {} {
	::comms::msg -NOTICE get_firmware_version_number
	mmr_read "get_firmware_version_number" "800010" "00"
}

proc set_heater_voltage {heater_voltage} {
	::comms::msg -NOTICE "set_heater_voltage '$heater_voltage'"
	mmr_write "set_heater_voltage" "803834" "04" [zero_pad [int_to_hex $heater_voltage] 2]
}



proc set_steam_highflow_start {desired_seconds} {
	::comms::msg -NOTICE "set_steam_highflow_start '$desired_seconds'"

	###
	### NB: The BLE queue is not thread safe
	###

	remove_matching_ble_queue_entries {^MMR set_steam_highflow_start}

	mmr_write "set_steam_highflow_start" "80382C" "04" [zero_pad [int_to_hex $desired_seconds] 2]
}

proc get_steam_highflow_start {} {
	::comms::msg -NOTICE get_setam_highflow_start
	mmr_read "get_steam_highflow_start" "80382C" "00"
}


proc set_ghc_mode {desired_mode} {
	::comms::msg -NOTICE "set_ghc_mode '$desired_mode'"
	mmr_write "set_ghc_mode" "803820" "04" [zero_pad [int_to_hex $desired_mode] 2]
}

proc get_ghc_mode {} {
	::comms::msg -NOTICE get_ghc_mode
	mmr_read "get_ghc_mode" "803820" "00"
}

proc get_ghc_is_installed {} {
	::comms::msg -NOTICE get_is_ghc_installed
	mmr_read "get_ghc_is_installed" "80381C" "00"
}

proc get_fan_threshold {} {
	::comms::msg -NOTICE get_fan_threshold
	mmr_read "get_fan_threshold" "803808" "00"
}

proc get_calibration_flow_multiplier {} {
	::comms::msg -NOTICE get_calibration_flow_multiplier
	mmr_read "get_calibration_flow_multiplier" "80383C" "00"
}

proc set_fan_temperature_threshold {temp} {
	::comms::msg -NOTICE set_fan_temperature_threshold "'$temp'"
	mmr_write "set_fan_temperature_threshold" "803808" "04" [zero_pad [int_to_hex $temp] 2]
}

proc set_calibration_flow_multiplier {m} {
	::comms::msg -NOTICE set_calibration_flow_multiplier "'$m'"
	mmr_write "set_calibration_flow_multiplier" "80383C" "04" [zero_pad [long_to_little_endian_hex [expr {int(1000 * $m)}] ] 2]
}

proc get_tank_temperature_threshold {} {
	::comms::msg -NOTICE get_tank_temperature_threshold
	mmr_read "get_tank_temperature_threshold" "80380C" "00"
}

proc de1_cause_refill_now_if_level_low {} {
	::comms::msg -NOTICE de1_cause_refill_now_if_level_low

	# john 05-08-19 commented out, will obsolete soon.  Turns out not to work, because SLEEP mode does not check low water setting.
	return

	# set the water level refill point to 10mm more water
	set backup_waterlevel_setting $::settings(water_refill_point)
	set ::settings(water_refill_point) [expr {$::settings(water_refill_point) + 20}]
	de1_send_waterlevel_settings

	# then set the water level refill point back to the user setting
	set ::settings(water_refill_point) $backup_waterlevel_setting

	# and in 30 seconds, tell the machine to set it back to normal
	after 30000 de1_send_waterlevel_settings
}

proc de1_send_waterlevel_settings {} {
	::comms::msg -NOTICE de1_send_waterlevel_settings
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 12"
		return
	}

	set data [return_de1_packed_waterlevel_settings]
	parse_binary_water_level $data arr2
	userdata_append "Set water level settings: [array get arr2]" [list de1_comm write "WaterLevels" $data] 1
}


proc de1_send_state {comment msg} {
	::comms::msg -NOTICE de1_send_state "'$comment'" [::logging::format_asc_bin msg]
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 13"
		return
	}

	#clear_timers
	delay_screen_saver

	#if {$::de1(device_handle) == "0"} {
	#	return
	#}

	#set ::de1(substate) -
	userdata_append $comment [list de1_comm write "RequestedState" "$msg"] 1
}


proc remove_matching_ble_queue_entries {comment_regexp} {

	###
	### NB: The BLE queue is not thread safe
	###

	# Any new DE1 shot frames or steam/hot water settings
	# are just going to be overwritten.
	# Remove them before adding new requests to the queue

	set old_stack $::de1(cmdstack)
	set old_length [llength $old_stack]
	set needs_poke 0
	set index 0 

	set new_stack {}
	foreach cmd $old_stack {
		if { ! [regexp "$comment_regexp" [lindex $cmd 0]] } {
			lappend new_stack $cmd
		} else {
			::comms::msg -DEBUG "ble_queue: Removing" \
				[string range [lindex $cmd 0] 0 30] \
				"... for '$comment_regexp'"
			if {$index == 0} {
				set needs_poke 1
			}
		}
		incr index
	}
	set new_length [llength $new_stack]

	if { $old_length != $new_length } {
		::comms::msg -INFO [format "ble_queue: Removed stale '%s' from queue; %d to %d (%d removed)" \
				   $comment_regexp \
				   $old_length $new_length \
				   [expr {$old_length - $new_length}]]
	}

	set ::de1(cmdstack) $new_stack

	if {$needs_poke} {
		run_next_userdata_cmd
	}
}

proc de1_send_shot_frames { {override {}} } {
	::comms::msg -NOTICE de1_send_shot_frames

	###
	### NB: The BLE queue is not thread safe
	###

	# this is to track which frames are ACKed as having been successfully sent
	unset -nocomplain ::de1(shot_frames_sent)

	set parts [de1_packed_shot_wrapper $override]
	set header [lindex $parts 0]

	####
	# this is purely for testing the parser/deparser
	parse_binary_shotdescheader $header arr2
	####


	remove_matching_ble_queue_entries {^Espresso header:}
	remove_matching_ble_queue_entries {^Espresso frame #}

	userdata_append "Espresso header: [array get arr2]" [list de1_comm write "HeaderWrite" $header] 1

	set cnt 0
	foreach packed_frame [lindex $parts 1] {

		####
		# this is purely for testing the parser/deparser
		incr cnt
		unset -nocomplain arr3
		parse_binary_shotframe $packed_frame arr3
		::comms::msg -DEBUG "frame #$cnt: [string length $packed_frame] bytes: [array get arr3]"
		####

		userdata_append "Espresso frame #$cnt: [array get arr3] (FLAGS: [parse_shot_flag [ifexists arr3(Flag)]])"  [list de1_comm write "FrameWrite" $packed_frame] 1
	}

	# only set the tank temperature for advanced profile shots
	if {$::settings(settings_profile_type) == "settings_2c"} {
		set_tank_temperature_threshold $::settings(tank_desired_water_temperature)
	} else {
		set_tank_temperature_threshold 0
	}

	# Bengle integrated-scale stop-at-weight. Each profile carries its own
	# final_desired_shot_weight[_advanced]; push it to MMR 0x00803864 every
	# time we upload frames so the machine-side target stays aligned with
	# the profile currently on the app. Writing 0 when the profile has no
	# target clears any value left persisted on disk by a prior profile.
	if {$::settings(settings_profile_type) == "settings_2c"} {
		set _saw_target [ifexists ::settings(final_desired_shot_weight_advanced) 0]
	} else {
		set _saw_target [ifexists ::settings(final_desired_shot_weight) 0]
	}
	set_end_of_shot_weight $_saw_target

	userdata_append "Confirm that all shot frames were correctly sent"  [list confirm_de1_send_shot_frames_worked [lindex $parts 1]] 1
	return
}

proc de1_send_pre_maintenance_profile {} {

	# Workaround for a DE1 firmware flaw: the machine refuses the Clean, Descale
	# and AirPurge (travel) states while it is still cold, unless a profile has
	# already been loaded. We load a harmless minimal 1-step profile whose goal
	# temperature is 1°C (so it never actually heats), which satisfies the
	# firmware's check. Because this rides the same FIFO BLE queue, calling it
	# just before de1_send_state guarantees the profile is delivered (and ACKed)
	# before the state-change request.
	::comms::msg -NOTICE de1_send_pre_maintenance_profile
	de1_send_shot_frames "onestep_cold"
}

proc confirm_de1_send_shot_frames_worked {parts} {

	::comms::msg -NOTICE "confirm_de1_send_shot_frames_worked (frames acked: [llength [ifexists ::de1(shot_frames_sent)]]) (frames desired: [llength $parts])"

	set success 1

	set num 0

	foreach frame_sent [ifexists ::de1(shot_frames_sent)] {
		::comms::msg -NOTICE "confirm_de1_send_shot_frames_worked : checking frame $num : $frame_sent"

		array unset -nocomplain this_frame_array
		array set this_frame_array $frame_sent

		if {$num != [ifexists this_frame_array(FrameToWrite)]} {
			::comms::msg -NOTICE "confirm_de1_send_shot_frames_worked : unexpected frame number, expected $num, got [ifexists this_frame_array(FrameToWrite)]"
			set success 0
			break
		}

		incr num
	}

	if {$success == 1} {
		# check that the number of frames ACKed is the same number as what we sent
		if {[llength [ifexists ::de1(shot_frames_sent)]] != [llength $parts]} {
			::comms::msg -NOTICE "confirm_de1_send_shot_frames_worked : unexpected total number of frames acked, expected [llength $parts], got [llength [ifexists ::de1(shot_frames_sent)]]"
			set success 0
		}
	}

	if {$success != 1} {
		# if this was not successful, try sending the shot frames again
		::comms::msg -NOTICE "confirm_de1_send_shot_frames_worked : shot frames were not successfully sent, so trying to send them again"
		
		# in a half second, try again.  We put a delay in, so that if a logic error occurs, and this goes into a loop, it won't tie up the cpu 100% trying
		#after 500 de1_send_shot_frames
	} else {
		::comms::msg -NOTICE "confirm_de1_send_shot_frames_worked : [llength [ifexists ::de1(shot_frames_sent)]] shot frames were successfully sent"
	}

	unset -nocomplain ::de1(shot_frames_sent)

	#####
	# this is needed because the BLE command stack relies on callbacks to continue unspooling. Since no BLE command was initiated in this proc, then no unspooling would occur, so we do this manually.
	set ::de1(wrote) 0
	after 100 run_next_userdata_cmd
	return 1
	#####
}

proc save_settings_to_de1 {} {
	::comms::msg -NOTICE save_settings_to_de1

	###
	### NB: The BLE queue is not thread safe
	###

	# let this run even though no connection, so it can be displayed in the debug log.  Very useful info for programmers.
	#if {[ifexists ::sinstance($::de1(suuid))] == ""} {
	#		return
	#	}

	de1_send_shot_frames
	de1_send_steam_hotwater_settings
}

proc de1_send_steam_hotwater_settings { {temporarily_disable_steam 0} } {
	::comms::msg -NOTICE de1_send_steam_hotwater_settings

	###
	### NB: The BLE queue is not thread safe
	###

	# let this run even though no connection, so it can be displayed in the debug log.  Very useful info for programmers.
	#if {[ifexists ::sinstance($::de1(suuid))] == ""} {
	#	return
	#}


	remove_matching_ble_queue_entries {^Set water/steam settings:}

	set data [return_de1_packed_steam_hotwater_settings $temporarily_disable_steam]
	parse_binary_hotwater_desc $data arr2
	userdata_append "Set water/steam settings: [array get arr2]" [list de1_comm write "ShotSettings" $data] 1

	set_steam_flow $::settings(steam_flow)
	set_steam_highflow_start $::settings(steam_highflow_start)

	set_flush_timeout $::settings(flush_seconds)
	set_flush_flow_rate $::settings(flush_flow)

	# only works on Bengle
	set_cupwarmer_temperature $::settings(cupwarmer_temp)

	# Milk temp auto-stop: write the target, or 0 to disable. Both settings
	# are read with ifexists -- there is no UI for them in this series, so a
	# tablet that has never set them must not throw here.
	if {[ifexists ::settings(steam_stop_mode)] eq "temp"} {
		set_target_milk_temp [ifexists ::settings(target_milk_temp) 0]
	} else {
		set_target_milk_temp 0
	}
	# CupWarmerMode is NOT persisted on the firmware side; must (re)send. On
	# every boot and reconnect the app sends 0 here -- the mode only goes to 1
	# after the user taps the toggle, or when the pre-warm scheduler fires.
	# This is intentional: no auto-heat after a blackout.
	set_cupwarmer_mode [ifexists ::settings(cupwarmer_enable) 0]
	
}


proc de1_send_calibration {calib_target reported measured {calibcmd 1} } {
	::comms::msg -NOTICE de1_send_calibration

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 17"
		return
	}

	if {$calib_target == "flow"} {
		set target 0
	} elseif {$calib_target == "pressure"} {
		set target 1
	} elseif {$calib_target == "temperature"} {
		set target 2
	} else {
		::comms::msg -ERROR "Unknown calibration send target: '$calib_target'"
		return
	}

	set arr(WriteKey) [expr 0xCAFEF00D]

	# change calibcmd to 2, to reset to factory settings, otherwise default of 1 does a write
	set arr(CalCommand) $calibcmd

	set arr(CalTarget) $target
	set arr(DE1ReportedVal) [convert_float_to_S32P16 $reported]
	set arr(MeasuredVal) [convert_float_to_S32P16 $measured]

	set data [make_packed_calibration arr]
	parse_binary_calibration $data arr2
	userdata_append "Set calibration: [array get arr2] : [string length $data] bytes: ([convert_string_to_hex $data])" [list de1_comm write "Calibration" $data] 1
}

proc de1_read_calibration {calib_target {factory 0} } {
	::comms::msg -NOTICE de1_read_calibration

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		::comms::msg -DEBUG "DE1 not connected, cannot send BLE command 18"
		return
	}


	if {$calib_target == "flow"} {
		set target 0
	} elseif {$calib_target == "pressure"} {
		set target 1
	} elseif {$calib_target == "temperature"} {
		set target 2
	} else {
		::comms::msg -ERROR "Unknown calibration write target: '$calib_target'"
		return
	}

	#set arr(WriteKey) [expr 0xCAFEF00D]
	set arr(WriteKey) 1

	set arr(CalCommand) 0
	set what "current"
	if {$factory == "factory"} {
		set arr(CalCommand) 3
		set what "factory"
	}

	set arr(CalTarget) $target
	set arr(DE1ReportedVal) 0
	set arr(MeasuredVal) 0

	set data [make_packed_calibration arr]
	parse_binary_calibration $data arr2
	userdata_append "Read $what calibration: [array get arr2] : [string length $data] bytes: ([convert_string_to_hex $data])" [list de1_comm write "Calibration" $data] 1
}


proc de1_read_hotwater {} {
	::comms::msg -NOTICE de1_read_hotwater

	userdata_append "read de1 hot water/steam" [list de1_comm read "ShotSettings"] 1
}

proc de1_read_shot_header {} {
	::comms::msg -NOTICE de1_read_shot_header

	userdata_append "read shot header" [list de1_comm read "HeaderWrite"] 1
}
proc de1_read_shot_frame {} {
	::comms::msg -NOTICE de1_read_shot_frame

	userdata_append "read shot frame" [list de1_comm read "FrameWrite"] 1
}

proc is_bengle_model {} {
	# Delegate to the canonical Bengle detection used by the BLE packet
	# code (shot sample decoder, shot profile encoder, max_flowrate). See
	# ::de1::packet::detect_ble_protocol_version in de1_de1.tcl — it
	# watches ::settings(machine_model) (set from the v13Model MMR) and
	# flips ble_protocol_version to 2 when it equals 128. Reading the var
	# directly (rather than calling use_ble_v2) avoids depending on the
	# proc being defined at file-load time, which matters for the skin's
	# is_bengle_model gates.
	return [expr {[ifexists ::de1(ble_protocol_version) 1] >= 2}]
}


########################################
# LED strip colour control (Bengle only)
#
# Stored colours (persistent, firmware switches automatically on sleep/wake):
#   FrontLEDAwake  0x803898   RearLEDAwake  0x80389C
#   FrontLEDSleep  0x8038A0   RearLEDSleep  0x8038A4
#
# Live/preview colours (transient, for picker real-time feedback):
#   FrontLEDColor  0x803890   RearLEDColor  0x803894
########################################

namespace eval ::led {
	# ephemeral UI state for the picker page
	variable editing_state  "awake"   ;# "awake" or "sleep" — which stored colour is being edited
	variable picker_active  0         ;# 1 while the led_picker page is open (live preview mode)
	# Per-strip last-written colour cache. Used to dedupe MMR writes.
	variable _last_written
	array set _last_written {front "" rear ""}
}

proc ::led::hex_to_int {hex} {
	set hex [string trimleft $hex "#"]
	if {[string length $hex] != 6} { return 0 }
	scan $hex %x result
	return $result
}

proc ::led::int_to_hex {val} {
	return [format "#%06X" [expr {$val & 0xFFFFFF}]]
}

# HSV → "#RRGGBB". h: 0-360 (normalised), s: 0-1, v: 0-1
proc ::led::hsv_to_hex {h s v} {
	# Normalise h into [0, 360) so negative / out-of-range inputs don't
	# land in the wrong hexant via the switch's default branch.
	set h [expr {fmod($h, 360.0)}]
	if {$h < 0} { set h [expr {$h + 360.0}] }
	if {$s <= 0.0} {
		set r $v; set g $v; set b $v
	} else {
		set hh [expr {$h / 60.0}]
		set i  [expr {int(floor($hh))}]
		set f  [expr {$hh - $i}]
		set p  [expr {$v * (1.0 - $s)}]
		set q  [expr {$v * (1.0 - $s * $f)}]
		set t  [expr {$v * (1.0 - $s * (1.0 - $f))}]
		switch -- $i {
			0 { set r $v; set g $t; set b $p }
			1 { set r $q; set g $v; set b $p }
			2 { set r $p; set g $v; set b $t }
			3 { set r $p; set g $q; set b $v }
			4 { set r $t; set g $p; set b $v }
			default { set r $v; set g $p; set b $q }
		}
	}
	return [format "#%02X%02X%02X" \
		[expr {int(round($r * 255))}] \
		[expr {int(round($g * 255))}] \
		[expr {int(round($b * 255))}]]
}

# "#RRGGBB" → {h s v}
proc ::led::hex_to_hsv {hex} {
	set hex [string trimleft $hex "#"]
	if {[string length $hex] != 6} { return {0 0 0} }
	scan $hex "%2x%2x%2x" ri gi bi
	set r [expr {$ri / 255.0}]
	set g [expr {$gi / 255.0}]
	set b [expr {$bi / 255.0}]
	set mx [expr {max($r, max($g, $b))}]
	set mn [expr {min($r, min($g, $b))}]
	set d  [expr {$mx - $mn}]
	set v  $mx
	set s  [expr {$mx <= 0 ? 0 : $d / $mx}]
	if {$d <= 0} {
		set h 0
	} elseif {$mx == $r} {
		set h [expr {60.0 * fmod((($g - $b) / $d), 6.0)}]
	} elseif {$mx == $g} {
		set h [expr {60.0 * ((($b - $r) / $d) + 2.0)}]
	} else {
		set h [expr {60.0 * ((($r - $g) / $d) + 4.0)}]
	}
	if {$h < 0} { set h [expr {$h + 360.0}] }
	return [list $h $s $v]
}

# Write one strip's colour to the machine.
# strip: "front" | "rear" ; hex: "#RRGGBB"
# Writes to the live/preview registers (FrontLEDColor / RearLEDColor).
proc ::led::write_strip {strip hex} {
	if {![is_bengle_model]} { return }
	switch -- $strip {
		"front" { set addr "803890" }
		"rear"  { set addr "803894" }
		default { return }
	}
	if {![::led::_validate_hex $hex]} { return }
	# Dedupe — skip the MMR write if this strip already has this colour.
	if {[string equal -nocase $::led::_last_written($strip) $hex]} {
		return
	}
	set ::led::_last_written($strip) $hex
	set val [::led::hex_to_int $hex]
	mmr_write "led_${strip} $hex" $addr "04" [long32_to_little_endian_hex $val]
}

# Write a stored awake/sleep colour to the firmware's persistent registers.
# The firmware applies these automatically on sleep/wake transitions.
# state: "awake" | "sleep" ; strip: "front" | "rear" ; hex: "#RRGGBB"
proc ::led::write_stored {state strip hex} {
	if {![is_bengle_model]} { return }
	switch -- "${state}_${strip}" {
		"awake_front" { set addr "803898" }
		"awake_rear"  { set addr "80389C" }
		"sleep_front" { set addr "8038A0" }
		"sleep_rear"  { set addr "8038A4" }
		default { return }
	}
	if {![::led::_validate_hex $hex]} { return }
	set val [::led::hex_to_int $hex]
	mmr_write "led_${state}_${strip} $hex" $addr "04" [long32_to_little_endian_hex $val]
}

proc ::led::_validate_hex {hex} {
	set stripped [string trimleft $hex "#"]
	if {[string length $stripped] != 6 || ![regexp {^[0-9A-Fa-f]{6}$} $stripped]} {
		::comms::msg -WARNING "::led: bad hex '$hex', skipping"
		return 0
	}
	return 1
}

# Write to one strip or both, per target mode.
# target: "front" | "rear" | "both" ; hex: "#RRGGBB"
proc ::led::write_target {target hex} {
	switch -- $target {
		"front" { ::led::write_strip front $hex }
		"rear"  { ::led::write_strip rear  $hex }
		"both"  { ::led::write_strip front $hex; ::led::write_strip rear $hex }
	}
}

# Push all 4 stored colours to the firmware's persistent registers.
# The firmware applies the correct pair automatically on sleep/wake.
# Called on connect and when the picker saves changes.
proc ::led::push_all_stored {} {
	if {![is_bengle_model]} { return }
	::led::write_stored awake front $::settings(led_front_awake_colour)
	::led::write_stored awake rear  $::settings(led_rear_awake_colour)
	::led::write_stored sleep front $::settings(led_front_sleep_colour)
	::led::write_stored sleep rear  $::settings(led_rear_sleep_colour)
}

# No state-change listener needed — firmware switches LEDs autonomously.


# Bengle-specific UI logic (cup warmer / LED picker / firmware update procs),
# extracted from the Insight skin so all Bengle behaviour lives in one file.
# Sourced here (loaded early) so the procs exist before the skin builds the pages
# that reference them. Page/widget construction stays in the skin.
source "[homedir]/bengle.tcl"
