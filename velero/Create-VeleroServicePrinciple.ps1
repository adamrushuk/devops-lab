# Create a new Azure service principle for Velero credentials
# https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#create-service-principal

# Vars
$servicePrincipleName = "velero_sp"
$veleroResourceGroupName = "rush-rg-velero-dev-001"

# Login to Azure
az login

# Create new service principle
# WARNING: assigns the Contributer role to the current subscription
$servicePrinciple = az ad sp create-for-rbac --name $servicePrincipleName --query "{ AZURE_CLIENT_ID: appId, AZURE_CLIENT_SECRET: password, AZURE_TENANT_ID: tenant }" | ConvertFrom-Json
$subscription = az account show --query "{ AZURE_SUBSCRIPTION_ID: id }" | ConvertFrom-Json

# Output values and put into GitHub Secrets
Write-Output "Navigate to https://github.com/<GITHUB_USERNAME>/<REPO_NAME>/settings/secrets and create GitHub secrets using the new Service Principle credentials shown below...`n"

# Output credentials in correct format for Velero
$veleroCredentialString = @"
AZURE_SUBSCRIPTION_ID=$($subscription.AZURE_SUBSCRIPTION_ID)
AZURE_TENANT_ID=$($servicePrinciple.AZURE_TENANT_ID)
AZURE_CLIENT_ID=$($servicePrinciple.AZURE_CLIENT_ID)
AZURE_CLIENT_SECRET=$($servicePrinciple.AZURE_CLIENT_SECRET)
AZURE_RESOURCE_GROUP=$veleroResourceGroupName
AZURE_CLOUD_NAME=AzurePublicCloud
"@

$veleroCredentialString
$env:CREDENTIALS_VELERO = $veleroCredentialString
