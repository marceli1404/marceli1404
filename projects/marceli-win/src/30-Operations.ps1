# All commands below are fixed allowlisted actions. No user-supplied shell command execution.
$script:Actions=@(
 @{ID='winupdate';Name='Windows Update';Desc='Open Update settings';Group='Tools';Kind='open';Target='ms-settings:windowsupdate'},
 @{ID='appssettings';Name='Installed apps';Desc='Manage applications';Group='Tools';Kind='open';Target='ms-settings:appsfeatures'},
 @{ID='startupsettings';Name='Startup apps';Desc='Manage automatic start';Group='Tools';Kind='open';Target='ms-settings:startupapps'},
 @{ID='storage';Name='Storage Sense';Desc='Safe space management';Group='Tools';Kind='open';Target='ms-settings:storagesense'},
 @{ID='display';Name='Display';Desc='Resolution and scaling';Group='Tools';Kind='open';Target='ms-settings:display'},
 @{ID='advanceddisplay';Name='Advanced display';Desc='Refresh rate and HDR';Group='Gaming';Kind='open';Target='ms-settings:display-advanced'},
 @{ID='graphics';Name='Graphics settings';Desc='Per-app graphics options';Group='Gaming';Kind='open';Target='ms-settings:display-advancedgraphics'},
 @{ID='gamemodecfg';Name='Game Mode settings';Desc='Native Windows gaming options';Group='Gaming';Kind='open';Target='ms-settings:gaming-gamemode'},
 @{ID='capturecfg';Name='Captures settings';Desc='Review background recording';Group='Gaming';Kind='open';Target='ms-settings:gaming-gamedvr'},
 @{ID='gamebarcfg';Name='Game Bar settings';Desc='Review keyboard and controller shortcuts';Group='Gaming';Kind='open';Target='ms-settings:gaming-gamebar'},
 @{ID='sound';Name='Sound settings';Desc='Devices and audio levels';Group='Gaming';Kind='open';Target='ms-settings:sound'},
 @{ID='mouse';Name='Mouse settings';Desc='Sensitivity, scrolling, primary button';Group='Gaming';Kind='open';Target='ms-settings:mousetouchpad'},
 @{ID='bluetooth';Name='Bluetooth and devices';Desc='Devices and pairing';Group='Tools';Kind='open';Target='ms-settings:bluetooth'},
 @{ID='privacy';Name='Privacy dashboard';Desc='Audit app permissions';Group='Tools';Kind='open';Target='ms-settings:privacy'},
 @{ID='permissions';Name='Background apps';Desc='Manage app privacy where supported';Group='Tools';Kind='open';Target='ms-settings:privacy-backgroundapps'},
 @{ID='developer';Name='Developer settings';Desc='Enable supported developer features';Group='Tools';Kind='open';Target='ms-settings:developers'},
 @{ID='optional';Name='Optional features';Desc='Manage Windows optional features';Group='Tools';Kind='open';Target='ms-settings:optionalfeatures'},
 @{ID='recovery';Name='Recovery settings';Desc='Reset and advanced startup';Group='Tools';Kind='open';Target='ms-settings:recovery'},
 @{ID='networksettings';Name='Network settings';Desc='Manage connections';Group='Network';Kind='open';Target='ms-settings:network'},
 @{ID='wifi';Name='Wi-Fi settings';Desc='Manage Wi-Fi networks';Group='Network';Kind='open';Target='ms-settings:network-wifi'},
 @{ID='proxy';Name='Proxy settings';Desc='Review proxies';Group='Network';Kind='open';Target='ms-settings:network-proxy'},
 @{ID='vpn';Name='VPN settings';Desc='Review VPN connections';Group='Network';Kind='open';Target='ms-settings:network-vpn'},
 @{ID='dns';Name='DNS preferences';Desc='Inspect DNS from network settings';Group='Network';Kind='open';Target='ms-settings:network-ethernet'},
 @{ID='firewall';Name='Windows Firewall';Desc='Inspect firewall settings';Group='Network';Kind='open';Target='windowsdefender://network'},
 @{ID='defender';Name='Windows Security';Desc='Review antivirus and protection';Group='Tools';Kind='open';Target='windowsdefender:'},
 @{ID='sysinfo';Name='System Information';Desc='Full hardware inventory';Group='Tools';Kind='open';Target='msinfo32.exe'},
 @{ID='taskmgr';Name='Task Manager';Desc='Processes and performance';Group='Tools';Kind='open';Target='taskmgr.exe'},
 @{ID='resource';Name='Resource Monitor';Desc='CPU, memory, storage and network';Group='Tools';Kind='open';Target='resmon.exe'},
 @{ID='eventviewer';Name='Event Viewer';Desc='Windows event logs';Group='Tools';Kind='open';Target='eventvwr.msc'},
 @{ID='services';Name='Services';Desc='Inspect service status; no auto-changes';Group='Tools';Kind='open';Target='services.msc'},
 @{ID='device';Name='Device Manager';Desc='Drivers and devices';Group='Tools';Kind='open';Target='devmgmt.msc'},
 @{ID='restoreui';Name='System Restore';Desc='Open restore-point control panel';Group='Tools';Kind='open';Target='SystemPropertiesProtection.exe'},
 @{ID='diskmgmt';Name='Disk Management';Desc='Advanced disk inspection; use with care';Group='Tools';Kind='open';Target='diskmgmt.msc'},
 @{ID='diskcleanup';Name='Disk Cleanup';Desc='Use Microsoft cleanup tool';Group='Tools';Kind='open';Target='cleanmgr.exe'},
 @{ID='regedit';Name='Registry Editor';Desc='Advanced manual changes; use with care';Group='Tools';Kind='open';Target='regedit.exe'},
 @{ID='powershell';Name='PowerShell console';Desc='Open a local PowerShell terminal';Group='Tools';Kind='open';Target='powershell.exe'},
 @{ID='dxdiag';Name='DirectX Diagnostics';Desc='Video and driver diagnostics';Group='Gaming';Kind='open';Target='dxdiag.exe'},
 @{ID='checkhealth';Name='DISM CheckHealth';Desc='Check image corruption flag';Group='Repair';Kind='run';Target='dism.exe';Args=@('/Online','/Cleanup-Image','/CheckHealth');Admin=$true},
 @{ID='scanhealth';Name='DISM ScanHealth';Desc='Scan component store health';Group='Repair';Kind='run';Target='dism.exe';Args=@('/Online','/Cleanup-Image','/ScanHealth');Admin=$true},
 @{ID='restorehealth';Name='DISM RestoreHealth';Desc='Repair Windows component store';Group='Repair';Kind='run';Target='dism.exe';Args=@('/Online','/Cleanup-Image','/RestoreHealth');Admin=$true},
 @{ID='sfc';Name='System File Checker';Desc='Scan and repair protected Windows files';Group='Repair';Kind='run';Target='sfc.exe';Args=@('/scannow');Admin=$true},
 @{ID='chkdsk';Name='Online disk scan';Desc='Read-only disk scan on C:';Group='Repair';Kind='run';Target='chkdsk.exe';Args=@('C:','/scan');Admin=$true},
 @{ID='cleanmgr';Name='Windows Disk Cleanup';Desc='Choose what Windows removes';Group='Repair';Kind='open';Target='cleanmgr.exe'},
 @{ID='reliability';Name='Reliability Monitor';Desc='App crash and error timeline';Group='Repair';Kind='run';Target='perfmon.exe';Args=@('/rel');Admin=$false},
 @{ID='flushdns';Name='Flush DNS resolver';Desc='Clear local DNS cache';Group='Network';Kind='run';Target='ipconfig.exe';Args=@('/flushdns');Admin=$false},
 @{ID='ipinfo';Name='IP configuration';Desc='Show assigned IP and DNS settings';Group='Network';Kind='console';Target='ipconfig.exe';Args=@('/all')},
 @{ID='netstat';Name='Active connections';Desc='Show listening ports and connections';Group='Network';Kind='console';Target='netstat.exe';Args=@('-ano')},
 @{ID='routetable';Name='Routing table';Desc='Inspect local route entries';Group='Network';Kind='console';Target='route.exe';Args=@('print')},
 @{ID='ping';Name='Connectivity ping';Desc='Ping public DNS at 1.1.1.1';Group='Network';Kind='console';Target='ping.exe';Args=@('-n','4','1.1.1.1')},
 @{ID='tracert';Name='Network trace';Desc='Trace path to public DNS';Group='Network';Kind='console';Target='tracert.exe';Args=@('-d','-h','8','-w','700','1.1.1.1')},
 @{ID='wingetupgrade';Name='Update all apps';Desc='WinGet installed package updates';Group='Repair';Kind='run';Target='winget.exe';Args=@('upgrade','--all','--accept-source-agreements','--accept-package-agreements');Admin=$false},
 @{ID='wingetlist';Name='List installed packages';Desc='Inspect WinGet inventory';Group='Repair';Kind='console';Target='winget.exe';Args=@('list')}
)

