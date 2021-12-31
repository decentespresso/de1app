### By Damian Brakel ###
set plugin_name "D_Flow_Espresso_Profile"


namespace eval ::plugins::${plugin_name} {

    # These are shown in the plugin selection page
    variable author "Damian"
    variable contact "via Diaspora"
    variable description "D-Flow is a simple to use advanced profile"
    variable version 1.6
    variable min_de1app_version {1.36.7}



proc check_Roboto-Regular_exists {} {
    if {[file exists "[homedir]/fonts/Roboto-Regular.ttf"] != 1} {
        file copy -force [homedir]/skins/DSx/DSx_Font_Files/Roboto-Regular.ttf [homedir]/fonts/Roboto-Regular.ttf
    }
}

### Info messages
set temp_info "Higher temperature helps extract the soluble compounds,\r however it also increases harsher tasts too."
set infuse_info "A longer infusion increases body, but it also reduces puck resistance during the pour.\rWhich means we would need to grind finer to maintain the same pour pressure/flow rates.\rFiner grinds also reduce body and can increase bitterness, so we try to ballence for our prefered outcome.\r A longer infusion also means we have a higher pecentage of the shot being at 3 bar.\r 2g to 5g is a good starting range."
set pour_info "Using flow and pressure limits allows for a greater grind range, giving better control and resulting in less wasted shots.\rIncreasing pressure will shift taste from wine like to a more syrupy texture, it also\rshifts tastes from clear delicate flavours to more muddled flavours. Faster flows can increase clarity in ligher roasts,\rslower flow can help increase intensity and body in darker than light roasts"
set stop_info "Increasing the extraction ratio will shift the taste from\rSour > Sweet > Bitter"

check_Roboto-Regular_exists
################# Check / write profile
proc set_Dflow_default {} {
    set ::settings(advanced_shot) {{exit_if 1 flow 8 volume 100 max_flow_or_pressure_range 0.2 transition fast exit_flow_under 0 temperature 86.0 weight 5.00 name Filling pressure 2.00 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 max_flow_or_pressure 0 exit_pressure_over 1.50 seconds 25.00 exit_pressure_under 0} {exit_if 0 flow 8 volume 100.00 max_flow_or_pressure_range 0.2 transition fast exit_flow_under 0 temperature 88.0 weight 4.00 name Infusing pressure 3.0 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 max_flow_or_pressure 0 exit_pressure_over 3.0 seconds 60.0 exit_pressure_under 0} {exit_if 0 flow 2.0 volume 0 max_flow_or_pressure_range 0.2 transition fast exit_flow_under 0 temperature 88.0 weight 0.00 name Pouring pressure 4.8 sensor coffee pump flow exit_type flow_over exit_flow_over 2.80 max_flow_or_pressure 8.5 exit_pressure_over 11 seconds 127 exit_pressure_under 0}}
    set ::settings(espresso_temperature_steps_enabled) 0
    set ::settings(author) Damian
    set ::settings(espresso_hold_time) 16
    set ::settings(preinfusion_time) 20
    set ::settings(espresso_pressure) 6.0
    set ::settings(espresso_decline_time) 30
    set ::settings(pressure_end) 4.0
    set ::settings(espresso_temperature) 86.0
    set ::settings(espresso_temperature_0) 86.0
    set ::settings(espresso_temperature_1) 86.0
    set ::settings(espresso_temperature_2) 86.0
    set ::settings(espresso_temperature_3) 86.0
    set ::settings(settings_profile_type) settings_2c
    set ::settings(flow_profile_preinfusion) 4
    set ::settings(flow_profile_preinfusion_time) 5
    set ::settings(flow_profile_hold) 2
    set ::settings(flow_profile_hold_time) 8
    set ::settings(flow_profile_decline) 1.2
    set ::settings(flow_profile_decline_time) 17
    set ::settings(flow_profile_minimum_pressure) 4
    set ::settings(preinfusion_flow_rate) 4
    set ::settings(profile_notes) {Damian's D-Flow profile. A simple to use advanced profile
        By Damian Brakel https://www.diy.brakel.com.au/}
    set ::settings(final_desired_shot_volume) 36
    set ::settings(final_desired_shot_weight) 54
    set ::settings(final_desired_shot_weight_advanced) 54
    set ::settings(tank_desired_water_temperature) 0
    set ::settings(final_desired_shot_volume_advanced) 0
    set ::settings(profile_language) en
    set ::settings(preinfusion_stop_pressure) 4.0
    set ::settings(profile_hide) 0
    set ::settings(final_desired_shot_volume_advanced_count_start) 2
    set ::settings(beverage_type) espresso
    set ::settings(maximum_pressure) 0
    set ::settings(maximum_pressure_range_advanced) 0.2
    set ::settings(maximum_flow_range_advanced) 0.2
    set ::settings(maximum_flow) 0
    set ::settings(maximum_pressure_range_default) 0.9
    set ::settings(maximum_flow_range_default) 1.0
    set ::settings(active_settings_tab) "settings_1"
    prep
}

proc prep { args } {
    set title_test [string range [ifexists ::settings(profile_title)] 0 7]
    if {$title_test == "D-Flow /" } {

        array set filling [lindex $::settings(advanced_shot) 0]
        set ::Dflow_filling_temperature $filling(temperature)

        array set soaking [lindex $::settings(advanced_shot) 1]
        set ::Dflow_soaking_seconds [round_to_one_digits $soaking(seconds)]
        set ::Dflow_soaking_volume $soaking(volume)
        set ::Dflow_soaking_weight $soaking(weight)

        array set pouring [lindex $::settings(advanced_shot) 2]
        set ::Dflow_pouring_flow [round_to_one_digits $pouring(flow)]
        set ::Dflow_pouring_pressure $pouring(max_flow_or_pressure)
        set ::Dflow_pouring_temperature $pouring(temperature)
    }
}

if {[file exists "[homedir]/profiles/D-Flow____default.tcl"] != 1} {
    set ::settings(profile_title) {D-Flow / default}
    set_Dflow_default
    set ::settings(original_profile_title) $::settings(profile_title)
    set ::settings(profile_filename) "D-Flow____default"
    set ::settings(profile_to_save) $::settings(profile_title)
    save_profile
}


################# variables
if {$::settings(active_settings_tab) == "settings_2c"} {
    set ::settings(active_settings_tab) "settings_1"
}
set settings_tab_font "Helv_10_bold"
set botton_button_font "Helv_10_bold"
set listbox_font "Helv_10"
if {[language] == "ar"} {
	set settings_tab_font "Helv_15_bold"
	set botton_button_font "Helv_15_bold"
} elseif {[language] == "he"} {
	set settings_tab_font "Helv_10_bold"
	set botton_button_font "Helv_12_bold"
} elseif {[language] == "zh-hans" || [language] == "zh-hant" || [language] == "kr"} {
	set settings_tab_font "Helv_15_bold"
	set botton_button_font "Helv_15_bold"
} elseif {[language] != "en" && [language] != "kr" && [language] != "zh-hans" && [language] != "zh-hant"} {
	set settings_tab_font "Helv_8_bold"
}

set page_name Dflowset
set font "Roboto-Regular"
set font_colour #7f879a
set icon_colour #7f879a
set button_outline_colour #eee
set button_outline_width 2

prep

################ procedures
proc update_D-Flow {} {
    array set filling [lindex $::settings(advanced_shot) 0]
    array set soaking [lindex $::settings(advanced_shot) 1]
    array set pouring [lindex $::settings(advanced_shot) 2]
    set filling(temperature) $::Dflow_filling_temperature
    set soaking(temperature) $::Dflow_pouring_temperature
    set soaking(seconds) $::Dflow_soaking_seconds
    set soaking(volume) $::Dflow_soaking_volume
    set soaking(weight) $::Dflow_soaking_weight
    set pouring(temperature) $::Dflow_pouring_temperature
    set pouring(flow) $::Dflow_pouring_flow
    set pouring(max_flow_or_pressure) $::Dflow_pouring_pressure
    set newprofile {}
    lappend newprofile [array get filling]
    lappend newprofile [array get soaking]
    lappend newprofile [array get pouring]
    set ::settings(advanced_shot) $newprofile
    range_check_shot_variables
    profile_has_changed_set
    ::plugins::D_Flow_Espresso_Profile::demo_graph
}

proc format_seconds {n} {
	set num [round_to_integer $n]
	if {$num == 0} {
		set output [translate "off"]
	} elseif {$num == 1} {
		set output [subst {$num [translate "sec"]}]
	} elseif {$num == 60} {
		set output [translate "1 min"]
	} elseif {$num > 60} {
		set m [round_to_integer [expr {$num / 60}]]
		set s [round_to_integer [expr {$num - ($m * 60)}]]
		set min [translate "m"]
		set sec [translate "s"]
		set output $m$min$s$sec
	} else {
		set output [subst {$num [translate "sec"]}]
	}
	return $output
}

proc format_SAW {n} {

	if {$n == 0 || $n == ""} {
		return [translate "off"]
	} else {
	    if {$::de1(language_rtl) == 1} {
			return [subst {[translate "g"][round_to_one_digits $n]}]
		}
		if {$::settings(enable_fluid_ounces) != 1} {
			return [subst {[round_to_one_digits $n][translate "g"]}]
		} else {
			return [subst {[round_to_one_digits [ml_to_oz $n]] oz}]
		}
	}
}

proc save_D-Flow_profile {} {
    set pre "D-Flow____"
    set df "D-Flow / "
    set profile_filename $pre$::DFlow_name
    set title_test [string range [ifexists ::settings(profile_title)] 0 7]
    if {[file exists "[homedir]/profiles/${profile_filename}.tcl"] != 1} {
        if {$title_test == "D-Flow /" } {
            set ::settings(profile_title) $df$::DFlow_name;
        } else {
            set ::settings(profile_title) $::DFlow_name;
        }
        borg toast [translate "Saved"]
        save_profile
        ::plugins::D_Flow_Espresso_Profile::demo_graph

    } else {
        set ::Dflow_message "$df$::DFlow_name [translate "already exists"]"
        after 1200 {set ::Dflow_message ""}
    }

}

proc tap_to_update {} {
    if {$::settings(profile_has_changed) == 1} {
        return "*tap to save"
    } else {
        return ""
    }
}

proc extraction_ratio {} {
    if {$::settings(final_desired_shot_volume_advanced) > 0 && $::settings(final_desired_shot_volume_advanced) < $::settings(final_desired_shot_weight_advanced)} {
	    set b "extraction ratio 1 : "
        set r [round_to_one_digits [expr (0.01 + $::settings(final_desired_shot_volume_advanced))/$::settings(grinder_dose_weight)]]
        return $b$r
	} else {
	    set b "extraction ratio  (1 : "
        set r [round_to_one_digits [expr (0.01 + $::settings(final_desired_shot_weight_advanced))/$::settings(grinder_dose_weight)]])
        return $b$r
	}

}


################ page
add_de1_page $page_name "settings_2c2.png" "default"
dui add canvas_item rect $page_name 0 1424 1300 1600 -fill "#d7d9e6" -width 0
dui add canvas_item rect $page_name 14 950 2546 1420 -fill #ededfa -width 0
dui add canvas_item rect $page_name 100 1050 2460 1400 -fill #fff -width 3 -outline #e9e9ed

dui add variable $page_name 400 450 -justify center -anchor center -font [dui font get $font 16] -fill #ff574a -textvariable {$::Dflow_message}
dui add variable $page_name 980 186 -justify center -anchor center -font [dui font get $font 12] -fill #333 -textvariable {[::plugins::D_Flow_Espresso_Profile::tap_to_update]}

dui add dtext $page_name 1170 270  -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -text {| <}
dui add dtext $page_name 2270 270 -tags inpor -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -text {> |}
dui add dtext $page_name 1330 270 -tags inpoi -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -text {Infuse}
dui add dtext $page_name 1870 270 -tags inpop -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -text {Pour}
dui add dtext $page_name 1500 270 -tags inpoc -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -text {> | <}

dui add dtext $page_name 300 1000 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -text {Temperature}
dui add dtext $page_name 200 1080 -justify center -anchor center -font [dui font get $font 14] -fill $font_colour -text {Infuse}
dui add dtext $page_name 400 1080 -justify center -anchor center -font [dui font get $font 14] -fill $font_colour -text {Pour}
dui add variable $page_name 200 1250 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -textvariable {[return_temperature_setting $::Dflow_filling_temperature]}
dui add variable $page_name 400 1250 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -textvariable {[return_temperature_setting $::Dflow_pouring_temperature]}

dui add dtext $page_name 980 980 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -text {Infuse until}
dui add dtext $page_name 980 1026 -justify center -anchor center -font [dui font get $font 15] -fill $font_colour -text {which ever comes first}

dui add dtext $page_name 780 1080 -justify center -anchor center -font [dui font get $font 14] -fill $font_colour -text {time}
dui add dtext $page_name 980 1080 -justify center -anchor center -font [dui font get $font 14] -fill $font_colour -text {volume}
dui add dtext $page_name 1180 1080 -justify center -anchor center -font [dui font get $font 14] -fill $font_colour -text {weight}
dui add variable $page_name 780 1250 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -textvariable {[::plugins::D_Flow_Espresso_Profile::format_seconds $::Dflow_soaking_seconds]}
dui add variable $page_name 980 1250 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -textvariable {[return_stop_at_volume_measurement $::Dflow_soaking_volume]}
dui add variable $page_name 1180 1250 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -textvariable {[::plugins::D_Flow_Espresso_Profile::format_SAW $::Dflow_soaking_weight]}

dui add dtext $page_name 1660 1000 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -text {Pour limits}
dui add dtext $page_name 1560 1080 -justify center -anchor center -font [dui font get $font 14] -fill $font_colour -text {Flow}
dui add dtext $page_name 1760 1080 -justify center -anchor center -font [dui font get $font 14] -fill $font_colour -text {Pressure}
dui add variable $page_name 1560 1250 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -textvariable {[return_flow_measurement $::Dflow_pouring_flow]}
dui add variable $page_name 1760 1250 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -textvariable {[return_pressure_measurement $::Dflow_pouring_pressure]}

dui add dtext $page_name 2260 980 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -text {Stop at}
dui add variable $page_name 2260 1026 -justify center -anchor center -font [dui font get $font 15] -fill $font_colour -textvariable {[::plugins::D_Flow_Espresso_Profile::extraction_ratio]}
dui add dtext $page_name 2160 1080 -justify center -anchor center -font [dui font get $font 14] -fill $font_colour -text {volume}
dui add dtext $page_name 2360 1080 -justify center -anchor center -font [dui font get $font 14] -fill $font_colour -text {weight}

dui add variable $page_name 2160 1250 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -textvariable {[return_stop_at_volume_measurement $::settings(final_desired_shot_volume_advanced)]}
dui add variable $page_name 2360 1250 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -textvariable {[return_stop_at_weight_measurement $::settings(final_desired_shot_weight_advanced)]}

dui add variable $page_name 40 1550 -justify left -anchor w -font [dui font get "Font Awesome 5 Pro-Regular-400" 14] -fill #aaa -textvariable {\uf129 = more info is available}


### Bean weight
dui add dtext $page_name 380 800 -justify center -anchor center -font [dui font get $font 14] -fill $font_colour -text {Bean weight}
dui add variable $page_name 380 850 -justify center -anchor center -font [dui font get $font 18] -fill $font_colour -textvariable {[return_weight_measurement $::settings(grinder_dose_weight)]}

dui add dbutton $page_name 180 770 \
    -bwidth 400 -bheight 160  \
    -shape outline -width $button_outline_width -outline $button_outline_colour

dui add dbutton $page_name 180 750 \
    -bwidth 200 -bheight 200  \
    -label \uf104 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::settings(grinder_dose_weight) [expr {$::settings(grinder_dose_weight) - 0.1}]
        set ::DSx_settings(bean_weight) $::settings(grinder_dose_weight)

    }

