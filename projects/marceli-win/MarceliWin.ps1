# Marceli Win 0.1 - Copyright (c) 2026 Marceli Pawlinski. MIT.
# Review downloaded scripts before running. No telemetry or secondary code downloads.
param([ValidateSet('','Safe','Balanced','Gaming','Developer')][string]$Preset='', [switch]$WhatIf, [switch]$Yes)
$ErrorActionPreference='Stop'
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
 @{ID='Discord.Discord';Name='Discord';Group='Gaming'}
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
 @{ID='dvr';Name='Disable background Game DVR';Path='HKCU:\System\GameConfigStore';Key='GameDVR_Enabled';Value=0;Info='Affects background captures. Undo available.'}
)
$script:Presets=@{
 Safe=@('extensions','tips')
 Balanced=@('extensions','tips','darkapps','darkshell','thispc')
 Gaming=@('gamemode','dvr','extensions')
 Developer=@('extensions','hidden','darkapps','darkshell','thispc','seconds')
}
function Snapshot($t) {
 $exists=$false;$old=$null;$kind='DWord'
 if (Test-Path $t.Path) {
  $rk=Get-Item -Path $t.Path
  if ($rk.GetValueNames() -contains $t.Key) {
   $exists=$true;$old=$rk.GetValue($t.Key);$kind=$rk.GetValueKind($t.Key).ToString()
  }
 }
 [pscustomobject]@{Path=$t.Path;Key=$t.Key;Exists=$exists;Value=$old;Kind=$kind}
}
function Apply([string[]]$ids,[bool]$preview=$false) {
 $chosen=@($script:Tweaks | Where-Object { $ids -contains $_.ID })
 if (!$chosen.Count) { Log 'Nothing selected.';return }
 $summary=($chosen | ForEach-Object { $_.Name+' - '+$_.Info }) -join [Environment]::NewLine
 if ($preview -or $WhatIf) { Log ('PREVIEW: '+$summary);return }
 if ($script:Window) {
  $choice=[Windows.MessageBox]::Show($summary+[Environment]::NewLine+'Apply these changes?','Marceli Win','YesNo','Warning')
  if ($choice -ne 'Yes') { Log 'Cancelled';return }
 } elseif (!$Yes) {
  Write-Host $summary
  if ((Read-Host 'Type APPLY to continue') -cne 'APPLY') { Log 'Cancelled';return }
 }
 $backup=@($chosen | ForEach-Object { Snapshot $_ })
 $tmp=$script:BackupPath+'.tmp'
 ConvertTo-Json -InputObject $backup -Depth 6 | Set-Content -LiteralPath $tmp -Encoding UTF8
 Move-Item -LiteralPath $tmp -Destination $script:BackupPath -Force
 foreach($t in $chosen) {
  try {
   New-Item -Path $t.Path -Force | Out-Null
   New-ItemProperty -Path $t.Path -Name $t.Key -PropertyType DWord -Value $t.Value -Force | Out-Null
   Log ('Applied: '+$t.Name)
  } catch { Log ('FAILED: '+$t.Name+' - '+$_.Exception.Message) }
 }
 Log 'Saved last-batch undo data locally. Some settings may require sign-out.'
}
if($Preset) { Apply $script:Presets[$Preset];return }
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase
[xml]$ui=@'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
 Title="Marceli Win" Width="1040" Height="755" Background="#0A1020" Foreground="#E2E8F0"
 WindowStartupLocation="CenterScreen" FontFamily="Segoe UI" FontSize="14">
 <Window.Resources>
  <Style TargetType="Button"><Setter Property="Margin" Value="5"/><Setter Property="Padding" Value="14,10"/><Setter Property="Background" Value="#4338CA"/><Setter Property="Foreground" Value="White"/><Setter Property="BorderThickness" Value="0"/></Style>
  <Style TargetType="CheckBox"><Setter Property="Margin" Value="8"/><Setter Property="Foreground" Value="#E2E8F0"/></Style>
  <Style TargetType="TextBlock"><Setter Property="Foreground" Value="#E2E8F0"/></Style>
  <Style TargetType="TabItem"><Setter Property="Padding" Value="14,10"/></Style>
 </Window.Resources>
 <Grid Margin="22">
  <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="160"/></Grid.RowDefinitions>
  <Border Padding="22" CornerRadius="14" Background="#17213A" Margin="0,0,0,14">
   <StackPanel>
    <TextBlock Text="◈  MARCELI WIN" FontSize="27" FontWeight="Bold" Foreground="#A5B4FC"/>
    <TextBlock Text="Your Windows, your choices. No telemetry. Changes only on confirmation." Foreground="#94A3B8" Margin="0,5,0,0"/>
   </StackPanel>
  </Border>
  <TabControl Grid.Row="1" Background="#121B30" BorderBrush="#334155">
   <TabItem Header="Overview"><StackPanel Margin="22"><TextBlock Text="SYSTEM OVERVIEW" FontSize="21" FontWeight="Bold"/><TextBlock Name="SysInfo" TextWrapping="Wrap" Margin="0,24,0,18" LineHeight="30"/><Button Name="Refresh" Content="Refresh details" Width="170" HorizontalAlignment="Left"/></StackPanel></TabItem>
   <TabItem Header="Apps"><DockPanel Margin="18"><Button Name="Install" Content="Install selected via WinGet" DockPanel.Dock="Bottom" HorizontalAlignment="Right"/><ScrollViewer><StackPanel><TextBlock Text="INSTALL APPLICATIONS" FontSize="21" FontWeight="Bold"/><TextBlock Text="Curated official WinGet package IDs. You choose what gets installed." Margin="0,7,0,18"/><WrapPanel Name="AppsPanel"/></StackPanel></ScrollViewer></DockPanel></TabItem>
   <TabItem Header="Tweaks"><DockPanel Margin="18"><StackPanel DockPanel.Dock="Bottom" Orientation="Horizontal" HorizontalAlignment="Right"><Button Name="Preview" Content="Preview"/><Button Name="Apply" Content="Apply selected"/></StackPanel><ScrollViewer><StackPanel><TextBlock Text="REVERSIBLE PREFERENCES" FontSize="21" FontWeight="Bold"/><TextBlock Text="User-level registry settings only. Latest batch can be undone." Margin="0,7,0,18"/><WrapPanel Name="TweaksPanel"/></StackPanel></ScrollViewer></DockPanel></TabItem>
   <TabItem Header="Repair"><ScrollViewer><StackPanel Margin="22"><TextBlock Text="WINDOWS DIAGNOSTICS" FontSize="21" FontWeight="Bold"/><TextBlock Text="Confirm each command. Admin rights required for system repair." Margin="0,8,0,22"/><WrapPanel><Button Name="Disk" Content="Scan C: disk"/><Button Name="Scan" Content="DISM scan"/><Button Name="Repair" Content="DISM repair"/><Button Name="SFC" Content="SFC scan"/><Button Name="DNS" Content="Flush DNS cache"/><Button Name="Updates" Content="Windows Update settings"/><Button Name="Upgrades" Content="Upgrade apps (WinGet)"/></WrapPanel></StackPanel></ScrollViewer></TabItem>
   <TabItem Header="Presets"><StackPanel Margin="22"><TextBlock Text="QUICK PROFILES" FontSize="21" FontWeight="Bold"/><TextBlock Text="Safe • Balanced • Gaming • Developer" Margin="0,10,0,22"/><ComboBox Name="Preset" Width="220" HorizontalAlignment="Left" SelectedIndex="0"><ComboBoxItem Content="Safe"/><ComboBoxItem Content="Balanced"/><ComboBoxItem Content="Gaming"/><ComboBoxItem Content="Developer"/></ComboBox><StackPanel Orientation="Horizontal" Margin="0,18,0,0"><Button Name="PreviewPreset" Content="Preview preset"/><Button Name="ApplyPreset" Content="Apply preset"/></StackPanel></StackPanel></TabItem>
   <TabItem Header="Recovery"><StackPanel Margin="22"><TextBlock Text="RECOVERY &amp; PRIVACY" FontSize="21" FontWeight="Bold"/><TextBlock Text="Undo the last registry change batch. Data and logs remain on your device." TextWrapping="Wrap" Margin="0,12,0,22"/><WrapPanel><Button Name="Undo" Content="Undo last batch"/><Button Name="OpenData" Content="Open data folder"/><Button Name="CopySystem" Content="Copy system details"/></WrapPanel></StackPanel></TabItem>
  </TabControl>
  <Border Grid.Row="2" CornerRadius="10" Background="#17213A" Padding="14" Margin="0,14,0,0">
   <DockPanel><TextBlock Text="ACTIVITY LOG (LOCAL)" DockPanel.Dock="Top" Foreground="#A5B4FC" FontWeight="Bold" FontSize="12" Margin="4,0,0,8"/>
   <TextBox Name="LogText" IsReadOnly="True" Background="#0A1020" Foreground="#A5F3FC" FontFamily="Consolas" FontSize="11" BorderThickness="0" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/></DockPanel>
  </Border>
 </Grid>
