ad_library {
    Library for accounts ledger contacts
    @creation-date 2016-06-28

}

ad_proc qal_contact_id_exists_q {
    contact_id
} {
    Returns 1 if contact_id exists, otherwise returns 0
} {
    upvar 1 instance_id instance_id
    db_0or1row qal_contact_exists_q {select id from qal_contact where instance_id=:instance_id and id=:contact_id and trashed_p!='1'}
    return [info exists id]
}


ad_proc qal_contact_id_from_label {
    contact_label
} {
    Returns id if contact_label exists, otherwise returns ""
} {
    upvar 1 instance_id instance_id
    set id ""
    db_0or1row qal_contact_label_exists_q {select id from qal_contact where instance_id=:instance_id and label=:contact_label and trashed_p!='1'}
    return $id
}


ad_proc qal_customer_id_exists_q {
    customer_id
} {
    Returns 1 if customer_id exists, otherwise returns 0
} {
    upvar 1 instance_id instance_id
    db_0or1row qal_customer_exists_q {select id from qal_customer where instance_id=:instance_id and id=:customer_id and trashed_p!='1'}
    return [info exists id]
}


ad_proc qal_customer_id_from_code {
    customer_code
} {
    Returns id if customer_code exists, otherwise returns ""
} {
    upvar 1 instance_id instance_id
    set id ""
    db_0or1row qal_customer_code_exists_q {select id from qal_customer where instance_id=:instance_id and customer_code=:customer_code and trashed_p!='1'}
    return $id
}


ad_proc qal_vendor_id_exists_q {
    vendor_id
} {
    Returns 1 if vendor_id exists, otherwise returns 0
} {
    upvar 1 instance_id instance_id
    db_0or1row qal_vendor_exists_q {select id from qal_vendor where instance_id=:instance_id and id=:vendor_id and trashed_p!='1'}
    return [info exists id]
}


ad_proc qal_vendor_id_from_code {
    vendor_code
} {
    Returns id if vendor_code exists, otherwise returns ""
} {
    upvar 1 instance_id instance_id
    set id ""
    db_0or1row qal_vendor_code_exists_q {select id from qal_vendor where instance_id=:instance_id and vendor_code=:vendor_code and trashed_p!='1'}
    return $id
}



ad_proc qal_contact_id_from_customer_id {
    customer_id_list
} {
    Returns contact_id(s) of customer_id(s)
} {
    # used in contact-support, expects parameter to be a list
    ##code
}

ad_proc qal_contact_id_from_vendor_id {
    vendor_id_list
} {
    Returns contact_id(s) of vendor_id(s)
} {
    # used in contact-support, expects parameter to be a list
    ##code
}


ad_proc qal_contact_id_read {
    contact_id
    names_list
} {
    Returns a record in a name value list. names are fields from qal_contact table.
} {   
    # used in contact-support pkg
    # select data from one contact_id
    ##code
    
}

ad_proc qal_contact_ids_of_user_id {
    user_id
} {
    
} {
    upvar 1 instance_id instance_id
    set contact_id_list ""
    ##code
    return $contact_id_list
}


ad_proc qal_customer_ids_of_user_id {
    user_id
} {
    
} {
    upvar 1 instance_id instance_id
    set customer_id_list ""
    ##code
    return $customer_id_list
}



ad_proc qal_vendor_ids_of_user_id {
    user_id
} {
    
} {
    upvar 1 instance_id instance_id
    set vendor_id_list ""
    ##code
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
    ##code
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

ad_proc qal_customer_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_customer
} {
    set keys_list [list \
                       id \
                       instance_id \
                       rev_id \
                       contact_id \
                       discount \
                       tax_included \
                       credit_limit \
                       terms \
                       terms_unit \
                       annual_value \
                       customer_code \
                       pricegroup_id \
                       created \
                       created_by \
                       trashed_p \
                       trashed_by \
                       trashed_ts ]
    set keys [qal_keys_by $keys_list $separator]
    return $keys
}

ad_proc qal_vendor_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_vendor
} {
    set keys_list [list \
                       id \
                       instance_id \
                       rev_id \
                       contact_id \
                       terms \
                       terms_unit \
                       tax_included \
                       vendor_code \
                       gifi_accno \
                       discount \
                       credit_limit \
                       pricegroup_id \
                       created \
                       created_by \
                       trashed_p \
                       trashed_by \
                       trashed_ts \
                       area_market \
                       purchase_policy \
                       return_policy \
                       price_guar_policy \
                       installation_policy ]
    set keys [qal_keys_by $keys_list $separator]
    return $keys
}
