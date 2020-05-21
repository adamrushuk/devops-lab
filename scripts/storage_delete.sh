#! /usr/bin/env bash
#
# deletes the azure resource group, storage account and storage container, used to store terraform remote state

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Resource Group
taskMessage="Deleting Resource Group"
echo "STARTED: $taskMessage..."
az group delete --name "$TERRAFORM_STORAGE_RG" --yes
echo "FINISHED: $taskMessage."
