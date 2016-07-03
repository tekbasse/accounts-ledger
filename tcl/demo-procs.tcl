# demo-procs.tcl
ad_library {

    procedures for building demonstrations
    @creation-date 11 December 2013
    @Copyright (c) 2014 Benjamin Brink
    @license GNU General Public License 2, see project home or http://www.gnu.org/licenses/gpl-2.0.html
    @project home: http://github.com/tekbasse/accounts-ledger
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com
}

ad_proc -private qal_namelur { 
    {n "3"}
    {m "5"}
    {dot "."}
} {
    @param n     word count
    @param m     Max pseudo-syllables.
    @param dots  Substitute a period with another letter or space or empty string.
    @return N words up to M pseudo-syllables. Words of one call may not be unique.
    
    Inspired by namelur GNU GPL v2 licensed, originally coded in C. 
    Code and following starwars configuration data retrieved from 
    https://sourceforge.net/projects/namelur/ on 3 June 2016
} {
    # from namelur/nar/starwars.nar # 
    # sw_names.txt converted by Namelur (C) legolas558
    # The double spaces in the original file are meant to provide a space.
    # Here, they have been revised to insert initials and/or capitalization.
    set r1 [randomRange 1]
    set r2 [randomRange 1]
    incr r1
    incr r2
    set mystery1 [ad_generate_random_string ]
    set mystery2 [ad_generate_random_string ]
    regsub -all -- {[0-9]+} $mystery1 $dot  mystery1
    regsub -all -- {[0-9]+} $mystery2 $dot  mystery2
    set mystery1 [string range "[string trim $mystery1 " ${dot}"]${dot}" 0 $r1]
    set mystery2 [string range "[string trim $mystery2 " ${dot}"]${dot}" 0 $r2]
    #ns_log Notice "qal_namelur.36: mystery1 $mystery1 mystery2 $mystery2"
    set n_list [list \
                    v10790 ${mystery1} 2 \
                    v382 a 4 \
                    v409 e 4 \
                    v170 i 4 \
                    v20 ae 4 \
                    v40 ee 4 \
                    v224 o 4 \
                    v327 a 1 \
                    v113 y 4 \
                    v94 y 1 \
                    v60 ye 4 \
                    v6 ea 4 \
                    v20 oo 4 \
                    v4 oi 4 \
                    v29 u 4 \
                    v4 yo 4 \
                    v11 ei 4 \
                    v34 ia 4 \
                    v4 eu 4 \
                    v15 ay 4 \
                    v5 yu 4 \
                    v1 oa 4 \
                    v3 eo 4 \
                    v8 yi 4 \
                    v2 ya 4 \
                    v6 oe 4 \
                    c82 p 4 \
                    c226 h 4 \
                    c72 f 1 \
                    c6201 ${mystery2} 2 \
                    c1083 r 4 \
                    c471 m 4 \
                    c465 k 4 \
                    c411 t 4 \
                    c646 l 4 \
                    c490 n 4 \
                    c224 t 1 \
                    c270 s 4 \
                    c74 kr 4 \
                    c154 s 1 \
                    c42 sr 4 \
                    c50 ht 4 \
                    c174 tr 4 \
                    c7 tl 4 \
                    c183 w 4 \
                    c23 ll 4 \
                    c7 ds 4 \
                    c92 h 1 \
                    c1 tg 4 \
                    c181 sh 4 \
                    c188 j 4 \
                    c73 hr 4 \
                    c151 n 1 \
                    c30 ms 4 \
                    c42 th 4 \
                    c193 d 4 \
                    c144 b 4 \
                    c148 g 4 \
                    c105 q 4 \
                    c26 ng 4 \
                    c71 sk 4 \
                    c42 rh 4 \
                    c3 ft 4 \
                    c70 ch 4 \
                    c60 l 1 \
                    c238 c 4 \
                    c4 rk 4 \
                    c3 dp 4 \
                    c2 fd 4 \
                    c14 fr 4 \
                    c4 kt 4 \
                    c32 dg 4 \
                    c47 f 4 \
                    c5 dn 4 \
                    c1 tp 4 \
                    c6 kn 4 \
                    c29 g 1 \
                    c26 rn 4 \
                    c80 z 4 \
                    c2 fv 4 \
                    c52 d 1 \
                    c134 dr 4 \
                    c28 pr 4 \
                    c18 dk 4 \
                    c36 ck 4 \
                    c3 fc 4 \
                    c4 hm 4 \
                    c9 dm 4 \
                    c8 rr 4 \
                    c4 rm 4 \
                    c6 tm 4 \
                    c5 hk 4 \
                    c5 fh 4 \
                    c4 fw 4 \
                    c9 kl 4 \
                    c5 dw 4 \
                    c12 dl 4 \
                    c1 tb 4 \
                    c4 tk 4 \
                    c3 hq 4 \
                    c4 rw 4 \
                    c7 dc 4 \
                    c12 dd 4 \
                    c6 hl 4 \
                    c2 hc 4 \
                    c4 ks 4 \
                    c5 db 4 \
                    c3 rl 4 \
                    c2 kv 4 \
                    c2 ts 4 \
                    c7 dt 4 \
                    c6 kh 4 \
                    c1 hv 4 \
                    c1 fb 4 \
                    c33 v 4 \
                    c5 kw 4 \
                    c3 hn 4 \
                    c5 rs 4 \
                    c2 kq 4 \
                    c2 tt 4 \
                    c6 km 4 \
                    c1 hw 4 \
                    c3 fk 4 \
                    c6 dh 4 \
                    c2 hd 4 \
                    c3 dv 4 \
                    c2 rq 4 \
                    c7 kk 4 \
                    c1 rc 4 \
                    c1 hh 4 \
                    c2 fp 4 \
                    c4 kd 4 \
                    c2 hb 4 \
                    c2 fm 4 \
                    c2 rg 4 \
                    c1 tc 4 \
                    c2 hp 4 \
                    c1 tw 4 \
                    c1 fn 4 \
                    c2 fl 4 \
                    c1 kc 4 \
                    c2 kb 4 \
                    c2 rb 4 \
                    c3 rt 4 \
                    c1 td 4 \
                    c1 fq 4 \
                    c1 fg 4 \
                    c1 kg 4 ]
    # create x y table for statistical proc
    set header [list x y ]
    set bc_lists [list ]
    set bv_lists [list ]
    lappend bc_lists $header
    lappend bv_lists $header
    set mc_lists [list ]
    set mv_lists [list ]
    lappend mc_lists $header
    lappend mv_lists $header
    set ec_lists [list ]
    set ev_lists [list ]
    lappend ec_lists $header
    lappend ev_lists $header

    set y 0
    set y_prev 0
    set bc_counter 0
    set bv_counter 0
    set ec_counter 0
    set ev_counter 0
    foreach entry $n_list {
        switch -regexp -- $entry {
            ^[c][0-9]+$ {
                set letter "c"
                set x [string range $entry 1 end]
                #ns_log Notice "qal_namelur.196. entry '${entry}' c x ${x}"
            }
            ^[v][0-9]+$ {
                set letter "v"
                set x [string range $entry 1 end]
                #ns_log Notice "qal_namelur.201. entry '${entry}' v x ${x}"
            }
            ^[A-Za-z\ \.]+$ {
                set y_prev $y
                set y_arr(${y}) $entry
                incr y
                #ns_log Notice "qal_namelur.206. entry '${entry}' y_arr(${y}) '${entry}'"
            }
            ^[0-9]+$ {
                set row [list $x $y_prev]
                #ns_log Notice "qal_namelur.209. entry '${entry}' row '${row}'"
                if { [expr { $entry & 4 } ] == 4 } {
                    # can be in middle
                    if { $letter eq "c" } {
                        lappend mc_lists $row
                        #ns_log Notice "qal_namelur.215. entry '${entry}' mc"
                    } elseif { $letter eq "v" } {
                        lappend mv_lists $row
                        #ns_log Notice "qal_namelur.218. entry '${entry}' mv"
                    }
                }
                if { [expr { $entry & 2 } ] == 2 } {
                    # can be at beginning
                    if { $letter eq "c" } {
                        lappend bc_lists $row
                        incr bc_counter
                        #ns_log Notice "qal_namelur.215. entry '${entry}' bc"
                    } elseif { $letter eq "v" } {
                        incr bv_counter
                        lappend bv_lists $row
                        #ns_log Notice "qal_namelur.215. entry '${entry}' bv"
                    }
                }
                if { [expr { $entry & 1 } ] == 1 } {
                    # can be at end of word
                    if { $letter eq "c" } {
                        incr ec_counter
                        lappend ec_lists $row
                        #ns_log Notice "qal_namelur.215. entry '${entry}' ec"
                    } elseif { $letter eq "v" } {
                        incr ev_counter
                        lappend ev_lists $row
                        #ns_log Notice "qal_namelur.215. entry '${entry}' ev"
                    }
                }
            }
            default {
                if { $entry ne "" } {
                    ns_log Notice "qal_namelur.237: rejecting entry '${entry}'"
                }
            }
        }
    }
    #ns_log Notice "qal_namelur.239: bc_lists '${bc_lists}' bc_counter ${bc_counter}"
    set names_list [list ]
    # set up weighted beginnings and ends based on count of vowels vs constants
    set bv_fraction [expr { $bv_counter / ( $bv_counter + $bc_counter + 1 ) } ]
    set ev_fraction [expr { $ev_counter / ( $ev_counter + $ec_counter + 1 ) } ]
    for {set j 0} {$j < $n} {incr j} {
        set chars_list [list ]
        if { [random] < $bv_fraction } {
            set y1 [qaf_y_of_x_dist_curve [random] $bc_lists]
            set y1 [expr { round($y1) } ]
            lappend chars_list $y_arr(${y1})
        } 
        set y1 [qaf_y_of_x_dist_curve [random] $bv_lists]
        set y1 [expr { round($y1) } ]
        lappend chars_list $y_arr(${y1})

        set max [randomRange $m]
        for {set i 1 } {$i < $max } { incr i } {
            set ymc [qaf_y_of_x_dist_curve [random] $mc_lists]
            set ymc [expr { round($ymc) } ]
            lappend chars_list $y_arr(${ymc})
            set ymv [qaf_y_of_x_dist_curve [random] $mv_lists]
            set ymv [expr { round($ymv) } ]
            lappend chars_list $y_arr(${ymv})
        }
        set yec [qaf_y_of_x_dist_curve [random] $ec_lists]
        set yec [expr { round($yec) } ]
        lappend chars_list $y_arr(${yec})
        if { [random] < $ev_fraction } {
            set yev [qaf_y_of_x_dist_curve [random] $ev_lists]
            set yev [expr { round($yev) } ]
            lappend chars_list $y_arr(${yev})
        }
        lappend names_list [join $chars_list ""]
    }
    return $names_list
}

