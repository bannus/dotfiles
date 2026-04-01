$creds = @(
)

Write-Host @"
[-1] custom creds
[0] $($creds[0][0])
[1] $($creds[1][0])
"@
$index = Read-Host 'Please select an index'

if ($index -eq -1) {
    $username = Read-Host 'Username'
    $password = Read-Host 'Password'
} else {
    $username = $creds[$index][0]
    $password = $creds[$index][1]
}
$password = $password.Replace("`$", "`\`$")

Invoke-Expression -command "adb devices"
$device = Read-Host 'Device ID'

$inputcmd = "adb -s $device shell input"

function Input-KeyCode($key)
{
    Invoke-Expression -command "$inputcmd keyevent KEYCODE_$key"
}

Write-Host "Entering credentials"
Invoke-Expression -command "$inputcmd text $username"
Input-Keycode "TAB"
Invoke-Expression -command "$inputcmd text $password"
Input-Keycode "TAB"
Input-Keycode "TAB"
Input-Keycode "ENTER"

