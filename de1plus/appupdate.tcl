#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"
source "pkgIndex.tcl"
package require de1_updater

# do an app update on the de1plus code base, if this is a de1plus machine
if {[file exists "de1plus.tcl"] == 1} {
	package provide de1plus 1.0
}

determine_if_android

#source pkgIndex.tcl
#package require de1_utils
#package require snit
package require sha256
package require crc32
package require http 2.5
package require tls 1.6
::http::register https 443 ::tls::socket
set ::settings(logfile) "updatelog.txt"

# always log app updates
set ::settings(log_enabled) 1

# if using this tool, always update to the latest release version, never to a beta version
set ::settings(app_updates_beta_enabled) 0

set debugcnt 0

proc translate {x} {return $x}

set tk ""
catch {
	set tk [package present Tk]
}
if {$tk != ""} {
	button .hello -text "Update Decent App" -command { 
		catch { .hello configure -text "Working" }
		catch { pack forget .frame; }
		start_app_update; 
		after 3000 exit;
	} -height 10 -width 40
	frame .frame -border 2
	button .frame.redownloadapp -text " Redownload entire app " -command { 
		catch { .hello configure -text "Working" }
		catch { file delete "manifest.txt"; }
		catch { file delete "timestamp.txt"; }
		catch { pack forget .frame; }
		catch { start_app_update;} 
		exit 
	} 
	button .frame.exitapp -text " --- Exit --- " -command { exit } 
	button .frame.resetapp -text " Reset settings " -command { 
		catch { file delete "settings.tdb"; } ; 
		exit 
	} 
	button .frame.iconcreate -text " Create icon " -command { 

		catch {
			source "pkgIndex.tcl"
			catch {
			        # john 4-11-20 Android 10 is failing on this script, if we don't include these two dependencies
			        package require snit
			        package require de1_updater
			}

			package require de1_main
			package require de1_gui
			cd "[file dirname [info script]]"

			install_de1plus_app_icon
			after 1000 exit
		}
	} 
	button .frame.resetskin -text " Reset skin " -command { 
		catch { } ; 
		reset_skin
		exit 
	} 
	
	pack .hello  -pady 10 -padx 10
	pack .frame -side bottom -pady 0 -padx 0

	pack .frame.resetapp -side left -pady 10 -padx 10
	pack .frame.iconcreate -side left -pady 10 -padx 10
	pack .frame.resetskin -side left -pady 10 -padx 10
	
	# john 13-11-19 taking away this button as many users click it and it causes huge downloads.
	# better to ask them to redownload the entire app from our web site https://decentespresso.com/downloads
	#pack .frame.redownloadapp -side right -pady 10 -padx 10
	pack .frame.exitapp -side right -pady 10 -padx 10
	
	.hello configure -text "[ifexists ::de1(app_update_button_label)] Update app"

}

