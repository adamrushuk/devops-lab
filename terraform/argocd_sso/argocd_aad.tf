provider "azurerm" {
  version = "2.44.0"
  features {}
}

variable "dns_zone_name" {
  default = "thehypepipe.co.uk"
}

variable "admin_consent" {
  default = true
}


# TODO: remove temp outputs
# data "azuread_application" "argocd_manual" {
#   display_name = "AR-Dev_ArgoCD"
# }

# output "azure_app_object_manual" {
#   value = data.azuread_application.argocd_manual
# }

# data "azuread_service_principal" "argocd_manual" {
#   display_name = "AR-Dev_ArgoCD"
# }

# output "azure_sp_object_manual" {
#   value = data.azuread_service_principal.argocd_manual
# }

output "azure_ad_object_argocd" {
  value = azuread_application.argocd
}
output "azure_sp_object_argocd" {
  value = azuread_service_principal.argocd
}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
# source: https://github.com/hashicorp/terraform-provider-azuread/issues/173#issuecomment-663727531
resource "azuread_application" "argocd" {
  display_name               = "ArgoCD"
  prevent_duplicate_names    = true
  homepage                   = "https://argocd.${var.dns_zone_name}"
  identifier_uris            = ["https://argocd.${var.dns_zone_name}/api/dex/callback"]
  reply_urls                 = ["https://argocd.${var.dns_zone_name}/api/dex/callback"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
  # type                       = "webapp/api"
  # owners                     = ["00000004-0000-0000-c000-000000000000"]
  group_membership_claims = "All"

  required_resource_access {
    //https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/grant-admin-consent
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id   = "5f8c59db-677d-491f-a6b8-5f174b11ec1d"
      type = "Scope"
    }
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }

  app_role {
    allowed_member_types = [
      "User"
    ]

    description  = "User"
    display_name = "User"
    is_enabled   = true
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
  provisioner "local-exec" {
    command = "az rest --method PATCH --uri 'https://graph.microsoft.com/v1.0/applications/${self.object_id}' --body '{\"optionalClaims\": {\"saml2Token\": [{\"name\": \"groups\", \"additionalProperties\": []}]}}'"
  }
}

resource "azuread_service_principal" "argocd" {
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

  # https://docs.microsoft.com/en-us/graph/application-saml-sso-configure-api?tabs=http#set-single-sign-on-mode
  provisioner "local-exec" {
    command = "az ad sp update --id ${azuread_application.argocd.application_id} --set preferredSingleSignOnMode='saml'"
  }

  # depends_on = [
  #   azuread_application.argocd
  # ]
}

resource "null_resource" "grant_admin_constent" {
  count = var.admin_consent ? 1 : 0
  // https://docs.microsoft.com/en-us/cli/azure/ad/app/permission?view=azure-cli-latest#code-try-3
  provisioner "local-exec" {
    command = "sleep 20"
  }
  provisioner "local-exec" {
    command = "az ad app permission admin-consent --id ${azuread_application.argocd.application_id}"
  }
  depends_on = [
    azuread_service_principal.argocd
  ]
}
