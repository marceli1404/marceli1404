# Offline packaging orchestrator. The signed version requires authenticated signing between stages.
[CmdletBinding()]
param(
 [Parameter(Mandatory)][ValidateSet('Stage','Compile','Finalize')][string]$Phase,
 [switch]$Signed,
 [string]$SourceCommit
)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Push-Location $root
try {
 $version='0.3.0'
 $stage=Join-Path $root 'dist\stage'
 $output=Join-Path $root 'dist\release'
 if($Phase -eq 'Stage'){
  & (Join-Path $root 'build.ps1') -Check
  New-Item -ItemType Directory -Path $stage -Force|Out-Null
  Copy-Item -LiteralPath (Join-Path $root 'MarceliWin.ps1') -Destination $stage -Force
  Copy-Item -LiteralPath (Join-Path $root 'launcher.cmd') -Destination $stage -Force
  Copy-Item -LiteralPath (Join-Path $root 'LICENSE') -Destination $stage -Force
  Copy-Item -LiteralPath (Join-Path $root 'installer\INSTALLATION.txt') -Destination $stage -Force
  Write-Host 'Staged the standalone app and installer resources.'
 }
 elseif($Phase -eq 'Compile'){
  if(!(Test-Path (Join-Path $stage 'MarceliWin.ps1'))){throw 'Missing staged PowerShell payload.'}
  New-Item -ItemType Directory -Path (Join-Path $root 'dist') -Force|Out-Null
  $compiler='C:\Program Files (x86)\NSIS\makensis.exe'
  if(!(Test-Path $compiler)){throw 'NSIS compiler not installed.'}
  $label=if($Signed){'signed-candidate'}else{'unsigned-preview'}
  & $compiler '/V3' ("/DBUILD_LABEL="+$label) (Join-Path $root 'installer\MarceliWin.nsi')
  if($LASTEXITCODE -ne 0){throw ('NSIS compile failed: '+$LASTEXITCODE)}
 }
 else {
  if($SourceCommit -notmatch '^[A-Fa-f0-9]{40}$'){throw 'A full source commit hash is required.'}
  $label=if($Signed){'signed-candidate'}else{'unsigned-preview'}
  $exe=Join-Path $root ('dist\MarceliWin-Setup-'+$version+'-'+$label+'.exe')
  if(!(Test-Path $exe)){throw ('Expected installer missing: '+$exe)}
  New-Item -ItemType Directory -Path $output -Force|Out-Null
  Copy-Item -LiteralPath $exe -Destination $output -Force
  Copy-Item -LiteralPath (Join-Path $stage 'MarceliWin.ps1') -Destination $output -Force
  Compress-Archive -Path (Join-Path $stage '*') -DestinationPath (Join-Path $output 'MarceliWin-0.3.0-portable.zip') -Force
  $extra=@{}
  if($Signed){
   $signature=Get-AuthenticodeSignature (Join-Path $output 'MarceliWin.ps1')
   if($signature.Status -ne 'Valid' -or !$signature.SignerCertificate){throw 'Signed release requested without a verified script publisher.'}
   $extra=@{RequireSignature=$true;ExpectedPublisherThumbprint=$signature.SignerCertificate.Thumbprint}
  }
  & (Join-Path $root 'release\New-ReleaseManifest.ps1') -ReleaseDirectory $output -Version $version -SourceCommit $SourceCommit @extra
  & (Join-Path $root 'release\Test-ReleaseIntegrity.ps1') -ManifestPath (Join-Path $output 'release-manifest.json') -BaseDirectory $output @extra
  Write-Host ('Release candidate created at '+$output)
 }
} finally {Pop-Location}
