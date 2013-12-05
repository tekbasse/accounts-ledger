#!/usr/bin/tclsh8.0
# \
exec tclsh "$0" ${1+"$@"}
#


# this program convers sql-ledger locale files to openacs catalog il8n xml files

# puts -nonewline "file to convert: "
# flush stdout
# set slfilenam [gets stdin]
# set dir [pwd]/sql

set sl_file_list [glob [file join $sl_loc_dir "*" "Num2text"]]
lappend sl_file_list [file join $sl_base_dir SL "Num2text.pm"]
set oacs_xml_file_list [glob [file join $qal_cat_dir {*.xml}]]
foreach slfilepathnam $sl_file_list {
 if { [string equal [file tail $slfilepathnam] "Num2text.pm"] } {
     set slfilenam "default"
 } else {
     set slfilenam [string range $slfilepathnam [expr [string length $sl_loc_dir] + 1] end-9]
     # set slfilenam [string range $slfilepathnam 8 end]
 }
puts "slfilenam: '$slfilenam', slfilepathnam: '$slfilepathnam'"
    if { [info exists dirmap($slfilenam)] } {

  set charset "ISO-8859-1"
  if [catch {open $slfilepathnam r} slId] {
      puts stderr "Cannot open $slfilenam: $slId for read."
  } else {
      puts "reading: $slfilepathnam"
      # open database file, open brace A
      #
      gets $slId line

      set locale $dirmap($slfilenam)

      set file_exists [lsearch $oacs_xml_file_list "*${locale}*"]
      if { $file_exists == -1 } {
          set newFile [file join $qal_cat_dir "accounts-ledger.${locale}.$charset.xml"]
          set write_type "w"
      } else {
          set write_type "a"
          set newFile [lindex $oacs_xml_file_list $file_exists]
      }
#      puts "writing ${write_type} $newFile"
      regexp {accounts-ledger.[a-z][a-z]_[A-Z][A-Z]\.([^\.]*)\.xml} $newFile scratch charset


      if [catch {open $newFile ${write_type}} newId] {
          puts stderr "Cannot open $newFile: $newId for write."
      } else {
          # open output file, open brace B
          
          puts "locale: '$locale', charset: '$charset'"
#          puts stdout "w"
          if { $file_exists == -1 } {
              puts $newId "<?xml version=\"1.0\" encoding=\"$charset\"?>
<message_catalog package_key=\"accounts-ledger\" package_version=\"0.1d\" locale=\"${locale}\" charset=\"$charset\">

"
          }

          while {[gets $slId line] >= 0} {
#              puts -nonewline "r"
              if { [string match "* => *" $line ] && ![string match "*'',*" $line ] && ![string match "*#*" $line]} { 
 
                 # get key string

                  set hash_list [split $line {=>} ]
                  set phrase [lindex $hash_list 0]
                  regsub -all -- {\(} $phrase {} phrase2
                  regsub -all -- {'} $phrase2 {} phrase
                  set phrase [string trim $phrase]

                  regsub -all -- {[^a-zA-Z0-9]} $phrase "_" full_phrase

                  set key_phrase [string trimright $full_phrase "_"]

                  set translation [lindex $hash_list 2]
                  regsub -all {'} $translation "" translation2
                  regsub -all {,} $translation2 "" translation
                  set translation [string trim $translation]  

 
                  # check if key is already used for a different EN phrase

# we have to use a different key_array from convert-SL-locale.tcl since we dump the 
# en_US one to make sure we get an index key in en_US for all the different keys generated
# from the other locales.

                  if { [info exists key_array2($key_phrase) ] && ![string equal $key_array2($key_phrase) $phrase ] } {
                          set old_phrase $key_phrase
                      while { [info exists key_array2($key_phrase) ] && ![string equal $key_array2($key_phrase) $phrase ] } {
                          # modify the key for a different translation key
                          append key_phrase "_" 
                      }
                      if { ![info exists key_array2($key_phrase) ] } {
                          puts "new key $key_phrase given 'key_array2($old_phrase)' <> '$phrase'(EN), here to: '$translation'"
                      }
                  }
                  # check if key has already been set for this locale
                  if { [info exists translation_array($locale-${key_phrase}) ] && [string equal $translation_array($locale-${key_phrase}) $translation] } {
                      set skip 1
                  } elseif { [info exists translation_array($locale-${key_phrase}) ] && ![string equal $translation_array($locale-${key_phrase}) $translation] } {
                      # just in case
                      puts "Two different translations for same key in one locale for '$phrase' ('$translation_array($locale-${key_phrase})' <> '$translation'. Skipping!"
                      set skip 1
                  } else {
                      set skip 0
                  }

                  if { !$skip } {
#                      puts -nonewline "w"
                      # we do not want to output the en_US quite yet, because we will dump
                      # all of the keys into en_US so they all at least load into one locale
                      if { ![string equal $locale "en_US"] } {
                          set translation [quote_xml_values $translation]
                          puts $newId "<msg key=\"${key_phrase}\">$translation</msg>"
                      }
                      # remember it to screen for duplications
                      set key_array2(${key_phrase}) $phrase
                      set translation_array($locale-${key_phrase}) $translation
                  } else {
                      puts "duplicate: ${key_phrase} for $phrase skipping.." 
                  }
              }
          }
#          puts $newId "</message_catalog>"
          close $newId

        }
        close $slId
    }

  }

}
# end foreach loop
# almost done... sql-ledger uses en_US for the system locale defaults, and so does not have 
# a translation file for it.. 
# create the en_US catalog file by expanding key_array2

set charset "ISO-8859-1"
set locale "en_US"
set newFile [file join $qal_cat_dir "accounts-ledger.$locale.$charset.xml"]

if [catch {open $newFile a} newId] {
    puts stderr "Cannot open $newFile: $newId for write."
} else {
    set index_value_list [array get key_array2]
# skip the next line, because convert-SL-locales.tcl should already have added it.
#    puts $newId "<?xml version=\"1.0\" encoding=\"$charset\"?>
#<message_catalog package_key=\"accounts-ledger\" package_version=\"0.1d\" locale=\"$locale\" charset=\"$charset\">
#"
    foreach {keyphrase phrase} $index_value_list {
        if { [info exists translation_array($locale-${keyphrase})] } {
            set translation $translation_array($locale-${keyphrase})
        } else {
            set translation $phrase
        }
                      set translation [quote_xml_values $translation]
                      puts $newId "<msg key=\"${keyphrase}\">$translation</msg>"
    }
    close $newId
}
