function Run-ADScanTools {
    <#
    .SYNOPSIS

        Runs PingCastle and SharpHound

    .DESCRIPTION

        Runs PingCastle and SharpHound

    .PARAMETER DomainName

        The AD domain to scan

    .PARAMETER PingCastlePath

        Path to PingCastle executable (default: C:\Program Files\PingCastle\PingCastle.exe)

    .PARAMETER SharpHoundPath

        Path to SharpHound executable (default: C:\Program Files\SharpHound\SharpHound.exe)

    .EXAMPLE

        Run-ADScanTools -DomainName antani.it

    .EXAMPLE

        Run-ADScanTools -DomainName antani.it -PingCastlePath C:\Custom\Path\To\PingCastle.exe
    #>

    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$DomainName,

        [Parameter(Mandatory=$false)]
        [string]$PingCastlePath = "C:\Program Files\PingCastle\PingCastle.exe",

        [Parameter(Mandatory=$false)]
        [string]$SharpHoundPath = "C:\Program Files\SharpHound\SharpHound.exe"
    )
    
    $DomainName = $DomainName.toUpper()

    # Check if PingCastle exists
    if(-not (Test-Path -Path $PingCastlePath)) {
        Write-Host "(!) PingCastle is missing (looking at $PingCastlePath)" -ForegroundColor Red
        return
    }

    # Check if SharpHound exists
    if(-not (Test-Path -Path $SharpHoundPath)) {
        Write-Host "(!) SharpHound is missing (looking at $SharpHoundPath)" -ForegroundColor Red
        return
    }

    # Obtain primary DC
    $primary_dc = $null
    try {
        $primary_dc =  (nltest.exe /dsgetdc:$DomainName /pdc | findstr 'DC:').replace(' ', '').replace('DC:\\', '').toLower()
    } catch {
        Write-Host "(!) Unable to find a primary DC for $DomainName" -ForegroundColor Red
        return
    }

    ###
    ### Run PingCastle
    ###

    $exe_file = $PingCastlePath
    $prefix = "PingCastle-$DomainName"

    # Create and move into workdir
    $currdir = Get-Location
    $personal = [Environment]::GetFolderPath("Personal")
    $now = $(Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
    $workdir = New-Item -ItemType "directory" -Path "$personal" -Name "$prefix-$now"
    Set-Location -Path "$workdir"

    # Run PingCastle healthcheck
    $command = "$exe_file --healthcheck --no-enum-limit --server $primary_dc"
    Write-Host "(*) Executing: $command" -ForegroundColor Yellow | Tee-Object -FilePath "PingCastle.log" -Append
    Invoke-Expression -Command "$command" | Tee-Object -FilePath "PingCastle.log" -Append

    # Consolidate PingCastle reports
    $command = "$exe_file --hc-conso"
    Write-Host "(*) Executing: $command" -ForegroundColor Yellow | Tee-Object -FilePath "PingCastle.log" -Append
    Invoke-Expression -Command "$command" | Tee-Object -FilePath "PingCastle.log" -Append

    # Go back
    Set-Location -Path "$currdir"

    ###
    ### Run Sharpound
    ###

    $exe_file = $SharpHoundPath
    $prefix = "SharpHound-$DomainName"

    # Create and move into workdir
    $currdir = Get-Location
    $now = $(Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
    $personal = [Environment]::GetFolderPath("Personal")
    $workdir = New-Item -ItemType "directory" -Path "$personal" -Name "$prefix-$now"
    Set-Location -Path "$workdir"

    # Run SharpHound
    $command = "$exe_file --CollectionMethod All --prettyjson -v -d $DomainName"
    Write-Host "(*) Executing: $command" -ForegroundColor Yellow | Tee-Object -FilePath "SharpHound.log" -Append
    Invoke-Expression -Command "$command" | Tee-Object -FilePath "SharpHound.log" -Append

    # Go back
    Set-Location -Path "$currdir"
}
