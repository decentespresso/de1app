advanced_shot {{exit_if 1 flow 6.0 volume 100 transition fast exit_flow_under 4.0 temperature 84.0 name preinfusion pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 3.0 seconds 10.0 exit_pressure_under 0} {exit_if 0 volume 100 transition fast exit_flow_under 0 temperature 81.0 name {rise and hold} pressure 7.5 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 seconds 8.0 exit_pressure_under 0} {exit_if 0 volume 100 transition smooth exit_flow_under 0 temperature 78.0 name decline pressure 3.0 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 seconds 30.0 exit_pressure_under 0}}
author Decent
espresso_decline_time 30
espresso_hold_time 10
espresso_pressure 8.4
espresso_temperature 88.0
final_desired_shot_volume 36
final_desired_shot_volume_advanced 0
final_desired_shot_weight 36
final_desired_shot_weight_advanced 36
flow_profile_decline 1
flow_profile_decline_time 23
flow_profile_hold 4.0
flow_profile_hold_time 2
flow_profile_minimum_pressure 6
flow_profile_preinfusion 4.2
flow_profile_preinfusion_time 6
preinfusion_flow_rate 3.5
preinfusion_guarantee 1
preinfusion_stop_pressure 4
preinfusion_time 20
pressure_end 6.0
profile_hide 0
profile_language en
profile_notes {We recommend this pressure profile as the most likely to produce a good espresso in the most varied number of cases.  The decreasing pressure will help reduce acidity.}
profile_title {Best overall pressure profile}
settings_profile_type settings_2a
tank_desired_water_temperature 0
water_temperature 76

