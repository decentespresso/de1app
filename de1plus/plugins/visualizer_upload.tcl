package require http
package require tls

set plugin_name "visualizer_upload"

set ::plugins::${plugin_name}::author "JoJo"
set ::plugins::${plugin_name}::contact "email@coffee-mail.de"
set ::plugins::${plugin_name}::version 1.0
set ::plugins::${plugin_name}::description "Minimal plugin to showcase the interface"

proc upload {content} {
    msg "uploading shot"
    http::register https 443 [list ::tls::socket]

    set username $::plugins::visualizer_upload::settings(visualizer_username)
    set password $::plugins::visualizer_upload::settings(visualizer_password)

    set auth "Basic [binary encode base64 $username:$password]"
    # For the moment we need to butcher the form-data format
    set type "multipart/form-data; charset=utf-8;"

    set headerl [list Authorization "$auth" Content-Type "$type"]

    set url $::plugins::visualizer_upload::settings(visualizer_url)/$::plugins::visualizer_upload::settings(visualizer_endpoint)
    set body "content=$content"

    if {[catch {
        set token [http::geturl $url -headers $headerl -method POST -query $body -timeout 30000]
        msg $token
        set status [http::status $token]
        set answer [http::data $token]
        msg "status: $status"
        msg "answer $answer"
	} err] != 0} {
        msg "Could not upload shot! $err"
        return
    }

    http::cleanup $token
}

proc uploadShotData {old new} {
    if {[espresso_elapsed length] > 5 && [espresso_pressure length] > 5} {
        set espresso_data [format_espresso_for_history]
        upload $espresso_data
    }
}


proc ::plugins::${plugin_name}::main {} {
    register_state_change_handler Espresso Idle uploadShotData   
}

