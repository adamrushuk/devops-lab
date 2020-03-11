# Nexus NuGet Repository Notes

**WARNING: This is a work in progress, and currently not complete...**

## Contents

- [Nexus NuGet Repository Notes](#nexus-nuget-repository-notes)
  - [Contents](#contents)
  - [Prereqs](#prereqs)
  - [Configure NuGet Repo](#configure-nuget-repo)
  - [Register and Publish to NuGet Repo](#register-and-publish-to-nuget-repo)
    - [Using a Script](#using-a-script)
    - [Manually](#manually)
  - [List Modules in NuGet Repo](#list-modules-in-nuget-repo)

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
    kubectl exec -n ingress-tls -it $podName cat /nexus-data/admin.password

    # [OPTIONAL] Enter pod shell, then output admin password
    kubectl exec -n ingress-tls -it $podName /bin/bash
    echo -e "\nadmin password: \n$(cat /nexus-data/admin.password)\n"
    ```

## Configure NuGet Repo

1. Login as admin, using auto-generated admin password from prereqs section:

    ```powershell
    # Set URL
    $nexusHost = kubectl get ingress -A -o jsonpath="{.items[0].spec.rules[0].host}"
    $nexusBaseUrl = "http://$nexusHost"

    # Sign in as admin, using auto-generated admin password from prereqs section
    Start-Process $nexusBaseUrl
    ```

1. Update admin password.
1. Enable anonymous access (to avoid using credential during repo testing)
1. Configure NuGet repo:

    ```powershell
    # Get NuGet API token
    Start-Process "$nexusBaseUrl/#user/nugetapitoken"
    $nuGetApiKey = "<Enter NuGet API Key>"

    # Set NuGet API-Key Realm as "Active"
    Start-Process https://sammart.in/post/creating-your-own-powershell-repository-with-nexus-3/
    Start-Process "$nexusBaseUrl/#admin/security/realms"
    ```

## Register and Publish to NuGet Repo

### Using a Script

1. Enter the NuGet API key:

    ```powershell
    $NuGetApiKey = "<NUGET_API_KEY>"
    ```

1. Enter the FQDN of the Nexus host (eg: `nexus.thehypepipe.co.uk`) or use `kubectl`:

    ```powershell
    $NexusHost = (kubectl get ingress -A -o jsonpath="{.items[0].spec.rules[0].host}")
    ```

1. Run the script:

    ```powershell
    ./nexus/repositories/nuget/Publish-PowerShellModule.ps1 -NugetApiKey $NuGetApiKey -NexusHost $NexusHost
    ```

### Manually

1. Register Nuget feed as a PowerShell repository:

    ```powershell
    # Vars
    $nexusRepoName = "nuget-hosted"
    $nugetRepoUrl = "$nexusBaseUrl/repository/$nexusRepoName/"
    $nugetRepoName = "NexusNugetRepo"

    # [OPTIONAL] Use credential for if anonymous access not enabled
    # Update admin password
    $cred = [PSCredential]::new("admin", (ConvertTo-SecureString "<PASSWORD>" -AsPlainText -Force))


    # Test repo connection
    Invoke-WebRequest $nugetRepoUrl

    # [OPTIONAL] Use credential for if anonymous access not enabled
    Invoke-WebRequest $nugetRepoUrl -Credential $cred


    # List current repos
    Get-PSRepository


    # [OPTIONAL] Remove previous repo
    Unregister-PSRepository -Name $nugetRepoName -ErrorAction "SilentlyContinue"


    # Register new repo
    $registerParams = @{
        Name                      = $nugetRepoName
        SourceLocation            = $nugetRepoUrl
        PublishLocation           = $nugetRepoUrl
        PackageManagementProvider = "nuget"
        InstallationPolicy        = "Trusted"
        Verbose                   = $true
    }
    Register-PSRepository @registerParams

    # [OPTIONAL] Use credential for if anonymous access not enabled
    Register-PSRepository @registerParams -Credential $cred
    ```

1. Ensure you have the required PowerShell modules to allow publishing:

    ```powershell
    # Check modules exist
    Get-Module PackageManagement, PowerShellGet

    # [OPTIONAL] Install modules if required
    Install-Module PackageManagement, PowerShellGet
    ```

1. Publish PowerShell Modules to NuGet Repo:

    ```powershell
    # Publish single module
    $publishParams = @{
        Name        = "./nexus/repositories/nuget/PSvCloud"
        Repository  = $nugetRepoName
        NuGetApiKey = $nuGetApiKey
        Verbose     = $true
    }
    Publish-Module @publishParams

    # [OPTIONAL] Use credential for if anonymous access not enabled
    Publish-Module @publishParams -Credential $cred
    ```

## List Modules in NuGet Repo

```powershell
# Find modules
Find-Module -Repository $nugetRepoName
Find-Module -Name "PSvCloud" -Repository $nugetRepoName

# [OPTIONAL] Use credential for if anonymous access not enabled
Find-Module -Name "PSvCloud" -Repository $nugetRepoName -Credential $cred -Verbose
Find-Module -Repository $nugetRepoName -Credential $cred -Verbose

# Show modules in Nexus repo
Start-Process "$nexusBaseUrl/#browse/browse:$nexusRepoName"
```
