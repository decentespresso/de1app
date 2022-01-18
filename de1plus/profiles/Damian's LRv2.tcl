advanced_shot {{exit_if 1 flow 8 volume 100 transition fast exit_flow_under 0 temperature 89.0 name Fill pressure 2.00 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 1.5 exit_pressure_under 0 seconds 25.00} {exit_if 0 flow 8 volume 100 transition fast exit_flow_under 0 temperature 88.5 name Infuse pressure 3.0 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 3.0 seconds 12.0 exit_pressure_under 0} {exit_if 0 volume 100 transition fast exit_flow_under 0 temperature 88.5 name {Pressure Up} pressure 9.0 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 8.0} {exit_if 1 volume 100 transition smooth exit_flow_under 0 temperature 88.0 name {Pressure Decline} pressure 3.0 sensor coffee pump pressure exit_type flow_over exit_flow_over 2.80 exit_pressure_over 11 exit_pressure_under 0 seconds 55.00} {exit_if 1 volume 100 transition fast exit_flow_under 0 temperature 88.0 name {Pressure Hold} pressure 3.0 sensor coffee pump pressure exit_type flow_over exit_flow_over 2.80 exit_pressure_over 11 seconds 127 exit_pressure_under 0} {exit_if 0 flow 2.50 volume 100 transition fast exit_flow_under 0 temperature 88.0 name {Flow Limit} pressure 3.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 127 exit_pressure_under 0}}
author Damian
beverage_type espresso
espresso_decline_time 30
espresso_hold_time 15
espresso_pressure 6.0
espresso_temperature 89.0
espresso_temperature_0 89.0
espresso_temperature_1 89.0
espresso_temperature_2 89.0
espresso_temperature_3 89.0
final_desired_shot_volume 95
final_desired_shot_volume_advanced 0
final_desired_shot_volume_advanced_count_start 0
final_desired_shot_weight 42
final_desired_shot_weight_advanced 42
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
profile_hide 1
profile_language en
profile_notes {This profile simulates a Londinium R machines extraction style. This is an advanced profile with some added steps to assist with less than ideal puck prep. Christee-Lee described it as like having a milkshake with extra syrup. Great body and flavour range. 2nd edition.  This is identical to the "Londonium" profile, but renamed to be easier to understand.  By Damian Brakel https://www.diy.brakel.com.au/}
profile_title {Damian's LRv2}
settings_profile_type settings_2c
tank_desired_water_temperature 0

