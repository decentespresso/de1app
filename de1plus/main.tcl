#!/usr/local/bin/tclsh

package require msgcat 
package require img::jpeg
package require snit
package require sha256
#package require md5
package require crc32
package require BWidget

package require http 2.5
package require tls 1.6



package provide de1 1.0
package provide de1_main 1.0
package require de1_logging 1.0
package require de1_updater
package require de1_gui 
package require de1_vars 
package require de1_binary
package require de1_utils 
package require de1_machine
package require math::statistics
package require http 2.5

##############################

proc de1_ui_startup {} {

    cd [homedir]

	http::register https 443 [list ::tls::socket -require true -cafile [homedir]/allcerts.pem]

    msg -INFO "Tcl version $::tcl_patchLevel"
    # There are multiple reports of AndroWish 2020-11-05 causing crashes in early 2021
    if { $::tcl_patchLevel == "8.6.10" } {
	msg -WARNING "AndroWish 2020-11-05 is not recommended at this time. 2019-06-22 (8.6.9) is preferred."
    }

    return [ui_startup]
}


