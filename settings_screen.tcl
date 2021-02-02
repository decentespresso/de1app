

add_background "iconik_settings"

create_button "iconik_settings" 580 1440 1880 1560 [translate "Done"] $::font_tiny [theme button_tertiary] [theme button_text_light] { say [translate "settings"] $::settings(sound_button_in); iconik_save_settings; page_to_show_when_off "off" }

add_de1_widget "iconik_settings" checkbutton 160 180 {} -text [translate "Show Steam Graph"] -indicatoron true  -font Helv_8 -bg [theme background] -anchor nw -foreground [theme button_text_light] -variable ::iconik_settings(show_steam)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme button_text_light] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 240 {} -text [translate "Show Water level indicator"] -indicatoron true  -font Helv_8 -bg [theme background] -anchor nw -foreground [theme button_text_light] -variable ::iconik_settings(show_water_level_indicator)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme button_text_light] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 300 {} -text [translate "Use profile for cleanup button"] -indicatoron true  -font Helv_8 -bg [theme background] -anchor nw -foreground [theme button_text_light] -variable ::iconik_settings(cleanup_use_profile)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme button_text_light] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 360 {} -text [translate "Only tare when pouring (usefull for weighing beans)"] -indicatoron true  -font Helv_8 -bg [theme background] -anchor nw -foreground [theme button_text_light] -variable ::settings(tare_only_on_espresso_start)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme button_text_light] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 420 {} -text [translate "Reconnect to the scale on espresso start"] -indicatoron true  -font Helv_8 -bg [theme background] -anchor nw -foreground [theme button_text_light] -variable ::settings(reconnect_to_scale_on_espresso_start)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme button_text_light] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 480 {} -text [translate "Try reconnecting to the scale forever (Can exhaust the tablet)"] -indicatoron true  -font Helv_8 -bg [theme background] -anchor nw -foreground [theme button_text_light] -variable ::settings(automatically_ble_reconnect_forever_to_scale)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme button_text_light] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 540 {} -text [translate "Double the scale input / Spouted portafilter scale mode"] -indicatoron true  -font Helv_8 -bg [theme background] -anchor nw -foreground [theme button_text_light] -variable ::settings(scale_stop_at_half_shot)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme button_text_light] -relief flat -bd 0

# Cleanup profile name
add_de1_text iconik_settings 180 600 -text [translate "Cleanup Profile name"] -font Helv_8 -width 300 -fill [theme button_text_light] -anchor "nw"
# The actual content. Here a list of all settings for this plugin
add_de1_widget "iconik_settings" entry 180 660  {
    set ::globals(widget_profile_name_to_save) $widget
    bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; iconik_save_settings; hide_android_keyboard}
    bind $widget <Leave> hide_android_keyboard
} -width [expr {int(38 * $::globals(entry_length_multiplier))}] -font Helv_8  -borderwidth 1 -bg [theme background_highlight]  -foreground [theme button_text_light] -textvariable ::iconik_settings(cleanup_profile) -relief flat  -highlightthickness 1 -highlightcolor [theme button_text_light]

# Screensaver folder
add_de1_text iconik_settings 180 720 -text [translate "Screensaver folder"] -font Helv_8 -width 300 -fill [theme button_text_light] -anchor "nw"
# The actual content. Here a list of all settings for this plugin
add_de1_widget "iconik_settings" entry 180 780  {
    set ::globals(widget_profile_name_to_save) $widget
    bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; iconik_save_settings; hide_android_keyboard}
    bind $widget <Leave> hide_android_keyboard
} -width [expr {int(38 * $::globals(entry_length_multiplier))}] -font Helv_8  -borderwidth 1 -bg [theme background_highlight]  -foreground [theme button_text_light] -textvariable ::iconik_settings(saver_dir) -relief flat  -highlightthickness 1 -highlightcolor [theme button_text_light]


# System Settings button
create_button "iconik_settings" 2080 240 2480 1140 [translate "System Settings"] $::font_tiny [theme button_tertiary] [theme button_text_light] { say [translate "settings"] $::settings(sound_button_in); iconik_save_settings; iconik_show_settings}


## Water Temp
create_settings_button "iconik_settings" 2080 1200 2480 1320 "" $::font_tiny [theme button_secondary] [theme button_text_light]  {  set ::settings(water_temperature) [expr {$::settings(water_temperature) - 5}]; de1_send_steam_hotwater_settings; save_settings} {  set ::settings(water_temperature) [expr {$::settings(water_temperature) + 5}]; de1_send_steam_hotwater_settings; save_settings}
add_de1_variable "iconik_settings" [expr (2080 + 2480) / 2.0 ] [expr (1200 + 1320) / 2.0 ] -width [rescale_x_skin 280]  -text "" -font $::font_tiny -fill [theme button_text_light] -anchor "center" -justify "center" -state "hidden" -textvariable {Water [iconik_water_temperature]}


# Skin theme buttons
create_button "iconik_settings" 1800 240 2000 420  "Default"  $::font_big $::default_theme(button)   $::default_theme(button_text_light) {set ::iconik_settings(theme) "::default_theme"; iconik_save_settings; borg toast "Theme changed, please restart"}
create_button "iconik_settings" 1800 480 2000 660  "Dark"     $::font_big $::dark_theme(button)      $::dark_theme(button_text_light)    {set ::iconik_settings(theme) "::dark_theme";    iconik_save_settings; borg toast "Theme changed, please restart"}
create_button "iconik_settings" 1800 720 2000 900  "Purple"   $::font_big $::purple_theme(button)    $::purple_theme(button_text_light)  {set ::iconik_settings(theme) "::purple_theme";  iconik_save_settings; borg toast "Theme changed, please restart"}
create_button "iconik_settings" 1800 960 2000 1140 "Red"      $::font_big $::red_theme(button)       $::red_theme(button_text_light)     {set ::iconik_settings(theme) "::red_theme";     iconik_save_settings; borg toast "Theme changed, please restart"}


