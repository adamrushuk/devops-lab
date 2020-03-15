# Publish example PowerShell module to NuGet repository
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    # Get NuGet API key from: <NEXUS_HOST>/#user/nugetapitoken
    [String] $NugetApiKey,

    # Nexus host, eg: nexus.thehypepipe.co.uk
    [String] $NexusHost = (kubectl.exe get ingress -A -o jsonpath="{.items[0].spec.rules[0].host}"),

    $NexusBaseUrl = "https://$NexusHost",

    [String] $NexusRepoName = "nuget-hosted",

    [String] $NugetRepoName = "NexusNugetRepo",

    [pscredential] $Credential
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
    Verbose                   = $VerbosePreference
}
if ($null -ne $Credential) {
    $registerParams.Add("Credential", $Credential)
}
Register-PSRepository @registerParams

# Publish single module
$publishParams = @{
    Name        = "./nexus/repositories/nuget/PSvCloud"
    Repository  = $NugetRepoName
    NugetApiKey = $NugetApiKey
    Verbose     = $true
}
if ($null -ne $Credential) {
    $publishParams.Add("Credential", $Credential)
}
Publish-Module @publishParams

# Find modules
Find-Module -Repository $NugetRepoName -Verbose

# Show modules in Nexus repo
Write-Output "Browse to: $NexusBaseUrl/#browse/browse:$NexusRepoName"
