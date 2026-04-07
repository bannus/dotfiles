#==============================================================================
#=
#= PowerShell profile aliases — migrated from aliases.doskey
#= Source this from $PROFILE:  . "C:\developer\bavander\aliases.ps1"
#=
#==============================================================================

#=== Reload
function reload { . $PROFILE }

#==============================================================================
#= Team specific aliases
#==============================================================================

#==============================================================================
#=== MSBuild
function mbr {
    & "$env:DEVELOPER_ROOT\Scripts\msbuild.bat" /m /p:Configuration=Release /p:SigningScenarioForRelease=Test /p:DeveloperBuild=true @args
}
function mbd {
    & "$env:DEVELOPER_ROOT\Scripts\msbuild.bat" /m /p:Configuration=Debug /p:DeveloperBuild=true @args
}
function mbrr {
    & "$env:DEVELOPER_ROOT\Scripts\msbuild.bat" /m /p:Configuration=Release /p:SigningScenarioForRelease=Test /t:rebuild @args
}
function mbdr {
    & "$env:DEVELOPER_ROOT\Scripts\msbuild.bat" /m /p:Configuration=Debug /t:rebuild @args
}

#=== Enlistment Dirs
function binr { Push-Location "$env:ENLISTMENT_ROOT\bin\AnyCPU\Release" }
function bind { Push-Location "$env:ENLISTMENT_ROOT\bin\AnyCPU\Debug" }
function objr { Push-Location "$env:ENLISTMENT_ROOT\obj\AnyCPU\Release" }
function objd { Push-Location "$env:ENLISTMENT_ROOT\obj\AnyCPU\Debug" }

#=== Android SDK Commands
function adb {
    if (-not $env:ANDROID_SDK_ROOT) {
        Write-Host "ANDROID_SDK_ROOT is not set. Install the Android SDK or set the variable manually." -ForegroundColor Red
        return
    }
    $adbExe = "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe"

    # Auto-detect device if not set
    if (-not $env:SPECIFIC_DEVICE) {
        $devices = (& $adbExe devices | Select-String '^\S+\s+device$') -replace '\s+device$', ''
        if ($devices -and @($devices).Count -eq 1) {
            $env:SPECIFIC_DEVICE = "$devices".Trim()
            Write-Host "Auto-selected device [$env:SPECIFIC_DEVICE]" -ForegroundColor DarkGray
        }
    }

    if ($env:SPECIFIC_DEVICE) {
        $output = & $adbExe -s $env:SPECIFIC_DEVICE @args 2>&1
        if ($output -match "device '.*' not found") {
            Write-Host "Device [$env:SPECIFIC_DEVICE] not found, clearing." -ForegroundColor Yellow
            $env:SPECIFIC_DEVICE = $null
            & $adbExe @args
        } else {
            $output
        }
    } else {
        & $adbExe @args
    }
}
function avd { & "$env:ANDROID_SDK_ROOT\AVD Manager.exe" @args }

#=== Android Studio / Gradle
function as { explorer.exe $env:ANDROID_STUDIO_ROOT }
function gradlew {
    gradlew.bat @args
    $result = if ($LASTEXITCODE -eq 0) { "succeeded" } else { "FAILED" }
    & "$env:DEVELOPER_ROOT\Scripts\notify.ps1" -title "Gradle $result" -message "$args"
}
function gr { gradlew assembleRelease }
function gcr { gradlew clean assembleRelease }
function gd { gradlew assembleDebug }
function gcd { gradlew clean assembleDebug }
function cs {
    gradlew --configure-on-demand checkstyle -PcheckForNewPackages=false
}

#==============================================================================
#= Developer specific aliases
#==============================================================================

