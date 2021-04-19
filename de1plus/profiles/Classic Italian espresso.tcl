advanced_shot {{exit_if 1 flow 4 volume 100 transition fast exit_flow_under 0 temperature 98.0 name preinfusion pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 4 exit_pressure_under 0 seconds 25.0} {exit_if 0 flow 0 volume 100 transition fast exit_flow_under 0 temperature 90.0 name pause pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 30.0} {exit_if 0 flow 2.2 volume 100 transition smooth exit_flow_under 0 temperature 92.0 name ramp pressure 4.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 5.0} {exit_if 0 flow 2.2 volume 100 transition fast exit_flow_under 0 temperature 92.0 name {flat flow} pressure 4.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 20.0 exit_pressure_under 0} {exit_if 0 flow 0.0 volume 100 transition fast exit_flow_under 0 temperature 98.0 name {reset temperature} pressure 4.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 1.0 exit_pressure_under 0}}
author Decent
espresso_hold_time 35
preinfusion_time 8
espresso_pressure 9.0
espresso_decline_time 0
pressure_end 6.0
espresso_temperature 94
espresso_temperature_0 94
espresso_temperature_1 94
espresso_temperature_2 94
espresso_temperature_3 94
settings_profile_type settings_2a
flow_profile_preinfusion 4.2
flow_profile_preinfusion_time 6
flow_profile_hold 1.8
flow_profile_hold_time 0
flow_profile_decline 1
flow_profile_decline_time 23
flow_profile_minimum_pressure 6
preinfusion_flow_rate 4.5
profile_notes {This will imitate the espresso style of the majority of cafes around the world. It uses a short preinfusion with a flat 9 bar pressure profile.}
water_temperature 86.0
final_desired_shot_volume 36
final_desired_shot_weight 36
final_desired_shot_weight_advanced 60
tank_desired_water_temperature 0
final_desired_shot_volume_advanced 0
profile_title {Classic Italian espresso}
profile_language en
preinfusion_stop_pressure 4
profile_hide 0
final_desired_shot_volume_advanced_count_start 0
beverage_type espresso
maximum_pressure 0
maximum_pressure_range_advanced 0.6
maximum_flow_range_advanced 0.6
maximum_flow 4.5
maximum_pressure_range_default 0.9
maximum_flow_range_default 1.0