dui add dbutton $page_name 380 750 \
    -bwidth 200 -bheight 200 \
    -label \uf105 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::settings(grinder_dose_weight) [expr {$::settings(grinder_dose_weight) + 0.1}]
        set ::DSx_settings(bean_weight) $::settings(grinder_dose_weight)
    }

### Temperature buttons
dui add dbutton $page_name 100 1050 \
    -bwidth 200 -bheight 200 -tags fill_temp_up \
    -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_filling_temperature [expr {$::Dflow_filling_temperature + 1}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }

dui add dbutton $page_name 100 1250 \
    -bwidth 200 -bheight 200 -tags fill_temp_down \
    -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_filling_temperature [expr {$::Dflow_filling_temperature - 1}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }

dui add dbutton $page_name 300 1050 \
    -bwidth 200 -bheight 200 -tags pour_temp_up \
    -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_pouring_temperature [expr {$::Dflow_pouring_temperature + 1}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }

dui add dbutton $page_name 300 1250 \
    -bwidth 200 -bheight 200 -tags pour_temp_down \
    -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_pouring_temperature [expr {$::Dflow_pouring_temperature - 1}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }

### Move on buttons
dui add dbutton $page_name 680 1050 \
    -bwidth 200 -bheight 200 -tags soak_seconds_up \
    -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_soaking_seconds [expr {$::Dflow_soaking_seconds + 1}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }

