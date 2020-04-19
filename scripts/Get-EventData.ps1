<#
    # Get GitHub event context data from env var
    # assumes GitHub workflow
    - name: Show triggered event data
    env:
    GITHUB_CONTEXT: ${{ toJson(github) }}
#>
$eventContextJson = $env:GITHUB_CONTEXT

# Convert to PowerShell object
$eventContext = $eventContextJson | ConvertFrom-Json

# Output info
Write-Output "action: $($eventContext.event.action)"
Write-Output "client_payload: $($eventContext.event.client_payload)"
