package provide de1_event 1.0

package require lambda

package require de1_logging 1.0

#
# Generic event subscription and callbacks to listeners
#
# See specific subsystems for concrete implementations
#
# Default execution of a callback is to schedule "after idle"
# -noidle as the first parameter will schedule "after 0"
# -sync will execute immediately, prior to continuing to other callbacks or operations
#


namespace eval ::event::listener {

	proc _init_callback_list {callback_list_name} {

		# Callback_name should be fully qualified to target namespace

		if { [namespace qualifiers $callback_list_name] == "" } {
			msg -ERROR "Unqualfied name '$callback_list_name' passed to create callback lists"
			set callback_list_name ::event::listener::${callback_list_name}
			msg -WARNING "Using ${callback_list_name} from caller in [uplevel 1 {namespace current}]"
		}

		if { ! [info exists $callback_list_name] } {
			array set $callback_list_name [list idle [list] noidle [list] sync [list]]
		} else {
			msg -WARNING "Callback list ${callback_list_name} already exists. Not initializing."
		}
	}


	proc _generic_add {callback_list_name args} {

		# args can contain zero or more of -idle, -noidle, -sync
		#    and exactly one "executable" (typically a bare proc or a list)
		# If more than one "timing" option is present, the last will be used

		# callback_list_name should be fully qualified (see _init_callback_list)

		# As failure to register may result in not stopping the flow of hot water,
		# throw and let caller manage if needed

		if { ! [info exists $callback_list_name] } {
			set errmsg "No such callback list '${callback_list_name}'. Callback NOT added."
			msg -ERROR $errmsg
			throw [list ::event::listener NOSUCHLIST $callback_list_name] $errmsg
		}

		set flag idle
		set remainder [lmap elem $args \
				       { expr { $elem ni [list -idle -noidle -sync] \
							? $elem \
							: [set flag [string range $elem 1 end]; continue]}}]

		if { [llength $remainder] != 1 } {
			set errmsg "Unable to register callback to ${callback_list_name} with args: '${args}'"
			msg -ERROR $errmsg
			throw [list ::event::listener BADARGS ${args}] $errmsg

		} else {
			lappend ${callback_list_name}($flag) [lindex $remainder 0]
		}
	}

}


namespace eval ::event::apply {

	proc _generic {callback_list_name args} {

		# callback_list_name should be fully qualified (see _init_callback_list)

		if { ! [info exists $callback_list_name] } {
			msg -ERROR "No such callback list '${callback_list_name}'. Callbacks NOT executed."
			return
		}

		foreach cb [lindex [array get $callback_list_name sync] 1] {

			# Trap errors on synchronous execution to be able to continue

			try {
				eval [list {*}$cb {*}$args]
			} on error {result opts_dict} {
				msg -ERROR "Callback from ${callback_list_name} failed for sync: {*}$cb {*}$args"
			}
		}

		foreach cb [lindex [array get $callback_list_name noidle] 1] {

			after 0 [list {*}$cb {*}$args]
		}

		foreach cb [lindex [array get $callback_list_name idle] 1] {

			after idle [list after 0 [list {*}$cb {*}$args]]
		}
	}
}
