ad_library {
    Library for accounts ledger contacts
    @creation-date 2016-06-28

}

ad_proc qal_customer_create {
    arr_name
} {
    Create a customer record
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name c_arr


}

ad_proc qal_customer_update {
    arr_name
} {
    Update a customer record
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name c_arr


}


ad_proc qal_customer_trash {
    arr_name
} {
    Trash a customer record
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name c_arr


}

