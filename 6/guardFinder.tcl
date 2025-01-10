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


proc getEastRowObs {drawMap lxpos lypos} {
    upvar $drawMap dMap

    global yMax
    global xMax
    set yC [expr [expr $yMax - 1 ] - $lypos]
    set lrow [lindex $dMap $yC ]

    set rstr [string range  $lrow [expr $lxpos + 1] $xMax]

    if { [ string length $rstr ] <= 0 } {
        puts "no string to the right, walked outside"
        return {}
    }
    set obs [string first [# O] $rstr]

    if { [expr $obs > -1 ]} {
        set xpos [expr $lxpos + $obs]
        set ypos [expr [expr $yMax - 1 ] - $yC ]

        return [list $xpos $ypos]
    } else {
        return {}
    }
}

proc getWestRowObs {drawMap lxpos lypos} {
    upvar $drawMap dMap

    global yMax
    global xMax

    set yC [expr [expr $yMax - 1 ] - $lypos]
    set lrow [lindex $dMap $yC ]

    set rstr [string range  $lrow 0 [expr $lxpos - 1] ]
    set rstr [string reverse $rstr]

    if { [ string length $rstr ]  <= 0} {
        puts "no string to the right, walked outside"
        return {}
    }

    set obs [string first [# O] $rstr]
    if { [expr $obs > -1 ]} {
        set xpos [expr $lxpos - $obs]
        set ypos [expr [expr $yMax - 1 ] - $yC ]
        return [list $xpos $ypos]
    } else {
        return false
    }
}

proc getSouthColObs {drawMap lxpos lypos} {
    upvar $drawMap dMap
    global yMax
    global xMax

    set yC [expr [expr [expr $yMax - 1 ] - $lypos] + 1]

    for {set i $yC} {$i <= [ expr $yMax - 1 ] } { incr i} {
        set crow [lindex $dMap $i ]
        set cletter [string index $crow $lxpos]
        switch $cletter {
            "#" {
                    set xpos $lxpos
                    set ypos [expr [expr $yMax - 1 ] - [expr $i - 1] ]
                    return [list $xpos $ypos]
            }
            "O" {
                    set xpos $lxpos
                    set ypos [expr [expr $yMax - 1 ] - [expr $i - 1] ]
                    return [list $xpos $ypos]
            }
            "." {
                continue
            }
            default {
                puts "hic sunt draconis"
            }

        }
    }

    return {}

}

proc getNorthColObs {drawMap lxpos lypos} {
    upvar $drawMap dMap
    global yMax
    global xMax

    set yC [expr [expr [expr $yMax - 1 ] - $lypos] - 1]

    for {set i $yC} {$i >= 0 } { incr i -1} {
        set crow [lindex $dMap $i ]
        set cletter [string index $crow $lxpos]

        switch $cletter {
            "#" {
                    set xpos $lxpos
                    set ypos [expr [expr $yMax - 1 ] - [expr $i + 1] ]
                    return [list $xpos $ypos]
            }
            "O" {
                    set xpos $lxpos
                    set ypos [expr [expr $yMax - 1 ] - [expr $i - 1] ]
                    return [list $xpos $ypos]
            }
            "." {
                continue
            }
            default {
                puts "hic sunt draconis"
            }

        }
    }

    return false

}
proc lookAhead {dMap stepDir xpos ypos} {
    upvar $dMap cdrawMap

    upvar $xpos lxpos 
    upvar $ypos lypos 
    set txpos $lxpos
    set typos $lypos

    set x [lindex $stepDir 0]

    set loaPos {}

    switch $x {
       "1" { 
            set loaPos [getEastRowObs cdrawMap $txpos $typos]
       }
       "-1" { 
            set loaPos [getWestRowObs cdrawMap $txpos $typos]
       }
       "0" { 
           set y [lindex $stepDir 1]
           switch $y {
               "1" {
                   set loaPos [getNorthColObs cdrawMap $txpos $typos]
               }
               "-1" {
                   set loaPos [getSouthColObs cdrawMap $txpos $typos]

               }
               default {
                   puts "Y hic sunt draconis"
                return -1
            }
            }
           }
       default {
           puts "X hic sunt draconis"
           return -1
       }
    }

    if { [llength $loaPos] == 2 } {
        set lxpos [lindex $loaPos 0]
        set lypos [lindex $loaPos 1]
        return 1

    } else {
        return 0
    }

}

proc guardPatrol2 { dMap xpos ypos stepDir lc countingLoop} {

        global precalcStep
        set guard "^"
        set guardOnMap 1

        upvar $lc loopCounter
        upvar $dMap drawMap


        set steps 0
        set i 0

        while { $guardOnMap } {
            #look ahead
            if { [ lookAhead drawMap $stepDir xpos ypos] == 1 } {
                incr i
                rotateRight stepDir

            } else {
                incr i
                puts "outside on step $i"
                set guardOnMap 0

            }
            
        }
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
        set obsCount 0
        while { $guardOnMap } {

            drawSymbol $xpos $ypos drawMap "X"
            guardStep xpos ypos $stepDir
            incr steps

            set rightTurns 0
            while { [checkObs $xpos $ypos $stepDir drawMap] == 1 } {
                incr obsCount
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

            if {  $countingLoop == 1 } {

                if {[expr $steps > [expr 5 * $precalcStep ] ] } {
                    incr loopCounter
                    break
                }

            }
        }

        puts $obsCount
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

set boundX []
set boundY [expr $yMax - 1]

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
set loopCounter 0

#set t2 [time [guardPatrol drawMap $xpos $ypos $stepDir loopCounter $countingLoop] 1000]

set xpos $origXpos 
set ypos $origYpos 
set stepDir $originalStepDir

set t2 [time [guardPatrol2 drawMap $xpos $ypos $stepDir loopCounter $countingLoop] 1000]

puts $t2

set xLocs {}

set nmbrOfXs [findXs drawMap xLocs]

puts "number of pos $nmbrOfXs"

#foreach loc $xLocs {
#
#    set dMap $origDrawMap
#
#    set obsx [lindex $loc 0]
#    set obsy [lindex $loc 1]
#
#    if { [ checkPos $obsx $obsy dMap] == 1 } {
#         continue
#     }
#
#     set xpos $origXpos 
#     set ypos $origYpos 
#
#     set stepDir $originalStepDir
#
#     drawSymbol $obsx $obsy dMap "O"
#
#     guardPatrol dMap $xpos $ypos $stepDir loopCounter 1
#
#     incr obsRun
#
#}

puts "Loops $loopCounter"

