#! /usr/bin/env bash
#
# Starts AKS Cluster
#
# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# info
az version

# Check AKS power state
aks_power_state=$(az aks show --name "$AKS_CLUSTER_NAME" --resource-group "$AKS_RG_NAME" --output tsv --query 'powerState.code')
echo -e "\n[$AKS_CLUSTER_NAME] AKS Cluster power state is [$aks_power_state]."

if [ "$aks_power_state" == "Running" ]; then
    echo -e "\nSKIPPING: $AKS_CLUSTER_NAME AKS Cluster is already running."
else
    # Start AKS Cluster
    message="Starting AKS Cluster: [$AKS_CLUSTER_NAME]"
    echo -e "\nSTARTED: $message..."
    az aks start --name "$AKS_CLUSTER_NAME" --resource-group "$AKS_RG_NAME"
    echo -e "FINISHED: $message."
fi
