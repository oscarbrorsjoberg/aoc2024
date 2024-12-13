#!/bin/tclsh


proc lcount_sorted {inputList value} {
    # assumes sorted list
    set occurence 0
    set index [lsearch $inputList $value]
    if { $index < 0 } {
        return $occurence
    }
    incr occurence
    set nextValue [ lindex $inputList [expr $index + $occurence]]
    while { $nextValue == $value } {
        incr occurence
        set nextValue [ lindex $inputList [expr $index + $occurence]]
    }
    return $occurence
}

if {$argc != 1 } {
    puts "Select input file"
}

set input_file [lindex $argv 0]

set infile [open $input_file r]
set numberLines 0

set Llist {}
set Rlist {}

while { [gets $infile line] >=  0} {

        set lists [split $line " "]

        set Llist [concat $Llist [lindex $lists 0 ]]
        set Rlist [concat $Rlist [lindex $lists 1 ]]

        incr numberLines
}

close $infile

set sLlist [lsort $Llist]
set sRlist [lsort $Rlist]

set simScore 0

set leftindex 0
set rightindex 0

# task two
while { [llength $sLlist] > $leftindex } {
    set value [lindex $sLlist $leftindex]
    set lOcc [lcount_sorted $sLlist $value]
    set rOcc [lcount_sorted $sRlist $value]
    set leftindex [ expr $leftindex + $lOcc ]

    #puts "value $value"
    #puts "lOcc $lOcc"
    #puts "rOcc $rOcc"
    #puts "leftindex $leftindex"

    set mulA [expr $rOcc * $value]
    set simScore [expr $simScore + [ expr $lOcc * $mulA ]]
    #puts "simScore $simScore"

}

# task one
set listSum 0

for {set i 0} {$i < [ llength $sLlist] } {incr i} {

    set a [lindex $sLlist $i]
    set b [lindex $sRlist $i]

    set diff [expr $a - $b]
    set adiff [expr abs($diff)]
    set listSum [expr $listSum + $adiff]
}



puts "Number of lines: $numberLines"
puts "listSum: $listSum"
puts "simScore fin $simScore"
