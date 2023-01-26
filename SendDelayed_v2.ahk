SendDelayed(keys, keydelay:=A_KeyDelay, transl_only:=false)    {
    static transl_map:=Map("`n","{Enter}","`r","{Enter}","`t","{Tab}","`b","{BS}")
    (keydelay~="[^\d]"?keydelay:=10:"")
    ,sleep_key:="{Sleep " keydelay "}"
    ;---------------------------------
    RegExMatch(keys,"isD`a)^(.*?)(\{Text}|\{Raw})(.*)$",&m)
        ?(usualKeys:=m.1    ,rawKeys:=m.3, rawType:=m.2)
        :(usualKeys:=keys   ,rawKeys:="")
    ;====================================================
    out1:=""
    if (usualKeys!="")    {
        spo:=1
        While (fpo:=RegExMatch(usualKeys
        , "s`a)(?<!\{)(?P<affix>(?:[<>]?[\Q^+!#\E])+)"
        . "(?P<main>\{.+?}|[^\Q^+!#{}\E])",&m,spo))    {
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
        While (RegExMatch(rawKeys,"s`a)(.)",&m,spo)) ; to consider outside the BMP(basic multilingual plane)
            rawKeys_list.Push(m.0), spo:=m.pos(0)+m.len(0)
        For i,v in rawKeys_list    {
            out2.=transl_map.Has(v)
                ?transl_map.Get(v) sleep_key
                :"{U+" Format("{:04X}",Ord(v)) "}" sleep_key
        }
    }

    Switch !!transl_only
    {
        case true:      return out1 . out2
        case false:     SendInput(out1 . out2)
    }  
}