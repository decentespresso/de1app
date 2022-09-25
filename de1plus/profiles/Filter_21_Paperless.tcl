advanced_shot {{exit_if 0 flow 4.0 volume 0 max_flow_or_pressure_range 1.0 transition fast exit_flow_under 0 temperature 92.00 weight 0.00 name preinfusion pressure 1 pump flow sensor coffee exit_type pressure_over exit_flow_over 6 exit_pressure_over 4.00 max_flow_or_pressure 0 seconds 4.00 exit_pressure_under 0} {exit_if 1 flow 1.0 volume 0 max_flow_or_pressure_range 1.0 transition smooth exit_flow_under 0 temperature 92.00 weight 0 name preinfusion pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 1.00 max_flow_or_pressure 0 exit_pressure_under 0 seconds 8.00} {exit_if 1 flow 1.0 volume 0 max_flow_or_pressure_range 1.0 transition fast exit_flow_under 0 temperature 92.00 weight 1.00 name preinfusion pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 0.30 max_flow_or_pressure 0 exit_pressure_under 0 seconds 10.00} {exit_if 0 flow 0.1 volume 0 max_flow_or_pressure_range 1.0 transition fast exit_flow_under 0 temperature 85.00 weight 0 name {1 ml/s bloom} pressure 6.0 pump flow sensor coffee exit_type pressure_over exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 0.3 seconds 90.00 exit_pressure_under 0} {exit_if 0 flow 3.0 volume 0 max_flow_or_pressure_range 1.0 transition fast exit_flow_under 0 temperature 85.00 weight 0 name ramp pressure 4.0 pump flow sensor coffee exit_type pressure_over exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 2.0 seconds 10.00 exit_pressure_under 0} {exit_if 0 flow 3.0 volume 0 max_flow_or_pressure_range 1.0 transition fast exit_flow_under 0 temperature 92.00 weight 0 name {3 ml/s} pressure 4.0 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 0.0 exit_pressure_under 0 seconds 120.00}}
espresso_temperature_steps_enabled 0
author Cesar
espresso_hold_time 15
preinfusion_time 20
espresso_pressure 6.0
espresso_decline_time 30
pressure_end 4.0
espresso_temperature 92.00
espresso_temperature_0 92.00
espresso_temperature_1 92.00
espresso_temperature_2 92.00
espresso_temperature_3 92.00
settings_profile_type settings_2c
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_minimum_pressure 4
preinfusion_flow_rate 4
profile_notes {8g+10g (18g) in 22g basket
This is a modification of Scott Rao's 2.1 profile that doesn't use a paper filter. This profile has only been tested WITH a scale. 1) Grind 8g of coffee as you would for Traditional Lever or E61 9bar profiles that you like. 2) WDT all the way to the bottom and get as flat a bed as you can. 3) Grind 10g of coffee on top of that as you would for a V60 or a little finer. 3) WDT just the surface and OCD the top. 4) Tamp gently. 5) Place a metal mesh filter on top.  6) Lock in the portafilter and it should make the espresso to a little less than 5:1 ratio.
}
final_desired_shot_volume 42
final_desired_shot_weight 42
final_desired_shot_weight_advanced 90.6
tank_desired_water_temperature 0
final_desired_shot_volume_advanced 0
profile_title {Filter 2.1.1 Home}
profile_language en
preinfusion_stop_pressure 4.0
profile_hide 0
final_desired_shot_volume_advanced_count_start 0
beverage_type espresso
maximum_pressure 0
maximum_pressure_range_advanced 1.0
maximum_flow_range_advanced 4.5
maximum_flow 0
maximum_pressure_range_default 0.9
maximum_flow_range_default 1.0

