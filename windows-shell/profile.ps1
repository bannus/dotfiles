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

oh-my-posh init --config 'stelbent.minimal' pwsh | Invoke-Expression
. "C:\developer\bavander\aliases.ps1"
