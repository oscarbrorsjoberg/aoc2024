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

    #puts "curr incr $localIsIncreasing"
    set localWasIncreasing $localIsIncreasing

    return 1

}

# returns 1 for true 0 for false
#
proc setValidResult { inList removed} {

    set isIncreasing 0
    set wasIncreasing 0

    set first 1

    for {set i 1 } { $i < [llength $inList] } { incr i } {

        set valC [lindex $inList $i]

        set last 0


        set valB [lindex $inList [expr $i - 1]]
        set diffCB [ expr $valC - $valB ]

        if { [diffValid $diffCB isIncreasing wasIncreasing $first] == 0 } {

            if { $removed  == 1 } {
                return 0
            }

            set prev [expr $i - 1]
            set nex [expr $i + 1]

            set resprev 0
            set rescurr 0
            set resnext 0

            set totRes 0

            # last
            if { $i == [llength $inList] } {

                set listwprev [lreplace $inList $prev $prev]
                set listwcurr [lreplace $inList $i $i]

                set resprev [setValidResult $listwprev 1]
                set respcurr [setValidResult $listwprev 1]

            } else {
                set listwprev [lreplace $inList $prev $prev]
                set listwcurr [lreplace $inList $i $i]
                set listwnext [lreplace $inList $nex $nex]

                set resprev [setValidResult $listwprev 1]
                set respcurr [setValidResult $listwcurr 1]
                set resnext [setValidResult $listwnext 1]

            }

            puts "resprev $resprev "
            puts "respcurr $respcurr"
            puts "resnext $resnext "

            if { [expr [expr $resprev + $respcurr] + $resnext] > 0 } {
                return 1

            }
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
    set cRep [ setValidResult $reportResult 0 ]
    set safeReports [ expr $safeReports + $cRep ]

    #puts $reportResult
    #puts $safeReports
    #
    if { $cRep == 0 } {
        puts "cRep: $cRep"
        puts "$reportResult"
    }

    incr numberOfLines
}

puts "numberOfLines: $numberOfLines"
puts "safeReports: $safeReports"
