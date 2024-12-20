#!/bin/tclsh
#

package require Tcl 8.4
package require Thread 2.8

set pi2 [expr {-3.1415926/2.0}]

set drawMap {}
set yMax 0
set xMax 0
set guard "F"

set precalcStep 46
#set precalcStep 5865


proc setStepDir {guard} {
    switch $guard {
       ">" { return [list 1 0 ]}
       "V" { return [list 0 -1 ]}
       "<" { return [list -1 0 ]}
       "^" { return [list 0 1 ]}
       default {
           puts "hic sunt draconis"
           return -1
       }
    }
}

proc setGuard {stepDir} {
    set x [lindex $stepDir 0]
    switch $x {
       "1" { return ">"}
       "-1" { return "<"}
       "0" { 
            set y [lindex $stepDir 1]
            switch $y {
            "1" { return "^"}
            "-1" { return "V"}
            default {
                puts "Y hic sunt draconis"
                return -1
            }
            }

           return }
       default {
           puts "X hic sunt draconis"
           return -1
       }
    }
}


# x -> y ^
proc rotateRight { stepDir } {
    global pi2
    upvar $stepDir localStepDir
    set x [ lindex $localStepDir 0 ]
    set y [ lindex $localStepDir 1 ]

    set xca [expr $x * [expr {cos($pi2)}]]
    set yca [expr $y * [expr {sin($pi2)}]]

    set xcb [expr $x * [expr {sin($pi2)}]]
    set ycb [expr $y * [expr {cos($pi2)}]]

    set newX [expr round([ expr $xca - $yca ])]
    set newY [expr round([ expr $xcb + $ycb ])]

    set localStepDir [lreplace $localStepDir 0 0 $newX]
    set localStepDir [lreplace $localStepDir 1 1 $newY]
}

proc drawDrawMap { dMap } {
    foreach row $dMap {
        puts $row
    }
}

proc drawSymbol {xPos yPos dMap symbol} {
    upvar $dMap drawMap

    global yMax
    set yC [expr [expr $yMax - 1 ] - $yPos]
    set lrow [lindex $drawMap $yC ]
    set rstr [string replace $lrow $xPos $xPos $symbol]
    set drawMap [lreplace $drawMap $yC $yC $rstr]
}


proc guardStep {xpos ypos stepDir } {
    upvar $xpos lxpos
    upvar $ypos lypos
    set xd [lindex $stepDir 0]
    set yd [lindex $stepDir 1]
    set lxpos [expr $lxpos + $xd ]
    set lypos [expr $lypos + $yd ]
}


proc checkPos {xpos ypos dMap } {
    upvar $dMap drawMap
    global yMax

    set yC [expr [expr $yMax - 1] - $ypos]
    set lrow [lindex $drawMap $yC ]
    set clett [string index $lrow $xpos]

    switch $clett {
        "#" {
            return 1
        }
        "^" {
            return 1
        }
        default {
            return 0
        }

    }

}


proc checkObs {xpos ypos stepDir dMap} {

    upvar $dMap drawMap
    global yMax

    set xd [lindex $stepDir 0]
    set yd [lindex $stepDir 1]
    set nxpos [expr $xpos + $xd ]
    set nypos [expr $ypos + $yd ]

    set yC [expr [ expr $yMax - 1 ] - $nypos]
    set lrow [lindex $drawMap $yC ]
    set clett [string index $lrow $nxpos]

    switch $clett {
        "#" {
            return 1
        }
        "O" {
            return 1
        }
        default {
            return 0
        }

    }

}

proc findXs {dmap xlocs} {
    upvar $dmap drawMap
    upvar $xlocs lxlocs
    global yMax

    set xCount 0
    set i [ expr $yMax - 1 ]
    foreach row $drawMap {
        set sind [ regexp -inline -indices -all  {X} $row ]
        set c [llength $sind]

        foreach xs $sind {
            set lxlocs [lappend lxlocs [list [ lindex $xs 0 ] $i  ]]

        }


        set xCount [expr $xCount + $c ]
        incr i -1
    }

    return $xCount
}
    


proc isGuardOnMap {xpos ypos maxX maxY} {
    if { [ expr $xpos < 0 ] || [ expr $xpos > $maxX ] } {
        return 0
    }

    if { [ expr $ypos < 0 ] || [ expr $ypos > $maxY ] } {
        return 0
    }
    return 1
}


