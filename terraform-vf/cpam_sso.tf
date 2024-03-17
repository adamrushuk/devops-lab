# Configures EntraID App Registration Auth using OIDC

locals {
  cpam_fqdn = "vgpwa1vw.eito-dublin.local"
  cpam_owner_ids = [
    "cc9375df-8e64-4e24-8ab2-45e02c01a111", # Adam Rush
  ]
}

# CPAM groups
resource "azuread_group" "cpam_admins" {
  display_name            = "CPAM-Admins"
  security_enabled        = true
  prevent_duplicate_names = true
  owners                  = concat([data.azuread_client_config.current.object_id], local.cpam_owner_ids)
}

resource "azuread_group" "cpam_readonly" {
  display_name            = "CPAM-ReadOnly"
  security_enabled        = true
  prevent_duplicate_names = true
  owners                  = concat([data.azuread_client_config.current.object_id], local.cpam_owner_ids)
}

resource "azuread_service_principal" "msgraph" {
  client_id    = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing = true
}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
resource "azuread_application" "cpam" {
  display_name            = "cpam"
  description             = "Used for Single Sign On to CPAM"
  owners                  = local.cpam_owner_ids
  sign_in_audience        = "AzureADMyOrg"
  group_membership_claims = ["All"]
  prevent_duplicate_names = true

  web {
    redirect_uris = ["https://vgpwa1vw.eito-dublin.local/PasswordVault/api/Auth/OIDC/TitanicusOIDC/Token"]
    logout_url    = "https://${local.cpam_fqdn}/PasswordVault/v10/logon"

    implicit_grant {
      access_token_issuance_enabled = false
    }
  }

  required_resource_access {
    # Microsoft Graph
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    # Oauth2Permissions are delegated permissions, type=Scope
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]
      type = "Scope"
    }
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Reader Access to the PAM"
    display_name         = "PAM Read Only"
    enabled              = true
    id                   = random_uuid.reader.id
    value                = "reader"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Administrative Access to the PAM"
    display_name         = "PAM Administrators"
    enabled              = true
    id                   = random_uuid.admin.id
    value                = "admin"
  }

  optional_claims {
    access_token {
      name                  = "groups"
      source                = null
      essential             = false
      additional_properties = []
    }

    id_token {
      name                  = "groups"
      source                = null
      essential             = false
      additional_properties = []
    }
  }
}

resource "azuread_service_principal" "cpam" {
  client_id                     = azuread_application.cpam.client_id
  owners                        = concat([data.azuread_client_config.current.object_id], local.cpam_owner_ids)
  description                   = "Argo CD Service Principle"
  notes                         = "Operational notes can go here"
  preferred_single_sign_on_mode = "oidc"
}

# Random IDs for the App Roles
resource "random_uuid" "reader" {}

resource "random_uuid" "admin" {}

# App Role Assignments
resource "azuread_app_role_assignment" "cpam_readonly" {
  app_role_id         = azuread_service_principal.cpam.app_role_ids["reader"]
  principal_object_id = azuread_group.cpam_readonly.object_id
  resource_object_id  = azuread_service_principal.cpam.object_id
}

resource "azuread_app_role_assignment" "cpam_admins" {
  app_role_id         = azuread_service_principal.cpam.app_role_ids["admin"]
  principal_object_id = azuread_group.cpam_admins.object_id
  resource_object_id  = azuread_service_principal.cpam.object_id
}
