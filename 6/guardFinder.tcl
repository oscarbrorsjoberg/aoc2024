#!/bin/tclsh
#
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

proc drawGuard {xPos yPos dMap} {
    upvar $dMap drawMap

    global yMax
    global guard

    set yC [expr [expr $yMax - 1 ] - $yPos]
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


set boundX [expr $xMax - 1]
set boundY [expr $yMax - 1]

set origDrawMap $drawMap
set origXpos $xpos
set origYpos $ypos


#drawSymbol $xpos $ypos drawMap "X"

set originalStepDir [setStepDir $guard]

set obsRun 0
set loopCounter 0

for {set obsy 0} {$obsy < $yMax} {incr obsy } {
    for {set obsx 0 } {$obsx < $xMax } {incr obsx} {


        set guardOnMap 1
        set drawMap $origDrawMap

        if { [ checkPos $obsx $obsy drawMap] == 1 } {
            continue
        }

        set xpos $origXpos 
        set ypos $origYpos 

        set stepDir $originalStepDir

        drawSymbol $obsx $obsy drawMap "O"

        #puts "\033\[2J"
        #puts "\033\[H"
        #
        #drawDrawMap $drawMap
        #after 80

        set steps 0
        while { $guardOnMap } {

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

            #drawGuard $xpos $ypos drawMap

            set guardOnMap [isGuardOnMap $xpos $ypos $boundX $boundY ]

            #drawSymbol $xpos $ypos drawMap "X"
            #puts "\033\[2J"
            #puts "\033\[H"

            #drawDrawMap $drawMap
            #after 30

            if {[expr $steps > [expr 5 * $precalcStep ] ] } {
                incr loopCounter
                break
            }
        }

        #puts "Guard left the Arena"
        #puts "steps $steps"
        #puts $xpos
        #puts $ypos
        #after 500

        drawSymbol $xpos $ypos drawMap "X"
        incr obsRun
    }
}






set nmbrOfXs [findXs]
puts "Pos: $nmbrOfXs"
puts "Loops $loopCounter"

puts "steps $steps"

