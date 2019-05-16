package provide de1_machine 1.0

#set ::debugging 0

# ray's DE1 address (usb key #?)
# de1_address "EE:01:68:94:A5:48"

# john's DE1 (usb key #2)
#	de1_address "C5:80:EC:A5:F9:72"

# USB KEY #1
# de1_address "C1:80:A7:32:CD:A3"

#	de1_address "C1:80:A7:32:CD:A3"
#	has_flowmeter 0


array set ::de1 {
	current_frame_number 0
	calibration_pressure {}
	calibration_temperature {}
	calibration_flow {}
	factory_calibration_pressure {}
	factory_calibration_temperature {}
	factory_calibration_flow {}
	advanced_shot_moveone_enabled 1
    found    0
    scanning 1
    device_handle 0
    skale_device_handle 0
	suuid "0000A000-0000-1000-8000-00805F9B34FB"
	sinstance 12
	cuuid "0000A002-0000-1000-8000-00805F9B34FB"
	cuuid_01 "0000A001-0000-1000-8000-00805F9B34FB"
	cuuid_02 "0000A002-0000-1000-8000-00805F9B34FB"
	cuuid_0A "0000A00A-0000-1000-8000-00805F9B34FB"
	cuuid_0B "0000A00B-0000-1000-8000-00805F9B34FB"
	cuuid_0C "0000A00C-0000-1000-8000-00805F9B34FB"
	cuuid_0D "0000A00D-0000-1000-8000-00805F9B34FB"
	cuuid_0E "0000A00E-0000-1000-8000-00805F9B34FB"
	cuuid_0F "0000A00F-0000-1000-8000-00805F9B34FB"
	cuuid_06 "0000A006-0000-1000-8000-00805F9B34FB"
	cuuid_09 "0000A009-0000-1000-8000-00805F9B34FB"
	cuuid_10 "0000A010-0000-1000-8000-00805F9B34FB"
	cuuid_11 "0000A011-0000-1000-8000-00805F9B34FB"
	cuuid_12 "0000A012-0000-1000-8000-00805F9B34FB"
	cuuid_skale_EF80 "0000EF80-0000-1000-8000-00805F9B34FB"
	cuuid_skale_EF81 "0000EF81-0000-1000-8000-00805F9B34FB"
	cuuid_skale_EF82 "0000EF82-0000-1000-8000-00805F9B34FB"
	suuid_skale "0000FF08-0000-1000-8000-00805F9B34FB"
	cinstance 0
	pressure 0
	head_temperature 0
	mix_temperature 0
	flow 0
	currently_erasing_firmware 0
	currently_updating_firmware {}
	flow_delta 0
	pressure_delta 0
	timer 0
	hertz 50
	volume 0
	wrote 0
	cmdstack {}
	water_level_mm_correction 5
	scale_autostop_triggered 1
	water_level_full_point 40
	connect_time 0
	water_level 20
	firmware_bytes_uploaded 0
	firmware_update_size 0
	firmware_update_button_label "Firmware Update"
	app_update_button_label ""
	state 0
	substate 0
	current_context ""
	serial_number 0
	scale_sensor_weight 0
	scale_weight {}
	scale_weight_rate 0
	final_water_weight 0
	voltage 110
	has_catering_kit 0
	has_plumbing_kit 0
	max_pressure 12
	max_flowrate 6
	max_flowrate_v11 8
	version ""
	min_temperature 80
	max_temperature 100
	goal_flow 2
	GroupPressure 0
	goal_pressure 6
	goal_temperature 90
	water_level_percent 0
	water_heater_wattage 1500
	steam_heater_wattage 1500
	group_heater_wattage 500
	maxpressure 10
	steam_min_temperature 120
	steam_max_temperature 170
	water_min_temperature 20
	water_max_temperature 95
	preinfusion_volume 0
	pour_volume 0
	water_time_min 1
	steam_time_min 1
	steam_time_max 120
	last_ping 0
	steam_heater_temperature 150
}

set ::de1(last_ping) [clock seconds]

if {[de1plus]} { 
	set ::de1(maxpressure) 12 
}


