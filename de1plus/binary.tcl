package provide de1_binary 1.1

package require lambda

package require de1_event 1.0
package require de1_logging 1.0
package require de1_profile 2.0



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
	   } else {
	   	# john this seems to be a case which throws an error for integers
	   		set ty $t
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
	   
	   if {$ty == "I" && $s ==  "s"} {
	   	# signed integers are by default, and need no modifier
	   	#set ty "s1"
	   	set s ""
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
   return [eval binary format [list $form] {*}$in]
}

# pack the fields from $packed contained into array according to spec
proc ::fields::unpack {packed spec array {endian ""}} {
   upvar $array Record
   foreach {form out in} [::fields::2form $spec Record $endian] break
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

	# turn the steam heater off completely, if the heater is set to below 130ºC
	set steam_temperature $::settings(steam_temperature)
	if {$steam_temperature < 130} {
		set steam_temperature 0
	}

	if {$::settings(steam_disabled) != 1} {
		set arr(TargetSteamTemp) [convert_float_to_U8P0 $steam_temperature]
	} else {
		set arr(TargetSteamTemp) [convert_float_to_U8P0 0]
	}
	set arr(TargetSteamLength) [convert_float_to_U8P0 $::settings(steam_timeout)]
	set arr(TargetHotWaterTemp) [convert_float_to_U8P0 $::settings(water_temperature)]
	
	if {$::de1(scale_device_handle) != 0} {
		# "hot water: stop on weight" feature. Works with the scale, so it's more accurate.
		# we ask for more water than we need, so that we can definitely get enough
		# to stop on weight.
		set arr(TargetHotWaterVol) [convert_float_to_U8P0 [expr { 2 * $::settings(water_volume)}] ]
		#set arr(TargetHotWaterVol) [convert_float_to_U8P0 $::settings(water_volume)]
	} else {
		set arr(TargetHotWaterVol) [convert_float_to_U8P0 $::settings(water_volume)]
	}

	set arr(TargetHotWaterLength) [convert_float_to_U8P0 $::settings(water_time_max)]
	set arr(TargetEspressoVol) [convert_float_to_U8P0 $::settings(espresso_typical_volume)]
	set arr(TargetGroupTemp) [convert_float_to_U16P8 $::settings(espresso_temperature)]
	return [make_packed_steam_hotwater_settings arr]
}


proc return_de1_packed_waterlevel_settings {} {
	set arr(Level) [convert_float_to_U16P8 0]
	set arr(StartFillLevel) [convert_float_to_U16P8 $::settings(water_refill_point)]
	return [make_packed_waterlevel_settings arr]
}

proc make_packed_steam_hotwater_settings {arrname} {
	upvar $arrname arr
	return [::fields::pack [hotwater_steam_settings_spec] arr]
}

proc make_packed_waterlevel_settings {arrname} {
	upvar $arrname arr
	return [::fields::pack [waterlevel_spec] arr]
}

proc make_packed_maprequest {arrname} {
	upvar $arrname arr
	return [::fields::pack [maprequest_spec] arr]
}

proc make_packed_calibration {arrname} {
	upvar $arrname arr
	return [::fields::pack [calibrate_spec] arr]
}

proc make_U32P0 {val} {
 	set arr(highest)  [expr {($val >> 24) & 0xFF}]
 	set arr(hi)  [expr {($val >> 16) & 0xFF}]
  	set arr(mid) [expr {($val >> 8 ) & 0xFF}]
  	set arr(low)  [expr {($val      ) & 0xFF}]
	return [::fields::pack [U32P0_spec] arr]
}


proc make_U24P0 {val} {
 	set arr(hi)  [expr {($val >> 16) & 0xFF}]
  	set arr(mid) [expr {($val >> 8 ) & 0xFF}]
  	set arr(low)  [expr {($val      ) & 0xFF}]
	return [::fields::pack [U24P0_spec] arr]
}


proc make_U24P0_3_chars {val} {
 	set hi  [expr {($val >> 16) & 0xFF}]
  	set mid [expr {($val >> 8 ) & 0xFF}]
  	set lo  [expr {($val      ) & 0xFF}]
	return [list $hi $mid $lo]
}

proc make_U32P0_4_chars {val} {
 	set highest  [expr {($val >> 24) & 0xFF}]
 	set hi  [expr {($val >> 16) & 0xFF}]
  	set mid [expr {($val >> 8 ) & 0xFF}]
  	set lo  [expr {($val      ) & 0xFF}]
	return [list $highest $hi $mid $lo]
}
proc U24P0_spec {} {
	set spec {
		hi {char {} {} {unsigned} {}}
		mid {char {} {} {unsigned} {}}
		low {char {} {} {unsigned} {}}
	}
	return $spec
}
proc U32P0_spec {} {
	set spec {
		highest {char {} {} {unsigned} {}}
		hi {char {} {} {unsigned} {}}
		mid {char {} {} {unsigned} {}}
		low {char {} {} {unsigned} {}}
	}
	return $spec
}

proc decent_scale_generic_read_spec {} {
	set spec {
		model {char {} {} {unsigned} {}}
		command {char {} {} {unsigned} {}}
		data3 {char {} {} {unsigned} {}}
		data4 {char {} {} {unsigned} {}}
		data5 {char {} {} {unsigned} {}}
		data6 {char {} {} {unsigned} {}}
		xor {char {} {} {unsigned} {}}
	}
	return $spec
}

proc decent_scale_generic_read_spec_v12 {} {
	set spec {
		model {char {} {} {unsigned} {}}
		command {char {} {} {unsigned} {}}
		data3 {char {} {} {unsigned} {}}
		data4 {char {} {} {unsigned} {}}
		data5 {char {} {} {unsigned} {}}
		data6 {char {} {} {unsigned} {}}
		data7 {char {} {} {unsigned} {}}
		data8 {char {} {} {unsigned} {}}
		data9 {char {} {} {unsigned} {}}
		xor {char {} {} {unsigned} {}}
	}
	return $spec
}

proc decent_scale_weight_read_spec {} {
	set spec {
		model {char {} {} {unsigned} {}}
		wtype {char {} {} {unsigned} {}}
		weight {Short {} {} {} {}}
		rate {Short {} {} {unsigned} {}}
		xor {char {} {} {unsigned} {}}
	}
	return $spec
}

proc decent_scale_weight_read_spec2 {} {
	set spec {
		model {char {} {} {unsigned} {}}
		wtype {char {} {} {unsigned} {}}
		weight {Short {} {} {} {}}
		rate {Short {} {} {unsigned} {}}
		xor {char {} {} {unsigned} {}}
	}
	return $spec
}

proc decent_scale_weight_read_spec_v12 {} {
	set spec {
		model {char {} {} {unsigned} {}}
		wtype {char {} {} {unsigned} {}}
		weight {Short {} {} {} {}}
		minutes {char {} {} {unsigned} {}}
		seconds {char {} {} {unsigned} {}}
		milliseconds {char {} {} {unsigned} {}}
		unused1 {char {} {} {unsigned} {}}
		unused2 {char {} {} {unsigned} {}}
		xor {char {} {} {unsigned} {}}
	}

	return $spec
}


# typedef struct {
#   U32 CheckSum;    // The checksum of the rest of the encrypted image. Includes "CheckSums" + "Data" fields, not "Header"
#   U32 BoardMarker; // 0xDE100001
#   U32 Version;     // The version of this image
#   U32 ByteCount;   // Number of bytes in image body, ignoring padding.
#   U32 CPUBytes;    // The first CPUBytes of the image are for the CPU. Remainder is for BLE.
#   U32 Unused;      // Blank spot for future extension. Always zero for now
#   U32 DCSum;       // Checksum of decrypted image
#   U8  IV[32];       // Initialization vector for the firmware
#   U32 HSum;        // Checksum of this header.
# } T_FirmwareHeader;

proc firmware_file_spec {} {
	set spec {
		CheckSum {int {} {} {unsigned} {[format %X $val]}}
		BoardMarker {int {} {} {unsigned} {[format %X $val]}}
		Version {int {} {} {unsigned} {}}
		ByteCount {int {} {} {unsigned} {}}
		CPUBytes {int {} {} {unsigned} {}}
		Unused {int {} {} {unsigned} {}}
		DCSum {int {} {} {unsigned} {[format %X $val]}}
	}
	return $spec
}


proc decent_scale_timing_read_spec {} {
	set spec {
		minute {char {} {} {unsigned} {}}
		seconds {char {} {} {unsigned} {}}
	}
	return $spec
}

proc maprequest_spec {} {
	set spec {
		WindowIncrement {Short {} {} {unsigned} {$val / 1.0}}
		FWToErase {char {} {} {unsigned} {}}
		FWToMap {char {} {} {unsigned} {}}
		FirstError1 {char {} {} {unsigned} {}}
		FirstError2 {char {} {} {unsigned} {}}
		FirstError3 {char {} {} {unsigned} {}}
	}
	return $spec

}

proc calibrate_spec {} {
	set spec {
		WriteKey {Int {} {} {unsigned} {[format %X $val]}}
		CalCommand {char {} {} {unsigned} {}}
		CalTarget {char {} {} {unsigned} {}}
		DE1ReportedVal {Int {} {} {unsigned} {double(round(100*($val / 65536.0)))/100}}
		MeasuredVal {Int {} {} {} {double(round(100*($val / 65536.0)))/100}}
	}
	return $spec
}

proc version_spec {} {
	set spec {
		BLE_APIVersion {char {} {} {unsigned} {}}
		BLE_Release {char {} {} {unsigned} {[convert_F8_1_7_to_float $val]}}
		BLE_Commits {Short {} {} {undsigned} {}}
		BLE_Changes {char {} {} {unsigned} {}}
		BLE_Sha {int {} {} {unsigned} {[format %X $val]}}

		FW_APIVersion {char {} {} {unsigned} {}}
		FW_Release {char {} {} {unsigned} {[convert_F8_1_7_to_float $val]}}
		FW_Commits {Short {} {} {unsigned} {}}
		FW_Changes {char {} {} {unsigned} {}}
		FW_Sha {int {} {} {unsigned} {[format %X $val]}}
	}
	return $spec
}
proc waterlevel_spec {} {
	set spec {
		Level {Short {} {} {unsigned} {$val / 256.0}}
		StartFillLevel {Short {} {} {unsigned} {$val / 256.0}}
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
		msg -DEBUG "$field : $val "
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

proc convert_float_to_S32P16 {in} {
	if {$in > 65536} {
		set in 65536
	}
	return [expr {round($in * 65536.0)}]
}

proc convert_float_to_F8_1_7 {in} {

	if {$in >= 12.75} {
		if {$in > 127} {
			msg -ERROR "Numbers over 127 are not allowed this F8_1_7; limiting at 127"
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

proc parse_shot_flag {num} {

	if {$num == {}} {
		return {}
	}

	set enabled_features {}

	if {[expr {$num & 0x01}] } {
		lappend enabled_features "CtrlF"
	} 

	if {[expr {$num & 0x02}] } {
		lappend enabled_features "DoCompare"
	} 

	if {[expr {$num & 0x04}] } {
		lappend enabled_features "DC_GT"
	} 

	if {[expr {$num & 0x08}] } {
		lappend enabled_features "DC_CompF"
	} 

	if {[expr {$num & 0x10}] } {
		lappend enabled_features "TMixTemp"
	} 

	if {[expr {$num & 0x20}] } {
		lappend enabled_features "Interpolate"
	} 

	if {[expr {$num & 0x40}] } {
		lappend enabled_features "IgnoreLimit"
	}
	return $enabled_features
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
	if {$ShotSample(FrameToWrite) >= 32} {
		set spec [spec_extshotframe]
		array unset specarr *
		array unset ShotSample *
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
}





# C code:
#	struct PACKEDATTR T_ReadFromMMR {
#	  U8P0  Len;       // Length of data to read, in words-1. ie. 0 = 4 bytes, 1 = 8 bytes, 255 = 2014 bytes, etc.
#	  U24P0 Address;   // Address of window. Will autoincrement if set up in MapRequest
#	  U8P0  Data[16];  // If data reaches past the end of a region, bytes will be zero filled
#	};
proc spec_ReadFromMMR {} {
	set spec {
		Len {char {} {} {unsigned} {}}
		Address1 {char {} {} {unsigned} {}}
		Address2 {char {} {} {unsigned} {}}
		Address3 {char {} {} {unsigned} {}}
		Data0 {char {} {} {unsigned} {}}
		Data1 {char {} {} {unsigned} {}}
		Data2 {char {} {} {unsigned} {}}
		Data3 {char {} {} {unsigned} {}}
		Data4 {char {} {} {unsigned} {}}
		Data5 {char {} {} {unsigned} {}}
		Data6 {char {} {} {unsigned} {}}
		Data7 {char {} {} {unsigned} {}}
		Data8 {char {} {} {unsigned} {}}
		Data9 {char {} {} {unsigned} {}}
		Data10 {char {} {} {unsigned} {}}
		Data11 {char {} {} {unsigned} {}}
		Data12 {char {} {} {unsigned} {}}
		Data13 {char {} {} {unsigned} {}}
		Data14 {char {} {} {unsigned} {}}
		Data15 {char {} {} {unsigned} {}}
	}
}

proc spec_ReadFromMMR_int {} {

	set spec {
		Len {char {} {} {unsigned} {}}
		Address1 {char {} {} {unsigned} {}}
		Address2 {char {} {} {unsigned} {}}
		Address3 {char {} {} {unsigned} {}}
		Data0 {int {} {} {unsigned} {}}
		Data1 {int {} {} {unsigned} {}}
		Data2 {int {} {} {unsigned} {}}
		Data3 {int {} {} {unsigned} {}}
	}
}

# C code:
#	struct PACKEDATTR T_WriteToMMR {
#	  U8P0  Len;       // Length of data
#	  U24P0 Address;   // Address within the MMR
#	  U8P0  Data[16];  // Data, zero padded
#	};

proc spec_WriteToMMR {} {
	set spec {
		Len {char {} {} {unsigned} {}}
		Address1 {char {} {} {unsigned} {}}
		Address2 {char {} {} {unsigned} {}}
		Address3 {char {} {} {unsigned} {}}
		Data0 {char {} {} {unsigned} {}}
		Data1 {char {} {} {unsigned} {}}
		Data2 {char {} {} {unsigned} {}}
		Data3 {char {} {} {unsigned} {}}
		Data4 {char {} {} {unsigned} {}}
		Data5 {char {} {} {unsigned} {}}
		Data6 {char {} {} {unsigned} {}}
		Data7 {char {} {} {unsigned} {}}
		Data8 {char {} {} {unsigned} {}}
		Data9 {char {} {} {unsigned} {}}
		Data10 {char {} {} {unsigned} {}}
		Data11 {char {} {} {unsigned} {}}
		Data12 {char {} {} {unsigned} {}}
		Data13 {char {} {} {unsigned} {}}
		Data14 {char {} {} {unsigned} {}}
		Data15 {char {} {} {unsigned} {}}
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

proc spec_extshotframe {} {
	set spec {
		FrameToWrite {char {} {} {unsigned} {$val}}
		MaxFlowOrPressure {char {} {} {unsigned} {$val / 16.0}}
		MaxFoPRange {char {} {} {unsigned} {$val / 16.0}}
		Pad1  {char {} {} {unsigned} {$val}}
		Pad2  {char {} {} {unsigned} {$val}}
		Pad3  {char {} {} {unsigned} {$val}}
		Pad4  {char {} {} {unsigned} {$val}}
		Pad5  {char {} {} {unsigned} {$val}}
	}
	return $spec
}

proc spec_shottail {} {
	# Unused. Use highest bit to enable / disable preinfusion tracking
	#MaxTotalVolume {char {} {} {unsigned} {$val }}
	set spec {
		FrameToWrite {char {} {} {unsigned} {$val}}
		MaxTotalVolume {Short {} {} {unsigned} {[convert_bottom_10_of_U10P0 $val]}}
		Pad1  {char {} {} {unsigned} {$val}}
		Pad2  {char {} {} {unsigned} {$val}}
		Pad3  {char {} {} {unsigned} {$val}}
		Pad4  {char {} {} {unsigned} {$val}}
		Pad5  {char {} {} {unsigned} {$val}}
	}
	return $spec
}

proc make_chunked_packed_shot_sample {hdrarrname framenames extension_framenames tail_framename} {
	upvar $hdrarrname hdrarr

	set packed_header [::fields::pack [spec_shotdescheader] hdrarr]

	set packed_frames {}

	foreach framearrname $framenames {
		upvar $framearrname $hdrarrname
		lappend packed_frames [::fields::pack [spec_shotframe] $hdrarrname]
	}

	foreach framearrname $extension_framenames {
		upvar $framearrname $hdrarrname
		lappend packed_frames [::fields::pack [spec_extshotframe] $hdrarrname]
	}

	upvar $tail_framename tailarr
	lappend packed_frames [::fields::pack [spec_shottail] tailarr]

	return [list $packed_header $packed_frames]
}



proc de1_packed_shot {shot_list} {

	set hdr(HeaderV) 1
	set hdr(MinimumPressure) 0
	set hdr(MaximumFlow) [convert_float_to_U8P4 6]

	set cnt 0

	array set profile $shot_list

	# for now, we are defaulting to IgnoreLimit as our starting flag, because we are not setting constraints of max pressure or max flow
	set frame_names ""
	set extension_frames ""

	set this_profile $profile(advanced_shot)

	if {[ifexists ::settings(insert_preinfusion_pause)] == 1} {

		msg -DEBUG "Prefixing profile with a 2 seconds slow start preinfusion pause"

        set pause [list \
            name [translate "Pause"] \
            temperature $::settings(espresso_temperature) \
            sensor "coffee" \
            pump "flow" \
            transition "fast" \
            pressure 0 \
            flow 0 \
            seconds 2 \
            volume 0 \
            exit_if 0 \
            exit_pressure_over 0 \
            exit_pressure_under 0 \
            exit_flow_over 6 \
            exit_flow_under 0 \
        ]

        set this_profile [concat [list $pause] $this_profile]

	}


	foreach step $this_profile {
		unset -nocomplain props
		array set props $step

		set frame_name "frame_$cnt"
		set extension_frame "ext_frame_$cnt"
		lappend frame_names $frame_name

		set features {IgnoreLimit}

		# flow control
		if {$props(pump) == "flow"} {
			lappend features "CtrlF"
			set SetVal $props(flow)
		} else {
			set SetVal $props(pressure)
		}

		# use boiler water temperature as the goal
		if {$props(sensor) == "water"} {
			lappend features "TMixTemp"
		}

		if {$props(transition) == "smooth"} {
			lappend features "Interpolate"
		}

		# "move on if...."
		if {$props(exit_if) == 1} {
			if {[ifexists props(exit_type)] == "pressure_under"} {
				lappend features "DoCompare"
				set TriggerVal $props(exit_pressure_under)
			} elseif {[ifexists props(exit_type)] == "pressure_over"} {
				lappend features "DoCompare"
				lappend features "DC_GT"
				set TriggerVal $props(exit_pressure_over)
			} elseif {[ifexists props(exit_type)] == "flow_under"} {
				lappend features "DoCompare"
				lappend features "DC_CompF"
				set TriggerVal $props(exit_flow_under)
			} elseif {[ifexists props(exit_type)] == "flow_over"} {
				lappend features "DoCompare"
				lappend features "DC_GT"
				lappend features "DC_CompF"
				set TriggerVal $props(exit_flow_over)
			} else {
				# no exit condition was checked
				set TriggerVal 0
			}
			
		} else {
			set TriggerVal 0
		}

		array set $frame_name [list FrameToWrite $cnt]
		array set $frame_name [list Flag [make_shot_flag $features]]
		array set $frame_name [list SetVal [convert_float_to_U8P4 $SetVal]]
		array set $frame_name [list Temp [convert_float_to_U8P1 $props(temperature)]]
		array set $frame_name [list FrameLen [convert_float_to_F8_1_7 $props(seconds)]]
		array set $frame_name [list TriggerVal [convert_float_to_U8P4 $TriggerVal]]

		# max water volume feature, per-step
		array set $frame_name [list MaxVol [convert_float_to_U10P0 $props(volume)]]

		#Extension Frame
		if {[ifexists props(max_flow_or_pressure)] != 0 && [ifexists props(max_flow_or_pressure)] != {}} {
			array set $extension_frame [list FrameToWrite [expr $cnt + 32]]
			array set $extension_frame [list MaxFlowOrPressure [convert_float_to_U8P4 $props(max_flow_or_pressure)]]
			array set $extension_frame [list MaxFoPRange [convert_float_to_U8P4 $props(max_flow_or_pressure_range)]]
			array set $extension_frame [list Pad1 0]
			array set $extension_frame [list Pad2 0]
			array set $extension_frame [list Pad3 0]
			array set $extension_frame [list Pad4 0]
			array set $extension_frame [list Pad5 0]

			lappend extension_frames $extension_frame
			msg -DEBUG "Settings extension frame for " $cnt [array get $extension_frame]
		}
		incr cnt
	}

	set hdr(NumberOfFrames) $cnt
	
	# advanced shots can define when to start counting pour
	set NumberOfPreinfuseFrames [ifexists profile(final_desired_shot_volume_advanced_count_start)]
	if {$NumberOfPreinfuseFrames == ""} {
		set NumberOfPreinfuseFrames 0
	}

	if {[ifexists ::setting(insert_preinfusion_pause)] == 1} {
		incr NumberOfPreinfuseFrames
	}
	set hdr(NumberOfPreinfuseFrames) $NumberOfPreinfuseFrames

	set tail(FrameToWrite) $cnt
	set tail(MaxTotalVolume) 0
	set tail(Pad1) 0
	set tail(Pad2) 0
	set tail(Pad3) 0
	set tail(Pad4) 0
	set tail(Pad5) 0

	return [make_chunked_packed_shot_sample hdr $frame_names $extension_frames tail]

}


# return two values as a list, with the 1st being the packed header, and the 2nd value itself
# being a list of packed frames
proc de1_packed_shot_wrapper { {override {}} } {

	if {$override == "cool"} {
		# set first frame temperature to 5C 
		array set coolsettings [array get ::settings]
		set coolsettings(espresso_temperature) 1
		set coolsettings(espresso_temperature_0) 1
		return [de1_packed_shot [::profile::pressure_to_advanced_list coolsettings]]
	} else {
		if {[ifexists ::settings(settings_profile_type)] == "settings_2b"} {
			return [de1_packed_shot [::profile::flow_to_advanced_list]]
		} elseif {([ifexists ::settings(settings_profile_type)] == "settings_2c" || [ifexists ::settings(settings_profile_type)] == "settings_2c2")} {
			return [de1_packed_shot [::profile::settings_to_advanced_list]]
		} else {
			return [de1_packed_shot [::profile::pressure_to_advanced_list]]
		}
	}
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

proc parse_firmware_file_header {packed destarrname} {
	upvar $destarrname Version
	unset -nocomplain Version

	set spec [firmware_file_spec]
	array set specarr $spec

   	::fields::unpack $packed $spec Version littleeendian
	foreach {field val} [array get Version] {
		set specparts $specarr($field)
		set extra [lindex $specparts 4]
		if {$extra != ""} {
			set Version($field) [expr $extra]
		}
	}
}

proc parse_map_request {packed destarrname} {
	upvar $destarrname Version
	unset -nocomplain Version

	set spec [maprequest_spec]
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


proc parse_binary_water_level {packed destarrname} {
	upvar $destarrname Waterlevel
	unset -nocomplain Waterlevel

	set spec [waterlevel_spec]
	array set specarr $spec

   	::fields::unpack $packed $spec Waterlevel bigeendian
	foreach {field val} [array get Waterlevel] {
		set specparts $specarr($field)
		set extra [lindex $specparts 4]
		if {$extra != ""} {
			set Waterlevel($field) [expr $extra]
		}
	}
}


proc parse_binary_mmr_read_obs {packed destarrname} {
	upvar $destarrname mmrdata
	unset -nocomplain mmrdata

	set spec [spec_ReadFromMMR]
	array set specarr $spec

   	::fields::unpack $packed $spec mmrdata bigeendian
	foreach {field val} [array get mmrdata] {
		set specparts $specarr($field)
		set extra [lindex $specparts 4]
		if {$extra != ""} {
			set mmrdata($field) [expr $extra]
		}
	}

	set mmrdata(Address) "[format %02X $mmrdata(Address1)][format %02X $mmrdata(Address2)][format %02X $mmrdata(Address3)]"
}

proc parse_binary_mmr_read {packed destarrname} {

	upvar $destarrname mmrdata
	unset -nocomplain mmrdata

	set spec [spec_ReadFromMMR]
	array set specarr $spec

   	::fields::unpack $packed $spec mmrdata bigeendian
	foreach {field val} [array get mmrdata] {
		set specparts $specarr($field)
		set extra [lindex $specparts 4]
		if {$extra != ""} {
			set mmrdata($field) [expr $extra]
		}
	}

	set mmrdata(Address) "[format %02X $mmrdata(Address1)][format %02X $mmrdata(Address2)][format %02X $mmrdata(Address3)]"
	unset -nocomplain mmrdata(Address1)
	unset -nocomplain mmrdata(Address2)
	unset -nocomplain mmrdata(Address3)

}
proc parse_binary_mmr_read_int {packed destarrname} {
	upvar $destarrname mmrdata
	unset -nocomplain mmrdata

	set spec [spec_ReadFromMMR_int]
	array set specarr $spec

   	::fields::unpack $packed $spec mmrdata littleeendian
	foreach {field val} [array get mmrdata] {
		set specparts $specarr($field)
		set extra [lindex $specparts 4]
		if {$extra != ""} {
			set mmrdata($field) [expr $extra]
		}
	}

	set mmrdata(Address) "[format %02X $mmrdata(Address1)][format %02X $mmrdata(Address2)][format %02X $mmrdata(Address3)]"
	unset -nocomplain mmrdata(Address1)
	unset -nocomplain mmrdata(Address2)
	unset -nocomplain mmrdata(Address3)

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



proc parse_binary_calibration {packed destarrname} {
	upvar $destarrname ShotSample
	unset -nocomplain ShotSample

	set spec [calibrate_spec]
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
		msg -DEBUG "$field : $val "
	}

}


proc convert_3_char_to_U24P16 {char1 char2 char3} {
	return [expr {$char1 + ($char2 / 256.0) + ($char3 / 65536.0) }]
}

proc convert_3_char_to_U24P0 {char1 char2 char3} {
	return [expr {($char1 * 65536) + ($char2 * 256) + $char3}]
}

proc convert_4_char_to_U32P0 {char0 char1 char2 char3} {
	return [expr {($char0 * 16777216) + ($char1 * 65536) + ($char2 * 256) + $char3}]
}



# System to plug-in handlers for state (not substate) changes.

proc register_state_change_handler {old_state_name new_state_name handler} {

	msg -WARNING "DEPRECATED, see package de1_event: register_state_change_handler $old_state_name $new_state_name $handler"
  # Registers a state change handler for a specific state-to-state transition.
  #
  # Args:
  #   old_state_name: name for the "from" state. Names are from ::de1_num_state
  #   new_state_name: name for the "to" state.
  #   handler: callback that handles state transition.
  #     When invoked, old_state_name and new_state_name are added as arguments.

	set lstr [format {lambda {event_dict} {
		set ps [dict get $event_dict previous_state] ; set ts [dict get $event_dict this_state]
		if { $ps == "%s" && $ts == "%s" } {%s $ps $ts}}} \
			  $old_state_name $new_state_name $handler]

	msg -INFO "Rewritten as \[$lstr\]"

	::de1::event::listener::on_major_state_change_add [{*}$lstr]
}


proc parse_decent_scale_recv {packed destarrname} {
	upvar $destarrname recv
	unset -nocomplain recv

	if {[string length $packed] == 7} {
   		::fields::unpack $packed [decent_scale_generic_read_spec] recv bigeendian
	} elseif {[string length $packed] == 10} {
   		::fields::unpack $packed [decent_scale_generic_read_spec_v12] recv bigeendian
	} else {
		msg -DEBUG "Unexpected data length in Decentscale message: length=[string length $packed]"
		return 
	}


   	if {$recv(command) == 0xCE || $recv(command) == 0xCA} {
   		# weight comes as a short, so use a different parsing format in this case, otherwise just return bytes

   		#unset -nocomplain recv
	   	#::fields::unpack $packed [decent_scale_weight_read_spec] recv bigeendian
	   	set cmd $recv(command)

   		unset -nocomplain recv

		if {[string length $packed] == 7} {
		   	::fields::unpack $packed [decent_scale_weight_read_spec2] recv bigeendian
		} elseif {[string length $packed] == 10} {
		   	::fields::unpack $packed [decent_scale_weight_read_spec_v12] recv bigeendian

		   	# convert timestamp into milliseconds and also store that in the data structure
		   	set timestamp [expr { ($recv(minutes) * 600) + ($recv(seconds) * 10) + $recv(milliseconds) }]
		   	set recv(timestamp) $timestamp
		} else {
			msg -DEBUG "Unexpected data length in Decentscale weight message: length=[string length $packed]"
			return 
		}

	   	set recv(parsed) "weight"
	   	set recv(command) $cmd

	   	#::fields::unpack $packed [decent_scale_generic_read_spec] recv bigeendian
   	} elseif {$recv(command) == 0xAA} {
	   	set recv(parsed) "button"
   		msg -DEBUG "Decentscale BUTTON pressed: [array get recv]"
   	} elseif {$recv(command) == 0x0C} {
   		#unset -nocomplain recv
	   	#::fields::unpack $packed [decent_scale_timing_read_spec] recv bigeendian
	   	#set recv(parsed) "timer"
   		#msg -DEBUG "Decentscale time received: [array get recv]"
   		# feature not implemented in the firmware, removed from spec
	   	set recv(parsed) "unknown"
   		msg -DEBUG "Decentscale unexpected timer data received: [array get recv]"
   	} else {
   		#unset -nocomplain recv
	   	#::fields::unpack $packed [decent_scale_timing_read_spec] recv bigeendian
	   	#set recv(command) "unknown"
	   	set recv(parsed) "unknown"
   		msg -DEBUG "Decentscale unknown data received: [array get recv]"
   	}

}


# TODO: parse_state_change and update_de1_state should be moved to ::de1
#	The large number of unqualified references to globals
#	and contexts in which they are called makes it a lower priority

proc parse_state_change {packed destarrname} {
	upvar $destarrname ShotSample
	unset -nocomplain ShotSample

	set spec {
		state {char {} {} {unsigned} {}}
		substate {char {} {} {unsigned} {}}
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
}


proc update_de1_state {statechar} {

	# TODO: Get event_time from earlier in the processing chain

	set event_time [expr { [clock milliseconds] / 1000.0 }]

	parse_state_change $statechar msg

	# Ignore "empty" state messages
	# https://3.basecamp.com/3671212/buckets/7351439/messages/3239055806#__recording_3248555671

	if {[info exists msg(state)] != 1} {
		msg -NOTICE "update_de1_state: Empty state message received"
		return
	}

	set this_state [ifexists ::de1_num_state([ifexists msg(state)])]
	set this_substate [ifexists ::de1_substate_types([ifexists msg(substate)])]

	set previous_state [ifexists ::de1_num_state($::de1(state))]
	set previous_substate [ifexists ::de1_substate_types($::de1(substate))]

	set event_dict [dict create \
				event_time $event_time \
				this_state $this_state \
				this_substate $this_substate \
				previous_state $previous_state \
				previous_substate $previous_substate \
			       ]

	# Update the global state for any consumers and timers, such as in callbacks
	# Using `trace` on these is bad form as the app may not have caught up yet

	set ::de1(state) $msg(state)
	set ::de1(substate) $msg(substate)

	set this_flow_phase [::de1::state::flow_phase $this_state $this_substate]
	set previous_flow_phase [::de1::state::flow_phase $previous_state $previous_substate]

	if { $this_flow_phase == "during" && $previous_flow_phase != "during" } {

		switch $this_state {

			Espresso {
				start_espresso_timers
			}

			Steam {
				start_timer_steam_pour
			}

			HotWater {
				start_timer_water_pour
			}

			HotWaterRinse {
				start_timer_flush_pour
			}

		}
	}

	if { $this_flow_phase != "during" && $previous_flow_phase == "during" } {

		switch $previous_state {

			Espresso {
				stop_espresso_timers
			}

			Steam {
				stop_timer_steam_pour
			}

			HotWater {
				stop_timer_water_pour
			}

			HotWaterRinse {
				stop_timer_flush_pour
			}
		}
	}

	if {      ( $this_state == "Espresso" && $this_substate == "preinfusion" ) \
	     && ! ( $previous_state == "Espresso" && $previous_substate == "preinfusion" ) } {

		start_timer_espresso_preinfusion

	}

	if {    ! ( $this_state == "Espresso" && $this_substate == "preinfusion" ) \
	     &&   ( $previous_state == "Espresso" && $previous_substate == "preinfusion" ) } {

		stop_timer_espresso_preinfusion

	}

	if {      ( $this_state == "Espresso" && $this_substate == "pouring" ) \
	     && ! ( $previous_state == "Espresso" && $previous_substate == "pouring" ) } {

		start_timer_espresso_pour

	}

	if {    ! ( $this_state == "Espresso" && $this_substate == "pouring" ) \
	     &&   ( $previous_state == "Espresso" && $previous_substate == "pouring" ) } {

		stop_timer_espresso_pour

	}



	#
	# Then start processing
	#



	if { $this_state != $previous_state } {

		###
		### Major state change
		###

		msg -INFO [format "DE1 major state change: %s, %s => %s, %s" \
				   $previous_state $previous_substate \
				   $this_state $this_substate]

		::de1::event::apply::on_all_state_change_callbacks $event_dict
		::de1::event::apply::on_major_state_change_callbacks $event_dict

		switch $this_state {

			Espresso {
				# When starting an espresso we are trying to reconnect to the scale just to be sure.
				# This by far does not saturate the Android 5 tablets
				# but just to be sure it is feature gated

				if { $::settings(reconnect_to_scale_on_espresso_start) \
					     && $::de1(scale_device_handle) == 0 \
					     && $::settings(scale_bluetooth_address) != ""} {

					msg -INFO "try to connect to scale automatically (if it is currently disconnected)"
					ble_connect_to_scale
				}
			}

			Idle {
				if { $previous_state == "Steam" } {
					after 3000 check_if_steam_clogged
					msg -INFO "Scheduled check_if_steam_clogged in 3 seconds"
				}
			}

			Sleep {
				if { $previous_state != "Sleep" } {
					scale_disable_lcd
				}
			}
		}

		if { $previous_state == "Sleep" && $this_state != "Sleep"} {

			# If awakening from sleep, on Group Head Controller machines,
			# this is not on on the tablet, and so we should
			# now try to connect to the scale upon awakening from sleep

			if {$::de1(scale_device_handle) == 0 && $::settings(scale_bluetooth_address) != ""} {
				msg -INFO "Back from sleep, try to connect to scale automatically (if it is currently disconnected)"
				ble_connect_to_scale
			} else {
				scale_enable_lcd
			}
		}




	} elseif { $this_substate != $previous_substate } {

		###
		### Substate change only
		###

		msg -INFO [format "DE1 substate change: %s, %s => %s, %s" \
				   $previous_state $previous_substate \
				   $this_state $this_substate]

		::de1::event::apply::on_all_state_change_callbacks $event_dict

	}

	###
	### Flow change events
	###


	if { $this_flow_phase != $previous_flow_phase } {

		::de1::event::apply::on_flow_change_callbacks $event_dict
	}

	#
	# after_flow_complete will trigger after
	# $::settings(after_flow_complete_delay)
	#     after transition to ending, but not before leaving a flow state
	#     after transition out of a flow state, if not already pending or triggered
	#
	# Cases:
	#
	# Triggers on transition to ending:
	#    timer fires after transition out of flow state -- apply
	#    timer fires before transition out of flow -- wait for transition, then apply
	# Transition directly to non-flow state:
	#    set timer and apply when fires
	#
	# State 0 -- Ready
	# State 1 -- Flow
	# State 2 -- Pending with timer
	# State 3 -- Waiting for Idle
	#
	# State 0:
	#    Enter during-flow state ==> State 1
	# State 1:
	#    Leave during-flow state -- set timer ==> State 2
	# State 2:
	#    Timer fires, in non-flow state -- apply ==> State 0
	#    Timer fires, in flow state -- ignore ==> State 3
	# State 3:
	#    Enter non-flow state -- apply ==> State 0
	#


	# TODO: Keep all this logic in one place (other half is in de1_de1.tcl in 1.34.x)


	if { $this_flow_phase == "during" && $previous_flow_phase != "during" } {

		# => State 1

		# No other actions needed
	}

	if { $this_flow_phase != "during" && $previous_flow_phase == "during" } {

		# State 1 ==> State 2

		if { [::de1::event::apply::after_flow_complete_is_pending] } {

			# Chosing not to cancel existing at this time; valid use cases unclear
			# See notes before ::de1::event::apply::after_flow_complete_cancel_pending

			msg -WARNING "Pending after_flow_complete callbacks. " \
				[format "Second flow started before %g seconds?" \
					 $::settings(after_flow_complete_delay)]
		}


		set ::de1::event::apply::_after_flow_complete_after_id \
			[ after [expr { 1000 *  $::settings(after_flow_complete_delay) }] \
				  [list ::de1::event::apply::_maybe_after_flow_complete_callbacks $event_dict]
			 ]

		set ::de1::event::apply::_after_flow_complete_holding_for_idle True

		msg -DEBUG "after_flow_complete: Scheduled"

	}

	if { $::de1::event::apply::_after_flow_complete_holding_for_idle \
		     && $::de1::event::apply::_after_flow_complete_after_id == "" \
		     && $this_flow_phase == "" } {

		# TODO: Decouple this from internal representation

		set ::de1::event::apply::_after_flow_complete_holding_for_idle False

		::de1::event::apply::after_flow_complete_callbacks $event_dict

		msg -DEBUG "after_flow_complete: Applied deferred"
	}




	###
	### This looks wonky, but GUI will freeze if sent on every change
	###

	if {[info exists msg(substate)] == 1} {

		catch {
			skins_page_change_due_to_de1_state_change $this_state
		}
	}
}


proc convert_string_to_decimal {chrs} {
	binary scan [encoding convertto ascii $chrs] c* x
	return $x
}


proc convert_string_to_hex {chrs} {
    
    set toreturn {}
    foreach {a b} [split [binary encode hex $chrs] {}] {
    	append toreturn "$a$b "
    }
    return [string toupper [string trim $toreturn]]
}
