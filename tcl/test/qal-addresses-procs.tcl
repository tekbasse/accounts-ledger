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

                        set instance_id [ad_conn package_id]
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
                        aa_true "A1 Created a contact" $co_created_p

                        set a_idx [randomRange 2]
                        set addrs_arr(address_type) [lindex $qal


                        qal_demo_address_write addrs_arr $co_id
                        













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

