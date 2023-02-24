Class ClipEx ; v1.1
{
    Backup()    {
        global _ClipexSavedAll
        _ClipexSavedAll:=ClipboardAll
    }
        BackupExist()    {
            global _ClipexSavedAll
            return (_ClipexSavedAll!="")
        }
        BackupDelete()    {
            global _ClipexSavedAll
            _ClipexSavedAll:=""
        }
    Restore(timeout:=1)    {
        global _ClipexSavedAll
        Critical On
        this.RestoreTimerWait:=false
        this.OnClipboardChange_Temp(0)
        this.PasteHotkey(false)
        ;-----------------------------
        if this.WaitAvailability(0.5)    {
            this.OnClipboardChange_Existing(0)
            Clipboard:=""
            if this.BackupExist()    {
                Clipboard:=_ClipexSavedAll
                Clipwait, % timeout, true
            }
            this.OnClipboardChange_Existing(1)
        }
        this.BackupDelete()
        Critical Off
    }
        _OnClipboardChange    {
            ; Prevent existing onclipboardchange responding when restore clipboard
        }
        OnClipboardChange_Existing(addremove)    {           
            Switch IsObject(this._OnClipboardChange)
            {
                case true:
                    For i,v in this._OnClipboardChange    {
                        if (v!="")
                            IsFunc(v)?OnClipboardChange(v, addremove):""
                    }
                default:
                    v:=this._OnClipboardChange
                    if (v!="")
                        IsFunc(v)?OnClipboardChange(v, addremove):""
            }
        }
    ;====================================================
    SetRestorTimer(onoff, period:=-1200)    {
        onoff:=!!onoff
        this.RestoreTimerWait:=onoff
        this.OnClipboardChange_Temp(onoff?1:0)
        this.PasteHotkey(onoff)
        _tp:=this.__Bind_Restore
        Switch onoff ;  this.Restore()
        {
            case true:      SetTimer, % _tp, % -1*Abs(period)
            case false:     SetTimer, % _tp, % "Off"
         }
    }
    OnClipboardChange_Temp(addremove)    {
        static vOcc
        (!vOcc?vOcc:=ObjBindMethod(this,"OnClipboardChange_TempFunc"):"")
        OnClipboardChange(vOcc, addremove)
    }
    PasteHotkey(onoff)    {
        this._vPasteHotkey_IfCond:=!!onoff
        ,_fn1:=this.__Bind_PasteHotkey_Available, _fn2:=this.__Bind_PasteHotkey_Func
        Hotkey, If, % _fn1
        Hotkey, ^v, % _fn2, % "UseErrorLevel " (onoff?"On":"Off")
        Hotkey, If
    }
        ;------------------------------------------ While waiting for the timer, if the clipboard changes...
        OnClipboardChange_TempFunc(type)    {
            this.OnClipboardChange_Temp(0)
            this.PasteHotkey(false)
            this.BackupDelete()
            _tp:=this.__Bind_Restore
            SetTimer, % _tp, % "Off" ;  this.Restore()
        }
        ;------------------------------------------ While waiting for the timer, if you press Ctrl + V...
        PasteHotkey_Available()    { ; #if cond
            return !!this._vPasteHotkey_IfCond
        }
        PasteHotkey_Func()    {
            this.OnClipboardChange_Temp(0)
            this.PasteHotkey(false)
            this.Restore()
            SendInput % "{Ctrl down}v{Ctrl up}"
            _tp:=this.__Bind_Restore
            SetTimer, % _tp, % "Off" ;  this.Restore()
        }
    ;====================================================
    WaitAvailability(timeout:=0)    { ; #ClipboardTimeout
        Switch timeout
        {
            case 0:     endtick:=0
            default:    endtick:=A_TickCount+timeout*1000
        }
        Loop    { ; DllCall("GetOpenClipboardWindow", "Ptr")
            if this.Open()    {
                this.Close()
                return true
            }  else if (endtick&&endtick<=A_TickCount)    {
                return false
            }
            Sleep 50
        }
    }
    ;----------------------------------------------
    Open(hWndNewOwner:=0)    { ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-openclipboard
        return DllCall("User32.dll\OpenClipboard", "Ptr",hWndNewOwner)
    }
    Close()    { ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-closeclipboard
        return DllCall("User32.dll\CloseClipboard")
    }
    ;----------------------------------------------
        RestoreTimerWait    {
            get  {
                return !!this._vRestoreTimerWait
            }
            set  {
                this._vRestoreTimerWait:=value
            }
        }
        __Bind_Restore    {
            get  {
                static vObm
                (!vObm?vObm:=ObjBindMethod(this,"Restore"):"")
                return vObm
            }
        }
        __Bind_PasteHotkey_Func    {
            get  {
                static vObm
                (!vObm?vObm:=ObjBindMethod(this,"PasteHotkey_Func"):"")
                return vObm
            }
        }
        __Bind_PasteHotkey_Available    {
            get  {
                static vObm
                (!vObm?vObm:=ObjBindMethod(this,"PasteHotkey_Available"):"")
                return vObm
            }
        }
}