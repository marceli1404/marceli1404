# Marceli Win 0.3 - Copyright (c) 2026 Marceli Pawlinski. MIT.
# Review downloaded scripts before running. No telemetry or secondary code downloads.
param([ValidateSet('','Safe','Balanced','Gaming','Developer','Privacy','Focus','Accessibility')][string]$Preset='', [switch]$WhatIf, [switch]$Yes, [switch]$SmokeTest)
$ErrorActionPreference='Stop'
# Optional CI-only smoke flag exercises the EXACT streamed irm | iex launch path.
if ($env:MARCELI_WIN_SMOKE_TEST -eq '1') { $SmokeTest = $true }
if ($env:OS -ne 'Windows_NT') { throw 'Marceli Win requires Windows.' }
if([Threading.Thread]::CurrentThread.GetApartmentState() -ne [Threading.ApartmentState]::STA -and !$Preset){throw 'Marceli Win WPF requires an STA thread. Use powershell.exe -STA -NoProfile -File .\MarceliWin.ps1.'}
$script:Data=Join-Path $env:LOCALAPPDATA 'MarceliWin'
New-Item -Path $script:Data -ItemType Directory -Force | Out-Null
$script:LogPath=Join-Path $script:Data 'activity.log'
$script:BackupPath=Join-Path $script:Data 'last-registry-backup.json'
$script:LogBox=$null
$script:Window=$null
function Log([string]$message) {
 $line='['+(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')+'] '+$message
 try {
  # Rotate locally at 5 MiB; prevent a very old log from growing without bound.
  if((Test-Path $script:LogPath) -and (Get-Item -LiteralPath $script:LogPath).Length -gt 5MB){
   Move-Item -LiteralPath $script:LogPath -Destination ($script:LogPath+'.old') -Force
  }
  Add-Content -LiteralPath $script:LogPath -Value $line -Encoding UTF8 -ErrorAction Stop
 } catch {Write-Warning ('Could not write Marceli Win log: '+$_.Exception.Message)}
 if($script:LogBox){
  $script:LogBox.AppendText($line+[Environment]::NewLine)
  if($script:LogBox.Text.Length -gt 32000){$script:LogBox.Text=$script:LogBox.Text.Substring($script:LogBox.Text.Length-20000)}
  $script:LogBox.ScrollToEnd()
 } else {Write-Host $line}
}
function IsAdmin {
 $p=[Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
 return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
