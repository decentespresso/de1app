advanced_shot {{exit_if 0 flow 6.0 volume 70.0 transition fast exit_flow_under 0 temperature 99.0 name Prewet pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 4.0} {exit_if 0 flow 0 volume 100 transition fast exit_flow_under 0 temperature 97.0 name Pause pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 40.0} {exit_if 0 flow 6.0 volume 250.0 transition fast exit_flow_under 0 temperature 97.0 name {Main water #1} pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 14.0 exit_pressure_under 0} {exit_if 0 flow 0 volume 250.0 transition fast exit_flow_under 0 temperature 95.0 name Pause pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 20.0 exit_pressure_under 0} {exit_if 0 flow 5.0 volume 200.0 transition fast exit_flow_under 0 temperature 95.0 name {Main water #2} pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 25.0 exit_pressure_under 0} {exit_if 0 flow 0 volume 175.0 transition fast exit_flow_under 0 temperature 95.0 name Drain pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 20.0 exit_pressure_under 0}}
author Decent
espresso_decline_time 26
espresso_hold_time 8
espresso_pressure 9.0
espresso_temperature 94
final_desired_shot_volume 36
final_desired_shot_volume_advanced 180
final_desired_shot_weight 36
final_desired_shot_weight_advanced 135
flow_profile_decline 1
flow_profile_decline_time 23
flow_profile_hold 2.3
flow_profile_hold_time 2
flow_profile_minimum_pressure 6
flow_profile_preinfusion 4.2
flow_profile_preinfusion_time 6
preinfusion_flow_rate 4.5
preinfusion_guarantee 1
preinfusion_stop_pressure 4
preinfusion_time 20
pressure_end 0.0
profile_hide 1
profile_language en
profile_notes {A final evolution of the classic lever machine style was to add a second spring. This helped work around a deficiency with single springs, namely that the top pressure achieved went down almost immediately, rather than being held.  The second spring required more arm muscle but is often considered the final perfection of the lever espresso style.}
profile_title {Two spring lever machine to 9 bar}
settings_profile_type settings_2a
tank_desired_water_temperature 0
beverage_type {espresso}
read_only 1