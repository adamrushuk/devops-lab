# Deploy Velero

# ! WARNING HELM v3 NOT CURRENTLY SUPPORTED!
# https://github.com/vmware-tanzu/helm-charts/issues/7

# Reference
# https://github.com/vmware-tanzu/helm-charts/tree/master/charts/velero#if-using-helm-2-tiller-cluster-admin-permissions
# https://github.com/vmware-tanzu/helm-charts/blob/master/charts/velero/values.yaml
# https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure/blob/master/backupstoragelocation.md
# https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure/blob/master/volumesnapshotlocation.md

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Version info
Write-Output "INFO: Velero Chart currently support Helm v2 CLI. `nTrack issue here: https://github.com/vmware-tanzu/helm-charts/issues/7"
helm version --debug


#region Velero
# https://github.com/vmware-tanzu/helm-charts/blob/master/charts/velero/README.md
$message = "[HELM] Installing Velero"
Write-Output "STARTED: $message..."

# Helm 2 - Tiller config
# https://github.com/vmware-tanzu/helm-charts/tree/master/charts/velero#if-using-helm-2-tiller-cluster-admin-permissions
# This is now done in Init-Helm.ps1

# Add the Helm repository
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts

# Update your local Helm chart repository cache
helm repo update
helm repo list

# DEBUG
# Troubleshooting "helm install context deadline exceeded" error
if ($env:CI_DEBUG -eq "true") {
    Write-Output "`nDEBUG: Showing all kubernetes resources, before installing [Velero]..."
    kubectl get all --all-namespaces
}

# Check if Helm release installed already
$helmReleaseName = "Velero"
$helmDeployedList = helm list --output json | ConvertFrom-Json

if ($helmReleaseName -in $helmDeployedList.Releases.Name) {
    Write-Output "SKIPPING: [$helmReleaseName] already deployed."
} else {
    Write-Output "STARTED: Installing Helm release: [$helmReleaseName]..."

    <#
    # Testing
    $env:CREDENTIALS_VELERO = (SEE ./velero/Create-VeleroServicePrinciple.ps1)
    $env:LOCATION = "uksouth"
    $env:VELERO_STORAGE_RG = "rush-rg-velero-dev-001"
    $env:VELERO_STORAGE_ACCOUNT = "rushstbckuksouth001"

    $env:CREDENTIALS_VELERO
    $env:LOCATION
    $env:VELERO_STORAGE_RG
    $env:VELERO_STORAGE_ACCOUNT

    kubectl get namespace
    kubectl create namespace velero
    #>

    # https://github.com/vmware-tanzu/helm-charts/tree/master/charts/velero#option-1-cli-commands

    # Helm v2
    # helm install -h
    # helm install [CHART] [flags]
    # helm install vmware-tanzu/velero `
    #     --name velero `
    #     --namespace velero `
    #     --set configuration.backupStorageLocation.bucket=velero `
    #     --set configuration.backupStorageLocation.config.resourceGroup=$($env:VELERO_STORAGE_RG) `
    #     --set configuration.backupStorageLocation.config.storageAccount=$($env:VELERO_STORAGE_ACCOUNT) `
    #     --set configuration.backupStorageLocation.name=azure `
    #     --set configuration.provider=azure `
    #     --set configuration.volumeSnapshotLocation.config.resourceGroup=$($env:VELERO_STORAGE_RG) `
    #     --set configuration.volumeSnapshotLocation.name=azure `
    #     --set credentials.secretContents.cloud=$($env:CREDENTIALS_VELERO) `
    #     --set image.pullPolicy=IfNotPresent `
    #     --set image.repository=velero/velero `
    #     --set image.tag=v1.3.0 `
    #     --set initContainers[0].image=velero/velero-plugin-for-microsoft-azure:v1.0.1 `
    #     --set initContainers[0].name=velero-plugin-for-microsoft-azure `
    #     --set initContainers[0].volumeMounts[0].mountPath=/target `
    #     --set initContainers[0].volumeMounts[0].name=plugins
        # --dry-run --debug

    # [OPTIONAL] args
    # --set configuration.volumeSnapshotLocation.config.apiTimeout=5m `
    # Set log-level for Velero pod. Default: info. Other options: debug, warning, error, fatal, panic.
    # --set configuration.logLevel=debug `

    # [Incorrect] args (produced errors)?
    # --set configuration.backupStorageLocation.config.region=$($env:LOCATION) `
    # --set configuration.volumeSnapshotLocation.config.region=$($env:LOCATION) `


    # Helm
    # Show latest chart version
    helm search vmware-tanzu/velero


    # # OPTION 2 - YAML file
    # https://github.com/vmware-tanzu/helm-charts/tree/master/charts/velero#option-2-yaml-file
    # still use '--set` for dynamic values
    # https://stackoverflow.com/questions/52854092/how-to-use-powershell-splatting-for-azure-cli
    helm install vmware-tanzu/velero `
        --name velero `
        --version 2.9.1 `
        --namespace velero `
        --atomic `
        --timeout 600 `
        --values ./velero/velero-values.yaml `
        --set configuration.backupStorageLocation.config.resourceGroup=$($env:VELERO_STORAGE_RG) `
        --set configuration.backupStorageLocation.config.storageAccount=$($env:VELERO_STORAGE_ACCOUNT) `
        --set configuration.volumeSnapshotLocation.config.resourceGroup=$($env:VELERO_STORAGE_RG) `
        --set credentials.secretContents.cloud=$($env:CREDENTIALS_VELERO) `
        --set configuration.logLevel=debug `
        --debug

    <#
    # Monitor deployment progress
    kubectl get all -n velero
    kubectl describe pod -n velero
    kubectl get events --sort-by=.metadata.creationTimestamp --namespace velero
    kubectl get events --namespace velero --watch
    kubectl get deployment -n velero --watch
    kubectl logs deployment/velero -n velero -f
    kubectl logs deployment/velero -n velero -f | sls warning, error, unauthorized_client

    # Cleanup
    helm ls --all velero
    helm del --purge velero --dry-run --debug
    helm del --purge velero
    kubectl delete namespace velero
    #>
}

# Verify
# Show Velero pods
kubectl get pods -o wide --namespace velero

Write-Output "FINISHED: $message.`n"
#endregion
