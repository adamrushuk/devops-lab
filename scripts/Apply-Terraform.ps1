# Terraform Apply

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
# Apply terraform
$message = "Applying Terraform configuration"
Write-Output "STARTED: $message..."
terraform apply -auto-approve tfplan
Write-Output "FINISHED: $message."
#endregion



# Revert to previous folder location
Pop-Location
