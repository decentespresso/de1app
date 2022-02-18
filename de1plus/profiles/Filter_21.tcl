advanced_shot {{exit_if 0 flow 4.0 volume 0 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 98.00 name preinfusion sensor coffee pump flow exit_flow_over 6 exit_pressure_over 0 max_flow_or_pressure 0 exit_pressure_under 0 seconds 4.00} {exit_if 0 flow 1.0 volume 0 max_flow_or_pressure_range 0.6 transition smooth exit_flow_under 0 temperature 95.00 name preinfusion sensor coffee pump flow exit_flow_over 6 exit_pressure_over 0 max_flow_or_pressure 0 seconds 8.00 exit_pressure_under 0} {exit_if 1 flow 1.0 volume 0 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 92.00 name preinfusion sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 0.30 max_flow_or_pressure 0 exit_pressure_under 0 seconds 10.00} {exit_if 0 flow 0.1 volume 0 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 88.00 name {0.1 mL/s bloom} sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 0.30 max_flow_or_pressure 0 seconds 90.00 exit_pressure_under 0} {exit_if 0 flow 3.0 volume 0 max_flow_or_pressure_range 0.6 transition smooth exit_flow_under 0 temperature 87.00 pressure 0 name ramp sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 0.30 max_flow_or_pressure 0.8 seconds 10.00 exit_pressure_under 0} {exit_if 0 flow 3.0 volume 0 max_flow_or_pressure_range 0.6 transition fast exit_flow_under 0 temperature 84.00 pressure 0 name {3 mL/s} sensor coffee pump flow exit_type pressure_over exit_flow_over 6 exit_pressure_over 0.30 max_flow_or_pressure 0.8 seconds 60.00 exit_pressure_under 0}}
author Decent
beverage_type pourover
espresso_decline_time 0
espresso_hold_time 25
espresso_pressure 8.6
espresso_temperature 98.0
espresso_temperature_0 90.0
espresso_temperature_1 88.0
espresso_temperature_2 88.0
espresso_temperature_3 88.0
espresso_temperature_steps_enabled 1
final_desired_shot_volume 36
final_desired_shot_volume_advanced 0
final_desired_shot_volume_advanced_count_start 0
final_desired_shot_weight 100
final_desired_shot_weight_advanced 100
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
preinfusion_flow_rate 4
preinfusion_stop_pressure 4
preinfusion_time 0
pressure_end 6.0
profile_hide 1
profile_language en
profile_notes {Make excellent filter-style coffee using a normal espresso basket, a paper filter, and your DE1.  No V60 or other equipment required.

A new technique developed by Scott Rao, for making filter coffee with an espresso machine and 24g basket.  The process: (1) insert two micron 55mm paper filter into the bottom of a clean portafilter basket.  (2) Rinser the filter and basket with hot water.  (3) Fill the basket with 20g to 22g of finely ground coffee, not quite espresso grind, but far finer than any filter grind.  (4) WDT the grounds.  (5) tamping is optional.  (6) Place a metal mesh filter on top.  (7) Lock in the portafilter and make the espresso to a 5:1 ratio. (8) Dilute with 225g-250g of water.

From Scott Rao: I put the Filter 2.0 profile on in the Internet prematurely, hoping others would try it out and offer suggestions. I received some interesting feedback, some of which helped, and some of which sent me down some dead ends. Now every extraction is stellar.   

My Filter 2.1 of Pradera Geisha yesterday scored 88.5, exceeding my cupping score by a point. Every cup recently has been juicy, clean, and free of astringency. I consider the profile complete, and better than 99% of pourovers out there. 2.0 is also fast, as total brew time is 2:00. That is especially helpful for cafes seeking a way to brew individual cups with maximum efficiency, which was the goal of this project. 

The keys to Filter 2.0 are:  

(1) Use a paper filter cut to size. The Whatman lab filters yielded cleaner cups, but often imparted off-flavors and weren’t food grade/ food safe, so I dropped those. I’m currently using Chemex filters cut to 55mm circles. I finally found a use for all of that wasteful extra filter paper. 

(2) Use an oversized basket relative to dose, to keep pressure as low as possible. (more pressure > more astringency from a given channel). For this profile, I used 16g in a 25g basket. 

(3) Use a fine enough grind to use a 3:1 ratio, such that the puck provides enough resistance to maintain a slurry during the bloom (this took months to figure out). 

(4) This profile is made for a 15-17g dose. With a larger dose, proportionally increase the water volume in the steps before the bloom. Likewise, if you use 16g in a smaller basket, such as 20g, decrease the amount of preinfusion water, as there will be less headspace to fill. 

(5) After brewing 48g of liquid, dilute to your preferred strength (I dilute to 260g total liquid). 

(6) My typical extractions are 24%-26%, 8%-8.5% TDS, 16g in, 48g out. Pressure never rises above 0.3 bar.  

(7) When dialing in, if pressure never rises at all, grind finer. If pressure exceeds 0.3 bar during the last few seconds, grind coarser.}
profile_title {Filter 2.1}
settings_profile_type settings_2c
tank_desired_water_temperature 0

