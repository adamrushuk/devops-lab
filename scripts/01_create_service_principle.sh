#! /usr/bin/env bash
#
# creates and configures a service principle for github / terraform usage

# ensure strict mode and predictable failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# vars
TERRAFORM_SP="sp_terraform"
CUSTOM_ROLE_FILEPATH="./scripts/02_terraform.customrole.json"
API_PERMS_FILEPATH="./scripts/03_sp_api_permissions_manifest.json"

#region service principle
# create service principle
service_principle_json=$(az ad sp create-for-rbac --name $TERRAFORM_SP --skip-assignment)
app_id=$(echo "$service_principle_json" | jq -r .appId)

# service principle json output
sp_json=$(echo "$service_principle_json" | jq ". | {ARM_CLIENT_ID: .appId, ARM_CLIENT_SECRET: .password, ARM_TENANT_ID: .tenant}")
subscription_id=$(az account show --query "id" --output tsv)
extra_json=$(cat <<-END
{
  "ARM_SUBSCRIPTION_ID": "$subscription_id"
}
END
)

# show merged json
echo "$sp_json $extra_json" | jq -s add
#endregion service principle



#region custom role definition
# list the roles assigned at the subscription level
az role assignment list --output table

# insert subscription id into role manifest
sed -i "s/<SUBSCRIPTION_ID>/$subscription_id/g" $CUSTOM_ROLE_FILEPATH

# create custom role for Terraform
az role definition create --role-definition $CUSTOM_ROLE_FILEPATH

# show new Terraform role definition
az role definition list --name Terraform

# assign role to service principle
az role assignment create --role Terraform --assignee "$app_id"

# list the roles assigned at the subscription level, again
az role assignment list --output table
#endregion custom role definition



#region service principle api permissions
# show current api perms
az ad app show --id "$app_id" --query requiredResourceAccess

# update api permissions using manifest json
# ? NOTE: these will not show in the Portal until admin-consent step below
az ad app update --id "$app_id" --required-resource-accesses @$API_PERMS_FILEPATH

# grant admin consent
az ad app permission admin-consent --id "$app_id" --verbose

# show new api perms
az ad app show --id "$app_id" --query requiredResourceAccess
#endregion service principle api permissions
