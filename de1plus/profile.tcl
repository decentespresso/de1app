package provide de1_profile 2.0

package require huddle
package require json

namespace eval ::profile {

    variable current {}
    variable profile_version 2

    proc pressure_to_advanced_list {} {
        array set temp_advanced [settings_to_advanced_list]

        set temp_advanced(advanced_shot) {}
        set temp_advanced(final_desired_shot_volume_advanced_count_start) 0

        if {[ifexists temp_advanced(espresso_temperature_steps_enabled)] == 1} {
            set temp_bump_time_seconds $::settings(temp_bump_time_seconds)
            set first_frame_len $temp_bump_time_seconds

            set second_frame_len [expr {$temp_advanced(preinfusion_time) - $temp_bump_time_seconds}]		
            if {$second_frame_len < 0} { 
                set second_frame_len 0
            }
        } else {
            set first_frame_len 0
            set second_frame_len $temp_advanced(preinfusion_time)
            set temp_advanced(espresso_temperature_0) $temp_advanced(espresso_temperature)
            set temp_advanced(espresso_temperature_1) $temp_advanced(espresso_temperature)
            set temp_advanced(espresso_temperature_2) $temp_advanced(espresso_temperature)
            set temp_advanced(espresso_temperature_3) $temp_advanced(espresso_temperature)
        }

        if {$first_frame_len > 0} {
            set preinfusion [list \
                name [translate "preinfusion temp boost"] \
                temperature $temp_advanced(espresso_temperature_0) \
                sensor "coffee" \
                pump "flow" \
                transition "fast" \
                pressure 1 \
                flow $temp_advanced(preinfusion_flow_rate) \
                seconds $first_frame_len \
                volume 0 \
                exit_if "1" \
                exit_type "pressure_over" \
                exit_pressure_over $temp_advanced(preinfusion_stop_pressure) \
                exit_pressure_under 0 \
                exit_flow_over 0 \
                exit_flow_under 0 \
            ]
            lappend temp_advanced(advanced_shot) $preinfusion
            incr temp_advanced(final_desired_shot_volume_advanced_count_start)
        }

        if {$second_frame_len > 0} {
            set preinfusion2 [list \
                name [translate "preinfusion"] \
                temperature $temp_advanced(espresso_temperature_1) \
                sensor "coffee" \
                pump "flow" \
                transition "fast" \
                pressure 1 \
                flow $temp_advanced(preinfusion_flow_rate) \
                seconds $second_frame_len \
                volume 0 \
                exit_if "1" \
                exit_type "pressure_over" \
                exit_pressure_over $temp_advanced(preinfusion_stop_pressure) \
                exit_pressure_under 0 \
                exit_flow_over 6 \
                exit_flow_under 0 \
            ]
            lappend temp_advanced(advanced_shot) $preinfusion2
            incr temp_advanced(final_desired_shot_volume_advanced_count_start)
        }

        if {$temp_advanced(espresso_hold_time) > 0} {
            set hold [list \
                name [translate "rise and hold"] \
                temperature $temp_advanced(espresso_temperature_2) \
                sensor "coffee" \
                pump "pressure" \
                transition "fast" \
                pressure $temp_advanced(espresso_pressure) \
                seconds $temp_advanced(espresso_hold_time) \
                volume 0 \
                exit_if 0 \
                exit_pressure_over 0 \
                exit_pressure_under 0 \
                exit_flow_over 0 \
                exit_flow_under 0 \
            ]
            if {$temp_advanced(maximum_flow) != 0 && $temp_advanced(maximum_flow) != {}} {
                lappend hold max_flow_or_pressure $temp_advanced(maximum_flow)
                lappend hold max_flow_or_pressure_range $temp_advanced(maximum_flow_range_default)
            }
            lappend temp_advanced(advanced_shot) $hold
        }

        if {$temp_advanced(espresso_decline_time) > 0} {
            set decline [list \
                name [translate "decline"] \
                temperature $temp_advanced(espresso_temperature_3) \
                sensor "coffee" \
                pump "pressure" \
                transition "smooth" \
                pressure $temp_advanced(pressure_end) \
                seconds $temp_advanced(espresso_decline_time) \
                volume 0 \
                exit_if 0 \
                exit_pressure_over 0 \
                exit_pressure_under 0 \
                exit_flow_over 6 \
                exit_flow_under 0 \
            ]
            if {$temp_advanced(maximum_flow) != 0 && $temp_advanced(maximum_flow) != {}} {
                lappend decline max_flow_or_pressure $temp_advanced(maximum_flow)
                lappend decline max_flow_or_pressure_range $temp_advanced(maximum_flow_range_default)
            }
            lappend temp_advanced(advanced_shot) $decline
        }

        if {[llength $temp_advanced(advanced_shot)] == 0} {
                set empty [list \
                name [translate "empty"] \
                temperature 90 \
                sensor "coffee" \
                pump "flow" \
                transition "smooth" \
                flow 0 \
                seconds 0 \
                volume 0 \
                exit_if 0 \
                exit_pressure_over 0 \
                exit_pressure_under 0 \
                exit_flow_over 0 \
                exit_flow_under 0 \
            ]
            lappend temp_advanced(advanced_shot) $empty
        }

        set temp_advanced(final_desired_shot_weight_advanced) $temp_advanced(final_desired_shot_weight)
        set temp_advanced(final_desired_shot_volume_advanced) $temp_advanced(final_desired_shot_volume)

        set temp_advanced(maximum_pressure_range_advanced) $temp_advanced(maximum_pressure_range_default)
        set temp_advanced(maximum_flow_range_advanced) $temp_advanced(maximum_flow_range_default)

        return [array get temp_advanced]
    }

