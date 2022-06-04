# cleanup all resource groups
# useful after failed build/destroy workflows

$taskMessage="Deleting all devops lab resource groups"
Write-Output "STARTED: $taskMessage..."

Write-Output "Found these resource groups:"
$resourceGroupsToDelete = Get-AzResourceGroup -Name "$PREFIX*"
$resourceGroupsToDelete.ResourceGroupName

Write-Output "Deleting 'AsJob' for async removal..."
$jobs = $resourceGroupsToDelete | Remove-AzResourceGroup -Force -AsJob

Write-Output "Waiting for [$($jobs.Count)] jobs to finish..."
$jobs | Wait-Job
$jobs | Receive-Job -Keep

Write-Output "FINISHED: $taskMessage."
