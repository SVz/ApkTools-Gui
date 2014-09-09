#Include once "windows.bi"
#Include "vbcompat.bi"

#Include Once "win/commctrl.bi"
#Include Once "win/commdlg.bi"
#Include Once "win/shellapi.bi"
#Include "ApkTools Gui.bi"

#Include "rsrc.bi"


Sub MyThread(param as any ptr)
	Dim as _MyType Ptr pMyType = param
	Dim sat As SECURITY_ATTRIBUTES
	Dim hread As DWORD
	Dim hwrite As DWORD
	Dim bytesRead As DWORD
	Dim startupinfo As STARTUPINFO
	Dim pinfo As PROCESS_INFORMATION
	
	Dim as ZString *2048 buffer_read
	Dim as ZString *2048 buffer_print

	If pMyType->flagcons Then
		sat.nLength=SizeOf(SECURITY_ATTRIBUTES)
		sat.lpSecurityDescriptor=NULL
		sat.bInheritHandle=TRUE
		If (CreatePipe(@hread,@hwrite,@sat,NULL))=NULL Then
			MessageBox(pMyType->hWin,"Erreur creation pipe","SVz",MB_ICONERROR)
		Else
			startupinfo.cb=SizeOf(STARTUPINFO)
     		GetStartupInfo(@startupinfo)
     		startupinfo.hStdOutput=hwrite
     		startupinfo.hStdError=hwrite
     		startupinfo.dwFlags=STARTF_USESHOWWINDOW Or STARTF_USESTDHANDLES
     		startupinfo.wShowWindow=SW_HIDE

			If CreateProcess(NULL,pMyType->mystr, NULL, NULL, TRUE, NULL, NULL, NULL,@startupinfo,@pinfo)=NULL Then
         	MessageBox(pMyType->hWin,"erreur create process","SVz",MB_ICONERROR Or MB_OK)
			Else
				' Sauvegarde du handle pour le cas adb logcat
				If InStr(pMyType->mystr,"logcat") <> 0 Then
					hprocess_logcat = pinfo.hProcess
				EndIf
			
        		CloseHandle(hwrite)
        		Do
         	   If ReadFile(hread,@buffer_read,2000,@bytesRead,NULL)=NULL Then
         	   	Exit Do
         	   EndIf
         	   lstrcpyn(@buffer_print,@buffer_read,bytesRead+1)
            	SendDlgItemMessage(pMyType->hWin,IDC_CONS,EM_REPLACESEL,0,@buffer_print)
         	Loop
			End If
     		CloseHandle(hread)
		End If
	Else
		WinExec(pMyType->mystr,SW_MAXIMIZE)
	EndIf
  	SendDlgItemMessage(pMyType->hWin,IDC_CONS,EM_REPLACESEL,0,StrPtr(pMyType->mystr))
  	SendDlgItemMessage(pMyType->hWin,IDC_CONS,EM_REPLACESEL,0,StrPtr(" "))
  	SendDlgItemMessage(pMyType->hWin,IDC_CONS,EM_REPLACESEL,0,StrPtr(szDone))

End Sub

Sub WriteClipboard(byval Text As String, byval CPFormat As Integer = CF_TEXT, byref hWnd As HWND = NULL)        
       Var hGlobalClip = GlobalAlloc(GMEM_MOVEABLE Or GMEM_SHARE, Len(Text)+1)        
       OpenClipboard(hWnd)
       EmptyClipboard()
       Var lpMem = GlobalLock(hGlobalClip)
       CopyMemory(lpMem, Strptr(Text), Len(text))
       GlobalUnlock(lpMem)
       SetClipboardData(CPFormat, hGlobalClip)
       CloseClipboard()
End Sub        
                
