package provide de1_logging 1.1

package require lambda

# Originally in gui.tcl
proc msg {args} {

	::logging::default_logger {*}$args
}

# Originally in updater.tcl
proc log_to_debug_file {args} {
	::logging::default_logger {*}$args
}


# TODO: Persist and restore the "settings"

namespace eval ::logging {

	variable severity_limit_logfile 7
	variable severity_limit_console 7
	variable severity_limit_window  7

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

	variable recent_log_lines [list]

	variable _log_fh ""

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

		set formatted_output [format "%s.%03u %s: %s" \
					      [clock format $secs -format "%Y-%m-%d %H:%M:%S"] $msecs \
					      $::logging::severity_to_string($severity) \
					      $message ]

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

		if { $severity <= $::logging::severity_limit_window \
			     && [safe_get ::debugging] == 1 } {

			if {[info exists ::settings(debugging_window_size)]} {
				set last_line_index \
					[expr { max(0, [safe_get ::settings(debugging_window_size] - 2]) } ]
			} else {
				set last_line_index 98
			}

			set ::logging::recent_log_lines \
				[list $formatted_output \
					 {*}[lrange $::logging::recent_log_lines 0 $last_line_index]]

			set ::debuglog [join $::logging::recent_log_lines "\n"]
		}
	}

	# TODO: catch log-rotation and file-open errors and somehow report them

	proc init {} {

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

		if { [info exists tmp_settings(log_enabled)] } {
			set ::settings(log_enabled) $tmp_settings(log_enabled)
		} else {
			set ::settings(log_enabled) 1
		}

		if { [info exists tmp_settings(logfile)] } {
			set ::settings(logfile) $tmp_settings(logfile)
		} else {
			set ::settings(logfile) "log.txt"
		}

		# Try log rotation

		set to_rotate {{log.txt}}
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

		# https://3.basecamp.com/3671212/buckets/7351439/messages/3033510129#__recording_3039704280
		# logging is always fast now, with only line level buffering
		#
		# https://3.basecamp.com/3671212/buckets/7351439/messages/3033510129#__recording_3037579684
		# Michael argues that there's no need to go nonblocking
		# if you have a write buffer defined.
		# so disabling for now, to see if he's right.

		catch {
			set ::logging::_log_fh [open "${de1root}/$::settings(logfile)" w]

			set ::settings(log_fast) 1
			if {[safe_get ::settings(log_fast)] == "1"} {
				fconfigure $::logging::_log_fh -blocking 0 -buffering line
				# Avoid reentrant call
				after idle [list msg -INFO "fast log file: "]
			} else {
				fconfigure $::logging::_log_fh -buffersize 65536
			}
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

}
