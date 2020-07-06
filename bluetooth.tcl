
package provide de1_bluetooth

set ::failed_attempt_count_connecting_to_de1 0
set ::successful_de1_connection_count 0

proc userdata_append {comment cmd} {
	#set cmds [ble userdata $::de1(device_handle)]
	#lappend cmds $cmd
	#ble userdata $::de1(device_handle) $cmds
	lappend ::de1(cmdstack) [list $comment $cmd]
	run_next_userdata_cmd
}

proc read_de1_version {} {
	catch {
		userdata_append "read_de1_version" [list ble read $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_01) $::cinstance($::de1(cuuid_01))]
	}
}

# repeatedly request de1 state
proc poll_de1_state {} {

	msg "poll_de1_state"
	read_de1_state
	after 1000 poll_de1_state
}

proc read_de1_state {} {
	if {[catch {
		userdata_append "read de1 state" [list ble read $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0E) $::cinstance($::de1(cuuid_0E))]
	} err] != 0} {
		msg "Failed to 'read de1 state' in DE1 BLE because: '$err'"
	}
}

proc skale_timer_start {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return 
	}


	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot start timer"
		return
	}

	set timeron [binary decode hex "DD"]
	userdata_append "Skale : timer start" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $timeron]

}


# cmdtype is either 0x0A for LED (cmddata 00=off, 01=on), or 0x0F for tare (cmdata = incremented char counter for each TARE use)
proc decent_scale_calc_xor {cmdtype cmdddata} {
	set xor [format %02X [expr {0x03 ^ $cmdtype ^ $cmdddata ^ 0x00 ^ 0x00 ^ 0x00}]]
	msg "decent_scale_calc_xor for '$cmdtype' '$cmdddata' is '$xor'"
	return $xor
}

proc decent_scale_calc_xor4 {cmdtype cmdddata1 cmdddata2} {
	set xor [format %02X [expr {0x03 ^ $cmdtype ^ $cmdddata1 ^ $cmdddata2 ^ 0x00 ^ 0x00}]]
	msg "decent_scale_calc_xor4 for '$cmdtype' '$cmdddata1' '$cmdddata2' is '$xor'"
	return $xor
}

proc decent_scale_make_command {cmdtype cmdddata {cmddata2 {}} } {
	if {$cmddata2 == ""} {
		set hex [subst {03${cmdtype}${cmdddata}000000[decent_scale_calc_xor "0x$cmdtype" "0x$cmdddata"]}]
		#set hex2 [subst {03${cmdtype}${cmdddata}000000[decent_scale_calc_xor4 "0x$cmdtype" "0x$cmdddata" "0x00"]}]
		#msg "compare hex '$hex' to '$hex2'"
	} else {
		set hex [subst {03${cmdtype}${cmdddata}${cmddata2}0000[decent_scale_calc_xor4 "0x$cmdtype" "0x$cmdddata" "0x$cmddata2"]}]
	}
	msg "hex is '$hex' for '$cmdtype' '$cmdddata' '$cmddata2'"
	return [binary decode hex $hex]
}

proc tare_counter_incr {} {
	if {[info exists ::decent_scale_tare_counter] != 1} {
		set ::decent_scale_tare_counter 253
	} elseif {$::decent_scale_tare_counter >= 255} {
		set ::decent_scale_tare_counter 0
	} else {
		incr ::decent_scale_tare_counter
	}
	

}

proc int_to_hex {in} {
	return [format %02X $in]
}

proc decent_scale_tare_cmd {} {
	tare_counter_incr
	set cmd [decent_scale_make_command "0F" [format %02X $::decent_scale_tare_counter]]
	return $cmd
}

proc scale_enable_lcd {} {
	if {$::settings(scale_type) == "atomaxskale"} {
	 	skale_enable_lcd
 	} elseif {$::settings(scale_type) == "decentscale"} {
	 	decentscale_enable_lcd
 	}
 }


proc decentscale_enable_lcd {} {
	if {$::de1(scale_device_handle) == 0} {
		return 
	}
	set screenon [decent_scale_make_command 0A 01 01]
	msg "decent scale screen on: '[convert_string_to_hex $screenon]' '$screenon'"
	userdata_append "decentscale : enable LCD" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $screenon]

	#set timeron [decent_scale_make_command 0A 00 01]
	#msg "decent scale timer on: '$timeron'"
	#userdata_append "decentscale : timer on" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $timeron]



	#set timeron [decent_scale_make_command 0B 02]
	#msg "decent scale timer on: '$timeron'"
	#userdata_append "decentscale : timer on" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $timeron]

	#decentscale_timer_start
	#set timeron [decent_scale_make_command 0B 01]
	#msg "decent scale timer on: '$timeron'"
	#userdata_append "decentscale : timer on" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $timeron]



}


proc scale_disable_lcd {} {
	if {$::settings(scale_type) == "atomaxskale"} {
	 	skale_disable_lcd
 	} elseif {$::settings(scale_type) == "decentscale"} {
	 	decentscale_disable_lcd
 	}
 }
proc decentscale_disable_lcd {} {
	if {$::de1(scale_device_handle) == 0} {
		return 
	}
	set screenoff [decent_scale_make_command 0A 00 00]

	if {[ifexists ::sinstance($::de1(suuid_decentscale))] == ""} {
		msg "decentscale not connected, cannot disable LCD"
		return
	}

	userdata_append "decentscale : disable LCD" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $screenoff]
}

proc scale_timer_start {} {

	if {$::settings(scale_type) == "atomaxskale"} {
	 	skale_timer_start
 	} elseif {$::settings(scale_type) == "decentscale"} {
	 	decentscale_timer_start
 	}
}


proc decentscale_timer_start {} {
	if {$::de1(scale_device_handle) == 0} {
		return 
	}

	if {[ifexists ::sinstance($::de1(suuid_decentscale))] == ""} {
		msg "decentscale not connected, cannot start timer"
		return
	}

	#set timerreset [decent_scale_make_command 0B 02]
	#msg "decent scale timer reset: '$timerreset'"
	#userdata_append "decentscale : timer reset" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $timerreset]

	set timeron [decent_scale_make_command 0B 03 00]
	msg "decent scale timer on: [convert_string_to_hex $timeron] '$timeron'"
	userdata_append "decentscale : timer on" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $timeron]

}


proc scale_timer_stop {} {

	if {$::settings(scale_type) == "atomaxskale"} {
	 	skale_timer_stop
 	} elseif {$::settings(scale_type) == "decentscale"} {
	 	decentscale_timer_stop
 	}
}


proc decentscale_timer_stop {} {

	if {$::de1(scale_device_handle) == 0} {
		return 
	}
	set tare [binary decode hex "D1"]

	if {[ifexists ::sinstance($::de1(suuid_decentscale))] == ""} {
		msg "decentscale not connected, cannot stop timer"
		return
	}

	set timeron [decent_scale_make_command 0B 00 00]
	msg "decent scale timer on: '$timeron'"
	userdata_append "decentscale : timer on" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $timeron]

	# cmd not yet implemented
	#userdata_append "decentscale: timer stop" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $tare]
}

