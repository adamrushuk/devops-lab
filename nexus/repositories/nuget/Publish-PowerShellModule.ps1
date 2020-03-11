# Publish example PowerShell module to NuGet repository
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    # Get NuGet API key from: <NEXUS_HOST>/#user/nugetapitoken
    [String] $NugetApiKey,

    # Nexus host, eg: nexus.thehypepipe.co.uk
    [String] $NexusHost = (kubectl get ingress -A -o jsonpath="{.items[0].spec.rules[0].host}"),

    [String] $NexusBaseUrl = "http://$NexusHost",

    [String] $NexusRepoName = "nuget-hosted",

    [String] $NugetRepoName = "NexusNugetRepo"
)

# Local vars
$NugetRepoUrl = "$NexusBaseUrl/repository/$NexusRepoName/"

# Test repo connection
Invoke-WebRequest $NugetRepoUrl

# List current repos
Get-PSRepository

# [OPTIONAL] Remove previous repo
Unregister-PSRepository -Name $NugetRepoName -ErrorAction "SilentlyContinue"

# Register new repo
$registerParams = @{
    Name                      = $NugetRepoName
    SourceLocation            = $NugetRepoUrl
    PublishLocation           = $NugetRepoUrl
    PackageManagementProvider = "nuget"
    InstallationPolicy        = "Trusted"
    Verbose                   = $true
}
Register-PSRepository @registerParams

# Publish single module
$publishParams = @{
    Name        = "./nexus/repositories/nuget/PSvCloud"
    Repository  = $NugetRepoName
    NugetApiKey = $NugetApiKey
    Verbose     = $true
}
Publish-Module @publishParams

# Find modules
Find-Module -Repository $NugetRepoName -Verbose

# Show modules in Nexus repo
Start-Process "$NexusBaseUrl/#browse/browse:$NexusRepoName"
