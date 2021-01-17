# Velero Notes

## Contents

- [Velero Notes](#velero-notes)
  - [Contents](#contents)
  - [TODO](#todo)
  - [Prereqs](#prereqs)
  - [Install CLI](#install-cli)
  - [Install Server (CLI)](#install-server-cli)
  - [Install Server (Helm)](#install-server-helm)
  - [Backup / Restore](#backup--restore)
    - [NGINX example (without PersistentVolumes)](#nginx-example-without-persistentvolumes)
    - [NGINX example (with PersistentVolumes)](#nginx-example-with-persistentvolumes)
    - [Nexus example (with PersistentVolumes)](#nexus-example-with-persistentvolumes)
  - [Prometheus Metrics](#prometheus-metrics)
  - [Troubleshooting](#troubleshooting)
  - [Cleanup](#cleanup)

## TODO

- [x] Complete test backup / restore
- [x] Test Velero Server install using CLI
- [x] Troubleshoot why Velero looks in wrong AKS resource group for disks to backup
- [x] Test Velero Server install using Helm
- [ ] Configure and test Restic for AzureFile backup support: https://velero.io/docs/v1.2.0/restic/

## Prereqs

- Follow Azure setup guide: https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#setup

```powershell
# Vars
$prefix = "rush"
$aksClusterName = "$($prefix)-aks-001"
$aksClusterResourceGroupName = "$($prefix)-rg-aks-dev-001"
$location = "uksouth"
$backupResourceGroupName = "$($prefix)-rg-velero-dev-001"
$snapshotResourceGroupName = "$($prefix)-rg-snap"
$storageAccountName = "$($prefix)stbckuksouth001"
$blobContainerName = "velero"

# Downloading latest credentials for AKS Cluster
az aks get-credentials --resource-group $aksClusterResourceGroupName --name $aksClusterName --overwrite-existing --admin

# [OPTIONAL] View AKS Dashboard
az aks browse --resource-group $aksClusterResourceGroupName --name $aksClusterName

# Create Resource Groups
az group create --name $backupResourceGroupName --location $location
az group create --name $snapshotResourceGroupName --location $location

# Create Storage Account
az storage account create `
  --name $storageAccountName `
  --resource-group $backupResourceGroupName `
  --sku Standard_LRS `
  --encryption-services blob `
  --https-only true `
  --kind BlobStorage `
  --access-tier Hot

# Create Blob Container
az storage container create -n $blobContainerName --public-access off --account-name $storageAccountName
```

## Install CLI

Follow these steps: https://velero.io/docs/master/basic-install/

```powershell
# Install velero via Chocolatey
choco install velero

# Show version
velero version
```

## Install Server (CLI)

```powershell
# Create namespace
kubectl get namespace
kubectl create namespace velero

# Check velero-plugin-for-microsoft-azure release version:
# https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure/releases

# Example
# velero install \
#     --provider azure \
#     --plugins velero/velero-plugin-for-microsoft-azure:v1.0.0 \
#     --bucket $BLOB_CONTAINER \
#     --secret-file ./credentials-velero \
#     --backup-location-config resourceGroup=$AZURE_BACKUP_RESOURCE_GROUP,storageAccount=$AZURE_STORAGE_ACCOUNT_ID[,subscriptionId=$AZURE_BACKUP_SUBSCRIPTION_ID] \
#     --snapshot-location-config apiTimeout=<YOUR_TIMEOUT>[,resourceGroup=$AZURE_BACKUP_RESOURCE_GROUP,subscriptionId=$AZURE_BACKUP_SUBSCRIPTION_ID]

# View help
velero install -h

# Install
velero install `
    --provider azure `
    --plugins velero/velero-plugin-for-microsoft-azure:v1.0.0 `
    --bucket $blobContainerName `
    --secret-file ./velero/credentials-velero `
    --backup-location-config resourceGroup=$backupResourceGroupName,storageAccount=$storageAccountName `
    --snapshot-location-config apiTimeout=5m,resourceGroup=$snapshotResourceGroupName `
    --v=3 `
    --dry-run

# Monitor deployment progress
kubectl get all -n velero
kubectl describe pod -n velero
kubectl get events --sort-by=.metadata.creationTimestamp --namespace velero
kubectl get events --sort-by=.metadata.creationTimestamp --namespace velero --watch
kubectl get deployment -n velero --watch
kubectl logs deployment/velero -n velero -f
```

## Install Server (Helm)

```powershell
# Create namespace
kubectl create namespace velero
kubectl get ns

# Show current config
helm repo list

# Add repo
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update

# Check chart versions
# Show latest chart version
helm search repo vmware-tanzu/velero

# Show all chart version
helm search repo vmware-tanzu/velero -l

# Show all chart versions starting with 2.9 (eg. 2.9.x)
helm search repo vmware-tanzu/velero -l --version ~2.9

# Install
helm install --namespace velero -f velero-values.yaml stable/velero
```

## Backup / Restore

### NGINX example (without PersistentVolumes)

```powershell
# Start the sample nginx app
kubectl apply -f ./velero/examples/nginx-app/base.yaml

# Check resources and wait for EXTERNAL-IP
kubectl get all -n nginx-example
kubectl get svc -n nginx-example -w

# Open browser to view NGINX default page
$newUrl = kubectl get svc my-nginx -n nginx-example --ignore-not-found -o jsonpath="http://{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}"
Write-Output "Browse to NGINX URL: $newUrl"

# Create a backup
velero backup create nginx-backup --include-namespaces nginx-example

# Check backup
velero backup get
velero backup describe nginx-backup
velero backup logs nginx-backup

# Simulate a disaster
kubectl get ns
kubectl get all -n nginx-example
kubectl delete namespace nginx-example
# Wait for the namespace to be deleted
kubectl get ns
kubectl get all -n nginx-example

# Restore your lost resources
velero restore create --from-backup nginx-backup

# Check resources and wait for EXTERNAL-IP
kubectl get ns
kubectl get all -n nginx-example
kubectl get svc -n nginx-example -w

$newUrl = kubectl get svc my-nginx -n nginx-example --ignore-not-found -o jsonpath="http://{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}"
Write-Output "Browse to new NGINX URL: $newUrl"
```

### NGINX example (with PersistentVolumes)

```powershell
# Start the nginx app
kubectl apply -f ./velero/examples/nginx-app/with-pv.yaml

# Monitor deployment progress
kubectl get all,pvc,pv -n nginx-pv
kubectl describe pod -n nginx-pv
kubectl get events --sort-by=.metadata.creationTimestamp --namespace nginx-pv
kubectl get events --namespace nginx-pv --watch
kubectl get deployment -n nginx-pv --watch
# kubectl logs deployment/nginx-deployment -n nginx-pv -f -c nginx
# kubectl logs deployment/nginx-deployment -n nginx-pv -f --all-containers

# Check resources and wait for EXTERNAL-IP
kubectl get all,pvc,pv -n nginx-pv
kubectl get svc -n nginx-pv -w

# Open browser to view NGINX default page
$urlPv = kubectl get svc my-nginx-pv -n nginx-pv --ignore-not-found -o jsonpath="http://{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}"
Write-Output "Browse to NGINX URL: $urlPv"
Start-Process $urlPv

# Cleanup previous attempts
velero backup get
velero backup delete nginx-pv-backup

# Create a backup
velero backup create nginx-pv-backup --include-namespaces nginx-pv
velero backup create ingress-backup --include-namespaces ingress --storage-location azure

# Check backup
velero backup describe nginx-pv-backup
velero backup describe nginx-pv-backup --details
$logOutput = velero backup logs nginx-pv-backup
$logOutput | sls error
$logOutput

# Simulate a disaster
kubectl get ns
kubectl get all,pvc,pv -n nginx-pv
kubectl delete namespace nginx-pv
# Wait for the namespace to be deleted
kubectl get ns
kubectl get all,pvc,pv -n nginx-pv
# pv shows as failed
kubectl describe pv -n nginx-pv
# pv may be deleted, but can delete ourselves
kubectl delete pv -n nginx-pv
kubectl delete persistentvolume/pvc-17b8832c-58ec-11ea-9ec4-6e4d21b19189 -n nginx-pv

# Restore your lost resources
velero restore create --from-backup nginx-pv-backup

# Check restore
velero restore get
velero restore describe
velero restore logs nginx-pv-backup-20200306092349

# Monitor restore progress
kubectl get ns
kubectl get all,pvc,pv -n nginx-pv
kubectl describe pod -n nginx-pv
kubectl get events --sort-by=.metadata.creationTimestamp --namespace nginx-pv
kubectl get events --namespace nginx-pv --watch
kubectl get deployment -n nginx-pv --watch
# kubectl logs deployment/nginx-deployment -n nginx-pv -f -c nginx
# kubectl logs deployment/nginx-deployment -n nginx-pv -f --all-containers

# Check resources and wait for EXTERNAL-IP
kubectl get svc -n nginx-pv -w
$newUrlPv = kubectl get svc my-nginx-pv -n nginx-pv --ignore-not-found -o jsonpath="http://{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}"
Write-Output "Browse to new NGINX URL: $newUrlPv"
Start-Process $newUrlPv
```

### Nexus example (with PersistentVolumes)

```powershell
# Monitor deployment progress
# use splatting: https://stackoverflow.com/questions/52854092/how-to-use-powershell-splatting-for-azure-cli
$kubeParams = "-n", "ingress", "-l", "app=nexus"
kubectl @kubeParams get all,pvc,pv
kubectl @kubeParams describe pod
kubectl @kubeParams describe sts
kubectl @kubeParams get events --sort-by=.metadata.creationTimestamp
kubectl @kubeParams get events --watch
kubectl @kubeParams get sts --watch
kubectl @kubeParams logs -f --all-containers --since 20m

# Wait for EXTERNAL-IP
kubectl get svc nginx-ingress-controller -n ingress -w

# Open browser
$nexusHost = kubectl get ingress -A -o jsonpath="{.items[0].spec.rules[0].host}"
$nexusBrowseUrl = "http://$nexusHost/#browse/browse:nuget-hosted"
Start-Process $nexusBrowseUrl

# Create a backup
velero backup create nexus-pv-backup --include-namespaces ingress -l app=nexus

# Check backup
velero backup get
velero backup describe nexus-pv-backup
velero backup describe nexus-pv-backup --details
velero backup logs nexus-pv-backup
velero backup logs nexus-pv-backup | sls "error"

# Simulate a disaster
$kubeParams = "-n", "ingress", "-l", "app=nexus"
kubectl @kubeParams get all,pvc,pv
kubectl @kubeParams delete all,pvc
# Wait for nexus resources to be deleted
kubectl @kubeParams get all,pvc,pv
kubectl get pvc,pv -A
# pv shows as failed
kubectl @kubeParams describe pv
kubectl @kubeParams describe pvc
# pv may be deleted, but can delete ourselves
kubectl @kubeParams delete pv
kubectl @kubeParams delete persistentvolume/pvc-TODO

# Restore your lost resources
velero restore create --from-backup nexus-pv-backup

# Check restore
velero restore get
velero restore describe
velero restore logs nexus-pv-backup-TODO
velero restore logs nexus-pv-nexus-pv-backup-20200309075403

# Monitor restore progress
kubectl @kubeParams get all,pvc,pv
kubectl @kubeParams describe pod
kubectl get events --sort-by=.metadata.creationTimestamp -n ingress
kubectl @kubeParams get sts --watch
# kubectl logs sts -f --all-containers --since 20m

# Check resources and wait for EXTERNAL-IP
kubectl get svc -n ingress -w

# Open browser
$nexusHost = kubectl get ingress -A -o jsonpath="{.items[0].spec.rules[0].host}"
$nexusBrowseUrl = "http://$nexusHost/#browse/browse:nuget-hosted"
Start-Process $nexusBrowseUrl
```

## Prometheus Metrics

```powershell
# Show velero resources
kubectl get all -n velero
kubectl describe pod -n velero

# Port forward
$podName = kubectl get pod -n velero -l app.kubernetes.io/name=velero -o jsonpath="{.items[0].metadata.name}"
kubectl -n velero port-forward $podName 8085:8085

# Show metrics
Start-Process http://localhost:8085/metrics
```

## Troubleshooting

Run the following checks:

```powershell
# Are your Velero server and daemonset pods running?
kubectl get pods -n velero

# Does your restic repository exist, and is it ready?
velero restic repo get
velero restic repo get REPO_NAME -o yaml

# Are there any errors in your Velero backup/restore?
velero backup describe BACKUP_NAME
velero backup logs BACKUP_NAME

velero restore describe RESTORE_NAME
velero restore logs RESTORE_NAME

# What is the status of your pod volume backups/restores?
kubectl -n velero get podvolumebackups -l velero.io/backup-name=BACKUP_NAME -o yaml
kubectl -n velero get podvolumerestores -l velero.io/restore-name=RESTORE_NAME -o yaml

# Is there any useful information in the Velero server or daemon pod logs?
kubectl -n velero logs deploy/velero
kubectl -n velero logs DAEMON_POD_NAME
```

**NOTE**: You can increase the verbosity of the pod logs by adding --log-level=debug as an argument to the
container command in the deployment/daemonset pod template spec.

## Cleanup

```powershell
# Delete Resource Groups
az group delete --name $backupResourceGroupName --verbose
az group delete --name $snapshotResourceGroupName --verbose
```
