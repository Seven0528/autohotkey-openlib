Deselect_DraggedText(restore:=false)    { ; v2.0
    A_Clipboard:=""
    SendEvent(expk("^c"))
    if Clipwait(0.5)    {
        if DllCall("IsClipboardFormatAvailable", "Uint",1)
        || DllCall("IsClipboardFormatAvailable", "Uint",13)    {
            Sleep(100)
            SendEvent(expk("^v"))
        }
    }
}