dui add dbutton $page_name 680 1250 \
    -bwidth 200 -bheight 200 -tags soak_seconds_down \
    -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_soaking_seconds [expr {$::Dflow_soaking_seconds - 1}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }

dui add dbutton $page_name 880 1050 \
    -bwidth 200 -bheight 200 -tags soak_volume_up \
    -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_soaking_volume [expr {$::Dflow_soaking_volume + 1}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }

dui add dbutton $page_name 880 1250 \
    -bwidth 200 -bheight 200 -tags soak_volume_down \
    -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_soaking_volume [expr {$::Dflow_soaking_volume - 1}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }

dui add dbutton $page_name 1080 1050 \
    -bwidth 200 -bheight 200 -tags soak_weight_up \
    -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_soaking_weight [expr {$::Dflow_soaking_weight + 0.5}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }

dui add dbutton $page_name 1080 1250 \
    -bwidth 200 -bheight 200 -tags soak_weight_down \
    -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_soaking_weight [expr {$::Dflow_soaking_weight - 0.5}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }


### pour buttons

dui add dbutton $page_name 1460 1050 \
    -bwidth 200 -bheight 200 -tags pouring_flow_up \
    -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_pouring_flow [expr {$::Dflow_pouring_flow + 0.1}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }

dui add dbutton $page_name 1460 1250 \
    -bwidth 200 -bheight 200 -tags pouring_flow_down \
    -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_pouring_flow [expr {$::Dflow_pouring_flow - 0.1}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }

