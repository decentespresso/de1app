	add_de1_command "steam" do_steam 104 308 404 706 
	add_de1_command "espresso" do_espresso 474 293 803 721
	add_de1_command "water" do_water 875 307 1175 706 
	add_de1_command "exit" app_exit 1133 0 1280 142

	.can create text 255 573 -anchor "center" -text [string toupper [translate "steam"]] -font Helv_10 -fill "#2d3046" -tag .weight_setting_units_label
	.can create text 640 573 -anchor "center" -text [string toupper [translate "espresso"]] -font Helv_10 -fill "#2d3046" -tag .weight_setting_units_label
	.can create text 1024 573 -anchor "center" -text [string toupper [translate "hot water"]] -font Helv_10 -fill "#2d3046" -tag .weight_setting_units_label
	.can create text 255 573 -anchor "center" -text [string toupper [translate "steam"]] -font Helv_10 -fill "#2d3046" -tag .weight_setting_units_label
