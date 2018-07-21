#!/usr/local/bin/tclsh

source pkgIndex.tcl
package require de1_updater
package require de1_utils
package require de1_vars
package require de1_misc
package provide de1plus 1.0
#package require md5
package require sha256
package require crc32
package require snit
package require de1_gui 




if {$argv != ""} {
	puts "Updating apps"

	# optionally purge the source directories and resync
	# do this if we remove files from the sync list
	file delete -force /d/download/sync/de1plus
	file delete -force /d/download/sync/de1
	file delete -force /d/download/desktop/osx/de1plus_osx.zip
	file delete -force /d/download/desktop/win32/de1plus_win.zip
	file delete -force /d/download/desktop/linux/de1plus_linux.zip
	file delete -force /d/download/desktop/source/de1plus_source.zip

	#skin_convert_all
	make_de1_dir


	cd "[homedir]/desktop_app/osx"
	exec zip -u -x "*CVS*" -x ".DS_Store" -r /d/download/desktop/osx/de1plus_osx.zip DE1+.app 
	#exec zip -u -x "*CVS*" -x ".DS_Store" -r /d/download/desktop/osx/de1_osx.zip DE1.app

	cd "[homedir]/desktop_app/win32"
	exec zip -u -x "*CVS*" -x ".DS_Store" -r /d/download/desktop/win32/de1plus_win.zip ./

	cd "[homedir]/desktop_app/linux"
	exec zip -u -x "*CVS*" -x ".DS_Store" -r /d/download/desktop/linux/de1plus_linux.zip ./

	cd "/d/download/sync"
	exec zip -u -x "*CVS*" -x ".DS_Store" -r /d/download/desktop/source/de1plus_source.zip de1plus
	#exec zip -u -x "*CVS*" -x ".DS_Store" -r /d/download/desktop/source/de1_source.zip de1
} else {
	#skin_convert_all
	make_de1_dir

}

puts "done"