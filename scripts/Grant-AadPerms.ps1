# Grant administrator permissions to Terraform service principle
#
# source: https://www.terraform.io/docs/providers/azuread/guides/service_principal_configuration.html#granting-administrator-permissions

# ! NOTE: This requires the use of powershell cmdlets and is easiest to run in CloudShell.
# ! MUST use Windows PowerShell session (PowerShell 7 not currently supported)

# ? Notes on Role names
# In the Microsoft Graph API and Azure AD PowerShell, the role identified as "Company Administrator" is
# "Global Administrator" in the Azure portal.
# "User Account Administrator" is "User administrator" in the Azure portal

# Vars
# $tenantId = "00000000-0000-0000-0000-000000000000"
# [OPTIONAL] load Azure connection script to populate env vars
$tenantId = $env:ARM_TENANT_ID
$servicePrincipleName = "<TERRAFORM_SERVICE_PRINCIPLE_NAME>"
$userAdminRoleName = "User Account Administrator"
$globalAdminRoleName = "Company Administrator"

# Firstly, connect to the directory (WARNING: window may pop-up in the background!)
# Connect-AzureAD -TenantID "00000000-0000-0000-0000-000000000000"
Connect-AzureAD -TenantID $tenantId

# Next we want to get the correct role to assign, in this case User Account Administrator:
$role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq $userAdminRoleName}
Write-Host $role

# Since this is a built-in Role, if this doesn't exist (returns null above) then we need to instantiate it from the Role Template:
if ($null -eq $role) {
    # Instantiate an instance of the role template
    $roleTemplate = Get-AzureADDirectoryRoleTemplate | Where-Object {$_.displayName -eq $userAdminRoleName}
    Enable-AzureADDirectoryRole -RoleTemplateId $roleTemplate.ObjectId

    # Fetch User Account Administrator role instance again
    $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq $userAdminRoleName}
}

# Next we need the Client ID (sometimes referred to as the Application ID) of the Service Principal.
# We can look this up by it's display name
$sp = Get-AzureADServicePrincipal -All $true | Where-Object {$_.displayName -eq $servicePrincipleName}
$sp.ObjectId

# Now that we have all the required information we can add the service principal to the role:
Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RefObjectId $sp.ObjectId

# Finally we can repeat this for the Company Administrator role:
$role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq $globalAdminRoleName}
$role

if ($null -eq $role) {
    # Instantiate an instance of the role template
    $roleTemplate = Get-AzureADDirectoryRoleTemplate | Where-Object {$_.displayName -eq $globalAdminRoleName}
    Enable-AzureADDirectoryRole -RoleTemplateId $roleTemplate.ObjectId

    # Fetch User Account Administrator role instance again
    $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq $globalAdminRoleName}
}

$sp = Get-AzureADServicePrincipal -All $true | Where-Object {$_.displayName -eq $servicePrincipleName}
$sp.ObjectId

Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RefObjectId $sp.ObjectId

# At this point you should now be able to manage Users, Groups and other Azure Active Directory resources using Terraform.
