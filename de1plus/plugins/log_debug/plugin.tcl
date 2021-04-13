set plugin_name "log_debug"

namespace eval ::plugins::${plugin_name} {

    # These are shown in the plugin selection page
    variable author "Jeff Kletsky"
    variable contact "git-commits@allycomm.com"
    variable version 1.0
    variable description "Enable DEBUG-level logging for Stable builds."
    variable name "Log DEBUG"

    proc main {} {
	    set ::logging::severity_limit_logfile 7
	    msg -NOTICE "Log level set to DEBUG"
    }
}
