HotkeyTitleCase(vhotkey)    {
    static list_of_keys:=GetKeyListMap()
    vtitlehotkey:=""
    (VerCompare(A_AhkVersion,"2.0-")>=0)
        ?(list_of_keys.Has(vhotkey)? vtitlehotkey:=list_of_keys[vhotkey] :"")
        :(list_of_keys.HasKey(vhotkey)? vtitlehotkey:=list_of_keys[vhotkey] :"")
    return (vtitlehotkey!="")
        ?StrReplace(vhotkey,vtitlehotkey,vtitlehotkey)
        :RegExReplace(RegExReplace(vhotkey
            ,"i)\b(vk)([a-fA-F0-9]{2})\b","$U{1}$U{2}")
            ,"i)\b(sc)([a-fA-F0-9]{3})\b","$U{1}$U{2}")
}
#Include <GetKeyListMap>