![Build environment](https://github.com/adamrushuk/aks-nexus-velero/workflows/Build%20environment/badge.svg)

# aks-nexus-velero

Provisions an AKS cluster, deploys Nexus Repository OSS, configures Velero backups.

## Contents

- [aks-nexus-velero](#aks-nexus-velero)
  - [Contents](#contents)
  - [Getting Started](#getting-started)
    - [Assumptions](#assumptions)
    - [Azure Secrets](#azure-secrets)
  - [Login to Nexus Console](#login-to-nexus-console)

## Getting Started

Before you start the `build` GitHub Action workflow, you need to create the following Secrets within
[GitHub Settings](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets):

### Assumptions

<!-- TODO -->

- Configure Azure Service Principle for Terraform, and grant permission to manage AAD:
https://www.terraform.io/docs/providers/azuread/guides/service_principal_configuration.html#granting-administrator-permissions

These API permissions are required for your Terraform Service Principle:

```bash
Azure Active Directory Graph (3)
Application.ReadWrite.All
Application
Read and write all applications

Directory.Read.All
Application
Read directory data

User.Read
Delegated
Sign in and read user profile
```

### Azure Secrets

<!-- TODO -->

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

## Login to Nexus Console

Follow the steps below to update AKS credentials, get the Nexus admin password, then login and update the password:

1. Import the AKS Cluster credentials:

    ```bash
    # Vars
    PREFIX="rush"
    AKS_CLUSTER_NAME="$PREFIX-aks-001"
    AKS_RG_NAME="$PREFIX-rg-aks-dev-001"

    # AKS Cluster credentials
    az aks get-credentials --resource-group $AKS_RG_NAME --name $AKS_CLUSTER_NAME --overwrite-existing

    # [OPTIONAL] View AKS Dashboard
    az aks browse --resource-group $AKS_RG_NAME --name $AKS_CLUSTER_NAME
    ```

1. Get the auto-generated admin password from within the Nexus container:

    ```bash
    # Get pod name
    pod_name=$(kubectl get pod -n ingress -l app=nexus -o jsonpath="{.items[0].metadata.name}")

    # Get admin password from pod
    admin_password=$(kubectl exec -n ingress -it $pod_name -- cat /nexus-data/admin.password)
    echo "$admin_password"

    # [OPTIONAL] Enter pod shell, then output admin password
    kubectl exec -n ingress -it $pod_name -- /bin/bash
    echo -e "\nadmin password: \n$(cat /nexus-data/admin.password)\n"
    ```

1. Open the Nexus web console

    ```bash
    # Set URL
    nexus_host=$(kubectl get ingress -A -o jsonpath="{.items[0].spec.rules[0].host}")
    nexus_base_url="https://$nexus_host"

    # Sign in as admin, using auto-generated admin password from prereqs section
    echo "$nexus_base_url"
    ```

1. Click `Sign in` in top right corner, then login using admin password.
1. Update admin password.
1. Enable anonymous access (to avoid using credential during repo testing).
