; Win11-Virtual-Desktop-Enhancer.ahk:
; Enhance Windows 11 virtual desktops
; Author: Andrea Brandi <git@andreabrandi.com>

#Requires AutoHotkey v2.0

#HotIf MouseIsOnTaskbarArea() and not WinActive("ahk_class TscShellContainerClass")
  WheelDown:: GoToNextDesktop()
  WheelUp:: GoToPrevDesktop()
#HotIf

; Hotkeys to move the current window to prev or next desktop
^#+Right:: MoveToNextDesktop() ; Ctrl+Shift+Win + Right arrow
^#+Left:: MoveToPrevDesktop() ; Ctrl+Shift+Win + Left arrow

; VirtualDesktopAccessor Windows 11 binary, works with 23H2 22631.3085
; https://github.com/Ciantic/VirtualDesktopAccessor/releases/tag/2024-01-25-windows11
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
  Return
}

GoToPrevDesktop() {
  Send("{LControl down}#{Left}{LControl up}")
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
