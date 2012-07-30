

proc long_csv_parse {line quoteVal} {

# setup other constants etc.
    if {[string length quoteVal] == 0 } {
        set quoteVal "\""
    }
    set beginStringVal ",${quoteVal}"
    set endStringVal "${quoteVal},"
    set DeBug 0
    set no_parse_error 1

    set field_current 1
    set field_to_append ""
    set lineA ",$line,"
    set linePos 0
    set lineLen [string length $lineA]
    set lastField [expr $lineLen - 1] 

    set return_list [list]

    # while more fields remain in line
    while {$linePos < $lastField && $no_parse_error} {
      # open brace D

      set newFieldDelim [string range $lineA $linePos [expr $linePos + 1]]
      set remainingRecord [string range $lineA [expr $linePos + 1] $lineLen]
      set fieldIsString [string compare $newFieldDelim $beginStringVal]
      if {$fieldIsString == 0} {
        # this field is a string.. (cases 4,5,6)
        # case 4: string-field then end of record
        # case 5: string-field then another string-field
        # case 6: string-field then number-field
        set testlinePos $linePos
        set consistent 0

        while {$consistent == 0 && $no_parse_error} {
        # open brace E
        # guessing beginning of current field is: $testlinePos
        # further guessing ending of current field is: $qEOField a position of $endStringVal found
        # guess end of field
        set testRemainingRecord [string range $lineA [expr $testlinePos + 1] $lineLen]
        set qEOField [string first $endStringVal $testRemainingRecord]
        # note $testRemainingRecord clips the leftmost comma to prevent finding that delimiter

        if { $qEOField == -1} {
          puts "\t==> $pattern_current"
          put "Parse, error(ref BB): No end-field delimiter found for a string field."
	      # This line has an Unrecoverable parse error (program ref: BB)
          #error
          #  this is position BB
	      set no_parse_error 0
          break
        }

        set lastStringField [expr [string length $testRemainingRecord] - 2]
        if {[string compare $qEOField $lastStringField] == 0} {
          #    reached end of record
          set consistent 1
          } else {
         
          # examine next field based on testlinePos is accurate
          # Is next field a num or quoted field? how does next field begin?
          set loc4 [expr $qEOField + 2]
          # loc4 is the character after the comma
          set loc4type [string index $testRemainingRecord $loc4]
 
          # how does next of field end, and what does it contain?
          # set testNextField to the $testRemainingRecord string less the current guessed field (same offset no comma)
          set testNextField [string range $lineA [expr $loc4 + $testlinePos + 1] $lineLen]
 
          set isquote [string compare $loc4type $quoteVal]
          # isquote=0 is true
          if {$isquote == 0} {
            # test/confirm adjacent complete STRING FIELD
            set qEOField2 [expr 1 + [string first $endStringVal $testNextField]]
            set qSOField2 [string first $beginStringVal $testNextField]
 
            # qSOField2 needs to search with an offset, so as to not find the first field's delim again
            # qSOField2 is a BEGINNING DELIMITER IE. ',"'!
 
            # is qEOField2 a comma?
            set checkEndFieldPos [string compare [string index $testNextField $qEOField2] ","]
            if {$checkEndFieldPos != 0} {
              puts "\t==> $pattern_current"
              puts "Parse, Error(ref FF): endFieldPos: qEOField2 does not represent a comma!\nqEOField2=$qEOField2"
              # error
        	  set no_parse_error 0
              break
            }
            # is qSOField2 a comma?
            set checkEndFieldPos [string compare [string index $testNextField [expr $qSOField2]] ","]
            if {$checkEndFieldPos != 0 && $qSOField2 > -1} {
              puts "\t==> $pattern_current"
              puts "Parse error(ref GG): endFieldPos: qSOField2+1 does not represent a comma!\nqSOField2=$qSOField2"
              # error
              set no_parse_error 0
              break
            }
            # qSOField2 is Start of Field
            if { ($qEOField2 <= $qSOField2) || ($qSOField2 == -1 && $qEOField2 > -1)} {
              set consistent 1
              set endfieldK 2
            }
          } else {
 
          # test/confirm adjacent complete NUMBER FIELD
          set testAdjField ",$testNextField"
          set endfieldK 2
          set consistent [regexp {^,(-?[a-zA-Z0-9\.]*),} $testAdjField newFieldVal]
 
          # consistent=0 is false, consistent=1 is true
          }
        }
        set testlinePos  [expr $qEOField + $testlinePos + $endfieldK]
        # in case not consistent, moving testlinePos forward
        # is testlinePos a comma?
        set checkEndFieldPos [string compare [string index $lineA $testlinePos] ","]
        if {$checkEndFieldPos != 0} {
          puts "\t==> $pattern_current"
          puts "Parse error(ref EE): endFieldPos does not represent a comma!\ntestlinePos=$testlinePos"
          # error
          set no_parse_error 0
          break
        }
    
      }
      #close brace E
      # if $consistent==0, check next end-field flag for consistency
      set endField [expr $testlinePos - $linePos - 1]
      set endFieldPos [expr $endField + $linePos + 1]
 
      set fieldVal [string range $lineA $linePos $endFieldPos]
      set newFieldVal [string range $lineA [expr $linePos + 2] [expr $endFieldPos - 2]]
      lappend return_list $newFieldVal

 # This is where one can reference the field value "newFieldVal" for use in creating more (calculated) fields

 
      set checkEndFieldPos [string compare [string index $lineA $endFieldPos] ","]

      if {$DeBug == 1} {
        puts "endField$endField"
        puts "endFieldPos$endFieldPos"
        puts "fieldVal$fieldVal"
        puts "newFieldVal$newFieldVal"
        # puts "loc4$loc4\nloc4type$loc4type\ntestRemainingRecord$testRemainingRecord\ntestAdjField$testAdjField"
        # puts "testNextField$testNextField\nnewFieldVal$newFieldVal"
        set DeBug 0
      }
      if {$checkEndFieldPos != 0} {
        puts "\t==> $pattern_current"
        puts "Parse error(ref CC): endFieldPos does not represent a comma!\nendFieldPos=$endFieldPos"
        # error
	    set no_parse_error 0
        break
     }
	if {[string compare $linePos $endFieldPos] == 0} {
        puts "\t==> $pattern_current"
        puts $errorInfo
        error
      }
      set linePos $endFieldPos
      append pattern_current "_"
      set field_current [expr $field_current + 1 ]
      } else {
      # this field is not a string, assuming a number.. (cases 1,2,3)
      # case 1: number-field then end of record
      # case 2: number-field then a string-field
      # case 3: number-field then number-field

      set remainingRecord [string range $lineA [expr $linePos] $lineLen]

      set isnum [regexp {^,(-?[a-zA-Z0-9\.]*),} $remainingRecord newFieldVal]
      #allows for single words without quotes

      # newFieldVal retains last value where $isnum is true ie 1, false is 0
      # if true, process... identified field, remove it from remaining record... leave leftmost comma


      if {$isnum == 1} {
        set endField [string length $newFieldVal]
      } else {
        # try not to fail, if it's a single character, try to recover by treating it as if it is quoted.
        set remainingRecord [string range $lineA [expr $linePos] $lineLen]
        set isnum [regexp {^,([^,]?),} $remainingRecord newFieldVal]
        if {$isnum == 1} {
          set endField [string length $newFieldVal]
        } else {
          puts "\t==> $pattern_current"
          puts "Parse error(ref AA)."
          # error
          # program comment AA
          # this pattern fails here:  , ea, 
          set no_parse_error 0
          break
        }
      }
 
      set endFieldPos [expr $endField + $linePos - 1]
      set fieldVal [string range $lineA $linePos $endFieldPos]
      set newFieldVal [string range $lineA [expr $linePos + 1] [expr $endFieldPos - 1]]
      lappend return_list $newFieldVal 

# This is where one can reference the field value "newFieldVal" for use in creating more (calculated) fields
      if {$field_current == 3 || $field_current == 2 } {
set newfield_to_append [newfield3 $newFieldVal]
set field_to_append "$field_to_append$newfield_to_append"
   }
 

      set checkEndFieldPos [string compare [string index $lineA $endFieldPos] ","]
      if {$checkEndFieldPos != 0} {
        puts "\t==> $pattern_current"
        puts "Parse error (ref DD): endFieldPos does not represent a comma!"
        # error
        set no_parse_error 0
        break
      }
      if {[string compare $linePos $endFieldPos] == 0} {
        puts "\t==> $pattern_current"
        puts $errorInfo
        error
      }
      set linePos $endFieldPos
      append pattern_current "."
      set field_current [expr $field_current + 1 ]

    }
    # end case 1,2,3 processing
    
# returning a list so no need to add a new delimiter here

  # close brace D
  }
return $return_list
}

# this is where one can add new fields based on same record, previous field values

#  puts $newId "$field_to_append"



#  if {$lineCounter == 1} {
#    set pattern_primary $pattern_current
#    puts "\n$lineCounter\t==> $pattern_current "
#  } else { 
#    if {$pattern_primary != $pattern_current && $no_parse_error} {
#      puts "\t==> $pattern_current "
#      puts "Line $lineCounter does not match field type pattern of primary"
#    }
#  }
#  set pattern_current ""
  #puts ";)  $lineCounter"

  ###### test line follows
  #####error



