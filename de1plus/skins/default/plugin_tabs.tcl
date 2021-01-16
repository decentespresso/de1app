##############################################
#  Plugin available tabs
##############################################

add_de1_page "plugin_tab0" "plugin_tab0.jpg" "default"
add_de1_page "plugin_tab1" "plugin_tab1.jpg" "default"
add_de1_page "plugin_tab2" "plugin_tab2.jpg" "default"

add_de1_text   "plugin_tab0 plugin_tab1 plugin_tab2" 1250 1520 -text [translate "Done"] -font Helv_10_bold -fill "#FFFFFF" -anchor "center"
add_de1_button "plugin_tab0 plugin_tab1 plugin_tab2" {say [translate {Done}] $::settings(sound_button_in); page_to_show_when_off off; save_settings} 980 1480 1680 1610 ""
add_de1_button "plugin_tab0 plugin_tab1 plugin_tab2" {say "[translate Extensions]" $::settings(sound_button_in); set_next_page off "extensions"; page_show off} 0 1480 130 1610

set plugin0 [plugin_for_tab 0]
set plugin1 [plugin_for_tab 1]
set plugin2 [plugin_for_tab 2]

# The pages are set up. Let the plugins fill them if possible
if {${plugin0} != "" && [info proc ::plugins::${plugin0}::preload_tab] != "" && [plugin_enabled $plugin0]} {
    ::plugins::${plugin0}::preload_tab plugin_tab0

}

if {${plugin1} != "" && [info proc ::plugins::${plugin1}::preload_tab] != "" && [plugin_enabled $plugin1]} {
    ::plugins::${plugin1}::preload_tab plugin_tab1
}

if {${plugin2} != "" && [info proc ::plugins::${plugin2}::preload_tab] != "" && [plugin_enabled $plugin2]} {
    ::plugins::${plugin2}::preload_tab plugin_tab2
}

# The 'other' case. Tab is empty
if {${plugin0} == ""} {
    set plugin0 [translate "Unset"]
}

if {${plugin1} == ""} {
    set plugin1 [translate "Unset"]
}

if {${plugin2} == ""} {
    set plugin2 [translate "Unset"]
}

add_de1_text "plugin_tab1 plugin_tab2" 420  80 -text $plugin0 -font Helv_10_bold -width 1200 -fill "#7f879a" -anchor "center" -justify "center" 
add_de1_text "plugin_tab0 plugin_tab2" 1270 80 -text $plugin1 -font Helv_10_bold -width 1200 -fill "#7f879a" -anchor "center" -justify "center" 
add_de1_text "plugin_tab0 plugin_tab1" 2120 80 -text $plugin2 -font Helv_10_bold -width 1200 -fill "#7f879a" -anchor "center" -justify "center" 

add_de1_text "plugin_tab0" 420  80 -text $plugin0 -font Helv_10_bold -width 1200 -fill "#BBBBBB" -anchor "center" -justify "center" 
add_de1_text "plugin_tab1" 1270 80 -text $plugin1 -font Helv_10_bold -width 1200 -fill "#BBBBBB" -anchor "center" -justify "center" 
add_de1_text "plugin_tab2" 2120 80 -text $plugin2 -font Helv_10_bold -width 1200 -fill "#BBBBBB" -anchor "center" -justify "center"

add_de1_button "plugin_tab1 plugin_tab2" {say [plugin_for_tab 0] $::settings(sound_button_in); set_next_page off plugin_tab0; page_show off} 0 0 850 300
add_de1_button "plugin_tab0 plugin_tab2" {say [plugin_for_tab 1] $::settings(sound_button_in); set_next_page off plugin_tab1; page_show off} 860 0 1680 300
add_de1_button "plugin_tab0 plugin_tab1" {say [plugin_for_tab 2] $::settings(sound_button_in); set_next_page off plugin_tab2; page_show off} 1710 0 2560 300

