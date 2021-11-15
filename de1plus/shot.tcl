package provide de1_shot 2.0

package require huddle
package require json

namespace eval ::shot {
    variable last {}


    proc format_timers_for_history {espresso_data_name} {
        upvar $espresso_data_name espresso_data
        foreach {name reftime} [array get ::timers] {
            append espresso_data "timers(${name}) ${reftime}\n"
        }
    }


    proc create_legacy {} {

        if {[info exists ::settings(espresso_clock)] != 1} {
            # in theory, this should never occur.
            msg -ERROR "This espresso's start time was not recorded." \
                "Possibly we didn't get the bluetooth message" \
                "of state change to espresso."
            set ::settings(espresso_clock) [clock seconds]
        }

        set clock $::settings(espresso_clock)

        set espresso_data {}
        append espresso_data "clock $clock\n"
        append espresso_data "local_time {[clock format $clock]}\n"

        append espresso_data "espresso_elapsed {[espresso_elapsed range 0 end]}\n"
        append espresso_data "espresso_pressure {[espresso_pressure range 0 end]}\n"
        append espresso_data "espresso_weight {[espresso_weight range 0 end]}\n"
        append espresso_data "espresso_flow {[espresso_flow range 0 end]}\n"
        append espresso_data "espresso_flow_weight {[espresso_flow_weight range 0 end]}\n"
        append espresso_data "espresso_flow_weight_raw {[espresso_flow_weight_raw range 0 end]}\n"
        append espresso_data "espresso_temperature_basket {[espresso_temperature_basket range 0 end]}\n"
        append espresso_data "espresso_temperature_mix {[espresso_temperature_mix range 0 end]}\n"
        append espresso_data "espresso_water_dispensed {[espresso_water_dispensed range 0 end]}\n"

        append espresso_data "espresso_pressure_delta {[espresso_pressure_delta range 0 end]}\n"
        append espresso_data "espresso_flow_delta_negative {[espresso_flow_delta_negative range 0 end]}\n"
        append espresso_data "espresso_flow_delta_negative_2x {[espresso_flow_delta_negative_2x range 0 end]}\n"

        append espresso_data "espresso_resistance {[espresso_resistance range 0 end]}\n"
        append espresso_data "espresso_resistance_weight {[espresso_resistance_weight range 0 end]}\n"

        append espresso_data "espresso_state_change {[espresso_state_change range 0 end]}\n"

        catch { ::device::scale::format_for_history espresso_data }

        append espresso_data "espresso_pressure_goal {[espresso_pressure_goal range 0 end]}\n"
        append espresso_data "espresso_flow_goal {[espresso_flow_goal range 0 end]}\n"
        append espresso_data "espresso_temperature_goal {[espresso_temperature_goal range 0 end]}\n"

        catch { format_timers_for_history espresso_data }

        # format settings nicely so that it is easier to read and parse
        append espresso_data "settings {\n"
        foreach k [lsort -dictionary [array names ::settings]] {
            set v $::settings($k)
            append espresso_data [subst {\t[list $k] [list $v]\n}]
        }
        append espresso_data "}\n"

        # things associated with the machine itself
        append espresso_data "machine {\n"
        foreach k [lsort -dictionary [array names ::de1]] {
            set v $::de1($k)
            append espresso_data [subst {\t[list $k] [list $v]\n}]
        }
        append espresso_data "}\n"

        set app_version [package version de1app]
        append espresso_data "app_version {$app_version}\n"

        ::profile::sync_from_legacy
        append espresso_data "profile [huddle jsondump $::profile::current]"

        return $espresso_data
    }
    
    proc get_vector {vectorname} {
        if {[$vectorname length] == 0} {
            return {}
        } else {
            return [$vectorname range 0 end]
        }
    }

