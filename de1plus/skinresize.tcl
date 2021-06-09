#!/usr/local/bin/tclsh

namespace eval ::logging { variable disable_logging_for_build True }

cd "[file dirname [info script]]/"

source pkgIndex.tcl
package require de1_updater
package require de1_utils
package require de1_vars
package provide de1plus 1.0

skin_convert_all
exit
