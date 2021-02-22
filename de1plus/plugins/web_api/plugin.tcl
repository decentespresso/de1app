package require wibble
package require de1_machine

set plugin_name "web_api"

set ::plugins::${plugin_name}::author "Johanna Schander"
set ::plugins::${plugin_name}::contact "coffee-plugins@mimoja.de"
set ::plugins::${plugin_name}::version 1.1
set ::plugins::${plugin_name}::description "Minimal webserver to report, enable, and disable the DE1's power state"

proc ::plugins::${plugin_name}::main {} {

    if { $::plugins::web_api::settings(webserver_magic_phrase_confirm) != $::plugins::web_api::settings(webserver_magic_phrase)} {
        after 2000 {error "Webserver confirmation string not found or incorrect"}
        return
    }

    if { $::plugins::web_api::settings(webserver_authentication_key) == "ChangeMe"} {
        after 2000 {error "Please change the Webserver auth key!"}
        return
    }
    # Define handlers
    ::wibble::handle /on togglePowerOn
    ::wibble::handle /off togglePowerOff
    ::wibble::handle /status checkStatus
    ::wibble::handle / notfound

    # Start a server and enter the event loop if not already there.
    catch {
        ::wibble::listen 8080
    }
}

proc ::wibble::check_auth {state} {
    set auth [dict getnull $state request query auth]
    set auth [lindex $auth 1]

    if {$auth eq ""} {
        return [unauthorized $state]
    }

    if {$auth != $::plugins::web_api::settings(webserver_authentication_key)} {
        return [unauthorized $state]
    }

    return true;
}

proc ::wibble::unauthorized {state} {
    dict set response status 403
    dict set state response header content-type "" {application/json charset utf-8}
    dict set response content "{status: \"unauthorized\"}"
    sendresponse $response
    return false;
}


proc ::wibble::togglePowerOn {state} {
    if { ![check_auth $state] } {
        return;
    }

    start_idle

    dict set response status 200
    dict set state response header content-type "" {application/json charset utf-8}
    dict set response content "{status: \"ok\"}"
    sendresponse $response
}

proc ::wibble::togglePowerOff {state} {
    if { ![check_auth $state] } {
        return;
    }
    
    start_sleep

    dict set response status 200
    dict set state response header content-type "" {application/json charset utf-8}
    dict set response content "{status: \"ok\"}"
    sendresponse $response
}

proc ::wibble::checkStatus {state} {
    if { ![check_auth $state] } {
        return;
    }

    dict set response status 200
    dict set state response header content-type "" {text/plain charset utf-8}
    
    # Returning a simple text 1 if the machine is in anything other than an idle state. Return text 0 if idle.
    # Return values chosen by cribbing from Supereg/homebridge-http-switch

    if { $::de1_num_state != 0 } {
        dict set response content "1"
    } else {
        dict set response content "0"
    }
    
    sendresponse $response
}