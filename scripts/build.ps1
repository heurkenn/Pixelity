param(
    [ValidateSet("love", "windows")]
    [string]$Target = "windows",

    [string]$LoveExePath = "",

    [string]$RuntimeDir = ""
)

$ErrorActionPreference = "Stop"

function Get-ProjectRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Ensure-Directory {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Remove-IfExists {
    param([string]$Path)

    if (Test-Path $Path) {
        Remove-Item -Recurse -Force $Path
    }
}

function Resolve-LoveRuntimeDir {
    param(
        [string]$ProjectRoot,
        [string]$LoveExePath,
        [string]$RuntimeDir
    )

    if ($RuntimeDir) {
        return (Resolve-Path $RuntimeDir).Path
    }

    if ($LoveExePath) {
        return Split-Path -Parent (Resolve-Path $LoveExePath).Path
    }

    $defaultRuntimeDir = Join-Path $ProjectRoot "tools/love-win64"
    if (Test-Path (Join-Path $defaultRuntimeDir "love.exe")) {
        return $defaultRuntimeDir
    }

    $command = Get-Command love.exe -ErrorAction SilentlyContinue
    if ($command) {
        return Split-Path -Parent $command.Source
    }

    throw "Impossible de trouver love.exe. Passe -LoveExePath 'C:\...\love.exe' ou -RuntimeDir 'C:\...\LOVE'."
}

function Build-LoveArchive {
    param([string]$ProjectRoot)

    $distDir = Join-Path $ProjectRoot "dist"
    $loveFile = Join-Path $distDir "Pixelity.love"
    $stagingDir = Join-Path $ProjectRoot "build/love_staging"

    Ensure-Directory $distDir
    Remove-IfExists $stagingDir
    New-Item -ItemType Directory -Path $stagingDir | Out-Null

    $itemsToPack = @(
        "main.lua",
        "conf.lua",
        "src",
        "assets",
        "README.md",
        "PROJECT_FILES.md",
        "ARCHITECTURE_GUIDE.md",
        "GAME_DESIGN.md"
    )

    foreach ($item in $itemsToPack) {
        Copy-Item -Recurse -Force (Join-Path $ProjectRoot $item) $stagingDir
    }

    Remove-IfExists $loveFile
    $zipFile = "$loveFile.zip"
    Remove-IfExists $zipFile

    Compress-Archive -Path (Join-Path $stagingDir "*") -DestinationPath $zipFile -CompressionLevel Optimal
    Move-Item -Force $zipFile $loveFile
    Remove-IfExists $stagingDir

    Write-Host "Archive creee: $loveFile"
    return $loveFile
}

function Build-WindowsPackage {
    param(
        [string]$ProjectRoot,
        [string]$LoveExePath,
        [string]$RuntimeDir
    )

    $loveFile = Build-LoveArchive -ProjectRoot $ProjectRoot
    $resolvedRuntimeDir = Resolve-LoveRuntimeDir -ProjectRoot $ProjectRoot -LoveExePath $LoveExePath -RuntimeDir $RuntimeDir
    $resolvedLoveExePath = Join-Path $resolvedRuntimeDir "love.exe"

    if (-not (Test-Path $resolvedLoveExePath)) {
        throw "love.exe introuvable dans $resolvedRuntimeDir"
    }

    $distDir = Join-Path $ProjectRoot "dist/Pixelity-windows"
    Remove-IfExists $distDir
    New-Item -ItemType Directory -Path $distDir | Out-Null

    Copy-Item -Recurse -Force (Join-Path $resolvedRuntimeDir "*") $distDir

    $loveExeBytes = [System.IO.File]::ReadAllBytes($resolvedLoveExePath)
    $loveArchiveBytes = [System.IO.File]::ReadAllBytes($loveFile)
    $mergedBytes = New-Object byte[] ($loveExeBytes.Length + $loveArchiveBytes.Length)

    [System.Buffer]::BlockCopy($loveExeBytes, 0, $mergedBytes, 0, $loveExeBytes.Length)
    [System.Buffer]::BlockCopy($loveArchiveBytes, 0, $mergedBytes, $loveExeBytes.Length, $loveArchiveBytes.Length)

    $outputExe = Join-Path $distDir "Pixelity.exe"
    [System.IO.File]::WriteAllBytes($outputExe, $mergedBytes)

    Remove-Item -Force (Join-Path $distDir "love.exe")

    Write-Host "Build Windows cree dans: $distDir"
    Write-Host "Pixelity.exe doit rester avec les DLL du runtime LOVE."
}

$projectRoot = Get-ProjectRoot

switch ($Target) {
    "love" {
        Build-LoveArchive -ProjectRoot $projectRoot | Out-Null
    }
    "windows" {
        Build-WindowsPackage -ProjectRoot $projectRoot -LoveExePath $LoveExePath -RuntimeDir $RuntimeDir
    }
}
