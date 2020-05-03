#!/bin/bash
#
# apply kubernetes manifests

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Replace tokens
# local testing - manually add env vars
# EMAIL_ADDRESS="admin@domain.com"
# DNS_DOMAIN_NAME="nexus.thehypepipe.co.uk"
# CERT_API_ENVIRONMENT="staging"
pwsh -Command "./scripts/Replace-Tokens.ps1" -targetFilePattern "./manifests/*.yml"

# Setting k8s current context
message="Merging AKS credentials"
echo "STARTED: $message..."
az aks get-credentials --resource-group "$AKS_RG_NAME" --name "$AKS_CLUSTER_NAME" --overwrite-existing
echo "FINISHED: $message."

# Testing kubectl
kubectl version --short

# Apply manifests
message="Applying Kubernetes manifests"
echo "STARTED: $message..."
echo "ENABLE_TLS_INGRESS: [$ENABLE_TLS_INGRESS]"

# ClusterIssuers
if [[ $ENABLE_TLS_INGRESS == "true" ]]; then
    echo "APPLYING: ClusterIssuers..."
    kubectl apply -f "./manifests/cluster-issuer-staging.yml"
    kubectl apply -f "./manifests/cluster-issuer-prod.yml"
else
    echo "SKIPPING: ClusterIssuers..."
fi

# Applications
echo "APPLYING: Applications..."
kubectl apply -n ingress -f "./manifests/nexus.yml"

# Ingress
# ConfigMap - NGINX Configuration options
# https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
# kubectl apply -n ingress -f ./manifests/nginx-configmap.yml

# default to basic http
ingressFilename="ingress-http.yml"
if [[ $ENABLE_TLS_INGRESS == "true" ]]; then
    ingressFilename="ingress-tls.yml"
fi
echo "APPLYING: Ingress [$ingressFilename]..."
kubectl apply -n ingress -f "./manifests/$ingressFilename"
echo "FINISHED: $message."
