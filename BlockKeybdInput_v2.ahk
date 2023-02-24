Class BlockKeybdInputObj ; v2.0
{ ; No administrator rights required
    static On(obj:="ih")    {
        Try     this.%obj% ;  <-- Error: This value of type "BlockKeybdInput" has no property named "ih".
        Catch    {
            this.%obj%:=InputHook()
        }
        if !this.%obj%.InProgress    {
            this.%obj%.MinSendLevel:=101
            this.%obj%.VisibleNonText:=false
            this.%obj%.Start()
        }
    }
    static Off(obj:="ih")    {
        Try     this.%obj%
        Catch    {
            this.%obj%:=InputHook()
        }
        if this.%obj%.InProgress
            this.%obj%.Stop()
    }
}