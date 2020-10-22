# velero managed identity auth
resource "azurerm_user_assigned_identity" "velero" {
  count               = var.velero_enabled ? 1 : 0
  resource_group_name = azurerm_resource_group.velero[0].name
  location            = azurerm_resource_group.velero[0].location

  name = "mi_velero"
}

# assign velero MI contributor rights to velero storage RG
resource "azurerm_role_assignment" "velero_mi_velero_storage_rg" {
  count                            = var.velero_enabled ? 1 : 0
  principal_id                     = azurerm_user_assigned_identity.velero[0].id
  role_definition_name             = "Contributor"
  scope                            = azurerm_resource_group.velero[0].id
}