Function CommandExecute(ByVal hWin As HWND,ByVal Cmdstr As ZString Ptr,ByVal flagcons As BOOLEAN) As Integer
	Dim sat As SECURITY_ATTRIBUTES
	Dim hread As DWORD
	Dim hwrite As DWORD
	Dim bytesRead As DWORD
	Dim startupinfo As STARTUPINFO
	Dim pinfo As PROCESS_INFORMATION
	
	Dim as ZString *2048 buffer_read
	Dim as ZString *2048 buffer_print

	If flagcons Then
		sat.nLength=SizeOf(SECURITY_ATTRIBUTES)
		sat.lpSecurityDescriptor=NULL
		sat.bInheritHandle=TRUE
		If (CreatePipe(@hread,@hwrite,@sat,NULL))=NULL Then
			MessageBox(hWin,"Erreur creation pipe","SVz",MB_ICONERROR)
		Else
			startupinfo.cb=SizeOf(STARTUPINFO)
     		GetStartupInfo(@startupinfo)
     		startupinfo.hStdOutput=hwrite
     		startupinfo.hStdError=hwrite
     		startupinfo.dwFlags=STARTF_USESHOWWINDOW Or STARTF_USESTDHANDLES
     		startupinfo.wShowWindow=SW_HIDE

			If CreateProcess(NULL,Cmdstr, NULL, NULL, TRUE, NULL, NULL, NULL,@startupinfo,@pinfo)=NULL Then
         	MessageBox(hWnd,"erreur create process","SVz",MB_ICONERROR Or MB_OK)
			Else
        		CloseHandle(hwrite)
        		Do
         	   If ReadFile(hread,@buffer_read,2000,@bytesRead,NULL)=NULL Then
         	   	Exit Do
         	   EndIf
         	   lstrcpyn(@buffer_print,@buffer_read,bytesRead+1)
            	SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,@buffer_print)
         	Loop
			End If
     		CloseHandle(hread)
		End If
	Else
		WinExec(Cmdstr,SW_MAXIMIZE)
	EndIf
	Return 0
End Function

Function CommandLapk(ByVal hWin As HWND,ByVal Cmdstr As ZString Ptr,ByVal flagcons As BOOLEAN) As Integer
	Dim sat As SECURITY_ATTRIBUTES
	Dim hread As DWORD
	Dim hwrite As DWORD
	Dim As DWORD bytesRead
	Dim As Integer i,j
	Dim startupinfo As STARTUPINFO
	Dim pinfo As PROCESS_INFORMATION
	
	Dim as ZString *2048 buffer_read
	Dim as ZString *2048 buffer_print
	Dim as ZString *2048 buffer_tmp
	
	If flagcons Then
		sat.nLength=SizeOf(SECURITY_ATTRIBUTES)
		sat.lpSecurityDescriptor=NULL
		sat.bInheritHandle=TRUE
		If (CreatePipe(@hread,@hwrite,@sat,NULL))=NULL Then
			MessageBox(hWin,"Erreur creation pipe","SVz",MB_ICONERROR)
		Else
			startupinfo.cb=SizeOf(STARTUPINFO)
     		GetStartupInfo(@startupinfo)
     		startupinfo.hStdOutput=hwrite
     		startupinfo.hStdError=hwrite
     		startupinfo.dwFlags=STARTF_USESHOWWINDOW Or STARTF_USESTDHANDLES
     		startupinfo.wShowWindow=SW_HIDE

			If CreateProcess(NULL,Cmdstr, NULL, NULL, TRUE, NULL, NULL, NULL,@startupinfo,@pinfo)=NULL Then
         	MessageBox(hWnd,"erreur create process","SVz",MB_ICONERROR Or MB_OK)
			Else
        		CloseHandle(hwrite)
        		Do
         	   If ReadFile(hread,@buffer_read,2000,@bytesRead,NULL)=NULL Then
         	   	Exit Do
         	   EndIf
         	   i=0
         	   'While i<bytesRead
         	   	i=InStr(buffer_read,"package:")
         	   	j=InStr(buffer_read,".apk")
           	   	lstrcpyn(@buffer_print,@buffer_read+i+8,j-5)

						SendDlgItemMessage(hWin,IDC_LAPK,LB_ADDSTRING,0,Cast(LPARAM,@buffer_print))
            	'SendDlgItemMessage(hWin,IDC_LAPK,EM_REPLACESEL,0,@buffer_print)
         	   'Wend
         	Loop
			End If
     		CloseHandle(hread)
		End If
	Else
		WinExec(Cmdstr,SW_MAXIMIZE)
	EndIf
	Return 0
