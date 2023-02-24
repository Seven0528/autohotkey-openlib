SetCapsLockStateEx(onoff:="", retrv_CL:=true)    {
    retrv_CL?vCL:=GetKeyState("CapsLock","T"):""
    Switch onoff, false
    {
        case "":
            SetCapsLockState
        case "On",true:
            if (retrv_CL&&vCL)
                return
            SetCapsLockState(true)
        case "Off",false:
            if (retrv_CL&&!vCL)
                return
            SetCapsLockState(false)
        case "AlwaysOn","1A":
            if (retrv_CL&&vCL)
                return
            SetCapsLockState("AlwaysOn")
        case "AlwaysOff","0A":
            if (retrv_CL&&!vCL)
                return
            SetCapsLockState("AlwaysOff")
        case "Toggle",-1:
            SetCapsLockState(!vCL)
        case "AlwaysToggle","-1A":
            SetCapsLockState("Always" (vCL?"Off":"On"))
        case "Always","A":
            SetCapsLockState("Always" (vCL?"On":"Off"))
    }
}