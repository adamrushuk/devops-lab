# Terraform init

#region Vars
# Set preferences
$VerbosePreference = if ($env:CI_DEBUG -eq "true") { "Continue" } else { "SilentlyContinue" }
# Ensure any PowerShell errors fail the build (try/catch wont work for non-PowerShell CLI commands)
$ErrorActionPreference = "Stop"
#endregion



# Change into TF folder location
Push-Location -Path .\terraform
terraform version



#region Terraform init
$taskMessage = "Initialising Terraform environment"
Write-Verbose "STARTED: $taskMessage..."

# Run CLI command
$output = terraform init

# Error handling
if (-not $output) {
    Write-Error "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
} else {
    $output
    Write-Verbose "FINISHED: $taskMessage."
}
#endregion



# Revert to previous folder location
Pop-Location
