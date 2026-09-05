#############################################################################
# bengle.tcl — Bengle-specific logic (procs), extracted from the Insight skin
# (de1_skin_settings.tcl) so all Bengle behaviour lives in one place.
#
# This file holds LOGIC ONLY (proc definitions + their namespace state). The
# page/widget construction for these features stays in the skin, since it builds
# skin widgets at skin-load time. Sourced from de1_comms.tcl so these procs are
# defined before the skin builds the pages that reference them.
#
# Namespaces: ::cupwarmer (cup-warmer page logic), ::led (LED colour picker
# logic), ::bengle_fw (live firmware update flow).
#############################################################################


########################## cup warmer #######################################
	namespace eval ::cupwarmer {}
	set ::cupwarmer::_commit_after ""
	proc ::cupwarmer::_commit {} {
		set ::cupwarmer::_commit_after ""
		set_cupwarmer_temperature $::settings(cupwarmer_temp)
		set_cupwarmer_mode $::settings(cupwarmer_enable)
		# Pre-warm timing lives in the firmware (MatPreheatEnable /
		# MatPreheatLeadMin), so the toggle and the lead slider must reach the
		# machine, not only be saved locally.
		set_cupwarmer_preheat [ifexists ::settings(cupwarmer_prewarm_enable) 0] \
			[ifexists ::settings(cupwarmer_prewarm_minutes) 30]
		set_alarms_for_de1_wake_sleep
		after idle save_settings
	}
	proc ::cupwarmer::_request_commit {} {
		if {$::cupwarmer::_commit_after ne ""} {
			after cancel $::cupwarmer::_commit_after
		}
		set ::cupwarmer::_commit_after [after 250 ::cupwarmer::_commit]
	}

	proc ::cupwarmer::toggle_enable {} {
		set ::settings(cupwarmer_enable) [expr {!$::settings(cupwarmer_enable)}]
		::cupwarmer::_request_commit
		::cupwarmer::_update_enable_state
	}

	# Hide the "Target temperature" controls when the warmer is off, so only the
	# enable toggle + status show. Called on page show and when the toggle flips.
	proc ::cupwarmer::_update_enable_state {} {
		set on [ifexists ::settings(cupwarmer_enable) 0]
		catch {dui item show_or_hide $on cupwarmer cw_temp_grp}
		# The whole pre-warm group only applies when the warmer is on.
		catch {dui item show_or_hide $on cupwarmer cw_pw_all}
		# When shown, still collapse the "start heater" sub-section if pre-warm is off.
		if {$on} { ::cupwarmer::_update_prewarm_state }
	}

	proc ::cupwarmer::toggle_prewarm {} {
		set ::settings(cupwarmer_prewarm_enable) [expr {!$::settings(cupwarmer_prewarm_enable)}]
		::cupwarmer::_request_commit
		::cupwarmer::_update_prewarm_state
	}

	# Hide the "Start heater before wake" controls entirely when pre-warm is off,
	# so only the toggle shows. Called on page show and when the toggle flips.
	proc ::cupwarmer::_update_prewarm_state {} {
		set on [ifexists ::settings(cupwarmer_prewarm_enable) 0]
		catch {dui item show_or_hide $on cupwarmer cw_prewarm_grp}
	}

	# Live status poll — get_cupwarmer_status is otherwise only read once at
	# connect, so the "Currently heating at: N %" readout was stale. While the
	# page is open, re-read drive/fault every 2s; self-cancels on leaving.
	proc ::cupwarmer::_start_poll {} {
		if {[ifexists ::cupwarmer::_poll_after ""] ne ""} { return }
		::cupwarmer::_poll
	}
	proc ::cupwarmer::_poll {} {
		set ::cupwarmer::_poll_after ""
		if {![is_bengle_model]} { return }
		if {[ifexists ::de1(current_context) ""] ne "cupwarmer"} { return }
		get_cupwarmer_status
		set ::cupwarmer::_poll_after [after 2000 ::cupwarmer::_poll]
	}

	proc ::cupwarmer::status_text {} {
		set fault [ifexists ::de1(mat_temp_fault) 0]
		if {$fault == 1} { return [translate "NTC disconnected — warmer disabled"] }
		if {[ifexists ::settings(cupwarmer_enable) 0] != 1} {
			return [translate "Warmer is off"]
		}
		set pct [ifexists ::de1(mat_heater_drive) 0]
		return "[translate "Currently heating at:"] ${pct} %"
	}

	# Compact indicator shown on the target-temperature row: "Heating" while the
	# mat is drawing power, otherwise "Hot" (at target). Updated by the live poll.
	proc ::cupwarmer::heat_word {} {
		if {[ifexists ::de1(mat_temp_fault) 0] == 1} { return "⚠" }
		return [expr {[ifexists ::de1(mat_heater_drive) 0] > 0 ? [translate "Heating"] : [translate "Hot"]}]
	}

	proc ::cupwarmer::prewarm_preview {} {
		if {[ifexists ::settings(scheduler_enable) 0] != 1} {
			return [translate "Enable the wake schedule first"]
		}
		if {[ifexists ::settings(cupwarmer_prewarm_enable) 0] != 1} {
			return ""
		}
		set mins [ifexists ::settings(cupwarmer_prewarm_minutes) 0]
		set wake_at [next_alarm_time $::settings(scheduler_wake)]
		set prewarm_at [expr {$wake_at - 60 * $mins}]
		return "[translate "Heater turns on at"] [time_format $prewarm_at]"
	}



