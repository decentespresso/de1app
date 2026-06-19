#!/usr/local/bin/tclsh
# de1app-textmode.tcl --
#
# A headless (no Tk) harness that loads the REAL de1app Bluetooth machinery
# (bluetooth.tcl, de1_comms.tcl, machine.tcl) on top of the macOS `ble` package,
# so the scan/connect path can be driven and debugged from a terminal.
#
# It is NOT the whole app: the GUI/DUI layers are replaced with text stubs, and
# `de1_device_scale` (which pulls in de1_gui -> Tk) is stubbed out.  Everything
# that touches Bluetooth is the genuine de1app code.
#
# Run interactively:   tclsh de1app-textmode.tcl
#   commands:  scan | stop | devices | connect de1|scale|<addr> | settings k v | state | quit
# Or one-shot:         tclsh de1app-textmode.tcl scan 15      (scan 15s, print, exit)

set ::DIR [file dirname [file normalize [info script]]]
cd $::DIR
lappend auto_path $::DIR [file join $::DIR ble]

# ---------------------------------------------------------------------------
# 0. text logger (so the de1app's msg/::bt::msg print to the terminal)
# ---------------------------------------------------------------------------
proc tput {args} { puts [join $args " "]; flush stdout }

# ---------------------------------------------------------------------------
# 1. Stub the GUI-heavy packages so the real BT files load without Tk.
#    Providing them up front makes `package require` skip their source files.
# ---------------------------------------------------------------------------
package provide de1_device_scale 1.5
package provide de1_gui 1.3
package provide de1_de1 1.4
package provide de1_event 1.0
package provide de1_dui 1.0
package provide de1_profile 2.0
package provide de1_shot 2.0
package provide de1_metadata 1.0

# Source the real utils.tcl for its many helper procs (ifexists, reverse_array,
# homedir, read_binary_file, ...) that machine.tcl needs at load time.  It has
# no Tk at top level.  Our GUI stubs below intentionally override any GUI procs
# it defines (translate, etc.).
if {[catch { package require de1_utils } e]} { puts "note: de1_utils unavailable ($e); using hand stubs" }

# ---------------------------------------------------------------------------
# 2. Stub the GUI / app procs the BT code calls (define BEFORE sourcing).
# ---------------------------------------------------------------------------
proc translate {s args} { return $s }
proc say {args} {}
proc info_page {args} { tput "  \[info_page\] $args" }
proc popup {args} { tput "  \[popup\] $args" }
proc show_settings {args} {}
proc make_current_listbox_item_blue {args} {}
proc fill_ble_listbox {} { textmode_show de1 }
proc fill_peripheral_listbox {} { textmode_show scale }
proc borg {args} { return "" }
proc language {args} { return "en" }
proc soundsystem_quick {args} {}
proc set_next_state {args} {}
proc android_specific_stubs {args} {}
proc fill_ble_scale_listbox {args} {}
proc page_display_change {args} {}
proc update_onscreen_variables {args} {}

# utility procs from utils.tcl that the BT code uses
proc ifexists {varname {default ""}} {
    upvar 1 $varname v
    if {[info exists v]} { return $v }
    return $default
}
proc unshift {args} {}
proc round_to_two_digits {x} { return [expr {round($x*100)/100.0}] }
proc reverse_array {arrname} {
    upvar $arrname arr
    foreach {k v} [array get arr] { set newarr($v) $k }
    return [array get newarr]
}
proc homedir {} { return $::DIR }
proc fancyclock {args} { return "" }
proc array_keys_matching {args} { return {} }
proc read_binary_file {fn} {
    if {[catch {open $fn rb} fd]} { return "" }
    fconfigure $fd -translation binary
    set d [read $fd]; close $fd; return $d
}

# event-system stubs (normally de1_event / device_scale)
namespace eval ::de1::event::apply {}
namespace eval ::device::scale::event::apply {}
proc ::de1::event::apply::on_connect_callbacks {args} {}
proc ::de1::event::apply::on_disconnect_callbacks {args} {}
namespace eval ::device::scale {}
proc ::device::scale::process_weight_update {w {t 0}} {
    set ::de1(scale_weight) $w
    puts "    >>> SCALE WEIGHT: [format %.1f $w] g"
}
proc ::device::scale::event::apply::on_connect_callbacks {args} {}
proc ::device::scale::event::apply::on_disconnect_callbacks {args} {}
namespace eval ::de1::state {}
namespace eval ::de1::state::update {}
proc ::de1::state::current_state {} { return "Sleep" }
proc ::de1::state::update::from_shotvalue {args} {}
proc de1_connect_handler {args} { tput "  \[de1_connect_handler\] $args" }
proc de1_disconnect_handler {args} { tput "  \[de1_disconnect_handler\] $args" }
proc scale_disconnect_handler {args} { tput "  \[scale_disconnect_handler\] $args" }
proc de1_send_steam_hotwater_settings {args} {}

# ---------------------------------------------------------------------------
# 3. Globals + defaulting traces so unset ::settings/::de1 keys read as "".
# ---------------------------------------------------------------------------
array set ::settings {}
array set ::de1 {}
proc _default_empty {arr n1 n2 op} {
    upvar #0 $arr a
    if {$n2 ne "" && ![info exists a($n2)]} { set a($n2) "" }
}
trace add variable ::settings read [list _default_empty ::settings]
trace add variable ::de1      read [list _default_empty ::de1]

