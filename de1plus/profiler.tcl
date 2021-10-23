package provide de1_profiler 1.0
##
	package require profiler
	#catch {::profiler::init}
	::profiler::init

# be sure to call
	::profiler::reset
# immediately before the function you want to profile
#
# and then to obtain useful profiling data, call
# set pd [profilerdata $functionname]
#
# the function name is optional, and if present also returns the runtime for that function
#
# which you can then puts to the screen or to your html page

proc profilerdata { {functionname {}}} {
	puts "printing profiler results\n---"
	#::profiler::print
	#set x [::profiler::sortFunctions totalRuntime]
	
	# change to one of:
	# calls, compileTime, exclusiveRuntime, nonCompileTime, totalRuntime, avgExclusiveRuntime, avgRuntime
	#set x [::profiler::sortFunctions exclusiveRuntime]
	set x [::profiler::sortFunctions totalRuntime]
	
	set y {}
	if {$functionname != ""} {
		set y [::profiler::print $functionname]\n\n
	}
	
	set totalproctime 0
	foreach a $x {
		set proctime [lindex $a 1]
		if {$proctime > 0} {
			set procname [lindex $a 0]
			#append y "$procname $proctime\n"
			set arr($procname)  $proctime
			incr totalproctime $proctime
		}
		
	}
	
	set max_to_display 30
	set cnt 0
	puts "Total: [add_commas_to_number [expr {$totalproctime / 1000}]]ms"
	foreach k [array_keys_decr_sorted_by_number_val arr] {
		if {[incr cnt] > $max_to_display} { append y "---"; break }
		unset -nocomplain m
		array set m [lindex [::profiler::dump $k] 1]
		#puts "parts: [array get m]"
		set more [subst {(calls: $m(callCount) calls, descendanttime: [add_commas_to_number [expr {$m(descendantTime) / 1000}]]ms, avgrun: [add_commas_to_number [expr {$m(averageRuntime) / 1000}]]ms)}]
		#set nondesctime [expr {$m(totalRuntime) - $m(descendantTime)}]
		#puts "$k : $nondesctime"
		append y "[expr { (100 * $arr($k))  / $totalproctime}]% $k [add_commas_to_number [expr {$arr($k)  / 1000}]] $more\n"
	}
	return $y

}