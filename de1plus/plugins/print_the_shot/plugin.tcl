package require http
package require json

set plugin_name "print_the_shot"

# 在命名空间外部定义版本信息，确保插件系统能立即访问
# Define version information outside the namespace to ensure the plugin system can access it immediately
# 服务器部署说明: https://github.com/Sofronio/DecentEspressoPrintTheShot
# Server deployment instructions: https://github.com/Sofronio/DecentEspressoPrintTheShot
set ::plugins::print_the_shot::author "Sofronio Chen"
set ::plugins::print_the_shot::contact "xbox2xbox@gmail.com" 
set ::plugins::print_the_shot::version 1.2
set ::plugins::print_the_shot::description "Upload shots to local server and print it"
set ::plugins::print_the_shot::name "Print The Shot"

namespace eval ::plugins::${plugin_name} {
    # 重新在命名空间内定义变量（确保一致性）
    # Redefine variables inside the namespace (ensuring consistency)
    variable author "Sofronio Chen"
    variable contact "xbox2xbox@gmail.com"
    variable version 1.2
    variable description "Upload shots to local server and print it"
    variable name "Print The Shot"

    # 创建设置界面
    # Create settings screen
    proc create_ui {} {
        set needs_save_settings 0

        # 如果设置不存在则创建
        # Create settings if non-existent
        if {[array size ::plugins::print_the_shot::settings] == 0} {
            array set ::plugins::print_the_shot::settings {
                auto_upload 1
                server_endpoint upload
                server_url yourserverip:8000
                use_http 1
                machine_name ""
            }
            set needs_save_settings 1
        }
        if { ![info exists ::plugins::print_the_shot::settings(last_upload_shot)] } {
            set ::plugins::print_the_shot::settings(last_upload_shot) {}
            set ::plugins::print_the_shot::settings(last_upload_result) {}
            set ::plugins::print_the_shot::settings(last_upload_id) {}
            set ::plugins::print_the_shot::settings(auto_upload_min_seconds) 6
            set needs_save_settings 1
        }
        if { ![info exists ::plugins::print_the_shot::settings(last_action)] } {
            set ::plugins::print_the_shot::settings(last_action) {}
        }
        if { $needs_save_settings == 1 } {
            plugins save_settings print_the_shot
        }

        dui page add printshot_settings -namespace [namespace current]::printshot_settings \
            -bg_img settings_message.png -type fpdialog

        return "printshot_settings"
    }

    proc msg { msg } {
        catch {
            ::msg [namespace current] {*}$msg
        }
    }

