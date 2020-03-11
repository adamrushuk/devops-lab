# Deploy Nexus on AKS
throw "do not run whole script; F8 sections as required"

# TODO review notes and remove unwanted content

#region Connect Kubectl
# Vars
$prefix = "rush"
$aksClusterName = "$($prefix)-aks-001"
$aksClusterResourceGroupName = "$($prefix)-rg-aks-dev-001"

# standard | retain | stateful (this is best to retain data across deployments)
# $manifestFolderName = "stateful"

# Get AKS k8s creds
az aks get-credentials --resource-group $aksClusterResourceGroupName --name $aksClusterName --overwrite-existing

# Open AKS k8s dashboard
az aks browse --resource-group $aksClusterResourceGroupName --name $aksClusterName

# Show resources
# Cluster scope
kubectl get nodes,ns,pv

# Namespace scope
kubectl get all -A
kubectl get ingress -A
kubectl get configmap -A
kubectl get configmap -A | sls nginx
kubectl get configmap -n ingress-tls nginx-ingress-controller -o yaml
kubectl describe configmap -n ingress-tls nginx-ingress-controller
#endregion Connect Kubectl



#region Deploy Nexus
# https://help.sonatype.com/repomanager3/formats/nuget-repositories

# AKS Container Insights is awesome - view live data
Start-Process https://portal.azure.com/#blade/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/containerInsights/menuId/containerInsights

# Prepare
# permanently save the namespace for all subsequent kubectl commands in that context
kubectl config set-context --current --namespace ingress-tls
kubectl config current-context

# Custom Storage Class
# Show default yaml
kubectl get sc default -o yaml --export

# Create custom storage class (with "reclaimPolicy: Retain")
https://docs.microsoft.com/en-us/azure/aks/concepts-storage#storage-classes


# Check
kubectl get sc,pvc,pv,all
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get events --sort-by=.metadata.creationTimestamp -w
$podName = kubectl get pod -l app=nexus -o jsonpath="{.items[0].metadata.name}"
kubectl describe pod $podName
kubectl top pod $podName

# Wait for pod to be ready
kubectl get pod $podName --watch
kubectl get svc nexus --watch

# View container (Nexus application) logs
kubectl logs $podName
# Follow (tail) logs
kubectl logs -f $podName

# Assemble and show App URL
$nexusUri = kubectl get svc nexus --ignore-not-found -o jsonpath="{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}"
$appurl = "http://$nexusUri"
Write-Output "Browse to app with: $appurl"
Start-Process $appurl

# Connect to pod and output generated admin password
kubectl exec -it $podName /bin/bash
echo -e "\nadmin password: \n$(cat /nexus-data/admin.password)\n"

# Show nexus user details (should have UID 200)
cat /etc/passwd | grep nexus

# Show persistent data folder mount info (eg. /nexus-data)
# Check available disk space on mount
df -h | grep -iE "Use%|nexus"
# Check perms and owner
ls -lah / | grep nexus
# Show data files
ls -lah /nexus-data

# Get NuGet API token from Nexus
Start-Process "http://$nexusUri/#user/nugetapitoken"
$nuGetApiKey = "<NuGetApiKey>"

# Set NuGet API-Key Realm as "Active": http://<NexusHost>:8081/#admin/security/realms
Start-Process https://sammart.in/post/creating-your-own-powershell-repository-with-nexus-3/
Start-Process "http://$nexusUri/#admin/security/realms"

# Register Nuget feed as PowerShell repository
$repoUrl = "http://$nexusUri/repository/nuget-hosted/"
$repoName = "MyNugetRepo"
Unregister-PSRepository -Name $repoName
Register-PSRepository -Name $repoName -SourceLocation $repoUrl -PublishLocation $repoUrl -PackageManagementProvider "nuget" -InstallationPolicy "Trusted"
Get-PSRepository
Install-Module packagemanagement,powershellget -Verbose

# Publish modules
"Az.Advisor", "Az.Aks" | ForEach-Object { Publish-Module -Name "$env:HOME\Documents\PowerShell\Modules\$_" -Repository $repoName -NuGetApiKey $nuGetApiKey -Verbose }

# Find modules
Find-Module -Repository $repoName

# Show modules in Nexus repo
Start-Process "http://$nexusUri/#browse/browse:nuget-hosted"
#endregion Deploy Nexus



# BACKUP / RESTORE
# https://docs.microsoft.com/en-us/azure/aks/azure-disks-dynamic-pv#back-up-a-persistent-volume



#region SCALE
# Scale down StatefulSet
kubectl get statefulsets
kubectl scale statefulsets nexus --replicas 0
kubectl get all,pvc,pv

# Scale up StatefulSet
kubectl scale statefulsets nexus --replicas 1
# Check
kubectl get sc,pvc,pv,all
kubectl get events --sort-by=.metadata.creationTimestamp
$podName = kubectl get pod -l app=nexus -o jsonpath="{.items[0].metadata.name}"
kubectl describe pod $podName
# Wait for pod to be ready
kubectl get pod $podName --watch
#endregion SCALE



#region CLEANUP
# Delete manifest
kubectl delete -f ./manifests/nexus.yml
kubectl get events --sort-by=.metadata.creationTimestamp --watch

# NOTE: Persistent Volume and Persistent Volume Claims may not be deleted
# Get and delete Persistent Volume Claims
kubectl get pvc,pv -A
kubectl describe pv -A
kubectl describe pvc -A
kubectl delete pvc,pv -A --all

# Check
kubectl get all,pvc,pv
#endregion CLEANUP
