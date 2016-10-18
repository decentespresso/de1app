package provide de1_utils 1.0

proc reverse_array {arrname} {
	upvar $arrname arr
	foreach {k v} [array get arr] {
		set newarr($v) $k
	}
	return [array get newarr]
}

proc stacktrace {} {
    set stack "Stack trace:\n"
    for {set i 1} {$i < [info level]} {incr i} {
        set lvl [info level -$i]
        set pname [lindex $lvl 0]
        append stack [string repeat " " $i]$pname
        foreach value [lrange $lvl 1 end] arg [info args $pname] {
            if {$value eq ""} {
                info default $pname $arg value
            }
            append stack " $arg='$value'"
        }
        append stack \n
    }
    return $stack
}