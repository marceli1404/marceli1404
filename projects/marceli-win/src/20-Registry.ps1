# Per-user preference transaction engine.
# The journal is durable BEFORE the first write; a crash leaves it available for recovery.
function PendingRegistryPath { Join-Path $script:Data 'pending-registry-transaction.json' }
function Snapshot($t) {
 if(!$t.Path.StartsWith('HKCU:\',[StringComparison]::OrdinalIgnoreCase)){throw 'Non-user registry paths are not permitted.'}
 $exists=$false;$old=$null;$kind='DWord'
 if(Test-Path $t.Path){
  $key=Get-Item -LiteralPath $t.Path -ErrorAction Stop
  if($key.GetValueNames() -contains $t.Key){
   $exists=$true
   $old=$key.GetValue($t.Key,$null,'DoNotExpandEnvironmentNames')
   $kind=$key.GetValueKind($t.Key).ToString()
  }
 }
 [pscustomobject]@{ID=$t.ID;Path=$t.Path;Key=$t.Key;Exists=$exists;Value=$old;Kind=$kind}
}
function GetChangePlan([string[]]$ids) {
 $changes=@()
 foreach($t in $script:Tweaks){
  if($ids -notcontains $t.ID){continue}
  $snap=Snapshot $t
  $newKind=if($t.ContainsKey('Kind')){$t.Kind}else{'DWord'}
  $unchanged=$snap.Exists -and $snap.Kind -eq $newKind -and [string]$snap.Value -ceq [string]$t.Value
  $changes+=@([pscustomobject]@{Tweak=$t;Before=$snap;Changed=(!$unchanged);DesiredKind=$newKind})
 }
 return $changes
}
function ConfirmRegistryBackup([object[]]$records) {
 if(!$records.Count -or $records.Count -gt @($script:Tweaks).Count){throw 'Invalid backup entry count.'}
 $seen=@{}
 foreach($record in $records){
  if($null -eq $record -or !$record.Path -or !$record.Key){throw 'Incomplete registry backup record.'}
  $matching=@($script:Tweaks|Where-Object {
   $_.Path -eq $record.Path -and $_.Key -eq $record.Key
  })
  if($matching.Count -ne 1){throw ('Backup contains an unrecognised registry key: '+$record.Key)}
  if($record.PSObject.Properties['ID'] -and $record.ID -and $record.ID -ne $matching[0].ID){
   throw ('Backup key ID does not match the trusted catalogue: '+$record.Key)
  }
  if($record.Exists -isnot [bool]){throw ('Invalid saved existence flag: '+$record.Key)}
  if([string]$record.Kind -notin @('DWord','QWord','String','ExpandString','Binary','MultiString')){
   throw ('Unsupported saved registry type: '+$record.Kind)
  }
  $unique=$record.Path+'|'+$record.Key
  if($seen.ContainsKey($unique)){throw ('Duplicate registry backup value: '+$unique)}
  $seen[$unique]=$true
 }
 return $true
}
function ReadRegistryBackup([string]$path) {
 if(!(Test-Path -LiteralPath $path -PathType Leaf)){throw 'Registry backup not found.'}
 $data=Get-Item -LiteralPath $path -ErrorAction Stop
 if($data.Length -gt 1048576){throw 'Unexpectedly large registry backup.'}
 $records=@(Get-Content -LiteralPath $path -Raw -Encoding UTF8 -ErrorAction Stop|ConvertFrom-Json -ErrorAction Stop)
 [void](ConfirmRegistryBackup $records)
 return $records
}
function RestoreRegistryRecords([object[]]$records) {
 # Validate all entries before restoring any. Traverse in reverse write order.
 [void](ConfirmRegistryBackup $records)
 $failed=$false
 for($i=$records.Count-1;$i -ge 0;$i--){
  $r=$records[$i]
  try {
   if($r.Exists){
    New-Item -Path $r.Path -Force -ErrorAction Stop|Out-Null
    New-ItemProperty -Path $r.Path -Name $r.Key -PropertyType $r.Kind -Value $r.Value -Force -ErrorAction Stop|Out-Null
   } elseif(Test-Path $r.Path){
    $key=Get-Item -LiteralPath $r.Path -ErrorAction Stop
    if($key.GetValueNames() -contains $r.Key){
     Remove-ItemProperty -Path $r.Path -Name $r.Key -ErrorAction Stop
    }
   }
   Log ('Restored: '+$r.Key)
  } catch {
   $failed=$true
   Log ('Recovery failed for '+$r.Key+': '+$_.Exception.Message)
  }
 }
 return (!$failed)
}
function SavePendingRegistryRecords([object[]]$records) {
 [void](ConfirmRegistryBackup $records)
 $pending=PendingRegistryPath
 $temporary=$pending+'.tmp'
 ConvertTo-Json -InputObject $records -Depth 6|Set-Content -LiteralPath $temporary -Encoding UTF8 -ErrorAction Stop
 Move-Item -LiteralPath $temporary -Destination $pending -ErrorAction Stop
}
function Apply([string[]]$ids,[bool]$preview=$false) {
 if(!$ids.Count){Log 'Nothing selected.';return}
 $pending=PendingRegistryPath
 if(Test-Path -LiteralPath $pending){
  Log 'An unfinished registry transaction exists. Use Recovery > Undo before applying another batch.'
  return
 }
 try {$plan=@(GetChangePlan $ids)}
 catch {Log ('Failed to inspect current settings: '+$_.Exception.Message);return}
 if(!$plan.Count){Log 'Nothing selected.';return}
 $changes=@($plan|Where-Object {$_.Changed})
 $summary=@($plan|ForEach-Object {
  $old=if($_.Before.Exists){[string]$_.Before.Value+' ('+$_.Before.Kind+')'}else{'Not configured'}
  $new=[string]$_.Tweak.Value+' ('+$_.DesiredKind+')'
  $status=if($_.Changed){'CHANGE'}else{'ALREADY SET'}
  $_.Tweak.Name+': '+$old+' -> '+$new+' ['+$status+']'
 }) -join [Environment]::NewLine
 if($preview -or $WhatIf){Log ('PREVIEW - '+$summary);return}
 if(!$changes.Count){Log 'Selected preferences are already configured. Nothing changed.';return}
 if($script:Window){
  $answer=[Windows.MessageBox]::Show(
   'Review '+$changes.Count+' changes (no-ops are skipped):'+[Environment]::NewLine+$summary+
   [Environment]::NewLine+'Save a recovery journal and apply?','Marceli Win - Review','YesNo','Warning')
  if($answer -ne 'Yes'){Log 'Registry changes cancelled.';return}
 } elseif (!$Yes){
  Write-Host $summary
  if((Read-Host 'Type APPLY to continue') -cne 'APPLY'){Log 'Cancelled';return}
 }
 $backup=@($changes|ForEach-Object {$_.Before})
 try {SavePendingRegistryRecords $backup}
 catch {Log ('Cannot persist recovery journal; no settings applied: '+$_.Exception.Message);return}
 $failed=$false
 foreach($entry in $changes){
  try {
   $t=$entry.Tweak
   New-Item -Path $t.Path -Force -ErrorAction Stop|Out-Null
   New-ItemProperty -Path $t.Path -Name $t.Key -PropertyType $entry.DesiredKind -Value $t.Value -Force -ErrorAction Stop|Out-Null
   Log ('Applied: '+$t.Name)
  } catch {
   Log ('FAILED: '+$entry.Tweak.Name+' - '+$_.Exception.Message)
   $failed=$true
   break
  }
 }
 if($failed){
  Log 'Applying the batch failed. Attempting automatic rollback of the entire batch.'
  # Use the original snapshots; even a failed write may have partially altered its value.
  try {
   if(RestoreRegistryRecords $backup){
    Remove-Item -LiteralPath $pending -Force -ErrorAction Stop
    Log 'Automatic rollback completed; previous undo history retained.'
   } else {Log 'Rollback was incomplete. Recovery journal retained; no further changes allowed.'}
  } catch {Log ('Rollback could not complete; journal preserved: '+$_.Exception.Message)}
  return
 }
 try {
  if(Test-Path -LiteralPath $script:BackupPath){
   $archive=Join-Path $script:Data 'backup-history'
   New-Item -ItemType Directory -Path $archive -Force -ErrorAction Stop|Out-Null
   Copy-Item -LiteralPath $script:BackupPath -Destination (Join-Path $archive ('batch-'+(Get-Date -Format 'yyyyMMdd-HHmmss-fff')+'.json')) -ErrorAction Stop
  }
  # Successful commit: publish the journal as the latest undo snapshot.
  Move-Item -LiteralPath $pending -Destination $script:BackupPath -Force -ErrorAction Stop
  Log 'Batch committed. Latest undo data and historical backups are saved locally.'
 } catch {
  Log ('Preferences were written, but undo finalisation failed: '+$_.Exception.Message)
  Log 'Recovery journal is retained where possible. Review Recovery before applying further changes.'
 }
}
