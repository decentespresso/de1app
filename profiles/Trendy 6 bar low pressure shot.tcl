advanced_shot {{exit_if 0 flow 6.0 volume 70.0 transition fast exit_flow_under 0 temperature 99.0 name Prewet pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 4.0} {exit_if 0 flow 0 volume 100 transition fast exit_flow_under 0 temperature 97.0 name Pause pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 40.0} {exit_if 0 flow 6.0 volume 250.0 transition fast exit_flow_under 0 temperature 97.0 name {Main water #1} pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 14.0 exit_pressure_under 0} {exit_if 0 flow 0 volume 250.0 transition fast exit_flow_under 0 temperature 95.0 name Pause pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 20.0 exit_pressure_under 0} {exit_if 0 flow 5.0 volume 200.0 transition fast exit_flow_under 0 temperature 95.0 name {Main water #2} pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 25.0 exit_pressure_under 0} {exit_if 0 flow 0 volume 175.0 transition fast exit_flow_under 0 temperature 95.0 name Drain pressure 6.0 sensor water pump flow exit_flow_over 6 exit_pressure_over 11 seconds 20.0 exit_pressure_under 0}}
author Decent
espresso_hold_time 35
preinfusion_time 20
espresso_pressure 6.0
espresso_decline_time 0
pressure_end 6.0
espresso_temperature 92.0
settings_profile_type settings_2a
flow_profile_preinfusion 4.2
flow_profile_preinfusion_time 6
flow_profile_hold 2.3
flow_profile_hold_time 2
flow_profile_decline 1
flow_profile_decline_time 23
flow_profile_minimum_pressure 6
preinfusion_flow_rate 4
profile_notes {Some lightly roasted espresso beans smell great but resist being well extracted into a drink.  The solution can be to lower the pressure to 6 bar. Try this technique if you're having trouble with a particularly sophisticated lightly roasted bean.}
water_temperature 80
final_desired_shot_weight 36
preinfusion_guarantee 1
profile_title {Trendy 6 bar low pressure shot}
profile_language en
preinfusion_stop_pressure 4.0

