# Data sources
data "azurerm_subscription" "current" {}

data "azuread_group" "aks" {
  name = var.aad_group_name
}

data "azurerm_resource_group" "aks_node_rg" {
  name = azurerm_kubernetes_cluster.aks.node_resource_group
}
