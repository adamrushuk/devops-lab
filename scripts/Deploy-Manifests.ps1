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
    $env:DNS_DOMAIN_NAME = "nexus.thehypepipe.co.uk"
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

Write-Output "`nENABLE_TLS_INGRESS: [$env:ENABLE_TLS_INGRESS]"

# ClusterIssuers
if ($env:ENABLE_TLS_INGRESS -eq "true") {
    Write-Output "`nAPPLYING: ClusterIssuers..."
    kubectl apply -f ./manifests/cluster-issuer-staging.yml
    kubectl apply -f ./manifests/cluster-issuer-prod.yml
} else {
    Write-Output "`nSKIPPING: ClusterIssuers..."
}

# Applications
Write-Output "`nAPPLYING: Applications..."
# kubectl apply -n ingress-tls -f ./manifests/azure-vote.yml
kubectl apply -n ingress-tls -f ./manifests/nexus.yml

# Ingress
# default to basic http
$ingressFilename = "ingress-http.yml"
if ($env:ENABLE_TLS_INGRESS -eq "true") {
    $ingressFilename = "ingress-tls.yml"
}
Write-Output "`nAPPLYING: Ingress [$ingressFilename]..."
kubectl apply -n ingress-tls -f ./manifests/$ingressFilename

<#
# DEBUG
curl -I http://nexus.thehypepipe.co.uk/
curl -I https://nexus.thehypepipe.co.uk/

kubectl get ing -A
kubectl get ing -n ingress-tls
kubectl describe ing -n ingress-tls
kubectl get events --sort-by=.metadata.creationTimestamp -A
kubectl get events -w -A

kubectl apply -n ingress-tls -f ./manifests/ingress-http.yml
kubectl apply -n ingress-tls -f ./manifests/ingress-tls.yml
kubectl apply -n ingress-tls -f ./manifests/nginx-configmap.yml

kubectl delete -n ingress-tls -f ./manifests/ingress-http.yml
kubectl delete -n ingress-tls -f ./manifests/ingress-tls.yml
kubectl delete ing -n ingress-tls --all

# Cleanup
helm list
helm del --purge nginx-ingress
#>
Write-Output "FINISHED: $message."
