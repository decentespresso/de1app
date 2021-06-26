### By Damian Brakel ###
set plugin_name "DPx_Scheduler"

dui add variable saver 0 0 -font [dui font get "Font Awesome 5 Pro-Regular-400" 30] -fill #aaa -textvariable {[::plugins::DPx_Scheduler::timer_check]}

namespace eval ::plugins::${plugin_name} {
    
    # These are shown in the plugin selection page
    variable author "Damian"
    variable contact "via Diaspora"
    variable description ""
    variable version 1.2
    variable min_de1app_version {1.36.5}

    proc build_ui {} {
        if {$::settings(scheduler_enable) == 1} {
            set ::settings(scheduler_enable) 0
            ::save_settings
        }
        # Unique name per page
        set page_name "DPx_scheduler"
        dui page add $page_name
        set font_colour #444
        set click_colour #888
        set ::plugins::DPx_Scheduler::hours 10
        set ::plugins::DPx_Scheduler::minutes_tens 0
        set ::plugins::DPx_Scheduler::minutes_units 0
        set ::plugins::DPx_Scheduler::minutes 0
        set ::plugins::DPx_Scheduler::pm am
        set picker_x 540
        set picker_y 0
        set day_x 260
        set day_y 40
        set button_height 100
        set button_label_colour #333
        set button_outline_width 2
        set button_outline_colour #eee

        foreach day {Mon Tue Wed Thu Fri Sat Sun} {
            if { ! [info exists ::DPx_scheduler_times($day)] } {
                set ::DPx_scheduler_times($day) {}
            }
        }

        # Background image and "Done" button
        dui add canvas_item rect $page_name 0 0 2560 1600 -fill "#d7d9e6" -width 0
        dui add canvas_item rect $page_name 10 188 2552 1424 -fill "#ededfa" -width 0
        dui add canvas_item rect $page_name 220 412 2344 1192 -fill #fff -width 3 -outline #e9e9ed
        dui add canvas_item line $page_name 12 186 2552 186 -fill "#c7c9d5" -width 3
        dui add canvas_item line $page_name 2552 186 2552 1424 -fill "#c7c9d5" -width 3
        dui add dbutton $page_name 1034 1250 \
            -bwidth 492 -bheight 120 \
            -shape round -fill #c1c5e4 \
            -label [translate "Done"] -label_font Helv_10_bold -label_fill #fAfBff -label_pos {0.5 0.5} \
            -command {if {$::settings(skin) == "DSx"} {restore_DSx_live_graph}; set_next_page off off; dui page load off; ::plugins::DPx_Scheduler::save_schedule}

        # Testing shortcuts
        dui add dbutton DPx_scheduler 0 1210 -bwidth 120 -bheight 200 -command {dui page load extensions}
        dui add dbutton extensions 0 1210 -bwidth 120 -bheight 200 -command {dui page load DPx_scheduler}

        # Headline
        dui add dtext $page_name 1280 300 -text [translate "DPx Scheduler"] -font Helv_20_bold -fill $font_colour -anchor "center" -justify "center"

        dui add dbutton $page_name [expr $picker_x + 1124] [expr $picker_y + 600] \
            -bwidth 650 -bheight 400 -tags picker_outline \
            -shape outline -width $button_outline_width -outline $button_outline_colour

        #hours
        dui add variable $page_name [expr $picker_x + 1200] [expr $picker_y + 800] -justify center -anchor center -font [dui font get "Font Awesome 5 Pro-Regular-400" 30] -fill $font_colour -textvariable {$::plugins::DPx_Scheduler::hours}
        dui add dbutton $page_name [expr $picker_x + 1124] [expr $picker_y + 600] \
            -bwidth 150 -bheight 200 -tags hour_up \
            -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::plugins::DPx_Scheduler::hours < 12} {
                    set ::plugins::DPx_Scheduler::hours [expr $::plugins::DPx_Scheduler::hours + 1]
                } else {
                    set ::plugins::DPx_Scheduler::hours 1
                }
            }

        dui add dbutton $page_name [expr $picker_x + 1124] [expr $picker_y + 800] \
            -bwidth 150 -bheight 200 -tags hour_down \
            -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::plugins::DPx_Scheduler::hours > 1} {
                    set ::plugins::DPx_Scheduler::hours [expr $::plugins::DPx_Scheduler::hours - 1]
                } else {
                    set ::plugins::DPx_Scheduler::hours 12
                }
            }

        dui add dtext $page_name [expr $picker_x + 1300] [expr $picker_y +  784] -justify center -anchor center -font [dui font get "Font Awesome 5 Pro-Regular-400" 30] -fill $font_colour -text ":"

        #minutes_tens
        dui add variable $page_name [expr $picker_x + 1400] [expr $picker_y + 800] -justify center -anchor center -font [dui font get "Font Awesome 5 Pro-Regular-400" 30] -fill $font_colour -textvariable {$::plugins::DPx_Scheduler::minutes_tens}
        dui add dbutton $page_name [expr $picker_x + 1324] [expr $picker_y +  600] \
            -bwidth 150 -bheight 200 -tags minutes_ten_up \
            -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::plugins::DPx_Scheduler::minutes < 49} {
                    set ::plugins::DPx_Scheduler::minutes [expr $::plugins::DPx_Scheduler::minutes + 10]
                } else {
                    set ::plugins::DPx_Scheduler::minutes [expr $::plugins::DPx_Scheduler::minutes - 50]
                }
                ::plugins::DPx_Scheduler::plugins::DPx_Scheduler::minutes_digits
            }

        dui add dbutton $page_name [expr $picker_x + 1324] [expr $picker_y +  800] \
            -bwidth 150 -bheight 200 -tags minutes_ten_down \
            -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::plugins::DPx_Scheduler::minutes > 9} {
                    set ::plugins::DPx_Scheduler::minutes [expr $::plugins::DPx_Scheduler::minutes - 10]
                } else {
                    set ::plugins::DPx_Scheduler::minutes [expr $::plugins::DPx_Scheduler::minutes + 50]
                }
                ::plugins::DPx_Scheduler::plugins::DPx_Scheduler::minutes_digits
            }

        #minutes
        dui add variable $page_name [expr $picker_x + 1550] [expr $picker_y +  800] -justify center -anchor center -font [dui font get "Font Awesome 5 Pro-Regular-400" 30] -fill $font_colour -textvariable {$::plugins::DPx_Scheduler::minutes_units}
        dui add dbutton $page_name [expr $picker_x + 1474] [expr $picker_y +  600] \
            -bwidth 150 -bheight 200 -tags minutes_up \
            -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::plugins::DPx_Scheduler::minutes < 59} {
                    set ::plugins::DPx_Scheduler::minutes [expr $::plugins::DPx_Scheduler::minutes + 1]
                } else {
                    set ::plugins::DPx_Scheduler::minutes 0
                }
                ::plugins::DPx_Scheduler::plugins::DPx_Scheduler::minutes_digits
            }

        dui add dbutton $page_name [expr $picker_x + 1474] [expr $picker_y +  800] \
            -bwidth 150 -bheight 200 -tags minutes_down \
            -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::plugins::DPx_Scheduler::minutes > 0} {
                    set ::plugins::DPx_Scheduler::minutes [expr $::plugins::DPx_Scheduler::minutes - 1]
                } else {
                    set ::plugins::DPx_Scheduler::minutes 59
                }
                ::plugins::DPx_Scheduler::plugins::DPx_Scheduler::minutes_digits
            }

        #pm
        dui add variable $page_name [expr $picker_x + 1700] [expr $picker_y +  800] -justify center -anchor center -font [dui font get "Font Awesome 5 Pro-Regular-400" 30] -fill $font_colour -textvariable {$::plugins::DPx_Scheduler::pm}
        dui add dbutton $page_name [expr $picker_x + 1624] [expr $picker_y +  600] \
            -bwidth 150 -bheight 200 -tags pm_up \
            -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {if {$::plugins::DPx_Scheduler::pm == "am"} {set ::plugins::DPx_Scheduler::pm pm} else {set ::plugins::DPx_Scheduler::pm am}}
        dui add dbutton $page_name [expr $picker_x + 1624] [expr $picker_y + 800] \
            -bwidth 150 -bheight 200 -tags pm_down \
            -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {if {$::plugins::DPx_Scheduler::pm == "am"} {set ::plugins::DPx_Scheduler::pm pm} else {set ::plugins::DPx_Scheduler::pm am}}

        #day buttons
        dui add dbutton $page_name [expr $day_x + 0] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Mon \
            -label Mon -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::set_time Mon}
        dui add dbutton $page_name [expr $day_x + 200] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Tue \
            -label Tue -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::set_time Tue}
        dui add dbutton $page_name [expr $day_x + 400] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Wed \
            -label Wed -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::set_time Wed}
        dui add dbutton $page_name [expr $day_x + 600] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Thu \
            -label Thu -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::set_time Thu}
        dui add dbutton $page_name [expr $day_x + 800] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Fri \
            -label Fri -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::set_time Fri}
        dui add dbutton $page_name [expr $day_x + 1000] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Sat \
            -label Sat -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::set_time Sat}
        dui add dbutton $page_name [expr $day_x + 1200] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Sun \
            -label Sun -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::set_time Sun}

        #clear days
        dui add dbutton $page_name [expr $day_x + 0] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Mon \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::clear_time Mon}
        dui add dbutton $page_name [expr $day_x + 200] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Tue \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::clear_time Tue}
        dui add dbutton $page_name [expr $day_x + 400] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Wed \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::clear_time Wed}
        dui add dbutton $page_name [expr $day_x + 600] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Thu \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::clear_time Thu}
        dui add dbutton $page_name [expr $day_x + 800] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Fri \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::clear_time Fri}
        dui add dbutton $page_name [expr $day_x + 1000] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Sat \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::clear_time Sat}
        dui add dbutton $page_name [expr $day_x + 1200] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Sun \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::DPx_Scheduler::clear_time Sun}

        dui add variable $page_name [expr $day_x + 90] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::DPx_scheduler_times(Mon)}
        dui add variable $page_name [expr $day_x + 290] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::DPx_scheduler_times(Tue)}
        dui add variable $page_name [expr $day_x + 490] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::DPx_scheduler_times(Wed)}
        dui add variable $page_name [expr $day_x + 690] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::DPx_scheduler_times(Thu)}
        dui add variable $page_name [expr $day_x + 890] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::DPx_scheduler_times(Fri)}
        dui add variable $page_name [expr $day_x + 1090] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::DPx_scheduler_times(Sat)}
        dui add variable $page_name [expr $day_x + 1290] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::DPx_scheduler_times(Sun)}
        dui add variable $page_name [expr $day_x + 700] [expr $day_y + 770] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 26] -fill "#00dd00" -textvariable {$::plugins::DPx_Scheduler::message}
        dui add dtext $page_name [expr $day_x + 700] [expr $day_y + 400] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 12] -fill "#999" -text [translate "Tap the day button to add the current Scheduler Time"]
        dui add dtext $page_name [expr $picker_x + 1450] [expr $picker_y + 610] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 12] -fill "#999" -text [translate "Scheduler Time"]
        dui add dbutton $page_name 1040 1480 \
            -bwidth 500 -bheight 120 \
            -labelvariable {[translate "Note: your cool down timer is set to "] [minutes_text $::settings(screen_saver_delay)]} -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 14] -label_fill #999 -label_pos {0.5 0.5} \
            -command {backup_settings; set_next_page off settings_3; dui page load settings_3; scheduler_feature_hide_show_refresh; set ::settings(active_settings_tab) "settings_3"}

        return $page_name
    }

    proc check_versions {} {
        if { [package vcompare [package version de1app] $::plugins::DPx_Scheduler::min_de1app_version] < 0 } {
            variable description "        * * *  WARNING  * * *\rDPx Scheduler is not compatable with \rApp Version [package version de1app]\rPlease update to version $::plugins::DPx_Scheduler::min_de1app_version or newer"
        }
    }
    check_versions

    proc timer_check {} {
        after 100 {::plugins::DPx_Scheduler::scan_times}
        return ""
    }

    proc remove_zero { x } {
        scan $x %d n
        return $n
    }

    proc scan_times {} {
        set ct [clock seconds]
        set day [clock format $ct -format {%a}]
        set mins [expr {([remove_zero [clock format $ct -format {%H}]] * 60 ) + [remove_zero [clock format $ct -format {%M}]]}]
        if {[info exist ::DPx_scheduler_minutes($day)] == 1} {
            foreach time $::DPx_scheduler_minutes($day) {
                if {$time == $mins} {
                    start_idle
                }
            }
        }
    }

    proc clear_time { day } {
        set ::DPx_scheduler_minutes($day) ""
        set ::DPx_scheduler_times($day) ""
    }
    proc checkArr {name} {
        upvar $name arr
        if {![info exists arr(key1)]} {
            return 0
        } else {
            return 1
        }
    }

    proc set_time { day } {
        if {$::plugins::DPx_Scheduler::pm == "pm" && $::plugins::DPx_Scheduler::hours != 12} {
            set sh [expr $::plugins::DPx_Scheduler::hours + 12]
        } else {
            set sh $::plugins::DPx_Scheduler::hours
        }
        if {$::plugins::DPx_Scheduler::pm == "am" && $sh == 12} {
            set sh [expr $::plugins::DPx_Scheduler::hours - 12]
        }
        set m [expr ($sh * 60) + $::plugins::DPx_Scheduler::minutes]
        set s [expr $m * 60]
        set z [clock format [clock seconds] -format {%z}]
        set sep " "
        if {[info exists ::DPx_scheduler_minutes($day)] == 1} {
            if {[lsearch -exact $::DPx_scheduler_minutes($day) $m] >= 0} {
                set ::plugins::DPx_Scheduler::message "That time already exists"
                after 1200 {set ::plugins::DPx_Scheduler::message ""}
            } else {
                append ::DPx_scheduler_times($day) [clock format $s -format {%I:%M%P} -gmt $z] \r
                append ::DPx_scheduler_minutes($day) $sep$m$sep
            }
        } else {
            append ::DPx_scheduler_times($day) [clock format $s -format {%I:%M%P} -gmt $z] \r
            append ::DPx_scheduler_minutes($day) $sep$m$sep
        }
    }

    proc load_sched {} {
        set fn "[plugin_directory]/DPx_Scheduler/schedule.tbd"
        array set ::DPx_scheduler_minutes [encoding convertfrom utf-8 [read_binary_file $fn]]
        foreach day {Mon Tue Wed Thu Fri Sat Sun} {
            if {[info exists ::DPx_scheduler_minutes($day)] == 1} {
                foreach m $::DPx_scheduler_minutes($day) {
                    set s [expr $m * 60]
                    set z [clock format [clock seconds] -format {%z}]
                    append ::DPx_scheduler_times($day) [clock format $s -format {%I:%M%P} -gmt $z] \r
                }
            }
        }
    }

    if {[file exist "[plugin_directory]/DPx_Scheduler/schedule.tbd"]} {
        ::plugins::DPx_Scheduler::load_sched
    }

    proc save_schedule {} {
        msg "saving DPx Schedule"
        set fn "[plugin_directory]/DPx_Scheduler/schedule.tbd"
        upvar ::DPx_scheduler_minutes item
        set DPx_shed {}
        foreach k [lsort -dictionary [array names item]] {
            set v $item($k)
            append DPx_shed [subst {[list $k] [list $v]\n}]
        }
        write_file $fn $DPx_shed
    }

    proc DPx_sched_minutes_digits {} {
        if {$::plugins::DPx_Scheduler::minutes >= 50 && $::plugins::DPx_Scheduler::minutes < 60} {
            set a 5
        } elseif {$::plugins::DPx_Scheduler::minutes >= 40 && $::plugins::DPx_Scheduler::minutes < 50} {
            set a 4
        } elseif {$::plugins::DPx_Scheduler::minutes >= 30 && $::plugins::DPx_Scheduler::minutes < 40} {
            set a 3
        } elseif {$::plugins::DPx_Scheduler::minutes >= 20 && $::plugins::DPx_Scheduler::minutes < 30} {
            set a 2
        } elseif {$::plugins::DPx_Scheduler::minutes >= 10 && $::plugins::DPx_Scheduler::minutes < 20} {
            set a 1
        } else {
            set a 0
        }
        set ::plugins::DPx_Scheduler::minutes_tens $a
        set ::plugins::DPx_Scheduler::minutes_units [round_to_integer [expr {$::plugins::DPx_Scheduler::minutes - ($a * 10)}]]
    }

    proc main {} {
        plugins gui DPx_Scheduler [build_ui]
    }
}
