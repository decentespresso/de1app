package provide de1_comms 1.0

### Helper

proc int_to_hex {in} {
	return [format %02X $in]
}

proc long_to_little_endian_hex {in} {
	set i [format %04X $in]
	#msg "i: '$i"
	set i2 "[string range $i 2 3][string range $i 0 1]"
	#msg "i2: '$i2"
	return $i2
}

proc userdata_append {comment cmd {vital 0} } {
	lappend ::de1(cmdstack) [list $comment $cmd $vital]
	run_next_userdata_cmd
}

proc run_next_userdata_cmd {} {
	if {$::android == 1} {
		# if running on android, only write one BLE command at a time
		if {$::de1(wrote) == 1} {
			#msg "Do not write, already writing to DE1, queue has [llength $::de1(cmdstack)] items"
			return
		}
	}
	if {($::de1(device_handle) == "0" || $::de1(device_handle) == "1") && $::de1(scale_device_handle) == "0"} {
		#msg "run_next_userdata_cmd error: de1 not connected"
		return
	}

	if {$::de1(cmdstack) ne {}} {

		set cmd [lindex $::de1(cmdstack) 0]
		set cmds [lrange $::de1(cmdstack) 1 end]
		set vital [lindex $cmd 2]

		set result 0
		msg ">>> [lindex $cmd 0] (-[llength $::de1(cmdstack)]) : [lindex $cmd 1]"
		set eer ""
		set errcode [catch {
			set result [{*}[lindex $cmd 1]]			
		} eer]

		if {$errcode != 0} {
			catch {
				msg "run_next_userdata_cmd catch error: $::errorInfo"
			}
		}



		if {$result != 1} {

			if {[string first "invalid handle" $::errorInfo] != -1 } {
				msg "Not retrying this command because BLE handle for the device is now invalid"
				#after 500 run_next_userdata_cmd
			} elseif {$vital != 1 } {
				msg "Not retrying this because it is not vital"
				#after 500 run_next_userdata_cmd
			} else {
				if {$eer != 0} {
					msg "BLE command failed, will retry ($result): [lindex $cmd 1] ($eer) $::errorInfo"
				} else {
					msg "BLE command failed, will retry ($result): [lindex $cmd 1] ($eer)"
				}

				# test idea to keep scale from interference with DE1
				#if {$::de1(scale_device_handle) != 0} {
				#	ble abort $::de1(scale_device_handle)
				#}


				# john 4/28/18 not sure if we should give up on the command if it fails, or retry it
				# retrying a command that will forever fail kind of kills the BLE abilities of the app
				
				after 500 run_next_userdata_cmd
				update
				return 
			}
		}


		set ::de1(cmdstack) $cmds
		set ::de1(wrote) 1
		set ::de1(previouscmd) [lindex $cmd 1]
		if {[llength $::de1(cmdstack)] == 0} {
			msg "BLE command queue is now empty"
		}

		# try the bluetooth stack in a second, in case there were no bluetooth commands succeeded
		# and thus the queue doesn't keep getting tried
		after 1000 run_next_userdata_cmd

	} else {
		#msg "no userdata cmds to run"
	}
}


### Commands
proc read_de1_version {} {
	catch {
		userdata_append "read_de1_version" [list de1_ble read Version] 1
	}
}

# repeatedly request de1 state
proc poll_de1_state {} {

	msg "poll_de1_state"
	read_de1_state
	after 1000 poll_de1_state
}

proc read_de1_state {} {
	if {$::android != 1} {
		return
	}
	if {[catch {
		userdata_append "read de1 state" [list de1_ble read StateInfo] 1
	} err] != 0} {
		msg "Failed to 'read de1 state' in DE1 BLE because: '$err'"
	}
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
				msg "MMR is not enabled on this DE1 BLE API <4 #: [de1_version_bleapi]"
				set ::settings(mmr_enabled) 0
			}

			save_settings

			set ::mmr_enabled $::settings(mmr_enabled)
		}

	}
	return $::mmr_enabled
}

