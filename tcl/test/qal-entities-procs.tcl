ad_library {
    Automated tests for accounts-ledger
    @creation-date 2017-05-01
}

aa_register_case -cats {api smoke} qal_entities_check {
    Test qal entities ie contact+customer+vendor procs for CRUD consistency
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



                        # Iterate through creating contact, customer, and vendor to test more trash/delete cases
                        # Build the permutations randomly to help flush out any business logic idiosyncracies

                        # ico = iterating contact_id list 
                        # icu = iterating customer_id list
                        # ive = iterating vendor_id list
                        # deleted_p_arr(id) = has been deleted?
                        # trashed_p_arr(id) = has been trashed?
                        # is_co_p_arr(id) = is a contact?
                        # is_cu_p_arr(id) = is a customer?
                        # is_ve_p_arr(id) = is a vendor?
                        # permu_ids_larr(type) = list of permutations of this type.
                        # permutations:
                        set permutations_list [list co co-cu co-ve co-cu-ve ]
                        foreach p $permutations_list {
                            set permu_ids_larr(${p}) [list ]
                        }
                        # Careful: co-cu-ve  includes cases of co-ve-cu..
                        # Make 4 x 3 of each type
                        # which means 4 x 3 x 4 contacts.
                        for {set i 0} {$i < 4} {incr i} {
                            append types_list $permutations_list
                        }
                        # Randomize the types in an evolving way, kind of like how it will be used.
                        # 
                        # acc_fin::shuffle_list is defined in a package not required. So, using its code:
                        set len [llength $types_list]
                        while { $len > 0 } {
                            set n_idx [expr { int( $len * [random] ) } ]
                            set tmp [lindex $types_list $n_idx]
                            lset types_list $n_idx [lindex $types_list [incr len -1]]
                            lset types_list $len $tmp
                        }

                        # There must be:
                        # At least 16 contacts of which 4 are not customers or vendors
                        # And for each permutation, a case of do nothing, trash, and delete 
                        # each subtype co,cu,ve
                        # 3 x 1 
                        set min_arr(co) 3
                        # of which 8 become customers at some point, and 4 customers only (not vendors)
                        # 3 x 2 
                        set min_arr(co-cu) 6
                        # 8 become vendors (4 only vendors not customers), and
                        # 3 x 2
                        set min_arr(co-ve) 6
                        # 4 become customers and vendors
                        # 3 x 3
                        set min_arr(co-cu-ve) 9
                        
                        set permutations_met_p 0
                        set i 0
                        while { !$permutations_met_p && $i < 2000 } {
                            set type [lindex $permutations_list [randomRange 3]]
                            ns_log Notice "qal_entitites-procs.tcl.302 i '${i}' type '${type}' id count: [llength $permu_ids_larr(${type})]"
                            switch -- $type {
                                co {
                                    set co_id [qal_demo_contact_create dco_arr "" $user_id]
                                    set deleted_p_arr(${co_id}) 0
                                    set trashed_p_arr(${co_id}) 0
                                    set is_co_p_arr(${co_id}) 1
                                    set is_cu_p_arr(${co_id}) 0
                                    set is_ve_p_arr(${co_id}) 0

                                    unset dco_arr
                                    if { $co_id ne "" } {
                                        lappend permu_ids_larr(co) $co_id
                                        set p_granted_p [qc_user_role_add $co_id $this_user_id $org_admin_id $instance_id]

                                    } else {
                                        aa_true "E.299: qal_demo_contact_create failed unexpectedly" 0
                                    }
                                }
                                co-cu {
                                    set co_id [qal_demo_contact_create dco_arr "" $user_id]
                                    set deleted_p_arr(${co_id}) 0
                                    set trashed_p_arr(${co_id}) 0
                                    set is_co_p_arr(${co_id}) 1
                                    set is_cu_p_arr(${co_id}) 0
                                    set is_ve_p_arr(${co_id}) 0

                                    unset dco_arr
                                    if { $co_id ne "" } {
                                        lappend permu_ids_larr(co) $co_id
                                        set p_granted_p [qc_user_role_add $co_id $this_user_id $org_admin_id $instance_id]
                                    } else {
                                        aa_true "E.307: qal_demo_contact_create failed unexpectedly" 0
                                    }
                                    
                                    # choose any existing co-only to convert to co-cu
                                    set idx_max [llength $permu_ids_larr(co)]
                                    incr idx_max -1
                                    if { $idx_max > 0 } {
                                        set idx [randomRange $idx_max]
                                        set co_id [lindex $permu_ids_larr(co) $idx]
                                        set permu_ids_larr(co) [lreplace $permu_ids_larr(co) $idx $idx]
                                        
                                        set cu_id [qal_demo_customer_create dcu_arr $co_id $user_id]
                                        set is_cu_p_arr(${co_id}) 1
                                        unset dcu_arr
                                        if { $cu_id ne "" } {
                                            lappend permu_ids_larr(co-cu) $co_id
                                            set p_granted_p [qc_user_role_add $co_id $this_user_id $org_admin_id $instance_id]
                                        } else {
                                            aa_true "E.321: qal_demo_customer_create for co_id '${co_id}' failed unexpectedly" 0
                                        }
                                    }
                                }
                                co-ve {
                                    set co_id [qal_demo_contact_create dco_arr "" $user_id]
                                    set deleted_p_arr(${co_id}) 0
                                    set trashed_p_arr(${co_id}) 0
                                    set is_co_p_arr(${co_id}) 1
                                    set is_cu_p_arr(${co_id}) 0
                                    set is_ve_p_arr(${co_id}) 0

                                    unset dco_arr
                                    if { $co_id ne "" } {
                                        lappend permu_ids_larr(co) $co_id
                                        set p_granted_p [qc_user_role_add $co_id $this_user_id $org_admin_id $instance_id]
                                    } else {
                                        aa_true "E.307: qal_demo_contact_create failed unexpectedly" 0
                                    }
                                    
                                    # choose any existing co-only to convert to co-ve
                                    set idx_max [llength $permu_ids_larr(co)]
                                    incr idx_max -1
                                    if { $idx_max > 0 } {
                                        set idx [randomRange $idx_max]
                                        set co_id [lindex $permu_ids_larr(co) $idx]
                                        set permu_ids_larr(co) [lreplace $permu_ids_larr(co) $idx $idx]
                                        
                                        set ve_id [qal_demo_vendor_create dve_arr $co_id $user_id]
                                        set is_ve_p_arr(${co_id}) 1
                                        unset dve_arr
                                        if { $ve_id ne "" } {
                                            lappend permu_ids_larr(co-ve) $co_id
                                        } else {
                                            aa_true "E.321: qal_demo_vendor_create for co_id '${co_id}' failed unexpectedly" 0
                                        }
                                    }
                                }
                                co-cu-ve {
                                    set co_id [qal_demo_contact_create dco_arr "" $user_id]
                                    set p_granted_p [qc_user_role_add $co_id $this_user_id $org_admin_id $instance_id]
                                    set deleted_p_arr(${co_id}) 0
                                    set trashed_p_arr(${co_id}) 0
                                    set is_co_p_arr(${co_id}) 1
                                    set is_cu_p_arr(${co_id}) 0
                                    set is_ve_p_arr(${co_id}) 0

                                    unset dco_arr
                                    if { $co_id ne "" } {
                                        lappend permu_ids_larr(co) $co_id
                                        set p_granted_p [qc_user_role_add $co_id $this_user_id $org_admin_id $instance_id]
                                    } else {
                                        aa_true "E.354: qal_demo_contact_create failed unexpectedly" 0
                                    }
                                    
                                    # choose any existing co-only, co-cu or co-cv to convert to co-cu-ve
                                    set idx_choice [randomRange 2]
                                    set choice [lindex [list co co-cu co-ve] $idx_choice]
                                    set success_p 1
                                    set idx_max [llength $permu_ids_larr(${choice})]
                                    incr idx_max -1
                                    if { $idx_max > 0 } {
                                        set idx [randomRange $idx_max]
                                        set co_id [lindex $permu_ids_larr(${choice}) $idx]
                                        if { ![string match "*cu*" $choice] } {
                                            set cu_id [qal_demo_customer_create dcu_arr $co_id $user_id]
                                            unset dcu_arr
                                            if { $cu_id eq "" } {
                                                set success_p 0
                                            } else {
                                                set is_cu_p_arr(${co_id}) 1
                                            }
                                        }
                                        if { ![string match "*ve*" $choice] } {
                                            set ve_id [qal_demo_vendor_create dve_arr $co_id $user_id]
                                            unset dve_arr
                                            if { $ve_id eq "" } {
                                                set success_p 0
                                            } else {
                                                set is_ve_p_arr(${co_id})
                                            }
                                        }
                                        if { $success_p } {
                                            set permu_ids_larr(${choice}) [lreplace $permu_ids_larr(${choice}) $idx $idx]
                                            lappend permu_ids_larr(co-cu-ve) $co_id
                                        } else {
                                            aa_true "E.388: co_id '${co_id}' type '${choice}' failed to convert to co-xu-ve unexpectedly" 0
                                        }
                                    }
                                }
                                default {
                                    aa_true "E.399. Switch should not be provided type '${type}'" 0
                                }
                            }
                            if { $i > 1999 } {
                                set i_gt_2k_p 1
                                aa_false "E.439 'Permutation count is over 2000.' If true and repeatable, there's an error somewhere in loop." $i_gt_2k_p
                            }
                            set permutations_met_p 1

                            foreach p $permutations_list {
                                if { [llength $permu_ids_larr(${p})] >= $min_arr(${p}) } {
                                    set perms_met_for_this_type_p 1
                                } else {
                                    set perms_met_for_this_type_p 0
                                }
                                set permutations_met_p [expr { $permutations_met_p && $perms_met_for_this_type_p } ]
                           }
                            incr i
                        }

                        # For each permutation, choose one of each type it is (co, cu, and ve)
                        # and trash, or delete.

                        set type_list [list co cu ve]
                        foreach p $permutations_list {
                            set p_id_list $permu_ids_larr(${p}) 
                            set p_idx_max [llength $p_id_list]
                            incr p_idx_max -1
                            foreach t $type_list {
                                if { [string match "*${t}*" $p] } {
                                    foreach action [list trash del ] {
                                        set p_idx [randomRange $p_idx_max]
                                        set co_id [lindex $p_id_list $p_idx]
                                        set p_id_list [lreplace $p_id_list $p_idx $p_idx]
                                        incr p_idx_max -1
                                        set toggle $action
                                        append toggle "-" $t
                                        switch -- $toggle {
                                            trash-co {
                                                set r [qal_contact_trash $co_id]
                                                set trashed_p_arr(${co_id}) $r
                                            }
                                            del-co {
                                                set r [qal_contact_delete $co_id]
                                                set deleted_p_arr(${co_id}) $r
                                            }
                                            trash-cu {
                                                set cu_id [qal_customer_id_from_contact_id $co_id]
                                                set r [qal_customer_trash $cu_id]
                                                set is_cu_p_arr(${co_id}) $r
                                            }
                                            del-cu {
                                                set cu_id [qal_customer_id_from_contact_id $co_id]
                                                set r [qal_customer_delete $cu_id]
                                                set is_cu_p_arr(${co_id}) $r
                                            }
                                            trash-ve {
                                                set ve_id [qal_vendor_id_from_contact_id $co_id]
                                                set r [qal_contact_trash $ve_id]
                                                set is_ve_p_arr(${co_id}) $r
                                            }
                                            del-ve {
                                                set ve_id [qal_vendor_id_from_contact_id $co_id]
                                                set r [qal_contact_delete $ve_id]
                                                set is_ve_p_arr(${co_id}) $r
                                            }
                                            default {
                                                ns_log Warning "qal_entities_procs.tcl.499 toggle '${toggle}' not found for switch."
                                            }
                                        }
                                        aa_true "E.500 action '${action}' on type '${t}' with contact_id '${co_id}' reports succeeded." $r
                                    }
                                }
                            }
                        }

##code
                        foreach p $permutations_list {
                            foreach co_id $permu_ids_larr(${p}) {
                                # verify status using  qal_contact_id_exists_q qal_customer_id_exists_q qal_vendor_id_exists_q
                                # type co
                                set actual [qal_contact_id_exists_q $co_id]
                                set expected [expr { !( $deleted_p_arr(${co_id}) || $trashed_p_arr(${co_id}) )}] 
                                aa_equals "E. Permutation '${p}' contact_id '${co_id}' exists?" $actual $expected

                                # type ce
                                set cu_id [qal_customer_id_from_contact_id $co_id]
                                set actual [qal_customer_id_exists_q $cu_id]
                                set expected $is_cu_p_arr(${co_id})
                                aa_equals "E. Permutation '${p}' customer_id '${cu_id}' of contact_id '${co_id}' exists?" $actual $expected

                                # type ve
                                set ve_id [qal_vendor_id_from_contact_id $co_id]
                                set actual [qal_vendor_id_exists_q $ve_id]
                                set expected $is_ve_p_arr(${co_id})
                                aa_equals "E. Permutation '${p}' vendor_id '${ve_id}' of contact_id '${co_id}' exists?" $actual $expected

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

