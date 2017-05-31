ad_library {
    Automated tests for accounts-ledger
    @creation-date 2017-05-24
}

aa_register_case -cats {api smoke} qal_addresses_check {
    Test qal addresses proces ie in context of a contact for CRUD consistency
} {
    aa_run_with_teardown \
        -test_code {
            # -rollback \
                        ns_log Notice "aa_register_case.13: Begin test contact_check"

                        set instance_id [qc_set_instance_id]
                        # use the sysadmin user, because we aren't testing permissions
                        set sysowner_email [ad_system_owner]
                        set sysowner_user_id [party::get_by_email -email $sysowner_email]
                        set user_id $sysowner_user_id
                        set this_user_id [ad_conn user_id]
                        set org_admin_id [qc_role_id_of_label org_admin $instance_id]
                        ns_log Notice "qal-entities-procs.tcl.21: this_user_id ${this_user_id}' org_admin_id '${org_admin_id}' user_id '${user_id}' instance_id '${instance_id}'"

                        # CRURTRDR tests for contact, customer, vendor
                        #    C=Create, R=Read, U=Update T=Trash D=Delete
                        #

                        # co = contact, cu = customer, ve = vendor
                        set create_start_cs [clock seconds]
                        set co_id [qal_demo_contact_create contact_arr "" $user_id]
                        set co_created_p [qf_is_natural_number $co_id] 
                        if { $co_created_p } {
                            set perm_granted_p [qc_user_role_add $co_id $this_user_id $org_admin_id $instance_id]
                        }
                        ns_log Notice "qal-entities-procs.tcl.34: this_user_id ${this_user_id}' org_admin_id '${org_admin_id}' user_id '${user_id}' instance_id '${instance_id}'"
                        aa_true "A1 Created a contact" $co_created_p

                        # plan is to loop through:
                        # make/save an address
                        #  verify
                        # do one of edit, trash or delete: 
                        # one of the existing addresses
                        #  verify
                        # 
                        # continue loop until all tests have been performed:
                        # 1 address delete of postal and nonpostal types
                        # 1 address trash of postal and nonpostal types
                        # 1 address edit of postal and nonpostal types


                        set record_type_list [qal_address_type_keys]
                        # An empty type tells demo to make one up..
                        lappend record_type_list ""

                        # apt = address postal type
                        # ant = address nonpostal type
                        set apt_delete_p 1
                        set apt_trash_p 1
                        set apt_edit_p 1
                        set ant_delete_p 1
                        set ant_trash_p 1
                        set ant_edit_p 1
                        set more_to_test_p [expr { $apt_delete_p \
                                                       || $apt_trash_p \
                                                       || $apt_edit_p \
                                                       || $ant_delete_p \
                                                       || $ant_trash_p \
                                                       || $ant_edit_p } ]
                        set actions_list [list create edit trash delete]
                        set actions_list_len_1 [llength $actions_list]
                        incr actions_list_len -1
                        set i 0
                        while { $more_to_test_p && $i < 50 } {
                            ns_log Notice "qal-entities-procs.tcl.73: this_user_id ${this_user_id}' org_admin_id '${org_admin_id}' user_id '${user_id}' instance_id '${instance_id}'"
                            set a_idx [randomRange 3]
                            set addrs_arr(record_type) [lindex $record_type_list $a_idx]
                            set addrs_id [qal_demo_address_write addrs_arr $co_id]
                            # ref x0x0 start
                            set addrs_id_is_nbr_p [qf_is_natural_number $addrs_id]
                            aa_true "A1.1 qal_demo_address_write returns a valid addrs_id '${addrs_id}'" $addrs_id_is_nbr_p
                            
                            set record_type [qal_address_type $addrs_id ]
                            set record_type2 [qal_address_type $addrs_id $co_id]
                            aa_equals "A1.2 qal_address_type calls are consistent record_type '${record_type}' record_type2 '${record_type2}'" $record_type $record_type2
                            if { $addrs_arr(record_type) ne "" } {
                                # filter out cases that we leave to qal_demo_address_write to make
                                aa_equals "A1.3 qal_address_type from db matches expected/specified type" $record_type $addrs_arr(record_type)
                            } else {
                                if { $record_type eq "other" } {
                                    set blank_to_other_p 1
                                } else {
                                    set blank_to_other_p 0
                                }
                                aa_true "A1.3.b qal_address_type returns 'other' when demo submits ''" $blank_to_other_p 
                            }
                            set addrs2_list [qal_address_read $addrs_id]
                            array unset addrs2_arr
                            array set addrs2_arr $addrs2_list
                            # compare i/o
                            set addrs2_keys_list [array names addrs2_arr]
                            if { [llength $addrs2_keys_list] > 0 } {
                                foreach key $addrs2_keys_list {
                                    aa_equals "A1.4 qal_address_read returns same as written with qal_address_write for key '${key}'" $addrs2_arr(${key}) $addrs_arr(${key})
                                    
                                }
                            } else {
                                aa_true "A1.4b qal_address_read returns a full address record" 0
                            }
                            
                            # set sets of addresses for retesting
                            if { $addrs_id_is_nbr_p } {
                                set addrs_id_is_apt_p_arr(${addrs_id}) [qal_address_type_is_postal_q $record_type] 
                                lappend addrs_ids_list $addrs_id
                                set deleted_p_arr(${addrs_id}) 0
                                set trashed_p_arr(${addrs_id}) 0
                            }

                            # ref x0x0 end
   
                            #
                            #  Choose one test
                            #
                            set addrs_ids_list_len_1 [llength $addrs_ids_list]
                            incr addrs_ids_list_len_1 -1
                            set addrs_id [lindex $addrs_ids_list [randomRange $addrs_ids_list_len_1]]
                            
                            if { [qal_address_type_is_postal_q $record_type] } {
                                set do "apt"
                            } else {
                                set do "ant"
                            }
                            set action [lindex $actions_list [randomRange $actions_list_len_1]]
                            append do "_" $action

                            # params: action co_id addrs_id
                            ns_log Notice "qal-addresses-procs.tcl.133: unit test: do '${do}'"
                            switch -exact -- $do {
                                apt_edit {
                                    array unset addrs_arr
                                    set addrs_list [qal_address_read $addrs_id]
                                    array set addrs_arr $addrs_list
                                    set addrs_id2 [qal_demo_address_write addrs_arr $co_id $addrs_id]
                                    set treat_as_edit_p 1
                                    if { $addrs_id2 ne $addrs_id } {
                                        # did this edit result in the creation of a new address?
                                        set record_type_id1 [qal_address_type $addrs_id]
                                        set record_type_id2 [qal_address_type $addrs_id2]
                                        set is_postal_id1 [qal_address_type_is_postal_q $record_type_id1]
                                        set is_postal_id2 [qal_address_type_is_postal_q $record_type_id2]
                                        if { $is_postal_id1 eq $is_postal_id2 } {
                                            set treat_as_edit_p 1
                                        } else {
                                            set treat_as_edit_p 0
                                            # this is a new address, not edit
                                            
                                        }
                                    }
                                    if { $treat_as_edit_p } {
                                        aa_equals "A1.${do}-1 qal_demo_address_write  returns same address_id" $addrs_id $addrs_id2
                                        
                                        set record_type [qal_address_type $addrs_id ]
                                        set record_type2 [qal_address_type $addrs_id $co_id]
                                        aa_equals "A1.${do}-2 qal_address_type calls to db match each other" $record_type $record_type2
                                        if { $addrs_arr(record_type) ne "" } {
                                            
                                            aa_equals "A1.${do}-3 qal_address_type from db matches expected/requested" $record_type $addrs_arr(record_type)
                                        } 
                                        
                                        set addrs2_list [qal_address_read $addrs_id]
                                        array unset addrs2_arr
                                        array set addrs2_arr $addrs2_list
                                        # compare i/o
                                        set addrs2_keys_list [array names addrs2_arr]
                                        foreach key $addrs2_keys_list {
                                        aa_equals "A1.${do}-4 qal_address_read returns same as written with qal_address_write for key '${key}'" $addrs2_arr(${key}) $addrs_arr(${key})
                                            
                                        }
                                        set apt_edit_p 0
                                    } else {
                                        # This edit actually created a new address.
                                        # Let's check it. Yeah, there are other cases of new addresses. Yet, maybe this results in something different..
                                        # This is essentially a copy of test code between references x0x

                                        set addrs_id_is_nbr_p [qf_is_natural_number $addrs_id2]
                                        aa_true "A1.${do}-0-A1.1 qal_demo_address_write returns a valid addrs_id '${addrs_id}'" $addrs_id_is_nbr_p
                                        
                                        set record_type [qal_address_type $addrs_id2 ]
                                        set record_type2 [qal_address_type $addrs_id2 $co_id]
                                        aa_equals "A1.${do}-0-A1.2 qal_address_type calls are consistent record_type '${record_type}' record_type2 '${record_type2}'" $record_type $record_type2
                                        if { $addrs_arr(record_type) ne "" } {
                                            # filter out cases that we leave to qal_demo_address_write to make
                                            aa_equals "A1.${do}-0-A1.3 qal_address_type from db matches expected/specified type" $record_type $addrs_arr(record_type)
                                        } else {
                                            if { $record_type eq "other" } {
                                                set blank_to_other_p 1
                                            } else {
                                                set blank_to_other_p 0
                                            }
                                            aa_true "A1.${do}-0-A1.3.b qal_address_type returns 'other' when demo submits ''" $blank_to_other_p 
                                        }
                                        set addrs2_list [qal_address_read $addrs_id2]
                                        array unset addrs2_arr
                                        array set addrs2_arr $addrs2_list
                                        # compare i/o
                                        set addrs2_keys_list [array names addrs2_arr]
                                        if { [llength $addrs2_keys_list] > 0 } {
                                            foreach key $addrs2_keys_list {
                                                aa_equals "A1.${do}-0-A1.4 qal_address_read returns same as written with qal_address_write for key '${key}'" $addrs2_arr(${key}) $addrs_arr(${key})
                                                
                                            }
                                        } else {
                                            aa_true "A1.${do}-0-A1.4b qal_address_read returns a full address record" 0
                                        }
                                        
                                        # set sets of addresses for retesting
                                        if { $addrs_id_is_nbr_p } {
                                            set addrs_id_is_apt_p_arr(${addrs_id}) [qal_address_type_is_postal_q $record_type] 
                                            lappend addrs_ids_list $addrs_id2
                                            set deleted_p_arr(${addrs_id}) 0
                                            set trashed_p_arr(${addrs_id}) 0
                                        }
                                    }
                                }
                                apt_trash {

                                    set success_p [qal_address_trash $addrs_id]
                                    aa_true "A1.${do}-1 qal_address_trash '${addrs_id}' returns success" $success_p
                                    set addrs_list [qal_address_read $addrs_id]
                                    if { [llength $addrs_list ] == 0 } {
                                        set verified_p 1
                                    } else {
                                        set verified_p 0
                                    }
                                    aa_true "A1.${do}-2 qal_address_read '${addrs_id}' returns empty list" $verified_p
                                    set t_idx [lsearch -exact $addrs_ids_list $addrs_id]
                                    set addrs_ids_list [lreplace $addrs_ids_list $t_idx $t_idx]
                                    set apt_trash_p 0
                                    set trashed_p_arr(${addrs_id}) 1
                                }
                                apt_delete {
                                    set success_p [qal_address_delete $addrs_id]
                                    aa_true "A1.${do}-1 qal_address_delete '${addrs_id}' returns success" $success_p
                                    set addrs_list [qal_address_read $addrs_id]
                                    if { [llength $addrs_list ] == 0 } {
                                        set verified_p 1
                                    } else {
                                        set verified_p 0
                                    }
                                    aa_true "A1.${do}-2 qal_address_read '${addrs_id}' returns empty list" $verified_p
                                    set t_idx [lsearch -exact $addrs_ids_list $addrs_id]
                                    set addrs_ids_list [lreplace $addrs_ids_list $t_idx $t_idx]
                                    set deleted_p_arr(${addrs_id}) 1
                                    set apt_delete_p 0
                                }
                                ant_edit {
                                    array unset addrs_arr
                                    set addrs_list [qal_address_read $addrs_id]
                                    array set addrs_arr $addrs_list
                                    set addrs_id2 [qal_demo_address_write addrs_arr $co_id $addrs_id]
                                    set treat_as_edit_p 1
                                    if { $addrs_id2 ne $addrs_id } {
                                        # did this edit result in the creation of a new address?
                                        set record_type_id1 [qal_address_type $addrs_id]
                                        set record_type_id2 [qal_address_type $addrs_id2]
                                        set is_postal_id1 [qal_address_type_is_postal_q $record_type_id1]
                                        set is_postal_id2 [qal_address_type_is_postal_q $record_type_id2]
                                        if { $is_postal_id1 eq $is_postal_id2 } {
                                            set treat_as_edit_p 1
                                        } else {
                                            set treat_as_edit_p 0
                                            # this is a new address, not edit
                                            
                                        }
                                    }
                                    if { $treat_as_edit_p } {
                                        aa_equals "A1.${do}-1 qal_demo_address_write  returns same address_id" $addrs_id $addrs_id2
                                        
                                        set record_type [qal_address_type $addrs_id ]
                                        set record_type2 [qal_address_type $addrs_id $co_id]
                                        aa_equals "A1.${do}-2 qal_address_type calls to db match each other" $record_type $record_type2
                                        if { $addrs_arr(record_type) ne "" } {
                                            
                                            aa_equals "A1.${do}-3 qal_address_type from db matches expected/requested" $record_type $addrs_arr(record_type)
                                        } 
                                        
                                        set addrs2_list [qal_address_read $addrs_id]
                                        array unset addrs2_arr
                                        array set addrs2_arr $addrs2_list
                                        # compare i/o
                                        set addrs2_keys_list [array names addrs2_arr]
                                        foreach key $addrs2_keys_list {
                                        aa_equals "A1.${do}-4 qal_address_read returns same as written with qal_address_write for key '${key}'" $addrs2_arr(${key}) $addrs_arr(${key})
                                            
                                        }
                                        set ant_edit_p 0
                                    } else {
                                        # This edit actually created a new address.
                                        # Let's check it. Yeah, there are other cases of new addresses. Yet, maybe this results in something different..
                                        # This is essentially a copy of test code between references x0x

                                        set addrs_id_is_nbr_p [qf_is_natural_number $addrs_id2]
                                        aa_true "A1.${do}-0-A1.1 qal_demo_address_write returns a valid addrs_id '${addrs_id}'" $addrs_id_is_nbr_p
                                        
                                        set record_type [qal_address_type $addrs_id2 ]
                                        set record_type2 [qal_address_type $addrs_id2 $co_id]
                                        aa_equals "A1.${do}-0-A1.2 qal_address_type calls are consistent record_type '${record_type}' record_type2 '${record_type2}'" $record_type $record_type2
                                        if { $addrs_arr(record_type) ne "" } {
                                            # filter out cases that we leave to qal_demo_address_write to make
                                            aa_equals "A1.${do}-0-A1.3 qal_address_type from db matches expected/specified type" $record_type $addrs_arr(record_type)
                                        } else {
                                            if { $record_type eq "other" } {
                                                set blank_to_other_p 1
                                            } else {
                                                set blank_to_other_p 0
                                            }
                                            aa_true "A1.${do}-0-A1.3.b qal_address_type returns 'other' when demo submits ''" $blank_to_other_p 
                                        }
                                        set addrs2_list [qal_address_read $addrs_id2]
                                        array unset addrs2_arr
                                        array set addrs2_arr $addrs2_list
                                        # compare i/o
                                        set addrs2_keys_list [array names addrs2_arr]
                                        if { [llength $addrs2_keys_list] > 0 } {
                                            foreach key $addrs2_keys_list {
                                                aa_equals "A1.${do}-0-A1.4 qal_address_read returns same as written with qal_address_write for key '${key}'" $addrs2_arr(${key}) $addrs_arr(${key})
                                                
                                            }
                                        } else {
                                            aa_true "A1.${do}-0-A1.4b qal_address_read returns a full address record" 0
                                        }
                                        
                                        # set sets of addresses for retesting
                                        if { $addrs_id_is_nbr_p } {
                                            set addrs_id_is_apt_p_arr(${addrs_id}) [qal_address_type_is_postal_q $record_type] 
                                            lappend addrs_ids_list $addrs_id2
                                            set deleted_p_arr(${addrs_id}) 0
                                            set trashed_p_arr(${addrs_id}) 0
                                        }
                                    }
                                }
                                ant_trash {
                                    set success_p [qal_address_trash $addrs_id]
                                    aa_true "A1.${do}-1 qal_address_trash '${addrs_id}' returns success" $success_p
                                    set addrs_list [qal_address_read $addrs_id]
                                    if { [llength $addrs_list ] == 0 } {
                                        set verified_p 1
                                    } else {
                                        set verified_p 0
                                    }
                                    aa_true "A1.${do}-2 qal_address_read '${addrs_id}' returns empty list" $verified_p
                                    set t_idx [lsearch -exact $addrs_ids_list $addrs_id]
                                    set addrs_ids_list [lreplace $addrs_ids_list $t_idx $t_idx]
                                    set trashed_p_arr(${addrs_id}) 1
                                    set ant_trash_p 0
                                }
                                ant_delete {
                                    set success_p [qal_address_delete $addrs_id]
                                    aa_true "A1.${do}-1 qal_address_delete '${addrs_id}' returns success" $success_p
                                    set addrs_list [qal_address_read $addrs_id]
                                    if { [llength $addrs_list ] == 0 } {
                                        set verified_p 1
                                    } else {
                                        set verified_p 0
                                    }
                                    aa_true "A1.${do}-2 qal_address_read '${addrs_id}' returns empty list" $verified_p
                                    set t_idx [lsearch -exact $addrs_ids_list $addrs_id]
                                    set addrs_ids_list [lreplace $addrs_ids_list $t_idx $t_idx]
                                    set deleted_p_arr(${addrs_id}) 1
                                    set ant_delete_p 0
                                }
                                default {
                                    # ie. create..
                                    # do nothing this time
                                }
                            }

                            # finish while loop
                            set more_to_test_p [expr { $apt_delete_p \
                                                           || $apt_trash_p \
                                                           || $apt_edit_p \
                                                           || $ant_delete_p \
                                                           || $ant_trash_p \
                                                           || $ant_edit_p } ]
                            incr i
                        }

                        










                        set cu_id [qal_demo_customer_create customer_arr $co_id $user_id]
                        set cu_created_p [qf_is_natural_number $cu_id] 

                        aa_true "A2 Created a customer" $cu_created_p

                        set ve_id [qal_demo_vendor_create vendor_arr $co_id $user_id]
                        set ve_created_p [qf_is_natural_number $ve_id] 
                        set create_end_cs [clock seconds]
                        if { $create_end_cs ne $create_start_cs } {
                            aa_log "Created field may have a timing error of 1 second."
                        }
                        aa_true "A3 Created a vendor" $ve_created_p

                        aa_log "B0 Read and verify each value"

                        set co_v2_list [qal_contact_read $co_id]
                        set co_v2_list_len [llength $co_v2_list]
                        set co_keys_list [qal_contact_keys]
                        set co_v2_list_keys [dict keys $co_v2_list]
                        foreach key $co_keys_list {
                            if { $key ne "id" && $key ne "rev_id" } {
                                if { $co_v2_list_len > 0 } {
                                    set actual [dict get $co_v2_list $key] 
                                    set expected $contact_arr(${key})
                                    if { $key in [list time_start time_end created] } {
                                        # compare epochs
                                        aa_log "B1-0 ${key} field actual from db: '${actual}', expected from var cache: '${expected}'"
                                        if { $actual ne "" } {
                                            set actual [qf_clock_scan_from_db $actual]
                                        }
                                        if { $expected ne "" } {
                                            set expected [qf_clock_scan $expected]
                                        } else {
                                            if { $key eq "created" } {
                                                set expected $create_start_cs
                                            }
                                        }
                                    }
                                } 
                                aa_equals "B1 Contact read/write test key ${key}" $actual $expected
                            } else {
                                set is_nn_p 0
                                if { $key in $co_v2_list_keys } {
                                    set is_nn_p [qf_is_natural_number [dict get $co_v2_list $key ]]
                                }
                                aa_true "B1 Contact read/write test key ${key}'s value is natural number" $is_nn_p
                            }
                        }

                        set cu_v2_list [qal_customer_read $cu_id]
                        set cu_keys_list [qal_customer_keys]
                        foreach key $cu_keys_list {
                            if { $key ne "id" && $key ne "rev_id" } {
                                set actual [dict get $cu_v2_list $key] 
                                set expected $customer_arr(${key})

                                if { $key in [list time_start time_end created] } {
                                    # compare epochs
                                    if { $actual ne "" } {
                                        set actual [qf_clock_scan_from_db $actual]
                                    }
                                    if { $expected ne "" } {
                                        set expected [qf_clock_scan $expected]
                                    } else {
                                        if { $key eq "created" } {
                                            set expected $create_end_cs
                                        }
                                    }
                                } 
                                aa_equals "B2  Customer read/write test key ${key}" $actual $expected
                            }
                        }

                        set ve_v2_list [qal_vendor_read $ve_id]
                        set ve_keys_list [qal_vendor_keys]
                        foreach key $ve_keys_list {
                            if { $key ne "id" && $key ne "rev_id" } {
                                set actual [dict get $ve_v2_list $key] 
                                set expected $vendor_arr(${key})

                                if { $key in [list time_start time_end created] } {
                                    # compare epochs
                                    if { $actual ne "" } {
                                        set actual [qf_clock_scan_from_db $actual]
                                    }
                                    if { $expected ne "" } {
                                        set expected [qf_clock_scan $expected]
                                    } else {
                                        if { $key eq "created" } {
                                            set expected $create_end_cs
                                        }
                                    }
                                } 
                                aa_equals "B3  Vendor read/write test key ${key}" $actual $expected
                            }
                        }

                        aa_log "C0  Change/update each value"

                        set co2_id [qal_demo_contact_create contact_arr $co_id $user_id]
                        if { [qf_is_natural_number $co2_id] && $co_id eq $co2_id } {
                            set co_updated_p 1
                        } else {
                            set co_updated_p 0
                        }

                        aa_true "C1  Updated a contact" $co_updated_p

                        set cu2_id [qal_demo_customer_create customer_arr $co_id $user_id]
                        if { [qf_is_natural_number $cu2_id] && $cu_id eq $cu2_id } {
                            set cu_updated_p 1
                        } else {
                            set cu_updated_p 0
                            ns_log Notice "qal-entities-procs.tcl.136 co_id '$co_id' co2_id '$co2_id' cu_id '$cu_id' cu2_id '$cu2_id'"
                        }

                        aa_true "C2  Updated a customer" $cu_updated_p

                        set ve2_id [qal_demo_vendor_create vendor_arr $co_id $user_id]
                        if { [qf_is_natural_number $ve2_id] && $ve_id eq $ve2_id } {
                            set ve_updated_p 1
                        } else {
                            set ve_updated_p 0
                            ns_log Notice "qal-entities-procs.tcl.146 co_id '$co_id' co2_id '$co2_id' ve_id '$ve_id' ve2_id '$ve2_id'"
                        }

                        aa_true "C3  Updated a vendor" $ve_updated_p


                        aa_log "D0  Read and verify each updated value"

                        set co_v3_list [qal_contact_read $co_id]
                        set co_v3_list_len [llength $co_v3_list]
                        set co_keys_list [qal_contact_keys]
                        set co_v3_list_keys [dict keys $co_v3_list]
                        foreach key $co_keys_list {
                            if { $key ne "id" && $key ne "rev_id" } {
                                if { $co_v3_list_len > 0 } {
                                    set actual [dict get $co_v3_list $key] 
                                    set expected $contact_arr(${key})
                                    if { $key in [list time_start time_end created] } {
                                        # compare epochs
                                        aa_log "D1-0 ${key} field actual from db: '${actual}', expected from var cache: '${expected}'"
                                        if { $actual ne "" } {
                                            set actual [qf_clock_scan_from_db $actual]
                                        }
                                        if { $expected ne "" } {
                                            set expected [qf_clock_scan $expected]
                                        } else {
                                            if { $key eq "created" } {
                                                set expected $create_start_cs
                                            }
                                        }
                                    }
                                } 
                                aa_equals "D1 Contact read/write test key ${key}" $actual $expected
                            } else {
                                set is_nn_p 0
                                if { $key in $co_v3_list_keys } {
                                    set is_nn_p [qf_is_natural_number [dict get $co_v3_list $key ]]
                                }
                                aa_true "D1 Contact read/write test key ${key}'s value is natural number" $is_nn_p
                            }
                        }

                        set cu_v3_list [qal_customer_read $cu_id]
                        set cu_keys_list [qal_customer_keys]
                        foreach key $cu_keys_list {
                            if { $key ne "id" && $key ne "rev_id" } {
                                set actual [dict get $cu_v3_list $key] 
                                set expected $customer_arr(${key})

                                if { $key in [list time_start time_end created] } {
                                    # compare epochs
                                    if { $actual ne "" } {
                                        set actual [qf_clock_scan_from_db $actual]
                                    }
                                    if { $expected ne "" } {
                                        set expected [qf_clock_scan $expected]
                                    } else {
                                        if { $key eq "created" } {
                                            set expected $create_end_cs
                                        }
                                    }
                                } 
                                aa_equals "D2  Customer read/write test key ${key}" $actual $expected
                            }
                        }


                        set ve_v3_list [qal_vendor_read $ve_id]
                        set ve_keys_list [qal_vendor_keys]
                        foreach key $ve_keys_list {
                            if { $key ne "id" && $key ne "rev_id" } {
                                set actual [dict get $ve_v3_list $key] 
                                set expected $vendor_arr(${key})

                                if { $key in [list time_start time_end created] } {
                                    # compare epochs
                                    if { $actual ne "" } {
                                        set actual [qf_clock_scan_from_db $actual]
                                    }
                                    if { $expected ne "" } {
                                        set expected [qf_clock_scan $expected]
                                    } else {
                                        if { $key eq "created" } {
                                            set expected $create_end_cs
                                        }
                                    }
                                } 
                                aa_equals "D3  Vendor read/write test key ${key}" $actual $expected
                            }
                        }

                        ns_log Notice "tcl/test/q-control-procs.tcl.429 end"


                    } \
        -teardown_code {
            # 
            #acs_user::delete -user_id $user_arr(user_id) -permanent

        }
    #aa_true "Test for .." $passed_p
    #aa_equals "Test for .." $test_value $expected_value

}

