#!/usr/bin/env tclsh
# test_safe_write.tcl — Tests for safe_write.tcl and safe_load.tcl
#
# Run from project root:
#   undroidwish-win64.exe run_tests.tcl
#
# Results written to: de1app/de1plus/tests/test_results.txt

package require tcltest 2.5
namespace import ::tcltest::*

set test_dir [file dirname [info script]]
set src_dir [file normalize [file join $test_dir ".."]]
set results_file [file join $test_dir "test_results.txt"]

# --- Redirect tcltest output to results file from the start ---
set rf [open $results_file w]
puts $rf "=== Test Results ==="
puts $rf "Source: [file join $src_dir safe_write.tcl]"
puts $rf "Source: [file join $src_dir safe_load.tcl]"
puts $rf ""
close $rf

configure -outfile $results_file
configure -verbose {pass body error skip start}

# --- Mock dependencies (must be defined before sourcing production code) ---

set ::mock_messages {}
proc msg {args} {
    lappend ::mock_messages $args
}

set ::mock_popups {}
proc popup {text} {
    lappend ::mock_popups $text
}

proc read_binary_file {path} {
    if {![file exists $path]} { return "" }
    set f [open $path rb]
    set data [read $f]
    close $f
    return $data
}

# --- Source the real production code ---
source [file join $src_dir "safe_write.tcl"]
source [file join $src_dir "safe_load.tcl"]

# --- Test helpers ---
proc write_test_file {path content} {
    set f [open $path w]
    fconfigure $f -translation {lf lf}
    puts $f $content
    close $f
}

set tmp_base [file join $test_dir "tmp_test_data"]
catch { file delete -force $tmp_base }
file mkdir $tmp_base
set ::test_num 0

proc fresh_dir {} {
    incr ::test_num
    set d [file join $::tmp_base "t$::test_num"]
    file mkdir $d
    return $d
}

# ============================================================
# write_file tests (TC-01 through TC-04, TC-10)
# ============================================================

test tc-01 {Normal write — file created with correct content, no .tmp left} -setup {
    set dir [fresh_dir]
    set target [file join $dir "data.txt"]
} -body {
    set result [write_file $target "hello world"]
    list $result \
         [string trim [read_binary_file $target]] \
         [file exists "${target}.tmp"]
} -result {1 {hello world} 0}

test tc-02 {Write to existing file creates .bak with previous content} -setup {
    set dir [fresh_dir]
    set target [file join $dir "data.txt"]
    write_test_file $target "original content"
} -body {
    set result [write_file $target "new content"]
    list $result \
         [string trim [read_binary_file $target]] \
         [file exists "${target}.bak"] \
         [string trim [read_binary_file "${target}.bak"]]
} -result {1 {new content} 1 {original content}}

test tc-03 {Multiple writes — .bak contains second-to-last content} -setup {
    set dir [fresh_dir]
    set target [file join $dir "data.txt"]
    write_test_file $target "version 1"
} -body {
    write_file $target "version 2"
    write_file $target "version 3"
    list [string trim [read_binary_file $target]] \
         [string trim [read_binary_file "${target}.bak"]]
} -result {{version 3} {version 2}}

test tc-04 {Original survives if .tmp write fails} -setup {
    set dir [fresh_dir]
    set target [file join $dir "data.txt"]
    write_test_file $target "precious data"
    file mkdir "${target}.tmp"
} -body {
    set result [write_file $target "bad write"]
    list $result [string trim [read_binary_file $target]]
} -cleanup {
    catch { file delete -force "${target}.tmp" }
} -result {0 {precious data}}

test tc-10 {Stale .tmp from previous crash overwritten on next write} -setup {
    set dir [fresh_dir]
    set target [file join $dir "data.txt"]
    write_test_file $target "existing data"
    write_test_file "${target}.tmp" "stale crash data"
} -body {
    set result [write_file $target "fresh data"]
    list $result \
         [string trim [read_binary_file $target]] \
         [file exists "${target}.tmp"]
} -result {1 {fresh data} 0}

test tc-01b {First write to non-existent file — no .bak created} -setup {
    set dir [fresh_dir]
    set target [file join $dir "data.txt"]
} -body {
    set result [write_file $target "first write"]
    list $result \
         [string trim [read_binary_file $target]] \
         [file exists "${target}.bak"]
} -result {1 {first write} 0}

