#!/usr/local/bin/tclsh

package require msgcat 
package require img::jpeg
package require snit
package require sha256
#package require md5
package require crc32
catch {
    # john 6/17/2024 not sure why this is even included, as it's not used by any code I can find.
    package require BWidget
}


package require http 2.5
package require tls 1.6



package provide de1 1.0
package provide de1_main 1.0
package require de1_logging 1.0
package require de1_updater
package require de1_gui 
package require de1_vars 
package require de1_binary
package require de1_utils 
package require de1_machine
package require math::statistics
package require http 2.5

##############################

proc de1_ui_startup {} {

    # On iOS the code lives in the read-only app bundle (cwd is already there,
    # set by de1app.tcl) and all data is addressed by absolute [homedir] paths
    # (~/Documents/Decent). Do NOT cd to [homedir] there: it would move cwd off
    # the bundle and break setup_environment's relative `source bluetooth.tcl` /
    # `source app_metadata.tcl` -> white screen on launch.
    if {[ifexists ::ios] != 1} {
        cd [homedir]
    }

	http::register https 443 [list ::tls::socket -require true -cafile [homedir]/allcerts.pem]

    msg -INFO "Tcl version $::tcl_patchLevel"
    # There are multiple reports of AndroWish 2020-11-05 causing crashes in early 2021
    if { $::tcl_patchLevel == "8.6.10" } {
	#msg -WARNING "AndroWish 2020-11-05 is not recommended at this time. 2019-06-22 (8.6.9) is preferred."
    }

    return [ui_startup]
}


# ---------------------------------------------------------------------------
# Headless Bluetooth self-test:   wish de1plus.tcl --ble-test
#
# Powers up Bluetooth, runs a real BLE scan (the same `ble` command the app
# uses), logs everything it finds to log.txt, waits 10 seconds and exits
# cleanly -- WITHOUT bringing up the GUI.  Used to debug whether a given build
# actually has a working CoreBluetooth stack.  All output is tagged "BLETEST".
# Invoked from de1app.tcl in place of de1_ui_startup when --ble-test is passed.
# ---------------------------------------------------------------------------
proc ble_headless_test {} {

	proc ::_blt {m} {
		catch { msg -INFO "BLETEST $m" }
		catch { puts stderr "BLETEST $m" ; flush stderr }
	}

	::_blt "==================== headless BLE test start ===================="
	::_blt "tcl=$::tcl_patchLevel  platform=$::tcl_platform(os)/$::tcl_platform(machine)"
	::_blt "android=[ifexists ::android] undroid=[ifexists ::undroid] has_bluetooth=[ifexists ::has_bluetooth]"
	::_blt "ble command present=[expr {[llength [info commands ble]] > 0}]"

	# Did the REAL ble package load, or is the no-op stub (`ble {args} {return 1}`) active?
	if {[info exists ::bleosx::backend]} {
		::_blt "real ble package loaded; backend=[set ::bleosx::backend]"
	} else {
		::_blt "WARNING: ::bleosx::backend unset -> real ble package did NOT load; the no-op stub is active (scan will find nothing)"
	}
	if {[info exists ::env(BLE_NO_NATIVE)]} { ::_blt "BLE_NO_NATIVE=$::env(BLE_NO_NATIVE)" }

	if {[info exists ::bleosx::helper]} {
		set h $::bleosx::helper
		::_blt "helper=$h  exists=[file exists $h]  executable=[file executable $h]"
		catch { ::_blt "helper codesign: [exec codesign -dvv $h 2>@1]" }
	}

	catch { ::_blt "ble state (initial) = [ble state]" }

	set ::_blt_found [list]
	proc ::_blt_cb {event data} {
		if {$event ne "scan"} {
			::_blt "event=$event $data"
			return
		}
		array set d $data
		set ad [ifexists d(address)]
		if {$ad ne "" && [lsearch -exact $::_blt_found $ad] < 0} {
			lappend ::_blt_found $ad
			::_blt "FOUND #[llength $::_blt_found]  name='[ifexists d(name)]'  address=$ad  rssi=[ifexists d(rssi)]"
		}
	}

	set tok ""
	if {[catch { set tok [ble scanner ::_blt_cb] ; ble start $tok } err]} {
		::_blt "ERROR starting scan: $err"
	} else {
		::_blt "scan started (token=$tok); scanning for 10s ..."
	}

	set ::_blt_done 0
	after 10000 { set ::_blt_done 1 }
	vwait ::_blt_done

	catch { ble stop $tok }
	catch { ::_blt "ble state (final) = [ble state]" }
	::_blt "scan complete: [llength $::_blt_found] device(s) found"
	::_blt "==================== headless BLE test end ===================="

	catch { ::logging::flush_log }
	catch { ble close $tok }
	after 200
	exit 0
}


