ad_library {
    Library for accounts ledger contacts
    @creation-date 2016-06-28

}

ad_proc qal_contact_read {
    contact_id
} {
    Returns a name value list of one contact record.
} {
    upvar 1 instance_id instance_id
    set return_lists [qal_contacts_read [list $contact_id]]
    # list is in order of qal_contact_keys
    set return_val_list [lindex $return_lists 0]
    set return_list [list ]
    if { [llength $return_val_list] > 0 } {
        set keys_list [qal_contact_keys]
        set i 0
        foreach key $keys_list {
            set val [lindex $return_val_list $i]
            lappend return_list $key $val
            incr i
        }
    }
    return $return_list
}

ad_proc qal_contacts_read {
    contact_id_list
} {
    Returns list of lists; Each list is an contact record for each contact_id in contact_id_list as a list of field (key) values.
    
    @param contact_id_list

} {
    upvar 1 instance_id instance_id
    upvar 1 user_id user_id
    set contact_ids_list [hf_list_filter_by_natural_number $contact_id_list]
    set return_lists [list ]
    foreach contact_id $contact_ids_list {
        # Redo this to grab contact_ids_of_user_id and set_intersect?
        # No, because user may still not have permission to read non_assets.
        # Consider re-working if there is a way to combine multiple db calls.
        set read_p [qc_permission_p $user_id $contact_id non_assets read $instance_id]
        if { $read_p } {
            set rows_lists [db_list_of_lists qal_contact_get "select [qal_contact_keys ","] from qal_contact where contact_id=:contact_id and instance_id=:instance_id and trashed_p!='1'" ]
            # should return only 1 row max
            set row_list [lindex $rows_lists 0]
            if { [llength $row_list] > 0 } {
                lappend return_lists $row_list
            }
        } else {
            ns_log Notice "qal_contacts_read.66: read_p '${read_p}' for user_id '${user_id}' instance_id '${instance_id}' contact_id '${contact_id}'"
        }
    }
    return $return_lists
}


ad_proc qal_customer_read {
    customer_id
} {
    Returns a name value list of one customer record.
} {
    upvar 1 instance_id instance_id
    set return_lists [qal_customers_read [list $customer_id]]
    # list is in order of qal_customer_keys
    set return_val_list [lindex $return_lists 0]
    set return_list [list ]
    if { [llength $return_val_list] > 0 } {
        set keys_list [qal_customer_keys]
        set i 0
        foreach key $keys_list {
            set val [lindex $return_val_list $i]
            lappend return_list $key $val
            incr i
        }
    }
    return $return_list
}

ad_proc qal_customers_read {
    customer_id_list
} {
    Returns list of lists; Each list is an customer record for each customer_id in customer_id_list as a list of customer record values.
    
    @param customer_id_list

    @see qal_customer_keys for order of field (key) values
} {
    upvar 1 instance_id instance_id
    upvar 1 user_id user_id
    if { ![info exists user_id] } {
        if { [ns_conn isconnected] } {
            set user_id [ad_conn user_id]
        } else {
            set user_id ""
        }
    }
    set customer_ids_list [hf_list_filter_by_natural_number $customer_id_list]
    set allowed_customer_ids [qal_customer_ids_of_user_id $user_id]
    set intersect_ids [set_intersection $customer_ids_list $allowed_customer_ids]
    set rows_lists [db_list_of_lists qal_customer_get "select [qal_customer_keys ","] from qal_customer where customer_id=:customer_id and instance_id=:instance_id and trashed_p!='1' and customer_id in ([template::util::tcl_to_sql_list $customer_ids_list])" ]
    return $rows_lists
}



ad_proc qal_vendor_read {
    vendor_id
} {
    Returns a name value list of one vendor record.
} {
    upvar 1 instance_id instance_id
    set return_lists [qal_vendors_read [list $vendor_id]]
    # list is in order of qal_vendor_keys
    set return_val_list [lindex $return_lists 0]
    set return_list [list ]
    if { [llength $return_val_list] > 0 } {
        set keys_list [qal_vendor_keys]
        set i 0
        foreach key $keys_list {
            set val [lindex $return_val_list $i]
            lappend return_list $key $val
            incr i
        }
    }
    return $return_list
}

ad_proc qal_vendors_read {
    vendor_id_list
} {
    Returns list of lists; Each list is an vendor record for each vendor_id in vendor_id_list as a list of vendor record values.
    
    @param vendor_id_list

    @see qal_vendor_keys for order of field (key) values
} {
    upvar 1 instance_id instance_id
    upvar 1 user_id user_id
    if { ![info exists user_id] } {
        if { [ns_conn isconnected] } {
            set user_id [ad_conn user_id]
        } else {
            set user_id ""
        }
    }
    set vendor_ids_list [hf_list_filter_by_natural_number $vendor_id_list]
    set allowed_vendor_ids [qal_vendor_ids_of_user_id $user_id]
    set intersect_ids [set_intersection $vendor_ids_list $allowed_vendor_ids]
    set rows_lists [db_list_of_lists qal_vendor_get "select [qal_vendor_keys ","] from qal_vendor where vendor_id=:vendor_id and instance_id=:instance_id and trashed_p!='1' and vendor_id in ([template::util::tcl_to_sql_list $vendor_ids_list])" ]
    return $rows_lists
}

##code qal_contact_address_read addrs_id
##code qal_contact_addresses_read {contact_id_list ""}
