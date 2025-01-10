#!/bin/tclsh

proc dec2bin {i lPadding} {
    set res {}

    while {$i > 0} {

        set res [expr $i % 2]$res 
        set i [expr $i / 2]
    }
    if {$res == {}} {set res 0} 

    if {$lPadding > [string length $res]} {
        set toAdd [expr $lPadding - [string length $res]]
        while {$toAdd > 0} {
            set res 0$res 
            incr toAdd -1
        }
    } 
    return $res
}

proc dec2trin {i lPadding} {
    set res {}

    while {$i > 0} {

        set res [expr $i % 3]$res 
        set i [expr $i / 3]
    }
    if {$res == {}} {set res 0} 

    if {$lPadding > [string length $res]} {
        set toAdd [expr $lPadding - [string length $res]]
        while {$toAdd > 0} {
            set res 0$res 
            incr toAdd -1
        }
    } 
    return $res
}


if {$argc != 1 } {
    puts "needs mul file"
}

set infilePath [lindex $argv 0]
set infile [open $infilePath r]

set totSum 0


set el -1
while {[gets $infile line] >= 0} {
    incr el
    
    set fsplit [split $line ":"]
    set tvalue [lindex $fsplit 0]
    set coeffList [lindex $fsplit 1]
    set coeffList [split $coeffList " "]
    set coeffList [lrange $coeffList 1 [llength $coeffList]]

    set clength [llength $coeffList]

    set nmbrOfOpp [expr $clength - 1]

    #set startBin [expr [expr 2 ** $nmbrOfOpp ] - 1]
    set startBin [expr [expr 3 ** $nmbrOfOpp ] - 1]
    set toForm [format "0%sb" $nmbrOfOpp]
    set toForm %$toForm

    for {set i $startBin} {$i >= 0} {incr i -1} {

        #set binPerm [dec2bin $i $nmbrOfOpp]
        set binPerm [dec2trin $i $nmbrOfOpp]
        #set binPerm [format $toForm $i]

        set totExp [lindex $coeffList 0]

        for {set j 0 } {$j < [string length $binPerm]} {incr j} {
            set t [string index $binPerm $j]
            set currCoeff [expr $j + 1 ]
            switch $t {
                "0" {
                    set totExp [expr $totExp + [ lindex $coeffList $currCoeff]]
                }
                "1" {
                    set totExp [expr $totExp * [ lindex $coeffList $currCoeff]]
                }
                "2" {
                    set concValue [ lindex $coeffList $currCoeff ]
                    set totExp $totExp$concValue
                }
                default {
                    puts "hic sunt dracs"

                }

            }
        }


        if {$totExp == $tvalue} {
            set totSum [expr $totSum + $tvalue]
            break
        }
    }
}
puts $totSum
