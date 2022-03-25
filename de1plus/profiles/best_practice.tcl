advanced_shot {{exit_if 0 flow 8.0 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 93.00 name Prefill pressure 3.0 sensor coffee pump flow exit_type pressure_over exit_flow_over 1.00 exit_pressure_over 3.00 max_flow_or_pressure 0 exit_pressure_under 0 seconds 2.00} {exit_if 1 flow 8.0 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 93.00 name Fill pressure 3.0 sensor coffee pump flow exit_type pressure_over exit_flow_over 1.00 exit_pressure_over 3.00 max_flow_or_pressure 0 seconds 12.00 exit_pressure_under 0} {exit_if 1 flow 6.8 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 3.00 temperature 88.00 name Compressing pressure 3.0 sensor coffee pump pressure exit_type flow_under exit_flow_over 1.00 exit_pressure_over 3.00 max_flow_or_pressure 0 seconds 12.00 exit_pressure_under 0} {exit_if 0 flow 6.8 volume 0 max_flow_or_pressure_range 0.6 transition smooth exit_flow_under 0 temperature 88.00 weight 0 name Dripping pressure 3.0 pump pressure sensor coffee exit_type flow_over exit_flow_over 1.00 exit_pressure_over 1.5 max_flow_or_pressure 0 exit_pressure_under 0 seconds 6.00} {exit_if 1 volume 100 max_flow_or_pressure_range 0.6 transition smooth exit_flow_under 0 temperature 88.00 name Pressurize pressure 11.0 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 8.80 max_flow_or_pressure 0 exit_pressure_under 0 seconds 6.00} {exit_if 1 flow 1.5 volume 0 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 88.00 name {Extraction start} pressure 3.0 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 0 max_flow_or_pressure 9.5 exit_pressure_under 0 seconds 0.00} {exit_if 0 flow 2.5 volume 100 max_flow_or_pressure_range 0.6 transition smooth exit_flow_under 0 temperature 88.00 weight 0.0 name Extraction pressure 3.0 pump flow sensor coffee exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 9.5 exit_pressure_under 0 seconds 60.00}}
espresso_temperature_steps_enabled 1
author Decent
espresso_hold_time 15
preinfusion_time 20
espresso_pressure 6.0
espresso_decline_time 30
pressure_end 4.0
espresso_temperature 93.00
espresso_temperature_0 89.00
espresso_temperature_1 89.00
espresso_temperature_2 89.00
espresso_temperature_3 89.00
settings_profile_type settings_2c
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_minimum_pressure 4
preinfusion_flow_rate 4
profile_notes {This profile aims to unite the best practices in espresso extraction that we have learned so far with the Decent. It unites Brakel's Londonium, Rao's Blooming and Gagné's Adaptive profiles. The flow rate during extraction will automatically adjust itself from the flow rate actually happening during the Pressurize step and then gently increase it from there.  A 15g dose is typical.  Aim for a flow rate around 1.5 ml/s at the Pressurize step. 15g in, 33g out, in 32 seconds is a typical recipe for a medium roast.  Grind fine enough to keep dripping during preinfusion to around 4g.}
final_desired_shot_volume 36
final_desired_shot_weight 36
final_desired_shot_weight_advanced 36
tank_desired_water_temperature 0
final_desired_shot_volume_advanced 36
profile_title {Adaptive (for medium roasts)}
profile_language en
preinfusion_stop_pressure 4.0
profile_hide 0
final_desired_shot_volume_advanced_count_start 3
beverage_type espresso
maximum_pressure 0
maximum_pressure_range_advanced 0.6
maximum_flow_range_advanced 0.6
maximum_flow 0
maximum_pressure_range_default 0.9
maximum_flow_range_default 1.0

