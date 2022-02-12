advanced_shot {{exit_if 0 flow 5.0 volume 465.00 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 92.00 name preinfusion pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 4.00 max_flow_or_pressure 0 seconds 6.00 exit_pressure_under 0} {exit_if 0 flow 0 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 85.00 name pause pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 0 seconds 120.00 exit_pressure_under 0} {exit_if 0 flow 3.0 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 85.00 weight 150.00 name {flat flow} pressure 4.0 pump flow sensor coffee exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 3.0 seconds 120.00 exit_pressure_under 0} {exit_if 0 flow 0.0 volume 500 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 92.00 name {reset temperature} pressure 4.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 0 exit_pressure_under 0 seconds 1.0}}
author Decent
beverage_type filter
espresso_decline_time 30
espresso_hold_time 15
espresso_pressure 6.0
espresso_temperature 92.0
espresso_temperature_0 92.0
espresso_temperature_1 92.0
espresso_temperature_2 92.0
espresso_temperature_3 92.0
espresso_temperature_steps_enabled 0
final_desired_shot_volume 42
final_desired_shot_volume_advanced 100
final_desired_shot_volume_advanced_count_start 1
final_desired_shot_weight 42
final_desired_shot_weight_advanced 100.0
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
preinfusion_stop_pressure 4.0
preinfusion_time 20
pressure_end 4.0
profile_hide 1
profile_language en
profile_notes {A new technique developed by Scott Rao, for making filter coffee with an espresso machine and 24g basket.  The process: (1) insert two micron 55mm paper filter into the bottom of a clean portafilter basket.  (2) Rinser the filter and basket with hot water.  (3) Fill the basket with 20g to 22g of finely ground coffee, not quite espresso grind, but far finer than any filter grind.  (4) WDT the grounds.  (5) tamping is optional.  (6) Place a metal mesh filter on top.  (7) Lock in the portafilter and make the espresso to a 5:1 ratio. (8) Dilute with 225g-250g of water.}
profile_title {Filter 2.0}
settings_profile_type settings_2c
tank_desired_water_temperature 0

