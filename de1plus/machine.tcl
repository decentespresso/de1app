package provide de1_machine 1.2

package require de1_comms 1.1
package require de1_logging 1.0

###
### NB: The array ::de1() is a global variable and not in the namespace ::de1
###
###     The namespace ::de1 is described after the existing globals
###


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
	firmware_crc ""
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
    language_rtl 0
    scale_device_handle 0
    decentscale_device_handle 0
	suuid "0000A000-0000-1000-8000-00805F9B34FB"
	sinstance 12
	cuuid "0000A002-0000-1000-8000-00805F9B34FB"
	cuuid_01 "0000A001-0000-1000-8000-00805F9B34FB"
	cuuid_02 "0000A002-0000-1000-8000-00805F9B34FB"
	cuuid_05 "0000A005-0000-1000-8000-00805F9B34FB"
	cuuid_06 "0000A006-0000-1000-8000-00805F9B34FB"
	cuuid_09 "0000A009-0000-1000-8000-00805F9B34FB"
	cuuid_0A "0000A00A-0000-1000-8000-00805F9B34FB"
	cuuid_0B "0000A00B-0000-1000-8000-00805F9B34FB"
	cuuid_0C "0000A00C-0000-1000-8000-00805F9B34FB"
	cuuid_0D "0000A00D-0000-1000-8000-00805F9B34FB"
	cuuid_0E "0000A00E-0000-1000-8000-00805F9B34FB"
	cuuid_0F "0000A00F-0000-1000-8000-00805F9B34FB"
	cuuid_10 "0000A010-0000-1000-8000-00805F9B34FB"
	cuuid_11 "0000A011-0000-1000-8000-00805F9B34FB"
	cuuid_12 "0000A012-0000-1000-8000-00805F9B34FB"
	cuuid_skale_EF80 "0000EF80-0000-1000-8000-00805F9B34FB"
	cuuid_skale_EF81 "0000EF81-0000-1000-8000-00805F9B34FB"
	cuuid_skale_EF82 "0000EF82-0000-1000-8000-00805F9B34FB"
	suuid_skale "0000FF08-0000-1000-8000-00805F9B34FB"
	cuuid_decentscale_read "0000FFF4-0000-1000-8000-00805F9B34FB"
	cuuid_decentscale_write "000036F5-0000-1000-8000-00805F9B34FB"
	cuuid_decentscale_writeback "83CDC3D4-3BA2-13FC-CC5E-106C351A9352"
	suuid_decentscale "0000FFF0-0000-1000-8000-00805F9B34FB"
	cuuid_acaia_ips_age "00002A80-0000-1000-8000-00805F9B34FB"
	suuid_acaia_ips "00001820-0000-1000-8000-00805F9B34FB"
	suuid_felicita "0000FFE0-0000-1000-8000-00805F9B34FB"
	cuuid_felicita "0000FFE1-0000-1000-8000-00805F9B34FB"
	suuid_hiroiajimmy "06C31822-8682-4744-9211-FEBC93E3BECE"
	cuuid_hiroiajimmy_cmd "06C31823-8682-4744-9211-FEBC93E3BECE"
	cuuid_hiroiajimmy_status "06C31824-8682-4744-9211-FEBC93E3BECE"
	cinstance 0
	fan_threshold 0
	tank_temperature_threshold 0
	listbox_global_width_multiplier 1
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
	widget_current_profile_name_color_normal "#ff6b6b"
	widget_current_profile_name_color_changed "#969eb1"
	water_level_mm_correction 5
	app_autostop_triggered True
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
	scale_weight_rate_raw 0
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
	steam_time_max 250
	last_ping 0
	steam_heater_temperature 150
	connectivity "ble"
}

set ::de1(last_ping) [clock seconds]

set ::de1(maxpressure) 12 


if {$android == 0 && $undroid == 0} {
	package require tkblt
}

if {$android == 0 || $undroid == 1} {
	# no 'borg' or 'ble' commands, so emulate
    android_specific_stubs
}

array set ::de1_cuuids_to_command_names {
	$::de1(cuuid_01) Version
	$::de1(cuuid_02) RequestedState
	#$::de1(cuuid_03) SetTime
	#$::de1(cuuid_04) ShotDirectory
	$::de1(cuuid_05) ReadFromMMR
	$::de1(cuuid_06) WriteToMMR
	#$::de1(cuuid_07) ShotMapRequest
	#$::de1(cuuid_08) DeleteShotRange
	$::de1(cuuid_09) FWMapRequest
	$::de1(cuuid_0A) Temperatures
	$::de1(cuuid_0B) ShotSettings
	$::de1(cuuid_0C) DeprecatedShotDesc
	$::de1(cuuid_0D) ShotSample
	$::de1(cuuid_0E) StateInfo
	$::de1(cuuid_0F) HeaderWrite
	$::de1(cuuid_10) FrameWrite
	$::de1(cuuid_11) WaterLevels
	$::de1(cuuid_12) Calibration
}

