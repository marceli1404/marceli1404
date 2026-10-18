function Snapshot($t) {
 # Snapshot ONLY a known per-user registry preference.
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
function Apply([string[]]$ids,[bool]$preview=$false){
 if(!$ids.Count){Log 'Nothing selected.';return}
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
 if(!$changes.Count){Log 'All selected registry preferences already match. Nothing changed.';return}
 if($script:Window){
  $answer=[Windows.MessageBox]::Show(
   'Review '+$changes.Count+' changes (no-op choices are skipped):'+[Environment]::NewLine+$summary+
   [Environment]::NewLine+'Save backup and apply?','Marceli Win - Review','YesNo','Warning')
  if($answer -ne 'Yes'){Log 'Registry changes cancelled.';return}
 } elseif (!$Yes){
  Write-Host $summary
  if((Read-Host 'Type APPLY to continue') -cne 'APPLY'){Log 'Cancelled';return}
 }
 $backup=@($changes|ForEach-Object {$_.Before})
 try {
  $tmp=$script:BackupPath+'.tmp'
  if(Test-Path $script:BackupPath){
   $archive=Join-Path $script:Data 'backup-history'
   New-Item -ItemType Directory -Path $archive -Force|Out-Null
   Copy-Item -LiteralPath $script:BackupPath -Destination (Join-Path $archive ('batch-'+(Get-Date -Format 'yyyyMMdd-HHmmss-fff')+'.json')) -ErrorAction Stop
  }
  ConvertTo-Json -InputObject $backup -Depth 6|Set-Content -LiteralPath $tmp -Encoding UTF8 -ErrorAction Stop
  Move-Item -LiteralPath $tmp -Destination $script:BackupPath -Force -ErrorAction Stop
 } catch {Log ('Backup failed - no settings applied: '+$_.Exception.Message);return}
 foreach($record in $changes){
  $t=$record.Tweak
  try {
   New-Item -Path $t.Path -Force -ErrorAction Stop|Out-Null
   New-ItemProperty -Path $t.Path -Name $t.Key -PropertyType $record.DesiredKind -Value $t.Value -Force -ErrorAction Stop|Out-Null
   Log ('Applied: '+$t.Name)
  } catch {Log ('FAILED: '+$t.Name+' - '+$_.Exception.Message)}
 }
 Log 'Local backup saved. A sign-out or Explorer restart may be needed for some preferences.'
}

