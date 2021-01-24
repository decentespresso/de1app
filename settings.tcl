# colours
set ::color_text "#eee"
set ::color_background "#FFFFFF"
set ::color_background_highlight "#EEEEEE"

set ::color_primary "#3d537a"  
set ::color_primary_light "#417491"  
set ::color_primary_dark "##414A91"  

set ::color_secondary "#DEBA37"  
set ::color_secondary_light "#F5B731"  


set ::color_button "#3d537a"  
set ::color_button_secondary "#DEBA37"
set ::color_button_tertiary "#b8d4d5"

set ::color_button_text_light "#eee"
set ::color_button_text_dark "#111"

# fonts
set ::font_description [get_font "Mazzard Regular" 16]
set ::font_button_small [get_font "Mazzard Regular" 20]
set ::font_button [get_font "Mazzard Regular" 22]

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
