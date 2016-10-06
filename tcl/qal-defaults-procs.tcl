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

    return 1
}
