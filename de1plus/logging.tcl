package provide de1_logging 1.2

package require lambda

# Originally in gui.tcl
proc msg {args} {

	::logging::default_logger {*}$args
}

# TODO: Persist and restore the "settings"

namespace eval ::logging {

	variable severity_limit_logfile 7
	variable severity_limit_console 7

	# NB: Android default limit is Info. See commit message or
	#     https://developer.android.com/studio/command-line/logcat

	variable severity_limit_android 7

	variable android_logger_tag DE1

	variable severity_default 6

	variable severity_option_to_number
	array set severity_option_to_number {
		-EMERG	  0
		-ALERT	  1
		-CRIT     2
		-CRITICAL 2
		-ERR	  3
		-ERROR	  3
		-WARNING  4
		-WARN	  4
		-NOTICE	  5
		-INFO	  6
		-DEBUG	  7
	}
	variable severity_to_string
	array set severity_to_string {
		0 EMERG
		1 ALERT
		2 CRITICAL
		3 ERROR
		4 WARNING
		5 NOTICE
		6 INFO
		7 DEBUG
	}
	variable severity_max [tcl::mathfunc::max {*}[array names severity_to_string]]


	# See https://www.androwish.org/home/wiki?name=Android+facilities
	#     https://developer.android.com/reference/android/util/Log
	#     The Android "verbose" level is not used at this time

	variable severity_to_borg_log_priority
	array set severity_to_borg_log_priority {
		0 fatal
		1 fatal
		2 error
		3 error
		4 warn
		5 info
		6 info
		7 debug
	}

	variable _log_fh ""

	# To disable logging, set to Boolean True externally,
	# prior to any `package require` of de1app code
	#   namespace eval ::logging { variable disable_logging_for_build True }

	variable disable_logging_for_build

	proc safe_get {var_name} {

		upvar $var_name var

		if {[info exists var]} {
			return $var
		} else {
			return ""
		}
	}

	proc default_logger {args} {

		set now [clock milliseconds]
		set secs [expr $now / 1000]
		set msecs [expr $now % 1000]

		if { [llength $args] == 0 } { set args { -NOTICE (no arguments passed to log_to_debug_file) } }

		set first_arg [lindex $args 0]

		if { [string index $first_arg 0] == {-} } {
			set sevkey [string toupper $first_arg]
			if { [info exists ::logging::severity_option_to_number($sevkey)] } {
				set severity $::logging::severity_option_to_number($sevkey)
				set message [join [lrange $args 1 end] { }]
			} else {
				set severity $::logging::severity_default
				set message [join $args { }]
			}
		} else {
			set severity $::logging::severity_default
			set message [join $args { }]
		}

		#
		# Conditional and log-file open from vars.tcl:proc msg
		#

		set formatted_output ""

		foreach line [split $message "\n"] {
			append formatted_output [format "%s.%03u %s: %s" \
						      [clock format $secs -format "%Y-%m-%d %H:%M:%S"] $msecs \
						      $::logging::severity_to_string($severity) \
							 $line ] "\n"
		}
		set formatted_output [string trimright $formatted_output]

		if { $severity <= $::logging::severity_limit_logfile } {
			catch {
				puts $::logging::_log_fh $formatted_output
			}
		}

		if { $severity <= $::logging::severity_limit_console } {
			catch {
				puts $formatted_output
			}
		}

		if { $severity <= $::logging::severity_limit_android } {
			catch {
				borg log $::logging::severity_to_borg_log_priority($severity) \
					$::logging::android_logger_tag \
					$message
			}
		}
	}

	# TODO: catch log-rotation and file-open errors and somehow report them

	proc init {} {

		# Set the default limit to INFO for Stable builds

		if { [regexp {^[0-9]+\.[0.9]+$} [package version de1app]] } {

			set ::logging::severity_limit_logfile 6
		}

		set de1root [file normalize [file dirname [info script]]]

		# Get log-related parameters from settings.tdb

		try {
			set _fh [open "${de1root}/settings.tdb" "r"]
			fconfigure $_fh -translation binary
			array set tmp_settings [encoding convertfrom utf-8 [read $_fh]]
			close $_fh
		} on error {result opts_dict} {
			array set tmp_settings [list]
		}

		# Starting with v1.35, logging is always enabled

		if { [info exists tmp_settings(logfile)] } {
			set ::settings(logfile) $tmp_settings(logfile)
		} else {
			set ::settings(logfile) "log.txt"
		}

		# Try log rotation

		set to_rotate [list $::settings(logfile)]
		set retain 10

		foreach f $to_rotate {
			set f_source [format "%s.%i" $f $retain]
			if {[file exists $f_source]} {
				catch { file delete $f_source }
			}
			for {set n $retain} {$n > 1} {incr n -1} {
				set f_source [format "%s.%i" $f [expr {$n - 1}]]
				set f_target [format "%s.%i" $f $n]
				if {[file exists $f_source]} {
					catch { file rename $f_source $f_target }
				}
			}
			set f_target [format "%s.%i" $f 1]
			if {[file exists $f]} {
				catch { file rename $f  $f_target }
			}
		}

		# Open the log, set to 64 kB buffering due to flash-wear concerns

		catch {
			set ::logging::_log_fh [open "${de1root}/$::settings(logfile)" w]
			fconfigure $::logging::_log_fh -buffersize 65536
		}
	}


