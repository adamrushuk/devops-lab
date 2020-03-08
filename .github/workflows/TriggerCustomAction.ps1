# Trigger action with custom events

<#
    # Examples

    # Add GitHub Personal access token to env var
    $env:GITHUB_TOKEN = "<GITHUB_ACCESS_TOKEN>"

    # Trigger test action
    ./.github/workflows/TriggerCustomAction.ps1 -CustomEventAction "test"

    # Trigger build action
    ./.github/workflows/TriggerCustomAction.ps1 -CustomEventAction "build"

    # Trigger destroy action
    ./.github/workflows/TriggerCustomAction.ps1 -CustomEventAction "destroy"
#>

[CmdletBinding()]
param(
    # Personal Access Token stored as environment variable
    $GithubToken = $env:GITHUB_TOKEN,

    $GithubUserName = "adamrushuk",

    $GithubRepo = "aks-nexus-velero",

    [ValidateSet("test", "build", "destroy")]
    $CustomEventAction = "test"
)

# https://developer.github.com/v3/repos/#create-a-repository-dispatch-event
$uri = "https://api.github.com/repos/$GithubUserName/$GithubRepo/dispatches"

$body = @{
    # used for if condition of Github Action
    event_type = $CustomEventAction
    client_payload = @{
        source_trigger = "TriggerCustomAction.ps1"
        source_ip = "$(Invoke-WebRequest 'https://canihazip.com/s')"
    }
} | ConvertTo-Json

$params = @{
    ContentType = "application/json"
    Headers     = @{
        "authorization" = "token $($GithubToken)"
        "accept"        = "application/vnd.github.everest-preview+json"
    }
    Method      = "Post"
    URI         = $uri
    Body        = $body
}

Invoke-RestMethod @params -Verbose
