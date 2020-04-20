set title "#acs-subsite.Application#"
set context [list $title]
set contents ""

set f_lol [list \
               [list type input name stack_id value stack_id_value context content_c1] \
               [list type input name deck_id value deck-id_value context content_c2 ] \
               [list type input name card_id value card_id_value context content_c3] ]

set c4_list  [list type input name frompage value "backside" context content_c4] 
set f4_lol [qfo::form_list_def_to_css_table_rows -list_of_lists_name c4_list -rows_count 6 -group_letter j]
foreach f4_l $f4_lol {
    lappend f_lol $f4_l
}
set f2_lol [list \
                [list type input name page value "frontside"] \
                [list type submit name keep \
                     value "\#flashcards.Keep\#" datatype text title "\#flashcards.Keep_in_stack\#" label "" style "float: left;padding: 35px;" class "btn-big"] \
                [list type submit name pop \
                     value "\#flashcards.Pop\#" datatype text title "\#flashcards.Pop_from_stack\#" label "" style "float: right;padding: 35px;" class "btn-big" ] \
               ]
foreach f2_l $f2_lol {
    lappend f_lol $f2_l
}



::qfo::form_list_def_to_array \
    -list_of_lists_name f_lol \
    -fields_ordered_list_name qf_fields_ordered_list \
    -array_name f_arr \
    -ignore_parse_issues_p 0

set form_submitted_p 0

set validated_p [qal_3g \
                     -form_id 20200419 \
                     -fields_ordered_list $qf_fields_ordered_list \
                     -fields_array f_arr \
                     -inputs_as_array input_array \
                     -form_submitted_p $form_submitted_p \
                     -form_varname form_html ]



