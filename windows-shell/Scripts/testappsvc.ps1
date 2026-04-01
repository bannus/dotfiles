param (
    [string]$svc,
    [string]$method = "",
    [string[]] $strArgs,
    [bool[]] $boolArgs
)

$taskId = [guid]::NewGuid()

adb shell am startservice -n com.microsoft.mdm.testapp1/com.microsoft.mdm.testappbase.dispatch.$svc -a com.microsoft.mdm.test.roles.action.INVOKE --es "method" "$method" --ez "expected" "true" --es "locations" "1\;2\;32" --es "taskid" "$taskId"

write-output "Ran $method with ID: $taskId"