proc scale_timer_off {} {

	if {$::settings(scale_type) == "atomaxskale"} {
	 	skale_timer_off
 	} elseif {$::settings(scale_type) == "decentscale"} {
	 	decentscale_timer_off
 	}
}

proc decentscale_timer_off {} {

	if {$::de1(scale_device_handle) == 0} {
		return 
	}

	if {[ifexists ::sinstance($::de1(suuid_decentscale))] == ""} {
		msg "decentscale not connected, cannot off timer"
		return
	}


	set timeroff [decent_scale_make_command 0B 02 00]
	msg "decent scale timer off: '$timeroff'"
	userdata_append "decentscale : timer off" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $timeroff]
}


proc skale_timer_stop {} {

	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return 
	}
	set tare [binary decode hex "D1"]

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot stop timer"
		return
	}

	userdata_append "Skale: timer stop" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $tare]
}

proc skale_timer_off {} {

	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return 
	}
	set tare [binary decode hex "D0"]

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot off timer"
		return
	}

	userdata_append "Skale: timer off" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $tare]
}



proc scale_tare {} {

	if {$::settings(scale_type) == "atomaxskale"} {
	 	skale_tare
 	} elseif {$::settings(scale_type) == "decentscale"} {
	 	decentscale_tare
 	}
}


proc decentscale_tare {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "decentscale"} {
		return 
	}
	set tare [binary decode hex "10"]
	set ::de1(scale_weight) 0
	set ::de1(scale_weight_rate) 0
	set ::de1(scale_weight_rate_raw) 0

	# if this was a scheduled tare, indicate that the tare has completed
	unset -nocomplain ::scheduled_scale_tare_id

	if {[ifexists ::sinstance($::de1(suuid_decentscale))] == ""} {
		msg "decent scale not connected, cannot tare"
		return
	}

	set tare [decent_scale_tare_cmd]

	userdata_append "decentscale : tare" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $tare]
}


proc skale_tare {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return 
	}
	set tare [binary decode hex "10"]
	set ::de1(scale_weight) 0
	set ::de1(scale_weight_rate_raw) 0

	# if this was a scheduled tare, indicate that the tare has completed
	unset -nocomplain ::scheduled_scale_tare_id

	#set ::de1(final_espresso_weight) 0

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot tare"
		return
	}

	userdata_append "Skale: tare" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $tare]
}


proc scale_enable_weight_notifications {} {

	if {$::settings(scale_type) == "atomaxskale"} {
	 	scale_enable_weight_notifications
 	} elseif {$::settings(scale_type) == "decentscale"} {
	 	decentscale_enable_notifications
 	}
 }

proc skale_enable_weight_notifications {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return 
	}

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot enable weight notifications"
		return
	}

	userdata_append "enable Skale weight notifications" [list ble enable $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF81) $::cinstance($::de1(cuuid_skale_EF81))]
}

proc decentscale_enable_notifications {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "decentscale"} {
		return 
	}

	if {[ifexists ::sinstance($::de1(suuid_decentscale))] == ""} {
		msg "decent scale not connected, cannot enable weight notifications"
		return
	}

	userdata_append "enable decent scale weight notifications" [list ble enable $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_read) $::cinstance($::de1(cuuid_decentscale_read))]
}

proc scale_enable_button_notifications {} {

	if {$::settings(scale_type) == "atomaxskale"} {
	 	skale_enable_button_notifications
 	} elseif {$::settings(scale_type) == "decentscale"} {
	 	# nothing
 	}
 }

proc skale_enable_button_notifications {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return 
	}

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot enable button notifications"
		return
	}


	userdata_append "enable Skale button notifications" [list ble enable $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF82) $::cinstance($::de1(cuuid_skale_EF82))]
}

proc scale_enable_grams {} {

	if {$::settings(scale_type) == "atomaxskale"} {
	 	skale_enable_grams
 	} elseif {$::settings(scale_type) == "decentscale"} {
	 	#nothing
 	}
 }


proc skale_enable_grams {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return 
	}
	set grams [binary decode hex "03"]

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot enable grams"
		return
	}

	userdata_append "Skale : enable grams" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $grams]
}

proc skale_enable_lcd {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return 
	}
	set screenon [binary decode hex "ED"]
	set displayweight [binary decode hex "EC"]

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot enable LCD"
		return
	}

	userdata_append "Skale : enable LCD" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $screenon]
	userdata_append "Skale : display weight on LCD" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $displayweight]
	#ble write $::de1(scale_device_handle) "0000FF08-0000-1000-8000-00805F9B34FB" 0 "0000EF80-0000-1000-8000-00805F9B34FB" 0 $displayweight
}

proc skale_disable_lcd {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return 
	}
	set screenoff [binary decode hex "EE"]

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		msg "Skale not connected, cannot disable LCD"
		return
	}

	userdata_append "Skale : disable LCD" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $screenoff]
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

proc de1_enable_mmr_notifications {} {

	if {[mmr_available] == 0} {
		msg "Unable to de1_enable_mmr_notifications because MMR not available"
		return
	}

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 7"
		return
	}

	#userdata_append "enable MMR write notifications" [list ble enable $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_06) $::cinstance($::de1(cuuid_06))]
	userdata_append "enable MMR read notifications" [list ble enable $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_05) $::cinstance($::de1(cuuid_05))]
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
		if {$::settings(force_fw_update) != 1} {
			set ::de1(firmware_update_button_label) "Up to date"
			return
		}
	} else {
		if {$::settings(force_fw_update) != 1} {
			set ::de1(firmware_update_button_label) "Up to date"
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
		userdata_append "Erase firmware do: [array get arr]" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_09) $::cinstance($::de1(cuuid_09)) $data]
		after 10000 write_firmware_now
	} else {
		after 1000 write_firmware_now
	}
}

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
			userdata_append "Find first error in firmware update: [array get arr]" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_09) $::cinstance($::de1(cuuid_09)) $data]
		}
	} else {
		set ::de1(firmware_update_button_label) "Updating"

		set data "\x10[make_U24P0 $::de1(firmware_bytes_uploaded)][string range $::de1(firmware_update_binary) $::de1(firmware_bytes_uploaded) [expr {15 + $::de1(firmware_bytes_uploaded)}]]"
		userdata_append "Write [string length $data] bytes of firmware data ([convert_string_to_hex $data])" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_06) $::cinstance($::de1(cuuid_06)) $data]
		set ::de1(firmware_bytes_uploaded) [expr {$::de1(firmware_bytes_uploaded) + 16}]
		if {$::android != 1} {
			set ::de1(firmware_bytes_uploaded) [expr {$::de1(firmware_bytes_uploaded) + 160}]
			after 1 firmware_upload_next
			#firmware_upload_next
		}
	}
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
		msg "MMR requesting read $address:$length [convert_string_to_hex $mmrlen] bytes of firmware data from [convert_string_to_hex $mmrloc]: with comment [convert_string_to_hex $data]"
	}

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 11"
		return
	}

	set cmt "MMR requesting read '$note' [convert_string_to_hex $mmrlen] bytes of firmware data from [convert_string_to_hex $mmrloc] with '[convert_string_to_hex $data]'"
	msg "queing $cmt"
	userdata_append $cmt [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_05) $::cinstance($::de1(cuuid_05)) $data]

}

