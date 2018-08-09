ad_library {
    library that provides defaults for accounts-ledger
    @creation-date 2016-06-28

}



ad_proc -private qal_customer_defaults {
    arr_name
} {
    Sets defaults for a contact record into array_name 
    if element does not yet exist in array.

    @see qal_customer_keys
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name c_arr

    set c_list [list \
                    id "" \
                    instance_id $instance_id \
                    rev_id "" \
                    contact_id "" \
                    discount "" \
                    tax_included "" \
                    credit_limit "" \
                    terms "" \
                    terms_unit "" \
                    annual_value "" \
                    customer_code "" \
                    pricegroup_id "" \
                    created [qf_clock_format [clock seconds]] \
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


ad_proc -private qal_vendor_defaults {
    arr_name
} {
    Sets defaults for a contact record into array_name 
    if element does not yet exist in array.

    @see qal_vendor_keys
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name v_arr

    set v_list [list \
                    id "" \
                    instance_id $instance_id \
                    rev_id "" \
                    contact_id "" \
                    terms "" \
                    terms_unit "" \
                    tax_included "" \
                    vendor_code "" \
                    gifi_accno "" \
                    discount "" \
                    credit_limit "" \
                    pricegroup_id "" \
                    created [qf_clock_format [clock seconds]] \
                    created_by "" \
                    trashed_p "0" \
                    trashed_by "" \
                    trashed_ts "" \
                    area_market "" \
                    purchase_policy "" \
                    return_policy "" \
                    price_guar_policy "" \
                    installation_policy ""]
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