    # We are creating a huddle instead of a dict as we can easily JSON dump it!
    proc create {} {
        variable last

        if {[info exists ::settings(espresso_clock)] != 1} {
            # in theory, this should never occur.
            msg -ERROR "This espresso's start time was not recorded." \
                "Possibly we didn't get the bluetooth message" \
                "of state change to espresso."
            set ::settings(espresso_clock) [clock seconds]
        }

        set clock $::settings(espresso_clock)
        set date [clock format $clock]
        set app_version [package version de1app]

        set pressure [huddle create \
            pressure [huddle list {*}[get_vector espresso_pressure]] \
            goal [huddle list {*}[get_vector espresso_pressure_goal]] \
        ]

        set flow [huddle create \
            flow [huddle list {*}[get_vector espresso_flow]] \
            by_weight [huddle list {*}[get_vector espresso_flow_weight]] \
            by_weight_raw [huddle list {*}[get_vector espresso_flow_weight_raw]] \
            goal [huddle list {*}[get_vector espresso_flow_goal]] \
        ]

        set temperature [huddle create \
            basket [huddle list {*}[get_vector espresso_temperature_basket]] \
            mix [huddle list {*}[get_vector espresso_temperature_mix]] \
            goal [huddle list {*}[get_vector espresso_temperature_goal]] \
        ]

        set totals [huddle create \
            weight [huddle list {*}[get_vector espresso_weight]] \
            water_dispensed [huddle list {*}[get_vector espresso_water_dispensed]] \
        ]

        set resistance [huddle create \
            resistance [huddle list {*}[get_vector espresso_resistance]] \
            by_weight [huddle list {*}[get_vector espresso_resistance_weight]] \
        ]

        set app_data [huddle create \
            settings [huddle create {*}[array get ::settings]] \
            machine_state [huddle create {*}[array get ::DE1]] \
        ]

        set app_specifics [huddle create \
            app_name "DE1App" \
            app_version $app_version \
            data $app_data \
        ]

        set timers [huddle create]
        catch {
            foreach {name reftime} [array get ::timers] {
                set timers [huddle append timers(${name}) ${reftime}]
            }
        }

        set scale [huddle create]
        catch {
            set scale_data_temp {}
            array set scale_data [::device::scale::format_for_history scale_data_temp]
            set scale [huddle append $scale espresso_start $scale_data(espresso_start) scale_raw_weight $scale_data(scale_raw_weight) scale_raw_arrival $scale_data(scale_raw_arrival)]
        }

        set beanweight $::settings(grinder_dose_weight)
        if { $beanweight eq "" } {
            if {[info exists file_sets(DSx_bean_weight)] == 1} {
                set shot_data(grinder_dose_weight) $::settings(DSx_bean_weight)
            } elseif {[info exists file_sets(bean_weight)] == 1} {
                set shot_data(grinder_dose_weight) $::settings(bean_weight)
            } elseif {[info exists file_sets(dsv4_bean_weight)] == 1} {
                set shot_data(grinder_dose_weight) $::settings(dsv4_bean_weight)
            } elseif {[info exists file_sets(dsv3_bean_weight)] == 1} {
                set shot_data(grinder_dose_weight) $::settings(dsv3_bean_weight)
            } elseif {[info exists file_sets(dsv2_bean_weight)] == 1} {
                set shot_data(grinder_dose_weight) $::settings(dsv2_bean_weight)
            }
        }

        set out [ifexists ::settings(drink_weight)]
        if {$out eq {} || $out == 0} {
            set out [ifexists ::de1(pour_volume)]
        }

        set time 0
        if {[espresso_elapsed length] > 0} {
            set time  [round_to_one_digits [espresso_elapsed range end end]]
        }
        set meta [huddle create \
            bean [huddle create \
                brand [ifexists ::settings(bean_brand)] \
                type [ifexists ::settings(bean_type)] \
                notes [ifexists ::settings(bean_notes)] \
                roast_level [ifexists ::settings(roast_level)] \
                roast_date [ifexists ::settings(roast_date)] \
            ]\
            shot [huddle create \
                enjoyment [ifexists ::settings(espresso_enjoyment)] \
                notes [ifexists ::settings(espresso_notes)] \
                tds [ifexists ::settings(drink_tds)] \
                ey [ifexists ::settings(drink_ey)] \
            ] \
            grinder [huddle create \
                model [ifexists ::settings(grinder_model)] \
                setting [ifexists ::settings(grinder_setting)] \
            ] \
            in $beanweight \
            out [ifexists ::settings(drink_weight)] \
            time $time \
        ]

        ::profile::sync_from_legacy
        set espresso_data [huddle create \
            version 2 \
            clock $clock \
            date $date \
            timestamp $clock \
            elapsed [huddle list {*}[get_vector espresso_elapsed]] \
            timers $timers \
            pressure $pressure \
            flow $flow \
            temperature $temperature \
            scale $scale \
            totals $totals \
            resistance $resistance \
            state_change [huddle list {*}[get_vector espresso_state_change]] \
            profile $::profile::current \
            meta $meta \
            app $app_specifics \
        ]

        set json [huddle jsondump $espresso_data]
        set last [json::json2dict $json]
        return $json
    }

