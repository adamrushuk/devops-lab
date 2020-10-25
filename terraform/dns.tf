# DNS
data "azurerm_resource_group" "dns" {
  name     = var.dns_resource_group_name
}

data "azurerm_dns_zone" "dns" {
  name                = var.dns_zone_name
  resource_group_name = data.azurerm_resource_group.dns.name
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
  principal_id                     = azuread_service_principal.aks_dns_sp.id
  role_definition_name             = "Reader"
  scope                            = data.azurerm_dns_zone.dns.id
  skip_service_principal_aad_check = true
  depends_on                       = [azuread_service_principal_password.aks_dns_sp]
}

# contributor on dns zone
resource "azurerm_role_assignment" "aks_dns_sp_to_zone" {
  principal_id                     = azuread_service_principal.aks_dns_sp.id
  role_definition_name             = "Contributor"
  scope                            = data.azurerm_resource_group.dns.id
  skip_service_principal_aad_check = true
  depends_on                       = [azuread_service_principal_password.aks_dns_sp]
}


# Kuberenetes Secret for external-dns
resource "kubernetes_secret" "external_dns" {
  metadata {
    name      = "azure-config-file"
    namespace = "ingress"
  }

  data = {
    "azure.json" = <<EOT
{
  "aadClientId": "${azuread_service_principal.aks_dns_sp.application_id}",
  "aadClientSecret": "${random_string.aks_dns_sp.result}",
  "tenantId": "${data.azurerm_subscription.current.tenant_id}",
  "subscriptionId": "${data.azurerm_subscription.current.subscription_id}",
  "resourceGroup": "${data.azurerm_resource_group.dns.name}"
}
EOT
  }

  type       = "Opaque"
  depends_on = [kubernetes_namespace.ingress]
}
