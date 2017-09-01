
package provide de1_bluetooth

#set suuid "0000A000-0000-1000-8000-00805F9B34FB"
#set sinstance 0
#set cuuid "0000a001-0000-1000-8000-00805f9b34fb"
#set cinstance 0

# a00b = hot water/steam settings
# a00c = espresso frame settings


proc userdata_append {cmd} {
	#set cmds [ble userdata $::de1(device_handle)]
	#lappend cmds $cmd
	#ble userdata $::de1(device_handle) $cmds
	lappend ::de1(cmdstack) $cmd
	run_next_userdata_cmd
	#set ::de1(wrote) 1
}

proc de1_enable_bluetooth_notifications {} {
	msg "de1_enable_bluetooth_notifications"
	userdata_append [list ble enable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00d" $::de1(cinstance)]
	userdata_append [list ble enable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00e" $::de1(cinstance)]
	#userdata_append [list ble enable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00f" $::de1(cinstance)]
}

proc de1_disable_bluetooth_notifications {} {
	msg "de1_disable_bluetooth_notifications"
	userdata_append [list ble disable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00d" $::de1(cinstance)]
	userdata_append [list ble disable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00e" $::de1(cinstance)]
	#userdata_append [list ble enable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00f" $::de1(cinstance)]
}


proc poll_de1_state {} {

	puts "poll_de1_state"

	#de1_enable_bluetooth_notifications

	userdata_append [list ble read $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00d" $::de1(cinstance)]
	userdata_append [list ble read $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00e" $::de1(cinstance)]

	#userdata_append [list ble read $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00f" $::de1(cinstance)]
	after 5000 poll_de1_state
	#userdata_append [list ble read $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid) $::de1(cinstance)]
}

proc de1_enable_a00d {} {
	#set handle $::de1(device_handle)
	#ble enable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00d" $::de1(cinstance)

	userdata_append [list ble enable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00d" $::de1(cinstance)]
}

proc de1_enable_a00e {} {
	#set handle $::de1(device_handle)
	userdata_append [list ble enable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00e" $::de1(cinstance)]
	#ble enable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00e" $::de1(cinstance)
}

proc run_next_userdata_cmd {} {
	if {$::de1(wrote) == 1} {
		#msg "Do no write, already writing to DE1"
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
		catch {
			{*}$cmd
		}


		#if {$result <= 0} {
			#msg "BLE command failed to start $result: $cmd"
			#return
		#}
		#pause 300
		#ble userdata $::de1(device_handle) $cmds
		set ::de1(cmdstack) $cmds
		set ::de1(wrote) 1
		set ::de1(previouscmd) $cmd

	} else {
		#msg "no userdata cmds to run"
	}
}

proc app_exit {} {

	# this is a fail-over in case the bluetooth command hangs, which it sometimes does
	after 1000 {exit}
	
	catch {
		msg "Closing de1"
		ble close $::de1(device_handle)

		#ble unpair $::de1(de1_address)
		ble unpair $::settings(bluetooth_address)
		
	}
	exit
}

proc de1_enable_obsolete {cuuid_to_enable} {
	msg "Enabling DE1 notification: '$cuuid'"
	ble enable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $cuuid_to_enable $::de1(cinstance)
}

proc de1_send {msg} {
	#clear_timers
	delay_screen_saver
	
	if {$::de1(device_handle) == "0"} {
		msg "error: de1 not connected"
		return
	}

	set ::de1(substate) -
	msg "Sending to DE1: '$msg'"
	userdata_append [list ble write $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid) $::de1(cinstance) "$msg"]
}


proc send_de1_shot_and_steam_settings {} {
	return
	msg "send_de1_shot_and_steam_settings"
	#return
	#de1_send_shot_frames
	de1_send_steam_hotwater_settings

}

proc de1_send_shot_frames {} {


	if {$::de1(device_handle) == "0"} {
		msg "error: de1 not connected"
		return
	}

	#de1_disable_bluetooth_notifications	

	msg ======================================

	#userdata_append de1_disable_bluetooth_notifications

	set parts [de1_packed_shot]
	set header [lindex $parts 0]
	parse_binary_shotdescheader $header arr2
	msg "frame header of [string length $header] bytes parsed: $header [array get arr2]"
	#userdata_append [list after 300 ble write $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid_0f) $::de1(cinstance) $header]
	userdata_append [list ble_write_00f $header]
	#userdata_append [list ble_write_00f $header]
	#userdata_append [list ble_write_00f $header]

	set cnt 0
	foreach packed_frame [lindex $parts 1] {
		incr cnt
		unset -nocomplain arr3
		parse_binary_shotframe $packed_frame arr3
		msg "frame #$cnt data parsed [string length $packed_frame] bytes: $packed_frame  : [array get arr3]"
		userdata_append [list ble_write_010 $packed_frame]
		#userdata_append [list ble_write_010 $packed_frame]
		#userdata_append [list ble_write_010 $packed_frame]
	}

	#de1_enable_bluetooth_notifications

	return
}

proc ble_write_010 {packed_frame} {
	#ble begin $::de1(device_handle); 
	ble write $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid_10) $::de1(cinstance) $packed_frame
	#ble execute $::de1(device_handle); 
}

proc ble_write_00f {packed_frame} {
	#ble begin $::de1(device_handle); 
	ble write $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid_0f) $::de1(cinstance) $packed_frame
	#ble execute $::de1(device_handle); 
}

proc save_settings_to_de1 {} {
	if {$::de1(device_handle) == "0"} {
		msg "error: de1 not connected"
		return
	}

	de1_disable_bluetooth_notifications	
	de1_send_steam_hotwater_settings
	de1_send_shot_frames
	de1_enable_bluetooth_notifications

}

proc de1_send_steam_hotwater_settings {} {
#return

	if {$::de1(device_handle) == "0"} {
		msg "error: de1 not connected"
		return
	}


	set data [return_de1_packed_steam_hotwater_settings]
	parse_binary_hotwater_desc $data arr2
	msg "send de1_send_steam_hotwater_settings of [string length $data] bytes: $data  : [array get arr2]"
	#ble write $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid_0b) $::de1(cinstance) $data
	#userdata_append [list ble write $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid_0b) $::de1(cinstance) "1"]
	userdata_append [list ble write $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid_0b) $::de1(cinstance) $data]
	#userdata_append [list ble write $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid_0b) $::de1(cinstance) $data]
	#userdata_append [list ble write $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid_0b) $::de1(cinstance) $data]

}


proc de1_read {} {
	#set handle $::de1(device_handle)
	#global suuid sinstance cuuid cinstance
	if {$::de1(device_handle) == "0"} {
		msg "error: de1 not connected"
		return
	}

	set ::de1(substate) -
	#set magic1 "0000A000-0000-1000-8000-00805F9B34FB"
	#set magic2 "0000A002-0000-1000-8000-00805F9B34FB"
	#set magic3 "0000a001-0000-1000-8000-00805f9b34fb"

	userdata_append [list ble read $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid) $::de1(cinstance)]
	#set res [ble read $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid) $::de1(cinstance)]
	#msg "Received from DE1: '$res'"
	#return $res
    #ble execute $handle
}


proc de1_read_hotwater {} {
	if {$::de1(device_handle) == "0"} {
		msg "error: de1 not connected"
		return
	}

	userdata_append [list ble read $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid_0b) $::de1(cinstance)]
}

proc de1_read_shot_header {} {
	if {$::de1(device_handle) == "0"} {
		msg "error: de1 not connected"
		return
	}

	userdata_append [list ble read $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid_0f) $::de1(cinstance)]
}
proc de1_read_shot_frame {} {
	if {$::de1(device_handle) == "0"} {
		msg "error: de1 not connected"
		return
	}

	userdata_append [list ble read $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid_10) $::de1(cinstance)]
}

