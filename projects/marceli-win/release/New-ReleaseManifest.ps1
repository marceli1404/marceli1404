# Generate candidate integrity metadata only after final (optional) signing is finished.
[CmdletBinding()]
param(
 [Parameter(Mandatory)][string]$ReleaseDirectory,
 [Parameter(Mandatory)][ValidatePattern('^\d+\.\d+\.\d+$')][string]$Version,
 [Parameter(Mandatory)][ValidatePattern('^[0-9a-fA-F]{40}$')][string]$SourceCommit,
 [switch]$RequireSignature,
 [string]$ExpectedPublisherThumbprint
)
$ErrorActionPreference='Stop'
$files=Get-ChildItem -LiteralPath $ReleaseDirectory -File |
 Where-Object {$_.Name -match '^MarceliWin.*\.(exe|ps1)$'} | Sort-Object Name
if(@($files).Count -lt 2){throw 'Release requires both the PowerShell script and desktop installer.'}
if($RequireSignature -and $ExpectedPublisherThumbprint -notmatch '^[0-9a-fA-F]{40}$'){
 throw 'Cannot mark a release signed without an independently supplied 40-hex publisher thumbprint.'
}
$metadata=@()
foreach($file in $files){
 if($RequireSignature){
  $auth=Get-AuthenticodeSignature -LiteralPath $file.FullName
  if($auth.Status -ne 'Valid' -or $auth.SignerCertificate.Thumbprint -ine $ExpectedPublisherThumbprint){
   throw ('Cannot publish unsigned or untrusted release asset: '+$file.Name)
  }
 }
 $metadata+=@{name=$file.Name;sha256=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant();size=$file.Length}
}
$doc=[ordered]@{
 format='marceli-win-release';schema=1;version=$Version
 sourceCommit=$SourceCommit;channel=$(if($RequireSignature){'stable-candidate'}else{'unsigned-preview'})
 signed=[bool]$RequireSignature
 files=$metadata
}
$path=Join-Path $ReleaseDirectory 'release-manifest.json'
$doc|ConvertTo-Json -Depth 5|Set-Content -LiteralPath $path -Encoding UTF8
Write-Host ('Wrote integrity manifest: '+$path)
