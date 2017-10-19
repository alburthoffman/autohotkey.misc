#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, 0  ; need this setting to avoid sending multiple keystrokes
#UseHook

#SingleInstance force

;;; prefix hot key 
isPrefixAltZDown := 0
timeOfPrefixAltZDown := 0
timespanOfPrefixAltZ := 1500

ResetPrefixAltZStatus:
	ElspsedTime := A_TickCount - timeOfPrefixAltZDown
	If (ElspsedTime > timespanOfPrefixAltZ) {
		isPrefixAltZDown := 0
		timeOfPrefixAltZDown := 0
		SetTimer, ResetPrefixAltZStatus, Off
	} else {
		SetTimer, ResetPrefixAltZStatus, %timespanOfPrefixAltZ%
	}
Return

#a::
	If shouldBeIgnored() {
		Send %A_ThisHotkey%
		Return
	}

	If (isPrefixAltZDown <= 0) {
		SetTimer, ResetPrefixAltZStatus, %timespanOfPrefixAltZ%
	}

	;; actually initialization goes here
	isPrefixAltZDown = 1
	timeOfPrefixAltZDown := A_TickCount
	timespanOfPrefixAltZ := 1500
Return

;; define ur ignore list here
ShouldBeIgnored() {
	Return 0
}

IsSkippable() {
	global isPrefixAltZDown
	global timeOfPrefixAltZDown
	If ShouldBeIgnored()
		Return 1

	If isPrefixAltZDown {
		isPrefixAltZDown = 0
		timeOfPrefixAltZDown = 0
		Return 0
	} else {
		Return 1
	}
}

!d::
	if IsSkippable() {
		Send %A_ThisHotkey%
	} else {
		Run C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\Remote Desktop Connection.lnk
	}
Return
