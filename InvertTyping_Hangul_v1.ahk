Class InvertTyping_Hangul ; v1.1
{
    KOR_to_ENG(ByRef text, clUpper:=false)    { ; 두히ㅑ노 --> english
        Output_ENG := "", Output_ENGinveted := ""
        Loop, % StrLen(text)    {
            Letter := SubStr(text, A_Index, 1)
            if RegExMatch(Letter, "[ㄱ-ㅣ]")
                Output_ENG .= 한글_자모(Asc(Letter))
            else if RegExMatch(Letter, "[가-힣]")
                Output_ENG .= 한글_완성형(Asc(Letter))
            else
                Output_ENG .= Letter
        }
        if clUpper    {
            Loop, % StrLen(Output_ENG)    {
                Letter := SubStr(Output_ENG, A_Index, 1)
                if Letter is Upper
                    StringLower, Letter, Letter
                else if Letter is Lower
                    StringUpper, Letter, Letter
                Output_ENGinveted .= Letter
            }
            text := Output_ENGinveted
        }
        else
            text := Output_ENG
    }
    
    ENG_to_KOR(ByRef text, clUpper:=false)    { ; gksrrndj --> 한국어
        Hangul_Johab := [], Output_KOR := ""
        if clUpper    {
            Loop, % StrLen(text)    {
                Letter := SubStr(text, A_Index, 1)
                if Letter is Upper
                    StringLower, Letter, Letter
                else if Letter is Lower
                    StringUpper, Letter, Letter
                text2 .= Letter
            }
            text := text2
        }
        text.=A_Space ; 시뮬레이션 마무리를 쉽게 구성하기 위해 (IME 조합 종료를 의미)
        ; -------------------------------------------------------------------------------
        Loop, % StrLen(text)    {
        koreanchar_current := SubStr(text, A_Index, 1)
        ; Uni		= ( 초성 * 21 + 중성 ) * 28 + 종성 + 44032
        ; Uni		= 12593 + 자모
        Loop    {
            if (Hangul_Johab[1] == "")    { ; 자음X
            ; [0. 자음X] ===================================================
                ; 첫 조합 시작
                if (Hangul_Johab[2] == "")    {
                    if koreanchar_current is alpha
                    {
                        if (영어_자음모음_단순구별(koreanchar_current) == "자음")    {
                            Hangul_Johab[1] := koreanchar_current
                            continue 2
                        }
                        else if (영어_자음모음_단순구별(koreanchar_current) == "모음")    { ; ㅗ, ㅡ
                            if (koreanchar_current=="h"||koreanchar_current=="H"
                            ||koreanchar_current=="n"||koreanchar_current=="N"
                            ||koreanchar_current=="m"||koreanchar_current=="M")    { ; ㅗ, ㅜ, ㅡ
                                Hangul_Johab[2] := koreanchar_current
                                continue 2
                            }
                            else    { ; 이중모음 조합X	담지 않고 새로 시작
                                Output_KOR .= 알파벳을_자모로_변환( koreanchar_current )
                                continue 2
                            }
                        }
                    }
                    else    {
                        Output_KOR .= koreanchar_current
                        continue 2
                    }
                }
        ; -------------------------------------------------------------------------------
            ; [0.특수. 자음X 모음O]
                ; ㅘ, ㅢ 같은 조합 확인
                else    {
                    ; ㅗ, ㅜ, ㅡ 이중모음 가능
                    No_Diphthong := 0 ; 이중모음 아닐 때 담기는 변수
                    if (Hangul_Johab[2]=="h"||Hangul_Johab[2]=="H")    { ; ㅗ
                        ; ㅘ, ㅙ, ㅚ
                        if (koreanchar_current=="k"||koreanchar_current=="o"||koreanchar_current=="l")
                            Hangul_Johab[2] .= koreanchar_current
                        ; Shift ㅘ, ㅚ
                        else if (koreanchar_current=="K"||koreanchar_current=="L")
                            Hangul_Johab[2] .= koreanchar_current
                        else
                            No_Diphthong := 1
                    }
                    else if (Hangul_Johab[2]=="n"||Hangul_Johab[2]=="N")    { ; ㅜ
                        ; ㅝ, ㅞ, ㅟ
                        if (koreanchar_current=="j"||koreanchar_current=="p"||koreanchar_current=="l")
                            Hangul_Johab[2] .= koreanchar_current
                        ; Shift ㅝ, ㅟ
                        else if (koreanchar_current=="J"||koreanchar_current=="L")
                            Hangul_Johab[2] .= koreanchar_current
                        else
                            No_Diphthong := 1
                    }
                    else if (Hangul_Johab[2]=="m"||koreanchar_current=="M")    { ; ㅡ
                        ; ㅢ
                        if (koreanchar_current=="l")
                            Hangul_Johab[2] .= koreanchar_current
                        ; Shift ㅢ
                        else if (koreanchar_current=="L")
                            Hangul_Johab[2] .= koreanchar_current
                        else
                            No_Diphthong := 1
                    }
                    else
                        No_Diphthong := 1


                    if (No_Diphthong == 1)    { ; ㅗㅒ 이중모음 아님
                        Output_KOR .= 알파벳을_자모로_변환( Hangul_Johab[2] ) ; (ㅗ)
                        Hangul_Johab[2] := ""
                        continue ; 다시 루프 (ㅒ)
                    }
                    else    {
                        ; 이중 모음
                        Output_KOR .= 알파벳을_자모로_변환( Hangul_Johab[2] )
                        Hangul_Johab[2] := ""
                        continue 2
                    }
                }
            }
        ; -------------------------------------------------------------------------------
            ; [1. 자음O] ===================================================
            else if (Hangul_Johab[1] != "") && (Hangul_Johab[2] == "")    {
                if koreanchar_current is alpha
                {
                    ; 이전 자음이 단자음
                    if (StrLen(Hangul_Johab[1]) != 2)    {
                        ; 단자음O 자음O - 자음 연속
                        if (영어_자음모음_단순구별(koreanchar_current) == "자음")    { ; ㄳ, ㄵ 등 (글자조합은 안되지만 초성자음끼리만으로 조합될 수 있음)
                            No_Double_Consonant := 0 ; 겹자음이 아닐 때 담기는 변수
                            ; ㄳ
                            if (Hangul_Johab[1]=="r")    {
                                if (koreanchar_current=="t")
                                    Hangul_Johab[1] .= koreanchar_current
                                else
                                    No_Double_Consonant := 1
                            }
                            ; ㄵ / ㄶ
                            else if (Hangul_Johab[1]=="s"||Hangul_Johab[1]=="S")    {
                                if (koreanchar_current=="w"||koreanchar_current=="g"||koreanchar_current=="G")
                                    Hangul_Johab[1] .= koreanchar_current
                                else
                                    No_Double_Consonant := 1
                            }
                            ; ㄺ / ㄻ / ㄼ / ㄽ / ㄾ/ ㄿ / ㅀ
                            else if (Hangul_Johab[1]=="f"||Hangul_Johab[1]=="F")    {
                                if (koreanchar_current=="r"||koreanchar_current=="a"||koreanchar_current=="A"||koreanchar_current=="q"
                                ||koreanchar_current=="t"||koreanchar_current=="x"||koreanchar_current=="X"
                                ||koreanchar_current=="v"||koreanchar_current=="V"||koreanchar_current=="g"||koreanchar_current=="G")
                                    Hangul_Johab[1] .= koreanchar_current
                                else
                                    No_Double_Consonant := 1
                            }
                            ; ㅄ
                            else if (Hangul_Johab[1]=="q")    {
                                if (koreanchar_current=="t")
                                    Hangul_Johab[1] .= koreanchar_current
                                else
                                    No_Double_Consonant := 1
                            }
                            else
                                No_Double_Consonant := 1


                            if (No_Double_Consonant == 1)    { ; ㄱ ㄲ ㅅ ㅆ 겹자음 아님
                                Output_KOR .= 알파벳을_자모로_변환( Hangul_Johab[1] ) ; (ㄱ)
                                Hangul_Johab[1] := ""
                                continue ; 다시 루프 (ㅁ)
                            }
                            else ; ㄳ 겹자음 (앞서 [1]을 겹자음으로 바꾸고 끝 - 바로 아래 "이전 자음이 겹자음" 부분 참조)
                                continue 2
                        }
                        ; 단자음O 모음O
                        else if (영어_자음모음_단순구별(koreanchar_current) == "모음")    { ; ㅅㅏ
                            Hangul_Johab[2] := koreanchar_current
                            continue 2
                        }
                    }
                    ; 이전 자음이 겹자음
                    else    {
                        ; 겹자음 O 자음O
                        if (영어_자음모음_단순구별(koreanchar_current) == "자음")    { ; ㄳ ㄱ
                            Output_KOR .= 알파벳을_자모로_변환( Hangul_Johab[1] ) ; (ㄳ)
                            Hangul_Johab[1] := ""
                            continue ; 다시 루프 (ㄱ)
                        }
                        else if (영어_자음모음_단순구별(koreanchar_current) == "모음")    { ; ㄳ ㅏ
                            Output_KOR .= 알파벳을_자모로_변환( SubStr(Hangul_Johab[1], 1, 1) ) ; (ㄱ)
                            Hangul_Johab[1] := SubStr(Hangul_Johab[1], 2, 1) ; (ㅅ)
                            continue ; 다시 루프 (ㅅㅏ) 	-	단자음O 모음O으로
                        }
                    }
                }
                else    {
                    ; 조합 종료
                    Output_KOR .= 알파벳을_자모로_변환( Hangul_Johab[1] ) ; 뭐가 들어있던 간에...
                    Hangul_Johab[1] := ""
                    Output_KOR .= koreanchar_current
                    continue 2
                }
            }
        ; -------------------------------------------------------------------------------
        ; [2. 자음O 모음O] ===================================================
            else if (Hangul_Johab[1] != "") && (Hangul_Johab[2] != "") && (Hangul_Johab[3] == "")    {
                ; ㅅ ㅗ
                if koreanchar_current is alpha
                {
                    if (영어_자음모음_단순구별(koreanchar_current) == "자음")    { ; 속 (일단 받침으로 감)
                        ; 일부 쌍받침은 받침으로 못감 ; 가ㄸ
                        if (koreanchar_current=="W"||koreanchar_current=="Q"||koreanchar_current=="E")    {
                            Output_KOR .= 한글_단순_조합(	초성_값(알파벳을_자모로_변환( Hangul_Johab[1])	)
                                                    ,	중성_값(알파벳을_자모로_변환( Hangul_Johab[2]))
                                                    ,	종성_값(알파벳을_자모로_변환( Hangul_Johab[3]))) ; (가)
                            Hangul_Johab[1] := ""
                            Hangul_Johab[2] := ""
                            continue ; 다시 루프 (ㄸ)
                        }
                        else    {
                            Hangul_Johab[3] := koreanchar_current
                            continue 2
                        }
                    }
                    else if (영어_자음모음_단순구별(koreanchar_current) == "모음")    { ; ㅗ, ㅡ
                        if (StrLen(Hangul_Johab[2]) != 2)    { ; 이전 모음이 이중모음이 아님
                            ; ㅗ, ㅜ, ㅡ 이중모음 가능
                            No_Diphthong := 0 ; 이중모음 아닐 때 담기는 변수
                            if (Hangul_Johab[2]=="h"||Hangul_Johab[2]=="H")    { ; ㅗ
                                ; ㅘ, ㅙ, ㅚ
                                if (koreanchar_current=="k"||koreanchar_current=="o"||koreanchar_current=="l")
                                    Hangul_Johab[2] .= koreanchar_current
                                ; Shift ㅘ, ㅚ
                                else if (koreanchar_current=="K"||koreanchar_current=="L")
                                    Hangul_Johab[2] .= koreanchar_current
                                else
                                    No_Diphthong := 1
                            }
                            else if (Hangul_Johab[2]=="n"||Hangul_Johab[2]=="N")    { ; ㅜ
                                ; ㅝ, ㅞ, ㅟ
                                if (koreanchar_current=="j"||koreanchar_current=="p"||koreanchar_current=="l")
                                    Hangul_Johab[2] .= koreanchar_current
                                ; Shift ㅝ, ㅟ
                                else if (koreanchar_current=="J"||koreanchar_current=="L")
                                    Hangul_Johab[2] .= koreanchar_current
                                else
                                    No_Diphthong := 1
                            }
                            else if (Hangul_Johab[2]=="m"||koreanchar_current=="M")    { ; ㅡ
                                ; ㅢ
                                if (koreanchar_current=="l")
                                    Hangul_Johab[2] .= koreanchar_current
                                ; Shift ㅢ
                                else if (koreanchar_current=="L")
                                    Hangul_Johab[2] .= koreanchar_current
                                else
                                    No_Diphthong := 1
                            }
                            else
                                No_Diphthong := 1


                            if (No_Diphthong == 1)    { ; ㅅㅗㅒ  -> 소ㅒ 이중모음 아님
                                Output_KOR .= 한글_단순_조합(	초성_값(알파벳을_자모로_변환( Hangul_Johab[1])	)
                                                ,	중성_값(알파벳을_자모로_변환( Hangul_Johab[2]))
                                                ,	종성_값(알파벳을_자모로_변환( Hangul_Johab[3]))) ; (소)
                                Hangul_Johab[1] := ""
                                Hangul_Johab[2] := ""
                                continue ; 다시 루프 (ㅒ)
                            }
                            else ; 이중 모음 ; 쇄
                                continue 2
                        }
                        else    { ; 이전 모음이 이중모음 - 조합 종료; 쇄ㅕ
                            Output_KOR .= 한글_단순_조합(	초성_값(알파벳을_자모로_변환( Hangul_Johab[1])	)
                                            ,	중성_값(알파벳을_자모로_변환( Hangul_Johab[2]))
                                            ,	종성_값(알파벳을_자모로_변환( Hangul_Johab[3]))) ; (쇄)
                            Hangul_Johab[1] := ""
                            Hangul_Johab[2] := ""
                            continue ; 다시 루프 (ㅕ)
                        }
                    }
                }
                else    {
                    Output_KOR .= 한글_단순_조합(	초성_값(알파벳을_자모로_변환( Hangul_Johab[1])	)
                                            ,	중성_값(알파벳을_자모로_변환( Hangul_Johab[2]))
                                            ,	종성_값(알파벳을_자모로_변환( Hangul_Johab[3])))
                    Hangul_Johab[1] := ""
                    Hangul_Johab[2] := ""
                    Output_KOR .= koreanchar_current
                    continue 2
                }
            }
        ; -------------------------------------------------------------------------------
        ; [3. 자음O 모음O 받침O] ===================================================
            ; 단 무조건 받침있는 글자로 가는 건 아님 	각ㅏ -> 가가
            else if (Hangul_Johab[1] != "") && (Hangul_Johab[2] != "") && (Hangul_Johab[3] != "")    {
                if koreanchar_current is alpha
                {
                    if (영어_자음모음_단순구별(koreanchar_current) == "자음")    {
                        ; 이전 자음이 단받침 ; 괄 +
                        if (StrLen(Hangul_Johab[3]) != 2)    {
                            No_Double_Consonant := 0 ; 겹자음이 아닐 때 담기는 변수
                            ; ㄳ
                            if (Hangul_Johab[3]=="r")    {
                                if (koreanchar_current=="t")
                                    Hangul_Johab[3] .= koreanchar_current
                                else
                                    No_Double_Consonant := 1
                            }
                            ; ㄵ / ㄶ
                            else if (Hangul_Johab[3]=="s"||Hangul_Johab[3]=="S")    {
                                if (koreanchar_current=="w"||koreanchar_current=="g"||koreanchar_current=="G")
                                    Hangul_Johab[3] .= koreanchar_current
                                else
                                    No_Double_Consonant := 1
                            }
                            ; ㄺ / ㄻ / ㄼ / ㄽ / ㄾ/ ㄿ / ㅀ
                            else if (Hangul_Johab[3]=="f"||Hangul_Johab[3]=="F")    {
                                if (koreanchar_current=="r"||koreanchar_current == "a"||koreanchar_current == "A"
                                ||koreanchar_current == "q"||koreanchar_current == "t"||koreanchar_current == "x"||koreanchar_current == "X"
                                ||koreanchar_current == "v"||koreanchar_current == "V"||koreanchar_current == "g"||koreanchar_current == "G")
                                    Hangul_Johab[3] .= koreanchar_current
                                else
                                    No_Double_Consonant := 1
                            }
                            ; ㅄ
                            else if (Hangul_Johab[3]=="q")    {
                                if (koreanchar_current=="t")
                                    Hangul_Johab[3] .= koreanchar_current
                                else
                                    No_Double_Consonant := 1
                            }
                            else
                                No_Double_Consonant := 1


                            if (No_Double_Consonant == 1)    { ; 괄 + ㅋ		겹자음 아님 (조합 완료)
                                Output_KOR .= 한글_단순_조합(	초성_값(알파벳을_자모로_변환( Hangul_Johab[1])	)
                                                        ,	중성_값(알파벳을_자모로_변환( Hangul_Johab[2]))
                                                        ,	종성_값(알파벳을_자모로_변환( Hangul_Johab[3])))
                                Hangul_Johab[1] := ""
                                Hangul_Johab[2] := ""
                                Hangul_Johab[3] := ""
                                continue ; 다시 루프 (ㅁ)
                            }
                            else ; 괄 + ㅎ -> 괋		(괋 + ㅓ -> 괄허 가 될 수 있으므로 조합중)
                                continue 2
                        }
                        else    { ; 이전 자음이 겹받침 ; 괋 + ㅋ (조합 완료)
                            Output_KOR .= 한글_단순_조합(	초성_값(알파벳을_자모로_변환( Hangul_Johab[1])	)
                                                    ,	중성_값(알파벳을_자모로_변환( Hangul_Johab[2]))
                                                    ,	종성_값(알파벳을_자모로_변환( Hangul_Johab[3]))) ; (괄)
                            Hangul_Johab[1] := ""
                            Hangul_Johab[2] := ""
                            Hangul_Johab[3] := ""
                            continue ; 다시 루프 (ㅋ)
                        }
                    }
                    else if (영어_자음모음_단순구별(koreanchar_current) == "모음")    {
                        ; 이전 받침이 단받침 ; 괄 + ㅓ (쌍받침 곾 + ㅓ 도 과꺼로 로 되므로 여기에 포함)
                        if (StrLen(Hangul_Johab[3]) != 2)    {
                            종성_to_초성 := ""
                            종성_to_초성 := Hangul_Johab[3]
                            Hangul_Johab[3] := "" ; 과

                            Output_KOR .= 한글_단순_조합(	초성_값(알파벳을_자모로_변환( Hangul_Johab[1])	)
                                                    ,	중성_값(알파벳을_자모로_변환( Hangul_Johab[2]))
                                                    ,	종성_값(알파벳을_자모로_변환( Hangul_Johab[3])))

                            Hangul_Johab[1] := ""
                            Hangul_Johab[2] := ""
                            Hangul_Johab[1] := 종성_to_초성
                            continue ; 다시 루프 (ㄹㅓ)
                        }

                        ; 이전 받침이 겹받침 ; 괋 + ㅓ -> 괄허
                        else    {
                            종성_to_초성 := ""
                            종성_to_초성 := SubStr(Hangul_Johab[3], 2, 1)
                            Hangul_Johab[3] := SubStr(Hangul_Johab[3], 1, 1) ; 괄

                        Output_KOR .= 한글_단순_조합(	초성_값(알파벳을_자모로_변환( Hangul_Johab[1])	)
                                                    ,	중성_값(알파벳을_자모로_변환( Hangul_Johab[2]))
                                                    ,	종성_값(알파벳을_자모로_변환( Hangul_Johab[3])))

                            Hangul_Johab[1] := ""
                            Hangul_Johab[2] := ""
                            Hangul_Johab[3] := ""
                            Hangul_Johab[1] := 종성_to_초성
                            continue ; 다시 루프 (ㅎㅓ)
                        }
                    }
                }
                else    {
                    Output_KOR .= 한글_단순_조합(	초성_값(알파벳을_자모로_변환( Hangul_Johab[1])	)
                                            ,	중성_값(알파벳을_자모로_변환( Hangul_Johab[2]))
                                            ,	종성_값(알파벳을_자모로_변환( Hangul_Johab[3])))

                    Hangul_Johab[1] := ""
                    Hangul_Johab[2] := ""
                    Hangul_Johab[3] := ""
                    Output_KOR .= koreanchar_current
                    continue 2
                }
            }
        }
        }
        ; 마지막에 논리 마무리를 쉽게 하기 위한 Space는 제거
        text := SubStr(Output_KOR, 1, StrLen(Output_KOR)-1)
    }
}



