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



#file link "/d/admin/code/de1beta/desktop_app/linux" "/d/admin/code/de1beta/desktop_app/decent"
#file link "/d/admin/code/de1beta/desktop_app/linux" "/d/admin/code/de1beta/desktop_app/decent"
catch { file link  "/d/admin/code/de1beta/desktop_app/linux/src" "/d/download/sync/de1beta" }
catch { file link  "/d/admin/code/de1beta/desktop_app/osx/Decent.app/Contents/Resources/de1plus" "/d/download/sync/de1beta" }
catch { file link  "/d/admin/code/de1beta/desktop_app/win32/src" "/d/download/sync/de1beta" }

if {$argv != ""} {
	puts "Updating apps"

	# optionally purge the source directories and resync
	# do this if we remove files from the sync list
	file delete -force /d/download/sync/de1beta
	file delete -force /d/download/sync/decent
	file mkdir /d/download/sync/de1beta
	file link /d/download/sync/decent /d/download/sync/de1beta
	#file delete -force /d/download/sync/de1
	file delete -force /d/download/desktop/osx/decent_osx.zip
	file delete -force /d/download/desktop/win32/decent_win.zip
	file delete -force /d/download/desktop/linux/decent_linux.zip
	file delete -force /d/download/desktop/source/decent_source.zip

	#skin_convert_all
	make_de1_dir


	cd "[homedir]/desktop_app/osx"
	exec zip -u -x "*CVS*" -x ".DS_Store" -r /d/download/desktop/osx/decent_osx.zip Decent.app 

	cd "[homedir]/desktop_app/win32"
	exec zip -u -x "*CVS*" -x ".DS_Store" -r /d/download/desktop/win32/decent_win.zip ./

	cd "[homedir]/desktop_app/linux"
	file attributes "undroidwish/undroidwish-linux32" -permission 0755
	file attributes "undroidwish/undroidwish-linux64" -permission 0755
	file attributes "undroidwish/undroidwish-raspberry" -permission 0755
	file attributes "undroidwish/undroidwish-wayland64" -permission 0755

	cd ..
	file delete -force "[homedir]/desktop_app/decent"
	file link "[homedir]/desktop_app/decent" "[homedir]/desktop_app/linux"
	exec zip -u -x "*CVS*" -x ".DS_Store" -r /d/download/desktop/linux/decent_linux.zip decent

	cd "/d/download/sync"
	exec zip -x "*CVS*" -x ".DS_Store" -r /d/download/desktop/source/decent_source.zip de1beta

} else {
	#skin_convert_all
	make_de1_dir

}

file delete /d/admin/code/de1beta/desktop_app/linux/src
file delete /d/admin/code/de1beta/desktop_app/osx/Decent.app/Contents/Resources/de1plus
file delete /d/admin/code/de1beta/desktop_app/win32/src

puts "done"



