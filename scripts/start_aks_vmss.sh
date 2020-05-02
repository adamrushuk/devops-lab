#!/bin/bash
# Finds and starts AKS VMSS

# Ensure strict mode and predictable pipeline failure
set -euo pipefail

# Get AKS node resource group name
nodeResourceGroup=$(az aks show --resource-group "$AKS_RG_NAME" --name "$AKS_CLUSTER_NAME" --query nodeResourceGroup -o tsv)

# Get VMSS
vmss_name=$(az vmss list --resource-group "$nodeResourceGroup" --query "[].name" -o tsv)

# Start VMSS
message="Starting VMSS: [$vmss_name]"
echo -e "\nSTARTED: $message..."
az vmss start --name "$vmss_name" --resource-group "$nodeResourceGroup"
echo -e "FINISHED: $message."
