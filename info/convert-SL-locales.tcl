#!/usr/bin/tclsh8.0
# \
exec tclsh "$0" ${1+"$@"}
#


# this program convers sql-ledger locale files to openacs catalog il8n xml files
# run from the accounts-ledger/catalog directory
# expects txt files in accounts-ledger/catalog/txt/*

# puts -nonewline "file to convert: "
# flush stdout
# set slfilenam [gets stdin]



set sl_file_list [glob [file join $sl_loc_dir "*" "all"]]
foreach slfilenampath $sl_file_list {
# set slfilenam [string range $slfilenampath 4 end]
    set slfilenam [string range $slfilenampath [expr [string length $sl_loc_dir] + 1] end-4]
    
 if { [info exists dirmap($slfilenam)] } {

  set charset "ISO-8859-1"
  if [catch {open $slfilenampath r} slId] {
      puts stderr "Cannot open $slfilenam: $slId for read."
  } else {
      puts "reading: $slfilenam"
      # open database file, open brace A
      #
      gets $slId line
      while { ![string match "*self{texts}*" $line ] } {
          if { [string match "*self{charset}*" $line ] } {
              set begin_quote [expr 1 + [string first "'" $line ] ]
              set end_quote [expr [string first "'" $line $begin_quote ] - 1 ]
              set charset [string range $line $begin_quote $end_quote ]
          }
          gets $slId line
#          puts -nonewline "r"
      }

      set locale $dirmap($slfilenam)

      set newFile [file join $qal_cat_dir "accounts-ledger.${locale}.$charset.xml"]
 
      if [catch {open $newFile w} newId] {
          puts stderr "Cannot open $newFile: $newId for write."
      } else {
          # open output file, open brace B
          #
#          puts stdout "w"
          puts $newId "<?xml version=\"1.0\" encoding=\"$charset\"?>
<message_catalog package_key=\"accounts-ledger\" package_version=\"0.1d\" locale=\"${locale}\" charset=\"$charset\">

"

          while {[gets $slId line] >= 0} {
#              puts -nonewline "r"
              if { [string match "* => *" $line ] && ![string match "*'',*" $line ]} { 
                  # get key string
                  set begin_quote1 [expr 1 + [string first "'" $line ] ]
                  set end_quote1 [expr [string first "'" $line $begin_quote1 ] - 1 ]
                  set phrase [string range $line $begin_quote1 $end_quote1 ]
                  regsub -all -- {[^a-zA-Z0-9\!]} $phrase "_" full_phrase2 

                  set full_phrase [string trimright ${full_phrase2} "_"]
                  regsub -all -- {[^a-zA-Z0-9]} ${full_phrase} "_" key_phrase 

                  # need to properly differentiate between 'Printing' and 'Printing ...'
                  if { [string equal [string range $phrase 0 7] "Printing"] && [string length $phrase] > 9} {
                      set key_phrase "Printing_"
                  }

                  set begin_quote2 [expr 1 + [string first "'" $line [expr $end_quote1 + 2]] ]
                  set end_quote2 [expr [string first "'" $line $begin_quote2 ] - 1 ]
                  set translation [string range $line $begin_quote2 $end_quote2 ]
  
                  # check if key is already used for a different EN phrase
                  if { [info exists key_array(${key_phrase}) ] && ![string equal $key_array(${key_phrase}) $phrase ] } {
                          set old_phrase ${key_phrase}
                      while { [info exists key_array(${key_phrase}) ] && ![string equal $key_array(${key_phrase}) $phrase ] } {
                          # modify the key for a different translation key
                          append key_phrase "_" 
                      }
                      if { ![info exists key_array(${key_phrase}) ] } {
                          puts "new key ${key_phrase} given 'key_array(${old_phrase})' = '$key_array(${old_phrase})' and <> '$phrase'(EN), here to: '$translation'"
                      }
                  }
                  # check if key has already been set for this locale
                  if { [info exists translation_array($locale-${key_phrase}) ] && [string equal $translation_array($locale-${key_phrase}) $translation] } {
                      set skip 1
                  } elseif { [info exists translation_array($locale-${key_phrase}) ] && ![string equal $translation_array($locale-${key_phrase}) $translation] } {
                      # just in case
                      puts "Two different translations for same key in one locale for '$phrase' ('$translation_array($locale-${key_phrase})' <> '$translation'. Skipping!"
                      set skip 1
                  } elseif { [string length $key_phrase] == 0 } {
                      set skip 1
                  } else {
                      set skip 0
                  }

                  if { !$skip } {
#                      puts -nonewline "w"
                      set translation [quote_xml_values $translation]
                      puts $newId "<msg key=\"${key_phrase}\">$translation</msg>"
  
                      # remember it to screen for duplications
                      # and to dump one of each key into the en_US version..
                      set key_array(${key_phrase}) $phrase
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
# create the en_US catalog file by expanding key_array

set charset "ISO-8859-1"
set locale "en_US"
set newFile [file join $qal_cat_dir "accounts-ledger.$locale.$charset.xml"]

if [catch {open $newFile w} newId] {
    puts stderr "Cannot open $newFile: $newId for write."
} else {
    set index_value_list [array get key_array]
    puts $newId "<?xml version=\"1.0\" encoding=\"$charset\"?>
<message_catalog package_key=\"accounts-ledger\" package_version=\"0.1d\" locale=\"$locale\" charset=\"$charset\">

"
    foreach {key_phrase translation} $index_value_list {
                      set translation [quote_xml_values $translation]
        if { [string length $key_phrase] > 0 } {
                      puts $newId "<msg key=\"${key_phrase}\">$translation</msg>"
        }
    }
    close $newId
}
