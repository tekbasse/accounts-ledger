ad_library {
    Library for accounts ledger contacts
    @creation-date 2016-06-28

}

ad_proc -public qal_contact_id_exists_q {
    contact_id
} {
    Returns 1 if contact_id exists, otherwise returns 0
} {
    upvar 1 instance_id instance_id
    db_0or1row qal_contact_exists_q {select id from qal_contact where instance_id=:instance_id and id=:contact_id and trashed_p!='1'}
    return [info exists id]
}


ad_proc -public qal_contact_id_from_label {
    contact_label
} {
    Returns id if contact_label exists, otherwise returns ""
} {
    upvar 1 instance_id instance_id
    set id ""
    db_0or1row qal_contact_label_exists_q {select id from qal_contact where instance_id=:instance_id and label=:contact_label and trashed_p!='1'}
    return $id
}

ad_proc -public qal_contact_id_from_customer_id {
    customer_id
} {
    Returns contact_id(s) of customer_id(s). If supplied 1, returns a scalar, otherwise returns a list.
    Returns an empty string if customer_id not found.
} {
    if { [llength $customer_id] > 1 } {
        set contact_ids [db_list qal_customer_read_c_id_n "select contact_id from qal_customer \
 where customer_id in ([template::util::tcl_to_sql_list $customer_id]) and trashed_p!='1' and instance_id=:instance_id"]
    } else {
        set contact_ids ""
        db_0or1row qal_customer_read_customer_id_1 {select contact_id as contact_ids from qal_customer
            where customer_id=:customer_id}
    }
    return $contact_ids
}

ad_proc -public qal_contact_id_from_vendor_id {
    vendor_id
} {
    Returns contact_id(s) of vendor_id(s). If supplied 1, returns a scalar, otherwise returns a list.
    Returns an empty string if vendor_id not found.
} {
    if { [llength $vendor_id] > 1 } {
        set contact_ids [db_list qal_vendor_read_c_id_n "select contact_id from qal_vendor \
 where vendor_id in ([template::util::tcl_to_sql_list $vendor_id]) and trashed_p!='1' and instance_id=:instance_id"]
    } else {
        set contact_ids ""
        db_0or1row qal_vendor_read_vendor_id_1 {select contact_id as contact_ids from qal_vendor
            where vendor_id=:vendor_id}
    }
    return $vendor_ids
}


ad_proc -public qal_customer_id_exists_q {
    customer_id
} {
    Returns 1 if customer_id exists, otherwise returns 0
} {
    upvar 1 instance_id instance_id
    db_0or1row qal_customer_exists_q {select id from qal_customer where instance_id=:instance_id and id=:customer_id and trashed_p!='1'}
    return [info exists id]
}


ad_proc -public qal_customer_id_from_code {
    customer_code
} {
    Returns id if customer_code exists, otherwise returns ""
} {
    upvar 1 instance_id instance_id
    set id ""
    db_0or1row qal_customer_code_exists_q {select id from qal_customer where instance_id=:instance_id and customer_code=:customer_code and trashed_p!='1'}
    return $id
}

ad_proc -public qal_vendor_id_exists_q {
    vendor_id
} {
    Returns 1 if vendor_id exists, otherwise returns 0
} {
    upvar 1 instance_id instance_id
    db_0or1row qal_vendor_exists_q {select id from qal_vendor where instance_id=:instance_id and id=:vendor_id and trashed_p!='1'}
    return [info exists id]
}


ad_proc -public qal_vendor_id_from_code {
    vendor_code
} {
    Returns id if vendor_code exists, otherwise returns ""
} {
    upvar 1 instance_id instance_id
    set id ""
    db_0or1row qal_vendor_code_exists_q {select id from qal_vendor where instance_id=:instance_id and vendor_code=:vendor_code and trashed_p!='1'}
    return $id
}


ad_proc -public qal_contact_ids_of_user_id {
    user_id
} {
    Returns contact_id(s) of user_id, or empty string if none found.
} {
    upvar 1 instance_id instance_id
    set contact_id_list [db_list qal_contact_user_map_read_ids { select contact_id from qal_contact_user_map 
        where instance_id=:instance_id
        and user_id=:user_id
        and trashed_p!='1' } ]
    return $contact_id_list
}


ad_proc -public qal_customer_ids_of_user_id {
    user_id
} {
    Returns customer_id(s) of user_id, or empty string if none found.
} {
    upvar 1 instance_id instance_id
    # Every customer_id has one contact_id
    set contact_id_list [qal_contact_ids_of_user_id $user_id]
    set customer_id_list [list ]
    if { [llength $contact_id_list] > 0 } {
        set customer_id_list [db_list qal_customer_contact_ids_r " select id from qal_customer
        where contact_id in ([template::util::tcl_to_sql_list $contact_id_list])
        and instance_id=:instance_id"]
    }
    return $customer_id_list
}

ad_proc -public qal_vendor_ids_of_user_id {
    user_id
} {
    Returns vendor_id(s) of user_id, or empty string if none found.
} {
    upvar 1 instance_id instance_id
    # Every vendor_id has one contact_id
    set contact_id_list [qal_contact_ids_of_user_id $user_id]
    set vendor_id_list [list ]
    if { [llength $contact_id_list] > 0 } {
        set vendor_id_list [db_list qal_vendor_contact_ids_r " select id from qal_vendor
        where contact_id in ([template::util::tcl_to_sql_list $contact_id_list])
        and instance_id=:instance_id"]
    }
    return $vendor_id_list
}


ad_proc -public qal_contact_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_contact.
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

ad_proc -public qal_customer_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_customer.
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

ad_proc -public qal_vendor_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_vendor.
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

ad_proc -public qal_address_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_address.
} {
    set keys_list [list \
                       id \
                       instance_id \
                       rev_id \
                       address_type \
                       address0 \
                       address1 \
                       address2 \
                       city \
                       state \
                       postal_code \
                       country_code \
                       attn \
                       phone \
                       phone_time \
                       fax \
                       email \
                       cc \
                       bcc ]
    set keys [qal_keys_by $keys_list $separator]
    return $keys
}


ad_proc -public qal_other_address_map_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_other_address_map.
} {
    set keys_list [list \
                       contact_id \
                       instance_id \
                       addrs_id \
                       record_type \
                       address_id \
                       sort_order \
                       created \
                       created_by \
                       trashed_p \
                       trashed_by \
                       trashed_ts \
                       account_name \
                       notes ]
    set keys [qal_keys_by $keys_list $separator]
    return $keys
}
