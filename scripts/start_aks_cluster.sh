#! /usr/bin/env bash
#
# Starts AKS Cluster
#
# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Prereqs as this is a preview feature: https://docs.microsoft.com/en-us/azure/aks/start-stop-cluster
# Install the aks-preview extension
az extension add --name aks-preview

# Update the extension to make sure you have the latest version installed
az extension update --name aks-preview

# Check AKS power state
aks_power_state=$(az aks show --name "$AKS_CLUSTER_NAME" --resource-group "$AKS_RG_NAME" --query 'powerState.code')
if [ "$aks_power_state" == "Running" ]; then
    echo -e "\nSKIPPING: $AKS_CLUSTER_NAME AKS Cluster state is [$aks_power_state]."
else
    # Start AKS Cluster
    message="Starting AKS Cluster: [$AKS_CLUSTER_NAME]"
    echo -e "\nSTARTED: $message..."
    az aks start --name "$AKS_CLUSTER_NAME" --resource-group "$AKS_RG_NAME"
    echo -e "FINISHED: $message."
fi
