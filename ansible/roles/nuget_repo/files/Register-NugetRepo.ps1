# Register NuGet repository
[CmdletBinding()]
param (
    [String] $NugetRepoName = $env:NUGET_REPO_NAME,
    [String] $NugetRepoUrl = $env:NUGET_REPO_URL
)

# Get current repos
$currentRepos = Get-PSRepository

# Register new repo
if ($NugetRepoName -notin $currentRepos.Name) {
    $registerParams = @{
        Name                      = $NugetRepoName
        SourceLocation            = $NugetRepoUrl
        PublishLocation           = $NugetRepoUrl
        PackageManagementProvider = "nuget"
        InstallationPolicy        = "Trusted"
        Verbose                   = $VerbosePreference
    }
    Register-PSRepository @registerParams
}

# Set repo as trusted
Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted" | Out-Null
Get-PSRepository
