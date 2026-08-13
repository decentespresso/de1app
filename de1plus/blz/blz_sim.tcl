# blz_sim.tcl --
#
# A SIMULATED `blz` command: same interface as undroidwish's real BlueZ-backed
# `blz` (verified against tclblz.c), but backed by in-memory virtual BLE devices.
# Runs anywhere Tcl runs (macOS included) with NO Bluetooth radio.
#
# Purpose: exercise blz_ble_shim.tcl (and any AndroWish BLE app) end-to-end,
# deterministically, without hardware. It ships two virtual peripherals that
# behave realistically: a Decent DE1 and an Atomax Skale.
#
# It reproduces the real blz semantics the shim depends on:
#   * async callbacks delivered through the Tcl event loop (via `after`)
#   * scan events carry raw advertising `scandata` (name + service UUIDs)
#   * connect fires AFTER discovery is ready (services/characteristics queryable)
#   * read/write are SYNCHRONOUS and emit NO event (shim synthesizes r/w acks)
#   * enable starts real notification streams; devices push characteristic events
#
# API: blz open <btdev> | scan <h> <cb> | stop <h> | connect <h> <addr> <cb> ?random?
#      | disconnect <h> | close <h> | services <h> | characteristics <h> <suuid>
#      | enable/disable <h> <suuid> <cuuid> | read <h> <suuid> <cuuid>
#      | write <h> <suuid> <cuuid> <value> | info ?<h>? | userdata <h> ?<v>? | callback <h> ?<cb>?

package require Tcl 8.5

namespace eval ::blzsim {
    variable seq 0
    variable adapters       ;# handle -> dict {scanning devaddr cb udata}
    variable devices        ;# addr  -> dict {name adv svcorder svc notifysrc}
    variable timers         ;# key   -> afterid (scan repeats, notify streams)
    variable seen           ;# handle -> list of addresses already reported this scan
    array set adapters {}
    array set devices  {}
    array set timers   {}
    array set seen     {}
    variable BASE 0000%s-0000-1000-8000-00805F9B34FB
    variable log ""         ;# optional call log for assertions
}

proc ::blzsim::u {short} { variable BASE; return [format $BASE [string toupper $short]] }

# --- advertising-data builder: Complete Local Name (0x09) + 16-bit svc (0x03) ---
proc ::blzsim::mk_adv {name svc16} {
    set nb [encoding convertto utf-8 $name]
    set ad [binary format cc [expr {[string length $nb]+1}] 0x09]$nb
    if {[llength $svc16]} {
        set sb ""
        foreach s $svc16 { append sb [binary format s [expr {"0x$s"}]] }  ;# LE 16-bit
        append ad [binary format cc [expr {[string length $sb]+1}] 0x03]$sb
    }
    return $ad
}

# --- register a virtual device ---
# svcspec: {suuid16 {cuuid16 initialvaluehex ...} ...}
proc ::blzsim::add_device {addr name svc16adv svcspec} {
    variable devices
    set svcorder {}; set svc [dict create]
    foreach {s chars} $svcspec {
        set su [u $s]; lappend svcorder $su
        set corder {}; set cd [dict create]
        foreach {c val} $chars {
            set cu [u $c]; lappend corder $cu
            dict set cd $cu [expr {$val eq "-" ? "" : [binary decode hex $val]}]
        }
        dict set svc $su [list order $corder val $cd]
    }
    set devices([string toupper $addr]) [dict create \
        name $name adv [mk_adv $name $svc16adv] svcorder $svcorder svc $svc]
}

proc ::blzsim::note {m} { variable log; lappend log $m }

