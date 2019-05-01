
package provide de1_bluetooth

set ::failed_attempt_count_connecting_to_de1 0
set ::successful_de1_connection_count 0

#set suuid "0000A000-0000-1000-8000-00805F9B34FB"
#set sinstance 0
#set cuuid "0000a001-0000-1000-8000-00805f9b34fb"
#set cinstance 0

# a00b = hot water/steam settings
# a00c = espresso frame settings


proc userdata_append {comment cmd} {
	#set cmds [ble userdata $::de1(device_handle)]
	#lappend cmds $cmd
	#ble userdata $::de1(device_handle) $cmds
	lappend ::de1(cmdstack) [list $comment $cmd]
	run_next_userdata_cmd
	#set ::de1(wrote) 1
}




proc read_de1_version {} {
	#puts "read_de1_version"
	userdata_append "read_de1_version" [list ble read $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_01) $::cinstance($::de1(cuuid_01))]
}

# repeatedly request de1 state
proc poll_de1_state {} {

	msg "poll_de1_state"

	#de1_enable_bluetooth_notifications
	read_de1_state
	#userdata_append "read de1 temp" [list ble read $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0D) $::cinstance($::de1(cuuid_0D))]
	#userdata_append "read de1 state" [list ble read $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0E) $::cinstance($::de1(cuuid_0E))]
	after 1000 poll_de1_state
}

proc read_de1_state {} {
	userdata_append "read de1 state" [list ble read $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0E) $::cinstance($::de1(cuuid_0E))]
}

proc skale_timer_start {} {
	if {$::de1(skale_device_handle) == 0} {
		return 
	}

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot start timer"
		return
	}

	set timeron [binary decode hex "DD"]
	userdata_append "Skale : timer start" [list ble write $::de1(skale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $timeron]

}



proc skale_timer_stop {} {

	if {$::de1(skale_device_handle) == 0} {
		return 
	}
	set tare [binary decode hex "D1"]
	#set ::de1(scale_weight) 0
	#set ::de1(scale_weight_rate) 0

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot stop timer"
		return
	}

	userdata_append "Skale: timer stop" [list ble write $::de1(skale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $tare]
}

proc skale_timer_off {} {

	if {$::de1(skale_device_handle) == 0} {
		return 
	}
	set tare [binary decode hex "D0"]
	#set ::de1(scale_weight) 0
	#set ::de1(scale_weight_rate) 0

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot off timer"
		return
	}



	userdata_append "Skale: timer off" [list ble write $::de1(skale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $tare]
}



proc skale_tare {} {
	if {$::de1(skale_device_handle) == 0} {
		return 
	}
	set tare [binary decode hex "10"]
	set ::de1(scale_weight) 0
	set ::de1(scale_weight_rate) 0

	# if this was a scheduled tare, indicate that the tare has completed
	unset -nocomplain ::scheduled_skale_tare_id

	#set ::de1(final_espresso_weight) 0

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot tare"
		return
	}

	userdata_append "Skale: tare" [list ble write $::de1(skale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $tare]
}

proc skale_enable_weight_notifications {} {
	if {$::de1(skale_device_handle) == 0} {
		return 
	}

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot enable weight notifications"
		return
	}

	userdata_append "enable Skale weight notifications" [list ble enable $::de1(skale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF81) $::cinstance($::de1(cuuid_skale_EF81))]
}

proc skale_enable_button_notifications {} {
	if {$::de1(skale_device_handle) == 0} {
		return 
	}

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot enable button notifications"
		return
	}


	userdata_append "enable Skale button notifications" [list ble enable $::de1(skale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF82) $::cinstance($::de1(cuuid_skale_EF82))]
}

proc skale_enable_grams {} {
	if {$::de1(skale_device_handle) == 0} {
		return 
	}
	set grams [binary decode hex "03"]

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot enable grams"
		return
	}

	userdata_append "Skale : enable grams" [list ble write $::de1(skale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $grams]
}

proc skale_enable_lcd {} {
	if {$::de1(skale_device_handle) == 0} {
		return 
	}
	set screenon [binary decode hex "ED"]
	set displayweight [binary decode hex "EC"]

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot enable LCD"
		return
	}

	userdata_append "Skale : enable LCD" [list ble write $::de1(skale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $screenon]
	userdata_append "Skale : display weight on LCD" [list ble write $::de1(skale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $displayweight]
	#ble write $::de1(skale_device_handle) "0000FF08-0000-1000-8000-00805F9B34FB" 0 "0000EF80-0000-1000-8000-00805F9B34FB" 0 $displayweight
}

proc skale_disable_lcd {} {
	if {$::de1(skale_device_handle) == 0} {
		return 
	}
	set screenoff [binary decode hex "EE"]

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot disable LCD"
		return
	}

	userdata_append "Skale : disable LCD" [list ble write $::de1(skale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $screenoff]
}


# calibration change notifications ENABLE
proc de1_enable_calibration_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 1"
		return
	}

	userdata_append "enable de1 calibration notifications" [list ble enable $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_12) $::cinstance($::de1(cuuid_12))]
}

# calibration change notifications DISABLE
proc de1_disable_calibration_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 2"
		return
	}

	userdata_append "disable de1 calibration notifications" [list ble disable $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_12) $::cinstance($::de1(cuuid_12))]
}

# temp changes
proc de1_enable_temp_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 3"
		return
	}

	userdata_append "enable de1 temp notifications" [list ble enable $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0D) $::cinstance($::de1(cuuid_0D))]
}

# status changes
proc de1_enable_state_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 4"
		return
	}

	userdata_append "enable de1 state notifications" [list ble enable $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0E) $::cinstance($::de1(cuuid_0E))]
}

proc de1_disable_temp_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 5"
		return
	}

	userdata_append "disable temp notifications" [list ble disable $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0D) $::cinstance($::de1(cuuid_0D))]
}

proc de1_disable_state_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 6"
		return
	}

	userdata_append "disable state notifications" [list ble disable $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0E) $::cinstance($::de1(cuuid_0E))]
}

# water level notifications
proc de1_enable_water_level_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 7"
		return
	}

	userdata_append "enable de1 water level notifications" [list ble enable $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_11) $::cinstance($::de1(cuuid_11))]
}

proc de1_disable_water_level_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 8"
		return
	}

	userdata_append "disable state notifications" [list ble disable $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_11) $::cinstance($::de1(cuuid_11))]
}

