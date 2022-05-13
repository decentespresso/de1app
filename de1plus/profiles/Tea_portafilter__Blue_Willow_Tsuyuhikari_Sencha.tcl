advanced_shot {{exit_if 1 flow 4 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 60.0 name Fill pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 3.00 max_flow_or_pressure 0 seconds 20.00 exit_pressure_under 0} {exit_if 0 flow 4 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 60.0 name Infuse pressure 0.10 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 seconds 20.00 exit_pressure_under 0} {exit_if 0 flow 11 volume 80.00 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 60.0 name Flush pressure 6.00 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 seconds 30.00 exit_pressure_under 0} {exit_if 0 flow 4.00 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 60.0 name Infuse pressure 0.10 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 seconds 25.00 exit_pressure_under 0} {exit_if 0 flow 11 volume 80.00 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 60.0 name Flush pressure 0.50 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 seconds 30.00 exit_pressure_under 0} {exit_if 0 flow 11 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 60.0 name infuse pressure 0.1 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 seconds 30.00 exit_pressure_under 0} {exit_if 0 flow 11 volume 80.00 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 60.0 name Flush pressure 0.50 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 2.00 max_flow_or_pressure 0 seconds 30.00 exit_pressure_under 0}}
author Decent
beverage_type tea_portafilter
espresso_decline_time 0
espresso_hold_time 25
espresso_pressure 8.6
espresso_temperature 60.0
espresso_temperature_0 90.0
espresso_temperature_1 88.0
espresso_temperature_2 88.0
espresso_temperature_3 88.0
espresso_temperature_steps_enabled 1
final_desired_shot_volume 36
final_desired_shot_volume_advanced 0
final_desired_shot_volume_advanced_count_start 1
final_desired_shot_weight 100
final_desired_shot_weight_advanced 350
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
preinfusion_flow_rate 4
preinfusion_stop_pressure 4
preinfusion_time 0
pressure_end 6.0
profile_hide 1
profile_language en
profile_notes {This profile requires the Decent Espresso tea portafilter and is optimized for the tea named "Tsuyuhikari Sencha" from Blue Willow Tea https://www.bluewillowtea.com/ - Taste wise, this profile created a similar taste to the mug made with a French press, with a 3 minute and 65C temperature water, though the end beverage quantity is less on the DE1 version. Three infusion steps were used, because we found the 4th infusion to be unpleasant.  We use a 4 gram dose of leaves for this profile.}
profile_title {Tea portafilter/Sencha}
settings_profile_type settings_2c
tank_desired_water_temperature 0