    proc flow_to_advanced_list {} {
        array set temp_advanced [settings_to_advanced_list]

        set temp_advanced(advanced_shot) {}
        set temp_advanced(final_desired_shot_volume_advanced_count_start) 0

        if {[ifexists temp_advanced(espresso_temperature_steps_enabled)] == 1} {
            set temp_bump_time_seconds $::settings(temp_bump_time_seconds)
            set first_frame_len $temp_bump_time_seconds

            set second_frame_len [expr {$temp_advanced(preinfusion_time) - $temp_bump_time_seconds}]		
            if {$second_frame_len < 0} { 
                set second_frame_len 0
            }
        } else {
            set first_frame_len 0
            set second_frame_len $temp_advanced(preinfusion_time)
            set temp_advanced(espresso_temperature_0) $temp_advanced(espresso_temperature)
            set temp_advanced(espresso_temperature_1) $temp_advanced(espresso_temperature)
            set temp_advanced(espresso_temperature_2) $temp_advanced(espresso_temperature)
            set temp_advanced(espresso_temperature_3) $temp_advanced(espresso_temperature)
        }

        if {$first_frame_len > 0} {
            set preinfusion [list \
                name [translate "preinfusion boost"] \
                temperature $temp_advanced(espresso_temperature_0) \
                sensor "coffee" \
                pump "flow" \
                transition "fast" \
                pressure 1 \
                flow $temp_advanced(preinfusion_flow_rate) \
                seconds $first_frame_len \
                volume 0 \
                exit_if "1" \
                exit_type "pressure_over" \
                exit_pressure_over $temp_advanced(preinfusion_stop_pressure) \
                exit_pressure_under 0 \
                exit_flow_over 0 \
                exit_flow_under 0 \
            ]
            lappend temp_advanced(advanced_shot) $preinfusion
            incr temp_advanced(final_desired_shot_volume_advanced_count_start)
        }

        if {$second_frame_len > 0} {
            set preinfusion2 [list \
                name [translate "preinfusion"] \
                temperature $temp_advanced(espresso_temperature_1) \
                sensor "coffee" \
                pump "flow" \
                transition "fast" \
                pressure 1 \
                flow $temp_advanced(preinfusion_flow_rate) \
                seconds $second_frame_len \
                volume 0 \
                exit_if "1" \
                exit_type "pressure_over" \
                exit_pressure_over $temp_advanced(preinfusion_stop_pressure) \
                exit_pressure_under 0 \
                exit_flow_over 0 \
                exit_flow_under 0 \
            ]
            lappend temp_advanced(advanced_shot) $preinfusion2
            incr temp_advanced(final_desired_shot_volume_advanced_count_start)
        }

        if {$temp_advanced(espresso_hold_time) > 0} {
            set hold [list \
                name [translate "hold"] \
                temperature $temp_advanced(espresso_temperature_2) \
                sensor "coffee" \
                pump "flow" \
                transition "fast" \
                flow $temp_advanced(flow_profile_hold) \
                seconds $temp_advanced(espresso_hold_time) \
                volume 0 \
                exit_if 0 \
                exit_pressure_over 0 \
                exit_pressure_under 0 \
                exit_flow_over 6 \
                exit_flow_under 0 \
            ]
            if {$temp_advanced(maximum_pressure) != 0 && $temp_advanced(maximum_pressure) != {}} {
                lappend hold max_flow_or_pressure $temp_advanced(maximum_pressure)
                lappend hold max_flow_or_pressure_range $temp_advanced(maximum_pressure_range_default)
            }
            lappend temp_advanced(advanced_shot) $hold
        }

        if {$temp_advanced(espresso_hold_time) > 0} {
            set decline [list \
                name [translate "decline"] \
                temperature $temp_advanced(espresso_temperature_3) \
                sensor "coffee" \
                pump "flow" \
                transition "smooth" \
                flow $temp_advanced(flow_profile_decline) \
                seconds $temp_advanced(espresso_decline_time) \
                volume 0 \
                exit_if 0 \
                exit_pressure_over 0 \
                exit_pressure_under 0 \
                exit_flow_over 0 \
                exit_flow_under 0 \
            ]
            if {$temp_advanced(maximum_pressure) != 0 && $temp_advanced(maximum_pressure) != {}} {
                lappend decline max_flow_or_pressure $temp_advanced(maximum_pressure)
                lappend decline max_flow_or_pressure_range $temp_advanced(maximum_pressure_range_default)
            }
            lappend temp_advanced(advanced_shot) $decline
        }

        if {[llength $temp_advanced(advanced_shot)] == 0} {
                set empty [list \
                name [translate "empty"] \
                temperature 90 \
                sensor "coffee" \
                pump "flow" \
                transition "smooth" \
                flow 0 \
                seconds 0 \
                volume 0 \
                exit_if 0 \
                exit_pressure_over 0 \
                exit_pressure_under 0 \
                exit_flow_over 0 \
                exit_flow_under 0 \
            ]
            lappend temp_advanced(advanced_shot) $empty
        }

        set temp_advanced(final_desired_shot_weight_advanced) $temp_advanced(final_desired_shot_weight)
        set temp_advanced(final_desired_shot_volume_advanced) $temp_advanced(final_desired_shot_volume)

        set temp_advanced(maximum_pressure_range_advanced) $temp_advanced(maximum_pressure_range_default)
        set temp_advanced(maximum_flow_range_advanced) $temp_advanced(maximum_flow_range_default)

        return [array get temp_advanced]
    }

