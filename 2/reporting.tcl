#!/bin/tclsh

if { $argc != 1 } {
    puts "specifiy input file"
    return 
}

set inputFile [ lindex $argv 0]

set infile [open $inputFile r]

set numberOfLines 0

# returns 1 for true 0 for false
proc setValidResult { inList } {

    set isIncreasing 0
    set wasIncreasing 0

    for { set i 1 } { $i < [llength $inList ] } { incr i } {
        set valA [ lindex $inList [expr $i - 1]]
        set valB [ lindex $inList $i]

        set diff [expr $valB - $valA]

        #puts "diff: $diff"
        #puts "incr: $isIncreasing"
        #puts "was incr: $wasIncreasing"
        #puts "valA: $valA"
        #puts "valB: $valB"
        #
        
        if {$diff > 0} {
            set isIncreasing 1 
        } elseif { $diff  < 0} {
            set isIncreasing 0 
        } else {
            return 0
        }

        # switch increasing
        if { $i > 1 &&
            $wasIncreasing != $isIncreasing
        } then {
            return 0
        }

        # check diff
        if { [ expr abs($diff) ] > 3  } {
            return 0
        }
        
        set wasIncreasing $isIncreasing

    }

    return 1

}

set safeReports 0
while { [gets $infile line] >=  0} {

    set reportResult [ split $line " "]
    set cRep [ setValidResult $reportResult ]
    set safeReports [ expr $safeReports + $cRep ]

    if {$cRep} {
        puts $reportResult
        puts $safeReports
    }

    incr numberOfLines
}

puts "numberOfLines: $numberOfLines"
puts "safeReports: $safeReports"