if {$android == 0 && $undroid == 0} {
	package require tkblt
}

if {$android == 0 || $undroid == 1} {
	# no 'borg' or 'ble' commands, so emulate
    android_specific_stubs
}


#namespace import blt::*
#namespace import -force blt::tile::*


#espresso_elapsed append 0
#espresso_pressure append 0
#espresso_flow append 0
#espresso_temperature_mix append 0
#espresso_temperature_basket append 0
#espresso_state_change append 0

#espresso_elapsed append 0 1 2
#espresso_pressure append 0 1 4
# espresso_pressure espresso_temperature_mix espresso_temperature_basket

#global accelerometer
#set accelerometer 0
#if {[flight_mode_enable] == 1} {#
#	set accelerometer 1
#}

array set ::settings {
	preset_counter 1
	screen_size_width {}
	screen_size_height {}
	current_frame_description {asdfasdfsa}
	default_font_calibration 0.5
	language en
	active_settings_tab settings_2a
	color_stage_1 "#c8e7d5"
	color_stage_2 "#efdec2"
	color_stage_3 "#edceca"
	logfile "log.txt"
	water_refill_point 5
	max_steam_pressure 3
	insight_skin_show_embedded_profile 0
	flying 0
	ble_unpair_at_exit 1
	preload_all_page_images 0
	advanced_shot_chart_temp_max 100
	advanced_shot_chart_temp_min 80
	bean_notes {}
	chart_dashes_flow ""
	chart_dashes_temperature ""
	name {}
	chart_dashes_pressure ""
	water_level_sensor_max 50
	espresso_notes {}
	profile_graph_smoothing_technique "quadratic"
	espresso_count 0
	steaming_count 0
	profile_has_changed 0
	water_count 0
	advanced_shot {}
	water_time_max 60
	refill_check_at_sleep 0
	grinder_dose_weight 0
	scentone {}
	seconds_after_espresso_stop_to_continue_weighing 8
	one_tap_mode 0
	allow_unheated_water 1
	minimum_water_temperature 80
	seconds_to_display_done_espresso 120
	seconds_to_display_done_steam 120
	seconds_to_display_done_flush 120
	seconds_to_display_done_hotwater 120
	waterlevel_blink_start_offset 5
	waterlevel_indicator_blink_rate 1000
	waterlevel_indicator_on 1
	waterlevel_indicator_blink 1
	drink_weight 0
	espresso_enjoyment 0
	god_espresso_filename {}
	god_espresso_name {}
	god_espresso_pressure {}
	god_espresso_temperature_basket {}
	god_espresso_flow {}
	god_espresso_flow_weight {}
	drink_tds 0
	drink_ey 0
	display_connected_msg_seconds 5
	flow_rise_timeout 10
	scheduler_enable 0
	max_ble_connect_attempts 3
	scheduler_wake 3600
	scheduler_sleep 6000
	timer_interval 100
	screen_saver_delay 60
	screen_saver_change_interval 10
	enable_fluid_ounces 0
	has_refractometer 1
	my_name ""
	espresso_chart_over 3
	espresso_chart_under 10
	display_group_head_delta_number 0
	display_espresso_water_delta_number 1
	display_fluid_ounces_option 0
	has_scale 1
	enable_fahrenheit 0
	enable_ampm 0
	settings_1_page settings_1
	settings_profile_type "settings_2"
	steam_max_time 120
	skale_bluetooth_address {}
	bluetooth_address {}
	water_max_vol 500
	water_temperature 80
	final_desired_shot_weight 36
	final_desired_shot_weight_advanced 0
	espresso_max_time 60
	scale_button_starts_espresso 0
	espresso_temperature 92
	espresso_decline_time 25
	preinfusion_enabled 1
	preinfusion_time 5
	pressure_hold_time 10
	espresso_hold_time 10
	flow_profile_preinfusion 4
	flow_profile_hold 2
	flow_profile_decline 1.2
	flow_profile_hold_time 8
	espresso_typical_volume 200
	enable_negative_flow_charts 0
	flow_profile_decline_time 17
	flow_profile_preinfusion_time 5
	shot_weight_percentage_stop 79
	history_saved 0
	should_save_history 1
	pressure_end 4 
	stop_weight_before_seconds 2.8
	max_stop_at_weight 500
	espresso_step_1 pressure
	espresso_step_2 pressure
	espresso_step_3 pressure
	espresso_pressure 9.2
	app_brightness 70
	saver_brightness 0
	accelerometer_angle 45
	goal_is_basket_temp 1
	flight_mode_angle 30
	display_pressure_delta_line 0
	display_flow_delta_line 0
	stress_test 0
	display_weight_delta_line 0
	machine_name "pretty decent"
	enable_spoken_prompts 0
	preinfusion_guarantee 1
	speaking_rate 1.5
	display_rate_espresso 1
	temperature_target "portafilter"
	flow_rate_transition "smooth"
	water_speed_type "flow"
	speaking_pitch 1.0
	sound_button_in 8
	sound_button_out 11
	profile_notes {}
	flight_mode_enable 1
	profile default
	flow_profile_minimum_pressure 4
	preinfusion_flow_rate 4
	preinfusion_flow_rate2 4
	preinfusion_temperature 92
	preinfusion_stop_flow_rate 1
	preinfusion_stop_pressure 4
	profile_step ""
	preinfusion_stop_volumetric 100 
	preinfusion_stop_timeout 30
	pressure_rampup_timeout 20
	pressure_rampup_stop_volumetric 100
	pressure_hold_stop_volumetric 100
	flow_hold_stop_volumetric 100
	flow_decline_stop_volumetric 100
	pressure_decline_stop_volumetric 100
	steam_temperature 160
	steam_timeout 120
	skin "default"
	preheat_volume 50
	preheat_temperature 95
	water_volume 50
}

