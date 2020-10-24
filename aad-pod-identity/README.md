# aad-pod-identity

## Contents

- [aad-pod-identity](#aad-pod-identity)
  - [Contents](#contents)
  - [Introduction](#introduction)
  - [Manual Testing](#manual-testing)
    - [Deploy aad-pod-identity using Helm 3](#deploy-aad-pod-identity-using-helm-3)
    - [Configure aad-pod-identity](#configure-aad-pod-identity)
    - [Install Velero](#install-velero)

## Introduction

[AAD Pod Identity](https://github.com/Azure/aad-pod-identity) enables Kubernetes applications to access cloud
resources securely with Azure Active Directory (AAD).

Using Kubernetes primitives, administrators configure identities and bindings to match pods. Then without any code
modifications, your containerized applications can leverage any resource in the cloud that depends on AAD as an
identity provider.

## Manual Testing

Before automating the installation and configuration of aad-pod-identity, follow the steps below to test manually.

### Deploy aad-pod-identity using Helm 3

Repo: [aad-pod-identity chart](https://github.com/Azure/aad-pod-identity/tree/master/charts/aad-pod-identity)

```bash
# Navigate to aad-pod-identity folder
cd ./aad-pod-identity

# Deploy aad-pod-identity using Helm 3
# Add aad-pod-identity repo
helm repo list
helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts
helm repo update

# Find available chart versions, over v2
helm search repo aad-pod-identity --version ^2.0.0

# Create namespace
kubectl create namespace aad-pod-identity

# Install aad-pod-identity
helm upgrade aad-pod-identity aad-pod-identity/aad-pod-identity --version 2.0.2 --values aad_pod_identity_values.yaml --set=installCRDs=true --install --atomic --namespace aad-pod-identity --debug
```

### Configure aad-pod-identity

Source: [https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#option-2-use-aad-pod-identity](https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#option-2-use-aad-pod-identity)

```bash
# Vars
export AKS_RG_NAME="rush-rg-aks-dev-001"
export AKS_CLUSTER_NAME="rush-aks-001"
export IDENTITY_NAME="velero"
export AZURE_SUBSCRIPTION_ID=$(az account list --query '[?isDefault].id' -o tsv)
export AKS_NODE_RESOURCE_GROUP_NAME=$(az aks show --resource-group "$AKS_RG_NAME" --name "$AKS_CLUSTER_NAME" --query nodeResourceGroup -o tsv)
export AKS_NODE_RESOURCE_GROUP_ID=$(az group show --name "$AKS_NODE_RESOURCE_GROUP_NAME" --query id -o tsv)

# Create Managed Identity
# portal: https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.ManagedIdentity%2FuserAssignedIdentities
az identity create --subscription "$AZURE_SUBSCRIPTION_ID" --resource-group "$AKS_NODE_RESOURCE_GROUP_NAME" --name $IDENTITY_NAME

# Store the client ID and resource ID of the identity as environment variables
export IDENTITY_CLIENT_ID="$(az identity show -g "$AKS_NODE_RESOURCE_GROUP_NAME" -n "$IDENTITY_NAME" --subscription "$AZURE_SUBSCRIPTION_ID" --query clientId -o tsv)"
export IDENTITY_RESOURCE_ID="$(az identity show -g "$AKS_NODE_RESOURCE_GROUP_NAME" -n "$IDENTITY_NAME" --subscription "$AZURE_SUBSCRIPTION_ID" --query id -o tsv)"
echo "IDENTITY_RESOURCE_ID: $IDENTITY_RESOURCE_ID"
echo "IDENTITY_CLIENT_ID: $IDENTITY_CLIENT_ID"

# [OPTIONAL] Check assigned VMSS identity
az vmss identity show -g "$AKS_NODE_RESOURCE_GROUP_NAME" -n "aks-default-39636823-vmss"

# Assign the identity a role
export IDENTITY_ASSIGNMENT_ID="$(az role assignment create --role Contributor --assignee "$IDENTITY_CLIENT_ID" --scope "$AKS_NODE_RESOURCE_GROUP_ID" --query id -o tsv)"

# Describe AzureIdentity CRDs (they dont have metadata)
kubectl describe AzureIdentity velero
kubectl explain --recursive AzureIdentity
kubectl explain --recursive backups
kubectl explain --recursive AzureIdentity.spec
kubectl explain --recursive AzureIdentityBinding
kubectl explain --recursive AzureIdentityBinding.spec

# Create an AzureIdentity
cat <<EOF | kubectl apply --namespace aad-pod-identity -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: $IDENTITY_NAME
spec:
  type: 0
  vmType: vmss
  resourceID: $IDENTITY_RESOURCE_ID
  clientID: $IDENTITY_CLIENT_ID
EOF

# Create an AzureIdentityBinding
cat <<EOF | kubectl apply --namespace aad-pod-identity -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: $IDENTITY_NAME-binding
spec:
  azureIdentity: $IDENTITY_NAME
  selector: $IDENTITY_NAME
EOF

# Create velero namespace
kubectl create namespace velero

# Create velero credential file
cat << EOF  > ./credentials-velero
AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}
AZURE_RESOURCE_GROUP=${AKS_NODE_RESOURCE_GROUP_NAME}
AZURE_CLOUD_NAME=AzurePublicCloud
EOF

# Create velero-credentials secret from file
kubectl create secret generic --namespace velero velero-credentials --from-file=cloud=./credentials-velero
```

### Install Velero

Once `aad-pod-identity` has been configured, and the Velero credentials secret has been populated, install Velero via Helm chart ensuring the aadpodidbinding=$IDENTITY_NAME label has been added to the Velero values.yaml, eg:

```yaml
# source: https://github.com/vmware-tanzu/helm-charts/blob/velero-2.13.3/charts/velero/values.yaml#L27
podLabels:
  aadpodidbinding: velero
```

During testing, edit Velero schedule to run every 10 mins (`*/10 * * * *`):

```powershell
# set env var to use vscode
$env:KUBE_EDITOR = 'code --wait'

# list crds
kubectl get crd

# list velero schedules
kubectl get schedules.velero.io --namespace velero

# describe velero schedule
kubectl describe schedules.velero.io/velero-fullbackup --namespace velero

# edit velero schedule - every 5 mins (0 */5 * * *)
kubectl edit schedules.velero.io/velero-fullbackup --namespace velero
```
