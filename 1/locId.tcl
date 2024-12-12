#!/bin/tclsh

set infile [open "./input" r]
set numberLines 0

set totSum 0

set Llist {}
set Rlist {}

while { [gets $infile line] >=  0} {

        set lists [split $line " "]
        puts $lists

        set Llist [concat $Llist [lindex $lists 0 ]]

        set Rlist [concat $Rlist [lindex $lists 1 ]]


        #set sllist [ lsort $llist]
        #set srlist [ lsort $rlist]
        #
        #
        incr numberLines

}

set sLlist [lsort $Llist]
set sRlist [lsort $Rlist]

set listSum 0

for {set i 0} {$i < [ llength $sLlist] } {incr i} {

    set a [lindex $sLlist $i]
    set b [lindex $sRlist $i]

    set diff [expr $a - $b]
    set adiff [expr abs($diff)]
    puts "adiff $adiff"
    set listSum [expr $listSum + $adiff]
    puts "listSum $listSum"
}

puts "list length: [llength $Rlist]"

close $infile
puts "Tot: $totSum"
puts "Number of lines: $numberLines"
puts "listSum: $listSum"
