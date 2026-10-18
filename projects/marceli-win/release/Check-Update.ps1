# Safe, manually invoked update verifier. Downloads are NOT executed or installed.
# Requires a trusted publisher thumbprint supplied from your CURRENT approved installation.
[CmdletBinding()]
param(
 [Parameter(Mandatory)][ValidatePattern('^[0-9A-Fa-f]{40}$')][string]$ExpectedPublisherThumbprint,
 [ValidatePattern('^\d+\.\d+\.\d+$')][string]$CurrentVersion='0.3.0'
)
$ErrorActionPreference='Stop'
$api='https://api.github.com/repos/marceli1404/marceli1404/releases/latest'
$headers=@{'Accept'='application/vnd.github+json';'User-Agent'='MarceliWin-UpdateVerifier'}
$release=Invoke-RestMethod -Uri $api -Headers $headers -TimeoutSec 25 -ErrorAction Stop
if($release.prerelease -or $release.draft){throw 'Release is not a stable published version.'}
$version=([string]$release.tag_name).TrimStart('v')
if($version -notmatch '^\d+\.\d+\.\d+$'){throw 'Latest tag does not contain a release version.'}
if([version]$version -le [version]$CurrentVersion){
 Write-Host ('No newer stable version. Current: '+$CurrentVersion+'; latest: '+$version)
 return
}
$assets=@($release.assets)
$manifestAsset=@($assets|Where-Object {$_.name -eq 'release-manifest.json'})
if($manifestAsset.Count -ne 1){throw 'Stable release has no unambiguous integrity manifest.'}
$dest=Join-Path (Join-Path $env:LOCALAPPDATA 'MarceliWin\updates') $version
New-Item -ItemType Directory -Path $dest -Force|Out-Null
$manifestPath=Join-Path $dest 'release-manifest.json'
Invoke-WebRequest -Uri $manifestAsset[0].browser_download_url -OutFile $manifestPath -TimeoutSec 60 -ErrorAction Stop
if((Get-Item $manifestPath).Length -gt 65536){throw 'Manifest too large.'}
$manifest=Get-Content $manifestPath -Raw -Encoding UTF8|ConvertFrom-Json
if($manifest.format -ne 'marceli-win-release' -or $manifest.version -ne $version -or !$manifest.signed){
 throw 'Invalid version or unsigned release manifest.'
}
foreach($file in @($manifest.files)){
 $name=[string]$file.name
 if($name -cnotmatch '^[A-Za-z0-9][A-Za-z0-9_.-]{1,180}$' -or $name -match '\.\.'){throw 'Unsafe release asset name.'}
 $matching=@($assets|Where-Object {$_.name -ceq $name})
 if($matching.Count -ne 1){throw ('Missing release asset: '+$name)}
 Invoke-WebRequest -Uri $matching[0].browser_download_url -OutFile (Join-Path $dest $name) -TimeoutSec 180 -ErrorAction Stop
}
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $root 'Test-ReleaseIntegrity.ps1') -ManifestPath $manifestPath -BaseDirectory $dest -RequireSignature -ExpectedPublisherThumbprint $ExpectedPublisherThumbprint
if(!$?){throw 'Update verification failed.'}
Write-Host ('Verified update '+$version+' is available at '+$dest)
Write-Host 'NO AUTOMATIC INSTALL: inspect the signed package and launch it manually after review.'
