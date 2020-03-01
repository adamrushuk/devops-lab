# This will create an Azure resource group, Storage account and Storage container, used to store terraform remote state

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Set prefs
# TODO: make dynamic depending on $env:CI_DEBUG
$VerbosePreference = "Continue"

# Resource Group
Write-Verbose "`nSTARTED: Creating Resource Group..."
az group create --location $env:LOCATION --name $env:TERRAFORM_STORAGE_RG

Write-Verbose "FINISHED: Creating Resource Group."

# Storage Account
$taskMessage = "Creating Storage Account"
Write-Verbose "STARTED: $taskMessage..."
try {
    az storage account create --name $env:TERRAFORM_STORAGE_ACCOUNT --resource-group $env:TERRAFORM_STORAGE_RG --location $env:LOCATION --sku Standard_LRS

    Write-Verbose "FINISHED: $taskMessage."
}
catch {
    Write-Error "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}




# Storage Container
Write-Verbose "`nSTARTED: Creating Storage Container..."
az storage container create --name "terraform" --account-name $env:TERRAFORM_STORAGE_ACCOUNT
Write-Verbose "FINISHED: Creating Storage Container."

# Get latest supported AKS version
Write-Verbose "`nSTARTED: Finding latest supported AKS version..."
$latest_aks_version = $(az aks get-versions -l $env:LOCATION --query "orchestrators[-1].orchestratorVersion" -o tsv)
Write-Verbose "Latest AKS Version: [$latest_aks_version]"
Write-Verbose "FINISHED: Finding latest supported AKS version.`n"
