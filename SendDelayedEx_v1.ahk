SendDelayedEx(keys, keydelay:="", blind_mode:=true)    { ; v1.1
    (keydelay==""?keydelay:=A_KeyDelay:"", keydelay~="[^\d]"?keydelay:=10:"")
    ,sleep_key:="{Sleep " keydelay "}"
    ;---------------------------------
    ,spo:=1
    if blind_mode   {
        if (keydelay!=A_KeyDelay)    {
            SetKeyDelay, -1
            prev_KeyDelay:=A_KeyDelay
        }  else  {
            prev_KeyDelay:=""
        }
        For k,v in modifierkey_state:={"LCtrl":GetKeyState("LCtrl","P"),"RCtrl":GetKeyState("RCtrl","P")
                                        ,"LAlt":GetKeyState("LAlt","P"),"RAlt":GetKeyState("RAlt","P")
                                        ,"LShift":GetKeyState("LShift","P"),"RShift":GetKeyState("RShift","P")
                                        ,"LWin":GetKeyState("LWin","P"),"RWin":GetKeyState("RWin","P")}
            (v?modifierkey_blindup.="{" k " up}":"")
        SendEvent, % "{Blind}" modifierkey_blindup
    }
    While RegExMatch(SendDelayed(keys,"ret" keydelay),"sD`aO)(.*?)\Q" sleep_key "\E",m,spo)    {
        SendInput, % (blind_mode?"{Blind}":"") m.1
        Sleep, % keydelay
        spo:=m.pos(0)+m.len(0)
    }
    if blind_mode   {
        For k,v in modifierkey_state
            (v?modifierkey_blinddown.="{" k " down}":"")
        SendEvent, % "{Blind}" modifierkey_blinddown
        if prev_KeyDelay
            SetKeyDelay, % prev_KeyDelay
    }
}
#Include <SendDelayed_v1>