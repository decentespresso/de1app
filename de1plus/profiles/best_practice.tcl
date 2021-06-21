advanced_shot {{exit_if 1 flow 6.800000000000004 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 92.50 name {Preinfusion fill} pressure 3.000000000000001 sensor coffee pump pressure exit_type pressure_over exit_flow_over 1.00 exit_pressure_over 3.00 max_flow_or_pressure 0 seconds 12.00 exit_pressure_under 0} {exit_if 1 flow 6.800000000000004 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 1.00 temperature 92.50 name {Preinfusion fill end} pressure 3.000000000000001 sensor coffee pump pressure exit_type flow_under exit_flow_over 1.00 exit_pressure_over 3.00 max_flow_or_pressure 0 exit_pressure_under 0 seconds 12.00} {exit_if 0 flow 6.800000000000004 volume 8.00 max_flow_or_pressure_range 0.6 transition smooth exit_flow_under 0 temperature 89.00 name {Preinfusion dripping} pressure 2.5000000000000004 sensor coffee pump pressure exit_type flow_over exit_flow_over 1.00 exit_pressure_over 1.5 max_flow_or_pressure 0 exit_pressure_under 0 seconds 6.00} {exit_if 1 volume 100 max_flow_or_pressure_range 0.6 transition smooth exit_flow_under 0 temperature 89.00 name Pressurize pressure 10.999999999999993 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 8.80 max_flow_or_pressure 0 seconds 6.00 exit_pressure_under 0} {exit_if 0 flow 2.2 volume 100 max_flow_or_pressure_range 0.6 transition smooth exit_flow_under 0 temperature 89.00 name Extraction pressure 3.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 9.5 exit_pressure_under 0 seconds 30.00}}
author Decent
beverage_type espresso
espresso_decline_time 30
espresso_hold_time 15
espresso_pressure 6.0
espresso_temperature 92.50
espresso_temperature_0 89.00
espresso_temperature_1 89.00
espresso_temperature_2 89.00
espresso_temperature_3 89.00
espresso_temperature_steps_enabled 1
final_desired_shot_volume 36
final_desired_shot_volume_advanced 36
final_desired_shot_volume_advanced_count_start 2
final_desired_shot_weight 36
final_desired_shot_weight_advanced 36
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_minimum_pressure 4
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
maximum_flow 0
maximum_flow_range_advanced 0.6
maximum_flow_range_default 1.0
maximum_pressure 0
maximum_pressure_range_advanced 0.6
maximum_pressure_range_default 0.9
preinfusion_flow_rate 4
preinfusion_stop_pressure 4.0
preinfusion_time 20
pressure_end 4.0
profile_hide 0
profile_language en
profile_notes {This profile aims to unite the best practices in espresso extraction that we have learned so far with the Decent. It unites Brakel's Londonium, Rao's Blooming and Gagné's Adaptive profiles. Your grind should be finer for these medium light and darker roasts, aiming for a flow rate around 2 ml/s at peak pressure. 16g in, 36g out, in 32 seconds is a typical recipe.  Grind fine enough to keep dripping during preinfusion to around 4g.}
profile_title {Best practice (medium roast)}
settings_profile_type settings_2c
tank_desired_water_temperature 0

