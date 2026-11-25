# Self-check for the DPx_Screen_Saver folder import. Run: tclsh tests/dpx_screen_saver_import.tcl
set plugin [file normalize [file join [file dirname [info script]] .. de1plus plugins DPx_Screen_Saver plugin.tcl]]
set tmp [file join /tmp dpx_ss_test_[pid]]; file mkdir $tmp/src/sub $tmp/data; cd $tmp
foreach f {a.jpg B.JPEG c.png} { close [open src/$f w] }
set ::screen_size_width 1280; set ::screen_size_height 800; set ::android 0
set ::settings(screen_saver_change_interval) 10
set ::env(HOME) [pwd]
proc data_directory {} { return [pwd]/data }
proc translate {s} { return $s }
proc popup {s} { set ::last_popup $s }
proc borg {args} {}
proc msg {args} { puts $args }
proc ifexists {v {d ""}} { if {[info exists $v]} { return [set $v] }; return $d }
source $plugin
set ns ::plugins::DPx_Screen_Saver
proc check {c m} { if {![uplevel 1 [list expr $c]]} { error "FAIL: $m" } }
check {[${ns}::active_root] eq ""} "no root initially"
${ns}::browse_to [pwd]/src
check {[set ${ns}::browse_display] eq {sub/}} "lists subdirs"
${ns}::use_browse_dir
set got [lsort [glob -tails -directory data/MySaver_imported/1280x800 *]]
check {$got eq {B.jpg a.jpg}} "copied jpg+jpeg as .jpg: $got"
check {$::saver_directory eq "[pwd]/data/MySaver_imported"} "saver dir applied"
${ns}::browse_to [pwd]/src/sub
${ns}::use_browse_dir
check {$::last_popup eq "No .jpg images in this folder"} "empty folder rejected"
check {[llength [glob -directory data/MySaver_imported/1280x800 *]] == 2} "empty pick keeps old set"
puts "OK: [${ns}::message]"
file delete -force $tmp
