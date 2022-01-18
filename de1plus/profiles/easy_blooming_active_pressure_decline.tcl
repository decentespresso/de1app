advanced_shot {{exit_if 1 flow 6.000000000000007 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 88.00 name preinfusion pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 4.00 max_flow_or_pressure 0 exit_pressure_under 0 seconds 20.00} {exit_if 1 flow 0 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 88.00 name {dynamic bloom} pressure 6.0 sensor coffee pump flow exit_type pressure_under exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 0 exit_pressure_under 2.00 seconds 60.00} {exit_if 0 flow 2.2 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 88.00 name {fast pressure} pressure 6.9999999999999964 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 max_flow_or_pressure 0 seconds 4.00 exit_pressure_under 0} {exit_if 1 flow 2.2 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 88.00 name {pressure hold 1} pressure 6.9999999999999964 sensor coffee pump pressure exit_type flow_over exit_flow_over 1.60 exit_pressure_over 11 max_flow_or_pressure 0 seconds 4.00 exit_pressure_under 0} {exit_if 1 flow 2.2 volume 100 max_flow_or_pressure_range 0.6 transition smooth exit_flow_under 1.40 temperature 88.00 name {P fast decline 1} pressure 5.699999999999997 sensor coffee pump pressure exit_type flow_under exit_flow_over 2.00 exit_pressure_over 11 max_flow_or_pressure 0 exit_pressure_under 0 seconds 5.00} {exit_if 1 flow 2.2 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 1.40 temperature 88.00 name {P fast decline 2} pressure 5.899999999999997 sensor coffee pump pressure exit_type flow_under exit_flow_over 2.00 exit_pressure_over 11 max_flow_or_pressure 0 seconds 40.00 exit_pressure_under 0} {exit_if 1 flow 2.2 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 1.80 temperature 88.00 name {pressure hold 2} pressure 6.9999999999999964 sensor coffee pump pressure exit_type flow_over exit_flow_over 1.90 exit_pressure_over 11 max_flow_or_pressure 0 exit_pressure_under 0 seconds 8.00} {exit_if 1 flow 2.2 volume 100 max_flow_or_pressure_range 0.6 transition smooth exit_flow_under 1.70 temperature 88.00 name {P decline 1} pressure 5.799999999999996 sensor coffee pump pressure exit_type flow_under exit_flow_over 2.20 exit_pressure_over 11 max_flow_or_pressure 0 exit_pressure_under 0 seconds 8.00} {exit_if 1 flow 2.2 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 1.70 temperature 88.00 name {P decline 2} pressure 5.899999999999997 sensor coffee pump pressure exit_type flow_under exit_flow_over 2.20 exit_pressure_over 11 max_flow_or_pressure 0 exit_pressure_under 0 seconds 40.00} {exit_if 1 flow 2.2 volume 100 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 1.80 temperature 88.00 name {pressure hold 3} pressure 6.9999999999999964 sensor coffee pump pressure exit_type flow_over exit_flow_over 2.20 exit_pressure_over 11 max_flow_or_pressure 0 seconds 30.00 exit_pressure_under 0} {exit_if 0 flow 2.2 volume 100 max_flow_or_pressure_range 0.6 transition smooth exit_flow_under 1.80 temperature 88.00 name {P slow decline} pressure 5.899999999999997 sensor coffee pump pressure exit_type flow_over exit_flow_over 2.20 exit_pressure_over 11 max_flow_or_pressure 0 exit_pressure_under 0 seconds 40.00}}
author Decent
beverage_type espresso
espresso_decline_time 30
espresso_hold_time 15
espresso_pressure 6.0
espresso_temperature 88.00
espresso_temperature_0 88.00
espresso_temperature_1 88.00
espresso_temperature_2 88.00
espresso_temperature_3 88.00
espresso_temperature_steps_enabled 0
final_desired_shot_volume 42
final_desired_shot_volume_advanced 0
final_desired_shot_volume_advanced_count_start 1
final_desired_shot_weight 42
final_desired_shot_weight_advanced 45.0
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_minimum_pressure 4
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
maximum_flow 0
maximum_flow_range_advanced 3.5
maximum_flow_range_default 1.0
maximum_pressure 0
maximum_pressure_range_advanced 1.0
maximum_pressure_range_default 0.9
preinfusion_flow_rate 4
preinfusion_stop_pressure 4.0
preinfusion_time 20
pressure_end 4.0
profile_hide 1
profile_language en
profile_notes {This profile is a more forgiving evolution of Scott Rao’s original blooming profile. It can produce tasty cups of espresso coffee in a wide range of grind settings. This is accomplished thanks to 2 main features: 1. As the bloom with no water flow progresses, the pressure measured above the puck decreases. We have added a condition asking the machine to end the bloom and switch to the next step when the pressure has declined from 4 bar to 2 bar. Doing so, the bloom is shorter when coarser grinds are used and longer with finer grinds. This guarantees a more consistent puck resistance when the subsequent extraction phase is about to start. The length of the bloom is no longer a fixed value. 2. Then, the pressure of the extraction phase adapts automatically based on the estimated flow rate evolution, that is, in some way, an image of the puck resistance. The pressure decline starts earlier when the resistance is lower (when the DE1 sees a quicker increase of the flow rate) and occurs later when the resistance is higher. The profile has been developed with lightly roasted beans (hence the limited maximum pressure and the medium-high optimum flow rate during the extraction phase), ground with large flat burrs, but some users have also reported good results with darker roast levels. The temperature has been set to 88°C: it can be increased with very light roasts and / or when a grinder with a wider particle distribution (e.g. conical grinder) is used. The temperature can be decreased to 84°C – 86°C with darker roasts. The length of the bloom phase can also be adjusted with the exit pressure condition: e.g. increased exit pressure for a shorter bloom (probably a sensible approach for darker roasts) and lower exit pressure for longer blooms. With a 20 gram dose and considering extraction ratios between 1:2 to 1:2.5, this profile has generally produced very tasty shots with total shot times ranging from 25 to 45 seconds. By Stéphane Ribes.}
profile_title {Easy blooming - active pressure decline}
settings_profile_type settings_2c
tank_desired_water_temperature 0