# firmware update command notifications (not writing new fw, this is for erasing and switching firmware)
proc de1_enable_maprequest_notifications {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 9"
		return
	}

	userdata_append "enable de1 state notifications" [list ble enable $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_09) $::cinstance($::de1(cuuid_09))]
}

proc fwfile {} {
	return "[homedir]/fw/bootfwupdate.dat"
}


proc start_firmware_update {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		if {$::android == 1} {
			msg "DE1 not connected, cannot send BLE command 10"
			return
		}
	}


	if {$::de1(currently_erasing_firmware) == 1} {
		msg "Already erasing firmware"
		return
	}

	if {$::de1(currently_updating_firmware) == 1} {
		msg "Already updating firmware"
		return
	}

	de1_enable_maprequest_notifications
	
	set ::de1(firmware_bytes_uploaded) 0
	set ::de1(firmware_update_size) [file size [fwfile]]

	if {$::android != 1} {
		after 100 write_firmware_now
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

	set ::de1(firmware_update_button_label) "Updating"

	# it'd be useful here to test that the maprequest was correctly packed
	set ::de1(currently_erasing_firmware) 1
	userdata_append "Erase firmware: [array get arr]" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_09) $::cinstance($::de1(cuuid_09)) $data]

}

proc write_firmware_now {} {
	set ::de1(currently_updating_firmware) 1
	msg "Start writing firmware now"

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
			
		} else {
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
			userdata_append "Find first error in firmware update: [array get arr]" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_09) $::cinstance($::de1(cuuid_09)) $data]
		}
	} else {
		set ::de1(firmware_update_button_label) "Updating"

		set data "\x10[make_U24P0 $::de1(firmware_bytes_uploaded)][string range $::de1(firmware_update_binary) $::de1(firmware_bytes_uploaded) [expr {15 + $::de1(firmware_bytes_uploaded)}]]"
		userdata_append "Write [string length $data] bytes of firmware data ([convert_string_to_hex $data])" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_06) $::cinstance($::de1(cuuid_06)) $data]
		set ::de1(firmware_bytes_uploaded) [expr {$::de1(firmware_bytes_uploaded) + 16}]
		if {$::android != 1} {
			after 1 firmware_upload_next
		}
	}
}


proc de1_send_waterlevel_settings {} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 12"
		return
	}


	#puts ">>>> Sending BLE hot water/steam settings"
	set data [return_de1_packed_waterlevel_settings]
	parse_binary_water_level $data arr2
	userdata_append "Set water level settings: [array get arr2]" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_11) $::cinstance($::de1(cuuid_11)) $data]
	#puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
	# for testing parser/deparser
	
	#msg "send de1_send_steam_hotwater_settings of [string length $data] bytes: $data  : [array get arr2]"

}



proc run_next_userdata_cmd {} {
	if {$::android == 1} {
		# if running on android, only write one BLE command at a time
		if {$::de1(wrote) == 1} {
			#msg "Do no write, already writing to DE1"
			return
		}
	}
	if {$::de1(device_handle) == "0" && $::de1(skale_device_handle) == "0"} {
		#msg "error: de1 not connected"
		return
	}

	#pause 300

	#msg "run_next_userdata_cmd $::de1(device_handle)"
	#set cmds {}
	
#	catch {
#		set cmds [ble userdata $::de1(device_handle)]
#	}
	if {$::de1(cmdstack) ne {}} {

		set cmd [lindex $::de1(cmdstack) 0]
		set cmds [lrange $::de1(cmdstack) 1 end]
		#msg "stack cmd: $cmd"
			#msg "{*}$cmd"
		#set result 0
		set result 0
		msg ">>> [lindex $cmd 0] (-[llength $::de1(cmdstack)])"
		catch {
			set result [{*}[lindex $cmd 1]]
			
			#msg " "
		}

		if {$result != 1} {
			msg "!!!! BLE command failed ($result): [lindex $cmd 1]"

			# john 4/28/18 not sure if we should give up on the command if it fails, or retry it
			# retrying a command that will forever fail kind of kills the BLE abilities of the app
			
			#after 500 run_next_userdata_cmd
			return 
		}


		#if {$result <= 0} {
			#msg "BLE command failed to start $result: $cmd"
			#return
		#}
		#pause 300
		#ble userdata $::de1(device_handle) $cmds
		set ::de1(cmdstack) $cmds
		set ::de1(wrote) 1
		set ::de1(previouscmd) [lindex $cmd 1]
		if {[llength $::de1(cmdstack)] == 0} {
			msg "BLE command queue is now empty"
		}

		catch {
			#after cancel $::bletimeoutid
		}
		#set ::bletimeoutid [after 5000 run_next_userdata_cmd]

	} else {
		#msg "no userdata cmds to run"
	}
}

proc close_all_ble_and_exit {} {
	if {$::scanning  == 1} {
		catch {
			ble stop $::ble_scanner
		}
	}
	
	msg "Closing de1"
	if {$::de1(device_handle) != 0} {
		catch {
			ble close $::de1(device_handle)
		}
	}

	msg "Closing skale"
	if {$::de1(skale_device_handle) != 0} {
		catch {
			ble close $::de1(skale_device_handle)
		}
	}

	catch {
		if {$::settings(ble_unpair_at_exit) == 1} {
			ble unpair $::de1(de1_address)
			ble unpair $::settings(bluetooth_address)
		}
	}

	#after 2000 exit
	exit 0
}	

proc app_exit {} {
	close_log_file

	if {$::android != 1} {
		close_all_ble_and_exit
	}

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
	userdata_append $comment [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_02) $::cinstance($::de1(cuuid_02)) "$msg"]
}


#proc send_de1_shot_and_steam_settings {} {
#	return
#	msg "send_de1_shot_and_steam_settings"
	#return
	#de1_send_shot_frames
#	de1_send_steam_hotwater_settings

#}

proc de1_send_shot_frames {} {


	#if {$::de1(device_handle) == "0"} {
	#	msg "error: de1 not connected"
	#	return
	#}

	#de1_disable_bluetooth_notifications	

	#msg ======================================
 #puts ">>>> Sending Espresso frames"
	#userdata_append de1_disable_bluetooth_notifications

	set parts [de1_packed_shot]
	set header [lindex $parts 0]
	
	####
	# this is purely for testing the parser/deparser
	parse_binary_shotdescheader $header arr2
	#msg "frame header of [string length $header] bytes parsed: $header [array get arr2]"
	####


	userdata_append "Espresso header: [array get arr2]" [list ble_write_00f $header]
	#userdata_append [list ble_write_00f $header]
	#userdata_append [list ble_write_00f $header]

	set cnt 0
	foreach packed_frame [lindex $parts 1] {

		####
		# this is purely for testing the parser/deparser
		incr cnt
		unset -nocomplain arr3
		parse_binary_shotframe $packed_frame arr3
		msg "frame #$cnt data parsed [string length $packed_frame] bytes: $packed_frame  : [array get arr3]"
		####
	#set enabled_features 

		userdata_append "Espresso frame #$cnt: [array get arr3] (FLAGS: [parse_shot_flag $arr3(Flag)])"  [list ble_write_010 $packed_frame]
	}
	#puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

	return
}