dui add dbutton $page_name 1660 1050 \
    -bwidth 200 -bheight 200 -tags pouring_pressure_up \
    -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_pouring_pressure [expr {$::Dflow_pouring_pressure + 0.1}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }

dui add dbutton $page_name 1660 1250 \
    -bwidth 200 -bheight 200 -tags pouring_pressure_down \
    -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::Dflow_pouring_pressure [expr {$::Dflow_pouring_pressure - 0.1}]
        ::plugins::D_Flow_Espresso_Profile::update_D-Flow
    }

### stop

dui add dbutton $page_name 2060 1050 \
    -bwidth 200 -bheight 200 -tags SAV_up \
    -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::settings(final_desired_shot_volume_advanced) [expr {$::settings(final_desired_shot_volume_advanced) + 1}]
        range_check_shot_variables
        profile_has_changed_set
        ::plugins::D_Flow_Espresso_Profile::demo_graph
    }

dui add dbutton $page_name 2060 1250 \
    -bwidth 200 -bheight 200 -tags SAV_down \
    -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::settings(final_desired_shot_volume_advanced) [expr {$::settings(final_desired_shot_volume_advanced) - 1}]
        range_check_shot_variables
        profile_has_changed_set
        ::plugins::D_Flow_Espresso_Profile::demo_graph
    }

dui add dbutton $page_name 2260 1050 \
    -bwidth 200 -bheight 200 -tags SAW_up \
    -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::settings(final_desired_shot_weight_advanced) [expr {$::settings(final_desired_shot_weight_advanced) + 1}]
        range_check_shot_variables
        profile_has_changed_set
        ::plugins::D_Flow_Espresso_Profile::demo_graph
    }

dui add dbutton $page_name 2260 1250 \
    -bwidth 200 -bheight 200 -tags SAW_down \
    -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        set ::settings(final_desired_shot_weight_advanced) [expr {$::settings(final_desired_shot_weight_advanced) - 1}]
        range_check_shot_variables
        profile_has_changed_set
        ::plugins::D_Flow_Espresso_Profile::demo_graph
    }

#set defaults
dui add dbutton $page_name 100 250 \
    -bwidth 600 -bheight 160 \
    -shape outline -width $button_outline_width -outline $button_outline_colour \
    -label "load default values" -label_font [dui font get $font 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        ::plugins::D_Flow_Espresso_Profile::set_Dflow_default
        ::plugins::D_Flow_Espresso_Profile::demo_graph
        set ::settings(profile_has_changed) 1
    }

dui add dbutton $page_name 100 480 \
    -bwidth 600 -bheight 100 \
    -shape outline -width $button_outline_width -outline $button_outline_colour \
    -label "Save as" -label_font [dui font get $font 18] -label_fill $icon_colour -label_pos {0.5 0.5} \
    -command {
        say [translate {save}] $::settings(sound_button_in)

        ::plugins::D_Flow_Espresso_Profile::save_D-Flow_profile
    }


dui add dtext $page_name 100 610 -justify center -anchor nw -font [dui font get $font 16] -fill $font_colour -text {D-Flow / }

add_de1_widget $page_name entry 270 600  {
    set ::globals(widget_profile_name_to_save) $widget
    bind $widget <Return> { say [translate {save}] $::settings(sound_button_in)
    ::plugins::D_Flow_Espresso_Profile::save_D-Flow_profile; hide_android_keyboard}
    bind $widget <Leave> hide_android_keyboard
} -width [expr {int(19 * $::globals(entry_length_multiplier))}] -font Helv_8  -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -textvariable ::DFlow_name -relief flat  -highlightthickness 1 -highlightcolor #000000



