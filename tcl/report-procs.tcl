ad_library {
    library of reporting procedures
    @creation-date 2013-12-09


}

ad_proc qal_pretty_bytes_iec {
    number
    {unit "B"}
    {significand "3"}
} {
    Returns a pretty number with IEC units in n digits, where first 3 are assumed to be integer.
} {

    # http://en.wikipedia.org/wiki/Orders_of_magnitude_%28data%29
    set abbrev_list [list B KiB MiB GiB TiB PiB EiB ZiB YiB]
    # convert to units of one
    set unit_index [lsearch -exact $abbrev_list $unit]
    set number [expr { wide( $number ) } ]
    if { $unit_index > 0 } {
        set number [expr { $number * pow(1000,$unit_index) } ]
        set unit "B"
    }
#    set units_list \[list bytes kibibyte mebibyte gibibyte tebibyte pebibyte exbibyte zebibyte yobibyte\]
    set test_base_nbr 1
    set base_nbr 1
    foreach abbrev $abbrev_list {
        if { $number > $test_base_nbr } {
            set base_nbr $test_base_nbr
            set unit $abbrev
            set test_base_nbr [expr { $test_base_nbr * 1024 } ] 
        } 
    }
    set base_bytes [expr { $number / ( $base_nbr * 1. ) } ]
#    ns_log Notice "qal_pretty_bytes_iec(35): number $number base_nbr $base_nbr base_bytes $base_bytes"
    if { $significand > 3 } {
        set extra_significand [expr { $significand - 3 } ]
        set bytes [format "%3.${extra_significand}f" $base_bytes]
    } else {
        set bytes [format "%3d" [expr { round ( $base_bytes ) } ]]
    }
    set pretty_bytes "$bytes $unit"
    return $pretty_bytes
}
 
ad_proc qal_pretty_bytes_dec {
    number
    {unit "B"}
    {significand "3"}
} {
    Returns a pretty Metric number with byte units in n digits.
} {
    set abbrev_list [list B kB MB GB TB PB EB ZB YB]
    # convert to units of one
    set unit_index [lsearch -exact $abbrev_list $unit]
    set number [expr { wide( $number ) } ]
    if { $unit_index > 0 } {
        set number [expr { $number * pow(1000,$unit_index) } ]
        set unit "B"
    }
#    set units_list \[list bytes kilobyte megabyte gigabyte terabyte petabyte exabyte zettabyte yottabyte\]
    set test_base_nbr 1
    set base_nbr 1
    foreach abbrev $abbrev_list {
        if { $number > $test_base_nbr } {
            set base_nbr $test_base_nbr
            set unit $abbrev
            set test_base_nbr [expr { $test_base_nbr * 1000 } ] 
        } 
    }
    set base_bytes [expr { $number / ( $base_nbr * 1. ) } ]
#    ns_log Notice "qal_pretty_bytes_dec(71): number $number base_nbr $base_nbr base_bytes $base_bytes"
    if { $significand > 3 } {
        set extra_significand [expr { $significand - 3 } ]
        set bytes [format "%3.${extra_significand}f" $base_bytes]
    } else {
        set bytes [format "%3d" [expr { round ( $base_bytes ) } ]]
    }
    set pretty_bytes "$bytes $unit"
    return $pretty_bytes
}

ad_proc qal_pretty_metric {
    number
    {unit ""}
    {significand "1"}
    {ignore_units ""}
} {
    Returns a pretty, compact Metric number with units in up to 3 digit whole numbers. 
} {
    set number_abs [expr { abs( $number ) } ]

    # ref: http://en.wikipedia.org/wiki/Metric_prefix#List_of_SI_prefixes
    # The yy yyy yyyy gglmn and YY YYY YYYY Ggl extensions are nonstandard for SI, but may be useful nevertheless.
    set abbrev_list [list yyyy gglmn yyy yy y z a f p n "&mu;" m c d "" da h k M G T P E Z Y YY YYY Ggl YYYY]
    set prefix_list [list quadyocto googolmin triyocto duoyocto yocto zepto atto femto pico nano micro milli centi deci "" deca hecto kilo mega giga tera peta exa zetta yotta duoyotta triyotta googol quadyotta]
    set ab_pow_list [list -192 -100 -96 -48 -24 -21 -18 -15 -12 -9 -6 -3 -2 -1 0 1 2 3 6 9 12 15 18 21 24 48 96 100 192]
    # sometimes &mu; is replaced with mcg..
    # remove units to ignore
    if { [string length $ignore_units] > 0 } {
        set ignore_list [split $ignore_units ", "]
        foreach i $ignore_list {
            set ii [lsearch -exact $abbrev_list $i]
            if { $ii > -1 } {
                set abbrev_list [lreplace $abbrev_list $ii $ii]
                set ab_pow_list [lreplace $ab_pow_list $ii $ii]
            }
        }
    } 
    # convert number to base of one unit (if unit is other than one).
    set unit_index [lsearch -exact $abbrev_list $unit]
    if { $unit_index > -1 } {
        set number [expr { $number * pow(10,[lindex $ab_pow_list $unit_index]) } ]
        set number_abs [expr { abs( $number ) } ]
        set unit ""
    }
    #    set units_list \[list pico nano micro milli centi deci "" deca hecto kilo mega giga tera \]
    set test_base_nbr 1e-192
    set i 0
    foreach abbrev $abbrev_list {
        if { $number_abs > $test_base_nbr } {
            set base_nbr $test_base_nbr
            set unit $abbrev
            incr i
            set test_base_nbr [expr { pow(10,[lindex $ab_pow_list $i]) } ] 
#            ns_log Notice "testing unit $unit base_nbr $base_nbr test_base_nbr $test_base_nbr i $i"
        } 

    }
    if { [info exists base_nbr] } {
        set base_metric [expr { $number / ( $base_nbr * 1. ) } ]
        if { $significand > 1 } {
            set extra_significand [expr { $significand - 1 } ]
            set metric [format "%+3.${extra_significand}f" $base_metric]
        } else {
            set metric [format "%+3d" [expr { round( $base_metric ) } ]]
        }
        set pretty_metric "${metric} ${unit}"
    } else {
        # out of range
        set pretty_metric [format "%+3.${significand}g" $number]
    }
    return $pretty_metric
}

ad_proc qal_first_nonempty_in_list {
    some_list
} {
    Returns the value of the first nonempty element in list, or an empty string if none found.
} {
    set some_list_len [llength $some_list]
    set i 0
    set some_val [lindex $some_list $i]
    incr i
    while { $i < $some_list_len && $some_val eq "" } {
        set some_val [lindex $some_list $i]
        incr i
    }
    return $some_val
}