proc mmr_read {note address length} {
	if {[mmr_available] == 0} {
		msg "Unable to mmr_read because MMR not available"
		return
	}


	set mmrlen [binary decode hex $length]	
	set mmrloc [binary decode hex $address]
	set data "$mmrlen${mmrloc}[binary decode hex 00000000000000000000000000000000]"
	
	if {$::android != 1} {
		msg "MMR non-android requesting read $address:$length [convert_string_to_hex $mmrlen] bytes of firmware data from [convert_string_to_hex $mmrloc]: with comment [convert_string_to_hex $data]"
	}

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 11"
		return
	}

	set cmt "MMR requesting read '$note' [convert_string_to_hex $mmrlen] bytes of firmware data from [convert_string_to_hex $mmrloc] with '[convert_string_to_hex $data]'"
	msg "queing $cmt"
	userdata_append $cmt [list de1_ble write "ReadFromMMR" $data] 1

}

proc mmr_write { note address length value} {
	if {[mmr_available] == 0} {
		msg "Unable to mmr_read because MMR not available"
		return
	}

	set mmrlen [binary decode hex $length]	
	set mmrloc [binary decode hex $address]
	set mmrval [binary decode hex $value]	
	set data "$mmrlen${mmrloc}${mmrval}[binary decode hex 0000000000000000000000000000000000]"

	#msg "mmr write length [string length $data]"
	if {[string length $data] > 20} {
		set data [string range $data 0 19]
		#msg "mmr new write length [string length $data]"
	}
	
	if {$::android != 1} {
		msg "MMR $note writing [convert_string_to_hex $mmrlen] bytes of firmware data to [convert_string_to_hex $mmrloc] with value [convert_string_to_hex $mmrval] : with comment [convert_string_to_hex $data]"
	}

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 11"
		return
	}
	userdata_append "MMR $note writing [convert_string_to_hex $mmrlen] bytes of firmware data to [convert_string_to_hex $mmrloc] with value [convert_string_to_hex $mmrval] : with comment [convert_string_to_hex $data]" [list de1_ble write "WriteToMMR" $data] 1
}


proc mmr_read {note address length} {
	if {[mmr_available] == 0} {
		msg "Unable to mmr_read because MMR not available"
		return
	}


	set mmrlen [binary decode hex $length]	
	set mmrloc [binary decode hex $address]
	set data "$mmrlen${mmrloc}[binary decode hex 00000000000000000000000000000000]"
	
	if {$::android != 1} {
		msg "MMR non-android requesting read $address:$length [convert_string_to_hex $mmrlen] bytes of firmware data from [convert_string_to_hex $mmrloc]: with comment [convert_string_to_hex $data]"
	}

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 11"
		return
	}

	set cmt "MMR requesting read '$note' [convert_string_to_hex $mmrlen] bytes of firmware data from [convert_string_to_hex $mmrloc] with '[convert_string_to_hex $data]'"
	msg "queing $cmt"
	userdata_append $cmt [list de1_ble write "ReadFromMMR" $data] 1

}

proc mmr_write { note address length value} {
	if {[mmr_available] == 0} {
		msg "Unable to mmr_read because MMR not available"
		return
	}

	set mmrlen [binary decode hex $length]	
	set mmrloc [binary decode hex $address]
	set mmrval [binary decode hex $value]	
	set data "$mmrlen${mmrloc}${mmrval}[binary decode hex 0000000000000000000000000000000000]"

	#msg "mmr write length [string length $data]"
	if {[string length $data] > 20} {
		set data [string range $data 0 19]
		#msg "mmr new write length [string length $data]"
	}
	
	if {$::android != 1} {
		msg "MMR $note writing [convert_string_to_hex $mmrlen] bytes of firmware data to [convert_string_to_hex $mmrloc] with value [convert_string_to_hex $mmrval] : with comment [convert_string_to_hex $data]"
	}

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 11"
		return
	}
	userdata_append "MMR $note writing [convert_string_to_hex $mmrlen] bytes of firmware data to [convert_string_to_hex $mmrloc] with value [convert_string_to_hex $mmrval] : with comment [convert_string_to_hex $data]" [list de1_ble write "WriteToMMR" $data] 1
}

proc set_tank_temperature_threshold {temp} {
	msg "Setting desired water tank temperature to '$temp' [stacktrace]"

	if {$temp < 10} {
		# no point in circulating the water if the desired temp is <10ºC, or no preheating.
		mmr_write "set_tank_temperature_threshold" "80380C" "04" [zero_pad [int_to_hex $temp] 2]
	} else {
		# if the water temp is being set, then set the water temp temporarily to 60º in order to force a water circulation for 2 seconds
		# then a few seconds later, set it to the real, desired value
		set hightemp 60
		mmr_write "set_tank_temperature_threshold" "80380C" "04" [zero_pad [int_to_hex $hightemp] 2]
		after 4000 [list mmr_write "set_tank_temperature_threshold" "80380C" "04" [zero_pad [int_to_hex $temp] 2]]
	}
}

