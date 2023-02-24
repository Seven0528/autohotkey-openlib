SetNumLockStateEx(onoff:="", retrv_CL:=true)    {
    retrv_CL?vCL:=GetKeyState("NumLock","T"):""
    prev_StringCaseSense:=A_StringCaseSense
    StringCaseSense, Off
    Switch onoff
    {
        case "":
            SetNumLockState
        case "On",true:
            if (retrv_CL&&vCL)
                return
            SetNumLockState, On
        case "Off",false:
            if (retrv_CL&&!vCL)
                return
            SetNumLockState, Off
        case "AlwaysOn","1A":
            if (retrv_CL&&vCL)
                return
            SetNumLockState, AlwaysOn
        case "AlwaysOff","0A":
            if (retrv_CL&&!vCL)
                return
            SetNumLockState, AlwaysOff
        case "Toggle",-1:
            SetNumLockState, % !vCL
        case "AlwaysToggle","-1A":
            SetNumLockState, % "Always" (vCL?"Off":"On")
        case "Always","A":
            SetNumLockState, % "Always" (vCL?"On":"Off")
    }
    StringCaseSense, % prev_StringCaseSense
}