advanced_shot {{exit_if 0 flow 11 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 105 name Heat pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 seconds 1.00 exit_pressure_under 0} {exit_if 1 flow 11 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 95.00 name Fill pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 max_flow_or_pressure 0 exit_pressure_over 2.00 exit_pressure_under 0 seconds 20.00} {exit_if 0 flow 4 volume 140.00 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 105 name Infuse pressure 0.10 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 exit_pressure_under 0 seconds 20.00} {exit_if 0 flow 11 volume 140.00 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 95.00 name Flush pressure 6.00 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 exit_pressure_under 0 seconds 30.00} {exit_if 0 flow 4.00 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 105 name Infuse pressure 0.10 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 exit_pressure_under 0 seconds 20.00} {exit_if 0 flow 11 volume 140.00 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 95.00 name Flush pressure 0.50 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 seconds 30.00 exit_pressure_under 0} {exit_if 0 flow 6.00 volume 153.00 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 105 name Infuse pressure 0.10 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 exit_pressure_under 0 seconds 20.00} {exit_if 0 flow 10.999999999999982 volume 140.00 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 105 name Flush pressure 0.10 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 seconds 30.00 exit_pressure_under 0} {exit_if 0 flow 6.00 volume 153.00 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 105 name Infuse pressure 0.10 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 exit_pressure_under 0 seconds 20.00} {exit_if 0 flow 11 volume 140.00 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 95.00 name Flush pressure 0.50 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 seconds 30.00 exit_pressure_under 0}}
espresso_temperature_steps_enabled 1
author Decent
espresso_hold_time 25
preinfusion_time 0
espresso_pressure 8.6
espresso_decline_time 0
pressure_end 6.0
espresso_temperature 105
espresso_temperature_0 90.0
espresso_temperature_1 88.0
espresso_temperature_2 88.0
espresso_temperature_3 88.0
settings_profile_type settings_2c
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_minimum_pressure 4
preinfusion_flow_rate 4
profile_notes {This profile requires a specially designed tea portafilter that opens its valve at pressures of 3 bar or above.  Put a tea bag or loose leaf tea into the basket.  Makes about 230ml of tea in 3 minutes.  The 2 bar of pressure extract a stronger brew, with different flavors.  You can up the pressure during the infusion steps, if you tighten the screw on your tea portafilter.}
water_temperature 80
final_desired_shot_volume 36
final_desired_shot_weight 36
final_desired_shot_weight_advanced 36
tank_desired_water_temperature 0
final_desired_shot_volume_advanced 0
profile_title {Tea portafilter/black tea}
profile_language en
preinfusion_stop_pressure 4
profile_hide 0
final_desired_shot_volume_advanced_count_start 1
beverage_type tea_portafilter
maximum_pressure 0
maximum_pressure_range_advanced 0.6
maximum_flow_range_advanced 0.6
maximum_flow 0
maximum_pressure_range_default 0.9
maximum_flow_range_default 1.0

