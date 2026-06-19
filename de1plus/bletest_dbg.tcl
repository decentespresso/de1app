puts "START"; flush stdout
set rc [catch {package require ble} err]
puts "pkg rc=$rc err=$err"; flush stdout
puts "backend=[expr {[info exists ::bleosx::backend] ? $::bleosx::backend : {NONE}}]"; flush stdout
exit 0
