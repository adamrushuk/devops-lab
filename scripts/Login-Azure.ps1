# Login to Azure using Azure Service Principal env vars

# Set preferences
$VerbosePreference = if ($env:CI_DEBUG -eq "true") { "Continue" } else { "SilentlyContinue" }
# Ensure any PowerShell errors fail the build (try/catch wont work for non-PowerShell CLI commands)
$ErrorActionPreference = "Stop"

# Output all env vars
if ($env:CI_DEBUG -eq "true") { Get-ChildItem env: | Select-Object Name, Value }



#region Login
$taskMessage = "Logging in to Azure"
Write-Verbose "STARTED: $taskMessage..."

# Run CLI command
$outputJson = az login --service-principal --tenant $env:ARM_TENANT_ID -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET | ConvertFrom-Json

# Error handling
if (-not $outputJson) {
    Write-Error "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
} else {
    Write-Verbose "FINISHED: $taskMessage."
}
#endregion



#region Subscription
$taskMessage = "Selecting Subscription"
Write-Verbose "STARTED: $taskMessage..."

# Run CLI command
$subOutputJson = az account set --subscription $env:ARM_SUBSCRIPTION_ID | ConvertFrom-Json

# Error handling
if (-not $subOutputJson) {
    Write-Error "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
} else {
    $subOutputJson
    Write-Verbose "FINISHED: $taskMessage."
}
#endregion

