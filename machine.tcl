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
	water_refill_point 2
	advanced_shot_moveone_enabled 1
    found    0
    scanning 1
    device_handle 0
    skale_device_handle 0
	suuid "0000A000-0000-1000-8000-00805F9B34FB"
	sinstance 0
	cuuid "0000a002-0000-1000-8000-00805f9b34fb"
	cuuid_0a "0000a00a-0000-1000-8000-00805f9b34fb"
	cuuid_0b "0000a00b-0000-1000-8000-00805f9b34fb"
	cuuid_0c "0000a00c-0000-1000-8000-00805f9b34fb"
	cuuid_0f "0000a00f-0000-1000-8000-00805f9b34fb"
	cuuid_10 "0000A010-0000-1000-8000-00805F9B34FB"
	cuuid_11 "0000A011-0000-1000-8000-00805F9B34FB"
	cinstance 0
	pressure 0
	head_temperature 0
	mix_temperature 0
	flow 0
	flow_delta 0
	pressure_delta 0
	timer 0
	volume 0
	wrote 0
	cmdstack {}
	scale_autostop_triggered 1
	connect_time 0
	water_level 30
	state 0
	substate 0
	current_context ""
	serial_number 0
	scale_weight {}
	scale_weight_rate 0
	final_water_weight 0
	voltage 110
	has_catering_kit 0
	has_plumbing_kit 0
	max_pressure 12
	max_flowrate 6
	version "1.0"
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
	hertz 50
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
	steam_heater_temperature 170
}

set ::de1(last_ping) [clock seconds]

if {[de1plus]} { 
	set ::de1(maxpressure) 12 
}

catch {
	package require tkblt
}
catch {
	package require BLT
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
	color_stage_1 "#c8e7d5"
	color_stage_2 "#efdec2"
	color_stage_3 "#edceca"
	water_refill_point 2
	flying 0
	bean_notes {}
	espresso_notes {}
	advanced_shot {}
	water_time_max 60
	grinder_dose_weight 0
	allow_unheated_water 1
	minimum_water_temperature 80
	waterlevel_blink_start_level 15
	waterlevel_indicator_on 1
	waterlevel_indicator_blink 1
	drink_weight 0
	espresso_enjoyment 0
	drink_tds 0
	drink_ey 0
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
	steam_temperature 170
	settings_profile_type "settings_2"
	steam_max_time 120
	skale_bluetooth_address {}
	bluetooth_address {}
	water_max_vol 500
	water_temperature 80
	final_desired_shot_weight 36
	espresso_max_time 42
	skale_square_button_starts_espresso 0
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
	final_desired_shot_weight_percentage_to_stop .93
	history_saved ""
	pressure_end 4 
	espresso_step_1 pressure
	espresso_step_2 pressure
	espresso_step_3 pressure
	espresso_pressure 9.2
	app_brightness 100
	saver_brightness 0
	accelerometer_angle 45
	goal_is_basket_temp 1
	flight_mode_angle 30
	display_pressure_delta_line 0
	display_flow_delta_line 0
	display_weight_delta_line 0
	machine_name "pretty decent"
	enable_spoken_prompts 0
	preinfusion_guarantee 1
	speaking_rate 1.5
	display_rate_espresso 0
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
}
array set ::de1_substate_types_reversed [reverse_array ::de1_substate_types]

array set translation [read_file "[homedir]/translation.tcl"]


proc de1_substate_text {} {
	set num $::de1(substate)
	set substate_txt $::de1_substate_types($num)
	return [translate $substate_txt]
}


proc next_espresso_step {} {
	msg "Tell DE1 to move to the next step in espresso making"

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

	if {$::android == 0} {
		#after [expr {1000 * $::settings(steam_max_time)}] {page_display_change "steam" "off"}
		after 200 [list update_de1_state "$::de1_state(Steam)\x5"]
	}
}

proc start_espresso {} {
	msg "Tell DE1 to start making ESPRESSO"
	set ::settings(history_saved) ""
	set ::de1(timer) 0
	set ::de1(volume) 0
	set ::de1(preinfusion_volume) 0
	set ::de1(pour_volume) 0

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
	clear_timers
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

	#run_next_userdata_cmd
}

proc start_water {} {
	msg "Tell DE1 to start making HOT WATER"
	set ::de1(timer) 0
	set ::de1(volume) 0
	de1_send_state "make hot water" $::de1_state(HotWater)

	if {$::android == 0} {
		#after [expr {1000 * $::settings(water_max_time)}] {page_display_change "water" "off"}
		after 200 [list update_de1_state "$::de1_state(HotWater)\x5"]
	}
}

proc start_idle {} {
	msg "Tell DE1 to start to go IDLE (and stop whatever it is doing)"


	if {$::de1(skale_device_handle) == 0 && $::settings(skale_bluetooth_address) != ""} {
		ble_connect_to_skale
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

	set ::settings(flying) 0
	de1_send_state "go idle" $::de1_state(Idle)
	if {$::android == 0} {
		#after [expr {1000 * $::settings(water_max_time)}] {page_display_change "water" "off"}
		after 200 [list update_de1_state "$::de1_state(Idle)\x0"]
	}

	#msg "sensors: [borg sensor list]"
}


proc start_sleep {} {
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


