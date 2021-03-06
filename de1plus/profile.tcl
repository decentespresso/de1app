package provide de1_profile 2.0

package require huddle
package require json

namespace eval ::profile {

    proc pressure_to_advanced_list {} {
        array set temp_advanced [settings_to_advanced_list]

        if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} {
            set temp_bump_time_seconds $::settings(temp_bump_time_seconds)
            set first_frame_len $temp_bump_time_seconds

            set second_frame_len [expr {$::settings(preinfusion_time) - $temp_bump_time_seconds}]		
            if {$second_frame_len < 0} { 
                set second_frame_len 0
            }
        } else {
            set first_frame_len 0
            set second_frame_len $::settings(preinfusion_time)
            set temp_advanced(espresso_temperature_0) $::settings(espresso_temperature)
            set temp_advanced(espresso_temperature_1) $::settings(espresso_temperature)
            set temp_advanced(espresso_temperature_2) $::settings(espresso_temperature)
            set temp_advanced(espresso_temperature_3) $::settings(espresso_temperature)
        }

        set preinfusion [list \
            name [translate "preinfusion"] \
            temperature $::settings(espresso_temperature) \
            sensor "coffee" \
            pump "flow" \
            transition "fast" \
            pressure 1 \
            flow $::settings(preinfusion_flow_rate) \
            seconds $first_frame_len \
            volume $::settings(preinfusion_stop_volumetric) \
            exit_if "1" \
            exit_type "pressure_over" \
            exit_pressure_over $::settings(preinfusion_stop_pressure) \
            exit_pressure_under 0 \
            exit_flow_over 6 \
            exit_flow_under 0 \
        ]

        set preinfusion2 [list \
            name [translate "preinfusion"] \
            temperature $::settings(espresso_temperature_1) \
            sensor "coffee" \
            pump "flow" \
            transition "fast" \
            pressure 1 \
            flow $::settings(preinfusion_flow_rate) \
            seconds $second_frame_len \
            volume $::settings(preinfusion_stop_volumetric) \
            exit_if "1" \
            exit_type "pressure_over" \
            exit_pressure_over $::settings(preinfusion_stop_pressure) \
            exit_pressure_under 0 \
            exit_flow_over 6 \
            exit_flow_under 0 \
        ]

        set hold [list \
            name [translate "rise and hold"] \
            temperature $::settings(espresso_temperature_2) \
            sensor "coffee" \
            pump "pressure" \
            transition "fast" \
            pressure $::settings(espresso_pressure) \
            seconds $::settings(espresso_hold_time) \
            volume $::settings(pressure_hold_stop_volumetric) \
            exit_if 0 \
            exit_pressure_over 11 \
            exit_pressure_under 0 \
            exit_flow_over 6 \
            exit_flow_under 0 \
            max_flow_or_pressure $::settings(maximum_flow) \
            max_flow_or_pressure_range $::settings(maximum_flow_pressure_range) \
        ]

        set decline [list \
            name [translate "decline"] \
            temperature $::settings(espresso_temperature_3) \
            sensor "coffee" \
            pump "pressure" \
            transition "smooth" \
            pressure $::settings(pressure_end) \
            seconds $::settings(espresso_decline_time) \
            volume $::settings(pressure_decline_stop_volumetric) \
            exit_if 0 \
            exit_pressure_over 11 \
            exit_pressure_under 0 \
            exit_flow_over 6 \
            exit_flow_under 0 \
            max_flow_or_pressure $::settings(maximum_flow) \
            max_flow_or_pressure_range $::settings(maximum_flow_pressure_range) \
        ]


