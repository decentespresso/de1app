package provide de1_binary 1.0


# from http://wiki.tcl.tk/12148

namespace eval fields {
   variable endianness ""
   variable cache
}

proc fields::2form {spec array {endian ""}} {
   variable cache

   variable endianness
   if {$endian == ""} {
	   set endian $endianness
   }

   if {[info exists cache($endian,$array,$spec)]} {
	   return $cache($endian,$array,$spec)
   }

   set form ""
   set vars {}
   foreach {name qual} $spec {
	   foreach {type count fendian signed extra} $qual break
	   set t [string index $type 0]
	   set s [string index $signed 0]
	   
	   if {$fendian == ""} {
		   set fendian [string tolower [string index $endian 0]]
	   } else {
		   set fendian [string tolower [string index $fendian 0]]
	   }
	   
	   # special forms skip n, back n, jump n
	   if {$name == "skip" && [string is integer $type]} {
		   set count $type
		   set type "x"
	   } elseif {$name == "back" && [string is integer $type]} {
		   set count $type
		   set type "X"
	   } elseif {$name == "jump" && [string is integer $type]} {
		   set count $type
		   set type "@"
	   }
	   
	   if {$fendian == "h" || $fendian == "b"} {
		   set ty [string toupper $t]
	   } elseif {$fendian == "l"} {
		   set ty [string tolower $t]
	   }
	   
	   switch [string tolower $t] {
		   a {
			   # ascii - char string of $count
			   # Ascii - pad with " "
		   }
		   
		   b {
			   # bits - low2high
			   # Bits - high2low
		   }
		   
		   c {
			   # char - 8 bit integer values
			   set ty [string tolower $t]
		   }
		   
		   h {
			   # hex low2high
			   # Hex high2low
		   }
		   
		   i {
			   # integer - 32bits low2high
			   # Integer - 32bits high2low
		   }
		   
		   s {
			   # short - 16bits low2high
			   # Short - 16bits high2low
			   set ty $t
		   }
		   
		   w {
			   # wide-integer - 64bits low2high
			   # Wide-integer - 64bits high2low
		   }
		   
		   f {
			   # float
			   set ty $t        ;# don't play with endianness
		   }

		   d {
			   # double
			   set ty $t        ;# don't play with endianness
		   }
		   
		   @ {
			   # skip to absolute location
			   set name ""
		   }
		   
		   x {
			   # x - move relative forward
			   # X - move relative back
			   set ty $t        ;# don't play with endianness
			   set name ""
		   }
	   }

	   if {$name != ""} {
		   append outvars "$array\($name\) "
		   append invars "\$$array\($name\) "
	   }
	   
	   catch {
	   	#msg "type: 'name=$name qual =$qual == $ty$s$count'"
	   }
	   append form $ty$s$count
   }

   set cache($endian,$array,$spec) [list $form $outvars $invars]
   return $cache($endian,$array,$spec)
}

# pack the fields contained in array into a binary string according to spec
proc ::fields::pack {spec array {endian ""}} {
   upvar $array Record
   foreach {form out in} [::fields::2form $spec Record $endian] break
   #puts stderr "pack: binary format $form $in"
   return [eval binary format [list $form] {*}$in]
}

# pack the fields from $packed contained into array according to spec
proc ::fields::unpack {packed spec array {endian ""}} {
   upvar $array Record
   foreach {form out in} [::fields::2form $spec Record $endian] break
   #puts stderr "unpack: binary scan $form $out"
   return [binary scan $packed [list $form] {*}$out]
}

# binary scan the fields from $packed according to spec
proc ::fields::scan {spec packed {endian ""}} {
   ::fields::unpack $packed $spec Record $endian
   foreach {form out in} [::fields::2form $spec Record $endian] break
   set result {}
   foreach var $out {
	   lappend result [set $var]
   }
   return $result
}

# binary format the args according to spec
proc ::fields::format {spec endian args} {
   foreach {form out in} [::fields::2form $spec Record $endian] break
   set result {}
   foreach var $out arg $args {
	   set $var $arg
   }
   return [::fields::pack $form Record $endian]
}

proc return_de1_packed_steam_hotwater_settings {} {

	set arr(SteamSettings) [expr {0 & 0x80 & 0x40}]
	set arr(TargetSteamTemp) [convert_float_to_U8P0 $::settings(steam_temperature)]
	set arr(TargetSteamLength) [convert_float_to_U8P0 $::settings(steam_max_time)]
	set arr(TargetHotWaterTemp) [convert_float_to_U8P0 $::settings(water_temperature)]
	set arr(TargetHotWaterVol) [convert_float_to_U8P0 $::settings(water_max_vol)]
	set arr(TargetHotWaterLength) [convert_float_to_U8P0 $::settings(water_max_time)]
	set arr(TargetEspressoVol) [convert_float_to_U8P0 $::settings(minimum_water_before_refill)]
	set arr(TargetGroupTemp) [convert_float_to_U16P8 $::settings(espresso_temperature)]
	return [make_packed_steam_hotwater_settings arr]
}


proc make_packed_steam_hotwater_settings {arrname} {
	upvar $arrname arr
	return [::fields::pack [hotwater_steam_settings_spec] arr]
}