	proc close_logfiles {} {

		msg -NOTICE "::logging::close_logfiles"
		catch { close $::logging::_log_fh }
	}

	# flush_log should only be called when required
	# such as just prior to an upload of the logs
	#
	# Use of Android logging via logcat
	# is suggested for real-time monitoring

	proc flush_log {} {

		if { $::logging::_log_fh != "" } {
			if { [catch {::flush $::logging::_log_fh} result opts_dict] != 0 } {
				msg -ERROR "::logging::flush failed: $result $opts_dict"
			} else {
				msg -NOTICE "::logging::flush_log"
			}
		} else {
				msg -NOTICE "::logging::flush_log: No filehandle to flush"
		}
	}




	if { [info exists ::logging::disable_logging_for_build] \
		     && $::logging::disable_logging_for_build } {

		proc default_logger {args} {
			# pass
		}

		proc init {args} {
			# pass
		}
	}


	::logging::init



	# General "dumper" for catch/try results

	proc log_error_result_opts_dict {result opts_dict {tag ""}} {

		set opts_dict_lines {}
		dict for {_k _v} $opts_dict {
			lappend opts_dict_lines [format "%s %s" $_k $_v]
		}

		::logging::default_logger -ERROR [format "%s%s%s\n%s" \
							  $tag \
							  [expr { $tag != "" ? " " : "" }] \
							  $result \
							  [join $opts_dict_lines "\n"] ]
	}

	#
	# Prepend logging of background errors
	# to the current error handler
	#

	variable _previous_bgerror [interp bgerror {}]

	proc _logging_bgerror {result opts_dict} {

		::logging::log_error_result_opts_dict $result $opts_dict

		# Effectively undocumented is bgerror is run in a loop context
		# See tk/library/bgerror.tcl for details of the Tk implementation

		# Catch the break and bubble up

		# The modal error dialog will prevent "proper" timestamps
		# on later errors. As multiple, different, unrelated
		# run-time errors should rarely occur in the field
		# avoid the complexity of using the idle queue at this time.

		# From https://www.tcl-lang.org/man/tcl/TclCmd/catch.htm
		#  TCL_OK sets inner_result
		#  TCL_ERROR sets inner_result to an error message
		#  TCL_RETURN, TCL_BREAK, and TCL_CONTINUE are unspecified

		catch { $::logging::_previous_bgerror $result $opts_dict } inner_result inner_dict

		return -code [dict get $inner_dict -code] $inner_result
	}


	msg -INFO "Overriding existing bgerror handler ${_previous_bgerror}"

	interp bgerror {} ::logging::_logging_bgerror


#
# Utilities for sanatizing date for logging
#

	###  generics

	# Render as printable if all "standard", printable ASCII (0x20 - 0x7e),
	# as hex otherwise.

	proc format_asc_bin {maybe_printable_maybe_binary} {
	    if { [regexp {^[\x20-\x7e]*$} $maybe_printable_maybe_binary] } {
		return "$maybe_printable_maybe_binary"
	    } else {
		set hexval [binary encode hex $maybe_printable_maybe_binary]
		return "hex: [regexp -inline -all .. $hexval]"
	    }
	}

	proc format_map_asc_bin {mixed_string} {

	    return [join [lmap s [split $mixed_string] \
				  { ::logging::format_asc_bin $s } ]]
	}

	proc ellipsis_zeros {hex_str} {

	    if { [regsub {00 (00 ){3,}00$} $hex_str "00 ... 00" retval] } {
		set bytes [expr { ([string length $hex_str] + 1 ) / 3 }]
		append retval " ($bytes bytes)"
	    }
	    return $retval
	}



	### MMR data

