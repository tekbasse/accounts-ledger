ad_library {

    Simple set-manipulation procedures.

    @creation-date 19 January 2001
    @author Eric Lorenzo (elorenzo@arsdigita.com)
    # Recovered from deprecation at Openacs 5.8 package acs-tcl/tcl/set-operations-procs.tcl
    #@cvs-id $Id: set-operation-procs.tcl,v 1.3.8.2 2014/09/09 13:34:49 gustafn Exp $
    # Subsequently renamed procs to avoid name collision. --Benjamin Brink
}

ad_proc -public set_v_member_of_s_q { s v } {
    Tests whether or not $v is a member of set $s. s is a list.
} {
    if {$v ni $s} {
        return 0
    } else {
        return 1
    }
}


ad_proc -public set_s_name_add_v { s_name v } {
    Adds the element v to the set named s_name in the calling
    environment, if it isn't already there.
} {
    upvar $s_name s
    
    if { ![set_v_member_of_s_q $s $v] } {
        lappend s $v
    }
}



ad_proc -public set_union { u v } {
    Returns the union of sets $u and $v. Both u and v are lists.
} {
    set result $u

    foreach ve $v {
        if { ![set_v_member_of_s_q $result $ve] } {
            lappend result $ve
        }
    }
    return $result
}


ad_proc -public set_s_named_union_v { u_name v } {
    Computes the union of the set stored in the variable
    named $u_name in the calling environment and the set v (list),
    sets the variable named $u_name in the calling environment
    to that union, and also returns that union.
} {
    upvar $u_name u

    foreach ve $v {
        if { ![set_v_member_of_s_q $u $ve] } {
            lappend u $ve
        }
    }
    return $u
}


ad_proc -public set_intersection { u v } {
    Returns the intersection of sets $u and $v. Both u and v are lists.
} {
    set result [list]
    
    foreach ue $u {
        if { [set_v_member_of_s_q $v $ue] } {
            lappend result $ue
        }
    }
    return $result
}

ad_proc -public set_intersection_named_v { u_name v } {
    Computes the intersection of the set stored in the variable
    named $u_name in the calling environment and the set v (list),
    sets the variable named $u_name in the calling environment
    to that intersection, and also returns that intersection.
} {
    upvar $u_name u
    set result [list]
    
    foreach ue $u {
        if { [set_v_member_of_s_q $v $ue] } {
            lappend result $ue
        }
    }
    set u $result
    return $result
}

ad_proc -public set_difference { u v } {
    Returns the difference of sets $u and $v.  
    i.e. The set of all members of u that aren't also members of $v.
} {
    set result [list]

    foreach ue $u {
        if { ![set_v_member_of_s_q $v $ue] } {
            lappend result $ue
        }
    }
    return $result    
}

ad_proc -public set_difference_named_v { u_name v } {
    Computes the difference of the set stored in the variable (list)
    named $u_name in the calling environment and the set v,
    sets the variable named $u_name in the calling environment
    to that difference, and also returns that difference.
} {
    upvar $u_name u
    set result [list]

    foreach ue $u {
        if { ![set_v_member_of_s_q $v $ue] } {
            lappend result $ue
        }
    }
    set u $result
    return $result
}