proc mmr_write { address length value} {
	if {[mmr_available] == 0} {
		msg "Unable to mmr_read because MMR not available"
		return
	}

 	set mmrlen [binary decode hex $length]	
	set mmrloc [binary decode hex $address]
 	set mmrval [binary decode hex $value]	
	set data "$mmrlen${mmrloc}${mmrval}[binary decode hex 000000000000000000000000000000]"
	
	if {$::android != 1} {
		msg "MMR writing [convert_string_to_hex $mmrlen] bytes of firmware data to [convert_string_to_hex $mmrloc] with value [convert_string_to_hex $mmrval] : with comment [convert_string_to_hex $data]"
	}

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 11"
		return
	}
	userdata_append "MMR writing [convert_string_to_hex $mmrlen] bytes of firmware data to [convert_string_to_hex $mmrloc] with value [convert_string_to_hex $mmrval] : with comment [convert_string_to_hex $data]" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_06) $::cinstance($::de1(cuuid_06)) $data]
}

proc set_tank_temperature_threshold {temp} {
	msg "Setting desired water tank temperature to '$temp' [stacktrace]"

	if {$temp < 10} {
		# no point in circulating the water if the desired temp is <10ºC, or no preheating.
		mmr_write "80380C" "04" [zero_pad [int_to_hex $temp] 2]
	} else {
		# if the water temp is being set, then set the water temp temporarily to 60º in order to force a water circulation for 2 seconds
		# then a few seconds later, set it to the real, desired value
		set hightemp 60
		mmr_write "80380C" "04" [zero_pad [int_to_hex $hightemp] 2]
		after 4000 [list mmr_write "80380C" "04" [zero_pad [int_to_hex $temp] 2]]
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



proc set_steam_flow {desired_flow} {
	#return
	msg "Setting steam flow rate to '$desired_flow'"
	mmr_write "803828" "04" [zero_pad [int_to_hex $desired_flow] 2]
}

proc get_steam_flow {} {
	msg "Getting steam flow rate"
	mmr_read "get_steam_flow" "803828" "00"
}

proc get_heater_voltage {} {
	msg "Getting heater voltage"
	mmr_read "get_heater_voltage" "803834" "00"
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
	mmr_write "803834" "04" [zero_pad [int_to_hex $heater_voltage] 2]
}



proc set_steam_highflow_start {desired_seconds} {
	#return
	msg "Setting steam high flow rate start seconds to '$desired_seconds'"
	mmr_write "80382C" "04" [zero_pad [int_to_hex $desired_seconds] 2]
}

proc get_steam_highflow_start {} {
	msg "Getting steam high flow rate start seconds "
	mmr_read "get_steam_highflow_start" "80382C" "00"
}


proc set_ghc_mode {desired_mode} {
	msg "Setting group head control mode '$desired_mode'"
	mmr_write "803820" "04" [zero_pad [int_to_hex $desired_mode] 2]
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
	mmr_write "803808" "04" [zero_pad [int_to_hex $temp] 2]
}

proc get_tank_temperature_threshold {} {
	msg "Reading desired water tank temperature"
	mmr_read "get_tank_temperature_threshold" "80380C" "00"
}

proc de1_cause_refill_now_if_level_low {} {

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
	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
		msg "DE1 not connected, cannot send BLE command 12"
		return
	}

	set data [return_de1_packed_waterlevel_settings]
	parse_binary_water_level $data arr2
	userdata_append "Set water level settings: [array get arr2]" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_11) $::cinstance($::de1(cuuid_11)) $data]
}


