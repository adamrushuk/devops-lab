#!/usr/bin/env bash
#
# Setup Azure DNS for kubernetes external-dns
# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# vars
RESOURCE_GROUP="rg-externaldns"
LOCATION="uksouth"
DNS_ZONE="thehypepipe.co.uk"
DNS_SERVICE_PRINCIPLE="sp_external_dns"
DNS_MANAGED_IDENTITY="mid_external_dns"
AKS_RG_NAME="rush-rg-aks-dev-001"
AKS_CLUSTER_NAME="rush-aks-001"

# create resource group and dns zone
az group create --name $RESOURCE_GROUP --location $LOCATION
az network dns zone create --resource-group $RESOURCE_GROUP --name $DNS_ZONE



#region [OPTION 1] Service Principle authentication
# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md#creating-service-principal
# create service principle for dns
service_principle_json=$(az ad sp create-for-rbac --name $DNS_SERVICE_PRINCIPLE --skip-assignment)

# prepare credential json
assignee_id=$(echo "$service_principle_json" | jq -r .appId)
cred_json=$(echo "$service_principle_json" | jq ". | {aadClientId: .appId, aadClientSecret: .password, tenantId: .tenant}")
subscription_id=$(az account show --query "id" --output tsv)
extra_json=$(cat <<-END
{
  "subscriptionId": "$subscription_id",
  "resourceGroup": "$RESOURCE_GROUP"
}
END
)

# show separate json
echo "$cred_json"
echo "$extra_json"

# combine into an array
echo "$cred_json $extra_json" | jq -s

# merge json
echo "$cred_json $extra_json" | jq -s add

# create config file in this format, then save as GitHub Secret (EXTERNAL_DNS_CREDENTIAL_JSON)
# aadClientId = appId = $assignee_id
# {
#   "tenantId": "01234abc-de56-ff78-abc1-234567890def",
#   "subscriptionId": "01234abc-de56-ff78-abc1-234567890def",
#   "resourceGroup": "MyDnsResourceGroup",
#   "aadClientId": "01234abc-de56-ff78-abc1-234567890def",
#   "aadClientSecret": "01234abc-de56-ff78-abc1-234567890def"
# }
#endregion [OPTION 1] Service Principle authentication



#region [OPTION 2] Managed Identity authentication
# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md#azure-managed-service-identity-msi
# create managed identity for dns
assignee_id=$(az identity create --resource-group $RESOURCE_GROUP --name $DNS_MANAGED_IDENTITY --query "principalId" --output tsv)

# get existing managed identity
assignee_id=$(az ad sp list --display-name "$DNS_MANAGED_IDENTITY" --query [].objectId --output tsv)

# create config file in this format, then save as GitHub Secret (EXTERNAL_DNS_CREDENTIAL_JSON)
# {
#   "tenantId": "01234abc-de56-ff78-abc1-234567890def",
#   "subscriptionId": "01234abc-de56-ff78-abc1-234567890def",
#   "resourceGroup": "MyDnsResourceGroup",
#   "useManagedIdentityExtension": true
# }

# Get AKS node resource group name
node_resource_group=$(az aks show --resource-group "$AKS_RG_NAME" --name "$AKS_CLUSTER_NAME" --query nodeResourceGroup -o tsv)

# Get VMSS
vmss_name=$(az vmss list --resource-group "$node_resource_group" --query "[].name" -o tsv)

# Assign Managed Identity to VMSS
managed_identity_id=$(az ad sp list --display-name "$DNS_MANAGED_IDENTITY" --query [].alternativeNames[1] --output tsv)
az vmss identity assign --resource-group "$node_resource_group" --name "$vmss_name" --identities "$managed_identity_id"

# Show VMSS identities
az vmss identity show --resource-group "$node_resource_group" --name "$vmss_name"
#endregion [OPTION 2] Managed Identity authentication



#region Role Assignment
# get resource ids of resource group and dns zone
resource_group_id=$(az group show --name $RESOURCE_GROUP --query "id" --output tsv)
dns_zone_id=$(az network dns zone show --resource-group $RESOURCE_GROUP --name $DNS_ZONE --query "id" --output tsv)

# assign the rights to the created service principal, using the resource ids from previous step
# 1. as a reader to the resource group
az role assignment create --role "Reader" --assignee "$assignee_id" --scope "$resource_group_id"

# 2. as a contributor to DNS Zone itself
az role assignment create --role "Contributor" --assignee "$assignee_id" --scope "$dns_zone_id"
#endregion Role Assignment



#region Kubernetes
# create kubernetes secret
# first, write file from GitHub secret: echo $EXTERNAL_DNS_CREDENTIAL_JSON > ./creds/azure.json
kubectl ns ingress
kubectl create -n ingress secret generic azure-config-file --from-file=./creds/azure.json

# apply manifest
kubectl apply -f ./manifests/external-dns.yml

# add arg to nginx-ingress deployment
--publish-service=ingress/nginx-nginx-ingress-controller
#endregion Kubernetes



# testing
az network dns record-set a list --resource-group $RESOURCE_GROUP --zone $DNS_ZONE
nslookup -type=SOA nexus.thehypepipe.co.uk
nslookup nexus.thehypepipe.co.uk
ping nexus.thehypepipe.co.uk