End Function

Function DlgProc(byval hDlg as HWND, byval uMsg as UINT, byval wParam as WPARAM, byval lParam as LPARAM) as integer
	dim as long id, event
	Dim regpath As string 
	Dim keyname As String 
	Dim strbuffer As ZString*260
	
	select case uMsg
		case WM_INITDIALOG
			SetDlgItemText(hDlg,IDC_SAVEPATH,ReadRegistry(HKEY_CURRENT_USER,"SOFTWARE\SVz","savepath"))
			SetDlgItemText(hDlg,IDC_GREPPATH,ReadRegistry(HKEY_CURRENT_USER,"SOFTWARE\SVz","greppath"))
			SetDlgItemText(hDlg,IDC_TAG,ReadRegistry(HKEY_CURRENT_USER,"SOFTWARE\SVz","tag"))
			If ReadRegistry(HKEY_CURRENT_USER,"SOFTWARE\SVz","boolclean") = "0" Then
				CheckDlgButton(hDlg,IDC_SCLEAN,BST_UNCHECKED)
			Else
				CheckDlgButton(hDlg,IDC_SCLEAN,BST_CHECKED)
			EndIf
			

		case WM_CLOSE
			EndDialog(hDlg, 0)
			'
		case WM_COMMAND
			id=loword(wParam)
			event=hiword(wParam)
			select case id
				case IDC_SSAVE
					GetDlgItemText(hDlg,IDC_SAVEPATH,strbuffer,259)
					WriteRegistry (HKEY_CURRENT_USER, "SOFTWARE\SVz", "savepath", ValString ,strbuffer)				
					GetDlgItemText(hDlg,IDC_GREPPATH,strbuffer,259)
					WriteRegistry (HKEY_CURRENT_USER, "SOFTWARE\SVz", "greppath", ValString ,strbuffer)				
					GetDlgItemText(hDlg,IDC_TAG,strbuffer,259)
					WriteRegistry (HKEY_CURRENT_USER, "SOFTWARE\SVz", "tag", ValString ,strbuffer)				
					WriteRegistry (HKEY_CURRENT_USER, "SOFTWARE\SVz", "boolclean", ValString ,Str(IsDlgButtonChecked(hDlg,IDC_SCLEAN)))				
					EndDialog(hDlg, 0)

				case IDC_SCANCEL
					EndDialog(hDlg, 0)
					'
			end select
		case WM_SIZE
			'
		case else
			return FALSE
			'
	end select
	return TRUE

End Function

