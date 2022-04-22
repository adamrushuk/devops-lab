# DNS
data "azurerm_resource_group" "dns" {
  name = var.dns_resource_group_name
}

data "azurerm_dns_zone" "dns" {
  name                = var.dns_zone_name
  resource_group_name = data.azurerm_resource_group.dns.name
}

# external-dns managed identity
resource "azurerm_user_assigned_identity" "external_dns" {
  resource_group_name = module.aks.node_resource_group
  location            = var.location
  name                = "mi-external-dns"
}

# reader on dns resource group
resource "azurerm_role_assignment" "aks_dns_mi_to_rg" {
  principal_id                     = azurerm_user_assigned_identity.external_dns.principal_id
  role_definition_name             = "Reader"
  scope                            = data.azurerm_dns_zone.dns.id
  skip_service_principal_aad_check = true
}

# contributor on dns zone
resource "azurerm_role_assignment" "aks_dns_mi_to_zone" {
  principal_id                     = azurerm_user_assigned_identity.external_dns.principal_id
  role_definition_name             = "Contributor"
  scope                            = data.azurerm_resource_group.dns.id
  skip_service_principal_aad_check = true
}


resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
  timeouts {
    delete = "15m"
  }

  depends_on = [module.aks]
}

# https://www.terraform.io/docs/provisioners/local-exec.html
resource "null_resource" "azureIdentity_external_dns" {
  triggers = {
    azureidentity_external_dns_yaml_contents = filemd5(var.azureidentity_external_dns_yaml_path)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = var.aks_config_path
      AZUREIDENTITY_EXTERNAL_DNS_YAML = templatefile(
        var.azureidentity_external_dns_yaml_path,
        {
          "managedIdentityResourceID" = azurerm_user_assigned_identity.external_dns.id
          "managedIdentityClientID"   = azurerm_user_assigned_identity.external_dns.client_id
        }
      )
    }
    command = <<EOT
      echo "$AZUREIDENTITY_EXTERNAL_DNS_YAML" | kubectl apply -f -
    EOT
  }

  depends_on = [
    local_sensitive_file.kubeconfig,
    kubernetes_namespace.external_dns,
    helm_release.aad_pod_identity
  ]
}

# https://github.com/bitnami/charts/tree/master/bitnami/external-dns
# https://bitnami.com/stack/external-dns/helm
resource "helm_release" "external_dns" {
  chart      = "external-dns"
  name       = "external-dns"
  namespace  = kubernetes_namespace.external_dns.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  version    = var.external_dns_chart_version
  timeout    = 600
  atomic     = true
  # values     = [file("helm/NOT_USED.yaml")]

  # specify user-assigned managed identity
  set {
    name  = "azure.userAssignedIdentityID"
    value = azurerm_user_assigned_identity.external_dns.client_id
  }

  set {
    name  = "logLevel"
    value = "debug"
  }

  set {
    name  = "domainFilters[0]"
    value = var.dns_zone_name
  }

  set {
    name  = "provider"
    value = "azure"
  }

  set {
    name  = "azure.tenantId"
    value = data.azurerm_subscription.current.tenant_id
  }

  set {
    name  = "azure.subscriptionId"
    value = data.azurerm_subscription.current.subscription_id
  }

  set {
    name  = "azure.resourceGroup"
    value = data.azurerm_resource_group.dns.name
  }

  set {
    name  = "azure.useManagedIdentityExtension"
    value = true
  }

  # podbinding for Managed Identity auth
  set {
    name  = "podLabels.aadpodidbinding"
    value = "external-dns"
  }

  depends_on = [
    azurerm_role_assignment.aks_dns_mi_to_rg,
    azurerm_role_assignment.aks_dns_mi_to_zone
  ]
}