############### Adapted navigation buttons from original settings
### tabs
add_de1_text $page_name 380 100 -text [translate "PRESETS"] -font $settings_tab_font -fill "#7f879a" -anchor "center"
set ::tab2_profile_label [add_de1_variable $page_name 1010 80 -text "" -font $settings_tab_font -fill "#2d3046"  -justify "center" -anchor "center" -textvariable {[setting_profile_type_to_text]}]
add_de1_variable $page_name 1010 130 -text "" -font Helv_7 -fill "#2d3046"  -justify "center" -anchor "center" -textvariable {[wrapped_profile_title]}
add_de1_text $page_name 1650 100 -text [translate "MACHINE"] -font $settings_tab_font -fill "#7f879a" -anchor "center"
add_de1_text $page_name 2270 100 -text [translate "APP"] -font $settings_tab_font -fill "#7f879a" -anchor "center"
add_de1_button $page_name {after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off "settings_1"; page_show off; set ::settings(active_settings_tab) "settings_1"; set_profiles_scrollbar_dimensions} 0 0 641 188
add_de1_button $page_name {say [translate {save}] $::settings(sound_button_in); set ::settings(original_profile_title) $::settings(profile_title); if {$::settings(profile_has_changed) == 1} { borg toast [translate "Saved"]; save_profile; ::plugins::D_Flow_Espresso_Profile::demo_graph} } 642 0 1277 188
add_de1_button $page_name {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_3; page_show settings_3; scheduler_feature_hide_show_refresh; set ::settings(active_settings_tab) "settings_3"} 1278 0 1904 188
add_de1_button $page_name {say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_4; page_show settings_4; set ::settings(active_settings_tab) "settings_4"; set_ble_scrollbar_dimensions; set_ble_scale_scrollbar_dimensions} 1905 0 2560 188
########## setting_2 tab button
dui add dbutton "settings_1 settings_3 settings_4" 642 0 1277 188 \
            -bwidth 635 -bheight 188 \
            -labelvariable {} -label_font [dui font get $font 14] -label_fill $font_colour -label_pos {0.5 0.5} \
            -command {
            set title_test [string range [ifexists ::settings(profile_title)] 0 7]
            if {$title_test == "D-Flow /" } {
                ::plugins::D_Flow_Espresso_Profile::prep
                ::plugins::D_Flow_Espresso_Profile::demo_graph
                if {$::settings(skin) == "DSx"} {
                    set ::settings(grinder_dose_weight) [round_to_one_digits $::DSx_settings(bean_weight)]
                }
                dui page load Dflowset
                } else {
                after 500 update_de1_explanation_chart
                say [translate {settings}] $::settings(sound_button_in)
                set_next_page off $::settings(settings_profile_type)
                page_show off
                set ::settings(active_settings_tab) $::settings(settings_profile_type)
                fill_advanced_profile_steps_listbox
                set_advsteps_scrollbar_dimensions
                }
            }

### ok/cancel buttons
add_de1_text $page_name 2275 1520 -text [translate "Ok"] -font $botton_button_font -fill "#FFFFFF" -anchor "center"
add_de1_text $page_name 1760 1520 -text [translate "Cancel"] -font $botton_button_font -fill "#FFFFFF" -anchor "center"

add_de1_button $page_name {save_settings_to_de1; set_alarms_for_de1_wake_sleep; say [translate {save}] $::settings(sound_button_in); save_settings; profile_has_changed_set_colors;
    if {$::settings(skin) == "DSx"} {
        DSx_add_to_profile_settings_ok_button_enter
    }
    if {[ifexists ::profiles_hide_mode] == 1} {
        unset -nocomplain ::profiles_hide_mode
        fill_profiles_listbox
    }
    if {[ifexists ::settings_backup(calibration_flow_multiplier)] != [ifexists ::settings(calibration_flow_multiplier)]} {
        set_calibration_flow_multiplier $::settings(calibration_flow_multiplier)
    }
    if {[ifexists ::settings_backup(fan_threshold)] != [ifexists ::settings(fan_threshold)]} {
        set_fan_temperature_threshold $::settings(fan_threshold)
    }
    if {[ifexists ::settings_backup(water_refill_point)] != [ifexists ::settings(water_refill_point)]} {
        de1_send_waterlevel_settings
    }
    if {[array_item_difference ::settings ::settings_backup "steam_temperature steam_flow"] == 1} {
        # resend the calibration settings if they were changed
        de1_send_steam_hotwater_settings
        de1_enable_water_level_notifications
    }
    if {[array_item_difference ::settings ::settings_backup "enable_fahrenheit orientation screen_size_width saver_brightness use_finger_down_for_tap log_enabled hot_water_idle_temp espresso_warmup_timeout scale_bluetooth_address language skin waterlevel_indicator_on default_font_calibration waterlevel_indicator_blink display_rate_espresso display_espresso_water_delta_number display_group_head_delta_number display_pressure_delta_line display_flow_delta_line display_weight_delta_line allow_unheated_water display_time_in_screen_saver enabled_plugins plugin_tabs"] == 1  || [ifexists ::app_has_updated] == 1} {
        # changes that effect the skin require an app restart
        .can itemconfigure $::message_label -text [translate "Please quit and restart this app to apply your changes."]
        .can itemconfigure $::message_button_label -text [translate "Wait"]

        set_next_page off message; page_show message
        after 200 app_exit
    } else {

        if {[ifexists ::settings(settings_profile_type)] == "Dflowset"} {
            # if they were on the LIMITS tab of the Advanced profiles, reset the ui back to the main tab
            set ::settings(settings_profile_type) "Dflowset"
        }

        #set_next_page off off; page_show off
        if {$::settings(skin) == "DSx"} {
            DSx_add_to_profile_settings_ok_button_leave
        } else {
            set_next_page off off; page_show off
        }
    }
} 2016 1430 2560 1600

