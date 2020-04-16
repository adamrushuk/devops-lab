#!/bin/bash

# Waits for resources to be "Ready" before allowing build pipeline to continue

# Ensure strict mode and predictable pipeline failure
set -euo pipefail

# Get AKS creds
message="Merging AKS credentials"
echo -e "\nSTARTED: $message..."
az aks get-credentials --resource-group "$AKS_RG_NAME" --name "$AKS_CLUSTER_NAME" --overwrite-existing
echo -e "FINISHED: $message.\n"

# Testing kubectl
kubectl version --short

# Wait
kubectl --namespace ingress wait pod nexus-0 --for condition=ready --timeout=5m

echo -e "FINISHED: $message."
