ad_library {
    Library for accounts ledger contacts
    @creation-date 2016-06-28

}
#
ad_proc qal_contact_ids_of_user_id {
    user_id
} {

} {
    upvar 1 instance_id instance_id
    set contact_id_list ""

    return $contact_id_list
}

ad_proc qal_user_ids_of_contact_id {
    contact_id
} {

} {
    upvar 1 instance_id instance_id
    set user_id_list ""

    return $user_id_list
}


ad_proc qal_contact_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_contact
} {

    set keys_list [list instance_id id label name street_address_id mailing_address_id billing_address_id business_id taxnumber sic_code iban bic language_code currency time_start time_end url notes]
    set keys [qal_keys_by $keys_list $separator]
     return $keys
}
