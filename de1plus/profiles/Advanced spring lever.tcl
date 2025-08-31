advanced_shot {{exit_if 1 flow 8.0 volume 0 max_flow_or_pressure_range 0.6 transition fast popup {} exit_flow_under 0 temperature 88.0 weight 0.0 name infuse pressure 0 pump flow sensor coffee exit_type pressure_over exit_flow_over 6 max_flow_or_pressure 0 exit_pressure_over 6.0 seconds 10 exit_pressure_under 0} {exit_if 0 flow 8.0 volume 0 max_flow_or_pressure_range 0.6 transition fast popup {} exit_flow_under 0 temperature 88.0 weight 0.0 name {rise and hold} pressure 9.0 pump pressure sensor coffee exit_type pressure_over exit_flow_over 6 max_flow_or_pressure 0 exit_pressure_over 11 seconds 3.00 exit_pressure_under 0} {exit_if 1 flow 8.0 volume 0 max_flow_or_pressure_range 0.6 transition smooth popup {} exit_flow_under 0 temperature 88.0 weight 0.0 name decline pressure 6.0 pump pressure sensor coffee exit_type pressure_under exit_flow_over 1.2 max_flow_or_pressure 1.5 exit_pressure_over 11 seconds 30 exit_pressure_under 6.0} {exit_if 0 flow 1.5 volume 0 max_flow_or_pressure_range 0.6 transition smooth popup {} exit_flow_under 0 temperature 88.0 weight 0.0 name {maintain flow} pressure 3.0 pump flow sensor coffee exit_type flow_over exit_flow_over 6 max_flow_or_pressure 6.0 exit_pressure_over 11 seconds 30 exit_pressure_under 0}}
author Decent
beverage_type espresso
espresso_decline_time 30
espresso_hold_time 15
espresso_pressure 6.0
espresso_temperature 88.0
espresso_temperature_0 88.0
espresso_temperature_1 88.0
espresso_temperature_2 88.0
espresso_temperature_3 88.0
espresso_temperature_steps_enabled 0
final_desired_shot_volume 32
final_desired_shot_volume_advanced 0
final_desired_shot_volume_advanced_count_start 0
final_desired_shot_weight 32
final_desired_shot_weight_advanced 32
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
profile_notes {Advanced spring lever profile, with additional constant flow step to salvage overly slow and fast flowing shots.}
profile_title {Advanced spring lever}
read_only 1
settings_profile_type settings_2c
tank_desired_water_temperature 0

