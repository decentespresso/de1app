advanced_shot {{exit_if 0 flow 7.5 volume 0 max_flow_or_pressure_range 0.6 transition fast popup {} exit_flow_under 0 temperature 82.0 weight 0 name {preinfusion start} pressure 1 sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 3.8 max_flow_or_pressure 0 exit_pressure_under 0 seconds 2} {exit_if 1 flow 7.5 volume 0 max_flow_or_pressure_range 0.6 transition fast popup {} exit_flow_under 0 temperature 82.0 weight 0 name preinfusion pressure 1 pump flow sensor coffee exit_type pressure_over exit_flow_over 6 exit_pressure_over 3.8 max_flow_or_pressure 0 exit_pressure_under 0 seconds 6} {volume 0 exit_if 0 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 80.0 weight 0 name {rise and hold} pressure 7.8 sensor coffee pump pressure exit_flow_over 0 exit_pressure_over 0 max_flow_or_pressure 0 exit_pressure_under 0 seconds 4.00} {volume 0 exit_if 0 max_flow_or_pressure_range 0.6 transition smooth exit_flow_under 0 temperature 72.0 weight 0 name decline pressure 5.0 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 0 max_flow_or_pressure 0 exit_pressure_under 0 seconds 50.00}}
author Decent
beverage_type espresso
espresso_decline_time 47
espresso_hold_time 1
espresso_pressure 7.8
espresso_temperature 82.0
espresso_temperature_0 82.0
espresso_temperature_1 82.0
espresso_temperature_2 80.0
espresso_temperature_3 72.0
espresso_temperature_steps_enabled 1
final_desired_shot_volume 30.0
final_desired_shot_volume_advanced 0
final_desired_shot_volume_advanced_count_start 1
final_desired_shot_weight 36
final_desired_shot_weight_advanced 36
flow_profile_decline 1.2
flow_profile_decline_time 17
flow_profile_hold 2
flow_profile_hold_time 8
flow_profile_minimum_pressure 4
flow_profile_preinfusion 4
flow_profile_preinfusion_time 5
maximum_flow 0
maximum_flow_range_advanced 1.0
maximum_flow_range_default 1.0
maximum_pressure 0
maximum_pressure_range_advanced 0.9
maximum_pressure_range_default 0.9
preinfusion_flow_rate 7.5
preinfusion_stop_pressure 3.8
preinfusion_time 8
pressure_end 5.0
profile_hide 0
profile_language en
profile_notes {For medium to dark roasted beans. Produced a complex espresso meant for sipping, not for mixing with milk. The low starting temperature of 82C--which declines to 72C--is the magic.  This creates a silky, textured shot with good aroma, pleasant acidity, great complexity, and no off flavors. There are two styles: a ristretto or a double shot.  With a ristretto, put the recommended dose weight (ie, 14g, 15g, 18g, 20g) into the basket, and pull it as a 1:1 ratio shot.  For a double shot, updose by 10% to 20% and extract to a 2:1 ratio (and grind a bit coarser).  With both approaches, immediately after preinfusion aim for a flow rate in the range of 0.5-1.2ml/sec. The darker the roast, the slower the recommended flow rate. The ristretto has more flavor and complexity while the overdosed double shot is very smooth, easy to drink, and classic.}
profile_title {80's Espresso}
read_only 1
settings_profile_type settings_2c
tank_desired_water_temperature 0

