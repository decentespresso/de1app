array set ::default_theme {
    background "#FFFFFF"
    background_highlight "#EEEEEE"

    primary "#3D5682"  
    primary_light "#417491"  
    primary_dark "#414A91"  

    secondary "#F27405"  
    secondary_light "#F28705"  


    button "#3D5682"  
    button_secondary "#F27405"
    button_tertiary "#182130"

    button_text_light "#eee"
    button_text_dark "#111"
}

array set ::dark_theme {
    background "#121212"
    background_highlight "#121212"

    primary "#BB86FC"  
    primary_light "#BB86FC"  
    primary_dark "#BB86FC"  

    secondary "#03DAC6"  
    secondary_light "#03DAC6"  


    button "#1E1E1E"  
    button_secondary "#1E1E1E"
    button_tertiary "#1E1E1E"

    button_text_light "#FFFFFF"
    button_text_dark "#FFFFFF"
}


# fonts
set ::font_tiny [get_font "Mazzard Regular" 16]
set ::font_small [get_font "Mazzard Regular" 18]
set ::font_big [get_font "Mazzard Regular" 24]

array set ::iconik_settings {
    profile1  {default}
    profile2 {low pressure lever machine at 6 bar}
    profile3 {low pressure lever machine at 6 bar}

    profile1_title {Default}
    profile2_title {Lever at 6 Bar}
    profile3_title {Lever at 6 Bar}

    profiles {}

    flush_timeout 2

    steam_timeout1 26
    steam_timeout2 30
    steam_active_slot 1

    theme "::dark_theme"
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