set ::android 0
set ::undroid 1
set ::some_droid 1
set ::has_bluetooth 1     ;# harness simulates an osx-undroid build WITH the ble package
set ::env(BLE_NO_NATIVE) 1 ;# osx undroidwish uses the subprocess helper, not the in-process extension
set ::scanning 0
set ::ble_scanner ""
set ::currently_connecting_de1_handle 0
set ::currently_connecting_scale_handle 0
set ::de1_device_list {}
set ::peripheral_device_list {}
set ::ble_listbox_widget ""
set ::ble_scale_listbox_widget ""

# A couple of settings the scan path reads:
set ::settings(bluetooth_address) ""
set ::settings(scale_bluetooth_address) ""
set ::settings(scale_type) "atomaxskale"
set ::settings(ble_debug) 1

# ---------------------------------------------------------------------------
# 4. Load the REAL Bluetooth code + the ble package.
# ---------------------------------------------------------------------------
set ::loaderr ""
if {[catch {
    package require de1_logging
    package require de1_binary
    package require de1_machine     ;# pulls de1_comms -> de1_bluetooth (real)
} eo]} {
    set ::loaderr $eo
    puts "LOAD ERROR: $eo\n$::errorInfo"
}

if {[catch { package require ble } eo]} {
    puts "ble package load error: $eo"
} else {
    puts "ble package: loaded (state [ble state])"
}

# Re-assert flags machine.tcl/others may have changed.
set ::android 0
set ::ble_scanner ""

# ---------------------------------------------------------------------------
# 5. Text display of discovered devices.
# ---------------------------------------------------------------------------
proc textmode_show {which} {
    if {$which eq "de1"} {
        puts "  --- DE1 devices (::de1_device_list) ---"
        foreach d $::de1_device_list {
            puts "    DE1   [dict get $d name]  [dict get $d address]"
        }
    } else {
        puts "  --- peripherals/scales (::peripheral_device_list) ---"
        foreach d $::peripheral_device_list {
            puts "    SCALE [dict get $d name]  [dict get $d address]  ([dict get $d devicefamily])"
        }
    }
    flush stdout
}

# ---------------------------------------------------------------------------
# 6. Command interface
# ---------------------------------------------------------------------------
proc cmd_scan {} {
    if {[llength [info commands ble]] == 0} { puts "NO ble command"; return }
    puts ">>> scanning_restart (android=$::android, ble cmd present=[expr {[llength [info commands ble]]>0}])"
    scanning_restart
}
proc cmd_devices {} { textmode_show de1; textmode_show scale }
proc cmd_stop {} { catch { stop_scanner }; catch { ble stop $::ble_scanner }; set ::scanning 0; puts "stopped" }
proc cmd_connect {what} {
    switch -- $what {
        de1   { set ::settings(bluetooth_address) [pick_addr de1];   ble_connect_to_de1 }
        scale { set ::settings(scale_bluetooth_address) [pick_addr scale]; ble_connect_to_scale }
        default {
            set ::settings(bluetooth_address) $what
            ble_connect_to_de1
        }
    }
}
proc pick_addr {which} {
    if {$which eq "de1"} {
        if {[llength $::de1_device_list]} { return [dict get [lindex $::de1_device_list 0] address] }
    } else {
        if {[llength $::peripheral_device_list]} { return [dict get [lindex $::peripheral_device_list 0] address] }
    }
    return ""
}

proc on_stdin {} {
    if {[gets stdin line] < 0} {
        if {[eof stdin]} { puts "(eof)"; exit 0 }
        return
    }
    set line [string trim $line]
    if {$line eq ""} { prompt; return }
    set cmd [lindex $line 0]
    switch -- $cmd {
        scan     { cmd_scan }
        stop     { cmd_stop }
        devices  { cmd_devices }
        connect  { cmd_connect [lindex $line 1] }
        state    { puts "ble state: [ble state]   scanning=$::scanning   ble_scanner=$::ble_scanner" }
        settings { set ::settings([lindex $line 1]) [lindex $line 2]; puts "set settings([lindex $line 1])=[lindex $line 2]" }
        info     { puts "ble info: [ble info]" }
        eval     { if {[catch {uplevel #0 [lrange $line 1 end]} r]} { puts "ERR: $r" } else { puts "= $r" } }
        quit     { puts "bye"; exit 0 }
        default  { puts "commands: scan | stop | devices | connect de1|scale|<addr> | state | settings k v | eval <tcl> | info | quit" }
    }
    prompt
}
proc prompt {} { puts -nonewline "de1> "; flush stdout }

# ---------------------------------------------------------------------------
# 7. Run: one-shot (argv) or interactive REPL
# ---------------------------------------------------------------------------
proc errfile {m} { catch { set f [open /tmp/de1_scan_err.txt a]; puts $f $m; close $f } }
if {[llength $argv] >= 1 && [lindex $argv 0] eq "scan"} {
    set secs [expr {[llength $argv] >= 2 ? [lindex $argv 1] : 15}]
    if {[catch {cmd_scan} e]} { errfile "cmd_scan ERROR: $e\n$::errorInfo" } else { errfile "cmd_scan returned OK" }
    after [expr {$secs * 1000}] {
        puts "\n=== devices after ${::secs_done}s ==="
        cmd_devices
        exit 0
    }
    set ::secs_done $secs
    vwait forever
} else {
    puts "de1app-textmode ready. Type 'scan' then 'devices'. 'quit' to exit."
    prompt
    fileevent stdin readable on_stdin
    vwait forever
}
