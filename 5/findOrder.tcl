#!/bin/tclsh


if {$argc != 1 } {
    puts "need input file"
}


set inputFile [open [lindex $argv 0] r]


set data [read $inputFile ]
close $inputFile

#puts $data

set prePageRules [regexp -all -inline {(\d\d\|\d\d)} $data ]
puts $prePageRules
set pageProd [lindex [regexp -all -inline {(\d\d,.*$)} $data ] 0]

# getting doubles for some reason

set ruleDict [dict create]

for {set i 0 } {$i < [llength $prePageRules]} {incr i 2} {
    set rule [lindex $prePageRules $i]
    set ab [split $rule "|"]
    set a [lindex $ab 0]
    set b [lindex $ab 1]

    if {[dict exists $ruleDict $a ] == 0} {
        list pagesAfter $b
        dict set ruleDict $a $b

    } else {
        set pAfter [dict get $ruleDict $a]
        lappend pAfter $b
        dict set ruleDict $a $pAfter
    }

}


foreach prod $pageProd {
    set $prodP [lrange $prod 1 [llength $prod]]
    foreach index page $prod {

        set ruleList [dict get $ruleDict $page]

        
        

    }
}


