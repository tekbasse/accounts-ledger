ad_library {
    business logic for accounts ledger contacts
    @creation-date 2016-06-28

}

    ##code 
    # if contact.id eq "" see if id exists in qal_contact_read, otherwise create an id via qal_contact_create?
    # No. This feature should be a separate function, only create after a qualified user accepts it.
    # Add to a UBL feature in accounts-ledger, such as when accepting a quotation request etc.
    # This will mean there needs to be a stack for incoming documents with related info..
    # as a part of UBL..

ad_proc qal_contact_create {
    arr_name
} {
    # Creates a new qal_contact record

    upvar 1 instance_id instance_id

    # at a minimum, object_id needs to be used to prevent id collision with other packges:
    # set id \[db_nextval acs_object_id_seq\]
    set arr_name(id) ""
    qal_contact_write arr_name

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
    set error_p 0
    qal_contact_defaults arr_name
    qf_array_to_vars arr_name [qal_contact_keys]

    # validations etc
    if { ![qf_is_natural_number $parent_id] } {
        set parent_id ""
    }
    if { [string length $name] > 79 } {
        set name [qf_abbreviate $name 79 ]
    }
    
    if { $label eq "" } { 
        set label [qf_abbreviate $name 39 "-"]
    } elseif { [string length $label ] > 39 } {
        set label [qf_abbreviate $label 39 "-"]
    }
    if { ![qf_is_natural_number $street_addrs_id] } {
        set street_addrs_id ""
    }
    if { ![qf_is_natural_number $mailing_addrs_id] } {
        set mailing_addrs_id ""
    }
    if { ![qf_is_natural_number $billing_addrs_id] } {
        set billing_addrs_id ""
    }
    if { ![qf_is_natural_number $vendor_id] } {
        set vendor_id ""
    }
    if { ![qf_is_natural_number $customer_id] } {
        set customer_id ""
    }
    if { [string length $taxnumber ] > 32 } {
        regsub -all -- {[^a-zA-Z0-9]} $taxnumber {} taxnumber
        set taxnumber [string range $taxnumber 0 31]
    }
    if { [string length $sic_code ] > 15 } {
        regsub -all -- {[^a-zA-Z0-9]} $sic_code {} sic_code
        set sic_code [string range $sic_code 0 14]
    }
    if { [string length $iban ] > 34 } {
        regsub -all -- {[^a-zA-Z0-9]} $iban {} iban
        set iban [string range $iban 0 33]
    }
    set iban [string toupper $iban]
    if { [string length $bic ] > 12 } {
        regsub -all -- {[^a-zA-Z0-9]} $bic {} bic
        set bic [string range $bic 0 11]
    }
    if { [string length $language_code ] > 6} {
        regsub -all -- {[^a-z_A-Z0-9]} $language_code {} language_code
        set language_code [string range $language_code 0 5]
    }
    if { [string length $currency ] > 3} {
        regsub -all -- {[^a-z_A-Z0-9]} $currency {} currency
        set currency [string range $currency 0 2]
    }
    if { [string length $timezone ] > 100} {
        regsub -all -- {[^a-z_A-Z0-9]} $timezone {} timezone
        set timezone [string range $timezone 0 99]
    }
    # skip time_start , time_end checks for now
    set time_start_s [qf_clock_scan $time_start]
    if { $time_start_s eq "" } {
        set time_start_s [clock seconds]
    }
    set time_start [qf_clock_format $time_start_s ]
    set time_end_s [qf_clock_scan $time_end]
    if { $time_end_s ne "" } {
        set time_end [qf_clock_format $time_end_s ]
    }

    if { [hf_are_safe_and_printable_characters_q $url] } {
        if  { ![util_url_valid_p $url ] } {
            set url2 "http://"
        }
        append url2 $url
    } else {
       ## check recent discussion with gustafn and others about nsencode etc
    }
    ##code
    if { ![qf_natural_number $user_id] } {
        if { [ns_conn isconnected] } {
            set user_id [ad_conn user_id]
        } else {
            set user_id $instance_id


    # insert into db
    if { ![qf_is_natural_number $id] } {
        # record revision/new
        set id [application_group::new -package_id $instance_id -group_name $label]
        #  now_yyyymmdd_hhmmss
        set time_start [clock format [clock seconds] -format "%Y%m%d %H%M%S"]
    } 
    if { $error_p } {
        ns_log Warning "qal_contact_write: rejected '[array get arr_name]'"
    } else {



        set rev_id [db_nextval qal_id]
        set created [clock format [clock seconds] -format "%Y%m%d %H%M%S"]
        set created_by $user_id
        set trashed_p 0
        set trashed_by ""
        set trashed_ts ""
        db_transaction {
            ##code if old id exists with untrashed rev_id, trash it
            db_dml ns_asset_create "insert into qal_contact \
 ([qal_contact_keys ","]) values ([qal_contact_keys ",:"])"
        }
    }
    return $id
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