# /*
#  *  Memory Mapped Registers
#  *
#  *  RangeNum Position       Len  Desc
#  *  -------- --------       ---  ----
#  *         1 0x0080 0000      4  : HWConfig
#  *         2 0x0080 0004      4  : Model
#  *         3 0x0080 2800      4  : How many characters in debug buffer are valid. Accessing this pauses BLE debug logging.
#  *         4 0x0080 2804 0x1000  : Last 4K of output. Zero terminated if buffer not full yet. Pauses BLE debug logging.
#  *         6 0x0080 3808      4  : Fan threshold.
#  *         7 0x0080 380C      4  : Tank water threshold.
#  *        11 0x0080 381C      4  : GHC Info Bitmask, 0x1 = GHC Present, 0x2 = GHC Active
#  *
#  */


proc get_heater_tweaks_obs {} {
	#mmr_read "hot_water_idle_temp" "803818" "00"
	#after 3000 mmr_read "espresso_warmup_timeout" "803838" "00"
}

proc get_heater_voltage {} {
	msg "Getting heater voltage"
	mmr_read "get_heater_voltage" "803834" "01"
}


# 4 - 121. (2020-07-09 20:43:40) >>> MMR hot_water_idle_temp 800 writing 04 bytes of firmware data to 80 38 18 with value 03 20 : with comment 04 80 38 18 03 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 (-2) : ble write ble1 0000A000-0000-1000-8000-00805F9B34FB 12 0000A006-0000-1000-8000-00805F9B34FB 29 {8 
# 2 - 130. (2020-07-09 20:45:57) >>> MMR hot_water_idle_temp 790 writing 04 bytes of firmware data to 80 38 18 with value 31 :    with comment 04 80 38 18 31 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 (-2) : ble write ble2 0000A000-0000-1000-8000-00805F9B34FB 12 0000A006-0000-1000-8000-00805F9B34FB 29 81
proc set_heater_tweaks {} {
	#set ::settings(hot_water_idle_temp) 790

	mmr_write "phase_1_flow_rate $::settings(phase_1_flow_rate)" "803810" "04" [zero_pad [long_to_little_endian_hex $::settings(phase_1_flow_rate)] 4]
	mmr_write "phase_2_flow_rate $::settings(phase_2_flow_rate)" "803814" "04" [zero_pad [long_to_little_endian_hex $::settings(phase_2_flow_rate)] 4]
	mmr_write "hot_water_idle_temp $::settings(hot_water_idle_temp)" "803818" "04" [zero_pad [long_to_little_endian_hex $::settings(hot_water_idle_temp)] 4]
	mmr_write "espresso_warmup_timeout $::settings(espresso_warmup_timeout)" "803838" "04" [zero_pad [long_to_little_endian_hex $::settings(espresso_warmup_timeout)] 4]
}

proc set_steam_flow {desired_flow} {
	#return
	msg "Setting steam flow rate to '$desired_flow'"
	mmr_write "set_steam_flow" "803828" "04" [zero_pad [int_to_hex $desired_flow] 2]
}

proc get_steam_flow {} {
	msg "Getting steam flow rate"
	mmr_read "get_steam_flow" "803828" "00"
}

proc get_3_mmr_cpuboard_machinemodel_firmwareversion {} {
	mmr_read "cpuboard_machinemodel_firmwareversion" "800008" "02"

}

proc get_cpu_board_model {} {
	msg "Getting CPU board model"
	mmr_read "get_cpu_board_model" "800008" "00"
}

proc get_machine_model {} {
	msg "Getting machine model"
	mmr_read "get_machine_model" "80000C" "00"
}

proc get_firmware_version_number {} {
	msg "Getting firmware version number"
	mmr_read "get_firmware_version_number" "800010" "00"
}

proc set_heater_voltage {heater_voltage} {
	#return
	msg "Setting heater voltage to '$heater_voltage'"
	mmr_write "set_heater_voltage" "803834" "04" [zero_pad [int_to_hex $heater_voltage] 2]
}



proc set_steam_highflow_start {desired_seconds} {
	#return
	msg "Setting steam high flow rate start seconds to '$desired_seconds'"
	mmr_write "set_steam_highflow_start" "80382C" "04" [zero_pad [int_to_hex $desired_seconds] 2]
}

