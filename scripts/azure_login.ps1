# login to azure using azure service principal env vars

$taskMessage="Logging in to Azure"
Write-Output "STARTED: $taskMessage..."

# Write-Output "Env vars loaded for Client ID: [$($env:ARM_CLIENT_ID)]"

# Login PowerShell and Az CLI sessions with Service Principal env vars
Write-Output "Authenticating PowerShell and Az CLI sessions using env vars..."
$servicePrincipleCredential = [pscredential]::new($env:ARM_CLIENT_ID, (ConvertTo-SecureString $env:ARM_CLIENT_SECRET -AsPlainText -Force))
Connect-AzAccount -ServicePrincipal -Tenant $env:ARM_TENANT_ID -Credential $servicePrincipleCredential -Subscription $env:ARM_SUBSCRIPTION_ID -Verbose

# Set context to specific subscription
az login --service-principal --username $env:ARM_CLIENT_ID --password $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID
az account set --subscription $env:ARM_SUBSCRIPTION_ID
az account show

Write-Output "PowerShell and Az CLI session logins complete."

Write-Output "FINISHED: $taskMessage."
