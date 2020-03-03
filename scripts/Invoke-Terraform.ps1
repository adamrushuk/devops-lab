# Invoke Terraform commands

[CmdletBinding()]
param(
    $Command = "-h"
)

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
$taskMessage = "Running Terraform $Command"
Write-Verbose "`nSTARTED: $taskMessage...`n"

# Run CLI command
$output = & terraform $Command

# Error handling
if (-not $output) {
    Write-Error "`nERROR: $taskMessage.`n" -ErrorAction 'Continue'
    throw $_
} else {
    $output
    Write-Verbose "`nFINISHED: $taskMessage.`n"
}
#endregion



# Revert to previous folder location
Pop-Location
