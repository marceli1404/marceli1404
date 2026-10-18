# Verify integrity and, for trusted releases, the publisher of staged Windows artifacts.
# A manifest delivered beside an unsigned file is NOT a proof of publisher identity.
[CmdletBinding()]
param(
 [Parameter(Mandatory)][string]$ManifestPath,
 [Parameter(Mandatory)][string]$BaseDirectory,
 [switch]$RequireSignature,
 [string]$ExpectedPublisherThumbprint
)
$ErrorActionPreference='Stop'
if(!$IsWindows -and $PSVersionTable.PSVersion.Major -ge 6 -and $env:OS -ne 'Windows_NT'){
 throw 'Authenticode release verification requires Windows.'
}
if(!(Test-Path -LiteralPath $ManifestPath -PathType Leaf)){throw 'Manifest missing.'}
if((Get-Item -LiteralPath $ManifestPath).Length -gt 65536){throw 'Manifest is unexpectedly large.'}
$doc=Get-Content -LiteralPath $ManifestPath -Raw -Encoding UTF8|ConvertFrom-Json
if($doc.format -ne 'marceli-win-release' -or [int]$doc.schema -ne 1){throw 'Unexpected release manifest format.'}
if([string]$doc.version -notmatch '^\d+\.\d+\.\d+$'){throw 'Invalid release version.'}
$files=@($doc.files)
if($files.Count -lt 2 -or $files.Count -gt 10){throw 'Invalid release file count.'}
$seen=@{}
if($RequireSignature -and [string]::IsNullOrWhiteSpace($ExpectedPublisherThumbprint)){
 throw 'A trusted signing certificate thumbprint must be supplied separately for a production verification.'
}
if($ExpectedPublisherThumbprint -and $ExpectedPublisherThumbprint -notmatch '^[0-9a-fA-F]{40}$'){throw 'Expected thumbprint must be exactly 40 hex characters.'}
foreach($record in $files){
 $name=[string]$record.name
 if($name -cnotmatch '^[A-Za-z0-9][A-Za-z0-9_.-]{1,180}$' -or $name -match '\.\.'){
  throw ('Unsafe release filename: '+$name)
 }
 if($seen.ContainsKey($name)){throw ('Duplicate file entry: '+$name)}
 $seen[$name]=$true
 if([string]$record.sha256 -notmatch '^[a-fA-F0-9]{64}$'){throw ('Invalid checksum: '+$name)}
 $path=Join-Path $BaseDirectory $name
 if(!(Test-Path -LiteralPath $path -PathType Leaf)){throw ('Missing release asset: '+$name)}
 $actual=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
 if($actual -ine $record.sha256){throw ('SHA-256 mismatch for '+$name)}
 if($RequireSignature -and ($name -match '\.(ps1|exe)$')){
  $auth=Get-AuthenticodeSignature -LiteralPath $path
  if($auth.Status -ne 'Valid' -or !$auth.SignerCertificate){
   throw ('Publisher signature is missing or invalid: '+$name)
  }
  if($auth.SignerCertificate.Thumbprint -ine $ExpectedPublisherThumbprint){
   throw ('Unexpected code-signing publisher for '+$name)
  }
 }
 Write-Host ('Verified: '+$name)
}
if($RequireSignature){
 if(!$doc.signed){throw 'Manifest does not identify a signed distribution.'}
 if(@($files|Where-Object {$_.name -match '\.exe$'}).Count -lt 1 -or
    @($files|Where-Object {$_.name -match '\.ps1$'}).Count -lt 1){throw 'Missing signed script/installer pair.'}
 Write-Host 'Publisher verification completed against independently supplied pinned thumbprint.'
} else {
 Write-Warning 'Checksums confirmed file integrity only. No publisher authenticity is established for unsigned previews.'
}
