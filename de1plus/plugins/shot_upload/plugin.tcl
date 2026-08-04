# shot_upload — uploads espresso shots to the Decent server in decaid JSON format.
#
# This slice provides the Tcl -> decaid-JSON converter (converter.tcl) and the
# plugin scaffold. The authenticated upload orchestration (OAuth2 login against
# decentespresso.com, machine-ownership verification, fire-after-shot + throttled
# sleep-state backlog drain with exponential backoff, per-.shot uploaded stamp)
# is the next slice and is intentionally NOT wired up yet, so enabling the plugin
# is currently a no-op beyond loading the converter.

set plugin_name "shot_upload"

namespace eval ::plugins::${plugin_name} {
    variable author "Decent"
    variable contact "john@decentespresso.com"
    variable version 0.1
    variable description "Upload espresso shots to the Decent server (decaid JSON)."
    variable name "Shot Upload"
}

# Load the converter procs (::plugins::shot_upload::convert, ...).
source [file join [file dirname [info script]] converter.tcl]

proc ::plugins::shot_upload::main {} {
    # No event wiring yet — see header. The converter is available for the
    # forthcoming uploader and for manual conversion/testing:
    #   ::plugins::shot_upload::convert <path-to-.shot> [dict create serialNumber $::settings(sn) ...]
    msg -INFO "shot_upload plugin loaded (converter ready; uploader not yet wired)"
}

# Convenience: build the machine-identity dict from the running app state,
# for the uploader to pass into convert. Serial comes from BLE (MMR 803830).
proc ::plugins::shot_upload::machine_identity {} {
    set d [dict create]
    if {[info exists ::settings(sn)] && $::settings(sn) ne "" && $::settings(sn) != 0} {
        dict set d serialNumber $::settings(sn)
    } elseif {[info exists ::de1(sn)] && $::de1(sn) ne ""} {
        dict set d serialNumber $::de1(sn)
    }
    if {[info exists ::de1(version)] && $::de1(version) ne ""} {
        dict set d firmwareVersion $::de1(version)
    }
    return $d
}
