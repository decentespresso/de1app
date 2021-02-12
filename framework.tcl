
# Functions for creating the Metric menu framework

proc add_background { contexts } {
	set background_id [.can create rect 0 0 [rescale_x_skin 2560] [rescale_y_skin 1600] -fill [theme background] -width 0 -state "hidden"]
	add_visual_items_to_contexts $contexts $background_id
}

# add a regular button
proc create_button { contexts x1 y1 x2 y2 font backcolor textcolor action variable } {
	rounded_rectangle $contexts  $x1 $y1 $x2 $y2 [rescale_x_skin 80] $backcolor
	add_de1_variable "$contexts"  [expr ($x1 + $x2) / 2.0 ] [expr ($y1 + $y2) / 2.0 ] -width [rescale_x_skin [expr ($x2 - $x1) - 20]]  -text "" -font $::font_tiny -fill [theme button_text_light] -anchor "center" -justify "center" -state "hidden" -textvariable $variable
	add_de1_button $contexts $action $x1 $y1 $x2 $y2
}

proc create_settings_button { contexts x1 y1 x2 y2 font backcolor textcolor action_down action_up variable} {
	rounded_rectangle $contexts  $x1 $y1 $x2 $y2 [rescale_x_skin 80] $backcolor

	add_de1_text $contexts [expr ($x1 + 40)] [expr ($y1 + $y2) / 2.0 ] -text "-" -font $font -fill $textcolor -anchor "center" -state "hidden"
	add_de1_text $contexts [expr ($x2 - 40) ] [expr ($y1 + $y2) / 2.0 ] -text "+" -font $font -fill $textcolor -anchor "center" -state "hidden"
	add_de1_variable "$contexts" [expr ($x1 + $x2) / 2.0 ] [expr ($y1 + $y2) / 2.0 ] -width [expr ($x2 - $x1) - 80]  -text "" -font $font -fill [theme button_text_light] -anchor "center" -justify "center" -state "hidden" -textvariable $variable
	add_de1_button $contexts $action_down $x1 $y1 [expr ($x1 + $x2) / 2.0 ] $y2
	add_de1_button $contexts $action_up   [expr ($x1 + $x2) / 2.0 ] $y1 $x2 $y2
}

proc update_button_color { button_id backcolor } {
	.can itemconfigure "button_$button_id" -fill $backcolor
}


### drawing functions ###

# add multiple visuals to multiple contexts
proc add_visual_items_to_contexts { contexts tags } {
    set context_list [split $contexts " "]
    set tag_list [split $tags " " ]
    foreach context $context_list {
        foreach tag $tag_list {
            add_visual_item_to_context $context $tag
        }
    }
}

proc rectangle {contexts x1 y1 x2 y2 colour } {
	set x1 [rescale_x_skin $x1] 
	set y1 [rescale_y_skin $y1] 
	set x2 [rescale_x_skin $x2] 
	set y2 [rescale_y_skin $y2]
	if { [info exists ::_rect_id] != 1 } { set ::_rect_id 0 }
	set tag "rect_$::_rect_id"
    .can create rectangle $x1 $y1 $x2 $y2 -fill $colour -outline $colour -width 0 -tag $tag -state "hidden"
	add_visual_items_to_contexts $contexts $tag
	incr ::_rect_id
	return $tag
}

proc rounded_rectangle {contexts x1 y1 x2 y2 radius colour } {
	set x1 [rescale_x_skin $x1] 
	set y1 [rescale_y_skin $y1] 
	set x2 [rescale_x_skin $x2] 
	set y2 [rescale_y_skin $y2]
	if { [info exists ::_rect_id] != 1 } { set ::_rect_id 0 }
	set tag "rect_$::_rect_id"
    .can create oval $x1 $y1 [expr $x1 + $radius] [expr $y1 + $radius] -fill $colour -outline $colour -width 0 -tag $tag -state "hidden"
    .can create oval [expr $x2-$radius] $y1 $x2 [expr $y1 + $radius] -fill $colour -outline $colour -width 0 -tag $tag -state "hidden"
    .can create oval $x1 [expr $y2-$radius] [expr $x1+$radius] $y2 -fill $colour -outline $colour -width 0 -tag $tag -state "hidden"
    .can create oval [expr $x2-$radius] [expr $y2-$radius] $x2 $y2 -fill $colour -outline $colour -width 0 -tag $tag -state "hidden"
    .can create rectangle [expr $x1 + ($radius/2.0)] $y1 [expr $x2-($radius/2.0)] $y2 -fill $colour -outline $colour -width 0 -tag $tag -state "hidden"
    .can create rectangle $x1 [expr $y1 + ($radius/2.0)] $x2 [expr $y2-($radius/2.0)] -fill $colour -outline $colour -width 0 -tag $tag -state "hidden"
	add_visual_items_to_contexts $contexts $tag
	incr ::_rect_id
	return $tag
}

proc create_grid { } {
	for {set x 80} {$x < 2560} {incr x 100} {
		.can create line [rescale_x_skin $x] [rescale_y_skin 0] [rescale_x_skin $x] [rescale_y_skin 1600] -width 1 -fill "#000" -tags "grid" -state "hidden"
		.can create text [rescale_x_skin $x] 0 -text $x -font [get_font "Mazzard Regular" 12] -fill "#000" -anchor "nw" -tag "grid" -state "hidden"
	}
	for {set y 60} {$y < 1600} {incr y 60} {
		.can create line [rescale_x_skin 0] [rescale_y_skin $y] [rescale_x_skin 2560] [rescale_y_skin $y] -width 1 -fill  "#000" -tags "grid" -state "hidden"
		.can create text 0 [rescale_y_skin $y] -text $y -font [get_font "Mazzard Regular" 12] -fill "#000" -anchor "nw" -tag "grid" -state "hidden"
	}
}