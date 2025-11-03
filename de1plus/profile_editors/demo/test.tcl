proc show_editor { args } {
    ## put setup code here that you need to run
    ## page_show demo_editor_page   // you could use this but better to use the following line instead
    set_next_page off demo_editor_page; page_show off
}

set message {This is a non functional profile_editor page for demo purposes. The profile you are editing has a variable "profile_editor demo" which tells the app to open the profile_editor demo's editor page}

dui add variable demo_editor_page 1280 200 -width 2000 -justify center -anchor center -font [dui font get "Roboto-Regular" 20] -fill #b7b9c6 -textvariable {$::demo::message}


dui add dbutton demo_editor_page 810 400 \
    -bwidth 340 -bheight 110 \
    -shape round -radius 30 -fill #333 \
    -labelvariable {presets} -label_font [dui font get "Roboto-Regular" 20] -label_fill #666 -label_pos {0.5 0.5} \
    -command {exit_profile_editor presets}

dui add dbutton demo_editor_page 1210 400 \
    -bwidth 340 -bheight 110 \
    -shape round -radius 30 -fill #333 \
    -labelvariable {machine} -label_font [dui font get "Roboto-Regular" 20] -label_fill #666 -label_pos {0.5 0.5} \
    -command {exit_profile_editor machine}

dui add dbutton demo_editor_page 1610 400 \
    -bwidth 340 -bheight 110 \
    -shape round -radius 30 -fill #333 \
    -labelvariable {app} -label_font [dui font get "Roboto-Regular" 20] -label_fill #666 -label_pos {0.5 0.5} \
    -command {exit_profile_editor app}

dui add dbutton demo_editor_page 810 560 \
    -bwidth 340 -bheight 110 \
    -shape round -radius 30 -fill #333 \
    -labelvariable {save} -label_font [dui font get "Roboto-Regular" 20] -label_fill #666 -label_pos {0.5 0.5} \
    -command {exit_profile_editor save}


dui add dbutton demo_editor_page 1210 560 \
    -bwidth 340 -bheight 110 \
    -shape round -radius 30 -fill #333 \
    -labelvariable {cancel} -label_font [dui font get "Roboto-Regular" 20] -label_fill #666 -label_pos {0.5 0.5} \
    -command {exit_profile_editor cancel}

dui add dbutton demo_editor_page 1610 560 \
    -bwidth 340 -bheight 110 \
    -shape round -radius 30 -fill #333 \
    -labelvariable {{}} -label_font [dui font get "Roboto-Regular" 20] -label_fill #666 -label_pos {0.5 0.5} \
    -command {exit_profile_editor {}}