proc get_steam_highflow_start {} {
	msg "Getting steam high flow rate start seconds "
	mmr_read "get_steam_highflow_start" "80382C" "00"
}


proc set_ghc_mode {desired_mode} {
	msg "Setting group head control mode '$desired_mode'"
	mmr_write "set_ghc_mode" "803820" "04" [zero_pad [int_to_hex $desired_mode] 2]
}

proc get_ghc_mode {} {
	msg "Reading group head control mode"
	mmr_read "get_ghc_mode" "803820" "00"
}

proc get_ghc_is_installed {} {
	msg "Reading whether the group head controller (GHC) is installed or not"
	mmr_read "get_ghc_is_installed" "80381C" "00"
}

proc get_fan_threshold {} {
	msg "Reading at what temperature the PCB fan turns on"
	mmr_read "get_fan_threshold" "803808" "00"
}

proc set_fan_temperature_threshold {temp} {
	msg "Setting fan temperature to '$temp'"
	mmr_write "set_fan_temperature_threshold" "803808" "04" [zero_pad [int_to_hex $temp] 2]
}

proc get_tank_temperature_threshold {} {
	msg "Reading desired water tank temperature"
	mmr_read "get_tank_temperature_threshold" "80380C" "00"
}

proc de1_send_waterlevel_settings {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 12"
		return
	}

	set data [return_de1_packed_waterlevel_settings]
	parse_binary_water_level $data arr2
	userdata_append "Set water level settings: [array get arr2]" [list de1_ble write "WaterLevels" $data] 1
}


proc app_exit {} {
	close_log_file

	if {$::android != 1} {
		close_all_ble_and_exit
	}

	# john 1/15/2020 this is a bit of a hack to work around a firmware bug in 7C24F200 that has the fan turn on during sleep, if the fan threshold is set > 0
	set_fan_temperature_threshold 0

	set ::exit_app_on_sleep 1
	start_sleep
	
	# fail-over, if the DE1 doesn't to to sleep
	set since_last_ping [expr {[clock seconds] - $::de1(last_ping)}]
	if {$since_last_ping > 10} {
		# wait less time for the fail-over if we don't have any temperature pings from the DE1
		after 1000 close_all_ble_and_exit
	} else {
		after 5000 close_all_ble_and_exit
	}

	after 5000 { .can itemconfigure $::message_button_label -text [translate "Quit"] }


	after 10000 "exit 0"
}

proc de1_send_state {comment msg} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 13"
		return
	}

	#clear_timers
	delay_screen_saver
	
	#if {$::de1(device_handle) == "0"} {
	#	msg "error: de1 not connected"
	#	return
	#}

	#set ::de1(substate) -
	#msg "Sending to DE1: '$msg'"
	userdata_append $comment [list de1_ble write "RequestedState" "$msg"] 1
}

proc de1_send_shot_frames {} {

	msg "de1_send_shot_frames"

	set parts [de1_packed_shot]
	set header [lindex $parts 0]
	
	####
	# this is purely for testing the parser/deparser
	parse_binary_shotdescheader $header arr2
	#msg "frame header of [string length $header] bytes parsed: $header [array get arr2]"
	####


	userdata_append "Espresso header: [array get arr2]" [list de1_ble write "HeaderWrite" $header] 1

	set cnt 0
	foreach packed_frame [lindex $parts 1] {

		####
		# this is purely for testing the parser/deparser
		incr cnt
		unset -nocomplain arr3
		parse_binary_shotframe $packed_frame arr3
		#msg "frame #$cnt data parsed [string length $packed_frame] bytes: $packed_frame  : [array get arr3]"
		msg "frame #$cnt: [string length $packed_frame] bytes: [array get arr3]"
		####

		userdata_append "Espresso frame #$cnt: [array get arr3] (FLAGS: [parse_shot_flag $arr3(Flag)])"  [list de1_ble write "FrameWrite" $packed_frame] 1
	}

	# only set the tank temperature for advanced profile shots
	if {$::settings(settings_profile_type) == "settings_2c"} {
		set_tank_temperature_threshold $::settings(tank_desired_water_temperature)
	} else {
		set_tank_temperature_threshold 0
	}


	return
}

proc save_settings_to_de1 {} {
	de1_send_shot_frames
	de1_send_steam_hotwater_settings
}

