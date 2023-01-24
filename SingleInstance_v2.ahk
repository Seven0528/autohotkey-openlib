Class SingleInstance ; v2.0
{
    ShellMessageFunc := ObjBindMethod(this,"ShellMessage")
    ,DeforceFunc := ObjBindMethod(this,"DeForce")

    Force(include_otherdir:=false, ext_needle:="(exe|ahk)")    {
        SplitPath(A_ScriptFullPath, &outfilename, &outdir, &outextension, &outnamenoext, &outdrive)
        ,this.include_otherdir:=!!include_otherdir, this.ext_needle:=ext_needle
        ,this.outfilename:=outfilename, this.outdir:=outdir, this.outextension:=outextension, this.outnamenoext:=outnamenoext, this.outdrive:=outdrive
        ,DllCall("RegisterShellHookWindow", "UInt",A_ScriptHwnd)
        ,OnMessage(this.MsgNum:=DllCall("RegisterWindowMessage", "Str","SHELLHOOK"), this.ShellMessageFunc)
        ,OnExit(this.DeforceFunc)
    }
    DeForce(*)    {
        DllCall("DeregisterShellHookWindow", "UInt",A_ScriptHwnd)
    }
    ShellMessage(wParam, lParam, *)    {
        static EVENT_SYSTEM_DIALOGSTART:=0x0010
        prev_DetectHiddenWindows:=A_DetectHiddenWindows
        ,DetectHiddenWindows(true)
        Switch wParam
        {
            case EVENT_SYSTEM_DIALOGSTART:
				vTitle:=WinGetTitle("ahk_id" lParam)
                Switch this.include_otherdir
                {
                    case true:
                        if (vTitle~="iD)\\\Q" this.outnamenoext "\E\." this.ext_needle)
                            ExitApp
                    case false:
                        if (vTitle~="iD)^\Q" A_ScriptFullPath "\E")
                            ExitApp
                }
        }
        DetectHiddenWindows(prev_DetectHiddenWindows)
    }
}
; New Process Notifier
; https://www.autohotkey.com/board/topic/56984-new-process-notifier/
; [How to] Hook on to Shell to receive its messages?
; https://www.autohotkey.com/board/topic/80644-how-to-hook-on-to-shell-to-receive-its-messages/
; [Functions] - OnWin() - On_WinType_Event() - etc (SHELL HOOK)
; https://www.autohotkey.com/boards/viewtopic.php?t=60831
; RegisterShellHookWindow
; https://www.autohotkey.com/boards/viewtopic.php?t=83303
; [Class] WinHook
; https://www.autohotkey.com/boards/viewtopic.php?t=59149