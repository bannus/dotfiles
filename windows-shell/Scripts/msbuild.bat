@echo off
rem
call msbuild.exe %* /v:m /fileLoggerParameters:LogFile=%TEMP%\latest-build.log
if %errorlevel% == 0 (
    set title=\"Build succeeded\"
) else (
    set title=\"Build failed\"
)
set message=\"Time: %time%. Log at %temp%\latest-build.log.\"
powershell %DEVELOPER_ROOT%\Scripts\notify.ps1 -title %title% -message %message%
echo "log at %temp%\latest-build.log"
