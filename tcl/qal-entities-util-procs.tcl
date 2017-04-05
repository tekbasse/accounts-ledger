ad_library {
    Library for accounts ledger contacts
    @creation-date 2016-06-28

}

ad_proc qal_contact_id_from_customer_id {
    customer_id_list
} {
    Returns contact_id(s) of customer_id(s)
} {
    # used in contact-support, expects parameter to be a list

}

ad_proc qal_contact_id_from_vendor_id {
    vendor_id_list
} {
    Returns contact_id(s) of vendor_id(s)
} {
    # used in contact-support, expects parameter to be a list

}


ad_proc qal_contact_id_read {
    contact_id
    names_list
} {
    Returns a record in a name value list. names are fields from qal_contact table.
} {   
    # used in contact-support pkg
    # select data from one contact_id
    
    
}

ad_proc qal_contact_ids_of_user_id {
    user_id
} {
    
} {
    upvar 1 instance_id instance_id
    set contact_id_list ""

    return $contact_id_list
}


ad_proc qal_customer_ids_of_user_id {
    user_id
} {
    
} {
    upvar 1 instance_id instance_id
    set customer_id_list ""

    return $customer_id_list
}



ad_proc qal_vendor_ids_of_user_id {
    user_id
} {
    
} {
    upvar 1 instance_id instance_id
    set vendor_id_list ""

    return $vendor_id_list
}


ad_proc qal_user_ids_of_contact_id {
    contact_id
    {all_p "1"}
} {
    Returns user_ids of contact_id, if all_p is "0", just returns primary (default first user_id).
} {
    # used in contact-support to determine timezone
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
    set keys_list [list \
                       id \
                       rev_id \
                       instance_id \
                       parent_id \
                       label \
                       name \
                       street_addrs_id \
                       mailing_addrs_id \
                       billing_addrs_id \
                       vendor_id \
                       customer_id \
                       taxnumber \
                       sic_code \
                       iban \
                       bic \
                       language_code \
                       currency \
                       timezone \
                       time_start \
                       time_end \
                       url \
                       user_id \
                       created \
                       created_by \
                       trashed_p \
                       trashed_by \
                       trashed_ts \
                       notes ]
    set keys [qal_keys_by $keys_list $separator]
    return $keys
}
