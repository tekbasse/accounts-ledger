ad_library {
    Library for accounts ledger contacts
    @creation-date 2016-06-28

}

ad_proc qal_contact_id_from_customer_id {
    customer_id
} {
    Returns contact_id of customer_id
} {
    # used in customer-service

}

ad_proc qal_contact_id_read {
    contact_id
    {names ""}
} {
    Returns a record in a name value list. names are fields from table.
} {    # select data from one contact_id, customer_id, or vendor_id
    # if customer_id or vendor_id, also makes available contact_id info
    
    
}

ad_proc qal_contact_ids_of_user_id {
    user_id
} {

} {
    upvar 1 instance_id instance_id
    set contact_id_list ""

    return $contact_id_list
}

ad_proc qal_user_ids_of_contact_id {
    contact_id
    {all_p "1"}
} {
    Returns user_ids of contact_id, if all_p is "0", just returns primary (default first user_id).
} {
    # used in customer-service to determine timezone
    upvar 1 instance_id instance_id
    set user_id_list ""
    
    if { [qf_is_true $all_p] } {

    } else {


    }
    return $user_id_list
}


ad_proc qal_contact_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_contact
} {

    set keys_list [list instance_id id label name street_address_id mailing_address_id billing_address_id business_id taxnumber sic_code iban bic language_code currency time_start time_end url notes]
    set keys [qal_keys_by $keys_list $separator]
     return $keys
}
