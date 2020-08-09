# Data sources
data "azurerm_subscription" "current" {}

data "azuread_group" "aks" {
  name = var.aad_group_name
}
