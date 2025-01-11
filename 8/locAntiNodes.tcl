#!/bin/tclsh


#proc toVec {}
#{
#
#}

if {$argc != 1} {
    puts "Needs input data"
    return
}

set file [open [lindex $argv 0 ] r]
set data [read $file]
close $file

puts $data

set map [split $data "\n"]
set map [lrange $map 0 [expr [llength $map] - 2]]

set xMax [string length [lindex $map 0 ]]
set yMax [llength $map]

set boundX [expr $xMax - 1]
set boundY [expr $yMax - 1]

set antennas [regexp -inline -all {[^\.\n]} $data ]

set prev "."

proc checkPrev {prev curr} {
    upvar $prev locprev
    if {$locprev != $curr} {
        set locprev $curr
        return 1
    }
    return 0
}

set antennas [lsort $antennas]

set uniqueAntennas [lmap x $antennas {expr {
    [checkPrev prev $x] ? $x : [ continue ]
}}]

puts "antennas"
puts $antennas
puts "unique"
puts $uniqueAntennas
