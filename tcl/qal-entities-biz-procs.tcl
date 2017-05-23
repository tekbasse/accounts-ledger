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




ad_proc -public qal_contact_create {
    arr_name
    {contact_id ""}
} {
    Creates a new qal_contact record. 
    If contact_id is not "", replaces arr_name(contact_id) with value.
    Returns contact_id, or empty string if there was a problem.
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name c_arr
    if { [qf_is_natural_number $contact_id] } {
        set c_arr(contact_id) $contact_id
    }
    # at a minimum, object_id needs to be used to prevent id collision with other packages:

    set c_arr(id) ""
    set id [qal_contact_write c_arr]
    return $id
}

ad_proc -public qal_contact_write {
    arr_name
    {contact_id ""}
} {
    Writes a new revision to an existing qal_contact record.
    If id is empty, creates a new record and returns new id.
    Otherwise empty string is returned.
    If contact_id is not "", replaces arr_name(contact_id) with value.

    @param array_name
    @return id or ""
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr
    set error_p 0
    qal_contact_defaults a_arr
    qf_array_to_vars a_arr [qal_contact_keys]

    set a_arr(contact_id) ""

    # validations etc
    if { [qf_is_natural_number $contact_id] } {
        set a_arr(contact_id) $contact_id
        # enforce reference sanity
        set id $a_arr(contact_id)
    }

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
    if { $time_start ne "" } {
        set time_start_s [qf_clock_scan $time_start]
        set time_start [qf_clock_format $time_start_s ]
    }
    if { $time_end ne "" } {
        set time_end_s [qf_clock_scan $time_end]
        if { $time_end_s ne "" } {
            set time_end [qf_clock_format $time_end_s ]
        }
    }

    if { [hf_are_safe_and_printable_characters_q $url] } {
        if  { ![util_url_valid_p $url ] } {
            set url2 "http://"
        } else {
            set url2 ""
        }
        append url2 $url
        set url2 [ns_absoluteurl $url2 [ad_url]]
    } else {
        set url2 [ns_absoluteurl $url2 [ad_url]]
    }
    set url [string range $url2 0 198]

    if { ![qf_is_natural_number $user_id] } {
        if { [ns_conn isconnected] } {
            set user_id [ad_conn user_id]
        } else {
            set user_id $instance_id
        }
    }


    # insert into db
    if { ![qf_is_natural_number $id] } {
        # record revision/new
        # In the openacs permissions system, a contact is a party that can represent a group or a person.
        # The email address of a party must be unique within an OpenACS system (or be empty string).
        # So, email is not passed to the party object. email is stored in qal_contact
        # party_type is group, because some contacts may be members of other contacts
        # Here is a rough outline:
        #  set group_arr(join_policy) "closed"
        #  set id party::new -context_id $instance_id -email "" group 
        # pps. Initial tests suggest above line fails with group_name null yet constrained to not null.
        #  group::update -group_id $id -array group_arr
        #  set group_arr(group_name) $label
        # Having a contact group for this party makes it easier to manage complex memberships 
        #  set contact_grp_id group::new -context_id $instance_id -group_name $label -pretty_name $name qal_grp_contacts
        #  group::update -group_id $contact_grp_id -array group_arr
        ##code later. Must make contact_grp_id a member of id for OpenACS permissions
        set id [db_nextval acs_object_id_seq]

        # Not write, create
        set create_p 1

    } else {
        set create_p 0
    }

    if { $error_p } {
        ns_log Warning "qal_contact_write: rejected '[array get a_arr]'"
    } else {

        set rev_id [db_nextval qal_id]

        set created_s [qf_clock_scan $created]
        set created [qf_clock_format $created_s ]

        if { [ns_conn isconnected] } {
            set created_by [ad_conn user_id]
        } else {
            set created_by $user_id
        } 

        set trashed_p 0
        set trashed_by ""
        set trashed_ts ""


        db_transaction {
            if { $create_p } {
                set created [qf_clock_format [clock seconds]]
            } else {
                if { $created eq "" } {
                    db_0or1row qal_contact_created_r1 {
                        select created from qal_contact 
                        where id=:id 
                        and trashed_p!='1'
                        and instance_id=:instance_id }
                }
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
            ns_log Notice "qal_contact_create.213: created '${created}' qf_clock_scan -> '[qf_clock_scan $created]' qf_clock_scan_from_db -> '[qf_clock_scan_from_db $created]'"
            db_dml qal_contact_create_1 "insert into qal_contact \
 ([qal_contact_keys ","]) values ([qal_contact_keys ",:"])"
        }
    }
    return $id
}

ad_proc -public qal_contact_delete {
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
                    db_dml qal_address_ids_delete "delete from qal_address \
                        where id in (select address_id from qal_other_address_map \
                        where instance_id=:instance_id and contact_id in \
                        ([template::util::tcl_to_sql_list $contact_id_list]) ) "
                    d_dml qal_other_address_map_delete " \
                        delete from qal_other_address_map \
                        where instance_id=:instance_id and contact_id in \
                        ([template::util::tcl_to_sql_list $contact_id_list]) "
                    db_dml qal_customer_ids_delete "delete from qal_customer \
                        where instance_id=:instance_id and contact_id in \
                        ([template::util::tcl_to_sql_list $contact_id_list]) "
                    db_dml qal_vendor_ids_delete "delete from qal_vendor \
                        where instance_id=:instance_id and contact_id in \
                        ([template::util::tcl_to_sql_list $contact_id_list]) "
                    db_dml qal_contact_ids_delete "delete from qal_contact \
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

ad_proc -public qal_contact_trash {
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
                    d_dml qal_other_address_map_trash " \
                        update qal_other_address_map \
                        set trashed_p='1',trashed_by=:user_id,trashed_ts=now() \
                        where instance_id=:instance_id and contact_id in \
                        ([template::util::tcl_to_sql_list $contact_id_list]) "
                    db_dml qal_customer_ids_trash "update qal_customer \
                        set trashed_p='1',trashed_by=:user_id,trashed_ts=now() \
                        where instance_id=:instance_id and contact_id in \
                        ([template::util::tcl_to_sql_list $contact_id_list]) "
                    db_dml qal_vendor_ids_trash "update qal_vendor \
                        set trashed_p='1',trashed_by=:user_id,trashed_ts=now() \
                        where instance_id=:instance_id and contact_id in \
                        ([template::util::tcl_to_sql_list $contact_id_list]) "
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


ad_proc -public qal_customer_create {
    arr_name
    {contact_id ""}
} {
    Creates a new qal_customer record.
    If contact_id is supplied, sets arr_name(contact_id) to contact_id's value.
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr
    if { [qf_is_natural_number $contact_id ]} {
        set a_arr(contact_id) $contact_id
    }
    # at a minimum, object_id needs to be used to prevent id collision with other packages:

    set a_arr(id) ""
    set id [qal_customer_write a_arr]
    return $id
}

ad_proc -public qal_customer_write {
    arr_name
    {contact_id ""}
} {
    Writes a new revision to an existing qal_customer record.
    If contact_id doesn't have a customer_id, a new customer record is created and returns new id (customer_id).
    If contact_id or id is provided, record is updated.
    Otherwise empty string is returned.
    If contact_id is supplied, sets arr_name(contact_id) to contact_id's value.

    @param arr_name
    @param contact_id arr_name(contact_id) or arr_name(id) (id customer_id)
    @return id or ""
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr

    set error_p 0
    qal_customer_defaults a_arr
    qf_array_to_vars a_arr [qal_customer_keys]

    ns_log Notice "qal_customer_write.351 contact_id '${contact_id}' id '${id}'"
    if { [qf_is_natural_number $contact_id] } {
        set a_arr(contact_id) $contact_id
    } else {
        set contact_id ""
    }

    # validations etc

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
    set created [qf_clock_format $created_s ]

    # Sanity check refrences id and contact_id
    # Contact_id takes presedence because of possible association with permissions
    ns_log Notice "qal_customer_write.394. contact_id '${contact_id}' id '${id}' "
    if { [qf_is_natural_number $contact_id ] } {
        set contact_id_exists_p [qal_contact_id_exists_q $contact_id]
    } else {
        set contact_id ""
        set contact_id_exists_p 0
    }
    ns_log Notice "qal_customer_write.401. contact_id '${contact_id}' id '${id}' contact_id_exists_p '${contact_id_exists_p}'"
    if { [qf_is_natural_number $id] } {
        set contact_id_from_cu_id [qal_contact_id_from_customer_id $id]
    } else {
        set id ""
        set contact_id_from_cu_id ""
    }
    ns_log Notice "qal_customer_write.408. contact_id '${contact_id}' id '${id}' contact_id_exists_p '${contact_id_exists_p}' contact_id_from_cu_id '${contact_id_from_cu_id}'"
    if { $contact_id_exists_p } {
        if { $contact_id_from_cu_id ne $contact_id } {
            set id [qal_customer_id_from_contact_id $contact_id]
            set contact_id_from_cu_id $contact_id
        }
    } else {
        # contact_id does not exist
        if { $id eq "" } {
            set error_p 1
            ns_log Warning "qal_customer_write.412: Unable to write. reference issue contact_id '${contact_id}' (customer) id '${id}' instance_id '${instance_id}' customer_code '${customer_code}'"
        } else {
            set contact_id $contact_id_from_cu_id
        }
    }
    ns_log Notice "qal_customer_write.423. contact_id '${contact_id}' id '${id}' contact_id_exists_p '${contact_id_exists_p}' contact_id_from_cu_id '${contact_id_from_cu_id}' error_p '${error_p}'"
    if { !$error_p } {
        
        # insert into db
        if { $id eq "" } {
            # record revision/new
            
            set customer_label "qal_customer "
            # Use contact_id instead of contact_id's label, because id is static.
            append customer_label $contact_id
            
            # Create an OpenACS group for party_id customers
            # Having a customer group for the contact party makes it easier to manage user memberships in bulk
            # In any case, id must be an object_id to avoid id collisions
            # Here is an outline of code to implement OpenACS permissions. Incomplete and with errors.
            #  set id group::new -context_id $instance_id -group_name $customer_label -pretty_name $name qal_grp_customers
            #  set group_arr(join_policy) "closed"
            #  set group_arr(group_name) $customer_label
            #  group::update -group_id $id -array group_arr
            ##code later. Make this group id a member of customer_id for OpenACS permissions
            set id [db_nextval acs_object_id_seq]
            
            set create_p 1
        } else {
            set create_p 0
        }
    }

    if { $error_p } {
        ns_log Warning "qal_customer_write.425: error '[array get a_arr]'"
    } else {

        set rev_id [db_nextval qal_id]
        if { [ns_conn isconnected] } {
            set user_id [ad_conn user_id]
        } else {
            set user_id $instance_id
        } 
        set created_by $user_id
        set trashed_p 0
        set trashed_by ""
        set trashed_ts ""
        db_transaction {
            if { $create_p } {
                set created [qf_clock_format [clock seconds]]
            } else {
                if { $created eq "" } {
                    db_0or1row qal_customer_created_r1 {
                        select created from qal_customer 
                        where id=:id 
                        and trashed_p!='1'
                        and instance_id=:instance_id }
                }
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
        # If we wanted the original array to return any changed values, add here:
        # qf_vars_to_array qal_customer_keys a_arr
    }
    return $id
}

ad_proc -public qal_customer_delete {
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


ad_proc -public qal_customer_trash {
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


ad_proc -public qal_vendor_create {
    arr_name
    {contact_id ""}
} {
    Creates a new qal_vendor record.
    If contact_id is supplied, sets arr_name(contact_id) to contact_id's value.
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name v_arr
    if { $contact_id ne "" } {
        set v_arr(contact_id) $contact_id
    }
    # at a minimum, object_id needs to be used to prevent id collision with other packages:

    set v_arr(id) ""
    set id [qal_vendor_write v_arr]
    return $id
}


ad_proc -public qal_vendor_write {
    arr_name
    {contact_id ""}
} {
    Writes a new revision to an existing qal_vendor record.
    If contact_id doesn't have a vendor_id, a new vendor record is created and returns new id (vendor_id).
    If contact_id or id is provided, record is updated.
    Otherwise empty string is returned.
    If contact_id is supplied, sets arr_name(contact_id) to contact_id's value.

    @param arr_name
    @param contact_id arr_name(contact_id) or arr_name(id) (id vendor_id)
    @return id or ""
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr

    set error_p 0
    qal_vendor_defaults a_arr
    qf_array_to_vars a_arr [qal_vendor_keys]

    ns_log Notice "qal_vendor_write.624 contact_id '${contact_id}'"
    if { [qf_is_natural_number $contact_id] } {
        set a_arr(contact_id) $contact_id
    } else {
        set contact_id ""
    }

    # validations etc
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
    set created [qf_clock_format $created_s ]
    # Sanity check refrences id and contact_id
    # Contact_id takes presedence because of possible association with permissions
    ns_log Notice "qal_vendor_write.394. contact_id '${contact_id}' id '${id}' "
    if { [qf_is_natural_number $contact_id ] } {
        set contact_id_exists_p [qal_contact_id_exists_q $contact_id]
    } else {
        set contact_id ""
        set contact_id_exists_p 0
    }
    ns_log Notice "qal_vendor_write.401. contact_id '${contact_id}' id '${id}' contact_id_exists_p '${contact_id_exists_p}'"
    if { [qf_is_natural_number $id] } {
        set contact_id_from_ve_id [qal_contact_id_from_vendor_id $id]
    } else {
        set id ""
        set contact_id_from_ve_id ""
    }
    ns_log Notice "qal_vendor_write.408. contact_id '${contact_id}' id '${id}' contact_id_exists_p '${contact_id_exists_p}' contact_id_from_ve_id '${contact_id_from_ve_id}'"
    if { $contact_id_exists_p } {
        if { $contact_id_from_ve_id ne $contact_id } {
            set id [qal_vendor_id_from_contact_id $contact_id]
            set contact_id_from_ve_id $contact_id
        }
    } else {
        # contact_id does not exist
        if { $id eq "" } {
            set error_p 1
            ns_log Warning "qal_vendor_write.412: Unable to write. reference issue contact_id '${contact_id}' (vendor) id '${id}' instance_id '${instance_id}' vendor_code '${vendor_code}'"
        } else {
            set contact_id $contact_id_from_ve_id
        }
    }
    ns_log Notice "qal_vendor_write.423. contact_id '${contact_id}' id '${id}' contact_id_exists_p '${contact_id_exists_p}' contact_id_from_ve_id '${contact_id_from_ve_id}' error_p '${error_p}'"
    if { !$error_p } {
        
        # insert into db
        if { $id eq "" } {
            # record revision/new
            set vendor_label "qal_vendor "
            append vendor_label $contact_id

            # Create an OpenACS group for party_id vendors
            # Having a vendor group for the contact party makes it easier to manage user memberships in bulk
            # In any case, id must be an object_id to avoid id collisions
            #  set id group::new -context_id $instance_id -group_name $vendor_label -pretty_name $name qal_grp_vendors
            #  set group_arr(join_policy) "closed"
            #  set group_arr(group_name) $vendor_label
            #  group::update -group_id $id -array group_arr
            ##code later. Must make this id a member of vendor_id
            set id [db_nextval acs_object_id_seq]

            set create_p 1
        } else {
            set create_p 0
        }
    }
    if { $error_p } {
        ns_log Warning "qal_vendor_write.660: error '[array get a_arr]'"
    } else {

        set rev_id [db_nextval qal_id]
        if { [ns_conn isconnected] } {
            set user_id [ad_conn user_id]
        } else {
            set user_id $instance_id
        } 
        set created_by $user_id
        set trashed_p 0
        set trashed_by ""
        set trashed_ts ""
        db_transaction {
            if { $create_p } {
                set created [qf_clock_format [clock seconds]]
            } else {
                if { $created eq "" } {
                    db_0or1row qal_vendor_created_r1 {
                        select created from qal_vendor 
                        where id=:id 
                        and trashed_p!='1'
                        and instance_id=:instance_id }
                }
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

ad_proc -public qal_vendor_delete {
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


ad_proc -public qal_vendor_trash {
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

ad_proc -private qal_address_postal_create {
    arr_name
} {
    Creates a qal_address record.
    @param array_name

    @see qal_address_create
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr
    set error_p 0
    qal_address_defaults a_arr
    qf_array_to_vars a_arr [qal_address_keys]

    # validations etc
    set address_type [string range $address_type 0 19]
    set address0 [string range $address0 0 39]
    set address1 [string range $address1 0 39]
    set address2 [string range $address2 0 39]
    set city [string range $city 0 39]
    set state [string range $state 0 31]
    set postal_code [string range $postal_code 0 19]
    set country_code [string range $country_code 0 2]
    set attn [string range $attn 0 63]
    set phone [string range $phone 0 29]
    set phone_time [string range $phone_time 0 9]
    set fax [string range $fax 0 29]
    regsub -all -- {[^[:graph:]\ ]+} $email {} email
    regsub -all -- {[^[:graph:]\ ]+} $cc {} cc
    regsub -all -- {[^[:graph:]\ ]+} $bcc {} bcc

    # insert into db
    set id [db_nextval qal_id]
    db_dml qal_address_postal_create_1 "insert into qal_address \
 ([qal_address_keys ","]) values ([qal_address_keys ",:"])"
    return $id
}




ad_proc -public qal_address_create {
    arr_name
    {contact_id ""}
} {
    Creates a new qal_address record. 
    If contact_id is not supplied, the value is assumed to be in arr_name(contact_id).
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr
    if { $contact_id ne "" } {
        set a_arr(contact_id) $contact_id
    }
    # at a minimum, object_id needs to be used to prevent id collision with other packages:

    set a_arr(id) ""
    set id [qal_address_write a_arr]
    return $id
}



ad_proc -public qal_address_write {
    arr_name
    {contact_id ""}
} {
    Writes a new revision to an existing qal_address record.
    If id is empty, creates a new record and returns the new id.
    Otherwise empty string is returned.
    If contact_id is not supplied, the value is assumed to be in arr_name(contact_id).
    <br/><br/>
    If address_type matches "*address*" then type is assumed to be a postal address.
    <br/><br/>
    Postal address_types: 
    street_address, mailing_address, billing_address and anything that matches *address*.
    <br/><br/>
    Postal address fields: 
    record_type sort_order address_type address0 address1 address2 city state postal_code country_code attn phone phone_time fax email cc bcc
    <br/><br/>
    If postal address is contact's first street_address, mailing_address, or billing address, then automatically maps to contact record via qal_contact.street_addrs_id etc.
    </br>For other cases, app should change via qal_set_primary_address

    <br/><br/>
    Other addresses can be most anything: twitter, phone, etc.
    <br/><br/>
    Other address fields: 
    record_type sort_order account_name notes
    <br/><br/>


    @param array_name
    @return qal_other_address_map.id or ""

    @see qal_set_primary_address
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name a_arr
    if { $contact_id ne "" } {
        set a_arr(contact_id) $contact_id
    }
    qal_other_address_map_defaults a_arr
    qf_array_to_vars a_arr [qal_other_address_map_keys]

    # validations etc
    if { ![qf_is_natural_number $contact_id] } {
        set contact_id ""
    }
    if { ![qf_is_natural_number $addrs_id] } {
        set addrs_id [db_nextval qal_id]
        set create_p 1
    } else {
        set create_p 0
    }

    set record_type [string range $record_type 0 29]
    if { ![qf_is_natural_number $address_id] } {
        set address_id ""
    }
    if { ![qf_is_natural_number $sort_order] } {
        db_1row qal_other_address_map_c_recs_ct {select count(*) as addrs_id_ct from qal_other_address_map where instance_id=:instance_id and contact_id=:contact_id}
    }
    
    set created_s [qf_clock_scan $created]
    set created [qf_clock_format $created_s ]
    if { [ns_conn isconnected] } {
        set created_by [ad_conn user_id]
    } else {
        set created_by $instance_id
    }

    set postal_address_p 0
    if { [string match -nocase "address" $record_type] } {
        set postal_address_p 1
    }
    set trashed_p 0
    set trashed_by ""
    set trashed_ts ""
    db_transaction {
        if { $create_p } {
            set created [qf_clock_format [clock seconds]]
        } else {
            if { $created eq "" } {
                db_0or1row qal_contact_created_r1 {
                    select created from qal_contact 
                    where id=:id 
                    and trashed_p!='1'
                    and instance_id=:instance_id }
            }
            db_dml qal_address_trash { update qal_address set trashed_p='1',trashed_by=:user_id,trashed_ts=now() 
                where addrs_id=:addrs_id 
                and contact_id=:contact_id
                and instance_id=:instance_id
            }
        }
        if { $postal_address_p } {
            set address_id [qal_postal_address_postal_write a_arr]
        }
        db_dml qal_address_create_1 "insert into qal_other_address_map \
 ([qal_other_address_map_keys ","]) values ([qal_other_address_map_keys ",:"])"
    }

    return $addrs_id
}

ad_proc -public qal_address_delete {
    addrs_id_list
} {
    Deletes records.
    addrs_id_list may be a one qal_contact.*_addrs_id or a list, where * is street, mailing or billing.
    User must be a package admin.
} {
    set success_p 1
    if { $address_id_list ne "" } {
        set user_id [ad_conn user_id]
        set instance_id [qc_set_instance_id]
        set admin_p [permission::permission_p -party_id $user_id \
                         -object_id [ad_conn package_id] -privilege admin]
        set success_p $admin_p
        if { $admin_p } {
            if { [llength $address_id_list] > 0 } {
                set validated_p [hf_natural_number_list_validate $address_id_list]
            } else {
                set validated_p 0
            }
            if { $validated_p } {
                db_transaction {
                    set address_id_list [db_list qal_address_id_2_d \
                                             "select address_id from qal_other_address_map \
                         where instance_id=:instance_id \
                         and addrs_id in ([template::util::tcl_to_sql_list $addrs_id_list])"]
                    if { [string length $address_id_list ] > 0 } {
                        db_dml qal_address_ids_delete "delete from qal_address \
                            where instance_id=:instance_id and address_id in \
                             ([template::util::tcl_to_sql_list $address_id_list])"
                    }
                    db_dml qal_addrs_ids_delete "delete from qal_address \
                            where instance_id=:instance_id and addrs_id in \
                            ([template::util::tcl_to_sql_list $addrs_id_list])"
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


ad_proc -public qal_address_trash {
    addrs_id_list
} {
    Trash one or more qal_contact.*_addrs_id address records, where * is street, mailing or billing.
} {
    set success_p 0
    if { $address_id_list ne "" } {
        set user_id [ad_conn user_id]
        set instance_id [qc_set_instance_id]
        set address_id_list_len [llength $address_id_list]
        if { $address_id_list_len > 0 } {
            set validated_p [hf_natural_number_list_validate $address_id_list]
        } else {
            set validated_p 0
        }
        if { $validated_p } {
            set instance_write_p [qc_permission_p $user_id $instance_id non_assets write $instance_id]
            if { $instance_write_p } {
                set filtered_address_id_list $address_id_list
            } else {
                set filtered_address_id_list [list ]
                set at_least_one_write_p 0
                foreach address_id $address_id_list {
                    if { [qc_permission_p $user_id $address_id non_assets write $instance_id] } {
                        set at_least_one_write_p 1
                        lappend filtered_address_id_list $address_id
                    }
                }
            } 
            if { $instance_write_p || $at_least_one_write_p } {
                set success_p 1
                set null ""
                db_transaction {
                    db_dml qal_addrs_ids_trash "update qal_other_address_map \
                            set trashed_p='1',trashed_by=:user_id,trashed_ts=now() \
                            where instance_id=:instance_id and trashed_p!='1' and addrs_id in \
                            ([template::util::tcl_to_sql_list $filtered_address_id_list])"
                    db_dml qal_street_addrs_ids_trash "update qal_contact \
                            set street_addrs_id=:null
                             where instance_id=:instance_id and trashed_p!='1' and street_addrs_id in \
                            ([template::util::tcl_to_sql_list $filtered_address_id_list])"
                    db_dml qal_mailing_addrs_ids_trash "update qal_contact \
                            set mailing_addrs_id=:null
                             where instance_id=:instance_id and trashed_p!='1' and mailing_addrs_id in \
                            ([template::util::tcl_to_sql_list $filtered_address_id_list])"
                    db_dml qal_billing_addrs_ids_trash "update qal_contact \
                            set billing_addrs_id=:null
                             where instance_id=:instance_id and trashed_p!='1' and billing_addrs_id in \
                            ([template::util::tcl_to_sql_list $filtered_address_id_list])"
                } on_error {
                    set success_p 0
                }
            }
        }
    }
    return $success_p
}

ad_proc -public qal_address_postal_set_primary {
    contact_id
    addrs_id
    {address_type ""}
    {postal_constraint_p "1"}
} {
    Set the primary postal address for contact_id. 
    Address type is one of: street_address mailing_address or billing_address
    corresponding to qal_contact.street_addrs_id, mailing_addrs_id, or billing_addrs_id.

    If address_type is other than a postal address type, address_type is set to the addrs_id's address_type.


    If postal_constraint_p is "0", then any address type can be assigned to
    the contact's primary postal address.
    Returns 1 if successful, otherwise returns 0.
} {
    upvar1 instance_id instance_id
    # supplied address_type is target address type
    set success_p 0
    set address_type_new ""
    set postal_go_p 1
    set address_type_new [qal_address_type $addrs_id $contact_id]
    set is_postal_p [qal_address_type_is_postal_q $address_type_new]
    if { $postal_constraint_p } {
        if { $is_postal_p } {
            ns_log Notice "qal_address_postal_set_primary.987: address_type_new '${address_type_new}' not a postal address. Ignored for instance_id '${instance_id}' contact_id '${contact_id}' addrs_id '${addrs_id}' address_type '${address_type}'."
            set postal_go_p 0
        }
    }
    
    if { $is_postal_p && $postal_go_p && $address_type_new ne "" } {
        # target address validated

        set co_list [qal_contact_read $contact_id]
        if { [llength $co_list > 0 ] } {
            # contact record exists
            array set co_arr $co_list
            set ati [qal_field_name_of_address_type $address_type]
            set co_arr(${ati}) $addrs_id

            set updated_q [qal_contact_write co2_arr ]
            if { $updated_q ne "" } {
                set success_p 1
            }
        }
    }
    return $success_p
}
