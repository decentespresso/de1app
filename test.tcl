#!/usr/local/bin/tclsh

cd [file dirname [info script]]
set f [open log.txt w]
fconfigure $f -blocking 0
fconfigure $f -buffersize 10000

for {set x 0} {$x < 100000000} {incr x} {
	puts $f "$x"
	if {[expr {$x % 100000}] == 0} {
		puts "Wrote $x lines"
		update
	}
}
close $f
puts "done."