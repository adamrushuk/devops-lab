# This will create an Azure resource group, Storage account and Storage container, used to store terraform remote state

# Set preferences
$VerbosePreference = if ($env:CI_DEBUG -eq "true") { "Continue" } else { "SilentlyContinue" }
# Ensure any PowerShell errors fail the build (try/catch wont work for non-PowerShell CLI commands)
$ErrorActionPreference = "Stop"


#region Resource Group
$taskMessage = "Creating Resource Group"
Write-Verbose "STARTED: $taskMessage..."

# Run CLI command
$rgJson = az group create --location $env:LOCATION --name $env:TERRAFORM_STORAGE_RG | ConvertFrom-Json

# Error handling
if (-not $rgJson) {
    Write-Error "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
} else {
    $rgJson
    Write-Verbose "FINISHED: $taskMessage."
}
#endregion



#region Storage Account
$taskMessage = "Creating Storage Account"
Write-Verbose "STARTED: $taskMessage..."

# Run CLI command
$stAccJson = az storage account create --name $env:TERRAFORM_STORAGE_ACCOUNT --resource-group $env:TERRAFORM_STORAGE_RG --location $env:LOCATION --sku Standard_LRS | ConvertFrom-Json

# Error handling
if (-not $stAccJson) {
    Write-Error "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
} else {
    $stAccJson
    Write-Verbose "FINISHED: $taskMessage."
}
#endregion



#region Storage Container
$taskMessage = "Creating Storage Container"
Write-Verbose "STARTED: $taskMessage..."

# Run CLI command
$stContJson = az storage container create --name "terraform" --account-name $env:TERRAFORM_STORAGE_ACCOUNT | ConvertFrom-Json

# Error handling
if (-not $stContJson) {
    Write-Error "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
} else {
    $stContJson
    Write-Verbose "FINISHED: $taskMessage."
}
#endregion



#region Get latest supported AKS version
$taskMessage = "Finding latest supported AKS version"
Write-Verbose "STARTED: $taskMessage..."

# Run CLI command
$latest_aks_version = $(az aks get-versions -l $env:LOCATION --query "orchestrators[-1].orchestratorVersion" -o tsv)

# Error handling
if (-not $latest_aks_version) {
    Write-Error "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
} else {
    $latest_aks_version
    Write-Verbose "FINISHED: $taskMessage."
}
#endregion