proc ble_write_010 {packed_frame} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 14"
		return
	}

	#ble begin $::de1(device_handle); 
	return [ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_10) $::cinstance($::de1(cuuid_10)) $packed_frame]
	#ble execute $::de1(device_handle); 
}

proc ble_write_00f {packed_frame} {
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 15"
		return
	}

	#ble begin $::de1(device_handle); 
	return [ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0F) $::cinstance($::de1(cuuid_0F)) $packed_frame]
	#ble execute $::de1(device_handle); 
}

proc save_settings_to_de1 {} {
	#if {$::de1(device_handle) == "0"} {
	#	msg "error: de1 not connected"
	#	return
	#}

	#de1_disable_temp_notifications
	de1_send_shot_frames
	#start_idle
	de1_send_steam_hotwater_settings
	#de1_enable_temp_notifications
}

proc de1_send_steam_hotwater_settings {} {

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 16"
		return
	}


	#puts ">>>> Sending BLE hot water/steam settings"
	set data [return_de1_packed_steam_hotwater_settings]
	parse_binary_hotwater_desc $data arr2
	userdata_append "Set water/steam settings: [array get arr2]" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0B) $::cinstance($::de1(cuuid_0B)) $data]
	#puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
	
	# for testing parser/deparser
	
	#msg "send de1_send_steam_hotwater_settings of [string length $data] bytes: $data  : [array get arr2]"
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
		msg "Uknown calibration target: '$calib_target'"
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
	userdata_append "Set calibration: [array get arr2] : [string length $data] bytes: ([convert_string_to_hex $data])" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_12) $::cinstance($::de1(cuuid_12)) $data]
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
		msg "Uknown calibration target: '$calib_target'"
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
	userdata_append "Read $what calibration: [array get arr2] : [string length $data] bytes: ([convert_string_to_hex $data])" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_12) $::cinstance($::de1(cuuid_12)) $data]

}

proc de1_read_version {} {
	#if {$::de1(device_handle) == "0"} {
	#	msg "error: de1 not connected"
	#	return
	#}

	userdata_append "read de1 version" [list ble read $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0A) $::cinstance($::de1(cuuid_0A))]
}

proc de1_read_hotwater {} {
	#if {$::de1(device_handle) == "0"} {
	#	msg "error: de1 not connected"
	#	return
	#}

	userdata_append "read de1 hot water/steam" [list ble read $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0B) $::cinstance($::de1(cuuid_0B))]
}

proc de1_read_shot_header {} {
	#if {$::de1(device_handle) == "0"} {
	#	msg "error: de1 not connected"
	#	return
	#}

	userdata_append "read shot header" [list ble read $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0F) $::cinstance($::de1(cuuid_0F))]
}
proc de1_read_shot_frame {} {
	#if {$::de1(device_handle) == "0"} {
	#	msg "error: de1 not connected"
	#	return
	#}

	userdata_append "read shot frame" [list ble read $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_10) $::cinstance($::de1(cuuid_10))]
}

proc remove_null_terminator {instr} {
	set pos [string first "\x00" $instr]
	if {$pos == -1} {
		return $instr
	}

	incr pos -1
	return [string range $instr 0 $pos]
}

set ::ble_scanner [ble scanner de1_ble_handler]
set ::scanning -1
proc ble_find_de1s {} {

	return
	if {$::android != 1} {
		ble_connect_to_de1
	}
	
	#puts "ble_find_de1s"
	after 30000 stop_scanner
	ble start $::ble_scanner
}

proc stop_scanner {} {

	if {$::scanning == 0} {
		return
	}

	if {$::de1(device_handle) == 0} {
		# don't stop scanning if there is no DE1 connection
		after 30000 stop_scanner
		return
	}

	set ::scanning 0
	ble stop $::ble_scanner
	#userdata_append "stop scanning" [list ble stop $::ble_scanner]
}

proc bluetooth_connect_to_devices {} {
	if {$::settings(bluetooth_address) != ""} {
		ble_connect_to_de1
	}

	if {$::settings(skale_bluetooth_address) != ""} {
		after 3000 ble_connect_to_skale
	}

}


set ::currently_connecting_de1_handle 0
proc ble_connect_to_de1 {} {
	#return

	if {$::android != 1} {
	    set ::de1(connect_time) [clock seconds]
	    set ::de1(last_ping) [clock seconds]

	    msg "Connected to fake DE1"
		set ::de1(device_handle) 1

		# example binary string containing binary version string
		#set version_value "\x01\x00\x00\x00\x03\x00\x00\x00\xAC\x1B\x1E\x09\x01"
		#set version_value "\x01\x00\x00\x00\x03\x00\x00\x00\xAC\x1B\x1E\x09\x01"
		set version_value "\x02\x04\x00\xA4\x0A\x6E\xD0\x68\x51\x02\x04\x00\xA4\x0A\x6E\xD0\x68\x51"
		parse_binary_version_desc $version_value arr2
		set ::de1(version) [array get arr2]

		return
	}

	if {$::settings(bluetooth_address) == ""} {
		# if no bluetooth address set, then don't try to connect
		return ""
	}

    set ::de1(connect_time) 0
    set ::de1(scanning) 0

	if {$::de1(device_handle) != "0"} {
		catch {
			msg "disconnecting from DE1"
			ble close $::de1(device_handle)
			set ::de1(device_handle) "0"
			after 1000 ble_connect_to_de1
		}
		catch {
			#ble unpair $::settings(bluetooth_address)
		}

	}
    set ::de1(device_handle) 0

    set ::de1_name "DE1"
	if {[catch {
		set ::currently_connecting_de1_handle [ble connect $::settings(bluetooth_address) de1_ble_handler]
    	msg "Connecting to DE1 on $::settings(bluetooth_address)"
    	set retcode 1
	} err] != 0} {
		msg "Failed to start to BLE connect to DE1 because: '$err'"
		set retcode 0
	}
	return $retcode    


	#msg "Failed to start to BLE connect to DE1 for some reason"
	#return 0    
    
}

