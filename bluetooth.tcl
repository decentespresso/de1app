
array set ::de1 {
    found    0
    scanning 1
    device_handle 0
	state "-"
}

proc app_exit {} {
	catch {
		msg "Closing de1"
		ble close $::de1(device_handle)

		set de1_address "C1:80:A7:32:CD:A3"
		ble unpair $de1_address
	}
	exit
}

proc de1_send {msg} {
	set handle $::de1(device_handle)
	if {$handle == "0"} {
		msg "error: de1 not connected"
		return
	}

	set ::de1(state) -
	msg "Sending to DE1: '$msg'"
	
	set magic1 "0000A000-0000-1000-8000-00805F9B34FB"
	set magic2 "0000A002-0000-1000-8000-00805F9B34FB"
	set magic3 "0000a001-0000-1000-8000-00805f9b34fb"
	ble write $handle $magic1 0 $magic2 0 "$msg"
	#set res [ble characteristics $handle $magic1 0]
	#set res [ble services $handle]
    #set res [ble begin $handle]
    #ble begin $handle
    #lappend cmds [list ble write $handle $magic1 0 $magic2 0 "$msg"]
	#ble userdata $handle $cmds
    #ble execute $handle


	#set res [ble read $handle $magic1 0 $magic3 0]
	#after 1000 de1_read
}


proc de1_read {} {
	set handle $::de1(device_handle)
	if {$handle == "0"} {
		msg "error: de1 not connected"
		return
	}

	set ::de1(state) -
	set magic1 "0000A000-0000-1000-8000-00805F9B34FB"
	set magic2 "0000A002-0000-1000-8000-00805F9B34FB"
	set magic3 "0000a001-0000-1000-8000-00805f9b34fb"

	set res [ble read $handle $magic1 0 $magic3 0]
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

	set de1_address "C1:80:A7:32:CD:A3"

	catch {
		ble unpair $de1_address
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
    ble connect $de1_address de1_ble_handler 
    msg "Connecting to DE1 on $de1_address"

    #after 10000 ble_try_again_to_connect_to_bpoint
}

proc de1_ble_handler {event data} {
	puts "de1 ble_handler $event $data"
	#msg "de1 ble_handler $event $data"
    dict with data {
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

				    set ::de1(found) 1
				    msg "Connected to DE1"
					set ::de1(device_handle) $handle
					#msg "connected to de1 with handle $handle"

                    set runthis 1
                    if {$runthis == 1} {
					    set cmds [ble userdata $handle]
					    if {$cmds ne {}} {
							set cmd [lindex $cmds 0]
							set cmds [lrange $cmds 1 end]
							{*}$cmd

							#set ::skale(device_handle) $handle
							msg "1) connected to de1 with handle $handle"
							#msg "command type received: '$cmd'"
						}
					}

					run_de1_app


			    }
			}
		    characteristic {
			    #.t insert end "${event}: ${data}\n"
			    #msg "de1 characteristic ${event}: ${data}"
			    #msg "connected to de1 with $handle "
				if {($state eq "discovery") && ($properties & 0x10)} {
				    # later turn on notifications
				    set cmds [ble userdata $handle]
				    lappend cmds [list ble enable $handle $suuid $sinstance \
						      $cuuid $cinstance]
				    ble userdata $handle $cmds
				} elseif {$state eq "connected"} {
					#msg "$data"
					#.t insert end "${event}: ${data}\n"
					set run_this 0
					if {$run_this == 1} {
						msg "OBSOLETE"
						return

					    set cmds [ble userdata $handle]
					    if {$cmds ne {}} {
							set cmd [lindex $cmds 0]
							set cmds [lrange $cmds 1 end]
							{*}$cmd
							#ble userdata $handle $cmds

							# clear the userdata once it's been run
							ble userdata $handle ""
							de1_read
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
				    }

				}
		    }
		    descriptor {
				if {$state eq "connected"} {
				    set cmds [ble userdata $handle]
				    if {$cmds ne {}} {
						set cmd [lindex $cmds 0]
						set cmds [lrange $cmds 1 end]
						{*}$cmd
						ble userdata $handle $cmds
				    }
				}
		    }
		}
    }

    #msg "exited event"
}