array set ::de1_command_names_to_cuuids [reverse_array ::de1_cuuids_to_command_names]


#set ::de1(in_fw_update_mode) 1


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
	enable_rise 0
	force_fw_update 0
	preset_counter 1
	screen_size_width {}
	ble_debug 0
	tank_desired_water_temperature 0
	screen_size_height {}
	log_enabled 0
	app_updates_beta_enabled 0
	current_frame_description {}
	mmr_enabled 0	
	default_font_calibration 0.5
	log_fast 0
	use_finger_down_for_tap 0
	linear_resistance_adjustment 1
	language en
	display_time_in_screen_saver 0
	steam_over_temp_threshold 180
	disable_long_press 0
	steam_over_pressure_threshold 6
	automatically_ble_reconnect_forever_to_scale 0
	chart_total_shot_flow 1
	steam_over_pressure_count_trigger 10
	heater_voltage ""
	steam_over_temp_count_trigger 10
	go_idle_before_all_operations 0
	mark_most_popular_profiles_used 0
	active_settings_tab settings_2a
	espresso_temperature_steps_enabled 0
	chart_total_shot_weight 1
	calibration_flow_multiplier 1
	phase_1_flow_rate 20
	phase_2_flow_rate 40
	ghc_mode 0
	fan_threshold 60
	steam_flow 700
	color_stage_1 "#c8e7d5"
	color_stage_2 "#efdec2"
	hot_water_idle_temp "850"
	espresso_warmup_timeout "20"
	color_stage_3 "#edceca"
	start_espresso_only_if_scale_connected 0
	logfile "log.txt"
	firmware_sha {}
	water_refill_point 5
	max_steam_pressure 3
	mmr_enabled 0
	insight_skin_show_embedded_profile 0
	flying 0
	ble_unpair_at_exit 1
	preload_all_page_images 0
	temp_bump_time_seconds 2
	enable_shot_history_export 0
	advanced_shot_chart_temp_max 100
	advanced_shot_chart_temp_min 80
	final_desired_shot_volume_advanced 0
	show_mixtemp_during_espresso 0
	enable_descale_steam_check 1
	bean_notes {}
	chart_dashes_flow ""
	chart_dashes_espresso_weight {2 1}
	chart_dashes_temperature ""
	steam_highflow_start 70
	zoomed_y_axis_scale 12
	name {}
	display_espresso_water_temp_difference 0
	chart_dashes_pressure ""
	insight_skin_show_weight_activity_bar 0
	debuglog_window_size 35
	water_level_sensor_max 50
	espresso_notes {}
	profile_graph_smoothing_technique "quadratic"
	live_graph_smoothing_technique "linear"
	preview_graph_smoothing_technique "quadratic"
	espresso_count 0
	steaming_count 0
	profile_has_changed 0
	water_count 0
	also_load_god_shot 1
	advanced_shot {}
	water_time_max 60
	battery_medium_trigger 90
	battery_medium_brightness 70
	battery_low_trigger 60
	battery_low_brightness 50
	battery_very_low_trigger 30
	battery_very_low_brightness 10
	orientation "landscape"
	grinder_dose_weight 0
	scentone {}
	after_flow_complete_delay 5
	display_volumetric_usage 0
	one_tap_mode 0
	allow_unheated_water 1
	minimum_water_temperature 99
	seconds_to_display_done_espresso 300
	seconds_to_display_done_steam 300
	seconds_to_display_done_flush 300
	seconds_to_display_done_hotwater 300
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
    scale_type ""
	enable_fahrenheit 0
	enable_ampm 0
	settings_1_page settings_1
	settings_profile_type "settings_2"
	steam_max_time 120
	scale_bluetooth_address {}
	scale_bluetooth_name {}
	skale_bluetooth_address {}
	bluetooth_address {}
	water_max_vol 500
	water_temperature 85
	final_desired_shot_weight 36
	final_desired_shot_volume 36
	final_desired_shot_weight_advanced 0
	final_desired_shot_volume_advanced 0
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
	water_stop_on_scale 1
	ghc_is_installed 0
	force_acaia_heartbeat 0
	reconnect_to_scale_on_espresso_start 1
	comms_debugging 0
	scale_stop_at_half_shot 0
	lock_screen_during_screensaver 0
	enabled_plugins {}

	maximum_flow 0
	maximum_flow_range_default 1.0
	maximum_pressure 0
	maximum_pressure_range_default 0.9

	maximum_flow_range_advanced 0.6
	maximum_pressure_range_advanced 0.6
	high_vibration_scale_filtering False
	last_version "1.34"
}