set ::currently_connecting_skale_handle 0
proc ble_connect_to_skale {} {

	#puts "ble_connect_to_skale [stacktrace]"


	#set ::de1(scale_weight) ""

	if {$::settings(skale_bluetooth_address) == ""} {
		msg "No Skale BLE address in settings, so not connecting to it"
		return
	}

	if {$::currently_connecting_skale_handle != 0} {
		msg "Already trying to connect to Skale, so don't try again"
		return
	}

	set do_this 0
	if {$do_this == 1} {
		if {$::de1(skale_device_handle) != "0"} {
			msg "Skale already connected, so disconnecting before reconnecting to it"
			#return
			catch {
				ble close $::de1(skale_device_handle)
			}

			catch {
				set ::de1(skale_device_handle) 0
				set ::de1(cmdstack) {};
				set ::currently_connecting_skale_handle 0
				after 1000 ble_connect_to_skale
				# when the skale disconnect message occurs, this proc will get re-run and a connection attempt will be made
				return
			}

		}
	}

	if {$::de1(device_handle) == 0} {
		#msg "No DE1 connected, so delay connecting to Skale"
		#after 1000 ble_connect_to_skale
		#return
	}

	catch {
		#ble unpair $::settings(skale_bluetooth_address)
	}

	if {[catch {
		set ::currently_connecting_skale_handle [ble connect $::settings(skale_bluetooth_address) de1_ble_handler]
	    msg "Connecting to Skale on $::settings(skale_bluetooth_address)"
		set retcode 0
	} err] != 0} {
		set ::currently_connecting_skale_handle 0
		set retcode 1
		msg "Failed to start to BLE connect to Skale because: '$err'"
	}
	return $retcode    

}

proc append_to_de1_bluetooth_list {address} {
	set newlist $::de1_bluetooth_list
	lappend newlist $address
	set newlist [lsort -unique $newlist]

	if {[llength $newlist] == [llength $::de1_bluetooth_list]} {
		return
	}

	msg "Scan found DE1: $address"
	set ::de1_bluetooth_list $newlist
	catch {
		fill_ble_listbox
	}
}


proc append_to_skale_bluetooth_list {address} {
	#msg "Sca $address"
	set newlist $::skale_bluetooth_list
	lappend newlist $address
	set newlist [lsort -unique $newlist]

	if {[llength $newlist] == [llength $::skale_bluetooth_list]} {
		return
	}

	msg "Scan found Skale: $address"
	set ::skale_bluetooth_list $newlist
	catch {
		fill_ble_skale_listbox 
	}
}

