# blz_ble_shim.tcl --
#
# An AndroWish-compatible `ble` command implemented on top of undroidwish's
# built-in `blz` (BlueZ) command, so Tcl code written against the AndroWish BLE
# API runs UNALTERED on Linux/BlueZ.
#
# Copyright (C) 2026 John Buckman
# SPDX-License-Identifier: TCL
#
# Usage (the ONLY change an AndroWish app needs):
#     package require blz_ble_shim 1.0
# ...placed before the app's own `package require ble` / `ble ...` calls.
#
# ---------------------------------------------------------------------------
# THREADING (one-bus design)
#
# blz's `connect` is SYNCHRONOUS -- it blocks until the peripheral's GATT
# services resolve (several seconds for the DE1). On the single-threaded Tcl/SDL
# event loop that would freeze the UI. So ALL blz work -- scanning AND device
# connections AND their reads/writes/notifications -- runs on ONE dedicated
# worker thread, sharing ONE sd_bus connection (sd_bus is per-thread). The main
# thread's `ble` command is a thin proxy:
#   * connect       -> fire-and-forget to the worker; returns the handle at once
#                      (no UI freeze). While the worker blocks in connect, the
#                      main/UI thread stays responsive; scanning simply waits its
#                      turn on the worker (like the app's other platforms).
#   * read/write/... -> synchronous thread::send (fast single GATT ops; same
#                      ordering the app expects). The worker never calls back
#                      into main synchronously, so there is no deadlock.
#   * scan/connect share one bus, so a connect never fights discovery (the
#                      two-bus version hung; this does not) and no pause/resume
#                      dance is needed.
# blz's async callbacks (scan / connection / notification) fire on the worker
# and are marshalled to main via `thread::send -async`, where the app's
# callbacks run. A connect-by-address to a not-yet-discovered device fails on
# BlueZ (ConnectDevice needs bluetoothd --experimental); we throttle that failure
# so the app can't hot-loop reconnects before a scan populates the registry.
# If the Thread package is unavailable we fall back to fully-synchronous blz.
# ---------------------------------------------------------------------------
# API presented (matches AndroWish / tcl-ble-osx exactly):
#
#   ble scanner   <callback>                       -> scanner token (starts scan)
#   ble start     <token>                          -> (re)start scanning
#   ble stop      <token>                          -> stop scanning
#   ble connect   <address> <callback> ?<reconnect>? -> connection handle "ble<n>"
#   ble reconnect <handle>                         -> re-attempt connect
#   ble disconnect/close <handle>                  -> disconnect / stop scanner
#   ble info      ?<handle>?                        -> handles / info dict
#   ble enable    <h> <suuid> <si> <cuuid> <ci>    -> 1  (+ synth descriptor ack)
#   ble disable   <h> <suuid> <si> <cuuid> <ci>    -> 1
#   ble write     <h> <suuid> <si> <cuuid> <ci> ?<wt>? <data> -> 1 (+ synth w-ack)
#   ble read      <h> <suuid> <si> <cuuid> <ci>    -> 1  (+ synth r-event)
#   ble mtu       <h> ?<value>?                     -> mtu (best-effort)
#   ble userdata  <h> ?<value>?                     -> per-handle scratch
#   ble state                                       -> adapter state
#   ble expand/shorten/equal ...                    -> pure-Tcl UUID helpers
#   ble abort/unpair/pair/begin/execute/getrssi     -> accepted (no-op/best effort)
# ---------------------------------------------------------------------------

package require Tcl 8.5

namespace eval ::blzshim {
    variable BASE 0000%s-0000-1000-8000-00805F9B34FB
    variable CCCD 00002902-0000-1000-8000-00805F9B34FB

    variable adapter     "hci0"
    variable handleseq   0
    variable scannerseq  0
    variable scannercb   ""     ;# app callback for scan events
    variable scannertok  ""
    variable scanning    0

