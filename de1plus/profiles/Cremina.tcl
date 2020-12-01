advanced_shot {{exit_if 1 flow 4 volume 100 transition fast exit_flow_under 0 temperature 91.5 name preinfusion pressure 1.1 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 3.0 exit_pressure_under 0 seconds 5.0} {exit_if 0 flow 0.0 volume 100 transition fast exit_flow_under 0 temperature 91.5 name soak pressure 1.1 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 3.0 exit_pressure_under 0 seconds 10.0} {exit_if 0 volume 100 transition smooth exit_flow_under 0 temperature 91.5 name ramp pressure 9.0 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 9.0 seconds 10.0 exit_pressure_under 0} {exit_if 0 volume 100 transition smooth exit_flow_under 0 temperature 92.0 name ramp-down pressure 3.0 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 seconds 50.0 exit_pressure_under 0}}
author Decent
espresso_hold_time 10
preinfusion_time 20
espresso_pressure 8.6
espresso_decline_time 25
pressure_end 6.0
espresso_temperature 91.5
espresso_temperature_0 91.5
espresso_temperature_1 91.5
espresso_temperature_2 91.5
espresso_temperature_3 91.5
settings_profile_type settings_2c
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_minimum_pressure 4
preinfusion_flow_rate 4
profile_notes {Aim for a 50 second shot time to have a thick espresso in the style of the much-loved Cremina manual lever machine. By Denis from KafaTek.}
water_temperature 80
final_desired_shot_volume 38
final_desired_shot_weight 38
final_desired_shot_weight_advanced 0
tank_desired_water_temperature 0
final_desired_shot_volume_advanced 0
preinfusion_guarantee 0
profile_title {Cremina lever machine}
profile_language en
preinfusion_stop_pressure 4
profile_hide 0
final_desired_shot_volume_advanced_count_start 0
bean_brand {}
bean_type {}
grinder_setting {}
grinder_dose_weight 0
grinder_model {}

