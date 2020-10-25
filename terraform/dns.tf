# DNS
data "azurerm_resource_group" "dns" {
  name = var.dns_resource_group_name
}

data "azurerm_dns_zone" "dns" {
  name                = var.dns_zone_name
  resource_group_name = data.azurerm_resource_group.dns.name
}

# # Service Principle for external-dns k8s deployment
# resource "azuread_application" "aks_dns_sp" {
#   name = var.dns_service_principle_name
# }

# resource "azuread_service_principal" "aks_dns_sp" {
#   application_id = azuread_application.aks_dns_sp.application_id
# }

# resource "random_string" "aks_dns_sp" {
#   length  = 16
#   special = true
#   keepers = {
#     service_principal = azuread_service_principal.aks_dns_sp.id
#   }
# }

# resource "azuread_service_principal_password" "aks_dns_sp" {
#   service_principal_id = azuread_service_principal.aks_dns_sp.id
#   value                = random_string.aks_dns_sp.result
#   end_date_relative    = "8760h" # 8760h = 1 year

#   lifecycle {
#     ignore_changes = [end_date]
#   }
# }

# Service Principle role assignments
# reader on dns resource group
resource "azurerm_role_assignment" "aks_dns_mi_to_rg" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "Reader"
  scope                            = data.azurerm_dns_zone.dns.id
  skip_service_principal_aad_check = true
}

# contributor on dns zone
resource "azurerm_role_assignment" "aks_dns_mi_to_zone" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "Contributor"
  scope                            = data.azurerm_resource_group.dns.id
  skip_service_principal_aad_check = true
}

# # Kuberenetes Secret for external-dns
# # https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md#azure-managed-service-identity-msi
# resource "kubernetes_secret" "external_dns" {
#   metadata {
#     name      = "azure-config-file"
#     namespace = "ingress"
#   }

#   data = {
#     "azure.json" = <<EOT
# {
#   "aadClientId": "${azuread_service_principal.aks_dns_sp.application_id}",
#   "aadClientSecret": "${random_string.aks_dns_sp.result}",
#   "tenantId": "${data.azurerm_subscription.current.tenant_id}",
#   "subscriptionId": "${data.azurerm_subscription.current.subscription_id}",
#   "resourceGroup": "${data.azurerm_resource_group.dns.name}"
# }
# EOT
#   }

#   type       = "Opaque"
#   depends_on = [kubernetes_namespace.ingress]
# }

# https://github.com/bitnami/charts/tree/master/bitnami/external-dns
# https://bitnami.com/stack/external-dns/helm
resource "helm_release" "external_dns" {
  chart = "external-dns"
  name  = "external-dns"
  # TODO: change to "external-dns" namespace
  namespace  = "ingress"
  repository = "https://charts.bitnami.com/bitnami"
  version    = var.external_dns_chart_version
  # values     = [file("helm/NOT_USED.yaml")]

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

  timeout = 600
  depends_on = [
    kubernetes_namespace.ingress,
    azurerm_role_assignment.aks_dns_mi_to_rg,
    azurerm_role_assignment.aks_dns_mi_to_zone
  ]
}
