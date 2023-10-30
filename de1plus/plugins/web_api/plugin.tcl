package require de1_machine

set plugin_name "web_api"

namespace eval ::plugins::${plugin_name} {

    variable author "Johanna Schander"
    variable contact "coffee-plugins@mimoja.de"
    variable version 1.1
    variable description "Minimal webserver to report, enable, and disable the DE1's power state"
    variable name "Web API"

    proc main {} {
        package require wibble

        # Create settings if non-existant
        if {[array size ::plugins::web_api::settings] == 0} {
            array set ::plugins::web_api::settings {
                webserver_magic_phrase "I really want an unsecured (non-SSL) Webserver on my coffee machine"
                webserver_magic_phrase_confirm ""
                webserver_port 8080
                webserver_authentication_key "ChangeMe"
            }
            save_plugin_settings web_api
        }

        if { $::plugins::web_api::settings(webserver_magic_phrase_confirm) != $::plugins::web_api::settings(webserver_magic_phrase)} {
            after 2000 [list info_page [translate "Webserver confirmation string not found or incorrect"] [translate "Ok"]]
            return
        }

        if { $::plugins::web_api::settings(webserver_authentication_key) == "ChangeMe"} {
            after 2000 [list info_page [translate "Please change the Webserver auth key!"] [translate "Ok"]]
            return
        }

	# Auth

	proc ::wibble::check_auth {state} {
		set header_auth [dict getnull $state request header authorization]
		set auth [dict getnull $state request query auth]
		set auth [lindex $auth 1]

		if {$header_auth eq "Bearer $::plugins::web_api::settings(webserver_authentication_key)"} {
			return true
		}

		if {$auth eq $::plugins::web_api::settings(webserver_authentication_key)} {
			return true
		}

		return [unauthorized $state]
	}

	proc ::wibble::unauthorized {state} {
		dict set response status 403
		dict set state response header content-type "" {application/json charset utf-8}
		dict set response content "{status: \"unauthorized\"}"
		sendresponse $response
		return false;
	}

	# Utilities

	proc ::wibble::return_200_json {} {

		if { $::de1_num_state($::de1(state)) != "Sleep" } {
			set awake "true"
		} else {
			set awake "false"
		}

		if { $::plugins::web_api::recent_target_state != {} } {
			msg -DEBUG web_api "recent_target_state is $::plugins::web_api::recent_target_state"
			set awake $::plugins::web_api::recent_target_state
			after 800 { set ::plugins::web_api::recent_target_state {} }
		}

		set content "{\"status\": \"ok\", \"active\": $awake}"

		msg -INFO web_api "Sending response: $content"

		dict set response status 200
		dict set state response header content-type "" {application/json charset utf-8}
		dict set response content "$content"
		sendresponse $response
	}

	proc ::wibble::return_200_text {{content "ok"}} {

		dict set response status 200
		dict set state response header content-type "" {text/plain charset utf-8}
		dict set response content "$content"
		sendresponse $response
	}

	# Actions

	proc ::wibble::togglePowerOn {state} {
		if { ![check_auth $state] } {
			return;
		}

		msg -INFO web_api "Turning the machine on"
		set ::plugins::web_api::recent_target_state true
		start_idle

		::wibble::return_200_json
	}

	proc ::wibble::togglePowerOff {state} {
		if { ![check_auth $state] } {
			return;
		}
		msg -INFO web_api "Turning the machine off"

		set ::plugins::web_api::recent_target_state false
		start_sleep

		::wibble::return_200_json
	}

	proc ::wibble::togglePower {state} {
		if { ![check_auth $state] } {
			return;
		}

		msg -DEBUG web_api "toggle called"

		set target_state [lindex [dict getnull $state request query active] 1]
		set post_state [lindex [dict getnull $state request post] 0]

		if {$target_state eq true || [string toupper $post_state] eq "ON"} {
			::wibble::togglePowerOn $state
		}

		if {$target_state eq false || [string toupper $post_state] eq "OFF"} {
			::wibble::togglePowerOff $state
		}

		::wibble::return_200_json
	}

	proc ::wibble::flushLog {state} {
		if { ![check_auth $state] } {
			return;
		}

		::logging::flush_log

		::wibble::return_200_text
	}

	proc ::wibble::checkStatus {state} {
		if { ![check_auth $state] } {
			return;
		}

		# Returning a simple text 1 if the machine is in anything other than an sleep state. Return text 0 if sleep.
		# Return values chosen by cribbing from Supereg/homebridge-http-switch

		if { $::de1_num_state($::de1(state)) != "Sleep" } {
			set not_sleep "1"
		} else {
			set not_sleep "0"
		}

		::wibble::return_200_text $not_sleep
	}

	set ::plugins::web_api::recent_target_state {}

	# Define handlers

        ::wibble::handle /on togglePowerOn
        ::wibble::handle /off togglePowerOff
		::wibble::handle /toggle togglePower
		::wibble::handle /status checkStatus
		::wibble::handle /flush flushLog
        ::wibble::handle / notfound

        # Start a server and enter the event loop if not already there.

        catch {
		::wibble::listen $::plugins::web_api::settings(webserver_port)
        }

	}  ;# main
}
