# Get GitHub event context data
$eventContextJson = '${{ toJson( github.event ) }}'

# Convert to PowerShell object
$eventContext = $eventContextJson | ConvertFrom-Json

# Output info
Write-Output "action: $($eventContext.action)"
Write-Output "client_payload: $($eventContext.client_payload)"
