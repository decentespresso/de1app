advanced_shot {{exit_if 1 flow 8.0 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 86.00 name preinfusion pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 4.00 max_flow_or_pressure 0 exit_pressure_under 0 seconds 20.00} {exit_if 1 flow 0 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 70.00 name {dynamic bloom} pressure 6.0 sensor coffee pump flow exit_type pressure_under exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 0 exit_pressure_under 2.20 seconds 40.00} {exit_if 0 flow 2.2 volume 100 max_flow_or_pressure_range 1.0 transition fast exit_flow_under 0 temperature 80.00 name ramp pressure 6.0000000000000036 sensor coffee pump pressure exit_type pressure_under exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 0.0 exit_pressure_under 0 seconds 4.00} {exit_if 1 flow 2.2 volume 100 max_flow_or_pressure_range 1.0 transition fast exit_flow_under 0 temperature 77.00 name {6 bar} pressure 6.0000000000000036 sensor coffee pump pressure exit_type flow_under exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 4.5 exit_pressure_under 0 seconds 2.00} {exit_if 0 flow 3.200000000000001 volume 100 max_flow_or_pressure_range 1.0 transition smooth exit_flow_under 0 temperature 77.00 name decline pressure 2.999999999999999 sensor coffee pump pressure exit_type pressure_under exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 4.5 exit_pressure_under 0 seconds 40.00}}
espresso_temperature_steps_enabled 0
author {Joe D}
espresso_hold_time 15
preinfusion_time 20
espresso_pressure 6.0
espresso_decline_time 30
pressure_end 4.0
espresso_temperature 86.00
espresso_temperature_0 86.00
espresso_temperature_1 86.00
espresso_temperature_2 86.00
espresso_temperature_3 86.00
settings_profile_type settings_2c
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_minimum_pressure 4
preinfusion_flow_rate 4
profile_notes {Dynamic bloom into pressure extraction. Based on the "easy blooming" profile structure from Luca and Stephane and modified to primarily target high extraction grinders at high flow rates, typically ending around 3-4.5ml/s. Dial with ratio once grind is giving an ending flowrate in the range. Includes a significant temperature drop that reduces harshness (although the actual temperature drop is much less than programmed). By Joe D.}
final_desired_shot_volume 0
final_desired_shot_weight 0
final_desired_shot_weight_advanced 39
tank_desired_water_temperature 0
final_desired_shot_volume_advanced 0
profile_title TurboBloom
profile_language en
preinfusion_stop_pressure 4.0
profile_hide 0
final_desired_shot_volume_advanced_count_start 2
beverage_type espresso
maximum_pressure 0
maximum_pressure_range_advanced 0.6
maximum_flow_range_advanced 1.0
maximum_flow 0
maximum_pressure_range_default 0.9
maximum_flow_range_default 1.0