########################## LED colour picker ###############################
	# Build the HSV colour wheel into a Tk photo image. Renders at V=1;
	# brightness is applied separately via the slider. Runs once, lazily.
	proc ::led::_build_wheel_image {} {
		if {$::led::wheel_img ne ""} { return }
		# Rectangular hue(x) x saturation(y) gradient at V=1. Built small then
		# zoomed to the footprint so the ~24k hsv computations stay fast.
		set fw [rescale_x_skin $::led::rect_w]
		set fh [rescale_y_skin $::led::rect_h]
		set z 3
		set sw [expr {int($fw / $z)}]
		set sh [expr {int($fh / $z)}]
		if {$sw < 2} { set sw 2 }
		if {$sh < 2} { set sh 2 }
		set small [image create photo -width $sw -height $sh]
		for {set y 0} {$y < $sh} {incr y} {
			set sat [expr {1.0 - double($y) / ($sh - 1)}]   ;# top = full saturation
			set row [list]
			for {set x 0} {$x < $sw} {incr x} {
				set hue [expr {double($x) / ($sw - 1) * 360.0}]
				lappend row [::led::hsv_to_hex $hue $sat 1.0]
			}
			$small put [list $row] -to 0 $y
		}
		set img [image create photo -width [expr {$sw * $z}] -height [expr {$sh * $z}]]
		$img copy $small -zoom $z
		image delete $small
		set ::led::wheel_img $img
	}
	# Current hex being painted onto the target LEDs, based on wheel+brightness.
	proc ::led::_current_preview_hex {} {
		set v [expr {$::led::brightness / 100.0}]
		return [::led::hsv_to_hex $::led::wheel_hue $::led::wheel_sat $v]
	}
	# Setting name for a given state / strip, e.g. (awake, front) → led_front_awake_colour
	proc ::led::_setting_name {state strip} {
		return "led_${strip}_${state}_colour"
	}
	# Write `hex` into the settings vars for the currently-edited state and
	# the currently-selected target (front / rear / both).
	proc ::led::_store_edited_colour {hex} {
		set state $::led::editing_state
		set target $::settings(led_target_mode)
		if {$target eq "front" || $target eq "both"} {
			set ::settings([::led::_setting_name $state front]) $hex
		}
		if {$target eq "rear" || $target eq "both"} {
			set ::settings([::led::_setting_name $state rear]) $hex
		}
		set ::led::_dirty 1
	}
	proc ::led::_update_swatches {} {
		foreach state {awake sleep} {
			foreach strip {front rear} {
				set key "${state}_${strip}"
				set hex $::settings([::led::_setting_name $state $strip])
				if {[info exists ::led::swatch_item($key)]} {
					.can itemconfigure $::led::swatch_item($key) -fill $hex
				}
				# Show the stored #RGB value inside the swatch, in a colour that
				# reads on that background (white on dark, black on light).
				if {[info exists ::led::off_indicator($key)]} {
					.can itemconfigure $::led::off_indicator($key) -text "[string toupper $strip]\n$hex" -fill [::led::_contrast_color $hex]
				}
			}
		}
	}
	proc ::led::_update_puck {} {
		if {$::led::puck_item == 0} { return }
		set x [expr {$::led::rect_x0 + ($::led::wheel_hue / 360.0) * $::led::rect_w}]
		set y [expr {$::led::rect_y0 + (1.0 - $::led::wheel_sat) * $::led::rect_h}]
		set px [rescale_x_skin [expr {$x - 28}]]
		set py [rescale_y_skin [expr {$y - 28}]]
		set px2 [rescale_x_skin [expr {$x + 28}]]
		set py2 [rescale_y_skin [expr {$y + 28}]]
		.can coords $::led::puck_item $px $py $px2 $py2
	}
	# Load the currently-edited state's colour into the wheel puck + slider.
	# Uses the "target" mode to decide which LED to track — front by default,
	# or rear if target is rear, or the front colour if target is both.
	proc ::led::_sync_controls_from_settings {} {
		set state $::led::editing_state
		set strip front
		if {$::settings(led_target_mode) eq "rear"} { set strip rear }
		set hex $::settings([::led::_setting_name $state $strip])
		lassign [::led::hex_to_hsv $hex] h s v
		# When v is 0 (black) the hex contains no hue/saturation information,
		# so don't overwrite the puck position — let it keep wherever the user
		# last placed it. Only the brightness slider moves to 0.
		if {$v > 0.001} {
			set ::led::wheel_hue $h
			set ::led::wheel_sat $s
		}
		set ::led::_suppress_brightness_cmd 1
		set ::led::brightness [expr {int(round($v * 100))}]
		set ::led::_suppress_brightness_cmd 0
		::led::_update_puck
	}
	# Push the currently-edited colour to the physical LEDs.
	# While the picker is open we push whatever colour the user is editing,
	# regardless of machine state, so they can judge the sleep colour while
	# the machine is awake.
	proc ::led::_commit_current {} {
		set hex [::led::_current_preview_hex]
		::led::write_target $::settings(led_target_mode) $hex
	}
	# Debounced commit — used during slider/wheel drags.
	# Guarded on picker_active so stray events (e.g. a queued ButtonRelease
	# landing after the user navigates away) can't arm a stale timer.
	proc ::led::_schedule_commit {} {
		if {!$::led::picker_active} { return }
		if {$::led::_commit_after ne ""} {
			after cancel $::led::_commit_after
		}
		# Timer body re-checks picker_active in case `after cancel` raced
		# with dispatch and the body still fires after picker_exit.
		set ::led::_commit_after [after 120 {
			set ::led::_commit_after ""
			if {$::led::picker_active} { ::led::_commit_current }
		}]
		::led::_schedule_save
	}
	# Debounced settings save — protects edits if the app dies before Back.
	# Re-scheduled on every edit, so only fires after ~3s of inactivity.
	proc ::led::_schedule_save {} {
		if {!$::led::picker_active} { return }
		if {$::led::_save_after ne ""} {
			after cancel $::led::_save_after
		}
		set ::led::_save_after [after 3000 {set ::led::_save_after ""; save_settings; ::led::push_all_stored; set ::led::_dirty 0}]
	}
	# px, py: widget pixel coords (from %x %y). commit=1 on release.
	proc ::led::on_wheel_input {px py commit} {
		# Ignore stray events that land after the user has navigated away.
		if {!$::led::picker_active} { return }
		set x [dui platform unscale_x $px]
		set y [dui platform unscale_y $py]
		# Map into the rectangle: x -> hue (0-360), y -> saturation (top = 1).
		set fx [expr {($x - $::led::rect_x0) / double($::led::rect_w)}]
		set fy [expr {($y - $::led::rect_y0) / double($::led::rect_h)}]
		if {$fx < 0} { set fx 0 } elseif {$fx > 1} { set fx 1 }
		if {$fy < 0} { set fy 0 } elseif {$fy > 1} { set fy 1 }
		set ::led::wheel_hue [expr {$fx * 360.0}]
		set ::led::wheel_sat [expr {1.0 - $fy}]
		::led::_update_puck
		set hex [::led::_current_preview_hex]
		::led::_store_edited_colour $hex
		::led::_update_swatches
		if {$commit} {
			::led::_commit_current
		} else {
			::led::_schedule_commit
		}
	}
	proc ::led::on_brightness_change {val} {
		if {$::led::_suppress_brightness_cmd} { return }
		# Ignore trailing Scale-widget -command callbacks that fire after
		# the user has navigated away from the picker.
		if {!$::led::picker_active} { return }
		set hex [::led::_current_preview_hex]
		::led::_store_edited_colour $hex
		::led::_update_swatches
		::led::_schedule_commit
	}
	proc ::led::set_editing {state} {
		set ::led::editing_state $state
		::led::_sync_controls_from_settings
		::led::_update_toggle_visuals
		::led::_commit_current   ;# preview whatever state is now being edited
	}
	proc ::led::set_target {target} {
		set ::settings(led_target_mode) $target
		set ::led::_dirty 1   ;# led_target_mode is persisted; ensure save runs
		::led::_sync_controls_from_settings
		::led::_update_toggle_visuals
		::led::_commit_current   ;# newly-targeted LED picks up the preview
		::led::_schedule_save
	}
	# Tap a swatch to choose which stored colour the wheel edits. With that row's
	# "Both" box checked, tapping either swatch selects the pair.
	proc ::led::select_swatch {state strip} {
		set ::led::editing_state $state
		if {[set ::led::both_$state]} {
			set ::settings(led_target_mode) both
		} else {
			set ::settings(led_target_mode) $strip
		}
		set ::led::_dirty 1
		::led::_sync_controls_from_settings
		::led::_update_toggle_visuals
		::led::_commit_current
		::led::_schedule_save
	}
	# "Both" checkbox changed (the dtoggle has already flipped ::led::both_<state>).
	# If that row is the one being edited, re-derive the target + highlight.
	proc ::led::on_both_changed {state} {
		if {$::led::editing_state ne $state} { return }
		if {[set ::led::both_$state]} {
			set ::settings(led_target_mode) both
		} elseif {$::settings(led_target_mode) eq "both"} {
			set ::settings(led_target_mode) front
		}
		::led::_sync_controls_from_settings
		::led::_update_toggle_visuals
	}
	# Readable text colour for a swatch background (white on dark, black on light).
	proc ::led::_contrast_color {hex} {
		set h [string trimleft $hex "#"]
		if {[string length $h] != 6 || [scan $h "%2x%2x%2x" r g b] != 3} { return "#FFFFFF" }
		return [expr {(0.299*$r + 0.587*$g + 0.114*$b) < 128 ? "#FFFFFF" : "#000000"}]
	}
	proc ::led::apply_preset {hex} {
		lassign [::led::hex_to_hsv $hex] h s v
		set ::led::wheel_hue $h
		set ::led::wheel_sat $s
		set ::led::_suppress_brightness_cmd 1
		set ::led::brightness [expr {int(round($v * 100))}]
		set ::led::_suppress_brightness_cmd 0
		::led::_update_puck
		::led::_store_edited_colour $hex
		::led::_update_swatches
		::led::_commit_current
		::led::_schedule_save
	}
	# Position the blue selection highlight around the swatch(es) currently being
	# edited: a single swatch, or the front+rear pair when the row's Both is on.
	proc ::led::_update_toggle_visuals {} {
		if {$::led::active_pair_box eq ""} { return }
		set state $::led::editing_state
		set target $::settings(led_target_mode)
		set m 12
		if {$target eq "both" && [info exists ::led::_swatch_bounds(${state}_front)] \
				&& [info exists ::led::_swatch_bounds(${state}_rear)]} {
			set a $::led::_swatch_bounds(${state}_front)
			set b $::led::_swatch_bounds(${state}_rear)
			set x0 [lindex $a 0]; set y0 [lindex $a 1]
			set x1 [lindex $b 2]; set y1 [lindex $b 3]
		} elseif {[info exists ::led::_swatch_bounds(${state}_${target})]} {
			set s $::led::_swatch_bounds(${state}_${target})
			set x0 [lindex $s 0]; set y0 [lindex $s 1]
			set x1 [lindex $s 2]; set y1 [lindex $s 3]
		} else {
			return
		}
		.can coords $::led::active_pair_box \
			[rescale_x_skin [expr {$x0 - $m}]] [rescale_y_skin [expr {$y0 - $m}]] \
			[rescale_x_skin [expr {$x1 + $m}]] [rescale_y_skin [expr {$y1 + $m}]]
	}
	proc ::led::picker_enter {} {
		::led::_build_wheel_image
		if {$::led::wheel_img ne "" && $::led::wheel_canvas_item ne ""} {
			.can itemconfigure $::led::wheel_canvas_item -image $::led::wheel_img
			# Snap the grey frame to the image's actual pixel size — the zoom
			# rounds the field a few px off rect_w/rect_h, which otherwise leaves
			# the frame's right/bottom edges hanging past the colour field.
			if {[info exists ::led::_field_frame] && $::led::_field_frame ne ""} {
				set fx0 [rescale_x_skin $::led::rect_x0]
				set fy0 [rescale_y_skin $::led::rect_y0]
				catch {.can coords $::led::_field_frame $fx0 $fy0 \
					[expr {$fx0 + [image width $::led::wheel_img]}] \
					[expr {$fy0 + [image height $::led::wheel_img]}]}
			}
		}
		# Defensive reset — if a previous session was torn down abnormally
		# without running picker_exit, _dirty could leak as 1.
		set ::led::_dirty 0
		set ::led::picker_active 1
		set ::led::editing_state "awake"
		::led::_sync_controls_from_settings
		::led::_update_swatches
		::led::_update_toggle_visuals
	}
	# Idempotent — safe to call from any exit path, including tab switches
	# and re-entry. If the picker wasn't active, does nothing.
	proc ::led::picker_exit {} {
		if {!$::led::picker_active} { return }
		set ::led::picker_active 0
		if {$::led::_commit_after ne ""} {
			after cancel $::led::_commit_after
			set ::led::_commit_after ""
		}
		if {$::led::_save_after ne ""} {
			after cancel $::led::_save_after
			set ::led::_save_after ""
		}
		# Persist edits and push all 4 stored colours to firmware. The
		# firmware will immediately apply the correct pair for its current
		# state, replacing any live-preview colour the picker was showing.
		if {$::led::_dirty} {
			set ::led::_dirty 0
			after idle save_settings
		}
		::led::push_all_stored
	}
	# Quick-colour presets, below brightness — 12 in a 6x2 grid (same width).
	proc ::led::_build_preset_row {} {
		set i 0
		foreach phex $::led::presets {
			set x [expr {1310 + ($i % 6) * 195}]
			set y [expr {1235 + ($i / 6) * 80}]
			dui add canvas_item rect led_picker $x $y [expr {$x + 170}] [expr {$y + 65}] -fill $phex -outline "#DDDDDD" -width 2
			add_de1_button "led_picker" [list ::led::apply_preset $phex] $x $y [expr {$x + 170}] [expr {$y + 65}]
			incr i
		}
	}
	# Single entry-point for opening the picker: initialises state before
	# the page is shown. Called from the settings_3 "Lighting" button.
	proc ::led::open_picker {} {
		say [translate {Lighting}] $::settings(sound_button_in)
		::led::picker_enter
		page_to_show_when_off led_picker
	}


