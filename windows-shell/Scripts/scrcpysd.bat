@echo off

pushd C:\src\ast\Test\3p\SCRCPY\scrcpy-win64
REM start C:\src\ast\Test\3p\SCRCPY\scrcpy-win64\scrcpy.exe -m 1280 -s %SPECIFIC_DEVICE%
start wscript C:\src\ast\Test\3p\SCRCPY\scrcpy-win64\scrcpy-noconsole.vbs --video-bit-rate=8M --no-audio --stay-awake -s %SPECIFIC_DEVICE%
popd
