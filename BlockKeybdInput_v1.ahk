Class BlockKeybdInput ; v1.1
{ ; No administrator rights required
    On(obj:="ih")    {
        if !this[obj].InProgress    {
            this[obj]:=InputHook()
            this[obj].MinSendLevel:=101
            this[obj].VisibleNonText:=false
            this[obj].Start()
        }
    }
    Off(obj:="ih")    {
        if this[obj].InProgress
            this[obj].Stop()
    }
}