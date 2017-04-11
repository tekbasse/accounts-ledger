ad_library {
    Library for accounts ledger utility procedures
    @creation-date 2016-10-06

}


ad_proc -public qal_keys_by {
    keys_list
    {separator ""}
} {
    if { $separator ne ""} {
        set keys ""
        if { $separator eq ",:" } {
            # for db
            set keys ":"
        }
        append keys [join $keys_list $separator]
    } else {
        set keys $keys_list
    }
    return $keys
}

ad_proc -public qal_contact_tz {
    contact_id
} {
    Retuns the timezone of the contact. 
    If not known, will guess based on primary user_id or system default.
    If timezone exists, will use it instead.
} {
    set tz [qal_contact_id_read $contact_id [list timezone user_id]]
    if { $tz eq "" && [qf_is_natural_number $user_id] } {
        set tz [lang::user::timezone $user_id]
    }
    if { $tz eq "" } {
        set tz [lang::system::timezone]
    }
    return $tz
}

ad_proc -public qal_timestamp_to_tz {
    timestamp_any_tz
    {tz ""}
    {timestamp_format "%Y-%m-%d %H:%M:%S%z"}
} {
    Converts a timestamp to specified timezone. 
    If timezone (tz) is empty string, converts to system's default timezone.
    If timestamp_format is empty string, uses clock scan's default interpretation.
} {
    set ts_s [qf_clock_scan $timestamp_any_tz $timestamp_format]
    if { $tz eq "" } {
        set tz_offset [clock format $ts_s -format "%z"]
    }
    set ts_new_tz [clock format $ts_s -format $timestamp_format]
    return $ts_new_tz
}
