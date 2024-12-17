#!/bin/tclsh

if { $argc != 1 } {
    puts "needs xmas file"
}

set infilePath [lindex $argv 0]

set rows {}
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

foreach row $rows   {
    lappend cols ""
}

for {set k 0} {$k < [expr [expr $nmbrOfCols * $nmbrOfRows] - 2]} {incr k} { 
    lappend diaga ""
    lappend diagb ""
}

# get cols
for {set j 0} {$j < $nmbrOfCols} {incr j} {
    set currstr ""
    for {set i 0} {$i < $nmbrOfRows} {incr i} {


        set crow [lindex $rows $i]
        puts $crow
        set clett [string index $crow $j]

        set currstr [string cat $currstr $clett]

}
set cols [linsert $cols $j $currstr ]
}

set nmbrOfDiag [expr [expr $nmbrOfCols * $nmbrOfRows] - 2]

for {set p  } { $p < nmbrOfDiag  } {incr p} {
    expr[%]
}

for {set j 0} {$j < [$nmbrOfCols} {incr j} {
    set currstr ""
    for {set i 0} {$i < $nmbrOfRows} {incr i} {


        set crow [lindex $rows $i]
        puts $crow
        set clett [string index $crow $j]

        set currstr [string cat $currstr $clett]

}
set cols [linsert $cols $j $currstr ]

}
#puts $rows
#puts $cols





