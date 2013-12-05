#!/usr/bin/tclsh8.0
# \
exec tclsh "$0" ${1+"$@"}
#


# this program adds the closing tag to the catalog xml files


set oacs_xml_file_list [glob [file join $qal_cat_dir {*.xml}]]
foreach xmlfilenam ${oacs_xml_file_list} {
    if [catch {open $xmlfilenam a} xmlID] {
        puts stderr "Cannot open $xmlfilenam: $xmlID for write."
    } else {
        puts $xmlID "</message_catalog>"
        close $xmlID
    }
}

file rename [file join $qal_cat_dir accounts-ledger.in_ID.ISO-8859-1.xml] [file join $qal_cat_dir accounts-ledger.ind_ID.ISO-8859-1.xml]

puts "Note: remember to  edit 'accounts-ledger/catalog/accounts-ledger.ind_ID.ISO-8859-1.xml' to change locale from in_ID to ind_ID."
