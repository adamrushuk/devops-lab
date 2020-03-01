# Login to Azure using Azure Service Principal env vars

# Set preferences
$VerbosePreference = if ($env:CI_DEBUG -eq "true") { "Continue" } else { "SilentlyContinue" }
# Ensure any PowerShell errors fail the build (try/catch wont work for non-PowerShell CLI commands)
$ErrorActionPreference = "Stop"

# Output all env vars
if ($env:CI_DEBUG -eq "true") { Get-ChildItem env: | Select-Object Name, Value }

# Login to Az
$message = "Logging in to Azure"
Write-Verbose "STARTED: $message..."
az login --service-principal --tenant $env:ARM_TENANT_ID -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET | Out-Null
az account set --subscription $env:ARM_SUBSCRIPTION_ID
Write-Verbose "FINISHED: $message."