proc de1_ble_handler { event data } {
	#msg "de1 ble_handler $event $data"
	#set ::de1(wrote) 0
	#msg "ble event: $event $data"

	set previous_wrote 0
	set previous_wrote [ifexists ::de1(wrote)]
	#set ::de1(wrote) 0

	#set ::de1(last_ping) [clock seconds]

    dict with data {

    	if {$state != "scanning"} {
    		#msg "de1b ble_handler $event $data"
    	}

		switch -- $event {
	    	#msg "-- device $name found at address $address"
		    scan {
		    	#msg "-- device $name found at address $address ($data)"
				if {[string first DE1 $name] != -1} {
					append_to_de1_bluetooth_list $address
					#if {$address == $::settings(bluetooth_address) && $::scanning != 0} {
						#ble stop $::ble_scanner
						#set ::scanning 0
						#ble_connect_to_de1
					#}
					if {$address == $::settings(bluetooth_address) && $::currently_connecting_de1_handle == 0} {
						ble_connect_to_de1
					}
				} elseif {[string first Skale $name] != -1} {
					append_to_skale_bluetooth_list $address
					#msg "$::settings(skale_bluetooth_address) == $address && $::currently_connecting_skale_handle == 0"
					if {$::settings(skale_bluetooth_address) == $address && $::currently_connecting_skale_handle == 0} {
						#msg "connecting to skale"
						#ble_connect_to_skale
					}

					#if {$::settings(skale_bluetooth_address) != $address} {
					#	msg "-- Saving new Skale bluetooth address"
					#	set ::settings(skale_bluetooth_address) $address					
					#	save_settings
					#} else {
					#	msg "-- Already Configured Skale found"
					#}
				} else {
					#msg "-- device $name found at address $address ($data)"
				}
		    }
		    connection {
				if {$state eq "disconnected"} {
					if {$address == $::settings(bluetooth_address)} {
					    # fall back to scanning
					    
			    		set ::de1(wrote) 0
			    		set ::de1(cmdstack) {}
				    	if {$::de1(device_handle) != 0} {
						    ble close $::de1(device_handle)
						}

						catch {
					    	ble close $::currently_connecting_de1_handle
					    }

					    set ::currently_connecting_de1_handle 0

					    msg "de1 disconnected"
					    set ::de1(device_handle) 0

					    # temporarily disable this feature as it's not clear that it's needed.
					    #set ::settings(max_ble_connect_attempts) 99999999
					    set ::settings(max_ble_connect_attempts) 10
					    
					    incr ::failed_attempt_count_connecting_to_de1
					    if {$::failed_attempt_count_connecting_to_de1 > $::settings(max_ble_connect_attempts) && $::successful_de1_connection_count > 0} {
					    	# if we have previously been connected to a DE1 but now can't connect, then make the UI go to Sleep
					    	# and we'll try again to reconnect when the user taps the screen to leave sleep mode

					    	# set this to zero so that when we come back from sleep we try several times to connect
					    	set ::failed_attempt_count_connecting_to_de1 0

					    	update_de1_state "$::de1_state(Sleep)\x0"
					    } else {
						    ble_connect_to_de1
					    }

				    } elseif {$address == $::settings(skale_bluetooth_address)} {
			    		set ::de1(wrote) 0
				    	msg "skale disconnected $data"
			    		catch {
			    			ble close $handle
			    		}

			    		# if the skale connection closed in the currentl one, then reset it
			    		if {$handle == $::de1(skale_device_handle)} {
			    			set ::de1(skale_device_handle) 0
			    		}

					    if {$::currently_connecting_skale_handle == 0} {
					    	#ble_connect_to_skale
					    }

				    	set do_this 1
				    	if {$do_this == 1} {
							catch {
						    	ble close $::currently_connecting_skale_handle
						    }

						    set ::currently_connecting_skale_handle 0
				    		#ble_connect_to_skale
				    	}
				    }
				} elseif {$state eq "scanning"} {
					set ::scanning 1
					msg "scanning"
				} elseif {$state eq "idle"} {
					#ble stop $::ble_scanner
					if {$::scanning > 0} {

						if {$::de1(device_handle) == 0 && $::currently_connecting_de1_handle == 0} {
							ble_connect_to_de1
						}

						if {$::de1(skale_device_handle) == 0 && $::settings(skale_bluetooth_address) != "" && $::currently_connecting_skale_handle == 0} {
							#userdata_append "connect to Skale" ble_connect_to_skale
							#ble_connect_to_skale
						}
					}
					set ::scanning 0
				} elseif {$state eq "discovery"} {
					#msg "discovery"
					#ble_connect_to_de1
				} elseif {$state eq "connected"} {

					if {$::de1(device_handle) == 0 && $address == $::settings(bluetooth_address)} {
						msg "de1 connected $event $data"
						
						incr ::successful_de1_connection_count
						set ::failed_attempt_count_connecting_to_de1 0


			    		set ::de1(wrote) 0
			    		set ::de1(cmdstack) {}
					    #set ::de1(found) 1
					    set ::de1(connect_time) [clock seconds]
					    set ::de1(last_ping) [clock seconds]
					    set ::currently_connecting_de1_handle 0

					    #msg "Connected to DE1"
						set ::de1(device_handle) $handle
						append_to_de1_bluetooth_list $address
						#return


						#msg "connected to de1 with handle $handle"
						set testing 0
						if {$testing == 1} {
							de1_read_calibration "temperature"
						} else {

							set ::globals(if_in_sleep_move_to_idle) 1
							de1_enable_temp_notifications
							de1_enable_water_level_notifications
							de1_send_steam_hotwater_settings
							de1_send_shot_frames
							read_de1_version
							de1_enable_state_notifications
							de1_send_waterlevel_settings
							read_de1_state

							# john 02-16-19 need to make this pair in android bluetooth settings -- not working yet
							#catch {
							#	if {$::settings(ble_unpair_at_exit) == 0} {
							#		ble pair $::settings(bluetooth_address)
							#	}
							#}

							#after 2000 "; ; ; "
							#poll_de1_state
							#start_idle
							#after 2000 de1_enable_calibration_notifications
							#after 3000 de1_read_calibration "temperature"
						}


						if {$::settings(skale_bluetooth_address) != "" && $::de1(skale_device_handle) == 0 } {
							# connect to the scale once the connection to the DE1 is set up
							#userdata_append "BLE connect to scale" [list ble_connect_to_skale] 
							#ble_connect_to_skale
						}
						
						#set_next_page off off
						#start_idle

			    		if {$::de1(skale_device_handle) != 0 || $::settings(skale_bluetooth_address) == ""} {
							# if we're connected to both the scale and the DE1, stop scanning (or if there is not scale to connect to and we're connected to the de1)
			    			stop_scanner
			    		}


					} elseif {$::de1(skale_device_handle) == 0 && $address == $::settings(skale_bluetooth_address)} {
						append_to_skale_bluetooth_list $address
			    		set ::de1(wrote) 0
						set ::de1(skale_device_handle) $handle

						msg "skale connected $::de1(skale_device_handle) $handle - $event $data"

						#skale_disable_lcd
						#after 500 
						#skale_tare 
						#after 1000 
						skale_enable_lcd
						after 1000 skale_enable_weight_notifications
						after 2000 skale_enable_button_notifications


						# john 02-16-19 need to make this pair in android bluetooth settings -- not working yet
						#catch {
						#	if {$::settings(ble_unpair_at_exit) == 0} {
						#		ble pair $::settings(skale_bluetooth_address)
						#	}
						#}

						#after 1500 
						#after 2000 
						#set displayweight [binary decode hex "EC"]
						#set screenon [binary decode hex "ED"]
						#set result [ble disable $handle "0000FF08-0000-1000-8000-00805F9B34FB" 0 "0000EF80-0000-1000-8000-00805F9B34FB" 0]
						#userdata_append "Skale : display weight on LCD" [ble write $::de1(skale_device_handle) "0000FF08-0000-1000-8000-00805F9B34FB" 12 "0000EF80-0000-1000-8000-00805F9B34FB" 22 $displayweight]
						#msg "ble result1: '$result' $data"

						#userdata_append "Skale : display weight on LCD" [list ble write $::de1(skale_device_handle) "0000FF08-0000-1000-8000-00805F9B34FB" 12 "0000EF80-0000-1000-8000-00805F9B34FB" 22 $screenon]
						#set result [ble write $::de1(skale_device_handle) "0000FF08-0000-1000-8000-00805F9B34FB" 12 "0000EF80-0000-1000-8000-00805F9B34FB" 22 $screenon]
						#msg "ble result2: '$result' $data"

						#after 2000 [list ble write $::de1(skale_device_handle) "0000FF08-0000-1000-8000-00805F9B34FB" 12 "0000EF80-0000-1000-8000-00805F9B34FB" 22 $displayweight]

						#skale_enable_lcd
						#after 2500 skale_enable_grams

						set ::currently_connecting_skale_handle 0

						if {$::de1(device_handle) != 0} {
							# if we're connected to both the scale and the DE1, stop scanning
							stop_scanner
						}

						#run_next_userdata_cmd

					} else {
						msg "doubled connection notification from $address, already connected with $address"
						#ble close $handle
					}


			    } else {
			    	msg "unknown connection msg: $data"
			    }
			}
		    transaction {
		    	msg "ble transaction result $event $data"
			}

		    characteristic {
			    #.t insert end "${event}: ${data}\n"
			    if {[string first A001 $data] != -1} {
			    	#msg "de1 characteristic $state: ${event}: ${data}"
			    }
		    	#msg "de1 characteristic $state: ${event}: ${data}"
			    #msg "connected to de1 with $handle "
				if {$state eq "discovery"} {
					# save the mapping because we now need it for Android 7
					set ::cinstance($cuuid) $cinstance
					set ::sinstance($suuid) $sinstance

					#msg "discovery 1"
					#ble_connect_to_de1
					# && ($properties & 0x10)
				    # later turn on notifications

				    # john don't enable all notifications
				    #set cmds [ble userdata $handle]
				    #lappend cmds [list ble enable $handle $suuid $sinstance $cuuid $cinstance]
				    #msg "enabling $suuid $sinstance $cuuid $cinstance"
				    #ble userdata $handle $cmds
				} elseif {$state eq "connected"} {
					#msg "$data"

				    if {$access eq "r" || $access eq "c"} {
				    	#msg "rc: $data"
				    	if {$access eq "r"} {
				    		set ::de1(wrote) 0
				    		run_next_userdata_cmd
				    	}
				    		#set ::de1(wrote) 0
				    		#run_next_userdata_cmd

				    	#msg "Received from DE1: '[remove_null_terminator $value]'"
						# change notification or read request
						#de1_ble_new_value $cuuid $value
						# change notification or read request
						#de1_ble_new_value $cuuid $value


						if {$cuuid == "0000A00D-0000-1000-8000-00805F9B34FB"} {
						    set ::de1(last_ping) [clock seconds]
							set results [update_de1_shotvalue $value]
							#msg "Shotvalue received: $results" 
							#set ::de1(wrote) 0
							#run_next_userdata_cmd
							set do_this 0
							if {$do_this == 1} {
								# this tries to handle bad write situations, but it might have side effects if it is not working correctly.
								# probably this should be adding a command to the top of the write queue
								if {$previous_wrote == 1} {
									msg "bad write reported"
									{*}$::de1(previouscmd)
									set ::de1(wrote) 1
									return
								}
							}
						} elseif {$cuuid == "0000A001-0000-1000-8000-00805F9B34FB"} {
						    set ::de1(last_ping) [clock seconds]
							#update_de1_state $value
							parse_binary_version_desc $value arr2
							msg "version data received [string length $value] bytes: '$value' \"[convert_string_to_hex $value]\"  : '[array get arr2]'/ $event $data"
							set ::de1(version) [array get arr2]

							set ::de1(wrote) 0
							run_next_userdata_cmd

						} elseif {$cuuid == "0000A012-0000-1000-8000-00805F9B34FB"} {
						    #set ::de1(last_ping) [clock seconds]
						    calibration_ble_received $value
						} elseif {$cuuid == "0000A011-0000-1000-8000-00805F9B34FB"} {
							set ::de1(last_ping) [clock seconds]
							parse_binary_water_level $value arr2
							#msg "water level data received [string length $value] bytes: $value  : [array get arr2]"
	
							# compensate for the fact that we measure water level a few mm higher than the water uptake point
							set mm [expr {$arr2(Level) + $::de1(water_level_mm_correction)}]
							set ::de1(water_level) $mm
							
						} elseif {$cuuid == "0000A009-0000-1000-8000-00805F9B34FB"} {
						    #set ::de1(last_ping) [clock seconds]
							parse_map_request $value arr2
							if {$::de1(currently_erasing_firmware) == 1 && [ifexists arr2(FWToErase)] == 0} {
								msg "BLE recv: finished erasing fw '[ifexists arr2(FWToMap)]'"
								set ::de1(currently_erasing_firmware) 0
								write_firmware_now
							} elseif {$::de1(currently_erasing_firmware) == 1 && [ifexists arr2(FWToErase)] == 1} { 
								msg "BLE recv: currently erasing fw '[ifexists arr2(FWToMap)]'"
							} elseif {$::de1(currently_erasing_firmware) == 0 && [ifexists arr2(FWToErase)] == 0} { 
								msg "BLE firmware find error BLE recv: '$value' [array get arr2]'"
						
								if {[ifexists arr2(FirstError1)] == [expr 0xFF] && [ifexists arr2(FirstError2)] == [expr 0xFF] && [ifexists arr2(FirstError3)] == [expr 0xFD]} {
									set ::de1(firmware_update_button_label) "Updated"
								} else {
									set ::de1(firmware_update_button_label) "Update failed"
								}
								set ::de1(currently_updating_firmware) 0

							} else {
								msg "unknown firmware cmd ack recved: [string length $value] bytes: $value : [array get arr2]"
							}
						} elseif {$cuuid == "0000A00B-0000-1000-8000-00805F9B34FB"} {
						    set ::de1(last_ping) [clock seconds]
							#update_de1_state $value
							parse_binary_hotwater_desc $value arr2
							msg "hotwater data received [string length $value] bytes: $value  : [array get arr2]"

							#update_de1_substate $value
							#msg "Confirmed a00e read from DE1: '[remove_null_terminator $value]'"
						} elseif {$cuuid == "0000A00C-0000-1000-8000-00805F9B34FB"} {
						    set ::de1(last_ping) [clock seconds]
							#update_de1_state $value
							parse_binary_shot_desc $value arr2
							msg "shot data received [string length $value] bytes: $value  : [array get arr2]"
						} elseif {$cuuid == "0000A00F-0000-1000-8000-00805F9B34FB"} {
						    set ::de1(last_ping) [clock seconds]
							#update_de1_state $value
							parse_binary_shotdescheader $value arr2
							msg "READ shot header success: [string length $value] bytes: $value  : [array get arr2]"
						} elseif {$cuuid == "0000A010-0000-1000-8000-00805F9B34FB"} {
						    set ::de1(last_ping) [clock seconds]
							#update_de1_state $value
							parse_binary_shotframe $value arr2
							msg "shot frame received [string length $value] bytes: $value  : [array get arr2]"
						} elseif {$cuuid == "0000A00E-0000-1000-8000-00805F9B34FB"} {
						    set ::de1(last_ping) [clock seconds]
							update_de1_state $value

							if {[info exists ::globals(if_in_sleep_move_to_idle)] == 1} {
								unset ::globals(if_in_sleep_move_to_idle)
								if {$::de1_num_state($::de1(state)) == "Sleep"} {
									# when making a new connection to the espresso machine, if the machine is currently asleep, then take it out of sleep
									# but only do this check once, right after connection establisment
									start_idle
								}
							}
							#update_de1_substate $value
							#msg "Confirmed a00e read from DE1: '[remove_null_terminator $value]'"
							set ::de1(wrote) 0
							run_next_userdata_cmd

						} elseif {$cuuid == "0000A00F-0000-1000-8000-00805F9B34FB"} {
							msg "error"
							#update_de1_state $value
							#msg "Confirmed a00f read from DE1: '[remove_null_terminator $value]'"

						} elseif {$cuuid eq "0000EF81-0000-1000-8000-00805F9B34FB"} {
					        binary scan $value cus1cu t0 t1 t2 t3 t4 t5
							set sensorweight [expr {$t1 / 10.0}]
							if {$sensorweight < 0 && $::de1_num_state($::de1(state)) == "Idle"} {
								# one second after the negative weights have stopped, automatically do a tare
								if {[info exists ::scheduled_skale_tare_id] == 1} {
									after cancel $::scheduled_skale_tare_id
								}
								set ::scheduled_skale_tare_id [after 1000 skale_tare]
							}

							set multiplier1 0.95
							if {$::de1(scale_weight) == ""} {
								set ::de1(scale_weight) 0
							}
							set diff 0
							set diff [expr {$::de1(scale_weight) - $sensorweight}]
							

							set enabled_alt_multiplier 0
							if {$enabled_alt_multiplier == 1} {
								# the greater the weight leap from the previous read weight, the more smoothing we apply, so make bumps to the scale have only a minor effect
								if {$::de1_num_state($::de1(state)) == "Idle"} {
									# no smoothing when the machine is idle
									set multiplier1 0
								} elseif {$diff > 1} { 
									# more than 1 gram in 1/10th of a second is smoothed out the most
									set multiplier1 0.998
								} elseif {$diff > .5} { 
									set multiplier1 0.99
								} elseif {$diff > .1} { 
									set multiplier1 0.98
								}

								# john 5/11/18 hard set this to 5% weighting, until we're sure these other methods work well.
								set multiplier1 .95
							} else {

								if {$::de1_num_state($::de1(state)) == "Idle"} {
									# no smoothing when the machine is idle
									set multiplier1 0
								} else {
									# john 5/11/18 hard set this to 5% weighting, until we're sure these other methods work well.
									set multiplier1 .95
								}
							}

							set multiplier2 [expr {1 - $multiplier1}];
							set thisweight [expr {($::de1(scale_weight) * $multiplier1) + ($sensorweight * $multiplier2)}]

							if {$diff != 0} {
								#msg "Diff: [round_to_two_digits $diff] - mult: [round_to_two_digits $multiplier1] - wt [round_to_two_digits $thisweight] - sen [round_to_two_digits $sensorweight]"
							}


							# 10hz refresh rate on weight means should 10x the weight change to get a change-per-second
							set flow [expr { 10 * ($thisweight - $::de1(scale_weight)) }]

							#set flow [expr {($::de1(scale_weight_rate) * $multiplier1) + ($tempflow * $multiplier2)}]
							if {$flow < 0} {
								set flow 0
							}

							set ::de1(scale_weight_rate) $flow
							
							set ::de1(scale_weight) $thisweight
							set ::de1(scale_sensor_weight) $sensorweight
							#msg "weight received: $thisweight : flow: $tempflow"


							# (beta) stop shot-at-weight feature
							if {$::de1_num_state($::de1(state)) == "Espresso" && ($::de1(substate) == $::de1_substate_types_reversed(pouring) || $::de1(substate) == $::de1_substate_types_reversed(preinfusion) || $::de1(substate) == $::de1_substate_types_reversed(ending)) } {
								
								if {$::de1(scale_sensor_weight) > $::de1(final_water_weight)} {
									set ::de1(final_water_weight) $thisweight
									set ::settings(drink_weight) [round_to_one_digits $::de1(final_water_weight)]
								}



								# john 1/18/19 support added for advanced shots stopping on weight, just like other shots
								# john improve 5/2/19 with a separate (much higher value) weight option for advanced shots
								set target_shot_weight $::settings(final_desired_shot_weight)
								if {$::settings(settings_profile_type) == "settings_2c"} {
									set target_shot_weight $::settings(final_desired_shot_weight_advanced)
								}

								if {$target_shot_weight != "" && $target_shot_weight > 0} {

									# damian found:
									# > after you hit the stop button, the remaining liquid that will end up in the cup is equal to about 2.6 seconds of the current flow rate, minus a 0.4 g adjustment
								    set lag_time_calibration [expr {$::de1(scale_weight_rate) * $::settings(stop_weight_before_seconds) }]

									if {$::de1(scale_autostop_triggered) == 0 && [round_to_one_digits $thisweight] > [round_to_one_digits [expr {$target_shot_weight - $lag_time_calibration}]]} {	

										if {[espresso_timer] < 5} {
											skale_tare
										} else {
											msg "Weight based Espresso stop was triggered at ${thisweight}g > ${target_shot_weight}g "
										 	start_idle
										 	say [translate {Stop}] $::settings(sound_button_in)

										 	# immediately set the DE1 state as if it were idle so that we don't repeatedly ask the DE1 to stop as we still get weight increases. There might be a slight delay between asking the DE1 to stop and it stopping.
										 	set ::de1(scale_autostop_triggered) 1

										 	# let a few seconds elapse after the shot stop command was given and keep updating the final shot weight number
										 	for {set t 0} {$t < [expr {1000 * $::settings(seconds_after_espresso_stop_to_continue_weighing)}]} { set t [expr {$t + 1000}]} {
										 		after $t after_shot_weight_hit_update_final_weight
										 	}
										 }
									}
								}
							} elseif {$::de1_num_state($::de1(state)) == "Espresso" && ( $::de1(substate) == $::de1_substate_types_reversed(heating) || $::de1(substate) == $::de1_substate_types_reversed(stabilising) || $::de1(substate) == $::de1_substate_types_reversed(final heating) )} {
								if {$::de1(scale_weight) > 10} {
									# if a cup was added during the warmup stage, about to make an espresso, then tare automatically
									skale_tare
								}
							}

						} elseif {$cuuid eq "0000EF82-0000-1000-8000-00805F9B34FB"} {
							set t0 {}
					        #set t1 {}
					        binary scan $value cucucucucucu t0 t1
							msg "- Skale button pressed: $t0 : DE1 state: $::de1(state) = $::de1_num_state($::de1(state)) "

						    if {$t0 == 1} {
								skale_tare
							} elseif {$t0 == 2} {
								if {$::settings(scale_button_starts_espresso) == 1} {
									 if {$::de1_num_state($::de1(state)) == "Espresso"} {
									 	say [translate {Stop}] $::settings(sound_button_in)
									 	start_idle
								 	} else {
								 		say [translate {Espresso}] $::settings(sound_button_in)
										start_espresso
									}
								}
							}
						} else {
							msg "Confirmed unknown read from DE1 $cuuid: '$value'"
						}

						#set ::de1(wrote) 0

				    } elseif {$access eq "w"} {
						set ::de1(wrote) 0
				    	run_next_userdata_cmd

				    	if {$cuuid == $::de1(cuuid_10)} {
							parse_binary_shotframe $value arr3				    		
					    	msg "Confirmed shot frame written to DE1: '$value' : [array get arr3]"
				    	} elseif {$cuuid == $::de1(cuuid_11)} {
							parse_binary_water_level $value arr2
							msg "water level write confirmed [string length $value] bytes: $value  : [array get arr2]"
						} elseif {$cuuid eq "0000EF80-0000-1000-8000-00805F9B34FB"} {
							set tare [binary decode hex "10"]
							set grams [binary decode hex "03"]
							set screenon [binary decode hex "ED"]
							set displayweight [binary decode hex "EC"]
							if {$value == $tare } {
								msg "- Skale: tare confirmed"

								# after a tare, we can now use the autostop mechanism
								set ::de1(scale_autostop_triggered) 0
							} elseif {$value == $grams } {
								msg "- Skale: grams confirmed"
							} elseif {$value == $screenon } {
								msg "- Skale: screen on confirmed"
							} elseif {$value == $displayweight } {
								msg "- Skale: display weight confirmed"
							} else {
								msg "- Skale write received: $value vs '$tare'"
							}
			    		} else {
					    	if {$address == $::settings(bluetooth_address)} {
								if {$cuuid == "0000A002-0000-1000-8000-00805F9B34FB"} {
									parse_state_change $value arr
						    		msg "Confirmed state change written to DE1: '[array get arr]'"
								} elseif {$cuuid == "0000A006-0000-1000-8000-00805F9B34FB"} {
									msg "firmware write ack recved: [string length $value] bytes: $value : [array get arr2]"
									firmware_upload_next
								} else {
						    		msg "Confirmed wrote to $cuuid of DE1: '$value'"
								}
				    		} elseif {$address == $::settings(skale_bluetooth_address)} {
					    		msg "Confirmed wrote to $cuuid of Skale: '$value'"
				    		} else {
					    		msg "Confirmed wrote to $cuuid of unknown device: '$value'"
				    		}
			    		}
						
						#set ::de1(wrote) 0

						# change notification or read request
						#de1_ble_new_value $cuuid $value

				    } else {
				    	msg "weird characteristic received: $data"
				    }

		    		#run_next_userdata_cmd
				    #run_next_userdata_cmd
				}
		    }
		    service {
		    }
		    descriptor {
		    	#msg "de1 descriptor $state: ${event}: ${data}"
				if {$state eq "connected"} {

				    if {$access eq "w"} {
						if {$cuuid == "0000A00D-0000-1000-8000-00805F9B34FB"} {
					    	msg "Confirmed: BLE temperature notifications: $data"
						} elseif {$cuuid == "0000A00E-0000-1000-8000-00805F9B34FB"} {
					    	msg "Confirmed: BLE state change notifications"
						} elseif {$cuuid == "0000A012-0000-1000-8000-00805F9B34FB"} {
					    	msg "Confirmed: BLE calibration notifications"
						} else {
					    	msg "DESCRIPTOR UNKNOWN WRITE confirmed: $data"
						}

				    	set ::de1(wrote) 0
						run_next_userdata_cmd
				    }

					set run_this 0

					if {$run_this == 1} {
					    #set cmds [lindex [ble userdata $handle] 0]
					    set lst [ble userdata $handle]
					    set cmds [unshift lst]
					    ble userdata $handle $lst
					    msg "$cmds"
					    if {$cmds ne {}} {
							set cmd [lindex $cmds 0]
							set cmds [lrange $cmds 1 end]
							{*}[lindex $cmd 1]
							ble userdata $handle $cmds
					    }
					}
				}
				
		    }

		    default {
		    	msg "ble unknown callback $event $data"
		    }
		}
	}

	#run_next_userdata_cmd

    #msg "exited event"
}

