# Data sources
data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "aks_node_rg" {
  name = azurerm_kubernetes_cluster.aks.node_resource_group
}