proc run_next_userdata_cmd {} {
	if {$::android == 1} {
		# if running on android, only write one BLE command at a time
		if {$::de1(wrote) == 1} {
			#msg "Do no write, already writing to DE1"
			return
		}
	}
	if {($::de1(device_handle) == "0" || $::de1(device_handle) == "1") && $::de1(scale_device_handle) == "0"} {
		#msg "error: de1 not connected"
		return
	}

	if {$::de1(cmdstack) ne {}} {

		set cmd [lindex $::de1(cmdstack) 0]
		set cmds [lrange $::de1(cmdstack) 1 end]
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

			if {[string first "invalid handle" $::errorInfo] != -1} {
				msg "Not retrying this command because BLE handle for the device is now invalid"
				#after 500 run_next_userdata_cmd
			} else {
				if {$eer != 0} {
					msg "BLE command failed, will retry ($result): [lindex $cmd 1] ($eer) $::errorInfo"
				} else {
					msg "BLE command failed, will retry ($result): [lindex $cmd 1] ($eer)"
				}


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

	msg "Closing scale"
	if {$::de1(scale_device_handle) != 0} {
		catch {
			ble close $::de1(scale_device_handle)
		}
	}


	catch {
		if {$::settings(ble_unpair_at_exit) == 1} {
			#ble unpair $::de1(de1_address)
			#ble unpair $::settings(bluetooth_address)
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

	msg "de1_send_shot_frames"

	set parts [de1_packed_shot]
	set header [lindex $parts 0]
	
	####
	# this is purely for testing the parser/deparser
	parse_binary_shotdescheader $header arr2
	#msg "frame header of [string length $header] bytes parsed: $header [array get arr2]"
	####


	userdata_append "Espresso header: [array get arr2]" [list ble_write_00f $header]

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

		userdata_append "Espresso frame #$cnt: [array get arr3] (FLAGS: [parse_shot_flag $arr3(Flag)])"  [list ble_write_010 $packed_frame]
	}

	# only set the tank temperature for advanced profile shots
	if {$::settings(settings_profile_type) == "settings_2c"} {
		set_tank_temperature_threshold $::settings(tank_desired_water_temperature)
	} else {
		set_tank_temperature_threshold 0
	}


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
	userdata_append "Set water/steam settings: [array get arr2]" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_0B) $::cinstance($::de1(cuuid_0B)) $data]

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
	userdata_append "Read $what calibration: [array get arr2] : [string length $data] bytes: ([convert_string_to_hex $data])" [list ble write $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $::de1(cuuid_12) $::cinstance($::de1(cuuid_12)) $data]

}

proc de1_read_version_obsolete {} {
	msg "LIKELY OBSOLETE BLE FUNCTION: DO NOT USE"

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

proc android_8_or_newer {} {

	if {$::android != 1} {
		msg "android_8_or_newer reports: not android (0)"		
		return 0
	}

	catch {
		set x [borg osbuildinfo]
		#msg "osbuildinfo: '$x'"
		array set androidprops $x
		msg [array get androidprops]
		msg "Android release reported: '$androidprops(version.release)'"
	}
	set test 0
	catch {
		# john note: Android 7 behaves like 8
		set test [expr {$androidprops(version.release) >= 7}]
	}
	#msg "Is this Android 8 or newer? '$test'"
	return $test
	
	#msg "android_8_or_newer failed and reports: 0"
	#return 0
}

set ::ble_scanner [ble scanner de1_ble_handler]
set ::scanning -1

proc check_if_initial_connect_didnt_happen_quickly {} {
	msg "check_if_initial_connect_didnt_happen_quickly"
# on initial startup, if a direct connection to DE1 doesn't work quickly, start a scan instead
	set ble_scan_started 0
	if {$::de1(device_handle) == 0 } {
		#msg "check_if_initial_connect_didnt_happen_quickly ::de1(device_handle) == 0"
		catch {
	    	ble close $::currently_connecting_de1_handle
	    }
	    catch {
	    	set ::currently_connecting_de1_handle 0
	    }
	    set ble_scan_started 1
	} else {
		msg "DE1 device handle is $::de1(device_handle)"
	}

	if {$::settings(scale_bluetooth_address) != "" && $::de1(scale_device_handle) == 0} {
		msg "on initial startup, if a direct connection to scale doesn't work quickly, start a scan instead"
		catch {
	    	ble close $::currently_connecting_scale_handle
	    }
	    catch {
	    	set ::currently_connecting_scale_handle 0
	    }
	    set ble_scan_started 1
	}	    


	if {$ble_scan_started == 1} {
	    scanning_restart
	}


}


proc ble_find_de1s {} {

	return
	if {$::android != 1} {
		ble_connect_to_de1
	}
	
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

	#@return
	msg "bluetooth_connect_to_devices"

	if {$::android != 1} {
		ble_connect_to_de1
	}

	if {$::settings(bluetooth_address) != ""} {

		if {[android_8_or_newer] == 1} {
			# on bootpup, android 8 won't connect directly to a BLE device unless it's found by a scan
			# this step below waits 4 seconds to see if a direct connection worked, and if not, activates a scan
			# when a scan finds the device, then it will initiate a new connection request and that one will work
			ble_connect_to_de1
			after 4000 check_if_initial_connect_didnt_happen_quickly

			msg "will launch check_if_initial_connect_didnt_happen_quickly in 4000ms"
		} else {
			# earlier android revisions can connect directly, and it's fast
			ble_connect_to_de1

		}
	}

	if {$::settings(scale_bluetooth_address) != ""} {
		
		if {[android_8_or_newer] == 1} {
			ble_connect_to_scale
		} else {
			after 3000 ble_connect_to_scale
		}
			#after 3000 [list userdata_append "connect to scale" ble_connect_to_scale]

		#after 3000 ble_connect_to_scale
	}

#		ble_connect_to_scale
}


set ::currently_connecting_de1_handle 0
proc ble_connect_to_de1 {} {
	msg "ble_connect_to_de1"
	#return

	if {$::android != 1} {
		msg "simulated DE1 connection"
	    set ::de1(connect_time) [clock seconds]
	    set ::de1(last_ping) [clock seconds]

	    msg "Connected to fake DE1"
		set ::de1(device_handle) 1

		# example binary string containing binary version string
		#set version_value "\x01\x00\x00\x00\x03\x00\x00\x00\xAC\x1B\x1E\x09\x01"
		#set version_value "\x01\x00\x00\x00\x03\x00\x00\x00\xAC\x1B\x1E\x09\x01"
		set version_value "\x02\x04\x00\xA4\x0A\x6E\xD0\x68\x51\x02\x04\x00\xA4\x0A\x6E\xD0\x68\x51"
		#parse_binary_version_desc $version_value arr2
		set ::de1(version) [array get arr2]

		set mmr_test "\x0C\x80\x00\x08\x14\x05\x00\x00\x03\x00\x00\x00\x71\x04\x00\x00\x00\x00\x00\x00"
		#parse_binary_mmr_read $mmr_test arr3
		msg [array get arr3]

		#set mmr_test "\x0C\x80\x00\x08\x14\x05\x00\x00\x03\x00\x00\x00\x71\x04\x00\x00\x00\x00\x00\x00"
		parse_binary_mmr_read_int $mmr_test arr4
		msg [array get arr4]

		msg "MMRead: CPU board model: '[ifexists arr4(Data0)]'"
		msg "MMRead: machine model:  '[ifexists arr4(Data1)]'"
		msg "MMRead: firmware version number: '[ifexists arr4(Data2)]'"

		set ::settings(cpu_board_model) [ifexists arr4(Data0)]
		set ::settings(machine_model) [ifexists arr4(Data1)]
		set ::settings(firmware_version_number) [ifexists arr4(Data2)]

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
		set ::currently_connecting_de1_handle [ble connect $::settings(bluetooth_address) de1_ble_handler false]
    	msg "Connecting to DE1 on $::settings(bluetooth_address)"
    	set retcode 1
	} err] != 0} {
		if {$err == "unsupported"} {
			after 5000 [list info_page [translate "Bluetooth is not on"] [translate "Ok"]]
		}
		msg "Failed to start to BLE connect to DE1 because: '$err'"
		set retcode 0
	}
	return $retcode    


	#msg "Failed to start to BLE connect to DE1 for some reason"
	#return 0    
    
}