proc version_spec {} {
	set spec {
		APIVersion {Short {} {} {unsigned} {$val / 1.0}}
		BLEFWMajor {Short {} {} {unsigned} {$val / 1.0}}
		BLEFWMinor {Short {} {} {unsigned} {$val / 1.0}}
		P0BLECommits {Short {} {} {unsigned} {$val / 1.0}}
		BLESha {char {} {} {unsigned} {$val / 1.0}}
		Dirty {char {} {} {unsigned} {$val / 1.0}}
	}
	return $spec
}

proc hotwater_steam_settings_spec {} {
	set spec {
		SteamSettings {char {} {} {unsigned} {}}
		TargetSteamTemp {char {} {} {unsigned} {}}
		TargetSteamLength {char {} {} {unsigned} {}}
		TargetHotWaterTemp {char {} {} {unsigned} {}}
		TargetHotWaterVol {char {} {} {unsigned} {}}
		TargetHotWaterLength {char {} {} {unsigned} {}}
		TargetEspressoVol {char {} {} {unsigned} {}}
		TargetGroupTemp {Short {} {} {unsigned} {$val / 256.0}}
	}
	return $spec
}

proc bintest {} {
	set packed "\x15\x09\x4c\x5e\x0d\x5b\x2d"

	set packed "\x02\xDE\x03\x36\x5D\xCD\x5B\x07\x5D\xD0\x5B\x00\x05\x34\x01"

	#write_binary_file "compare.dat" $packed

	set spec [hotwater_steam_settings_spec]

	array set specarr $spec

   ::fields::unpack $packed $spec ShotSample bigeendian
	foreach {field val} [array get ShotSample] {
		set specparts $specarr($field)
		set extra [lindex $specparts 4]
		if {$extra != ""} {
			set ShotSample($field) [expr $extra]
		}
   }


	foreach {field val} [array get ShotSample] {
		puts "$field : $val "
	}

}

proc convert_F8_1_7_to_float {in} {

  set highbit [expr {$in & 128}]
  if {$highbit == 0} {
	set out [expr {$in / 10.0}]
  } else {
  	set out [expr {$in & 127}]
  }
  return $out
}


proc convert_bottom_10_of_U10P0 {in} {
  set lowbits [expr {$in & 1023}]
  return $lowbits
}

proc make_packed_shot_sample {arrname} {
	upvar $arrname arr
	return [::fields::pack [shot_sample_spec] arr]
}

proc convert_float_to_U8P4 {in} {
	if {$in > 16} {
		set in 16
	}
	return [expr {round($in * 16)}]
}

proc convert_float_to_U8P1 {in} {
	if {$in > 128} {
		set in 128
	}
	return [expr {round($in * 2)}]
}

proc convert_float_to_U8P0 {in} {
	if {$in > 256} {
		set in 256
	}
	return [expr {round($in)}]
}

proc convert_float_to_U16P8 {in} {
	if {$in > 256} {
		set in 256
	}
	return [expr {round($in * 256.0)}]
}

proc convert_float_to_F8_1_7 {in} {

	if {$in >= 12.75} {
		if {$in > 127} {
			puts "Numbers over 127 are not allowed this F8_1_7"
			set in 127
		}
		return [expr {round($in) | 128}]

	} else {
		return [expr {round($in * 10)}]
	}
}

proc convert_float_to_U10P0 {in} {
	return [expr {round($in) | 1024}]
}


# enum T_E_FrameFlags : U8 {
#
#  // FrameFlag of zero and pressure of 0 means end of shot, unless we are at the tenth frame, in which case it's the end of shot no matter what
#  CtrlF       = 0x01, // Are we in Pressure or Flow priority mode?
#  DoCompare   = 0x02, // Do a compare, early exit current frame if compare true
#  DC_GT       = 0x04, // If we are doing a compare, then 0 = less than, 1 = greater than
#  DC_CompF    = 0x08, // Compare Pressure or Flow?
#  TMixTemp    = 0x10, // Disable shower head temperature compensation. Target Mix Temp instead.
#  Interpolate = 0x20, // Hard jump to target value, or ramp?
#  IgnoreLimit = 0x40, // Ignore minimum pressure and max flow settings
#
#  DontInterpolate = 0, // Don't interpolate, just go to or hold target value
#  CtrlP = 0,
#  DC_CompP = 0,
#  DC_LT = 0,
#  TBasketTemp = 0       // Target the basket temp, not the mix temp
#};


proc make_shot_flag {enabled_features} {

	set num 0

	foreach feature $enabled_features {
		if {$feature == "CtrlF"} {
			set num [expr {$num | 0x01}]
		} elseif {$feature == "DoCompare"} {
			set num [expr {$num | 0x02}]
		} elseif {$feature == "DC_GT"} {
			set num [expr {$num | 0x04}]
		} elseif {$feature == "DC_CompF"} {
			set num [expr {$num | 0x08}]
		} elseif {$feature == "TMixTemp"} {
			set num [expr {$num | 0x10}]
		} elseif {$feature == "Interpolate"} {
			set num [expr {$num | 0x20}]
		} elseif {$feature == "IgnoreLimit"} {
			set num [expr {$num | 0x40}]
		} else {
			err "unknown shot flat: '$feature'"
		}
	}
	return $num
}


