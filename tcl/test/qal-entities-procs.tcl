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

            # co = contact, cu = customer, ve = vendor
            set co_list [list  \
                             instance_id $instance_id \
                             label "test1" \
                             name [qal_namelur]  \
                             street_addrs_id "" \
                             mailing_addrs_id "" \
                             billing_addrs_id "" \
                             vendor_id "" \
                             customer_id "" \
                             taxnumber [ad_generate_random_string [randomRange 32]] \
                             sic_code [ad_generate_random_string [randomRange 15]] \
                             iban [ad_generate_random_string [randomRange 34]] \
                             bic [ad_generate_random_string [randomRange 12]] \
                             language_code [ad_generate_random_string [randomRange 6]] \
                             currency [ad_generate_random_string [randomRange 3]] \
                             timezone [ad_generate_random_string [randomRange 3]] \
                             time_start [qf_clock_format] \
                             time_end "" \
                             url [ad_generate_random_string [randomRange 200]] \
                             user_id $user_id \
                             created $nowts \
                             created_by [ad_conn user_id] \
                             trashed_p "0" \
                             trashed_by "" \
                             trashed_ts "" \
                             notes "test from accounts-ledger/tcl/test/qal-entities-procs.tcl" ]
            set co_id [qal_contact_create contact_arr]
            aa_true "Created a contact"

            ns_log Notice "tcl/test/q-control-procs.tcl.429 end"


        } \
        -teardown_code {
            # 
            #acs_user::delete -user_id $user1_arr(user_id) -permanent

        }
    #aa_true "Test for .." $passed_p
    #aa_equals "Test for .." $test_value $expected_value


}