   proc upload {content} {
        variable settings
        variable version
        
        # 获取机器名称
        # Get machine name
        set machine_name $settings(machine_name)
        
        # 处理机器名称，创建简洁的标识符
        # Process machine name to create clean identifier
        set machine_id ""
        if {$machine_name ne ""} {
            # 移除所有非字母数字字符，替换为空（直接删除）
            # Remove all non-alphanumeric characters, replace with nothing (just delete)
            set clean_name [regsub -all {[^a-zA-Z0-9]} $machine_name ""]
            
            # 如果处理后的名字为空，使用默认值
            # If processed name is empty, use default
            if {$clean_name eq ""} {
                set clean_name "UNKNOWN"
            }
            
            # 限制长度
            # Limit length
            if {[string length $clean_name] > 20} {
                set clean_name [string range $clean_name 0 19]
            }
            
            set machine_id $clean_name
        } else {
            set machine_id "UNKNOWN"
        }
        
        msg "Machine name: '$machine_name', Clean ID: '$machine_id'"
        msg "Original shot data length: [string length $content] bytes"
        
        if {[string length $content] < 100} {
            msg "Warning: Shot data seems too short: [string length $content] bytes"
        }
        
        set settings(last_action) "upload"
        set settings(last_upload_shot) $::settings(espresso_clock)
        set settings(last_upload_result) ""
        set settings(last_upload_id) ""
        
        # 确保内容是 UTF-8 编码
        # Ensure content is UTF-8 encoded
        set content_utf8 [encoding convertto utf-8 $content]

        # 确定协议
        # Determine protocol
        set protocol "http"
        if {[info exists settings(use_http)] && $settings(use_http) == 0} {
            set protocol "https"
            package require tls
            http::register https 443 [list ::tls::socket -servername $settings(server_url)]
        }

        # 生成时间戳
        # Generate timestamp
        set timestamp [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
        
        # 构建简洁的URL查询参数
        # Build clean URL query parameters
        set base_url "$protocol://$settings(server_url)/$settings(server_endpoint)"
        
        # 简洁的参数：只有 machine_id, timestamp, plugin_version
        # Clean parameters: only machine_id, timestamp, plugin_version
        set url "$base_url?machine_id=$machine_id&timestamp=$timestamp&plugin_version=$version"
        
        msg "Clean Upload URL: $url"
        msg "Parameters: machine_id=$machine_id, timestamp=$timestamp, plugin_version=$version"
        
        # 使用简单的HTTP头
        # Use simple HTTP headers
        set headerl [list "Content-Type" "application/json"]
        
        set body $content_utf8

        set returncode 0
        set returnfullcode ""
        set answer ""

        # 重试机制
        # Retry mechanism
        set retryCount 0
        set maxAttempts 3
        set success 0
        set attempts 0

        while {$retryCount < $maxAttempts && !$success} {
            if {[catch {
                if {$attempts == 0} {
                    incr attempts
                    popup [translate_toast "Uploading to Local Server"]
                } else {
                    popup [subst {[translate_toast "Uploading to Local Server, attempt"] #[incr attempts]}]
                }

                set timeout 10000
                msg "Attempt $attempts: Sending request to $url"
                set token [http::geturl $url -headers $headerl -method POST -query $body -timeout $timeout]
                
                set status [http::status $token]
                set answer [http::data $token]
                set returncode [http::ncode $token]
                set returnfullcode [http::code $token]
                
                msg "Request status: $status"
                msg "Response code: $returncode"
                msg "Response length: [string length $answer] bytes"
                if {[string length $answer] < 200} {
                    msg "Response: $answer"
                }

                http::cleanup $token

                # 检查是否成功 (2xx 系列)
                # Check if successful (2xx series)
                if {$returncode >= 200 && $returncode < 300} {
                    set success 1
                    msg "Upload successful on attempt $attempts"
                } else {
                    incr retryCount
                    msg "Upload failed, retrying... ($retryCount/$maxAttempts)"
                    after 2000
                }
            } err] != 0} {
                incr retryCount
                msg "Error during upload attempt $retryCount: $err"
                set returnfullcode $err
                catch { http::cleanup $token }

                if {$retryCount < $maxAttempts} {
                    after 2000
                }
            }
        }

        if {!$success} {
            msg "Upload failed after $maxAttempts attempts: $returnfullcode"
            popup [translate_toast "Upload failed!"]
            set settings(last_upload_result) "[translate {Upload failed!}] $returnfullcode"
            plugins save_settings print_the_shot
            return
        }

        popup [translate_toast "Upload successful"]
        if {$machine_id ne "" && $machine_id ne "UNKNOWN"} {
            set settings(last_upload_result) "[translate {Upload successful!}] (ID: $machine_id)"
        } else {
            set settings(last_upload_result) "[translate {Upload successful!}]"
        }
        
        plugins save_settings print_the_shot
        return $answer
    }

    proc uploadShotData {} {
        variable settings
        set settings(last_action) "upload"
        set settings(last_upload_shot) $::settings(espresso_clock)
        set settings(last_upload_result) ""
        set settings(last_upload_id) ""
        
        if { ! $settings(auto_upload) } {
            set settings(last_upload_result) [translate "Not uploaded: auto-upload is not enabled"]
            save_plugin_settings print_the_shot
            return
        }
        if {[espresso_elapsed length] < 6 && [espresso_pressure length] < 6 } {
            set settings(last_upload_result) [translate "Not uploaded: shot was too short"]
            save_plugin_settings print_the_shot
            return
        }
        set min_seconds [ifexists settings(auto_upload_min_seconds) 6]
        if {[espresso_elapsed range end end] < $min_seconds } {
            set settings(last_upload_result) [translate "Not uploaded: shot duration was less than $min_seconds seconds"]
            save_plugin_settings print_the_shot
            return
        }
        set bev_type [ifexists ::settings(beverage_type) "espresso"]
        if {$bev_type eq "cleaning" || $bev_type eq "calibrate"} {
            set settings(last_upload_result) [translate "Not uploaded: Profile was 'cleaning' or 'calibrate'"]
            save_plugin_settings print_the_shot
            return
        }
        
        set espresso_data [::shot::create]
        ::plugins::print_the_shot::upload $espresso_data
    }

    proc async_dispatch {old new} {
        # 如果上次流程是热水或热水冲洗，则防止上传数据
        # Prevent uploading of data if last flow was HotWater or HotWaterRinse
        if { $old eq "Espresso" } {
            after 100 ::plugins::print_the_shot::uploadShotData
        }
    }
    
    proc manual_upload {} {
        variable settings
        
        # 检查是否有可用的冲泡数据
        # Check if shot data is available
        if {![info exists ::settings(espresso_clock)] || $::settings(espresso_clock) eq ""} {
            popup [translate_toast "No shot data available to upload"]
            set settings(last_upload_result) [translate "No shot data available"]
            plugins save_settings print_the_shot
            return
        }
        
        # 检查冲泡数据是否太短
        # Check if shot data is too short
        if {[espresso_elapsed length] < 6} {
            popup [translate_toast "Shot data is too short to upload"]
            set settings(last_upload_result) [translate "Shot data is too short"]
            plugins save_settings print_the_shot
            return
        }
        
        # 手动上传启动
        # Manual upload initiated
        msg "Manual upload initiated"
        
        # 创建咖啡数据
        # Create shot data
        if {[catch {
            set espresso_data [::shot::create]
            msg "Shot data created, size: [string length $espresso_data] bytes"
            
            # 调用上传函数
            # Call upload function
            ::plugins::print_the_shot::upload $espresso_data
            
        } error]} {
            msg "Error creating shot data: $error"
            popup [translate_toast "Error creating shot data"]
            set settings(last_upload_result) "[translate {Error:}] $error"
            plugins save_settings print_the_shot
        }
    }

    proc main {} {
        plugins gui print_the_shot [create_ui]
        ::de1::event::listener::after_flow_complete_add \
            [lambda {event_dict} {
            ::plugins::print_the_shot::async_dispatch \
                [dict get $event_dict previous_state] \
                [dict get $event_dict this_state] \
            } ]
    }

}

namespace eval ::plugins::${plugin_name}::printshot_settings {
    variable widgets
    array set widgets {}
    
    variable data
    array set data {}

    proc setup { } {
        variable widgets
        set page_name [namespace tail [namespace current]]
        
        # "完成" 按钮
        # "Done" button
        dui add dbutton $page_name 980 1210 1580 1410 -tags page_done -label [translate "Done"] -label_pos {0.5 0.5} -label_font Helv_10_bold -label_fill "#fAfBff"
        
        # 标题
        # Headline
        dui add dtext $page_name 1280 300 -text [translate "Print The Shot Upload"] -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"
        
        # 服务器 URL
        # Server URL
        dui add entry $page_name 280 540 -tags server_url -width 38 -font Helv_8 -borderwidth 1 -bg #fbfaff -foreground #4e85f4 -textvariable ::plugins::print_the_shot::settings(server_url) -relief flat -highlightthickness 1 -highlightcolor #000000 \
            -label [translate "Server URL"] -label_pos {280 480} -label_font Helv_8 -label_width 1000 -label_fill "#444444" 
        bind $widgets(server_url) <Return> [namespace current]::save_settings 
        
        # 服务器端点
        # Server Endpoint
        dui add entry $page_name 280 680 -tags server_endpoint -width 38 -font Helv_8 -borderwidth 1 -bg #fbfaff -foreground #4e85f4 -textvariable ::plugins::print_the_shot::settings(server_endpoint) -relief flat -highlightthickness 1 -highlightcolor #000000 \
            -label [translate "Server Endpoint"] -label_pos {280 620} -label_font Helv_8 -label_width 1000 -label_fill "#444444" 
        bind $widgets(server_endpoint) <Return> [namespace current]::save_settings
        
        # 紧凑的 checkbox 区域
        # Compact checkbox area
        dui add dcheckbox $page_name 280 760 -tags use_http -textvariable ::plugins::print_the_shot::settings(use_http) -fill "#444444" \
            -label [translate "Use HTTP (uncheck for HTTPS)"] -label_font Helv_8 -label_fill #4e85f4 -command save_settings 
        
        dui add dcheckbox $page_name 280 820 -tags auto_upload -textvariable ::plugins::print_the_shot::settings(auto_upload) -fill "#444444" \
            -label [translate "Auto-Upload"] -label_font Helv_8 -label_fill #4e85f4 -command save_settings 
        
        # 更长的 Manual Upload Button
        # Longer Manual Upload Button
        dui add dbutton $page_name 280 1000 -tags manual_upload -bwidth 600 -bheight 80 -label [translate "Manual Upload Last Shot"] \
            -label_font Helv_9 -label_fill white -command [list ::plugins::print_the_shot::manual_upload] -style insight_ok
        
        # 最小时间输入框和说明文字在同一行，垂直对齐
        # Minimum time entry and description text on the same line, vertically aligned
        dui add dtext $page_name 360 885 -tags min_seconds_label -text [translate "S: Minimum duration"] -font Helv_8 -width 600 -fill "#888888" -anchor "nw"
        dui add entry $page_name 280 880 -tags auto_upload_min_seconds -textvariable ::plugins::print_the_shot::settings(auto_upload_min_seconds) -width 3 -font Helv_8 -borderwidth 1 -bg #fbfaff -foreground #4e85f4 -relief flat -highlightthickness 1 -highlightcolor #000000
        #dui add dtext $page_name 400 1260 -tags min_seconds_desc -text [translate "(minimum shot duration)"] -font Helv_7 -width 500 -fill "#888888" -anchor "nw"
                
        # 机器名称 (新增)
        # Machine Name (new)
        dui add entry $page_name 1350 540 -tags machine_name -width 38 -font Helv_8 -borderwidth 1 -bg #fbfaff -foreground #4e85f4 -textvariable ::plugins::print_the_shot::settings(machine_name) -relief flat -highlightthickness 1 -highlightcolor #000000 \
            -label [translate "Machine Name"] -label_pos {1350 480} -label_font Helv_8 -label_width 1000 -label_fill "#444444"
        bind $widgets(machine_name) <Return> [namespace current]::save_settings
        
        # 显示当前机器名称 (只读)
        # Show current machine name (read-only)
        dui add dtext $page_name 1350 620 -tags current_machine_label -text [translate "Current Machine:"] -font Helv_8 -width 900 -fill "#444444"
        dui add dtext $page_name 1350 680 -tags current_machine_name -font Helv_8 -width 900 -fill "#4e85f4" -anchor "nw" -justify "left"
    
        # 最后一次上传咖啡
        # Last upload shot
        dui add dtext $page_name 1350 760 -tags last_action_label -text [translate "Last upload:"] -font Helv_8 -width 900 -fill "#444444"
        dui add dtext $page_name 1350 820 -tags last_shot_time -font Helv_8 -width 900 -fill "#4e85f4" -anchor "nw" -justify "left" 
        
        # 最后上传结果
        # Last upload result
        dui add dtext $page_name 1350 880 -tags last_upload_result -font Helv_8 -width 900 -fill "#4e85f4" -anchor "nw" -justify "left"
        
        }

    proc show { page_to_hide page_to_show } {
        dui item config $page_to_show last_action_label -text [translate "Last upload:"]
        dui item config $page_to_show last_shot_time -text [::plugins::print_the_shot::printshot_settings::format_shot_start]
        dui item config $page_to_show last_upload_result -text $::plugins::print_the_shot::settings(last_upload_result)
        
        # 显示机器名称
        # Show machine name
        set machine_name $::plugins::print_the_shot::settings(machine_name)
        if {$machine_name eq ""} {
            # 尝试获取 DE1 序列号作为默认机器名
            # Try to get DE1 serial number as default machine name
            catch {
                if {[info exists ::de1(skin)] && [info exists ::de1(serial_number)]} {
                    set machine_name "DE1-[string range $::de1(serial_number) end-3 end]"
                } else {
                    set machine_name "DE1-Unknown"
                }
            }
        }
        dui item config $page_to_show current_machine_name -text $machine_name
    }

    # 格式化咖啡开始时间
    # Format shot start time
    proc format_shot_start {} {
        set dt $::plugins::print_the_shot::settings(last_upload_shot)
        if { $dt eq {} } {
            return [translate "Last shot not found"]
        }
        if { [clock format [clock seconds] -format "%Y%m%d"] eq [clock format $dt -format "%Y%m%d"] } {
            return "[translate {Shot started today at}] [time_format $dt]"
        } else {
            return "[translate {Shot started on}] [clock format $dt -format {%B %d %Y, %H:%M}]"
        }
    }
    
    proc save_settings {} {
        dui say [translate {Saved}] sound_button_in
        save_plugin_settings print_the_shot
    }
    
    proc page_done {} {
        dui say [translate {Done}] sound_button_in
        save_plugin_settings print_the_shot
        dui page close_dialog
    }
}
