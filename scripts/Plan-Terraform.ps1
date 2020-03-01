# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Change into TF folder location
Push-Location -Path .\terraform

# Plan with differential output
$message = "Planning Terraform configuration"
Write-Output "STARTED: $message..."
terraform plan -out=tfplan
Write-Output "FINISHED: $message."

Write-Output "Terraform Plan - Generated on: $(Get-Date)`n" > diff.txt
terraform show -no-color tfplan | Tee-Object -FilePath diff.txt

# Revert to previous folder location
Pop-Location
