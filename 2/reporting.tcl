#!/bin/tclsh

proc diffValid { diff isIncreasing wasIncreasing first} {
    # pass by reference
    upvar $isIncreasing localIsIncreasing
    upvar $wasIncreasing localWasIncreasing

    if { $diff > 0 } {
        set localIsIncreasing 1 
    } elseif { $diff  < 0 } {
        set localIsIncreasing 0 
    } else {
        return 0
    }

    # switch increasing
    if { $first == 0 &&
        $localWasIncreasing != $localIsIncreasing
    } then {
        return 0
    }

    # check diff
    if { [ expr abs($diff) ] > 3  } {
        return 0
    }

    set localWasIncreasing $localIsIncreasing

    return 1

}

# returns 1 for true 0 for false
#
proc setValidResult { inList } {

    set isIncreasing 0
    set wasIncreasing 0

    set first 1

    for {set i 1 } { $i < [llength $inList] } { incr i } {

        set valC [lindex $inList $i]

        set last 0


        set valB [lindex $inList [expr $i - 1]]
        set diffCB [ expr $valC - $valB ]

        if { [diffValid $diffCB isIncreasing wasIncreasing $first] == 0 } {
            return 0
        }

        set first 0
    }

    return 1
}


if { $argc != 1 } {
    puts "specifiy input file"
    return 
}


set inputFile [ lindex $argv 0]

set infile [open $inputFile r]

set numberOfLines 0

set safeReports 0

puts "$inputFile"

while { [gets $infile line] >=  0} {

    set reportResult [ split $line " "]
    set cRep [ setValidResult $reportResult ]

    if { $cRep == 0 } {
        for {set j 0 } { $j < [llength $reportResult] } {incr j} {
            set tempReportResult [lreplace $reportResult $j $j]
            set cRep [ setValidResult $tempReportResult ]
            if { $cRep == 1} {
                break
            }
        }
    }

    set safeReports [ expr $safeReports + $cRep ]
    incr numberOfLines
}

puts "numberOfLines: $numberOfLines"
puts "safeReports: $safeReports"
