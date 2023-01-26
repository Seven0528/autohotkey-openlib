HotkeySplit(vhotkey)    { ; v1.0
    if !RegExMatch(vhotkey,"iDO)^(?P<pre>~?)(?P<k1>.+?)[ `t]+&[ `t]+(?P<k2>.+?)(?P<up>[ `t]+up)?$",m)
    && !RegExMatch(vhotkey,"iDO)^(?P<pre>[\Q#!^+&<>*~$\E]*)"
                        . "(?P<k2>[^a-zA-Z0-9]|[a-zA-Z0-9]+?)(?P<up>[ `t]+up)?$",m)
        return
    ahotkey:={OriginKey:vHotkey
            ,Prefix:m.pre
            ,IsMainUp:!!m.up
            ,HotKey:""
            ,SubKey:""
            ,MainKey:""}
    Loop 2    {
        if (m[pname:=(A_Index==1?"k1":"k2")]=="")
            continue
        ahotkey[(A_Index==1?"SubKey":"MainKey")]:=HotkeyTitleCase(m[pname])
    }
    ahotkey.HotKey:=(ahotkey.SubKey!=""?ahotkey.SubKey " & ":"")
                    . ahotkey.MainKey . (ahotkey.IsMainUp?" Up":"")
    return ahotkey
}
#Include <HotkeyTitleCase>