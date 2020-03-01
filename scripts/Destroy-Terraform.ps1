# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Change into TF folder location
Push-Location -Path .\terraform

# Apply terraform
$message = "Destroying Terraform configuration"
Write-Output "STARTED: $message..."
terraform destroy -auto-approve
Write-Output "FINISHED: $message."

# Revert to previous folder location
Pop-Location
