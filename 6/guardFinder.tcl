#!/bin/tclsh
#
set pi2 [expr {-3.1415926/2.0}]

set drawMap {}
set yMax 0
set xMax 0
set guard "F"

set precalcSteps 46
# set precalcSteps 5865

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
proc drawDrawMap {} {
    global drawMap
    foreach row $drawMap {
        puts $row
    }
}

proc drawX {xPos yPos dMap} {

    upvar $dMap drawMap
    global yMax
    set yC [expr $yMax - $yPos]
    set lrow [lindex $drawMap $yC ]
    set rstr [string replace $lrow $xPos $xPos "X"]
    set drawMap [lreplace $drawMap $yC $yC $rstr]
}

proc drawXInString {xPos yPos trimData} {
    upvar $trimData tData
    global xMax

    set sPos [expr [expr $yPos * $xMax] + $xPos]
    set tData [string replace $tData $sPos $sPos "X"]
}

proc drawGuard {xPos yPos dMap} {
    upvar $dMap drawMap

    global yMax
    global guard

    set yC [expr $yMax - $yPos]
    set lrow [lindex $drawMap $yC ]
    set rstr [string replace $lrow $xPos $xPos $guard]
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

proc checkObs {xpos ypos stepDir dMap} {

    upvar $dMap drawMap
    global yMax

    set xd [lindex $stepDir 0]
    set yd [lindex $stepDir 1]
    set nxpos [expr $xpos + $xd ]
    set nypos [expr $ypos + $yd ]

    set yC [expr $yMax - $nypos]
    set lrow [lindex $drawMap $yC ]
    set clett [string index $lrow $nxpos]

    switch $clett {
        "#" {
            return 1
        }
        default {
            return 0
        }

    }

}

proc findXs {} {
    global drawMap

    set xCount 0
    foreach row $drawMap {
        set xCount [expr $xCount + [ regexp -all {X} $row match ]]
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

proc randomGuardWalk {xposStart yposStart stepDir guard } {


    while { $guardOnMap } {

    guardStep xpos ypos $stepDir
    incr steps

    if { [checkObs $xpos $ypos $stepDir] == 1 } {
        rotateRight stepDir
        set guard [setGuard $stepDir]
    }



    drawGuard $xpos $ypos drawMap

    set guardOnMap [isGuardOnMap $xpos $ypos $boundX $boundY ]

    drawX $xpos $ypos drawMap

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

set stepDir [setStepDir $guard]
set sPos [lindex $sPos 0]

set xpos [expr $sPos % $xMax ]
set ypos [expr $yMax - [expr $sPos / $xMax]]

set guardOnMap 1
set boundX [expr $xMax - 1]
set boundY [expr $yMax - 1]


drawX $xpos $ypos drawMap

set steps 0


while { $guardOnMap } {
    #puts "\033\[2J"
    #puts "\033\[H"

    guardStep xpos ypos $stepDir
    incr steps

    if { [checkObs $xpos $ypos $stepDir drawMap] == 1 } {
        rotateRight stepDir
        set guard [setGuard $stepDir]
    }



    drawGuard $xpos $ypos drawMap
    #drawDrawMap
    #after 3

    set guardOnMap [isGuardOnMap $xpos $ypos $boundX $boundY ]

    drawX $xpos $ypos drawMap

}

#puts "\033\[2J"
#puts "\033\[H"

drawX $xpos $ypos drawMap

#drawDrawMap

set nmbrOfXs [findXs]

puts "Guard left the Arena"
puts "Pos: $nmbrOfXs"
puts "steps $steps"

