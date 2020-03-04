# Create a new service principle for GitHub Actions workflow

# Vars
# Create SP, eg: "github_actions_sp" | "velero_sp"
$servicePrincipleName = "github_actions_sp"

# Login to Azure
az login

# Create new service principle
# WARNING: assigns the Contributer role to the current subscription
$spJson = az ad sp create-for-rbac --name $servicePrincipleName --query "{ ARM_CLIENT_ID: appId, ARM_CLIENT_SECRET: password, ARM_TENANT_ID: tenant }"
$subJson = az account show --query "{ ARM_SUBSCRIPTION_ID: id }"

# Output values and put into GitHub Secrets
Write-Output "Navigate to https://github.com/<GITHUB_USERNAME>/<REPO_NAME>/settings/secrets and create GitHub secrets using the new Service Principle credentials"
$spJson
$subJson
