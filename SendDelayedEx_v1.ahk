SendDelayedEx(keys, keydelay:="")    { ; requires SendDelayed()
    (keydelay==""?keydelay:=A_KeyDelay:"", keydelay~="[^\d]"?keydelay:=10:"")
    ,sleep_key:="{Sleep " keydelay "}"
    ;---------------------------------
    ,spo:=1
    While RegExMatch(SendDelayed(keys,keydelay,true),"sD`aO)(.*?)\Q" sleep_key "\E",m,spo)    {
        SendInput, % m.1
        Sleep, % keydelay
        spo:=m.pos(0)+m.len(0)
    }
}
#Include <SendDelayed_v1>