# macOS-only: AndroWish-compatible `ble` command via CoreBluetooth (no-op on
# platforms that ship a native `ble`, since determine_if_android requires it
# inside a catch).  Lets `package require ble` succeed on the Mac.
#
# The driver lives in the local `ble/` subdirectory (a git submodule of the
# tcl-ble-osx repo).  We add it to auto_path so Tcl can load it from that subdir
# -- but determine_if_android (updater.tcl) sources the bundled ble.tcl
# DIRECTLY on macOS so the local copy always wins over any system-wide install
# (e.g. a /usr/local/lib/tcl-ble-osx symlink on auto_path).
# NOT on iWish (Catalyst): it ships its own libble1.0.dylib (registered as
# `ble 1.0` in lib-batteries/ble1.0); registering ble.tcl here would otherwise
# override it with the x86_64/subprocess macOS package, which can't work on iOS.
if {!([info exists ::iwish] && $::iwish)} {
    lappend ::auto_path [file normalize [file join [file dirname [info script]] ble]]
}
package ifneeded de1_vars 1.2 [list source [file join "./" vars.tcl]]
package ifneeded de1_binary 1.1 [list source [file join "./" binary.tcl]]
package ifneeded de1_bluetooth 1.1 [list source [file join "./" bluetooth.tcl]]
package ifneeded de1_comms 1.1 [list source [file join "./" de1_comms.tcl]]
package ifneeded de1_plugins 1.0 [list source [file join "./" plugins.tcl]]
package ifneeded de1_gui 1.3 [list source [file join "./" gui.tcl]]
package ifneeded de1_utils 1.1 [list source [file join "./" utils.tcl]]
package ifneeded de1_main 1.0 [list source [file join "./" main.tcl]]
package ifneeded de1_machine 1.2 [list source [file join "./" machine.tcl]]
package ifneeded de1_dui 1.0 [list source [file join "./" dui.tcl]]
package ifneeded de1_misc 1.0 [list source [file join "./" misc.tcl]]
package ifneeded de1_updater 1.1 [list source [file join "./" updater.tcl]]
package ifneeded de1_event 1.0 [list source [file join "./" event.tcl]]
package ifneeded de1_logging 1.2 [list source [file join "./" logging.tcl]]
package ifneeded de1_profile 2.0 [list source [file join "./" profile.tcl]]
package ifneeded de1_shot 2.0 [list source [file join "./" shot.tcl]]
package ifneeded de1_de1 1.4 [list source [file join "./" de1_de1.tcl]]
package ifneeded de1_device_scale 1.5 [list source [file join "./" device_scale.tcl]]

package ifneeded de1_history_viewer 1.1 [list source [file join "./" history_viewer.tcl]]
package ifneeded de1_metadata 1.0 [list source [file join "./" metadata.tcl]]
package ifneeded de1_profiler 1.0 [list source [file join "./" profiler.tcl]]