Function apkProc(byval hDlg as HWND, byval uMsg as UINT, byval wParam as WPARAM, byval lParam as LPARAM) as integer
	dim as long id, event, nInx
	Dim regpath As string 
	Dim keyname As String 
	Dim strbuffer As ZString*260
	Dim command_build As ZString *2048
	Dim hCtl As HWND


	select case uMsg
		case WM_INITDIALOG
			hCtl=GetDlgItem(hDlg,IDC_LAPK)
			SendMessage(hCtl,LB_RESETCONTENT,0,0)
		
			command_build = "adb shell pm list packages -f"
			'CommandLapk(hDlg,@command_build,TRUE)

			'SendDlgItemMessage(hDlg,IDC_LAPK,LB_ADDSTRING,0,Cast(LPARAM,StrPtr("adb 1")))
			'SendDlgItemMessage(hDlg,IDC_LAPK,LB_ADDSTRING,0,Cast(LPARAM,StrPtr("adb 2")))
			'SendDlgItemMessage(hDlg,IDC_LAPK,LB_ADDSTRING,0,Cast(LPARAM,StrPtr("adb 3")))

		case WM_CLOSE
			EndDialog(hDlg, 0)
			'
		case WM_COMMAND
			id=loword(wParam)
			event=hiword(wParam)
			Select Case Event
				Case LBN_DBLCLK
					' Get the filename from the listbox
					nInx=SendDlgItemMessage(hDlg,IDC_LAPK,LB_GETCURSEL,0,0)
					SendDlgItemMessage(hDlg,IDC_LAPK,LB_GETTEXT,nInx,Cast(LPARAM,@strbuffer))
					SetDlgItemText(hDlg,IDC_APKNAME,strbuffer)

			End Select
			
			select case id
				case IDC_OK
					GetDlgItemText(hDlg,IDC_APKNAME,strbuffer,80)
					command_build = "adb pull " + strbuffer + " " + Left(fullnameapk,InStrRev(fullnameapk,"\")) + Right(strbuffer,Len(strbuffer) - InStrRev(strbuffer,"/"))
					MyType.hWin = hWnd
					MyType.mystr = command_build
					MyType.flagcons = TRUE
					ThreadCreate (@MyThread, @MyType)
					'MessageBox(hDlg,command_build,"",MB_ICONASTERISK)
					
				case IDC_SCANCEL
					EndDialog(hDlg, 0)
					'
			end select
		case WM_SIZE
			'
		case else
			return FALSE
			'
	end select
	return TRUE

End Function


Function NotesDlgProc(byval hDlg as HWND, byval uMsg as UINT, byval wParam as WPARAM, byval lParam as LPARAM) as integer
	dim as long id, event
	Dim hfont As HFONT
	Dim filename As ZString*260
	Dim As Byte Ptr lpBuffer
	Dim As Integer hFile, Size
	
	select case uMsg
		case WM_INITDIALOG
			hfont=CreateFont(10,0,0,0,400,0,FALSE,0,DEFAULT_CHARSET,0,0,0,0 or 0,"Lucida Console")
			SendMessage(GetDlgItem(hDlg,IDC_NOTES),WM_SETFONT,hfont,TRUE)
			filename = fullnameapk + ".txt"
			hFile = FreeFile()
			If Open(filename For Binary Access Read As #hFile) = 0 Then
				Size = LOF(hFile)
				lpBuffer = Allocate(Size)
				Get #hFile, , lpBuffer[0], Size
     			SetDlgItemText(hDlg,IDC_NOTES,lpBuffer)
     			PostMessage(GetDlgItem(hDlg,IDC_NOTES),EM_SETSEL,-1,0)
				Close #hFile
				Deallocate lpBuffer
			Else
        		SendDlgItemMessage(hDlg,IDC_NOTES,EM_REPLACESEL,0,StrPtr("New!"))
			End If
			
		case WM_CLOSE
			EndDialog(hDlg, 0)
			'
		case WM_COMMAND
			id=loword(wParam)
			event=hiword(wParam)
			select case id
				case IDC_SAVENOTES
					filename = fullnameapk + ".txt"
					hFile = FreeFile()
					If Open(filename For Binary Access Write As #hFile) = 0 Then
						Size = GetWindowTextLength(GetDlgItem(hDlg,IDC_NOTES)) + 1
						lpBuffer = Allocate(Size)
						GetDlgItemText(hDlg,IDC_NOTES,lpBuffer,Size)
						Put #hFile, , lpBuffer[0],Size
						Close #hFile
						Deallocate lpBuffer
						EndDialog(hDlg, 0)
					EndIf	 

			end select
		case WM_SIZE
			'
		case else
			return FALSE
			'
	end select
	return TRUE

End Function

Function WndProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim hfont As HFONT
	Dim command_build As ZString *2048
	Dim ofn As OPENFILENAME
	Dim namebuffer As ZString*260
	Dim path As String = ExePath
	Dim As String SourceFile, DestFile
	
	Select Case uMsg
		Case WM_INITDIALOG
			hWnd=hWin
				
			hfont=CreateFont(10,0,0,0,400,0,FALSE,0,DEFAULT_CHARSET,0,0,0,0 or 0,"Lucida Console")
			SendMessage(GetDlgItem(hWnd,IDC_CONS),WM_SETFONT,hfont,TRUE)
			If ReadRegistry(HKEY_CURRENT_USER,"SOFTWARE\SVz","lastapk") <> "" Then
				SetDlgItemText(hWnd,IDC_FILENAME,ReadRegistry(HKEY_CURRENT_USER,"SOFTWARE\SVz","lastapk"))
				namebuffer = ReadRegistry(HKEY_CURRENT_USER,"SOFTWARE\SVz","lastapk")
				SetCurrentDirectory(Left(namebuffer,InStrRev(namebuffer,"\")))
        		EnableWindow(GetDlgItem(hWnd,IDC_GO),TRUE)
      		EnableWindow(GetDlgItem(hWnd,IDC_FORCE),TRUE)
      		EnableWindow(GetDlgItem(hWnd,IDC_COMP),TRUE)
      		EnableWindow(GetDlgItem(hWnd,IDC_JAR),TRUE)
      		EnableWindow(GetDlgItem(hWnd,IDC_JD),TRUE)
      		EnableWindow(GetDlgItem(hWnd,IDC_SIGN),TRUE)
      		EnableWindow(GetDlgItem(hWnd,IDC_ZIP),TRUE)
      		EnableWindow(GetDlgItem(hWnd,IDC_INSTALL),TRUE)
      		EnableWindow(GetDlgItem(hWnd,IDC_SAVE),TRUE)
      		EnableWindow(GetDlgItem(hWnd,IDC_MANIFEST),TRUE)
      		EnableWindow(GetDlgItem(hWnd,IDC_EXPLORE),TRUE)
			EndIf
			
			'Extend control edit text
			SendMessage(GetDlgItem(hWnd,IDC_CONS),EM_SETLIMITTEXT,524288,0)
			
			SendDlgItemMessage(hWnd,IDC_CLEAR,BM_SETIMAGE,IMAGE_ICON,LoadIcon(hInstance,ANDROID))
						
		Case WM_COMMAND
			Select Case HiWord(wParam)
				Case BN_CLICKED,1
					Select Case LoWord(wParam)
						Case IDC_CHOOSE
							ofn.lStructSize=SizeOf(OPENFILENAME)
							ofn.hwndOwner=hWin
							ofn.hInstance=hInstance
							ofn.lpstrInitialDir=StrPtr(path)
							namebuffer=String(260,0)
							ofn.lpstrFile=@namebuffer
							ofn.nMaxFile=260
							ofn.lpstrFilter=StrPtr(szFilter)
							ofn.lpstrTitle=StrPtr("Choose apk")
							ofn.Flags=OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST
							If GetOpenFileName(@ofn) Then
								WriteRegistry (HKEY_CURRENT_USER, "SOFTWARE\SVz", "lastapk", ValString ,namebuffer)
								SetDlgItemText(hWnd,IDC_FILENAME,namebuffer)
                  		EnableWindow(GetDlgItem(hWnd,IDC_GO),TRUE)
                  		EnableWindow(GetDlgItem(hWnd,IDC_FORCE),TRUE)
                  		EnableWindow(GetDlgItem(hWnd,IDC_COMP),TRUE)
                  		EnableWindow(GetDlgItem(hWnd,IDC_JAR),TRUE)
                  		EnableWindow(GetDlgItem(hWnd,IDC_JD),TRUE)
                  		EnableWindow(GetDlgItem(hWnd,IDC_SIGN),TRUE)
                  		EnableWindow(GetDlgItem(hWnd,IDC_ZIP),TRUE)
                  		EnableWindow(GetDlgItem(hWnd,IDC_INSTALL),TRUE)
                  		EnableWindow(GetDlgItem(hWnd,IDC_SAVE),TRUE)
                  		EnableWindow(GetDlgItem(hWnd,IDC_MANIFEST),TRUE)
                  		EnableWindow(GetDlgItem(hWnd,IDC_EXPLORE),TRUE)
							EndIf
							
							'
						Case IDC_MANIFEST
						
							GetDlgItemText(hWin,IDC_FILENAME,namebuffer,259)
							command_build="aapt d xmltree " + namebuffer + " AndroidManifest.xml"
							MyType.hWin = hWin
							MyType.mystr = command_build
							MyType.flagcons = TRUE
							ThreadCreate (@MyThread, @MyType)
							
							'CommandExecute(hWnd,@command_build,TRUE)
							
						Case IDC_CLEAR
							SetDlgItemText(hWnd,IDC_CONS,"")
							'
						Case IDC_GO
							GetDlgItemText(hWin,IDC_FILENAME,namebuffer,259)
							command_build="apktool.bat d "
							If (IsDlgButtonChecked(hWnd,IDC_FORCE)<>0) Then
								If MessageBox(hWnd,"Modified files will be lost !","Alert",MB_ICONEXCLAMATION Or MB_OKCANCEL) <> IDCANCEL Then
									command_build = command_build + "-f "
								EndIf
							EndIf
							command_build = command_build + namebuffer + " -o " + namebuffer + "_dump"
							MyType.hWin = hWin
							MyType.mystr = command_build
							MyType.flagcons = TRUE
							ThreadCreate (@MyThread, @MyType)
'							CommandExecute(hWnd,@command_build,TRUE)
'                  	SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szDone))
							'
						Case IDC_COMP
							GetDlgItemText(hWin,IDC_FILENAME,namebuffer,259)
							command_build = "apktool.bat b " + namebuffer + "_dump -o " + RTrim(namebuffer,".apk") + ".v.apk"
							MyType.hWin = hWin
							MyType.mystr = command_build
							MyType.flagcons = TRUE
							ThreadCreate (@MyThread, @MyType)
'							CommandExecute(hWnd,@command_build,TRUE)
'                  	SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szDone))
                  	
                  Case IDC_JAR
							GetDlgItemText(hWin,IDC_FILENAME,namebuffer,259)
							command_build = "dex2jar.bat " + namebuffer
							MyType.hWin = hWin
							MyType.mystr = command_build
							MyType.flagcons = TRUE
							ThreadCreate (@MyThread, @MyType)
							'CommandExecute(hWnd,@command_build,TRUE)
                  	'SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szDone))
                  	
						Case IDC_JD
							GetDlgItemText(hWin,IDC_FILENAME,namebuffer,259)
							command_build = "jd-gui.exe  " + namebuffer + ".dex2jar.jar"
							CommandExecute(hWnd,@command_build,FALSE)
							
						Case IDC_SIGN
							GetDlgItemText(hWin,IDC_FILENAME,namebuffer,259)
							command_build = "java -classpath testsign.jar testsign " + RTrim(namebuffer,".apk") + ".v.apk"
							MyType.hWin = hWin
							MyType.mystr = command_build
							MyType.flagcons = TRUE
							ThreadCreate (@MyThread, @MyType)
							'CommandExecute(hWnd,@command_build,TRUE)
                  	'SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr("Sign "))
                  	'SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szDone))
                  	
						Case IDC_ZIP
							GetDlgItemText(hWin,IDC_FILENAME,namebuffer,259)
							command_build = "zipalign -f 4 " + RTrim(namebuffer,".apk") + ".v.apk " + RTrim(namebuffer,".apk") + ".sv.apk"
							MyType.hWin = hWin
							MyType.mystr = command_build
							MyType.flagcons = TRUE
							ThreadCreate (@MyThread, @MyType)
							'CommandExecute(hWnd,@command_build,TRUE)
                  	'SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr("Zip "))
                  	'SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szDone))
                  	
                  	
						Case IDC_DEVICES
							command_build = "adb devices"
							MyType.hWin = hWin
							MyType.mystr = command_build
							MyType.flagcons = TRUE
							ThreadCreate (@MyThread, @MyType)
							'CommandExecute(hWnd,@command_build,TRUE)
                  	'SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szDone))

						Case IDC_LISTAPK
							command_build = "adb shell pm list packages -f"
							MyType.hWin = hWin
							MyType.mystr = command_build
							MyType.flagcons = TRUE
							ThreadCreate (@MyThread, @MyType)
							'CommandExecute(hWnd,@command_build,TRUE)
							'CreateDialogParam(hInstance,Cast(ZString Ptr,IDD_APK),NULL,@apkProc,NULL)
                  	'SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szDone))
						
						Case IDC_PULL
							GetDlgItemText(hWin,IDC_FILENAME,fullnameapk,259)
                  	CreateDialogParam(hInstance,Cast(ZString Ptr,IDD_APK),NULL,@apkProc,NULL)
                  	
						Case IDC_LOGCAT
							If hprocess_logcat=0 then
								command_build = "adb logcat "
								If ReadRegistry(HKEY_CURRENT_USER,"SOFTWARE\SVz","tag") <> "" Then
									command_build = command_build + ReadRegistry(HKEY_CURRENT_USER,"SOFTWARE\SVz","tag") + ":* *:S"
								EndIf
								MyType.hWin = hWin
								MyType.mystr = command_build
								MyType.flagcons = TRUE
								ThreadCreate (@MyThread, @MyType)
	               		SendDlgItemMessage(hWnd,IDC_GRP4,WM_SETTEXT,0,StrPtr("adb (log on)"))
							Else
								TerminateProcess(hprocess_logcat,0)
	               		SendDlgItemMessage(hWnd,IDC_GRP4,WM_SETTEXT,0,StrPtr("adb"))
								hprocess_logcat=0
							EndIf

						Case IDC_NOTE
							GetDlgItemText(hWin,IDC_FILENAME,fullnameapk,259)
							CreateDialogParam(hInstance,Cast(ZString Ptr,IDD_NOTES),NULL,@NotesDlgProc,NULL)

						Case IDC_INSTALL
							GetDlgItemText(hWin,IDC_FILENAME,namebuffer,259)
							If (ReadRegistry(HKEY_CURRENT_USER,"SOFTWARE\SVz","boolclean") = "1") Then
								namebuffer = RTrim(namebuffer,".apk") + ".v.apk"
								If DeleteFile(namebuffer) <> 0 Then
									namebuffer = namebuffer + " deleted !"
		               		SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(namebuffer))
									SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szCRLF))
								endif
							EndIf
							GetDlgItemText(hWin,IDC_FILENAME,namebuffer,259)
							command_build = "adb install -r " + RTrim(namebuffer,".apk") + ".sv.apk "
							MyType.hWin = hWin
							MyType.mystr = command_build
							MyType.flagcons = TRUE
							ThreadCreate (@MyThread, @MyType)

						Case IDC_SAVE
							GetDlgItemText(hWin,IDC_FILENAME,namebuffer,259)
							SourceFile = RTrim(namebuffer,".apk") + ".sv.apk"
							namebuffer = RTrim(namebuffer,".apk") + ".sv.apk"
							DestFile = ReadRegistry(HKEY_CURRENT_USER,"SOFTWARE\SVz","savepath") + Right(namebuffer,Len(namebuffer) - InStrRev(namebuffer,"\"))
							If CopyFile(SourceFile, DestFile,FALSE) <> 0 Then
								SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr("Apk copied @ "))
								SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(DestFile))
								SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szCRLF))
							Else
								SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr("Error ! Apk not copied"))
								SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szCRLF))
							EndIf

							GetDlgItemText(hWin,IDC_FILENAME,namebuffer,259)
							SourceFile = namebuffer + ".txt"
							namebuffer = namebuffer + ".txt"
							If FileExists(SourceFile) Then
								DestFile = ReadRegistry(HKEY_CURRENT_USER,"SOFTWARE\SVz","savepath") + Right(namebuffer,Len(namebuffer) - InStrRev(namebuffer,"\"))
								If CopyFile(SourceFile, DestFile,FALSE) <> 0 Then
									SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr("Txt copied"))
									SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szCRLF))
								Else
									SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr("Error ! TxT not copied"))
									SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szCRLF))
								EndIf
							EndIf

						'Case IDC_CLEAN
						'	GetDlgItemText(hWin,IDC_FILENAME,namebuffer,259)
						'	namebuffer = RTrim(namebuffer,".apk") + ".v.apk"
						'	If MessageBox(hWnd,"Erase File !","Alert",MB_ICONEXCLAMATION Or MB_OKCANCEL) <> IDCANCEL Then
						'		If DeleteFile(namebuffer) <> 0 Then
						'			namebuffer = namebuffer + " deleted !"
		            '   		SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(namebuffer))
						'			SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szCRLF))
						'		Else
		            '   		SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr("error deleting file !"))
						'			SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szCRLF))
						'		EndIf
						'	EndIf

						Case IDC_GREP
							CommandExecute(hWnd,ReadRegistry(HKEY_CURRENT_USER,"SOFTWARE\SVz","greppath"),FALSE)

						Case IDC_EXPLORE
							GetDlgItemText(hWin,IDC_FILENAME,namebuffer,259)
							command_build = "explorer.exe " + namebuffer + "_dump"
							Print command_build
							CommandExecute(hWnd,command_build,FALSE)

						Case IDC_SNIPPET
							WriteClipboard(szSnippet,CF_TEXT,hWin)
							SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr("Copied to clipboard !"))
							SendDlgItemMessage(hWnd,IDC_CONS,EM_REPLACESEL,0,StrPtr(szCRLF))

						Case IDM_SETTING
							CreateDialogParam(hInstance,Cast(ZString Ptr,IDD_SETTING),NULL,@DlgProc,NULL)

						Case IDM_FILE_EXIT
							SendMessage(hWin,WM_CLOSE,0,0)
							'
						Case IDM_HELP_ABOUT
							ShellAbout(hWin,@AppName,@AboutMsg,NULL)
							'
					End Select
					'
			End Select
			'
		Case WM_SIZE
			'
		Case WM_CLOSE
			DestroyWindow(hWin)
			'
		Case WM_DESTROY
			PostQuitMessage(NULL)
			'
		Case Else
			Return DefWindowProc(hWin,uMsg,wParam,lParam)
			'
	End Select
	Return 0