    proc settings_to_advanced_list {} {
        array set temp_advanced {}
        foreach k [list profile_filename {*}[profile_vars]] {
            if {[info exists ::settings($k)] == 1} {
                set temp_advanced($k) $::settings($k)
            }
        }
        return [array get temp_advanced]
    }

    proc advanced_list_to_settings {list} {
        array set ::settings $list
        set ::current_step_number 0
    }

    proc legacy_profile_to_v2 {profile_list} {
        array set legacy_profile $profile_list

        set huddle_steps {}
        foreach step $legacy_profile(advanced_shot) {
            unset -nocomplain props
            array set props $step

            set huddle_step [huddle create \
                name [ifexists props(name)] \
                temperature [ifexists props(temperature)] \
                sensor [ifexists props(sensor)] \
                pump [ifexists props(pump)] \
                transition [ifexists props(transition)] \
                pressure [ifexists props(pressure)] \
                flow [ifexists props(flow)] \
                seconds [ifexists props(seconds)] \
                volume [ifexists props(volume)] \
            ]
            if {[ifexists props(exit_if)] == 1} {
                if {[ifexists props(exit_type)] == "pressure_under"} {
                    set exit_type "pressure"
                    set exit_condition "under"
                    set exit_value $props(exit_pressure_under)
                } elseif {[ifexists props(exit_type)] == "pressure_over"} {
                    set exit_type "pressure"
                    set exit_condition "over"
                    set exit_value $props(exit_pressure_over)
                } elseif {[ifexists props(exit_type)] == "flow_under"} {
                    set exit_type "flow"
                    set exit_condition "under"
                    set exit_value  $props(exit_flow_under)
                } elseif {[ifexists props(exit_type)] == "flow_over"} {
                    set exit_type "flow"
                    set exit_condition "over"
                    set exit_value $props(exit_flow_over)
                }
                huddle append huddle_step exit [huddle create type $exit_type condition $exit_condition value $exit_value]
            }
            if {[ifexists props(max_flow_or_pressure)] >= 0 && [info exists props(max_flow_or_pressure_range)]} {
                huddle append huddle_step limiter [huddle create value $props(max_flow_or_pressure) range $props(max_flow_or_pressure_range)]
            }
            lappend huddle_steps $huddle_step
        }
        set profile_type "advanced"

        if { $legacy_profile(settings_profile_type) eq "settings_2a" } {
            set profile_type "pressure"
        } elseif {$legacy_profile(settings_profile_type) eq "settings_2b"} {
            set profile_type "flow"
        }

        # we are not using a huddle spec as we are renaming and removing fields
        set profile [huddle create \
            title [ifexists legacy_profile(profile_title)]\
            author [ifexists legacy_profile(author)] \
            notes [ifexists legacy_profile(profile_notes)] \
            beverage_type [ifexists legacy_profile(beverage_type)] \
            steps [huddle list {*}$huddle_steps] \
            tank_temperature [ifexists legacy_profile(tank_desired_water_temperature)] \
            target_weight [ifexists legacy_profile(final_desired_shot_weight_advanced)] \
            target_volume [ifexists legacy_profile(final_desired_shot_volume_advanced)] \
            target_volume_count_start [ifexists legacy_profile(final_desired_shot_volume_advanced_count_start)] \
            legacy_profile_type [ifexists legacy_profile(settings_profile_type)] \
            type $profile_type \
            lang [ifexists legacy_profile(profile_language)] \
            hidden [ifexists legacy_profile(profile_hide)] \
            reference_file [ifexists legacy_profile(profile_filename)] \
            changes_since_last_espresso {} \
            version $::profile::profile_version\
        ]

        return $profile
    }

