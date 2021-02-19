advanced_shot {{exit_if 1 volume 500 transition fast exit_flow_under 0 temperature 1 name {fast rise} pressure 7.00 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 7.00 exit_pressure_under 0 seconds 20.00} {exit_if 0 volume 500 transition smooth exit_flow_under 0 temperature 1 name {final slow rise} pressure 9.0 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 seconds 3.00 exit_pressure_under 0} {exit_if 0 volume 500 transition fast exit_flow_under 0 temperature 1 name hold pressure 9.0 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 seconds 60.00 exit_pressure_under 0}}
author Decent
espresso_decline_time 0
espresso_hold_time 35
espresso_pressure 9.0
espresso_temperature 1
espresso_temperature_0 1
espresso_temperature_1 1
espresso_temperature_2 1
espresso_temperature_3 1
espresso_temperature_steps_enabled 0
final_desired_shot_volume 36
final_desired_shot_volume_advanced 36
final_desired_shot_volume_advanced_count_start 2
final_desired_shot_weight 36
final_desired_shot_weight_advanced 36
flow_profile_decline 1
flow_profile_decline_time 23
flow_profile_hold 1.8
flow_profile_hold_time 0
flow_profile_minimum_pressure 6
flow_profile_preinfusion 4.2
flow_profile_preinfusion_time 6
preinfusion_flow_rate 4.5
preinfusion_guarantee 0
preinfusion_stop_pressure 4
preinfusion_time 8
pressure_end 6.0
profile_hide 1
profile_language en
profile_notes {You will need a portafilter fitted with a pressure gauge that leaks or has a slow flow rate.  This profile will slowly rise to 9 bar and hold it.  Compare what is on the screen with what your analog pressure gauge tells you.  Go to Settings->Machine->Calibrate and enter the held pressure value, and then retest until the pressure until the two agree.}
profile_title {Test/pressure calibration}
settings_profile_type settings_2c
tank_desired_water_temperature 0
water_temperature 86.0
beverage_type {calibrate}