if {[de1plus]} {
	# default de1plus skin
	set ::settings(skin) "Insight"
}

# default the listbox to the currently set ble addresses
set ::de1_bluetooth_list $settings(bluetooth_address)
set ::skale_bluetooth_list $settings(skale_bluetooth_address)

array set ::de1_state {
	Sleep \x00
	GoingToSleep \x01
	Idle \x02
	Busy \x03
	Espresso \x04
	Steam \x05
	HotWater \x06
	ShortCal \x07
	SelfTest \x08
	LongCal \x09
	Descale \x0A
	FatalError \x0B
	Init \x0C
	NoRequest \x0D
    SkipToNext \x0E
    HotWaterRinse \x0F
    SteamRinse \x10
	Refill \x11
    Clean \x12
    InBootLoader \x13
    AirPurge \x14
}


array set ::de1_num_state {
  0 Sleep
  1 GoingToSleep
  2 Idle 
  3 Busy 
  4 Espresso 
  5 Steam
  6 HotWater
  7 ShortCal
  8 SelfTest
  9 LongCal 
  10 Descale
  11 FatalError 
  12 Init
  13 NoRequest
  14 SkipToNext
  15 HotWaterRinse
  16 SteamRinse
  17 Refill
  18 Clean
  19 InBootLoader
  20 AirPurge
}




array set ::de1_num_state_reversed [reverse_array ::de1_num_state]


array set ::de1_substate_types {
	-   "starting"
	0	"ready"
	1	"heating"
	2	"final heating"
	3	"stabilising"
	4	"preinfusion"
	5	"pouring"
	6	"ending"
	17  "refill"
}
array set ::de1_substate_types_reversed [reverse_array ::de1_substate_types]

array set translation [encoding convertfrom utf-8 [read_binary_file "[homedir]/translation.tcl"]]

proc de1_substate_text {} {
	set num $::de1(substate)
	set substate_txt $::de1_substate_types($num)
	return [translate $substate_txt]
}


proc next_espresso_step {} {
	msg "Tell DE1 to move to the next step in espresso making"

}


