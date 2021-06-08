# DE1 App Core: Shot Cycle Overview

# Objective

This document is intended to provide a roadmap to the general operation of the DE1 tablet application ("de1app") as to what happens "under" the GUI. Though at this time there is not a clear and complete API between the two, this overview can help skin and extension developers select appropriate integration points.

Here, the typical sequence of events that occur from starting a shot through its completion is outlined.

This is a work in progress. While believed to represent the behavior of the system at the time it was written or revised, the code in hand is the best reference. Like the code itself, this documentation is subject to revision.

Suggestions, improvements, and contributions are welcome.

# Revision History

* 2021-04-14 – Wording change on `after_shot_complete` default message
* 2021-03-22 – Reflect code changes that removed previous scheduled tare
* 2021-03-14 – Autotare threshold updated. Minor corrections and clarfications.
* 2021-03-10 – Initial release

# Related Reading

# The Life Of A Shot

Desribing what happens during a typical shot can put things into perspective before diving into implementation details. Most of what is described below is implemented with a mix of code from previous versions (which may have moved in location and/or been modestly refactored) and new code introduced in early 2021. Code that is not implemented in the core, or the response of the GUI to events or calls are indicated by use of *italics.*

> NB: This represents the process for frame-derived shot profiles. How FROTH-driven profiles will be managed has not yet been determined (2021-03).

## Go!

The shot is started either with a tap of the GHC, or, with machines without a GHC, sending a request to enter Espresso mode from the tablet.

## Initialization

The DE1 update packets indicate a transition from
Idle mode to Espresso mode. The change is detected in a BLE message about changes in DE1 state and the internal state is updated correspondingly.

Several `::de1::state` functions change return values, such as:

```
::de1::state::is_flow_state -> True
::de1::state::flow_phase -> "before"
::de1::state::is_flow_before_state -> True
```

Several events are fired:

```
::de1::event::apply::on_major_state_change_callbacks $event_dict
::de1::event::apply::on_all_state_change_callbacks $event_dict
::de1::event::apply::on_flow_change_callbacks $event_dict
```

These events trigger several other actions, as follows:

### Legacy Callbacks

Any callbacks registered with the legacy `::register_state_change_handler` are called if they have a key of Idle -> Espresso

> Although callbacks may be registered with the above method, it has been deprecated. Directly rewriting calling code against the new event system is strongly suggested. The logs contain the automated rewrite to calls to this method.

### Scale Setup

The scale sets the target for "final drink weight" to `::de1(final_espresso_weight)`

> Not part of a shot flow, but worth mentioning here is that if `$::settings(high_vibration_scale_filtering)` exists and is True at app start up, a median estimate is used throughout for weight and mass-flow. This may help reduce the impact of impacts and vibration at the expense of slightly increased delay.

#### Start Recording

The scale starts resets its shot record, starts recording data and making weight and mass-flow estimates available with `::device::scale::event::apply::on_update_available_callback $event_dict`

*Consumers can prefer this ~10 Hz sample-rate data to the data previously captured only when the DE1 reports on its roughly 4 or 5 Hz rate.*

If a scale seems like it should be connected, but it is not, `::gui::notify::scale_event not_connected` is called to allow the GUI to alert the user.

*The default implementation of this is to raise a toast containing and speak "WARNING: Scale not connected".*

The scale code begins looking for the reference time of `espresso_clock` (managed by preexisting code) to be able to align with other time series, as well as to save the recorded data in a more readable format (normalized to "espresso start" to the millisecond).

#### Pre-Shot Tare Management

As Espresso mode is in `$::device::scale::autotare_states` (Espresso and HotWater, by default), the app starts checking for "a cup being added" prior to the start of delivery of the shot. If it is more than `$::device::scale::tare_threshold` off of zero (default, 0.04, so 0.1 g will trigger, but still resist vibratation and drift on an 0.01 g scale), it requests a tare by calling `::device::scale::tare`

Tare requests are now rate limited to no more often than `$::device::scale::_tare_holdoff` (200 ms default). A tare is "seen" if, after one is requested by the app, the reported weight is within `$::device::scale::tare_threshold` of zero, within `$::device::scale::_tare_awaiting_zero_ms` (1000 ms default) of the request.

Any time tare is seen, the scale code resets its internal calculations, to prevent the tare event for being misinterpreted as an actual change in weight. At this time, there is not detection of tare performed on the scale directly. (The Atomax Skale II "tare" button action is handled by the app, not the scale itself.)

<a name="saw_setup"></a>
#### SAW Setup