if {$::settings(skin) == "DSx"} {
    set ::DSx_settings(orange_cup_indicator) { }
    set ::DSx_settings(blue_cup_indicator) { }
    set ::DSx_settings(pink_cup_indicator) { }
    clear_profile_font
    add_de1_button $page_name {if {[ifexists ::profiles_hide_mode] == 1} { unset -nocomplain ::profiles_hide_mode; fill_profiles_listbox }; array unset ::settings {\*}; array set ::settings [array get ::settings_backup]; update_de1_explanation_chart; fill_skin_listbox; profile_has_changed_set_colors; say [translate {Cancel}] $::settings(sound_button_in); back_to_previous_page; fill_advanced_profile_steps_listbox; restore_espresso_chart; LRv2_preview; DSx_graph_restore; save_settings_to_de1; fill_profiles_listbox; fill_extensions_listbox; refresh_DSx_temperature; ::plugins::D_Flow_Espresso_Profile::prep} 1505 1430 2015 1600
    } else {
    add_de1_button $page_name {if {[ifexists ::profiles_hide_mode] == 1} { unset -nocomplain ::profiles_hide_mode; fill_profiles_listbox }; array unset ::settings {\*}; array set ::settings [array get ::settings_backup]; update_de1_explanation_chart; fill_skin_listbox; profile_has_changed_set_colors; say [translate {Cancel}] $::settings(sound_button_in); set_next_page off off; page_show off; fill_advanced_profile_steps_listbox; restore_espresso_chart; save_settings_to_de1; fill_profiles_listbox ; fill_extensions_listbox; ::plugins::D_Flow_Espresso_Profile::prep} 1505 1430 2015 1600
}

########## settings_1 page
set {} {
add_de1_widget "settings_1" entry 1360 1310  {
    set ::globals(widget_profile_name_to_save) $widget
    bind $widget <Return> { say [translate {save}] $::settings(sound_button_in)
    ::plugins::D_Flow_Espresso_Profile::save_D-Flow_profile; hide_android_keyboard}
    bind $widget <Leave> hide_android_keyboard
} -width [expr {int(38 * $::globals(entry_length_multiplier))}] -font Helv_8  -borderwidth 1 -bg #fbfaff  -foreground #4e85f4 -textvariable ::DFlow_name -relief flat  -highlightthickness 1 -highlightcolor #000000


dui add dbutton settings_1 2300 1220 \
    -bwidth 250 -bheight 190 \
    -command {
        say [translate {save}] $::settings(sound_button_in)
        ::plugins::D_Flow_Espresso_Profile::save_D-Flow_profile
    }
}

dui add dbutton "settings_1" 1330 220 2560 800 \
            -bwidth 1230 -bheight 580 \
            -labelvariable {} -label_font [dui font get $font 14] -label_fill $font_colour -label_pos {0.5 0.5} \
            -command {
            set title_test [string range [ifexists ::settings(profile_title)] 0 7]
            if {$title_test == "D-Flow /" } {
                ::plugins::D_Flow_Espresso_Profile::prep
                ::plugins::D_Flow_Espresso_Profile::demo_graph
                if {$::settings(skin) == "DSx"} {
                    set ::settings(grinder_dose_weight) [round_to_one_digits $::DSx_settings(bean_weight)]
                }
                dui page load Dflowset
                } else {
                after 500 update_de1_explanation_chart
                say [translate {settings}] $::settings(sound_button_in)
                set_next_page off $::settings(settings_profile_type)
                page_show off
                set ::settings(active_settings_tab) $::settings(settings_profile_type)
                fill_advanced_profile_steps_listbox
                set_advsteps_scrollbar_dimensions
                }
            }

add_de1_widget "settings_1c" graph 1330 300 {
		set ::preview_graph_advanced $widget
		update_de1_explanation_chart;
		$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure  -label "" -linewidth [rescale_x_skin 10] -color #47e098  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0;
		$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow  -label "" -linewidth [rescale_x_skin 12] -color #98c5ff  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0;
		$widget element create line_espresso_de1_explanation_chart_temp -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_temperature_10  -label "" -linewidth [rescale_x_skin 10] -color #ff888c  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0;

		$::preview_graph_advanced axis configure x -color #5a5d75 -tickfont Helv_6;
		$::preview_graph_advanced axis configure y -color #5a5d75 -tickfont Helv_6 -min 0.0 -max 12 -majorticks {1 2 3 4 5 6 7 8 9 10 11 12} -title [translate "Advanced"] -titlefont Helv_8 -titlecolor #5a5d75;
		bind $::preview_graph_advanced [platform_button_press] {
            set title_test [string range [ifexists ::settings(profile_title)] 0 7]
            if {$title_test == "D-Flow /" } {
                ::plugins::D_Flow_Espresso_Profile::prep
                ::plugins::D_Flow_Espresso_Profile::demo_graph
                if {$::settings(skin) == "DSx"} {
                    set ::settings(grinder_dose_weight) [round_to_one_digits $::DSx_settings(bean_weight)]
                }
                dui page load Dflowset
                } else {
                after 500 update_de1_explanation_chart
                say [translate {settings}] $::settings(sound_button_in)
                set_next_page off $::settings(settings_profile_type)
                page_show off
                set ::settings(active_settings_tab) $::settings(settings_profile_type)
                fill_advanced_profile_steps_listbox
                set_advsteps_scrollbar_dimensions
                }
            }
	} -plotbackground #fff -width [rescale_x_skin 1050] -height [rescale_y_skin 450] -borderwidth 1 -background #FFFFFF -plotrelief raised  -plotpady 0 -plotpadx 10


if {[info exists ::settings(D_Flow_graph_style)] == 0} {
    set ::settings(D_Flow_graph_style) "DSx"
}

