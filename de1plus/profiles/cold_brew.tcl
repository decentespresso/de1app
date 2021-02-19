advanced_shot {{exit_if 0 flow 6.00 volume 500 transition fast exit_flow_under 0 temperature 20.00 name preinfusion pressure 0 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 1.5 seconds 14.00 exit_pressure_under 0} {exit_if 0 flow 0.0 volume 500 transition fast exit_flow_under 0 temperature 20.00 name bloom* pressure 0.00 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 30.00} {exit_if 0 flow 2.50 volume 500 transition fast exit_flow_under 0 temperature 20.00 name pulse pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 60.00} {exit_if 0 flow 0.0 volume 500 transition fast exit_flow_under 0 temperature 20.00 name pause pressure 0.00 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 seconds 30.0 exit_pressure_under 0} {exit_if 0 flow 2.00 volume 500 transition fast exit_flow_under 0 temperature 20.00 name pulse pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 60.00 exit_pressure_under 0} {exit_if 0 flow 0.0 volume 500 transition fast exit_flow_under 0 temperature 20.00 name pause pressure 0 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 30.0} {exit_if 0 flow 2.00 volume 500 transition fast exit_flow_under 0 temperature 20.00 name pulse pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 52.00 exit_pressure_under 0} {exit_if 0 flow 0.10 volume 500 transition fast exit_flow_under 0 temperature 20.00 name pulse* pressure 6.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 2.00 exit_pressure_under 0}}
author Decent
espresso_decline_time 25
espresso_hold_time 10
espresso_pressure 8.6
espresso_temperature 20.00
espresso_temperature_0 20.00
espresso_temperature_1 20.00
espresso_temperature_2 20.00
espresso_temperature_3 20.00
espresso_temperature_steps_enabled 0
final_desired_shot_volume 32
final_desired_shot_volume_advanced 0
final_desired_shot_volume_advanced_count_start 0
final_desired_shot_weight 32
final_desired_shot_weight_advanced 0
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_minimum_pressure 4
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
preinfusion_flow_rate 4
preinfusion_guarantee 0
preinfusion_stop_pressure 1.5
preinfusion_time 20
pressure_end 6.0
profile_hide 1
profile_language en
profile_notes {Brewing with cold water substantially slows the flow rate of liquid through the coffee bed and often leads to choking. We set the flow rate very low for our cold brew recipe in order to provide steady flow, mitigate choking, and promote an even extraction. We recommend grinding a little coarser for cold brew than for hot-water brewing. Expect cold-brew extraction levels to be a couple of points lower than hot-water extractions.  We recommend giving the brewer a gentle spin after prewetting and after the last pulse of water has sprayed. }
profile_title {Pour over basket/Cold brew 22g in, 375ml out}
settings_profile_type settings_2c
tank_desired_water_temperature 0
water_temperature 80
beverage_type {pourover}