proc parse_binary_shotdescheader {packed destarrname} {
	upvar $destarrname ShotSample
	unset -nocomplain ShotSample

	set spec [spec_shotdescheader]
	array set specarr $spec

   	::fields::unpack $packed $spec ShotSample bigeendian
	foreach {field val} [array get ShotSample] {
		set specparts $specarr($field)
		set extra [lindex $specparts 4]
		if {$extra != ""} {
			set ShotSample($field) [expr $extra]
		}
	}
}

proc parse_binary_shotframe {packed destarrname} {
	upvar $destarrname ShotSample
	unset -nocomplain ShotSample

	set spec [spec_shotframe]
	array set specarr $spec

   	::fields::unpack $packed $spec ShotSample bigeendian
	foreach {field val} [array get ShotSample] {
		set specparts $specarr($field)
		set extra [lindex $specparts 4]
		if {$extra != ""} {
			set ShotSample($field) [expr $extra]
		}
	}
}

proc spec_shotdescheader {} {
	set spec {
		HeaderV {char {} {} {unsigned} {}}
		NumberOfFrames {char {} {} {unsigned} {}}
		NumberOfPreinfuseFrames {char {} {} {unsigned} {}}
		MinimumPressure {char {} {} {unsigned} {$val / 16.0}}
		MaximumFlow {char {} {} {unsigned} {$val / 16.0}}
	}

}

proc spec_shotframe {} {
	set spec {
		FrameToWrite {char {} {} {unsigned} {}}
		Flag {char {} {} {unsigned} {}}
		SetVal {char {} {} {unsigned} {$val / 16.0}}
		Temp {char {} {} {unsigned} {$val / 2.0}}
		FrameLen {char {} {} {unsigned} {[convert_F8_1_7_to_float $val]}}
		TriggerVal {char {} {} {unsigned} {$val / 16.0}}
		MaxVol {Short {} {} {unsigned} {[convert_bottom_10_of_U10P0 $val]}}
	}
	return $spec
}

proc make_chunked_packed_shot_sample {hdrarrname framenames} {
	upvar $hdrarrname hdrarr

	set packed_header [::fields::pack [spec_shotdescheader] hdrarr]

	set packed_frames {}

	foreach framearrname $framenames {
		upvar $framearrname $hdrarrname
		lappend packed_frames [::fields::pack [spec_shotframe] $hdrarrname]
	}
	return [list $packed_header $packed_frames]
}

