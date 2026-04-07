#==============================================================================
#= PowerShell profile — managed via dotfiles
#= Loaded by the OneDrive-synced stub in Documents\PowerShell\$PROFILE
#==============================================================================

if ($env:TERM_PROGRAM -eq "vscode") { . "$(code --locate-shell-integration-path pwsh)" }

# Auto-install required modules
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    Write-Host "Installing BurntToast module..." -ForegroundColor Yellow
    Install-Module BurntToast -Scope CurrentUser -Force
}

# Auto-install oh-my-posh
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing oh-my-posh..." -ForegroundColor Yellow
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-package-agreements --accept-source-agreements
    # Refresh PATH so the current session picks up the new binary
    $env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('PATH', 'User')
}

# Auto-detect ANDROID_SDK_ROOT if not set
if (-not $env:ANDROID_SDK_ROOT) {
    $candidates = @(
        "$env:LOCALAPPDATA\Android\Sdk",
        "$env:USERPROFILE\AppData\Local\Android\Sdk",
        "C:\Android\Sdk",
        "C:\Android\android-sdk"
    )
    # Also check the most recently modified Intune Android SDK NuGet package
    $nugetSdk = Get-ChildItem "C:\NuGetPackages" -Filter "microsoft.intune.androidsdk.universal.*" -Directory -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName
    if ($nugetSdk) { $candidates = @($nugetSdk) + $candidates }

    $detected = $candidates | Where-Object { Test-Path "$_\platform-tools\adb.exe" } | Select-Object -First 1
    if ($detected) {
        $env:ANDROID_SDK_ROOT = $detected
        Write-Host "ANDROID_SDK_ROOT auto-detected: $detected" -ForegroundColor DarkGray
    }
}

oh-my-posh init --config 'stelbent.minimal' pwsh | Invoke-Expression

# Set DEVELOPER_ROOT and add Scripts to PATH
$env:DEVELOPER_ROOT = "C:\developer\bavander"
if ($env:PATH -notlike "*$env:DEVELOPER_ROOT\Scripts*") {
    $env:PATH = "$env:DEVELOPER_ROOT\Scripts;$env:PATH"
}

. "C:\developer\bavander\aliases.ps1"
