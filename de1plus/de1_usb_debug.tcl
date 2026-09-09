#!/usr/bin/env tclsh
#
# de1_usb_debug.tcl -- standalone USB-C serial debugger for the Decent DE1.
#
# Connects to the DE1 over its USB-C CDC-ACM serial port, wakes it, reads the
# machine state, version, firmware/model, and serial number, decodes them, and
# prints the result. No Tk / de1app dependencies -- runs under plain tclsh so it
# can be used to debug the USB transport in isolation.
#
#   tclsh de1_usb_debug.tcl [/dev/cu.usbmodemXXXX]
#
# Protocol (mirrors decaid + de1app): outbound write "<X>hex\n", enable notify
# "<+X>\n", disable "<-X>\n"; inbound "[X]hex\n". Letters map to characteristics
# A001..A013 as 'A'+(uuid-0xA001): A=Version B=RequestedState E=ReadFromMMR
# F=WriteToMMR N=StateInfo M=ShotSample Q=WaterLevels.

set dev [lindex $argv 0]
if {$dev eq ""} {
    set cand [lsort [glob -nocomplain /dev/cu.usbmodem*]]
    if {[llength $cand] == 0} { puts "no /dev/cu.usbmodem* found"; exit 1 }
    set dev [lindex $cand 0]
}
puts "== opening $dev =="
set ch [open $dev {RDWR NONBLOCK}]
fconfigure $ch -mode 115200,n,8,1 -translation binary -buffering none -blocking 0
catch { fconfigure $ch -handshake none }
catch { fconfigure $ch -ttycontrol {DTR 0 RTS 0} }

# ---- inbound framing -------------------------------------------------------
set ::buf ""
array set ::last {}   ;# last payload hex per letter
array set ::mmr  {}   ;# last MMR reply hex per 3-byte address (upper hex)

proc onread {ch} {
    if {[catch {set d [read $ch]}]} return
    if {$d eq ""} return
    append ::buf $d
    while {[regexp -indices {(\[[A-Z]\][0-9A-Fa-f]*?)(?=\[|\n|\r)} $::buf whole]} {
        set s [lindex $whole 0]; set e [lindex $whole 1]
        set frame [string range $::buf $s $e]
        set ::buf [string range $::buf [expr {$e+1}] end]
        set L [string index $frame 1]
        set hex [string tolower [string range $frame 3 end]]
        set ::last($L) $hex
        if {$L eq "E"} {
            # MMR reply: byte0=len, bytes1-3 = address (as sent, big-endian in hex)
            set addr [string toupper [string range $hex 2 7]]
            set ::mmr($addr) $hex
        }
    }
    set lb [string first "\[" $::buf]; if {$lb>0} {set ::buf [string range $::buf $lb end]}
}
fileevent $ch readable [list onread $ch]

proc W {s} { puts "  >> $s"; puts -nonewline $::ch "$s\n"; flush $::ch }

# little-endian int32 from a hex string at byte offset
proc le32 {hex byteoff} {
    set o [expr {$byteoff*2}]
    set b0 [scan [string range $hex $o [expr {$o+1}]] %x]
    set b1 [scan [string range $hex [expr {$o+2}] [expr {$o+3}]] %x]
    set b2 [scan [string range $hex [expr {$o+4}] [expr {$o+5}]] %x]
    set b3 [scan [string range $hex [expr {$o+6}] [expr {$o+7}]] %x]
    return [expr {$b0 | ($b1<<8) | ($b2<<16) | ($b3<<24)}]
}

# Build + send an MMR read exactly like de1app's mmr_read: 1-byte length, then
# the 3-byte address (from a 6-hex-char string), then zero-padded to 20 bytes.
proc mmr_read {addr6 lenhex} {
    set body "${lenhex}${addr6}"
    while {[string length $body] < 40} { append body "0" }
    W "<E>$body"
}

proc wait_ms {ms} { after $ms {set ::_w 1}; vwait ::_w }

puts "== priming streams + wake =="
foreach l {N M Q} { W "<+$l>" }
wait_ms 300
W "<B>02"      ;# wake to Idle
wait_ms 800

puts "== state =="
if {[info exists ::last(N)]} {
    set st [scan [string range $::last(N) 0 1] %x]
    set su [scan [string range $::last(N) 2 3] %x]
    puts "  StateInfo \[N\]=$::last(N)  state=$st substate=$su"
} else { puts "  NO \[N\] state received" }

puts "== version (arm <+A>) =="
W "<+A>"
wait_ms 800
if {[info exists ::last(A)]} { puts "  Version \[A\]=$::last(A)" } else { puts "  NO \[A\] version reply" }
catch { W "<-A>" }

puts "== MMR: cpu/model/firmware (800008 len 02) =="
mmr_read "800008" "02"
wait_ms 800
if {[info exists ::mmr(800008)]} {
    set h $::mmr(800008)
    puts "  \[E\]=$h"
    puts "  cpu_board_model = [le32 $h 4]"
    puts "  machine_model   = [le32 $h 8]"
    puts "  firmware_version= [le32 $h 12]"
} else { puts "  NO \[E\] reply for 800008" }

puts "== MMR: serial number (803830 len 00) =="
mmr_read "803830" "00"
wait_ms 800
if {[info exists ::mmr(803830)]} {
    set h $::mmr(803830)
    puts "  \[E\]=$h   serial_number = [le32 $h 4]"
} else { puts "  NO \[E\] reply for 803830" }

puts "== MMR: GHC installed (80381C len 00) =="
mmr_read "80381C" "00"
wait_ms 800
if {[info exists ::mmr(80381C)]} {
    set h $::mmr(80381C)
    puts "  \[E\]=$h   ghc_installed = [le32 $h 4]"
} else { puts "  NO \[E\] reply for 80381C" }

puts "== all inbound letters seen: [lsort [array names ::last]] =="

# Bengle integrated scale: the weight rides on the BengleShotSample ([S], 0xA013)
# superset -- a signed big-endian Short at byte offset 20, x 0.0625 g. Arm it and
# watch the live weight for a few seconds so the integrated scale can be verified
# (put something on / take it off the drip tray and watch the number move).
proc bengle_weight {hex} {
    if {[string length $hex] < 44} { return "" }
    set raw [scan [string range $hex 40 43] %x]      ;# bytes 20..21, big-endian
    if {$raw >= 32768} { set raw [expr {$raw - 65536}]}
    return [format %.2f [expr {$raw * 0.0625}]]
}
if {[info exists ::last(S)]} {
    puts "== Bengle integrated scale detected (\[S\] streaming). Live weight for 8s: =="
    W "<+S>"
    set ::scale_end [expr {[clock milliseconds] + 8000}]
    set ::prevw ""
    proc scale_tick {} {
        if {[clock milliseconds] > $::scale_end} { set ::scale_done 1; return }
        if {[info exists ::last(S)]} {
            set w [bengle_weight $::last(S)]
            if {$w ne "" && $w ne $::prevw} { puts "   weight = ${w} g"; set ::prevw $w }
        }
        after 200 scale_tick
    }
    set ::scale_done 0
    after 200 scale_tick
    vwait ::scale_done
    catch { W "<-S>" }
} else {
    puts "== no \[S\] BengleShotSample seen -- not a Bengle (or integrated scale silent) =="
}

catch { foreach l {N M Q} { W "<-$l>" } }
close $ch
puts "== done =="
