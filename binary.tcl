package provide binary 1.0

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



#bintest