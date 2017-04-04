set title "accounts ledger demo install"
set context [list $title]
qc_pkg_admin_required

ns_log Notice "demo install begin, based on: aa_register_case.12: Begin test assets_sys_build_api_check"
#aa_log "0. Build 2 DCs with HW and some attributes"
# Use default permissions provided by tcl/accounts-ledger-init.tcl
# Yet, users must have read access permissions or test fails
# Some tests will fail (predictably) in a hardened system

set instance_id [qc_set_instance_id]
# We avoid qf_permission_p by using a sysadmin user
# hf_roles_init $instance_id
# hf_property_init $instance_id
# hf_privilege_init $instance_id
# hf_asset_type_id_init $instance_id

# Identify and test full range of parameters


# keep namespace clean to help prevent bugs in test code
#unset role_id
#unset role
#unset roles_lists

# A user with sysadmin rights and not customer
set sysowner_email [ad_system_owner]
set sysowner_user_id [party::get_by_email -email $sysowner_email]
set prior_asset_ids_list [hf_asset_ids_for_user $sysowner_user_id]
set i [string first "@" $sysowner_email]
if { $i > -1 } {
    set domain [string range $sysowner_email $i+1 end]
} else {
    set domain [hf_domain_example]
}
# create a contact for each user.
set users_list [db_list_of_lists cc_users_read_all {select user_id, email_verified_p, first_names, last_name, email, username, screen_name, member_state from cc_users} ]
foreach user $users_list {
    ##code


}


ns_log Notice "demo install end, based on: accounts-ledger-test-api-procs.tcl assets_sys_build_api_check"