########################## firmware update #################################
namespace eval ::bengle_fw {
	variable _probed 0
	variable apply_result ""
	variable _saw_disconnect 0
	variable from_version ""
	variable _card1 ""
	variable _card2 ""
}
# Auto-fit a card rect to its text. Keeps the rect's top and sides fixed and
# sets the bottom so the gap below the last line equals the gap above the first
# line (symmetric vertical padding). Recomputed as the text changes, so the box
# grows/shrinks with longer or shorter translations rather than clipping. All of
# a card's text carries the shared tag <text_tag>; buttons are tagged separately
# and excluded.
proc ::bengle_fw::_fit_card {rect_id text_tag} {
	if {$rect_id eq ""} return
	set can [dui canvas]
	if {[catch {$can bbox $text_tag} bb] || $bb eq ""} return
	if {[catch {$can coords $rect_id} rc] || [llength $rc] < 4} return
	lassign $bb tx0 ty0 tx1 ty1
	lassign $rc rx0 ry0 rx1 ry1
	set toppad [expr {$ty0 - $ry0}]
	if {$toppad < 0} { set toppad 0 }
	$can coords $rect_id $rx0 $ry0 $rx1 [expr {$ty1 + $toppad}]
}
# "v<from> → v<to> (upgrade|downgrade|no version change)" for the running machine
# vs the firmware file. On page 1 (before an update) from_version is empty, so it
# uses the live installed version; during/after an update it uses the version
# captured at begin(), so the "from" doesn't change once the machine reflashes.
proc ::bengle_fw::version_change_label {} {
	set from $::bengle_fw::from_version
	if {$from eq ""} { set from [ifexists ::settings(firmware_version_number) ""] }
	set to [ifexists ::de1(Firmware_file_Version) ""]
	if {$to eq ""} { catch { fwfile }; set to [ifexists ::de1(Firmware_file_Version) ""] }
	if {$from eq "" || $to eq ""} { return "" }
	if {$to > $from} {
		set kind [translate "upgrade"]
	} elseif {$to < $from} {
		set kind [translate "downgrade"]
	} else {
		set kind [translate "no version change"]
	}
	return "v$from ➜ v$to ($kind)"
}
# Open the confirmation page. Reachable only via the Bengle firmware button.
proc ::bengle_fw::open {} {
	say [translate {Firmware}] $::settings(sound_button_in)
	page_to_show_when_off bengle_firmware_update_1
}
# Kick off the live update: sleep → fwUpgrade (0x16) → erase/upload/verify.
proc ::bengle_fw::begin {} {
	if {[ifexists ::de1(device_handle) 0] == 0 && $::has_bluetooth} {
		::comms::msg -NOTICE "bengle_fw: not connected, cannot start firmware update"
		return
	}
	if {[ifexists ::de1(currently_updating_firmware) 0] == 1 \
			|| [ifexists ::de1(currently_erasing_firmware) 0] == 1} {
		::comms::msg -INFO "bengle_fw: firmware update already in progress"
		page_show bengle_firmware_update_2
		return
	}

	::comms::msg -NOTICE "bengle_fw: starting live firmware update (no power cycle)"
	# Explicitly NOT setting ::de1(in_fw_update_mode): that flag drives the DE1
	# reboot/reconnect path. We stay connected and drive the states live.
	set ::de1(in_fw_update_mode) 0

	# Reset the post-apply version probe for this run, and capture the currently
	# installed version as the "from" for the from→to display.
	set ::bengle_fw::_probed 0
	set ::bengle_fw::_saw_disconnect 0
	set ::bengle_fw::apply_result ""
	set ::bengle_fw::from_version [ifexists ::settings(firmware_version_number) ""]

	page_show bengle_firmware_update_2

	# 1) sleep, 2) enter the fwUpgrade sub-state, 3) erase + upload + verify.
	de1_send_state "go to sleep" $::de1_state(Sleep)
	after 700  { de1_send_state "firmware upgrade" $::de1_state(FWUpgrade) }
	after 1500 { start_firmware_update }
}
# Completion monitor, driven by an off-screen variable on page 2. Reveals the
# "Done" button once the upload has finished and been verified.
proc ::bengle_fw::_tick {} {
	# Keep the inactivity screen saver at bay during the (minute-long) upload.
	catch { delay_screen_saver }
	# Keep the card fitted to the (changing) text -- the status/verdict lines grow
	# and shrink, so re-fit each refresh for symmetric top/bottom padding.
	catch { ::bengle_fw::_fit_card $::bengle_fw::_card2 bfw2_body }
	set b   [ifexists ::de1(firmware_bytes_uploaded) 0]
	set sz  [ifexists ::de1(firmware_update_size) 0]
	set upd [ifexists ::de1(currently_updating_firmware) 0]
	set era [ifexists ::de1(currently_erasing_firmware) 0]
	set done [expr {$b > 0 && $sz > 0 && $b >= $sz && $upd == 0 && $era == 0}]
	# Drive the Done button's canvas state directly by the compound page/tag
	# selector (what dui's own get() uses). This is more reliable than
	# dui item show_or_hide here, which was leaving the button visible mid-update.
	catch { [dui canvas] itemconfigure "p:bengle_firmware_update_2&&bfw_done" -state [expr {$done ? "normal" : "hidden"}] }

	# Edge-triggered on completion: the upload is flashed but the machine is still
	# running the OLD firmware -- it must be power-cycled to apply it. Tell the
	# user to do that, then poll until the machine reconnects reporting the new
	# version, which validates the update.
	if {$done && !$::bengle_fw::_probed} {
		set ::bengle_fw::_probed 1
		set ::bengle_fw::apply_result [translate "Firmware uploaded. Turn your machine OFF, wait a few seconds, then turn it back ON to finish the update."]
		after 3000 { ::bengle_fw::_monitor 0 }
	}
	return ""
}
# Ask the machine for its running firmware build number (BLE Version + MMR
# 0x800010, both land in ::settings(firmware_version_number)).
proc ::bengle_fw::_read_version {} {
	catch { read_de1_version }
	catch { get_firmware_version_number }
}
# Post-upload monitor. The image is flashed but not yet applied: the machine
# must be power-cycled. Poll until it reconnects reporting the new version, which
# validates the update. Settling states:
#   * connected + reports the new version  -> validated (power cycle worked)
#   * disconnected                         -> machine is off mid power-cycle
#   * connected + still the old version     -> waiting for the user to power-cycle
# Auto-reconnect is left enabled, so the app re-links on its own when it powers on.
proc ::bengle_fw::_monitor {{elapsed 0}} {
	catch { delay_screen_saver }
	set expected  [ifexists ::de1(Firmware_file_Version) ""]
	set connected [expr {[ifexists ::de1(device_handle) 0] != 0 || !$::has_bluetooth}]
	set timeout   600000 ;# 10 minutes, to allow a manual power cycle

	if {!$connected} {
		# Machine is off (mid power-cycle). Record that we saw it drop -- this is
		# how we confirm the power cycle actually happened, which is the only
		# reliable signal when the version number does not change (reflash of the
		# same version).
		set ::bengle_fw::_saw_disconnect 1
		if {$elapsed >= $timeout} {
			set ::bengle_fw::apply_result [translate "Waiting for the machine to power back on and reconnect…"]
			return
		}
		set ::bengle_fw::apply_result [translate "Turn your machine back ON to finish the update…"]
	} elseif {$::bengle_fw::_saw_disconnect} {
		# The machine dropped and is back: the power cycle happened. The running
		# version read LAGS the reconnect -- and the machine often sleeps right
		# after, so ::settings(firmware_version_number) can still hold the old
		# value for a while (it only refreshes once the machine is awake/read).
		# So re-read every tick and KEEP polling; never give up on the first tick
		# (that was reporting a stale old version). Only a confirmed new version
		# ends it as success; the overall timeout ends it with a neutral message,
		# not a scary "still reports old firmware".
		::bengle_fw::_read_version
		set running [ifexists ::settings(firmware_version_number) ""]
		if {$running ne "" && $expected ne "" && $running >= $expected} {
			set ::bengle_fw::apply_result "[translate {Update complete.}] [translate {Machine now reports firmware}] v$running."
			return
		}
		if {$elapsed >= $timeout} {
			set ::bengle_fw::apply_result [translate "Your machine restarted. Wake it to confirm the new firmware version."]
			return
		}
		set ::bengle_fw::apply_result [translate "Reconnected — verifying the updated firmware…"]
	} else {
		# Uploaded, still on the pre-power-cycle connection: wait for the user to
		# power-cycle. A flash always needs a power cycle, even reflashing the same
		# version, so we do NOT short-circuit on the version number here.
		::bengle_fw::_read_version
		if {$elapsed >= $timeout} {
			set ::bengle_fw::apply_result [translate "Still waiting. Please turn the machine off and on to finish the update."]
			return
		}
		set ::bengle_fw::apply_result [translate "Firmware uploaded. Turn your machine OFF, wait a few seconds, then turn it back ON to finish the update."]
	}
	after 3000 [list ::bengle_fw::_monitor [expr {$elapsed + 3000}]]
}
