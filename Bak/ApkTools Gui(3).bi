#Define IDD_DIALOG			1000

#Define IDM_MENU				10000
#Define IDM_FILE_EXIT		10001
#Define IDM_HELP_ABOUT		10101

' Registry section definitions
'Const HKEY_CLASSES_ROOT = &H80000000
'Const HKEY_CURRENT_USER = &H80000001
'Const HKEY_LOCAL_MACHINE = &H80000002
'Const HKEY_USERS = &H80000003
'Const HKEY_PERFORMANCE_DATA = &H80000004
'Const HKEY_CURRENT_CONFIG = &H80000005

Enum InTypes
   ValNull = 0
   ValString = 1
   ValXString = 2
   ValBinary = 3
   ValDWord = 4
   ValLink = 6
   ValMultiString = 7
   ValResList = 8
End Enum

Type _MyType
	hWin As HWND
   mystr As String
   flagcons As BOOLEAN
End Type

Dim Shared hInstance As HMODULE
Dim Shared CommandLine As ZString Ptr
Dim Shared hWnd As HWND
Dim Shared MyType As _MyType
Dim Shared hprocess_logcat As HANDLE

Const ClassName="DLGCLASS"
Const AppName="Apktools Gui"
Const AboutMsg=!"Apk Reversing tools Gui\13\10Copyright � SVz 2o11"

Const szNULL =!"\0"
Const szFilter	= "apk files" & szNULL & "*.apk" & szNULL & szNULL
Const szCRLF = Chr(13, 10)
Const szDone = "done !" & szCRLF

Const szSnippet =!"const/4 v1, 0x0\13\10\13\10const-string v0, \"cracked by SVz\"\13\10\13\10invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;\13\10\13\10move-result-object v0\13\10\13\10invoke-virtual {v0}, Landroid/widget/Toast;->show()V\13\10\13\10"

Function ReadRegistry(ByVal Group as HKEY, ByVal Section As LPCSTR, ByVal Key As LPCSTR) As String
Dim as DWORD lDataTypeValue, lValueLength
Dim sValue As String * 2048
Dim As String Tstr1, Tstr2  
Dim lKeyValue As HKEY
Dim lResult as Integer
Dim td As Double

   sValue = ""
   
   lResult      = RegOpenKey(Group, Section, @lKeyValue)
   lValueLength = Len(sValue)
   lResult      = RegQueryValueEx(lKeyValue, Key, 0&, @lDataTypeValue, Cast(Byte Ptr,@sValue), @lValueLength)
   
   If (lResult = 0) Then

      Select Case lDataTypeValue
         case REG_DWORD 
            td = Asc(Mid(sValue, 1, 1)) + &H100& * Asc(Mid(sValue, 2, 1)) + &H10000 * Asc(Mid(sValue, 3, 1)) + &H1000000 * CDbl(Asc(Mid(sValue, 4, 1)))
            sValue = Format(td, "000")
         case REG_BINARY 
            ' Return a binary field as a hex string (2 chars per byte)
            Tstr2 = ""
            For I As Integer = 1 To lValueLength
               Tstr1 = Hex(Asc(Mid(sValue, I, 1)))
               If Len(Tstr1) = 1 Then Tstr1 = "0" & Tstr1
               Tstr2 += Tstr1
            Next
            sValue = Tstr2
         Case Else
            sValue = Left(sValue, lValueLength - 1)
      End Select
   
   End If

   lResult = RegCloseKey(lKeyValue)
   
   Return sValue

End Function

Sub WriteRegistry(ByVal Group as HKEY, ByVal Section As LPCSTR, ByVal Key As LPCSTR, ByVal ValType As InTypes, value As String)
Dim lResult as Integer
Dim lKeyValue As HKEY
Dim lNewVal as DWORD
Dim sNewVal As String * 2048

   lResult = RegCreateKey(Group, Section, @lKeyValue)

   If ValType = ValDWord Then
      lNewVal = CUInt(value)
      lResult = RegSetValueEx(lKeyValue, Key, 0&, ValType, Cast(Byte Ptr,@lNewVal), SizeOf(DWORD))
   Else
      If ValType = ValString Then
         sNewVal = value & Chr(0)
         lResult = RegSetValueEx(lKeyValue, Key, 0&, ValString, Cast(Byte Ptr,@sNewVal), Len(sNewVal))
      EndIf
   End If

   lResult = RegFlushKey(lKeyValue)
   lResult = RegCloseKey(lKeyValue)

End Sub