/*
	1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30
		ㄱ	ㄲ	ㄳ	ㄴ	ㄵ	ㄶ	ㄷ	ㄸ	ㄹ	ㄺ	ㄻ	ㄼ	ㄽ	ㄾ	ㄿ	ㅀ	ㅁ	ㅂ	ㅃ	ㅄ	ㅅ	ㅆ	ㅇ	ㅈ	ㅉ	ㅊ	ㅋ	ㅌ	ㅍ	ㅎ
초		1	2		3			4	5	6								7	8	9		10	11	12	13	14	15	16	17	18	19
종	0	1	2	3	4	5	6	7		8	9	10	11	12	13	14	15	16	17		18	19	20	21	22		23	24	25	26	27
*/
;==========================================
초성_값(초성)   {
	if (초성 = "")
		return 0
	Hangul_1 := Asc(초성) -12593
	; 초성에 겹받침 제외
	if (20 <= Hangul_1) ; ㅄ 제외
		Hangul_1--
	if (16 <= Hangul_1) ; ㅀ 제외
		Hangul_1--
	if (15 <= Hangul_1) ; ㄿ 제외
		Hangul_1--
	if (14 <= Hangul_1) ; ㄾ 제외
		Hangul_1--
	if (13 <= Hangul_1) ; ㄽ 제외
		Hangul_1--
	if (12 <= Hangul_1) ; ㄼ 제외
		Hangul_1--
	if (11 <= Hangul_1) ; ㄻ 제외
		Hangul_1--
	if (10 <= Hangul_1) ; ㄺ 제외
		Hangul_1--
	if (6 <= Hangul_1) ; ㄶ 제외
		Hangul_1--
	if (5 <= Hangul_1) ; ㄵ 제외
		Hangul_1--
	if (3 <= Hangul_1) ; ㄳ 제외
		Hangul_1--
	return Hangul_1
}
;==========================================
중성_값(중성)   {
	if (중성 = "")
		return 0
	Hangul_2 := Asc(중성) -12593 -30
	return Hangul_2
}
;==========================================
종성_값(종성)   {
	if (종성 = "")
		return 0
	Hangul_3 := Asc(종성) -12593 +1
	; 종성에 일부 쌍자음 제외
	if (25 <= Hangul_3) ; ㅉ 제외
		Hangul_3--
	if (19 <= Hangul_3) ; ㅃ 제외
		Hangul_3--
	if (8 <= Hangul_3) ; ㄸ 제외
		Hangul_3--
	return Hangul_3
}
;==========================================
한글_단순_조합(초성값, 중성값, 종성값)   {
	return Chr((초성값*21 +중성값)*28 +종성값 +44032)
}
;==========================================
영어_자음모음_단순구별(char)   {
	if (char = "q") || (char = "w") || (char = "e") || (char = "r") || (char = "t") || (char = "a") || (char = "s") || (char = "d") || (char = "f") || (char = "g") || (char = "z") || (char = "x") || (char = "c") || (char = "v")
		return "자음"
	else if (char = "y") || (char = "u") || (char = "i") || (char = "o") || (char = "p") || (char = "h") || (char = "j") || (char = "k") || (char = "l") || (char = "b") || (char = "n") || (char = "m")
		return "모음"
	else
		return 0
}
;==========================================
알파벳을_자모로_변환(char)   {
    ; -----------------------------
	if (char == "")
		korean_output := ""
	else if (char == "r") ; 종성 기준 1
		korean_output := "ㄱ"
	else if (char == "R") ; 2
		korean_output := "ㄲ"
	else if (char == "rt") ; 3
		korean_output := "ㄳ"
	else if (char == "s") || (char == "S") ; 4
		korean_output := "ㄴ"
	else if (char == "sw") || (char == "Sw") ; 5
		korean_output := "ㄵ"
	else if (char == "sg") || (char == "Sg") || (char == "sG") || (char == "SG") ; 6
		korean_output := "ㄶ"
	else if (char == "e") ; 7
		korean_output := "ㄷ"
	else if (char == "E") ; 초성 3
		korean_output := "ㄸ"
	else if (char == "f") || (char == "F") ; 8
		korean_output := "ㄹ"
	else if (char == "fr") || (char == "Fr") ; 9
		korean_output := "ㄺ"
	else if (char == "fa") || (char == "Fa") || (char == "fA")|| (char == "FA") ; 10
		korean_output := "ㄻ"
	else if (char == "fq") || (char == "Fq") ; 11
		korean_output := "ㄼ"
	else if (char == "ft") || (char == "Ft") ; 12
		korean_output := "ㄽ"
	else if (char == "fx") || (char == "Fx") || (char == "fX") || (char == "FX") ; 13
		korean_output := "ㄾ"
	else if (char == "fv") || (char == "Fv") || (char == "fV") || (char == "FV") ; 14
		korean_output := "ㄿ"
	else if (char == "fg") || (char == "Fg") || (char == "fG") || (char == "FG") ; 15
		korean_output := "ㅀ"
	else if (char == "a") || (char == "A") ; 16
		korean_output := "ㅁ"
	else if (char == "q") ; 17
		korean_output := "ㅂ"
	else if (char == "Q") ; 초성 8
		korean_output := "ㅃ"
	else if (char == "qt") ; 18
		korean_output := "ㅄ"
	else if (char == "t") ; 19
		korean_output := "ㅅ"
	else if (char == "T") ; 20
		korean_output := "ㅆ"
	else if (char == "d") || (char == "D") ; 21
		korean_output := "ㅇ"
	else if (char == "w") ; 22
		korean_output := "ㅈ"
	else if (char == "W") ; 초성 13
		korean_output := "ㅉ"
	else if (char == "c") || (char == "C") ; 23
		korean_output := "ㅊ"
	else if (char == "z") || (char == "Z") ; 24
		korean_output := "ㅋ"
	else if (char == "x") || (char == "X") ; 25
		korean_output := "ㅌ"
	else if (char == "v") || (char == "V") ; 26
		korean_output := "ㅍ"
	else if (char == "g") || (char == "G") ; 27
		korean_output := "ㅎ"
    ; -----------------------------
	else if (char == "k") || (char == "K") ; 중성 기준 0
		korean_output := "ㅏ"
	else if (char == "o") ; 1
		korean_output := "ㅐ"
	else if (char == "i") || (char == "I") ; 2
		korean_output := "ㅑ"
	else if (char == "O") ; 3
		korean_output := "ㅒ"
	else if (char == "j") || (char == "J") ; 4
		korean_output := "ㅓ"
	else if (char == "p") ; 5
		korean_output := "ㅔ"
	else if (char == "u") || (char == "U") ; 6
		korean_output := "ㅕ"
	else if (char == "P") ; 7
		korean_output := "ㅖ"
	else if (char == "h") || (char == "H") ; 8
		korean_output := "ㅗ"
	else if (char == "hk") || (char == "Hk") || (char == "hK") || (char == "HK") ; 9
		korean_output := "ㅘ"
	else if (char == "ho") || (char == "Ho") ; 10
		korean_output := "ㅙ"
	else if (char == "hl") || (char == "Hl") || (char == "hL") || (char == "HL") ; 11
		korean_output := "ㅚ"
	else if (char == "y") || (char == "Y") ; 12
		korean_output := "ㅛ"
	else if (char == "n") || (char == "N") ; 13
		korean_output := "ㅜ"
	else if (char == "nj") || (char == "Nj") || (char == "nJ") || (char == "NJ") ; 14
		korean_output := "ㅝ"
	else if (char == "np") || (char == "Np") ; 15
		korean_output := "ㅞ"
	else if (char == "nl") || (char == "Nl") || (char == "nL") || (char == "NL") ; 16
		korean_output := "ㅟ"
	else if (char == "b") || (char == "B") ; 17
		korean_output := "ㅠ"
	else if (char == "m") || (char == "M") ; 18
		korean_output := "ㅡ"
	else if (char == "ml") || (char == "Ml") || (char == "mL") || (char == "ML") ; 19
		korean_output := "ㅢ"
	else if (char == "l") || (char == "L") ; 20
		korean_output := "ㅣ"
    ; -----------------------------
	return korean_output
}
;==========================================
한글_자모(Uni)   {
    ; 12593 = U+3131 (첫 자음 "ㄱ(0)" 유니코드)
    ; 12622 = U+314E (마지막 자음 "ㅎ(29)" 유니코드)
    ; 12623 = U+314F(첫 모음 "ㅏ(30)" 유니코드)
    ; 12643 = U+3163마지막 모음 "ㅣ(50)" 유니코드)
    ; 자음 총 30개 / 모음 총 21개
    ; 자모 총 51개
    static JAMO:={0:"r" ; ㄱ
        ,1:"R" ; ㄲ
        ,2:"rt" ; ㄳ
        ,3:"s" ; ㄴ
        ,4:"sw" ; ㄵ
        ,5:"sg" ; ㄶ
        ,6:"e" ; ㄷ
        ,7:"E" ; ㄸ   
        ,8:"f" ; ㄹ
        ,9:"fr" ; ㄺ
        ,10:"fa" ; ㄻ
        ,11:"fq" ; ㄼ 
        ,12:"ft" ; ㄽ
        ,13:"fx" ; ㄾ
        ,14:"fv" ; ㄿ
        ,15:"fg" ; ㅀ
        ,16:"a" ; ㅁ
        ,17:"q" ; ㅂ       
        ,18:"Q" ; ㅃ
        ,19:"qt" ; ㅄ
        ,20:"t" ; ㅅ
        ,21:"T" ; ㅆ
        ,22:"d" ; ㅇ
        ,23:"w" ; ㅈ
        ,24:"W" ; ㅉ
        ,25:"c" ; ㅊ
        ,26:"z" ; ㅋ
        ,27:"x" ; ㅌ
        ,28:"v" ; ㅍ
        ,29:"g" ; ㅎ
        ,30:"k" ; ㅏ       
        ,31:"o" ; ㅐ
        ,32:"i" ; ㅑ
        ,33:"O" ; ㅒ
        ,34:"j" ; ㅓ
        ,35:"p" ; ㅔ
        ,36:"u" ; ㅕ
        ,37:"P" ; ㅖ
        ,38:"h" ; ㅗ
        ,39:"hk" ; ㅘ
        ,40:"ho" ; ㅙ
        ,41:"hl" ; ㅚ
        ,42:"y" ; ㅛ
        ,43:"n" ; ㅜ
        ,44:"nj" ; ㅝ
        ,45:"np" ; ㅞ
        ,46:"nl" ; ㅟ
        ,47:"b" ; ㅠ
        ,48:"m" ; ㅡ
        ,49:"ml" ; ㅢ
        ,50:"l"} ; ㅣ        
    return JAMO[Uni-12593]
}
;==========================================
한글_완성형(Uni)   {
    ; Uni == ( 초성 * 21 + 중성 ) * 28 + 종성 + 44032
    ; 44032 = U+AC00 (첫 글자 "가(0/0/0)" 유니코드)
    ; 55203 = U+D7A3 (마지막 글자 "힣(18/20/27)" 유니코드)
    ; 완성형 총 11172개
    static CHO:={0:"r" ; ㄱ
        ,1:"R" ; ㄲ
        ,2:"s" ; ㄴ
        ,3:"e" ; ㄷ
        ,4:"E" ; ㄸ
        ,5:"f" ; ㄹ
        ,6:"a" ; ㅁ
        ,7:"q" ; ㅂ
        ,8:"Q" ; ㅃ
        ,9:"t" ; ㅅ
        ,10:"T" ; ㅆ
        ,11:"d" ; ㅇ
        ,12:"w" ; ㅈ
        ,13:"W" ; ㅉ
        ,14:"c" ; ㅊ
        ,15:"z" ; ㅋ
        ,16:"x" ; ㅌ
        ,17:"v" ; ㅍ
        ,18:"g"} ; 
        ,JUNG:={0:"k" ; ㅏ
        ,1:"o" ; ㅐ
        ,2:"i" ; ㅑ
        ,3:"O" ; ㅒ
        ,4:"j" ; ㅓ
        ,5:"p" ; ㅔ
        ,6:"u" ; ㅕ
        ,7:"P" ; ㅖ
        ,8:"h" ; ㅗ
        ,9:"hk" ; ㅘ
        ,10:"ho" ; ㅙ
        ,11:"hl" ; ㅚ
        ,12:"y" ; ㅛ
        ,13:"n" ; ㅜ
        ,14:"nj" ; ㅝ
        ,15:"np" ; ㅞ
        ,16:"nl" ; ㅟ
        ,17:"b" ; ㅠ
        ,18:"m" ; ㅡ
        ,19:"ml" ; ㅢ
        ,20:"l"} ; ㅣ
        ,JONG:={0:"" ; 없음
        ,1:"r" ; ㄱ				
        ,2:"R" ; ㄲ				
        ,3:"rt" ; ㄳ				
        ,4:"s" ; ㄴ				
        ,5:"sw" ; ㄵ				
        ,6:"sg" ; ㄶ				
        ,7:"e" ; ㄷ				
        ,8:"f" ; ㄹ				
        ,9:"fr" ; ㄺ				
        ,10:"fa" ; ㄻ				
        ,11:"fq" ; ㄼ				
        ,12:"ft" ; ㄽ				
        ,13:"fx" ; ㄾ				
        ,14:"fv" ; ㄿ				
        ,15:"fg" ; ㅀ				
        ,16:"a" ; ㅁ				
        ,17:"q" ; ㅂ				
        ,18:"qt" ; ㅄ				
        ,19:"t" ; ㅅ				
        ,20:"T" ; ㅆ				
        ,21:"d" ; ㅇ				
        ,22:"w" ; ㅈ				
        ,23:"c" ; ㅊ				
        ,24:"z" ; ㅋ				
        ,25:"x" ; ㅌ				
        ,26:"v" ; ㅍ				
        ,27:"g"} ; ㅎ
    초성중성종성 := Uni-44032
    ,초성 := Floor(초성중성종성/588)
    ,중성종성 := mod(초성중성종성,588)
    ,중성 := Floor(중성종성/28)
    ,종성 := mod(중성종성,28)
    return CHO[초성] JUNG[중성] JONG[종성]
}
;==========================================