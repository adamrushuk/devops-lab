# Deploy an AKS Ingress Controller

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
$helmDeployedList = helm list -n ingress-tls -o json | ConvertFrom-Json

if ($helmReleaseName -in $helmDeployedList.Name) {
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
    helm upgrade `
        nginx-ingress stable/nginx-ingress `
        --install --atomic `
        --namespace ingress-tls `
        --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
        --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
        --set controller.extraArgs.v=3

    # [OPTIONAL] args
    # --set controller.extraArgs.v=3 `
    # --set controller.replicaCount=2 `
}

# Check nginx-ingress resources
helm list --all-namespaces
kubectl get all -n ingress-tls -l app=nginx-ingress

Write-Output "FINISHED: $message."
#endregion
