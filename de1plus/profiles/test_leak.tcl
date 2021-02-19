advanced_shot {{exit_if 0 flow 8.00 volume 500 transition smooth exit_flow_under 0 temperature 0.0 name preinfusion pressure 10.00 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 10.0 exit_pressure_under 0 seconds 10.00} {exit_if 0 volume 500 transition fast exit_flow_under 0 temperature 0.0 name {rise and hold} pressure 10.0 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 5.00} {flow 0.00 exit_if 0 volume 500 transition fast exit_flow_under 0 temperature 0.0 name {hold at no flow} pressure 10.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 120.00}}
author Decent
espresso_decline_time 60
espresso_hold_time 60
espresso_pressure 10.0
espresso_temperature 0.0
espresso_temperature_0 0.0
espresso_temperature_1 0.0
espresso_temperature_2 0.0
espresso_temperature_3 0.0
espresso_temperature_steps_enabled 1
final_desired_shot_volume 0
final_desired_shot_volume_advanced 0
final_desired_shot_volume_advanced_count_start 1
final_desired_shot_weight 32
final_desired_shot_weight_advanced 32
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_minimum_pressure 4
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
preinfusion_flow_rate 8.0
preinfusion_guarantee 0
preinfusion_stop_pressure 10.0
preinfusion_time 60
pressure_end 10.0
profile_hide 1
profile_language en
profile_notes {Put a blind (no hole) portafilter basket into your portafilter, and then run this profile to see if there are any water leaks in your machine.  Once pressure is reached, water will be turned off and pressure held.  A small mount of pressure loss is normal, because of leaking around the pump's valve.  After two minutes of no flow, your pressure should be above 8 bar.}
profile_title {Test/for a small leak}
settings_profile_type settings_2c
tank_desired_water_temperature 0
water_temperature 70.00
beverage_type {calibrate}
