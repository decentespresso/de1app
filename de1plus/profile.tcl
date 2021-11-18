package provide de1_profile 2.0

package require huddle
package require json

namespace eval ::profile {

    variable current {}
    variable profile_version 2

    proc pressure_to_advanced_list { {settingsvar ::settings} } {
        upvar $settingsvar source_var

        array set temp_advanced [settings_to_advanced_list source_var]

        set temp_advanced(advanced_shot) {}
        set temp_advanced(final_desired_shot_volume_advanced_count_start) 0

        if {[ifexists temp_advanced(espresso_temperature_steps_enabled)] == 1} {
            set temp_bump_time_seconds [ifexists source_var(temp_bump_time_seconds) 2]
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
            if {$temp_advanced(espresso_hold_time) > 3} {
                # Second rise step without limiter
                set pressure_up [list \
                    name [translate "forced rise without limit"] \
                    temperature $temp_advanced(espresso_temperature_2) \
                    sensor "coffee" \
                    pump "pressure" \
                    transition "fast" \
                    pressure $temp_advanced(espresso_pressure) \
                    seconds 3 \
                    volume 0 \
                    exit_if 0 \
                    exit_pressure_over 0 \
                    exit_pressure_under 0 \
                    exit_flow_over 0 \
                    exit_flow_under 0 \
                ]
                lappend temp_advanced(advanced_shot) $pressure_up
                set temp_advanced(espresso_hold_time) [expr $temp_advanced(espresso_hold_time) - 3]
            }
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
            # If this is the firest pressurized step we forced the pressure up
            if {$temp_advanced(espresso_hold_time) < 3 && $temp_advanced(espresso_decline_time) > 3} {
                # Second rise step without limiter
                set pressure_up [list \
                    name [translate "forced rise without limit"] \
                    temperature $temp_advanced(espresso_temperature_3) \
                    sensor "coffee" \
                    pump "pressure" \
                    transition "fast" \
                    pressure $temp_advanced(espresso_pressure) \
                    seconds 3 \
                    volume 0 \
                    exit_if 0 \
                    exit_pressure_over 0 \
                    exit_pressure_under 0 \
                    exit_flow_over 0 \
                    exit_flow_under 0 \
                ]
                lappend temp_advanced(advanced_shot) $pressure_up
                set temp_advanced(espresso_decline_time) [expr $temp_advanced(espresso_decline_time) - 3]
            }

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

    proc flow_to_advanced_list { {settingsvar ::settings} } {
        upvar $settingsvar source_var

        array set temp_advanced [settings_to_advanced_list source_var]

        set temp_advanced(advanced_shot) {}
        set temp_advanced(final_desired_shot_volume_advanced_count_start) 0

        if {[ifexists temp_advanced(espresso_temperature_steps_enabled)] == 1} {
            set temp_bump_time_seconds [ifexists source_var(temp_bump_time_seconds) 2]
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

    proc settings_to_advanced_list { {settingsvar ::settings} } {
        upvar $settingsvar source_var
		
        array set temp_advanced {}
        foreach k [list profile_filename {*}[profile_vars]] {
            if {[info exists source_var($k)] == 1} {
                set temp_advanced($k) $source_var($k)
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
    
    # "sanitize" filename from profile title. Refactored from proc save_profile, so this is reusable in other parts
    # of the code such as profiles importing from Visualizer.
    proc filename_from_title { title } {
        set fn $title
        regsub -all {\s+} $fn _ fn 
        regsub -all {\/+} $fn __ fn 
        regsub -all {[\u0000-\u001f;:?<>(){}\[\]\|!@#$%^&*-\+=~`,.'"]+} $fn "" fn
        return [string range $fn 0 59]
    }
    
    # Ensure the profile type follows the latest app standard values. Refactored from proc select_profile, so this is reusable in other parts
    # of the code such as profiles importing from Visualizer. 
    proc fix_profile_type { profile_type } {
        if { $profile_type eq "settings_2" || $profile_type eq "settings_profile_pressure" } {
            set profile_type "settings_2a"
        } elseif { $profile_type eq "settings_profile_flow" } {
            set profile_type "settings_2b"
        } elseif { $profile_type eq "settings_profile_advanced" || $profile_type eq "settings_2c2" } {
            # old profile names that shouldn't exist any more, so upgrade them to the latest name
            set profile_type "settings_2c"
        }
        
        return $profile_type
    }
        
    # Based on proc load_settings_vars, but only loads profile variables, and returns a list with the profile (which can be
    # coerced to an array) instead of loading the profile into the global settings. The source file can also be a shot 
    # file, and only the profile-related vars will be loaded from it, plus any variables given in list $extra_vars.
    proc read_legacy { profile_path {extra_vars {}} } {
        if { [file pathtype $profile_path] eq "relative" && [file dirname $profile_path] eq "." } {
            set profile_path "[homedir]/profiles/[file tail $profile_path]"
        }
        if { [file extension $profile_path] eq "" } {
            append profile_path ".tcl"
        }
        if { ![file exists $profile_path] } {
            msg -WARNING [namespace current] load_profile: "profile file '$profile_path' not found"
            return
        }
        
        msg -INFO [namespace current] read_profile: "reading file '$profile_path'"
        array set profile {}
    
        # Set defaults in case they are not defined in the profile file 
        set profile(final_desired_shot_volume_advanced_count_start) 0
        set profile(settings_profile_type) "settings_2a"
        set profile(beverage_type) "espresso"
    
        try {
            array set arrfile [encoding convertfrom utf-8 [read_binary_file $profile_path]]
        } on error err {
            msg -WARNING [namespace current] read_profile: "error reading profile '$fn': $err"
            return
        }
    
        foreach k [concat [::profile_vars] $extra_vars] {
            if { [info exists arrfile($k)] } {
                set profile($k) $arrfile($k)
            } elseif { ![info exists profile($k)] } {
                set profile($k) {}
            }
        }
        
        set profile(settings_profile_type) [fix_profile_type $profile(settings_profile_type)]
        
        if { $profile(settings_profile_type) eq "settings_2c" && $profile(final_desired_shot_weight) ne "" &&
                $profile(final_desired_shot_weight_advanced) eq "" } {
            msg -NOTICE [namespace current] load_profile: "Using a default for final_desired_shot_weight_advanced " \
                "from final_desired_shot_weight of $profile(final_desired_shot_weight)"
            set profile(final_desired_shot_weight_advanced) $profile(final_desired_shot_weight)
        }
    
        # pre-set the shot volume, to the shot weight, if importing an old shot definition that doesn't have a an end volume 
        if { $profile(final_desired_shot_volume) eq "" } {
            msg -NOTICE [namespace current] load_profile: "pre-set the shot volume, to the shot weight, if importing an old shot definition" \
                "that doesn't have a an end volume"
            set profile(final_desired_shot_volume) $profile(final_desired_shot_weight)
        }
    
        if { $profile(advanced_shot) eq {} } {
            # Ensure the profile's advanced_shot variable is always defined
            switch $profile(settings_profile_type) \
                settings_2a {
                    array set temp_profile [pressure_to_advanced_list profile]
                    set profile(advanced_shot) $temp_profile(advanced_shot)
                } settings_2b {
                    array set temp_profile [flow_to_advanced_list profile]
                    set profile(advanced_shot) $temp_profile(advanced_shot)
                }
        }
        
        return [array get profile]
    }
    
    # Returns a dictionary with a textual representation of the provided profile.
    # The dictionary keys are the step numbers, with 0 corresponding to "global" profile metadata. Each step is also a dictionary.
    # Each step variable is a list, where the first element is the translatable text string, and subsequent (optional) elements are the 
    #    values to be replaced on the text string, matching codes "\1", "\2", etc in the main text string. Normally these values are
    #    numbers, but all user-definable profile variables are coded like this, so things like "quickly/gradually" or "sensor/coffee"
    #    also appear as replaceable strings.
    #
    # Step 0 dictionary can have keys 'title', 'type', 'nsteps', 'notes', 'preheat', 'limiter' and 'stop_at'. 
    # Step 1 to <nsteps> is each a dictionary which can have keys 'name', 'type', 'track', 'temp', 'flow_or_pressure', 'max', and 'exit_if'
    #
    # If a step doesn't have values for an element (e.g. a step doesn't define any "maximum" values), that key is NOT created.    
    proc legacy_to_textual { profile_list } {
        array set profile $profile_list
        set pdict [dict create]
    
        # Step 0 contains profile "globals"
        dict set pdict 0 title [list $profile(profile_title)] 
        
        set bev_type [value_or_default $profile(beverage_type) "espresso"]
        if { $bev_type == 0 } {
            set bev_type "espresso"
        }
        switch [fix_profile_type $profile(settings_profile_type)] \
            settings_2a {
                dict set pdict 0 type [list "Pressure $bev_type profile"]
            } settings_2b {
                dict set pdict 0 type [list "Flow $bev_type profile"]
            } settings_2c {
                dict set pdict 0 type [list "Advanced $bev_type profile"]
            } default {
                dict set pdict 0 type [list "Unknown $bev_type profile type"]
            }
    
        if { $profile(tank_desired_water_temperature) > 0 } {
            dict set pdict 0 preheat [list "Preheat water tank at \\1 ºC" [round_to_one_digits $profile(tank_desired_water_temperature)]]
        }
    
        # Limiters
        set ndef [expr {($profile(maximum_pressure_range_advanced)>0)+($profile(maximum_flow_range_advanced)>0)}]
        if { $ndef == 1 } {
            if { $profile(maximum_flow_range_advanced) > 0 } {
                dict set pdict 0 limiter [list "Limiter range of action: \\1 mL/s" [round_to_one_digits $profile(maximum_flow_range_advanced)]]
            } elseif { $profile(maximum_pressure_range_advanced) > 0 } {
                dict set pdict 0 limiter [list "Limiter range of action: \\1 bar" [round_to_one_digits $profile(maximum_pressure_range_advanced)]]
            }
        } elseif { $ndef == 2 } {
            dict set pdict 0 limiter [list "Limiter ranges of action: \\1 mL/s and \\2 bar" \
                [round_to_one_digits $profile(maximum_flow_range_advanced)] [round_to_one_digits $profile(maximum_pressure_range_advanced)]]
        }
    
        # Ending criteria
        set txt ""
        set items {}    
        set n_max [expr {($profile(final_desired_shot_volume)>0)+($profile(final_desired_shot_weight)>0)}]
        if { $n_max > 0 } {
            if { $n_max == 1 } {
                if { $profile(final_desired_shot_volume) > 0 } {
                    set txt "Stop at \\1 mL volume"
                    lappend items [round_to_one_digits $profile(final_desired_shot_volume)]
                } elseif { $profile(final_desired_shot_weight) > 0 } {
                    set txt "Stop at \\1 g weight"
                    lappend items [round_to_one_digits $profile(final_desired_shot_weight)]
                }
            } elseif { $n_max == 2 } {
                set txt "Stop at \\1 mL volume or \\2 g weight"
                lappend items [round_to_one_digits $profile(final_desired_shot_volume)] [round_to_one_digits $profile(final_desired_shot_weight)]
            }
            dict set pdict 0 stop_at [list $txt {*}$items]
        }
        
        dict set pdict 0 notes [list $profile(profile_notes)]
        
        # Profile steps
        set stepn 1
        set prev_temp 0.0
        set prev_sensor ""
        set prev_pressure_or_flow 0.0 
        set prev_pump ""
        set time_adjust 0.0
        
        foreach stepl $profile(advanced_shot) {
            array set step $stepl
            # Ignore the extra 3-second steps added by conversion of basic (flow/pressure) to advanced profile, as they are 
            # not in the GUI and would only confuse users, and undo the 3-seconds adjustments to match what's defined in the GUI 
            if { $profile(espresso_hold_time) > 0 && $step(seconds) == 3 && $step(volume) == 0 && $step(exit_if) == 0 } {
                set time_adjust 3.0
                continue
            }
            
            dict set pdict $stepn name [list $step(name)]
    
            if { $stepn > 1 && $profile(final_desired_shot_volume_advanced_count_start) == $stepn-1 } {
                dict set pdict $stepn track [list "Start tracking water volume"]
            }
        
            # Temperature
            if { $stepn == 1 || $prev_sensor ne $step(sensor) } {
                dict set pdict $stepn temp [list "Set \\1 temperature to \\2 ºC" $step(sensor) [round_to_one_digits $step(temperature)]]
            } elseif { $prev_temp == $step(temperature) } {
                dict set pdict $stepn temp [list "Maintain \\1 temperature at \\2 ºC" $step(sensor) [round_to_one_digits $step(temperature)]]
            } elseif { $prev_temp < $step(temperature) } {
                dict set pdict $stepn temp [list "Increase \\1 temperature to \\2 ºC" $step(sensor) [round_to_one_digits $step(temperature)]]
            } else {
                dict set pdict $stepn temp [list "Decrease \\1 temperature to \\2 ºC" $step(sensor) [round_to_one_digits $step(temperature)]]
            }
            
            # Flow or pressure
            ifexists step(max_flow_or_pressure) 0
            if { $step(transition) eq "smooth" } {
                set step(transition) "gradually"
            } elseif { $step(transition) eq "fast" } {
                set step(transition) "quickly"
            }
            
            set txt ""
            set items {}
            if { $step(pump) eq "flow" } {
                set txt "Pour \\1 at a rate of \\2 mL/s"
                lappend items $step(transition) [round_to_one_digits $step(flow)]
                
                if { $step(max_flow_or_pressure) > 0 } {
                    append txt " with a pressure limit of \\3 bar"
                    lappend items [round_to_one_digits $step(max_flow_or_pressure)]
                }
            } elseif { $step(pump) eq "pressure" } {
                if { $stepn == 1 || ($prev_pump ne "pressure" && $step(pressure) > 0) || \
                        ($stepn > 1 && $prev_pump eq "pressure" && $step(pressure) > $prev_pressure_or_flow ) } {
                    set txt  "Pressurize \\1 to \\2 bar"
                    lappend items $step(transition) [round_to_one_digits $step(pressure)]
                } elseif { $step(pressure) == 0 } {
                    set txt  "Depressurize \\1 to \\2 bar"
                    lappend items $step(transition) [round_to_one_digits $step(pressure)]
                } else {
                    set txt  "Decrease pressure \\1 to \\2 bar"
                    lappend items $step(transition) [round_to_one_digits $step(pressure)]
                }
                
                if { $step(max_flow_or_pressure) > 0 } {
                    append txt " with a flow limit of \\3 mL/s"
                    lappend items [round_to_one_digits $step(max_flow_or_pressure)]
                }                
            }
            
            dict set pdict $stepn flow_or_pressure [list $txt {*}$items]
            
            # Maximum
            if { $time_adjust != 0 } {
                set step(seconds) [expr {$step(seconds)+$time_adjust}] 
            }
            ifexists step(weight) 0
            
            set txt ""
            set items {}
            set n_max [expr {($step(seconds)>0)+($step(volume)>0)+($step(weight)>0)}]
            if { $n_max > 0 } {
                if { $n_max == 1 } {
                    set txt "For a maximum of \\1 \\2"
                } elseif { $n_max == 2 } {
                    set txt "For a maximum of \\1 \\2 or \\3 \\4"
                } elseif { $n_max == 3 } {
                    set txt "For a maximum of \\1 \\2 ,\\3 \\4 or \\5 \\6"
                }
            
                if { $step(seconds) > 0 } {
                    lappend items [round_to_one_digits $step(seconds)] "sec"
                    incr n_used
                }
                if { $step(volume) > 0 } {
                    lappend items [round_to_one_digits $step(volume)] "mL"
                }
                if { $step(weight) > 0 } {
                    lappend items [round_to_one_digits $step(weight)] "g"
                }
                
                dict set pdict $stepn max [list $txt {*}$items]
            }
            
            # Move on if
            if { $step(exit_if) } {
                if { $step(exit_flow_over) > 0 } {
                    dict set pdict $stepn exit_if "Move on if flow is \\1 \\2 mL/s" "over" [round_to_one_digits $step(exit_flow_over)]
                } elseif { $step(exit_flow_under) > 0 } {
                    dict set pdict $stepn exit_if "Move on if flow is \\1 \\2 mL/s" "under" [round_to_one_digits $step(exit_flow_under)]
                } elseif { $step(exit_pressure_over) > 0 } {
                    dict set pdict $stepn exit_if "Move on if pressure is \\1 \\2 bar" "over" [round_to_one_digits $step(exit_pressure_over)]
                } elseif { $step(exit_pressure_under) > 0 } {
                    dict set pdict $stepn exit_if "Move on if pressure is \\1 \\2 mL/s" "under" [round_to_one_digits $step(exit_pressure_under)]
                }
            }
            
            # Next step preparation
            set time_adjust 0.0
            set prev_sensor $step(sensor)
            set prev_temp $step(temperature)
            set prev_pump $step(pump)
            if { $prev_pump eq "flow" } {
                set prev_pressure_or_flow $step(flow)
            } else {
                set prev_pressure_or_flow $step(pressure)
            }
            incr stepn
        }
    
        dict set pdict 0 nsteps [expr {$stepn-1}]
        
        return $pdict
    }

}