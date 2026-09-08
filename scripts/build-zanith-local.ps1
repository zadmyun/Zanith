param(
    [string]$MsysRoot = "C:\msys64"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$MsysShell = Join-Path $MsysRoot "msys2_shell.cmd"

if (-not (Test-Path $MsysShell)) {
    Write-Host "MSYS2 was not found at $MsysRoot." -ForegroundColor Yellow
    Write-Host "Install it first with: winget install -e --id MSYS2.MSYS2"
    exit 1
}

$UnixRoot = $ProjectRoot -replace '\\','/' -replace '^([A-Za-z]):','/$1'
$UnixRoot = $UnixRoot.ToLower().Substring(0,2) + $UnixRoot.Substring(2)

Write-Host "Building Zanith 1.2.0 with the same MSYS2 toolchain used by the upstream Windows build..." -ForegroundColor Cyan
& $MsysShell -defterm -no-start -mingw64 -c "cd '$UnixRoot' && ./scripts/build-zanith-local-msys2.sh"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$IsccCandidates = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
)
$Iscc = $IsccCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $Iscc) {
    $RegistryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1"
    )
    foreach ($RegistryPath in $RegistryPaths) {
        if (Test-Path $RegistryPath) {
            $InstallLocation = (Get-ItemProperty $RegistryPath -ErrorAction SilentlyContinue).InstallLocation
            if ($InstallLocation) {
                $Candidate = Join-Path $InstallLocation "ISCC.exe"
                if (Test-Path $Candidate) {
                    $Iscc = $Candidate
                    break
                }
            }
        }
    }
}

if (-not $Iscc) {
    Write-Host "Portable build completed, but Inno Setup 6 was not found." -ForegroundColor Yellow
    Write-Host "Install it with: winget install -e --id JRSoftware.InnoSetup"
    Write-Host "Then run this script again to generate Zanith-1.2.0-Setup.exe."
    exit 0
}

Push-Location $ProjectRoot
try {
    & $Iscc "scripts\zanith.iss"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
finally {
    Pop-Location
}

Write-Host "" 
Write-Host "Done." -ForegroundColor Green
Write-Host "Portable: $ProjectRoot\Zanith-Win\Zanith.exe"
Write-Host "Installer: $ProjectRoot\Zanith-1.2.0-Setup.exe"
