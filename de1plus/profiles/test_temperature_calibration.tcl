advanced_shot {{exit_if 0 flow 6.0 volume 70.0 transition fast exit_flow_under 0 temperature 99.0 name Prewet pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 4.0} {exit_if 0 flow 0 volume 100 transition fast exit_flow_under 0 temperature 97.0 name Pause pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 40.0} {exit_if 0 flow 6.0 volume 250.0 transition fast exit_flow_under 0 temperature 97.0 name {Main water #1} pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 14.0 exit_pressure_under 0} {exit_if 0 flow 0 volume 250.0 transition fast exit_flow_under 0 temperature 95.0 name Pause pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 20.0 exit_pressure_under 0} {exit_if 0 flow 5.0 volume 200.0 transition fast exit_flow_under 0 temperature 95.0 name {Main water #2} pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 25.0 exit_pressure_under 0} {exit_if 0 flow 0 volume 175.0 transition fast exit_flow_under 0 temperature 95.0 name Drain pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 20.0 exit_pressure_under 0}}
author Decent
beverage_type calibrate
espresso_decline_time 0
espresso_hold_time 60
espresso_pressure 9.0
espresso_temperature 90.0
espresso_temperature_0 90.0
espresso_temperature_1 90.0
espresso_temperature_2 90.0
espresso_temperature_3 90.0
espresso_temperature_steps_enabled 0
final_desired_shot_volume 0
final_desired_shot_volume_advanced 180
final_desired_shot_volume_advanced_count_start 0
final_desired_shot_weight 0
final_desired_shot_weight_advanced 135
flow_profile_decline 1
flow_profile_decline_time 23
flow_profile_hold 3.0
flow_profile_hold_time 2
flow_profile_minimum_pressure 6
flow_profile_preinfusion 4.2
flow_profile_preinfusion_time 6
maximum_flow 0
maximum_flow_range_advanced 1.0
maximum_flow_range_default 1.0
maximum_pressure 0
maximum_pressure_range_advanced 0.9
maximum_pressure_range_default 0.9
preinfusion_flow_rate 4.5
preinfusion_stop_pressure 4.0
preinfusion_time 0
pressure_end 0.0
profile_hide 1
profile_language en
profile_notes {Make a device to read ºC inside a basket.  Drill a 3mm hole in a no hole basket. Thread a K type temperature bead through. Bend the wire. Run this profile twice to warm up the basket and portafilter. When the DE1 stabilizes at 90ºC, if the meter is not 90.0ºC then go to Settings->Machine->Calibrate and enter the temperature on your meter.  Press Enter, then Done, then Ok. Run the profile. Repeat until the DE1 is within 0.3ºC of the meter.}
profile_title {Test/temperature calibration}
settings_profile_type settings_2b
tank_desired_water_temperature 0

