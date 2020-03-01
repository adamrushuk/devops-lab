# Login to Azure using Azure Service Principal env vars

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# DEBUG: Output environment variables
if ($env:CI_DEBUG -eq "true") { Get-ChildItem env: | Select-Object Name, Value }

# Login to Az
$message = "Logging in to Azure"
Write-Output "STARTED: $message..."
az login --service-principal --tenant $env:ARM_TENANT_ID -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET | Out-Null
az account set --subscription $env:ARM_SUBSCRIPTION_ID
Write-Output "FINISHED: $message."
