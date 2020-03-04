# Deploy Velero

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

#region Velero
# https://github.com/vmware-tanzu/helm-charts/blob/master/charts/velero/README.md
$message = "[HELM] Installing Velero"
Write-Output "STARTED: $message..."

# Add the Helm repository
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts

# Update your local Helm chart repository cache
helm repo update

# Check if Helm release installed already
$helmReleaseName = "Velero"
$helmDeployedList = helm list --namespace velero --output json | ConvertFrom-Json

if ($helmReleaseName -in $helmDeployedList.Releases.Name) {
    Write-Output "SKIPPING: [$helmReleaseName] already deployed."
} else {
    Write-Output "STARTED: Installing Helm release: [$helmReleaseName]..."

    # helm upgrade [RELEASE] [CHART] [flags]
    # helm upgrade something ./path/to/my/chart -f my-values.yaml --install --atomic
    # TODO: complete all values below
    # helm install --namespace velero `
    #     --set configuration.provider=azure `
    #     --set-file credentials.secretContents.cloud=<FULL PATH TO FILE> `
    #     --set configuration.backupStorageLocation.name=azure `
    #     --set configuration.backupStorageLocation.bucket=velero `
    #     --set configuration.backupStorageLocation.config.region=uksouth `
    #     --set configuration.volumeSnapshotLocation.name=azure `
    #     --set configuration.volumeSnapshotLocation.config.region=uksouth `
    #     --set image.repository=velero/velero `
    #     --set image.tag=v1.3.0 `
    #     --set image.pullPolicy=IfNotPresent `
    #     --set initContainers[0].name=velero-plugin-for-microsoft-azure `
    #     --set initContainers[0].image=velero/velero-plugin-for-microsoft-azure:v1.0.1 `
    #     --set initContainers[0].volumeMounts[0].mountPath=/target `
    #     --set initContainers[0].volumeMounts[0].name=plugins `
    #     vmware-tanzu/velero

    # [OPTIONAL] args
}

# Verify
# Show Velero pods
kubectl get pods -o wide --namespace velero

Write-Output "FINISHED: $message.`n"
#endregion