set ::currently_connecting_scale_handle 0
proc ble_connect_to_scale {} {

	if {[ifexists ::de1(in_fw_update_mode)] == 1} {
		msg "in_fw_update_mode : ble_connect_to_scale"
		return
	}


	if {$::settings(scale_bluetooth_address) == ""} {
		msg "No Scale BLE address in settings, so not connecting to it"
		return
	}

	if {$::currently_connecting_scale_handle != 0} {
		msg "Already trying to connect to Scale, so don't try again"
		return
	}

	set do_this 0
	if {$do_this == 1} {
		if {$::de1(scale_device_handle) != "0"} {
			msg "Scale already connected, so disconnecting before reconnecting to it"
			#return
			catch {
				ble close $::de1(scale_device_handle)
			}

			catch {
				set ::de1(scale_device_handle) 0
				set ::de1(cmdstack) {};
				set ::currently_connecting_scale_handle 0
				after 1000 ble_connect_to_scale
				# when the scale disconnect message occurs, this proc will get re-run and a connection attempt will be made
				return
			}

		}
	}

	if {$::de1(device_handle) == 0} {
		#msg "No DE1 connected, so delay connecting to scale"
		#after 1000 ble_connect_to_scale
		#return
	}

	catch {
		#ble unpair $::settings(scale_bluetooth_address)
	}

	if {[catch {
		set ::currently_connecting_scale_handle [ble connect $::settings(scale_bluetooth_address) de1_ble_handler false]
	    msg "Connecting to scale on $::settings(scale_bluetooth_address)"
		set retcode 0
	} err] != 0} {
		set ::currently_connecting_scale_handle 0
		set retcode 1
		msg "Failed to start to BLE connect to scale because: '$err'"
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


proc append_to_scale_bluetooth_list {address name} {
	#msg "Sca $address"

	set ::scale_types($address) $name

	set newlist $::scale_bluetooth_list
	lappend newlist $address
	set newlist [lsort -unique $newlist]

	if {[llength $newlist] == [llength $::scale_bluetooth_list]} {
		return
	}

	msg "Scan found Skale or Decent Scale: $address ($name)"
	set ::scale_bluetooth_list $newlist
	catch {
		fill_ble_scale_listbox 
	}
}

# mmr_read used
proc later_new_de1_connection_setup {} {
	# less important stuff, also some of it is dependent on BLE version

	if {[ifexists ::de1(in_fw_update_mode)] == 1} {
		msg "in_fw_update_mode : later_new_de1_connection_setup skipped"
		return
	}

	de1_enable_mmr_notifications
	de1_enable_state_notifications
	get_ghc_is_installed
	de1_send_shot_frames
	set_fan_temperature_threshold $::settings(fan_threshold)
	de1_send_steam_hotwater_settings
	de1_send_waterlevel_settings
	get_3_mmr_cpuboard_machinemodel_firmwareversion
	de1_enable_water_level_notifications
	de1_enable_state_notifications
	de1_enable_temp_notifications
	

	#if {$::settings(heater_voltage) == ""} {
		after 7000 get_heater_voltage
	#}
	

	after 5000 read_de1_state

}

proc mmr_read_queue_add {cmd} {
	if {[info exists mmr_read_queue] != 1} {
		set mmr_read_queue {}
	}

	lappend mmr_read_queue $cmd
}


proc de1_ble_handler { event data } {
	#msg "de1 ble_handler '$event' $data"
	#set ::de1(wrote) 0
	#msg "ble event: $event $data"

	set previous_wrote 0
	set previous_wrote [ifexists ::de1(wrote)]
	#set ::de1(wrote) 0

	#set ::de1(last_ping) [clock seconds]

    dict with data {

    	if {$state != "scanning"} {
    		#msg "de1b ble_handler $event $data"
    	} else {
    		#msg "scanning $event $data"
    	}

		switch -- $event {
	    	msg "-- device '$name' found at address $address"
		    scan {
		    	#msg "-- device $name found at address $address ($data)"
				if {[string first DE1 $name] != -1} {
					append_to_de1_bluetooth_list $address
					#if {$address == $::settings(bluetooth_address) && $::scanning != 0} {
						#ble stop $::ble_scanner
						#set ::scanning 0
						#ble_connect_to_de1
					#}
					if {$address == $::settings(bluetooth_address)} {
						if {$::currently_connecting_de1_handle == 0} {
							msg "Not currently connecting to DE1, so trying now"
							ble_connect_to_de1
						} else {
							#msg "Already connecting to DE1, so not trying now"
							#catch {
						    	#ble close $::currently_connecting_de1_handle
						    #}
							#ble_connect_to_de1
						}
					}
				} elseif {[string first Skale $name] != -1} {
					append_to_scale_bluetooth_list $address "atomaxskale"

					if {$address == $::settings(scale_bluetooth_address)} {
						if {$::currently_connecting_scale_handle == 0} {
							msg "Not currently connecting to scale, so trying now"
							ble_connect_to_scale
						}
					}

				} elseif {[string first "Decent Scale" $name] != -1} {
					append_to_scale_bluetooth_list $address "decentscale"

					if {$address == $::settings(scale_bluetooth_address)} {
						if {$::currently_connecting_scale_handle == 0} {
							msg "Not currently connecting to scale, so trying now"
							ble_connect_to_scale
						}
					}

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

					    	if {[ifexists ::de1(disable_de1_reconnect)] != 1} {
						    	ble_connect_to_de1
						    }
					    }

				    } elseif {$address == $::settings(scale_bluetooth_address)} {
					
					#set ::de1(scale_type) ""

			    		set ::de1(wrote) 0
				    	msg "$::settings(scale_type) disconnected $data"
			    		catch {
			    			ble close $handle
			    		}

			    		# if the skale connection closed in the currentl one, then reset it
			    		if {$handle == $::de1(scale_device_handle)} {
			    			set ::de1(scale_device_handle) 0
			    		}

					    if {$::currently_connecting_scale_handle == 0} {
					    	#ble_connect_to_scale
					    }

						catch {
					    	ble close $::currently_connecting_scale_handle
					    }

					    set ::currently_connecting_scale_handle 0
			    		
					    # john 1-11-19 automatic reconnection attempts eventually kill the bluetooth stack on android 5.1
					    # john might want to make this happen automatically on Android 8, though. For now, it's a setting, which might 
					    # eventually get auto-set as per the current Android version, if we can trust that to give us a reliable BLE stack.
						if {$::settings(automatically_ble_reconnect_forever_to_scale) == 1} {
				    		ble_connect_to_scale
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

						#if {$::de1(scale_device_handle) == 0 && $::settings(scale_bluetooth_address) != "" && $::currently_connecting_scale_handle == 0} {
							#userdata_append "connect to scale" ble_connect_to_scale
							#ble_connect_to_scale
						#}
					}
					set ::scanning 0
				} elseif {$state eq "discovery"} {
					#msg "discovery"
					#ble_connect_to_de1
				} elseif {$state eq "connected"} {

					if {$::de1(device_handle) == 0 && $address == $::settings(bluetooth_address)} {
						msg "de1 connected $event $data"

						if {$::settings(scale_bluetooth_address) != ""} {
							ble_connect_to_scale
						}

						
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

						if {[ifexists ::de1(in_fw_update_mode)] == 1} {
							msg "in_fw_update_mode : de1 connected"

							msg "Tell DE1 to start to go to SLEEP (so it's asleep during firmware upgrade)"
							de1_send_state "go to sleep" $::de1_state(Sleep)
							set_fan_temperature_threshold 60
						} else {
							de1_enable_mmr_notifications

							set dothis 1
							if {$dothis == 1} {
								de1_enable_temp_notifications

								if {[info exists ::de1(first_connection_was_made)] != 1} {
									# on app startup, wake the machine up
									set ::de1(first_connection_was_made) 1
									start_idle
								}
								read_de1_version
								
								read_de1_state
								

								
							}
						}

			    		if {$::de1(scale_device_handle) != 0} {
							# if we're connected to both the scale and the DE1, stop scanning (or if there is not scale to connect to and we're connected to the de1)
			    			stop_scanner
			    		}


					} elseif {$::de1(scale_device_handle) == 0 && $address == $::settings(scale_bluetooth_address)} {
						#append_to_scale_bluetooth_list $address [ifexists ::scale_types($address)]
						#append_to_scale_bluetooth_list $address $::settings(scale_type)

			    		set ::de1(wrote) 0
						set ::de1(scale_device_handle) $handle

						msg "scale '$::settings(scale_type)' connected $::de1(scale_device_handle) $handle - $event $data"
						if {$::settings(scale_type) == ""} {
							msg "blank scale type found, reset to atomaxskale"
							set ::settings(scale_type) "atomaxskale"
						}

						#set ::de1(scale_type) [ifexists ::scale_types($address)]
						if {$::settings(scale_type) == "decentscale"} {
							append_to_scale_bluetooth_list $address "decentscale"
							#after 500 decentscale_enable_lcd
							decentscale_enable_lcd
							after 1000 decentscale_enable_notifications
							after 2000 decentscale_tare
							after 3000 decentscale_enable_lcd
							after 4000 decentscale_timer_stop
							after 5000 decentscale_timer_off

						} elseif {$::settings(scale_type) == "atomaxskale"} {
							append_to_scale_bluetooth_list $address "atomaxskale"
							#set ::de1(scale_type) "atomaxskale"
							skale_enable_lcd
							after 1000 skale_enable_weight_notifications
							after 2000 skale_enable_button_notifications
							after 3000 skale_enable_lcd

						} else {
							error "unknown scale: '$::settings(scale_type)'"
						}
						set ::currently_connecting_scale_handle 0

						if {$::de1(device_handle) != 0} {
							# if we're connected to both the scale and the DE1, stop scanning
							stop_scanner
						}


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
			    #if {[string first A001 $data] != -1} {
			    	#msg "de1 characteristic $state: ${event}: ${data}"
			    #}
			    #if {[string first 83 $data] != -1} {
			    #	msg "de1 characteristic $state: ${event}: ${data}"
			    #}
		    	#msg "characteristic $state: ${event}: ${data}"
			    #msg "connected to de1 with $handle "
				if {$state eq "discovery"} {
					# save the mapping because we now need it for Android 7
					set ::cinstance($cuuid) $cinstance
					set ::sinstance($suuid) $sinstance

					#msg "discovery ::cinstance(cuuid=$cuuid) cinstance=$cinstance - $data"
					#msg "discovery ::sinstance(suuid=$suuid) sinstance=$sinstance - $data"

					#ble_connect_to_de1
					# && ($properties & 0x10)
				    # later turn on notifications

				    # john don't enable all notifications
				    #set cmds [ble userdata $handle]
				    #lappend cmds [list ble enable $handle $suuid $sinstance $cuuid $cinstance]
				    #msg "enabling $suuid $sinstance $cuuid $cinstance"
				    #ble userdata $handle $cmds
				} elseif {$state eq "connected"} {

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
			    		} elseif {$cuuid == $::de1(cuuid_05)} {
			    			# MMR read
			    			msg "MMR recv read: '[convert_string_to_hex $value]'"

			    			parse_binary_mmr_read $value arr
			    			set mmr_id $arr(Address)
			    			set mmr_val [ifexists arr(Data0)]
			    			
			    			msg "MMR recv read from $mmr_id ($mmr_val): '[convert_string_to_hex $value]' : [array get arr]"

			    			if {$mmr_id == "80381C"} {
			    				msg "Read: GHC is installed: '$mmr_val'"
			    				set ::settings(ghc_is_installed) $mmr_val

								if {$::settings(ghc_is_installed) == 1 || $::settings(ghc_is_installed) == 2} {
									# if the GHC is present but not active, check back every 10 minutes to see if its status has changed
									# this is only relevant if the machine is in a debug GHC mode, where the DE1 acts as if the GHC 
									# is not there until it is touched. This allows the tablet to start operations.  If (or once) the GHC is 
									# enabled, only the GHC can start operations.
									after 600000 get_ghc_is_installed
								}

			    			} elseif {$mmr_id == "803808"} {
			    				set ::de1(fan_threshold) $mmr_val
			    				set ::settings(fan_threshold) $mmr_val
			    				msg "MMRead: Fan threshold: '$mmr_val'"
			    			} elseif {$mmr_id == "80380C"} {
			    				msg "MMRead: tank temperature threshold: '$mmr_val'"
			    				set ::de1(tank_temperature_threshold) $mmr_val
			    			} elseif {$mmr_id == "803820"} {
			    				msg "MMRead: group head control mode: '$mmr_val'"
			    				set ::settings(ghc_mode) $mmr_val
			    			} elseif {$mmr_id == "803828"} {
			    				msg "MMRead: steam flow: '$mmr_val'"
			    				set ::settings(steam_flow) $mmr_val
			    			} elseif {$mmr_id == "803834"} {
				    			parse_binary_mmr_read_int $value arr2

			    				msg "MMRead: heater voltage: '[ifexists arr2(Data0)]'"
			    				set ::settings(heater_voltage) [ifexists arr2(Data0)]

			    				catch {
			    					if {[ifexists ::settings(firmware_version_number)] != ""} {
			    						if {$::settings(firmware_version_number) >= 1142} {
					    					if {$::settings(heater_voltage) == 0} {
					    						msg "Heater voltage is unknown, please set it"
					    						show_settings calibrate2
					    					}
					    				}
					    			}
			    				}
			    			} elseif {$mmr_id == "800008"} {
				    			parse_binary_mmr_read_int $value arr2

			    				if {[ifexists arr(Len)] == 12} {
			    					# it's possibly to read all 3 MMR characteristics at once

					    			# CPU Board Model * 1000. eg: 1100 = 1.1
				    				msg "MMRead: CPU board model: '[ifexists arr2(Data0)]'"
				    				set ::settings(cpu_board_model) [ifexists arr2(Data0)]

				    				# v1.3+ Firmware Model (Unset = 0, DE1 = 1, DE1Plus = 2, DE1Pro = 3, DE1XL = 4, DE1Cafe = 5)
				    				msg "MMRead: machine model:  '[ifexists arr2(Data1)]'"
				    				set ::settings(machine_model) [ifexists arr2(Data1)]

				    				# CPU Board Firmware build number. (Starts at 1000 for 1.3, increments by 1 for every build)
				    				msg "MMRead: firmware version number: '[ifexists arr2(Data2)]'"
			    					set ::settings(firmware_version_number) [ifexists arr2(Data2)]

		    					} else {
		    						# CPU Board Model * 1000. eg: 1100 = 1.1
				    				msg "MMRead: CPU board model: '[ifexists arr2(Data0)]'"
				    				set ::settings(cpu_board_model) [ifexists arr2(Data0)]
				    			}

			    			} elseif {$mmr_id == "80000C"} {
								parse_binary_mmr_read_int $value arr2

			    				# v1.3+ Firmware Model (Unset = 0, DE1 = 1, DE1Plus = 2, DE1Pro = 3, DE1XL = 4, DE1Cafe = 5)
			    				msg "MMRead: machine model:  '[ifexists arr2(Data0)]'"
			    				set ::settings(machine_model) [ifexists arr2(Data0)]

			    			} elseif {$mmr_id == "800010"} {
								parse_binary_mmr_read_int $value arr2

			    				# CPU Board Firmware build number. (Starts at 1000 for 1.3, increments by 1 for every build)
			    				msg "MMRead: firmware version number: '[ifexists arr2(Data0)]'"
		    					set ::settings(firmware_version_number) [ifexists arr2(Data0)]

			    			} elseif {$mmr_id == "80382C"} {
			    				msg "MMRead: steam_highflow_start: '$mmr_val'"
			    				set ::settings(steam_highflow_start) $mmr_val
			    			} else {
			    				msg "Uknown type of direct MMR read $mmr_id on '[convert_string_to_hex $mmr_id]': $data"
			    			}

						} elseif {$cuuid == "0000A001-0000-1000-8000-00805F9B34FB"} {
						    set ::de1(last_ping) [clock seconds]
							#update_de1_state $value
							parse_binary_version_desc $value arr2
							msg "version data received [string length $value] bytes: '$value' \"[convert_string_to_hex $value]\"  : '[array get arr2]'/ $event $data"
							set ::de1(version) [array get arr2]

							# run stuff that depends on the BLE API version
							later_new_de1_connection_setup

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
							msg "a009: [array get arr2]"
							if {$::de1(currently_erasing_firmware) == 1 && [ifexists arr2(FWToErase)] == 0} {
								msg "BLE recv: finished erasing fw '[ifexists arr2(FWToMap)]'"
								set ::de1(currently_erasing_firmware) 0
								#write_firmware_now
							} elseif {$::de1(currently_erasing_firmware) == 1 && [ifexists arr2(FWToErase)] == 1} { 
								msg "BLE recv: currently erasing fw '[ifexists arr2(FWToMap)]'"
								#after 1000 read_fw_erase_progress
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

							#if {[info exists ::globals(if_in_sleep_move_to_idle)] == 1} {
							#	unset ::globals(if_in_sleep_move_to_idle)
							#	if {$::de1_num_state($::de1(state)) == "Sleep"} {
									# when making a new connection to the espresso machine, if the machine is currently asleep, then take it out of sleep
									# but only do this check once, right after connection establisment
							#		start_idle
							#	}
							#}
							#update_de1_substate $value
							#msg "Confirmed a00e read from DE1: '[remove_null_terminator $value]'"
							set ::de1(wrote) 0
							run_next_userdata_cmd

						} elseif {$cuuid eq "83CDC3D4-3BA2-13FC-CC5E-106C351A9352"} {
							# decent scale
							parse_decent_scale_recv $value vals
							#msg "decentscale: '[array get vals]'"
							
							#set sensorweight [expr {$t1 / 10.0}]

						} elseif {$cuuid eq "0000EF81-0000-1000-8000-00805F9B34FB" || $cuuid eq $::de1(cuuid_decentscale_read)} {

							if {$cuuid eq "0000EF81-0000-1000-8000-00805F9B34FB"} {
								# Atomax scale
						        binary scan $value cus1cu t0 t1 t2 t3 t4 t5
								set sensorweight [expr {$t1 / 10.0}]

							} elseif {$cuuid eq $::de1(cuuid_decentscale_read)} {
								# decent scale
								parse_decent_scale_recv $value weightarray

								if {[ifexists weightarray(command)] == [expr 0x0F] && [ifexists weightarray(data6)] == [expr 0xFE]} {
									# tare cmd success is a msg back to us with the tare in 'command', and a byte6 of 0xFE
									msg "- decent scale: tare confirmed"

									set ::de1(scale_weight) 0

									# after a tare, we can now use the autostop mechanism
									set ::de1(scale_autostop_triggered) 0

									return
								} elseif {[ifexists weightarray(command)] == 0xAA} {									
									msg "Decentscale BUTTON $weightarray(data3) pressed"
									if {[ifexists $weightarray(data3)] == 1} {
										# button 1 "O" pressed
										decentscale_tare
									} elseif {[ifexists $weightarray(data3)] == 2} {
										# button 2 "[]" pressed
									}
								} elseif {[ifexists weightarray(command)] != ""} {
									msg "scale command received: [array get weightarray]"

								}

								if {[info exists weightarray(weight)] == 1} {
									set sensorweight [expr {$weightarray(weight) / 10.0}]
									msg "decent scale: ${sensorweight}g [array get weightarray] '[convert_string_to_hex $value]'"
									#msg "decentscale recv read: '[convert_string_to_hex $value]'"
								} else {
									msg "decent scale recv: [array get weightarray]"
								}
							} else {
								error "unknown scale cuuid"
							}


							if {[info exists sensorweight] != 1} { 
								return
							}

							#msg "sensorweight: $sensorweight"

							if {$sensorweight < 0 && $::de1_num_state($::de1(state)) == "Idle"} {

								if {$::settings(tare_only_on_espresso_start) != 1} {

									# one second after the negative weights have stopped, automatically do a tare
									if {[info exists ::scheduled_scale_tare_id] == 1} {
										after cancel $::scheduled_scale_tare_id
									}
									set ::scheduled_scale_tare_id [after 1000 scale_tare]
								}
							}

							set multiplier1 0.95
							if {$::de1(scale_weight) == ""} {
								set ::de1(scale_weight) 0
							}
							set diff 0
							set diff [expr {abs($::de1(scale_weight) - $sensorweight)}]
							

							#if {$::de1_num_state($::de1(state)) == "Idle"} 
							if {$::de1_num_state($::de1(state)) == "Espresso" && ($::de1(substate) == $::de1_substate_types_reversed(pouring) || $::de1(substate) == $::de1_substate_types_reversed(preinfusion)) } {
								# john 5/11/18 hard set this to 5% weighting, until we're sure these other methods work well.
								set multiplier1 0.95
								#if {$diff > 10} {
									#set multiplier1 0.90
								#}
							} else {
								# no smoothing when the machine is idle or not pouring/preinfusion 
								set multiplier1 0
							}

								#set multiplier1 0.9

							#msg "sensorweight: $sensorweight / diff:$diff / multiplier1:$multiplier1"

							#set multiplier1 0

							set multiplier2 [expr {1.0 - $multiplier1}];
							set thisweight [expr {($::de1(scale_weight) * $multiplier1) + ($sensorweight * $multiplier2)}]


							# a much less smoothed, more raw weight, with lower latency
							set multiplier1r 0.5
							set multiplier2r [expr {1.0 - $multiplier1r}];
							set thisrawweight [expr {1.0 * ($::de1(scale_sensor_weight) * $multiplier1r) + ($sensorweight * $multiplier2r)}]

							if {$diff != 0} {
								#msg "Diff: [round_to_two_digits $diff] - mult: [round_to_two_digits $multiplier1] - wt [round_to_two_digits $thisweight] - sen [round_to_two_digits $sensorweight]"
							}

							set scale_refresh_rate 10
							if {$::settings(scale_type) == "atomaxskale"} {
								set scale_refresh_rate 10
						 	} elseif {$::settings(scale_type) == "decentscale"} {
								set scale_refresh_rate 10
						 	}

							# 10hz refresh rate on weight means should 10x the weight change to get a change-per-second
							set flow [expr { 1.0 * $scale_refresh_rate * ($thisweight - $::de1(scale_weight)) }]
							set flow_raw [expr { 1.0 * $scale_refresh_rate * ($thisrawweight - $::de1(scale_sensor_weight)) }]

							#set flow [expr {($::de1(scale_weight_rate) * $multiplier1) + ($tempflow * $multiplier2)}]
							if {$flow < 0} {
								set flow 0
							}

							set ::de1(scale_weight_rate) [round_to_two_digits $flow]
							set ::de1(scale_weight_rate_raw) [round_to_two_digits $flow_raw]
							
							set ::de1(scale_weight) [round_to_two_digits $thisweight]
							set ::de1(scale_sensor_weight) [round_to_two_digits $thisrawweight]
							#msg "weight received: $thisweight : flow: $flow"


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

								    #msg "lag_time_calibration: $lag_time_calibration | target_shot_weight: $target_shot_weight | thisweight: $thisweight | scale_autostop_triggered: $::de1(scale_autostop_triggered) | timer: [espresso_timer]"

									if {$::de1(scale_autostop_triggered) == 0 && [round_to_one_digits $thisweight] > [round_to_one_digits [expr {$target_shot_weight - $lag_time_calibration}]]} {	

										if {[espresso_timer] < 5} {
											# bad idea to tare during preinfusion, problem is there might not be a puck, so we remove the first 5 seconds of weight by doing this.
											# scale_tare 
										} else {
											msg "Weight based Espresso stop was triggered at ${thisweight}g > ${target_shot_weight}g "
										 	start_idle
										 	say [translate {Stop}] $::settings(sound_button_in)
						 				 	borg toast [translate "Espresso weight reached"]


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
									scale_tare
								}
							}

						} elseif {$cuuid eq "0000EF82-0000-1000-8000-00805F9B34FB"} {
							set t0 {}
					        #set t1 {}
					        binary scan $value cucucucucucu t0 t1
							msg "- Skale button pressed: $t0 : DE1 state: $::de1(state) = $::de1_num_state($::de1(state)) "

						    if {$t0 == 1} {
								scale_tare
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

			    		if {$cuuid == $::de1(cuuid_05)} {
			    			# MMR read
			    			#msg "MMR read: '[convert_string_to_hex $value]'"

			    			msg "MMR recv write-back: '[convert_string_to_hex $value]'"

			    		} elseif {$cuuid == $::de1(cuuid_10)} {
							parse_binary_shotframe $value arr3				    		
					    	msg "Confirmed shot frame written to DE1: '$value' : [array get arr3]"
				    	} elseif {$cuuid == $::de1(cuuid_11)} {
							parse_binary_water_level $value arr2
							msg "water level write confirmed [string length $value] bytes: $value  : [array get arr2]"
				    	} elseif {$cuuid == "83CDC3D4-3BA2-13FC-CC5E-106C351A9352"} {
							#parse_binary_water_level $value arr2
							msg "scale write confirmed [string length $value] bytes: $value"
						} elseif {$cuuid eq "0000EF80-0000-1000-8000-00805F9B34FB"} {
							set tare [binary decode hex "10"]
							set grams [binary decode hex "03"]
							set screenon [binary decode hex "ED"]
							set displayweight [binary decode hex "EC"]
							if {$value == $tare } {
								msg "- Skale: tare confirmed"

								# after a tare, we can now use the autostop mechanism
								set ::de1(scale_autostop_triggered) 0
								set ::de1(scale_weight) 0

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
									if {$::de1(currently_erasing_firmware) == 1 && $::de1(currently_updating_firmware) == 0} {
										# erase ack received
										#set ::de1(currently_erasing_firmware) 0
										msg "firmware erase write ack recved: [string length $value] bytes: $value : [array get arr2]"
									} elseif {$::de1(currently_erasing_firmware) == 0 && $::de1(currently_updating_firmware) == 1} {

										msg "firmware write ack recved: [string length $value] bytes: $value : [array get arr2]"
										firmware_upload_next
									} else {
										msg "MMR write ack: [string length $value] bytes: [convert_string_to_hex $value ] : $value : [array get arr2]"
									}
								} elseif {$cuuid == "0000A009-0000-1000-8000-00805F9B34FB" && $::de1(currently_erasing_firmware) == 1} {
									msg "fw request to erase sent"
									#msg "fw request to erase sent, now starting send"
									#write_firmware_now
								} else {
						    		msg "Confirmed wrote to $cuuid of DE1: '$value'"
								}
				    		} elseif {$address == $::settings(scale_bluetooth_address)} {
					    		msg "Confirmed wrote to $cuuid of $::settings(scale_type): '$value'"
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
				msg "de1 service $event $data"
				#if {$suuid == "0000180A-0000-1000-8000-00805F9B34FB"} {
				#	set ::scale_types($address) "atomaxskale"
				#	msg "atomaxskale FOUND $suuid"
				#} elseif {$suuid == "83CDC3D4-3BA2-13FC-CC5E-106C351A9352"} {
				#	set ::scale_types($address) "decentscale"
				#	msg "decentscale FOUND $suuid"
				#}

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
						} elseif {$cuuid == "0000A012-0000-1000-8000-00805F9B34FB"} {
					    	msg "Confirmed: BLE calibration notifications"
						} elseif {$cuuid == "0000A005-0000-1000-8000-00805F9B34FB"} {
					    	msg "Confirmed: BLE MMR write: $data"
						} elseif {$cuuid == "0000A011-0000-1000-8000-00805F9B34FB"} {
					    	msg "Confirmed: water level write: $data"
						} else {
					    	msg "DESCRIPTOR UNKNOWN WRITE confirmed: $data"
						}

				    	set ::de1(wrote) 0
						run_next_userdata_cmd
				    } else {
						msg "de1 unknown descriptor $state: ${event}: ${data}"				    	
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
				} else {
					#msg "de1 descriptor $event $data"
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

proc enable_de1_reconnect {} {
	msg "enable_de1_reconnect"
	set ::de1(disable_de1_reconnect) 1
	ble_connect_to_de1
}

proc disable_de1_reconnect {} {
	msg "disable_de1_reconnect"
	set ::de1(disable_de1_reconnect) 1
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

	#return [translate "Tap to select"]
	if {[ifexists ::de1_needs_to_be_selected] == 1 || [ifexists ::scale_needs_to_be_selected] == 1} {
		return [translate "Tap to select"]
	}

	return [translate "Search"]
}

proc scanning_restart {} {
	if {$::scanning == 1} {
		return
	}
	if {$::android != 1} {

		set ::scale_bluetooth_list [list "12:32:56:78:90" "32:56:78:90:12" "56:78:90:12:32"]
		set ::de1_bluetooth_list [list "12:32:56:18:90" "32:56:78:90:13" "56:78:90:13:32"]

		set ::scale_types(12:32:56:78:90) "decentscale"
		set ::scale_types(32:56:78:90:12) "decentscale"
		set ::scale_types(56:78:90:12:32) "atomaxskale"

		after 200 fill_ble_scale_listbox
		after 400 fill_ble_listbox

		set ::scanning 1
		after 3000 { set scanning 0 }
		return
	} else {
		# only scan for a few seconds
		after 10000 { stop_scanner }
	}

	set ::scanning 1
	ble start $::ble_scanner
}
