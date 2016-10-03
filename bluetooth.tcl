
package provide de1_bluetooth

#set de1_address "C5:80:EC:A5:F9:72"
#set suuid "0000A000-0000-1000-8000-00805F9B34FB"
#set sinstance 0
#set cuuid "0000a001-0000-1000-8000-00805f9b34fb"
#set cinstance 0

proc userdata_append {cmd} {
	#set cmds [ble userdata $::de1(device_handle)]
	#lappend cmds $cmd
	#ble userdata $::de1(device_handle) $cmds
	lappend ::de1(cmdstack) $cmd
	run_next_userdata_cmd
	#set ::de1(wrote) 1
}

proc de1_enable_bluetooth_notifications {} {
	userdata_append [list ble enable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00d" $::de1(cinstance)]
	userdata_append [list ble enable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00e" $::de1(cinstance)]
	userdata_append [list ble enable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) "a00f" $::de1(cinstance)]
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

	#msg "run_next_userdata_cmd $::de1(device_handle)"
	#set cmds {}
	
#	catch {
#		set cmds [ble userdata $::de1(device_handle)]
#	}
	if {$::de1(cmdstack) ne {}} {

		set cmd [lindex $::de1(cmdstack) 0]
		set cmds [lrange $::de1(cmdstack) 1 end]
		msg "stack cmd: $cmd"
		{*}$cmd
		#ble userdata $::de1(device_handle) $cmds
		set ::de1(cmdstack) $cmds
		set ::de1(wrote) 1
	} else {
		#msg "no userdata cmds to run"
	}
}

proc app_exit {} {
	catch {
		msg "Closing de1"
		#ble close $::de1(device_handle)

		ble unpair $::de1(de1_address)
	}
	exit
}

proc de1_enable {cuuid_to_enable} {
	msg "Enabling DE1 notification: '$cuuid'"
	ble enable $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $cuuid_to_enable $::de1(cinstance)
}

proc de1_send {msg} {
	delay_screen_saver
	
	#set handle $::de1(device_handle)
	#global suuid sinstance cuuid cinstance
	if {$::de1(device_handle) == "0"} {
		msg "error: de1 not connected"
		return
	}

	set ::de1(substate) -
	msg "Sending to DE1: '$msg'"
	
	#set magic1 "0000A000-0000-1000-8000-00805F9B34FB"
	#set magic2 "0000A002-0000-1000-8000-00805F9B34FB"
	#set magic3 "0000a001-0000-1000-8000-00805f9b34fb"
	#ble write $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid) $::de1(cinstance) "$msg"
	userdata_append [list ble write $::de1(device_handle) $::de1(suuid) $::de1(sinstance) $::de1(cuuid) $::de1(cinstance) "$msg"]
	#set res [ble characteristics $handle $magic1 0]
	#set res [ble services $handle]
    #set res [ble begin $handle]
    #ble begin $handle
    #lappend cmds [list ble write $handle $magic1 0 $magic2 0 "$msg"]
	#ble userdata $handle $cmds
    #ble execute $handle


	#set res [ble read $handle $magic1 $sinstance $magic3 0]
	#after 1000 de1_read
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

proc remove_null_terminator {instr} {
	set pos [string first "\x00" $instr]
	if {$pos == -1} {
		return $instr
	}

	incr pos -1
	return [string range $instr 0 $pos]
}

proc ble_connect_to_de1 {} {

	#set de1_address "C1:80:A7:32:CD:A3"
	#globel de1_address

	catch {
		ble unpair $::de1(de1_address)
	}

	if {$::de1(device_handle) != "0"} {
		catch {
			ble close $::de1(device_handle)
		}
	}


	set ::de1(found) 0	
    set ::de1_name "bPoint"
    set ::de1(scanning) 0
    set ::de1(device_handle) 0
    ble connect $::de1(de1_address) de1_ble_handler 
    msg "Connecting to DE1 on $::de1(de1_address)"

    #after 10000 ble_try_again_to_connect_to_bpoint
}

proc de1_ble_handler {event data} {
	#puts "de1 ble_handler $event $data"
	set ::de1(wrote) 0
	#msg "de1 ble_handler $event $data"
    dict with data {

    	catch {
			if {$cuuid != "0000A00D-0000-1000-8000-00805F9B34FB"} {
				msg "read from DE1: '$event $data'"
			}
		}

		switch -- $event {
	    	#msg "-- device $name found at address $address"
		    connection {
		    	#msg "connection: $data"
				if {$state eq "disconnected"} {
				    # fall back to scanning
				    #ble close $handle
				    #ble start [ble scanner ble_generic_handler]
				    msg "de1 disconnected"
				    #ble reconnect $::de1(device_handle)
				    ble_connect_to_de1
				} elseif {$state eq "connected"} {

					msg "de1 connected $event $data"
				    set ::de1(found) 1
				    msg "Connected to DE1"
					set ::de1(device_handle) $handle
					#msg "connected to de1 with handle $handle"

					#de1_enable_a00d
					#de1_enable_a00e
					#de1_enable_a00f
					de1_enable_bluetooth_notifications
					#run_next_userdata_cmd
					de1_send $::de1_state(Idle)
					run_de1_app
			    }
			}

		    characteristic {
			    #.t insert end "${event}: ${data}\n"
			    #msg "de1 characteristic $state: ${event}: ${data}"
			    #msg "connected to de1 with $handle "
				if {$state eq "discovery" && ($properties & 0x10)} {
					# && ($properties & 0x10)
				    # later turn on notifications

				    # john don't enable all notifications
				    #set cmds [ble userdata $handle]
				    #lappend cmds [list ble enable $handle $suuid $sinstance $cuuid $cinstance]
				    #msg "enabling $suuid $sinstance $cuuid $cinstance"
				    #ble userdata $handle $cmds
				} elseif {$state eq "connected"} {
					#msg "$data"
					#.t insert end "${event}: ${data}\n"
					set run_this 0
					if {$run_this == 1} {
						#msg "OBSOLETE"
						#return

					    set cmds [ble userdata $handle]
					    if {$cmds ne {}} {

							set cmd [lindex $cmds 0]
							set cmds [lrange $cmds 1 end]
							{*}$cmd
							ble userdata $handle $cmds

							# clear the userdata once it's been run
							ble userdata $handle ""
							#de1_read
					    }
					}

				    if {$access eq "r"} {
				    	msg "Received from DE1: '[remove_null_terminator $value]'"
						# change notification or read request
						#de1_ble_new_value $cuuid $value
				    } elseif {$access eq "w"} {
				    	msg "Confirmed wrote to DE1: '[remove_null_terminator $value]'"
						# change notification or read request
						#de1_ble_new_value $cuuid $value
				    } elseif {$access eq "c"} {
				    	
						# change notification or read request
						#de1_ble_new_value $cuuid $value
						if {$cuuid == "0000A00D-0000-1000-8000-00805F9B34FB"} {
							update_de1_shotvalue $value
						} elseif {$cuuid == "0000A00E-0000-1000-8000-00805F9B34FB"} {
							update_de1_substate $value
							msg "Confirmed a00e read from DE1: '[remove_null_terminator $value]'"
						} elseif {$cuuid == "0000A00F-0000-1000-8000-00805F9B34FB"} {
							update_de1_state $value
							msg "Confirmed a00f read from DE1: '[remove_null_terminator $value]'"
						} else {
							msg "Confirmed unknown read from DE1 $cuuid: '[remove_null_terminator $value]'"
						}

				    }

				    #run_next_userdata_cmd
				}
		    }
		    descriptor {
		    	#msg "de1 descriptor $state: ${event}: ${data}"
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
		}
    }



	run_next_userdata_cmd
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



proc update_de1_shotvalue {packed} {

	if {[string length $packed] < 7} {
		msg "ERROR: short packed message"
		return
	}

	set spec {
		Delta {char {} {} {unsigned}}
		GroupPressure {char {} {} {unsigned} {$val / 16.0}}
		GroupFlow {char {} {} {unsigned} {$val / 16.0}}
		MixTemp {short {} {} {unsigned} {$val / 256.0}}
		HeadTemp {short {} {} {unsigned} {$val / 256.0}}
	}

   array set specarr $spec

   	::fields::unpack $packed $spec ShotSample bigeendian
	foreach {field val} [array get ShotSample] {
		set specparts $specarr($field)
		set extra [lindex $specparts 4]
		if {$extra != ""} {
			set ShotSample($field) [expr $extra]
		}
	}

  	#msg "de1 internals: [array get ShotSample]"
	if {[info exists ShotSample(Delta)] == 1} {
		set ::de1(timer) [expr {$::de1(timer) + $ShotSample(Delta)}]
		#msg "updated timer"
	}
	if {[info exists ShotSample(HeadTemp)] == 1} {
		set ::de1(temperature) $ShotSample(HeadTemp)
		#msg "updated temp"
	}
	if {[info exists ShotSample(GroupFlow)] == 1} {
		set ::de1(flow) $ShotSample(GroupFlow)
		set ::de1(volume) [expr {$::de1(volume) + ($ShotSample(GroupFlow) * ($ShotSample(Delta)/100.0) )}]

		#msg "updated flow"
	}
	if {[info exists ShotSample(GroupPressure)] == 1} {
		set ::de1(pressure) $ShotSample(GroupPressure)
		#msg "updated pressure"
	}
}

proc update_de1_substate {statechar} {

	set spec {
		value char
	}

   	::fields::unpack $statechar $spec state bigeendian

   	if {$state(value) != $::de1(substate)} {
	   	msg "substate change: [array get state]"
   		set ::de1(substate) $state(value)
   	}

#    'NoState'          : 0,  # State is not relevant.
#    'HeatWaterTank'    : 1,  # Cold water is not hot enough. Heating hot water tank.
#    'HeatWaterHeater'  : 2,  # Warm up hot water heater for shot.
#    'StabilizeMixTemp' : 3,  # Stabilize mix temp and get entire water path up to temperature.
#    'PreInfuse'        : 4,  # Espresso only. Hot Water and Steam will skip this state.
#    'Pour'             : 5,  # Used in all states.
#    'Flush'            : 6   # Espresso only.

   	if {$state(value) == 0} {
   		# when the substate goes to 0 that means the current task is done, so indicate this by going back to the OFF state in the gui
   		if {$::de1(current_context) != "off"} {
			page_display_change $::de1(current_context) "off"
		}
   	}
}


proc update_de1_state {statechar} {

	set spec {
		value char
	}

   	::fields::unpack $statechar $spec state bigeendian

	msg "update_de1_state $state(value)"

   	if {$state(value) != $::de1(state)} {
	   	msg "state change: [array get state]"
   		set ::de1(state) $state(value)
   	}

   	if {$state(value) == 2} {
   		# when the state goes to 2 that means the current task is done, and we are back to idle
   		if {$::de1(current_context) != "off"} {
			page_display_change $::de1(current_context) "off"
		}
   	} elseif {$state(value) == 0} {
   		# when the state goes to 9 that means the DE1 is asleep, so we should show our screen saver
		page_display_change "sleep" "saver" 
   	}
}

