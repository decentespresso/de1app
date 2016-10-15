#!/usr/local/bin/tclsh 

# skin resizer for plus skins

cd /d/admin/code/de1beta/skinsplus/default/2560x1600

set fast 1

proc fast_write_open {fn parms} {
    set f [open $fn $parms]
    fconfigure $f -blocking 0
    fconfigure $f -buffersize 1000000
    return $f
}

proc write_file {filename data} {
    set fn [fast_write_open $filename w]
    puts $fn $data 
    close $fn
    return 1
}

proc read_file {filename} {
    set fn [open $filename]
    set data [read $fn]
    close $fn
    return $data
}

proc regsubex {regex in replace} {
	set escaped [string map {\[ \\[ \] \\] \$ \\$ \\ \\\\} $in]
	regsub -all $regex $escaped $replace result
	set result [subst $result]
	return $result
}

set skinfiles { nothing_on.png espresso_on.png settings_on.png steam_on.png tea_on.png sleep.jpg fill_tank.jpg filling_tank.jpg }
set dirs [list \
    "1280x800" 2 2 \
    "1920x1200" 1.333333 1.333333 \
    "1920x1080" 1.333333 1.4814814815 \
    "1280x720"  2 2.22222 \
    "2560x1440" 1 1.11111 \
]

# convert all the skin PNG files
foreach {dir xdivisor ydivisor} $dirs {
    #puts -nonewline "Making $dir skin $xdivisor / $ydivisor"
    puts -nonewline "Making $dir skin."
    if {$fast == 0} {
        foreach skinfile $skinfiles {
            puts -nonewline "."
            flush stdout
            exec convert $skinfile -resize $dir!  ../$dir/$skinfile &
        }
    }

    set newskin [read_file "skin.tcl"]
    set newskin [regsubex {add_de1_text (".*?") ([0-9]+) ([0-9]+) } $newskin "add_de1_text \\1 \[expr \{\\2/$xdivisor\}\] \[expr \{\\3/$ydivisor\}\] "]
    set newskin [regsubex {add_de1_button (".*?") (.*?) ([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+)\n} $newskin "add_de1_button \\1 \\2 \[expr \{\\3/$xdivisor\}\] \[expr \{\\4/$ydivisor\}\] \[expr \{\\5/$xdivisor\}\] \[expr \{\\6/$ydivisor\}\]\n"]
    set newskin [regsubex {add_de1_variable (".*?") ([0-9]+) ([0-9]+) } $newskin "add_de1_variable \\1 \[expr \{\\2/$xdivisor\}\] \[expr \{\\3/$ydivisor\}\] "]
    
    # this the maximum text width for labels
    #puts "xdivisor: $xdivisor"
    set newskin [regsubex {\-width ([0-9]+)} $newskin "-width \[expr \{\\1/$xdivisor\}\] "]
    write_file "../$dir/skin.tcl" $newskin 
    puts "";

}
