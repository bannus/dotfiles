param([Parameter(Mandatory)][string]$Id)
Start-Process "https://dev.azure.com/msazure/Intune/_workitems/edit/$Id"
