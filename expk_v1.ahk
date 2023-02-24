expk(keys, allow_dup:=false)    { ; v1.1  abbreviation for explicit keys
    static transl_map:={"^":"Ctrl","+":"Shift","!":"Alt","#":"LWin"
                    ,"<^":"LCtrl","<+":"LShift","<!":"LAlt","<#":"LWin"
                    ,">^":"RCtrl",">+":"RShift",">!":"RAlt",">#":"RWin"}
    RegExMatch(keys,"isD`aO)^(.*?)(\{Text}|\{Raw})(.*)$",m)
        ?(usualKeys:=m.1    ,rawKeys:=m.2 m.3)
        :(usualKeys:=keys   ,rawKeys:="")
    ;====================================================
    spo:=1, out:=""
    While (fpo:=RegExMatch(usualKeys
    , "s`aO)(?<!\{)(?P<affix>(?:[<>]?[\Q^+!#\E])+)"
    . "(?P<main>\{.+?}|[^\Q^+!#{}\E])",m,spo))    {
        out.=SubStr(usualKeys,spo,fpo-spo), spo:=m.pos(0)+m.len(0)
        ,vmain:=m.main
        ,vaffix:=m.affix
        ,(vmain~="D`a)^([A-Z]|\{[A-Z]})$"?(vmain:=Format("{:L}",vmain), vaffix.="+"):"")
        ;---------------------------------
        ,affixlist:=[]
        ,prev_LoopField:= curr_LoopField:= ""
        Loop, Parse, % vaffix
        {
            prev_LoopField:=curr_LoopField, curr_LoopField:=A_LoopField
            (prev_LoopField~="<|>")
                ?affixlist[affixlist.Length()].=curr_LoopField
                :affixlist.Push(curr_LoopField)
        }
        ;---------------------------------
        prifix:= suffix:= ""
        ,modifierkey_count:={Ctrl:0,LCtrl:0,RCtrl:0
                            ,Alt:0,LAlt:0,RAlt:0
                            ,Shift:0,LShift:0,RShift:0
                            ,Win:0,LWin:0,RWin:0}
        For i,v in affixlist    {
            modifierkey_count[modifierkey:=transl_map[v]]++
            Switch !!allow_dup
            {
                case false:
                    if (2<=modifierkey_count[modifierkey])
                        continue
            }
            prifix.="{" modifierkey " down}"
            ,suffix:="{" modifierkey " up}" suffix
        }
        out.=prifix . vmain . suffix
    }
    out.=SubStr(usualKeys,spo)
    return out . rawKeys
}