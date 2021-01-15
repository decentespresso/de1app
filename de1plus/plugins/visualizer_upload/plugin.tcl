package require http
package require tls


set plugin_name "visualizer_upload"

set ::plugins::${plugin_name}::author "Johanna Schander"
set ::plugins::${plugin_name}::contact "coffee-plugins@mimoja.de"
set ::plugins::${plugin_name}::version 1.0
set ::plugins::${plugin_name}::description "Upload your last shot to visualizer.coffee"

proc ::plugins::${plugin_name}::upload {content} {
    msg "uploading shot"
    borg toast "Uploading Shot"
    http::register https 443 [list ::tls::socket -servername $::plugins::visualizer_upload::settings(visualizer_url)]

    set username $::plugins::visualizer_upload::settings(visualizer_username)
    set password $::plugins::visualizer_upload::settings(visualizer_password)

    set auth "Basic [binary encode base64 $username:$password]"
    set boundary "--------[clock seconds]"
    set type "multipart/form-data, boundary=$boundary"
    set headerl [list Authorization "$auth"]

    set url "https://$::plugins::visualizer_upload::settings(visualizer_url)/$::plugins::visualizer_upload::settings(visualizer_endpoint)"
    
    set contentHeader "Content-Disposition: form-data; name=\"file\"; filename=\"file.shot\"\r\nContent-Type: File\r\n"
    set body "--$boundary\r\n$contentHeader\r\n$content\r\n--$boundary--\r\n"

    if {[catch {
        set token [http::geturl $url -headers $headerl -method POST -type $type -query $body -timeout 30000]
        msg $token
        set status [http::status $token]
        set answer [http::data $token]
        msg "status: $status"
        msg "answer $answer"
        if {[string length $answer] == 0} {
            msg "No id transmitted"
            borg toast "Upload failed!"
            return
        }

	} err] != 0} {
        msg "Could not upload shot! $err"
        borg toast "Upload failed!"
        return
    }

    borg toast "Upload successfull"
    http::cleanup $token
}

proc ::plugins::${plugin_name}::uploadShotData {old new} {
    if {[espresso_elapsed length] > 5 && [espresso_pressure length] > 5} {
        set espresso_data [format_espresso_for_history]
        upload $espresso_data
    }
}


proc ::plugins::${plugin_name}::main {} {
    register_state_change_handler Espresso Idle ::plugins::visualizer_upload::uploadShotData   
}

