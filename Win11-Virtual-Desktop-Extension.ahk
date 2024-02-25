; Win11-Virtual-Desktop-Extension.ahk:
; Enhance Windows 11 virtual desktops
; Author: Andrea Brandi <git@andreabrandi.com>

; Based on VirtualDesktopAccessor Windows 11 binary
; https://github.com/Ciantic/VirtualDesktopAccessor

;@Ahk2Exe-Let version=1.0.0
;@Ahk2Exe-SetVersion %U_version%
;@Ahk2Exe-SetProductVersion %U_version%
;@Ahk2Exe-SetName Virtual Desktop Extension
;@Ahk2Exe-SetDescription Virtual Desktop Extension
;@Ahk2Exe-SetCopyright Copyright (c) 2024`, Andrea Brandi
;@Ahk2Exe-SetLanguage 0x0409
;@Ahk2Exe-SetMainIcon .\icons\app.ico

#Requires AutoHotkey v2.0
#SingleInstance Force
#WinActivateForce
#UseHook True

#HotIf (MouseOnTaskbarArea() or MouseOnTaskviewArea()) and not IsRemoteDesktop()
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
VDExtMenu.Add("Task View", OpenTaskView)
VDExtMenu.Add("Credits", OpenCredits)
VDExtMenu.Add("Reload", ReloadScript)
VDExtMenu.Add("Exit", ExitScript)
VDExtMenu.Default := "Task View"
VDExtMenu.ClickCount := 2

OpenTaskView(Item, *) {
  Send("#{Tab}")
}

OpenCredits(Item, *) {
  VDExtGui := Gui()
  VDExtGui.Title := "About"
  info_repo := '<a href="https://github.com/starise/win11-virtual-desktop-extension">Win11-Virtual-Desktop-Extension</a>.'
  info_author := 'Maintained by <a href="https://andreabrandi.com">Andrea Brandi</a>.'
  info_vda := 'Based on <a href="https://github.com/Ciantic/VirtualDesktopAccessor">VirtualDesktopAccessor.dll</a> by Jari Pennanen.'
  VDExtGui.Add("Link",, info_repo " " info_author)
  VDExtGui.Add("Link",, info_vda)
  VDExtGui.Show
}

ReloadScript(Item, *) {
  Reload()
}

ExitScript(Item, *) {
  ExitApp()
}

VDA(func, argv*) {
  Static path := A_ScriptDir . ".\VirtualDesktopAccessor.dll"
  Static dll := DllCall("LoadLibrary", "Str", path, "Ptr")
  proc := DllCall("GetProcAddress", "Ptr", dll, "AStr", func, "Ptr")
  Return DllCall(proc, argv*)
}

MouseOnTaskbar() {
  MouseGetPos(,,&hoverID)
  taskbarPrimaryID := WinExist("ahk_class Shell_TrayWnd")
  taskbarSecondaryID := WinExist("ahk_class Shell_SecondaryTrayWnd")
  Return (hoverID == taskbarPrimaryID or hoverID == taskbarSecondaryID)
}

MouseOnTaskbarArea() {
  CoordMode("Mouse", "Screen")
  MouseGetPos(&xPos, &yPos)
  If (xPos <= A_ScreenWidth - 500 and yPos > A_ScreenHeight - 60) {
    Return true
  }
  Return false
}

MouseOnTaskviewArea() {
  MouseGetPos(,,&hoverID)
  taskviewAreaClass := "ahk_class XamlExplorerHostIslandWindow"
  taskviewAreaID := WinActive(taskviewAreaClass)
  Return (hoverID == WinExist(taskviewAreaID))
}

IsRemoteDesktop() {
  Return WinActive("ahk_class TscShellContainerClass")
}

GetDesktopCount() {
  count := VDA("GetDesktopCount", "UInt")
  Return count
}

GetCurrentDesktopNumber() {
  num := VDA("GetCurrentDesktopNumber", "Int")
  Return num
}

MoveWindowToDesktopNumber(num) {
  activeHwnd := WinGetID("A")
  VDA("MoveWindowToDesktopNumber", "Ptr", activeHwnd, "Int", num, "Int")
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
VDA("RegisterPostMessageHook", "Ptr", A_ScriptHwnd, "Int", 0x1400 + 30, "Int")
OnMessage(0x1400 + 30, OnDesktopChange)

OnDesktopChange(wParam, lParam, msg, hwnd) {
  ChangeAppearance()
  Return
}

ChangeAppearance() {
  desknum := GetCurrentDesktopNumber() + 1
  If (FileExist("./icons/" . desknum ".ico")) {
    TraySetIcon("icons/" . desknum . ".ico")
  }
  Else {
    TraySetIcon("icons/+.ico")
  }
  Return
}

ChangeAppearance()
