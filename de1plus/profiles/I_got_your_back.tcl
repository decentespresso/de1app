advanced_shot {{exit_if 1 flow 4 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 90.00 name preinfusion pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 4.00 max_flow_or_pressure 0 exit_pressure_under 0 seconds 13.00} {exit_if 1 flow 2.2 volume 500.00 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 1.50 temperature 90.00 name {Low Resistance} pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 10.00 max_flow_or_pressure 0 seconds 30.00 exit_pressure_under 0} {exit_if 1 flow 0 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 90.0 name {Pause at HR} pressure 6.0 sensor coffee pump flow exit_type pressure_under exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 0 seconds 60.00 exit_pressure_under 2.00} {exit_if 0 flow 2.2 volume 500 max_flow_or_pressure_range 0.6 transition smooth exit_flow_under 0 temperature 90.00 name ramp pressure 4.0 sensor coffee pump flow exit_type flow_under exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 0 seconds 5.0 exit_pressure_under 0} {exit_if 1 flow 2.2 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 90.00 name {flat flow} pressure 4.0 sensor coffee pump flow exit_type pressure_under exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 8.6 exit_pressure_under 0 seconds 30.00}}
author Decent
beverage_type espresso
espresso_decline_time 30
espresso_hold_time 15
espresso_pressure 6.0
espresso_temperature 90.00
espresso_temperature_0 90.00
espresso_temperature_1 90.00
espresso_temperature_2 90.00
espresso_temperature_3 90.00
final_desired_shot_volume 42
final_desired_shot_volume_advanced 0
final_desired_shot_volume_advanced_count_start 2
final_desired_shot_weight 42.0
final_desired_shot_weight_advanced 36.0
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_hold 2.0
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
preinfusion_flow_rate 4.0
preinfusion_stop_pressure 4.0
preinfusion_time 20
pressure_end 4.0
profile_hide 1
profile_language en
profile_notes {The goal of this profile is to never fail to make an acceptable espresso, at any grinder dial setting. The profile detects the resistance by looking at the pressure. It then either it transitions to a flat 2.2ml/s flow shot at the low resistance (low pressure) or to bloom at the high resistance (high pressure/low flow rate).  Profile created by Shin.}
profile_title {I got your back}
settings_profile_type settings_2c
tank_desired_water_temperature 0

