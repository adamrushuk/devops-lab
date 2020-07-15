# Azure Functions profile.ps1
#
# This profile.ps1 will get executed every "cold start" of your Function App.
# "cold start" occurs when:
#
# * A Function App starts up for the very first time
# * A Function App starts up after being de-allocated due to inactivity
#
# You can define helper functions, run commands, or specify environment variables
# NOTE: any variables defined that are not environment variables will get reset after the first execution

# Authenticate with Azure PowerShell using MSI.
# Remove this if you are not planning on using MSI or Azure PowerShell.
if ($env:MSI_SECRET -and (Get-Module -ListAvailable Az.Accounts)) {
    Write-Output "Authenticating PowerShell using Managed Identity..."
    Connect-AzAccount -Identity
}
elseif ($env:ARM_TENANT_ID -and $env:ARM_SUBSCRIPTION_ID -and $env:ARM_CLIENT_ID -and $env:ARM_CLIENT_SECRET) {
    # This is used for local development
    Write-Output "Authenticating PowerShell session using env vars..."
    $servicePrincipleCredential = [pscredential]::new($env:ARM_CLIENT_ID, (ConvertTo-SecureString $env:ARM_CLIENT_SECRET -AsPlainText -Force))
    Connect-AzAccount -ServicePrincipal -Tenant $env:ARM_TENANT_ID -Credential $servicePrincipleCredential -Subscription $env:ARM_SUBSCRIPTION_ID -Verbose
}

# Uncomment the next line to enable legacy AzureRm alias in Azure PowerShell.
# Enable-AzureRmAlias

# You can also define functions or aliases that can be referenced in any of your PowerShell functions.

#######

# source: https://www.dennisrye.com/post/send-smartphone-notifications-powershell-ifttt/
function Send-IftttAppNotification {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string]$EventName,

        [Parameter(Mandatory)]
        [string]$Key,

        [string]$Value1,

        [string]$Value2,

        [string]$Value3
    )

    $webhookUrl = "https://maker.ifttt.com/trigger/{0}/with/key/{1}" -f $EventName, $Key

    $body = @{
        value1 = $Value1
        value2 = $Value2
        value3 = $Value3
    }

    Invoke-RestMethod -Method Get -Uri $webhookUrl -Body $body -ResponseHeadersVariable responseHeaders -StatusCodeVariable statusCode

    Write-Host "Status Code: [$statusCode]"
    Write-Host "Response Headers:`n"
    $responseHeaders | Out-String
}


# Define function to check current time is within specified range
# Ref: https://automys.com/library/asset/scheduled-virtual-machine-shutdown-startup-microsoft-azure
function Test-WithinAllowedTimeRange ([string]$TimeRange) {
    # Initialize variables
    $rangeStart, $rangeEnd, $parsedDay = $null
    $currentTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date), [System.TimeZoneInfo]::Local.Id, 'GMT Standard Time')
    $midnight = $currentTime.AddDays(1).Date

    Write-Host "Current time in UK (GMT): [$currentTime]"

    try {
        # Parse as range if contains '->'
        if ($TimeRange -like "*->*") {
            $timeRangeComponents = $TimeRange -split "->" | foreach { $_.Trim() }
            if ($timeRangeComponents.Count -eq 2) {
                $rangeStart = Get-Date $timeRangeComponents[0]
                $rangeEnd = Get-Date $timeRangeComponents[1]

                # Check for crossing midnight
                if ($rangeStart -gt $rangeEnd) {
                    # If current time is between the start of range and midnight tonight, interpret start time as earlier today and end time as tomorrow
                    if ($currentTime -ge $rangeStart -and $currentTime -lt $midnight) {
                        $rangeEnd = $rangeEnd.AddDays(1)
                    }
                    # Otherwise interpret start time as yesterday and end time as today
                    else {
                        $rangeStart = $rangeStart.AddDays(-1)
                    }
                }
            }
            else {
                Write-Output "`tWARNING: Invalid time range format. Expects valid .Net DateTime-formatted start time and end time separated by '->'"
            }
        }
        # Otherwise attempt to parse as a full day entry, e.g. 'Monday' or 'December 25'
        else {
            # If specified as day of week, check if today
            if ([System.DayOfWeek].GetEnumValues() -contains $TimeRange) {
                if ($TimeRange -eq (Get-Date).DayOfWeek) {
                    $parsedDay = Get-Date "00:00"
                }
                else {
                    # Skip detected day of week that isn't today
                }
            }
            # Otherwise attempt to parse as a date, e.g. 'December 25'
            else {
                $parsedDay = Get-Date $TimeRange
            }

            if ($parsedDay -ne $null) {
                $rangeStart = $parsedDay # Defaults to midnight
                $rangeEnd = $parsedDay.AddHours(23).AddMinutes(59).AddSeconds(59) # End of the same day
            }
        }
    }
    catch {
        # Record any errors and return false by default
        Write-Output "`tWARNING: Exception encountered while parsing time range. Details: $($_.Exception.Message). Check the syntax of entry, e.g. '<StartTime> -> <EndTime>', or days/dates like 'Sunday' and 'December 25'"
        return $false
    }

    # Check if current time falls within range
    if ($currentTime -ge $rangeStart -and $currentTime -le $rangeEnd) {
        return $true
    }
    else {
        return $false
    }

} # End function Test-WithinAllowedTimeRange