proc de1_packed_shot_flow {} {

	set hdr(HeaderV) 1
	set hdr(MinimumPressure) 0
	set hdr(MaximumFlow) [convert_float_to_U8P4 6]

	set mixtempflag ""
	if {![de1plus]} {
		# DE1 does not have basket temo mode
		set mixtempflag "TMixTemp"
	}

	#if {$::settings(preinfusion_time) > 0} {
		set hdr(NumberOfFrames) 4
		set hdr(NumberOfPreinfuseFrames) 1

		# preinfusion
		set frame1(FrameToWrite) 0
		set frame1(Flag) [make_shot_flag "CtrlF DoCompare DC_GT IgnoreLimit $mixtempflag"] 
		set frame1(SetVal) [convert_float_to_U8P4 $::settings(preinfusion_flow_rate)]
		set frame1(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame1(FrameLen) [convert_float_to_F8_1_7 $::settings(preinfusion_time)]
		set frame1(MaxVol) [convert_float_to_U10P0 90]

		# exit preinfusion if your pressure is above the pressure goal, no matter what
		set frame1(TriggerVal) [convert_float_to_U8P4 $::settings(preinfusion_stop_pressure)]


		# compress
		set frame2(FrameToWrite) 1
		set frame2(Flag) [make_shot_flag "DoCompare DC_GT IgnoreLimit $mixtempflag"] 
		set frame2(SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set frame2(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame2(FrameLen) [convert_float_to_F8_1_7 20]
		set frame2(TriggerVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set frame2(MaxVol) [convert_float_to_U10P0 99]

		# hold
		set frame3(FrameToWrite) 2
		set frame3(Flag) [make_shot_flag "CtrlF IgnoreLimit $mixtempflag"] 
		set frame3(SetVal) [convert_float_to_U8P4 $::settings(flow_profile_hold)]
		set frame3(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame3(FrameLen) [convert_float_to_F8_1_7 $::settings(espresso_hold_time)]
		set frame3(TriggerVal) 0
		set frame3(MaxVol) [convert_float_to_U10P0 99]

		# decline
		set frame4(FrameToWrite) 3
		set frame4(Flag) [make_shot_flag "CtrlF IgnoreLimit Interpolate $mixtempflag"] 
		set frame4(SetVal) [convert_float_to_U8P4 $::settings(flow_profile_decline)]
		set frame4(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame4(FrameLen) [convert_float_to_F8_1_7 $::settings(espresso_decline_time)]
		set frame4(TriggerVal) 0
		set frame4(MaxVol) [convert_float_to_U10P0 99]

		return [make_chunked_packed_shot_sample hdr [list frame1 frame2 frame3 frame4]]
	#} else {
	#	set hdr(NumberOfFrames) 3
	#	set hdr(NumberOfPreinfuseFrames) 0

	#	set frame1(FrameToWrite) 0
	#	set frame1(Flag) [make_shot_flag "DoCompare DC_GT IgnoreLimit $mixtempflag"] 
	#	set frame1(SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
	#	set frame1(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
	#	set frame1(FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_rampup_timeout)]
	#	set frame1(TriggerVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
	#	set frame1(MaxVol) [convert_float_to_U10P0 $::settings(pressure_rampup_stop_volumetric)]

	#	set frame2(FrameToWrite) 1
	#	set frame2(Flag) [make_shot_flag "IgnoreLimit $mixtempflag"] 
	#	set frame2(SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
	#	set frame2(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
	#	set frame2(FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_hold_time)]
	#	set frame2(TriggerVal) 0
	#	set frame2(MaxVol) [convert_float_to_U10P0 $::settings(pressure_hold_stop_volumetric)]

	#	set frame3(FrameToWrite) 2
	#	set frame3(Flag) [make_shot_flag "IgnoreLimit Interpolate $mixtempflag"] 
	#	set frame3(SetVal) [convert_float_to_U8P4 $::settings(pressure_end)]
	#	set frame3(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
	#	set frame3(FrameLen) [convert_float_to_F8_1_7 $::settings(espresso_decline_time)]
	#	set frame3(TriggerVal) 0
	#	set frame3(MaxVol) [convert_float_to_U10P0 $::settings(decline_stop_volumetric)]

	#	return [make_chunked_packed_shot_sample hdr [list frame1 frame2 frame3]]
	#}
}


# return two values as a list, with the 1st being the packed header, and the 2nd value itself
# being a list of packed frames
proc de1_packed_shot {} {

	if {[de1plus] && [ifexists ::settings(settings_profile_type)] == "settings_profile_flow"} {
		return [de1_packed_shot_flow]
	}

	set hdr(HeaderV) 1
	set hdr(MinimumPressure) 0
	set hdr(MaximumFlow) [convert_float_to_U8P4 6]

	set mixtempflag ""
	if {![de1plus]} {
		# DE1 does not have basket temo mode
		set mixtempflag "TMixTemp"
	}

	#if {$::settings(preinfusion_time) > 0} {
		set hdr(NumberOfFrames) 3
		set hdr(NumberOfPreinfuseFrames) 1

		# preinfusion
		set frame1(FrameToWrite) 0
		set frame1(Flag) [make_shot_flag "CtrlF DoCompare DC_GT IgnoreLimit $mixtempflag"] 
		
		if {[de1plus]} {
			set frame1(SetVal) [convert_float_to_U8P4 $::settings(preinfusion_flow_rate)]
			#set frame1(SetVal) [convert_float_to_U8P4 3]
		} else {
			set frame1(SetVal) [convert_float_to_U8P4 4]
		}
		set frame1(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame1(FrameLen) [convert_float_to_F8_1_7 $::settings(preinfusion_time)]
		set frame1(MaxVol) [convert_float_to_U10P0 90]

		if {![de1plus]} {
			# exit preinfusion if your pressure is above the pressure goal, no matter what
			set frame1(TriggerVal) [convert_float_to_U8P4 $::settings(preinfusion_stop_pressure)]
		} else {
			set frame1(TriggerVal) [convert_float_to_U8P4 4]
		}

		# compress
		#set frame2(FrameToWrite) 1
		#set frame2(Flag) [make_shot_flag "DoCompare DC_GT IgnoreLimit $mixtempflag"] 
		#set frame2(SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		#set frame2(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		#set frame2(FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_rampup_timeout)]
		#set frame2(TriggerVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		#set frame2(MaxVol) [convert_float_to_U10P0 $::settings(pressure_rampup_stop_volumetric)]

		# hold
		set frame2(FrameToWrite) 1
		set frame2(Flag) [make_shot_flag "IgnoreLimit $mixtempflag"] 
		set frame2(SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set frame2(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame2(FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_hold_time)]
		set frame2(TriggerVal) 0
		set frame2(MaxVol) [convert_float_to_U10P0 $::settings(pressure_hold_stop_volumetric)]

		# decline
		set frame3(FrameToWrite) 2
		set frame3(Flag) [make_shot_flag "IgnoreLimit Interpolate $mixtempflag"] 
		set frame3(SetVal) [convert_float_to_U8P4 $::settings(pressure_end)]
		set frame3(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame3(FrameLen) [convert_float_to_F8_1_7 $::settings(espresso_decline_time)]
		set frame3(TriggerVal) 0
		set frame3(MaxVol) [convert_float_to_U10P0 $::settings(decline_stop_volumetric)]

		return [make_chunked_packed_shot_sample hdr [list frame1 frame2 frame3]]
	#} else {
	#	set hdr(NumberOfFrames) 3
	#	set hdr(NumberOfPreinfuseFrames) 0

	#	set frame1(FrameToWrite) 0
	#	set frame1(Flag) [make_shot_flag "DoCompare DC_GT IgnoreLimit $mixtempflag"] 
	#	set frame1(SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
	#	set frame1(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
	#	set frame1(FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_rampup_timeout)]
	#	set frame1(TriggerVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
	#	set frame1(MaxVol) [convert_float_to_U10P0 $::settings(pressure_rampup_stop_volumetric)]

	#	set frame2(FrameToWrite) 1
	#	set frame2(Flag) [make_shot_flag "IgnoreLimit $mixtempflag"] 
	#	set frame2(SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
	#	set frame2(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
	#	set frame2(FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_hold_time)]
	#	set frame2(TriggerVal) 0
	#	set frame2(MaxVol) [convert_float_to_U10P0 $::settings(pressure_hold_stop_volumetric)]

	#	set frame3(FrameToWrite) 2
	#	set frame3(Flag) [make_shot_flag "IgnoreLimit Interpolate $mixtempflag"] 
	#	set frame3(SetVal) [convert_float_to_U8P4 $::settings(pressure_end)]
	#	set frame3(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
	#	set frame3(FrameLen) [convert_float_to_F8_1_7 $::settings(espresso_decline_time)]
	#	set frame3(TriggerVal) 0
	#	set frame3(MaxVol) [convert_float_to_U10P0 $::settings(decline_stop_volumetric)]

	#	return [make_chunked_packed_shot_sample hdr [list frame1 frame2 frame3]]
	#}
}


# 
# a shot is a packed struct of this type:
# 
# struct PACKEDATTR T_ShotDesc {
#   U8P0 HeaderV;           // Set to 1 for this type of shot description
#   U8P0 NumberOfFrames;    // Total number of frames.
#   U8P0 NumberOfPreinfuseFrames; // Number of frames that are preinfusion
#   U8P4 MinimumPressure;   // In flow priority modes, this is the minimum pressure we'll allow
#   U8P4 MaximumFlow;       // In pressure priority modes, this is the maximum flow rate we'll allow
#   T_ShotFrame Frames[10];
# };
# 
# where T_ShotFrame is:
# 
# struct PACKEDATTR T_ShotFrame {
#   U8P0   Flag;       // See T_E_FrameFlags
#   U8P4   SetVal;     // SetVal is a 4.4 fixed point number, setting either pressure or flow rate, as per mode
#   U8P1   Temp;       // Temperature in 0.5 C steps from 0 - 127.5
#   F8_1_7 FrameLen;   // FrameLen is the length of this frame. It's a 1/7 bit floating point number as described in the F8_1_7 a struct
#   U8P4   TriggerVal; // Trigger value. Could be a flow or pressure.
#   U10P0  MaxVol;     // Exit current frame if the volume/weight exceeds this value. 0 means ignore
# };
# 

proc shot_sample_spec {} {

	set spec {
		00_HeaderV {char {} {} {unsigned} {}}
		00_NumberOfFrames {char {} {} {unsigned} {}}
		00_NumberOfPreinfuseFrames {char {} {} {unsigned} {}}
		00_MinimumPressure {char {} {} {unsigned} {$val / 16.0}}
		00_MaximumFlow {char {} {} {unsigned} {$val / 16.0}}

		01_Flag {char {} {} {unsigned} {}}
		01_SetVal {char {} {} {unsigned} {$val / 16.0}}
		01_Temp {char {} {} {unsigned} {$val / 2.0}}
		01_FrameLen {char {} {} {unsigned} {[convert_F8_1_7_to_float $val]}}
		01_TriggerVal {char {} {} {unsigned} {$val / 16.0}}
		01_MaxVol {Short {} {} {unsigned} {[convert_bottom_10_of_U10P0 $val]}}

		02_Flag {char {} {} {unsigned} {}}
		02_SetVal {char {} {} {unsigned} {$val / 16.0}}
		02_Temp {char {} {} {unsigned} {$val / 2.0}}
		02_FrameLen {char {} {} {unsigned} {[convert_F8_1_7_to_float $val]}}
		02_TriggerVal {char {} {} {unsigned} {$val / 16.0}}
		02_MaxVol {Short {} {} {unsigned} {[convert_bottom_10_of_U10P0 $val]}}

		03_Flag {char {} {} {unsigned} {}}
		03_SetVal {char {} {} {unsigned} {$val / 16.0}}
		03_Temp {char {} {} {unsigned} {$val / 2.0}}
		03_FrameLen {char {} {} {unsigned} {[convert_F8_1_7_to_float $val]}}
		03_TriggerVal {char {} {} {unsigned} {$val / 16.0}}
		03_MaxVol {Short {} {} {unsigned} {[convert_bottom_10_of_U10P0 $val]}}

		04_Flag {char {} {} {unsigned} {}}
		04_SetVal {char {} {} {unsigned} {$val / 16.0}}
		04_Temp {char {} {} {unsigned} {$val / 2.0}}
		04_FrameLen {char {} {} {unsigned} {[convert_F8_1_7_to_float $val]}}
		04_TriggerVal {char {} {} {unsigned} {$val / 16.0}}
		04_MaxVol {Short {} {} {unsigned} {[convert_bottom_10_of_U10P0 $val]}}

		05_Flag {char {} {} {unsigned} {}}
		05_SetVal {char {} {} {unsigned} {$val / 16.0}}
		05_Temp {char {} {} {unsigned} {$val / 2.0}}
		05_FrameLen {char {} {} {unsigned} {[convert_F8_1_7_to_float $val]}}
		05_TriggerVal {char {} {} {unsigned} {$val / 16.0}}
		05_MaxVol {Short {} {} {unsigned} {[convert_bottom_10_of_U10P0 $val]}}

		06_Flag {char {} {} {unsigned} {}}
		06_SetVal {char {} {} {unsigned} {$val / 16.0}}
		06_Temp {char {} {} {unsigned} {$val / 2.0}}
		06_FrameLen {char {} {} {unsigned} {[convert_F8_1_7_to_float $val]}}
		06_TriggerVal {char {} {} {unsigned} {$val / 16.0}}
		06_MaxVol {Short {} {} {unsigned} {[convert_bottom_10_of_U10P0 $val]}}

		07_Flag {char {} {} {unsigned} {}}
		07_SetVal {char {} {} {unsigned} {$val / 16.0}}
		07_Temp {char {} {} {unsigned} {$val / 2.0}}
		07_FrameLen {char {} {} {unsigned} {[convert_F8_1_7_to_float $val]}}
		07_TriggerVal {char {} {} {unsigned} {$val / 16.0}}
		07_MaxVol {Short {} {} {unsigned} {[convert_bottom_10_of_U10P0 $val]}}

		08_Flag {char {} {} {unsigned} {}}
		08_SetVal {char {} {} {unsigned} {$val / 16.0}}
		08_Temp {char {} {} {unsigned} {$val / 2.0}}
		08_FrameLen {char {} {} {unsigned} {[convert_F8_1_7_to_float $val]}}
		08_TriggerVal {char {} {} {unsigned} {$val / 16.0}}
		08_MaxVol {Short {} {} {unsigned} {[convert_bottom_10_of_U10P0 $val]}}

		09_Flag {char {} {} {unsigned} {}}
		09_SetVal {char {} {} {unsigned} {$val / 16.0}}
		09_Temp {char {} {} {unsigned} {$val / 2.0}}
		09_FrameLen {char {} {} {unsigned} {[convert_F8_1_7_to_float $val]}}
		09_TriggerVal {char {} {} {unsigned} {$val / 16.0}}
		09_MaxVol {Short {} {} {unsigned} {[convert_bottom_10_of_U10P0 $val]}}

		10_Flag {char {} {} {unsigned} {}}
		10_SetVal {char {} {} {unsigned} {$val / 16.0}}
		10_Temp {char {} {} {unsigned} {$val / 2.0}}
		10_FrameLen {char {} {} {unsigned} {[convert_F8_1_7_to_float $val]}}
		10_TriggerVal {char {} {} {unsigned} {$val / 16.0}}
		10_MaxVol {Short {} {} {unsigned} {[convert_bottom_10_of_U10P0 $val]}}
	}

}


proc parse_binary_version_desc {packed destarrname} {
	upvar $destarrname Version
	unset -nocomplain Version

	set spec [version_spec]
	array set specarr $spec

   	::fields::unpack $packed $spec Version bigeendian
	foreach {field val} [array get Version] {
		set specparts $specarr($field)
		set extra [lindex $specparts 4]
		if {$extra != ""} {
			set Version($field) [expr $extra]
		}
	}
}

proc parse_binary_hotwater_desc {packed destarrname} {
	upvar $destarrname ShotSample
	unset -nocomplain ShotSample

	set spec [hotwater_steam_settings_spec]
	array set specarr $spec

   	::fields::unpack $packed $spec ShotSample bigeendian
	foreach {field val} [array get ShotSample] {
		set specparts $specarr($field)
		set extra [lindex $specparts 4]
		if {$extra != ""} {
			set ShotSample($field) [expr $extra]
		}
	}
}

proc parse_binary_shot_desc {packed destarrname} {
	upvar $destarrname ShotSample
	unset -nocomplain ShotSample

	set spec [shot_sample_spec]
	array set specarr $spec

   	::fields::unpack $packed $spec ShotSample bigeendian
	foreach {field val} [array get ShotSample] {
		set specparts $specarr($field)
		set extra [lindex $specparts 4]
		if {$extra != ""} {
			set ShotSample($field) [expr $extra]
		}
	}
}

proc bintest2 {} {
	set packed [read_binary_file "/Desktop/PresShotDesc.bin"]

	parse_binary_shot_desc $packed ShotSample

	foreach field [lsort [array names ShotSample]] {
		set val $ShotSample($field)
		puts "$field : $val "
	}

}

proc get_timer {state substate} {

  set timerkey "$::de1_num_state_reversed($state)-$::de1_substate_types_reversed($substate)"
  set timer 0

  catch {
	set timer $::timers($timerkey)
  }

  #puts "$timerkey - timer $state $substate : $timer [array get ::timers]"
  return $timer
}

proc use_old_ble_spec {} {
	return 0
}


proc update_de1_shotvalue {packed} {

  if {[string length $packed] < 7} {
	msg "ERROR: short packed message"
	return
  }

  	# the timer stores hundreds of a second, so we take the half cycles, divide them by hertz/2 to get seconds, and then multiple that all by 100 to get 100ths of a second, stored as an int
	set spec_old {
		Timer {Short {} {} {unsigned} {int(100 * ($val / ($::de1(hertz) * 2.0)))}}
		GroupPressure {char {} {} {unsigned} {$val / 16.0}}
		GroupFlow {char {} {} {unsigned} {$val / 16.0}}
		MixTemp {Short {} {} {unsigned} {$val / 256.0}}
		HeadTemp {Short {} {} {unsigned} {$val / 256.0}}
		SetMixTemp {Short {} {} {unsigned} {$val / 256.0}}
		SetHeadTemp {Short {} {} {unsigned} {$val / 256.0}}
		SetGroupPressure {char {} {} {unsigned} {$val / 16.0}}
		SetGroupFlow {char {} {} {unsigned} {$val / 16.0}}
		FrameNumber {char {} {} {unsigned} {}}
		SteamTemp {Short {} {} {unsigned} {$val / 256.0}}
	}

	# HeatTemp is a 24bit number, which Tcl doesn't have, so we grab it as 3 chars and manually convert it to a number	
  	set spec {
		Timer {Short {} {} {unsigned} {int(100 * ($val / ($::de1(hertz) * 2.0)))}}
		GroupPressure {Short {} {} {unsigned} {$val / 4096.0}}
		GroupFlow {Short {} {} {unsigned} {$val / 4096.0}}
		MixTemp {Short {} {} {unsigned} {$val / 256.0}}
		HeadTemp1 {char {} {} {unsigned} {}}
		HeadTemp2 {char {} {} {unsigned} {}}
		HeadTemp3 {char {} {} {unsigned} {}}
		SetMixTemp {Short {} {} {unsigned} {$val / 256.0}}
		SetHeadTemp {Short {} {} {unsigned} {$val / 256.0}}
		SetGroupPressure {char {} {} {unsigned} {$val / 16.0}}
		SetGroupFlow {char {} {} {unsigned} {$val / 16.0}}
		FrameNumber {char {} {} {unsigned} {}}
		SteamTemp {chart {} {} {unsigned} {}}
  	}

  	if {[use_old_ble_spec] == 1} {
	   	array set specarr $spec_old
		::fields::unpack $packed $spec_old ShotSample bigeendian
	} else {
	   	array set specarr $spec
		::fields::unpack $packed $spec ShotSample bigeendian
	}

  	foreach {field val} [array get ShotSample] {
	set specparts $specarr($field)
	set extra [lindex $specparts 4]
	if {$extra != ""} {
	  	set ShotSample($field) [expr $extra]
	}
}



  #msg "update_de1_shotvalue [array get ShotSample]"

	#msg "de1 internals: [array get ShotSample]"
	set delta 0
 if {[info exists ShotSample(Timer)] == 1} {
	set previous_timer $::de1(timer)
	set ::de1(timer) $ShotSample(Timer)
	set delta [expr {$::de1(timer) - $previous_timer}]
	set timerkey "$::de1(state)-$::de1(substate)"
	set ::timers($timerkey) $::de1(timer)
  }
	#set previous_timer $::de1(timer)
	#set ::de1(timer) [clock milliseconds]
	#set delta [expr {$::de1(timer) - $previous_timer}]
	#set timerkey "$::de1(state)-$::de1(substate)"
	#set ::timers($timerkey) $::de1(timer)


  	if {[use_old_ble_spec] == 1} {
		set HeadTemp $ShotSample(HeadTemp)
		set ::de1(head_temperature) $HeadTemp
	} else {
	  	if {[info exists ShotSample(HeadTemp1)] == 1} {
			set HeadTemp [expr { $ShotSample(HeadTemp1) + ($ShotSample(HeadTemp2) / 256.0) + ($ShotSample(HeadTemp3) / 65536.0) }]
		}
		#puts "HeadTemp: $HeadTemp"
		set ::de1(head_temperature) $HeadTemp
		#msg "updated head temp $ShotSample(HeadTemp)"
	}

  if {[info exists ShotSample(MixTemp)] == 1} {
	set ::de1(mix_temperature) $ShotSample(MixTemp)
	#msg "updated mix temp to $ShotSample(MixTemp)"
  }
  if {[info exists ShotSample(SteamTemp)] == 1} {
	set ::de1(steam_heater_temperature) $ShotSample(SteamTemp)
	#msg "updated mix temp to $ShotSample(MixTemp)"
  }
  if {[info exists ShotSample(GroupFlow)] == 1 && $delta != 0} {
	set ::de1(flow_delta) [expr {$::de1(flow) - $ShotSample(GroupFlow)}]
	set ::de1(flow) $ShotSample(GroupFlow)
	set ::de1(volume) [expr {$::de1(volume) + ($ShotSample(GroupFlow) * ($delta/100.0) )}]
	#msg "updated flow"
  }

  if {[info exists ShotSample(GroupPressure)] == 1} {
	set ::de1(pressure) $ShotSample(GroupPressure)
	#msg "updated pressure"
  }

  if {[info exists ShotSample(SetGroupFlow)] == 1} {
	set ::de1(goal_flow) $ShotSample(SetGroupFlow)
	#msg "updated head flow $ShotSample(SetGroupFlow)"
  }
  if {[info exists ShotSample(SetGroupPressure)] == 1} {
	set ::de1(goal_pressure) $ShotSample(SetGroupPressure)
	#msg "updated head pressure $ShotSample(SetGroupPressure)"
  }
  if {[info exists ShotSample(SetHeadTemp)] == 1} {
	set ::de1(goal_temperature) $ShotSample(SetHeadTemp)
	#msg "updated head temp $ShotSample(SetHeadTemp)"
  }

  append_live_data_to_espresso_chart
}

set previous_de1_substate 0
set state_change_chart_value 10000000
set previous_espresso_flow 0
set previous_espresso_flow_time [millitimer]

proc append_live_data_to_espresso_chart {} {

    if {$::de1_num_state($::de1(state)) != "Espresso"} {
    	# we only store chart data during espresso
    	# we could theoretically store this data during steam as well, if we want to have charts of steaming temperature and pressure
    	return 
    }

	global previous_de1_substate
	global state_change_chart_value

  if {$::de1(substate) == $::de1_substate_types_reversed(pouring) || $::de1(substate) == $::de1_substate_types_reversed(preinfusion)} {
	# to keep the espresso charts going
	if {[millitimer] < 500} { 
	  # need to make sure we don't append data from an earlier time, as that destroys the chart
	  return
	}

	if {[espresso_elapsed length] > 0} {
	  if {[espresso_elapsed range end end] > [expr {[millitimer]/1000.0}]} {
		#puts "discarding chart data after timer reset"
		clear_espresso_chart
		return
	  }
	}

	set millitime [millitimer]

	espresso_elapsed append [expr {$millitime/1000.0}]
	espresso_pressure append $::de1(pressure)
	espresso_flow append $::de1(flow)
	espresso_flow_2x append [expr {2.0 * $::de1(flow)}]

	#set elapsed_since_last [expr {$millitime - $::previous_espresso_flow_time}]
	#puts "elapsed_since_last: $elapsed_since_last"
	#set flow_delta [expr { 10 * ($::de1(flow)  - $::previous_espresso_flow) }]
	set flow_delta [diff_flow_rate]
	set negative_flow_delta_for_chart 0
	if {$flow_delta > 0} {
		set negative_flow_delta_for_chart [expr {6.0 - (10.0 * $flow_delta)}]
		set negative_flow_delta_for_chart_2x [expr {12.0 - (10.0 * $flow_delta)}]
		##espresso_flow_delta append [round_to_two_digits $negative_flow_delta_for_chart]
		espresso_flow_delta_negative append $negative_flow_delta_for_chart
		espresso_flow_delta_negative_2x append $negative_flow_delta_for_chart_2x
		espresso_flow_delta append 0
		#puts "negative flow_delta: $flow_delta ($negative_flow_delta_for_chart)"
	} else {
		espresso_flow_delta append [expr {abs(10*$flow_delta)}]
		espresso_flow_delta_negative append 6
		espresso_flow_delta_negative_2x append 12
		#puts "flow_delta: $flow_delta ($negative_flow_delta_for_chart)"
	}


	set ::previous_espresso_flow $::de1(flow)

	#espresso_flow_delta append  3
	espresso_temperature_mix append [return_temperature_number $::de1(mix_temperature)]
	espresso_temperature_basket append [return_temperature_number $::de1(head_temperature)]
	espresso_state_change append $state_change_chart_value

	set ::previous_espresso_flow_time $millitime

	# don't chart goals at zero, instead take them off the chart
	if {$::de1(goal_flow) == 0} {
		espresso_flow_goal append "-.1"
		espresso_flow_goal_2x append "-.1"
	} else {
		espresso_flow_goal append $::de1(goal_flow)
		espresso_flow_goal_2x append [expr {2.0 * $::de1(goal_flow)}]
	}

	# don't chart goals at zero, instead take them off the chart
	if {$::de1(goal_pressure) == 0} {
		espresso_pressure_goal append "-.1"
	} else {
		espresso_pressure_goal append $::de1(goal_pressure)
	}

	espresso_temperature_goal append [return_temperature_number $::de1(goal_temperature)]

	# if the state changes flip the value negative
	if {$previous_de1_substate != $::de1(substate)} {
	  	set previous_de1_substate $::de1(substate)
		#set ::substate_timers($previous_timer) [clock seconds]
	  	set state_change_chart_value [expr {$state_change_chart_value * -1}]
	}

  }
}  

proc update_de1_state {statechar} {

  set spec {
	state char
	substate char
  }

  ::fields::unpack $statechar $spec msg bigeendian

  #msg "update_de1_state [array get msg]"

  if {$msg(state) != $::de1(state)} {
	set textstate $::de1_num_state($msg(state))    
	msg "state change: [array get msg] ($textstate)"
	set ::de1(state) $msg(state)
	clear_timers
  }

  if {[info exists msg(substate)] == 1} {
	#if {$msg(substate) != 0} {
	  # substate of zero means no information, discard
	  if {$msg(substate) != $::de1(substate)} {
		msg "substate change: [array get msg]"
		set ::de1(substate) $msg(substate)

		# if we are changing into preinfusion in espresso mode, reset the charts and the timer
		if {$::de1(state) == $::de1_num_state_reversed(Espresso) && $::de1(substate) == $::de1_substate_types_reversed(preinfusion)} {
		  clear_espresso_chart
		}

	  }
	  set timerkey "$::de1(state)-$::de1(substate)"
	  set ::timers($timerkey) $::de1(timer)
	#}
  }

  set textstate $::de1_num_state($msg(state))

  if {$textstate == "Idle"} {
	page_display_change $::de1(current_context) "off"
  } elseif {$textstate == "GoingToSleep"} {
	page_display_change $::de1(current_context) "sleep" 
  } elseif {$textstate == "Sleep"} {
	page_display_change $::de1(current_context) "saver" 
  } elseif {$textstate == "Steam"} {
	page_display_change $::de1(current_context) "steam" 
  } elseif {$textstate == "Espresso"} {
	page_display_change $::de1(current_context) "espresso" 
  } elseif {$textstate == "HotWater"} {
	page_display_change $::de1(current_context) "water" 
  } elseif {$textstate == "Refill"} {
	page_display_change $::de1(current_context) "tankempty" 
  } elseif {$textstate == "TankEmpty"} {
	page_display_change $::de1(current_context) "tankempty" 
  } elseif {$textstate == "FillingTank"} {
	page_display_change $::de1(current_context) "tankfilling" 
  }
}



#bintest