proc calibration_ble_received {value} {

    #calibration_ble_received $value
	parse_binary_calibration $value arr2
	#msg "calibration data received [string length $value] bytes: $value  : [array get arr2]"

	set varname ""
	if {[ifexists arr2(CalTarget)] == 0} {
		if {[ifexists arr2(CalCommand)] == 3} {
			set varname	"factory_calibration_flow"
		} else {
			set varname	"calibration_flow"
		}
	} elseif {[ifexists arr2(CalTarget)] == 1} {
		if {[ifexists arr2(CalCommand)] == 3} {
			set varname	"factory_calibration_pressure"
		} else {
			set varname	"calibration_pressure"
		}
	} elseif {[ifexists arr2(CalTarget)] == 2} {
		if {[ifexists arr2(CalCommand)] == 3} {
			set varname	"factory_calibration_temperature"
		} else {
			set varname	"calibration_temperature"
		}
	} 

	if {$varname != ""} {
		# this BLE characteristic receives packets both for notifications of reads and writes, but also the real current value of the calibration setting
		if {[ifexists arr2(WriteKey)] == 0} {
			msg "$varname value received [string length $value] bytes: [convert_string_to_hex $value] $value : [array get arr2]"
			set ::de1($varname) $arr2(MeasuredVal)
		} else {
			msg "$varname NACK received [string length $value] bytes: [convert_string_to_hex $value] $value : [array get arr2] "
		}
	} else {
		msg "unknown calibration data received [string length $value] bytes: $value  : [array get arr2]"
	}

}

