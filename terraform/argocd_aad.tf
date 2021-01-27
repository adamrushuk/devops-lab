# TODO: remove temp outputs
data "azuread_application" "argocd_manual" {
  display_name = "AR-Dev_ArgoCD"
}

output "azure_app_object_manual" {
  value = data.azuread_application.argocd_manual
}

data "azuread_service_principal" "argocd_manual" {
  display_name = "AR-Dev_ArgoCD"
}

output "azure_sp_object_manual" {
  value = data.azuread_service_principal.argocd_manual
}

output "azure_ad_object_argocd" {
  value = azuread_application.argocd
}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
resource "azuread_application" "argocd" {
  display_name               = "ArgoCD"
  prevent_duplicate_names    = true
  homepage                   = "https://argocd.${var.dns_zone_name}"
  identifier_uris            = ["https://argocd.${var.dns_zone_name}/api/dex/callback"]
  reply_urls                 = ["https://argocd.${var.dns_zone_name}/api/dex/callback"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
  type                       = "webapp/api"
  # owners                     = ["00000004-0000-0000-c000-000000000000"]
  group_membership_claims = "All"

  # TODO: are "required_resource_access" blocks needed?
  # required_resource_access {
  #   # Microsoft Graph App ID
  #   resource_app_id = "00000003-0000-0000-c000-000000000000"

  #   resource_access {
  #     id   = "..."
  #     type = "Role"
  #   }

  #   resource_access {
  #     id   = "..."
  #     type = "Scope"
  #   }

  #   resource_access {
  #     id   = "..."
  #     type = "Scope"
  #   }
  # }

  # required_resource_access {
  #   # AAD Graph API App ID
  #   resource_app_id = "00000002-0000-0000-c000-000000000000"

  #   resource_access {
  #     id   = "..."
  #     type = "Scope"
  #   }
  # }

  app_role {
    allowed_member_types = [
      "User"
    ]

    description  = "User"
    display_name = "User"
    is_enabled   = true
    # value        = ""
  }

  app_role {
    allowed_member_types = [
      "User"
    ]

    description  = "msiam_access"
    display_name = "msiam_access"
    is_enabled   = true
  }


  // We need to wait because Azure Graph API returns a 200 before its call-able #eventualconsistancy...
  provisioner "local-exec" {
    command = "sleep 20"
  }
  //https://github.com/Azure/azure-cli/issues/7579
  //Add metadata URL
  // provisioner "local-exec" {
  //   command = "az ad app update --id ${self.application_id} --set samlMetadataUrl=${var.saml_metadata_url}"
  //   }
  // We need to wait because Azure Graph API returns a 200 before its call-able #eventualconsistancy...
  // provisioner "local-exec" {
  //   command = "sleep 5"
  // }
  //https://github.com/Azure/azure-cli/issues/12946
  //https://github.com/Azure/azure-cli/issues/11534
  //https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-optional-claims
  //Optional Claims for tokens
  # provisioner "local-exec" {
  #   command = "az rest --method PATCH --uri 'https://graph.microsoft.com/v1.0/applications/${self.object_id}' --body '{\"optionalClaims\": {\"saml2Token\": [{\"name\": \"groups\", \"additionalProperties\": [\"sam_account_name\"]}]}}'"
  # }


  # oauth2_permissions {
  #   admin_consent_description  = "Allow the application to access Argo CD on behalf of the signed-in user."
  #   admin_consent_display_name = "Access Argo CD on behalf of the signed-in user"
  #   is_enabled                 = true
  #   type                       = "User"
  #   user_consent_description   = "Allow the application to access Argo CD on your behalf."
  #   user_consent_display_name  = "Access Argo CD"
  #   value                      = "user_impersonation"
  # }

  # oauth2_permissions {
  #   admin_consent_description  = "Administer the example application"
  #   admin_consent_display_name = "Administer"
  #   is_enabled                 = true
  #   type                       = "Admin"
  #   value                      = "administer"
  # }

  optional_claims {
    access_token {
      name = "email"
    }

    # access_token {
    #   name = "otherclaim"
    # }

    id_token {
      name                  = "userprincipalname"
      source                = "user"
      essential             = true
      # additional_properties = ["emit_as_roles"]
    }
  }
}

# Test adding SP to make an Enterprise App
# resource "azuread_service_principal" "this" {
#   application_id = azuread_application.argocd.application_id
#   tags = [
#     # "AppServiceIntegratedApp",
#     "WindowsAzureActiveDirectoryIntegratedApp",
#   ]
# }

# TODO: change id to argocd
resource "azuread_service_principal" "this" {
  //https://github.com/Azure/azure-cli/issues/9250
  application_id = azuread_application.argocd.application_id
  tags = [
    "WindowsAzureActiveDirectoryIntegratedApp",
    "WindowsAzureActiveDirectoryCustomSingleSignOnApplication",
    "WindowsAzureActiveDirectoryGalleryApplicationNonPrimaryV1"
  ]
  // We need to wait because Azure Graph API returns a 200 before its call-able #eventualconsistancy...
  provisioner "local-exec" {
    command = "sleep 20"
  }
  provisioner "local-exec" {
    command = "az ad sp update --id ${azuread_application.argocd.application_id} --set preferredSingleSignOnMode='saml'"
  }
  # depends_on = [
  #   azuread_application.argocd
  # ]
}

