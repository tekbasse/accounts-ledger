ad_library {
    Library for accounts ledger contacts
    @creation-date 2016-06-28

}
#
ad_proc qal_customer_ids_of_user_id {
    user_id
} {

} {
    upvar 1 instance_id instance_id
    set customer_id_list ""

    return $customer_id_list
}

ad_proc qal_user_ids_of_customer_id {
    customer_id
} {

} {
    upvar 1 instance_id instance_id
    set user_id_list ""

    return $user_id_list
}


