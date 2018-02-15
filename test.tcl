#!/usr/local/bin/tclsh

source pkgIndex.tcl
package require de1_updater
package require de1_utils
package require de1_vars
package provide de1plus 1.0
package require de1_binary 

proc obs_convert_string_to_hex {chrs} {
    
    set toreturn {}
    foreach {a b} [split [binary encode hex $chrs] {}] {
    	append toreturn "$a$b "
    }
    return [string toupper [string trim $toreturn]]
}

set s "\x01\x00\x00\x00\x03\x00\x00\x00\xAC\x1B\x1E\x09\x01"
puts "'[convert_string_to_hex $s]'"

parse_binary_version_desc $s arr
puts [array get arr]

#puts "BLESha: [format %X $arr(BLESha)]"