proc start_refill_kit {} {
	msg "Tell DE1 to start REFILL"
	set ::de1(timer) 0
	set ::de1(volume) 0

	if {$::android == 0} {
		#after [expr {1000 * $::settings(steam_max_time)}] {page_display_change "steam" "off"}
		#after 200 "update_de1_state $::de1_state(Descale)"
		after 200 [list update_de1_state "$::de1_state(Refill)\x5"]
		#after 1000 [list update_de1_state "$::de1_state(Idle)\x5"]
		after 2000 start_idle
	} else {
		de1_send_state "refill" $::de1_state(Refill)
	}

	if {[ifexists ::sleep_after_refill] == 1} {
		unset -nocomplain ::sleep_after_refill
	}
}

proc start_decaling {} {

	msg "Tell DE1 to start DESCALING"
	set ::de1(timer) 0
	set ::de1(volume) 0
	de1_send_state "descale" $::de1_state(Descale)

	if {$::android == 0} {
		#after [expr {1000 * $::settings(steam_max_time)}] {page_display_change "steam" "off"}
		#after 200 "update_de1_state $::de1_state(Descale)"
		after 200 [list update_de1_state "$::de1_state(Descale)\x5"]
	}
}


proc start_air_purge {} {

	msg "Tell DE1 to start TRAVEL DO"
	set ::de1(timer) 0
	set ::de1(volume) 0
	de1_send_state "air purge" $::de1_state(AirPurge)

	if {$::android == 0} {
		#after [expr {1000 * $::settings(steam_max_time)}] {page_display_change "steam" "off"}
		#after 200 "update_de1_state $::de1_state(Descale)"
		after 200 [list update_de1_state "$::de1_state(AirPurge)\x5"]
		after 5000 [list update_de1_state "$::de1_state(Idle)\x5"]
	}
}


proc start_cleaning {} {

	msg "Tell DE1 to start CLEANING"
	set ::de1(timer) 0
	set ::de1(volume) 0
	de1_send_state "descale" $::de1_state(Clean)

	if {$::android == 0} {
		#after [expr {1000 * $::settings(steam_max_time)}] {page_display_change "steam" "off"}
		#after 200 "update_de1_state $::de1_state(Descale)"
		after 200 [list update_de1_state "$::de1_state(Clean)\x5"]
	}
}

proc start_hot_water_rinse {} {
	msg "Tell DE1 to start HOT WATER RINSE"
	set ::de1(timer) 0
	set ::de1(volume) 0
	de1_send_state "hot water rinse" $::de1_state(HotWaterRinse)

	if {$::android == 0} {
		#after [expr {1000 * $::settings(steam_max_time)}] {page_display_change "steam" "off"}
		after 200 [list update_de1_state "$::de1_state(HotWaterRinse)\x5"]
	}
}

proc start_steam_rinse {} {
	msg "Tell DE1 to start STEAM RINSE"
	set ::de1(timer) 0
	set ::de1(volume) 0
	de1_send_state "steam rinse" $::de1_state(SteamRinse)

	if {$::android == 0} {
		#after [expr {1000 * $::settings(steam_max_time)}] {page_display_change "steam" "off"}
		after 200 [list update_de1_state "$::de1_state(SteamRinse)\x5"]
	}
}

proc start_steam {} {
	msg "Tell DE1 to start making STEAM"
	set ::de1(timer) 0
	set ::de1(volume) 0
	de1_send_state "make steam" $::de1_state(Steam)

	incr ::settings(steaming_count)
	save_settings

	steam_elapsed length 0
	steam_pressure length 0
	steam_flow length 0
	#steam_pressure append 0
	#steam_elapsed append 0

	if {$::settings(stress_test) == 1} {
		set ::idle_next_step start_steam
	}



	if {$::android == 0} {
		#after [expr {1000 * $::settings(steam_max_time)}] {page_display_change "steam" "off"}
		after 200 [list update_de1_state "$::de1_state(Steam)\x5"]
	}
}

