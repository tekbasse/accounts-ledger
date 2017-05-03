ad_library {
    Automated tests for q-control
    @creation-date 2015-03-19
}

aa_register_case -cats {api smoke} qal_entities_check {
    Test qal entities ie contact+customer+vendor procs for cases of CRUD
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
            set co_id [qal_demo_contact_create ]
            set co_created_p [qal_is_natural_number $co_id] 

            aa_true "Created a contact" $co_created_p

            set cu_id [qal_customer_create $customer_arr]
            set cu_created_p [qal_is_natural_number $cu_id] 

            aa_true "Created a customer" $cu_created_p

            set ve_id [qal_vendor_create $vendor_arr]
            set ve_created_p [qal_is_natural_number $ve_id] 

            aa_true "Created a vendor" $ve_created_p

            aa_log "Read and verify each value"

            set co_v2_list [qal_contact_read $co_id]

            set cu_v2_list [qal_customer_read $cu_id]

            set ve_v2_list [qal_vendor_read $ve_id]

            aa_log "Change/update each value"


            aa_log "Read and verify each updated value"

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
            #acs_user::delete -user_id $user1_arr(user_id) -permanent

        }
    #aa_true "Test for .." $passed_p
    #aa_equals "Test for .." $test_value $expected_value


}