#=== Directory shortcuts
function bavander { Push-Location $env:DEVELOPER_ROOT }
function mdm { Push-Location "$env:ENLISTMENT_ROOT\android\$args" }
function mdmt { Push-Location "$env:ENLISTMENT_ROOT\android\test\$args" }
function agent { Push-Location "$env:ENLISTMENT_ROOT\test\AppClient.Test.Agent$args" }
function internal { Push-Location "$env:ENLISTMENT_ROOT\product\AppClient.Internal$args" }
function external { Push-Location "$env:ENLISTMENT_ROOT\product\AppClient.External$args" }
function interface { Push-Location "$env:ENLISTMENT_ROOT\product\AppClient.Interface$args" }
function tapp1 { Push-Location "$env:ENLISTMENT_ROOT\test\AppClient.Test.App1$args" }
function tapp2 { Push-Location "$env:ENLISTMENT_ROOT\test\AppClient.Test.App2$args" }
function tapp3 { Push-Location "$env:ENLISTMENT_ROOT\test\AppClient.Test.App3$args" }
function tapp4 { Push-Location "$env:ENLISTMENT_ROOT\test\AppClient.Test.App4$args" }
function toapp1 { Push-Location "$env:ENLISTMENT_ROOT\test\AppClient.TestOnly.App1$args" }
function fta { Push-Location "$env:ENLISTMENT_ROOT\unittest\FunctionalTestApp$args" }

#=== Editors & tools
function apktool { & "$env:JAVA_HOME\bin\java" -jar "$env:HOMEPATH\downloads\apktool_2.6.1.jar" @args }
function np { notepad2.exe @args }
function vim { gvim -p --remote-tab-silent @args }
function blog { gvim "$env:TEMP\latest-build.log" }
function astver { gvim "$env:ANDROID_SHAREDTOOLS_ROOT\packages\Microsoft.CM.Test.AndroidSharedTools\Microsoft.CM.Test.AndroidSharedTools.version.props" }
function newast { gvim -p "$env:ANDROID_MDM_ROOT\_BuildCommon\NuGet\toolset\packages.config" "$env:ANDROID_MDM_ROOT\android\Test\build.props" }
function aliases { gvim "$env:DEVELOPER_ROOT\aliases.ps1" }
function ahk { gvim "$env:HOMEDRIVE$env:HOMEPATH\OneDrive\Documents\AutoHotKey.ahk" }
function ag {
    if (Get-Command rg -ErrorAction SilentlyContinue) {
        rg --ignore-file="$env:DEVELOPER_ROOT\.agignore" @args
    } else {
        ag.exe --path-to-agignore="$env:DEVELOPER_ROOT\.agignore" @args
    }
}

#=== APK install & logcat
function install-apk {
    adb install -t -r -d @args
    $apkName = ($args | Select-Object -Last 1) | Split-Path -Leaf
    & "$env:DEVELOPER_ROOT\Scripts\notify.ps1" -title "Install complete" -message $apkName
}
function logcat { adb logcat -v threadtime -d | gvim - }
function _stop-logcat([string]$pidFile) {
    if (Test-Path $pidFile) {
        $oldPid = Get-Content $pidFile -ErrorAction SilentlyContinue
        if ($oldPid) {
            Stop-Process -Id $oldPid -ErrorAction SilentlyContinue
            # Wait for process to release the file handle
            try { (Get-Process -Id $oldPid -ErrorAction SilentlyContinue).WaitForExit(3000) } catch {}
        }
        Remove-Item $pidFile -ErrorAction SilentlyContinue
    }
}

function glogcatd {
    adb logcat -v threadtime -d > "$env:TEMP\glogcat.log"
    & "C:\program files\glogg\glogg.exe" "$env:TEMP\glogcat.log"
}
function glogcat {
    _stop-logcat "$env:TEMP\glogcat.pid"
    $adbExe = "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe"
    $p = Start-Process $adbExe "-s $env:SPECIFIC_DEVICE logcat -v threadtime" `
        -RedirectStandardOutput "$env:TEMP\glogcat.log" -WindowStyle Hidden -PassThru
    $p.Id | Set-Content "$env:TEMP\glogcat.pid"
    Start-Process "C:\program files\glogg\glogg.exe" "`"$env:TEMP\glogcat.log`""
    Write-Host "Streaming logcat (PID $($p.Id)) → $env:TEMP\glogcat.log"
}
function klogcatd {
    adb logcat -v threadtime -d > "$env:TEMP\klogcat.log"
    & "C:\program files\klogg\klogg.exe" "$env:TEMP\klogcat.log"
}
function klogcat {
    _stop-logcat "$env:TEMP\klogcat.pid"
    $adbExe = "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe"
    $p = Start-Process $adbExe "-s $env:SPECIFIC_DEVICE logcat -v threadtime" `
        -RedirectStandardOutput "$env:TEMP\klogcat.log" -WindowStyle Hidden -PassThru
    $p.Id | Set-Content "$env:TEMP\klogcat.pid"
    Start-Process "C:\program files\klogg\klogg.exe" "`"$env:TEMP\klogcat.log`""
    Write-Host "Streaming logcat (PID $($p.Id)) → $env:TEMP\klogcat.log"
}
function clogcat {
    _stop-logcat "$env:TEMP\klogcat.pid"
    _stop-logcat "$env:TEMP\glogcat.pid"
    adb logcat -c
}

