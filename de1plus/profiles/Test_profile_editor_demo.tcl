advanced_shot {{exit_if 1 flow 8 volume 60.00 max_flow_or_pressure_range 0.2 transition fast exit_flow_under 0 temperature 84.0 weight 0.00 name Filling pressure 6.0 pump pressure sensor coffee exit_type pressure_over exit_flow_over 6 exit_pressure_over 3.0 max_flow_or_pressure 0 exit_pressure_under 0 seconds 25.00} {exit_if 0 flow 8 volume 100.00 max_flow_or_pressure_range 0.2 transition fast exit_flow_under 0 temperature 94.0 weight 0.0 name Infusing pressure 6.0 pump pressure sensor coffee exit_type pressure_over exit_flow_over 6 exit_pressure_over 3.0 max_flow_or_pressure 0 exit_pressure_under 0 seconds 1.0} {exit_if 0 flow 1.8 volume 100 max_flow_or_pressure_range 0.2 transition fast exit_flow_under 0 temperature 94.0 weight 0.00 name Pouring pressure 4.8 pump flow sensor coffee exit_type flow_over exit_flow_over 2.80 exit_pressure_over 11 max_flow_or_pressure 10.0 exit_pressure_under 0 seconds 127}}
author Damian
beverage_type calibrate
profile_editor demo
profile_notes {THIS IS NOT AN EDITABLE PROFILE - Although it will run a copy of D-FLow Q.
        It is a dummy profile to test the profile_editor framework, this profile has a variable 'profile_editor demo'.    By Damian Nov 2025}
profile_title {Test/profile_editor_demo}
read_only 1
settings_profile_type settings_2c
tank_desired_water_temperature 0