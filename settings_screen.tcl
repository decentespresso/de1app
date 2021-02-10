
set ::version_string "Version 1.2"

add_background "iconik_settings"

create_button "iconik_settings" 580 1440 1880 1560 [translate "Done"] $::font_tiny [theme button_tertiary] [theme button_text_light] { say [translate "settings"] $::settings(sound_button_in); iconik_save_settings; page_to_show_when_off "off" }
add_de1_text "iconik_settings" 1230 1380 -text "Restart the app via settings after making changes" -anchor center -justify center -font $::font_small

add_de1_text "iconik_settings" 160 60 -text "$::version_string" -anchor center -justify center -font $::font_tiny
add_de1_widget "iconik_settings" checkbutton 160 120 {} -text [translate "Have Steam Presets"] -indicatoron true  -font $::font_tiny -bg [theme background] -anchor nw -foreground [theme background_text] -variable ::iconik_settings(steam_presets_enabled)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme background_text] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 180 {} -text [translate "Show Steam Graph"] -indicatoron true  -font $::font_tiny -bg [theme background] -anchor nw -foreground [theme background_text] -variable ::iconik_settings(show_steam)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme background_text] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 240 {} -text [translate "Show Start/Stop buttons (required on non-GHC machines)"] -indicatoron true  -font $::font_tiny -bg [theme background] -anchor nw -foreground [theme background_text] -variable ::iconik_settings(show_ghc_buttons)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme background_text] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 300 {} -text [translate "Show Water level indicator"] -indicatoron true  -font $::font_tiny -bg [theme background] -anchor nw -foreground [theme background_text] -variable ::iconik_settings(show_water_level_indicator)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme background_text] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 360 {} -text [translate "Show remaining water in mL instead of Water level"] -indicatoron true  -font $::font_tiny -bg [theme background] -anchor nw -foreground [theme background_text] -variable ::iconik_settings(show_ml_instead_of_water_level)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme background_text] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 420 {} -text [translate "Use profile for cleanup button"] -indicatoron true  -font $::font_tiny -bg [theme background] -anchor nw -foreground [theme background_text] -variable ::iconik_settings(cleanup_use_profile)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme background_text] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 480 {} -text [translate "Bypass shot history for cleanup profile"] -indicatoron true  -font $::font_tiny -bg [theme background] -anchor nw -foreground [theme background_text] -variable ::iconik_settings(cleanup_bypass_shot_history)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme background_text] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 540 {} -text [translate "Restore selected profile after cleanup"] -indicatoron true  -font $::font_tiny -bg [theme background] -anchor nw -foreground [theme background_text] -variable ::iconik_settings(cleanup_restore_selected_profile)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme background_text] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 600 {} -text [translate "Only tare when pouring (usefull for weighing beans)"] -indicatoron true  -font $::font_tiny -bg [theme background] -anchor nw -foreground [theme background_text] -variable ::settings(tare_only_on_espresso_start)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme background_text] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 660 {} -text [translate "Reconnect to the scale on espresso start"] -indicatoron true  -font $::font_tiny -bg [theme background] -anchor nw -foreground [theme background_text] -variable ::settings(reconnect_to_scale_on_espresso_start)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme background_text] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 720 {} -text [translate "Try reconnecting to the scale forever (Can exhaust the tablet)"] -indicatoron true  -font $::font_tiny -bg [theme background] -anchor nw -foreground [theme background_text] -variable ::settings(automatically_ble_reconnect_forever_to_scale)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme background_text] -relief flat -bd 0
add_de1_widget "iconik_settings" checkbutton 160 780 {} -text [translate "Double the scale input / Spouted portafilter scale mode"] -indicatoron true  -font $::font_tiny -bg [theme background] -anchor nw -foreground [theme background_text] -variable ::settings(scale_stop_at_half_shot)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme background_text] -relief flat -bd 0

# Cleanup profile name
add_de1_text iconik_settings 180 840 -text [translate "Cleanup Profile name"] -font $::font_tiny -width 300 -fill [theme background_text] -anchor "nw"
# The actual content. Here a list of all settings for this plugin
add_de1_widget "iconik_settings" entry 180 900  {
    set ::globals(widget_profile_name_to_save) $widget
    bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; iconik_save_settings; hide_android_keyboard}
    bind $widget <Leave> hide_android_keyboard
} -width [expr {int(38 * $::globals(entry_length_multiplier))}] -font $::font_tiny  -borderwidth 1 -bg [theme background_highlight]  -foreground [theme background_text] -textvariable ::iconik_settings(cleanup_profile) -relief flat  -highlightthickness 1 -highlightcolor [theme button_text_light]

# Screensaver folder
add_de1_text iconik_settings 180 960 -text [translate "Screensaver folder"] -font $::font_tiny -width 300 -fill [theme background_text] -anchor "nw"
# The actual content. Here a list of all settings for this plugin
add_de1_widget "iconik_settings" entry 180 1020  {
    set ::globals(widget_profile_name_to_save) $widget
    bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; iconik_save_settings; hide_android_keyboard}
    bind $widget <Leave> hide_android_keyboard
} -width [expr {int(38 * $::globals(entry_length_multiplier))}] -font $::font_tiny  -borderwidth 1 -bg [theme background_highlight]  -foreground [theme background_text] -textvariable ::iconik_settings(saver_dir) -relief flat  -highlightthickness 1 -highlightcolor [theme button_text_light]


# System Settings button
create_button "iconik_settings" 2080 240 2480 1140 [translate "System Settings"] $::font_tiny [theme button_tertiary] [theme button_text_light] { say [translate "settings"] $::settings(sound_button_in); iconik_save_settings; iconik_show_settings}


## Water Temp
create_settings_button "iconik_settings" 2080 1200 2480 1320 "" $::font_tiny [theme button_secondary] [theme button_text_light]  {  set ::iconik_settings(water_temperature_overwride) [expr {$::iconik_settings(water_temperature_overwride) - 5}]; iconik_save_water_temperature} {  set ::iconik_settings(water_temperature_overwride) [expr {$::iconik_settings(water_temperature_overwride) + 5}];iconik_save_water_temperature}
add_de1_variable "iconik_settings" [expr (2080 + 2480) / 2.0 ] [expr (1200 + 1320) / 2.0 ] -width [rescale_x_skin 280]  -text "" -font $::font_tiny -fill [theme button_text_light] -anchor "center" -justify "center" -state "hidden" -textvariable {Water [iconik_water_temperature]}


# Skin theme buttons
create_button "iconik_settings" 1800 240 2000 420  "Default"  $::font_big $::default_theme(button)   $::default_theme(button_text_light) {set ::iconik_settings(theme) "::default_theme"; iconik_save_settings; borg toast "Theme changed, please restart"}
create_button "iconik_settings" 1800 480 2000 660  "Dark"     $::font_big $::dark_theme(button)      $::dark_theme(button_text_light)    {set ::iconik_settings(theme) "::dark_theme";    iconik_save_settings; borg toast "Theme changed, please restart"}
create_button "iconik_settings" 1800 720 2000 900  "Purple"   $::font_big $::purple_theme(button)    $::purple_theme(button_text_light)  {set ::iconik_settings(theme) "::purple_theme";  iconik_save_settings; borg toast "Theme changed, please restart"}
create_button "iconik_settings" 1800 960 2000 1140 "Red"      $::font_big $::red_theme(button)       $::red_theme(button_text_light)     {set ::iconik_settings(theme) "::red_theme";     iconik_save_settings; borg toast "Theme changed, please restart"}


