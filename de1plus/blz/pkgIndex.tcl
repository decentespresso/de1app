# Tcl package index for blz_ble_shim (dev tree).
# Put this directory on auto_path (or its parent) then:
#   package require blz_ble_shim   ;# AndroWish `ble` on undroidwish's `blz`
#   package require blz_sim        ;# optional simulated blz + virtual devices
package ifneeded blz_ble_shim 1.0 [list source [file join $dir blz_ble_shim.tcl]]
package ifneeded blz_sim      1.0 [list source [file join $dir blz_sim.tcl]]
