; VirtualDesktopExtension.ahk:
; Enhance Windows 11 virtual desktops
; Author: Andrea Brandi <https://andreabrandi.com>

; Based on VirtualDesktopAccessor Windows 11 binary
; https://github.com/Ciantic/VirtualDesktopAccessor

;@Ahk2Exe-Let version=__APP_VERSION__
;@Ahk2Exe-SetVersion %U_version%
;@Ahk2Exe-SetProductVersion %U_version%
;@Ahk2Exe-SetName Virtual Desktop Extension
;@Ahk2Exe-SetDescription Virtual Desktop Extension
;@Ahk2Exe-SetCopyright Copyright (c) 2024-2026`, Andrea Brandi
;@Ahk2Exe-SetLanguage 0x0409
;@Ahk2Exe-SetMainIcon .\icons\app.ico

#Requires AutoHotkey v2.0
#SingleInstance Force
#WinActivateForce
#UseHook True

#HotIf (MouseOnTaskbar() or MouseOnTaskviewArea()) and not IsRemoteDesktop()
WheelDown:: GoToNextDesktop()
WheelUp:: GoToPrevDesktop()
#HotIf

; Hotkeys to move the current window to prev or next desktop
^#+Right:: MoveToNextDesktop() ; Ctrl+Shift+Win + Right arrow
^#+Left:: MoveToPrevDesktop() ; Ctrl+Shift+Win + Left arrow

; Max 2000 hotkeys pressed within 2000ms
A_MaxHotkeysPerInterval := 2000

; Custom tray menu
VDExtMenu := A_TrayMenu
VDExtMenu.Delete()
VDExtMenu.Add("Task View", (*) => Send("#{Tab}"))
VDExtMenu.Add("Credits", OpenCredits)
VDExtMenu.Add("Reload", (*) => Reload())
VDExtMenu.Add("Exit", (*) => ExitApp())
VDExtMenu.Default := "Task View"
VDExtMenu.ClickCount := 2

OpenCredits(Item, *) {
  Static CreditsGui := ""

  If (IsObject(CreditsGui)) {
    CreditsGui.Show()
    WinActivate("ahk_id " CreditsGui.Hwnd)
    Return
  }

  authorUrl := "https://andreabrandi.com"
  repoUrl := "https://github.com/starise/win11-virtual-desktop-extension"
  vdaUrl := "https://github.com/Ciantic/VirtualDesktopAccessor"

  CreditsGui := Gui(, "Virtual Desktop Extension")
  CreditsGui.MarginX := 18
  CreditsGui.MarginY := 16
  CreditsGui.SetFont("s9", "Segoe UI")

  iconPath := A_ScriptDir . "\icons\app.ico"
  If (FileExist(iconPath))
    CreditsGui.Add("Picture", "xm ym w48 h48", iconPath)
  Else
    CreditsGui.Add("Text", "xm ym w48 h48")

  CreditsGui.SetFont("s12 bold", "Segoe UI")
  CreditsGui.Add("Text", "x+12 yp w330", "Virtual Desktop Extension")
  CreditsGui.SetFont("s9 norm", "Segoe UI")
  CreditsGui.Add("Text", "xp y+2 w330", "Version " GetAppVersion())
  CreditsGui.Add("Text", "xp y+8 w330", "Enhance Windows 11 virtual desktops.")

  CreditsGui.Add("Text", "xm y+16 w390 0x10")
  CreditsGui.Add("Link", "xm y+12 w390", 'Project: <a href="' repoUrl '">win11-virtual-desktop-extension</a>')
  CreditsGui.Add("Link", "xm y+8 w390", 'Author and maintainer: <a href="' authorUrl '">Andrea Brandi</a>')
  CreditsGui.Add("Link", "xm y+8 w390", 'Built with <a href="' vdaUrl '">VirtualDesktopAccessor.dll</a> by Jari Pennanen.')
  CreditsGui.Add("Text", "xm y+10 w390", "Copyright (c) 2024-2026, Andrea Brandi.")

  CreditsGui.Add("Button", "xm y+16 w116", "Repository").OnEvent("Click", (*) => Run(repoUrl))
  CreditsGui.Add("Button", "x+8 w116", "Author Website").OnEvent("Click", (*) => Run(authorUrl))
  CreditsGui.Add("Button", "x+34 w116 Default", "Close").OnEvent("Click", (*) => CreditsGui.Hide())
  CreditsGui.OnEvent("Close", (*) => (CreditsGui.Hide(), True))
  CreditsGui.OnEvent("Escape", (*) => (CreditsGui.Hide(), True))
  CreditsGui.Show()
}

GetAppVersion() {
  If (A_IsCompiled)
    Return RegExReplace(FileGetVersion(A_ScriptFullPath), "\.0$")

  Return "Dev"
}

VDA(func, argv*) {
  Static path := A_ScriptDir . "\VirtualDesktopAccessor.dll"
  Static dll := DllCall("LoadLibrary", "Str", path, "Ptr")
  If (!dll) {
    Return ""
  }

  proc := DllCall("GetProcAddress", "Ptr", dll, "AStr", func, "Ptr")
  If (!proc) {
    Return ""
  }

  Try {
    Return DllCall(proc, argv*)
  }
  Catch {
    Return ""
  }
}

MouseOnTaskbar() {
  MouseGetPos(, , &hoverID)
  taskbarPrimaryID := WinExist("ahk_class Shell_TrayWnd")
  taskbarSecondaryID := WinExist("ahk_class Shell_SecondaryTrayWnd")
  Return (hoverID == taskbarPrimaryID or hoverID == taskbarSecondaryID)
}

MouseOnTaskviewArea() {
  MouseGetPos(, , &hoverID)
  taskviewAreaClass := "ahk_class XamlExplorerHostIslandWindow"
  taskviewAreaID := WinActive(taskviewAreaClass)
  Return (hoverID == WinExist(taskviewAreaID))
}

IsRemoteDesktop() {
  Return WinActive("ahk_class TscShellContainerClass")
}

GetDesktopCount() {
  count := VDA("GetDesktopCount", "UInt")
  Return (count != "") ? count : 1
}

GetCurrentDesktopNumber() {
  num := VDA("GetCurrentDesktopNumber", "Int")
  Return (num != "") ? num : 0
}

MoveWindowToDesktopNumber(num) {
  activeHwnd := WinGetID("A")
  If (VDA("MoveWindowToDesktopNumber", "Ptr", activeHwnd, "Int", num, "Int") = "") {
    Return False
  }

  Return
}

GoToNextDesktop() {
  Send("{LControl down}#{Right}{LControl up}")
  Sleep 200
  Return
}

GoToPrevDesktop() {
  Send("{LControl down}#{Left}{LControl up}")
  Sleep 200
  Return
}

MoveToNextDesktop() {
  current := GetCurrentDesktopNumber()
  last_desktop := GetDesktopCount() - 1
  If (current != last_desktop) {
    MoveWindowToDesktopNumber(current + 1)
    GoToNextDesktop()
  }
  Return
}

MoveToPrevDesktop() {
  current := GetCurrentDesktopNumber()
  If (current != 0) {
    MoveWindowToDesktopNumber(current - 1)
    GoToPrevDesktop()
  }
  Return
}

; Desktop changes listener
If (VDA("RegisterPostMessageHook", "Ptr", A_ScriptHwnd, "Int", 0x1400 + 30, "Int") != "") {
  OnMessage(0x1400 + 30, (*) => ChangeAppearance())
}

ChangeAppearance() {
  desknum := GetCurrentDesktopNumber() + 1
  iconName := "d-" . Format("{:02}", desknum) . ".ico"
  iconPath := A_ScriptDir . "\icons\" . iconName
  fallbackIconPath := A_ScriptDir . "\icons\app.ico"

  If (FileExist(iconPath))
    TraySetIcon(iconPath)
  Else
    TraySetIcon(fallbackIconPath)
}

ChangeAppearance()