proc de1_send_steam_hotwater_settings {} {

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 16"
		return
	}

	set data [return_de1_packed_steam_hotwater_settings]
	parse_binary_hotwater_desc $data arr2
	userdata_append "Set water/steam settings: [array get arr2]" [list de1_ble write "ShotSettings" $data] 1

	set_steam_flow $::settings(steam_flow)
	set_steam_highflow_start $::settings(steam_highflow_start)
}

proc de1_send_calibration {calib_target reported measured {calibcmd 1} } {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 17"
		return
	}

	if {$calib_target == "flow"} {
		set target 0
	} elseif {$calib_target == "pressure"} {
		set target 1
	} elseif {$calib_target == "temperature"} {
		set target 2
	} else {
		msg "Unknown calibration send target: '$calib_target'"
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
	userdata_append "Set calibration: [array get arr2] : [string length $data] bytes: ([convert_string_to_hex $data])" [list de1_ble write "Calibration" $data] 1
}

proc de1_read_calibration {calib_target {factory 0} } {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 18"
		return
	}


	if {$calib_target == "flow"} {
		set target 0
	} elseif {$calib_target == "pressure"} {
		set target 1
	} elseif {$calib_target == "temperature"} {
		set target 2
	} else {
		msg "Unknown calibration write target: '$calib_target'"
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
	userdata_append "Read $what calibration: [array get arr2] : [string length $data] bytes: ([convert_string_to_hex $data])" [list de1_ble write "Calibration" $data] 1

}

proc de1_read_version_obsolete {} {
	msg "LIKELY OBSOLETE BLE FUNCTION: DO NOT USE"

	#if {$::de1(device_handle) == "0"} {
	#	msg "error: de1 not connected"
	#	return
	#}

	userdata_append "read de1 version" [list de1_ble read "Temperatures"] 1
}

proc de1_read_hotwater {} {
	#if {$::de1(device_handle) == "0"} {
	#	msg "error: de1 not connected"
	#	return
	#}

	userdata_append "read de1 hot water/steam" [list de1_ble read "ShotSettings"] 1
}

proc de1_read_shot_header {} {
	#if {$::de1(device_handle) == "0"} {
	#	msg "error: de1 not connected"
	#	return
	#}

	userdata_append "read shot header" [list de1_ble read "HeaderWrite"] 1
}
proc de1_read_shot_frame {} {
	#if {$::de1(device_handle) == "0"} {
	#	msg "error: de1 not connected"
	#	return
	#}

	userdata_append "read shot frame" [list de1_ble read "FrameWrite"] 1
}

### Notification Settings

# calibration change notifications ENABLE
proc de1_enable_calibration_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 1"
		return
	}

	userdata_append "enable de1 calibration notifications" [list de1_ble enable Calibration] 1
}

# calibration change notifications DISABLE
proc de1_disable_calibration_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 2"
		return
	}

	userdata_append "disable de1 calibration notifications" [list de1_ble disable Calibration)] 1
}

# temp changes
proc de1_enable_temp_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 3"
		return
	}

	userdata_append "enable de1 temp notifications" [list de1_ble enable "ShotSample"] 1
}

# status changes
proc de1_enable_state_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 4"
		return
	}

	userdata_append "enable de1 state notifications" [list de1_ble enable "StateInfo"] 1
}

proc de1_disable_temp_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 5"
		return
	}

	userdata_append "disable temp notifications" [list de1_ble disable "ShotSample"] 1
}

proc de1_disable_state_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 6"
		return
	}

	userdata_append "disable state notifications" [list de1_ble disable "StateInfo"] 1
}

proc de1_enable_mmr_notifications {} {

	if {[mmr_available] == 0} {
		msg "Unable to de1_enable_mmr_notifications because MMR not available"
		return
	}

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 7"
		return
	}

	#userdata_append "enable MMR write notifications" [list de1_ble  enable "WriteToMMR"] 1
	userdata_append "enable MMR read notifications" [list de1_ble enable "ReadFromMMR"] 1
}

# water level notifications
proc de1_enable_water_level_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 7"
		return
	}

	userdata_append "enable de1 water level notifications" [list de1_ble  enable "WaterLevels"] 1
}

proc de1_disable_water_level_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 8"
		return
	}

	userdata_append "disable state notifications" [list de1_ble  disable "WaterLevels"] 1
}

