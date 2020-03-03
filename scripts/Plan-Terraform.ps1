# Terraform Plan

#region Vars
# Set preferences
$VerbosePreference = if ($env:CI_DEBUG -eq "true") { "Continue" } else { "SilentlyContinue" }
# Ensure any PowerShell errors fail the build (try/catch wont work for non-PowerShell CLI commands)
$ErrorActionPreference = "Stop"
#endregion



#region Prep
# Info
Get-Command terraform | Select-Object Name, Source
terraform version

# Change into TF folder location
Push-Location -Path .\terraform
#endregion



#region Terraform
# Plan with differential output
$message = "Planning Terraform configuration"
Write-Output "STARTED: $message..."
terraform plan -out=tfplan
Write-Output "FINISHED: $message."

Write-Output "Terraform Plan - Generated on: $(Get-Date)`n" > diff.txt
terraform show -no-color tfplan | Tee-Object -FilePath diff.txt
#endregion



# Revert to previous folder location
Pop-Location
