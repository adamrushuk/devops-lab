# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

<#
# Local Debugging, as proper container is currently broken
# Load env vars from local.settings.json
$jsonSettings = Get-Content "function_app\local.settings.json" -Raw | ConvertFrom-Json
$envVars = $jsonSettings.Values
foreach ($envVar in $envVars.PSObject.Properties) {
    New-Item -Path "Env:$($envVar.Name)" -Value $envVar.Value -Force
}

gci env:

$PSVersionTable | Out-String

# Needed for VSCode debugger
# Wait-Debugger
#>


# List VMSS
Write-Host "Getting VMSS VMs..."
$vmssVms = Get-AzVmss | Get-AzVmssVM -InstanceView |
    Select-Object Name, ResourceGroupName, ProvisioningState, @{ N = "PowerState"; E = { $_.InstanceView.Statuses[1].Code } }
$vmssVms

# Check for running VMs
$runningVmssVms = $vmssVms | Where-Object { $_.PowerState -eq "PowerState/running" }

Write-Host "Running VM count: [$($runningVmssVms.Count)]"

# Sent notification if VMs still running
if ($runningVmssVms.Count -gt 0) {

    $vmsRunningwithinAllowedTimeRange = Test-WithinAllowedTimeRange -TimeRange $env:WEEKDAY_ALLOWED_TIME_RANGE
    Write-Host "Are VMs running within allowed time range of [$env:WEEKDAY_ALLOWED_TIME_RANGE]?...[$vmsRunningwithinAllowedTimeRange]"

    if (-not $vmsRunningwithinAllowedTimeRange) {
        Write-Host "Sending IFTTT notification as [$($runningVmssVms.Count)] VMs still running..."

        $params = @{
            EventName = "azure_vm_check"
            Key       = $env:IFTTT_WEBHOOK_KEY
            Value1    = "Allowed time range: [$env:WEEKDAY_ALLOWED_TIME_RANGE]"
            Value2    = $runningVmssVms.Name -join ", "
            Value3    = ($runningVmssVms.ResourceGroupName | Select-Object -Unique) -join ", "
        }
        Send-IftttAppNotification @params

        Start-Sleep -Seconds 5
    } else {
        Write-Host "Skipping sending notification as: [VMs running within allowed time range]"
    }
} else {
    Write-Host "Skipping sending notification as: [0 VMs running]"
}
