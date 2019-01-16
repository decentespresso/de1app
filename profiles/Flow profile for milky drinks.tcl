advanced_shot {{exit_if 1 flow 6.0 volume 100 transition fast exit_flow_under 4.0 temperature 84.0 name preinfusion pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 3.0 seconds 10.0 exit_pressure_under 0} {exit_if 0 volume 100 transition fast exit_flow_under 0 temperature 81.0 name {rise and hold} pressure 7.5 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 seconds 8.0 exit_pressure_under 0} {exit_if 0 volume 100 transition smooth exit_flow_under 0 temperature 78.0 name decline pressure 3.0 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 seconds 30.0 exit_pressure_under 0}}
author Decent
espresso_hold_time 30
preinfusion_time 20
espresso_pressure 8.6
espresso_decline_time 0
pressure_end 4.0
espresso_temperature 88.0
settings_profile_type settings_2b
flow_profile_preinfusion 4.2
flow_profile_preinfusion_time 6
flow_profile_hold 1.7
flow_profile_hold_time 0
flow_profile_decline 1
flow_profile_decline_time 23
flow_profile_minimum_pressure 6
preinfusion_flow_rate 4.0
profile_notes {John Buckman, the founder of Decent Espresso, finds that this flow profile produces the best espresso shots for milky drinks in the widest variety of circumstances. It is especially tolerant of not-yet-very-good barista technique.}
water_temperature 86.0
final_desired_shot_weight 32
preinfusion_guarantee 0
profile_title {Flow profile for milky drinks}
profile_language en
preinfusion_stop_pressure 5.0

