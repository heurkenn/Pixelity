$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$buildDir = Join-Path $projectRoot "build"
$distDir = Join-Path $projectRoot "dist"

if (Test-Path $buildDir) {
    Get-ChildItem -Force $buildDir | Remove-Item -Recurse -Force
}

if (Test-Path $distDir) {
    Get-ChildItem -Force $distDir | Remove-Item -Recurse -Force
}

Write-Host "Dossiers build/ et dist/ nettoyes."
