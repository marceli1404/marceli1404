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
