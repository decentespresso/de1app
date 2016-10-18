

proc load_android_wifi_settings {} {
	borg toast "Tap the \u25C0BACK\u25B6 BUTTON to return to\nDecent Espresso." 1
	after 500 { borg activity android.settings.WIFI_SETTINGS {} {} {} {} {} }
}



proc timer_test {} {
	global last_timer_test
	if {[info exists last_timer_test] != 1} {
		set last_timer_test [clock milliseconds]
		after 1000 timer_test
		return
	}

	set newtimer [clock milliseconds]
	set time_diff [expr {$newtimer - $last_timer_test - 1000}]

	if {$time_diff > 100} {
		msg "XXXX Delay on background timer test: ${time_diff}ms"
	}

	after $::settings(timer_interval) timer_test
	set last_timer_test $newtimer
}
