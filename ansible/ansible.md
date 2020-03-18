# Ansible Notes

Using Ansible for post-deployment configuration.

> **WARNING**  
> Most of the other code examples use PowerShell and CLIs that run on *all* platforms, but as Ansible won't run on
> Windows, Windows users will have to
> [install Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

## Contents

> [!NOTE]
> Information the user should notice even if skimming

- [Ansible Notes](#ansible-notes)
  - [Contents](#contents)
  - [Prereqs](#prereqs)

## Prereqs

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
    $adminPassword = kubectl exec -n ingress-tls -it $podName cat /nexus-data/admin.password
    echo $adminPassword
    ```

1. Set an environment variable for the admin password:

    ```powershell
    export API_PASSWORD=<MY_API_PASSWORD>
    ```
