package require tcltest
namespace import ::tcltest::*

package provide de1_logging 1.1

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

test decentscale-off-does-not-override-core-1 {} -body {
	if {[info commands ::plugins::decentscale_off::main] ne ""} {
		::plugins::decentscale_off::main
	}
	scale_disable_lcd
} -result core

test decentscale-off-is-hidden-1 {} -body {
	expr {[lsearch -exact [plugins list] decentscale_off] < 0}
} -result 1

test decentscale-off-stale-enabled-entry-1 {} -body {
	set ::settings(enabled_plugins) {decentscale_off}
	plugins load decentscale_off
	plugins loaded decentscale_off
} -result 0

cleanupTests
