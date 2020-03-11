![Build environment](https://github.com/adamrushuk/aks-nexus-velero/workflows/Build%20environment/badge.svg)

# aks-nexus-velero

Provisions an AKS cluster, deploys Nexus Repository OSS, configures Velero backups.

## Getting Started

Before you start the `build` GitHub Action, you need to create the following Secrets within
[GitHub Settings](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets):

### GoDaddy DNS API Secrets

There are plans to use [external-dns](https://github.com/kubernetes-sigs/external-dns) to handle DNS changes, but
in the meantime, I'm using a script to update GoDaddy DNS records.

Learn how to [setup GoDaddy API access](https://developer.godaddy.com/getstarted), then add the following GitHub
Secrets:

- `API_KEY`
- `API_SECRET`

### Azure Secrets

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

### Velero Secret

- `CREDENTIALS_VELERO`

## Connect

1. Import the AKS Cluster credentials:

    ```powershell
    # Vars
    $prefix = "rush"
    $aksClusterName = "$($prefix)-aks-001"
    $aksClusterResourceGroupName = "$($prefix)-rg-aks-dev-001"

    # AKS Cluster credentials
    az aks get-credentials --resource-group $aksClusterResourceGroupName --name $aksClusterName --overwrite-existing

    # [OPTIONAL] View AKS Dashboard
    az aks browse --resource-group $aksClusterResourceGroupName --name $aksClusterName
    ```

1. Get the auto-generated admin password from within the Nexus container:

    ```powershell
    # Get pod name
    $podName = kubectl get pod -n ingress-tls -l app=nexus -o jsonpath="{.items[0].metadata.name}"

    # Get admin password from pod
    kubectl exec -n ingress-tls -it $podName cat /nexus-data/admin.password

    # [OPTIONAL] Enter pod shell, then output admin password
    kubectl exec -n ingress-tls -it $podName /bin/bash
    echo -e "\nadmin password: \n$(cat /nexus-data/admin.password)\n"
    ```
