package provide de1_metadata 1.0

package require de1_logging 1.0
package require de1_updater 1.1
package require de1_utils 1.1

namespace eval ::metadata {
	namespace export init dictionary add set get fields exists validate
	namespace ensemble create

	# Data Dictionary
	variable dd
	::set dd [dict create]
	
	# Invoking 'init' resets all existing metadata
	proc init { } {
		variable dd		
		metadata dictionary init
		::set dd [dict create]
	}

	# Ensures a new property gets empty slots on each field
	proc _add_property { prop } {
		variable dd
		foreach field [dict keys $dd] {
			dict set dd $field $prop {}
		}
		return {}
	}
	
	namespace eval dictionary  {
		namespace export *
		namespace ensemble create
		
		variable properties
		::set properties [dict create]
		
		proc init {} {
			variable properties
			::set properties [dict create]
		}
		
		proc add { prop {vcmd {}} } {
			variable properties
			if { [dict exists $properties $prop] } {
				msg -WARNING [namespace current] "add: property name '$prop' already exists in the metadata data dictionary, duplicates not allowed"
				return
			}
			::set first_cmd [lindex $$vcmd 0]
			if { [string is wordchar -strict $first_cmd] && [namespace which -command [namespace current]::$first_cmd] ne "" } {
				lset vcmd 0 0 [namespace current]::$first_cmd
			}
			metadata::_add_property $prop
			dict set properties $prop $vcmd
		}

		proc properties { args } {
			variable properties
			return [dict keys $properties {*}$args]
		}

		proc exists { prop } {
			variable properties
			return [dict exists $properties $prop]
		}
		
		proc get {} {
			variable properties
			return $properties
		}
		
		proc validate_length { length } {
			return [expr {$length in {{} list} || [string is integer $length]}]
		}

		proc validate_nonempty_string { text } {
			return [expr {$text ne ""}]
		}

		proc validate_boolean { bool } {
			return [expr {[string is true -strict $bool] || [string is false -strict $bool]}]
		}

		proc validate_category { valid_values category } {
			return [expr {$category in $valid_values}]
		}
		
	}
		
	proc add { field after args } {
		variable dd		
		if { [dict exists $dd $field] } {
			msg -WARNING [namespace current] "add: field name '$field' already exists in the data dictionary, duplicates not allowed"
			return 0
		}		
		if { [llength $args] == 1 && [llength [lindex $args 0]] > 1 } {
			::set args [lindex $args 0]
		}
		array set arr_args $args
		
		::set props {}
		foreach prop [dictionary properties] {
			if { [info exists arr_args($prop)] } {
				lappend props $prop $arr_args($prop)
			} else {
				lappend props $prop {}
			}
		}
		
		if { $after eq "" || [string tolower $after] eq "end" } {
			::set after "end"
		} elseif { $after ne "start" && ![dict exists $dd $after] } {
			msg -WARNING [namespace current] "add: after field '$field' not found in the data dictionary, adding after end"
			set after "end"
		}
		
		if { $after eq "end" } {
			dict set dd $field [dict create {*}$props]
		} else {
			::set new_dd [dict create]
			if { [string tolower $after] eq "start" } {
				dict set new_dd $field [dict create {*}$props]
			}
			foreach key [dict keys $dd] {
				dict set new_dd $key [dict get $dd $key]
				if { $key eq $after } {
					dict set new_dd $field [dict create {*}$props]
				}
			}
			::set dd $new_dd
		}
		return 1
	}

	proc set { field args } {
		variable dd		
		if { ![dict exists $dd $field] } {
			msg -ERROR [namespace current] "set: field name '$field' not found in data dictionary"
			return 0
		}		
		if { [llength $args] == 1 && [llength [lindex $args 0]] > 1 } {
			::set args [lindex $args 0]
		}
		array set arr_args $args
		
		::set result 0
		::set props {}
		foreach prop [array names arr_args] {
			if { [metadata dictionary exists $prop] } {
				dict set dd $field $prop $arr_args($prop)
				::set result 1
			} else {
				msg -ERROR [namespace current] "set: property name '$prop' not found in metadata dictionary"
			}
		}
		
		return $result
	}
		
	# If no properties are specified in 'args', return a Tcl dict with all the properties.
	# If 'args' is given, return a list with the values of the requested properties.
	proc get { field args } {
		variable dd
		if { ![dict exists $dd $field] } {
			msg -WARNING [namespace current] "get: field name '$field' not found in the data dictionary"
			return {}
		} 
		
		::set field_dd [dict get $dd $field]
		if { $args eq "" } {
			return $field_dd
		} else {
			if { [llength $args] == 1 } {
				::set args [lindex $args 0]
			}
			::set alist {}
			foreach fn $args {
				lappend alist [dict get $field_dd $fn]
			}
			return $alist
		}
	}
	
	proc fields { args } {
		variable dd
		::set glob_pattern ""
		if { [llength $args] > 0 && [string range [lindex $args 0] 0 0] ne "-" } {
			::set fields [dict keys $dd [pop args]]
		} else {
			::set fields [dict keys $dd]
		}
		
		for { ::set i 0 } { $i < [llength $args] } { incr i 2 } {
			::set filter_field [lindex $args $i]
			if { [string range $filter_field 0 0] eq "-" } {
				::set filter_field [string range $filter_field 1 end]
			}
			::set filter_values [lindex $args [expr {$i+1}]]
			
			if { [metadata dictionary exists $filter_field] } {
				::set filtered_fields {}
				foreach fn $fields {
					if { [any_in_list {*}[metadata get $fn $filter_field] $filter_values] } {
						lappend filtered_fields $fn
					}
				}
				::set fields $filtered_fields
			} else {
				msg -WARNING [namespace current] "fields: metadata dictionary filter field '$filter_field' not found"
			}
		}
		
		return $fields
	}
	
	proc exists { field } {
		variable dd
		return [dict exists $dd $field]
	}	
	
	proc validate { field value } {
		
	}
}