proc start_espresso {} {
	msg "Tell DE1 to start making ESPRESSO"
	msg [stacktrace]
	
	set ::settings(history_saved) 0

	set ::de1(timer) 0
	set ::de1(volume) 0
	set ::de1(final_water_weight) 0
	set ::de1(preinfusion_volume) 0
	set ::de1(pour_volume) 0
	set ::de1(current_frame_number) 0

	# only works if a BLE scale is attached
	set ::de1(final_espresso_weight) 0	

	############
	# clear any description of the previous espresso
	set ::settings(scentone) ""
	set ::settings(espresso_enjoyment) 0
	set ::settings(espresso_notes) ""
	set ::settings(drink_tds) 0
	set ::settings(drink_weight) 0
	set ::settings(drink_ey) 0
	############

	de1_send_state "make espresso" $::de1_state(Espresso)

	clear_espresso_chart
	clear_espresso_timers

	incr ::settings(espresso_count)
	save_settings


	#start_timers

	if {$::de1(skale_device_handle) != 0} {
		# this variable prevents the stop trigger from happening until the Tare has succeeded.
		set ::de1(scale_autostop_triggered) 1
		skale_tare
		skale_timer_off
		#skale_timer_start
	}

	if {$::android == 0} {
		#after [expr {1000 * $::settings(espresso_max_time)}] {page_display_change "espresso" "off"}
		after 200 [list update_de1_state "$::de1_state(Espresso)\x1"]
	}

	if {$::settings(stress_test) == 1} {
		set ::idle_next_step start_espresso
	}


	#run_next_userdata_cmd
}

proc start_water {} {
	msg "Tell DE1 to start making HOT WATER"
	set ::de1(timer) 0
	set ::de1(volume) 0
	de1_send_state "make hot water" $::de1_state(HotWater)

	incr ::settings(water_count)
	save_settings


	if {$::android == 0} {
		#after [expr {1000 * $::settings(water_max_time)}] {page_display_change "water" "off"}
		after 200 [list update_de1_state "$::de1_state(HotWater)\x5"]
	}

	if {$::settings(stress_test) == 1} {
		set ::idle_next_step start_water
	}

}

proc start_idle {} {
	msg "Tell DE1 to start to go IDLE (and stop whatever it is doing)"


	if {$::de1(skale_device_handle) == 0 && $::settings(skale_bluetooth_address) != ""} {
		#scanning_restart
		ble_connect_to_skale
	}

	if {$::de1(device_handle) == 0} {
		#scanning_restart
		update_de1_state "$::de1_state(Idle)\x0"
		ble_connect_to_de1
		return
	}


	# save the UI settings whenever we have done an operation
	#save_settings

	# change the substate to ending immediately to provide UI feedback
	#set ::de1(substate) 6

	if {$::settings(stress_test) == 1} {
		# pressing stop on any step will stop the stress test
		unset -nocomplain ::idle_next_step 
	}


	set ::settings(flying) 0
	de1_send_state "go idle" $::de1_state(Idle)
	if {$::android == 0} {
		#after [expr {1000 * $::settings(water_max_time)}] {page_display_change "water" "off"}
		after 200 [list update_de1_state "$::de1_state(Idle)\x0"]
	}

	#msg "sensors: [borg sensor list]"
}


proc start_sleep {} {

	if {$::settings(refill_check_at_sleep) == 1} {
		msg "check refill first before sleep"
		set ::sleep_after_refill 1
		start_refill_kit
		return
	}

    if {[ifexists ::app_updating] == 1} {
		msg "delaying screen saver because tablet app is updating"
		delay_screen_saver
		return
	}

    if {$::de1(currently_updating_firmware) == 1} {
		msg "delaying screen saver because firmware is updating"
		delay_screen_saver
		return
	}

	change_screen_saver_img
	stop_screen_saver_timer
	msg "Tell DE1 to start to go to SLEEP (only send when idle)"
	de1_send_state "go to sleep" $::de1_state(Sleep)
	
	if {$::android == 0} {
		#after [expr {1000 * $::settings(water_max_time)}] {page_display_change "water" "off"}
		after 200 [list update_de1_state "$::de1_state(GoingToSleep)\x0"]
		after 800 [list update_de1_state "$::de1_state(Sleep)\x0"]
	}
}


proc has_flowmeter {} {
	return $::de1(has_flowmeter)
}