# default de1plus skin
set ::settings(skin) "Insight"


if {$::android != 1} {
	set ::settings(ghc_is_installed) 0
}


set ::de1_device_list {}
if { $settings(bluetooth_address) != ""} {
	append_to_de1_list $settings(bluetooth_address) "DE1" "ble"
}

#msg "init was run '$::settings(scale_type)'"

	#error "atomaxscale"
# initial filling of BLE scale list
#set ::scale_bluetooth_list $::settings(scale_bluetooth_address)


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
	SchedIdle \x15
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
  21 SchedIdle
}



set ::scale_bluetooth_list ""
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
	7	"Steaming"
	8	"DescaleInit"
	9	"DescaleFillGroup"
	10	"DescaleReturn"
	11	"DescaleGroup"
	12	"DescaleSteam"
	13	"CleanInit"
	14	"CleanFillGroup"
	15	"CleanSoak"
	16	"CleanGroup"
	17  "refill"
	18	"PausedSteam"
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


proc reset_gui_starting_hot_water_rinse {} {
	#msg "Tell DE1 to start HOT WATER RINSE"
	set ::de1(timer) 0
	set ::de1(volume) 0
}

proc start_hot_water_rinse {} {
	# here for backward compatiblity only
	start_flush
}

proc start_flush {} {

	if {$::settings(go_idle_before_all_operations) == 1} {
		msg "Tell DE1 to go idel before HOT WATER RINSE (flush)"
		de1_send_state "go idle" $::de1_state(Idle)
	}
	
	msg "Tell DE1 to start flush"
	de1_send_state "flush" $::de1_state(HotWaterRinse)


	#after 1000 read_de1_state
	if {[ghc_required] && $::settings(stress_test) != 1} {
		# show the user what button to press on the group head
		ghc_message ghc_flush
		return
	}


	if {$::android == 0} {
		#after [expr {1000 * $::settings(steam_max_time)}] {page_display_change "steam" "off"}
		after 200 [list update_de1_state "$::de1_state(HotWaterRinse)\x5"]
		after 10000 [list update_de1_state "$::de1_state(Idle)\x5"]
	}
}

proc start_steam_rinse {} {
	set ::de1(timer) 0
	set ::de1(volume) 0

	if {$::settings(go_idle_before_all_operations) == 1} {
		msg "Tell DE1 to go idle before steam rinse"
		de1_send_state "go idle" $::de1_state(Idle)
	}
	
	msg "Tell DE1 to start STEAM RINSE"
	de1_send_state "steam rinse" $::de1_state(SteamRinse)

	#after 1000 read_de1_state


	if {$::android == 0} {
		#after [expr {1000 * $::settings(steam_max_time)}] {page_display_change "steam" "off"}
		after 200 [list update_de1_state "$::de1_state(SteamRinse)\x5"]
	}
}

proc reset_gui_starting_steam {} {

	msg "reset_gui_starting_steam"

	set ::de1(timer) 0
	set ::de1(volume) 0

	incr ::settings(steaming_count)
	save_settings

	steam_elapsed length 0
	steam_pressure length 0
	steam_flow length 0
	steam_temperature length 0
	#steam_pressure append 0
	#steam_elapsed append 0
}

proc start_steam {} {

	if {$::settings(go_idle_before_all_operations) == 1} {
		msg "Tell DE1 to go idle before steam"
		de1_send_state "go idle" $::de1_state(Idle)
	}
	
	msg "Tell DE1 to start making STEAM"
	de1_send_state "make steam" $::de1_state(Steam)

	#after 1000 read_de1_state

	if {[ghc_required] && $::settings(stress_test) != 1} {
		# show the user what button to press on the group head
		ghc_message ghc_steam
		return
	}


	if {$::settings(stress_test) == 1} {
		set ::idle_next_step start_steam
	}

	if {$::android == 0} {
		#after [expr {1000 * $::settings(steam_max_time)}] {page_display_change "steam" "off"}
		after 200 [list update_de1_state "$::de1_state(Steam)\x5"]
		after 10000 [list update_de1_state "$::de1_state(Idle)\x5"]
	}
}

