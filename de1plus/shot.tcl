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
            pressure [huddle list {*}[espresso_pressure range 0 end]] \
            goal [huddle list {*}[espresso_pressure_goal range 0 end]] \
        ]

        set flow [huddle create \
            flow [huddle list {*}[espresso_flow range 0 end]] \
            by_weight [huddle list {*}[espresso_flow_weight range 0 end]] \
            by_weight_raw [huddle list {*}[espresso_flow_weight_raw range 0 end]] \
            goal [huddle list {*}[espresso_flow_goal range 0 end]] \
        ]

        set temperature [huddle create \
            basket [huddle list {*}[espresso_temperature_basket range 0 end]] \
            mix [huddle list {*}[espresso_temperature_mix range 0 end]] \
            goal [huddle list {*}[espresso_temperature_goal range 0 end]] \
        ]

        set totals [huddle create \
            weight [huddle list {*}[espresso_weight range 0 end]] \
            water_dispensed [huddle list {*}[espresso_water_dispensed range 0 end]] \
        ]

        set resistance [huddle create \
            resistance [huddle list {*}[espresso_resistance range 0 end]] \
            by_weight [huddle list {*}[espresso_resistance_weight range 0 end]] \
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
        ]

        ::profile::sync_from_legacy
        set espresso_data [huddle create \
            version 2 \
            date $date \
            timestamp $clock \
            elapsed [huddle list {*}[espresso_elapsed range 0 end]] \
            timers $timers \
            pressure $pressure \
            flow $flow \
            temperature $temperature \
            scale $scale \
            totals $totals \
            resistance $resistance \
            state_change [huddle list {*}[espresso_state_change range 0 end]] \
            profile $::profile::current \
            meta $meta \
            app $app_specifics \
        ]

        set json [huddle jsondump $espresso_data]
        set last [json::json2dict $json]
        return $json
    }

    proc list_last {{limit 100} {match_profile ""}} {
        set result {}
        set files [lsort -dictionary -decreasing [glob -nocomplain -tails -directory "[homedir]/history_v2/" *.json]]
        set cnt 0

        msg -INFO [namespace current] "Requesting $limit history items with match_profile=$match_profile"

        foreach shot_file $files {
            set tailname [file tail $shot_file]
            msg -DEBUG [namespace current] "Loading $tailname"

            if {$cnt == $limit} {
                break;
            }

            array unset -nocomplain shot
            catch {
                set shot_file_contents [read_file "[homedir]/history_v2/$shot_file"]
                set shot [json::json2dict $shot_file_contents]

                dict set shot filename $tailname
                set profile_title [dict get $shot profile title]
                if {$match_profile ne "" && $profile_title eq $match_profile} {
                    continue
                } else {
                    msg -DEBUG [namespace current] "Adding $profile_title to the history list"
                    lappend result $shot
                    incr cnt
                }
            }
        }
        return $result
    }
}
