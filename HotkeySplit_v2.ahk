HotkeySplit(vhotkey)    { ; v2.0
    if !RegExMatch(vhotkey,"iD)^(?P<pre>~?)(?P<k1>.+?)[ `t]+&[ `t]+(?P<k2>.+?)(?P<up>[ `t]+up)?$",&m)
    && !RegExMatch(vhotkey,"iD)^(?P<pre>[\Q#!^+&<>*~$\E]*)"
                        . "(?P<k2>[^a-zA-Z0-9]|[a-zA-Z0-9]+?)(?P<up>[ `t]+up)?$",&m)
        return
    ahotkey:=Map("OriginKey",vhotkey
                ,"Prefix",m.pre
                ,"IsMainUp",!!m.up
                ,"HotKey",""
                ,"SubKey",""
                ,"MainKey","")
    Loop 2    {
        try     m[pname:=(A_Index==1?"k1":"k2")]
        catch
            continue        
        ahotkey[(A_Index==1?"SubKey":"MainKey")]:=HotkeyTitleCase(m[pname])
    }
    ahotkey["HotKey"]:=(ahotkey.Get("SubKey")!=""?ahotkey.Get("SubKey") " & ":"")
                    . ahotkey.Get("MainKey") . (ahotkey.Get("IsMainUp")?" Up":"")
    return ahotkey
}
#Include <HotkeyTitleCase>