	proc format_mmr {mmr_binary} {

	    set mmr_hexstr [binary encode hex $mmr_binary]
	    set mmr_bytes [string range $mmr_hexstr 0 1]
	    set mmr_high_addr [string range $mmr_hexstr 2 3]
	    set mmr_low_addr [string range $mmr_hexstr 4 7]
	    set mmr_payload [string range $mmr_hexstr 8 end]
	    return [format "0x%s 0x%s %s payload: %s" \
			    $mmr_bytes $mmr_high_addr $mmr_low_addr \
			    [::logging::ellipsis_zeros \
				     [regexp -inline -all .. $mmr_payload]]]
	}

	proc format_mmr_short {mmr_binary} {

	    set mmr_hexstr [binary encode hex $mmr_binary]
	    set mmr_bytes [string range $mmr_hexstr 0 1]
	    set mmr_high_addr [string range $mmr_hexstr 2 3]
	    set mmr_low_addr [string range $mmr_hexstr 4 7]
	    return [format "0x%s 0x%s %s (payload omitted)" \
			    $mmr_bytes $mmr_high_addr $mmr_low_addr]
	}



	### ble event data

	proc format_ble_event {ble_event} {
	    # Everything should be printable, except for the "value"
	    if { [dict keys $ble_event value] == "value" } {
		dict set ble_event value \
			[format '%s' \
				 [::logging::format_asc_bin \
					  [dict get $ble_event value]]]
	    }
	    return $ble_event
	}

	#
	# For logging, only need some of:
	#   handle ble3
	#   address D9:B2:48:aa:bb:cc rssi -150 state connected
	#   suuid 0000A000-0000-1000-8000-00805F9B34FB sinstance 12
	#   cuuid 0000A011-0000-1000-8000-00805F9B34FB cinstance 62
	#   duuid 00002902-0000-1000-8000-00805F9B34FB
	#   permissions 0 access w
	#   value {'hex: 01 00'}
	#

	proc short_ble_uuid {long_uuid} {
	    return [string tolower [regsub {^0000([0-9a-fA-F]{4}).*$} \
					    $long_uuid \
					    {\1} ] ]
	}

	proc format_ble_event_short {ble_event} {

	    set formatted [::logging::format_ble_event $ble_event]
	    set short [dict filter $formatted script {k v} {
		expr { $k in {"cuuid" "access" "writetype" "value"} }
	    }]
	    if { [dict exists $short cuuid] } {
		dict set short cuuid [::logging::short_ble_uuid \
				 [dict get $short cuuid]]
	    }
	    return $short
	}

	proc format_ble_event_payload {ble_event} {

	    set value [expr { [dict keys $ble_event value] == "value" \
				      ? [dict get $ble_event value] \
				      : "(no value)" }]
	    return [::logging::format_asc_bin $value]
	}

	proc format_ble_command {ble_command} {

	    if { [lindex $ble_command 0] != "ble" } {
		msg -ERROR "Unrecognized as ble command: '$ble_command'"
		set retval $ble_command
	    }

	    set _action [lindex $ble_command 1]
	    set _handle [lindex $ble_command 2]

	    if { $_handle == $::de1(device_handle) } {

		set _handle "DE1 ($_handle)"

	    } elseif { $_handle == $::de1(scale_device_handle) } {

		set _handle "Scale ($_handle)"

	    } else {

		set _handle "Unknown ($_handle)"
	    }

	    set _cuuid [::logging::short_ble_uuid [lindex $ble_command 5]]

	    switch --  $_action {

		dread {

		    set _duuid [::logging::short_ble_uuid [lindex $ble_command 7]]
		    set retval "$_handle: $_action $_cuuid $_duuid"
		}

		dwrite {

		    set _duuid [::logging::short_ble_uuid [lindex $ble_command 7]]
		    set _dvalue [::logging::format_asc_bin [lindex $ble_command 8]]
		    set retval "$_handle: $_action $_cuuid $_duuid $_dvalue"
		}

		enable -
		disable -
		read {
		    set retval "$_handle: $_action $_cuuid"
		}

		write {
		    set _value [::logging::format_asc_bin [lindex $ble_command 7]]
		    return "$_handle: $_action $_cuuid $_value"
		}

		mtu {
			set _mtu [::logging::short_ble_uuid [lindex $ble_command 3]]
			set retval "$_handle: $_mtu"
		}

		default {

		    msg -NOTICE "Undecoded ble command action: '$_action'"
		    set retval "$_handle: [::logging::format_map_asc_bin $ble_command]"
		}
	    }

	    return $retval
	}

}  ;# ::logging
