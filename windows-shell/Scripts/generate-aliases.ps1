$aliases = get-content .\aliases.doskey
foreach ($alias in $aliases) {
    if (!$alias -or $alias[0] -eq '#') {
        continue;
    }
    $i = $alias.IndexOf('=');
    $filename = "$($alias.Substring(0, $i)).cmd"
    $command = "@$($alias.Substring($i+1).Replace("$", "%"))"
    $command | Add-Content "Scripts/aliases/$filename"
    write-host $filename
}