        if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} {
            set temp_advanced(advanced_shot) [list $preinfusion $preinfusion2 $hold $decline]
        } else {
            set temp_advanced(advanced_shot) [list $preinfusion2 $hold $decline]
        }

        set temp_advanced(final_desired_shot_weight_advanced) $::settings(final_desired_shot_weight)
        set temp_advanced(final_desired_shot_volume_advanced) $::settings(final_desired_shot_volume)
        set temp_advanced(final_desired_shot_volume_advanced_count_start) 1

        return [array get temp_advanced]
    }

    proc flow_to_advanced_list {} {
        array set temp_advanced [settings_to_advanced_list]

        if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} {
            set temp_bump_time_seconds $::settings(temp_bump_time_seconds)
            set first_frame_len $temp_bump_time_seconds

            set second_frame_len [expr {$::settings(preinfusion_time) - $temp_bump_time_seconds}]		
            if {$second_frame_len < 0} { 
                set second_frame_len 0
            }
        } else {
            set first_frame_len 0
            set second_frame_len $::settings(preinfusion_time)
            set temp_advanced(espresso_temperature_0) $::settings(espresso_temperature)
            set temp_advanced(espresso_temperature_1) $::settings(espresso_temperature)
            set temp_advanced(espresso_temperature_2) $::settings(espresso_temperature)
            set temp_advanced(espresso_temperature_3) $::settings(espresso_temperature)
        }

        set preinfusion [list \
            name [translate "preinfusion"] \
            temperature $::settings(espresso_temperature) \
            sensor "coffee" \
            pump "flow" \
            transition "fast" \
            pressure 1 \
            flow $::settings(preinfusion_flow_rate) \
            seconds $first_frame_len \
            volume $::settings(preinfusion_stop_volumetric) \
            exit_if "1" \
            exit_type "pressure_over" \
            exit_pressure_over $::settings(preinfusion_stop_pressure) \
            exit_pressure_under 0 \
            exit_flow_over 6 \
            exit_flow_under 0 \
        ]
        if {$::settings(maximum_pressure) != 0 && $::settings(maximum_pressure) != {}} {
            lappend preinfusion max_flow_or_pressure $::settings(maximum_pressure)
            lappend preinfusion max_flow_or_pressure_range $::settings(maximum_flow_pressure_range)
        }

        set preinfusion2 [list \
            name [translate "preinfusion"] \
            temperature $::settings(espresso_temperature_1) \
            sensor "coffee" \
            pump "flow" \
            transition "fast" \
            pressure 1 \
            flow $::settings(preinfusion_flow_rate) \
            seconds $second_frame_len \
            volume $::settings(preinfusion_stop_volumetric) \
            exit_if "1" \
            exit_type "pressure_over" \
            exit_pressure_over $::settings(preinfusion_stop_pressure) \
            exit_pressure_under 0 \
            exit_flow_over 6 \
            exit_flow_under 0 \
            max_flow_or_pressure $::settings(maximum_pressure) \
            max_flow_or_pressure_range $::settings(maximum_flow_pressure_range) \
        ]
        if {$::settings(maximum_pressure) != 0 && $::settings(maximum_pressure) != {}} {
            lappend preinfusion2 max_flow_or_pressure $::settings(maximum_pressure)
            lappend preinfusion2 max_flow_or_pressure_range $::settings(maximum_flow_pressure_range)
        }

        set hold [list \
            name [translate "hold"] \
            temperature $::settings(espresso_temperature_2) \
            sensor "coffee" \
            pump "flow" \
            transition "fast" \
            flow $::settings(flow_profile_hold) \
            seconds $::settings(espresso_hold_time) \
            volume $::settings(flow_hold_stop_volumetric) \
            exit_if 0 \
            exit_pressure_over 11 \
            exit_pressure_under 0 \
            exit_flow_over 6 \
            exit_flow_under 0 \
            max_flow_or_pressure $::settings(maximum_pressure) \
            max_flow_or_pressure_range $::settings(maximum_flow_pressure_range) \
        ]
        if {$::settings(maximum_pressure) != 0 && $::settings(maximum_pressure) != {}} {
            lappend decline max_flow_or_pressure $::settings(maximum_pressure)
            lappend decline max_flow_or_pressure_range 0,6
        }

        set decline [list \
            name [translate "decline"] \
            temperature $::settings(espresso_temperature_3) \
            sensor "coffee" \
            pump "flow" \
            transition "smooth" \
            flow $::settings(flow_profile_decline) \
            seconds $::settings(espresso_decline_time) \
            volume $::settings(flow_decline_stop_volumetric) \
            exit_if 0 \
            exit_pressure_over 11 \
            exit_pressure_under 0 \
            exit_flow_over 6 \
            exit_flow_under 0
        ]
        if {$::settings(maximum_pressure) != 0 && $::settings(maximum_pressure) != {}} {
            lappend decline max_flow_or_pressure $::settings(maximum_pressure)
            lappend decline max_flow_or_pressure_range 0.6
        }


        if {[ifexists ::settings(espresso_temperature_steps_enabled)] == 1} {
            set temp_advanced(advanced_shot) [list $preinfusion $preinfusion2 $hold $decline]
        } else {
            set temp_advanced(advanced_shot) [list $preinfusion $hold $decline]
        }

        set temp_advanced(final_desired_shot_weight_advanced) $::settings(final_desired_shot_weight)
        set temp_advanced(final_desired_shot_volume_advanced) $::settings(final_desired_shot_volume)
        set temp_advanced(final_desired_shot_volume_advanced_count_start) 2

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

    proc legacy_profile_to_v2 {profile_list} {
        array set legacy_profile $profile_list

        set huddle_steps {}
        foreach step $legacy_profile(advanced_shot) {
            unset -nocomplain props
            lappend huddle_steps [huddle create {*}$step]
        }


        set profile_type "advanced"

        if { $legacy_profile(settings_profile_type) eq "settings_2a" } {
            set profile_type "pressure"
        } elseif {$legacy_profile(settings_profile_type) eq "settings_2b"} {
            set profile_type "flow"
        }

        # we are not using a huddle spec as we are renaming and removing fields
        set profile [huddle create \
            title $legacy_profile(profile_title)\
            author $legacy_profile(author) \
            notes $legacy_profile(profile_notes) \
            type $legacy_profile(beverage_type) \
            steps [huddle list {*}$huddle_steps] \
            tank_temperature $legacy_profile(tank_desired_water_temperature) \
            target_weight $legacy_profile(final_desired_shot_weight_advanced) \
            target_volume $legacy_profile(final_desired_shot_volume_advanced) \
            target_volume_count_start $legacy_profile(final_desired_shot_volume_advanced_count_start) \
            legacy_profile_type $legacy_profile(settings_profile_type) \
            type $profile_type \
            lang $legacy_profile(profile_language) \
            hidden $legacy_profile(profile_hide) \
            reference_file $legacy_profile(profile_filename) \
            changes_since_last_espresso {} \
        ]

        return $profile
    }

    proc save {} {
        set profile_filename $::settings(profile_filename) 
        if {[ifexists ::settings(settings_profile_type)] == "settings_2b"} {
            set data [legacy_profile_to_v2 [flow_to_advanced_list]]
        } elseif {([ifexists ::settings(settings_profile_type)] == "settings_2c" || [ifexists ::settings(settings_profile_type)] == "settings_2c2")} {
            set data [legacy_profile_to_v2 [settings_to_advanced_list]]
        } else {
            set data [legacy_profile_to_v2 [pressure_to_advanced_list]]
        }

        msg [namespace current] "successfully converted a legacy profile to the new format"
        #set fn "[::homedir]/profiles_v2/${profile_filename}.json"
        #write_file $fn [huddle jsondump $data]
    }
}