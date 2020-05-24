# DNS
resource "azurerm_resource_group" "dns" {
  name     = var.dns_resource_group_name
  location = var.location
  tags     = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_dns_zone" "dns" {
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.dns.name
}


# Service Principle for external-dns k8s deployment
resource "azuread_application" "aks_dns_sp" {
  name = var.dns_service_principle_name
}

resource "azuread_service_principal" "aks_dns_sp" {
  application_id = azuread_application.aks_dns_sp.application_id
}

resource "random_string" "aks_dns_sp" {
  length  = 16
  special = true
  keepers = {
    service_principal = azuread_service_principal.aks_dns_sp.id
  }
}

resource "azuread_service_principal_password" "aks_dns_sp" {
  service_principal_id = azuread_service_principal.aks_dns_sp.id
  value                = random_string.aks_dns_sp.result
  end_date_relative    = "8760h" # 8760h = 1 year

  lifecycle {
    ignore_changes = [end_date]
  }
}


# Service Principle role assignments
# reader on dns resource group
resource "azurerm_role_assignment" "aks_dns_sp_to_rg" {
  principal_id         = azuread_application.aks_dns_sp.application_id
  role_definition_name = "Reader"
  scope                = azurerm_dns_zone.dns.id
}

# contributor on dns zone
resource "azurerm_role_assignment" "aks_dns_sp_to_zone" {
  principal_id         = azuread_application.aks_dns_sp.application_id
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.dns.id
}


# Kuberenetes Secret for external-dns
data "azurerm_subscription" "current" {}

resource "kubernetes_secret" "external_dns" {
  metadata {
    name      = "azure-config-file"
    namespace = "ingress"
  }

  data = {
    cloud = <<EOT
    {
      "aadClientId": "${azuread_service_principal.aks_dns_sp.application_id}",
      "aadClientSecret": "${random_string.aks_dns_sp.result}",
      "tenantId": "${data.azurerm_subscription.current.tenant_id}",
      "subscriptionId": "${data.azurerm_subscription.current.subscription_id}",
      "resourceGroup": "${azurerm_resource_group.dns.name}"
    }
    EOT
  }

  type       = "Opaque"
  depends_on = [kubernetes_namespace.ingress]
}
