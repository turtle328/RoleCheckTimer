[CmdletBinding()]
param(
    [string]$WowPath
)

$ErrorActionPreference = "Stop"

$addonName = "RoleCheckTimer"
$sourceDir = $PSScriptRoot

if (-not (Test-Path (Join-Path $sourceDir "RoleCheckTimer.toc")) -or
    -not (Test-Path (Join-Path $sourceDir "RoleCheckTimer.lua"))) {
    throw "Run this script from the RoleCheckTimer repository folder."
}

if ($WowPath) {
    $retailDir = Join-Path $WowPath "_retail_"
    if ((Split-Path $WowPath -Leaf) -eq "_retail_") {
        $retailDir = $WowPath
    }
} else {
    $candidates = @(
        "${env:ProgramFiles(x86)}\World of Warcraft\_retail_",
        "$env:ProgramFiles\World of Warcraft\_retail_",
        "C:\World of Warcraft\_retail_"
    ) | Where-Object { $_ -and (Test-Path $_) }

    if ($candidates.Count -eq 0) {
        throw "World of Warcraft Retail was not found automatically. Re-run with: .\Install.ps1 -WowPath 'D:\Games\World of Warcraft'"
    }

    $retailDir = $candidates[0]
}

if (-not (Test-Path $retailDir)) {
    throw "Retail folder not found: $retailDir"
}

$addonsDir = Join-Path $retailDir "Interface\AddOns"
$destination = Join-Path $addonsDir $addonName

New-Item -ItemType Directory -Path $destination -Force | Out-Null

Copy-Item (Join-Path $sourceDir "RoleCheckTimer.toc") $destination -Force
Copy-Item (Join-Path $sourceDir "RoleCheckTimer.lua") $destination -Force

Write-Host "Installed $addonName to:" -ForegroundColor Green
Write-Host $destination
Write-Host "Restart World of Warcraft or run /reload if the addon was already installed."
