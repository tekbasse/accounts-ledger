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
    if { $unit_index > 0 } {
        set number [expr { wide( $number ) * pow(1000,$unit_index) } ]
        set unit "B"
    }
#    set units_list \[list bytes kibibyte mebibyte gibibyte tebibyte pebibyte exbibyte zebibyte yobibyte\]
    set base_nbr 1
    set base_exp 0
    foreach abbrev $abbrev_list {
        if { $number > $base_nbr } {
            set base_nbr [expr { $base_nbr * 1024 } ]
            set unit $abbrev
        }
    }
    set base_bytes [expr { $number / ( $base_nbr * 1. ) } ]
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
    if { $unit_index > 0 } {
        set number [expr { wide( $number ) * pow(1000,$unit_index) } ]
        set unit "B"
    }
#    set units_list \[list bytes kilobyte megabyte gigabyte terabyte petabyte exabyte zettabyte yottabyte\]
    set base_nbr 1
    set base_exp 0
    foreach abbrev $abbrev_list {
        if { $number > $base_nbr } {
            set base_nbr [expr { $base_nbr * 1000 } ]
            set unit $abbrev
        }
    }
    set base_bytes [expr { $number / ( $base_nbr * 1. ) } ]
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
    {significand "3"}
    {ignore_units ""}
} {
    Returns a pretty, compact Metric number with units in n digits.
} {

       
    set abbrev_list [list y z a f p n "&mu;" m c d "" da h k M G T P E Z Y]
    set ab_pow_list [list -24 -21 -18 -15 -12 -9 -6 -3 -2 -1 0 1 2 3 6 9 12 15 18 21 24]
    # sometimes &mu; is replaced with mcg..
    # remove units to ignore
    if { [string length $ignore_units] > 0 } {
        set ignore_list [split $ignore_units ", "]
        foreach i $ignore_list {
            set ii [lsearch -exact $abbrev_list $i]
            if { $ii > -1 } {
                set abbrev_list [lreplace $abbrev_list $i $i]
                set ab_pow_list [lreplace $ab_pow_list $i $i]
            }
        }
    } 
    # convert to units of one
    set unit_index [lsearch -exact $abbrev_list $unit]
    if { $unit_index > 0 } {
        set number [expr { wide( $number ) * pow(10,[lindex $ab_pow_list $unit_index]) } ]
        set unit ""
    }
    #    set units_list \[list pico nano micro milli centi deci "" deca hecto kilo mega giga tera \]
    set base_nbr 1
    set base_exp 0
    foreach abbrev $abbrev_list {
        if { $number > $base_nbr } {
            set base_nbr [expr { $base_nbr * 1000 } ]
            set unit $abbrev
        }
    }
    set base_metric [expr { $number / ( $base_nbr * 1. ) } ]
    if { $significand > 3 } {
        set extra_significand [expr { $significand - 3 } ]
        set metric [format "%3.${extra_significand}f" $base_metric]
    } else {
        set metric [format "%3d" [expr { round ( $base_metric ) } ]]
    }
    set pretty_metric "$metric $unit"
    return $pretty_metric
}