# ============================================================
# load_settings_recover tests (TC-05 through TC-08)
# ============================================================

test tc-05 {Empty settings file + valid .bak triggers recovery} -setup {
    set dir [fresh_dir]
    set fn [file join $dir "settings.tdb"]
    set f [open $fn w]; close $f
    write_test_file "${fn}.bak" "language en\nskin default"
    catch { unset ::settings }
    array set ::settings {}
    set ::mock_popups {}
} -body {
    array set r [load_settings_recover $fn ""]
    list $r(corrupted) $r(recovered) \
         [info exists ::settings(language)] $::settings(language) \
         [expr {[llength $::mock_popups] > 0}]
} -result {1 1 1 en 1}

test tc-06 {Corrupt settings file + valid .bak triggers recovery} -setup {
    set dir [fresh_dir]
    set fn [file join $dir "settings.tdb"]
    write_test_file "${fn}.bak" "theme dark\nscale 1.0"
    catch { unset ::settings }
    array set ::settings {}
} -body {
    set corrupt "this is not valid tcl list \x7b"
    array set r [load_settings_recover $fn $corrupt]
    list $r(corrupted) $r(recovered) \
         [info exists ::settings(theme)] $::settings(theme)
} -result {1 1 1 dark}

test tc-07 {Both settings and backup corrupt — fresh defaults, no crash} -setup {
    set dir [fresh_dir]
    set fn [file join $dir "settings.tdb"]
    set f [open $fn w]; close $f
    set corrupt_bak "also broken \x7b"
    write_test_file "${fn}.bak" $corrupt_bak
    catch { unset ::settings }
    array set ::settings {}
} -body {
    array set r [load_settings_recover $fn ""]
    list $r(corrupted) $r(recovered) [array size ::settings]
} -result {1 0 0}

test tc-08 {Empty file + valid .bak — recovery with warning logged} -setup {
    set dir [fresh_dir]
    set fn [file join $dir "settings.tdb"]
    set f [open $fn w]; close $f
    write_test_file "${fn}.bak" "wifi_ssid MyNetwork\nbattery_limit 80"
    catch { unset ::settings }
    array set ::settings {}
    set ::mock_messages {}
} -body {
    array set r [load_settings_recover $fn ""]
    list $r(corrupted) $r(recovered) \
         [info exists ::settings(wifi_ssid)] $::settings(wifi_ssid) \
         [expr {[llength $::mock_messages] > 0}]
} -result {1 1 1 MyNetwork 1}

test tc-extra {File doesn't exist — no corruption, clean install path} -setup {
    set dir [fresh_dir]
    set fn [file join $dir "settings.tdb"]
    catch { unset ::settings }
    array set ::settings {}
} -body {
    array set r [load_settings_recover $fn ""]
    list $r(corrupted) $r(recovered) [array size ::settings]
} -result {0 0 0}

# ============================================================
# Translation defensive loading test (TC-09)
# ============================================================

test tc-09 {Corrupt translation file doesn't crash — empty translations used} -setup {
    set dir [fresh_dir]
    set corrupt "broken \x7b"
    write_test_file [file join $dir "translation.tcl"] $corrupt
    array set translation {}
    set ::mock_messages {}
} -body {
    if {[catch {array set translation [encoding convertfrom utf-8 [read_binary_file "[file join $dir translation.tcl]"]]}]} {
        msg -ERROR "translation.tcl is corrupted or unreadable — using empty translations"
        array set translation {}
    }
    list [array size translation] [expr {[llength $::mock_messages] > 0}]
} -result {0 1}

test tc-09b {Valid translation file loads correctly} -setup {
    set dir [fresh_dir]
    write_test_file [file join $dir "translation.tcl"] "hello Hola\ngoodbye Adios"
    array set translation {}
} -body {
    if {[catch {array set translation [encoding convertfrom utf-8 [read_binary_file "[file join $dir translation.tcl]"]]}]} {
        msg -ERROR "translation.tcl is corrupted or unreadable — using empty translations"
        array set translation {}
    }
    list [expr {[array size translation] > 0}] [info exists translation(hello)]
} -result {1 1}

# ============================================================
# Finalize
# ============================================================
cleanupTests

catch { file delete -force $tmp_base }
exit 0
