ad_library {
    business logic for accounts ledger contacts
    @creation-date 2016-06-28

}

    ##code 
    # if contact.id == "" see if id exists in qal_contact_read, otherwise create an id via qal_contact_create?
    # No. This feature should be a separate function, only create after a qualified user accepts it.
    # Add to a UBL feature in accounts-ledger, such as when accepting a quotation request etc.
    # This will mean there needs to be a stack for incoming documents with related info..
    # as a part of UBL..

ad_proc qal_contact_create {
    arr_name
} {
    Creates a new qal_contact record
    # validations etc
    ##code

    # at a minimum, object_id needs to be used to prevent id collision with other packges:
    # set id \[db_nextval acs_object_id_seq\]
    set id [application_group::new -package_id $instance_id -group_name $label]
    # insert into db

    return $id
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
    contact_id_list
} {
    Deletes records.
    contact_id_list may be a one or a list.
    User must be a package admin.
} {
    set success_p 1
    if { $contact_id_list ne "" } {
        set user_id [ad_conn user_id]
        set instance_id [qc_set_instance_id]
        set admin_p [permission::permission_p -party_id $user_id \
                         -object_id [ad_conn package_id] -privilege admin]
        set success_p $admin_p
        if { $admin_p } {
            if { [llength $contact_id_list] > 0 } {
                set validated_p [hf_list_filter_by_natural_number $contact_id_list]
                set ip_list $contact_id_list
            } else {
                set contact_id [lindex $contact_id_list 0]
                set validated_p [hf_is_natural_number $contact_id]
                set ip_list [list $contact_id]
            }
            if { $validated_p } {
                db_transaction {
                    db_dml hf_contact_ids_delete {
                        delete from hf_ip_addresses \
                            where instance_id=:instance_id and contact_id in \
                            ([template::util::tcl_to_sql_list $ip_list]) }
                    db_dml hf_ip_attr_map_del {
                        delete from hf_sub_asset_map \
                            where instance_id=:instance_id and sub_f_id in \
                            ([template::util::tcl_to_sql_list $ip_list]) }
                } on_error {
                    set success_p 0
                }
            } else {
                set success_p 0
            }
        }
    }
    return $success_p
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
    customer_id_list
} {
    Deletes records.
    customer_id_list may be a one or a list.
    User must be a package admin.
} {
    set success_p 1
    if { $customer_id_list ne "" } {
        set user_id [ad_conn user_id]
        set instance_id [qc_set_instance_id]
        set admin_p [permission::permission_p -party_id $user_id \
                         -object_id [ad_conn package_id] -privilege admin]
        set success_p $admin_p
        if { $admin_p } {
            if { [llength $customer_id_list] > 0 } {
                set validated_p [hf_list_filter_by_natural_number $customer_id_list]
                set ip_list $customer_id_list
            } else {
                set customer_id [lindex $customer_id_list 0]
                set validated_p [hf_is_natural_number $customer_id]
                set ip_list [list $customer_id]
            }
            if { $validated_p } {
                db_transaction {
                    db_dml hf_customer_ids_delete {
                        delete from hf_ip_addresses \
                            where instance_id=:instance_id and customer_id in \
                            ([template::util::tcl_to_sql_list $ip_list]) }
                    db_dml hf_ip_attr_map_del {
                        delete from hf_sub_asset_map \
                            where instance_id=:instance_id and sub_f_id in \
                            ([template::util::tcl_to_sql_list $ip_list]) }
                } on_error {
                    set success_p 0
                }
            } else {
                set success_p 0
            }
        }
    }
    return $success_p
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
    vendor_id_list
} {
    Deletes records.
    vendor_id_list may be a one or a list.
    User must be a package admin.
} {
    set success_p 1
    if { $vendor_id_list ne "" } {
        set user_id [ad_conn user_id]
        set instance_id [qc_set_instance_id]
        set admin_p [permission::permission_p -party_id $user_id \
                         -object_id [ad_conn package_id] -privilege admin]
        set success_p $admin_p
        if { $admin_p } {
            if { [llength $vendor_id_list] > 0 } {
                set validated_p [hf_list_filter_by_natural_number $vendor_id_list]
                set ip_list $vendor_id_list
            } else {
                set vendor_id [lindex $vendor_id_list 0]
                set validated_p [hf_is_natural_number $vendor_id]
                set ip_list [list $vendor_id]
            }
            if { $validated_p } {
                db_transaction {
                    db_dml hf_vendor_ids_delete {
                        delete from hf_ip_addresses \
                            where instance_id=:instance_id and vendor_id in \
                            ([template::util::tcl_to_sql_list $ip_list]) }
                    db_dml hf_ip_attr_map_del {
                        delete from hf_sub_asset_map \
                            where instance_id=:instance_id and sub_f_id in \
                            ([template::util::tcl_to_sql_list $ip_list]) }
                } on_error {
                    set success_p 0
                }
            } else {
                set success_p 0
            }
        }
    }
    return $success_p
}


ad_proc qal_vendor_trash {
    arr_name
} {
    Trash a vendor record
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr


}

