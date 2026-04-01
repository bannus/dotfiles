$files = Get-ChildItem . *.java -rec
foreach ($file in $files)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "516_AddFr", "519_AddFr" } |
    Set-Content $file.PSPath
}
