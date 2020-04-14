# Velero

# Prereqs
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
  name                      = var.velero_storage_account_name
  resource_group_name       = azurerm_resource_group.velero.name
  location                  = azurerm_resource_group.velero.location
  account_kind              = "BlobStorage"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
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


# Kubernetes
resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
  }
}

resource "helm_release" "velero" {
  chart      = "velero"
  name       = "velero"
  namespace  = "velero"
  repository = data.helm_repository.vmware_tanzu.metadata[0].name
  values     = ["${file("helm/velero_values.yaml")}"]
  version    = "2.9.11"
  set {
    name  = "configuration.backupStorageLocation.config.resourceGroup"
    value = azurerm_resource_group.velero.name
  }
  set {
    name  = "configuration.backupStorageLocation.config.storageAccount"
    value = azurerm_storage_account.velero.name
  }
  set {
    name  = "configuration.volumeSnapshotLocation.config.resourceGroup"
    value = azurerm_resource_group.velero.name
  }
  set {
    name  = "credentials.secretContents.cloud"
    value = var.credentials_velero
  }
  set {
    name  = "configuration.logLevel"
    value = "debug"
  }
}
