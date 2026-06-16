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

    cd [homedir]

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


