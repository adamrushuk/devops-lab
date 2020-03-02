# Trigger action with custom events

<#
    # Examples

    # Add GitHub Personal access token to env var
    $env:GITHUB_TOKEN = "<GITHUB_ACCESS_TOKEN>"

    # Trigger delete-all action
    ./TriggerCustomAction.ps1 -CustomEventAction "delete-all"

    # Trigger terraform-destroy action
    ./TriggerCustomAction.ps1 -CustomEventAction "terraform-destroy"

    # Trigger terraform-destroy action
    ./TriggerCustomAction.ps1 -CustomEventAction "test"
#>

[CmdletBinding()]
param(
    # Personal Access Token stored as environment variable
    $GithubToken = $env:GITHUB_TOKEN,

    $GithubUserName = "adamrushuk",

    $GithubRepo = "aks-nexus-velero",

    [ValidateSet("delete-all", "terraform-destroy", "test")]
    $CustomEventAction = "delete-all"
)

# https://developer.github.com/v3/repos/#create-a-repository-dispatch-event
$uri = "https://api.github.com/repos/$GithubUserName/$GithubRepo/dispatches"

$body = @{
    # used for if condition of Github Action
    event_type = $CustomEventAction
    client_payload = @{
        my_setting1 = "foo"
        my_setting2 = "bar"
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
