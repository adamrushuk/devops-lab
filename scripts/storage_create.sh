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
STORAGE_ID=$(az storage account create --name "$TERRAFORM_STORAGE_ACCOUNT" \
    --resource-group "$TERRAFORM_STORAGE_RG" --location "$LOCATION" --sku "Standard_LRS" --query id --output tsv)
echo "FINISHED: $taskMessage."

# Storage Container
taskMessage="Creating Storage Container"
echo "STARTED: $taskMessage..."
az storage container create --name "$TERRAFORM_STORAGE_CONTAINER" --account-name "$TERRAFORM_STORAGE_ACCOUNT"
echo "FINISHED: $taskMessage."

# Storage Container Role Assignment
taskMessage="Storage Container Role Assignment"
echo "STARTED: $taskMessage..."
# define container scope
TERRAFORM_STORAGE_CONTAINER_SCOPE="$STORAGE_ID/blobServices/default/containers/$TERRAFORM_STORAGE_CONTAINER"
echo "$TERRAFORM_STORAGE_CONTAINER_SCOPE"

# assign rbac
az role assignment create --assignee "$ARM_CLIENT_ID" --role "Storage Blob Data Contributor" \
    --scope "$TERRAFORM_STORAGE_CONTAINER_SCOPE"
echo "FINISHED: $taskMessage."
