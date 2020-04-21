set title "#acs-subsite.Application#"
set context [list $title]
set contents ""

set f_lol [list \
               [list name date value "04/20/2020" context content_c2 datatype date ] \
               [list name order_id value "o20200420" context content_c1 label "Order\#" datatype text ] \
               [list datatype text name job_id value job_id_value context content_c3 label "JobId"] ]

set html_before1 { <div class="grid-2 m-grid-6 s-grid-12"><div class="content-box">}
set html_after {</div></div>}
set html_before2 { <div class="grid-2 m-grid-3 s-grid-6"><div class="content-box">}

set c4_list  [list \
                  [list datatype text name pcode value "vendor-x" context content_c4 html_before $html_before1 html_after $html_after label "Product Code" size 12] \
                  [list datatype text name descr value "" context content_c4 html_before $html_before1 html_after $html_after label "Description" size 12 ] \
                  [list datatype text name listprice value "10.00" context content_c4 html_before $html_before2 html_after $html_after label "List" size 6] \
                  [list datatype text name qty value "1" context content_c4 html_before $html_before2 html_after $html_after label "Quantity" size 4 ] \
                  [list datatype text name price value "" context content_c4 html_before $html_before2 html_after $html_after label "Price" size 8 ] \
              [list datatype text name row_nbr value "" context content_c4 html_before $html_before2 html_after $html_after label "Row\#" size 4] ]
              
set f4_lol [qfo::form_list_def_to_css_table_rows -list_of_lists_name f_lol -form_field_defs_to_multiply c4_list -rows_count 6 -group_letter j]

set f2_lol [list \
                [list datatype text name page value "frontside" context content_c5] \
                [list type submit name keep context content_c6 \
                     value "\#accounts-ledger.Post\#" datatype text title "\#accounts-ledger.Post\#" label "" class "btn-big"] \
                [list type submit name update context content_c7 \
                     value "\#accounts-ledger.Update\#" datatype text title "\#accounts-ledger.Update\#" label "" class "btn-big" ] \
               ]
qf_append_lol2_to_lol1 f_lol f2_lol
#ns_log Notice "test-lib-fragments.tcl f_lol '${f_lol}'"

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
                     -form_varname "content_c" ]



