$exe_file = "C:\Tools\SharpHound\SharpHound.exe"
$prefix = "SharpHound"

# Create and move into workdir
$now = Get-Date -Format "yyyyMMddTHHmmss"
$workdir = New-Item -ItemType "directory" -Path "." -Name "$prefix-$now"
Set-Location -Path "$workdir"

# Run SharpHound
$command = "$exe_file --CollectionMethod All --prettyjson -v"
Write-Host "[*] Executing: $command" -ForegroundColor Yellow | Tee-Object -FilePath "SharpHound.log" -Append
Invoke-Expression -Command "$command" | Tee-Object -FilePath "SharpHound.log" -Append

# Go back
Set-Location -Path ".."