#=== Nuget packages
function sdkroot { Push-Location "$env:ANDROID_SDK_ROOT\$args" }
function asdk { explorer.exe $env:ANDROID_SDK_ROOT }
function rmlocals {
    Remove-Item -Recurse -Force "$env:NUGET_PKG_ROOT\Microsoft.CM.Test.AndroidSharedTools.0.0.0" -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force "$env:NUGET_PKG_ROOT\Microsoft.Intune.MAM.Internal.1.1.0-local-000" -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force "$env:NUGET_PKG_ROOT\..\nuget-global-packages\Microsoft.CM.Test.AndroidSharedTools\0.0.0" -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force "$env:NUGET_PKG_ROOT\..\nuget-global-packages\Microsoft.Intune.MAM.Internal\1.1.0-local-000" -ErrorAction SilentlyContinue
}

#==============================================================================
#= ADB specific device
#==============================================================================
function sd {
    if ($env:SPECIFIC_DEVICE) {
        $model = (& "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe" -s $env:SPECIFIC_DEVICE shell getprop ro.product.model 2>$null)
        if ($model) {
            Write-Host "Current ADB device is [$env:SPECIFIC_DEVICE] ($($model.Trim()))"
        } else {
            Write-Host "Current ADB device is [$env:SPECIFIC_DEVICE]"
        }
    } else {
        Write-Host "No device set (will auto-detect if one is connected)"
    }
}
function setsd { param([string]$Device) $env:SPECIFIC_DEVICE = $Device }
Register-ArgumentCompleter -CommandName setsd -ParameterName Device -ScriptBlock {
    (& "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe" devices | Select-String '^\S+\s+device$') |
        ForEach-Object { ($_ -replace '\s+device$', '').Trim() }
}
function getsd { $env:SPECIFIC_DEVICE = (& "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe" shell getprop ro.serialno).Trim() }

function pulllogsprivate { adb pull /data/data/com.microsoft.windowsintune.companyportal/files/ @args }
function pulllogs { adb pull /sdcard/android/data/com.microsoft.windowsintune.companyportal/files/ @args }

#=== Device presets
function nexus5  { $env:SPECIFIC_DEVICE = "052ab9560a66df4e" }
function 5x      { $env:SPECIFIC_DEVICE = "020511de3ba422d0" }
function 6p      { $env:SPECIFIC_DEVICE = "84B7N15A04003308" }
function nexus6  { $env:SPECIFIC_DEVICE = "ZX1G225SCJ" }
function nexus7  { $env:SPECIFIC_DEVICE = "078e7fd5" }
function note3   { $env:SPECIFIC_DEVICE = "919c54bb" }
function emu     { $env:SPECIFIC_DEVICE = "emulator-5554" }
function emu2    { $env:SPECIFIC_DEVICE = "emulator-5556" }
function pixel2  { $env:SPECIFIC_DEVICE = "HT7AD1A02688" }
function pixel3  { $env:SPECIFIC_DEVICE = "93GAX07RFK" }
function pixel4  { $env:SPECIFIC_DEVICE = "9A241FFAZ0034T" }
function pixel4a { $env:SPECIFIC_DEVICE = "08041JEC217716" }
function pixel4xl { $env:SPECIFIC_DEVICE = "9A311FFBA000GW" }
function shrike  { $env:SPECIFIC_DEVICE = "4d0087fcb8169077" }
function s10     { $env:SPECIFIC_DEVICE = "R38M204KVVL" }
function j700m   { $env:SPECIFIC_DEVICE = "33004139220d23e7" }
function redmi   { $env:SPECIFIC_DEVICE = "18ebb5050704" }
function p30     { $env:SPECIFIC_DEVICE = "22X0220507008508" }

