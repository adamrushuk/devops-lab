# This will create an Azure resource group, Storage account and Storage container, used to store terraform remote state

# Set prefs
# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# TODO: make dynamic depending on $env:CI_DEBUG
# $VerbosePreference = "Continue"


#region Resource Group
# Update task description
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
# Update task description
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


# Storage Container
Write-Verbose "`nSTARTED: Creating Storage Container..."
az storage container create --name "terraform" --account-name $env:TERRAFORM_STORAGE_ACCOUNT
Write-Verbose "FINISHED: Creating Storage Container."

# Get latest supported AKS version
Write-Verbose "`nSTARTED: Finding latest supported AKS version..."
$latest_aks_version = $(az aks get-versions -l $env:LOCATION --query "orchestrators[-1].orchestratorVersion" -o tsv)
Write-Verbose "Latest AKS Version: [$latest_aks_version]"
Write-Verbose "FINISHED: Finding latest supported AKS version.`n"
