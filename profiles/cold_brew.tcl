advanced_shot {{exit_if 0 flow 6.00 volume 100 transition fast exit_flow_under 0 temperature 20.00 name preinfusion pressure 0 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 1.5 seconds 14.00 exit_pressure_under 0} {exit_if 0 flow 0.0 volume 100 transition fast exit_flow_under 0 temperature 20.00 name bloom* pressure 0.00 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 30.00} {exit_if 0 flow 2.50 volume 100 transition fast exit_flow_under 0 temperature 20.00 name pulse pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 60.00} {exit_if 0 flow 0.0 volume 100 transition fast exit_flow_under 0 temperature 20.00 name pause pressure 0.00 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 seconds 30.0 exit_pressure_under 0} {exit_if 0 flow 2.00 volume 100 transition fast exit_flow_under 0 temperature 20.00 name pulse pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 60.00 exit_pressure_under 0} {exit_if 0 flow 0.0 volume 100 transition fast exit_flow_under 0 temperature 20.00 name pause pressure 0 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 30.0} {exit_if 0 flow 2.00 volume 100 transition fast exit_flow_under 0 temperature 20.00 name pulse pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 52.00 exit_pressure_under 0} {exit_if 0 flow 0.10 volume 100 transition fast exit_flow_under 0 temperature 20.00 name pulse* pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 2.00 exit_pressure_under 0}}
espresso_temperature_steps_enabled 0
author Decent
espresso_hold_time 10
preinfusion_time 20
espresso_pressure 8.6
espresso_decline_time 25
pressure_end 6.0
espresso_temperature 20.00
espresso_temperature_0 20.00
espresso_temperature_1 20.00
espresso_temperature_2 20.00
espresso_temperature_3 20.00
settings_profile_type settings_2c
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_minimum_pressure 4
preinfusion_flow_rate 4
profile_notes {Cold brew: this recipe works just like a hot pourover, but will take a little longer to drain and will produce slightly weaker coffee. We recommend using a 15:1 ratio to produce coffee of proper strength, which is important to combat dilution by ice.}
water_temperature 80
final_desired_shot_volume 32
final_desired_shot_weight 32
final_desired_shot_weight_advanced 0
tank_desired_water_temperature 0
final_desired_shot_volume_advanced 0
preinfusion_guarantee 0
profile_title {Pour over basket/Cold brew 22g in, 375ml out}
profile_language en
preinfusion_stop_pressure 1.5
profile_hide 0
final_desired_shot_volume_advanced_count_start 0

