# Terraform init

# Set preferences
$VerbosePreference = if ($env:CI_DEBUG -eq "true") { "Continue" } else { "SilentlyContinue" }
# Ensure any PowerShell errors fail the build (try/catch wont work for non-PowerShell CLI commands)
$ErrorActionPreference = "Stop"

terraform version

# Change into TF folder location
Push-Location -Path .\terraform

# Download required TF resources
$message = "Initialising Terraform environment"
Write-Output "STARTED: $message..."
terraform init
Write-Output "FINISHED: $message."

# Revert to previous folder location
Pop-Location
