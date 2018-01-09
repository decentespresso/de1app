#!/usr/local/bin/tclsh

package require msgcat 
package require img::jpeg
package require snit
package require sha256
#package require md5
package require crc32
package require BWidget

package provide de1 1.0
package provide de1_main 1.0
package require de1_gui 
package require de1_vars 
package require de1_binary
package require de1_utils 
package require de1_machine
package require http 2.5


##############################

proc de1_ui_startup {} {
	cd [homedir]
	return [ui_startup]
}


