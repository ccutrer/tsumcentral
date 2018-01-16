#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Pixel, Screen

WindowTitle = %1%
ClaimOnly = %2%
LogFile = %WindowTitle%.log

WinGet, PID, PID, %WindowTitle% ahk_class Qt5QWindowIcon

ControlGetPos, x, y, w, h, subWin1, %WindowTitle% ahk_class Qt5QWindowIcon
if (W == "") {
  ControlGetPos, x, y, w, h, QWidgetClassWindow, %WindowTitle% ahk_class Qt5QWindowIcon
}

Script_Name = Tsum Tsum Heart Sending
Script_Version = V3.3
Menu Tray, Tip, %Script_Name% %Script_Version% `n%WindowTitle% Res W%W% H%H%


;---------- MAIN LOGIC ------

AddLog("Start; Nox PID: " . PID)
ProcRes(PID)
WinRestore, %WindowTitle% ahk_class Qt5QWindowIcon

if (W == "") {
  AddLog("Could not find emulator window " . WindowTitle)
  ExitApp 1
}

; 405x720 + 24pixel virtual buttons on the bottom
if (W != 405) || (H != 744) {
  AddLog("Emulator is not 405x720. Please adjust the resolution.")
  ExitApp 2
}

if (X != 2) || (Y != 30) {
  AddLog("Emulator chrome is an odd size. Help!")
  ExitApp 3
}

; Press Home
Sleep, 1000
ControlClick, x204 y760, %WindowTitle% ahk_class Qt5QWindowIcon
Sleep, 1000
; Open the App
ControlClick, x204 y437, %WindowTitle% ahk_class Qt5QWindowIcon
Sleep, 2000

GoSub, CheckConnection

AddLog("Claiming All")
GoSub, ClaimAll

if (ClaimOnly == "--claim-only") {
  AddLog("0 Given; Claiming only")
  WinMinimize, %WindowTitle% ahk_class Qt5QWindowIcon
  ProcSus(PID)
  AddLog("End")
  ExitApp 0
}

TotalHeartsGiven = 0

Loop
{
  AddLog("Reset")
  GoSub, Reset2Me

  AddLog("Scrolling to top...")
  GoSub, Scroll2Top

  AddLog("Giving Hearts...")
  GoSub, SendHearts
  AddLog(GiveHearts . " hearts given this round")

  TotalHeartsGiven += GiveHearts
  if (GiveHearts == 0) {
    Break
  }

  AddLog("Claiming All")
  GoSub, ClaimAll
}

AddLog(TotalHeartsGiven . " Given")

WinMinimize, %WindowTitle% ahk_class Qt5QWindowIcon
ProcSus(PID)
AddLog("End")
ExitApp ;TsumTsum


;------------- LABEL(S) ----------

CheckConnection:
	Tap_Count = 0
	Loop
	{
		;WinActivate, %WindowTitle% ahk_class Qt5QWindowIcon ; Select Emulator
		ControlClick, x336 y178, %WindowTitle% ahk_class Qt5QWindowIcon ; Click mail button.
		Sleep, 1000

		; Search for pink heart bottom left of Mail Box.		
		if (FindPixel(Px1, Py1, 45, 555, 55, 565, 0x9540DE)) {
			Break
		} else {
			; OK button in Receive Gift popup
			FindAndClick(310, 435, 320, 445, 0x0AB0F2)

			; Close Button Search 5YY Range
			FindAndClick(195, 550, 205, 560, 0x0AADF0)
			
			; Close Button Search 6YY Range
			FindAndClick(195, 685, 205, 695, 0x4D3013)

			; Play Again button Error Code: -1
			FindAndClick(310, 435, 320, 445, 0x283B67)

			; Tap To Start button 
			if (FindAndClick(195, 605, 205, 615, 0x09AAEF)) {
				If Tap_Count = 0
				{
					AddLog("Reconnecting...")
				}
				Tap_Count++
			}
		}

		}
Return ;CheckConnection

ClaimAll:
 Mail_Claimed = 0

 ;Guarantees mailbox is click
 Loop	
 {
	if (FindPixel(Px1, Py1, 45, 555, 55, 565, 0x9540DE)) ;Search for pink heart bottom left of Mail Box.
		Break
	Else
		ControlClick, x336 y178, %WindowTitle% ahk_class Qt5QWindowIcon ; Click mail button.
 }

 Loop
 {
	Sleep, 500
	; Search for Claim All button
	FindAndClick(350, 565, 360, 575, 0x08ACF0)

	; Play Again button Error Code: -1
	FindAndClick(310, 435, 320, 445, 0x283B67)

	; OK button in Receive Gift popup
	FindAndClick(310, 435, 320, 445, 0x0AB0F2)

	; Received - Close Button Search 5YY Range
	if (FindAndClick(195, 550, 205, 560, 0x0AADF0))
	{
		Loop
		{
			if FindPixel(Px1, Py1, 45, 555, 55, 565, 0x9540DE) ;Search for pink heart bottom left of Mail Box.
			{
				Mail_Claimed++
				Break
			}

			; Disconnected
			if FindPixel(Px1, Py1, 195, 605, 205, 615, 0x09AAEF)
			{
				GoSub CheckConnection
				AddLog("Claiming All")
				Break
			}
		}
		if Mail_Claimed > 0
			Break
	}

	; No messages notice in Mail Box
	if FindPixel(Px1, Py1, 195, 255, 205, 265, 0xE7CC70)
	{
		AddLog("Nothing to Claim")
		Break
	}
 }

Loop
{
	Sleep, 500
	
	; Break loop if play button found on Leaderboard
	if FindPixel(Px1, Py1, 200, 640, 210, 650, 0x0F85FF)
		Break

 	; Guarantees Info Received popup gets closed
	FindAndClick(195, 550, 205, 560, 0x0AADF0)

 	; Close Button Search 6YY Range
	FindAndClick(195, 685, 205, 695, 0x4D3013)
}
	
Return ;ClaimAll 

Reset2Me:
	ResetL = 0
	Loop
	{
		if ResetL > 0
			Break
		else
		{	
			Sleep, 500
			
			;Play button in leaderboard
			FindAndClick(200, 640, 210, 650, 0x0F85FF)
		
			;Pink Start Button
			if FindPixel(Px1, Py1, 200, 640, 210, 650, 0x7D69F5)
			{
				ControlClick, x70 y637, %WindowTitle% ahk_class Qt5QWindowIcon ;Click Back Button
				Loop
				{
					Sleep, 500
					if FindPixel(Px1, Py1, 200, 640, 210, 650, 0x0F85FF)
						Break
					else
						ControlClick, x70 y637, %WindowTitle% ahk_class Qt5QWindowIcon ;Click Back Button
				}
				ResetL++
			}
		}
	}

Return ;Reset2Me

Scroll2Top:

 Loop
 {
	Sleep, 1000

	if FindPixel(Px1, Py1, 70, 270, 80, 320, 0x39C5F4)
		Break
	else
	{
		ControlClick, x217 y270 , %WindowTitle% ahk_class Qt5QWindowIcon,,,, D ,,, NA
		ControlClick, x217 y500 , %WindowTitle% ahk_class Qt5QWindowIcon,,,, U ,,, NA
	}
}
Return ;Scroll2Top

SendHearts:
	GiveHearts = 0
	loop
	{
		Sleep, 500
;		; Search for 0 Scores
;		WinActivate, %WindowTitle% ahk_class Qt5QWindowIcon ; Select Emulator
;		PixelSearch, Osx, Osy, 260, 300, 280, 500, 0xFFFFFF, 3, Fast
;		if ErrorLevel
;		    Break

		; Search for Pink Hearts
		if (FindAndClick(320, 240, 380, 550, 0x8B3DE1))
		{
			; Give Hearts
			Loop
			{
				; OK button in Gift a Heart popup
				FindAndClick(310, 435, 320, 445, 0x0AB0F2)

				; Play Again button Error Code: -1
				FindAndClick(310, 435, 320, 445, 0x283B67)

				; Heart Sent
				if (FindAndClick(290, 435, 300, 445, 0xE6C11F)) {
					GiveHearts++
					Break
				}
	
				; Error 6 - Disconnected while giving hearts
				if (FindAndClick(195, 550, 205, 560, 0x0AADF0)) {
				    TotalHeartsGiven += GiveHearts
					AddLog("Disconnected.  " . TotalHeartsGiven . " Given")
					WinMinimize, %WindowTitle% ahk_class Qt5QWindowIcon
                    ProcSus(PID)
					ExitApp
				}

			} 
		} else {
			; Scroll Down if no pink found
			;End of List
			if (FindPixel(Ex1, Ey1, 80, 390, 90, 530, 0x31509C))
				Break

			ControlClick, x62 y500 , %WindowTitle% ahk_class Qt5QWindowIcon,,,, D ,,, NA			
			Sleep, 25
			ControlClick, x62 y475 , %WindowTitle% ahk_class Qt5QWindowIcon,,,, D ,,, NA			
			Sleep, 25
			ControlClick, x62 y450 , %WindowTitle% ahk_class Qt5QWindowIcon,,,, D ,,, NA			
			Sleep, 25
			ControlClick, x62 y425 , %WindowTitle% ahk_class Qt5QWindowIcon,,,, D ,,, NA			
			Sleep, 25
			ControlClick, x62 y400 , %WindowTitle% ahk_class Qt5QWindowIcon,,,, D ,,, NA			
			Sleep, 25
			ControlClick, x62 y375 , %WindowTitle% ahk_class Qt5QWindowIcon,,,, D ,,, NA			
			Sleep, 25
			ControlClick, x62 y350 , %WindowTitle% ahk_class Qt5QWindowIcon,,,, D ,,, NA			
			Sleep, 25
			ControlClick, x62 y325 , %WindowTitle% ahk_class Qt5QWindowIcon,,,, D ,,, NA			
			Sleep, 25
			ControlClick, x62 y300 , %WindowTitle% ahk_class Qt5QWindowIcon,,,, D ,,, NA
			Sleep, 25
			ControlClick, x62 y275 , %WindowTitle% ahk_class Qt5QWindowIcon,,,, D ,,, NA			
			Sleep, 25
			ControlClick, x62 y275 , %WindowTitle% ahk_class Qt5QWindowIcon,,,, U ,,, NA
		}		
	}

Return ;SendHearts

AddLog(newString)
{
  global LogFile
  FormatTime, Time,, yyyy-MM-dd hh:mm:ss tt
  NewEntry := Time . " - " . newString
  FileAppend, %NewEntry%`n, %LogFile%
}

