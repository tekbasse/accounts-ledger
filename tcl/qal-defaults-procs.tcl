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
    set c_list [list \
                    id "" \
                    rev_id "" \
                    instance_id $instance_id \
                    parent_id "" \
                    label "" \
                    name "" \
                    street_addrs_id "" \
                    mailing_addrs_id "" \
                    billing_addrs_id "" \
                    vendor_id "" \
                    customer_id "" \
                    taxnumber "" \
                    sic_code "" \
                    iban "" \
                    bic "" \
                    language_code "" \
                    currency "" \
                    timezone "" \
                    time_start "" \
                    time_end "" \
                    url "" \
                    user_id "" \
                    created $nowts \
                    created_by "" \
                    trashed_p "0" \
                    trashed_by "" \
                    trashed_ts "" \
                    notes "" ]
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

ad_proc qal_contact_user_map_defaults {
    arr_name
} {
    Sets defaults for a contact record into array_name 
    if element does not yet exist in array.
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name c_arr
    set nowts [dt_systime -gmt 1]
    set c_list [list \
                    instance_id $instance_id \
                    contact_id "" \
                    user_id "" \
                    created $nowts \
                    created_by "" \
                    trashed_p "0" \
                    trashed_by "" \
                    trashed_ts "" ]
    set c2_list [list ]
    foreach {key value} $c_list {
        lappend c2_list $key
        if { ![exists_and_not_null c_arr(${key}) ] } {
            set c_arr(${key}) $value
        }
    }
    if { [llength [set_difference_named_v c2_list [qal_contact_user_map_keys]]] > 0 } {
        ns_log Warning "qal_contact_user_map_defaults: Update this proc. \
It is out of sync with qal_contact_user_map_keys"
    }
    return 1
}


ad_proc qal_other_address_map_defaults {
    arr_name
} {
    Sets defaults for a contact record into array_name 
    if element does not yet exist in array.
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name c_arr
    set nowts [dt_systime -gmt 1]
    set c_list [list \
                    instance_id $instance_id \
                    contact_id "" \
                    addrs_id "" \
                    record_type "" \

                    created $nowts \
                    created_by "" \
                    trashed_p "0" \
                    trashed_by "" \
                    trashed_ts "" ]
    set c2_list [list ]
    foreach {key value} $c_list {
        lappend c2_list $key
        if { ![exists_and_not_null c_arr(${key}) ] } {
            set c_arr(${key}) $value
        }
    }
    if { [llength [set_difference_named_v c2_list [qal_other_address_map_keys]]] > 0 } {
        ns_log Warning "qal_other_address_map_defaults: Update this proc. \
It is out of sync with qal_other_address_map_keys"
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
    set c_list [list \
                    id "" \
                    rev_id "" \
                    instance_id $instance_id \
                    contact_id "" \
                    discount "" \
                    tax_included "" \
                    credit_limit "" \
                    terms "" \
                    terms_unit "" \
                    annual_value "" \
                    customer_number "" \
                    pricegroup_id "" \
                    created $nowts \
                    created_by "" \
                    trashed_p "0" \
                    trashed_by "" \
                    trashed_ts "" ]

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

##code qal_address_defaults
##code qal_other_address_map_defaults
