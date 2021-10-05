set plugin_name "hazard"

namespace eval ::plugins::${plugin_name} {

    # These are shown in the plugin selection page
    variable author "JoJo"
    variable contact "email@coffee-mail.de"
    variable version 1.0
    variable description "Hazard customizations for mimojacafe"
    variable name "Hazard customizations"

    proc main {} {
        if { $::settings(skin) != "MimojaCafe" } { return }

        set Purple "#785fd8"
        set Blue "#4e85f4"
        set Orange "#F2B705"

        if {[package vcompare [package version de1app] 1.36.5.42] < 0} {
            set pressure_explanation line_espresso_de1_explanation_chart_pressurec
            set flow_explanation line_espresso_de1_explanation_chart_flowc 
            set pressure line2_espresso_pressure 
        } else {
            set pressure_explanation line_espresso_pressure_explanation 
            set flow_explanation line_espresso_flow_explanation
            set pressure line_espresso_pressure
        }

        if {[info exists ::skin::mimojacafe::graph::espresso_magadan]} {
            msg -INFO "Configuring magadan ui"
            set widget $::skin::mimojacafe::graph::espresso_magadan
            $widget element configure $pressure -color $Purple
            $widget element configure $pressure_explanation -color $Purple
            $widget element configure line_espresso_pressure_goal -color $Purple

            $widget element configure line_espresso_flow -color $Blue
            $widget element configure $flow_explanation -color $Blue
            $widget element configure line_espresso_flow_goal -color $Blue
            if {[::device::scale::expecting_present]} {
                $widget element configure line_espresso_flow_weight -color $Orange
                $widget element configure line_espresso_flow_weight_raw -color $Orange
            }
        }

        if {[info exists ::skin::mimojacafe::graph::espresso_default]} {
            msg -INFO "Configuring default ui"
            set widget $::skin::mimojacafe::graph::espresso_default
            $widget element configure $pressure -color $Purple
            $widget element configure $pressure_explanation -color $Purple
            $widget element configure line_espresso_pressure_goal -color $Purple

            $widget element configure line_espresso_flow -color $Blue
            $widget element configure $flow_explanation -color $Blue
            $widget element configure line_espresso_flow_goal -color $Blue
            if {[::device::scale::expecting_present]} {
                $widget element configure line_espresso_flow_weight -color $Orange
                $widget element configure line_espresso_flow_weight_raw -color $Orange
            }
        }
    }
}