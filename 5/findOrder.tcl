#!/bin/tclsh

# for list intersect
#package require Tclx

set ruleDict [dict create]

proc findRuleBreakers { prod cIncorrIndex } {

    global ruleDict 
    upvar $cIncorrIndex localcIncorrIndex
    set prodP [lrange $prod 1 [llength $prod]]
    set index 0

    foreach page $prodP {

        if {[dict exists $ruleDict $page ] == 0} {
            incr index
            continue
        }

        set ruleList [dict get $ruleDict $page]
        set prelist [lrange $prod 0 $index ]

        set j 0
        foreach prepage $prelist {

            if { [lsearch -exact $ruleList $prepage] >= 0 } {
                set cind [expr $index + 1 ]
                set localcIncorrIndex [list $cind $j ]
                return 0
            }
            incr j
        }
        incr index 
    }

    return 1
}


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


set i 0
set midSum 0

set incorrPages {}
set incorrIndex {}

foreach pages $pageProd {

    set prod [split $pages ","]
    set prodP [lrange $prod 1 [llength $prod]]

    set isOk 1
    set index 0
    set cIncorrIndex {}

    set isOk [findRuleBreakers $prod cIncorrIndex]

    if { [expr $isOk == 1] } {
        set middleIndex [expr [expr [llength $prod] / 2 ]]
        set middleValue [lindex $prod $middleIndex]
        puts $middleValue 
        set midSum [expr $midSum + $middleValue]
    } else {
        lappend incorrIndex $cIncorrIndex
        lappend incorrPages $prod
    }
    incr i
}

puts "midSum $midSum"

puts $incorrPages
puts $incorrIndex

set c 0
set fixedProd {}
foreach prod $incorrPages {
    set ruleBreaker [lindex $incorrIndex $c]
    set hasRuleBreaker [expr [llength $ruleBreaker] > 0 ]

    while { $hasRuleBreaker } {

        set to [lindex $ruleBreaker 0]
        set from [lindex $ruleBreaker 1]
        set valA [lindex $prod $to]
        set valB [lindex $prod $from]

        set prod [lreplace $prod $from $from $valA]
        set prod [lreplace $prod $to $to $valB]


        set tRuleBreaker {}
        set hasRuleBreaker [ expr [findRuleBreakers $prod tRuleBreaker] == 0 ]
        set ruleBreaker $tRuleBreaker
    }
    lappend fixedProd $prod
    incr c
}

puts $fixedProd

set secondMidSum 0
foreach p $fixedProd {
        set middleIndex [expr [expr [llength $p] / 2 ]]
        set middleValue [lindex $p $middleIndex]
        set secondMidSum [expr $secondMidSum + $middleValue]
}
puts $secondMidSum


