# This will create an Azure resource group, Storage account and Storage container, used to store terraform remote state

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Resource Group
Write-Output "`nSTARTED: Creating Resource Group..."
az group create --location $env:LOCATION --name $env:TERRAFORM_STORAGE_RG
Write-Output "FINISHED: Creating Resource Group."

# Storage Account
Write-Output "`nSTARTED: Creating Storage Account..."
az storage account create --name $env:TERRAFORM_STORAGE_ACCOUNT --resource-group $env:TERRAFORM_STORAGE_RG --location $env:LOCATION --sku Standard_LRS
Write-Output "FINISHED: Creating Storage Account."

# Storage Container
Write-Output "`nSTARTED: Creating Storage Container..."
az storage container create --name "terraform" --account-name $env:TERRAFORM_STORAGE_ACCOUNT
Write-Output "FINISHED: Creating Storage Container."

# Get latest supported AKS version
Write-Output "`nSTARTED: Finding latest supported AKS version..."
$latest_aks_version = $(az aks get-versions -l $env:LOCATION --query "orchestrators[-1].orchestratorVersion" -o tsv)
Write-Output "Latest AKS Version: [$latest_aks_version]"
Write-Output "FINISHED: Finding latest supported AKS version.`n"
