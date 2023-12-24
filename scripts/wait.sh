#! /usr/bin/env bash

# Waits for resources to be "Ready" before allowing build pipeline to continue

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Get AKS creds
message="Merging AKS credentials"
echo -e "\nSTARTED: $message..."
az aks get-credentials --resource-group "$AKS_RG_NAME" --name "$AKS_CLUSTER_NAME" --overwrite-existing --admin
echo -e "FINISHED: $message.\n"

# Testing kubectl
kubectl version

# Wait
pod_name=$(kubectl get pod --namespace nexus -l app.kubernetes.io/name=sonatype-nexus -o jsonpath="{.items[0].metadata.name}")
message="Waiting for Ready condition on pod: [$pod_name]"
echo -e "\nSTARTED: $message..."
kubectl --namespace nexus wait pod "$pod_name" --for condition=ready --timeout=5m
echo -e "FINISHED: $message."