The SAW target is set to the value given by `$::settings(final_desired_shot_weight)` or `$::settings(final_desired_shot_weight_advanced)`, depending on the profile type.

SAW parameters for "stopping early" are determined from the current estimates of overall system lag and the value of `$::settings(stop_weight_before_seconds)`.

SAW is set to ignore the first 5 seconds of flow and use the `espresso_timer` to measure elapsed time (consistent with previous code).

If the SAW target is greater than zero, a check is made to see if there is a scale expected, and, if so, if it has been reporting weight updates recently. If not, `::gui::notify::scale_event no_updates` is called.

*The default implementation of this is to raise a toast containing and speak "WARNING: Scale not updating".*

The flag for indicating that SAW or SAV has already been trigggered, `::de1(app_autostop_triggered)` is set to False.

>The weight and mass-flow estimates continue to respect `$::settings(scale_stop_at_half_shot) == 1`, doubling both when set. The presumed use case is two cups under a dual-spout PF, but only one on the scale.

### SAV Setup

The SAV target is set to the value given by `$::settings(final_desired_shot_volume)` or `$::settings(final_desired_shot_volume_advanced)`, depending on the profile type.

### Legacy Skin-Page Update

Atempting to move the existing code

```
if {[info exists msg(substate)] == 1} {

	catch {
		skins_page_change_due_to_de1_state_change $this_state
	}
}
```

to an event caused the skin to "freeze", so it has been retained in that form.

### Try To Connect To Scale

Not yet on an event and from previous code, if the scale seems like it should be present, but is not connected, a connection attempt is initiated.


## Wait For Flow To Start

As the DE1 progresses through its pre-flow checks and stabilization, the substates typically progress through "heating" (HeatWaterTank), "final heating" (HeatWaterHeater), and "stabilising" (StabilizeMixTemp).

The DE1 substate-change updates continue to be available from

```
::de1::event::apply::on_all_state_change_callbacks $event_dict
```

DE1 ShotSample updates continue to be available from

```
::de1::event::apply::on_shotvalue_available_callbacks $event_dict
```

Scale updates continue to be available from

```
::device::scale::event::apply::on_update_available_callbacks $event_dict
```

*During this time, present GUI implementations often reflect the substate to the user and update DE1 parameters, but typically don't display graphs.*

## Flow Starts

As the substate changes to "preinfusion" (PreInfuse), it is reflected in

```
::de1::state::is_flow_state -> True
::de1::state::flow_phase -> "during"
::de1::state::is_flow_before_state -> False
::de1::state::is_flow_during_state -> True
```

The changes are made visible to consumers through

```
::de1::event::apply::on_all_state_change_callbacks $event_dict
::de1::event::apply::on_flow_change_callbacks $event_dict
```

*Often GUI implementations will start collecting data for graphical display and rendering it.*

Updates from the DE1 and scale continue.

### Start Espresso Timers

`::start_espresso_timers` is called, as is `::start_timer_preinfusion`

> Some of these timers now support an optional argument, `time_reference`, that allows calculation of a different moment than "now" (default). Either seconds (float) or milliseconds can be passed. At this time, they include `::espresso_millitimer` and `::steam_pour_millitimer`.

### Dispensed Beverage Estimates

Now during preinfusion, the estimate of incremental dispensed water derived from the flow rate in the ShotSample, the number of half-cycles of mains since the last update, and the mains frequency, is added to `$::de1(volume)` and `$::de1(preinfusion_volume)`

The scale begins to update the drink weight to `$::de1(final_espresso_weight)` and `$::settings(running_weight)` During flow, the default implementation is track the weight estimate directly.

### Activate SAV

Checking for SAV begins on the transition to "preinfusion" (PreInfuse), with `$::de1(pour_volume)` being checked against the target set during initialization. If it exceeds the limit, a request for Idle is triggered if one has not already been requested, as indicated by `$::de1(app_autostop_triggered)`

If SAV is triggered, the GUI is notified by a call to

```
::gui::notify::de1_event sav_stop
```

*The default implementation is to raise a toast "Stopping for volume"*


### Activate SAW

