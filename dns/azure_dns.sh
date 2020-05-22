#!/usr/bin/env bash
#
# Setup Azure DNS for kubernetes external-dns
# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# vars
resource_group="rg-externaldns"
location="uksouth"
zone="thehypepipe.co.uk"
dns_service_principle="external_dns"

# create resource group and zone
az group create --name $resource_group --location $location
az network dns zone create --resource-group $resource_group --name $zone

# create service principle for dns
az ad sp create-for-rbac --name $dns_service_principle

# create config file in this format, then save as GitHub Secret (EXTERNAL_DNS_CREDENTIAL_JSON)
# {
#   "tenantId": "01234abc-de56-ff78-abc1-234567890def",
#   "subscriptionId": "01234abc-de56-ff78-abc1-234567890def",
#   "resourceGroup": "MyDnsResourceGroup",
#   "aadClientId": "01234abc-de56-ff78-abc1-234567890def",
#   "aadClientSecret": "01234abc-de56-ff78-abc1-234567890def"
# }

# find resource ids of the resource group where the dns zone is deployed, and the dns zone
az group show --name $resource_group
az network dns zone show --resource-group $resource_group --name $zone

# assign the rights to the created service principal, using the resource ids from previous step
# 1. as a reader to the resource group
az role assignment create --role "Reader" --assignee <appId GUID> --scope <resource group resource id>

# 2. as a contributor to DNS Zone itself
az role assignment create --role "Contributor" --assignee <appId GUID> --scope <dns zone resource id>

# create kubernetes secret
# first, write file from GitHub secret: echo $EXTERNAL_DNS_CREDENTIAL_JSON > ./creds/azure.json
kubectl ns ingress
kubectl create secret generic azure-config-file --from-file=./creds/azure.json

# apply manifest
kubectl apply -f ./manifests/external-dns.yml

# add arg to nginx-ingress deployment
--publish-service=ingress/nginx-nginx-ingress-controller





# misc
nslookup -type=SOA thehypepipe.co.uk