proc after_shot_weight_hit_update_final_weight {} {

	if {$::de1(scale_sensor_weight) > $::de1(final_water_weight)} {
		# if the current scale weight is more than the final weight we have on record, then update the final weight
		set ::de1(final_water_weight) $::de1(scale_sensor_weight)
		set ::settings(drink_weight) [round_to_one_digits $::de1(final_water_weight)]
	}

}

proc fast_write_open {fn parms} {
    set f [open $fn $parms]
    fconfigure $f -blocking 0
    fconfigure $f -buffersize 1000000
    return $f
}

proc write_binary_file {filename data} {
    set fn [fast_write_open $filename w]
    fconfigure $fn -translation binary
    puts $fn $data 
    close $fn
    return 1
}


proc scanning_state_text {} {
	if {$::scanning == 1} {
		return [translate "Searching"]
	}

	if {$::currently_connecting_de1_handle != 0} {
		return [translate "Connecting"]
	} 

	if {[expr {$::de1(connect_time) + 5}] > [clock seconds]} {
		return [translate "Connected"]
	}

	return [translate "Search"]
}

proc scanning_restart {} {
	if {$::scanning == 1} {
		return
	}
	if {$::android != 1} {
		set ::scanning 1
		after 3000 { set scanning 0 }
	} else {
		# only scan for a few seconds
		after 10000 { stop_scanner }
	}

	set ::scanning 1
	ble start $::ble_scanner
}