# ---------------------------------------------------------------------------
# GUI Bluetooth search-and-exit:   wish de1plus.tcl --ble-search-and-exit
#
# Brings up the normal GUI (so macOS can present the Bluetooth permission
# prompt -- unlike the headless --ble-test), then runs the SAME action as the
# in-app BLE SEARCH button (scanning_restart), lets it scan for the usual
# window, logs what it found, and exits cleanly.  Scheduled from de1app.tcl
# alongside de1_ui_startup.  All output is tagged "BLESEARCH".
# ---------------------------------------------------------------------------
proc ::_bls {m} {
	catch { msg -NOTICE "BLESEARCH $m" }
	catch { puts stderr "BLESEARCH $m" ; flush stderr }
}

proc ble_search_and_exit {} {
	if {![llength [info commands ble]]} {
		::_bls "no ble command available; exiting"
		after 200 { exit 1 }
		return
	}
	# Wait (up to ~10s) for Bluetooth to power on before searching.
	set st ""
	catch { set st [ble state] }
	if {$st ne "poweredOn" && [incr ::_bls_tries] <= 20} {
		after 500 ble_search_and_exit
		return
	}
	::_bls "ble state=$st; running scanning_restart (same as the in-app SEARCH button)"
	catch { scanning_restart }
	# The SEARCH button scans for ~10s (after 10000 stop_scanner). Give it a
	# little longer, then report and exit -- we can't just wait for ::scanning
	# to clear because stop_scanner defers forever when no DE1 is connected.
	after 12000 ble_search_finish
}

proc ble_search_finish {} {
	catch { set ::scanning 0 }
	catch { ble stop $::ble_scanner }
	set des  [ifexists ::de1_device_list]
	set peris [ifexists ::peripheral_device_list]
	::_bls "search complete: [llength $des] device(s), [llength $peris] peripheral(s) found"
	foreach d $des   { catch { ::_bls "  device:     '[dict get $d name]'  [dict get $d address]" } }
	foreach p $peris { catch { ::_bls "  peripheral: '[dict get $p name]'  [dict get $p address]" } }
	catch { ::logging::flush_log }
	after 500 { exit 0 }
}

# Simulation screenshot harness:  undroidwish de1plus.tcl --sim-screenshot
# Runs the full GUI, forces simulation mode (clears the DE1 bluetooth_address so
# espresso_simulation_active is true), taps START to play back a random
# simulations/ shot, waits ~3s, snapshots every blt::graph to PNG, logs vector
# lengths (to tell "no data appended" apart from "data but no redraw"), exits.
proc sim_screenshot_start {} {
	# force simulation: no real DE1 configured
	set ::settings(bluetooth_address) ""
	msg -INFO "SIMSHOT: starting simulated espresso"
	catch { start_espresso } err
	if {$err ne ""} { msg -INFO "SIMSHOT: start_espresso err: $err" }
	# force-show the espresso page so its live graph widget is built and visible
	after 800 { catch { page_display_change $::de1(current_context) "espresso" } }
	after 3000 sim_screenshot_capture
}

proc sim_screenshot_find_graphs {w listvar} {
	upvar $listvar L
	if {![catch {winfo class $w} cls] && ($cls eq "Graph" || $cls eq "Stripchart")} {
		lappend L $w
	}
	foreach c [winfo children $w] { sim_screenshot_find_graphs $c L }
}

proc sim_screenshot_capture {} {
	catch { msg -INFO "SIMSHOT: state=$::de1(state) substate=$::de1(substate) simindex=[ifexists ::simindex]" }
	catch { msg -INFO "SIMSHOT: vectors  espresso_elapsed=[espresso_elapsed length]  espresso_pressure=[espresso_pressure length]  espresso_flow=[espresso_flow length]" }
	set graphs {}
	sim_screenshot_find_graphs . graphs
	msg -INFO "SIMSHOT: found [llength $graphs] graph widget(s)"
	catch { msg -INFO "SIMSHOT: streamline_chart=[ifexists ::streamline_chart] mapped=[catch {winfo ismapped $::streamline_chart}]" }
	set i 0
	foreach g $graphs {
		incr i
		set els [$g element names]
		# is this a LIVE espresso graph? (has line_espresso_pressure)
		set live [expr {[lsearch -glob $els line_espresso_pressure*] >= 0}]
		set plen "-"
		if {$live} { catch { set plen [llength [$g element cget line_espresso_pressure -ydata]] } }
		set photo "simshot_photo_$i"
		catch { image delete $photo }
		if {[catch { image create photo $photo } e1]} { msg -INFO "SIMSHOT: photo create failed $g: $e1"; continue }
		if {[catch { $g snap $photo } e2]} { msg -INFO "SIMSHOT: snap failed $g: $e2"; continue }
		set dst "/tmp/sim_graph_$i.png"
		catch { $photo write $dst -format png }
		if {$live} { catch { $photo write "[file normalize ~]/Desktop/LIVE_espresso_graph.png" -format png } }
		msg -INFO "SIMSHOT: snapped $g -> $dst  ([llength $els] elements) LIVE=$live line_espresso_pressure_ydata_len=$plen"
	}
	catch { ::logging::flush_log }
	after 800 { exit 0 }
}



