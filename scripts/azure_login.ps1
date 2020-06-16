# login to azure using azure service principal env vars

$taskMessage="Logging in to Azure"
Write-Output "STARTED: $taskMessage..."
az login --service-principal --tenant "$env:ARM_TENANT_ID" -u "$env:ARM_CLIENT_ID" -p "$env:ARM_CLIENT_SECRET"
Write-Output "FINISHED: $taskMessage."

$taskMessage="Selecting Subscription"
Write-Output "STARTED: $taskMessage..."
az account set --subscription "$env:ARM_SUBSCRIPTION_ID"
Write-Output "FINISHED: $taskMessage."
