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

ad_proc -public qal_timestamp_to_contact_tz {
    contact_id
    timestamp_any_tz
    {contact_tz ""}
} {
    Converts a timestamp to contact's local timezone.
} {
    set yyyymmdd_hhmmss_utc [clock format $timestamp_any_tz -gmt true]
    set tz [qal_contact_id_read $contact_id [list timezone user_id]]
    if { $tz eq "" && [qf_is_natural_number $user_id] } {
        set tz [lang::user::timezone $user_id]
    }
    if { $tz eq "" } {
        set tz [lang::system::timezone]
        set begins_ltz [lc_time_utc_to_local_ $begins_yyyymmdd_hhmmss_utc $tz]
    }
}
