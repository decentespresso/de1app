package require tcltest
namespace import ::tcltest::*

package provide de1_logging 1.1
package provide de1_metadata 1.0
package provide struct::set 1.0

set test_root [file normalize [file join [file dirname [info script]] .. de1plus]]

proc msg {args} {}
proc homedir {} {
	return $::test_root
}
proc scale_disable_lcd {} {
	return core
}

source [file join [file dirname [info script]] .. de1plus plugins.tcl]
source [file join [file dirname [info script]] .. de1plus plugins decentscale_off plugin.tcl]
source [file join [file dirname [info script]] .. de1plus utils.tcl]

test decentscale-off-does-not-override-core-1 {} -body {
	if {[info commands ::plugins::decentscale_off::main] ne ""} {
		::plugins::decentscale_off::main
	}
	scale_disable_lcd
} -result core

test decentscale-off-is-hidden-1 {} -body {
	expr {[lsearch -exact [plugins list] decentscale_off] < 0}
} -result 1

test decentscale-off-stale-enabled-entry-is-migrated-1 {} -body {
	set ::settings(enabled_plugins) {visualizer_upload decentscale_off}
	set migrated [remove_retired_plugins_from_settings]
	set unchanged [remove_retired_plugins_from_settings]
	list $migrated $unchanged [plugins enabled decentscale_off] $::settings(enabled_plugins)
} -result {1 0 false visualizer_upload}

cleanupTests
