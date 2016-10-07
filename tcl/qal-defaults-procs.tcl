ad_library {
    library that provides defaults for accounts-ledger
    @creation-date 2016-06-28

}

ad_proc qal_contact_defaults {
    arr_name
} {
    Sets defaults for a contact record into array_name 
    if element does not yet exist in array.
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name c_arr
    set nowts [dt_systime -gmt 1]
    set c_list [list instance_id $instance_id \
                   ns_id "" \
                   active_p "0" \
                   name_record "" \
                   time_trashed "" \
                   time_created $nowts]
    set c2_list [list ]
    foreach {key value} $c_list {
        lappend c2_list $key
        if { ![exists_and_not_null c_arr(${key}) ] } {
            set c_arr(${key}) $value
        }
    }
    if { [llength [set_difference_named_v c2_list [qal_contact_keys]]] > 0 } {
        ns_log Warning "qal_contact_defaults: Update this proc. \
It is out of sync with qal_contact_keys"
    }
    return 1
}


ad_proc qal_customer_defaults {
    arr_name
} {
    Sets defaults for a contact record into array_name 
    if element does not yet exist in array.
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name c_arr
    set nowts [dt_systime -gmt 1]
    set c_list [list instance_id $instance_id \
                   ns_id "" \
                   active_p "0" \
                   name_record "" \
                   time_trashed "" \
                   time_created $nowts]
    set c2_list [list ]
    foreach {key value} $c_list {
        lappend c2_list $key
        if { ![exists_and_not_null c_arr(${key}) ] } {
            set c_arr(${key}) $value
        }
    }
    if { [llength [set_difference_named_v c2_list [qal_customer_keys]]] > 0 } {
        ns_log Warning "qal_customer_defaults: Update this proc. \
It is out of sync with qal_customer_keys"
    }
    return 1
}


ad_proc qal_vendor_defaults {
    arr_name
} {
    Sets defaults for a contact record into array_name 
    if element does not yet exist in array.
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name v_arr
    set nowts [dt_systime -gmt 1]
    set v_list [list instance_id $instance_id \
                   ns_id "" \
                   active_p "0" \
                   name_record "" \
                   time_trashed "" \
                   time_created $nowts]
    set v2_list [list ]
    foreach {key value} $v_list {
        lappend v2_list $key
        if { ![exists_and_not_null v_arr(${key}) ] } {
            set v_arr(${key}) $value
        }
    }
    if { [llength [set_difference_named_v v2_list [qal_vendor_keys]]] > 0 } {
        ns_log Warning "qal_vendor_defaults: Update this proc. \
It is out of sync with qal_vendor_keys"
    }
    return 1
}
