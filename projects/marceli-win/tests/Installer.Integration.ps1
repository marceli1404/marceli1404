# Windows-only silent install/uninstall acceptance in an ephemeral GitHub runner.
[CmdletBinding()]
param([Parameter(Mandatory)][string]$InstallerPath,[Parameter(Mandatory)][string]$ExpectedScriptPath)
$ErrorActionPreference='Stop'
$full=(Resolve-Path $InstallerPath).Path
$expected=(Resolve-Path $ExpectedScriptPath).Path
$target=Join-Path $env:LOCALAPPDATA 'Programs\MarceliWin'
$appData=Join-Path $env:LOCALAPPDATA 'MarceliWin'
New-Item -ItemType Directory -Path $appData -Force|Out-Null
$sentinel=Join-Path $appData 'preserve-undo-ci-test.txt'
Set-Content -LiteralPath $sentinel 'Uninstaller must never delete registry backups or activity logs'
try {
 $install=Start-Process -FilePath $full -ArgumentList '/S' -Wait -PassThru
 if($install.ExitCode -ne 0){throw ('Silent install failed: '+$install.ExitCode)}
 foreach($name in @('MarceliWin.ps1','launcher.cmd','LICENSE','INSTALLATION.txt','Check-Update.ps1','Test-ReleaseIntegrity.ps1','Uninstall.exe')){
  if(!(Test-Path (Join-Path $target $name))){throw ('Missing installed resource: '+$name)}
 }
 $shortcut=Join-Path ([Environment]::GetFolderPath('Programs')) 'Marceli Win\Marceli Win.lnk'
 if(!(Test-Path $shortcut)){throw 'Start Menu shortcut was not created.'}
 if(!(Test-Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\MarceliWin')){throw 'App registration missing.'}
 if((Get-FileHash -LiteralPath $expected -Algorithm SHA256).Hash -ne
    (Get-FileHash -LiteralPath (Join-Path $target 'MarceliWin.ps1') -Algorithm SHA256).Hash){
  throw 'The installed script does not match the packaged script.'
 }
 # Exercise the in-place upgrade path, not just a clean installation.
 # Simulate an outdated installed payload then ensure the new setup replaces it.
 Add-Content -LiteralPath (Join-Path $target 'MarceliWin.ps1') -Value '#stale-installed-payload' -Encoding UTF8
 $upgrade=Start-Process -FilePath $full -ArgumentList '/S' -Wait -PassThru
 if($upgrade.ExitCode -ne 0){throw ('In-place upgrade failed: '+$upgrade.ExitCode)}
 if((Get-FileHash -LiteralPath $expected -Algorithm SHA256).Hash -ne
    (Get-FileHash -LiteralPath (Join-Path $target 'MarceliWin.ps1') -Algorithm SHA256).Hash){
  throw 'In-place upgrade did not restore the published script contents.'
 }
 if(!(Test-Path $sentinel)){throw 'Upgrade destroyed persistent recovery data.'}
 $uninstall=Start-Process -FilePath (Join-Path $target 'Uninstall.exe') -ArgumentList '/S' -Wait -PassThru
 if($uninstall.ExitCode -ne 0){throw ('Silent uninstall failed: '+$uninstall.ExitCode)}
 if(Test-Path (Join-Path $target 'MarceliWin.ps1')){throw 'The installed application survived uninstall.'}
 if(Test-Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\MarceliWin'){throw 'Uninstall registration was not deleted.'}
 if(!(Test-Path $sentinel)){throw 'User recovery data was improperly erased.'}
 Write-Host 'PASS: install, in-place upgrade, shortcuts, script hash, uninstall and recovery-data preservation.'
} finally {
 Remove-Item -LiteralPath $sentinel -Force -ErrorAction SilentlyContinue
}