proc remove_null_terminator {instr} {
	set pos [string first "\x00" $instr]
	if {$pos == -1} {
		return $instr
	}

	incr pos -1
	return [string range $instr 0 $pos]
}

proc ble_find_de1s {} {
	userdata_append [list ble start [ble scanner de1_ble_handler]]
}

proc ble_connect_to_de1 {} {

	#set de1_address "C1:80:A7:32:CD:A3"
	#global de1_address

	catch {
		ble unpair $::settings(bluetooth_address)

	}

	if {$::de1(device_handle) != "0"} {
		catch {
			ble close $::de1(device_handle)
		}
	}

	if {$::settings(bluetooth_address) == ""} {
		# if no bluetooth address set, then don't try to connect
		return ""
	}

	#set ::de1(found) 0	
    set ::de1_name "DE1"
    set ::de1(scanning) 0
    set ::de1(device_handle) 0
    set ::de1(connect_time) 0
    #set ::de1(connecting) 1
    
    catch {
    	ble connect $::settings(bluetooth_address) de1_ble_handler 
    }
    msg "Connecting to DE1 on $::settings(bluetooth_address)"

    #after 10000 ble_try_again_to_connect_to_bpoint
}

proc append_to_de1_bluetooth_list {address} {
	lappend ::de1_bluetooth_list $address
	set ::de1_bluetooth_list [lsort -unique $::de1_bluetooth_list]
	catch {
		fill_ble_listbox $::ble_listbox_widget
	}
}

