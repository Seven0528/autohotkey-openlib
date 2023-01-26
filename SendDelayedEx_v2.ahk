SendDelayedEx(keys, keydelay:=A_KeyDelay)    { ; requires SendDelayed()
    (keydelay~="[^\d]"?keydelay:=10:"")
    ,sleep_key:="{Sleep " keydelay "}"
    ;---------------------------------
    ,spo:=1
    While RegExMatch(SendDelayed(keys,keydelay,true),"sD`a)(.*?)\Q" sleep_key "\E",&m,spo)    {
        SendInput(m.1)
        ,Sleep(keydelay)
        ,spo:=m.pos(0)+m.len(0)
    }
}
#Include <SendDelayed_v2>