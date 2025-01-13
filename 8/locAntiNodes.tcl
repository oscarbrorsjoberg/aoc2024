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
proc setAntiNode { ant0 ant1 sc} {
    #puts $ant0
    #puts $ant1
    set disX [expr [lindex $ant1 0] - [lindex $ant0 0]]
    set disY [expr [lindex $ant1 1] - [lindex $ant0 1]]

    set antiPosX [expr [lindex $ant1 0] + [expr $sc * $disX]]
    set antiPosY [expr [lindex $ant1 1] + [expr $sc * $disY]]

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


proc evalAntiNode {} {



}

if {$argc != 1} {
    puts "Needs input data"
    return
}

set file [open [lindex $argv 0 ] r]
set data [read $file]
close $file
#puts $data

set map [split $data "\n"]
set map [lrange $map 0 [expr [llength $map] - 2]]

set xMax [string length [lindex $map 0 ]]
set yMax [llength $map]

set boundX [expr $xMax - 1]
set boundY [expr $yMax - 1]

set antennas [regexp -inline -all {[^\.\n]} $data ]

#debug
#set antinodes [regexp -inline -all -indices {[#]} $data ]
#set ind 0
#foreach antinode $antinodes {
#    set nodeLoc [lindex $antinode 0]
#
#    set posX 0
#    set posY 0
#
#    toVec $nodeLoc posX posY
#
#    puts "$ind pos: $posX $posY"
#    incr ind
#
#}

set prev "."
set antennas [lsort $antennas]
set uniqueAntennas [lmap x $antennas {expr {
    [checkPrev prev $x] ? $x : [ continue ]
}}]


#set nrNotSingleAntennas 0
#foreach uni $uniqueAntennas {
#    set amountOfAnt [llength [lsearch -all $antennas $uni]]
#    if { $amountOfAnt > 1 } {
#        set nrNotSingleAntennas [expr $nrNotSingleAntennas + $amountOfAnt]
#    }
#}

#puts "antennas"
#puts $antennas
#puts "unique"
#puts $uniqueAntennas


set antiNodeList {}

foreach el $uniqueAntennas {
    set form [format "\[%s\]" $el]
    set loc [ regexp -inline -indices -all $form $data ]

    if {[llength $loc] == 1} {
        continue
    }

    for {set i 0} {$i < [llength $loc]} {incr i} {
        set currAnt [lindex [lindex $loc $i] 0 ]
        set antXPos 0
        set antYPos 0

        toVec $currAnt antXPos antYPos

        set cPos [list $antXPos $antYPos]

        set x [lsearch $antiNodeList $cPos]
        if { $x == -1 } {
            lappend antiNodeList $cPos 
        }

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
        
            set inside 1
            set step 1

            while {$inside == 1} {

                set antiNode [setAntiNode $antMap $qAntMap $step]

                set antiX [ lindex $antiNode 0 ]
                set antiY [ lindex $antiNode 1 ]
                if { [expr $antiX > -1 && $antiX <= $boundX ] } { 
                    if { [expr $antiY > -1 && $antiY <= $boundY ] } { 
                        set x [lsearch $antiNodeList $antiNode]

                        if { $x == -1 } {
                            lappend antiNodeList $antiNode 
                            #puts "added $antiNode"
                        }
                        incr step
                    } else {
                        set inside 0
                    } } else {
                    set inside 0
                }
            }

        }
    }

}


puts "Total nr antinodes [llength $antiNodeList]"
