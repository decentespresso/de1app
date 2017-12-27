#!/usr/local/bin/tclsh

source pkgIndex.tcl
package require de1_utils
package require de1_vars
package require de1_misc
package provide de1plus 1.0
package require crc32

skin_convert_all
make_de1_dir