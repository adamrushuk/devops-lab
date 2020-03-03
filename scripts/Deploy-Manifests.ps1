# Deploy kubernetes manifest files

#region Vars
# Set preferences
$VerbosePreference = if ($env:CI_DEBUG -eq "true") { "Continue" } else { "SilentlyContinue" }
# Ensure any PowerShell errors fail the build (try/catch wont work for non-PowerShell CLI commands)
$ErrorActionPreference = "Stop"
#endregion



# Replace tokens
<#
    # local testing - manually add env vars
    $env:EMAIL_ADDRESS = "admin@domain.com"
    $env:DNS_DOMAIN_NAME = "aks.thehypepipe.co.uk"
    $env:CERT_API_ENVIRONMENT = "staging"
#>
./scripts/Replace-Tokens.ps1 -targetFilePattern './manifests/*.yml'

# Setting k8s current context
$message = "Merging AKS credentials"
Write-Output "`nSTARTED: $message..."
az aks get-credentials --resource-group $env:AKS_RG_NAME --name $env:AKS_CLUSTER_NAME --overwrite-existing
Write-Output "FINISHED: $message.`n"

# Testing kubectl
kubectl version --short

# Apply manifests
$message = "Applying Kubernetes manifests"
Write-Output "`nSTARTED: $message..."

# "ingress-tls" namespace created in Deploy-Ingress-Controller.ps1

# [OPTIONAL] apply whole folder
# kubectl apply -n ingress-tls -f ./manifests

# ClusterIssuers
Write-Output "`nAPPLYING: ClusterIssuers..."
kubectl apply -f ./manifests/cluster-issuer-staging.yml
kubectl apply -f ./manifests/cluster-issuer-prod.yml

# Applications
Write-Output "`nAPPLYING: Applications..."
kubectl apply -n ingress-tls -f ./manifests/azure-vote.yml

# Ingress
Write-Output "`nAPPLYING: Ingress..."
kubectl apply -n ingress-tls -f ./manifests/ingress.yml

<#
# DEBUG
kubectl delete -n ingress-tls -f ./manifests/ingress.yml
kubectl delete -n ingress-tls -f ./manifests/azure-vote.yml
#>
Write-Output "FINISHED: $message."
