# Real Windows registry integration tests in disposable HKCU scratch keys only.
# NEVER target production preferences or HKLM.
$ErrorActionPreference='Stop'
$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$run=[guid]::NewGuid().ToString('N')
$reg="HKCU:\Software\MarceliWinTest\$run"
$script:Data=Join-Path $env:TEMP ("MarceliWinRegistryTests-$run")
$script:BackupPath=Join-Path $script:Data 'backup.json'
$script:LogPath=Join-Path $script:Data 'test.log'
$script:Window=$null
$Yes=$true
$WhatIf=$false
$script:Tweaks=@(
 @{ID='test-dword';Name='Test DWORD';Path=$reg;Key='TestDword';Value=1},
 @{ID='test-string';Name='Test String';Path=$reg;Key='TestString';Value='new';Kind='String'}
)
function Log([string]$message){Write-Host ("[test] "+$message)}
function Assert([bool]$condition,[string]$failure){if(!$condition){throw $failure}}
. (Join-Path $root 'src/20-Registry.ps1')
. (Join-Path $root 'src/30-Operations.ps1')
New-Item -ItemType Directory -Path $script:Data -Force|Out-Null
try {
 # Dry-run never creates values or backups.
 Apply @('test-dword') $true
 Assert (!(Test-Path $reg)) 'Preview unexpectedly changed the registry'
 Assert (!(Test-Path $script:BackupPath)) 'Preview unexpectedly saved a backup'

 # A missing value gets a backup that can delete the newly created value.
 $plan=@(GetChangePlan @('test-dword'))
 Assert ($plan.Count -eq 1 -and $plan[0].Changed) 'Initial change plan missing'
 Assert (!$plan[0].Before.Exists) 'Missing value was treated as existing'
 Apply @('test-dword')
 $value=(Get-ItemProperty -Path $reg -Name 'TestDword').TestDword
 Assert ($value -eq 1) 'DWORD was not written'
 Assert (Test-Path $script:BackupPath) 'Backup was not persisted before writing'
 $unchanged=@(GetChangePlan @('test-dword'))
 Assert (!$unchanged[0].Changed) 'No-op preference was not detected'
 RestoreBackup -NoPrompt
 Assert ($null -eq (Get-ItemProperty -Path $reg -Name 'TestDword' -ErrorAction SilentlyContinue)) 'Rollback did not remove newly created value'
 Assert (!(Test-Path $script:BackupPath)) 'Successful undo should consume the latest backup'

 # Restore a genuine, pre-existing REG_SZ rather than writing a DWORD.
 New-Item -Path $reg -Force|Out-Null
 New-ItemProperty -Path $reg -Name 'TestString' -PropertyType String -Value 'old-original' -Force|Out-Null
 $original=Snapshot $script:Tweaks[1]
 Assert ($original.Exists -and $original.Kind -eq 'String') 'Original string type was not preserved'
 Apply @('test-string')
 Assert ((Get-ItemProperty -Path $reg -Name 'TestString').TestString -eq 'new') 'String tweak did not apply'
 RestoreBackup -NoPrompt
 $restored=Snapshot $script:Tweaks[1]
 Assert ($restored.Exists -and $restored.Kind -eq 'String' -and $restored.Value -eq 'old-original') 'String rollback failed'

 # A forged backup must not be able to change an arbitrary registry key.
 $bad=@([pscustomobject]@{ID='forged';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Run';Key='Evil';Exists=$false;Kind='String';Value=$null})
 ConvertTo-Json -InputObject $bad|Set-Content -LiteralPath $script:BackupPath -Encoding UTF8
 RestoreBackup -NoPrompt
 Assert (Test-Path $script:BackupPath) 'Rejected malicious backup should remain for investigation'
 Assert (!$script:Tweaks[0].Path.StartsWith('HKLM')) 'Scratch catalogue should be user-only'

 # Snapshot hard-rejects paths outside the current user.
 $forbidden=@{ID='forbidden';Path='HKLM:\Software\MarceliWinTest';Key='Bad';Value=1}
 $blocked=$false
 try {Snapshot $forbidden|Out-Null} catch {$blocked=$true}
 Assert $blocked 'HKLM snapshot was not blocked'
 Write-Host 'PASS: preview, backup-before-write, no-op detection, DWORD undo, String undo, forged-backup rejection, HKLM rejection'
} finally {
 Remove-Item -Path $reg -Recurse -Force -ErrorAction SilentlyContinue
 Remove-Item -LiteralPath $script:Data -Recurse -Force -ErrorAction SilentlyContinue
}
