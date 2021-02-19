advanced_shot {{exit_if 0 flow 6.0 volume 500 transition fast exit_flow_under 0 temperature 99.0 name Prewet pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 4.0} {exit_if 0 flow 0 volume 500 transition fast exit_flow_under 0 temperature 97.0 name Pause pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 40.0} {exit_if 0 flow 6.0 volume 500 transition fast exit_flow_under 0 temperature 97.0 name {Main water #1} pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 14.0 exit_pressure_under 0} {exit_if 0 flow 0 volume 500 transition fast exit_flow_under 0 temperature 95.0 name Pause pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 20.0 exit_pressure_under 0} {exit_if 0 flow 5.0 volume 500 transition fast exit_flow_under 0 temperature 95.0 name {Main water #2} pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 25.0 exit_pressure_under 0} {exit_if 0 flow 0 volume 500 transition fast exit_flow_under 0 temperature 95.0 name Drain pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 20.0 exit_pressure_under 0} {exit_if 0 flow 0 volume 500 transition fast exit_flow_under 0 temperature 99.0 name {Reset temperature} pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 1.0 exit_pressure_under 0}}
author Decent
espresso_decline_time 25
espresso_hold_time 10
espresso_pressure 8.6
espresso_temperature 99.0
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
preinfusion_guarantee 1
preinfusion_stop_pressure 1.5
preinfusion_time 20
pressure_end 6.0
profile_hide 1
profile_language en
profile_notes {You can make a pour over coffee with your espresso machine.  To do this, first remove the drip tray. Then, place a coffee mug with a filter cone on it under the espresso machine's group head.}
profile_title {Pour over basket/Decent pour over}
settings_profile_type settings_2c
tank_desired_water_temperature 0
water_temperature 80
beverage_type {pourover}

