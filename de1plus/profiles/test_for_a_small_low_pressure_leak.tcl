advanced_shot {{exit_if 1 flow 1 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 0.0 name {preinfusion to 0.5 bar} pressure 10.00 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 0.50 max_flow_or_pressure 0 seconds 60.00 exit_pressure_under 0} {exit_if 0 flow 8.00 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 0.0 name {rise to 0.5 bar and hold} pressure 0.5 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 0.50 max_flow_or_pressure 0 exit_pressure_under 0 seconds 127} {exit_if 0 flow 8.00 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 0.0 name {rise to 0.5 bar and hold} pressure 0.5 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 max_flow_or_pressure 0 exit_pressure_over 0.50 seconds 127 exit_pressure_under 0} {exit_if 0 flow 8.00 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 0.0 name {rise to 0.5 bar and hold} pressure 0.5 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 0.50 max_flow_or_pressure 0 exit_pressure_under 0 seconds 127} {exit_if 0 flow 8.00 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 0.0 name {rise to 0.5 bar and hold} pressure 0.5 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 max_flow_or_pressure 0 exit_pressure_over 0.50 seconds 127 exit_pressure_under 0} {exit_if 0 flow 8.00 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 0.0 name {rise to 0.5 bar and hold} pressure 0.5 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 0.50 max_flow_or_pressure 0 exit_pressure_under 0 seconds 127} {exit_if 0 flow 8.00 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 0.0 name {rise to 0.5 bar and hold} pressure 0.5 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 max_flow_or_pressure 0 exit_pressure_over 0.50 seconds 127 exit_pressure_under 0} {exit_if 0 flow 8.00 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 0.0 name {rise to 0.5 bar and hold} pressure 0.5 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 0.50 max_flow_or_pressure 0 exit_pressure_under 0 seconds 127}}
author Decent
beverage_type calibrate
espresso_decline_time 60
espresso_hold_time 60
espresso_pressure 10.0
espresso_temperature 0.0
espresso_temperature_0 0.0
espresso_temperature_1 0.0
espresso_temperature_2 0.0
espresso_temperature_3 0.0
espresso_temperature_steps_enabled 1
final_desired_shot_volume 0
final_desired_shot_volume_advanced 0
final_desired_shot_volume_advanced_count_start 1
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
preinfusion_flow_rate 8.0
preinfusion_stop_pressure 10.0
preinfusion_time 60
pressure_end 10.0
profile_hide 1
profile_language en
profile_notes {Put a blind (no hole) portafilter basket into your portafilter, and then run this profile to see if there are any water leaks in your machine.  Once pressure is reached, water will be turned off and pressure held.  After five minutes check with a flashlight for any water droplets inside the machine.   You should not wait for the profile to stop. Start looking for leaks after 3 minutes and stop the profile once you feel assured there is no visible water leaking.}
profile_title {Test/low pressure leak}
settings_profile_type settings_2c
tank_desired_water_temperature 0

