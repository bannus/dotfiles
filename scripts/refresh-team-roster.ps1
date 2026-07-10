<#
.SYNOPSIS
    Builds a team roster cache with ADO VSIDs from various sources.

.DESCRIPTION
    Fetches team members from one of three sources (M365/Teams group, security
    group email, or a manager's direct reports) via MS Graph, resolves each
    member's ADO VSID, and writes copilot/team-roster.cache.md (gitignored).

    Run after team membership changes, then ask Copilot to update your user
    memories from the cache file.

.PARAMETER M365GroupId
    M365 / Teams group ID (the groupId from a Teams channel link).
    Find it in the Teams channel URL: ?groupId=<guid>

.PARAMETER GroupEmail
    Mail address of a security/distribution group.

.PARAMETER ManagerAlias
    Alias of a specific manager whose direct reports form the team.
    Omit to use your own manager (resolved from the authenticated user).

.EXAMPLE
    # By M365/Teams group ID (from the Teams channel URL)
    .\scripts\refresh-team-roster.ps1 -M365GroupId <groupId-guid>

    # By security group email
    .\scripts\refresh-team-roster.ps1 -GroupEmail yourteam@microsoft.com

    # Direct reports of your manager (auto-resolved)
    .\scripts\refresh-team-roster.ps1 -MyManager

    # Direct reports of a specific manager
    .\scripts\refresh-team-roster.ps1 -ManagerAlias youralias
#>
param(
    [string]$M365GroupId  = "",
    [string]$GroupEmail   = "",
    [string]$Org          = "https://dev.azure.com/msazure",
    [string]$Tenant       = "72f988bf-86f1-41af-91ab-2d7cd011db47",
    # Pass an alias for a specific manager, or use -MyManager to auto-resolve from /me/manager
    [string]$ManagerAlias = "",
    [switch]$MyManager
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot   = Split-Path $PSScriptRoot -Parent
$outputFile = Join-Path $repoRoot "copilot\team-roster.cache.md"

# --- Auth ---
function Get-Token([string]$Resource) {
    $json = az account get-access-token --resource $Resource --tenant $Tenant 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "az account get-access-token failed for $Resource.`nRun: az login --tenant $Tenant --allow-no-subscriptions`n$json"
    }
    return ($json | ConvertFrom-Json).accessToken
}

Write-Host "Acquiring tokens..."
$graphToken = Get-Token "https://graph.microsoft.com"
$adoToken   = Get-Token "499b84ac-1321-427f-aa17-267ca6975798"

$graphHeaders = @{ Authorization = "Bearer $graphToken"; "Content-Type" = "application/json" }
$adoHeaders   = @{ Authorization = "Bearer $adoToken";   "Content-Type" = "application/json" }

# --- Fetch members (UPN + displayName) from chosen source ---
function Get-GraphMembers([string]$Uri) {
    $results = @()
    $next = $Uri
    while ($next) {
        $page = Invoke-RestMethod -Uri $next -Headers $graphHeaders
        $results += $page.value
        $next = if ($page.PSObject.Properties["@odata.nextLink"]) { $page.'@odata.nextLink' } else { $null }
    }
    return $results
}

if ($MyManager -or $ManagerAlias) {
    if ($MyManager) {
        Write-Host "Resolving your manager via /me/manager..."
        $mgr  = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/me/manager?`$select=displayName,userPrincipalName" -Headers $graphHeaders
        Write-Host "Manager: $($mgr.displayName) ($($mgr.userPrincipalName))"
        $uri  = "https://graph.microsoft.com/v1.0/users/$($mgr.userPrincipalName)/directReports?`$select=displayName,userPrincipalName"
        $source = "direct reports of $($mgr.displayName)"
    } else {
        Write-Host "Fetching direct reports of $ManagerAlias..."
        $uri    = "https://graph.microsoft.com/v1.0/users/$ManagerAlias@microsoft.com/directReports?`$select=displayName,userPrincipalName"
        $source = "direct reports of $ManagerAlias"
    }
    $members = Get-GraphMembers $uri
} elseif ($GroupEmail) {
    Write-Host "Resolving group $GroupEmail..."
    $enc      = [Uri]::EscapeDataString($GroupEmail)
    $groupRes = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups?`$filter=mail eq '$enc'&`$select=id,displayName" -Headers $graphHeaders
    if (-not $groupRes.value) { Write-Error "Group '$GroupEmail' not found." }
    $gid      = $groupRes.value[0].id
    $gname    = $groupRes.value[0].displayName
    Write-Host "Found group: $gname ($gid)"
    $members  = Get-GraphMembers "https://graph.microsoft.com/v1.0/groups/$gid/members?`$select=displayName,userPrincipalName"
    $source   = $gname
} elseif ($M365GroupId) {
    Write-Host "Fetching members of M365 group $M365GroupId..."
    $groupRes = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups/$M365GroupId`?`$select=displayName" -Headers $graphHeaders
    Write-Host "Found group: $($groupRes.displayName)"
    $members  = Get-GraphMembers "https://graph.microsoft.com/v1.0/groups/$M365GroupId/members?`$select=displayName,userPrincipalName"
    $source   = $groupRes.displayName
} else {
    Write-Error "Specify -M365GroupId, -GroupEmail, -ManagerAlias <alias>, or -MyManager."
}

# Filter out nested groups and external/guest accounts
$members = $members | Where-Object {
    $_.'@odata.type' -eq '#microsoft.graph.user' -and
    $_.userPrincipalName -and
    $_.userPrincipalName -notlike '*#EXT#*'
}
Write-Host "Found $($members.Count) users."

# --- Resolve ADO VSID for each member ---
function Resolve-AdoVsid([string]$Upn) {
    $enc = [Uri]::EscapeDataString($Upn)
    $res = Invoke-RestMethod -Uri "https://vssps.dev.azure.com/msazure/_apis/identities?searchFilter=MailAddress&filterValue=$enc&api-version=7.1" -Headers $adoHeaders
    if ($res.value.Count -gt 0) { return $res.value[0].id }
    # Fallback: search by alias
    $alias = ($Upn -split "@")[0]
    $res2  = Invoke-RestMethod -Uri "https://vssps.dev.azure.com/msazure/_apis/identities?searchFilter=AccountName&filterValue=$alias&api-version=7.1-preview.1" -Headers $adoHeaders
    if ($res2.value.Count -gt 0) { return $res2.value[0].id }
    return $null
}

# --- Build roster ---
$lines = @(
    "# MAM Android Team Roster",
    "# Source: $source",
    "# Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm') -- do not commit (gitignored)",
    "# Run scripts/refresh-team-roster.ps1 to regenerate.",
    "",
    "MAM Android team members and ADO identity IDs:"
)

$notFound = @()
foreach ($m in $members | Sort-Object userPrincipalName) {
    $upn   = $m.userPrincipalName
    $name  = $m.displayName
    $alias = ($upn -split "@")[0]
    Write-Host -NoNewline "  Resolving $alias..."
    $vsid  = Resolve-AdoVsid $upn
    if ($vsid) {
        Write-Host " $vsid"
        $lines += "  - $alias ($name): ``$vsid``"
    } else {
        Write-Host " (not found in ADO)"
        $notFound += $alias
    }
}

if ($notFound) {
    $lines += ""
    $lines += "# Could not resolve ADO VSID for: $($notFound -join ', ')"
}

$lines | Set-Content -Path $outputFile -Encoding UTF8
Write-Host ""
Write-Host "Wrote: $outputFile"
if ($notFound) { Write-Host "WARNING: No ADO identity found for: $($notFound -join ', ')" -ForegroundColor Yellow }
Write-Host ""
Write-Host "--- Next step ---"
Write-Host "Tag the file in a Copilot chat and ask:"
Write-Host "  'Update my ADO identity memories from @copilot/team-roster.cache.md'"


