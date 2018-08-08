# demo-procs.tcl
ad_library {

    procedures for building demonstrations
    @creation-date 11 December 2013
    @Copyright (c) 2014 Benjamin Brink
    @license GNU General Public License 2, see project home or http://www.gnu.org/licenses/gpl-2.0.html
    @project home: http://github.com/tekbasse/accounts-ledger
    @address: po box 193, Marylhurst, OR 97036-0193 usa
    @email: tekbasse@yahoo.com
}

ad_proc -public qal_demo_customer_create {
    {customer_arr_name "customer_arr"}
    {contact_id ""}
    {user_id ""}
} {
    Part of test suite and demo. Creates a customer.
    If contact_id provided, uses existing contact_id otherwise creates new contact_id.
    Sets indexes in array with name customer_arr_name to values cooresponding to qal_customer_keys.
    Returns customer_id, or empty string if unsuccessful.
} {
    upvar 1 instance_id instance_id
    upvar 1 $customer_arr_name customer_arr
    # following from: http://wiki.tcl.tk/567
    #set maxint \[expr 0x7\[string range \[format %X -1\] 1 end\]\]
    set maxint 6531464675862196
    set pg_maxint 2147483647
    incr maxint -1
    if { $contact_id ne "" } {
        set customer_arr(contact_id) $contact_id
    }
    if { ![info exists customer_arr(contact_id)] } {
        set customer_arr(contact_id) $contact_id
    }
    if { ![info exists customer_arr(id)] } {
        set customer_arr(id) ""
    }
    set cu_list [list \
                     id $customer_arr(id) \
                     instance_id $instance_id \
                     contact_id $customer_arr(contact_id) \
                     discount [random] \
                     tax_included [randomRange 1] \
                     credit_limit [lindex [list "" [expr { [random] * [randomRange $maxint] } ]] [randomRange 2]] \
                     terms [expr { [random] * [randomRange $maxint] } ] \
                     terms_unit [lindex [list days weeks months years seconds] [randomRange 4]] \
                     annual_value [expr { $maxint * [random] } ] \
                     customer_code [ad_generate_random_string [randomRange 31]] \
                     pricegroup_id [lindex [list "" [randomRange $pg_maxint]] [randomRange 1] ] \
                     created "" \
                     created_by $user_id \
                     trashed_p "0" \
                     trashed_by "" \
                     trashed_ts "" ]
    array set customer_arr $cu_list
    if { [qf_is_natural_number $contact_id ] } {
        set cu_id [qal_customer_write customer_arr $contact_id]
    } else {
        set cu_id [qal_customer_create customer_arr]
    }
    return $cu_id
}

ad_proc -public qal_demo_vendor_create {
    {vendor_arr_name "vendor_arr"}
    {contact_id ""}
    {user_id ""}
} {
    Part of test suite and demo. Creates a vendor.
    If contact_id provided, uses existing contact_id otherwise creates new contact_id.
    Returns vendor_id, or empty string if unsuccessful.
} {
    upvar 1 instance_id instance_id
    upvar 1 $vendor_arr_name vendor_arr
    # following from: http://wiki.tcl.tk/567
    #set maxint \[expr 0x7\[string range \[format %X -1\] 1 end\]\]
    set maxint 6531464675862196
    set ve_list [list \
                     id "" \
                     instance_id $instance_id \
                     contact_id $contact_id \
                     terms [expr { [random] * [randomRange $maxint] } ] \
                     terms_unit [lindex [list days weeks months years seconds] [randomRange 4]] \
                     tax_included [randomRange 1] \
                     vendor_code "" \
                     gifi_accno "" \
                     discount "" \
                     credit_limit [lindex [list "" [expr { [random] * [randomRange $maxint] } ]] [randomRange 1]] \
                     pricegroup_id "" \
                     created "" \
                     created_by $user_id \
                     trashed_p "0" \
                     trashed_by "" \
                     trashed_ts "" \
                     area_market [join [qal_namelur]] \
                     purchase_policy [join [qal_namelur]] \
                     return_policy [join [qal_namelur]] \
                     price_guar_policy [join [qal_namelur]] \
                     installation_policy [join [qal_namelur]] ]

    array set vendor_arr $ve_list
    if { [qf_is_natural_number $contact_id ] } {
        set ve_id [qal_vendor_write vendor_arr $contact_id]
    } else {
        set ve_id [qal_vendor_create vendor_arr]
    }
    return $ve_id
}

