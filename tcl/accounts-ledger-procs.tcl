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

    @ported by Torben Brosten
    @creation-date 2005-11-13
    @cvs-id $Id:

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