proc reset_gui_starting_espresso {} {

	set ::settings(history_saved) 0

	set ::de1(timer) 0
	set ::de1(volume) 0
	set ::de1(final_water_weight) 0
	set ::de1(preinfusion_volume) 0
	set ::de1(pour_volume) 0
	set ::de1(current_frame_number) 0
	::de1::state::reset_framenumbers

	# only works if a BLE scale is attached
	set ::de1(final_espresso_weight) 0

	############
	# clear any description of the previous espresso
	set ::settings(scentone) ""
	set ::settings(espresso_enjoyment) 0

	# this sets the time the espresso starts, used for recording this espresso to a history file
	set ::settings(espresso_clock) [clock seconds]

	set ::settings(espresso_notes) ""
	set ::settings(drink_tds) 0
	set ::settings(drink_weight) 0
	set ::settings(drink_ey) 0
	############


	clear_espresso_chart

	incr ::settings(espresso_count)
	save_settings

	if {$::settings(stress_test) == 1} {
		# this will cease to work once the GHC is installed
		set ::idle_next_step start_espresso
	}
}

proc ghc_message {type} {
	# display READY instead of START, because they have to tap the group head to start, they cannot tap the tablet, due to UL compliance limits
	if {[info exists ::nextpage(machine:off)] == 1} {
		set currentpage $::nextpage(machine:off)
	} else {
		set currentpage "off"
	}

	set_next_page off $type
	page_show $type
	after 1000 "set ::nextpage(machine:off) $currentpage"
}

proc start_espresso {} {

	if {$::settings(start_espresso_only_if_scale_connected) == 1 && $::de1(scale_device_handle) == 0 && $::settings(scale_bluetooth_address) != ""} {
		msg "Refusing to START espresso without the scale being connected"
		info_page [translate "Please connect your scale"] [translate "Ok"]
		return
	}

	if {$::settings(go_idle_before_all_operations) == 1} {
		msg "Tell DE1 to go idle before espresso"
		de1_send_state "go idle" $::de1_state(Idle)
	}
	
	msg "Tell DE1 to start making ESPRESSO"
	de1_send_state "make espresso" $::de1_state(Espresso)

	#after 1000 read_de1_state



	if {[ghc_required] && $::settings(stress_test) != 1} {
		# show the user what button to press on the group head
		ghc_message ghc_espresso
		return
	}

	if {$::de1(scale_device_handle) != 0} {
	}

	if {$::android == 0} {
		#after [expr {1000 * $::settings(espresso_max_time)}] {page_display_change "espresso" "off"}
		after 200 [list update_de1_state "$::de1_state(Espresso)\x1"]
		after 30000 [list update_de1_state "$::de1_state(Idle)\x5"]
	}

	return	
}

proc reset_gui_starting_hotwater {} {
	set ::de1(timer) 0
	set ::de1(volume) 0
	set ::de1(pour_volume) 0
	incr ::settings(water_count)

	save_settings
}

proc start_water {} {

	if {$::settings(go_idle_before_all_operations) == 1} {
		msg "Tell DE1 to go idle before hot water"
		de1_send_state "go idle" $::de1_state(Idle)
	}
	
	msg "Tell DE1 to start making HOT WATER"
	de1_send_state "make hot water" $::de1_state(HotWater)

	#after 1000 read_de1_state

	if {[ghc_required] && $::settings(stress_test) != 1} {
		# show the user what button to press on the group head
		ghc_message ghc_hotwater
		return
	}


	if {$::android == 0} {
		#after [expr {1000 * $::settings(water_max_time)}] {page_display_change "water" "off"}
		after 200 [list update_de1_state "$::de1_state(HotWater)\x5"]
		after 10000 [list update_de1_state "$::de1_state(Idle)\x5"]
	}

	if {$::settings(stress_test) == 1} {
		set ::idle_next_step start_water
		after 1200 [list update_de1_state "$::de1_state(Idle)\x5"]
	}

}