</Window>
'@
$script:Window=[Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::new($ui))
function El([string]$id) { $script:Window.FindName($id) }
$script:LogBox=El 'LogText'
$system=El 'SysInfo'
function RefreshSystem {
 try {
  $o=Get-CimInstance Win32_OperatingSystem
  $c=Get-CimInstance Win32_Processor | Select-Object -First 1
  $gb=[Math]::Round($o.TotalVisibleMemorySize/1MB,1)
  $system.Text=$o.Caption+'  |  Build '+$o.BuildNumber+[Environment]::NewLine+'CPU: '+$c.Name+[Environment]::NewLine+'Memory: '+$gb+' GB  |  Administrator: '+(IsAdmin)+[Environment]::NewLine+'Backups and logs: '+$script:Data
 } catch { $system.Text=$_.Exception.Message }
}
RefreshSystem
(El 'Refresh').Add_Click({RefreshSystem})
$appBoxes=@();foreach($a in $script:Apps) {
 $box=[Windows.Controls.CheckBox]::new();$box.Content=$a.Name+'  ['+$a.Group+']';$box.Tag=$a.ID;$box.Width=245
 [void](El 'AppsPanel').Children.Add($box);$appBoxes+= $box
}
$tweakBoxes=@();foreach($t in $script:Tweaks) {
 $box=[Windows.Controls.CheckBox]::new();$box.Content=$t.Name;$box.Tag=$t.ID;$box.ToolTip=$t.Info;$box.Width=320
 [void](El 'TweaksPanel').Children.Add($box);$tweakBoxes+= $box
}
function SelectedTweaks { @($tweakBoxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { [string]$_.Tag }) }
(El 'Preview').Add_Click({Apply (SelectedTweaks) $true})
(El 'Apply').Add_Click({Apply (SelectedTweaks)})
function SelectedPreset { [string](El 'Preset').SelectedItem.Content }
(El 'PreviewPreset').Add_Click({Apply $script:Presets[(SelectedPreset)] $true})
(El 'ApplyPreset').Add_Click({Apply $script:Presets[(SelectedPreset)]})
(El 'Install').Add_Click({
 $wanted=@($appBoxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { [string]$_.Tag })
 $apps=@($script:Apps | Where-Object { $wanted -contains $_.ID })
 if (!$apps.Count) {Log 'Select applications first.';return}
 if (!(Get-Command winget.exe -ErrorAction SilentlyContinue)) {Log 'WinGet is not available.';return}
 if ([Windows.MessageBox]::Show('Install via WinGet: '+(($apps|ForEach-Object {$_.Name}) -join ', ')+'?','Marceli Win','YesNo') -ne 'Yes') {return}
 foreach($a in $apps) {
  Log ('Installing '+$a.Name)
  try {$p=Start-Process 'winget.exe' -ArgumentList @('install','--id',$a.ID,'--exact','--accept-source-agreements','--accept-package-agreements') -Wait -PassThru;Log ($a.Name+' exit code '+$p.ExitCode)}
  catch {Log ('Install failed: '+$_.Exception.Message)}
 }
})
function Command([string]$exe,[string[]]$args,[bool]$admin=$false) {
 if($admin -and !(IsAdmin)) {[Windows.MessageBox]::Show('Reopen PowerShell as Administrator.','Marceli Win')|Out-Null;return}
 $cmd=$exe+' '+($args -join ' ')
 if ([Windows.MessageBox]::Show('Execute the following command?'+[Environment]::NewLine+$cmd,'Marceli Win','YesNo') -ne 'Yes') {return}
 Log ('Running '+$cmd)
 try {$p=Start-Process $exe -ArgumentList $args -Wait -PassThru;Log ('Exit code: '+$p.ExitCode)}
 catch {Log ('Failed: '+$_.Exception.Message)}
}
(El 'Disk').Add_Click({Command 'chkdsk.exe' @('C:','/scan') $true})
(El 'Scan').Add_Click({Command 'dism.exe' @('/Online','/Cleanup-Image','/ScanHealth') $true})
(El 'Repair').Add_Click({Command 'dism.exe' @('/Online','/Cleanup-Image','/RestoreHealth') $true})
(El 'SFC').Add_Click({Command 'sfc.exe' @('/scannow') $true})
(El 'DNS').Add_Click({Command 'ipconfig.exe' @('/flushdns') $false})
(El 'Updates').Add_Click({Start-Process 'ms-settings:windowsupdate'})
(El 'Upgrades').Add_Click({Command 'winget.exe' @('upgrade','--all','--accept-source-agreements','--accept-package-agreements') $false})
(El 'OpenData').Add_Click({Start-Process 'explorer.exe' -ArgumentList $script:Data})
(El 'CopySystem').Add_Click({[Windows.Clipboard]::SetText($system.Text);Log 'Copied system details.'})
(El 'Undo').Add_Click({
 if(!(Test-Path $script:BackupPath)){Log 'No tweak backup found.';return}
 if([Windows.MessageBox]::Show('Restore the last tweak batch?','Marceli Win','YesNo') -ne 'Yes'){return}
 $records=@(Get-Content -LiteralPath $script:BackupPath -Raw|ConvertFrom-Json)
 $failed=$false
 foreach($r in $records) {
  try {
   if($r.Exists){New-Item -Path $r.Path -Force|Out-Null;New-ItemProperty -Path $r.Path -Name $r.Key -PropertyType $r.Kind -Value $r.Value -Force|Out-Null}
   elseif(Test-Path $r.Path){Remove-ItemProperty -Path $r.Path -Name $r.Key -ErrorAction SilentlyContinue}
   Log ('Restored '+$r.Key)
  } catch {$failed=$true;Log ('Undo failed: '+$_.Exception.Message)}
 }
 if(!$failed){Remove-Item -LiteralPath $script:BackupPath -Force}
})
Log 'Ready. No changes have been made.'
[void]$script:Window.ShowDialog()
