#! /usr/bin/env bash
#
# Finds and Deallocates AKS VMSS

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Get AKS node resource group name
nodeResourceGroup=$(az aks show --resource-group "$AKS_RG_NAME" --name "$AKS_CLUSTER_NAME" --query nodeResourceGroup -o tsv)

# Get VMSS
vmss_name=$(az vmss list --resource-group "$nodeResourceGroup" --query "[].name" -o tsv)

# Deallocate VMSS
message="Deallocating VMSS: [$vmss_name]"
echo -e "\nSTARTED: $message..."
az vmss deallocate --name "$vmss_name" --resource-group "$nodeResourceGroup"
echo -e "FINISHED: $message."
