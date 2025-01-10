#!/bin/tclsh

if {$argc != 1 } {
    puts "needs mul file"
}

set infilePath [lindex $argv 0]
set infile [open $infilePath r]

set totSum 0

while {[gets $infile line] >= 0} {
    set fsplit [split $line ":"]
    set tvalue [lindex $fsplit 0]
    set coeffList [lindex $fsplit 1]

    #set nmbrOf
    
    if {$tvalue == $coeffSum} {
        []

    }
}
