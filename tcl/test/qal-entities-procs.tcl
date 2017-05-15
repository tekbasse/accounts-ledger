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

            #
            # CRURTRDR tests for contact, customer, vendor
            #    C=Create, R=Read, U=Update T=Trash D=Delete
            #

            # co = contact, cu = customer, ve = vendor
            set co_id [qal_demo_contact_create contact_arr]
            set co_created_p [qf_is_natural_number $co_id] 

            aa_true "Created a contact" $co_created_p

            set cu_id [qal_demo_customer_create customer_arr]
            set cu_created_p [qf_is_natural_number $cu_id] 

            aa_true "Created a customer" $cu_created_p

            set ve_id [qal_demo_vendor_create vendor_arr]
            set ve_created_p [qf_is_natural_number $ve_id] 

            aa_true "Created a vendor" $ve_created_p

            aa_log "Read and verify each value"

            set co_v2_list [qal_contact_read $co_id]
            set co_keys_list [qal_contact_keys]
            foreach key $co_keys_list {
                aa_equal "Contact read/write test key ${key}" [dict get $co_v2_list $key] $contact_arr(${key})
            }

            set cu_v2_list [qal_customer_read $cu_id]
            set cu_keys_list [qal_customer_keys]
            foreach key $cu_keys_list {
                aa_equal "Customer read/write test key ${key}" [dict get $cu_v2_list $key] $customer_arr(${key})
            }

            set ve_v2_list [qal_vendor_read $ve_id]
            set ve_keys_list [qal_vendor_keys]
            foreach key $ve_keys_list {
                aa_equal "Vendor read/write test key ${key}" [dict get $ve_v2_list $key] $vendor_arr(${key})
            }

            aa_log "Change/update each value"

            set co2_id [qal_demo_contact_create contact_arr]
            if { [qf_is_natural_number $co2_id] && $co_id eq $co2_id } {
                set co_updated_p 1
            } else {
                set co_updated_p 0
            }

            aa_true "Updated a contact" $co_updated_p

            set cu2_id [qal_demo_customer_create customer_arr]
            if { [qf_is_natural_number $cu2_id] && $cu_id eq $cu2_id } {
                set cu_updated_p 1
            } else {
                set cu_updated_p 0
            }

            aa_true "Updated a customer" $cu_updated_p

            set ve2_id [qal_demo_vendor_create vendor_arr]
            if { [qf_is_natural_number $ve2_id] && $ve_id eq $ve2_id } {
                set ve_updated_p 1
            } else {
                set ve_updated_p 0
            }

            aa_true "Updated a vendor" $ve_updated_p


            aa_log "Read and verify each updated value"

            set co_v3_list [qal_contact_read $co_id]
            foreach key $co_keys_list {
                aa_equal "Contact read/write test key ${key}" [dict get $co_v3_list $key] $contact_arr(${key})
            }

            set cu_v3_list [qal_customer_read $cu_id]
            foreach key $cu_keys_list {
                aa_equal "Customer read/write test key ${key}" [dict get $cu_v3_list $key] $customer_arr(${key})
            }

            set ve_v3_list [qal_vendor_read $ve_id]
            foreach key $ve_keys_list {
                aa_equal "Vendor read/write test key ${key}" [dict get $ve_v3_list $key] $vendor_arr(${key})
            }


            # Iterate through creating contact, customer, and vendor to test more trash/delete cases


            # Trash customer or vendor, see if other and contact remains
            # Trash other, see if contact remains
            # Trash contact, verify customer and vendor trashed
            
            # Delete customer or vendor, see if other and contact remains
            # Delete other, see if contact remains
            # Delete contact, verify customer and vendor deleted
            

            ns_log Notice "tcl/test/q-control-procs.tcl.429 end"


        } \
        -teardown_code {
            # 
            #acs_user::delete -user_id $user_arr(user_id) -permanent

        }
    #aa_true "Test for .." $passed_p
    #aa_equals "Test for .." $test_value $expected_value


}
