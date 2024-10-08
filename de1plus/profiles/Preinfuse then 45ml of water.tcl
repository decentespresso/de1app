advanced_shot {{exit_if 0 flow 6.0 volume 70.0 transition fast exit_flow_under 0 temperature 99.0 name Prewet pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 4.0} {exit_if 0 flow 0 volume 100 transition fast exit_flow_under 0 temperature 97.0 name Pause pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 40.0} {exit_if 0 flow 6.0 volume 250.0 transition fast exit_flow_under 0 temperature 97.0 name {Main water #1} pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 14.0 exit_pressure_under 0} {exit_if 0 flow 0 volume 250.0 transition fast exit_flow_under 0 temperature 95.0 name Pause pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 20.0 exit_pressure_under 0} {exit_if 0 flow 5.0 volume 200.0 transition fast exit_flow_under 0 temperature 95.0 name {Main water #2} pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 25.0 exit_pressure_under 0} {exit_if 0 flow 0 volume 175.0 transition fast exit_flow_under 0 temperature 95.0 name Drain pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 20.0 exit_pressure_under 0}}
author Decent
espresso_decline_time 0
espresso_hold_time 20
espresso_pressure 9.0
espresso_temperature 90.0
final_desired_shot_volume 36
final_desired_shot_volume_advanced 0
final_desired_shot_weight 36
final_desired_shot_weight_advanced 0
flow_profile_decline 1
flow_profile_decline_time 23
flow_profile_hold 2.0
flow_profile_hold_time 0
flow_profile_minimum_pressure 6
flow_profile_preinfusion 4.2
flow_profile_preinfusion_time 6
preinfusion_flow_rate 5.0
preinfusion_guarantee 0
preinfusion_stop_pressure 4.0
preinfusion_time 25
pressure_end 6.0
profile_hide 1
profile_language en
profile_notes {Australian barista Matt Perger suggested this technique to us. The idea is to fully saturate your puck, and then squeeze the brewed coffee out using a calculated water volume.  This results in consistently brewed espresso without needing to use a scale.}
profile_title {Preinfuse then 45ml of water}
settings_profile_type settings_2b
tank_desired_water_temperature 0
beverage_type {espresso}
read_only 1