# Native command execution stays OUTSIDE the WPF dispatcher: launch without -Wait and poll.
# No secondary scripts are downloaded. All executables/arguments are allowlisted above.
$script:CommandQueue=New-Object 'System.Collections.Generic.Queue[object]'
$script:ActiveCommand=$null
$script:CancelAfterCurrent=$false
$script:CommandCompleted=0
$script:CommandTotal=0
$script:QueueTimer=$null

function UpdateQueueView {
 if (!$script:Window) {return}
 $busy=($null -ne $script:ActiveCommand -or $script:CommandQueue.Count -gt 0)
 $banner=El 'QueueBanner'
 $label=El 'QueueStatus'
 $bar=El 'QueueProgress'
 $stop=El 'QueueStop'
 $banner.Visibility=if($busy){'Visible'}else{'Collapsed'}
 $stop.IsEnabled=($script:CommandQueue.Count -gt 0 -or $null -ne $script:ActiveCommand)
 if ($busy) {
  $now=if($script:ActiveCommand){$script:ActiveCommand.Label}else{'Starting'}
  $pending=$script:CommandQueue.Count
  $label.Text=$now+' | '+$pending+' waiting'
  $bar.IsIndeterminate=$false
  $bar.Minimum=0
  $bar.Maximum=[math]::Max(1,$script:CommandTotal)
  $bar.Value=$script:CommandCompleted
  (El 'StatusText').Text='Executing approved commands'
 } else {
  $label.Text='Ready'
  $bar.Value=0
  (El 'StatusText').Text='Ready'
 }
}
function QueueCommand([string]$label,[string]$program,[string[]]$arguments) {
 # All callers construct arguments from hardcoded, trusted catalogue entries.
 if(!$script:Window){throw 'Command queue requires the desktop interface.'}
 if([string]::IsNullOrWhiteSpace($label) -or [string]::IsNullOrWhiteSpace($program)){throw 'Invalid queued command.'}
 $safe=@($arguments)
 $script:CommandQueue.Enqueue([pscustomobject]@{Label=$label;Program=$program;Arguments=$safe})
 $script:CommandTotal++
 Log ('QUEUED: '+$label)
 UpdateQueueView
 StartNextCommand
}
function StartNextCommand {
 if($script:ActiveCommand -or $script:CommandQueue.Count -eq 0){return}
 if($script:CancelAfterCurrent){
  $script:CommandQueue.Clear()
  $script:CancelAfterCurrent=$false
  $script:CommandCompleted=$script:CommandTotal
  UpdateQueueView
  return
 }
 $task=$script:CommandQueue.Dequeue()
 try {
  # -Wait is intentionally NOT supplied: this returns immediately to the WPF event loop.
  # The installer may show its own native UI, including elevation and licence agreements.
  $exe=Get-Command -Name $task.Program -CommandType Application -ErrorAction Stop |
     Select-Object -First 1 -ExpandProperty Source
  $p=Start-Process -FilePath $exe -ArgumentList $task.Arguments -PassThru -ErrorAction Stop
  if(!$p){throw 'Process did not return a handle.'}
  $script:ActiveCommand=[pscustomobject]@{Label=$task.Label;Process=$p;Started=Get-Date}
  if(!$script:QueueTimer.IsEnabled){$script:QueueTimer.Start()}
  Log ('STARTED: '+$task.Label+' (PID '+$p.Id+')')
 } catch {
  Log ('FAILED TO START: '+$task.Label+' - '+$_.Exception.Message)
  $script:CommandCompleted++
  # Defer the next queue item to the timer to avoid recursive process starts.
  if(!$script:QueueTimer.IsEnabled){$script:QueueTimer.Start()}
 }
 UpdateQueueView
}
function PollCommandQueue {
 if($null -ne $script:ActiveCommand){
  $running=$script:ActiveCommand
  try {
   if($running.Process.HasExited){
    $exit=$running.Process.ExitCode
    $seconds=[math]::Round(((Get-Date)-$running.Started).TotalSeconds,1)
    Log ('FINISHED: '+$running.Label+' (exit '+$exit+', '+$seconds+'s)')
    if($exit -ne 0){Log ('WARNING: '+$running.Label+' returned non-zero; inspect the installer output.')}
    $running.Process.Dispose()
    $script:ActiveCommand=$null
    $script:CommandCompleted++
   }
  } catch {
   Log ('Unable to inspect operation: '+$_.Exception.Message)
   try {$running.Process.Dispose()}catch{}
   $script:ActiveCommand=$null
   $script:CommandCompleted++
  }
 }
 if($null -eq $script:ActiveCommand -and $script:CancelAfterCurrent){
  $skipped=$script:CommandQueue.Count
  $script:CommandQueue.Clear()
  $script:CommandCompleted=$script:CommandTotal
  $script:CancelAfterCurrent=$false
  Log ('STOPPED: skipped '+$skipped+' remaining operations. Active installer was not terminated.')
 }
 if($null -eq $script:ActiveCommand -and $script:CommandQueue.Count -gt 0){StartNextCommand}
 if($null -eq $script:ActiveCommand -and $script:CommandQueue.Count -eq 0){
  if($script:QueueTimer.IsEnabled){$script:QueueTimer.Stop()}
  $script:CommandTotal=0;$script:CommandCompleted=0
 }
 UpdateQueueView
}
function RunAction([string]$id) {
 $item=$script:Actions | Where-Object {$_.ID -eq $id} | Select-Object -First 1
 if (!$item) {Log ('Unknown action: '+$id);return}
 if ($item.Kind -eq 'open') {
  try {Start-Process -FilePath $item.Target -ErrorAction Stop;Log ('Opened '+$item.Name)}
  catch {Log ('Could not open '+$item.Name+': '+$_.Exception.Message)}
  return
 }
 $arguments=@($item.Args)
 $command=$item.Target+' '+($arguments -join ' ')
 if ($item.Admin -and !(IsAdmin)) {
  [Windows.MessageBox]::Show('This operation needs an elevated PowerShell session.','Administrator required')|Out-Null
  return
 }
 $answer=[Windows.MessageBox]::Show('Queue this reviewed Windows command?'+[Environment]::NewLine+$command,'Marceli Win - Confirm','YesNo','Question')
 if ($answer -ne 'Yes') {return}
 if ($item.Kind -eq 'console') {
  # Display diagnostics in a separate console; do not execute a string from imported profiles.
  $line='& "'+$item.Target+'" '+($arguments -join ' ')
  try {
   Start-Process 'powershell.exe' -ArgumentList @('-NoProfile','-NoExit','-Command',$line) -ErrorAction Stop|Out-Null
   Log ('Opened diagnostic console: '+$item.Name)
  } catch {Log ('Console failed: '+$_.Exception.Message)}
 } else {QueueCommand $item.Name $item.Target $arguments}
}
function ExportReport {
 $save=New-Object Microsoft.Win32.SaveFileDialog
 $save.Filter='Text report (*.txt)|*.txt';$save.FileName='marceli-win-diagnostics.txt'
 if (!$save.ShowDialog()) {return}
 try {
  $os=Get-CimInstance Win32_OperatingSystem
  $cpu=Get-CimInstance Win32_Processor | Select-Object -First 1
  $gpu=@(Get-CimInstance Win32_VideoController | ForEach-Object {$_.Name}) -join ', '
  $disks=Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object {
    $_.DeviceID+': '+[math]::Round($_.FreeSpace/1GB,1)+' GB free / '+[math]::Round($_.Size/1GB,1)+' GB'
  }
  $adapters= @(Get-NetAdapter -ErrorAction SilentlyContinue | ForEach-Object {$_.Name+': '+$_.Status}) -join [Environment]::NewLine
  $body=@('MARCELI WIN - LOCAL DIAGNOSTICS REPORT','Created: '+(Get-Date).ToString('u'), 'Windows: '+$os.Caption,
    'Build: '+$os.BuildNumber,'CPU: '+$cpu.Name,'GPU: '+$gpu,'RAM: '+[math]::Round($os.TotalVisibleMemorySize/1MB,1)+' GB',
    'System uptime: '+((Get-Date)-$os.LastBootUpTime).ToString(),'Disk volumes:',($disks -join [Environment]::NewLine),
    'Network adapters:',$adapters,'Admin session: '+(IsAdmin),'End report')
  $body | Set-Content -LiteralPath $save.FileName -Encoding UTF8
  Log ('Saved report: '+$save.FileName)
 } catch {Log ('Report failed: '+$_.Exception.Message)}
}
function ExportProfile([string[]]$apps,[string[]]$tweaks) {
 $save=New-Object Microsoft.Win32.SaveFileDialog
 $save.Filter='Marceli profile (*.json)|*.json';$save.FileName='marceli-win-profile.json'
 if (!$save.ShowDialog()) {return}
 $doc=[ordered]@{format='marceli-win-profile';version=1;apps=@($apps);tweaks=@($tweaks)}
 $doc | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $save.FileName -Encoding UTF8
 Log ('Exported selection-only profile: '+$save.FileName)
}
function LoadProfile {
 $open=New-Object Microsoft.Win32.OpenFileDialog
 $open.Filter='Marceli profile (*.json)|*.json'
 if (!$open.ShowDialog()) {return $null}
 try {
  if((Get-Item -LiteralPath $open.FileName -ErrorAction Stop).Length -gt 131072){throw 'Profile is too large.'}
  $p=Get-Content -LiteralPath $open.FileName -Raw -Encoding UTF8 | ConvertFrom-Json
  if ($p.format -ne 'marceli-win-profile' -or $p.version -ne 1) {throw 'Unsupported profile format.'}
  $appIds=@($script:Apps | ForEach-Object {$_.ID})
  $tweakIds=@($script:Tweaks | ForEach-Object {$_.ID})
  $apps=@($p.apps | Where-Object {$appIds -contains $_})
  $tweaks=@($p.tweaks | Where-Object {$tweakIds -contains $_})
  Log ('Loaded selection-only profile: '+$open.FileName)
  return @{Apps=$apps;Tweaks=$tweaks}
 } catch {Log ('Import failed: '+$_.Exception.Message);return $null}
}
function RestoreBackup([switch]$NoPrompt) {
 $pending=PendingRegistryPath
 $isPending=(Test-Path -LiteralPath $pending)
 $source=if($isPending){$pending}else{$script:BackupPath}
 if(!(Test-Path -LiteralPath $source)){Log 'No pending transaction or last-batch backup found.';return}
 try {$records=@(ReadRegistryBackup $source)}
 catch {Log ('Undo blocked; backup failed validation: '+$_.Exception.Message);return}
 $label=if($isPending){'interrupted registry transaction'}else{'latest completed tweak batch'}
 if(!$NoPrompt -and [Windows.MessageBox]::Show(
  'Restore the '+$label+'? This will restore original saved values.'+
  [Environment]::NewLine+'Settings changed by other programs since then may also be affected.',
  'Marceli Win - Recovery','YesNo','Warning') -ne 'Yes'){return}
 try {
  if(RestoreRegistryRecords $records){
   Remove-Item -LiteralPath $source -Force -ErrorAction Stop
   Log ('Recovered '+$label+'. A new tweak batch can now be applied.')
  } else {Log 'Recovery was incomplete; the original backup remains available.'}
 } catch {Log ('Recovery interrupted; backup retained: '+$_.Exception.Message)}
}
function RestoreLast {RestoreBackup}
function MakeRestorePoint {
 if(!(IsAdmin)){
  [Windows.MessageBox]::Show('Open Windows PowerShell as Administrator to request a restore point.','Elevation needed')|Out-Null
  return
 }
 if([Windows.MessageBox]::Show('Request a Windows system restore point? Requires System Protection enabled. Windows may enforce a creation frequency limit.','Marceli Win','YesNo','Question') -ne 'Yes'){return}
 # The command is an audited, literal string, not sourced from profiles or text boxes.
 $command="Checkpoint-Computer -Description 'Marceli Win manual checkpoint' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop"
 $encoded=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
 QueueCommand 'Windows restore point' 'powershell.exe' @('-NoProfile','-NonInteractive','-EncodedCommand',$encoded)
}
