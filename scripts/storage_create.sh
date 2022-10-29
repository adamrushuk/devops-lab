#! /usr/bin/env bash
#
# creates an azure resource group, storage account and storage container, used to store terraform remote state

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Resource Group
taskMessage="Creating Resource Group"
echo "STARTED: $taskMessage..."
az group create --location "$LOCATION" --name "$TERRAFORM_STORAGE_RG"
echo "FINISHED: $taskMessage."

# Storage Account
taskMessage="Creating Storage Account"
echo "STARTED: $taskMessage..."
az storage account create --name "$TERRAFORM_STORAGE_ACCOUNT" --resource-group "$TERRAFORM_STORAGE_RG" --location "$LOCATION" --sku "Standard_LRS"
echo "FINISHED: $taskMessage."

# Storage Container
taskMessage="Creating Storage Container"
echo "STARTED: $taskMessage..."
az storage container create --name "terraform" --account-name "$TERRAFORM_STORAGE_ACCOUNT"
echo "FINISHED: $taskMessage."