    proc sync_from_legacy {} {
        variable current
        if {[ifexists ::settings(settings_profile_type)] == "settings_2b"} {
            set data [legacy_profile_to_v2 [flow_to_advanced_list]]
        } elseif {([ifexists ::settings(settings_profile_type)] == "settings_2c" || [ifexists ::settings(settings_profile_type)] == "settings_2c2")} {
            set data [legacy_profile_to_v2 [settings_to_advanced_list]]
        } else {
            set data [legacy_profile_to_v2 [pressure_to_advanced_list]]
        }
        set current $data
    }

    proc save {filename} {
        variable current
        sync_from_legacy
        write_file $filename [huddle jsondump $current]
    }

    proc all {} {
        set dirs [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/profiles_v2/" *.json]]
        set profiles {}
        foreach fn $dirs {
            set profile_contents [encoding convertfrom utf-8 [read_binary_file "[homedir]/profiles_v2/$fn"]]
            set d2 [json::json2dict $profile_contents]
            lappend profiles [huddle create {*}$d2]
        }
        return $profiles
    }

    proc convert_all_legacy_to_v2 {} {
        set dirs [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/profiles/" *.tcl]]

        foreach d $dirs {
            msg [namespace current] "Converting profile" $d "to version 2"
            set fn "[homedir]/profiles/${d}"

            set fbasename [file rootname [file tail $d]]
            set target_file "[homedir]/profiles_v2/${fbasename}.json"

            if {[file exists $target_file]} {
                continue
            }

            # Set the settings like we need them for conversion
            set ::settings(profile) $d
            set ::settings(profile_notes) ""
            
            # for importing De1 profiles that don't have this feature.
            set ::settings(preinfusion_flow_rate) 4

            # Disable limits by default
            set ::settings(maximum_flow) 0
            set ::settings(maximum_pressure) 0
            set ::settings(maximum_flow_range_advanced) 0.6
            set ::settings(maximum_pressure_range_advanced) 0.6

            # If the profile does not set hiding yet
            set ::settings(profile_hide) 0

            catch {
                set settings_file_contents [encoding convertfrom utf-8 [read_binary_file $fn]]    
                array set ::settings $settings_file_contents
                save $target_file
            }
        }
    }
}