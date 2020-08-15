<#
.SYNOPSIS
    Waits for a Load Balancer Ingress IP then uses it to update a DNS A record
.DESCRIPTION
    Waits for a Load Balancer Ingress IP then uses it to update a DNS A record
.LINK
    https://www.powershellgallery.com/packages/Trackyon.GoDaddy
.NOTES
    Author:  Adam Rush
    Blog:    https://adamrushuk.github.io
    GitHub:  https://github.com/adamrushuk
    Twitter: @adamrushuk
#>

[CmdletBinding()]
param (
    $AksResourceGroupName = $env:aks_rg,
    $AksClusterName = $env:aks_cluster_name,
    $UseAksAdmin,
    $TimeoutSeconds = 1800, # 1800s = 30 mins
    $RetryIntervalSeconds = 10,
    $DomainName = $env:dns_domain_name,
    $HasSubDomainName = $env:has_subdomain,
    $RecordName = "@",
    $ApiKey = $env:api_key,
    $ApiSecret = $env:api_secret,
    $Ttl = 600, # in seconds
    $ServiceLabel = 'app=nginx-ingress',
    $NameSpace = 'ingress',
    $DockerPrefix = 'docker'
)

# Ensure verbose messages are output
$VerbosePreference = "Continue"
# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Setting k8s current context
$message = "Getting AKS credentials"
Write-Verbose "`nSTARTED: $message..."
az aks get-credentials --resource-group $env:AKS_RG_NAME --name $env:AKS_CLUSTER_NAME --overwrite-existing --admin
Write-Verbose "FINISHED: $message.`n"

# Wait for Loadbalancer IP to exist
$timer = [Diagnostics.Stopwatch]::StartNew()

while (-not ($IPAddress = kubectl get service -l $ServiceLabel --namespace $NameSpace --ignore-not-found -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")) {

    if ($timer.Elapsed.TotalSeconds -gt $TimeoutSeconds) {
        Write-Verbose "Elapsed task time of [$($timer.Elapsed.TotalSeconds)] has exceeded timeout of [$TimeoutSeconds]"
        exit 1
    } else {
        Write-Verbose "Current Loadbalancer IP value: [$IPAddress]"
        Write-Verbose "Still creating LoadBalancer IP... [$($timer.Elapsed.Minutes)m$($timer.Elapsed.Seconds)s elapsed]"
        Start-Sleep -Seconds $RetryIntervalSeconds
    }
}

$timer.Stop()

# Update pipeline variable
Write-Verbose "`nCreation complete after [$($timer.Elapsed.Minutes)m$($timer.Elapsed.Seconds)s]"
Write-Verbose "Found IP [$IPAddress]"



#region DNS
# Split subdomain
if ($HasSubDomainName -eq "true") {
    Write-Verbose "HasSubDomainName switch selected..."
    $DomainNameSplit = $DomainName -split "\."
    $RecordName = $DomainNameSplit[0]
    $DomainName = $DomainNameSplit[1..($DomainNameSplit.Count)] -join "."

    Write-Verbose "Selected SubDomain: [$RecordName]"
    Write-Verbose "Selected Domain: [$DomainName]"
}

# Init
$message = "Installing GoDaddy PowerShell module"
Write-Verbose "`nSTARTED: $message..."
Install-Module -Name "Trackyon.GoDaddy"-Scope "CurrentUser" -Force | Out-Null
Write-Verbose "FINISHED: $message."

# API Creds
$apiCredential = [pscredential]::new($ApiKey, (ConvertTo-SecureString -String $ApiSecret -AsPlainText -Force))

$message = "Getting current domain information"
Write-Verbose "`nSTARTED: $message..."

# Output Domain
Get-GDDomain -credentials $apiCredential -domain $DomainName | Out-String | Write-Verbose

# Output current records
Get-GDDomainRecord -credentials $apiCredential -domain $DomainName | Out-String | Write-Verbose
Write-Verbose "FINISHED: $message."

# Update A record for nexus
$message = "Updating nexus A record [$RecordName] for domain [$DomainName] with IP Address [$IPAddress]"
Write-Verbose "STARTED: $message"
Set-GDDomainRecord -credentials $apiCredential -domain $DomainName -name $RecordName -ipaddress $IPAddress -type "A" -ttl $Ttl -Force
Write-Verbose "FINISHED: $message"

# Update A record for docker
$RecordName = "$DockerPrefix-$RecordName"
$message = "Updating docker A record [$RecordName] for domain [$DomainName] with IP Address [$IPAddress]"
Write-Verbose "STARTED: $message"
Set-GDDomainRecord -credentials $apiCredential -domain $DomainName -name $RecordName -ipaddress $IPAddress -type "A" -ttl $Ttl -Force
Write-Verbose "FINISHED: $message"

# Output updated records
Get-GDDomainRecord -credentials $apiCredential -domain $DomainName | Out-String | Write-Verbose
#endregion DNS
