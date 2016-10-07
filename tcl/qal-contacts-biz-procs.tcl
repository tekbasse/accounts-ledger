ad_library {
    business logic for accounts ledger contacts
    @creation-date 2016-06-28

}

ad_proc qal_contact_write {
    arr_name
} {
    Writes a new revision to an existing qal_contact record.
    If id is empty, creates a new record.
    A new id is returned if successful.
    Otherwise empty string is returned.
    @param array_name
    @return id or ""
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr
    qal_contact_defaults arr_name
    hf_sub_asset_map_defaults arr_name
    qf_array_to_vars arr_name [qal_contact_keys]
    qf_array_to_vars arr_name [hf_sub_asset_map_keys]
    qf_array_to_vars arr_name [list asset_type_id label]
    if { $type_id eq "" } {
        set type_id $asset_type_id
    }
    set sub_type_id "ns"
    hf_sub_label_define_empty
    set attribute_p [qf_is_true $attribute_p 1]
    set sub_f_id $ns_id
    set ns_id_new [hf_sub_asset_map_update $f_id $type_id $sub_label $sub_f_id $sub_type_id $attribute_p]
    if { $ns_id_new ne "" } {
        # record revision/new
        set ns_id $ns_id_new
        db_dml ns_asset_create "insert into qal_contact \
 ([qal_contact_keys ","]) values ([qal_contact_keys ",:"])"
    } else {
        ns_log Warning "qal_contact_write: rejected '[array get arr_name]'"
    }
    return $ns_id_new
}

ad_proc qal_contact_delete {
    arr_name
} {
    Delete a contact record
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr


}


ad_proc qal_contact_trash {
    arr_name
} {
    Trash a contact record
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr


}


ad_proc qal_customer_write {
    arr_name
} {
    Writes a new revision to an existing qal_customer record.
    If id is empty, creates a new record.
    A new id is returned if successful.
    Otherwise empty string is returned.
    @param array_name
    @return id or ""
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr


}

ad_proc qal_customer_delete {
    arr_name
} {
    Delete a customer record
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr


}


ad_proc qal_customer_trash {
    arr_name
} {
    Trash a customer record
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr


}


ad_proc qal_vendor_write {
    arr_name
} {
    Writes a new revision to an existing qal_vendor record.
    If id is empty, creates a new record.
    A new id is returned if successful.
    Otherwise empty string is returned.
    @param array_name
    @return id or ""
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr


}

ad_proc qal_vendor_delete {
    arr_name
} {
    Delete a vendor record
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr


}


ad_proc qal_vendor_trash {
    arr_name
} {
    Trash a vendor record
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr


}

