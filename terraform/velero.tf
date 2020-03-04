# Velero prereqs
# https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure/blob/master/README.md#Create-Azure-storage-account-and-blob-container
resource "azurerm_resource_group" "velero" {
  name     = var.velero_resource_group_name
  location = var.location
  tags     = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_account" "velero" {
  name                     = var.velero_storage_account_name
  resource_group_name      = azurerm_resource_group.velero.name
  location                 = azurerm_resource_group.velero.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_container" "velero" {
  name                  = "velero"
  storage_account_name  = azurerm_storage_account.velero.name
  container_access_type = "private"
}
