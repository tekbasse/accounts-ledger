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


ad_proc -public qal_contact_label_from_id {
    contact_id
} {
    Returns contact label if it exists, otherwise returns ""
} {
    upvar 1 instance_id instance_id
    set label ""
    db_0or1row qal_contact_label_exists_q {select label from qal_contact where instance_id=:instance_id and id=:contact_id and trashed_p!='1'}
    return $label
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
    upvar 1 instance_id instance_id
    if { [llength $customer_id] > 1 } {
        set contact_ids [db_list qal_customer_read_c_id_n "select contact_id from qal_customer \
 where customer_id in ([template::util::tcl_to_sql_list $customer_id]) and trashed_p!='1' and instance_id=:instance_id"]
    } else {
        set contact_ids ""
        db_0or1row qal_customer_read_customer_id_1 {select contact_id as contact_ids from qal_customer
            where id=:customer_id
            and instance_id=:instance_id
            and trashed_p!='1'}
    }
    return $contact_ids
}

ad_proc -public qal_contact_id_from_vendor_id {
    vendor_id
} {
    Returns contact_id(s) of vendor_id(s). If supplied 1, returns a scalar, otherwise returns a list.
    Returns an empty string if vendor_id not found.
} {
    upvar 1 instance_id instance_id
    if { [llength $vendor_id] > 1 } {
        set contact_ids [db_list qal_vendor_read_c_id_n "select contact_id from qal_vendor \
 where vendor_id in ([template::util::tcl_to_sql_list $vendor_id]) and trashed_p!='1' and instance_id=:instance_id"]
    } else {
        set contact_ids ""
        db_0or1row qal_vendor_read_vendor_id_1 {select contact_id as contact_ids from qal_vendor
            where id=:vendor_id
            and instance_id=:instance_id
            and trashed_p!='1'}
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
    Returns an ordered list of keys for qal_contact: 

    id 
    rev_id 
    instance_id 
    parent_id 
    label 
    name 
    street_addrs_id 
    mailing_addrs_id 
    billing_addrs_id 
    vendor_id 
    customer_id 
    taxnumber 
    sic_code 
    iban 
    bic 
    language_code 
    currency 
    timezone 
    time_start 
    time_end 
    url 
    user_id 
    created 
    created_by 
    trashed_p 
    trashed_by 
    trashed_ts 
    notes 

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
    Returns an ordered list of keys for qal_customer:
    id 
    instance_id 
    rev_id 
    contact_id 
    discount 
    tax_included 
    credit_limit 
    terms 
    terms_unit 
    annual_value 
    customer_code 
    pricegroup_id 
    created 
    created_by 
    trashed_p 
    trashed_by 
    trashed_ts
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
    Returns an ordered list of keys for qal_vendor:
    id 
    instance_id 
    rev_id 
    contact_id 
    terms 
    terms_unit 
    tax_included 
    vendor_code 
    gifi_accno 
    discount 
    credit_limit 
    pricegroup_id 
    created 
    created_by 
    trashed_p 
    trashed_by 
    trashed_ts 
    area_market 
    purchase_policy 
    return_policy 
    price_guar_policy 
    installation_policy 
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
    Returns an ordered list of keys for qal_address:
    id 
    instance_id 
    rev_id 
    address_type 
    address0 
    address1 
    address2 
    city 
    state 
    postal_code 
    country_code 
    attn 
    phone 
    phone_time 
    fax 
    email 
    cc 
    bcc
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
    Returns an ordered list of keys for qal_other_address_map:
    contact_id 
    instance_id 
    addrs_id 
    record_type 
    address_id 
    sort_order 
    created 
    created_by 
    trashed_p 
    trashed_by 
    trashed_ts 
    account_name 
    notes 

    @see qal_address_keys
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


ad_proc -public qal_addresses_keys {
    {separator ""}
} {
    Returns an ordered list of keys for the combined tables of qal_address and qal_other_address_map as qal_addresses_read: \
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
        accounts_name \
        notes \
        address_type \
        address0 \
        address1 \
        address2 \
        city \
        state \
        postal_code \
        country_coude \
        attn \
        phone \
        phone_time \
        fax \
        email \
        cc \
        bcc
    @see qal_address_keys
    @see qal_other_address_map_keys
} {
    # This only works to read from the database and a extract data from an ordered list.
    # To write to database, use qal_address_keys and qal_other_address_map_keys.
    set k_list [list \
                    om.contact_id \
                    om.instance_id \
                    om.addrs_id \
                    om.record_type \
                    om.address_id \
                    om.sort_order \
                    om.created \
                    om.created_by \
                    om.trashed_p \
                    om.trashed_by \
                    om.trashed_ts \
                    om.accounts_name \
                    om.notes \
                    ad.address_type \
                    ad.address0 \
                    ad.address1 \
                    ad.address2 \
                    ad.city \
                    ad.state \
                    ad.postal_code \
                    ad.country_code \
                    ad.attn \
                    ad.phone \
                    ad.phone_time \
                    ad.fax \
                    ad.email \
                    ad.cc \
                    ad.bcc ]
    if { $separator eq "," } {
        set keys_list $k_list
    } else {
        set keys_list [list ]
        foreach key $k_list {
            lappend keys_list [string range $key 3 end]
        }
    }
    set keys [qal_keys_by $keys_list $separator]
    return $keys
}

ad_proc -public qal_address_type {
    addrs_id
    {contact_id ""}
} {
    Returns address type (ie qal_other_address_map.record_type ) or empty string if not found.
    If contact_id is nonempty, constrains query to contact_id.
    <br/>
    @see qal_other_address_map_keys
} {
    upvar 1 instance_id instance_id
    set record_type ""
    if { [qf_is_natural_number $contact_id ] } {
        db_0or1row qal_other_address_map_address_type_r {
            select record_type from qal_other_address_map
            where contact_id=:contact_id
            and addrs_id=:addrs_id
            and instance_id=:instance_id
            and trashed_p!='1' }
    } else {
        db_0or1row qal_other_address_map_address_type_r2 {
            select record_type from qal_other_address_map
            where addrs_id=:addrs_id
            and instance_id=:instance_id
            and trashed_p!='1' }
    }
    return $record_type
}

ad_proc -public qal_address_type_keys {
} {
    Returns postal address_type keys
} {
    return [list mailing_address billing_address street_address]
}

ad_proc -private qal_address_type_fields {
} {
    Returns postal address_type fields that correspond to address_type keys

    @see qal_address_type_keys
} {
    return [list mailing_addrs_id billing_addrs_id street_addrs_id]
}

ad_proc -public qal_address_type_is_postal_q {
    address_type
} {
    Returns 1 if address type is a postal address, otherwise returns 0.
} {
    set is_postal_p 1
    set address_type_list [qal_address_type_keys]
    if { $address_type ni $address_type_list } {
        set is_postal_p 0
    }
    return $is_postal_p
}

ad_proc -public qal_field_name_of_address_type {
    address_type
} {
    Returns field name in table qal_other_address_map of record_type,
    or empty string if address_type not in table.
    <br/>
    Field names are: mailing_addrs_id billing_addrs_id street_addrs_id (in table qal_contact)
    @see qal_other_address_map_keys
} {
    set type_list [qal_address_type_keys]
    set name_list [qal_address_type_fields]
    set type_idx [lsearch -exact $type_list $address_type]
    set field_name [lindex $name_list $type_idx]
    return $field_name
}


ad_proc -private qal_customer_id_from_contact_id {
    contact_id
} {
    Returns customer_id of contact_id
    Returns an empty string if customer_id not found.
} {
    upvar 1 instance_id instance_id
    set id ""
    db_0or1row qal_customer_read_contact_id_1 {select id from qal_customer
        where contact_id=:contact_id
        and instance_id=:instance_id
        and trashed_p!='1'}
    return $id
}

ad_proc -private qal_vendor_id_from_contact_id {
    contact_id
} {
    Returns vendor_id of customer_id. 
    Returns an empty string if vendor_id not found.
} {
    upvar 1 instance_id instance_id
    set id ""
    db_0or1row qal_vendor_read_contact_id_1 {select id from qal_vendor
        where contact_id=:contact_id
        and instance_id=:instance_id
        and trashed_p!='1'}
return $id
}
