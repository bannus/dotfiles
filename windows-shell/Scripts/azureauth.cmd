@echo off
REM Shim for azureauth - automatically finds the latest installed version
for /f "delims=" %%D in ('dir /b /ad /o-n "%LOCALAPPDATA%\Programs\AzureAuth" 2^>nul') do (
    "%LOCALAPPDATA%\Programs\AzureAuth\%%D\azureauth.exe" %*
    exit /b %ERRORLEVEL%
)
echo ERROR: AzureAuth is not installed in %LOCALAPPDATA%\Programs\AzureAuth 1>&2
exit /b 1
