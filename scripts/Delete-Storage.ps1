# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Change into TF folder location
$message = "Deleting storage resource group: [$env:TERRAFORM_STORAGE_RG]"
Write-Output "STARTED: $message..."
az group delete --name $env:TERRAFORM_STORAGE_RG --yes
Write-Output "FINISHED: $message."
