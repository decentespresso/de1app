advanced_shot {{exit_if 0 flow 4 volume 100 transition fast exit_flow_under 0 temperature 88.0 name preinfusion pressure 0 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 4 exit_pressure_under 0 seconds 5.00} {flow 4 volume 100 exit_if 1 transition fast exit_flow_under 0 temperature 88.0 name preinfusion pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 4 exit_pressure_under 0 seconds 20} {name {rise and hold} temperature 88.0 sensor coffee pump pressure transition fast pressure 8.6 seconds 4 volume 100 exit_if 0 exit_pressure_over 11 exit_pressure_under 0 exit_flow_over 6 exit_flow_under 0} {name decline temperature 88.0 sensor coffee pump pressure transition smooth pressure 6.0 seconds 35 volume 100 exit_if 0 exit_pressure_over 11 exit_pressure_under 0 exit_flow_over 6 exit_flow_under 0}}
author Decent
espresso_hold_time 60
preinfusion_time 0
espresso_pressure 0.0
espresso_decline_time 60
pressure_end 0.0
espresso_temperature 88.0
settings_profile_type settings_2a
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_minimum_pressure 4
preinfusion_flow_rate 4
profile_notes {For use with machines that have a group head controller (GHC).  Hold your finger on the GHC for the pressure you want.}
water_temperature 80
final_desired_shot_volume 0
final_desired_shot_weight 36
final_desired_shot_weight_advanced 0
tank_desired_water_temperature 0
final_desired_shot_volume_advanced 0
preinfusion_guarantee 0
profile_title {Manual pressure control for GHC}
profile_language en
preinfusion_stop_pressure 4
profile_hide 0

