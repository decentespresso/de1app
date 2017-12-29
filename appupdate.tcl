#!/usr/local/bin/tclsh

source pkgIndex.tcl
package require de1_utils
package require de1_vars
package require de1_misc
package require snit
package require de1_gui
package provide de1plus 1.0
package require sha256
package require crc32
package require http 2.5

start_app_update