    proc parse_file {shot_file} {
        set shot {}
        catch {
            set shot_file_contents [read_file "[homedir]/history_v2/$shot_file"]
            set shot [json::json2dict $shot_file_contents]

            dict set shot filename $shot_file
        }
        return $shot
    }

    proc list_last {{limit 100}} {
        set result {}
        set files [lsort -dictionary -decreasing [glob -nocomplain -tails -directory "[homedir]/history_v2/" *.json]]
        set cnt 0

        msg -INFO [namespace current] "Requesting $limit history items"

        # TODO this could be an array slice?
        foreach shot_file $files {
            set tailname [file tail $shot_file]
            if {$cnt == $limit} {
                break;
            }

            lappend result $tailname
            incr cnt
        }
        return $result
    }

    proc load_history_field {target field} {
        if {[info exists ::past_shot($field)] == 1} {
            set value [set ::past_shot($field)]
            $target set $value
        } else {
            $target clear
            msg "Variable $field does not exist"
        }
    }

    proc read_past_legacy_shot {} {
        load_history_field espresso_elapsed            espresso_elapsed
        load_history_field espresso_pressure_goal      espresso_pressure_goal
        load_history_field espresso_pressure           espresso_pressure
        load_history_field espresso_flow_goal          espresso_flow_goal
        load_history_field espresso_flow               espresso_flow
        load_history_field espresso_flow_weight        espresso_flow_weight
        load_history_field espresso_weight             espresso_weight
        load_history_field espresso_temperature_basket espresso_temperature_basket
        load_history_field espresso_temperature_mix    espresso_temperature_mix
        load_history_field espresso_temperature_goal   espresso_temperature_goal
        # New 1.34.5 shot fields
        load_history_field espresso_temperature_goal       espresso_temperature_goal
        load_history_field espresso_state_change           espresso_state_change
        load_history_field espresso_resistance_weight      espresso_resistance_weight
        load_history_field espresso_resistance             espresso_resistance
        load_history_field espresso_flow_delta_negative_2x espresso_flow_delta_negative_2x
        load_history_field espresso_flow_delta_negative    espresso_flow_delta_negative
        load_history_field espresso_pressure_delta         espresso_pressure_delta
    }

