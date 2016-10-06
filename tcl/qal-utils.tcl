ad_library {
    Library for accounts ledger utility procedures
    @creation-date 2016-10-06

}


ad_proc -private qc_keys_by {
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

