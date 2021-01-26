# argocd helm chart
# https://argoproj.github.io/argo-cd/

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  timeouts {
    delete = "15m"
  }

  depends_on = [module.aks]
}

# https://www.terraform.io/docs/provisioners/local-exec.html
resource "null_resource" "argocd_cert_sync" {
  triggers = {
    # always_run = "${timestamp()}"
    cert_sync_yaml_contents = filemd5(var.argocd_cert_sync_yaml_path)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      export KUBECONFIG=${var.aks_config_path}
      kubectl apply -f ${var.argocd_cert_sync_yaml_path}
    EOT
  }

  depends_on = [
    local_file.kubeconfig,
    helm_release.akv2k8s,
    kubernetes_namespace.argocd
  ]
}

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "argocd" {
  chart      = "argo-cd"
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  version    = var.argocd_chart_version
  timeout    = 600
  atomic     = true
  values     = ["${file("${path.module}/files/argocd-values.yaml")}"]

  set {
    name  = "global.image.tag"
    value = var.argocd_image_tag
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = "argocd.${var.dns_zone_name}"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "argocd.${var.dns_zone_name}"
  }

  set {
    name  = "server.ingress.tls[0].secretName"
    value = "argocd-ingress-tls"
  }

  # Argo CD's externally facing base URL
  # used for logout destination and when configuring SSO
  set {
    name  = "server.config.url"
    value = "https://argocd.${var.dns_zone_name}"
  }

  depends_on = [
    null_resource.argocd_cert_sync
  ]
}

# post-install config
resource "null_resource" "argocd_configure" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      ARGOCD_ADMIN_PASSWORD              = var.argocd_admin_password
      ARGOCD_FQDN                        = var.argocd_fqdn
      HELM_CHART_REPO_DEPLOY_PRIVATE_KEY = var.helm_chart_repo_deploy_private_key
      KUBECONFIG                         = var.aks_config_path
      REPO_URL                           = "git@github.com:adamrushuk/charts-private.git"
    }

    command = <<-EOT
      chmod -R +x ./files/scripts
      timeout 5m ./files/scripts/argocd_config.sh
    EOT
  }

  depends_on = [
    local_file.kubeconfig,
    helm_release.argocd
  ]
}

# create argo app definitions
resource "null_resource" "argocd_apps" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = var.aks_config_path
    }
    command = <<-EOT
      kubectl apply -f ${var.gitlab_argocd_app_path}
    EOT
  }

  depends_on = [
    local_file.kubeconfig,
    null_resource.argocd_configure
  ]
}

# TODO: remove temp output
data "azuread_application" "argocd" {
  display_name = "AR-Dev_ArgoCD"
}

output "azure_ad_object_id" {
  value = data.azuread_application.argocd
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
  # type                       = "webapp/api"
  # owners                     = ["00000004-0000-0000-c000-000000000000"]
  group_membership_claims    = "All"

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

  # app_role {
  #   allowed_member_types = [
  #     "User"
  #   ]

  #   description  = "User"
  #   display_name = "User"
  #   is_enabled   = true
  #   value        = ""
  # }

  oauth2_permissions {
    admin_consent_description  = "Allow the application to access Argo CD on behalf of the signed-in user."
    admin_consent_display_name = "Access Argo CD on behalf of the signed-in user"
    is_enabled                 = true
    type                       = "User"
    user_consent_description   = "Allow the application to access Argo CD on your behalf."
    user_consent_display_name  = "Access Argo CD"
    value                      = "user_impersonation"
  }

  # oauth2_permissions {
  #   admin_consent_description  = "Administer the example application"
  #   admin_consent_display_name = "Administer"
  #   is_enabled                 = true
  #   type                       = "Admin"
  #   value                      = "administer"
  # }

  # optional_claims {
  #   access_token {
  #     name = "myclaim"
  #   }

  #   access_token {
  #     name = "otherclaim"
  #   }

  #   id_token {
  #     name                  = "userclaim"
  #     source                = "user"
  #     essential             = true
  #     additional_properties = ["emit_as_roles"]
  #   }
  # }
}
