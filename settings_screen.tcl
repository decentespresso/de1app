
set ::version_string "Version 1.3"

add_background "iconik_settings"

create_button "iconik_settings" 580 1440 1880 1560 $::font_tiny [theme button_tertiary] [theme button_text_light] { say [translate "settings"] $::settings(sound_button_in); iconik_save_settings; page_to_show_when_off "off" } { [translate "Done"]}
add_de1_text "iconik_settings" 1230 60 -text "Restart the app via settings after making changes" -anchor center -justify center -font $::font_small -fill [theme background_text]

add_de1_text "iconik_settings" 160 60 -text "$::version_string" -anchor center -justify center -font $::font_tiny -fill [theme background_text]
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
add_de1_widget "iconik_settings" checkbutton 160 840 {} -text [translate "Replace Steam & Hotwater with Grinder settings"] -indicatoron true  -font $::font_tiny -bg [theme background] -anchor nw -foreground [theme background_text] -variable ::iconik_settings(show_grinder_settings_on_main_page)  -borderwidth 0 -selectcolor [theme background] -highlightthickness 0 -activebackground [theme background]  -bd 0 -activeforeground [theme background_text] -relief flat -bd 0


# Screensaver folder
add_de1_text iconik_settings 180 900 -text [translate "Screensaver folder"] -font $::font_tiny -width 300 -fill [theme background_text] -anchor "nw"
# The actual content. Here a list of all settings for this plugin
add_de1_widget "iconik_settings" entry 180 960  {
    set ::globals(widget_profile_name_to_save) $widget
    bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; iconik_save_settings; hide_android_keyboard}
    bind $widget <Leave> hide_android_keyboard
} -width [expr {int(38 * $::globals(entry_length_multiplier))}] -font $::font_tiny  -borderwidth 1 -bg [theme background_highlight]  -foreground [theme background_text] -textvariable ::iconik_settings(saver_dir) -relief flat  -highlightthickness 1 -highlightcolor [theme button_text_light]


## Dose / Grind settings
create_settings_button "iconik_settings" 180 1080 580 1200 $::font_tiny [theme button_secondary] [theme button_text_light] { set ::settings(grinder_dose_weight) [expr {$::settings(grinder_dose_weight) - 0.5}]; profile_has_changed_set; save_profile; save_settings_to_de1; save_settings} { set ::settings(grinder_dose_weight) [expr {$::settings(grinder_dose_weight) + 0.5}]; profile_has_changed_set; save_profile; save_settings_to_de1; save_settings} {Dose:\n $::settings(grinder_dose_weight) ([iconik_get_ratio_text])}
create_settings_button "iconik_settings" 680 1080 1080 1200 $::font_tiny [theme button_secondary] [theme button_text_light]  { set ::settings(grinder_setting) [round_to_one_digits [expr {$::settings(grinder_setting) - 0.1}]]; profile_has_changed_set; save_profile; save_settings_to_de1; save_settings} { set ::settings(grinder_setting) [round_to_one_digits [expr {$::settings(grinder_setting) + 0.1}]]; profile_has_changed_set; save_profile; save_settings_to_de1; save_settings} {Grinder Setting:\n $::settings(grinder_setting)}

## Water / Steam settings
create_settings_button "iconik_settings" 180  1260 580 1380 $::font_tiny [theme button_secondary] [theme button_text_light]  {  set ::iconik_settings(water_temperature_overwride) [expr {$::iconik_settings(water_temperature_overwride) - 5}]; iconik_save_water_temperature} {  set ::iconik_settings(water_temperature_overwride) [expr {$::iconik_settings(water_temperature_overwride) + 5}];iconik_save_water_temperature} {Water [iconik_water_temperature]}
create_settings_button "iconik_settings" 680 1260 1080 1380 $::font_tiny [theme button_secondary] [theme button_text_light] {set ::settings(water_volume) [expr {$::settings(water_volume) - 5}]; de1_send_steam_hotwater_settings; save_settings} {  set ::settings(water_volume) [expr {$::settings(water_volume) + 5}]; de1_send_steam_hotwater_settings; save_settings} {Water [round_to_integer $::settings(water_volume)]ml}
create_settings_button "iconik_settings" 1180  1260 1580 1380 $::font_tiny [theme button_secondary] [theme button_text_light] {iconic_steam_tap down} {iconic_steam_tap up} {Steam $::iconik_settings(steam_active_slot):\n[iconik_get_steam_time]}


# Skin theme buttons
create_button "iconik_settings" 1800 240 2000 420 $::font_big $::default_theme(button) $::default_theme(button_text_light) {set ::iconik_settings(theme) "::default_theme"; iconik_save_settings; borg toast "Theme changed, please restart"}  "Default" 
create_button "iconik_settings" 1800 480 2000 660 $::font_big $::dark_theme(button)    $::dark_theme(button_text_light)    {set ::iconik_settings(theme) "::dark_theme";    iconik_save_settings; borg toast "Theme changed, please restart"} "Dark" 
create_button "iconik_settings" 2060 480 2260 660 $::font_big $::cocoa_theme(button)   $::cocoa_theme(button_text_light)   {set ::iconik_settings(theme) "::cocoa_theme";   iconik_save_settings; borg toast "Theme changed, please restart"}  "Cocoa"
create_button "iconik_settings" 1800 720 2000 900 $::font_big $::purple_theme(button)  $::purple_theme(button_text_light)  {set ::iconik_settings(theme) "::purple_theme";  iconik_save_settings; borg toast "Theme changed, please restart"} "Purple" 
create_button "iconik_settings" 2060 720 2260 900 $::font_big $::red_theme(button)     $::red_theme(button_text_light)     {set ::iconik_settings(theme) "::red_theme";     iconik_save_settings; borg toast "Theme changed, please restart"} "Red"  


# System Settings button
create_button "iconik_settings" 2080 1440 2480 1560 $::font_tiny [theme button_tertiary] [theme button_text_light] { say [translate "settings"] $::settings(sound_button_in); iconik_save_settings; iconik_show_settings} {[translate "System Settings"] }