    # per ble-handle state kept on MAIN (worker holds the blz handles)
    variable cbof    ;# ble handle -> app callback
    variable addrof  ;# ble handle -> address
    variable mtuof   ;# ble handle -> mtu
    variable udata   ;# ble handle -> scratch
    variable chars   ;# ble handle -> list of {suuid cuuid}
    array set cbof   {}
    array set addrof {}
    array set mtuof  {}
    array set udata  {}
    array set chars  {}

    # SYNC-fallback maps (only when no Thread)
    variable blzof ; array set blzof {}
    variable bleof ; array set bleof {}
    variable scanctx ""

    variable worker    ""
    variable useworker 0
    variable solib     ""

    variable debug 0
}

catch {
    set ::blzshim::solib \
        [file join [file dirname [file normalize [info script]]] \
             libblz-$::tcl_platform(machine).so]
}

proc ::blzshim::log {args} {
    variable debug
    if {!$debug} return
    catch { set f [open /tmp/blzshim.log a]; puts $f "[clock milliseconds] [join $args { }]"; close $f }
}

# ---- UUID helpers ----
proc ::blzshim::expand_uuid {u} {
    variable BASE
    set s [string toupper $u]
    if {[regexp {^[0-9A-F]{4}$} $s]}      { return [format $BASE $s] }
    if {[regexp {^[0-9A-F]{8}$} $s]}      { return "$s-0000-1000-8000-00805F9B34FB" }
    return $s
}
proc ::blzshim::shorten_uuid {u} {
    set s [string toupper $u]
    if {[regexp {^0000([0-9A-F]{4})-0000-1000-8000-00805F9B34FB$} $s -> x]} { return $x }
    return $s
}
proc ::blzshim::uuid_equal {a b} { return [string equal -nocase [expand_uuid $a] [expand_uuid $b]] }