    proc convert_all_legacy_to_v2 {} {
        set dirs [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/history/" *.shot]]

        borg toast [translate "Converting old shot files"]

        blt::vector create espresso_elapsed god_espresso_elapsed god_espresso_pressure steam_pressure steam_temperature steam_temperature100th steam_flow steam_elapsed espresso_pressure espresso_flow god_espresso_flow espresso_flow_weight god_espresso_flow_weight espresso_flow_weight_2x god_espresso_flow_weight_2x espresso_flow_2x god_espresso_flow_2x espresso_flow_delta espresso_pressure_delta espresso_temperature_mix espresso_temperature_basket god_espresso_temperature_basket espresso_state_change espresso_pressure_goal espresso_flow_goal espresso_flow_goal_2x espresso_temperature_goal espresso_weight espresso_weight_chartable espresso_resistance_weight espresso_resistance
        blt::vector create espresso_de1_explanation_chart_pressure espresso_de1_explanation_chart_flow espresso_de1_explanation_chart_elapsed espresso_de1_explanation_chart_elapsed_flow espresso_water_dispensed espresso_flow_weight_raw espresso_de1_explanation_chart_temperature  espresso_de1_explanation_chart_temperature_10 espresso_de1_explanation_chart_selected_step
        blt::vector create espresso_de1_explanation_chart_flow_1 espresso_de1_explanation_chart_elapsed_flow_1 espresso_de1_explanation_chart_flow_2 espresso_de1_explanation_chart_elapsed_flow_2 espresso_de1_explanation_chart_flow_3 espresso_de1_explanation_chart_elapsed_flow_3
        blt::vector create espresso_de1_explanation_chart_elapsed_1 espresso_de1_explanation_chart_elapsed_2 espresso_de1_explanation_chart_elapsed_3 espresso_de1_explanation_chart_pressure_1 espresso_de1_explanation_chart_pressure_2 espresso_de1_explanation_chart_pressure_3
        blt::vector create espresso_de1_explanation_chart_flow_2x espresso_de1_explanation_chart_flow_1_2x espresso_de1_explanation_chart_flow_2_2x espresso_de1_explanation_chart_flow_3_2x
        blt::vector create espresso_flow_delta_negative espresso_flow_delta_negative_2x
        # Beware all the shot handling commands use the settings, so the export process overwrites the settings
        # with those from the shot, and we must be careful to restore them afterwards.
        backup_settings

        foreach d $dirs {
            set fn "[homedir]/history/${d}"
            set fbasename [file rootname [file tail $d]]
            if {[file exists "[homedir]/history_v2/${fbasename}.json"]} {
                continue
            }

            convert_legacy_to_v2 $fn "[homedir]/history_v2" "${fbasename}.json" 0
        }

        array set ::settings [array get ::settings_backup]
        unset -nocomplain ::settings_backup
        blt::vector destroy espresso_elapsed god_espresso_elapsed god_espresso_pressure steam_pressure steam_temperature steam_temperature100th steam_flow steam_elapsed espresso_pressure espresso_flow god_espresso_flow espresso_flow_weight god_espresso_flow_weight espresso_flow_weight_2x god_espresso_flow_weight_2x espresso_flow_2x god_espresso_flow_2x espresso_flow_delta espresso_pressure_delta espresso_temperature_mix espresso_temperature_basket god_espresso_temperature_basket espresso_state_change espresso_pressure_goal espresso_flow_goal espresso_flow_goal_2x espresso_temperature_goal espresso_weight espresso_weight_chartable espresso_resistance_weight espresso_resistance
        blt::vector destroy espresso_de1_explanation_chart_pressure espresso_de1_explanation_chart_flow espresso_de1_explanation_chart_elapsed espresso_de1_explanation_chart_elapsed_flow espresso_water_dispensed espresso_flow_weight_raw espresso_de1_explanation_chart_temperature  espresso_de1_explanation_chart_temperature_10 espresso_de1_explanation_chart_selected_step
        blt::vector destroy espresso_de1_explanation_chart_flow_1 espresso_de1_explanation_chart_elapsed_flow_1 espresso_de1_explanation_chart_flow_2 espresso_de1_explanation_chart_elapsed_flow_2 espresso_de1_explanation_chart_flow_3 espresso_de1_explanation_chart_elapsed_flow_3
        blt::vector destroy espresso_de1_explanation_chart_elapsed_1 espresso_de1_explanation_chart_elapsed_2 espresso_de1_explanation_chart_elapsed_3 espresso_de1_explanation_chart_pressure_1 espresso_de1_explanation_chart_pressure_2 espresso_de1_explanation_chart_pressure_3
        blt::vector destroy espresso_de1_explanation_chart_flow_2x espresso_de1_explanation_chart_flow_1_2x espresso_de1_explanation_chart_flow_2_2x espresso_de1_explanation_chart_flow_3_2x
        blt::vector destroy espresso_flow_delta_negative espresso_flow_delta_negative_2x

    }

    proc convert_legacy_to_v2 { file {target_dir {}} {target_filename {}} {create_vectors 1} } {
        if { [file exists $file] } {
            set fn $file
        } elseif { [file exists "[homedir]/history/$file"] } {
            set fn "[homedir]/history/$file"
        } else {
            msg -ERROR [namespace current] "can't find file '$file' to convert"
            return {}
        }
        
        borg toast [translate "Converting shot file"]

        if { [string is true $create_vectors] } {
            foreach sn [espresso_chart_structures] {
                blt::vector create $sn
            }
            # Beware all the shot handling commands use the settings, so the export process overwrites the settings
            # with those from the shot, and we must be careful to restore them afterwards.
            backup_settings
        }
        
        if { $target_dir eq {} } {
            set target_dir "[homedir]/history_v2"
        }
        if { $target_filename eq {} } {
            set target_filename "[file rootname [file tail $fn]].json"
        }
        set target_file "${target_dir}/${target_filename}"

        msg -INFO [namespace current] "Converting shot '$fn' to version 2, target '$target_file'"

        if {[catch {
            array set ::past_shot [encoding convertfrom utf-8 [read_binary_file $fn]]
            # BEWARE we are overwritting the whole settings! If something fails the app will stay with an old 
            # version of the settings (as of the time of the imported shot)
            array set ::settings $::past_shot(settings)

            read_past_legacy_shot
            ::profile::sync_from_legacy
            set data [create]
            write_file $target_file $data
        } err] != 0} { 
            msg -ERROR "Error while converting $file :" $err
            borg toast [translate "Failure while converting. Please check logs"]
        }

        if { [string is true $create_vectors] } {
            array set ::settings [array get ::settings_backup]
            unset -nocomplain ::settings_backup
            foreach sn [espresso_chart_structures] {
                blt::vector destroy $sn
            }
        }
        
        return $target_file
    }
}
