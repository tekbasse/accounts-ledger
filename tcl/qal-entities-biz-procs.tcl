ad_library {
    business logic for accounts ledger contacts
    @creation-date 2016-06-28

}

    ##code comments about implementing UBL package
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
    upvar 1 $arr_name arr_name
    # at a minimum, object_id needs to be used to prevent id collision with other packges:
    # set id \[db_nextval acs_object_id_seq\]
    set arr_name(id) ""
    set id [qal_contact_write arr_name]
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
        set url2 [ad_urlencode_url $url2]
    } else {
        set url2 [ad_urlencode_url $url2]
    }
    set url [string range $url2 0 198]

    if { ![qf_natural_number $user_id] } {
        if { [ns_conn isconnected] } {
            set user_id [ad_conn user_id]
        } else {
            set user_id $instance_id
        }
    }

    set created_s [qf_clock_scan $created]
    if { $created_s eq "" } {
        set created_s [clock seconds]
    }
    set created [qf_clock_format $created_s ]
    # insert into db
    if { ![qf_is_natural_number $id] } {
        # record revision/new
        set id [application_group::new -package_id $instance_id -group_name $label]
        #  now_yyyymmdd_hhmmss
        set create_p 1
        set time_start [clock format [clock seconds] -format "%Y%m%d %H%M%S"]
    } else {
        set create_p 0
    }
    if { $error_p } {
        ns_log Warning "qal_contact_write: rejected '[array get arr_name]'"
    } else {

        set rev_id [db_nextval qal_id]
        set created [clock format [clock seconds] -format "%Y%m%d %H%M%S"]
        if { [ns_conn isconnected] } {
            set created_by [ad_conn user_id]
        } else {
            set created_by $user_id
        } 

        set trashed_p 0
        set trashed_by ""
        set trashed_ts ""
        db_transaction {
            if { !$create_p } {
                db_dml qal_contact_trash { update qal_contact set trashed_p='1',trashed_by=:user_id,trashed_ts=now() where id=:id
                }
            }
            # Make sure label is unique
            set i 1
            set label_orig $label
            set id_from_label [qal_contact_id_from_label $label]
            while { ( $id_from_label ne "" && $id_from_label ne $id ) && $i < 1000 } {
                incr i
                set chars_max [expr { 38 - [string length $i] } ]
                set label [string range $label_orig 0 $chars_max]
                append label "-" $i
                set id_from_label [qal_contact_id_from_label $label]
            }
            db_dml qal_contact_create_1 "insert into qal_contact \
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
            set contact_id_list_len [llength $contact_id_list]
            if { $contact_id_list_len > 0 } {
                set validated_p [hf_natural_number_list_validate $contact_id_list]
            } else {
                set validated_p 0
            }
            if { $validated_p } {
                db_transaction {
                    db_dml qal_contact_ids_delete "
                        delete from qal_contact \
                            where instance_id=:instance_id and contact_id in \
                            ([template::util::tcl_to_sql_list $contact_id_list]) "
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
    contact_id_list
} {
    Trash a contact record.
    May be one or a list
    Must have write permission for instance or contact_id (via q-control package).
} {
    set success_p 0
    if { $contact_id_list ne "" } {
        set user_id [ad_conn user_id]
        set instance_id [qc_set_instance_id]
        set contact_id_list_len [llength $contact_id_list]
        if { $contact_id_list_len > 0 } {
            set validated_p [hf_natural_number_list_validate $contact_id_list]
        } else {
            set validated_p 0
        }
        if { $validated_p } {
            set instance_write_p [qc_permission_p $user_id $instance_id non_assets write $instance_id]
            if { $instance_write_p } {
                set filtered_contact_id_list $contact_id_list
            } else {
                set filtered_contact_id_list [list ]
                set at_least_one_write_p 0
                foreach contact_id $contact_id_list {
                    if { [qc_permission_p $user_id $contact_id non_assets write $instance_id] } {
                        set at_least_one_write_p 1
                        lappend filtered_contact_id_list $contact_id
                    }
                }
            } 
            if { $instance_write_p || $at_least_one_write_p } {
                set success_p 1
                db_transaction {
                    db_dml qal_contact_ids_trash "update qal_contact \
                            set trashed_p='1',trashed_by=:user_id,trashed_ts=now() \
                            where instance_id=:instance_id and trashed_p!='1' and contact_id in \
                            ([template::util::tcl_to_sql_list $filtered_contact_id_list])"
                } on_error {
                    set success_p 0
                }
            }
        }
    }
    return $success_p
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
    set error_p 0
    qal_customer_defaults arr_name
    qf_array_to_vars arr_name [qal_contact_keys]

    # validations etc
    if { ![qf_is_natural_number $id] } {
        set id ""
    }
    if { ![qf_is_natural_number $contact_id] } {
        set contact_id ""
    }
    if { ![qf_is_decimal $discount] } {
        set discount ""
    }
    
    set tax_included [qf_is_true $tax_included]

    if { ![qf_is_decimal $credit_limit] } {
        set credit_limit ""
    }
    if { ![qf_is_decimal $terms] } {
        set terms ""
    }

    set terms_unit [string range $terms_unit 0 19]

    if { ![qf_is_decimal $annual_value] } {
        set annual_value ""
    }

    set customer_code [string range $customer_code 0 31]

    if { ![qf_is_natural_number $pricegroup_id] } {
        set pricegroup_id ""
    }

    set created_s [qf_clock_scan $created]
    if { $created_s eq "" } {
        set created_s [clock seconds]
    }
    set created [qf_clock_format $created_s ]
    # insert into db
    if { ![qf_is_natural_number $id] } {
        # record revision/new
        set id [application_group::new -package_id $instance_id -group_name "customer_num_for_contact_${contact_id}"]
        #  now_yyyymmdd_hhmmss
        set time_start [clock format [clock seconds] -format "%Y%m%d %H%M%S"]
    } 
    if { $error_p } {
        ns_log Warning "qal_customer_write: rejected '[array get arr_name]'"
    } else {

        set rev_id [db_nextval qal_id]
        set created [clock format [clock seconds] -format "%Y%m%d %H%M%S"]
        if { [ns_conn isconnected] } {
            set created_by [ad_conn user_id]
        } else {
            set created_by $user_id
        } 

        set trashed_p 0
        set trashed_by ""
        set trashed_ts ""
        db_transaction {
            if { !$create_p } {
                db_dml qal_customer_trash { update qal_customer set trashed_p='1',trashed_by=:user_id,trashed_ts=now() where id=:id
                }
            }
            # Make sure customer_code is unique
            set i 1
            set customer_code_orig $customer_code
            set id_from_customer_code [qal_customer_id_from_code $customer_code]
            while { ( $id_from_customer_code ne "" && $id_from_customer_code ne $id ) && $i < 1000 } {
                incr i
                set chars_max [expr { 31 - [string length $i] } ]
                set customer_code [string range $customer_code_orig 0 $chars_max]
                append customer_code "-" $i
                set id_from_customer_code [qal_customer_id_from_code $customer_code]
            }
            db_dml qal_customer_create_1 "insert into qal_customer \
 ([qal_customer_keys ","]) values ([qal_customer_keys ",:"])"
        }
    }
    return $id

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
                set validated_p [hf_natural_number_list_validate $customer_id_list]
            } else {
                set validated_p 0
            }
            if { $validated_p } {
                db_transaction {
                    db_dml qal_customer_ids_delete "delete from qal_customer \
                            where instance_id=:instance_id and customer_id in \
                            ([template::util::tcl_to_sql_list $customer_id_list]) "
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
    customer_id_list
} {
    Trash one or more customer records
} {
    set success_p 0
    if { $customer_id_list ne "" } {
        set user_id [ad_conn user_id]
        set instance_id [qc_set_instance_id]
        set customer_id_list_len [llength $customer_id_list]
        if { $customer_id_list_len > 0 } {
            set validated_p [hf_natural_number_list_validate $customer_id_list]
        } else {
            set validated_p 0
        }
        if { $validated_p } {
            set instance_write_p [qc_permission_p $user_id $instance_id non_assets write $instance_id]
            if { $instance_write_p } {
                set filtered_customer_id_list $customer_id_list
            } else {
                set filtered_customer_id_list [list ]
                set at_least_one_write_p 0
                foreach customer_id $customer_id_list {
                    if { [qc_permission_p $user_id $customer_id non_assets write $instance_id] } {
                        set at_least_one_write_p 1
                        lappend filtered_customer_id_list $customer_id
                    }
                }
            } 
            if { $instance_write_p || $at_least_one_write_p } {
                set success_p 1
                db_transaction {
                    db_dml qal_customer_ids_trash "update qal_customer \
                            set trashed_p='1',trashed_by=:user_id,trashed_ts=now() \
                            where instance_id=:instance_id and trashed_p!='1' and customer_id in \
                            ([template::util::tcl_to_sql_list $filtered_customer_id_list])"
                } on_error {
                    set success_p 0
                }
            }
        }
    }
    return $success_p
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
    set error_p 0
    qal_vendor_defaults arr_name
    qf_array_to_vars arr_name [qal_contact_keys]

    # validations etc
    if { ![qf_is_natural_number $id] } {
        set id ""
    }
    if { ![qf_is_natural_number $contact_id] } {
        set contact_id ""
    }
    if { ![qf_is_decimal $terms] } {
        set terms ""
    }

    set terms_unit [string range $terms_unit 0 19]

    set tax_included [qf_is_true $tax_included]

    set vendor_code [string range $vendor_code 0 31]

    set gifi_accno [string range $gifi_accno 0 29]

    if { ![qf_is_decimal $discount] } {
        set discount ""
    }

    if { ![qf_is_decimal $credit_limit] } {
        set credit_limit ""
    }

    if { ![qf_is_natural_number $pricegroup_id] } {
        set pricegroup_id ""
    }

    set created_s [qf_clock_scan $created]
    if { $created_s eq "" } {
        set created_s [clock seconds]
    }
    set created [qf_clock_format $created_s ]
    # insert into db
    if { ![qf_is_natural_number $id] } {
        # record revision/new
        set id [application_group::new -package_id $instance_id -group_name "vendor_num_for_contact_${contact_id}"]
        #  now_yyyymmdd_hhmmss
        set time_start [clock format [clock seconds] -format "%Y%m%d %H%M%S"]
    } 
    if { $error_p } {
        ns_log Warning "qal_vendor_write: rejected '[array get arr_name]'"
    } else {

        set rev_id [db_nextval qal_id]
        set created [clock format [clock seconds] -format "%Y%m%d %H%M%S"]
        if { [ns_conn isconnected] } {
            set created_by [ad_conn user_id]
        } else {
            set created_by $user_id
        } 

        set trashed_p 0
        set trashed_by ""
        set trashed_ts ""
        db_transaction {
            if { !$create_p } {
                db_dml qal_vendor_trash { update qal_vendor set trashed_p='1',trashed_by=:user_id,trashed_ts=now() where id=:id
                }
            }
            # Make sure vendor_code is unique
            set i 1
            set vendor_code_orig $vendor_code
            set id_from_vendor_code [qal_vendor_id_from_code $vendor_code]
            while { ( $id_from_vendor_code ne "" && $id_from_vendor_code ne $id ) && $i < 1000 } {
                incr i
                set chars_max [expr { 31 - [string length $i] } ]
                set vendor_code [string range $vendor_code_orig 0 $chars_max]
                append vendor_code "-" $i
                set id_from_vendor_code [qal_vendor_id_from_code $vendor_code]
            }
            db_dml qal_vendor_create_1 "insert into qal_vendor \
 ([qal_vendor_keys ","]) values ([qal_vendor_keys ",:"])"
        }
    }
    return $id
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
                set validated_p [hf_natural_number_list_validate $vendor_id_list]
            } else {
                set validated_p 0
            }
            if { $validated_p } {
                db_transaction {
                    db_dml qal_vendor_ids_delete "delete from qal_vendor \
                            where instance_id=:instance_id and vendor_id in \
                            ([template::util::tcl_to_sql_list $vendor_id_list])"
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
    vendor_id_list
} {
    Trash one or more vendor records
} {
    set success_p 0
    if { $vendor_id_list ne "" } {
        set user_id [ad_conn user_id]
        set instance_id [qc_set_instance_id]
        set vendor_id_list_len [llength $vendor_id_list]
        if { $vendor_id_list_len > 0 } {
            set validated_p [hf_natural_number_list_validate $vendor_id_list]
        } else {
            set validated_p 0
        }
        if { $validated_p } {
            set instance_write_p [qc_permission_p $user_id $instance_id non_assets write $instance_id]
            if { $instance_write_p } {
                set filtered_vendor_id_list $vendor_id_list
            } else {
                set filtered_vendor_id_list [list ]
                set at_least_one_write_p 0
                foreach vendor_id $vendor_id_list {
                    if { [qc_permission_p $user_id $vendor_id non_assets write $instance_id] } {
                        set at_least_one_write_p 1
                        lappend filtered_vendor_id_list $vendor_id
                    }
                }
            } 
            if { $instance_write_p || $at_least_one_write_p } {
                set success_p 1
                db_transaction {
                    db_dml qal_vendor_ids_trash "update qal_vendor \
                            set trashed_p='1',trashed_by=:user_id,trashed_ts=now() \
                            where instance_id=:instance_id and trashed_p!='1' and vendor_id in \
                            ([template::util::tcl_to_sql_list $filtered_vendor_id_list])"
                } on_error {
                    set success_p 0
                }
            }
        }
    }
    return $success_p
}
