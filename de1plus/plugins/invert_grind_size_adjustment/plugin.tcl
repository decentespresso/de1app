set plugin_name "invert_grind_size_adjustment"

namespace eval ::plugins::${plugin_name} {

	# These are shown in the plugin selection page
	variable author "Julian Andres Klode"
	variable contact "jak@jak-linux.org"
	variable version 0.1
	variable description "Change short taps to be in 0.1 increments, long to be in 1.0 increments."
	variable name "Invert Streamline grind size adjustment"

	# This file will be sourced to display meta-data. Dont put any code into the
	# general scope as there are no guarantees about when it will be run.
	# For security reasons it is highly unlikely you will find the plugin in the
	# official distribution if you are not beeing run from your main
	# REQUIRED

	proc main {} {
        set ::streamline_adjust_grind_shortpress .1
        set ::streamline_adjust_grind_longpress 1
	} ;# main
}