End Function

Function WinMain(ByVal hInst As HINSTANCE,ByVal hPrevInst As HINSTANCE,ByVal CmdLine As ZString ptr,ByVal CmdShow As Integer) As Integer
	Dim wc As WNDCLASSEX
	Dim msg As MSG

	' Setup and register class for dialog
	wc.cbSize=SizeOf(WNDCLASSEX)
	wc.style=CS_HREDRAW or CS_VREDRAW
	wc.lpfnWndProc=@WndProc
	wc.cbClsExtra=0
	wc.cbWndExtra=DLGWINDOWEXTRA
	wc.hInstance=hInst
	wc.hbrBackground=Cast(HBRUSH,COLOR_BTNFACE+1)
	wc.lpszMenuName=Cast(ZString Ptr,IDM_MENU)
	wc.lpszClassName=@ClassName
	wc.hIcon=LoadIcon(hInst,MAINICON)
	wc.hIconSm=wc.hIcon
	wc.hCursor=LoadCursor(NULL,IDC_ARROW)
	RegisterClassEx(@wc)
	' Create and show the dialog
	CreateDialogParam(hInstance,Cast(ZString Ptr,IDD_DIALOG),NULL,@WndProc,NULL)
	ShowWindow(hWnd,SW_SHOWNORMAL)
	UpdateWindow(hWnd)
	' Message loop
	Do While GetMessage(@msg,NULL,0,0)
		TranslateMessage(@msg)
		DispatchMessage(@msg)
	Loop
	Return msg.wParam

End Function

' Program start
hInstance=GetModuleHandle(NULL)
CommandLine=GetCommandLine
InitCommonControls
WinMain(hInstance,NULL,CommandLine,SW_SHOWDEFAULT)
If hprocess_logcat<>0 then
	TerminateProcess(hprocess_logcat,0)
EndIf
ExitProcess(0)

End
