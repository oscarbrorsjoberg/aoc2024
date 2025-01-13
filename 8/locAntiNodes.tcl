#!/bin/tclsh


# we're going for regular image coordinates
#

proc toVec { indic posX posY } {
    global xMax
    upvar $posX lPosX
    upvar $posY lPosY

    set lPosX [expr $indic % [expr $xMax + 1]]
    set lPosY [expr $indic / [expr $xMax + 1]]
}

# not
proc setAntiNode { ant0 ant1 } {
    puts $ant0
    puts $ant1
    set disX [expr [lindex $ant1 0] - [lindex $ant0 0]]
    set disY [expr [lindex $ant1 1] - [lindex $ant0 1]]

    set antiPosX [expr [lindex $ant1 0] + $disX]
    set antiPosY [expr [lindex $ant1 1] + $disY]

    return [list $antiPosX $antiPosY ]
}

proc checkPrev {prev curr} {

    upvar $prev locprev
    if {$locprev != $curr} {
        set locprev $curr
        return 1
    }

    return 0
}

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

puts $xMax

set boundX [expr $xMax - 1]
set boundY [expr $yMax - 1]

set antennas [regexp -inline -all {[^\.\n]} $data ]

set prev "."


set antennas [lsort $antennas]

set uniqueAntennas [lmap x $antennas {expr {
    [checkPrev prev $x] ? $x : [ continue ]
}}]

#puts "antennas"
#puts $antennas
#puts "unique"
#puts $uniqueAntennas

set totNrAntiNodes 0
foreach el $uniqueAntennas {
    set form [format "\[%s\]" $el]
    set loc [ regexp -inline -indices -all $form $data ]

    set nrAntiNodes 0

    for {set i 0} {$i < [llength $loc]} {incr i} {
        set currAnt [lindex [lindex $loc $i] 0 ]
        set antXPos 0
        set antYPos 0
        toVec $currAnt antXPos antYPos

        for {set j 0} {$j < [llength $loc]} {incr j} {
            if { $i == $j } {
                continue
            }
            set qAnt [lindex [lindex $loc $j 0]]

            set qAntXPos 0
            set qAntYPos 0
            toVec $qAnt qAntXPos qAntYPos

            set antMap [list $antXPos $antYPos]
            set qAntMap [list $qAntXPos $qAntYPos]


            set antiNode [setAntiNode $antMap $qAntMap ]



            if { [expr [lindex $antiNode 0 ] > -1 && [lindex $antiNode 0 ] < $boundX ] } { 
                puts "antinode in map"
                incr nrAntiNodes
            } else {
                puts "antinode outside map!"
            }
        }
    }

    puts "Total nr antinodes for $el: $nrAntiNodes"
    set totNrAntiNodes [expr $totNrAntiNodes + $nrAntiNodes]
}

puts "Total nr antinodes $totNrAntiNodes"
