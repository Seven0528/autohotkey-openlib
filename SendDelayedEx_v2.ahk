SendDelayedEx(keys, keydelay:=A_KeyDelay, blind_mode:=false)    { ; v2.0
    (keydelay~="[^\d]"?keydelay:=10:"")
    ,sleep_key:="{Sleep " keydelay "}"
    ;---------------------------------
    ,spo:=1
    if blind_mode   {
        if (keydelay!=A_KeyDelay)    {
            SetKeyDelay(keydelay)
            ,prev_KeyDelay:=A_KeyDelay
        }  else  {
            prev_KeyDelay:=""
        }
        For k,v in Map("Ctrl",GetKeyState("Ctrl","P"),"Alt",GetKeyState("Alt","P"),"Shift",GetKeyState("Shift","P"),"LWin",GetKeyState("LWin","P"),"RWin",GetKeyState("RWin","P"))
            (v?modifierkey_blindup.="{" k " up}":"")
        SendEvent("{Blind}" modifierkey_blindup)
    }
    While RegExMatch(SendDelayed(keys,"ret" keydelay),"sD`a)(.*?)\Q" sleep_key "\E",&m,spo)    {
        SendInput(m.1)
        ,Sleep(keydelay)
        ,spo:=m.pos(0)+m.len(0)
    }
    if blind_mode   {
        For k,v in Map("Ctrl",GetKeyState("Ctrl","P"),"Alt",GetKeyState("Alt","P"),"Shift",GetKeyState("Shift","P"),"LWin",GetKeyState("LWin","P"),"RWin",GetKeyState("RWin","P"))
            (v?modifierkey_blinddown.="{" k " down}":"")
        SendEvent("{Blind}" modifierkey_blinddown)
        if prev_KeyDelay
            SetKeyDelay(prev_KeyDelay)
    }
}
#Include <SendDelayed_v2>