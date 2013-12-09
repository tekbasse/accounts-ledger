ad_library {
    library of reporting procedures
    @creation-date 2013-12-09


}

ad_proc qal_pretty_bytes_iec {
    Returns a pretty number with IEC units in n digits, where first 3 are assumed to be integer.
} {
    number
    {decimals "3"}
} {
    # http://en.wikipedia.org/wiki/Orders_of_magnitude_%28data%29
    set abbrev_list [list B KiB MiB GiB TiB PiB EiB ZiB YiB]
#    set units_list \[list bytes kibibyte mebibyte gibibyte tebibyte pebibyte exbibyte zebibyte yobibyte\]
    set base_nbr 1
    set base_exp 0
    foreach abbrev $abbrev_list {
        if { $number > $base } {
            set base [expr { $base * 1024 } ]
            set unit $abbrev
        }
    }
    set base_bytes [expr { $number / ( $base * 1. ) } ]
    if { $decimals > 3 } {
        set extra_decimals [expr { $decimals - 3 } ]
        set bytes [format "%3.${extra_decimals}f" $base_bytes]
    } else {
        set bytes [format "%3d" [expr { round ( $base_bytes ) } ]]
    }
    set pretty_bytes "$bytes $unit"
    return $pretty_bytes
}
 
ad_proc qal_pretty_bytes_dec {
    Returns a pretty Metric number with byte units in n sigificant digits.
} {
    number
    significant_digits
} {
    number
    {decimals "3"}
} {
    set abbrev_list [list B kB MB GB TB PB EB ZB YB]
#    set units_list \[list bytes kilobyte megabyte gigabyte terabyte petabyte exabyte zettabyte yottabyte\]
    set base_nbr 1
    set base_exp 0
    foreach abbrev $abbrev_list {
        if { $number > $base } {
            set base [expr { $base * 1000 } ]
            set unit $abbrev
        }
    }
    set base_bytes [expr { $number / ( $base * 1. ) } ]
    if { $decimals > 3 } {
        set extra_decimals [expr { $decimals - 3 } ]
        set bytes [format "%3.${extra_decimals}f" $base_bytes]
    } else {
        set bytes [format "%3d" [expr { round ( $base_bytes ) } ]]
    }
    set pretty_bytes "$bytes $unit"
    return $pretty_bytes
}