proc guardPatrol { dMap xpos ypos stepDir lc countingLoop} {

        global xMax
        global yMax
        global precalcStep
        set guard "^"
        upvar $dMap drawMap

        upvar $lc loopCounter

        set boundX [expr $xMax - 1]
        set boundY [expr $yMax - 1]

        set guardOnMap 1
        set steps 0
        while { $guardOnMap } {

            drawSymbol $xpos $ypos drawMap "X"
            guardStep xpos ypos $stepDir
            incr steps

            set rightTurns 0
            while { [checkObs $xpos $ypos $stepDir drawMap] == 1 } {
                rotateRight stepDir
                set guard [setGuard $stepDir]
                incr rightTurns 
                if { [expr $rightTurns > 3 ] } {
                    puts "WEVE DONE A 360"
                    exit
                }
            }

            #drawSymbol $xpos $ypos drawMap $guard
            #
            #puts "\033\[2J"
            #puts "\033\[H"
            #
            #drawDrawMap $drawMap
            #after 80

            set guardOnMap [isGuardOnMap $xpos $ypos $boundX $boundY ]

            if { $countingLoop } {

                if {[expr $steps > [expr 5 * $precalcStep ] ] } {
                    incr loopCounter
                    break
                }

            }
        }
}


proc process_range {start end } {

    global origDrawMap
    global origXpos
    global origYpos
    global originalStepDir
    global xLocs

    set loopCounter 0

    for {set i $start} { $i < $end} {incr i} {
        set loc [lindex $xLocs $i]

        set dMap $origDrawMap

        set obsx [lindex $loc 0]
        set obsy [lindex $loc 1]

        if { [ checkPos $obsx $obsy dMap] == 1 } {
             continue
         }

         set xpos $origXpos 
         set ypos $origYpos 

         set stepDir $originalStepDir

         drawSymbol $obsx $obsy dMap "O"

         guardPatrol dMap $xpos $ypos $stepDir loopCounter 1

         puts "loopCount $loopCounter"
     }
}


    
if {$argc != 1} {
    puts "need input file"
    return

}

set inputFile [open [lindex $argv 0] r]
set data [read $inputFile ]
close $inputFile

set map [split $data "\n"]
set map [lrange $map 0 [expr [llength $map] - 2]]

set xMax [string length [lindex $map 0 ]]
set yMax [llength $map]

regsub -all {\n} $data "" trimData

set dataLength [ string length $trimData]

set drawMap $map

if { [regexp -all {V|>|<|\^} $data guard] != 1 } {
    puts "wrong number of guards!"
}

if { [regexp -indices {V|>|<|\^} $trimData sPos] != 1 } {
    puts "wrong number of guards!"
}

set sPos [lindex $sPos 0]

set xpos [expr $sPos % $xMax ]
set ypos [expr [expr $yMax - 1 ] - [expr $sPos / $xMax]]


set origDrawMap $drawMap
set origXpos $xpos
set origYpos $ypos

set originalStepDir [setStepDir $guard]

# inital count
set drawMap $origDrawMap

set xpos $origXpos 
set ypos $origYpos 

set stepDir $originalStepDir

set countingLoop 0

guardPatrol drawMap $xpos $ypos $stepDir loopCounter $countingLoop

set xLocs {}

set nmbrOfXs [findXs drawMap xLocs]

puts "number of pos $nmbrOfXs"

#drawDrawMap $drawMap


#set numThreads 4
#set rangeStart 0
#set rangeEnd [llength $xLocs]
#set rangeSize [expr {($rangeEnd - $rangeStart + 1) / $numThreads}]
#
#set threads {}
#
#for {set j 0 } {$j < $numThreads } {incr j } {
#    set start [expr {$rangeStart + $j * $rangeSize}]
#    set end [expr {$start + $rangeSize - 1}]
#    if {$j == [expr {$numThreads - 1 }]} {
#        set end $rangeEnd
#    }
#
#    lappend threads [thread::create { 
#        global start 
#        global end 
#        process_range $start $end
#    }]
#}
#
#foreach t $threads {
#    thread::wait $t
#}

foreach loc $xLocs {

    set dMap $origDrawMap

    set obsx [lindex $loc 0]
    set obsy [lindex $loc 1]

    if { [ checkPos $obsx $obsy dMap] == 1 } {
         continue
     }

     set xpos $origXpos 
     set ypos $origYpos 

     set stepDir $originalStepDir

     drawSymbol $obsx $obsy dMap "O"

     guardPatrol dMap $xpos $ypos $stepDir loopCounter 1

     incr obsRun

}


#
#for {set obsy 0} {$obsy < $yMax} {incr obsy } {
#    for {set obsx 0 } {$obsx < $xMax } {incr obsx} {
#
#
#    }
#}
#

puts "Loops $loopCounter"

