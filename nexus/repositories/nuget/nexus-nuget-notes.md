# Nexus NuGet Repository Notes

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

Follow the [Login to Nexus Console](./../../../README.md#login-to-nexus-console) steps in the main README.

## Configure NuGet Repo

1. Get NuGet API token:

    ```powershell
    # Open Nexus console and view API key
    Start-Process "$nexusBaseUrl/#user/nugetapitoken"

    # Assign API key
    $NuGetApiKey = "<NUGET_API_KEY>"
    ```

1. Move `NuGet API-Key Realm` into `Active`:

    ```powershell
    # Open Nexus console make Realm changes
    Start-Process "$nexusBaseUrl/#admin/security/realms"
    ```

## Register and Publish to NuGet Repo

### Using a Script

```powershell
# Ensure NuGet API key has been assigned
$NuGetApiKey = "<NUGET_API_KEY>"

# Enter the FQDN of the Nexus host (eg: nexus.thehypepipe.co.uk) or use kubectl
$NexusHost = (kubectl get ingress -A -o jsonpath="{.items[0].spec.rules[0].host}")

# Create a credential (default admin user is fine for testing)
$cred = [PSCredential]::new("admin", (ConvertTo-SecureString "<PASSWORD>" -AsPlainText -Force))

# Run the script:
./nexus/repositories/nuget/Publish-PowerShellModule.ps1 -NugetApiKey $NuGetApiKey -NexusHost $NexusHost -Credential $cred
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
