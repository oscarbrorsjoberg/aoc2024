#!/bin/tclsh

if { $argc != 2 } {
    puts "needs xmas file and word"
}


proc countOcc {pattern lowords} {
    set wCount 0
    set i 0

    foreach el $lowords {
        set hits 0
        set hits [regexp -all $pattern $el match ]
        set wCount [expr $wCount + $hits]
        incr i
    }
    return $wCount
}

set infilePath [lindex $argv 0]
set searchWord [lindex $argv 1]
set revSearchWord [string reverse $searchWord]

set lengthSearchWord [string length $searchWord]

set rows {}

set cols {}
# \
#
set diaga {}
# /
#
set diagb {}

set infile [ open $infilePath r ]

set nmbrOfRows 0

set firstRow [gets $infile]

lappend rows $firstRow


incr nmbrOfRows
set nmbrOfCols [string length $firstRow]

while { [ gets $infile row] >= 0 } {
    lappend rows $row
    incr nmbrOfRows
}

close $infile


set nmbrOfDiag [expr [expr $nmbrOfCols + $nmbrOfRows] - 3]

# get cols
for {set j 0} {$j < $nmbrOfCols} {incr j} {
    set currstr ""
    for {set i 0} {$i < $nmbrOfRows} {incr i} {

        set crow [lindex $rows $i]
        set clett [string index $crow $j]
        set currstr [string cat $currstr $clett]

    }
    lappend cols $currstr 
}


for {set p [expr $lengthSearchWord - 1 ]  } { $p <= $nmbrOfDiag } {incr p} {

    set nmbrOfIter 0
    
    set startRow 0
    set endRow 0

    set startCol 0
    set endCol 0

    if {$p >= $nmbrOfRows  } {
        set startRow [expr $nmbrOfRows - 1]
        set endRow [expr abs([expr [expr $nmbrOfRows - 1] - $p])]

        set startCol [expr abs([expr [expr $nmbrOfCols - 1] - $p])] 
        set endCol [expr $nmbrOfCols - 1]

        set numberOfIter [expr $nmbrOfCols - [ expr $p % $nmbrOfCols ]] 
    } else {

        set startRow $p
        set endRow 0
        set startCol 0
        set endCol $p
        set numberOfIter [expr $p + 1]
    }

    set r $startRow
    set c $startCol
    
    set currString ""

    set i 0
    while { [expr $i < $numberOfIter] } {
        set crow [ lindex $rows $r ]
        set cletter [ string index $crow $c]
        set currString [ string cat $currString $cletter ]

        incr r -1
        incr c
        incr i
    }
    lappend diaga $currString
}


set timesInLoop [ expr $nmbrOfDiag + 1 ] 

for {set l [expr $lengthSearchWord  ]} { $l <= $timesInLoop } {incr l } {

    set nmbrOfIter 0
    
    set startRow 0
    set endRow 0

    set startCol 0
    set endCol 0

    if {$l > $nmbrOfRows  } {
        set startRow [expr abs([expr [expr $nmbrOfRows ] - $l])]
        set endRow [expr $nmbrOfRows - 1]

        set startCol 0
        set endCol [expr abs([expr [expr $nmbrOfRows - 1] - $l])]

        set numberOfIter [expr $nmbrOfCols - [ expr $l % $nmbrOfCols ]] 
    } else {

        set startRow 0
        set endRow $l
        set startCol [expr $nmbrOfCols - $l]
        set endCol $nmbrOfCols 
        set numberOfIter [expr $l + 1]
    }

    #puts "srow $startRow"
    #puts "erow $endRow"
    #puts "scol $startCol"
    #puts "ecol $endCol"
    #puts "i $numberOfIter"
    #
    set r $startRow
    set c $startCol
    
    set currString ""

    set i 0
    while { [expr $i < $numberOfIter] } {

        #puts "r $r"
        #puts "c $c"
        #puts "i $i"
        #
        set crow [ lindex $rows $r ]
        set cletter [ string index $crow $c]
        set currString [ string cat $currString $cletter ]
        incr r
        incr c
        incr i
    }

    lappend diagb $currString
}

set pattern "$searchWord" 
set revpattern "$revSearchWord" 

set allElements {}
lappend allElements $rows
lappend allElements $cols
lappend allElements $diaga
lappend allElements $diagb


set amount 0

foreach el $allElements {
    set amount [expr $amount + [countOcc $pattern $el]]
    set amount [expr $amount + [countOcc $revpattern $el]]
}

puts "xmas found: $amount"

# part 2 find mass'es
#

proc countMnS {letter} {
    switch $letter {
        "M" {return 1}
        "S" {return -1}
        "X" {return -20}
        "A" {return -20}
        default { 
            puts "This shouldn't happen!"
            return -1249
        }
    }
}

set massesFound 0

for {set i 1} {$i < [expr $nmbrOfRows - 1]} {incr i} {
    set crow [lindex $rows $i]

    set prow [lindex $rows [expr $i - 1]]
    set nrow [lindex $rows [expr $i + 1]]

    for {set j 1} {$j < [expr $nmbrOfCols - 1]} {incr j} {

        set cletter [string index $crow $j]


        if {$cletter == "A"} {

            #puts "letter is A"
            #puts "at \[$i $j\]"
            #
            set alpha [string index $prow [expr $j - 1]]
            set beta [string index $prow [expr $j + 1]]
            set gamma [string index $nrow [expr $j - 1]]
            set eta [string index $nrow [expr $j + 1]]

            #puts $alpha
            #puts $beta 
            #puts $gamma
            #puts $eta 
            ##
            ## diag equal
            if {$alpha == $eta} {
                continue
            }
            #
            set equilib 0
            set equilib [expr $equilib + [countMnS $alpha]]
            set equilib [expr $equilib + [countMnS $beta]]
            set equilib [expr $equilib + [countMnS $gamma]]
            set equilib [expr $equilib + [countMnS $eta]]

            
            if {$equilib == 0} {
                #puts "found mas at $i $j"
                incr massesFound
            }
        }
  }
}

puts "tot masses found $massesFound"


#puts rows
#puts $cols
#puts $diaga
#puts $diagb
#
#
#
#

