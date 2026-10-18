@echo off
setlocal
REM Starts a locally installed, inspectable PowerShell/WPF file. Does not bypass execution policy.
if not exist "%~dp0MarceliWin.ps1" (
  echo Marceli Win could not find its installed script.
  echo Please reinstall using the verified installer.
  pause
  exit /b 2
)
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -STA -File "%~dp0MarceliWin.ps1"
set "EXITCODE=%ERRORLEVEL%"
if not "%EXITCODE%"=="0" (
  echo Marceli Win stopped with exit code %EXITCODE%.
  echo If execution policy blocked it, review the publisher signature and local policy.
  pause
)
exit /b %EXITCODE%
