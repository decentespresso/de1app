array set ::default_theme {
    background "#FFFFFF"
    background_highlight "#EEEEEE"
    background_text "#414A91"

    primary "#3D5682"
    primary_light "#417491"
    primary_dark "#414A91"

    secondary "#F27405"
    secondary_light "#F28705"

    button "#3D5682"
    button_secondary "#F27405"
    button_tertiary "#182130"

    button_text_light "#eee"
    button_text_dark "#CCCCCC"
}

array set ::dark_theme {
    background "#121212"
    background_highlight "#121212"
    background_text "#FFFFFF"

    primary "#BB86FC"
    primary_light "#BB86FC"
    primary_dark "#BB86FC"

    secondary "#03DAC6"
    secondary_light "#03DAC6"

    button "#1E1E1E"
    button_secondary "#1E1E1E"
    button_tertiary "#1E1E1E"

    button_text_light "#FFFFFF"
    button_text_dark "#969eb1"
}

array set ::purple_theme {
    background "#3c3c48"
    background_highlight "#343444"
    background_text "#FFFFFF"

    primary "#b73f49"
    primary_light "#c74f59"
    primary_dark "#a72f39"

    secondary "#e2a3b6"
    secondary_light "#bf8a9a"

    button "#b73f49"
    button_secondary "#3d3b5e"
    button_tertiary "#7a354b"

    button_text_light "#eee"
    button_text_dark "#CCCCCC"
}


# fonts
set ::font_tiny [get_font "Mazzard Regular" 16]
set ::font_small [get_font "Mazzard Regular" 18]
set ::font_big [get_font "Mazzard Regular" 22]

array set ::iconik_settings {
    profiles {1 {name default title Default} 2 {name {Gentle and sweet} title {Gentle and sweet}} 3 {name rao_allonge title {Rao Allongé}}}
    steam_profiles {1 {timeout {26}} 2 {timeout {30}}}

    flush_timeout 3
    steam_active_slot 0

    theme "::default_theme"

    cleanup_use_profile 0
    cleanup_profile "weber_spring_clean"

    show_steam 0

    saver_dir {/saver}

    show_water_level_indicator 0
}

proc theme {cntx} {
    set theme_name $::iconik_settings(theme)
    return [set ${theme_name}($cntx)]
}


proc iconik_settings_filename {} {
    return "[skin_directory]/settings.tdb"
}

proc iconik_array_to_file {arrname fn} {
    upvar $arrname item
    set icnoik_data {}
    foreach k [lsort -dictionary [array names item]] {
        set v $item($k)
        append icnoik_data [subst {[list $k] [list $v]\n}]
    }
    write_file $fn $icnoik_data
}

proc iconik_save_settings {} {
    iconik_array_to_file ::iconik_settings [iconik_settings_filename]
}

proc iconik_load_settings {} {
    array set ::iconik_settings [encoding convertfrom utf-8 [read_binary_file [iconik_settings_filename]]]
}
