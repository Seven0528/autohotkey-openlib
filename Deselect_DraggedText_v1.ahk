Deselect_DraggedText(restore:=false)    { ; v1.1
    Clipboard:=""
    SendEvent(expk("^c"))
    Clipwait, 0
    if !ErrorLevel    {
        if DllCall("IsClipboardFormatAvailable", "Uint",1)
        || DllCall("IsClipboardFormatAvailable", "Uint",13)    {
            Sleep(100)
            SendEvent(expk("^v"))
        }
    }
}