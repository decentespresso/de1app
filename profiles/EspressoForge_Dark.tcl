advanced_shot {{exit_if 1 flow 6.0 volume 100 transition fast exit_flow_under 4.0 temperature 84.0 name preinfusion pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 3.0 seconds 10.0 exit_pressure_under 0} {exit_if 0 volume 100 transition fast exit_flow_under 0 temperature 81.0 name {rise and hold} pressure 7.5 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 seconds 8.0 exit_pressure_under 0} {exit_if 0 volume 100 transition smooth exit_flow_under 0 temperature 78.0 name decline pressure 3.0 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 seconds 30.0 exit_pressure_under 0} {exit_if 0 flow 0.0 volume 100 transition smooth exit_flow_under 0 temperature 84.0 name {reset temperature} pressure 3.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 1.0 exit_pressure_under 0}}
author Decent
espresso_hold_time 10
preinfusion_time 5
espresso_pressure 7.0
espresso_decline_time 20
pressure_end 4.3
espresso_temperature 84.0
settings_profile_type settings_2c2
flow_profile_preinfusion 4.2
flow_profile_preinfusion_time 6
flow_profile_hold 2.3
flow_profile_hold_time 2
flow_profile_decline 1
flow_profile_decline_time 23
flow_profile_minimum_pressure 6
preinfusion_flow_rate 6.0
profile_notes {A dark roast pressure profile that emulates the flow and temperature characteristics of the Espresso Forge manual machine. Good for medium to dark roasts where you want to pull out more fruit flavors, similar to the classic Italian Lever profile.}
water_temperature 80
final_desired_shot_weight 42
final_desired_shot_weight_advanced 42
preinfusion_guarantee 1
profile_title {Espresso Forge Dark}
profile_language en
preinfusion_stop_pressure 4

