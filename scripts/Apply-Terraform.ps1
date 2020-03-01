# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Change into TF folder location
Push-Location -Path .\terraform

# Apply terraform
$message = "Applying Terraform configuration"
Write-Output "STARTED: $message..."
terraform apply -auto-approve
Write-Output "FINISHED: $message."

# Revert to previous folder location
Pop-Location
