proc register_profile_editors {} {
    set editors [lsort -dictionary [glob -nocomplain -tails -type d -directory "[homedir]/profile_editors/" *]]
    foreach editor $editors {
        set pass 0
        set file_name [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/profile_editors/$editor/" *.tcl]]
        foreach fn $file_name {
            set fn [file rootname $fn]
            set ::temp_file_path "[homedir]/profile_editors/${editor}/${fn}.tcl"
            set code [catch {namespace eval $editor {source [file join $::temp_file_path]}} results]
            if {$code != 0} {
                set pass 1
                msg -ERROR "profile_editor ${editor}/${fn}.tcl failed to load!"
                msg -ERROR $::errorInfo
            } else {
                msg -INFO "profile_editor ${editor}/${fn}.tcl loaded ok!"
                if {[info procs ::${editor}::show_editor] ne "::${editor}::show_editor"} {
                    msg -INFO "** but proc show_editor was not found in profile_editor $editor"
                }
            }
            unset -nocomplain ::temp_file_path
        }
        if {$pass == 1} {namespace delete $editor}
    }
}

register_profile_editors

ToDo
## this page is joined at at the start of ../skins/default/de1_skin_settings.tcl
## added code > set ::settings(profile_editor) "" < to vars.tcl select_profile proc.
