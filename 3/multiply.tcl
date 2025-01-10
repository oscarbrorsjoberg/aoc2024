#!/bin/tclsh


if {$argc != 1 } {
    puts "needs mul file"
}

set infilePath [lindex $argv 0]

set infile [open $infilePath r]


proc findMuls { str1 } {

    set totmul 0
    set res [ regexp -inline -all {mul\((\d+,\d+)\)} $str1]

    for {set i 1 } {$i < [llength $res] } {incr i 2} {

        set mul [lindex $res $i]
        set ab [split $mul ","]
        set a [lindex $ab 0]
        set b [lindex $ab 1]
        set locmul [expr $a * $b]
        set totmul [expr $totmul + $locmul]
    }

    return $totmul
}

set fileMul 0

set completestr ""

while {[gets $infile line] >= 0} {
    set completestr "$completestr$line"

    set donts [ regexp -indices -inline -all {(don't\(\))} $line ]
    set dos [ regexp -indices -inline -all {(do\(\))} $line ]
    set dontsdo [ regexp -indices -inline -all {(don't\(\).*?do\(\))} $line  ]
}


regsub -all {(don't\(\).*?do\(\))} $completestr "" res
set donts [ regexp -indices -inline -all {(don't\(\).*)} $res ]

if { $donts == 1 } {
    regsub -all {(don't\(\).*)} $completestr "" res
}

set mulRes [ findMuls $res ]

puts $mulRes
