# accounts-ledger/tcl/accounts-ledger-init.tcl


# Default initialization?  check at server startup (here)

#    @creation-date 2017-050-12
#    @Copyright (c) 2017 Benjamin Brink
#    @license GNU General Public License 2.
#    @see project home or http://www.gnu.org/licenses/gpl-2.0.html
#    @project home: http://github.com/tekbasse/accounts-ledger
#    @address: po box 193, Marylhurst, OR 97036-0193 usa
#    @email: tekbasse@yahoo.com


set instance_id 0
#ns_log Notice "accounts-ledger/tcl/accounts-ledger-init.tcl.16: begin"
if { [catch { set instance_id [apm_package_id_from_key accounts-ledger] } error_txt] } {
    # more than one instance exists
    set instance_id 0
    #ns_log Notice "accounts-ledger/tcl/accounts-ledger-init.tcl.20: More than one instance exists. skipping."
} elseif { $instance_id != 0 } {
    # only one instance of accounts-ledger exists.
} else {
    # package_id = 0, no instance exists
    # empty string converts to null for integers in db api
    set instance_id ""

}

set group_types_exist_p [db_0or1row qal_select_qal_grp_contacts { 
    select group_type from group_types where group_type='qal_grp_contacts' } ]
ns_log Notice "accounts-ledger-init.tcl: group_types_exist_p '${group_types_exist_p}' instance_id '${instance_id}'"
if { !$group_types_exist_p } {
    # If this is this the first run, add some defaults. 
    # acs group types for use with acs groups later
    db_transaction {
  #      group_type::new -group_type qal_grp_contacts -supertype group "#accounts-ledger.Contact#" "#accounts-ledger.Contacts#"
  #      group_type::new -group_type qal_grp_customers -supertype group "#accounts-ledger.Customer#" "#accounts-ledger.Customers#"
  #      group_type::new -group_type qal_grp_vendors -supertype group "#accounts-ledger.Vendor#" "#accounts-ledger.Vendors#"
    }
}
