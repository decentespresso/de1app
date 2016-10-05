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
       
       #puts "type: '$ty$s$count'"
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

proc bintest {} {
	set packed "\x15\x09\x4c\x5e\x0d\x5b\x2d"

	#write_binary_file "compare.dat" $packed

   set spec {
       Delta char
       GroupPressure6 {char {} {} {unsigned} {$val / 16.0}}
       GroupFlow {char {} {} {unsigned} {$val / 16.0}}
       MixTemp {short {} {} {unsigned} {$val / 256.0}}
       HeadTemp {short {} {} {unsigned} {$val / 256.0}}
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


	foreach {field val} [array get ShotSample] {
		puts "$field : $val "
	}

}


proc update_de1_shotvalue {packed} {

  if {[string length $packed] < 7} {
    msg "ERROR: short packed message"
    return
  }

  # the timer stores hundreds of a second, so we take the half cycles, divide them by hertz/2 to get seconds, and then multiple that all by 100 to get 100ths of a second, stored as an int
  set spec {
    Timer {short {} {} {unsigned} {int(100 * ($val / ($::de1(hertz) * 2.0)))}}
    GroupPressure {char {} {} {unsigned} {$val / 16.0}}
    GroupFlow {char {} {} {unsigned} {$val / 16.0}}
    MixTemp {short {} {} {unsigned} {$val / 256.0}}
    HeadTemp {short {} {} {unsigned} {$val / 256.0}}
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

  msg "update_de1_shotvalue [array get ShotSample]"


    #msg "de1 internals: [array get ShotSample]"
    set delta 0
  if {[info exists ShotSample(Timer)] == 1} {
    #set ::de1(timer) [expr {$::de1(timer) + $ShotSample(Delta)}]
    set previous_timer $::de1(timer)
    set ::de1(timer) $ShotSample(Timer)
    set delta [expr {$::de1(timer) - $previous_timer}]
    msg "updated timer to $::de1(timer) - delta=$delta"
  }
  if {[info exists ShotSample(HeadTemp)] == 1} {
    set ::de1(temperature) $ShotSample(HeadTemp)
    #msg "updated temp"
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
}


proc update_de1_substate {statechar} {

  set spec {
    value char
  }

  ::fields::unpack $statechar $spec state bigeendian

  if {$state(value) != $::de1(substate)} {
    msg "substate change: [array get state]"
    set ::de1(substate) $state(value)
  }

  #    'NoState'          : 0,  # State is not relevant.
  #    'HeatWaterTank'    : 1,  # Cold water is not hot enough. Heating hot water tank.
  #    'HeatWaterHeater'  : 2,  # Warm up hot water heater for shot.
  #    'StabilizeMixTemp' : 3,  # Stabilize mix temp and get entire water path up to temperature.
  #    'PreInfuse'        : 4,  # Espresso only. Hot Water and Steam will skip this state.
  #    'Pour'             : 5,  # Used in all states.
  #    'Flush'            : 6   # Espresso only.

  if {$state(value) == 0} {
    # when the substate goes to 0 that means the current task is done, so indicate this by going back to the OFF state in the gui
    if {$::de1(current_context) != "off"} {
      #page_display_change $::de1(current_context) "off"
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
    msg "state change: [array get msg]"
    set ::de1(state) $msg(state)
  }

  if {[info exists msg(substate)] == 1} {
    if {$msg(substate) != 0} {
      # substate of zero means no information, discard
      if {$msg(substate) != $::de1(substate)} {
        msg "substate change: [array get msg]"
        set ::de1(substate) $msg(substate)
      }
    }
  }

  set textstate $::de1_num_state($msg(state))

  if {$textstate == "Idle"} {
    # when the state goes to 2 that means the current task is done, and we are back to idle
    page_display_change $::de1(current_context) "off"
  } elseif {$textstate == "Sleep"} {
    # when the state goes to 9 that means the DE1 is asleep, so we should show our screen saver
    page_display_change $::de1(current_context) "saver" 
  } elseif {$textstate == "Steam"} {
    # when the state goes to 9 that means the DE1 is asleep, so we should show our screen saver
    page_display_change $::de1(current_context) "steam" 
  } elseif {$textstate == "Espresso"} {
    # when the state goes to 9 that means the DE1 is asleep, so we should show our screen saver
    page_display_change $::de1(current_context) "espresso" 
  } elseif {$textstate == "HotWater"} {
    # when the state goes to 9 that means the DE1 is asleep, so we should show our screen saver
    page_display_change $::de1(current_context) "water" 
  }
}



#bintest

