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

# return two values as a list, with the 1st being the packed header, and the 2nd value itself
# being a list of packed frames
proc return_chunked_de1_packed_shot_sample {} {

	set hdr(HeaderV) 1
	set hdr(MinimumPressure) 0
	set hdr(MaximumFlow) [convert_float_to_U8P4 6]

	if {$::settings(preinfusion_enabled) == 1} {
		set hdr(NumberOfFrames) 4
		set hdr(NumberOfPreinfuseFrames) 1

		set frame1(FrameToWrite) 0
		
		if {$::settings(goal_is_basket_temp) == 1} {
			set frame1(Flag) [make_shot_flag {CtrlF DoCompare DC_GT IgnoreLimit}] 
		} else {
			set frame1(Flag) [make_shot_flag {CtrlF DoCompare DC_GT IgnoreLimit TMixTemp}] 
		}
		set frame1(SetVal) [convert_float_to_U8P4 $::settings(preinfusion_flow_rate)]
		set frame1(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame1(FrameLen) [convert_float_to_F8_1_7 $::settings(preinfusion_stop_timeout)]
		set frame1(TriggerVal) [convert_float_to_U8P4 $::settings(preinfusion_stop_pressure)]
		set frame1(MaxVol) [convert_float_to_U10P0 $::settings(preinfusion_stop_volumetric)]

		set frame2(FrameToWrite) 1
		if {$::settings(goal_is_basket_temp) == 1} {
			set frame2(Flag) [make_shot_flag {DoCompare DC_GT IgnoreLimit}] 
		} else {
			set frame2(Flag) [make_shot_flag {DoCompare DC_GT IgnoreLimit TMixTemp}] 
		}
		set frame2(SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set frame2(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame2(FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_rampup_timeout)]
		set frame2(TriggerVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set frame2(MaxVol) [convert_float_to_U10P0 $::settings(pressure_rampup_stop_volumetric)]

		set frame3(FrameToWrite) 2
		if {$::settings(goal_is_basket_temp) == 1} {
			set frame3(Flag) [make_shot_flag {IgnoreLimit}] 
		} else {
			set frame3(Flag) [make_shot_flag {IgnoreLimit TMixTemp}] 
		}
		set frame3(SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set frame3(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame3(FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_hold_time)]
		set frame3(TriggerVal) 0
		set frame3(MaxVol) [convert_float_to_U10P0 $::settings(pressure_hold_stop_volumetric)]

		set frame4(FrameToWrite) 3
		if {$::settings(goal_is_basket_temp) == 1} {
			set frame4(Flag) [make_shot_flag {IgnoreLimit Interpolate}] 
		} else {
			set frame4(Flag) [make_shot_flag {IgnoreLimit Interpolate TMixTemp}] 
		}
		set frame4(SetVal) [convert_float_to_U8P4 $::settings(pressure_end)]
		set frame4(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame4(FrameLen) [convert_float_to_F8_1_7 $::settings(espresso_decline_time)]
		set frame4(TriggerVal) 0
		set frame4(MaxVol) [convert_float_to_U10P0 $::settings(decline_stop_volumetric)]

		return [make_chunked_packed_shot_sample hdr [list frame1 frame2 frame3 frame4]]
	} else {
		set hdr(NumberOfFrames) 3
		set hdr(NumberOfPreinfuseFrames) 0

		set frame1(FrameToWrite) 0
		
		if {$::settings(goal_is_basket_temp) == 1} {
			set frame1(Flag) [make_shot_flag {DoCompare DC_GT IgnoreLimit}] 
		} else {
			set frame1(Flag) [make_shot_flag {DoCompare DC_GT IgnoreLimit TMixTemp}] 
		}


		set frame1(SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set frame1(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame1(FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_rampup_timeout)]
		set frame1(TriggerVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set frame1(MaxVol) [convert_float_to_U10P0 $::settings(pressure_rampup_stop_volumetric)]

		set frame2(FrameToWrite) 1
		if {$::settings(goal_is_basket_temp) == 1} {
			set frame2(Flag) [make_shot_flag {IgnoreLimit}] 
		} else {
			set frame2(Flag) [make_shot_flag {IgnoreLimit TMixTemp}] 
		}
		set frame2(SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set frame2(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame2(FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_hold_time)]
		set frame2(TriggerVal) 0
		set frame2(MaxVol) [convert_float_to_U10P0 $::settings(pressure_hold_stop_volumetric)]

		set frame3(FrameToWrite) 2
		if {$::settings(goal_is_basket_temp) == 1} {
			set frame3(Flag) [make_shot_flag {IgnoreLimit Interpolate}] 
		} else {
			set frame3(Flag) [make_shot_flag {IgnoreLimit Interpolate TMixTemp}] 
		}
		set frame3(SetVal) [convert_float_to_U8P4 $::settings(pressure_end)]
		set frame3(Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set frame3(FrameLen) [convert_float_to_F8_1_7 $::settings(espresso_decline_time)]
		set frame3(TriggerVal) 0
		set frame3(MaxVol) [convert_float_to_U10P0 $::settings(decline_stop_volumetric)]

		return [make_chunked_packed_shot_sample hdr [list frame1 frame2 frame3]]
	}

}



proc return_de1_packed_shot_sample_obsolete {} {

	#set ::settings(preinfusion_stop_pressure) 

	set framenum 1
	set arr(00_HeaderV) 1
	set arr(00_MinimumPressure) 0
	set arr(00_MaximumFlow) [convert_float_to_U8P4 6]

	if {$::settings(preinfusion_enabled) == 1} {
		set arr(00_NumberOfFrames) 4
		set arr(00_NumberOfPreinfuseFrames) 1

		set arr(01_Flag) [make_shot_flag {CtrlF DoCompare DC_GT IgnoreLimit}] 
		set arr(01_SetVal) [convert_float_to_U8P4 $::settings(preinfusion_flow_rate)]
		set arr(01_Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set arr(01_FrameLen) [convert_float_to_F8_1_7 $::settings(preinfusion_stop_timeout)]
		set arr(01_TriggerVal) [convert_float_to_U8P4 $::settings(preinfusion_stop_pressure)]
		set arr(01_MaxVol) [convert_float_to_U10P0 $::settings(preinfusion_stop_volumetric)]

		set arr(02_Flag) [make_shot_flag {DoCompare DC_GT IgnoreLimit}] 
		set arr(02_SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set arr(02_Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set arr(02_FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_rampup_timeout)]
		set arr(02_TriggerVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set arr(02_MaxVol) [convert_float_to_U10P0 $::settings(pressure_rampup_stop_volumetric)]

		set arr(03_Flag) [make_shot_flag {IgnoreLimit}] 
		set arr(03_SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set arr(03_Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set arr(03_FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_hold_time)]
		set arr(03_TriggerVal) 0
		set arr(03_MaxVol) [convert_float_to_U10P0 $::settings(pressure_hold_stop_volumetric)]

		set arr(04_Flag) [make_shot_flag {IgnoreLimit Interpolate}] 
		set arr(04_SetVal) [convert_float_to_U8P4 $::settings(pressure_end)]
		set arr(04_Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set arr(04_FrameLen) [convert_float_to_F8_1_7 $::settings(espresso_decline_time)]
		set arr(04_TriggerVal) 0
		set arr(04_MaxVol) [convert_float_to_U10P0 $::settings(decline_stop_volumetric)]

	} else {
		set arr(00_NumberOfFrames) 3
		set arr(00_NumberOfPreinfuseFrames) 0

		set arr(01_Flag) [make_shot_flag {DoCompare DC_GT IgnoreLimit}] 
		set arr(01_SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set arr(01_Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set arr(01_FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_rampup_timeout)]
		set arr(01_TriggerVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set arr(01_MaxVol) [convert_float_to_U10P0 $::settings(pressure_rampup_stop_volumetric)]

		set arr(02_Flag) [make_shot_flag {IgnoreLimit}] 
		set arr(02_SetVal) [convert_float_to_U8P4 $::settings(espresso_pressure)]
		set arr(02_Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set arr(02_FrameLen) [convert_float_to_F8_1_7 $::settings(pressure_hold_time)]
		set arr(02_TriggerVal) 0
		set arr(02_MaxVol) [convert_float_to_U10P0 $::settings(pressure_hold_stop_volumetric)]

		set arr(03_Flag) [make_shot_flag {IgnoreLimit Interpolate}] 
		set arr(03_SetVal) [convert_float_to_U8P4 $::settings(pressure_end)]
		set arr(03_Temp) [convert_float_to_U8P1 $::settings(espresso_temperature)]
		set arr(03_FrameLen) [convert_float_to_F8_1_7 $::settings(espresso_decline_time)]
		set arr(03_TriggerVal) 0
		set arr(03_MaxVol) [convert_float_to_U10P0 $::settings(decline_stop_volumetric)]

		set arr(04_Flag) 0
		set arr(04_SetVal) 0
		set arr(04_Temp) 0
		set arr(04_FrameLen) 0
		set arr(04_TriggerVal) 0
		set arr(04_MaxVol) 0

	}

	set arr(05_Flag) 0
	set arr(05_SetVal) 0
	set arr(05_Temp) 0
	set arr(05_FrameLen) 0
	set arr(05_TriggerVal) 0
	set arr(05_MaxVol) 0

	set arr(06_Flag) 0
	set arr(06_SetVal) 0
	set arr(06_Temp) 0
	set arr(06_FrameLen) 0
	set arr(06_TriggerVal) 0
	set arr(06_MaxVol) 0

	set arr(07_Flag) 0
	set arr(07_SetVal) 0
	set arr(07_Temp) 0
	set arr(07_FrameLen) 0
	set arr(07_TriggerVal) 0
	set arr(07_MaxVol) 0

	set arr(08_Flag) 0
	set arr(08_SetVal) 0
	set arr(08_Temp) 0
	set arr(08_FrameLen) 0
	set arr(08_TriggerVal) 0
	set arr(08_MaxVol) 0

	set arr(09_Flag) 0
	set arr(09_SetVal) 0
	set arr(09_Temp) 0
	set arr(09_FrameLen) 0
	set arr(09_TriggerVal) 0
	set arr(09_MaxVol) 0

	set arr(10_Flag) 0
	set arr(10_SetVal) 0
	set arr(10_Temp) 0
	set arr(10_FrameLen) 0
	set arr(10_TriggerVal) 0
	set arr(10_MaxVol) 0


	return [make_packed_shot_sample arr]
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


proc update_de1_shotvalue {packed} {

  if {[string length $packed] < 7} {
	msg "ERROR: short packed message"
	return
  }

  # the timer stores hundreds of a second, so we take the half cycles, divide them by hertz/2 to get seconds, and then multiple that all by 100 to get 100ths of a second, stored as an int
  set spec {
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

   array set specarr $spec

	::fields::unpack $packed $spec ShotSample bigeendian
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


  if {[info exists ShotSample(HeadTemp)] == 1} {
	set ::de1(head_temperature) $ShotSample(HeadTemp)
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
proc append_live_data_to_espresso_chart {} {

  
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

	espresso_elapsed append [expr {[millitimer]/1000.0}]
	espresso_pressure append $::de1(pressure)
	espresso_flow append $::de1(flow)
	espresso_temperature_mix append [return_temperature_number $::de1(mix_temperature)]
	espresso_temperature_basket append [return_temperature_number $::de1(head_temperature)]
	espresso_state_change append $state_change_chart_value

	# don't chart goals at zero, instead take them off the chart
	if {$::de1(goal_flow) == 0} {
		espresso_flow_goal append -1
	} else {
		espresso_flow_goal append $::de1(goal_flow)
	}

	# don't chart goals at zero, instead take them off the chart
	if {$::de1(goal_pressure) == 0} {
		espresso_pressure_goal append -1
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
	if {$msg(substate) != 0} {
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
	}
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
  } elseif {$textstate == "TankEmpty"} {
	page_display_change $::de1(current_context) "tankempty" 
  } elseif {$textstate == "FillingTank"} {
	page_display_change $::de1(current_context) "tankfilling" 
  }
}



#bintest

