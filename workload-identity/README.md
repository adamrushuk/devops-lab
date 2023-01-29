# Workload Identity

## Reference

- <https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview>

## User Assigned Identity Example

```bash
# vars
AKS_RESOURCE_GROUP='arshz-rg-aks-dev-001'
AKS_CLUSTER_NAME='arshz-aks-001'
LOCATION='eastus'

# update aks creds
az aks get-credentials --resource-group "$AKS_RESOURCE_GROUP"  --name "$AKS_CLUSTER_NAME" --overwrite-existing --admin

# test kubectl
kubectl get node
kubectl get pod -A

# Export environmental variables
export AKS_OIDC_ISSUER="$(az aks show --resource-group "$AKS_RESOURCE_GROUP"  --name "$AKS_CLUSTER_NAME" --query "oidcIssuerProfile.issuerUrl" -otsv)"
echo $AKS_OIDC_ISSUER

# environment variables for the Kubernetes Service account & federated identity credential
export SERVICE_ACCOUNT_NAMESPACE="wi-test"
export SERVICE_ACCOUNT_NAME="workload-identity-sa"

# environment variables for the Federated Identity
export SUBSCRIPTION="$(az account show --query id --output tsv)"
# user assigned identity name
export UAID="fic-test-ua"
# federated identity name
export FICID="fic-test-fic-name"


# Create a managed identity and grant permissions to read from sub
az identity create --name "${UAID}" --resource-group "${AKS_RESOURCE_GROUP}" --location "${LOCATION}" --subscription "${SUBSCRIPTION}"

export USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group "${AKS_RESOURCE_GROUP}" --name "${UAID}" --query 'clientId' -otsv)"
export USER_ASSIGNED_PRINCIPAL_ID="$(az identity show --resource-group "${AKS_RESOURCE_GROUP}" --name "${UAID}" --query 'principalId' -otsv)"

# doesnt work using USER_ASSIGNED_CLIENT_ID
# az role assignment create --assignee-object-id "$USER_ASSIGNED_CLIENT_ID" --role "Reader" --subscription "${SUBSCRIPTION}" --assignee-principal-type 'ServicePrincipal'

# TODO test
# az role assignment create --assignee-object-id "$USER_ASSIGNED_PRINCIPAL_ID" --role "Reader" --subscription "${SUBSCRIPTION}" --assignee-principal-type 'ServicePrincipal'
az role assignment create --assignee "$USER_ASSIGNED_PRINCIPAL_ID" --role "Reader" --subscription "${SUBSCRIPTION}"


# Create Kubernetes service account
kubectl create namespace ${SERVICE_ACCOUNT_NAMESPACE}

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: ${USER_ASSIGNED_CLIENT_ID}
  labels:
    azure.workload.identity/use: "true"
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${SERVICE_ACCOUNT_NAMESPACE}
EOF


# Establish federated identity credential
az identity federated-credential create --name ${FICID} --identity-name ${UAID} --resource-group ${AKS_RESOURCE_GROUP} --issuer ${AKS_OIDC_ISSUER} --subject system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_NAME}


# test pod
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azcli-wi-test
  namespace: ${SERVICE_ACCOUNT_NAMESPACE}
  labels:
    app: azcli
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azcli
  template:
    metadata:
      labels:
        app: azcli
    spec:
      serviceAccount: ${SERVICE_ACCOUNT_NAME}
      containers:
        - name: azcli
          image: mcr.microsoft.com/azure-cli:latest
          command:
            - "/bin/bash"
            - "-c"
            - "sleep infinity"
EOF

# enter pod session
POD_NAME=$(kubectl get pod -l app=azcli -o jsonpath="{.items[0].metadata.name}" --namespace ${SERVICE_ACCOUNT_NAMESPACE})
echo "Found pod: [$POD_NAME]"

# attach to the pod and start a bash session
kubectl exec -it $POD_NAME --namespace ${SERVICE_ACCOUNT_NAMESPACE} -- /bin/bash

# show env vars
env | grep AZURE | sort
echo $AZURE_AUTHORITY_HOST
echo $AZURE_CLIENT_ID
echo $AZURE_TENANT_ID
echo $AZURE_FEDERATED_TOKEN_FILE

# login using federated token
az login --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID --federated-token "$(cat $AZURE_FEDERATED_TOKEN_FILE)" #--debug

# show resources
az aks list -o table
az group list -o table
```

## App Registration / Service Principle Example

TODO
