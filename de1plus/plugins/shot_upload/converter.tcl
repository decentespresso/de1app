# ::plugins::shot_upload::convert — de1app legacy .shot (Tcl) -> decaid ShotRecord JSON
#
# Emits the JSON shape decaid itself serialises (lib/src/models/data/shot_record.dart
# -> ShotSnapshot/MachineSnapshot/WeightSnapshot/Workflow/WorkflowContext/ShotAnnotations),
# so the Decent server ingest and decaid's own importer both accept it.
#
# Field mapping mirrors decaid's own lib/src/import/parsers/tcl_shot_parser.dart.
# Developed standalone (no de1app deps) so it can be unit-tested with tclsh; the
# same procs load inside the shot_upload plugin.

package require json

namespace eval ::plugins::shot_upload {}

# --- JSON scalar encoders -------------------------------------------------

proc ::plugins::shot_upload::_jesc {s} {
    string map [list \\ \\\\ \" \\\" \n \\n \r \\r \t \\t \b \\b \f \\f] $s
}

# Quoted JSON string.
proc ::plugins::shot_upload::_jstr {s} {
    return "\"[_jesc $s]\""
}

# JSON number, or "null" if not a finite number.
proc ::plugins::shot_upload::_jnum {v} {
    set v [string trim $v]
    if {$v eq "" || ![string is double -strict $v]} { return "null" }
    # normalise "nan"/"inf" which pass string-is-double on some builds
    if {[string match -nocase *n* $v] || [string match -nocase *inf* $v]} { return "null" }
    return $v
}

# Number that must be finite; non-numbers coerce to 0 (used inside the
# equal-length time-series where a gap would desync the columns).
proc ::plugins::shot_upload::_jnum0 {v} {
    set n [_jnum $v]
    return [expr {$n eq "null" ? "0" : $n}]
}

# ISO-8601 UTC with milliseconds, e.g. 2026-03-03T14:10:17.123Z
proc ::plugins::shot_upload::_iso_ms {ms} {
    set sec [expr {$ms / 1000}]
    set frac [expr {$ms % 1000}]
    return [format "%s.%03dZ" [clock format $sec -format "%Y-%m-%dT%H:%M:%S" -gmt 1] $frac]
}

# Normalise a free-text roast date to ISO yyyy-mm-dd, or "" if it is not a date.
# de1app's roast_date is whatever the user typed, so most of the work is
# refusing the ones that are not dates rather than parsing the ones that are.
proc ::plugins::shot_upload::_iso_date {s} {
    set s [string trim $s]
    if {$s eq "" || $s eq "{}"} { return "" }
    if {[regexp {^(\d{4})-(\d{1,2})-(\d{1,2})} $s -> y m d]} {
        if {$m < 1 || $m > 12 || $d < 1 || $d > 31} { return "" }
        return [format "%04d-%02d-%02d" $y $m $d]
    }
    if {[catch {clock scan $s -gmt 1} t]} { return "" }
    return [clock format $t -format "%Y-%m-%d" -gmt 1]
}

# dict get with default
proc ::plugins::shot_upload::_dget {d key {dflt ""}} {
    if {[dict exists $d $key]} { return [dict get $d $key] }
    return $dflt
}

# Emit "key":value into acc only when the string value is non-empty (mirrors
# decaid's toJson which omits null fields). isnum -> number, else quoted string.
proc ::plugins::shot_upload::_add_if {accVar key val {isnum 0}} {
    upvar 1 $accVar acc
    set v [string trim $val]
    if {$v eq "" || $v eq "{}"} { return }
    if {$isnum} {
        set n [_jnum $v]
        if {$n eq "null"} { return }
        lappend acc "[_jstr $key]:$n"
    } else {
        lappend acc "[_jstr $key]:[_jstr $v]"
    }
}

# --- main -----------------------------------------------------------------

# Convert a .shot file into a decaid ShotRecord JSON string.
#   shotfile   : path to a de1app history *.shot file
#   machine    : dict of machine identity {serialNumber .. bleId .. firmwareVersion .. model ..}
proc ::plugins::shot_upload::convert {shotfile {machine {}}} {
    set fh [open $shotfile r]
    fconfigure $fh -encoding utf-8
    set data [read $fh]
    close $fh
    return [convert_data $data $machine]
}

proc ::plugins::shot_upload::convert_data {data {machine {}}} {
    array set arr $data
    set settings [expr {[info exists arr(settings)] ? $arr(settings) : {}}]

    set clock [expr {[info exists arr(clock)] ? $arr(clock) : 0}]
    if {![string is integer -strict $clock]} { set clock 0 }
    set base_ms [expr {wide($clock) * 1000}]

    # Normalise the embedded profile once. The legacy writer stores the profile
    # JSON so that its outer { } are consumed as Tcl list braces, so arr(profile)
    # comes back without them; re-wrap when needed. profile_text = valid JSON
    # object string (or ""); profile_dict = parsed dict (or {}).
    set profile_text ""
    set profile_dict {}
    if {[info exists arr(profile)]} {
        set pt [string trim $arr(profile)]
        if {$pt ne "" && $pt ne "\{\}"} {
            if {![string match "\{*" $pt]} { set pt "\{$pt\}" }
            if {![catch {json::json2dict $pt} pd]} {
                set profile_text $pt
                set profile_dict $pd
            }
        }
    }

    # ---- time-series columns (parallel, index-aligned) ----
    foreach {var key} {
        elapsed      espresso_elapsed
        pressure     espresso_pressure
        flow         espresso_flow
        flowWeight   espresso_flow_weight
        weight       espresso_weight
        tempBasket   espresso_temperature_basket
        tempMix      espresso_temperature_mix
        tempGoal     espresso_temperature_goal
        pressureGoal espresso_pressure_goal
        flowGoal     espresso_flow_goal
    } {
        set $var [expr {[info exists arr($key)] ? $arr($key) : {}}]
    }

    # sample count = min length across all present series (decaid does the same)
    set count [llength $elapsed]
    foreach l [list $pressure $flow $flowWeight $weight $tempBasket $tempMix $tempGoal $pressureGoal $flowGoal] {
        set n [llength $l]
        if {$n < $count} { set count $n }
    }

    set boundaries [_step_boundaries $profile_dict]

    set meas {}
    for {set i 0} {$i < $count} {incr i} {
        set e [lindex $elapsed $i]
        set ems $base_ms
        if {[string is double -strict $e]} { set ems [expr {$base_ms + round($e * 1000)}] }
        set ts [_iso_ms $ems]
        set frame [_frame_for_elapsed $e $boundaries]

        set m "{[_jstr timestamp]:[_jstr $ts]"
        append m ",[_jstr state]:{[_jstr state]:[_jstr espresso],[_jstr substate]:[_jstr pouring]}"
        append m ",[_jstr flow]:[_jnum0 [lindex $flow $i]]"
        append m ",[_jstr pressure]:[_jnum0 [lindex $pressure $i]]"
        append m ",[_jstr targetFlow]:[_jnum0 [lindex $flowGoal $i]]"
        append m ",[_jstr targetPressure]:[_jnum0 [lindex $pressureGoal $i]]"
        append m ",[_jstr mixTemperature]:[_jnum0 [lindex $tempMix $i]]"
        append m ",[_jstr groupTemperature]:[_jnum0 [lindex $tempBasket $i]]"
        append m ",[_jstr targetMixTemperature]:[_jnum0 [lindex $tempGoal $i]]"
        append m ",[_jstr targetGroupTemperature]:[_jnum0 [lindex $tempGoal $i]]"
        append m ",[_jstr profileFrame]:$frame"
        append m ",[_jstr steamTemperature]:0}"

        set s "{[_jstr timestamp]:[_jstr $ts]"
        append s ",[_jstr weight]:[_jnum0 [lindex $weight $i]]"
        append s ",[_jstr weightFlow]:[_jnum0 [lindex $flowWeight $i]]"
        append s ",[_jstr battery]:null"
        append s ",[_jstr timerValue]:null}"

        lappend meas "{[_jstr machine]:$m,[_jstr scale]:$s}"
    }

    # ---- workflow context (from settings) ----
    set doseIn      [_dget $settings grinder_dose_weight]
    set actualYield [_dget $settings drink_weight]
    set targetYield [_dget $settings target_drink_weight]
    if {$targetYield eq "" || $targetYield eq "{}"} {
        set targetYield [_dget $settings final_desired_shot_weight]
    }
    if {$targetYield eq "" || $targetYield eq "{}"} { set targetYield $actualYield }

    set ctx {}
    _add_if ctx targetDoseWeight $doseIn 1
    _add_if ctx targetYield      $targetYield 1
    _add_if ctx grinderModel     [_dget $settings grinder_model]
    _add_if ctx grinderSetting   [_dget $settings grinder_setting]
    _add_if ctx coffeeName       [_dget $settings bean_type]
    _add_if ctx coffeeRoaster    [_dget $settings bean_brand]
    _add_if ctx baristaName      [_dget $settings my_name]
    _add_if ctx drinkerName      [_dget $settings drinker_name]

    # Roast date and level have no home in decaid's WorkflowContext, but it has
    # an `extras` map for exactly this. de1app has been recording both all
    # along and simply never sent them; without the roast date you cannot ask
    # the one question every bag raises -- when does it peak, and how long does
    # it stay there. roastDate is ISO yyyy-mm-dd; de1app stores it free-text, so
    # emit it only when it actually parses as a date.
    set extras {}
    _add_if extras roastDate  [_iso_date [_dget $settings roast_date]]
    _add_if extras roastLevel [_dget $settings roast_level]
    if {[llength $extras]} {
        lappend ctx "[_jstr extras]:{[join $extras ,]}"
    }
    set ctx_json "{[join $ctx ,]}"

    # ---- annotations ----
    set ann {}
    _add_if ann actualDoseWeight $doseIn 1
    _add_if ann actualYield      $actualYield 1
    _add_if ann drinkTds         [_dget $settings drink_tds] 1
    _add_if ann drinkEy          [_dget $settings drink_ey] 1
    _add_if ann enjoyment        [_dget $settings espresso_enjoyment] 1
    _add_if ann espressoNotes    [_dget $settings espresso_notes]
    set ann_json "{[join $ann ,]}"

    # ---- profile: splice the .shot's own profile JSON (already decaid-shaped) ----
    set profile_title [_dget $settings profile_title]
    if {$profile_title eq "" && [dict exists $profile_dict title]} {
        set profile_title [dict get $profile_dict title]
    }
    if {$profile_text ne ""} {
        set profile_json $profile_text
    } else {
        set profile_json "{[_jstr version]:[_jstr 2],[_jstr title]:[_jstr $profile_title],[_jstr steps]:\[\]}"
    }

    # ---- workflow ----
    set wf "{[_jstr id]:[_jstr [_uuidish $clock]]"
    append wf ",[_jstr name]:[_jstr $profile_title]"
    append wf ",[_jstr description]:null"
    append wf ",[_jstr profile]:$profile_json"
    append wf ",[_jstr context]:$ctx_json"
    append wf ",[_jstr steamSettings]:{}"
    append wf ",[_jstr hotWaterData]:{}"
    append wf ",[_jstr rinseData]:{}}"

    # ---- machine identity (our extension; decaid to promote to first-class) ----
    set mach {}
    _add_if mach serialNumber    [_dget $machine serialNumber [_dget $settings sn]]
    _add_if mach bleId           [_dget $machine bleId]
    _add_if mach firmwareVersion [_dget $machine firmwareVersion]
    _add_if mach model           [_dget $machine model]
    set mach_json "{[join $mach ,]}"

    # ---- top-level ShotRecord ----
    set out "{[_jstr id]:[_jstr "de1app-$clock"]"
    append out ",[_jstr timestamp]:[_jstr [_iso_ms $base_ms]]"
    append out ",[_jstr measurements]:\[[join $meas ,]\]"
    append out ",[_jstr workflow]:$wf"
    append out ",[_jstr annotations]:$ann_json"
    append out ",[_jstr machine]:$mach_json"
    append out ",[_jstr app]:{[_jstr name]:[_jstr de1app],[_jstr sourceFormat]:[_jstr de1app-tcl]}"
    append out ",[_jstr schemaVersion]:1}"
    return $out
}

# Cumulative step end-times from the parsed profile dict's steps.
proc ::plugins::shot_upload::_step_boundaries {profile_dict} {
    set boundaries {}
    if {![dict exists $profile_dict steps]} { return $boundaries }
    set cum 0.0
    foreach step [dict get $profile_dict steps] {
        set secs [expr {[dict exists $step seconds] ? [dict get $step seconds] : 0}]
        if {![string is double -strict $secs]} { set secs 0 }
        set cum [expr {$cum + $secs}]
        lappend boundaries $cum
    }
    return $boundaries
}

proc ::plugins::shot_upload::_frame_for_elapsed {e boundaries} {
    if {![string is double -strict $e]} { return 0 }
    set i 0
    foreach b $boundaries {
        if {$e < $b} { return $i }
        incr i
    }
    set n [llength $boundaries]
    return [expr {$n == 0 ? 0 : $n - 1}]
}

# Deterministic pseudo-uuid from the shot clock (avoids needing a uuid pkg;
# the real per-shot identity is id/clock anyway).
proc ::plugins::shot_upload::_uuidish {clock} {
    return "de1app-wf-$clock"
}
