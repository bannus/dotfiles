param([Parameter(Mandatory)][string]$Id)
Start-Process "https://dev.azure.com/msazure/Intune/_git/xplat-Android-MAM/pullrequest/$Id"