proc start_idle {} {
	msg "Tell DE1 to start to go IDLE (and stop whatever it is doing)"

	# Ensure we are not locking the screen during use.
	# This is only relevant when waking up the machine
	if  {[sdltk screensaver] == 1} {
		sdltk screensaver off
	}

	if {$::de1(device_handle) == 0} {
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

	# john 1/15/2020 this is a bit of a hack to work around a firmware bug in 7C24F200 that has the fan turn on during sleep, if the fan threshold is set > 0
	if {[firmware_has_fan_sleep_bug] == 1} {
		set_fan_temperature_threshold $::settings(fan_threshold)
	}

	#after 1000 read_de1_state
	
	if {$::de1(scale_device_handle) != 0} {
		#scale_enable_lcd
	}

	if {$::android == 0} {
		#after [expr {1000 * $::settings(water_max_time)}] {page_display_change "water" "off"}
		after 200 [list update_de1_state "$::de1_state(Idle)\x0"]
	}

	# moved the scale reconnect to be after the other commands, because otherwise a scale disconnected would interrupt the IDLE command
	if {$::de1(scale_device_handle) == 0 && $::settings(scale_bluetooth_address) != "" && [ifexists ::currently_connecting_de1_handle] == 0} {
		#ble_connect_to_scale
	}

	#msg "sensors: [borg sensor list]"
}


proc start_sleep {} {

	# obsolete, now done in fw
	#if {$::settings(refill_check_at_sleep) == 1} {
	#	msg "check refill first before sleep"
	#	set ::sleep_after_refill 1
	#	start_refill_kit
	#	return
	#}


	if {[firmware_has_fan_sleep_bug] == 1} {
		# john 1/15/2020 this is a bit of a hack to work around a firmware bug in 7C24F200 that has the fan turn on during sleep, if the fan threshold is set > 0
		set_fan_temperature_threshold 0
	}


    if {[ifexists ::app_updating] == 1} {
		msg "delaying screen saver because tablet app is updating"
		delay_screen_saver
		return
	}

    if {$::de1(currently_updating_firmware) == 1 || [ifexists ::de1(in_fw_update_mode)] == 1} {
		msg "delaying screen saver because firmware is updating"
		delay_screen_saver
		return
	}

	change_screen_saver_img
	stop_screen_saver_timer

	#de1_cause_refill_now_if_level_low

	msg "Tell DE1 to start to go to SLEEP (only send when idle)"
	de1_send_state "go to sleep" $::de1_state(Sleep)

	if {$::de1(scale_device_handle) != 0} {
		#scale_disable_lcd
	}

	
	if {$::android == 0} {
		#after [expr {1000 * $::settings(water_max_time)}] {page_display_change "water" "off"}
		after 200 [list update_de1_state "$::de1_state(GoingToSleep)\x0"]
		after 800 [list update_de1_state "$::de1_state(Sleep)\x0"]
	}

	if {$::settings(lock_screen_during_screensaver) == 1} {
		sdltk screensaver on
	}
}

proc check_if_steam_clogged {} {

	#msg "check_if_steam_cloggedcheck_if_steam_cloggedcheck_if_steam_cloggedcheck_if_steam_cloggedcheck_if_steam_cloggedcheck_if_steam_clogged"

	if {[steam_pressure length] < 30} {
		# if steaming was for less than 3 seconds, then don't run this test, as that was just a short purge
		msg "Not checking steam for clogging because steam_pressure length : [steam_pressure length] < 30"
		return 
	}

	if {$::settings(enable_descale_steam_check) != 1} {
		return
	}

	set ::settings(steam_over_temp_threshold) 180
	if {$::settings(enable_fahrenheit) == 1} {
		# change temp threshold for clogging to a Fahrenheit number, as steam temp logging is in their temp system
		set ::settings(steam_over_temp_threshold) [celsius_to_fahrenheit 180]
	}
	
	set ::settings(steam_over_pressure_threshold) 6

	set bad_pressure 0
	set bad_temp 0
	if {$::settings(steam_over_pressure_count_trigger) != 0} {

		# remove the first 20 samples (2 seconds) of data, as pressure is high to start, by design
		steam_pressure dup trimmed_steam_pressure
		catch {trimmed_steam_pressure delete 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20}

		set over_pressure [trimmed_steam_pressure search $::settings(steam_over_pressure_threshold) 999]

		if {[llength $over_pressure] > $::settings(steam_over_pressure_count_trigger)} {
			set bad_pressure 1
		}

		msg "over_pressure: [llength $over_pressure] vs $::settings(steam_over_pressure_count_trigger) - over_pressure: $over_pressure - bad_pressure: $bad_pressure ($::settings(steam_over_pressure_threshold) bar)"

	}

	if {$::settings(steam_over_temp_count_trigger) != 0} {
		# steam_temperature is mapped to the charts at 1/100th scale, so we need to multiple the threshold here by 100
		set over_temp [steam_temperature search $::settings(steam_over_temp_threshold) 999]
		if {[llength $over_temp] > $::settings(steam_over_temp_count_trigger)} {
			set bad_temp 1
		}

		msg "over_temp: $over_temp -  $bad_temp (> $::settings(steam_over_temp_threshold)º)"

	}

	if {$bad_pressure == 1 || $bad_temp == 1} {
		set_next_page off descalewarning;
		page_show descalewarning

	}
}

proc has_flowmeter {} {
	return $::de1(has_flowmeter)
}



###
### ::de1 namespace NOT included here (linear inclusion expected by existing code)
###
