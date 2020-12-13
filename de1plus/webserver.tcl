package provide de1_webserver 1.0

package require wibble
package require rl_json
package require de1_machine

proc start_webserver {} {

    if {$::settings(webserver_enabled) == 0} {
        after 2000 {error "Webserver start requested but not enabled in the settings"}
        return 
    }

    if {$::settings(webserver_magic_phrase_confirm) != $::settings(webserver_magic_phrase)} {
        after 2000 {error "Webserver confirmation string not found or incorrect"}
        return
    }

    if {$::settings(webserver_authentication_key) == "ChangeMe"} {
        after 2000 {error "Please change the Webserver auth key!"}
        return
    }
    # Define handlers
    ::wibble::handle /on togglePowerOn
    ::wibble::handle /off togglePowerOff
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

    if {$auth != $::settings(webserver_authentication_key)} {
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