; Marceli Win preview NSIS installer. Per-user by design; never needs admin.
; Compile from projects/marceli-win with makensis.exe /V3 installer\MarceliWin.nsi
Unicode true
!include "MUI2.nsh"
; Resolve all source assets against the current installer script directory.
!define APPROOT "${__FILEDIR__}\.."

!ifndef APP_VERSION
  !define APP_VERSION "0.3.0"
!endif
!ifndef BUILD_LABEL
  !define BUILD_LABEL "unsigned-preview"
!endif

Name "Marceli Win ${APP_VERSION} (Preview)"
OutFile "${APPROOT}\dist\MarceliWin-Setup-${APP_VERSION}-${BUILD_LABEL}.exe"
InstallDir "$LOCALAPPDATA\Programs\MarceliWin"
InstallDirRegKey HKCU "Software\MarceliWin" "InstallDir"
RequestExecutionLevel user
SetCompressor /SOLID lzma
ShowInstDetails show
ShowUninstDetails show

VIProductVersion "0.3.0.0"
VIAddVersionKey "ProductName" "Marceli Win"
VIAddVersionKey "CompanyName" "Marceli Win"
VIAddVersionKey "FileDescription" "Marceli Win Preview Installer"
VIAddVersionKey "FileVersion" "${APP_VERSION}"
VIAddVersionKey "LegalCopyright" "Copyright 2026 Marceli Pawlinski. MIT."

!define MUI_ABORTWARNING
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${APPROOT}\LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Section "Marceli Win (required)" SecMain
  SetShellVarContext current
  SetOutPath "$INSTDIR"
  File "${APPROOT}\dist\stage\MarceliWin.ps1"
  File "${APPROOT}\dist\stage\launcher.cmd"
  File "${APPROOT}\LICENSE"
  File "${APPROOT}\installer\INSTALLATION.txt"
  File "${APPROOT}\dist\stage\Check-Update.ps1"
  File "${APPROOT}\dist\stage\Test-ReleaseIntegrity.ps1"

  WriteUninstaller "$INSTDIR\Uninstall.exe"
  CreateDirectory "$SMPROGRAMS\Marceli Win"
  CreateShortCut "$SMPROGRAMS\Marceli Win\Marceli Win.lnk" "$INSTDIR\launcher.cmd" "" "$SYSDIR\shell32.dll" 15
  CreateShortCut "$SMPROGRAMS\Marceli Win\Uninstall Marceli Win.lnk" "$INSTDIR\Uninstall.exe"

  WriteRegStr HKCU "Software\MarceliWin" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MarceliWin" "DisplayName" "Marceli Win (Preview)"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MarceliWin" "DisplayVersion" "${APP_VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MarceliWin" "Publisher" "Marceli Win"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MarceliWin" "UninstallString" '$"$INSTDIR\Uninstall.exe$"'
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MarceliWin" "QuietUninstallString" '$"$INSTDIR\Uninstall.exe$" /S'
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MarceliWin" "InstallLocation" "$INSTDIR"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MarceliWin" "NoModify" 1
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MarceliWin" "NoRepair" 1
SectionEnd

Section "Uninstall"
  SetShellVarContext current
  Delete "$SMPROGRAMS\Marceli Win\Marceli Win.lnk"
  Delete "$SMPROGRAMS\Marceli Win\Uninstall Marceli Win.lnk"
  RMDir "$SMPROGRAMS\Marceli Win"
  Delete "$INSTDIR\MarceliWin.ps1"
  Delete "$INSTDIR\launcher.cmd"
  Delete "$INSTDIR\LICENSE"
  Delete "$INSTDIR\INSTALLATION.txt"
  Delete "$INSTDIR\Check-Update.ps1"
  Delete "$INSTDIR\Test-ReleaseIntegrity.ps1"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  DeleteRegKey HKCU "Software\MarceliWin"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MarceliWin"
  ; Preserve %LOCALAPPDATA%\MarceliWin (registry rollback backups and logs).
SectionEnd
