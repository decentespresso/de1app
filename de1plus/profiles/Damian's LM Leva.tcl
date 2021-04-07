advanced_shot {{exit_if 1 flow 11 volume 100 transition fast exit_flow_under 0 temperature 89.00 name fill pressure 1.80 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 1.00 exit_pressure_under 0 seconds 20} {exit_if 1 flow 1.50 volume 100 transition fast exit_flow_under 0 temperature 88.50 name preinfusion pressure 2.20 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 4 seconds 10.00 exit_pressure_under 0} {exit_if 1 volume 100 transition fast exit_flow_under 0 temperature 88.0 name rise pressure 8.00 sensor coffee pump pressure exit_type pressure_over exit_flow_over 1.50 exit_pressure_over 8.00 seconds 5.00 exit_pressure_under 0} {exit_if 1 volume 100 transition fast exit_flow_under 0 temperature 88.0 name hold pressure 8.00 sensor coffee pump pressure exit_type flow_over exit_flow_over 1.50 exit_pressure_over 11 exit_pressure_under 0 seconds 5.00} {exit_if 0 volume 100 transition smooth exit_flow_under 0 temperature 88.0 name decline pressure 2.20 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 seconds 58.00 exit_pressure_under 0}}
author Damian
espresso_hold_time 4
preinfusion_time 20
espresso_pressure 8.6
espresso_decline_time 35
pressure_end 6.0
espresso_temperature 89.00
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
profile_notes {Damian wrote this profile to mimic a shot Gabor Laczko recorded on a La Marzocco Leva machine using his Smart Espresso Profiler. He feels that this is a great profile for non milk drinks, it highlights flavours in a smooth balanced way, with a more creamy body than the thicker chocolatey body of the LRv2 profile. By Damian Brakel https://www.diy.brakel.com.au/}
water_temperature 80
final_desired_shot_volume 36
final_desired_shot_weight 36
final_desired_shot_weight_advanced 42
tank_desired_water_temperature 0
final_desired_shot_volume_advanced 0
preinfusion_guarantee 0
profile_title {Damian's LM Leva}
profile_language en
preinfusion_stop_pressure 4
profile_hide 1
final_desired_shot_volume_advanced_count_start 2
beverage_type espresso

