#!/bin/tclsh


if {$argc != 1 } {
    puts "needs mul file"
}

set infilePath [lindex $argv 0]

set infile [open $infilePath r]

set fileMul 0
while {[gets $infile line] >= 0} {
    set res [ regexp -inline -all {mul\((\d+,\d+)\)} $line]

    set totmul 0
    for {set i 1 } {$i < [llength $res] } {incr i 2} {

        set mul [lindex $res $i]
        set ab [split $mul ","]
        set a [lindex $ab 0]
        set b [lindex $ab 1]
        set locmul [expr $a * $b]
        set totmul [expr $totmul + $locmul]
    }

    #puts $totmul
    set fileMul [expr $totmul + $fileMul]

}

puts $fileMul
