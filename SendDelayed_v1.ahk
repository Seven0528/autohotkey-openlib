SendDelayed(keys, keydelay:="")    { ; v1.1
    static transl_map:={"`n":"{Enter}","`r":"{Enter}","`t":"{Tab}","`b":"{BS}"}
    if RegExMatch(keydelay,"is`aO)^ret(.*)",m)
        transl_only:=true, keydelay:=m.1
    else
        transl_only:=false
    (keydelay==""?keydelay:=A_KeyDelay:"", keydelay~="[^\d]"?keydelay:=10:"")
    ,sleep_key:="{Sleep " keydelay "}"
    ;---------------------------------
    RegExMatch(keys,"isD`aO)^(.*?)(\{Text}|\{Raw})(.*)$",m)
        ?(usualKeys:=m.1    ,rawKeys:=m.3, rawType:=m.2)
        :(usualKeys:=keys   ,rawKeys:="")
    ;====================================================
    out1:=""
    if (usualKeys!="")    {
        spo:=1
        While (fpo:=RegExMatch(usualKeys
        , "s`aO)(?<!\{)(?P<affix>(?:[<>]?[\Q^+!#\E])*)"
        . "(?P<main>\{.+?}|[^\Q^+!#{}\E])",m,spo))    {
            vsimple:=SubStr(usualKeys,spo,fpo-spo), vsimple:=RegExReplace(vsimple,"s`a)(.)","${1}" sleep_key)
            ,vcombi:=m.0 sleep_key
            ,out1.=vsimple . vcombi
            ,spo:=m.pos(0)+m.len(0)
        }
        vsimple:=SubStr(usualKeys,spo), vsimple:=RegExReplace(vsimple,"s`a)(.)","${1}" sleep_key)
        ,out1.=vsimple
    }
    out2:=""
    if (rawKeys!="")    {
        rawKeys_list:=[]
        ,(rawType~="i)\{Text}"?rawKeys:=StrReplace(rawKeys,"`r`n","`n"):"")
        ,spo:=1
        While (RegExMatch(rawKeys,"s`aO)(.)",m,spo)) ; to consider outside the BMP(basic multilingual plane)
            rawKeys_list.Push(m.0), spo:=m.pos(0)+m.len(0)
        For i,v in rawKeys_list    {
            out2.=transl_map.HasKey(v)
                ?transl_map[v] sleep_key
                :"{U+" Format("{:04X}",Ord(v)) "}" sleep_key
        }
    }

    Switch transl_only
    {
        case true:      return out1 . out2
        case false:     SendInput, % out1 . out2
    }    
}