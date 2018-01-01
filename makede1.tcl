#!/usr/local/bin/tclsh

source pkgIndex.tcl
package require de1_utils
package require de1_vars
package require de1_misc
package provide de1plus 1.0
#package require md5
package require sha256
package require crc32
package require snit
package require de1_gui 

skin_convert_all
make_de1_dir

cd "[homedir]/desktop_app/osx"
exec zip -u -r /d/download/desktop/osx/DE1PLUS.zip .