# firmware update command notifications (not writing new fw, this is for erasing and switching firmware)
proc de1_enable_maprequest_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 9"
		return
	}

	userdata_append "enable de1 state notifications" [list de1_ble  enable "FWMapRequest"] 1
}


proc fwfile {} {

	set fw "[homedir]/fw/bootfwupdate.dat"

	if {[info exists ::de1(Firmware_file_Version)] != 1} {
		msg "reading firmware file metadata"
		parse_firmware_file_header [read_binary_file $fw] arr
		#msg "firmware file info: [array get arr]"
		foreach {k v} [array get arr] {
			set varname "Firmware_file_$k"
			set varvalue $arr($k)
			msg "$varname : $varvalue"
			set ::de1($varname) $varvalue
		}
	}

	return $fw

	# obsolete as of 6-6-20 a only using one firmware file again now
		
	if {$::settings(ghc_is_installed) != 0} {
		# new firmware for v1.3 machines and newer, that have a GHC.
		# this dual firmware aspect is temporary, only until we have improved the firmware to be able to correctly migrate v1.0 v1.1 hardware machines to the new calibration settings.
		# please do not bypass this test and load the new firmware on your v1.0 v1.1 machines yet.  Once we have new firmware is known to work on those older machines, we'll get rid of the 2nd firmware image.

		# note that ghc_is_installed=1 ghc hw is there but unused, whereas ghc_is_installed=3 ghc hw is required.
		msg "using v1.3 firmware"
		return "[homedir]/fw/bootfwupdate2.dat"
	} else {
		msg "using v1.1 firmware"
		return "[homedir]/fw/bootfwupdate.dat"
	}
}


proc start_firmware_update {} {

	puts "start_firmware_update : [stacktrace]"

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		if {$::android == 1} {
			msg "DE1 not connected, cannot send BLE command 10"
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
		msg "Already erasing firmware"
		return
	}

	if {$::de1(currently_updating_firmware) == 1} {
		msg "Already updating firmware"
		return
	}

	#de1_enable_maprequest_notifications
	
	set ::de1(firmware_bytes_uploaded) 0
	set ::de1(firmware_update_size) [file size [fwfile]]

	if {$::android != 1} {
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


	if {$::android == 1} {
		userdata_append "Erase firmware do: [array get arr]" [list de1_ble  write "FWMapRequest" $data] 1
		after 10000 write_firmware_now
	} else {
		after 1000 write_firmware_now
	}
}

#proc get_firmware_file_specs {} {
#	parse_firmware_file_header [read_binary_file [fwfile]] arr
#	msg "firmware file info: [array get arr]"
#}

proc write_firmware_now {} {
	set ::de1(currently_updating_firmware) 1
	set ::de1(currently_erasing_firmware) 0
	set ::de1(firmware_update_start_time) [clock milliseconds]
	msg "Start writing firmware now [stacktrace]"

	set ::de1(firmware_update_binary) [read_binary_file [fwfile]]
	set ::de1(firmware_bytes_uploaded) 0

	firmware_upload_next
}


proc firmware_upload_next {} {
	
	if {$::android == 1} {
		msg "firmware_upload_next $::de1(firmware_bytes_uploaded)"
	}

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 11"
		return
	}

	#delay_screen_saver

	if  {$::de1(firmware_bytes_uploaded) >= $::de1(firmware_update_size)} {
		set ::settings(firmware_crc) [crc::crc32 -filename [fwfile]]
		save_settings

		if {$::android != 1} {
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
			userdata_append "Find first error in firmware update: [array get arr]" [list de1_ble write "FWMapRequest" $data] 1
		}
	} else {
		set ::de1(firmware_update_button_label) "Updating"

		set data "\x10[make_U24P0 $::de1(firmware_bytes_uploaded)][string range $::de1(firmware_update_binary) $::de1(firmware_bytes_uploaded) [expr {15 + $::de1(firmware_bytes_uploaded)}]]"
		userdata_append "Write [string length $data] bytes of firmware data ([convert_string_to_hex $data])" {[list de1_ble write "WriteToMMR" $data]} 1
		set ::de1(firmware_bytes_uploaded) [expr {$::de1(firmware_bytes_uploaded) + 16}]
		if {$::android != 1} {
			set ::de1(firmware_bytes_uploaded) [expr {$::de1(firmware_bytes_uploaded) + 160}]
			after 1 firmware_upload_next
			#firmware_upload_next
		}
	}
}