; Win11-Virtual-Desktop-Extension.ahk:
; Enhance Windows 11 virtual desktops
; Author: Andrea Brandi <git@andreabrandi.com>

; Based on VirtualDesktopAccessor Windows 11 binary
; https://github.com/Ciantic/VirtualDesktopAccessor

#Requires AutoHotkey v2.0
#SingleInstance Force
#WinActivateForce
#UseHook True

#HotIf MouseIsOnTaskbarArea() and not WinActive("ahk_class TscShellContainerClass")
  WheelDown:: GoToNextDesktop()
  WheelUp:: GoToPrevDesktop()
#HotIf

; Hotkeys to move the current window to prev or next desktop
^#+Right:: MoveToNextDesktop() ; Ctrl+Shift+Win + Right arrow
^#+Left:: MoveToPrevDesktop() ; Ctrl+Shift+Win + Left arrow

; Custom tray menu
A_TrayMenu.Delete()
A_TrayMenu.Add("Credits", OpenInfo)
A_TrayMenu.Add("Reload", ReloadScript)
A_TrayMenu.Add("Exit", ExitScript)

OpenInfo(Item, *) {
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

MouseIsOnTaskbarArea() {
  taskbarPrimaryID := WinExist("ahk_class Shell_TrayWnd")
  taskbarSecondaryID := WinExist("ahk_class Shell_SecondaryTrayWnd")
  MouseGetPos(,,&mouseHoveringID)
  Return (mouseHoveringID == taskbarPrimaryID or mouseHoveringID == taskbarSecondaryID)
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
  ChangeAppearance()
  Return
}

GoToPrevDesktop() {
  Send("{LControl down}#{Left}{LControl up}")
  ChangeAppearance()
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
  last_desktop := GetDesktopCount() - 1
  If (current != 0) {
    MoveWindowToDesktopNumber(current - 1)
    GoToPrevDesktop()
  }
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
}

ChangeAppearance()
