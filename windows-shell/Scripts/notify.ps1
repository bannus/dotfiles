param (
    [string]$title,
    [string]$message = "",
    [string]$tag = "PowerShell"
)

$text1 = New-BTText -Text $title
$text2 = New-BTText -Text $message
$binding = New-BTBinding -Children $text1, $text2
$visual = New-BTVisual -BindingGeneric $binding
$content = New-BTContent -Visual $visual
Submit-BTNotification -Content $content
