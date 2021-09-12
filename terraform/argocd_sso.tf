# Configures Azure AD App Registration Auth using OIDC
#
# https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/microsoft/#azure-ad-app-registration-auth-using-oidc

resource "random_password" "argocd" {
  length  = 32
  special = false
  keepers = {
    service_principal = azuread_application.argocd.id
  }
}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
resource "azuread_application" "argocd" {
  display_name            = var.argocd_app_reg_name
  identifier_uris         = ["https://${var.argocd_app_reg_name}"]
  sign_in_audience        = "AzureADMyOrg"
  group_membership_claims = ["All"]
  prevent_duplicate_names = true

  web {
    homepage_url  = "https://${var.argocd_fqdn}"
    redirect_uris = ["https://${var.argocd_fqdn}/auth/callback"]

    implicit_grant {
      access_token_issuance_enabled = false
    }
  }

  # you can check manually created app reg info in the app reg manifest tab
  # reference: https://github.com/mjisaak/azure-active-directory/blob/master/README.md#well-known-appids
  required_resource_access {
    # Microsoft Graph
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    # User.Read - e1fe6dd8-ba31-4d61-89e7-88639da4683d - Sign in and read user profile
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
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

data "azuread_client_config" "current" {}

resource "azuread_service_principal" "argocd" {
  application_id                = azuread_application.argocd.application_id
  owners                        = [data.azuread_client_config.current.object_id]
  description                   = "Argo CD Service Principle"
  notes                         = "Operational notes can go here"
  preferred_single_sign_on_mode = "oidc"
}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password
resource "azuread_application_password" "argocd" {
  application_object_id = azuread_application.argocd.id
  display_name          = "argocd_secret"
  # value                 = random_password.argocd.result
  end_date              = "2099-01-01T01:02:03Z"
  depends_on            = [azuread_service_principal.argocd]
}

data "azurerm_client_config" "current" {}


# argocd-cm patch
# https://www.terraform.io/docs/provisioners/local-exec.html
resource "null_resource" "argocd_cm" {
  triggers = {
    yaml_contents = filemd5(var.argocd_cm_yaml_path)
    sp_app_id     = azuread_service_principal.argocd.application_id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = var.aks_config_path
      ARGOCD_CM_PATCH_YAML = templatefile(
        var.argocd_cm_yaml_path,
        {
          "tenantId"    = data.azurerm_client_config.current.tenant_id
          "appClientId" = azuread_service_principal.argocd.application_id
        }
      )
    }
    # https://www.terraform.io/docs/language/functions/templatefile.html
    command = <<EOT
      kubectl patch configmap/argocd-cm --namespace argocd --type merge --patch "$ARGOCD_CM_PATCH_YAML"
    EOT
  }

  depends_on = [
    local_file.kubeconfig,
    null_resource.argocd_configure
  ]
}


# argocd-secret patch
# https://www.terraform.io/docs/provisioners/local-exec.html
# * uses "experiments = [provider_sensitive_attrs]" to hide output
# https://www.terraform.io/docs/language/expressions/references.html#sensitive-resource-attributes
resource "null_resource" "argocd_secret" {
  triggers = {
    yaml_contents = filemd5(var.argocd_secret_yaml_path)
    clientSecret  = random_password.argocd.result
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = var.aks_config_path
      ARGOCD_SECRET_PATCH_YAML = templatefile(
        var.argocd_secret_yaml_path,
        {
          "clientSecretBase64" = base64encode(random_password.argocd.result)
        }
      )
    }
    command = <<EOT
      kubectl patch secret/argocd-secret --namespace argocd --type merge --patch "$ARGOCD_SECRET_PATCH_YAML"
    EOT
  }

  depends_on = [
    local_file.kubeconfig,
    null_resource.argocd_configure
  ]
}


# argocd-rbac-cm patch
data "azuread_group" "argocd_admins" {
  display_name     = var.argocd_admins_aad_group_name
  security_enabled = true
}

# https://www.terraform.io/docs/provisioners/local-exec.html
resource "null_resource" "argocd_rbac_cm" {
  triggers = {
    yaml_contents    = filemd5(var.argocd_rbac_cm_yaml_path)
    argoAdminGroupId = data.azuread_group.argocd_admins.id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = var.aks_config_path
      ARGOCD_RBAC_CM_PATCH_YAML = templatefile(
        var.argocd_rbac_cm_yaml_path,
        {
          "argoAdminGroupId" = data.azuread_group.argocd_admins.id
        }
      )
    }
    command = <<EOT
      kubectl patch configmap/argocd-rbac-cm --namespace argocd --type merge --patch "$ARGOCD_RBAC_CM_PATCH_YAML"
    EOT
  }

  depends_on = [
    local_file.kubeconfig,
    null_resource.argocd_configure
  ]
}
