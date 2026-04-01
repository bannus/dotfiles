$xmls = get-childitem -path . -filter checkstyle.xml -recurse
foreach ($xml in $xmls) {
    $rep = '\s+<module name="RedundantThrows">\s+<property name="suppressLoadErrors" value="true"/>\s+</module>'
    $content = (Get-Content $xml.FullName -raw) -replace $rep, ""
    Write-Host $xml.FullName
    [IO.File]::WriteAllText($xml.FullName, $content)
}