proc toggle_graph {} {
    if {$::settings(D_Flow_graph_style) == "Insight"} {
        set ::settings(D_Flow_graph_style) "DSx"
    } else {
        set ::settings(D_Flow_graph_style) "Insight"
    }
    ::plugins::D_Flow_Espresso_Profile::select_flow_curve
}
proc select_flow_curve {} {
    if {$::settings(D_Flow_graph_style) == "Insight"} {
        $::Dflow_demo_graph element configure line_espresso_de1_explanation_chart_flow -ydata espresso_de1_explanation_chart_flow
        $::Dflow_demo_graph axis configure x -color #5a5d75
        $::Dflow_demo_graph axis configure y -color #5a5d75
        $::Dflow_demo_graph axis configure y2 -hide 1
        $::Dflow_demo_graph grid configure -color #ddd
        $::Dflow_demo_graph configure -plotbackground #f8f8f8 -background #fff -plotrelief raised
        dui item moveto Dflowset inpor 2270 270
    } else {
        $::Dflow_demo_graph element configure line_espresso_de1_explanation_chart_flow -ydata espresso_de1_explanation_chart_flow_2x
        $::Dflow_demo_graph axis configure x -color #5a5d75
        $::Dflow_demo_graph axis configure y -color #18c37e
        $::Dflow_demo_graph axis configure y2 -hide 0
        $::Dflow_demo_graph grid configure -color #ddd
        $::Dflow_demo_graph configure -plotbackground #f8f8f8 -background #fff -plotrelief raised
        dui item moveto Dflowset inpor 2216 270

    }
}

proc demo_graph { {context {}} } {
	set title_test [string range [ifexists ::settings(profile_title)] 0 7]
    if {$title_test == "D-Flow /" } {
        espresso_de1_explanation_chart_elapsed length 0
        espresso_de1_explanation_chart_temperature length 0
        espresso_de1_explanation_chart_temperature_10 length 0
        espresso_de1_explanation_chart_selected_step length 0
        espresso_de1_explanation_chart_pressure length 0
        espresso_de1_explanation_chart_flow length 0
        espresso_de1_explanation_chart_elapsed_flow length 0
        espresso_de1_explanation_chart_flow_2x length 0
        espresso_de1_explanation_chart_pressure append 0
        espresso_de1_explanation_chart_flow append 0
        espresso_de1_explanation_chart_elapsed append 0
        espresso_de1_explanation_chart_elapsed_flow append 0
        array set props [lindex $::settings(advanced_shot) 0]
        set c 0
        while {$c < 11} {
            incr c
            espresso_de1_explanation_chart_temperature append [ifexists props(temperature)]
            espresso_de1_explanation_chart_temperature_10 append [expr {[ifexists props(temperature)] / 10.0}]
        }
        espresso_de1_explanation_chart_pressure append {0.0 0.0 0.0 0.0 2.1 2.8 3.0 3.0 3.0 3.0 3.0}
        espresso_de1_explanation_chart_flow append {0.0 5.6 7.6 8.3 8.2 6.0 2.9 1.3 0.6 0.4 0.3}
        espresso_de1_explanation_chart_elapsed append {0.008 0.994 2.03 3.015 4.004 4.994 6.036 7.03 8.017 8.999 15}
        espresso_de1_explanation_chart_elapsed_flow append {0.008 0.994 2.03 3.015 4.004 4.994 6.036 7.03 8.017 8.999 15}
        array set props [lindex $::settings(advanced_shot) 2]
        if {$::settings(final_desired_shot_volume_advanced) > 0 && $::settings(final_desired_shot_volume_advanced) < $::settings(final_desired_shot_weight_advanced)} {
            set shotendtime [expr {$::settings(final_desired_shot_volume_advanced) / [ifexists props(flow)] + 16}]
        } else {
            set shotendtime [expr {$::settings(final_desired_shot_weight_advanced) / [ifexists props(flow)] + 16}]
        }
        espresso_de1_explanation_chart_temperature append [ifexists props(temperature)]
        espresso_de1_explanation_chart_temperature_10 append [expr {[ifexists props(temperature)] / 10.0}]
        espresso_de1_explanation_chart_pressure append [ifexists props(max_flow_or_pressure)]
        espresso_de1_explanation_chart_flow append [ifexists props(flow)]
        espresso_de1_explanation_chart_temperature append [ifexists props(temperature)]
        espresso_de1_explanation_chart_temperature_10 append [expr {[ifexists props(temperature)] / 10.0}]
        espresso_de1_explanation_chart_elapsed append 16
        espresso_de1_explanation_chart_elapsed_flow append 16
        espresso_de1_explanation_chart_pressure append [ifexists props(max_flow_or_pressure)]
        espresso_de1_explanation_chart_flow append [ifexists props(flow)]
        espresso_de1_explanation_chart_temperature append [ifexists props(temperature)]
        espresso_de1_explanation_chart_temperature_10 append [expr {[ifexists props(temperature)] / 10.0}]
        espresso_de1_explanation_chart_elapsed append $shotendtime
        espresso_de1_explanation_chart_elapsed_flow append $shotendtime
        foreach f [espresso_de1_explanation_chart_flow range 0 end] {
            espresso_de1_explanation_chart_flow_2x append [expr {2.0 * $f}]
        }
        dui item moveto Dflowset inpoc [expr {1160 + (1120 * 15 / (0.01 + $shotendtime))}] 270
        dui item moveto Dflowset inpoi [expr {1170 + ((1160 + (1120 * 15 / (0.01 + $shotendtime)) - 1170) / 2)}] 270
        if {$::settings(D_Flow_graph_style) == "Insight"} {
            set xcord 2270
        } else {
            set xcord 2216
        }
        dui item moveto Dflowset inpop [expr {$xcord - (($xcord - (1160 + (1120 * 15 / (0.01 + $shotendtime)))) / 2)}] 270

	}
}



