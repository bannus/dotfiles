param([Parameter(Mandatory)][string]$Id)
Start-Process "https://portal.microsofticm.com/imp/v3/incidents/details/$Id/home"