Checking for SAW has a hold off as noted above in [SAW Setup](#saw_setup). Once past the hold off, if the current weight estimate is greater than

* The target weight ...
* ... less the offset in grams (default, 0) ...
* ... less the current flow estimate multiplied by the time factor precalculated in [SAW Setup](#saw_setup)

a request for Idle is triggered if one has not already been requested, as indicated by `$::de1(app_autostop_triggered)`

If SAV is triggered, the GUI is notified by a call to

```
::gui::notify::scale_event saw_stop
```

*The default implementation is to raise a toast "Stopping for weight"*


SAV and SAW now interact as previously believed; the first to trigger terminates the shot.

*NB: Logic for inclusion of the possibility of a DE1-triggered SAV into the mix does not yet exist.*

## Flow Progresses To Pouring

When the DE1 sends a message that the substate is now "pouring" (Pour), the same general process continues.
The changes are made visible to consumers through

```
::de1::event::apply::on_all_state_change_callbacks $event_dict
::de1::event::apply::on_flow_change_callbacks $event_dict
```

The state utilities remain the same at this change:

```
::de1::state::is_flow_state -> True
::de1::state::flow_phase -> "during"
::de1::state::is_flow_before_state -> False
::de1::state::is_flow_during_state -> True
```

### Manage Espresso Timers

`::stop_timer_espresso_preinfusion` and `::start_timer_espresso_pour` are called.

Shot frame numbers (profile steps) continue to be available in the ShotSample data. There is *not* an event generated for changes in shot frame number.

*Tracking previous shot frame numbers for rendering on the GUI has been moved to GUI code.*

The incremental volume updates continue to `$::de1(volume)` and now to `$::de1(pour_volume)`

## That's Enough

The pouring phase of a shot can terminate in several ways. The profile can "time out", the GHC can instruct the DE1 to stop, the tablet can send a stop request (manual, SAV, SAW), the tablet can cause the profile to "step" off its last frame, and  *when implemented, firmware SAV.*

In all presently implemented cases, it is not what the DE1 was told to do, but what it reports that it is doing that causes transitions in the de1app's belief of the DE1's state and triggers events.

The DE1 and scale update-ready events continue to fire (as always).

### Events Fired

Typically the first indication that flow has stopped is that the substate changes to "ending" (Flush). This change resuls in firing:

```
::de1::event::apply::on_all_state_change_callbacks $event_dict
::de1::event::apply::on_flow_change_callbacks $event_dict
```

It also changes the state utilities:

```
::de1::state::is_flow_state -> True
::de1::state::flow_phase -> "after"
::de1::state::is_flow_before_state -> False
::de1::state::is_flow_during_state -> False
::de1::state::is_flow_after_state -> True
```

### Stop Espresso Timers

`::stop_timer_espresso_pour` and `::stop_espresso_timers` are called.

### After Flow Complete Countdown Begins

At this point, a timer is set for the `::de1::event::apply::after_flow_complete_callbacks` based on `$::settings(after_flow_complete_delay)`

The purpose of this callback is primarily to delay events related to "shot done" (such as determination final drink weight or saving the completed shot record) long enough for everything to settle down. Although the ending phase *may* be long enough for this, it can be very short. This event will be fired a minimum of time later, but not before exiting the Espresso state.

> NB: The `event_dict` for the pending event is captured at this time, not when the event is fired.

### Scale Switches To Final-Weight Determination

With the flow to the group head stopped, there is a period of time for the pressure to drop and the last drops to reach the cup. To improve accuracy, the default behaviour is to use a median estimate. This should help reduce the impact of the force of the shot landing in the glass, vibration, as well as the possibility that the user touches the cup on the scale.

## DE1 Reaches Idle State

After some period of time, determined by the logic within the DE1 itself and the conditions it observes, the DE1 enters Idle state. It communicates this to the de1app with a state-update notification.

Several events are fired:

```
::de1::event::apply::on_major_state_change_callbacks $event_dict
::de1::event::apply::on_all_state_change_callbacks $event_dict
::de1::event::apply::on_flow_change_callbacks $event_dict
```

Additionally, the previous implementation logic updates the GUI with

```
skins_page_change_due_to_de1_state_change $this_state
```

The state utilities change to their "Idle" values

```
::de1::state::is_flow_state -> False
::de1::state::flow_phase -> ""
::de1::state::is_flow_before_state -> False
::de1::state::is_flow_during_state -> False
::de1::state::is_flow_after_state -> False
```

## After Flow Complete Event

Once the timer ends and into Idle

```
::de1::event::apply::after_flow_complete_callbacks $event_dict
```

is fired.

>NB: The `event_dict` here is at the time that flow completed, not when the event is fired.

*This is an appropriate time for the GUI or other consumers to trigger "shot done" events, such as saving shot data.*

### Stop Recording Scale Data

With the shot complete, the scale stops recording data.

The GUI is notified that the shot is complete directly so that it can message the user by calling

```
::gui::notify::scale_event record_complete
```

*The default implementation is to raise a toast and speak "Shot complete"*

For reference, detection of the scale data being recorded can be done with `::device::scale::history::is_recording`