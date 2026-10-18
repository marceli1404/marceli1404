# Marceli Win reproducible single-file build. Windows PowerShell 5.1+ or PowerShell 7+.
[CmdletBinding()]
param([switch]$Check)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
$parts=@(
 'src/00-Bootstrap.ps1',
 'src/10-Catalogues.ps1',
 'src/20-Registry.ps1',
 'src/30-Operations.ps1',
 'src/40-Interface.ps1'
)
$chunks=foreach($part in $parts){
 $full=Join-Path $root $part
 if(!(Test-Path -LiteralPath $full)){throw ('Missing source module: '+$part)}
 [IO.File]::ReadAllText($full,[Text.Encoding]::UTF8)
}
$combined=[string]::Concat($chunks)
if([string]::IsNullOrEmpty($combined)){throw 'Build produced an empty script.'}
if([int][char]$combined[0] -eq 65279){throw 'An embedded BOM would break irm | iex.'}
$encoding=New-Object System.Text.UTF8Encoding($false)
$bytes=$encoding.GetBytes($combined)
$destination=Join-Path $root 'MarceliWin.ps1'
if($Check){
 if(!(Test-Path -LiteralPath $destination)){throw 'Generated launcher missing.'}
 $onDisk=[IO.File]::ReadAllBytes($destination)
 $sha=[Security.Cryptography.SHA256]::Create()
 try {
  $computed=[BitConverter]::ToString($sha.ComputeHash($bytes)).Replace('-','')
  $tracked=[BitConverter]::ToString($sha.ComputeHash($onDisk)).Replace('-','')
 } finally {$sha.Dispose()}
 if($computed -ne $tracked){throw ('Build mismatch: generated '+$computed+'; checked-in '+$tracked)}
 Write-Host ('Reproducible build verified ('+$bytes.Length+' bytes, SHA-256 '+$computed+')')
} else {
 [IO.File]::WriteAllBytes($destination,$bytes)
 Write-Host ('Built '+$destination+' ('+$bytes.Length+' bytes).')
}
