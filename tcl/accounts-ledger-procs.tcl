ad_library {
    Library of accounts ledger procedures
        includes conversions from
    # sql-ledger/SL/
    # AA.pm -- AR/AP backend routines
    # AM.pm
    # CA.pm
    # CP.pm
    # CT.pm
    # Form.pm
    # GL.pm
    # OP.pm
    # PE.pm
    # RC.pm
    # RP.pm
    # sql-ledger/bin/mozilla/
    # aa.pl
    # am.pl
    # arap.pl
    # arapprn.pl
    # ca.pl
    # gl.pl
    # pos.pl
    # ps.pl
    # rc.pl
    # rp.pl


    @creation-date 2005-11-13


}

ad_proc qal_instance_id {
} {
    Sets instance_id in calling environment. 

    @return instance_id in calling enviornment
} {
    upvar 1 instance_id instance_id
    # By using this proc, instances can be configured by
    # package parameter, package_id, subsite package_id etc 
    # without requiring changes throughout code.
    set pkg_id [ad_conn package_id]
    #set subsite_id \[ad_conn subsite_id\]
    set instance_id [parameter::get -package_id $instance_id -parameter instanceIdOverride -default $pkg_id]
    return $instance_id
}


ad_proc qal_post_transaction {
    parameter
} {
    description

    @ported from sql-ledger-2.6.2/SL/AA.pm
} {
    # code
}

ad_proc qal_delete_transaction {
    parameter
} {
    description

    @ported from sql-ledger-2.6.2/SL/AA.pm
} {
    # code
}

ad_proc qal_transactions {
    parameter
} {
    @ported from sql-ledger-2.6.2/SL/AA.pm
} {

}

ad_proc qal_get_name {
    parameter
} {
    used in IS, IR to retrieve name  (what kind of name??)
} {
   # get
}

