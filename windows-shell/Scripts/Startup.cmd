@if not defined echo_on echo off
@echo [bavander] environment modifications

rem Use VS2013
set set VS_DEFAULT_VER=14.0


:userenvironment
@set PERSONAL_DEV_SCRIPTS=%DEVELOPER_ROOT%\scripts
@set PATH=%PERSONAL_DEV_SCRIPTS%;%PATH%

:end
@echo Done.
