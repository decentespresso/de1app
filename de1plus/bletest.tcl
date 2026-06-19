package require ble

proc cb {event data} {
    if {$event eq "scan"} {
        puts "[dict get $data rssi] dBm  [dict get $data name]  [dict get $data address]"
    }
}
ble scanner cb        ;# start scanning; cb fires for every device
vwait forever         ;# in a script (or tclsh) you must run the event loop