proc de1_ble_handler {event data} {
	#puts "de1 ble_handler $event $data"
	#set ::de1(wrote) 0
	#msg "ble event: $event"

	set previous_wrote 0
	set previous_wrote [ifexists ::de1(wrote)]
	set ::de1(wrote) 0

	#set ::de1(last_ping) [clock seconds]

    dict with data {

		switch -- $event {
	    	#msg "-- device $name found at address $address"
		    scan {
		    	#puts "-- device $name found at address $address"
				if {[string first DE1 $name] != -1} {
					append_to_de1_bluetooth_list $address
				}
		    }
		    connection {
		    	msg "2"
		    	#msg "connection: $data"
				if {$state eq "disconnected"} {
				    # fall back to scanning
				    #ble close $handle
				    #ble start [ble scanner ble_generic_handler]
				    msg "de1 disconnected"
				    #ble reconnect $::de1(device_handle)
				    #ble_find_de1s
				    ble_connect_to_de1

				    #set ::de1(found) 0
				} elseif {$state eq "discovery"} {
					msg "1"
					#ble_connect_to_de1
				} elseif {$state eq "connected"} {

					msg "de1 connected $event $data"
				    #set ::de1(found) 1
				    set ::de1(connect_time) [clock seconds]
				    set ::de1(last_ping) [clock seconds]

				    msg "Connected to DE1"
					set ::de1(device_handle) $handle
					append_to_de1_bluetooth_list $address

					#msg "connected to de1 with handle $handle"

					#de1_enable_a00d
					#de1_enable_a00e
					#de1_enable_a00f
					de1_disable_bluetooth_notifications
					de1_send_steam_hotwater_settings					
					de1_send_shot_frames
					de1_enable_bluetooth_notifications
					start_idle
					#de1_disable_bluetooth_notifications
					# need to re-enable!!!!
					#poll_de1_state
					#
					#send_de1_shot_and_steam_settings
					#run_next_userdata_cmd
					#de1_send $::de1_state(Idle)

					#run_de1_app
			    } else {
			    	msg "unknown connection msg: $data"
			    }
			}
		    transaction {
		    	msg "ble transaction result $event $data"
			}

		    characteristic {
			    #.t insert end "${event}: ${data}\n"
			    #msg "de1 characteristic $state: ${event}: ${data}"
			    #msg "connected to de1 with $handle "
				if {$state eq "discovery"} {
					msg "1"
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

				    	#msg "Received from DE1: '[remove_null_terminator $value]'"
						# change notification or read request
						#de1_ble_new_value $cuuid $value
						# change notification or read request
						#de1_ble_new_value $cuuid $value


						if {$cuuid == "0000A00D-0000-1000-8000-00805F9B34FB"} {
						    set ::de1(last_ping) [clock seconds]
							update_de1_shotvalue $value
							#msg "shotvalue" 
							if {$previous_wrote == 1} {
								msg "bad write reported"
								{*}$::de1(previouscmd)
								set ::de1(wrote) 1
								return
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
							#update_de1_substate $value
							#msg "Confirmed a00e read from DE1: '[remove_null_terminator $value]'"
						} elseif {$cuuid == "0000A00F-0000-1000-8000-00805F9B34FB"} {
							msg "error"
							#update_de1_state $value
							#msg "Confirmed a00f read from DE1: '[remove_null_terminator $value]'"
						} else {
							msg "Confirmed unknown read from DE1 $cuuid: '$value'"
						}

				    } elseif {$access eq "w"} {

				    	if {$cuuid == $::de1(cuuid_10)} {
							parse_binary_shotframe $value arr3				    		
					    	msg "Confirmed shot frame written to DE1: '$value' : [array get arr3]"
			    		} else {
					    	msg "Confirmed wrote to $cuuid of DE1: '$value'"
			    		}
						
						set ::de1(wrote) 0

						# change notification or read request
						#de1_ble_new_value $cuuid $value
				    } else {
				    	msg "weird characteristic received: $data"
				    }

				    #run_next_userdata_cmd
				}
		    }
		    descriptor {
		    	msg "de1 descriptor $state: ${event}: ${data}"
				if {$state eq "connected"} {

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
							{*}$cmd
							ble userdata $handle $cmds
					    }
					}
				}
				#run_next_userdata_cmd
		    }

		    default {
		    	msg "ble unknown callback $event $data"
		    }
		}
    		run_next_userdata_cmd
	}



    #msg "exited event"
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


