package require http
package require tls
package require json

set plugin_name "visualizer_upload"

set ::plugins::${plugin_name}::author "Johanna Schander"
set ::plugins::${plugin_name}::contact "coffee-plugins@mimoja.de"
set ::plugins::${plugin_name}::version 1.0
set ::plugins::${plugin_name}::description "Upload your last shot to visualizer.coffee"

proc ::plugins::${plugin_name}::upload {content} {
    msg "uploading shot"
    borg toast "Uploading Shot"

    set content [encoding convertto utf-8 $content]

    http::register https 443 [list ::tls::socket -servername $::plugins::visualizer_upload::settings(visualizer_url)]

    set username $::plugins::visualizer_upload::settings(visualizer_username)
    set password $::plugins::visualizer_upload::settings(visualizer_password)

    set auth "Basic [binary encode base64 $username:$password]"
    set boundary "--------[clock seconds]"
    set type "multipart/form-data, charset=utf-8, boundary=$boundary"
    set headerl [list Authorization "$auth"]

    set url "https://$::plugins::visualizer_upload::settings(visualizer_url)/$::plugins::visualizer_upload::settings(visualizer_endpoint)"
    
    set contentHeader "Content-Disposition: form-data; name=\"file\"; filename=\"file.shot\"\r\nContent-Type: application/octet-stream\r\n"
    set body "--$boundary\r\n$contentHeader\r\n$content\r\n--$boundary--\r\n"

    if {[catch {
        set token [http::geturl $url -headers $headerl -method POST -type $type -query $body -timeout 30000]
        msg $token
        set status [http::status $token]
        set answer [http::data $token]
        set returncode [http::ncode $token]
        msg "status: $status"
        msg "answer $answer"
        http::cleanup $token
        if {$returncode == 401} {
            msg "Upload failed. Unauthorized"
            borg toast "Upload failed! Authentication failed. Please check username / password"
            return
        }
        if {[string length $answer] == 0 || $returncode != 200} {
            msg "Upload failed"
            borg toast "Upload failed!"
            return
        }
	} err] != 0} {
        msg "Could not upload shot! $err"
        borg toast "Upload failed!"
        return
    }

    borg toast "Upload successfull"

    if {[catch {
        set response [::json::json2dict $answer]
        set uploaded_id [dict get $response id]
    } err] != 0} {
        msg "Upload successfull but unexpected server answer!"
        return
    }
    msg "Upload successfull with id: $uploaded_id"

    return $uploaded_id
}

proc ::plugins::${plugin_name}::uploadShotData {old new} {
    if {[espresso_elapsed length] > 5 && [espresso_pressure length] > 5
         && $::plugins::visualizer_upload::settings(auto_upload)} {
        set espresso_data [format_espresso_for_history]
        upload $espresso_data
    }
}


proc ::plugins::${plugin_name}::main {} {
    register_state_change_handler Espresso Idle ::plugins::visualizer_upload::uploadShotData   
}

