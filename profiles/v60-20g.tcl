advanced_shot {{exit_if 0 flow 8 volume 100 transition fast exit_flow_under 0 temperature 100 name preinfusion pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 1.5 exit_pressure_under 0 seconds 12.00} {exit_if 0 flow 0.0 volume 100 transition fast exit_flow_under 0 temperature 100 name bloom* pressure 8.6 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 30.00 exit_pressure_under 0} {exit_if 0 flow 8.0 volume 100 transition fast exit_flow_under 0 temperature 100 name pulse pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 11.00 exit_pressure_under 0} {exit_if 0 flow 0.0 volume 100 transition fast exit_flow_under 0 temperature 100 name pause pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 35.00} {exit_if 0 flow 8 volume 100 transition fast exit_flow_under 0 temperature 100 name pulse pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 11.00 exit_pressure_under 0} {exit_if 0 flow 0.0 volume 100 transition fast exit_flow_under 0 temperature 100 name pause pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 35.00} {exit_if 0 flow 8.0 volume 100 transition fast exit_flow_under 0 temperature 100 name pulse pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 11.00 exit_pressure_under 0} {exit_if 0 flow 0.1 volume 100 transition fast exit_flow_under 0 temperature 100 name {[ spin at end]*} pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 1 exit_pressure_under 0}}
author Decent
espresso_decline_time 25
espresso_hold_time 10
espresso_pressure 8.6
espresso_temperature 100
final_desired_shot_volume 32
final_desired_shot_volume_advanced 0
final_desired_shot_weight 32
final_desired_shot_weight_advanced 0
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_minimum_pressure 4
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
preinfusion_flow_rate 4
preinfusion_guarantee 0
preinfusion_stop_pressure 1.5
preinfusion_time 20
pressure_end 6.0
profile_hide 1
profile_language en
profile_notes {Scott Rao's 20g profile for pour overs using the Decent pour over basket.}
profile_title {V60 20g}
settings_profile_type settings_2c
tank_desired_water_temperature 28
water_temperature 80

