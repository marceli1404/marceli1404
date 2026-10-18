# Marceli Win 0.1 - Copyright (c) 2026 Marceli Pawlinski. MIT.
# Review downloaded scripts before running. No telemetry or secondary code downloads.
param([ValidateSet('','Safe','Balanced','Gaming','Developer','Privacy','Focus','Accessibility')][string]$Preset='', [switch]$WhatIf, [switch]$Yes, [switch]$SmokeTest)
$ErrorActionPreference='Stop'
# Optional CI-only smoke flag exercises the EXACT streamed irm | iex launch path.
if ($env:MARCELI_WIN_SMOKE_TEST -eq '1') { $SmokeTest = $true }
if ($env:OS -ne 'Windows_NT') { throw 'Marceli Win requires Windows.' }
$script:Data=Join-Path $env:LOCALAPPDATA 'MarceliWin'
New-Item -Path $script:Data -ItemType Directory -Force | Out-Null
$script:LogPath=Join-Path $script:Data 'activity.log'
$script:BackupPath=Join-Path $script:Data 'last-registry-backup.json'
$script:LogBox=$null
$script:Window=$null
function Log([string]$message) {
 $line='['+(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')+'] '+$message
 Add-Content -LiteralPath $script:LogPath -Value $line -Encoding UTF8
 if ($script:LogBox) { $script:LogBox.AppendText($line+[Environment]::NewLine);$script:LogBox.ScrollToEnd() } else { Write-Host $line }
}
function IsAdmin {
 $p=[Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
 return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
$script:Apps=@(
 @{ID='Mozilla.Firefox';Name='Firefox';Group='Web'},
 @{ID='Google.Chrome';Name='Google Chrome';Group='Web'},
 @{ID='Brave.Brave';Name='Brave';Group='Web'},
 @{ID='Microsoft.VisualStudioCode';Name='VS Code';Group='Development'},
 @{ID='Git.Git';Name='Git';Group='Development'},
 @{ID='OpenJS.NodeJS.LTS';Name='Node.js LTS';Group='Development'},
 @{ID='Microsoft.WindowsTerminal';Name='Windows Terminal';Group='Development'},
 @{ID='7zip.7zip';Name='7-Zip';Group='Utilities'},
 @{ID='Microsoft.PowerToys';Name='PowerToys';Group='Utilities'},
 @{ID='voidtools.Everything';Name='Everything';Group='Utilities'},
 @{ID='Notepad++.Notepad++';Name='Notepad++';Group='Utilities'},
 @{ID='OBSProject.OBSStudio';Name='OBS Studio';Group='Media'},
 @{ID='VideoLAN.VLC';Name='VLC';Group='Media'},
 @{ID='Valve.Steam';Name='Steam';Group='Gaming'},
 @{ID='Discord.Discord';Name='Discord';Group='Gaming'},
 @{ID='Vivaldi.Vivaldi';Name='Vivaldi';Group='Web'},
 @{ID='Opera.Opera';Name='Opera';Group='Web'},
 @{ID='LibreWolf.LibreWolf';Name='LibreWolf';Group='Web'},
 @{ID='TorProject.TorBrowser';Name='Tor Browser';Group='Web'},
 @{ID='Microsoft.VisualStudio.2022.Community';Name='Visual Studio Community';Group='Development'},
 @{ID='JetBrains.Toolbox';Name='JetBrains Toolbox';Group='Development'},
 @{ID='GitHub.GitHubDesktop';Name='GitHub Desktop';Group='Development'},
 @{ID='Docker.DockerDesktop';Name='Docker Desktop';Group='Development'},
 @{ID='Postman.Postman';Name='Postman';Group='Development'},
 @{ID='Microsoft.PowerShell';Name='PowerShell 7';Group='Development'},
 @{ID='Python.Python.3.12';Name='Python 3.12';Group='Development'},
 @{ID='Microsoft.DotNet.SDK.9';Name=' .NET SDK 9';Group='Development'},
 @{ID='WinSCP.WinSCP';Name='WinSCP';Group='Utilities'},
 @{ID='PuTTY.PuTTY';Name='PuTTY';Group='Utilities'},
 @{ID='Rufus.Rufus';Name='Rufus';Group='Utilities'},
 @{ID='ShareX.ShareX';Name='ShareX';Group='Utilities'},
 @{ID='KeePassXC.KeePassXC';Name='KeePassXC';Group='Utilities'},
 @{ID='Bitwarden.Bitwarden';Name='Bitwarden';Group='Utilities'},
 @{ID='Microsoft.Sysinternals.ProcessExplorer';Name='Process Explorer';Group='Utilities'},
 @{ID='Spotify.Spotify';Name='Spotify';Group='Media'},
 @{ID='Audacity.Audacity';Name='Audacity';Group='Media'},
 @{ID='GIMP.GIMP';Name='GIMP';Group='Media'},
 @{ID='BlenderFoundation.Blender';Name='Blender';Group='Media'},
 @{ID='HandBrake.HandBrake';Name='HandBrake';Group='Media'},
 @{ID='qBittorrent.qBittorrent';Name='qBittorrent';Group='Media'},
 @{ID='KDE.Kdenlive';Name='Kdenlive';Group='Media'},
 @{ID='EpicGames.EpicGamesLauncher';Name='Epic Games Launcher';Group='Gaming'},
 @{ID='GOG.Galaxy';Name='GOG Galaxy';Group='Gaming'},
 @{ID='Blizzard.BattleNet';Name='Battle.net';Group='Gaming'},
 @{ID='Parsec.Parsec';Name='Parsec';Group='Gaming'},
 @{ID='TheDocumentFoundation.LibreOffice';Name='LibreOffice';Group='Productivity'},
 @{ID='Obsidian.Obsidian';Name='Obsidian';Group='Productivity'},
 @{ID='Notion.Notion';Name='Notion';Group='Productivity'},
 @{ID='Zotero.Zotero';Name='Zotero';Group='Productivity'},
 @{ID='Thunderbird.Thunderbird';Name='Thunderbird';Group='Productivity'},
 @{ID='SumatraPDF.SumatraPDF';Name='SumatraPDF';Group='Productivity'},
 @{ID='Telegram.TelegramDesktop';Name='Telegram';Group='Productivity'}
)
$expl='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$theme='HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$script:Tweaks=@(
 @{ID='extensions';Name='Show file extensions';Path=$expl;Key='HideFileExt';Value=0;Info='Displays full file names.'},
 @{ID='hidden';Name='Show hidden files';Path=$expl;Key='Hidden';Value=1;Info='Does not reveal protected OS files.'},
 @{ID='darkapps';Name='Dark app theme';Path=$theme;Key='AppsUseLightTheme';Value=0;Info='Switches Windows apps to dark theme.'},
 @{ID='darkshell';Name='Dark Windows shell';Path=$theme;Key='SystemUsesLightTheme';Value=0;Info='Switches Start and taskbar to dark theme.'},
 @{ID='tips';Name='Reduce suggested content';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager';Key='SubscribedContent-338388Enabled';Value=0;Info='Reduces Windows suggestions when supported.'},
 @{ID='thispc';Name='Explorer opens This PC';Path=$expl;Key='LaunchTo';Value=1;Info='Sets Explorer initial location.'},
 @{ID='seconds';Name='Seconds in taskbar clock';Path=$expl;Key='ShowSecondsInSystemClock';Value=1;Info='May require sign-out.'},
 @{ID='gamemode';Name='Enable Game Mode';Path='HKCU:\Software\Microsoft\GameBar';Key='AutoGameModeEnabled';Value=1;Info='Game Mode without altering drivers or anti-cheat.'},
 @{ID='dvr';Name='Disable background Game DVR';Path='HKCU:\System\GameConfigStore';Key='GameDVR_Enabled';Value=0;Info='Affects background captures. Undo available.'},
 @{ID='taskview';Name='Hide Task View button';Path=$expl;Key='ShowTaskViewButton';Value=0;Group='Desktop';Info='Hide Task View from taskbar.'},
 @{ID='widgets';Name='Hide taskbar widgets';Path=$expl;Key='TaskbarDa';Value=0;Group='Desktop';Info='Hide Widgets button where supported.'},
 @{ID='leftalign';Name='Left-align Start button';Path=$expl;Key='TaskbarAl';Value=0;Group='Desktop';Info='Align Windows 11 taskbar to the left.'},
 @{ID='transparency';Name='Enable transparency';Path=$theme;Key='EnableTransparency';Value=1;Group='Appearance';Info='Enable Windows translucency.'},
 @{ID='noanimations';Name='Reduce taskbar animations';Path=$expl;Key='TaskbarAnimations';Value=0;Group='Accessibility';Info='Turn off taskbar visual animations.'},
 @{ID='adsid';Name='Disable personalised ad ID';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo';Key='Enabled';Value=0;Group='Privacy';Info='Disable per-user advertising identifier.'},
 @{ID='lockspotlight';Name='Disable lock screen rotation';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager';Key='RotatingLockScreenEnabled';Value=0;Group='Privacy';Info='Turn off rotating lock screen backgrounds.'},
 @{ID='suggestapps';Name='Reduce suggested apps';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager';Key='SilentInstalledAppsEnabled';Value=0;Group='Privacy';Info='Reduce suggested app provisioning (limited by Windows edition).'},
 @{ID='tips2';Name='Turn off additional suggestions';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager';Key='SubscribedContent-338389Enabled';Value=0;Group='Privacy';Info='Reduce promotional content in supported versions.'},
 @{ID='searchhighlights';Name='Reduce search highlights';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings';Key='IsDynamicSearchBoxEnabled';Value=0;Group='Privacy';Info='Reduce search highlights when supported.'},
 @{ID='expandnav';Name='Expand Explorer folders';Path=$expl;Key='NavPaneExpandToCurrentFolder';Value=1;Group='Explorer';Info='Expand navigation to selected folder.'},
 @{ID='allfolders';Name='Show all Explorer folders';Path=$expl;Key='NavPaneShowAllFolders';Value=1;Group='Explorer';Info='Show all folders in Explorer navigation.'},
 @{ID='statusbar';Name='Show Explorer status bar';Path=$expl;Key='ShowStatusBar';Value=1;Group='Explorer';Info='Display status information in File Explorer.'},
 @{ID='noconflicts';Name='Show file merge conflicts';Path=$expl;Key='HideMergeConflicts';Value=0;Group='Explorer';Info='Show conflict warnings when copying folders.'},
 @{ID='starttrack';Name='Show frequent apps in Start';Path=$expl;Key='Start_TrackProgs';Value=1;Group='Productivity';Info='Show frequently used apps, if supported.'},
 @{ID='gamebarpopup';Name='Hide Xbox Game Bar popup';Path='HKCU:\Software\Microsoft\GameBar';Key='ShowStartupPanel';Value=0;Group='Gaming';Info='Reduce Game Bar pop-up prompts.'},
 @{ID='autocapture';Name='Turn off automatic capture toggle';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR';Key='AppCaptureEnabled';Value=0;Group='Gaming';Info='Turn off app capture; affects screen recording.'},
 @{ID='mouseaccel';Name='Disable pointer trails toggle';Path='HKCU:\Control Panel\Mouse';Key='MouseTrails';Value='0';Kind='String';Group='Accessibility';Info='Disable pointer trails; do not change sensitivity.'},
 @{ID='explorercompact';Name='Use compact Explorer mode';Path=$expl;Key='UseCompactMode';Value=1;Group='Explorer';Info='Compact File Explorer list spacing.'},
 @{ID='showdrives';Name='Show drive letters';Path=$expl;Key='ShowDriveLettersFirst';Value=4;Group='Explorer';Info='Show drive letters before drive names.'}
)
$script:Presets=@{
 Safe=@('extensions','tips')
 Balanced=@('extensions','tips','darkapps','darkshell','thispc')
 Gaming=@('gamemode','dvr','extensions')
 Developer=@('extensions','hidden','darkapps','darkshell','thispc','seconds','expandnav','statusbar')
 Privacy=@('tips','tips2','adsid','suggestapps','searchhighlights','lockspotlight')
 Focus=@('tips','widgets','taskview','darkapps','darkshell','explorercompact')
 Accessibility=@('extensions','statusbar','noconflicts','noanimations')
}

# Presets describe selections ONLY. Selecting a tile never executes installs or registry actions.
# App IDs must exist in $script:Apps; tweak IDs are the existing reversible presets.
$script:SetupPresets=[ordered]@{
 Safe=@{Apps=@('Mozilla.Firefox','7zip.7zip','Microsoft.PowerToys');Desc='Essential apps and the safest Windows preferences.';Tag='ESSENTIALS'}
 Balanced=@{Apps=@('Mozilla.Firefox','7zip.7zip','Microsoft.PowerToys','VideoLAN.VLC','Notepad++.Notepad++','voidtools.Everything');Desc='A good default for everyday work and browsing.';Tag='EVERYDAY'}
 Gaming=@{Apps=@('Valve.Steam','Discord.Discord','OBSProject.OBSStudio','EpicGames.EpicGamesLauncher','7zip.7zip');Desc='Launchers, capture software and guarded gaming settings.';Tag='PLAY'}
 Developer=@{Apps=@('Microsoft.VisualStudioCode','Git.Git','OpenJS.NodeJS.LTS','Microsoft.WindowsTerminal','Docker.DockerDesktop','Microsoft.PowerShell','Python.Python.3.12','GitHub.GitHubDesktop');Desc='An engineering workstation with build tools and editors.';Tag='BUILD'}
 Privacy=@{Apps=@('Brave.Brave','Bitwarden.Bitwarden','KeePassXC.KeePassXC','Mozilla.Firefox');Desc='Privacy-friendly software and per-user preference controls.';Tag='PRIVATE'}
 Focus=@{Apps=@('Obsidian.Obsidian','Notion.Notion','SumatraPDF.SumatraPDF','Microsoft.PowerToys');Desc='A distraction-light work environment.';Tag='FOCUS'}
 Accessibility=@{Apps=@('Mozilla.Firefox','Microsoft.PowerToys','SumatraPDF.SumatraPDF');Desc='Visibility and usability settings with practical everyday apps.';Tag='COMFORT'}
}
foreach($name in @($script:SetupPresets.Keys)) {
 if (!$script:Presets.ContainsKey($name)) {throw ('Missing tweak preset '+$name)}
 foreach($id in $script:SetupPresets[$name].Apps) {
  if (!(@($script:Apps|Where-Object {$_.ID -eq $id}).Count)) {throw ('Unknown preset app: '+$id)}
 }
}
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
function RestoreLast {
 if(!(Test-Path $script:BackupPath)){Log 'No last-batch registry backup found.';return}
 try {
  $raw=Get-Content -LiteralPath $script:BackupPath -Raw -ErrorAction Stop
  if($raw.Length -gt 1024*1024){throw 'Unexpectedly large backup.'}
  $records=@($raw|ConvertFrom-Json -ErrorAction Stop)
  if(!$records.Count -or $records.Count -gt $script:Tweaks.Count){throw 'Invalid backup entry count.'}
  # Backups are local files that may be edited by other software. Never trust arbitrary paths.
  foreach($record in $records){
   $matching=@($script:Tweaks|Where-Object {
     $_.Path -eq $record.Path -and $_.Key -eq $record.Key
   })
   if($matching.Count -ne 1){throw ('Backup contains an unrecognised registry key: '+$record.Key)}
   if([string]$record.Kind -notin @('DWord','QWord','String','ExpandString','Binary','MultiString')){
    throw ('Unsupported saved registry type: '+$record.Kind)
   }
  }
 } catch {Log ('Undo blocked: '+$_.Exception.Message);return}
 if([Windows.MessageBox]::Show('Undo the latest registry tweak batch? Other apps may have changed these settings since.','Marceli Win','YesNo','Warning') -ne 'Yes'){return}
 $failed=$false
 foreach($r in $records){
  try {
   if($r.Exists){
    New-Item -Path $r.Path -Force -ErrorAction Stop|Out-Null
    New-ItemProperty -Path $r.Path -Name $r.Key -PropertyType $r.Kind -Value $r.Value -Force -ErrorAction Stop|Out-Null
   } elseif(Test-Path $r.Path){
    Remove-ItemProperty -Path $r.Path -Name $r.Key -ErrorAction Stop
   }
   Log ('Restored: '+$r.Key)
  } catch {$failed=$true;Log ('Undo failed: '+$r.Key+' - '+$_.Exception.Message)}
 }
 if(!$failed){Remove-Item -LiteralPath $script:BackupPath -Force;Log 'Last batch successfully undone.'}
 else {Log 'Some items failed. Keeping the backup for another attempt.'}
}
function MakeRestorePoint {
 if(!(IsAdmin)){[Windows.MessageBox]::Show('Open as Administrator to create a restore point.','Elevation needed')|Out-Null;return}
 if([Windows.MessageBox]::Show('Create a Windows system restore point? Requires System Protection enabled.','Marceli Win','YesNo') -ne 'Yes'){return}
 try {Checkpoint-Computer -Description 'Marceli Win manual checkpoint' -RestorePointType 'MODIFY_SETTINGS';Log 'Windows restore point created.'}
 catch {Log ('Restore point unavailable: '+$_.Exception.Message)}
}
if($Preset) { Apply $script:Presets[$Preset];return }
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase
[xml]$ui=@'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
 Title="Marceli Win &#xB7; Preview 0.2" Width="1270" Height="845" MinWidth="1060" MinHeight="700"
 Background="#090E1B" Foreground="#E2E8F0" WindowStartupLocation="CenterScreen" FontFamily="Segoe UI" FontSize="13">
 <Window.Resources>
  <Style x:Key="NavButton" TargetType="Button">
   <Setter Property="Foreground" Value="#9BA9C7"/><Setter Property="Background" Value="Transparent"/>
   <Setter Property="BorderThickness" Value="0"/><Setter Property="Padding" Value="16,12"/>
   <Setter Property="HorizontalContentAlignment" Value="Left"/><Setter Property="Cursor" Value="Hand"/>
   <Setter Property="Margin" Value="11,2"/><Setter Property="FontSize" Value="14"/>
   <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border CornerRadius="11" Background="{TemplateBinding Background}" Padding="{TemplateBinding Padding}"><ContentPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" VerticalAlignment="Center"/></Border></ControlTemplate></Setter.Value></Setter>
   <Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#263451"/><Setter Property="Foreground" Value="#F8FAFC"/></Trigger></Style.Triggers>
  </Style>
  <Style x:Key="ActionButton" TargetType="Button">
   <Setter Property="Background" Value="#273563"/><Setter Property="Foreground" Value="#F1F5F9"/>
   <Setter Property="BorderThickness" Value="0"/><Setter Property="Padding" Value="17,11"/>
   <Setter Property="Margin" Value="4"/><Setter Property="FontSize" Value="13"/>
   <Setter Property="Cursor" Value="Hand"/>
   <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border CornerRadius="11" Background="{TemplateBinding Background}" Padding="{TemplateBinding Padding}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border></ControlTemplate></Setter.Value></Setter>
   <Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#4F46E5"/></Trigger></Style.Triggers>
  </Style>
  <Style x:Key="GlassCard" TargetType="Border"><Setter Property="Background" Value="#202B45"/><Setter Property="CornerRadius" Value="18"/><Setter Property="Padding" Value="18"/><Setter Property="Margin" Value="5"/></Style>
  <Style x:Key="SectionTitle" TargetType="TextBlock"><Setter Property="FontSize" Value="24"/><Setter Property="FontWeight" Value="SemiBold"/><Setter Property="Foreground" Value="#F8FAFC"/></Style>
  <Style TargetType="TextBlock"><Setter Property="Foreground" Value="#E2E8F0"/></Style>
  <Style TargetType="CheckBox"><Setter Property="Foreground" Value="#E2E8F0"/><Setter Property="Margin" Value="7"/></Style>
 </Window.Resources>
 <Grid>
  <Grid.ColumnDefinitions><ColumnDefinition Width="242"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
  <Border Grid.Column="0" Background="#10192C" BorderBrush="#1F304D" BorderThickness="0,0,1,0">
   <DockPanel>
    <StackPanel DockPanel.Dock="Top" Margin="20,29,10,30">
     <StackPanel Orientation="Horizontal"><TextBlock Text="&#x25C8;" Foreground="#A5B4FC" FontSize="35" VerticalAlignment="Center"/><StackPanel Margin="10,0,0,0"><TextBlock Text="MARCELI" FontSize="20" FontWeight="Bold"/><TextBlock Text="WIN / TOOLKIT" Foreground="#A5B4FC" FontSize="11" FontWeight="SemiBold"/></StackPanel></StackPanel>
     <Border Background="#233452" CornerRadius="12" Padding="10,6" HorizontalAlignment="Left" Margin="0,17,0,0"><TextBlock Text="PREVIEW 0.2  &#xB7;  OPEN SOURCE" FontSize="10" Foreground="#BFC8E8"/></Border>
    </StackPanel>
    <StackPanel DockPanel.Dock="Bottom" Margin="16,20">
     <Border Background="#192842" CornerRadius="13" Padding="12"><StackPanel>
      <TextBlock Text="SYSTEM MODE" FontWeight="Bold" Foreground="#A5B4FC" FontSize="10"/>
      <TextBlock Name="AdminStatus" Text="Checking Windows&#x2026;" Margin="0,6,0,0" FontSize="12"/>
      <TextBlock Text="No telemetry &#xB7; local changes" Foreground="#91A3C3" FontSize="10" Margin="0,6,0,0"/>
     </StackPanel></Border>
     <Button Name="MotionToggle" Style="{StaticResource NavButton}" Content="&#x25CC;  Motion: on" Margin="0,12,0,0"/>
    </StackPanel>
    <StackPanel Name="NavList" Margin="0,125,0,0">
     <Button Name="NavHome" Tag="Home" Style="{StaticResource NavButton}" Content="&#x2302;   Overview"/>
     <Button Name="NavApps" Tag="Apps" Style="{StaticResource NavButton}" Content="&#x25A6;   Applications"/>
     <Button Name="NavTweaks" Tag="Tweaks" Style="{StaticResource NavButton}" Content="&#x2726;   Tweaks &amp; privacy"/>
     <Button Name="NavGaming" Tag="Gaming" Style="{StaticResource NavButton}" Content="&#x25C6;   Gaming lab"/>
     <Button Name="NavNetwork" Tag="Network" Style="{StaticResource NavButton}" Content="&#x2301;   Network lab"/>
     <Button Name="NavRepair" Tag="Repair" Style="{StaticResource NavButton}" Content="&#x2692;   Repair centre"/>
     <Button Name="NavTools" Tag="Tools" Style="{StaticResource NavButton}" Content="&#x25A4;   System tools"/>
     <Button Name="NavProfiles" Tag="Profiles" Style="{StaticResource NavButton}" Content="&#x25C8;   Smart profiles"/>
     <Button Name="NavRecovery" Tag="Recovery" Style="{StaticResource NavButton}" Content="&#x21BA;   Recovery"/>
    </StackPanel>
   </DockPanel>
  </Border>
  <Grid Grid.Column="1" ClipToBounds="True">
   <Canvas IsHitTestVisible="False" Opacity="0.36">
    <Ellipse Name="BlurOne" Width="390" Height="390" Canvas.Left="360" Canvas.Top="-170" Fill="#4840BF"><Ellipse.Effect><BlurEffect Radius="95"/></Ellipse.Effect></Ellipse>
    <Ellipse Name="BlurTwo" Width="360" Height="360" Canvas.Left="670" Canvas.Top="260" Fill="#0E8193"><Ellipse.Effect><BlurEffect Radius="100"/></Ellipse.Effect></Ellipse>
    <Path Name="MorphShape" Fill="#4342C6" Opacity=".28" Canvas.Left="300" Canvas.Top="105" Stretch="None" Data="M 80,130 C 40,10 240,0 330,110 C 460,220 130,320 80,130 Z">
     <Path.Effect><BlurEffect Radius="33"/></Path.Effect>
    </Path>
   </Canvas>
   <Grid Margin="28,20,28,18">
    <Grid.RowDefinitions><RowDefinition Height="66"/><RowDefinition Height="188"/><RowDefinition Height="*"/><RowDefinition Height="136"/></Grid.RowDefinitions>
    <Grid Grid.Row="0">
     <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="246"/></Grid.ColumnDefinitions>
     <StackPanel>
      <TextBlock Name="PageHeading" FontSize="27" FontWeight="Bold" Text="Overview" Foreground="White"/>
      <TextBlock Name="PageSubheading" FontSize="12" Foreground="#94A3B8" Text="Personal Windows control center"/>
     </StackPanel>
     <Border Grid.Column="1" Background="#1A2740" BorderBrush="#304361" BorderThickness="1" CornerRadius="13" Height="40" VerticalAlignment="Top">
      <DockPanel Margin="12,6"><TextBlock DockPanel.Dock="Left" Text="&#x2315;" FontSize="20" Margin="0,-2,8,0" Foreground="#B7C1E9"/><TextBox Name="SearchBox" Background="Transparent" BorderThickness="0" Foreground="White" CaretBrush="White" FontSize="13" VerticalContentAlignment="Center" ToolTip="Search apps or tweaks (Ctrl+K)"/></DockPanel>
     </Border>
    </Grid>
    <Border Grid.Row="1" Background="#17243C" BorderBrush="#384A78" BorderThickness="1" CornerRadius="18" Padding="13" Margin="0,0,0,10">
     <Grid>
      <Grid.RowDefinitions><RowDefinition Height="31"/><RowDefinition Height="88"/><RowDefinition Height="*"/></Grid.RowDefinitions>
      <DockPanel Grid.Row="0">
       <TextBlock DockPanel.Dock="Left" Text="YOUR PRESETS" FontSize="16" FontWeight="Bold" Foreground="#E3E9FF"/>
       <TextBlock Text="Select a profile, then customise apps and tweaks. Nothing runs automatically." FontSize="11" Foreground="#9FABCB" VerticalAlignment="Center" HorizontalAlignment="Right"/>
      </DockPanel>
      <ScrollViewer Grid.Row="1" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Disabled" PanningMode="HorizontalOnly">
       <StackPanel Name="PresetRibbon" Orientation="Horizontal" Margin="0,2,0,0"/>
      </ScrollViewer>
      <Grid Grid.Row="2" Margin="3,5,0,0">
       <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
       <TextBlock Name="SelectionCounter" Text="Choose a preset or pick apps and tweaks manually" Foreground="#BCCCF2" VerticalAlignment="Center" FontSize="11" TextTrimming="CharacterEllipsis"/>
       <StackPanel Grid.Column="1" Orientation="Horizontal">
        <Button Name="RibbonApps" Style="{StaticResource ActionButton}" Padding="11,6" Content="Edit apps"/>
        <Button Name="RibbonTweaks" Style="{StaticResource ActionButton}" Padding="11,6" Content="Edit tweaks"/>
        <Button Name="RibbonReview" Style="{StaticResource ActionButton}" Padding="11,6" Background="#4D45A0" Content="Review setup"/>
        <Button Name="RibbonClear" Style="{StaticResource ActionButton}" Padding="11,6" Content="Clear"/>
       </StackPanel>
      </Grid>
     </Grid>
    </Border>
    <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
     <Grid Name="ContentGrid">
      <StackPanel Name="PageHome" Margin="0,8,12,12">
       <Border CornerRadius="22" Padding="26" Background="#30276A" BorderBrush="#5E5AA8" BorderThickness="1" Margin="0,4,0,15">
        <StackPanel><TextBlock Text="WELCOME TO YOUR WINDOWS" Foreground="#BFC9FF" FontSize="11" FontWeight="Bold"/>
         <TextBlock Text="Make your PC feel yours." FontSize="30" FontWeight="Bold" Foreground="White" Margin="0,8,0,4"/>
         <TextBlock Text="One dashboard. Complete visibility. Deliberate changes." FontSize="14" Foreground="#D3D8F0"/>
         <StackPanel Orientation="Horizontal" Margin="0,18,0,0"><Button Name="HomeApps" Style="{StaticResource ActionButton}" Content="Browse apps  &#x2192;"/><Button Name="HomeScan" Style="{StaticResource ActionButton}" Content="System diagnostics  &#x2192;"/><Button Name="HomeReport" Style="{StaticResource ActionButton}" Content="Export report  &#x2197;"/></StackPanel>
        </StackPanel>
       </Border>
       <TextBlock Text="YOUR MACHINE" Style="{StaticResource SectionTitle}" Margin="5,5,0,8"/>
       <Border Style="{StaticResource GlassCard}"><StackPanel><TextBlock Name="SysInfo" TextWrapping="Wrap" LineHeight="28" FontSize="14"/><Button Name="Refresh" Style="{StaticResource ActionButton}" Content="&#x21BB;  Refresh metrics" HorizontalAlignment="Left" Margin="0,14,0,0"/></StackPanel></Border>
       <TextBlock Text="QUICK ACCESS" Style="{StaticResource SectionTitle}" Margin="5,22,0,6"/>
       <WrapPanel Name="QuickPanel"/>
      </StackPanel>
      <StackPanel Name="PageApps" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Find your apps. Install only what you want." Foreground="#9DACCD" FontSize="14" Margin="5,2,0,14"/>
       <Border Style="{StaticResource GlassCard}"><DockPanel>
        <StackPanel DockPanel.Dock="Bottom" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,12,0,0"><Button Name="SelectAllApps" Style="{StaticResource ActionButton}" Content="Select visible"/><Button Name="ClearApps" Style="{StaticResource ActionButton}" Content="Clear"/><Button Name="Install" Style="{StaticResource ActionButton}" Content="Install selected  &#x2192;"/></StackPanel>
        <WrapPanel Name="AppsPanel"/>
       </DockPanel></Border>
       <TextBlock Name="AppCount" Foreground="#9DACCD" Margin="10"/>
      </StackPanel>
      <StackPanel Name="PageTweaks" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Individual settings. Understand them, preview them, undo them." Foreground="#9DACCD" FontSize="14" Margin="5,2,0,14"/>
       <Border Style="{StaticResource GlassCard}"><DockPanel>
        <StackPanel DockPanel.Dock="Bottom" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,14,0,0"><Button Name="Preview" Style="{StaticResource ActionButton}" Content="Preview"/><Button Name="Apply" Style="{StaticResource ActionButton}" Content="Apply selected  &#x2192;"/></StackPanel>
        <WrapPanel Name="TweaksPanel"/>
       </DockPanel></Border>
       <TextBlock Name="TweakCount" Foreground="#9DACCD" Margin="10"/>
      </StackPanel>
      <StackPanel Name="PageGaming" Visibility="Collapsed" Margin="0,8,12,12">
       <Border CornerRadius="18" Background="#26265D" Padding="20" Margin="0,0,0,12"><StackPanel><TextBlock Text="GAME LAB" Foreground="#A5B4FC" FontWeight="Bold"/><TextBlock Text="Gaming, without risky debloat scripts." FontSize="23" FontWeight="Bold" Margin="0,9,0,3"/><TextBlock Text="Game Mode, captures, graphics, HDR, audio and DirectX tools &#x2014; no anti-cheat tampering." Foreground="#B9C3DA" TextWrapping="Wrap"/><Button Name="GamingPreset" Style="{StaticResource ActionButton}" HorizontalAlignment="Left" Content="Preview Gaming profile" Margin="0,15,0,0"/></StackPanel></Border>
       <WrapPanel Name="GamingPanel"/>
      </StackPanel>
      <StackPanel Name="PageNetwork" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Network visibility &amp; troubleshooting" FontSize="21" FontWeight="Bold" Margin="4,0,0,8"/>
       <TextBlock Text="View connections, routes, DNS and adapter settings. Diagnostics use standard Windows tools." Foreground="#A3B2CE" TextWrapping="Wrap" Margin="4,0,0,13"/>
       <WrapPanel Name="NetworkPanel"/>
      </StackPanel>
      <StackPanel Name="PageRepair" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Recovery begins with understanding the issue." FontSize="21" FontWeight="Bold" Margin="4,0,0,8"/>
       <TextBlock Text="DISM, SFC, disk checks, package updates and built-in Windows troubleshooting. System changes require confirmation." Foreground="#A3B2CE" TextWrapping="Wrap" Margin="4,0,0,13"/>
       <WrapPanel Name="RepairPanel"/>
      </StackPanel>
      <StackPanel Name="PageTools" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Native Windows control surfaces" FontSize="21" FontWeight="Bold" Margin="4,0,0,8"/>
       <TextBlock Text="Use familiar Microsoft tools instead of hidden registry hacks." Foreground="#A3B2CE" Margin="4,0,0,13"/>
       <WrapPanel Name="ToolsPanel"/>
      </StackPanel>
      <StackPanel Name="PageProfiles" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Build your own setup." FontSize="24" FontWeight="Bold" Margin="4,0,0,9"/>
       <TextBlock Text="Click any preset in the large bar above, then adjust individual apps and tweaks. Your choices are not executed until you confirm." Foreground="#A4B4D0" FontSize="13" TextWrapping="Wrap" Margin="4,0,8,16"/>
       <Border Background="#242858" CornerRadius="17" Padding="18" Margin="0,0,0,12">
        <StackPanel>
         <TextBlock Name="ProfileName" Text="Custom setup" FontSize="21" Foreground="#E8ECFF" FontWeight="Bold"/>
         <TextBlock Name="ProfileDescription" TextWrapping="Wrap" Foreground="#B2C0E6" Margin="0,4,0,14"/>
         <StackPanel Orientation="Horizontal">
          <Button Name="ProfileEditApps" Style="{StaticResource ActionButton}" Content="Choose apps"/>
          <Button Name="ProfileEditTweaks" Style="{StaticResource ActionButton}" Content="Choose tweaks"/>
          <Button Name="ProfilePreview" Style="{StaticResource ActionButton}" Content="Preview selection"/>
         </StackPanel>
        </StackPanel>
       </Border>
       <Border Style="{StaticResource GlassCard}">
        <StackPanel>
         <TextBlock Name="ProfileCounts" FontSize="17" FontWeight="Bold"/>
         <TextBlock Text="SELECTED APPS" Foreground="#A5B4FC" FontWeight="Bold" Margin="0,14,0,8"/>
         <TextBlock Name="SelectedAppsSummary" Foreground="#CBD5EB" TextWrapping="Wrap"/>
         <TextBlock Text="SELECTED TWEAKS" Foreground="#A5B4FC" FontWeight="Bold" Margin="0,18,0,8"/>
         <TextBlock Name="SelectedTweaksSummary" Foreground="#CBD5EB" TextWrapping="Wrap"/>
        </StackPanel>
       </Border>
       <Border Background="#242A48" CornerRadius="16" Padding="18" Margin="5,13,5,0">
        <StackPanel>
         <TextBlock Text="READY WHEN YOU ARE" Foreground="#B4C2FF" FontWeight="Bold"/>
         <TextBlock Text="These two steps are deliberately separate and each asks for confirmation. Presets never install apps or modify settings by themselves." Foreground="#BECBE2" TextWrapping="Wrap" Margin="0,9,0,13"/>
         <WrapPanel>
          <Button Name="ProfileInstallApps" Style="{StaticResource ActionButton}" Content="Install selected apps"/>
          <Button Name="ProfileApplyTweaks" Style="{StaticResource ActionButton}" Background="#5B51A8" Content="Apply selected tweaks"/>
         </WrapPanel>
        </StackPanel>
       </Border>
      </StackPanel>
      <StackPanel Name="PageRecovery" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Recover, export &amp; inspect." FontSize="21" FontWeight="Bold" Margin="4,0,0,14"/>
       <WrapPanel>
        <Border Style="{StaticResource GlassCard}" Width="330"><StackPanel><TextBlock Text="Undo last tweak batch" FontSize="17" FontWeight="Bold"/><TextBlock Text="Previous registry values are restored. Archived older batches stay local." TextWrapping="Wrap" Foreground="#9FAEC8" Margin="0,8,0,12"/><Button Name="Undo" Style="{StaticResource ActionButton}" Content="&#x21BA;  Undo last batch"/></StackPanel></Border>
        <Border Style="{StaticResource GlassCard}" Width="330"><StackPanel><TextBlock Text="Windows restore point" FontSize="17" FontWeight="Bold"/><TextBlock Text="Ask Windows to create a restore point. Requires admin and System Protection." TextWrapping="Wrap" Foreground="#9FAEC8" Margin="0,8,0,12"/><Button Name="RestorePoint" Style="{StaticResource ActionButton}" Content="&#xFF0B;  Create checkpoint"/></StackPanel></Border>
        <Border Style="{StaticResource GlassCard}" Width="330"><StackPanel><TextBlock Text="Save your setup" FontSize="17" FontWeight="Bold"/><TextBlock Text="Share only the selected apps and tweaks. Import never applies them automatically." TextWrapping="Wrap" Foreground="#9FAEC8" Margin="0,8,0,12"/><StackPanel Orientation="Horizontal"><Button Name="ExportProfile" Style="{StaticResource ActionButton}" Content="Export"/><Button Name="ImportProfile" Style="{StaticResource ActionButton}" Content="Import"/></StackPanel></StackPanel></Border>
        <Border Style="{StaticResource GlassCard}" Width="330"><StackPanel><TextBlock Text="Diagnostics and logs" FontSize="17" FontWeight="Bold"/><TextBlock Text="Export a system summary or inspect local log and archived backups." TextWrapping="Wrap" Foreground="#9FAEC8" Margin="0,8,0,12"/><StackPanel Orientation="Horizontal"><Button Name="ExportReport" Style="{StaticResource ActionButton}" Content="Report"/><Button Name="OpenData" Style="{StaticResource ActionButton}" Content="Data folder"/></StackPanel></StackPanel></Border>
       </WrapPanel>
      </StackPanel>
     </Grid>
    </ScrollViewer>
    <Grid Grid.Row="3" Margin="0,7,0,0">
     <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
     <Border Name="QueueBanner" Grid.Row="0" Background="#252F51" BorderBrush="#55639B" BorderThickness="1" CornerRadius="12" Padding="8" Visibility="Collapsed" Margin="0,0,0,7">
      <Grid>
       <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
       <StackPanel>
        <TextBlock Name="QueueStatus" Text="Ready" Foreground="#E6EDFF" FontSize="11" TextTrimming="CharacterEllipsis"/>
        <ProgressBar Name="QueueProgress" Height="5" Margin="0,5,5,0" Foreground="#9184FE" Background="#17233B" Value="0"/>
       </StackPanel>
       <Button Name="QueueStop" Grid.Column="1" Content="Stop after current" Padding="11,5" Style="{StaticResource ActionButton}" ToolTip="Skips pending commands; never forcibly kills an active installer"/>
      </Grid>
     </Border>
     <Border Grid.Row="1" Background="#131E32" CornerRadius="14" BorderBrush="#2A395A" BorderThickness="1" Padding="13" Margin="0,12,0,0">
     <DockPanel><DockPanel DockPanel.Dock="Top" Margin="2,0,0,8"><TextBlock Text="&#x25CF;  LIVE LOCAL ACTIVITY" FontSize="11" FontWeight="Bold" Foreground="#8FDBDA"/><TextBlock Name="StatusText" Text="Ready" DockPanel.Dock="Right" HorizontalAlignment="Right" Foreground="#8EA1C5" FontSize="11"/></DockPanel>
      <TextBox Name="LogText" Background="#0D1525" Foreground="#C0F2E5" BorderThickness="0" FontFamily="Consolas" FontSize="11" IsReadOnly="True" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"/>
     </DockPanel>
     </Border>
    </Grid>
   </Grid>
  </Grid>
 </Grid>
</Window>
'@
$script:Window=[Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::new($ui))
function El([string]$id) { $script:Window.FindName($id) }
$script:QueueTimer=[Windows.Threading.DispatcherTimer]::new()
$script:QueueTimer.Interval=[TimeSpan]::FromMilliseconds(300)
$script:QueueTimer.Add_Tick({PollCommandQueue})
(El 'QueueStop').Add_Click({
 if($script:ActiveCommand -or $script:CommandQueue.Count -gt 0){
  $script:CancelAfterCurrent=$true
  Log 'Stop requested: pending commands will be skipped after the active installer exits.'
  if(!$script:ActiveCommand){PollCommandQueue}
 }
})
$script:LogBox=El 'LogText'
$script:MotionEnabled=$true
$script:MotionTargets=@()
$script:CurrentPage='Home'
$script:PageNames=@('Home','Apps','Tweaks','Gaming','Network','Repair','Tools','Profiles','Recovery')
$script:Descriptions=@{Home='Your personal Windows command centre';Apps='Browse curated WinGet applications';Tweaks='Reversible Windows preferences';Gaming='Performance and gaming controls';Network='Understand your connections';Repair='Repair with built-in Windows tools';Tools='Everything in one place';Profiles='Safe, focused presets';Recovery='Undo, backup and export'}
function Page([string]$id) {
 if ($script:PageNames -notcontains $id) {return}
 foreach($name in $script:PageNames) {
  $panel=El ('Page'+$name)
  $button=El ('Nav'+$name)
  if($id -eq $name) {
   $panel.Visibility='Visible'
   $button.Background=[Windows.Media.BrushConverter]::new().ConvertFromString('#36356D')
   $button.Foreground=[Windows.Media.Brushes]::White
   if($script:MotionEnabled) {
    $anim=[Windows.Media.Animation.DoubleAnimation]::new()
    $anim.From=0.1;$anim.To=1;$anim.Duration=[Windows.Duration]::new([TimeSpan]::FromMilliseconds(320))
    $panel.BeginAnimation([Windows.UIElement]::OpacityProperty,$anim)
   } else {$panel.Opacity=1}
  } else {
   $panel.Visibility='Collapsed'
   $button.ClearValue([Windows.Controls.Control]::BackgroundProperty)
   $button.ClearValue([Windows.Controls.Control]::ForegroundProperty)
  }
 }
 $script:CurrentPage=$id
 (El 'PageHeading').Text=$id
 (El 'PageSubheading').Text=$script:Descriptions[$id]
}
function AnimateMorph {
 $blob=El 'MorphShape'
 $geometry=[Windows.Media.PathGeometry]::CreateFromGeometry($blob.Data)
 if ($geometry.Figures.Count -lt 1 -or $geometry.Figures[0].Segments.Count -lt 1) { throw 'Morph path has no editable segments.' }
 $blob.Data=$geometry
 $seg=$geometry.Figures[0].Segments[0]
 $point=[Windows.Media.Animation.PointAnimation]::new()
 $point.To=[Windows.Point]::new(25,65)
 $point.Duration=[Windows.Duration]::new([TimeSpan]::FromSeconds(8))
 $point.AutoReverse=$true
 $point.RepeatBehavior=[Windows.Media.Animation.RepeatBehavior]::Forever
 $seg.BeginAnimation([Windows.Media.BezierSegment]::Point1Property,$point)
 $script:MotionTargets+=@($seg)
 foreach($name in @('BlurOne','BlurTwo')) {
  $ellipse=El $name
  $move=[Windows.Media.TranslateTransform]::new()
  $ellipse.RenderTransform=$move
  $a=[Windows.Media.Animation.DoubleAnimation]::new()
  $a.To= if($name -eq 'BlurOne'){85}else{-120}
  $a.Duration=[Windows.Duration]::new([TimeSpan]::FromSeconds(13))
  $a.AutoReverse=$true
  $a.RepeatBehavior=[Windows.Media.Animation.RepeatBehavior]::Forever
  $move.BeginAnimation([Windows.Media.TranslateTransform]::XProperty,$a)
  $script:MotionTargets+=@($move)
 }
}
function StopMorph {
 foreach($v in $script:MotionTargets) {
  if($v -is [Windows.Media.BezierSegment]) {$v.BeginAnimation([Windows.Media.BezierSegment]::Point1Property,$null)}
  elseif($v -is [Windows.Media.TranslateTransform]) {$v.BeginAnimation([Windows.Media.TranslateTransform]::XProperty,$null)}
 }
 $script:MotionTargets=@()
}
if ($SmokeTest) {
 AnimateMorph
 StopMorph
 $script:MotionEnabled=$false
} elseif ([Windows.SystemParameters]::MenuAnimation) {
 try { AnimateMorph } catch { StopMorph; $script:MotionEnabled=$false; Log ('Motion disabled: '+$_.Exception.Message) }
} else { $script:MotionEnabled=$false; (El 'MotionToggle').Content='Motion: off' }
(El 'MotionToggle').Add_Click({
 if($script:MotionEnabled){StopMorph;$script:MotionEnabled=$false;(El 'MotionToggle').Content='Motion  Motion: off'}
 else {AnimateMorph;$script:MotionEnabled=$true;(El 'MotionToggle').Content='Motion  Motion: on'}
})
foreach($name in $script:PageNames) {
 $nav=El ('Nav'+$name)
 $nav.Add_Click({param($sender,$args) Page ([string]$sender.Tag)})
}
Page 'Home'
$script:AppBoxes=@()
$script:TweakBoxes=@()
function NewCard([string]$title,[string]$detail,[string]$tag,[string]$group,[string]$target) {
 $card=[Windows.Controls.Border]::new()
 $card.Background=[Windows.Media.BrushConverter]::new().ConvertFromString('#1B2942')
 $card.BorderBrush=[Windows.Media.BrushConverter]::new().ConvertFromString('#2D4163')
 $card.BorderThickness=[Windows.Thickness]::new(1)
 $card.CornerRadius=[Windows.CornerRadius]::new(12)
 $card.Padding=[Windows.Thickness]::new(12)
 $card.Margin=[Windows.Thickness]::new(5)
 $card.Width=278
 $stack=[Windows.Controls.StackPanel]::new()
 $check=[Windows.Controls.CheckBox]::new()
 $check.Content=$title
 $check.Tag=$tag
 $check.FontWeight='SemiBold'
 $check.ToolTip=$detail
 $caption=[Windows.Controls.TextBlock]::new()
 $caption.Text=$group+'   -   '+$detail
 $caption.Foreground=[Windows.Media.BrushConverter]::new().ConvertFromString('#9CACCC')
 $caption.FontSize=11
 $caption.TextWrapping='Wrap'
 $caption.Margin=[Windows.Thickness]::new(8,4,7,0)
 [void]$stack.Children.Add($check);[void]$stack.Children.Add($caption)
 $card.Child=$stack
 [void](El $target).Children.Add($card)
 return [pscustomobject]@{Box=$card;Check=$check;Search=($title+' '+$group+' '+$detail).ToLowerInvariant()}
}
foreach($a in $script:Apps) {
 $script:AppBoxes+=@(NewCard $a.Name ('WinGet: '+$a.ID) $a.ID $a.Group 'AppsPanel')
}
foreach($t in $script:Tweaks) {
 $group=if($t.ContainsKey('Group')){$t.Group}else{'Windows'}
 $script:TweakBoxes+=@(NewCard $t.Name $t.Info $t.ID $group 'TweaksPanel')
}
function FilterCards {
 $query=(El 'SearchBox').Text.Trim().ToLowerInvariant()
 $appVisible=0;$tweakVisible=0
 foreach($a in $script:AppBoxes) {
  $show=(!$query -or $a.Search.Contains($query))
  $a.Box.Visibility=if($show){'Visible'}else{'Collapsed'}
  if($show){$appVisible++}
 }
 foreach($t in $script:TweakBoxes) {
  $show=(!$query -or $t.Search.Contains($query))
  $t.Box.Visibility=if($show){'Visible'}else{'Collapsed'}
  if($show){$tweakVisible++}
 }
 (El 'AppCount').Text=($appVisible.ToString()+' applications visible')
 (El 'TweakCount').Text=($tweakVisible.ToString()+' tweaks visible')
}
(El 'SearchBox').Add_TextChanged({FilterCards})
FilterCards
function SelectedApps { @($script:AppBoxes|Where-Object {$_.Check.IsChecked -eq $true}|ForEach-Object {[string]$_.Check.Tag}) }
function SelectedTweaks { @($script:TweakBoxes|Where-Object {$_.Check.IsChecked -eq $true}|ForEach-Object {[string]$_.Check.Tag}) }
$script:ChoosingPreset=$false
$script:CurrentPreset='Custom'
$script:PresetTiles=@{}
$script:PresetDescriptions=@{Custom='Create your own mix of apps and Windows preferences. No changes run automatically.'}
foreach($name in @($script:SetupPresets.Keys)) {$script:PresetDescriptions[$name]=$script:SetupPresets[$name].Desc}
function UpdateProfileSummary {
 $apps=@(SelectedApps)
 $tweaks=@(SelectedTweaks)
 $name=$script:CurrentPreset
 (El 'SelectionCounter').Text=($name+'  |  '+$apps.Count+' apps chosen  |  '+$tweaks.Count+' tweaks chosen')
 (El 'ProfileName').Text=($name+' setup')
 (El 'ProfileDescription').Text=$script:PresetDescriptions[$name]
 (El 'ProfileCounts').Text=($apps.Count.ToString()+' applications   /   '+$tweaks.Count.ToString()+' Windows tweaks')
 (El 'SelectedAppsSummary').Text=if($apps.Count){(@($script:Apps|Where-Object {$apps -contains $_.ID}|ForEach-Object {$_.Name}) -join '   |   ')}else{'No apps selected. Choose some from Applications.'}
 (El 'SelectedTweaksSummary').Text=if($tweaks.Count){(@($script:Tweaks|Where-Object {$tweaks -contains $_.ID}|ForEach-Object {$_.Name}) -join '   |   ')}else{'No tweaks selected. Choose some from Tweaks & privacy.'}
 foreach($id in @($script:PresetTiles.Keys)){
  $tile=$script:PresetTiles[$id]
  $tile.Background=[Windows.Media.BrushConverter]::new().ConvertFromString($(if($id -eq $name){'#5045A6'}else{'#202F4D'}))
  $tile.BorderBrush=[Windows.Media.BrushConverter]::new().ConvertFromString($(if($id -eq $name){'#A6A5FF'}else{'#394A6C'}))
 }
}
function SetSetupPreset([string]$name) {
 if($name -eq 'Custom') {
  $script:CurrentPreset='Custom'
  UpdateProfileSummary
  return
 }
 if (!$script:SetupPresets.Contains($name)) {throw ('Unknown setup preset: '+$name)}
 $appIds=@($script:SetupPresets[$name].Apps)
 $tweakIds=@($script:Presets[$name])
 $script:ChoosingPreset=$true
 try {
  foreach($a in $script:AppBoxes){$a.Check.IsChecked=($appIds -contains $a.Check.Tag)}
  foreach($t in $script:TweakBoxes){$t.Check.IsChecked=($tweakIds -contains $t.Check.Tag)}
 } finally {$script:ChoosingPreset=$false}
 $script:CurrentPreset=$name
 UpdateProfileSummary
 Log ('Selected '+$name+' profile ('+$appIds.Count+' apps, '+$tweakIds.Count+' tweaks). Nothing installed or changed.')
}
function NewPresetTile([string]$name,[string]$subtext,[string]$detail) {
 $button=[Windows.Controls.Button]::new()
 $button.Name='Tile'+$name
 $button.Tag=$name
 $button.Background=[Windows.Media.BrushConverter]::new().ConvertFromString('#202F4D')
 $button.Foreground=[Windows.Media.Brushes]::White
 $button.BorderBrush=[Windows.Media.BrushConverter]::new().ConvertFromString('#394A6C')
 $button.BorderThickness=[Windows.Thickness]::new(1)
 $button.Padding=[Windows.Thickness]::new(13,7,13,7)
 $button.Margin=[Windows.Thickness]::new(0,0,9,0)
 $button.Width=143
 $button.Height=70
 $button.Cursor=[Windows.Input.Cursors]::Hand
 $button.ToolTip=$detail
 $stack=[Windows.Controls.StackPanel]::new()
 $main=[Windows.Controls.TextBlock]::new()
 $main.Text=$name;$main.FontSize=15;$main.FontWeight='Bold'
 $secondary=[Windows.Controls.TextBlock]::new()
 $secondary.Text=$subtext;$secondary.Foreground=[Windows.Media.BrushConverter]::new().ConvertFromString('#C2C9ED')
 $secondary.FontSize=11;$secondary.Margin=[Windows.Thickness]::new(0,5,0,0)
 [void]$stack.Children.Add($main);[void]$stack.Children.Add($secondary)
 $button.Content=$stack
 $button.Add_Click({param($sender,$args) SetSetupPreset ([string]$sender.Tag)})
 [void](El 'PresetRibbon').Children.Add($button)
 $script:PresetTiles[$name]=$button
}
foreach($name in @($script:SetupPresets.Keys)) {
 $apps=@($script:SetupPresets[$name].Apps).Count
 $tweaks=@($script:Presets[$name]).Count
 NewPresetTile $name ($apps.ToString()+' apps  /  '+$tweaks.ToString()+' tweaks') $script:SetupPresets[$name].Desc
}
NewPresetTile 'Custom' 'Your own mix' 'Keep your current choices and customise freely.'
foreach($item in @($script:AppBoxes)+@($script:TweakBoxes)) {
 $item.Check.Add_Checked({
  if(!$script:ChoosingPreset){$script:CurrentPreset='Custom';UpdateProfileSummary}
 })
 $item.Check.Add_Unchecked({
  if(!$script:ChoosingPreset){$script:CurrentPreset='Custom';UpdateProfileSummary}
 })
}
UpdateProfileSummary
(El 'RibbonApps').Add_Click({Page 'Apps'})
(El 'RibbonTweaks').Add_Click({Page 'Tweaks'})
(El 'RibbonReview').Add_Click({Page 'Profiles'})
(El 'RibbonClear').Add_Click({
 $script:ChoosingPreset=$true
 try {
  foreach($a in $script:AppBoxes){$a.Check.IsChecked=$false}
  foreach($t in $script:TweakBoxes){$t.Check.IsChecked=$false}
 } finally {$script:ChoosingPreset=$false}
 $script:CurrentPreset='Custom'
 UpdateProfileSummary
 Log 'Cleared app and tweak selections. No system settings were changed.'
})
(El 'SelectAllApps').Add_Click({foreach($a in $script:AppBoxes){if($a.Box.Visibility -eq 'Visible'){$a.Check.IsChecked=$true}}})
(El 'ClearApps').Add_Click({foreach($a in $script:AppBoxes){$a.Check.IsChecked=$false}})
(El 'Preview').Add_Click({Apply (SelectedTweaks) $true})
(El 'Apply').Add_Click({Apply (SelectedTweaks)})
function InstallSelectedApps {
 $wanted=@(SelectedApps)
 $apps=@($script:Apps|Where-Object {$wanted -contains $_.ID})
 if(!$apps.Count){Log 'Select apps first.';return}
 if(!(Get-Command winget.exe -CommandType Application -ErrorAction SilentlyContinue)){
  Log 'WinGet is not installed or not in PATH. Install Microsoft App Installer first.'
  return
 }
 $message='Queue '+$apps.Count+' exact packages from the WinGet community source?'+[Environment]::NewLine+
  ($apps.Name -join ', ')+[Environment]::NewLine+
  'Installers may prompt separately for licence terms and elevation. Cancel pending tasks from the activity panel.'
 if([Windows.MessageBox]::Show($message,'Marceli Win - Confirm install','YesNo','Question') -ne 'Yes'){return}
 foreach($app in $apps){
  # Hardcoded package IDs only; exact match and source restriction avoid ambiguous installs.
  $args=@('install','--id',[string]$app.ID,'--exact','--source','winget','--accept-source-agreements')
  QueueCommand ('Install '+$app.Name) 'winget.exe' $args
 }
}
(El 'Install').Add_Click({InstallSelectedApps})
(El 'ProfileEditApps').Add_Click({Page 'Apps'})
(El 'ProfileEditTweaks').Add_Click({Page 'Tweaks'})
(El 'ProfileInstallApps').Add_Click({InstallSelectedApps})
(El 'ProfileApplyTweaks').Add_Click({Apply (SelectedTweaks)})
(El 'ProfilePreview').Add_Click({
 $apps=@(SelectedApps);$tweaks=@(SelectedTweaks)
 Log ('PREVIEW '+$script:CurrentPreset+' profile: '+$apps.Count+' apps + '+$tweaks.Count+' tweaks. No changes were made.')
 if($apps.Count){Log ('APPS: '+(@($script:Apps|Where-Object {$apps -contains $_.ID}|ForEach-Object {$_.Name}) -join ', '))}
 if($tweaks.Count){Apply $tweaks $true}
})
(El 'GamingPreset').Add_Click({SetSetupPreset 'Gaming';Page 'Profiles'})
function NewActionCard($act,[string]$target) {
 $border=[Windows.Controls.Border]::new()
 $border.Background=[Windows.Media.BrushConverter]::new().ConvertFromString('#1B2942')
 $border.BorderBrush=[Windows.Media.BrushConverter]::new().ConvertFromString('#2E4165')
 $border.BorderThickness=[Windows.Thickness]::new(1)
 $border.CornerRadius=[Windows.CornerRadius]::new(14)
 $border.Padding=[Windows.Thickness]::new(12)
 $border.Margin=[Windows.Thickness]::new(5)
 $border.Width=275
 $stack=[Windows.Controls.StackPanel]::new()
 $heading=[Windows.Controls.TextBlock]::new()
 $heading.Text=$act.Name;$heading.FontWeight='SemiBold';$heading.FontSize=14
 $desc=[Windows.Controls.TextBlock]::new()
 $desc.Text=$act.Desc
 $desc.Foreground=[Windows.Media.BrushConverter]::new().ConvertFromString('#9EAFCE')
 $desc.Margin=[Windows.Thickness]::new(0,7,0,10);$desc.TextWrapping='Wrap'
 $button=[Windows.Controls.Button]::new()
 $button.Content=if($act.Kind -eq 'open'){'Open  (open)'}else{'Review & run  > '}
 $button.Tag=$act.ID
 $button.Style=$script:Window.FindResource('ActionButton')
 $button.HorizontalAlignment='Left'
 $button.Add_Click({param($sender,$args) RunAction ([string]$sender.Tag)})
 [void]$stack.Children.Add($heading);[void]$stack.Children.Add($desc);[void]$stack.Children.Add($button)
 $border.Child=$stack
 [void](El $target).Children.Add($border)
}
foreach($act in $script:Actions) {NewActionCard $act ($act.Group+'Panel')}
foreach($id in @('taskmgr','winupdate','resource','storage')) {
 $action=$script:Actions|Where-Object {$_.ID -eq $id}|Select-Object -First 1
 if($action){NewActionCard $action 'QuickPanel'}
}
function RefreshSystem {
 try {
  $os=Get-CimInstance Win32_OperatingSystem
  $cpu=Get-CimInstance Win32_Processor|Select-Object -First 1
  $gpu=Get-CimInstance Win32_VideoController|Select-Object -First 1
  $drive=Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
  $memory=[math]::Round($os.TotalVisibleMemorySize/1MB,1)
  $free=if($drive){[math]::Round($drive.FreeSpace/1GB,1).ToString()+' GB'}else{'N/A'}
  (El 'SysInfo').Text='WINDOWS   '+$os.Caption+'  -  Build '+$os.BuildNumber+[Environment]::NewLine+
   'PROCESSOR   '+$cpu.Name+[Environment]::NewLine+
   'GRAPHICS   '+$gpu.Name+[Environment]::NewLine+
   'MEMORY   '+$memory+' GB    -    DISK C: FREE   '+$free+[Environment]::NewLine+
   'UPTIME   '+((Get-Date)-$os.LastBootUpTime).ToString('dd\.hh\:mm')+[Environment]::NewLine+
   'ADMINISTRATOR   '+(IsAdmin)
  (El 'AdminStatus').Text=if(IsAdmin){'Elevated mode'}else{'Standard user'}
 } catch {Log ('Metrics unavailable: '+$_.Exception.Message)}
}
(El 'Refresh').Add_Click({RefreshSystem})
(El 'HomeApps').Add_Click({Page 'Apps'})
(El 'HomeScan').Add_Click({Page 'Repair'})
(El 'HomeReport').Add_Click({ExportReport})
(El 'Undo').Add_Click({RestoreLast})
(El 'RestorePoint').Add_Click({MakeRestorePoint})
(El 'ExportProfile').Add_Click({ExportProfile (SelectedApps) (SelectedTweaks)})
(El 'ImportProfile').Add_Click({
 $p=LoadProfile
 if($null -eq $p){return}
 foreach($a in $script:AppBoxes){$a.Check.IsChecked=($p.Apps -contains $a.Check.Tag)}
 foreach($t in $script:TweakBoxes){$t.Check.IsChecked=($p.Tweaks -contains $t.Check.Tag)}
 $script:CurrentPreset='Custom'
 UpdateProfileSummary
 Page 'Profiles'
 Log 'Selections restored. Nothing applied automatically.'
})
(El 'ExportReport').Add_Click({ExportReport})
(El 'OpenData').Add_Click({Start-Process 'explorer.exe' -ArgumentList $script:Data})
$script:Window.Add_PreviewKeyDown({
 param($sender,$e)
 if($e.Key -eq 'K' -and ([Windows.Input.Keyboard]::Modifiers -band [Windows.Input.ModifierKeys]::Control)){
  (El 'SearchBox').Focus()|Out-Null
  if($script:CurrentPage -notin @('Apps','Tweaks')){Page 'Apps'}
  $e.Handled=$true
 }
 if($e.Key -eq 'Escape') {(El 'SearchBox').Text=''}
})
RefreshSystem
Log ('Marceli Win preview ready  -  '+$script:Apps.Count+' app entries  -  '+$script:Tweaks.Count+' tweaks  -  '+$script:Actions.Count+' system tools. No changes made.')
if($SmokeTest) {
 foreach($name in $script:PageNames) {if(!(El ('Page'+$name))){throw ('Missing page '+$name)}}
 foreach($name in @($script:SetupPresets.Keys)){
  SetSetupPreset $name
  if(@(SelectedApps).Count -ne @($script:SetupPresets[$name].Apps).Count){throw ('App preset selection mismatch: '+$name)}
  if(@(SelectedTweaks).Count -ne @($script:Presets[$name]).Count){throw ('Tweak preset selection mismatch: '+$name)}
 }
 SetSetupPreset 'Developer'
 $script:AppBoxes[0].Check.IsChecked=!$script:AppBoxes[0].Check.IsChecked
 if($script:CurrentPreset -ne 'Custom'){throw 'Manual selection must switch to Custom profile'}
 if($script:PresetTiles.Count -ne 8){throw 'Preset bar is missing a preset tile'}
 StopMorph
 Write-Host 'GUI smoke test passed: WPF navigation, 8 preset bar tiles, app/tweak selection, and customisation.'
 $script:Window.Close()
 return
}
[void]$script:Window.ShowDialog()
