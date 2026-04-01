@echo off

:: %ANDROID_SDK_ROOT%\platform-tools\adb.exe -s %SPECIFIC_DEVICE% get-state
if defined SPECIFIC_DEVICE (
    REM echo Using [%SPECIFIC_DEVICE%]
    %ANDROID_SDK_ROOT%\platform-tools\adb.exe -s %SPECIFIC_DEVICE% %*
) else (
    echo Using default device
    %ANDROID_SDK_ROOT%\platform-tools\adb.exe %*
)
