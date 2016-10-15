package provide de1_utils 1.0

proc reverse_array {arrname} {
	upvar $arrname arr
	foreach {k v} [array get arr] {
		set newarr($v) $k
	}
	return [array get newarr]
}