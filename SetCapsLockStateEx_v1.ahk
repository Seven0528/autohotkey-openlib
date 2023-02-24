SetCapsLockStateEx(onoff:="", retrv_CL:=true)    {
    retrv_CL?vCL:=GetKeyState("CapsLock","T"):""
    prev_StringCaseSense:=A_StringCaseSense
    StringCaseSense, Off
    Switch onoff
    {
        case "":
            SetCapsLockState
        case "On",true:
            if (retrv_CL&&vCL)
                return
            SetCapsLockState, On
        case "Off",false:
            if (retrv_CL&&!vCL)
                return
            SetCapsLockState, Off
        case "AlwaysOn","1A":
            if (retrv_CL&&vCL)
                return
            SetCapsLockState, AlwaysOn
        case "AlwaysOff","0A":
            if (retrv_CL&&!vCL)
                return
            SetCapsLockState, AlwaysOff
        case "Toggle",-1:
            SetCapsLockState, % !vCL
        case "AlwaysToggle","-1A":
            SetCapsLockState, % "Always" (vCL?"Off":"On")
        case "Always","A":
            SetCapsLockState, % "Always" (vCL?"On":"Off")
    }
    StringCaseSense, % prev_StringCaseSense
}