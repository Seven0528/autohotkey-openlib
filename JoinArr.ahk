JoinArr(array, delim:="",sep:=" : ",l_obj:="[",r_obj:="]")    { ; v
	static dpt:=0
	dpt++
    (delim==""?delim:=["`n",", "]:"")
    Switch IsObject(delim)
    {
        case true:
            if (VerCompare(A_AhkVersion,"2.0-")>=0)
                c_delim:=(dpt<=delim.Length)
                            ?delim[dpt]
                            :delim[delim.Length]
            else
                c_delim:=(dpt<=delim.Length())
                    ?delim[dpt]
                    :delim[delim.Length()]
        case false:
            c_delim:=delim
    }
	For k,v in array
		str.=IsObject(v)
	        ?c_delim (k!=A_Index?k sep:"") l_obj %A_ThisFunc%(v) r_obj
            :c_delim (k!=A_Index?k sep:"") v
	dpt--
	return RegExReplace(str,"sD`a)^\Q" c_delim "\E(.*)","${1}")
}