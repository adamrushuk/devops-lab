# Azure Functions profile.ps1
#
# This profile.ps1 will get executed every "cold start" of your Function App.
# "cold start" occurs when:
#
# * A Function App starts up for the very first time
# * A Function App starts up after being de-allocated due to inactivity
#
# You can define helper functions, run commands, or specify environment variables
# NOTE: any variables defined that are not environment variables will get reset after the first execution

# Authenticate with Azure PowerShell using MSI.
# Remove this if you are not planning on using MSI or Azure PowerShell.
if ($env:MSI_SECRET -and (Get-Module -ListAvailable Az.Accounts)) {
    Write-Output "Authenticating PowerShell using Managed Identity..."
    Connect-AzAccount -Identity
}
elseif ($env:ARM_TENANT_ID -and $env:ARM_SUBSCRIPTION_ID -and $env:ARM_CLIENT_ID -and $env:ARM_CLIENT_SECRET) {
    Write-Output "Authenticating PowerShell session using env vars..."
    $servicePrincipleCredential = [pscredential]::new($env:ARM_CLIENT_ID, (ConvertTo-SecureString $env:ARM_CLIENT_SECRET -AsPlainText -Force))
    Connect-AzAccount -ServicePrincipal -Tenant $env:ARM_TENANT_ID -Credential $servicePrincipleCredential -Subscription $env:ARM_SUBSCRIPTION_ID -Verbose
}

# Uncomment the next line to enable legacy AzureRm alias in Azure PowerShell.
# Enable-AzureRmAlias

# You can also define functions or aliases that can be referenced in any of your PowerShell functions.
