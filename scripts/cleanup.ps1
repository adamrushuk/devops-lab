# cleanup all resource groups
# useful after failed build/destroy workflows

param(
    [Parameter(Mandatory)]
    [ValidateNotNull()]
    [string]
    $ResourceGroupPrefix
)

Write-Output "Authenticating PowerShell sessions using env vars..."
$servicePrincipleCredential = [pscredential]::new($env:ARM_CLIENT_ID, (ConvertTo-SecureString $env:ARM_CLIENT_SECRET -AsPlainText -Force))
Connect-AzAccount -ServicePrincipal -Tenant $env:ARM_TENANT_ID -Credential $servicePrincipleCredential -Subscription $env:ARM_SUBSCRIPTION_ID -Verbose

$taskMessage = "Deleting all devops lab resource groups"
Write-Output "STARTED: $taskMessage..."

Write-Output "Found these resource groups:"
$resourceGroupsToDelete = Get-AzResourceGroup -Name "$ResourceGroupPrefix*"
$resourceGroupsToDelete.ResourceGroupName

Write-Output "Deleting 'AsJob' for async removal..."
$jobs = $resourceGroupsToDelete | Remove-AzResourceGroup -Force -AsJob

Write-Output "Waiting for [$($jobs.Count)] jobs to finish..."
$jobs | Wait-Job
$jobs | Receive-Job -Keep

Write-Output "FINISHED: $taskMessage."
