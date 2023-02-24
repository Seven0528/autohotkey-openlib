SetEditCueBanner(HWND, Cue)    { ; https://www.autohotkey.com/board/topic/76529-solvedgray-placeholder-text/
    Static EM_SETCUEBANNER := (0x1500 + 1)
    return DllCall("User32.dll\SendMessageW", "Ptr",HWND, "UInt",EM_SETCUEBANNER, "Ptr",True, "WStr",Cue)
}