add_de1_widget "Dflowset" graph 1060 290 {
    set ::Dflow_demo_graph $widget
    ::plugins::D_Flow_Espresso_Profile::demo_graph;

		$widget element create line_espresso_de1_explanation_chart_pressure -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_pressure  -label "" -linewidth [rescale_x_skin 10] -color #47e098  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0;
		$widget element create line_espresso_de1_explanation_chart_flow -xdata espresso_de1_explanation_chart_elapsed_flow -ydata espresso_de1_explanation_chart_flow  -label "" -linewidth [rescale_x_skin 12] -color #98c5ff  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0;
		$widget element create line_espresso_de1_explanation_chart_temp -xdata espresso_de1_explanation_chart_elapsed -ydata espresso_de1_explanation_chart_temperature_10  -label "" -linewidth [rescale_x_skin 10] -color #ff888c  -smooth $::settings(preview_graph_smoothing_technique) -pixels 0;


    $widget axis configure x -color #ddd -tickfont Helv_7 -min 0.0;
    $widget axis configure y -color #18c37e -tickfont Helv_7 -min 0.0 -max $::de1(max_pressure) -subdivisions 5 -majorticks {0  2  4  6  8  10  12}  -hide 0;
    $widget axis configure y2 -color #4e85f4 -tickfont Helv_7 -min 0.0 -max 6 -subdivisions 2 -majorticks {0  1  2  3  4  5  6} -hide 1;
    $widget grid configure -color #555
} -plotbackground #1e1e1e -width [rescale_x_skin 1250] -height [rescale_y_skin 590] -borderwidth 1 -background #1e1e1e -plotrelief flat
::plugins::D_Flow_Espresso_Profile::select_flow_curve

dui add dbutton $page_name 2320 400 \
    -bwidth 200 -bheight 200 \
    -shape outline -width $button_outline_width -outline $button_outline_colour \
    -label {showing} -label_font [dui font get $font 14] -label_justify center -label_anchor center -label_fill $font_colour -label_pos {0.5 0.28} \
    -label1variable {$::settings(D_Flow_graph_style)} -label1_justify center -label1_anchor center -label1_font [dui font get $font 18] -label1_fill $font_colour -label1_pos {0.5 0.5} \
    -label2 {style} -label2_font [dui font get $font 14] -label2_justify center -label2_anchor center -label2_fill $font_colour -label2_pos {0.5 0.72} \
    -command {
        ::plugins::D_Flow_Espresso_Profile::toggle_graph
        ::plugins::D_Flow_Espresso_Profile::demo_graph
    }

#### Info

set info " "
dui add dbutton $page_name 100 950 \
    -bwidth 400 -bheight 100 \
    -label "\uf129" -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 16] -label_fill #ccc -label_pos {0.9 0.5} \
    -command {
        dui item show Dflowset info*
        set info $::plugins::D_Flow_Espresso_Profile::temp_info
    }

dui add dbutton $page_name 710 950 \
    -bwidth 540 -bheight 100 \
    -label "\uf129" -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 16] -label_fill #ccc -label_pos {0.9 0.5} \
    -command {
        dui item show Dflowset info*
        set info $::plugins::D_Flow_Espresso_Profile::infuse_info
    }

dui add dbutton $page_name 1410 950 \
    -bwidth 500 -bheight 100 \
    -label "\uf129" -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 16] -label_fill #ccc -label_pos {0.8 0.5} \
    -command {
        dui item show Dflowset info*
        set info $::plugins::D_Flow_Espresso_Profile::pour_info
    }

dui add dbutton $page_name 2060 950 \
    -bwidth 500 -bheight 100 \
    -label "\uf129" -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 16] -label_fill #ccc -label_pos {0.85 0.5} \
    -command {
        dui item show Dflowset info*
        set info $::plugins::D_Flow_Espresso_Profile::stop_info
    }


dui add dbutton $page_name 100 1050 \
    -bwidth 2360 -bheight 350 -tags info -initial_state hidden \
    -shape rect -fill #fff \
    -label1 "Tap to close" -label1_font [dui font get $font 14] -label1_fill #ccc -label1_pos {0.5 0.95} \
    -labelvariable {$info} -label_justify center -label_anchor center -label_font [dui font get $font 18] -label_fill $font_colour -label_pos {0.5 0.5} \
    -command {
        dui item hide Dflowset info*
    }

proc D-Flow_data {} {
    set title_test [string range [ifexists ::settings(profile_title)] 0 7]
    if {$title_test == "D-Flow /" } {
        set a [round_to_integer $::Dflow_filling_temperature]
        set b [return_temperature_setting $::Dflow_pouring_temperature]
        set c [::plugins::D_Flow_Espresso_Profile::format_SAW $::Dflow_soaking_weight]
        set d [return_flow_measurement $::Dflow_pouring_flow]
        set f [return_pressure_measurement $::Dflow_pouring_pressure]
        set s {  }
        set m {-}
        return $a$m$b$s$s$c$s$s$d$s$f
    }
}
if {$::settings(skin) == "DSx"} {
    if {[file exists "[skin_directory]/DSx_Home_Page/DSx_2021_home.page"] == 1 && $::DSx_settings(DSx_home) == "2021home"} {
        dui add variable off [expr {$::DSx_data_x + 480}] [expr {$::DSx_data_y + 672}] -anchor "center" -justify "center" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -textvariable {[::plugins::D_Flow_Espresso_Profile::D-Flow_data]}
    } elseif {$::DSx_home_page_version == {} } {
        #dui add variable off 400 682 -anchor "center" -justify "center" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -textvariable {[::plugins::D_Flow_Espresso_Profile::D-Flow_data]}
    }

    trace add execution load_bluecup {leave} ::plugins::D_Flow_Espresso_Profile::prep
    trace add execution load_pinkcup {leave} ::plugins::D_Flow_Espresso_Profile::prep
    trace add execution load_orangecup {leave} ::plugins::D_Flow_Espresso_Profile::prep
}

}