# --- deliver an event to an adapter's callback (async, like real blz) ---
proc ::blzsim::fire {h event data} {
    variable adapters
    if {![info exists adapters($h)]} return
    set cb [dict get $adapters($h) cb]
    if {$cb eq ""} return
    dict set data handle $h
    after 0 [list ::blzsim::dispatch $cb $event $data]
}
proc ::blzsim::dispatch {cb event data} {
    if {[catch {uplevel #0 [list {*}$cb $event $data]} e]} {
        catch { puts stderr "blz_sim cb error: $e\n$::errorInfo" }
    }
}

# ------------------------------------------------------------------ the command
proc ::blzsim::blz {sub args} {
    variable seq; variable adapters; variable devices; variable timers; variable seen
    switch -- $sub {
        open {
            # blz open <btdev>  (btdev REQUIRED, like real blz)
            if {[llength $args] != 1} { error "wrong # args: blz open btdev" }
            set h "blz[incr seq]"
            set adapters($h) [dict create scanning 0 devaddr "" cb "" udata ""]
            note "open $args -> $h"
            return $h
        }
        scan {
            # blz scan <h> <cb>
            lassign $args h cb
            dict set adapters($h) cb $cb
            dict set adapters($h) scanning 1
            set seen($h) {}
            note "scan $h"
            scan_tick $h
            return ""
        }
        stop {
            lassign $args h
            dict set adapters($h) scanning 0
            catch { after cancel $timers(scan,$h) }
            note "stop $h"
            return ""
        }
        connect {
            # blz connect <h> <addr> <cb> ?random?
            lassign $args h addr cb random
            set addr [string toupper $addr]
            if {![info exists devices($addr)]} {
                # real blz: connect to an absent device times out; here, error
                error "device $addr not present"
            }
            dict set adapters($h) cb $cb
            dict set adapters($h) devaddr $addr
            note "connect $h $addr"
            # discovery is "ready" immediately in real blz by the time connected
            # fires; emulate a small delay then the connected event.
            set timers(conn,$h) [after 30 [list ::blzsim::fire $h connection \
                [dict create address $addr connected 1]]]
            return ""
        }
        disconnect - close {
            lassign $args h
            if {![info exists adapters($h)]} { return "" }
            set addr [dict get $adapters($h) devaddr]
            # stop any notify streams for this handle
            foreach k [array names timers notify,$h,*] { after cancel $timers($k); unset timers($k) }
            if {$addr ne "" && $sub eq "disconnect"} {
                fire $h connection [dict create address $addr connected 0]
            }
            dict set adapters($h) devaddr ""
            note "$sub $h"
            return ""
        }
        services {
            lassign $args h
            return [dict get [devof $h] svcorder]
        }
        characteristics {
            lassign $args h suuid
            set d [devof $h]
            if {![dict exists $d svc $suuid]} { return "" }
            return [dict get $d svc $suuid order]
        }
        read {
            # SYNCHRONOUS value return, no event (like real blz)
            lassign $args h suuid cuuid
            set d [devof $h]
            note "read $h $suuid $cuuid"
            if {[dict exists $d svc $suuid val $cuuid]} {
                return [dict get $d svc $suuid val $cuuid]
            }
            return ""
        }
        write {
            # SYNCHRONOUS, no event. Triggers device behavior (which may notify).
            lassign $args h suuid cuuid value
            set addr [dict get $adapters($h) devaddr]
            note "write $h $suuid $cuuid [binary encode hex $value]"
            device_behavior $h $addr $suuid $cuuid $value
            return 1
        }
        enable {
            lassign $args h suuid cuuid
            note "enable $h $suuid $cuuid"
            start_notify $h $suuid $cuuid
            return 1
        }
        disable {
            lassign $args h suuid cuuid
            note "disable $h $suuid $cuuid"
            catch { after cancel $timers(notify,$h,$suuid,$cuuid); unset timers(notify,$h,$suuid,$cuuid) }
            return 1
        }
        indenable { return [blz enable {*}$args] }
        info {
            if {[llength $args] == 0} { return [array names adapters] }
            lassign $args h
            if {![info exists adapters($h)]} { return "" }
            set a $adapters($h)
            return [list address [dict get $a devaddr] scanning [dict get $a scanning] \
                         connected [expr {[dict get $a devaddr] ne ""}]]
        }
        userdata {
            lassign $args h v
            if {[llength $args] >= 2} { dict set adapters($h) udata $v }
            return [dict get $adapters($h) udata]
        }
        callback {
            lassign $args h cb
            if {[llength $args] >= 2} { dict set adapters($h) cb $cb }
            return [dict get $adapters($h) cb]
        }
        default { error "blz_sim: unknown subcommand \"$sub\"" }
    }
}

proc ::blzsim::devof {h} {
    variable adapters; variable devices
    set addr [dict get $adapters($h) devaddr]
    if {$addr eq "" || ![info exists devices($addr)]} { error "invalid handle: not connected" }
    return $devices($addr)
}

# repeatedly report each device while scanning (like a real scan)
proc ::blzsim::scan_tick {h} {
    variable adapters; variable devices; variable timers; variable seen
    if {![info exists adapters($h)] || ![dict get $adapters($h) scanning]} return
    # Report each device ONCE per scan, like CoreBluetooth's default (duplicates
    # filtered). Re-reporting on every tick would make apps that rebuild their
    # device list (e.g. bledemo) clear the user's selection, blocking connect
    # mid-scan. The periodic tick stays so a newly-added device still appears.
    set rssi -55
    foreach addr [lsort [array names devices]] {
        incr rssi -7
        if {[lsearch -exact $seen($h) $addr] >= 0} continue
        lappend seen($h) $addr
        fire $h scan [dict create address $addr type 1 rssi $rssi \
                          scandata [dict get $devices($addr) adv]]
    }
    set timers(scan,$h) [after 1000 [list ::blzsim::scan_tick $h]]
}

# ---- device behaviors: what a virtual peripheral does on write/enable --------
proc ::blzsim::device_behavior {h addr suuid cuuid value} {
    variable devices
    set d $devices($addr)
    # store the written value as the characteristic's current value
    if {[dict exists $d svc $suuid val $cuuid]} {
        dict set devices($addr) svc $suuid val $cuuid $value
    }
    set name [dict get $d name]
    if {$name eq "DE1"} {
        # write RequestedState (A002) -> device emits StateInfo (A00E) notification
        if {[string match -nocase "*A002*" $suuid$cuuid] || [dict exists $d svc [u A000]]} {
            if {[string equal -nocase $cuuid [u A002]]} {
                binary scan $value cu st
                set payload [binary format cu [expr {$st & 0xff}]]
                after 40 [list ::blzsim::push $h [u A000] [u A00E] $payload]
            }
        }
    } elseif {$name eq "Skale"} {
        # write 0x03 to EF80 = tare -> reset weight, echo handled by shim ack
        if {[string equal -nocase $cuuid [u EF80]]} {
            dict set devices($addr) weight 0
        }
    }
}

proc ::blzsim::start_notify {h suuid cuuid} {
    variable adapters; variable devices; variable timers
    set addr [dict get $adapters($h) devaddr]
    set d $devices($addr)
    set name [dict get $d name]
    if {$name eq "Skale" && [string equal -nocase $cuuid [u EF81]]} {
        if {![dict exists $devices($addr) weight]} { dict set devices($addr) weight 0 }
        notify_weight $h $addr $suuid $cuuid
    } elseif {$name eq "DE1" && [string equal -nocase $cuuid [u A00D]]} {
        notify_temps $h $addr $suuid $cuuid
    }
    # (StateInfo A00E is event-driven, pushed by writes, not a periodic stream)
}
proc ::blzsim::notify_weight {h addr suuid cuuid} {
    variable devices; variable timers; variable adapters
    if {![info exists adapters($h)] || [dict get $adapters($h) devaddr] ne $addr} return
    set w [expr {[dict get $devices($addr) weight] + 3}]   ;# +0.3 g each tick
    dict set devices($addr) weight $w
    push $h $suuid $cuuid [skale_weight_packet $w]
    set timers(notify,$h,$suuid,$cuuid) [after 200 [list ::blzsim::notify_weight $h $addr $suuid $cuuid]]
}
# A real Atomax Skale EF81 notification is an 18-byte packet: a flag byte, the
# signed little-endian int16 weight (tenths of a gram) at offset 1 -- which is
# what de1app (binary scan cus1cu) and the ble.tcl example (binary scan xs) read
# -- followed by device markers/padding that parsers ignore. Mirror that length
# and layout so the simulator matches what a real Skale puts on the wire.
proc ::blzsim::skale_weight_packet {tenths} {
    set pkt [binary format cs 3 $tenths]                    ;# flag(0x03) + LE int16
    append pkt [binary decode hex "00ff00000000ff00000000ffff0000"]  ;# 15 bytes pad
    return [string range $pkt 0 17]                         ;# exactly 18 bytes
}
proc ::blzsim::notify_temps {h addr suuid cuuid} {
    variable timers; variable adapters
    if {![info exists adapters($h)] || [dict get $adapters($h) devaddr] ne $addr} return
    push $h $suuid $cuuid [binary format s 880]            ;# fake temperature word
    set timers(notify,$h,$suuid,$cuuid) [after 250 [list ::blzsim::notify_temps $h $addr $suuid $cuuid]]
}
# push a characteristic notification (real blz "characteristic" event)
proc ::blzsim::push {h suuid cuuid value} {
    variable adapters
    if {![info exists adapters($h)]} return
    set addr [dict get $adapters($h) devaddr]
    fire $h characteristic [dict create address $addr suuid $suuid cuuid $cuuid flags 16 value $value]
}

# ---- built-in virtual devices ------------------------------------------------
proc ::blzsim::install_default_devices {} {
    # DE1: service A000; A001 Versions(read), A002 RequestedState(w/r),
    #      A00D Temperatures(notify), A00E StateInfo(notify)
    add_device "DE:CE:00:00:00:01" "DE1" {A000} {
        A000 { A001 03000201 A002 00 A00D 0000 A00E 00 }
    }
    # Skale: service FF08; EF80 command(write), EF81 weight(notify), EF82 button(notify)
    add_device "A7:00:00:00:00:5C" "Skale" {FF08} {
        FF08 { EF80 - EF81 - EF82 - }
    }
}

# ---- install as the `blz` command + provide the package ----------------------
if {[llength [info commands ::blz]] == 0} {
    proc ::blz {sub args} { return [::blzsim::blz $sub {*}$args] }
}
::blzsim::install_default_devices
package provide blz 1.0
package provide blz_sim 1.0
