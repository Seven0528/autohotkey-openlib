SetNumLockStateEx(onoff:="", retrv_CL:=true)    {
    retrv_CL?vCL:=GetKeyState("NumLock","T"):""
    Switch onoff, false
    {
        case "":
            SetNumLockState
        case "On",true:
            if (retrv_CL&&vCL)
                return
            SetNumLockState(true)
        case "Off",false:
            if (retrv_CL&&!vCL)
                return
            SetNumLockState(false)
        case "AlwaysOn","1A":
            if (retrv_CL&&vCL)
                return
            SetNumLockState("AlwaysOn")
        case "AlwaysOff","0A":
            if (retrv_CL&&!vCL)
                return
            SetNumLockState("AlwaysOff")
        case "Toggle",-1:
            SetNumLockState(!vCL)
        case "AlwaysToggle","-1A":
            SetNumLockState("Always" (vCL?"Off":"On"))
        case "Always","A":
            SetNumLockState("Always" (vCL?"On":"Off"))
    }
}