#==============================================================================
#= ADB utilities
#==============================================================================
function adb-tab   { adb shell input keyevent KEYCODE_TAB }
function adb-enter { adb shell input keyevent KEYCODE_ENTER }
function devset    { adb shell am start -a android.settings.APPLICATION_DEVELOPMENT_SETTINGS }
function devtime   { adb shell am start -a android.settings.DATE_SETTINGS }
function accounts  { adb shell am start -a android.settings.SYNC_SETTINGS }
function adbsit    { adb shell input text @args }
function adbsite   { adb shell input text @args; adb shell input keyevent KEYCODE_ENTER }
function debugwait { adb shell am set-debug-app -w @args }

function ls-msft {
    adb shell pm list packages |
        Select-String -Pattern 'microsoft|azure' |
        ForEach-Object { $_ -replace 'package:', '' }
}
function kill-msft {
    ls-msft | ForEach-Object { adb shell am force-stop $_.Trim() }
}
function rm-msft {
    $adbExe = "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe"
    $device = $env:SPECIFIC_DEVICE
    ls-msft | ForEach-Object -ThrottleLimit 10 -Parallel {
        & $using:adbExe -s $using:device uninstall $_.Trim()
    }
}
function rm-apps {
    param([string]$Pattern)
    $adbExe = "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe"
    $device = $env:SPECIFIC_DEVICE
    & $adbExe -s $device shell pm list packages |
        Select-String -Pattern $Pattern |
        ForEach-Object { ($_ -replace 'package:', '').Trim() } |
        ForEach-Object -ThrottleLimit 10 -Parallel {
            & $using:adbExe -s $using:device uninstall $_
        }
}
function rm-portal { adb uninstall com.microsoft.windowsintune.companyportal }
function clear-msft {
    $adbExe = "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe"
    $device = $env:SPECIFIC_DEVICE
    ls-msft | ForEach-Object -ThrottleLimit 10 -Parallel {
        & $using:adbExe -s $using:device shell pm clear $_.Trim()
    }
}
function clear-apps {
    param([string]$Pattern)
    $adbExe = "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe"
    $device = $env:SPECIFIC_DEVICE
    & $adbExe -s $device shell pm list packages |
        Select-String -Pattern $Pattern |
        ForEach-Object { ($_ -replace 'package:', '').Trim() } |
        ForEach-Object -ThrottleLimit 10 -Parallel {
            & $using:adbExe -s $using:device shell pm clear $_
        }
}

#==============================================================================
#= Play Store (opens store page in browser)
#==============================================================================
function store { param([string]$Package) Start-Process "https://play.google.com/store/apps/details?id=$Package" }
function portal     { store com.microsoft.windowsintune.companyportal }
function teams      { store com.microsoft.teams }
function outlook    { store com.microsoft.office.outlook }
function onedrive   { store com.microsoft.skydrive }
function word       { store com.microsoft.office.word }
function excel      { store com.microsoft.office.excel }
function powerpoint { store com.microsoft.office.powerpoint }
function manbro     { store com.microsoft.intune.mam.managedbrowser }
function edge       { store com.microsoft.emmx }
function yammer     { store com.yammer.v1 }
function launcher   { store com.microsoft.launcher }
function todo       { store com.microsoft.todos }
function kaizala    { store com.microsoft.mobile.polymer }
function sfb        { store com.microsoft.office.lync15 }
function onenote    { store com.microsoft.office.onenote }
function sharepoint { store com.microsoft.sharepoint }
function office     { store com.microsoft.office.officehubrow }

#=== Drop shares
function drops {
    Write-Host "\\appvfile07\Private\Intune\AndroidMAM\develop"
    Write-Host "\\appvfile07\Private\Intune\AndroidSSP\develop"
}
function mamdev { explorer.exe "\\appvfile07\Private\Intune\AndroidMAM\develop" }
function mamrel { explorer.exe "\\appvfile07\Private\Intune\AndroidMAM\master" }
function mdmdev { explorer.exe "\\appvfile07\Private\Intune\AndroidSSP\develop" }
function mdmrel { explorer.exe "\\appvfile07\Private\Intune\AndroidSSP\release" }

function ecndevx { & "\\sgdfile04\users\ECNDEVX\ecndevx.bat" }
