$exe_file = "C:\Tools\SharpHound\SharpHound.exe"
$prefix = "SharpHound"

# Create and move into workdir
$currdir = Get-Location
$now = $(Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
$personal = [Environment]::GetFolderPath("Personal")
$workdir = New-Item -ItemType "directory" -Path "$personal" -Name "$prefix-$now"
Set-Location -Path "$workdir"

# Run SharpHound
$command = "$exe_file --CollectionMethod All --prettyjson -v"
Write-Host "[*] Executing: $command" -ForegroundColor Yellow | Tee-Object -FilePath "SharpHound.log" -Append
Invoke-Expression -Command "$command" | Tee-Object -FilePath "SharpHound.log" -Append

# Go back
Set-Location -Path "$currdir"
