<#
.SYNOPSIS
    Deletes Azure Resource Groups with a given prefix
.DESCRIPTION
    Deletes Azure Resource Groups with a given prefix, with confirmation prompt and WhatIf functionality
.PARAMETER Prefixes
    An array of prefix strings that matches the start of the Resource Group name
    "abc99", "abc12" would match resource group called "abc99-rg-blahblah" and "abc12-rg-blahblah"
    Wildcards are supported, so you could use "abc*" instead of "abc99" and "abc12".
.PARAMETER MaxLimit
    Aborts script if too many Resource Groups are found.
    This is a safety check.
.PARAMETER WhatIf
    Does a dry-run and shows what Resource Groups would be deleted.
.EXAMPLE
    ./Delete-ResourceGroups.ps1 -Prefixes abc99.

    Deletes all Resource Groups starting with "abc99", eg:
    "abc99-rg-one"
    "abc99-rg-two"
.EXAMPLE
    ./Delete-ResourceGroups.ps1 -Prefixes abc99 -WhatIf

    Shows what Resource Groups would be deleted
.NOTES
    Author: Adam Rush
    GitHub: adamrushuk
    Twitter: @adamrushuk
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNull()]
    [string[]]
    $Prefixes,

    [int]
    $MaxLimit = 2,

    [switch]
    $WhatIf
)

Write-Output "Searching for Resource groups starting with [$($Prefixes -join ', ')]"

# init
$resourceGroupsToDelete = $null
$jobs = $null

foreach ($Prefix in $Prefixes) {

    $resourceGroups = $null
    $resourceGroups = @(Get-AzResourceGroup -Name "$Prefix*")
    Write-Host "`nResource groups found starting with [$Prefix]: [$($resourceGroups.Count)]" -ForegroundColor Yellow

    # abort if we find no resource groups
    if ($resourceGroups.Count -eq 0) {
        Write-Host "Continuing...`n" -ForegroundColor Green
        continue
    }

    # safety check
    if ($resourceGroups.Count -gt $MaxLimit) {
        Write-Host "ABORTING, MaxLimit was hit. Over [$MaxLimit] resource groups were found." -ForegroundColor Red
        return
    }


    # show resource groups
    $resourceGroups | Select-Object -ExpandProperty "ResourceGroupName"
    Write-Output ""

    # confirm deletion
    $confirmation = $null
    while($confirmation -ne "y") {
        if ($confirmation -eq 'n') { break }

        $confirmation = Read-Host "Are you sure you want to select these [$($resourceGroups.Count)] Resource Groups for deletion? [y/n]"
    }

    # queue
    if ($confirmation -eq "y") {
        Write-Output "Queuing [$($resourceGroups.Count)] Resource Groups..."
        $resourceGroupsToDelete += $resourceGroups
    } else {
        Write-Host "Skipping...`n" -ForegroundColor Yellow
    }
}

# delete
if ($resourceGroupsToDelete.Count -gt 0) {
    Write-Output "Deleting [$($resourceGroupsToDelete.Count)] Resource Groups..."
    if ($WhatIf.IsPresent) {
        $resourceGroupsToDelete | Remove-AzResourceGroup -Force -WhatIf
    } else {
        $timer = [Diagnostics.Stopwatch]::StartNew()
        $jobs += $resourceGroupsToDelete | Remove-AzResourceGroup -Force -AsJob
    }
}

# wait for jobs to complete
if ($null -ne $jobs) {
    $jobs

    Write-Output "`nWaiting for [$($jobs.Count)] jobs to finish..."
    $jobs | Wait-Job
    $jobs | Receive-Job -Keep

    $timer.Stop()
    Write-Output "Deletion jobs completed in: [$($timer.Elapsed.Minutes)m$($timer.Elapsed.Seconds)s]"
}
