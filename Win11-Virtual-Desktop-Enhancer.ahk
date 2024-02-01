; Win11-Virtual-Desktop-Enhancer.ahk:
; Enhance Windows 11 virtual desktops
; Author: Andrea Brandi <git@andreabrandi.com>
; Copyright: 2024-present
; License: ISC

#Requires AutoHotkey v2.0

#HotIf MouseIsOnTaskbarArea() and not WinActive("ahk_class TscShellContainerClass")
  WheelDown:: Send("{LControl down}#{Right}{LControl up}")
  WheelUp:: Send("{LControl down}#{Left}{LControl up}")
#HotIf

MouseIsOnTaskbarArea() {
  taskbarPrimaryID := WinExist("ahk_class Shell_TrayWnd")
  taskbarSecondaryID := WinExist("ahk_class Shell_SecondaryTrayWnd")
  MouseGetPos(,,&mouseHoveringID)

  Return (mouseHoveringID == taskbarPrimaryID or mouseHoveringID == taskbarSecondaryID)
}
