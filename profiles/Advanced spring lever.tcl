advanced_shot {{exit_if 1 flow 6.0 volume 100 transition fast exit_flow_under 0 temperature 90.0 name infuse pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 3.0 exit_pressure_under 0 seconds 20.0} {exit_if 0 volume 100 transition fast exit_flow_under 0 temperature 90.0 name {rise and hold} pressure 9.0 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 seconds 10.0 exit_pressure_under 0} {exit_if 1 volume 100 transition smooth exit_flow_under 0 temperature 90.0 name decline pressure 4.0 sensor coffee pump pressure exit_type pressure_under exit_flow_over 1.2 exit_pressure_over 11 seconds 20.0 exit_pressure_under 4.0} {exit_if 1 flow 1.2 volume 100 transition smooth exit_flow_under 0 temperature 90.0 name {pressure limit} pressure 4.0 sensor coffee pump pressure exit_type flow_over exit_flow_over 1.0 exit_pressure_over 11 exit_pressure_under 0 seconds 10.0} {exit_if 0 flow 1.0 volume 100 transition smooth exit_flow_under 0 temperature 90.0 name {flow limit} pressure 3.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 30.0 exit_pressure_under 0}}
author Decent
espresso_hold_time 15
preinfusion_time 20
espresso_pressure 6.0
espresso_decline_time 30
pressure_end 4.0
espresso_temperature 90.0
settings_profile_type settings_2c2
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_minimum_pressure 4
preinfusion_flow_rate 4
profile_notes {An advanced spring lever profile that addresses a problem with simple spring lever profiles, by using both pressure and flow control. The last two steps keep pressure/flow under control as the puck erodes, if the shot has not finished by the end of step 3. Please consider this as a starting point for tweaking.}
water_temperature 80
final_desired_shot_weight 32
final_desired_shot_weight_advanced 36
tank_desired_water_temperature 0
final_desired_shot_volume_advanced 0
preinfusion_guarantee 1
profile_title {Advanced spring lever by John Weiss}
profile_language en
preinfusion_stop_pressure 4.0

