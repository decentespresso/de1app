advanced_shot {{exit_if 1 flow 4 volume 100 transition fast exit_flow_under 0 temperature 97.5 name preinfusion pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 4 seconds 23.00 exit_pressure_under 0} {exit_if 0 flow 0 volume 100 transition fast exit_flow_under 0 temperature 90.0 name pause pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 30.0} {exit_if 0 flow 2.2 volume 100 transition smooth exit_flow_under 0 temperature 92.0 name ramp pressure 4.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 5.0} {exit_if 0 flow 2.2 volume 100 transition fast exit_flow_under 0 temperature 92.0 name {flat flow} pressure 4.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 20.0 exit_pressure_under 0} {exit_if 0 flow 0.0 volume 100 transition fast exit_flow_under 0 temperature 98.0 name {reset temperature} pressure 4.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 1.0 exit_pressure_under 0}}
author Decent
espresso_decline_time 30
espresso_hold_time 15
espresso_pressure 6.0
espresso_temperature 97.5
final_desired_shot_volume 42
final_desired_shot_volume_advanced 0
final_desired_shot_weight 42
final_desired_shot_weight_advanced 60
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_minimum_pressure 4
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
preinfusion_flow_rate 4
preinfusion_guarantee 0
preinfusion_stop_pressure 4.0
preinfusion_time 20
pressure_end 4.0
profile_hide 0
profile_language en
profile_notes {This technique causes a furor when Rao first published it.  His extraction of 24% is 2% higher than what is usually attainable with only the very best grinders, yet Rao did it with an inexpensive home grinder.  This technique is especially appropriate for lightly roasted, complex and expensive coffee beans.}
profile_title {Blooming Espresso}
settings_profile_type settings_2c
tank_desired_water_temperature 0
water_temperature 80

