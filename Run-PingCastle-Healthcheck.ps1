$exe_file = "C:\Tools\PingCastle\PingCastle.exe"
$prefix = "PingCastle"

# Create and move into workdir
$currdir = Get-Location
$now = Get-Date -Format "yyyyMMddTHHmmss"
$personal = [Environment]::GetFolderPath("Personal")
$workdir = New-Item -ItemType "directory" -Path "$personal" -Name "$prefix-$now"
Set-Location -Path "$workdir"

# Run PingCastle healthcheck
$command = "$exe_file --healthcheck --no-enum-limit"
Write-Host "[*] Executing: $command" -ForegroundColor Yellow | Tee-Object -FilePath "PingCastle.log" -Append
Invoke-Expression -Command "$command" | Tee-Object -FilePath "PingCastle.log" -Append

# Consolidate PingCastle reports
$command = "$exe_file --hc-conso"
Write-Host "[*] Executing: $command" -ForegroundColor Yellow | Tee-Object -FilePath "PingCastle.log" -Append
Invoke-Expression -Command "$command" | Tee-Object -FilePath "PingCastle.log" -Append

# Go back
Set-Location -Path "$currdir"
