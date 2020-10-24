cd "[file dirname [info script]]/"

source pkgIndex.tcl
package require de1_updater
package require de1_utils
#package require snit
package require sha256
package require crc32
package require http 2.5
package require tls 1.6
::http::register https 443 ::tls::socket

source de1_comms.tcl
source bluetooth.tcl
source utils.tcl
#source gui.tcl
source machine.tcl

set ::failed_attempt_count_connecting_to_de1 0
set ::successful_de1_connection_count 0

# bluetooth.tcl is above
##################################################

#adb pull /sdcard/de1/settings.tdb ~/Desktop/settings.tdb

# adb shell am start -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1/autopair_with_de1.tcl
# ./makede1.tcl;adb push /d/download/sync/de1/autopair_with_de1.tcl /mnt/sdcard/de1/autopair_with_de1.tcl; adb shell am start -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1/autopair_with_de1.tcl
# adb shell am start -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1/autopair_with_de1.tcl

proc msg {text} {
	puts $text
	return
}

#borg bluetooth on

set tk ""
catch {
	set tk [package present Tk]
}
if {$tk != ""} {
	button .hello -text "Finding DE1s on bluetooth\n\n(tap screen to exit)" -command { app_exit } -width 200 -height 100
	pack .hello
}

proc fill_de1_listbox {} {}
set ::de1_device_list {}
set ::settings(bluetooth_address) {}
vwait ::de1_device_list

set success 1
#set err [catch {
#	start_app_update
#	set success 1
#}]
set err 0

if {$err != 0} {
	puts $errorInfo
}

if {$tk != ""} {
	if {$success == 1} {
		.hello configure -text "Found DE1: $::de1_device_list"
		#pause 1000
		set ::settings(bluetooth_address) [lindex $::de1_device_list 0]

		.hello configure -text "Saving DE1: $::de1_device_list"
		save_array_to_file ::settings [settings_filename]
		#pause 1000
		.hello configure -text "Saved DE1!"

	} else {
		.hello configure -text "Failed.\n------------\n\nError info:\n------------\n$errorInfo" 
		pause 10000
	}
}

##
#pause 1000

app_exit
