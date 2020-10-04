#! /usr/bin/env bash
#
# apply kubernetes manifests

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Replace tokens
# local testing - manually add env vars
# EMAIL_ADDRESS="certadmin@domain.com"
# DNS_DOMAIN_NAME="nexus.thehypepipe.co.uk"
# CERT_API_ENVIRONMENT="staging"
pwsh -Command "./scripts/Replace-Tokens.ps1" -targetFilePattern "./manifests/*.yml"

# Setting k8s current context
message="Merging AKS credentials"
echo "STARTED: $message..."
az aks get-credentials --resource-group "$AKS_RG_NAME" --name "$AKS_CLUSTER_NAME" --overwrite-existing --admin
echo "FINISHED: $message."

# Testing kubectl
kubectl version --short

# Apply manifests
message="Applying Kubernetes manifests"
echo "STARTED: $message..."

# external-dns
kubectl apply -n ingress -f ./manifests/external-dns.yml
echo "FINISHED: $message."