proc ::blzshim::deliver {cb event data} {
    if {$cb eq ""} return
    if {[catch {uplevel #0 [list {*}$cb $event $data]} err]} {
        catch {
            if {[llength [info commands ::bgerror]]} { ::bgerror $err } \
            else { puts stderr "ble callback error: $err\n$::errorInfo" }
        }
    }
}
proc ::blzshim::later {cb event data} { after 0 [list ::blzshim::deliver $cb $event $data] }

proc ::blzshim::parse_adv {scandata} {
    set name ""; set services {}; set mfr ""
    set n [string length $scandata]; set i 0
    while {$i < $n} {
        binary scan [string index $scandata $i] cu len
        if {$len == 0} { incr i; continue }
        if {$i + $len >= $n + 1} break
        binary scan [string index $scandata [expr {$i+1}]] cu type
        set payload [string range $scandata [expr {$i+2}] [expr {$i+$len}]]
        switch -- $type {
            8 - 9 { set name [encoding convertfrom utf-8 $payload] }
            2 - 3 { binary scan $payload su* us; foreach u $us { lappend services [format %04X [expr {$u & 0xffff}]] } }
        }
        incr i [expr {$len + 1}]
    }
    return [list $name $services $mfr]
}

# ---------------------------------------------------------------------------
# Worker thread script (owns scan + all device I/O on one bus). @PLACEHOLDERS@.
# ---------------------------------------------------------------------------
variable ::blzshim::worker_script {
    load @SOLIB@ Blz
    namespace eval ::blzw {
        variable main    @MAIN@
        variable adapter @ADAPTER@
        variable scanctx  ""
        variable scanning 0
        variable scanpoll ""
        variable scanseen ; array set scanseen {}
        variable blzof ; array set blzof {}   ;# ble -> blz handle
        variable bleof ; array set bleof {}   ;# blz handle -> ble
    }
    proc ::blzw::tomain {args} { variable main; catch { thread::send -async $main $args } }

    # ---- scan ----
    proc ::blzw::on_scan {event data} {
        if {$event ne "scan"} return
        variable scanseen
        set addr ""; catch { set addr [string toupper [dict get $data address]] }
        set rssi ""; catch { set rssi [dict get $data rssi] }
        set sd "";   catch { set sd [dict get $data scandata] }
        set name [lindex [split $sd "\x00"] 0]
        if {[info exists scanseen($addr)] && $scanseen($addr) eq $name} return
        set scanseen($addr) $name
        tomain ::blzshim::from_scan $addr $name $rssi
    }
    proc ::blzw::scanpoll {} {
        variable scanctx; variable scanpoll
        if {$scanctx eq ""} return
        catch { after cancel $scanpoll }
        catch { blz devices $scanctx }
        set scanpoll [after 1200 ::blzw::scanpoll]
    }
    proc ::blzw::scan_start {} {
        variable scanctx; variable scanning; variable adapter
        if {$scanctx eq ""} { catch { set scanctx [blz open $adapter] } }
        if {$scanctx ne "" && !$scanning} { catch { blz scan $scanctx ::blzw::on_scan }; set scanning 1; scanpoll }
    }
    proc ::blzw::scan_stop {} {
        variable scanctx; variable scanning; variable scanpoll; variable scanseen
        if {$scanctx ne ""} { catch { blz stop $scanctx } }
        set scanning 0
        catch { after cancel $scanpoll }; set scanpoll ""
        array unset scanseen; array set scanseen {}
    }

    # ---- device callbacks ----
    proc ::blzw::on_dev {event data} {
        variable bleof
        set bh ""; catch { set bh [dict get $data handle] }
        if {![info exists bleof($bh)]} return
        set ble $bleof($bh)
        switch -- $event {
            connection {
                set c 0; catch { set c [dict get $data connected] }
                if {$c} {
                    set disc {}
                    set svcs {}; catch { set svcs [blz services $bh] }
                    foreach su $svcs {
                        set cl {}; catch { set cl [blz characteristics $bh $su] }
                        lappend disc [list $su $cl]
                    }
                    tomain ::blzshim::from_connected $ble $disc
                } else {
                    tomain ::blzshim::from_disconnected $ble
                    dev_cleanup $ble
                }
            }
            characteristic {
                set su ""; catch { set su [dict get $data suuid] }
                set cu ""; catch { set cu [dict get $data cuuid] }
                set val ""; catch { set val [dict get $data value] }
                tomain ::blzshim::from_notify $ble $su $cu $val
            }
        }
    }
    proc ::blzw::dev_cleanup {ble} {
        variable blzof; variable bleof
        if {[info exists blzof($ble)]} {
            set bh $blzof($ble)
            catch { unset bleof($bh) }
            catch { blz close $bh }
            unset blzof($ble)
        }
    }
    proc ::blzw::connect {ble addr random} {
        variable blzof; variable bleof; variable adapter
        variable scanctx; variable scanning; variable scanpoll
        # BlueZ can't reliably connect while the adapter is discovering. Since
        # scan + connect share this one bus, pause discovery around the connect,
        # then restore it (the app still intends to scan). All on the worker, so
        # no cross-thread state.
        set was_scanning $scanning
        if {$was_scanning && $scanctx ne ""} {
            catch { blz stop $scanctx }
            catch { after cancel $scanpoll }; set scanpoll ""
        }
        set bh [blz open $adapter]
        set blzof($ble) $bh; set bleof($bh) $ble
        set rc [catch { blz connect $bh $addr ::blzw::on_dev $random } err]
        # restore discovery for the app's scan (if it still wants one)
        if {$was_scanning && $scanning && $scanctx ne ""} {
            catch { blz scan $scanctx ::blzw::on_scan }
            scanpoll
        }
        if {$rc} {
            dev_cleanup $ble
            # Throttle: connect-by-address to a not-yet-discovered device fails
            # instantly on BlueZ; delay the failure so the app can't hot-loop
            # reconnects before a scan populates the registry.
            after 2000 [list ::blzw::tomain ::blzshim::from_disconnected $ble]
        }
        # on success, blz's connection callback drives from_connected
    }
    proc ::blzw::reconnect {ble addr} {
        variable blzof
        if {[info exists blzof($ble)]} { catch { blz connect $blzof($ble) $addr ::blzw::on_dev } }
    }
    proc ::blzw::read {ble su cu} { variable blzof; if {![info exists blzof($ble)]} { return "" }; set v ""; catch { set v [blz read $blzof($ble) $su $cu] }; return $v }
    proc ::blzw::write {ble su cu data} { variable blzof; if {![info exists blzof($ble)]} { return 0 }; if {[catch { blz write $blzof($ble) $su $cu $data }]} { return 0 }; return 1 }
    proc ::blzw::enable {ble su cu} { variable blzof; if {![info exists blzof($ble)]} { return 0 }; if {[catch { blz enable $blzof($ble) $su $cu }]} { return 0 }; return 1 }
    proc ::blzw::disable {ble su cu} { variable blzof; if {![info exists blzof($ble)]} { return 0 }; if {[catch { blz disable $blzof($ble) $su $cu }]} { return 0 }; return 1 }
    proc ::blzw::services {ble} { variable blzof; if {![info exists blzof($ble)]} { return "" }; set o {}; catch { set o [blz services $blzof($ble)] }; return $o }
    proc ::blzw::chars {ble su} { variable blzof; if {![info exists blzof($ble)]} { return "" }; set o {}; catch { set o [blz characteristics $blzof($ble) $su] }; return $o }
    proc ::blzw::disconnect {ble} { variable blzof; if {[info exists blzof($ble)]} { catch { blz disconnect $blzof($ble) } }; dev_cleanup $ble }
    thread::wait
}

proc ::blzshim::ensure_worker {} {
    variable worker; variable useworker; variable solib; variable adapter; variable worker_script
    if {$useworker && $worker ne "" && [thread::exists $worker]} { return 1 }
    if {[catch { package require Thread }]} { return 0 }
    if {$solib eq "" || ![file exists $solib]} { return 0 }
    set body [string map [list \
        @SOLIB@   [list $solib] \
        @MAIN@    [list [thread::id]] \
        @ADAPTER@ [list $adapter]] $worker_script]
    if {[catch { set worker [thread::create $body] } e]} { log "worker create failed: $e"; return 0 }
    set useworker 1
    log "worker created $worker"
    return 1
}
proc ::blzshim::wcall {script} {
    variable worker
    set r ""; catch { set r [thread::send $worker $script] }; return $r
}

# ---- callbacks marshalled back from the worker (run on MAIN) ----
proc ::blzshim::from_scan {addr name rssi} {
    variable scannercb
    set services {}; set mfr ""
    if {$name eq ""} { }  ;# nameless: still deliver (app filters)
    set out [dict create address $addr name $name rssi $rssi]
    deliver $scannercb scan $out
}
proc ::blzshim::from_connected {ble disc} {
    variable cbof; variable addrof; variable mtuof; variable chars
    if {![info exists cbof($ble)]} return
    set addr [expr {[info exists addrof($ble)] ? $addrof($ble) : ""}]
    set chars($ble) {}
    foreach entry $disc {
        lassign $entry su clist
        deliver $cbof($ble) service [dict create handle $ble address $addr state discovery suuid $su sinstance 0 type primary]
        foreach cu $clist {
            lappend chars($ble) [list $su $cu]
            deliver $cbof($ble) characteristic [dict create handle $ble address $addr state discovery suuid $su sinstance 0 cuuid $cu cinstance 0]
        }
    }
    set mtu [expr {[info exists mtuof($ble)] ? $mtuof($ble) : 23}]
    deliver $cbof($ble) connection [dict create handle $ble address $addr state connected mtu $mtu]
}
proc ::blzshim::from_disconnected {ble} {
    variable cbof; variable addrof
    if {[info exists cbof($ble)]} {
        set addr [expr {[info exists addrof($ble)] ? $addrof($ble) : ""}]
        deliver $cbof($ble) connection [dict create handle $ble address $addr state disconnected]
    }
    forget_main $ble
}
proc ::blzshim::from_notify {ble su cu val} {
    variable cbof; variable addrof
    if {![info exists cbof($ble)]} return
    set addr [expr {[info exists addrof($ble)] ? $addrof($ble) : ""}]
    deliver $cbof($ble) characteristic [dict create handle $ble address $addr state connected access c suuid $su sinstance 0 cuuid $cu cinstance 0 value $val]
}
proc ::blzshim::forget_main {ble} {
    variable cbof; variable addrof; variable mtuof; variable chars; variable udata
    foreach a {cbof addrof mtuof chars udata} { catch { unset ${a}($ble) } }
}

# ---------------------------------------------------------------------------
# SYNC fallback (no Thread): original blocking behaviour.
# ---------------------------------------------------------------------------
proc ::blzshim::sync_open {} { variable adapter; if {[info exists ::env(BLZ_ADAPTER)]} { set adapter $::env(BLZ_ADAPTER) }; return [blz open $adapter] }
proc ::blzshim::sync_on_scan {event data} {
    variable scannercb
    if {$event ne "scan"} return
    set addr ""; catch { set addr [string toupper [dict get $data address]] }
    set rssi ""; catch { set rssi [dict get $data rssi] }
    set sd "";   catch { set sd [dict get $data scandata] }
    set name [lindex [split $sd "\x00"] 0]
    deliver $scannercb scan [dict create address $addr name $name rssi $rssi]
}
proc ::blzshim::sync_on_dev {event data} {
    variable bleof; variable addrof; variable cbof; variable mtuof
    set bh ""; catch { set bh [dict get $data handle] }
    if {![info exists bleof($bh)]} return
    set ble $bleof($bh); set addr [expr {[info exists addrof($ble)] ? $addrof($ble) : ""}]
    switch -- $event {
        connection {
            set c 0; catch { set c [dict get $data connected] }
            if {$c} {
                set chars_ [list]
                set svcs {}; catch { set svcs [blz services $bh] }
                foreach su $svcs {
                    deliver $cbof($ble) service [dict create handle $ble address $addr state discovery suuid $su sinstance 0 type primary]
                    set cl {}; catch { set cl [blz characteristics $bh $su] }
                    foreach cu $cl { deliver $cbof($ble) characteristic [dict create handle $ble address $addr state discovery suuid $su sinstance 0 cuuid $cu cinstance 0] }
                }
                set mtu [expr {[info exists mtuof($ble)] ? $mtuof($ble) : 23}]
                deliver $cbof($ble) connection [dict create handle $ble address $addr state connected mtu $mtu]
            } else {
                deliver $cbof($ble) connection [dict create handle $ble address $addr state disconnected]
                sync_forget $ble
            }
        }
        characteristic {
            set su ""; catch { set su [dict get $data suuid] }
            set cu ""; catch { set cu [dict get $data cuuid] }
            set val ""; catch { set val [dict get $data value] }
            deliver $cbof($ble) characteristic [dict create handle $ble address $addr state connected access c suuid $su sinstance 0 cuuid $cu cinstance 0 value $val]
        }
    }
}
proc ::blzshim::sync_forget {ble} {
    variable blzof; variable bleof
    if {[info exists blzof($ble)]} { set bh $blzof($ble); catch { unset bleof($bh) }; catch { blz close $bh }; catch { unset blzof($ble) } }
    forget_main $ble
}

# ---------------------------------------------------------------------------
# The `ble` command.
# ---------------------------------------------------------------------------
proc ::blzshim::cmd {sub args} {
    variable handleseq; variable scannerseq
    variable scannercb; variable scannertok; variable scanning
    variable cbof; variable addrof; variable mtuof; variable udata; variable chars
    variable blzof; variable bleof; variable scanctx
    variable useworker; variable worker; variable CCCD
    log "CMD $sub $args"

    switch -- $sub {

        scanner {
            set scannercb [lindex $args 0]
            incr scannerseq
            set scannertok "blzscanner$scannerseq"
            set scanning 1
            if {[ensure_worker]} {
                thread::send -async $worker ::blzw::scan_start
            } else {
                if {$scanctx eq ""} { set scanctx [sync_open] }
                catch { blz scan $scanctx ::blzshim::sync_on_scan }
            }
            return $scannertok
        }
        start {
            set scanning 1
            if {$useworker} { thread::send -async $worker ::blzw::scan_start } \
            elseif {$scanctx ne ""} { catch { blz scan $scanctx ::blzshim::sync_on_scan } }
            return ""
        }
        stop {
            set scanning 0
            if {$useworker} { thread::send -async $worker ::blzw::scan_stop } \
            elseif {$scanctx ne ""} { catch { blz stop $scanctx } }
            return ""
        }

        connect {
            set address [string toupper [lindex $args 0]]
            set callback [lindex $args 1]
            set random [expr {[llength $args] >= 3 ? [lindex $args 2] : 0}]
            incr handleseq
            set ble "ble$handleseq"
            set cbof($ble) $callback
            set addrof($ble) $address
            if {[ensure_worker]} {
                thread::send -async $worker [list ::blzw::connect $ble $address $random]
                return $ble
            }
            set bh [sync_open]
            set blzof($ble) $bh; set bleof($bh) $ble
            if {[catch { blz connect $bh $address ::blzshim::sync_on_dev $random } err]} { sync_forget $ble; error $err }
            return $ble
        }
        reconnect {
            set ble [lindex $args 0]
            if {![info exists addrof($ble)]} { return $ble }
            if {$useworker} { thread::send -async $worker [list ::blzw::reconnect $ble $addrof($ble)] } \
            elseif {[info exists blzof($ble)]} { catch { blz connect $blzof($ble) $addrof($ble) ::blzshim::sync_on_dev } }
            return $ble
        }
        close - disconnect {
            set h [lindex $args 0]
            if {[string match "blzscanner*" $h]} {
                set scanning 0
                if {$useworker} { thread::send -async $worker ::blzw::scan_stop } \
                elseif {$scanctx ne ""} { catch { blz stop $scanctx } }
                return ""
            }
            if {![info exists cbof($h)] && ![info exists blzof($h)]} { return "" }
            if {$useworker} { catch { thread::send -async $worker [list ::blzw::disconnect $h] }; forget_main $h } \
            else { catch { blz disconnect $blzof($h) }; sync_forget $h }
            return ""
        }

        info {
            if {[llength $args] == 0} { return [array names cbof] }
            set ble [lindex $args 0]
            if {![info exists addrof($ble)]} { return "" }
            set mtu [expr {[info exists mtuof($ble)] ? $mtuof($ble) : 23}]
            return [list handle $ble address $addrof($ble) mtu $mtu state connected]
        }

        enable {
            lassign $args ble suuid si cuuid ci
            if {![info exists cbof($ble)]} { return 0 }
            set addr $addrof($ble)
            if {$useworker} { if {![wcall [list ::blzw::enable $ble $suuid $cuuid]]} { return 0 } } \
            else { if {![info exists blzof($ble)] || [catch { blz enable $blzof($ble) $suuid $cuuid }]} { return 0 } }
            later $cbof($ble) descriptor [dict create handle $ble address $addr state connected access w suuid $suuid sinstance $si cuuid $cuuid cinstance $ci duuid $CCCD value [binary decode hex 0100]]
            return 1
        }
        disable {
            lassign $args ble suuid si cuuid ci
            if {![info exists cbof($ble)]} { return 0 }
            set addr $addrof($ble)
            if {$useworker} { if {![wcall [list ::blzw::disable $ble $suuid $cuuid]]} { return 0 } } \
            else { if {![info exists blzof($ble)] || [catch { blz disable $blzof($ble) $suuid $cuuid }]} { return 0 } }
            later $cbof($ble) descriptor [dict create handle $ble address $addr state connected access w suuid $suuid sinstance $si cuuid $cuuid cinstance $ci duuid $CCCD value [binary decode hex 0000]]
            return 1
        }
        write {
            set ble [lindex $args 0]; set suuid [lindex $args 1]; set si [lindex $args 2]
            set cuuid [lindex $args 3]; set ci [lindex $args 4]
            if {[llength $args] >= 7} { set data [lindex $args 6] } else { set data [lindex $args 5] }
            if {![info exists cbof($ble)]} { return 0 }
            set addr $addrof($ble)
            if {$useworker} { if {![wcall [list ::blzw::write $ble $suuid $cuuid $data]]} { return 0 } } \
            else { if {![info exists blzof($ble)] || [catch { blz write $blzof($ble) $suuid $cuuid $data }]} { return 0 } }
            later $cbof($ble) characteristic [dict create handle $ble address $addr state connected access w suuid $suuid sinstance $si cuuid $cuuid cinstance $ci value $data]
            return 1
        }
        read {
            lassign $args ble suuid si cuuid ci
            if {![info exists cbof($ble)]} { return 0 }
            set addr $addrof($ble); set val ""
            if {$useworker} { set val [wcall [list ::blzw::read $ble $suuid $cuuid]] } \
            else { if {![info exists blzof($ble)] || [catch { set val [blz read $blzof($ble) $suuid $cuuid] }]} { return 0 } }
            later $cbof($ble) characteristic [dict create handle $ble address $addr state connected access r suuid $suuid sinstance $si cuuid $cuuid cinstance $ci value $val]
            return 1
        }

        mtu      { set ble [lindex $args 0]; return [expr {[info exists mtuof($ble)] ? $mtuof($ble) : 23}] }
        userdata { set ble [lindex $args 0]; if {[llength $args] >= 2} { set udata($ble) [lindex $args 1] }; return [expr {[info exists udata($ble)] ? $udata($ble) : ""}] }
        state    { if {[catch { blz info } ]} { return "unknown" }; return "poweredOn" }
        services {
            set ble [lindex $args 0]; if {![info exists cbof($ble)]} { return "" }; set out {}
            if {$useworker} { catch { foreach su [wcall [list ::blzw::services $ble]] { lappend out $su 0 primary } } } \
            elseif {[info exists blzof($ble)]} { catch { foreach su [blz services $blzof($ble)] { lappend out $su 0 primary } } }
            return $out
        }
        characteristics {
            lassign $args ble suuid si; if {![info exists cbof($ble)]} { return "" }; set out {}
            if {$useworker} { catch { foreach cu [wcall [list ::blzw::chars $ble $suuid]] { lappend out $cu 0 0 0 2 } } } \
            elseif {[info exists blzof($ble)]} { catch { foreach cu [blz characteristics $blzof($ble) $suuid] { lappend out $cu 0 0 0 2 } } }
            return $out
        }

        expand  { return [expand_uuid  [lindex $args end]] }
        shorten { return [shorten_uuid [lindex $args end]] }
        equal   { return [uuid_equal [lindex $args end-1] [lindex $args end]] }
        abort - unpair - pair - begin - execute - getrssi - callback { return "" }
        default { error "ble: unknown subcommand \"$sub\"" }
    }
}

# ---- install ----
if {[llength [info commands ble]] > 0} {
    ::blzshim::log "real ble exists; deferring"
    package provide blz_ble_shim 1.0
    return
}
if {[catch { package require blz }]} {
    ::blzshim::log "no blz; shim inert"
    package provide blz_ble_shim 1.0
    return
}
proc ::ble {sub args} { return [::blzshim::cmd $sub {*}$args] }
package provide ble 1.0
package provide blz_ble_shim 1.0
::blzshim::log "installed: ble -> blz shim (one-bus worker)"
