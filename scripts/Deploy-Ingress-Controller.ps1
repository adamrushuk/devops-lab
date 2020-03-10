# Deploy an AKS Ingress Controller

<#
# Testing
$env:AKS_RG_NAME = "rush-rg-aks-dev-001"
$env:AKS_CLUSTER_NAME = "rush-aks-001"
#>

# Setting k8s current context
$message = "Merging AKS credentials"
Write-Output "STARTED: $message..."
az aks get-credentials --resource-group $env:AKS_RG_NAME --name $env:AKS_CLUSTER_NAME --overwrite-existing
Write-Output "FINISHED: $message.`n"

# Create a namespace for your ingress resources
$message = "Creating namespace"
Write-Output "STARTED: $message..."
kubectl apply -f ./manifests/namespace.yml
Write-Output "FINISHED: $message.`n"


#region NGINX Ingress
$message = "[HELM] Installing NGINX ingress controller"
Write-Output "STARTED: $message..."


# Add the official stable repository
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

# Check if Helm release installed already
$helmReleaseName = "nginx-ingress"
$helmDeployedList = helm list --namespace ingress-tls --output json | ConvertFrom-Json

if ($helmReleaseName -in $helmDeployedList.Releases.Name) {
    Write-Output "`nSKIPPING: [$helmReleaseName] already deployed."
} else {
    Write-Output "`nSTARTED: Installing helm release: [$helmReleaseName]..."

    # Use Helm to deploy an NGINX ingress controller
    # helm install nginx-ingress stable/nginx-ingress `
    #     --namespace ingress-tls `
    #     --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    #     --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
    #     --set controller.extraArgs.v=3

    # helm upgrade [RELEASE] [CHART] [flags]
    # helm upgrade something ./path/to/my/chart -f my-values.yaml --install --atomic
    # helm upgrade `
    #     nginx-ingress stable/nginx-ingress `
    #     --install --atomic `
    #     --namespace ingress-tls `
    #     --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    #     --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
    #     --set controller.extraArgs.v=3

    # [OPTIONAL] args
    # --set controller.config.hsts='"false"'
    # --set controller.extraArgs.v=3 `
    # --set controller.replicaCount=2 `
    # --debug --dry-run

    # helm upgrade [RELEASE] [CHART] [flags]
    helm upgrade nginx-ingress stable/nginx-ingress `
        --namespace ingress-tls `
        --install --atomic `
        -f ./nginx/nginx_values.yaml
        # --debug --dry-run
}

# Check nginx-ingress resources
helm list
kubectl get all -n ingress-tls -l app=nginx-ingress
kubectl get ing -n ingress-tls

Write-Output "FINISHED: $message."
#endregion


#region Troubleshooting
<#
# * IMPORTANT
# permanently save the namespace for all subsequent kubectl commands in that context
kubectl config set-context --current --namespace=ingress-tls

# Check the Ingress Resource Events
$ingressControllerPodName = kubectl get pod -l component=controller -o jsonpath="{.items[0].metadata.name}"
kubectl get ing
kubectl get ing ingress -o yaml
kubectl describe ing ingress
kubectl describe ing ingress-static

kubectl get svc nginx-ingress-controller
kubectl describe pod $ingressControllerPodName

kubectl get configmap -n ingress-tls
kubectl describe configmap -n ingress-tls

# Check the Ingress Controller Logs
kubectl logs -f -l component=controller --all-containers=true

# Check the NginX Configuration
# NginX vscode extension: https://marketplace.visualstudio.com/items?itemName=raynigon.nginx-formatter
# Search nginx.conf for location {} blocks, including "$service_name" etc
# Ensure $namespace, $ingress_name, $service_name, and $service_port are correct
kubectl get pods
kubectl exec -it $ingressControllerPodName cat /etc/nginx/nginx.conf > nginx.conf

# Check Stats within Controller pod
kubectl exec -it $ingressControllerPodName /bin/bash
curl http://localhost/nginx_status

# Check if used Services Exist
kubectl get svc --all-namespaces

# Check default backend pod
kubectl describe pods -l component=default-backend
#>
#endregion Troubleshooting