FindPixel(ByRef ox, ByRef oy, x1, y1, x2, y2, color)
{
  global WindowTitle
  WinGetPos, WX, WY, , , %WindowTitle% ahk_class Qt5QWindowIcon
  ;WinGet, hwnd, ID, %WindowTitle% ahk_class Qt5QWindowIcon
  ;DllCall("RedrawWindow", "Ptr", hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0)
  PixelSearch, ox, oy, x1 + WX, y1 + WY, x2 + WX, y2 + WY, color, 3, Fast
  return (ErrorLevel = 0)
}

FindAndClick(x1, y1, x2, y2, color)
{
  found := FindPixel(px, py, x1, y1, x2, y2, color)
  if found
    ClickPixel(px, py)
  return found
}

ClickPixel(x, y)
{
	global WindowTitle
    WinGetPos, WX, WY, , , %WindowTitle% ahk_class Qt5QWindowIcon
    real_x := (x - WX)
	real_y := (y - WY)
    ControlClick, x%real_x% y%real_y%, %WindowTitle% ahk_class Qt5QWindowIcon
}

ProcSus(PID)
{
	If !(h := DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", PID))
		Return -1
	DllCall("ntdll.dll\NtSuspendProcess", "Int", h), DllCall("CloseHandle", "Int", h)
}

ProcRes(PID)
{
	If !(h := DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", PID))
		Return -1
	DllCall("ntdll.dll\NtResumeProcess", "Int", h), DllCall("CloseHandle", "Int", h)
}

;---------- HOTKEYS ---------
Pause::Pause

^Esc::ExitApp

