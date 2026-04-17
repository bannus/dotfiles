$q = [uri]::EscapeDataString($args -join ' ')
Start-Process "https://dev.azure.com/msazure/Intune/_search?text=$q&type=workitem&pageSize=25&filters=Projects%7BIntune%7DArea%20Paths%7BIntune%5CMgmt%5CAndroid%20Mobility%5CMAM%20Android%7D"
